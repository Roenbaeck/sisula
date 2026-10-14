<#
    Runs the trigger tests on SQL Server. For each temporalization it creates an empty database, runs the SQL generated
    for the test model in it (golden/sqlserver-triggers/_full.sql, or the -bi or -crt one), runs the tests
    (sqlserver-tests/triggers-<t>.sql) and drops the database again. It prints what sqlcmd prints, the result of every
    check among it, and exits 1 if a check failed or a script did not run through.

    The SQL that is run is the golden output, so regenerate it first when Anchor's templates have changed
    (regenerate-golden.ps1 -Variant sqlserver-triggers,sqlserver-triggers-bi,sqlserver-triggers-crt). The tests need SQL Server
    2016 or later, sqlcmd (the ODBC one or the newer go-sqlcmd), and a login that may create databases.

    Usage:
      sqlserver-tests.ps1 [-Server <name>] [-Temporalization uni,bi,crt] [-Username <login> -Password <password>]
                          [-TrustServerCertificate] [-Keep] [-Prefix <name>] [-Sqlcmd <path>]

    Without -Username it signs in with Windows authentication. -TrustServerCertificate is for a server with a
    self-signed certificate, such as a local one. The databases are called <prefix><temporalization>,
    sisula_triggers_uni and so on; -Keep leaves them for a closer look, and a database left like that is dropped and
    made again by the next run.
#>
[CmdletBinding()]
param(
    [string] $Server = 'localhost',
    [string[]] $Temporalization = @('uni', 'bi', 'crt'),
    [string] $Username,
    [string] $Password,
    [switch] $TrustServerCertificate,
    [switch] $Keep,
    [string] $Prefix = 'sisula_triggers_',
    [string] $Sqlcmd = 'sqlcmd'
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

# powershell -File passes "a,b" as one string.
$Temporalization = @($Temporalization | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
foreach ($t in $Temporalization) {
    if (@('uni', 'bi', 'crt') -notcontains $t) { throw "Unknown temporalization '$t': use uni, bi or crt." }
}
if ($Prefix -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { throw "The prefix '$Prefix' has to be a plain name." }
if (-not (Get-Command $Sqlcmd -ErrorAction SilentlyContinue)) { throw "$Sqlcmd was not found: install sqlcmd, or give its path with -Sqlcmd." }

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

function Write-Lines($lines) {
    foreach ($line in $lines) {
        if ($line -match '^FAIL ') { Write-Host "  $line" -ForegroundColor Red }
        elseif ($line.Trim()) { Write-Host "  $line" }
    }
}

$failed = @()
foreach ($t in $Temporalization) {
    $suffix = ''
    if ($t -ne 'uni') { $suffix = "-$t" }
    $generated = Join-Path $root "golden\sqlserver-triggers$suffix\_full.sql"
    $tests = Join-Path $root "sqlserver-tests\triggers-$t.sql"
    $database = "$Prefix$t"
    Write-Host "$t`: $database on $Server"

    $drop = "IF DB_ID(N'$database') IS NOT NULL BEGIN ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$database]; END;"
    $out = Invoke-SqlcmdLines @('-b', '-Q', "$drop CREATE DATABASE [$database];")
    if ($LASTEXITCODE -ne 0) {
        Write-Lines $out
        $failed += "$t (the database could not be made)"
        continue
    }
    $out = Invoke-SqlcmdLines @('-d', $database, '-b', '-I', '-f', '65001', '-i', $generated)
    if ($LASTEXITCODE -ne 0) {
        Write-Lines ($out | Select-Object -Last 20)
        $failed += "$t (the generated SQL did not run)"
    }
    else {
        # without -b, so that every group of checks runs even if one of them stops on an error
        $out = Invoke-SqlcmdLines @('-d', $database, '-I', '-f', '65001', '-h', '-1', '-W', '-i', $tests)
        Write-Lines $out
        $checks = @($out | Where-Object { $_ -match '^(PASS|FAIL) ' })
        $failures = @($checks | Where-Object { $_ -match '^FAIL ' })
        $summary = @($out | Where-Object { $_ -match '^\d+ of \d+ checks passed' })
        if ($failures.Count -or -not $checks.Count -or -not $summary.Count) {
            $failed += "$t ($($failures.Count) of $($checks.Count) checks failed)"
        }
    }
    if (-not $Keep) {
        $out = Invoke-SqlcmdLines @('-b', '-Q', $drop)
        if ($LASTEXITCODE -ne 0) {
            Write-Lines $out
            Write-Warning "The database $database was not dropped."
        }
    }
}
if ($failed.Count) {
    Write-Host ('Failed: ' + ($failed -join ', ')) -ForegroundColor Red
    exit 1
}
Write-Host 'All trigger checks passed.'
exit 0
