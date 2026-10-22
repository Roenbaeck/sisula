<#
    Runs the SQL Server tests: the trigger tests, the natural key tests, and the trigger tests without decisiveness. For
    each suite and temporalization it creates an empty database, runs the SQL generated for the suite's test model in it
    (golden/sqlserver-triggers/_full.sql or golden/sqlserver-keys/_full.sql, or the -bi or -crt one, and
    golden/sqlserver-indecisive-crt/_full.sql), runs the tests (sqlserver-tests/<suite>-<t>.sql) and drops the database
    again. The indecisive suite is crt only: its model is the crt trigger model with decisiveness off. The deploy suite
    runs the SQL generated for every SQL Server model of the temporalization (the handwritten ones left out), each in an
    empty database, and says for each whether it ran through; a model with the original naming and two attributes on one
    knot fails as is known (KNOWN), since that naming cannot have it. It prints what the scripts print, the result of every
    check among it, and exits 1 if a check failed or a script did not run through.

    The SQL that is run is the golden output, so regenerate it first when Anchor's templates have changed
    (regenerate-golden.ps1 -Variant sqlserver-triggers,sqlserver-triggers-bi,sqlserver-triggers-crt, the same for
    sqlserver-keys, and sqlserver-indecisive-crt). The tests need SQL Server 2014 or later and a login that may create
    databases. They run the scripts with sqlcmd (the ODBC one or the newer go-sqlcmd) when there is one, and otherwise,
    or with -SqlClient, with the SqlClient of the .NET Framework, which Windows PowerShell has: one connection for each
    script, the batches split at the lines that say GO, and rows, messages and errors printed as sqlcmd prints them.

    Usage:
      sqlserver-tests.ps1 [-Server <name>] [-Suite triggers,keys,indecisive,deploy] [-Temporalization uni,bi,crt]
                          [-Username <login> -Password <password>] [-TrustServerCertificate] [-Keep] [-Prefix <name>]
                          [-Sqlcmd <path> | -SqlClient]

    Without -Username it signs in with Windows authentication. -TrustServerCertificate is for a server with a
    self-signed or expired certificate, such as a local one. The databases are called <prefix><suite>_<temporalization>,
    sisula_triggers_uni, sisula_keys_uni and so on; -Keep leaves them for a closer look, and a database left like that
    is dropped and made again by the next run.
