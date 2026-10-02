<#
    A heuristic check of the generated SQL, for the kinds of defects that the Snowflake bi and crt
    generators had, found by reading their output: columns without a name, a stray ":,", "a.," or
    "t." where a column name is missing, an operator with nothing after it, a column without its
    comma or a comma before a keyword, and unbalanced parentheses.

    It is not a SQL parser and cannot say that SQL is valid; it says that none of these defects is
    there. The uni output, which has been run on Snowflake, is the control: it must come out clean.
    There is no Snowflake on the development machine, so this is the stand-in.

    Usage:
      lint-sql.ps1 [-Variant <name>,...] [-Show <n>]      lints golden/<name>/_full.sql, every model but handwritten* by default
      lint-sql.ps1 -Path <file.sql>                       lints one file
    Exits 1 if anything is found.
#>
[CmdletBinding()]
param(
    [string[]] $Variant,
    [string] $Path,
    [int] $Show = 3
)
Set-StrictMode -Version 2.0
$root = Split-Path -Parent $PSScriptRoot

$types = 'int|tinyint|smallint|bigint|integer|decimal\(\d+,\s*\d+\)|number\(\d+(,\s*\d+)?\)|numeric\(\d+(,\s*\d+)?\)|timestamp_ntz(\(\d+\))?|timestamp(\(\d+\))?|datetime|date|string|text|varchar(\(\d+\))?|char(\(\d+\))?|boolean|bit|geography|binary'
$column = "^\s+[A-Za-z_][A-Za-z0-9_]*\s+($types)\b[^,]*$"          # a column definition with no comma at its end
$selectItem = '^\s+[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*\s*$' # "x.Column" with no comma at its end

