<#
    Runs the SQL Server tests: the trigger tests, the natural key tests, and the trigger tests without decisiveness. For
    each suite and temporalization it creates an empty database, runs the SQL generated for the suite's test model in it
    (golden/sqlserver-triggers/_full.sql or golden/sqlserver-keys/_full.sql, or the -bi or -crt one, and
    golden/sqlserver-indecisive-crt/_full.sql), runs the tests (sqlserver-tests/<suite>-<t>.sql) and drops the database
    again. The indecisive suite is crt only: its model is the crt trigger model with decisiveness off. It prints what
    sqlcmd prints, the result of every check among it, and exits 1 if a check failed or a script did not run through.

    The SQL that is run is the golden output, so regenerate it first when Anchor's templates have changed
    (regenerate-golden.ps1 -Variant sqlserver-triggers,sqlserver-triggers-bi,sqlserver-triggers-crt, the same for
    sqlserver-keys, and sqlserver-indecisive-crt). The tests need SQL Server 2016 or later, sqlcmd (the ODBC one or the
    newer go-sqlcmd), and a login that may create databases.

    Usage:
      sqlserver-tests.ps1 [-Server <name>] [-Suite triggers,keys,indecisive] [-Temporalization uni,bi,crt]
                          [-Username <login> -Password <password>] [-TrustServerCertificate] [-Keep] [-Prefix <name>]
                          [-Sqlcmd <path>]

    Without -Username it signs in with Windows authentication. -TrustServerCertificate is for a server with a
    self-signed certificate, such as a local one. The databases are called <prefix><suite>_<temporalization>,
    sisula_triggers_uni, sisula_keys_uni and so on; -Keep leaves them for a closer look, and a database left like that
    is dropped and made again by the next run.
#>
[CmdletBinding()]
param(
    [string] $Server = 'localhost',
    [string[]] $Suite = @('triggers', 'keys', 'indecisive'),
    [string[]] $Temporalization = @('uni', 'bi', 'crt'),
    [string] $Username,
    [string] $Password,
    [switch] $TrustServerCertificate,
    [switch] $Keep,
    [string] $Prefix = 'sisula_',
    [string] $Sqlcmd = 'sqlcmd'
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

# powershell -File passes "a,b" as one string.
$Suite = @($Suite | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
# the temporalizations that each suite has a model for
$temporalizationsOf = @{ triggers = @('uni', 'bi', 'crt'); keys = @('uni', 'bi', 'crt'); indecisive = @('crt') }
foreach ($s in $Suite) {
    if (-not $temporalizationsOf.ContainsKey($s)) { throw "Unknown suite '$s': use triggers, keys or indecisive." }
}
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

# Runs a script of checks and returns why it failed, or nothing if every check passed.
function Invoke-Checks([string] $database, [string] $checksFile) {
    # without -b, so that every group of checks runs even if one of them stops on an error
    $out = Invoke-SqlcmdLines @('-d', $database, '-I', '-f', '65001', '-h', '-1', '-W', '-i', $checksFile)
    Write-Lines $out
    $checks = @($out | Where-Object { $_ -match '^(PASS|FAIL) ' })
    $failures = @($checks | Where-Object { $_ -match '^FAIL ' })
    $summary = @($out | Where-Object { $_ -match '^\d+ of \d+ checks passed' })
    if ($failures.Count -or -not $checks.Count -or -not $summary.Count) {
        "$($failures.Count) of $($checks.Count) checks failed"
    }
}

$failed = @()
foreach ($s in $Suite) {
    foreach ($t in $Temporalization) {
        if ($temporalizationsOf[$s] -notcontains $t) { continue }
        $suffix = ''
        if ($t -ne 'uni') { $suffix = "-$t" }
        $generated = Join-Path $root "golden\sqlserver-$s$suffix\_full.sql"
        $tests = Join-Path $root "sqlserver-tests\$s-$t.sql"
        $database = "$Prefix${s}_$t"
        Write-Host "$s $t`: $database on $Server"

        $drop = "IF DB_ID(N'$database') IS NOT NULL BEGIN ALTER DATABASE [$database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$database]; END;"
        $out = Invoke-SqlcmdLines @('-b', '-Q', "$drop CREATE DATABASE [$database];")
        if ($LASTEXITCODE -ne 0) {
            Write-Lines $out
            $failed += "$s $t (the database could not be made)"
            continue
        }
        $out = Invoke-SqlcmdLines @('-d', $database, '-b', '-I', '-f', '65001', '-i', $generated)
        if ($LASTEXITCODE -ne 0) {
            Write-Lines ($out | Select-Object -Last 20)
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
                $out = Invoke-SqlcmdLines @('-d', $database, '-b', '-I', '-f', '65001', '-i', $upgrade)
                if ($LASTEXITCODE -ne 0) {
                    Write-Lines ($out | Select-Object -Last 20)
                    $failed += "$s $t (the upgrade script did not run)"
                }
                else {
                    $out = Invoke-SqlcmdLines @('-d', $database, '-b', '-I', '-f', '65001', '-i', $generated)
                    if ($LASTEXITCODE -ne 0) {
                        Write-Lines ($out | Select-Object -Last 20)
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
            $out = Invoke-SqlcmdLines @('-b', '-Q', $drop)
            if ($LASTEXITCODE -ne 0) {
                Write-Lines $out
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
