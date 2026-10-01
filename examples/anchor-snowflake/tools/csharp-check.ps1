<#
    Renders Anchor's templates with the C# renderer of sisula-mssql, the one that runs inside SQL
    Server, and compares the result, byte for byte, with the golden files. Every model, or the ones
    named. The bindings are the ones check.ps1 resolves for the model; only the renderer differs.

    The renderer is tests\bin\FixtureRunner.exe in the sisula-mssql checkout next to this repository
    (build it with tests\run-fixtures.ps1 there); -Runner names another one.

    Usage:
      csharp-check.ps1 [-Variant <name>,...] [-Name <template>,...] [-Runner <FixtureRunner.exe>] [-Anchor <checkout>]
#>
[CmdletBinding()]
param(
    [string[]] $Variant,
    [string[]] $Name,
    [string] $Runner,
    [string] $Anchor
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Runner) { $Runner = Join-Path $PSScriptRoot '..\..\..\..\sisula-mssql\tests\bin\FixtureRunner.exe' }
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
if (-not (Test-Path $Runner)) { throw "No renderer at $Runner. Build it with tests\run-fixtures.ps1 in sisula-mssql, or pass -Runner." }
$Runner = (Resolve-Path $Runner).Path
$Anchor = (Resolve-Path $Anchor).Path
. (Join-Path $PSScriptRoot 'directive.ps1')

$work = Join-Path ([IO.Path]::GetTempPath()) ('sisula-csharp-check-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory $work | Out-Null
if (-not $Variant) { $Variant = Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name | ForEach-Object { $_.BaseName } }
$Variant = @($Variant | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Name = @($Name | ForEach-Object { $_ -split ',' } | Where-Object { $_ })

$total = 0; $failed = 0
try {
    foreach ($v in $Variant) {
        $model = Join-Path $root "models\$v.xml"
        $info = Get-DirectiveInfo $Anchor (Get-ModelTemporalization $model)
        $bindings = Join-Path $work "$v.bindings.json"
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'check.ps1') -Variant $v -Name $info.Templates[0].Name -Anchor $Anchor -KeepBindings $bindings | Out-Null
        foreach ($t in $info.Templates) {
            if ($Name.Count -gt 0 -and $Name -notcontains $t.Name) { continue }
            $out = Join-Path $work "$v.$($t.Name).sql"
            & $Runner --render (Join-Path $Anchor $t.Path) $bindings $out
            $actual = [IO.File]::ReadAllBytes($out)
            $golden = [IO.File]::ReadAllBytes((Join-Path $root "golden\$v\$($t.Name).sql"))
            $total++
            $same = ($actual.Length -eq $golden.Length)
            if ($same) { for ($i = 0; $i -lt $actual.Length; $i++) { if ($actual[$i] -ne $golden[$i]) { $same = $false; break } } }
            if (-not $same) {
                $failed++
                $a = [Text.Encoding]::UTF8.GetString($actual) -split "`n"
                $g = [Text.Encoding]::UTF8.GetString($golden) -split "`n"
                $k = 0
                while ($k -lt [Math]::Min($a.Count, $g.Count) -and $a[$k] -ceq $g[$k]) { $k++ }
                Write-Host ("FAIL  {0}/{1}: golden {2} lines, C# {3} lines; first difference at line {4}" -f $v, $t.Name, $g.Count, $a.Count, ($k + 1))
                Write-Host ("   golden [{0}]" -f $(if ($k -lt $g.Count) { $g[$k] } else { '(end)' }))
                Write-Host ("   C#     [{0}]" -f $(if ($k -lt $a.Count) { $a[$k] } else { '(end)' }))
            }
        }
        Write-Host ("done  {0}" -f $v)
    }
} finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
}
Write-Host ''
Write-Host ("{0} of {1} template renderings identical to the golden files" -f ($total - $failed), $total)
if ($failed -gt 0) { exit 1 }
