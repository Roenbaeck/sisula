<#
    Runs the PostgreSQL tests: what the perspectives show for rows put straight into the tables (suite perspectives), what the
    triggers store for inserts, updates and deletes through the views (suite triggers, and indecisive for crt without
    decisiveness), what equivalence does (suite equivalence, uni) and whether every model deploys (suite deploy). For each suite
    and temporalization it creates a database on a PostgreSQL server, runs the SQL generated for the suite's test model in it
    (golden/postgresql-distinct-bi/_full.sql, or the -crt one, or postgresql-triggers-*), runs the tests
    (postgres-tests/<suite>-<t>.sql), queries every view and calls every function in it once (postgres-tests/compile.sql), and
    drops the database again. It prints the result of every check and exits 1 if a check failed or something did not run through.

    The models of the tests have text where Snowflake's have geography: PostGIS is not part of a plain server (make-target-models.ps1
    -Types). Every model that the generators are tested on is also deployed (-Suite deploy): its whole script is run in a new
    database, and what PostgreSQL says about it is a finding. The models with the original naming (plain) are KNOWN to fail, since
    two attributes of one anchor on the same knot give a perspective two columns of one name, which no database takes (see
    ANCHOR.md, "Generated objects and naming").

    A test script is split into groups at lines that say GO, as sqlcmd does it, and each group is sent to psql on its own; a group
    that ends with an error counts as a failure. A check inserts a row into public.test_result (test, passed, detail), which the
    script makes.

    The SQL that is run is the golden output, so regenerate it first when Anchor's templates have changed
    (regenerate-golden.ps1 -Variant postgresql-distinct-bi,postgresql-distinct-crt).

    Usage:
      postgres-tests.ps1 [-Psql <psql.exe>] [-Server 127.0.0.1] [-Port 5432] [-User postgres] [-Password <password>]
                         [-Suite perspectives,triggers,indecisive,deploy] [-Temporalization bi,crt] [-Keep] [-Prefix <name>]

    psql is looked for on the path, or in the environment variable POSTGRES_PSQL; the server, the port, the user and the password in
    PGHOST, PGPORT, PGUSER and PGPASSWORD. The user has to be allowed to make databases. The databases are called
    <prefix><suite>_<temporalization>, sisula_perspectives_bi and so on; -Keep leaves them for a closer look, and a database left
    like that is replaced by the next run.
