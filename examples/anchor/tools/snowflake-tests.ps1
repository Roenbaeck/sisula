<#
    Runs the Snowflake tests: what the perspectives show for rows put straight into the tables, since Snowflake has no
    triggers. For each suite and temporalization it creates a database, runs the SQL generated for the suite's test
    model in it (golden/distinct/_full.sql, or the -bi or -crt one, for the perspectives,
    golden/distinct-equivalence/_full.sql for equivalence, and golden/keys/_full.sql, or the -bi or -crt one, for the
    natural keys), runs the tests (snowflake-tests/<suite>-<t>.sql), queries every view and calls every function in it
    once (snowflake-tests/compile.sql), and drops the database again. It prints the result of every check and exits 1
    if a check failed or something did not run through.

    Snowflake compiles the body of a view or a function only when it is used, so running the generated SQL shows little
    more than its syntax; SQL that Snowflake cannot evaluate, such as a subquery of a kind it does not support, shows
    when a view is queried, and then whatever its rows are. compile.sql is there for that, and the tests for the rows.

    A test script is split into groups at lines that say GO, as sqlcmd does it. Each group is sent as one request, so
    the session variables that it sets (SET s = ...) last until its end and no further. A check inserts a row into
    public.test_result (test, passed, detail), which the script makes; a group that ends with an error counts as a
    failure, and the rest of it is not run.

    The SQL that is run is the golden output, so regenerate it first when Anchor's templates have changed
    (regenerate-golden.ps1 -Variant distinct,distinct-bi,distinct-crt,distinct-equivalence,keys,keys-bi,keys-crt). The tests talk to Snowflake
    through its SQL API with a programmatic access token, made in Snowsight or with ALTER USER ... ADD PROGRAMMATIC
    ACCESS TOKEN, for a role that may create databases. A token needs a network policy, or an authentication policy that
    does not require one (PAT_POLICY = (NETWORK_POLICY_EVALUATION = ENFORCED_NOT_REQUIRED)).

    Usage:
      snowflake-tests.ps1 -Account <identifier> (-Token <token> | -TokenFile <path>) [-Warehouse <name>] [-Role <name>]
                          [-Suite perspectives,equivalence,keys] [-Temporalization uni,bi,crt] [-Keep] [-Prefix <name>]

    The account is its identifier, such as myorg-myaccount, or the host name that Snowsight shows for it; without
    -Account, -Token and -TokenFile the environment variables SNOWFLAKE_ACCOUNT, SNOWFLAKE_TOKEN and
    SNOWFLAKE_TOKEN_FILE are read, and SNOWFLAKE_WAREHOUSE and SNOWFLAKE_ROLE likewise. The databases are called
    <prefix><suite>_<temporalization>, SISULA_PERSPECTIVES_UNI and so on; -Keep leaves them for a closer look, and a
    database left like that is replaced by the next run.
