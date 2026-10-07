<#
    Runs the Anchor generator that is built for Snowflake (tools/build-snowflake-generator.ps1 in the Anchor repository),
    as far as it can be run without Snowflake: the JavaScript of ANCHOR_BINDINGS and SISULATE under Jint, and the
    templates in the order that ANCHOR_GENERATE takes them from ANCHOR_TEMPLATE. For each model it reads the XML of
    models/<name>.xml, as a user would paste it, and the SQL that comes out has to be identical to golden/<name>/_full.sql.

    What this does not run is the SQL around the JavaScript: the CREATE statements, the table and the LISTAGG.
    Those are only run by Snowflake.

    It also checks that the temporalization argument does what editing the model's metadata does.

    Usage:
      hosted-check.ps1 [-Variant <name>,...] [-Anchor <checkout>] [-Parts <directory made by the build script>]
#>
[CmdletBinding()]
param(
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

$temporary = $null
if (-not $Parts) {
    $temporary = Join-Path ([IO.Path]::GetTempPath()) ('hosted-check-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    $Parts = Join-Path $temporary 'parts'
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Anchor 'tools\build-snowflake-generator.ps1') -Anchor $Anchor -Output (Join-Path $temporary 'anchor_generator.sql') -Parts $Parts
    if ($LASTEXITCODE -ne 0) { throw 'The build failed.' }
}
$utf8 = [Text.Encoding]::UTF8
$bindingsBody = [IO.File]::ReadAllText((Join-Path $Parts 'bindings.js'), $utf8)
$sisulateBody = [IO.File]::ReadAllText((Join-Path $Parts 'sisulate.js'), $utf8)
$templates = @(ConvertFrom-Json -InputObject ([IO.File]::ReadAllText((Join-Path $Parts 'templates.json'), $utf8)) | ForEach-Object { $_ })

# The two functions, as Snowflake runs them: the SQL gives the body a function of its arguments.
$engine = New-Object Jint.Engine
$engine.Execute("function ANCHOR_BINDINGS(MODEL_XML, TEMPORALIZATION) {`n$bindingsBody`n}") | Out-Null
$engine.Execute("function SISULATE(TEMPLATE, BINDINGS) {`n$sisulateBody`n}") | Out-Null

if (-not $Variant) { $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name | ForEach-Object { $_.BaseName } | Where-Object { $_ -notmatch '^sqlserver' } }   # the generator in Snowflake is for Snowflake models
$Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$failed = 0

function Get-Bindings([string] $xml, $temporalization) {
    $engine.SetValue('modelXml', $xml) | Out-Null
    $engine.SetValue('wanted', $temporalization) | Out-Null
    $engine.Execute('var bindingsJson = JSON.stringify(ANCHOR_BINDINGS(modelXml, wanted));') | Out-Null
    $engine.GetValue('bindingsJson').AsString()
}

foreach ($v in $Variant) {
    $xml = [IO.File]::ReadAllText((Join-Path $root "models\$v.xml"), $utf8)
    $json = Get-Bindings $xml $null
    $temporalization = [regex]::Match($json, '"temporalization":"(uni|bi|crt)"').Groups[1].Value
    $engine.SetValue('bindingsJson', $json) | Out-Null
    $sql = New-Object Text.StringBuilder
    foreach ($t in @($templates | Where-Object { $_.temporalization -eq $temporalization } | Sort-Object { [int] $_.position })) {
        $engine.SetValue('templateText', [string] $t.body) | Out-Null
        try { $engine.Execute('var rendered = SISULATE(templateText, bindingsJson);') | Out-Null }
        catch {
            $reason = $_.Exception.Message; if ($_.Exception.InnerException) { $reason = $_.Exception.InnerException.Message }
            Write-Host ("FAIL  {0}/{1}: the engine threw: {2}" -f $v, $t.name, $reason); $failed++; continue
        }
        [void] $sql.Append($engine.GetValue('rendered').AsString())
    }
    $golden = ([IO.File]::ReadAllText((Join-Path $root "golden\$v\_full.sql"), $utf8) -replace "`r`n", "`n")
    $actual = $sql.ToString()
    if ($actual -ceq $golden) { Write-Host ("PASS  {0}: ANCHOR_GENERATE would give the golden file ({1:N0} characters)" -f $v, $actual.Length) }
    else {
        $a = $golden -split "`n"; $b = $actual -split "`n"; $i = 0
        while ($i -lt [Math]::Min($a.Count, $b.Count) -and $a[$i] -ceq $b[$i]) { $i++ }
        Write-Host ("FAIL  {0}: differs from the golden file at line {1}" -f $v, ($i + 1))
        Write-Host ("   golden    [{0}]" -f $(if ($i -lt $a.Count) { $a[$i] } else { '(end)' }))
        Write-Host ("   generated [{0}]" -f $(if ($i -lt $b.Count) { $b[$i] } else { '(end)' }))
        $failed++
    }
}

# The argument against editing the metadata: base.xml says uni; ask for bi, and compare with base.xml edited to say bi.
$base = [IO.File]::ReadAllText((Join-Path $root 'models\base.xml'), $utf8)
$edited = $base.Replace('temporalization="uni"', 'temporalization="bi"')
if ($edited -ceq $base) { throw 'base.xml does not say temporalization="uni"' }
foreach ($other in 'bi', 'crt') {
    $asked = Get-Bindings $base $other
    $said = Get-Bindings ($base.Replace('temporalization="uni"', "temporalization=`"$other`"")) $null
    if ($asked -ceq $said) { Write-Host ("PASS  asking for {0} gives the bindings of a model that says {0}" -f $other) }
    else { Write-Host ("FAIL  asking for {0} differs from a model that says {0}" -f $other); $failed++ }
}
# Mistakes in the input have to say what is wrong.
foreach ($case in @(
    @{ Name = 'not XML'; Xml = '<schema><metadata'; Wanted = $null; Expect = 'XML' },
    @{ Name = 'no metadata'; Xml = '<schema format="0.101.2"></schema>'; Wanted = $null; Expect = 'no <metadata>' },
    @{ Name = 'a temporalization that does not exist'; Xml = $base; Wanted = 'tri'; Expect = "'uni', 'bi' or 'crt'" })) {
    try { [void] (Get-Bindings $case.Xml $case.Wanted); Write-Host ("FAIL  {0}: no error" -f $case.Name); $failed++ }
    catch {
        $reason = $_.Exception.Message; if ($_.Exception.InnerException) { $reason = $_.Exception.InnerException.Message }
        if ($reason.Contains($case.Expect)) { Write-Host ("PASS  {0}: {1}" -f $case.Name, $reason) } else { Write-Host ("FAIL  {0}: the message does not say what is wrong: {1}" -f $case.Name, $reason); $failed++ }
    }
}

if ($temporary) { Remove-Item -Recurse -Force $temporary -ErrorAction SilentlyContinue }
if ($failed -gt 0) { exit 1 }
