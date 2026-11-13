<#
    A heuristic check of the generated SQL, for the kinds of defects that the Snowflake bi and crt
    generators had, found by reading their output: columns without a name, a stray ":,", "a.," or
    "t." where a column name is missing, an operator with nothing after it, a column without its
    comma or a comma before a keyword, and unbalanced parentheses.

    It is not a SQL parser and cannot say that SQL is valid; it says that none of these defects is
    there. The uni output, which has been run on Snowflake, is the control: it must come out clean.
    snowflake-tests.ps1 runs the SQL of some of the models on Snowflake; this is the check that needs
    no account, and it covers every model.

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
. (Join-Path $PSScriptRoot 'lint-columns.ps1')

$types = 'int|tinyint|smallint|bigint|integer|decimal\(\d+,\s*\d+\)|number\(\d+(,\s*\d+)?\)|numeric\(\d+(,\s*\d+)?\)|timestamp_ntz(\(\d+\))?|timestamp(\(\d+\))?|datetime|date|string|text|varchar(\(\d+\))?|char(\(\d+\))?|boolean|bit|geography|binary'
$column = "^\s+[A-Za-z_][A-Za-z0-9_]*\s+($types)\b[^,;]*$"         # a column definition with no comma at its end (not a declaration in a function, which ends with a semicolon)
$selectItem = '^\s+[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*\s*$' # "x.Column" with no comma at its end

# The templates write the names that come from the model inside double quotes ("AC_Actor"), which keeps their case and lets them
# hold national characters. For this lint a quoted name is the name: the quotes are taken off, and a character that is not a letter,
# digit or underscore (a space, say) becomes an underscore, so that the name stays one word.
function Remove-IdentifierQuotes([string] $text, [string] $dialect = 'Snowflake') {
    $pattern = '"([^"\r\n]*)"'
    if ($dialect -eq 'BigQuery') { $pattern = '`([^`\r\n]*)`' }   # BigQuery quotes a name with backticks
    [regex]::Replace($text, $pattern, { param($m) $m.Groups[1].Value -replace '[^\w$]', '_' })
}

