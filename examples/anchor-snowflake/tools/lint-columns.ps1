# Used by lint-sql.ps1. Does every column that the SQL names exist in the table, view or function that it
# is taken from? Found necessary by running the generated SQL on Snowflake: a difference function asked a
# posit table for a column that only the annex table has ("invalid identifier").
#
# What it knows: the columns of every table (its definition), of every function (its RETURNS TABLE list) and
# of every view (its column list or its select list). A view or function over "*" has columns that cannot be
# read off the text, and is skipped.
# What it checks, in each function and view:
#   alias.column     the alias stands for a table, view or TABLE(function(...)) in the FROM clause; the
#                    column has to exist there (if an alias means different objects in different
#                    subqueries, any of them will do)
#   a bare column    in a SELECT from a single table with no alias, the names in the select list and the
#                    WHERE clause have to be columns of that table (or aliases, parameters, keywords)
# It is a heuristic over generated text, not a SQL parser.

$script:KeywordsForAlias = @('WHERE', 'JOIN', 'ON', 'LEFT', 'RIGHT', 'INNER', 'CROSS', 'FULL', 'UNION', 'GROUP', 'ORDER', 'LIMIT', 'AND', 'OR', 'NATURAL', 'QUALIFY', 'HAVING', 'LATERAL')
$script:KeywordsInQuery = @('SELECT', 'DISTINCT', 'FROM', 'WHERE', 'AND', 'OR', 'IS', 'NULL', 'NOT', 'LIKE', 'BETWEEN', 'IN', 'AS', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END', 'ON', 'JOIN', 'UNION', 'ALL', 'TRUE', 'FALSE', 'ASC', 'DESC', 'BY', 'ORDER', 'LIMIT', 'GROUP')

# name (lower case, schema.name) -> @{ Kind; Columns (a hashtable of lower case names, or $null if unknown); Params }
function Get-ObjectColumns([System.Collections.Generic.List[string]] $code) {
    $objects = @{}
    for ($i = 0; $i -lt $code.Count; $i++) {
        if ($code[$i] -notmatch '^CREATE (?:OR REPLACE )?(TABLE|VIEW|FUNCTION)(?: IF NOT EXISTS)? (\w+)\.(\w+)') { continue }
        $kind = $Matches[1]; $name = ($Matches[2] + '.' + $Matches[3]).ToLower()
        $columns = @{}; $params = @{}; $known = $true
        if ($kind -eq 'TABLE') {
            for ($j = $i + 1; $j -lt $code.Count -and $code[$j] -notmatch '^\)'; $j++) {
                if ($code[$j] -match '^ {4}([A-Za-z_]\w*)\s' -and $Matches[1] -ne 'constraint') { $columns[$Matches[1].ToLower()] = $true }
            }
        }
        elseif ($kind -eq 'FUNCTION') {
            $j = $i + 1
            while ($j -lt $code.Count -and $code[$j] -notmatch '^\)') { if ($code[$j] -match '^ {4}([A-Za-z_]\w*)\s') { $params[$Matches[1].ToLower()] = $true }; $j++ }
            while ($j -lt $code.Count -and $code[$j] -notmatch '^RETURNS') { $j++ }
            if ($j -lt $code.Count -and $code[$j] -match '^RETURNS TABLE') {
                for ($j = $j + 1; $j -lt $code.Count -and $code[$j] -notmatch '^\)'; $j++) {
                    if ($code[$j] -match '^ {4}([A-Za-z_]\w*)\s') { $columns[$Matches[1].ToLower()] = $true }
                }
            } else { $known = $false }   # a scalar function
        }
        else {   # VIEW: a column list, or the select list
            if ($code[$i] -match '\($') {
                for ($j = $i + 1; $j -lt $code.Count -and $code[$j] -notmatch '^\)'; $j++) {
                    if ($code[$j] -match '^ {4}([A-Za-z_]\w*)') { $columns[$Matches[1].ToLower()] = $true }
                }
            } else {
                $j = $i + 1; while ($j -lt $code.Count -and $code[$j] -notmatch '^SELECT') { $j++ }
                for ($j = $j + 1; $j -lt $code.Count -and $code[$j] -notmatch '^FROM'; $j++) {
                    $item = $code[$j].Trim().TrimEnd(',')
                    if ($item -match '\*$') { $known = $false; break }
                    if ($item -match '(?i)\bAS\s+(\w+)$') { $columns[$Matches[1].ToLower()] = $true }
                    elseif ($item -match '(?:^|\.)(\w+)$') { $columns[$Matches[1].ToLower()] = $true }
                }
            }
        }
        $objects[$name] = @{ Kind = $kind; Columns = $(if ($known) { $columns } else { $null }); Params = $params }
    }
    $objects
}

# The text of a parenthesis that opens at $open, and the index after its closing parenthesis.
function Get-Balanced([string] $text, [int] $open) {
    $depth = 0
    for ($k = $open; $k -lt $text.Length; $k++) {
        if ($text[$k] -eq '(') { $depth++ } elseif ($text[$k] -eq ')') { $depth--; if ($depth -eq 0) { return $k + 1 } }
    }
    return -1
}

function Test-Columns([System.Collections.Generic.List[string]] $code, [string[]] $lines, $found) {
    $objects = Get-ObjectColumns $code
    $reported = @{}
    for ($i = 0; $i -lt $code.Count; $i++) {
        if ($code[$i] -notmatch '^CREATE (?:OR REPLACE )?(VIEW|FUNCTION)(?: IF NOT EXISTS)? (\w+)\.(\w+)') { continue }
        $self = ($Matches[2] + '.' + $Matches[3]).ToLower()
        $end = $i; while ($end -lt $code.Count -and $code[$end] -notmatch '^;\s*$') { $end++ }
        $text = ($code[$i..([Math]::Min($end, $code.Count - 1))] -join "`n")
        $params = $objects[$self].Params
        # aliases: schema.name alias, and TABLE(schema.function(...)) alias
        $aliases = @{}
        foreach ($m in [regex]::Matches($text, '(?i)(?:\bFROM|\bJOIN|,)\s+(\w+)\.(\w+)\s+(?:AS\s+)?(\w+)')) {
            if ($script:KeywordsForAlias -contains $m.Groups[3].Value.ToUpper()) { continue }
            $obj = ($m.Groups[1].Value + '.' + $m.Groups[2].Value).ToLower()
            if (-not $aliases.ContainsKey($m.Groups[3].Value.ToLower())) { $aliases[$m.Groups[3].Value.ToLower()] = @() }
            $aliases[$m.Groups[3].Value.ToLower()] += $obj
        }
        foreach ($m in [regex]::Matches($text, '(?i)\bTABLE\s*\(\s*(\w+)\.(\w+)\s*\(')) {
            $open = $text.IndexOf('(', $m.Index)
            $close = Get-Balanced $text $open
            if ($close -lt 0) { continue }
            $after = [regex]::Match($text.Substring($close), '^\s*(?:AS\s+)?(\w+)')
            if (-not $after.Success -or $script:KeywordsForAlias -contains $after.Groups[1].Value.ToUpper()) { continue }
            $a = $after.Groups[1].Value.ToLower()
            if (-not $aliases.ContainsKey($a)) { $aliases[$a] = @() }
            $aliases[$a] += ($m.Groups[1].Value + '.' + $m.Groups[2].Value).ToLower()
        }
        # alias.column
        foreach ($m in [regex]::Matches($text, '\b(\w+)\.(\w+)\b')) {
            $a = $m.Groups[1].Value.ToLower(); $c = $m.Groups[2].Value.ToLower()
            if (-not $aliases.ContainsKey($a)) { continue }
            $sources = @($aliases[$a] | Where-Object { $objects.ContainsKey($_) })
            if ($sources.Count -ne @($aliases[$a]).Count) { continue }               # an object that this script does not define
            if (@($sources | Where-Object { $null -eq $objects[$_].Columns }).Count -gt 0) { continue }   # columns unknown
            if (@($sources | Where-Object { $objects[$_].Columns.ContainsKey($c) }).Count -gt 0) { continue }
            $key = "$self|$a.$c"
            if (-not $reported.ContainsKey($key)) {
                $reported[$key] = $true
                $found.Add("line $($i + 1): $($m.Groups[1].Value).$($m.Groups[2].Value) in ${self}: $(($sources | Select-Object -Unique) -join ' / ') has no column $($m.Groups[2].Value)")
            }
        }
        # a SELECT from one table without an alias
        foreach ($m in [regex]::Matches($text, '(?is)\bSELECT\s+(?:DISTINCT\s+)?(?<sel>(?:(?!\bFROM\b|\bSELECT\b)[\s\S])*?)\bFROM\s+(?<s>\w+)\.(?<n>\w+)\s*\r?\n\s*WHERE\s+(?<w>.*?)(?=\r?\n\s*(?:UNION\b|\)|\$\$)|\z)')) {
            $obj = ($m.Groups['s'].Value + '.' + $m.Groups['n'].Value).ToLower()
            if (-not $objects.ContainsKey($obj) -or $null -eq $objects[$obj].Columns) { continue }
            $body = $m.Groups['sel'].Value + ' ' + $m.Groups['w'].Value
            $body = [regex]::Replace($body, '::\s*\w+(\(\d+(,\s*\d+)?\))?', ' ')      # casts
            $body = [regex]::Replace($body, '(?i)\bAS\s+\w+', ' ')                     # aliases that the select list gives
            foreach ($t in [regex]::Matches($body, '\b[A-Za-z_]\w*\b(?!\s*\()')) {
                $w = $t.Value.ToLower()
                if ($script:KeywordsInQuery -contains $t.Value.ToUpper() -or $params.ContainsKey($w) -or $objects[$obj].Columns.ContainsKey($w)) { continue }
                $key = "$self|$obj|$w"
                if (-not $reported.ContainsKey($key)) {
                    $reported[$key] = $true
                    $found.Add("line $($i + 1): $($t.Value) in ${self}: $obj has no column $($t.Value)")
                }
            }
        }
    }
}
