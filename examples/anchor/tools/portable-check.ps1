<#
    Runs the portable Anchor generators (tools/build-portable-generator.ps1 in the Anchor repository: anchor-generator-<database>.js)
    under Jint, as any other ES5 engine would run them. For each model of a database that has a generator it reads the XML of
    models/<name>.xml, as a user would hand it over, and the SQL that AnchorGenerator.generate gives has to be identical to
    golden/<name>/_full.sql. Besides that it checks

      - that defaults() is what the modeler has saved in the metadata of the models of the database (the data types, the schema and now),
      - that asking for a temporalization gives the bindings of a model that says it, and that an unknown one is an error that says so,
      - that check() and generate() say what is wrong with a model that is wrong, and name the database in what they say,
      - that metadataElement() is a model's start: a model made of it and nothing else is generated.

    Usage:
      portable-check.ps1 [-Target SQLServer,Snowflake,PostgreSQL,Vertica,BigQuery] [-Variant <model name>,...] [-Anchor <checkout>]
                         [-Parts <directory with the generators>] [-JintPath <Jint.dll>]
#>
[CmdletBinding()]
param(
    [string[]] $Target = @('SQLServer', 'Snowflake', 'PostgreSQL', 'Vertica', 'BigQuery'),
    [string[]] $Variant,
    [string] $Anchor,
    [string] $Parts,
    [string] $JintPath
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
if (-not $JintPath) { $JintPath = Join-Path $PSScriptRoot '..\..\..\lib\Jint.2.11.58.dll' }
$Anchor = (Resolve-Path $Anchor).Path
Add-Type -Path (Resolve-Path $JintPath)
$Target = @($Target | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })

$temporary = $null
if (-not $Parts) {
    $temporary = Join-Path ([IO.Path]::GetTempPath()) ('portable-check-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    $Parts = $temporary
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Anchor 'tools\build-portable-generator.ps1') -Anchor $Anchor -Output $Parts -Target ($Target -join ',') | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'The build failed.' }
}
$utf8 = New-Object Text.UTF8Encoding($false)
$failed = 0

function Get-Reason($e) { $r = $e.Exception.Message; if ($e.Exception.InnerException) { $r = $e.Exception.InnerException.Message }; $r }

# the models, by the database they are for
$models = @{}
foreach ($file in Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name) {
    $text = [IO.File]::ReadAllText($file.FullName, $utf8)
    $m = [regex]::Match($text, 'databaseTarget="(\w+)"')
    if (-not $m.Success) { continue }
    if (-not $models.ContainsKey($m.Groups[1].Value)) { $models[$m.Groups[1].Value] = New-Object System.Collections.Generic.List[string] }
    $models[$m.Groups[1].Value].Add($file.BaseName)
}