function Test-Sql([string] $text, [string] $dialect = 'Snowflake') {
    $text = Remove-IdentifierQuotes $text $dialect
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
        if ($dialect -eq 'Snowflake' -and $l -match '\bCROSS JOIN LATERAL\b') { $found.Add("line ${n}: CROSS JOIN LATERAL, which Snowflake rejects in a SQL function body (use a comma join): [$($lines[$i])]") }
        # found the same way: SQL Server's length for the largest values, which Snowflake does not have (varbinary(max))
        if ($l -match '\b[A-Za-z]+\(\s*max\s*\)') { $found.Add("line ${n}: a (max) length, which $dialect does not have: [$($lines[$i])]") }
        # SQL Server's T-SQL, which the PostgreSQL templates were copied from
        if ($dialect -ne 'SQLServer' -and $l -match '\bIF Object_ID\b|\bEXEC\s*\(|^\s*GO\s*$|\bnonclustered\b|\bclustered\b|\bsysdatetime\b|\bisnull\s*\(') { $found.Add("line ${n}: T-SQL in SQL for $dialect : [$($lines[$i])]") }
        # what Snowflake's templates have that BigQuery does not take, which the BigQuery templates were made from
        if ($dialect -eq 'BigQuery') {
            if ($l -match '::\s*\w') { $found.Add("line ${n}: a :: cast, which BigQuery does not have (CAST(x AS type)): [$($lines[$i])]") }
            if ($l -match '\bCOPY GRANTS\b|\bRELY\b|\.nextval\b|\bCREATE SEQUENCE\b|\bIDENTITY\s*\(|\btimestamp_ntz\b|\bhash\s*\(|\bsysdate\s*\(|\bLISTAGG\b|\bOBJECT_CONSTRUCT\b') { $found.Add("line ${n}: Snowflake SQL in SQL for BigQuery: [$($lines[$i])]") }
            if ($l -match '\bCLUSTER BY\s*\(') { $found.Add("line ${n}: CLUSTER BY with parentheses; BigQuery has none: [$($lines[$i])]") }
            if ($l -match '\bUNIQUE\b') { $found.Add("line ${n}: a unique constraint, which BigQuery does not have: [$($lines[$i])]") }
            if ($l -cmatch '^\s*constraint\b') { $found.Add("line ${n}: a constraint written as in other databases (BigQuery: PRIMARY KEY (...) NOT ENFORCED, CONSTRAINT name FOREIGN KEY (...) REFERENCES ... NOT ENFORCED): [$($lines[$i])]") }
            if ($l -match '\bRETURNS TABLE\b|^\s*\$\$|\bTABLE\s*\(\s*\w+\.\w+\s*\(') { $found.Add("line ${n}: a function written as in Snowflake (BigQuery: CREATE TABLE FUNCTION ... AS (query), called as a table): [$($lines[$i])]") }
            if ($l -match '\bUNION\b(?!\s+(ALL|DISTINCT)\b)') { $found.Add("line ${n}: UNION without ALL or DISTINCT, which BigQuery requires: [$($lines[$i])]") }
        }
        # the next line that is code
        $j = $i + 1; while ($j -lt $code.Count -and $code[$j] -notmatch '\S') { $j++ }
        if ($j -lt $code.Count) {
            $next = $code[$j]
            if ($l -match 'CLUSTER BY \(\s*$' -and $next -match '^\s*\)') { $found.Add("line ${n}: an empty CLUSTER BY: [$($lines[$i])]") }
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
        if ($dialect -ne 'Snowflake') { break }   # COPY GRANTS is Snowflake's
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
    for ($i = 0; $i -lt $code.Count; $i++) {
        if ($code[$i] -match '^CREATE (?:OR REPLACE )?(?:TABLE FUNCTION|TABLE|VIEW|FUNCTION|SEQUENCE)(?: IF NOT EXISTS)? (\w+)\.(\w+)') {
            $key = ($Matches[1] + '.' + $Matches[2]).ToLower()
            if (-not $created.ContainsKey($key)) { $created[$key] = $i }   # where the first statement that creates it starts
            $schemas[$Matches[1].ToLower()] = $true
        }
        # a table that a trigger makes when it needs it (the deletion tables of deletable attributes and ties) is there for every statement
        elseif ($code[$i] -match '^\s+CREATE TABLE (\w+)\.(\w+)') {
            $key = ($Matches[1] + '.' + $Matches[2]).ToLower()
            if (-not $created.ContainsKey($key)) { $created[$key] = 0 }
        }
    }
    $missing = [ordered]@{}
    $tooEarly = [ordered]@{}
    $statement = -1
    for ($i = 0; $i -lt $code.Count; $i++) {
        if ($code[$i] -match '^CREATE ') { $statement = $i }
        foreach ($m in [regex]::Matches($code[$i], '\b(\w+)\.(\w+)\b')) {
            $schema = $m.Groups[1].Value.ToLower()
            if (-not $schemas.ContainsKey($schema)) { continue }
            $name = $schema + '.' + $m.Groups[2].Value.ToLower()
            if (-not $created.ContainsKey($name)) {
                if (-not $missing.Contains($name)) { $missing[$name] = @{ Line = $i + 1; Count = 0; Text = $lines[$i] } }
                $missing[$name].Count++
            }
            elseif ($statement -ge 0 -and $created[$name] -gt $statement) {
                # Snowflake needs the table that a foreign key names, and the function or view that a function or view uses, to exist
                if (-not $tooEarly.Contains($name)) { $tooEarly[$name] = @{ Line = $i + 1; Created = $created[$name] + 1; Text = $lines[$i] } }
            }
        }
    }
    foreach ($name in $tooEarly.Keys) {
        $found.Add("line $($tooEarly[$name].Line): uses $name, which the script creates later, at line $($tooEarly[$name].Created): [$($tooEarly[$name].Text.Trim())]")
    }
    foreach ($name in $missing.Keys) {
        $found.Add("line $($missing[$name].Line): refers to $name ($($missing[$name].Count) times), which the script never creates: [$($missing[$name].Text.Trim())]")
    }
    Test-Columns $code $lines $found
    $joined = ($code -join "`n")
    $open = ([regex]::Matches($joined, '\(')).Count; $close = ([regex]::Matches($joined, '\)')).Count
    if ($open -ne $close) { $found.Add("unbalanced parentheses: $open open, $close close") }
    , $found
}

if ($Path) { $targets = @([pscustomobject]@{ Name = (Split-Path $Path -Leaf); Path = $Path }) }
else {
    # oracle* are the original Oracle sisulets, ported as they were, and they have the defects that the original SQL had (see the handover; lint-sql.ps1 -Variant oracle-base shows them). sqlserver* are not models that the lint knows (it knows Snowflake and PostgreSQL SQL). handwritten* are not models that the modeler would save (see make-variants.ps1); they refer to tables that the generators never create, on purpose, so they are left out unless named
    if (-not $Variant) { $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name | ForEach-Object { $_.BaseName } | Where-Object { $_ -notmatch '^(handwritten|sqlserver|oracle)' } }
    $Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
    $targets = @($Variant | ForEach-Object { [pscustomobject]@{ Name = $_; Path = (Join-Path $root "golden\$_\_full.sql") } })
}
$dirty = 0
foreach ($t in $targets) {
    $dialect = 'Snowflake'
    if ($t.Name -match '^postgresql') { $dialect = 'PostgreSQL' }
    if ($t.Name -match '^vertica') { $dialect = 'Vertica' }
    if ($t.Name -match '^bigquery') { $dialect = 'BigQuery' }
    if ($t.Name -match '^oracle') { $dialect = 'Oracle' }
    $found = Test-Sql ([IO.File]::ReadAllText($t.Path, [Text.Encoding]::UTF8)) $dialect
    if ($found.Count -eq 0) { Write-Host ("clean  {0}" -f $t.Name); continue }
    $dirty++
    $kinds = $found | ForEach-Object { ($_ -replace '^line \d+: ', '' -replace ':.*$', '') } | Group-Object | Sort-Object Count -Descending
    Write-Host ("FOUND  {0}: {1} findings ({2})" -f $t.Name, $found.Count, (($kinds | ForEach-Object { "$($_.Count) x $($_.Name)" }) -join '; '))
    $found | Select-Object -First $Show | ForEach-Object { Write-Host "         $_" }
}
Write-Host ''
if ($dirty -gt 0) { Write-Host "$dirty of $($targets.Count) have findings."; exit 1 }
Write-Host "All $($targets.Count) clean."
