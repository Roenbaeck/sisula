<#
    Generates "golden" SQL by running the ORIGINAL Anchor Modeler engine, unmodified, under Jint:
    modules/Sisulator.js, modules/Map.js, SQL/Helpers.js, SQL/NamingConvention.js and the
    Snowflake sisulets, all read from an Anchor checkout. The only change made to the engine is
    stripping `async`/`await`, which Jint 2 cannot parse; the directives are read synchronously.

    Usage:
      golden.ps1 -Model <model.xml> -OutDir <dir> [-Anchor <checkout>] [-Directive Snowflake_uni.directive]

    Writes <dir>/_full.sql, the engine's output for the whole directive exactly as it returns it,
    and <dir>/<Sisulet>.sql, the part of that output each sisulet produced. The split comes from a
    second run in which every sisulet first appends a marker line to the output; the markers are
    checked to reproduce _full.sql when removed, so the parts always add up to the whole.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Model,
    [Parameter(Mandatory)] [string] $OutDir,
    [string] $Anchor,
    [string] $Directive = 'Snowflake_uni.directive',
    [string[]] $Prelude = @('SQL/Helpers.js', 'SQL/NamingConvention.js', 'SQL/Snowflake/NamingConvention.js'),
    [string] $JintPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
if (-not $JintPath) { $JintPath = Join-Path $PSScriptRoot '..\..\..\lib\Jint.2.11.58.dll' }
$Anchor = (Resolve-Path $Anchor).Path
. (Join-Path $PSScriptRoot 'xml-to-tree.ps1')
Add-Type -Path (Resolve-Path $JintPath)

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

function Read-AnchorFile([string] $relative) {
    [IO.File]::ReadAllText((Join-Path $Anchor $relative), [Text.Encoding]::UTF8)
}

$treeJson = Convert-XmlFileToTreeJson $Model
$directiveText = Read-AnchorFile $Directive
$sisulator = (Read-AnchorFile 'modules\Sisulator.js') -replace '\basync\s+', '' -replace '\bawait\s+', ''

# Runs the whole directive in a fresh engine. With -Marked, every script in it starts by
# appending the line "§SISULET:<path>§" to the output.
function Invoke-Sisulator([switch] $Marked) {
    $engine = New-Object Jint.Engine
    $engine.SetValue('host', (New-Object SisulaGoldenHost $Anchor)) | Out-Null
    $engine.SetValue('directiveText', $directiveText) | Out-Null
    $engine.SetValue('treeJson', $treeJson) | Out-Null
    $engine.SetValue('marked', [bool] $Marked) | Out-Null
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
    $engine.Execute($sisulator) | Out-Null
    $engine.Execute(@'
function loadScript(name) {
    if (!name) return directiveText;
    var text = host.Read(name);
    // The marker is JavaScript placed before the script's first template block, so it runs in
    // the Sisulator's own scope, where the output accumulates in _sisula_.
    return marked ? '_sisula_ += "\\n\\u00a7SISULET:' + name + '\\u00a7\\n";\n' + text : text;
}
var goldenResult = Sisulator.sisulate(buildDom(JSON.parse(treeJson)), MAP, loadScript);
'@) | Out-Null
    $diag = $engine.Execute('diagnostics.join("\n");').GetCompletionValue().ToObject()
    if ($diag) { Write-Warning "Engine diagnostics:`n$diag" }
    $engine.GetValue('goldenResult').ToObject()
}

$full = Invoke-Sisulator
$marked = Invoke-Sisulator -Marked

# Split the marked output into the parts each script produced.
$parts = New-Object System.Collections.Generic.List[object]
$current = $null
$lines = $marked -split "`n"
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\xA7SISULET:(.+)\xA7$') {
        $current = [pscustomobject]@{ Script = $Matches[1]; Lines = New-Object System.Collections.Generic.List[string] }
        $parts.Add($current)
    } elseif ($null -ne $current) {
        $current.Lines.Add($lines[$i])
    } elseif ($lines[$i] -ne '') {
        throw "Output before the first marker: $($lines[$i])"
    }
}
$endsWithNewline = $marked.EndsWith("`n")
$texts = @{}
for ($p = 0; $p -lt $parts.Count; $p++) {
    $partLines = $parts[$p].Lines
    $isLast = ($p -eq $parts.Count - 1)
    # A part is its lines, each ending in a newline, except where the whole output does not end in one.
    if ($isLast -and $endsWithNewline -and $partLines.Count -gt 0 -and $partLines[$partLines.Count - 1] -eq '') {
        $partLines.RemoveAt($partLines.Count - 1)
    }
    $text = ($partLines | ForEach-Object { $_ + "`n" }) -join ''
    if ($isLast -and -not $endsWithNewline -and $text.EndsWith("`n")) { $text = $text.Substring(0, $text.Length - 1) }
    $texts[$parts[$p].Script] = $text
}
$joined = ($parts | ForEach-Object { $texts[$_.Script] }) -join ''
if ($joined -cne $full) { throw 'The per-sisulet parts do not add up to the full output; the split is not trustworthy.' }

New-Item -ItemType Directory -Force $OutDir | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $OutDir '_full.sql'), $full, $utf8)
$written = 0
foreach ($part in $parts) {
    if ($Prelude -contains $part.Script) {
        if ($texts[$part.Script] -ne '') { throw "The prelude script $($part.Script) produced output." }
        continue
    }
    $name = [IO.Path]::GetFileNameWithoutExtension($part.Script)
    [IO.File]::WriteAllText((Join-Path $OutDir "$name.sql"), $texts[$part.Script], $utf8)
    $written++
}
Write-Host ("{0}: {1:N0} characters, {2} sisulets" -f (Join-Path $OutDir '_full.sql'), $full.Length, $written)
