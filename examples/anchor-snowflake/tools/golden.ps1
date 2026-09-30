<#
    Generates "golden" SQL by running the ORIGINAL Anchor Modeler engine, unmodified, under Jint:
    modules/Sisulator.js, modules/Map.js, SQL/Helpers.js, SQL/NamingConvention.js and the
    Snowflake sisulets, all read from an Anchor checkout. The only change made to the engine is
    stripping `async`/`await`, which Jint 2 cannot parse; the directives are read synchronously.

    Usage:
      golden.ps1 -Model <model.xml> -Out <file.sql> [-Sisulet CreateKnots] [-Anchor <checkout>]

    With -Sisulet, the output is that one sisulet run after the shared prelude (Helpers and the
    two naming conventions). Without it the whole Snowflake_uni.directive is run.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Model,
    [Parameter(Mandatory)] [string] $Out,
    [string] $Sisulet,
    [string] $Anchor,
    [string] $Directive = 'Snowflake_uni.directive',
    [string] $JintPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
if (-not $JintPath) { $JintPath = Join-Path $PSScriptRoot '..\..\..\..\sisula\code\DLL\Jint.2.11.58.dll' }
$Anchor = (Resolve-Path $Anchor).Path
. (Join-Path $PSScriptRoot 'xml-to-tree.ps1')

Add-Type -Path (Resolve-Path $JintPath)
$engine = New-Object Jint.Engine

function Read-AnchorFile([string] $relative) {
    [IO.File]::ReadAllText((Join-Path $Anchor $relative), [Text.Encoding]::UTF8)
}

# Host services for the engine. Jint cannot call a delegate built from a script block, so the
# file reader is a small C# class. It is compiled once per session.
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
$engine.SetValue('host', (New-Object SisulaGoldenHost $Anchor)) | Out-Null
$engine.Execute(@'
var DEBUG = false;
var diagnostics = [];
var console = { log: function (m) {}, error: function (m) { diagnostics.push('error: ' + m); } };
function alert(m) { diagnostics.push('alert: ' + m); }
if (!String.prototype.padStart) {
    String.prototype.padStart = function (n, pad) {
        var s = String(this); pad = pad === undefined ? ' ' : String(pad);
        while (s.length < n) s = pad + s;
        return s;
    };
}
'@) | Out-Null

$engine.Execute([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'dom-facade.js'))) | Out-Null
$engine.Execute((Read-AnchorFile 'modules\Map.js')) | Out-Null
$sisulator = (Read-AnchorFile 'modules\Sisulator.js') -replace '\basync\s+', '' -replace '\bawait\s+', ''
$engine.Execute($sisulator) | Out-Null

if ($Sisulet) {
    $directiveText = "SQL/Helpers.js`nSQL/NamingConvention.js`nSQL/Snowflake/NamingConvention.js`nSQL/Snowflake/uni/$Sisulet.js`n"
} else {
    $directiveText = Read-AnchorFile $Directive
}
$engine.SetValue('directiveText', $directiveText) | Out-Null
$engine.SetValue('treeJson', (Convert-XmlFileToTreeJson $Model)) | Out-Null

$engine.Execute(@'
var goldenResult = Sisulator.sisulate(
    buildDom(JSON.parse(treeJson)),
    MAP,
    function (name) { return name ? host.Read(name) : directiveText; }
);
'@) | Out-Null

$sql = $engine.GetValue('goldenResult').ToObject()
[IO.File]::WriteAllText($Out, $sql, (New-Object Text.UTF8Encoding($false)))
$diag = $engine.Execute('diagnostics.join("\n");').GetCompletionValue().ToObject()
if ($diag) { Write-Warning "Engine diagnostics:`n$diag" }
Write-Host ("{0}: {1:N0} characters" -f $Out, $sql.Length)