#>
[CmdletBinding()]
param(
    [string] $Account = $env:SNOWFLAKE_ACCOUNT,
    [string] $Token = $env:SNOWFLAKE_TOKEN,
    [string] $TokenFile = $env:SNOWFLAKE_TOKEN_FILE,
    [string] $Warehouse = $env:SNOWFLAKE_WAREHOUSE,
    [string] $Role = $env:SNOWFLAKE_ROLE,
    [string[]] $Suite = @('perspectives', 'equivalence', 'keys'),
    [string[]] $Temporalization = @('uni', 'bi', 'crt'),
    [switch] $Keep,
    [string] $Prefix = 'SISULA_',
    [int] $Timeout = 1800
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

# powershell -File passes "a,b" as one string.
$Suite = @($Suite | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
# the test model of each suite, and the temporalizations that the suite has tests for (equivalence is uni only in
# Anchor's Snowflake templates)
$modelOf = @{ perspectives = 'distinct'; equivalence = 'distinct-equivalence'; keys = 'keys' }
$temporalizationsOf = @{ perspectives = @('uni', 'bi', 'crt'); equivalence = @('uni'); keys = @('uni', 'bi', 'crt') }
foreach ($s in $Suite) {
    if (-not $modelOf.ContainsKey($s)) { throw "Unknown suite '$s': use perspectives, equivalence or keys." }
}
$Temporalization = @($Temporalization | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
foreach ($t in $Temporalization) {
    if (@('uni', 'bi', 'crt') -notcontains $t) { throw "Unknown temporalization '$t': use uni, bi or crt." }
}
if ($Prefix -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { throw "The prefix '$Prefix' has to be a plain name." }
if (-not $Account) { throw 'Give the account with -Account, or in SNOWFLAKE_ACCOUNT.' }
if (-not $Token) {
    if (-not $TokenFile) { throw 'Give a programmatic access token with -Token or -TokenFile, or in SNOWFLAKE_TOKEN or SNOWFLAKE_TOKEN_FILE.' }
    $Token = [IO.File]::ReadAllText($TokenFile).Trim()
}
$Account = $Account.Trim() -replace '^https://', '' -replace '\.snowflakecomputing\.com/?$', ''
$base = "https://$($Account.ToLowerInvariant()).snowflakecomputing.com"
$headers = @{
    Authorization = "Bearer $Token"
    'X-Snowflake-Authorization-Token-Type' = 'PROGRAMMATIC_ACCESS_TOKEN'
    Accept = 'application/json'
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Windows PowerShell reads a response without a charset as ISO-8859-1, and Snowflake's says none, so the bytes are
# decoded here.
function Invoke-Api([string] $method, [string] $uri, [byte[]] $body) {
    $arguments = @{ UseBasicParsing = $true; Method = $method; Uri = $uri; Headers = $headers }
    if ($body) { $arguments.ContentType = 'application/json; charset=utf-8'; $arguments.Body = $body }
    $response = Invoke-WebRequest @arguments
    [Text.Encoding]::UTF8.GetString($response.RawContentStream.ToArray()) | ConvertFrom-Json
}

function Get-Property($object, [string] $name) {
    $property = $object.PSObject.Properties[$name]
    if ($property) { $property.Value }
}

# The rows of a result as arrays of strings; ConvertFrom-Json makes a single row an array of values instead.
function Get-Rows($result) {
    $data = Get-Property $result 'data'
    if (-not $data) { return , @() }
    if ($data[0] -isnot [array]) { return , @(, @($data)) }
    , @($data)
}

# Runs SQL through the SQL API, as many statements as it has, and returns @{ rows; error }: the rows of the last
# statement, or why it failed.
function Invoke-Snowflake([string] $sql, [string] $database) {
    $body = @{ statement = $sql; timeout = $Timeout; parameters = @{ MULTI_STATEMENT_COUNT = '0' } }
    if ($Warehouse) { $body.warehouse = $Warehouse }
    if ($Role) { $body.role = $Role }
    if ($database) { $body.database = $database; $body.schema = 'PUBLIC' }
    $json = $body | ConvertTo-Json -Depth 5
    try {
        $r = Invoke-Api 'Post' "$base/api/v2/statements" ([Text.Encoding]::UTF8.GetBytes($json))
        # a request that runs longer than a while is answered with a handle to ask again with
        while ((Get-Property $r 'statementStatusUrl') -and -not (Get-Property $r 'resultSetMetaData')) {
            Start-Sleep -Seconds 2
            $r = Invoke-Api 'Get' "$base$($r.statementStatusUrl)"
        }
        $handles = Get-Property $r 'statementHandles'
        if ($handles) {
            $r = Invoke-Api 'Get' "$base/api/v2/statements/$(@($handles)[-1])"
        }
        $rows = New-Object System.Collections.Generic.List[object]
        foreach ($row in (Get-Rows $r)) { $rows.Add($row) }
        $partitions = @(Get-Property (Get-Property $r 'resultSetMetaData') 'partitionInfo')
        for ($i = 1; $i -lt $partitions.Count; $i++) {
            $p = Invoke-Api 'Get' "$base/api/v2/statements/$($r.statementHandle)?partition=$i"
            foreach ($row in (Get-Rows $p)) { $rows.Add($row) }
        }
        @{ rows = $rows.ToArray(); error = $null }
    }
    catch {
        $detail = $null
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            try { $detail = (ConvertFrom-Json $_.ErrorDetails.Message).message } catch { $detail = $_.ErrorDetails.Message }
        }
        if (-not $detail) { $detail = $_.Exception.Message }
        @{ rows = @(); error = $detail }
    }
}

function Write-Lines($lines) {
    foreach ($line in $lines) {
        if ($line -match '^FAIL ') { Write-Host "  $line" -ForegroundColor Red }
        elseif ("$line".Trim()) { Write-Host "  $line" }
    }
}

# The schemas that generated SQL puts things in, which have to be there before it runs (PUBLIC always is).
function Get-Schemas([string] $sql) {
    $names = New-Object System.Collections.Generic.List[string]
    $pattern = '(?i)\b(?:TABLE|VIEW|FUNCTION|PROCEDURE|SEQUENCE)\s+(?:IF\s+NOT\s+EXISTS\s+)?("(?:[^"]|"")+"|[A-Za-z_][A-Za-z0-9_$]*)\s*\.|\bCOMMENT\s+ON\s+SCHEMA\s+("(?:[^"]|"")+"|[A-Za-z_][A-Za-z0-9_$]*)'
    foreach ($m in [regex]::Matches($sql, $pattern)) {
        $name = if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value }
        if ($name -notmatch '^"' -and $name -ieq 'public') { continue }
        if (-not $names.Contains($name)) { $names.Add($name) }
    }
    $names
}

# Runs a script of checks, group by group, and returns the lines that tell how it went.
function Invoke-Checks([string] $database, [string] $checksFile) {
    $lines = New-Object System.Collections.Generic.List[string]
    $text = [IO.File]::ReadAllText($checksFile)
    $groups = [regex]::Split($text, '(?im)^[ \t]*GO[ \t]*\r?$')
    foreach ($group in $groups) {
        # a group of nothing but comments is no statement to Snowflake
        $code = [regex]::Replace($group, '(?m)--.*$', '')
        if (-not $code.Trim()) { continue }
        $name = ([regex]::Match($group, '(?m)^--[ \t]*(\S.*?)\s*$')).Groups[1].Value
        if (-not $name) { $name = 'a group without a comment' }
        $r = Invoke-Snowflake $group $database
        if ($r.error) { $lines.Add("FAIL $(Split-Path -Leaf $checksFile): $name did not run through: $($r.error)") }
    }
    $lines
}

$failed = @()
foreach ($s in $Suite) {
    foreach ($t in $Temporalization) {
        if ($temporalizationsOf[$s] -notcontains $t) { continue }
        $suffix = ''
        if ($t -ne 'uni') { $suffix = "-$t" }
        $generated = Join-Path $root "golden\$($modelOf[$s])$suffix\_full.sql"
        $tests = Join-Path $root "snowflake-tests\$s-$t.sql"
        $database = "$Prefix${s}_$t".ToUpperInvariant()
        Write-Host "$s $t`: $database on $Account"

        $sql = [IO.File]::ReadAllText($generated)
        $create = "CREATE OR REPLACE DATABASE $database COMMENT = 'sisula Snowflake tests ($s, $t)';"
        foreach ($schema in (Get-Schemas $sql)) { $create += " CREATE SCHEMA IF NOT EXISTS $database.$schema;" }
        $r = Invoke-Snowflake $create $null
        if ($r.error) {
            Write-Lines @("FAIL the database could not be made: $($r.error)")
            $failed += "$s $t (the database could not be made)"
            continue
        }
        $r = Invoke-Snowflake $sql $database
        if ($r.error) {
            Write-Lines @("FAIL the generated SQL did not run: $($r.error)")
            $failed += "$s $t (the generated SQL did not run)"
        }
        else {
            $lines = New-Object System.Collections.Generic.List[string]
            $r = Invoke-Snowflake 'CREATE OR REPLACE TABLE public.test_result (id int autoincrement order, test varchar not null, passed boolean not null, detail varchar);' $database
            if ($r.error) { $lines.Add("FAIL the table of results could not be made: $($r.error)") }
            else {
                foreach ($line in (Invoke-Checks $database $tests)) { $lines.Add($line) }
                # after the tests, so that the views are queried over rows
                foreach ($line in (Invoke-Checks $database (Join-Path $root 'snowflake-tests\compile.sql'))) { $lines.Add($line) }
                $r = Invoke-Snowflake "SELECT iff(passed, 'PASS ' || test, 'FAIL ' || test || coalesce(': ' || detail, '')) FROM public.test_result ORDER BY id;" $database
                if ($r.error) { $lines.Add("FAIL the results could not be read: $($r.error)") }
                else { foreach ($row in $r.rows) { $lines.Add([string] @($row)[0]) } }
            }
            Write-Lines $lines
            $checks = @($lines | Where-Object { $_ -match '^(PASS|FAIL) ' })
            $failures = @($lines | Where-Object { $_ -match '^FAIL ' })
            Write-Host "  $($checks.Count - $failures.Count) of $($checks.Count) checks passed"
            if ($failures.Count -or -not $checks.Count) { $failed += "$s $t ($($failures.Count) of $($checks.Count) checks failed)" }
        }
        if (-not $Keep) {
            $r = Invoke-Snowflake "DROP DATABASE IF EXISTS $database;" $null
            if ($r.error) { Write-Warning "The database $database was not dropped: $($r.error)" }
        }
    }
}
if ($failed.Count) {
    Write-Host ('Failed: ' + ($failed -join ', ')) -ForegroundColor Red
    exit 1
}
Write-Host 'All checks passed.'
exit 0