#>
[CmdletBinding()]
param(
    [string] $Server = 'localhost',
    [string[]] $Suite = @('triggers', 'keys', 'indecisive', 'deploy'),
    [string[]] $Temporalization = @('uni', 'bi', 'crt'),
    [string] $Username,
    [string] $Password,
    [switch] $TrustServerCertificate,
    [switch] $Keep,
    [string] $Prefix = 'sisula_',
    [string] $Sqlcmd = 'sqlcmd',
    [switch] $SqlClient
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

# powershell -File passes "a,b" as one string.
$Suite = @($Suite | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
# the temporalizations that each suite has a model for
$temporalizationsOf = @{ triggers = @('uni', 'bi', 'crt'); keys = @('uni', 'bi', 'crt'); indecisive = @('crt'); deploy = @('uni', 'bi', 'crt') }
foreach ($s in $Suite) {
    if (-not $temporalizationsOf.ContainsKey($s)) { throw "Unknown suite '$s': use triggers, keys, indecisive or deploy." }
}
$Temporalization = @($Temporalization | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
foreach ($t in $Temporalization) {
    if (@('uni', 'bi', 'crt') -notcontains $t) { throw "Unknown temporalization '$t': use uni, bi or crt." }
}
if ($Prefix -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { throw "The prefix '$Prefix' has to be a plain name." }
if (-not $SqlClient -and -not (Get-Command $Sqlcmd -ErrorAction SilentlyContinue)) {
    if ($PSBoundParameters.ContainsKey('Sqlcmd')) { throw "$Sqlcmd was not found: give the path of sqlcmd, or use -SqlClient." }
    Write-Host 'There is no sqlcmd here, so the scripts are run with the SqlClient of the .NET Framework.'
    $SqlClient = [switch] $true
}

$connection = @('-S', $Server)
if ($Username) { $connection += @('-U', $Username, '-P', $Password) } else { $connection += '-E' }
if ($TrustServerCertificate) { $connection += '-C' }

# Runs sqlcmd and returns what it printed, errors included, as lines; $LASTEXITCODE is what it returned.
function Invoke-SqlcmdLines([string[]] $arguments) {
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'   # what sqlcmd writes to stderr is output here, not a PowerShell error
    try { @(& $Sqlcmd @connection @arguments 2>&1 | ForEach-Object { "$_" }) }
    finally { $ErrorActionPreference = $saved }
}

# Runs SQL with the SqlClient of the .NET Framework, as sqlcmd runs a script: in one session, batch by batch, with a
# row as its values separated by spaces, a message as it is, and an error as sqlcmd shows it. An error does not end its
# batch, as in sqlcmd; with $stopOnError (sqlcmd -b) no batch after it is run.
function Invoke-SqlClientLines([string] $database, [string] $sql, [bool] $stopOnError) {
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder['Data Source'] = $Server
    $builder['Initial Catalog'] = $(if ($database) { $database } else { 'master' })
    if ($Username) { $builder['User ID'] = $Username; $builder['Password'] = $Password } else { $builder['Integrated Security'] = $true }
    if ($TrustServerCertificate) { $builder['Encrypt'] = $true; $builder['TrustServerCertificate'] = $true }
    # a pooled connection would keep a test database in use after the script
    $builder['Pooling'] = $false
    $builder['Application Name'] = 'sisula sqlserver-tests'
    $lines = New-Object System.Collections.Generic.List[string]
    $state = @{ failed = $false; batchFailed = $false }
    $add = {
        param($sqlError)
        if ($sqlError.Class -gt 10) {
            $lines.Add("Msg $($sqlError.Number), Level $($sqlError.Class), State $($sqlError.State), Server $($sqlError.Server), Line $($sqlError.LineNumber)")
            $state.failed = $true; $state.batchFailed = $true
        }
        $lines.Add($sqlError.Message)
    }.GetNewClosure()
    $connectionObject = New-Object System.Data.SqlClient.SqlConnection $builder.ConnectionString
    # errors up to severity 16 arrive as messages, so that the batch goes on, as it does in sqlcmd
    $connectionObject.FireInfoMessageEventOnUserErrors = $true
    $connectionObject.add_InfoMessage({ param($source, $e) foreach ($sqlError in $e.Errors) { & $add $sqlError } }.GetNewClosure())
    try {
        $connectionObject.Open()
        foreach ($batch in [regex]::Split($sql, '(?im)^[ \t]*GO[ \t]*(?:--[^\r\n]*)?\r?$')) {
            if (-not $batch.Trim()) { continue }
            $state.batchFailed = $false
            $command = $connectionObject.CreateCommand()
            # without the line end of the GO before it, so that the lines of an error count from the batch's first
            $command.CommandText = $batch -replace '^\r?\n', ''
            $command.CommandTimeout = 0
            try {
                $reader = $command.ExecuteReader()
                try {
                    do {
                        while ($reader.Read()) {
                            $values = New-Object object[] $reader.FieldCount
                            [void] $reader.GetValues($values)
                            $lines.Add((($values | ForEach-Object { if ($_ -is [DBNull]) { 'NULL' } else { "$_" } }) -join ' '))
                        }
                    } while ($reader.NextResult())
                }
                finally { $reader.Close() }
            }
            catch [System.Data.SqlClient.SqlException] {
                foreach ($sqlError in $_.Exception.Errors) { & $add $sqlError }
                $state.failed = $true; $state.batchFailed = $true
            }
            if ($state.batchFailed -and $stopOnError) { break }
        }
    }
    catch {
        $lines.Add("$($_.Exception.Message)")
        $state.failed = $true
    }
    finally { $connectionObject.Dispose() }
    @{ lines = $lines.ToArray(); failed = $state.failed }
}

# Runs a script file, or SQL given as text, and returns @{ lines; failed }: what was printed, and whether it failed
# (with $stopOnError: an error stopped it, as sqlcmd -b does). $plain prints rows without headers or padding (-h -1 -W).
function Invoke-Sql([string] $database, [string] $file, [string] $query, [bool] $stopOnError, [bool] $plain) {
    if ($SqlClient) {
        $sql = if ($file) { [IO.File]::ReadAllText($file, [Text.Encoding]::UTF8) } else { $query }
        return Invoke-SqlClientLines $database $sql $stopOnError
    }
    $arguments = @()
    if ($database) { $arguments += @('-d', $database) }
    if ($stopOnError) { $arguments += '-b' }
    if ($file) { $arguments += @('-I', '-f', '65001') }
    if ($plain) { $arguments += @('-h', '-1', '-W') }
    if ($file) { $arguments += @('-i', $file) } else { $arguments += @('-Q', $query) }
    $lines = Invoke-SqlcmdLines $arguments
    @{ lines = $lines; failed = ($LASTEXITCODE -ne 0) }
}

function Write-Lines($lines) {
    foreach ($line in $lines) {
        if ($line -match '^FAIL ') { Write-Host "  $line" -ForegroundColor Red }
        elseif ($line.Trim()) { Write-Host "  $line" }
    }
}

# Runs a script of checks and returns why it failed, or nothing if every check passed.
function Invoke-Checks([string] $database, [string] $checksFile) {
    # not stopped by an error, so that every group of checks runs even if one of them stops on an error
    $out = (Invoke-Sql $database $checksFile $null $false $true).lines
    Write-Lines $out
    $checks = @($out | Where-Object { $_ -match '^(PASS|FAIL) ' })
    $failures = @($checks | Where-Object { $_ -match '^FAIL ' })
    $summary = @($out | Where-Object { $_ -match '^\d+ of \d+ checks passed' })
    if ($failures.Count -or -not $checks.Count -or -not $summary.Count) {
        "$($failures.Count) of $($checks.Count) checks failed"
    }
}

# Runs the generated SQL of every SQL Server model of a temporalization, each in an empty database, and returns a PASS or
# FAIL line for each. The SQL does not create the schemas of the capsules, which are a user's to make, so they are made
# first; and the placeholder of the encryption password, which the modeler writes for a user to replace, is replaced by
# a password that a password policy takes.
function Invoke-Deploy([string] $t) {
    $lines = New-Object System.Collections.Generic.List[string]
    $database = "${Prefix}deploy_$t"
    $drop = "IF DB_ID(N'$database') IS NOT NULL BEGIN ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$database]; END;"
    $models = @(Get-ChildItem (Join-Path $root 'golden') -Directory | Where-Object {
        $_.Name -like 'sqlserver-*' -and $_.Name -notlike 'sqlserver-handwritten*' -and
        $(if ($_.Name -match '-(bi|crt)$') { $Matches[1] } else { 'uni' }) -eq $t
    } | Sort-Object Name)
    foreach ($model in $models) {
        $sql = [IO.File]::ReadAllText((Join-Path $model.FullName '_full.sql'), [Text.Encoding]::UTF8)
        $r = Invoke-Sql $null $null "$drop CREATE DATABASE [$database];" $true $false
        if ($r.failed) { $lines.Add("FAIL deploy $($model.Name): the database could not be made: $($r.lines -join ' ')"); continue }
        $schemas = @([regex]::Matches($sql, '(?i)\bCREATE\s+(?:TABLE|VIEW|FUNCTION|PROCEDURE|TRIGGER|SEQUENCE)\s+\[?(\w+)\]?\s*\.') |
            ForEach-Object { $_.Groups[1].Value } | Where-Object { @('dbo', 'sys') -notcontains $_ } | Sort-Object -Unique)
        if ($schemas.Count) {
            $r = Invoke-Sql $database $null (($schemas | ForEach-Object { "EXEC('CREATE SCHEMA [$_]');" }) -join ' ') $true $false
            if ($r.failed) { $lines.Add("FAIL deploy $($model.Name): the schemas could not be made: $($r.lines -join ' ')"); continue }
        }
        $file = [IO.Path]::GetTempFileName()
        try {
            [IO.File]::WriteAllText($file, $sql.Replace("'<TYPE STRONG PASSWORD HERE>'", "'Sisula-test-$([guid]::NewGuid())'"), (New-Object Text.UTF8Encoding($false)))
            $r = Invoke-Sql $database $file $null $true $false
        }
        finally { Remove-Item $file -ErrorAction SilentlyContinue }
        if ($r.failed) {
            $first = @($r.lines | Where-Object { $_ -match '^Msg ' } | Select-Object -First 1)
            $at = if ($first.Count) { [array]::IndexOf($r.lines, $first[0]) } else { -1 }
            $why = if ($at -ge 0 -and $at + 1 -lt $r.lines.Count) { "$($r.lines[$at]) $($r.lines[$at + 1])" } else { ($r.lines | Select-Object -Last 2) -join ' ' }
            # the original naming cannot have two attributes on one knot (Anchor's docs/ANCHOR.md, "Generated objects and
            # naming"), and some models have that on purpose
            $modelFile = Join-Path $root "models\$($model.Name).xml"
            $original = (Test-Path $modelFile) -and ([IO.File]::ReadAllText($modelFile) -match '<metadata[^>]*\bnaming="original"')
            if ($original -and $why -match '^Msg (4506|8156),') { $lines.Add("KNOWN deploy $($model.Name), with the original naming and two attributes on one knot: $why") }
            else { $lines.Add("FAIL deploy $($model.Name): $why") }
        }
        else { $lines.Add("PASS deploy $($model.Name)") }
    }
    if (-not $Keep) { [void] (Invoke-Sql $null $null $drop $true $false) }
    $lines
}

$failed = @()
foreach ($s in $Suite) {
    foreach ($t in $Temporalization) {
        if ($temporalizationsOf[$s] -notcontains $t) { continue }
        if ($s -eq 'deploy') {
            Write-Host "deploy $t`: the generated SQL of every SQL Server model, on $Server"
            $lines = @(Invoke-Deploy $t)
            Write-Lines $lines
            $failures = @($lines | Where-Object { $_ -match '^FAIL ' })
            $known = @($lines | Where-Object { $_ -match '^KNOWN ' })
            Write-Host "  $($lines.Count - $failures.Count - $known.Count) of $($lines.Count) models ran through, $($known.Count) did not as known"
            if ($failures.Count) { $failed += "deploy $t ($($failures.Count) of $($lines.Count) models did not run through)" }
            continue
        }
        $suffix = ''
        if ($t -ne 'uni') { $suffix = "-$t" }
        $generated = Join-Path $root "golden\sqlserver-$s$suffix\_full.sql"
        $tests = Join-Path $root "sqlserver-tests\$s-$t.sql"
        $database = "$Prefix${s}_$t"
        Write-Host "$s $t`: $database on $Server"

        $drop = "IF DB_ID(N'$database') IS NOT NULL BEGIN ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$database]; END;"
        $r = Invoke-Sql $null $null "$drop CREATE DATABASE [$database];" $true $false
        if ($r.failed) {
            Write-Lines $r.lines
            $failed += "$s $t (the database could not be made)"
            continue
        }
        $r = Invoke-Sql $database $generated $null $true $false
        if ($r.failed) {
            Write-Lines ($r.lines | Select-Object -Last 20)
            $failed += "$s $t (the generated SQL did not run)"
        }
        else {
            $why = Invoke-Checks $database $tests
            if ($why) { $failed += "$s $t ($why)" }
            # An upgrade: <suite>-<t>-upgrade.sql makes the database look like one that older generated SQL made, the
            # generated SQL runs again on it, as it does when a changed model is generated again, and
            # <suite>-<t>-upgraded.sql checks the result.
            $upgrade = Join-Path $root "sqlserver-tests\$s-$t-upgrade.sql"
            if (Test-Path $upgrade) {
                Write-Host "$s $t`: upgrade"
                $r = Invoke-Sql $database $upgrade $null $true $false
                if ($r.failed) {
                    Write-Lines ($r.lines | Select-Object -Last 20)
                    $failed += "$s $t (the upgrade script did not run)"
                }
                else {
                    $r = Invoke-Sql $database $generated $null $true $false
                    if ($r.failed) {
                        Write-Lines ($r.lines | Select-Object -Last 20)
                        $failed += "$s $t (the generated SQL did not run again)"
                    }
                    else {
                        $why = Invoke-Checks $database (Join-Path $root "sqlserver-tests\$s-$t-upgraded.sql")
                        if ($why) { $failed += "$s $t upgraded ($why)" }
                    }
                }
            }
        }
        if (-not $Keep) {
            $r = Invoke-Sql $null $null $drop $true $false
            if ($r.failed) {
                Write-Lines $r.lines
                Write-Warning "The database $database was not dropped."
            }
        }
    }
}
if ($failed.Count) {
    Write-Host ('Failed: ' + ($failed -join ', ')) -ForegroundColor Red
    exit 1
}
Write-Host 'All checks passed.'
exit 0
