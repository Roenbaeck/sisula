<#
    Compares the SQL that the modeler generated before and after a change, per target, ignoring only white space: every line is
    trimmed, runs of white space inside it become one space, and empty lines are left out. It is for a change that is meant to give
    the same SQL in another form, such as a port of the original sisulets in JavaScript to Sisula templates.

    The SQL comes from browser-check.ps1 -Targets -KeepOutput <directory>, which writes <Database>_<temporalization>.sql for every
    target (Anchor's example.xml, with the data types converted to the database). Make the "before" directory first, from the
    checkout as it was, and the "after" directory from the checkout as it is.

    Usage:
      compare-sql.ps1 -Before <directory> -After <directory> [-Name Oracle_uni,Oracle_crt] [-Show <n>]

    For each name it says IDENTICAL, or how many lines differ and shows the first <n> places (default 12) with the lines of both sides.
    Exits 1 if anything differs.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $Before,
    [Parameter(Mandatory = $true)] [string] $After,
    [string[]] $Name,
    [int] $Show = 12
)
Set-StrictMode -Version 2.0
$utf8 = New-Object Text.UTF8Encoding($false)
$Name = @($Name | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
if ($Name.Count -eq 0) {
    $Name = @(Get-ChildItem $Before -Filter *.sql | ForEach-Object { $_.BaseName })
}

function Get-Lines([string] $path) {
    $text = [IO.File]::ReadAllText($path, $utf8)
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($l in ($text -split "`r?`n")) {
        $t = ([regex]::Replace($l.Trim(), '\s+', ' '))
        if ($t.Length -gt 0) { $lines.Add($t) }
    }
    , $lines
}

$different = 0
foreach ($n in $Name) {
    $b = Join-Path $Before "$n.sql"; $a = Join-Path $After "$n.sql"
    if (-not (Test-Path $b) -or -not (Test-Path $a)) { Write-Host "MISSING  $n"; $different++; continue }
    $x = Get-Lines $b; $y = Get-Lines $a
    # a line-by-line walk that skips ahead to the next line that both sides have, so that one inserted line is one difference
    $i = 0; $j = 0; $diffs = New-Object System.Collections.Generic.List[string]; $count = 0
    while ($i -lt $x.Count -or $j -lt $y.Count) {
        if ($i -lt $x.Count -and $j -lt $y.Count -and $x[$i] -ceq $y[$j]) { $i++; $j++; continue }
        $count++
        if ($diffs.Count -lt $Show) { $diffs.Add(("  before {0}: {1}`n  after  {2}: {3}" -f ($i + 1), $(if ($i -lt $x.Count) { $x[$i] } else { '(end)' }), ($j + 1), $(if ($j -lt $y.Count) { $y[$j] } else { '(end)' }))) }
        # resynchronize: look a few lines ahead on either side for the line that the other side is at
        $found = $false
        for ($k = 1; $k -le 40 -and -not $found; $k++) {
            if ($i + $k -lt $x.Count -and $j -lt $y.Count -and $x[$i + $k] -ceq $y[$j]) { $i += $k; $found = $true }
            elseif ($j + $k -lt $y.Count -and $i -lt $x.Count -and $y[$j + $k] -ceq $x[$i]) { $j += $k; $found = $true }
        }
        if (-not $found) { $i++; $j++ }
    }
    if ($count -eq 0) { Write-Host ("IDENTICAL  {0}: {1} lines" -f $n, $x.Count) }
    else {
        $different++
        Write-Host ("DIFFERENT  {0}: {1} places ({2} lines before, {3} after)" -f $n, $count, $x.Count, $y.Count)
        $diffs | ForEach-Object { Write-Host $_ }
    }
}
if ($different -gt 0) { exit 1 }
