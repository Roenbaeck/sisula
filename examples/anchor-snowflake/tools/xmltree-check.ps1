<#
    Checks that Anchor's XML reader (modules/XmlTree.js), which the generator in Snowflake uses because a
    JavaScript function there has no DOMParser, makes the same tree as the PowerShell converter,
    xml-to-tree.ps1, for every model (whitespace between elements included), and that it handles entities,
    CDATA, line ends and malformed input.

    Usage:
      xmltree-check.ps1 [-Anchor <checkout>]
#>
param([string] $Anchor)
$ErrorActionPreference = 'Stop'
$example = Split-Path -Parent $PSScriptRoot
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
$XmlTree = Join-Path (Resolve-Path $Anchor).Path 'modules\XmlTree.js'
Add-Type -Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\lib\Jint.2.11.58.dll'))
. (Join-Path $example 'tools\xml-to-tree.ps1')
$engine = New-Object Jint.Engine
$engine.Execute([IO.File]::ReadAllText($XmlTree)) | Out-Null
$bad = 0; $n = 0
foreach ($m in Get-ChildItem (Join-Path $example 'models') -Filter *.xml | Sort-Object Name) {
    $n++
    $reference = Convert-XmlFileToTreeJson $m.FullName
    $engine.SetValue('xmlText', [IO.File]::ReadAllText($m.FullName, [Text.Encoding]::UTF8)) | Out-Null
    $engine.SetValue('referenceJson', $reference) | Out-Null
    $same = $engine.Execute('JSON.stringify(XmlTree.parse(xmlText)) === JSON.stringify(JSON.parse(referenceJson))').GetCompletionValue().AsBoolean()
    if (-not $same) { $bad++; "DIFFERENT: $($m.Name)" }
}
"models: $n, trees that differ from xml-to-tree.ps1: $bad"
# a few things that the models do not contain
$engine.Execute(@'
function t(xml) { return JSON.stringify(XmlTree.parse(xml)); }
var results = [];
results.push(t('<?xml version="1.0"?><!-- c --><a x="1" y=\'2\'><b/><c>t &amp; &lt;u&gt; &#65;&#x42;</c><![CDATA[<raw>]]></a>'));
results.push(t('<a x=""/>'));
results.push(t('<a>\r\n<b/>\r\n</a>'));
var errors = [];
['<a>', '<a></b>', '<a x=1/>', '', '<a/><b/>', '<a>&nope;</a>'].forEach(function (x) { try { XmlTree.parse(x); errors.push('NO ERROR: ' + x); } catch (e) { errors.push(String(e.message)); } });
'' + results.join('\n') + '\n--\n' + errors.join('\n');
'@).GetCompletionValue().AsString()