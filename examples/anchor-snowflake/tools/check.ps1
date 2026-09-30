<#
    Renders the dialect B templates for a model and compares them with the golden output of the
    original engine (made by golden.ps1).

    Usage:
      check.ps1 [-Variant base|equivalence|plain] [-Name CreateKnots,...] [-KeepBindings <file>]

    The model is models/<Variant>.xml and the golden files are golden/<Variant>/.

    For each name, templates/<Name>.sisula is rendered against the resolved model and compared
    with golden/<Name>.sql. Blank lines and trailing whitespace are ignored: the two engines treat
    the newlines around /*~ ~*/ blocks differently, which carries no meaning in SQL.
    Exits 1 if any comparison differs.
#>
[CmdletBinding()]
param(
    [string] $Variant = 'base',
    [string] $Model,
    [string[]] $Name = @('CreateKnots', 'CreateAnchors', 'CreateAttributes', 'CreateTies'),
    [string] $Anchor,
    [string] $JintPath,
    [string] $KeepBindings,
    [string] $GoldenDir,
    [int] $ContextLines = 3
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = Split-Path -Parent $here
if (-not $Anchor)     { $Anchor = Join-Path $here '..\..\..\..\anchor' }
if (-not $JintPath)   { $JintPath = Join-Path $here '..\..\..\..\sisula\code\DLL\Jint.2.11.58.dll' }
if (-not $Model)      { $Model = Join-Path $root (Join-Path 'models' ($Variant + '.xml')) }
if (-not $GoldenDir)  { $GoldenDir = Join-Path $root (Join-Path 'golden' $Variant) }
$Anchor = (Resolve-Path $Anchor).Path
. (Join-Path $here 'xml-to-tree.ps1')

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

function Read-Text([string] $path) { [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8) }

$engine = New-Object Jint.Engine
$engine.SetValue('host', (New-Object SisulaGoldenHost $Anchor)) | Out-Null
$engine.Execute('var XPathResult; var diagnostics = [];') | Out-Null
$engine.Execute((Read-Text (Join-Path $here 'dom-facade.js'))) | Out-Null
$engine.Execute((Read-Text (Join-Path $Anchor 'modules\Map.js'))) | Out-Null
$engine.Execute((Read-Text (Join-Path $here 'resolve-model.js'))) | Out-Null
$engine.Execute((Read-Text (Join-Path $root '..\..\core\sisula.js'))) | Out-Null

# Resolve the model once; every template renders against the same bindings.
$engine.SetValue('treeJson', (Convert-XmlFileToTreeJson $Model)) | Out-Null
$engine.Execute(@'
var bindingsJson = JSON.stringify(resolveModel(
    buildDom(JSON.parse(treeJson)),
    MAP,
    [host.Read('SQL/Helpers.js'), host.Read('SQL/NamingConvention.js'), host.Read('SQL/Snowflake/NamingConvention.js')]
), null, 2);
'@) | Out-Null
$bindings = $engine.GetValue('bindingsJson').AsString()
if ($KeepBindings) { [IO.File]::WriteAllText($KeepBindings, $bindings, (New-Object Text.UTF8Encoding($false))) }

function Normalize([string] $text) {
    ($text -split "`r?`n" | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ -ne '' }) -join "`n"
}

$failed = 0
foreach ($n in $Name) {
    $templatePath = Join-Path $root "templates\$n.sisula"
    $goldenPath = Join-Path $GoldenDir "$n.sql"
    if (-not (Test-Path $templatePath)) { Write-Host ("SKIP  {0}: no template" -f $n); continue }
    $engine.SetValue('templateText', (Read-Text $templatePath)) | Out-Null
    $engine.SetValue('bindingsText', $bindings) | Out-Null
    try {
        $engine.Execute('var rendered = sisulate(templateText, bindingsText);') | Out-Null
        $actual = $engine.GetValue('rendered').AsString()
    } catch {
        Write-Host ("FAIL  {0}/{1}: the renderer threw: {2}" -f $Variant, $n, $_.Exception.InnerException.Message)
        $failed++
        continue
    }
    $expectedLines = (Normalize (Read-Text $goldenPath)) -split "`n"
    $actualLines = (Normalize $actual) -split "`n"
    $diff = Compare-Object $expectedLines $actualLines -SyncWindow 0 -CaseSensitive
    if (-not $diff -and $expectedLines.Count -eq $actualLines.Count) {
        Write-Host ("PASS  {0}/{1} ({2} lines)" -f $Variant, $n, $expectedLines.Count)
        continue
    }
    $failed++
    # Report the first line that differs, with a little context from the golden output.
    $limit = [Math]::Min($expectedLines.Count, $actualLines.Count)
    $first = 0
    while ($first -lt $limit -and $expectedLines[$first] -ceq $actualLines[$first]) { $first++ }
    Write-Host ("FAIL  {0}/{1}: golden has {1} lines, rendered has {2}; first difference at line {4}" -f $Variant, $n, $expectedLines.Count, $actualLines.Count, ($first + 1))
    $from = [Math]::Max(0, $first - $ContextLines)
    for ($i = $from; $i -lt $first; $i++) { Write-Host ("        {0}" -f $expectedLines[$i]) }
    Write-Host ("   -    {0}" -f $(if ($first -lt $expectedLines.Count) { $expectedLines[$first] } else { '(end of golden)' }))
    Write-Host ("   +    {0}" -f $(if ($first -lt $actualLines.Count) { $actualLines[$first] } else { '(end of output)' }))
}

if ($failed -gt 0) { exit 1 }