#>
[CmdletBinding()]
param(
    [string] $Psql = $env:POSTGRES_PSQL,
    [string] $Server = $(if ($env:PGHOST) { $env:PGHOST } else { '127.0.0.1' }),
    [int] $Port = $(if ($env:PGPORT) { [int] $env:PGPORT } else { 5432 }),
    [string] $User = $(if ($env:PGUSER) { $env:PGUSER } else { 'postgres' }),
    [string] $Password = $env:PGPASSWORD,
    [string[]] $Suite = @('perspectives', 'equivalence', 'triggers', 'indecisive', 'deploy'),
    [string[]] $Temporalization = @('uni', 'bi', 'crt'),
    [switch] $Keep,
    [string] $Prefix = 'sisula_'
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$Suite = @($Suite | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Temporalization = @($Temporalization | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
foreach ($s in $Suite) { if (@('perspectives', 'equivalence', 'triggers', 'indecisive', 'deploy') -notcontains $s) { throw "Unknown suite '$s': use perspectives, equivalence, triggers, indecisive or deploy." } }
foreach ($t in $Temporalization) { if (@('uni', 'bi', 'crt') -notcontains $t) { throw "Unknown temporalization '$t': use uni, bi or crt." } }
if ($Prefix -notmatch '^[a-z_][a-z0-9_]*$') { throw "The prefix '$Prefix' has to be a plain name in lower case." }
if (-not $Psql) { $found = Get-Command psql -ErrorAction SilentlyContinue; if ($found) { $Psql = $found.Source } }
if (-not $Psql -or -not (Test-Path $Psql)) { throw 'psql was not found: put it on the path, or give it with -Psql or POSTGRES_PSQL.' }
if ($Password) { $env:PGPASSWORD = $Password }
$env:PGOPTIONS = '-c lc_messages=C'   # the messages in English, whatever the server speaks

# Runs SQL (a string) with psql, in a database; returns the lines that psql wrote, the errors among them marked.
function Invoke-Psql([string] $sql, [string] $database = 'postgres', [string] $file) {
    $arguments = @('-h', $Server, '-p', $Port, '-U', $User, '-d', $database, '-X', '-q', '-t', '-A', '-v', 'ON_ERROR_STOP=0')
    $temporary = $false
    if (-not $file) {
        $file = [IO.Path]::GetTempFileName()
        [IO.File]::WriteAllText($file, $sql, (New-Object Text.UTF8Encoding($false)))
        $temporary = $true
    }
    try {
        $arguments += @('-f', $file)
        $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        $output = & $Psql @arguments 2>&1 | ForEach-Object { "$_" }
        $ErrorActionPreference = $previous
        , @($output)
    }
    finally { if ($temporary) { Remove-Item $file -ErrorAction SilentlyContinue } }
}
function Get-Errors($output) {
    @($output | Where-Object { $_ -match 'ERROR:' } | ForEach-Object { ($_ -replace '^psql:[^:]*:\d+: ', '') -replace '^ERROR:\s+', '' })
}

function Invoke-Checks([string] $database, [string] $checksFile) {
    $lines = New-Object System.Collections.Generic.List[string]
    $text = [IO.File]::ReadAllText($checksFile, [Text.Encoding]::UTF8) -replace "`r`n", "`n"
    foreach ($group in [regex]::Split($text, '(?m)^GO[ \t]*$')) {
        $code = [regex]::Replace($group, '(?m)--.*$', '')
        if (-not $code.Trim()) { continue }
        $name = ([regex]::Match($group, '(?m)^--[ \t]*(\S.*?)\s*$')).Groups[1].Value
        if (-not $name) { $name = 'a group without a comment' }
        $output = Invoke-Psql $group $database
        foreach ($e in (Get-Errors $output)) { $lines.Add("FAIL $(Split-Path -Leaf $checksFile): $name did not run through: $e") }
    }
    $lines
}

$failed = @()
$known = @('postgresql-plain', 'postgresql-plain-bi', 'postgresql-plain-crt')   # the original naming
$jobs = @()
foreach ($s in $Suite) {
    foreach ($t in $Temporalization) {
        $suffix = ''
        if ($t -ne 'uni') { $suffix = "-$t" }
        if ($s -eq 'perspectives') { $jobs += [pscustomobject]@{ Suite = $s; T = $t; Models = @("postgresql-distinct$suffix") } }
        elseif ($s -eq 'triggers') { $jobs += [pscustomobject]@{ Suite = $s; T = $t; Models = @("postgresql-triggers$suffix") } }
        elseif ($s -eq 'indecisive') { if ($t -eq 'crt') { $jobs += [pscustomobject]@{ Suite = $s; T = $t; Models = @('postgresql-indecisive-crt') } } }
        elseif ($s -eq 'equivalence') { if ($t -eq 'uni') { $jobs += [pscustomobject]@{ Suite = $s; T = $t; Models = @('postgresql-distinct-equivalence') } } }
        else {
            $names = Get-ChildItem (Join-Path $root 'models') -Filter 'postgresql-*.xml' | Sort-Object Name | ForEach-Object { $_.BaseName }
            if ($t -eq 'uni') { $names = @($names | Where-Object { $_ -notmatch '-(bi|crt)$' }) } else { $names = @($names | Where-Object { $_ -match "-$t`$" }) }
            $jobs += [pscustomobject]@{ Suite = $s; T = $t; Models = @($names) }
        }
    }
}
foreach ($job in $jobs) {
    foreach ($model in $job.Models) {
        $label = "$($job.Suite) $($job.T)"
        if ($job.Suite -eq 'deploy') { $label = "deploy $model" }
        $database = ("$Prefix$($job.Suite)_$model" -replace '[^a-z0-9_]', '_')
        if ($database.Length -gt 63) { $database = $database.Substring(0, 63) }
        Write-Host "$label`: $database on $Server"
        $generated = Join-Path $root "golden\$model\_full.sql"
        $r = Invoke-Psql "DROP DATABASE IF EXISTS $database;"
        $r = Invoke-Psql "CREATE DATABASE $database;"
        $errors = @(Get-Errors $r)
        if ($errors.Count) { Write-Host "  FAIL the database could not be made: $($errors[0])"; $failed += "$label (the database could not be made)"; continue }
        $output = Invoke-Psql '' $database $generated
        $errors = @(Get-Errors $output)
        if ($job.Suite -eq 'deploy') {
            if ($errors.Count -eq 0) { Write-Host "  PASS $model deploys" }
            elseif ($known -contains $model) { Write-Host "  KNOWN $model does not deploy ($($errors.Count) errors; the original naming): $($errors[0])" }
            else { $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  FAIL $_" }; $failed += "$label ($($errors.Count) errors)" }
        }
        elseif ($errors.Count) {
            $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  FAIL the generated SQL did not run: $_" }
            $failed += "$label (the generated SQL did not run)"
        }
        else {
            $lines = New-Object System.Collections.Generic.List[string]
            $r = Invoke-Psql 'CREATE TABLE public.test_result (id serial, test varchar not null, passed boolean not null, detail varchar);' $database
            foreach ($line in (Invoke-Checks $database (Join-Path $root "postgres-tests\$($job.Suite)-$($job.T).sql"))) { $lines.Add($line) }
            # after the tests, so that the views are queried over rows
            foreach ($line in (Invoke-Checks $database (Join-Path $root 'postgres-tests\compile.sql'))) { $lines.Add($line) }
            $r = Invoke-Psql "SELECT CASE WHEN passed THEN 'PASS ' || test ELSE 'FAIL ' || test || coalesce(': ' || detail, '') END FROM public.test_result ORDER BY id;" $database
            foreach ($row in $r) { if ($row -match '^(PASS|FAIL) ') { $lines.Add($row) } }
            foreach ($l in $lines) { Write-Host "  $l" }
            $checks = @($lines | Where-Object { $_ -match '^(PASS|FAIL) ' })
            $failures = @($lines | Where-Object { $_ -match '^FAIL ' })
            Write-Host "  $($checks.Count - $failures.Count) of $($checks.Count) checks passed"
            if ($failures.Count -or -not $checks.Count) { $failed += "$label ($($failures.Count) of $($checks.Count) checks failed)" }
        }
        if (-not $Keep) { $r = Invoke-Psql "DROP DATABASE IF EXISTS $database;" }
    }
}
if ($failed.Count) {
    Write-Host ('Failed: ' + ($failed -join ', ')) -ForegroundColor Red
    exit 1
}
Write-Host 'All checks passed.'
exit 0
