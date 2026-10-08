<#
    Makes the bitemporal and concurrent-reliance-temporal SQL Server models, models/sqlserver-<name>-bi.xml and
    models/sqlserver-<name>-crt.xml, from the uni-temporal ones (models/sqlserver-<name>.xml): a copy of each that differs
    only in metadata/@temporalization, as the Snowflake models <name>-bi and <name>-crt do. A model says which temporalization
    it is for, and the tools take the directive from that. Each copy then has to be saved through the modeler
    (browser-check.ps1 -Canonicalize), which adds what a bitemporal or concurrent-reliance-temporal model has and a uni one does not
    (the identities of ties, whether an attribute or a tie is assertive, and so on); this script does not do that, so that the step
    can be seen. sqlserver-handwritten is copied too and is, on purpose, not saved through the modeler.

    Usage:
      make-sqlserver-bi-crt-models.ps1
      browser-check.ps1 -Canonicalize -Variant <the names it prints>
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$models = Join-Path (Split-Path -Parent $PSScriptRoot) 'models'
$utf8 = New-Object Text.UTF8Encoding($false)
$made = New-Object System.Collections.Generic.List[string]
foreach ($file in Get-ChildItem $models -Filter 'sqlserver-*.xml' | Sort-Object Name) {
    if ($file.BaseName -match '-(bi|crt)$') { continue }
    $text = [IO.File]::ReadAllText($file.FullName, $utf8)
    if ($text -notmatch '<metadata[^>]*\btemporalization="uni"') { throw "$($file.Name) is not a uni-temporal model" }
    foreach ($t in 'bi', 'crt') {
        $copy = [regex]::Replace($text, '(<metadata[^>]*\btemporalization=")uni(")', ('${1}' + $t + '${2}'), 1)
        if ($copy -ceq $text) { throw "$($file.Name): temporalization was not changed" }
        $name = "$($file.BaseName)-$t"
        [IO.File]::WriteAllText((Join-Path $models "$name.xml"), $copy, $utf8)
        $made.Add($name)
    }
}
Write-Host ('made ' + $made.Count + ' models:')
Write-Host (($made | Where-Object { $_ -notmatch 'handwritten' }) -join ',')
