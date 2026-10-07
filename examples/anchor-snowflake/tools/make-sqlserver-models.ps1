<#
    Makes the SQL Server models, models/sqlserver-<name>.xml, from the uni models of Snowflake, models/<name>.xml:
    the data types are converted with the Anchor Modeler's own converter (modules/DataTypeConverter.js, Snowflake to
    SQL Server, which also takes the schema to dbo and now to sysdatetime()) and databaseTarget is set. Then each
    model has to be saved through the modeler (browser-check.ps1 -Canonicalize), which fills in what a model made
    this way leaves out; this script does not do that, so that the step can be seen.

    On top of the converted models there are variants that reach what only the SQL Server generators have: business
    views and knot aliases, no triggers, partitioning of equivalent tables, natural keys, encryption.

    Usage:
      make-sqlserver-models.ps1 [-Anchor <checkout>]
      browser-check.ps1 -Canonicalize -Variant <the names it prints>
#>
[CmdletBinding()]
param([string] $Anchor)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
$Anchor = (Resolve-Path $Anchor).Path
Add-Type -Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\lib\Jint.2.11.58.dll'))
$utf8 = New-Object Text.UTF8Encoding($false)
$engine = New-Object Jint.Engine
$engine.Execute([IO.File]::ReadAllText((Join-Path $Anchor 'modules\DataTypeConverter.js'), $utf8)) | Out-Null

function Get-Temporalization([string] $text) { [regex]::Match($text, '<metadata[^>]*\btemporalization="(\w+)"').Groups[1].Value }

$made = New-Object System.Collections.Generic.List[string]
foreach ($file in Get-ChildItem (Join-Path $root 'models') -Filter *.xml | Sort-Object Name) {
    if ($file.BaseName -match '^sqlserver') { continue }
    $text = [IO.File]::ReadAllText($file.FullName, $utf8).TrimStart([char]0xFEFF)
    if ((Get-Temporalization $text) -ne 'uni') { continue }
    if ($text -notmatch 'databaseTarget="Snowflake"') { throw "$($file.Name) is not a Snowflake model" }
    $engine.SetValue('modelText', $text) | Out-Null
    $converted = $engine.Execute("DataTypeConverter.convertText(modelText, 'Snowflake', 'SQLServer')").GetCompletionValue().AsString()
    $converted = $converted.Replace('databaseTarget="Snowflake"', 'databaseTarget="SQLServer"')
    $name = "sqlserver-$($file.BaseName)"
    [IO.File]::WriteAllText((Join-Path $root "models\$name.xml"), $converted, $utf8)
    $made.Add($name)
}

# What only SQL Server has. Each is a change of the metadata of a converted model, which the modeler then saves.
function New-Variant([string] $from, [string] $name, [hashtable] $metadata) {
    $text = [IO.File]::ReadAllText((Join-Path $root "models\$from.xml"), $utf8)
    $match = [regex]::Match($text, '<metadata [^>]*\bdatabaseTarget="SQLServer"[^>]*/>')
    if (-not $match.Success) { throw "$from has no schema metadata" }
    $element = $match.Value
    foreach ($key in $metadata.Keys) {
        $pattern = '\b' + $key + '="[^"]*"'
        if ($element -match $pattern) { $element = [regex]::Replace($element, $pattern, "$key=`"$($metadata[$key])`"") }
        else { $element = $element.Replace('/>', " $key=`"$($metadata[$key])`"/>") }
    }
    [IO.File]::WriteAllText((Join-Path $root "models\$name.xml"), $text.Replace($match.Value, $element), $utf8)
    $made.Add($name)
}
New-Variant 'sqlserver-distinct' 'sqlserver-business' @{ businessViews = 'true'; knotAliases = 'true' }
New-Variant 'sqlserver-distinct' 'sqlserver-notriggers' @{ triggers = 'false' }
New-Variant 'sqlserver-distinct' 'sqlserver-naturalkeys' @{ naturalKeyAttributes = 'true' }
New-Variant 'sqlserver-distinct-equivalence' 'sqlserver-partitioned' @{ partitioning = 'true' }
New-Variant 'sqlserver-distinct' 'sqlserver-deletable' @{ deletability = 'true' }

# Encryption groups are a setting of an attribute. The distinct model has one, the actor's name in group PII; this
# adds the actor's gender to that group, and the stage's name to a group of its own.
$text = [IO.File]::ReadAllText((Join-Path $root 'models\sqlserver-distinct.xml'), $utf8)
$edits = 0
foreach ($target in @(@('AC', 'GEN', 'PII'), @('ST', 'NAM', 'Places'))) {
    $block = [regex]::Match($text, '(?s)<anchor mnemonic="' + $target[0] + '".*?</anchor>')
    $attribute = [regex]::Match($block.Value, '(?s)<attribute mnemonic="' + $target[1] + '"[^>]*>\s*<metadata ')
    if (-not $block.Success -or -not $attribute.Success) { throw "no attribute $($target[0])/$($target[1]) in sqlserver-distinct" }
    $text = $text.Replace($block.Value, $block.Value.Replace($attribute.Value, $attribute.Value + 'encryptionGroup="' + $target[2] + '" '))
    $edits++
}
[IO.File]::WriteAllText((Join-Path $root 'models\sqlserver-encrypted.xml'), $text, $utf8)
$made.Add('sqlserver-encrypted')

Write-Host ('made ' + $made.Count + ' models:')
Write-Host ($made -join ',')