function Test-Sql([string] $text) {
    $found = New-Object System.Collections.Generic.List[string]
    # comments and string literals are not code
    $lines = $text -split "`r?`n"
    $code = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) { $code.Add(([regex]::Replace(([regex]::Replace($l, "'(?:[^']|'')*'", "''")), '--.*$', ''))) }
    for ($i = 0; $i -lt $code.Count; $i++) {
        $l = $code[$i]; $n = $i + 1
        if ($l -match "^\s+($types)\b") { $found.Add("line ${n}: a column with a type and no name: [$($lines[$i])]") }
        if ($l -match '^\s*:,?\s*$') { $found.Add("line ${n}: a stray colon: [$($lines[$i])]") }
        if ($l -match '\b[A-Za-z_][A-Za-z0-9_]*\.(\s*,|\s*$|\s*\))') { $found.Add("line ${n}: a qualifier with no column after it: [$($lines[$i])]") }
        if ($l -match '[<>=]\s+(then|else|end|and|or|when)\b') { $found.Add("line ${n}: an operator with nothing after it: [$($lines[$i])]") }
        if ($l -match '^\s+as\s+\w+\s*,?\s*$') { $found.Add("line ${n}: an alias with no expression: [$($lines[$i])]") }
        # found by running the generated SQL on Snowflake: a SQL function body does not accept it; a comma join does the same
        if ($l -match '\bCROSS JOIN LATERAL\b') { $found.Add("line ${n}: CROSS JOIN LATERAL, which Snowflake rejects in a SQL function body (use a comma join): [$($lines[$i])]") }
        # the next line that is code
        $j = $i + 1; while ($j -lt $code.Count -and $code[$j] -notmatch '\S') { $j++ }
        if ($j -lt $code.Count) {
            $next = $code[$j]
            if ($l -match ',\s*$' -and $next -match '^\s*((FROM|WHERE|GROUP|ORDER|UNION|HAVING|LIMIT)(\s|$)|\)|;)') { $found.Add("line ${n}: a comma before ""$($next.Trim())"": [$($lines[$i])]") }
            if (($l -match $column -and $next -match "^\s+[A-Za-z_][A-Za-z0-9_]*\s+($types)\b") -or
                ($l -match $selectItem -and $next -match '^\s+[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*\s*,?\s*$')) {
                $found.Add("line ${n}: no comma between two columns: [$($lines[$i])] [$($next)]")
            }
        }
    }
    # a replaced function or view must keep its grants: COPY GRANTS before RETURNS (function), and before
    # COMMENT and AS (view)
    for ($i = 0; $i -lt $code.Count; $i++) {
        if ($code[$i] -notmatch '^CREATE OR REPLACE (FUNCTION|VIEW)\b') { continue }
        $kind = $Matches[1]
        $j = $i; $head = ''
        while ($j -lt $code.Count) {
            if ($kind -eq 'FUNCTION' -and $code[$j] -match '^RETURNS\b') { break }
            if ($kind -eq 'VIEW' -and $code[$j] -match '(^|\s)AS\s*$') { $head += ' ' + $code[$j]; break }
            $head += ' ' + $code[$j]; $j++
        }
        if ($head -notmatch 'COPY GRANTS') { $found.Add("line $($i + 1): a $kind that is replaced without COPY GRANTS: [$($lines[$i])]") }
        elseif ($kind -eq 'VIEW' -and $head -match 'COMMENT\s*=.*COPY GRANTS') { $found.Add("line $($i + 1): COPY GRANTS after COMMENT in a view: [$($lines[$i])]") }
    }
    # every table, view, function and sequence that the script refers to as schema.name must be created by it
    $created = @{}; $schemas = @{}
    foreach ($l in $code) {
        if ($l -match '^CREATE (?:OR REPLACE )?(?:TABLE|VIEW|FUNCTION|SEQUENCE)(?: IF NOT EXISTS)? (\w+)\.(\w+)') {
            $created[($Matches[1] + '.' + $Matches[2]).ToLower()] = $true; $schemas[$Matches[1].ToLower()] = $true
        }
    }
    $missing = [ordered]@{}
    for ($i = 0; $i -lt $code.Count; $i++) {
        foreach ($m in [regex]::Matches($code[$i], '\b(\w+)\.(\w+)\b')) {
            $schema = $m.Groups[1].Value.ToLower()
            if (-not $schemas.ContainsKey($schema)) { continue }
            $name = $schema + '.' + $m.Groups[2].Value.ToLower()
            if (-not $created.ContainsKey($name)) {
                if (-not $missing.Contains($name)) { $missing[$name] = @{ Line = $i + 1; Count = 0; Text = $lines[$i] } }
                $missing[$name].Count++
            }
        }
    }
    foreach ($name in $missing.Keys) {
        $found.Add("line $($missing[$name].Line): refers to $name ($($missing[$name].Count) times), which the script never creates: [$($missing[$name].Text.Trim())]")
    }
    $joined = ($code -join "`n")
    $open = ([regex]::Matches($joined, '\(')).Count; $close = ([regex]::Matches($joined, '\)')).Count
    if ($open -ne $close) { $found.Add("unbalanced parentheses: $open open, $close close") }
    , $found
}

if ($Path) { $targets = @([pscustomobject]@{ Name = (Split-Path $Path -Leaf); Path = $Path }) }
else {
    # handwritten* are not models that the modeler would save (see make-variants.ps1); they refer to tables that the generators never create, on purpose, so they are left out unless named
    if (-not $Variant) { $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name | ForEach-Object { $_.BaseName } | Where-Object { $_ -notmatch '^handwritten' } }
    $Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
    $targets = @($Variant | ForEach-Object { [pscustomobject]@{ Name = $_; Path = (Join-Path $root "golden\$_\_full.sql") } })
}
$dirty = 0
foreach ($t in $targets) {
    $found = Test-Sql ([IO.File]::ReadAllText($t.Path, [Text.Encoding]::UTF8))
    if ($found.Count -eq 0) { Write-Host ("clean  {0}" -f $t.Name); continue }
    $dirty++
    $kinds = $found | ForEach-Object { ($_ -replace '^line \d+: ', '' -replace ':.*$', '') } | Group-Object | Sort-Object Count -Descending
    Write-Host ("FOUND  {0}: {1} findings ({2})" -f $t.Name, $found.Count, (($kinds | ForEach-Object { "$($_.Count) x $($_.Name)" }) -join '; '))
    $found | Select-Object -First $Show | ForEach-Object { Write-Host "         $_" }
}
Write-Host ''
if ($dirty -gt 0) { Write-Host "$dirty of $($targets.Count) have findings."; exit 1 }
Write-Host "All $($targets.Count) clean."
