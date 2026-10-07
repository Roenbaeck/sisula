<#
    Renders Anchor's Sisula templates for a model and compares them, byte for byte, with the golden
    files (approved output; -Update writes them, see regenerate-golden.ps1). The templates, the directive that lists them and
    the engine all come from the Anchor checkout.

    Usage:
      check.ps1 [-Variant <name>] [-Name CreateKnots,...] [-Loose] [-Update] [-KeepBindings <file>] [-KeepOutput <dir>]

    The model is models/<Variant>.xml and the golden files are golden/<Variant>/. Every template
    in Anchor's Snowflake_uni.directive is rendered and compared with golden/<Variant>/<Name>.sql,
    and then the whole output, the templates concatenated in directive order, with _full.sql.
    -Name renders only some templates and skips the whole-output comparison.

    The comparison is exact: every character, including trailing spaces, must match. Line endings
    are the only thing normalised. -Loose also ignores blank lines and trailing whitespace, which
    helps while porting. Exits 1 if anything differs.
#>
[CmdletBinding()]
param(
    [string] $Variant = 'base',
    [string] $Model,
    [string[]] $Name,
    [switch] $Loose,
    [switch] $Update,
    [string] $Anchor,
    [string] $JintPath,
    [string] $KeepBindings,
    [string] $KeepOutput,
    [string] $GoldenDir,
    [int] $ContextLines = 3
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = Split-Path -Parent $here
if (-not $Anchor)     { $Anchor = Join-Path $here '..\..\..\..\anchor' }
if (-not $JintPath)   { $JintPath = Join-Path $here '..\..\..\lib\Jint.2.11.58.dll' }
if (-not $Model)      { $Model = Join-Path $root (Join-Path 'models' ($Variant + '.xml')) }
if (-not $GoldenDir)  { $GoldenDir = Join-Path $root (Join-Path 'golden' $Variant) }
$Anchor = (Resolve-Path $Anchor).Path
. (Join-Path $here 'xml-to-tree.ps1')
. (Join-Path $here 'directive.ps1')

Add-Type -Path (Resolve-Path $JintPath)
if (-not ('SisulaGoldenHost' -as [type])) {
    Add-Type -TypeDefinition @"
using System.IO;
using System.Text;
public class SisulaGoldenHost {
    private readonly string root;
    public SisulaGoldenHost(string root) { this.root = root; }
    public string Read(string relative) { return File.ReadAllText(Path.Combine(root, relative), Encoding.UTF8); }
}
"@
}

function Read-Text([string] $path) { [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8) -replace "`r`n", "`n" }
function Read-Directive([string] $path) {
    (Read-Text $path) -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
}

# What the model asks for decides the directive: the scripts that prepare the schema (Helpers.js, the
# naming conventions, derive.js) and then the templates, in the order to render. Once a
# temporalization has been switched to the Sisula engine its directive has to list exactly these.
$temporalization = Get-ModelTemporalization $Model
try { $info = Get-DirectiveInfo $Anchor $temporalization }
catch { Write-Host "FAIL  $($_.Exception.Message)"; exit 1 }
$prelude = $info.Prelude
$directive = @($info.Templates | ForEach-Object { $_.Name })
$templatePaths = @{}
foreach ($t in $info.Templates) { $templatePaths[$t.Name] = Join-Path $Anchor $t.Path }
$whole = -not $Name
if (-not $Name) { $Name = $directive }
# powershell -File passes "A,B" as one string.
$Name = @($Name | ForEach-Object { $_ -split ',' } | Where-Object { $_ })

$engine = New-Object Jint.Engine
$engine.SetValue('host', (New-Object SisulaGoldenHost $Anchor)) | Out-Null
$engine.Execute('var XPathResult;') | Out-Null
$engine.Execute((Read-Text (Join-Path $here 'dom-facade.js'))) | Out-Null
$engine.Execute((Read-Text (Join-Path $Anchor 'modules\Map.js'))) | Out-Null
# Anchor's own Sisulator.objectify and Resolver. The Sisulator also holds the original engine, whose
# async/await Jint 2 cannot parse; it is not used here, so they are stripped.
$engine.Execute(((Read-Text (Join-Path $Anchor 'modules\Sisulator.js')) -replace '\basync\s+', '' -replace '\bawait\s+', '')) | Out-Null
$engine.Execute((Read-Text (Join-Path $Anchor 'modules\Resolver.js'))) | Out-Null
$engine.Execute((Read-Text (Join-Path $here 'resolve-model.js'))) | Out-Null
$engine.Execute((Read-Text (Join-Path $Anchor 'modules\sisula.js'))) | Out-Null

# Resolve the model once, with the scripts that the directive starts with. Every template renders
# against the same bindings.
$engine.SetValue('treeJson', (Convert-XmlFileToTreeJson $Model)) | Out-Null
$engine.SetValue('preludeNames', ($prelude -join '|')) | Out-Null
$engine.Execute(@'
var bindingsJson = JSON.stringify(resolveModel(
    buildDom(JSON.parse(treeJson)),
    MAP,
    preludeNames.split('|').map(function (name) { return host.Read(name); })
), null, 2);
'@) | Out-Null
$bindings = $engine.GetValue('bindingsJson').AsString()
$utf8 = New-Object Text.UTF8Encoding($false)
if ($KeepBindings) { [IO.File]::WriteAllText($KeepBindings, $bindings, $utf8) }
if ($KeepOutput) { New-Item -ItemType Directory -Force $KeepOutput | Out-Null }
# -Update accepts the rendered output as the golden files, instead of comparing with them. For a whole model it first
# removes the golden files of templates that no longer exist.
if ($Update) {
    New-Item -ItemType Directory -Force $GoldenDir | Out-Null
    if ($whole) { Get-ChildItem $GoldenDir -Filter *.sql | Remove-Item }
}
$engine.SetValue('bindingsText', $bindings) | Out-Null

function Get-Lines([string] $text) {
    $lines = $text -split "`n"
    if ($Loose) { $lines = $lines | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ -ne '' } }
    , @($lines)
}

# Compares two texts; prints PASS or the first difference. Returns $true when they are equal.
function Compare-Text([string] $label, [string] $expected, [string] $actual) {
    if ($Loose) { $equal = ((Get-Lines $expected) -join "`n") -ceq ((Get-Lines $actual) -join "`n") }
    else { $equal = $expected -ceq $actual }
    $expectedLines = Get-Lines $expected
    $actualLines = Get-Lines $actual
    if ($equal) {
        Write-Host ("PASS  {0} ({1} lines{2})" -f $label, $expectedLines.Count, $(if ($Loose) { ', loose' } else { '' }))
        return $true
    }
    $limit = [Math]::Min($expectedLines.Count, $actualLines.Count)
    $first = 0
    while ($first -lt $limit -and $expectedLines[$first] -ceq $actualLines[$first]) { $first++ }
    Write-Host ("FAIL  {0}: golden has {1} lines, rendered has {2}; first difference at line {3}" -f $label, $expectedLines.Count, $actualLines.Count, ($first + 1))
    # Lines are shown between brackets, so trailing spaces are visible.
    $from = [Math]::Max(0, $first - $ContextLines)
    for ($i = $from; $i -lt $first; $i++) { Write-Host ("        [{0}]" -f $expectedLines[$i]) }
    Write-Host ("   -    {0}" -f $(if ($first -lt $expectedLines.Count) { '[' + $expectedLines[$first] + ']' } else { '(end of golden)' }))
    Write-Host ("   +    {0}" -f $(if ($first -lt $actualLines.Count) { '[' + $actualLines[$first] + ']' } else { '(end of output)' }))
    return $false
}

$failed = 0
$outputs = New-Object System.Collections.Generic.List[string]
foreach ($n in $Name) {
    $templatePath = $templatePaths[$n]
    if (-not $templatePath) { $templatePath = Join-Path $Anchor "SQL\Snowflake\$temporalization\$n.sisula" }
    if (-not (Test-Path $templatePath)) { Write-Host ("FAIL  {0}/{1}: no template" -f $Variant, $n); $failed++; $whole = $false; continue }
    $engine.SetValue('templateText', (Read-Text $templatePath)) | Out-Null
    try {
        $engine.Execute('var rendered = sisulate(templateText, bindingsText);') | Out-Null
        $actual = $engine.GetValue('rendered').AsString()
    } catch {
        $reason = $_.Exception.Message
        if ($_.Exception.InnerException) { $reason = $_.Exception.InnerException.Message }
        Write-Host ("FAIL  {0}/{1}: the renderer threw: {2}" -f $Variant, $n, $reason)
        $failed++; $whole = $false
        continue
    }
    $outputs.Add($actual)
    if ($KeepOutput) { [IO.File]::WriteAllText((Join-Path $KeepOutput "$n.sql"), $actual, $utf8) }
    $goldenPath = Join-Path $GoldenDir "$n.sql"
    if ($Update) { [IO.File]::WriteAllText($goldenPath, $actual, $utf8); continue }
    if (-not (Compare-Text "$Variant/$n" (Read-Text $goldenPath) $actual)) { $failed++ }
}

if ($whole) {
    $full = $outputs -join ''
    if ($KeepOutput) { [IO.File]::WriteAllText((Join-Path $KeepOutput '_full.sql'), $full, $utf8) }
    if ($Update) { [IO.File]::WriteAllText((Join-Path $GoldenDir '_full.sql'), $full, $utf8); Write-Host ("updated  {0}: {1:N0} characters, {2} templates" -f $Variant, $full.Length, $outputs.Count) }
    elseif (-not (Compare-Text "$Variant/(whole output)" (Read-Text (Join-Path $GoldenDir '_full.sql')) $full)) { $failed++ }
}

if ($failed -gt 0) { exit 1 }