foreach ($database in $Target) {
    $generator = Join-Path $Parts ("anchor-generator-{0}.js" -f $database.ToLowerInvariant())
    if (-not (Test-Path $generator)) { Write-Host "FAIL  ${database}: no generator at $generator"; $failed++; continue }
    $engine = New-Object Jint.Engine
    $engine.Execute([IO.File]::ReadAllText($generator, $utf8)) | Out-Null
    $temporalizations = @($engine.Execute('var list = AnchorGenerator.temporalizations.join(",");').GetValue('list').AsString() -split ',')
    $names = @($models[$database])
    if ($Variant.Count -gt 0) { $names = @($names | Where-Object { $Variant -contains $_ }) }
    Write-Host ("== {0}: {1} models, temporalizations {2}" -f $database, $names.Count, ($temporalizations -join ', '))

    function Invoke-Generator([string] $expression, [string] $xml, $wanted) {
        $engine.SetValue('modelXml', $xml) | Out-Null
        $engine.SetValue('wanted', $wanted) | Out-Null
        $engine.Execute("var result = $expression;") | Out-Null
        $engine.GetValue('result').AsString()
    }

    $firstXml = $null
    foreach ($v in $names) {
        $xml = [IO.File]::ReadAllText((Join-Path $root "models\$v.xml"), $utf8)
        $temporalization = [regex]::Match($xml, 'temporalization="(\w+)"').Groups[1].Value
        if ($temporalizations -notcontains $temporalization) { continue }   # a model that the generator does not make (Vertica uni)
        if ($null -eq $firstXml -and $v -match 'base') { $firstXml = $xml }
        try { $actual = Invoke-Generator 'AnchorGenerator.generate(modelXml, null)' $xml $null }
        catch { Write-Host ("FAIL  {0}: the generator threw: {1}" -f $v, (Get-Reason $_)); $failed++; continue }
        $golden = ([IO.File]::ReadAllText((Join-Path $root "golden\$v\_full.sql"), $utf8) -replace "`r`n", "`n")
        if ($actual -ceq $golden) { Write-Host ("PASS  {0}: the golden file ({1:N0} characters)" -f $v, $actual.Length) }
        else {
            $a = $golden -split "`n"; $b = $actual -split "`n"; $i = 0
            while ($i -lt [Math]::Min($a.Count, $b.Count) -and $a[$i] -ceq $b[$i]) { $i++ }
            Write-Host ("FAIL  {0}: differs from the golden file at line {1}" -f $v, ($i + 1))
            Write-Host ("   golden    [{0}]" -f $(if ($i -lt $a.Count) { $a[$i] } else { '(end)' }))
            Write-Host ("   generated [{0}]" -f $(if ($i -lt $b.Count) { $b[$i] } else { '(end)' }))
            $failed++
        }
    }
    if ($null -eq $firstXml) { Write-Host "FAIL  ${database}: no model to test the rest with"; $failed++; continue }

    # defaults() against what the modeler has saved: every setting that it names has the value that each model of the database has
    $defaults = @{}
    $engine.Execute('var keys = []; var d = AnchorGenerator.defaults(); for (var k in d) keys.push(k + "=" + d[k]);') | Out-Null
    $engine.GetValue('keys').ToObject() | ForEach-Object { $p = $_ -split '=', 2; $defaults[$p[0]] = $p[1] }
    $bad = New-Object System.Collections.Generic.List[string]
    $bases = @($names | Where-Object { $_ -match '(^|-)base(-bi|-crt)?$' })   # the models that change settings on purpose (business, ranges) are not the modeler's defaults
    foreach ($v in $bases) {
        $xml = [IO.File]::ReadAllText((Join-Path $root "models\$v.xml"), $utf8)
        $metadata = [regex]::Match($xml, '<metadata [^>]*changingRange[^>]*/>').Value
        foreach ($k in $defaults.Keys) {
            if ($k -eq 'temporalization') { continue }
            $m = [regex]::Match($metadata, "\s$k=""([^""]*)""")
            if (-not $m.Success) { $bad.Add("$v lacks $k"); continue }
            $expected = [Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
            if ($expected -cne $defaults[$k]) { $bad.Add("$v has $k=""$expected"", defaults() has ""$($defaults[$k])""") }
        }
    }
    if ($bad.Count -eq 0) { Write-Host ("PASS  {0}: defaults() is what the modeler saved in {1} base models" -f $database, $bases.Count) }
    else { Write-Host ("FAIL  {0}: defaults() differs from the models ({1}): {2}" -f $database, $bad.Count, (($bad | Select-Object -Unique -First 6) -join '; ')); $failed++ }

    # asking for a temporalization is the same as a model that says it
    foreach ($other in $temporalizations) {
        $asked = Invoke-Generator 'JSON.stringify(AnchorGenerator.bindings(modelXml, wanted))' $firstXml $other
        $said = Invoke-Generator 'JSON.stringify(AnchorGenerator.bindings(modelXml, null))' ([regex]::Replace($firstXml, 'temporalization="\w+"', "temporalization=`"$other`"")) $null
        if ($asked -ceq $said) { Write-Host ("PASS  {0}: asking for {1} gives the bindings of a model that says {1}" -f $database, $other) }
        else { Write-Host ("FAIL  {0}: asking for {1} differs from a model that says {1}" -f $database, $other); $failed++ }
    }
    try { [void] (Invoke-Generator 'AnchorGenerator.generate(modelXml, wanted)' $firstXml 'tri'); Write-Host ("FAIL  {0}: an unknown temporalization is no error" -f $database); $failed++ }
    catch { $r = Get-Reason $_; if ($r.Contains("not 'tri'")) { Write-Host ("PASS  {0}: an unknown temporalization: {1}" -f $database, $r) } else { Write-Host ("FAIL  {0}: the message does not say what is wrong: {1}" -f $database, $r); $failed++ } }

    # a model that is wrong says what and where, and for which database
    $broken = $firstXml.Replace(' naturalKeyAttributes="' + [regex]::Match($firstXml, 'naturalKeyAttributes="(\w+)"').Groups[1].Value + '"', '')
    $said = Invoke-Generator 'AnchorGenerator.check(modelXml)' $broken $null
    if ($said.Contains('these settings are missing') -and $said.Contains('naturalKeyAttributes=') -and $said.Contains("a $database model")) { Write-Host ("PASS  {0}: check() says what is missing, for {0}" -f $database) }
    else { Write-Host ("FAIL  {0}: check() says: {1}" -f $database, $said); $failed++ }
    if ((Invoke-Generator 'String(AnchorGenerator.check(modelXml))' $firstXml $null) -eq 'null') { Write-Host ("PASS  {0}: check() has nothing to say about a model that is fine" -f $database) }
    else { Write-Host ("FAIL  {0}: check() has something to say about a model that is fine" -f $database); $failed++ }
    try { [void] (Invoke-Generator 'AnchorGenerator.generate(modelXml, null)' '<schema><metadata' $null); Write-Host ("FAIL  {0}: XML that is not XML is no error" -f $database); $failed++ }
    catch { Write-Host ("PASS  {0}: not XML: {1}" -f $database, (Get-Reason $_)) }

    # a model that is a metadata element and a knot, an anchor and an attribute: enough to see that a new model is generated
    $metadata = Invoke-Generator 'AnchorGenerator.metadataElement()' '' $null
    $small = @"
<schema format="0.101.2">
$metadata
<knot mnemonic="GEN" descriptor="Gender" identity="$($defaults['identity'])" dataRange="varchar(42)">
<metadata capsule="$($defaults['encapsulation'])" generator="false"/>
</knot>
<anchor mnemonic="AC" descriptor="Actor" identity="$($defaults['identity'])">
<metadata capsule="$($defaults['encapsulation'])" generator="true"/>
<attribute mnemonic="NAM" descriptor="Name" timeRange="$($defaults['changingRange'])" dataRange="varchar(42)">
<metadata capsule="$($defaults['encapsulation'])"/>
</attribute>
</anchor>
</schema>
"@
    $temporalizationOfSmall = $temporalizations[0]
    try {
        $sql = Invoke-Generator 'AnchorGenerator.generate(modelXml, wanted)' $small $temporalizationOfSmall
        if ($sql -match 'CREATE' -and $sql -notmatch 'undefined') { Write-Host ("PASS  {0}: a model that starts with metadataElement() is generated ({1:N0} characters, {2})" -f $database, $sql.Length, $temporalizationOfSmall) }
        else { Write-Host ("FAIL  {0}: the small model gives no script, or one with 'undefined' in it" -f $database); $failed++ }
    }
    catch { Write-Host ("FAIL  {0}: the small model: {1}" -f $database, (Get-Reason $_)); $failed++ }
}

if ($temporary) { Remove-Item -Recurse -Force $temporary -ErrorAction SilentlyContinue }
if ($failed -gt 0) { Write-Host "$failed failed."; exit 1 }
Write-Host 'All passed.'
