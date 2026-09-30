<#
    Runs every fixture in tests/fixtures/*.json against core/sisula.js using Jint, the same
    ES5 engine the PowerShell tools use. Use this where Node is not installed.

    Usage: .\tests\run.ps1 [-JintPath <path to Jint.dll>]
#>
[CmdletBinding()]
param(
    [string] $JintPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# Jint 2.x is not vendored here. Point -JintPath at a copy, or rely on the sibling checkout.
if (-not $JintPath) {
    $JintPath = Join-Path $PSScriptRoot '..\..\sisula\code\DLL\Jint.2.11.58.dll'
}
Add-Type -Path (Resolve-Path $JintPath)
$engine = New-Object Jint.Engine
$engine.Execute([IO.File]::ReadAllText((Resolve-Path (Join-Path $PSScriptRoot '..\core\sisula.js')))) | Out-Null

$engine.Execute(@'
function runFixtures(text, file) {
    var cases = JSON.parse(text), failures = [], n = 0;
    for (var i = 0; i < cases.length; i++) {
        var c = cases[i];
        var actual = sisulate(c.template, JSON.stringify(c.bindings));
        n++;
        if (actual !== c.expected) {
            failures.push('FAIL ' + file + ': ' + c.name + '\n  expected: ' + JSON.stringify(c.expected) + '\n  actual:   ' + JSON.stringify(actual));
        }
    }
    return JSON.stringify({ total: n, failures: failures });
}
'@) | Out-Null

$total = 0
$failed = 0
foreach ($file in Get-ChildItem (Join-Path $PSScriptRoot 'fixtures') -Filter *.json | Sort-Object Name) {
    $engine.SetValue('fixtureText', [IO.File]::ReadAllText($file.FullName)) | Out-Null
    $engine.SetValue('fixtureFile', $file.Name) | Out-Null
    $engine.Execute('var fixtureResult = runFixtures(fixtureText, fixtureFile);') | Out-Null
    $result = $engine.GetValue('fixtureResult').AsString() | ConvertFrom-Json
    $total += $result.total
    foreach ($f in @($result.failures)) { $failed++; Write-Host $f }
}

Write-Host ("{0} passed, {1} failed" -f ($total - $failed), $failed)
if ($failed -gt 0) { exit 1 }
