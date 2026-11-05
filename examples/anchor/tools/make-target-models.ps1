<#
    Makes the models of another database, models/<database>-<name>.xml, from the Snowflake models, models/<name>.xml (and
    <name>-bi, <name>-crt): the data types are converted with the Anchor Modeler's own converter (modules/DataTypeConverter.js,
    Snowflake to the database, which also takes the schema and now to what the database has) and databaseTarget is set. Then
    each model has to be saved through the modeler (browser-check.ps1 -Canonicalize), which fills in what a model made this way
    leaves out; this script does not do that, so that the step can be seen.

    -Types replaces a data type that the database has no type for here: PostgreSQL has geography only with PostGIS, which a plain
    server lacks, so the models that are run on one have text.

    The models are the ones that test what a template does: base (the plain model), distinct (a historized and knotted
    attribute on a nexus, a tie with a nexus role and no identifiers), flags (what may not be restated, and decisiveness),
    national (names with national characters), plain and ranges.

    -From says which database the models are for: Snowflake, unless it is SQLServer, whose models are sqlserver-<name> (the trigger
    models, for instance).

    Usage:
      make-target-models.ps1 -Database PostgreSQL [-Models base,distinct,...] [-Types @{geography='text'}] [-From SQLServer] [-Anchor <checkout>]
      browser-check.ps1 -Canonicalize -Variant <the names it prints>
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $Database,
    [string[]] $Models = @('base', 'distinct', 'flags', 'national', 'plain', 'ranges'),
    [hashtable] $Types = @{},
    [string] $From = 'Snowflake',
    [string] $Anchor
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $Anchor) { $Anchor = Join-Path $PSScriptRoot '..\..\..\..\anchor' }
$Anchor = (Resolve-Path $Anchor).Path
$Models = @($Models | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
Add-Type -Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\lib\Jint.2.11.58.dll'))
$utf8 = New-Object Text.UTF8Encoding($false)
$engine = New-Object Jint.Engine
$engine.Execute([IO.File]::ReadAllText((Join-Path $Anchor 'modules\DataTypeConverter.js'), $utf8)) | Out-Null
$prefix = $Database.ToLowerInvariant()
$sourcePrefix = ''
if ($From -ne 'Snowflake') { $sourcePrefix = $From.ToLowerInvariant() + '-' }

$made = New-Object System.Collections.Generic.List[string]
foreach ($name in $Models) {
    foreach ($suffix in '', '-bi', '-crt') {
        $path = Join-Path $root "models\$sourcePrefix$name$suffix.xml"
        if (-not (Test-Path $path)) { continue }
        $text = [IO.File]::ReadAllText($path, $utf8).TrimStart([char]0xFEFF)
        if ($text -notmatch ('databaseTarget="' + $From + '"')) { throw "$sourcePrefix$name$suffix.xml is not a $From model" }
        $engine.SetValue('modelText', $text) | Out-Null
        $converted = $engine.Execute("DataTypeConverter.convertText(modelText, '$From', '$Database')").GetCompletionValue().AsString()
        $converted = $converted.Replace(('databaseTarget="' + $From + '"'), "databaseTarget=`"$Database`"")
        foreach ($type in $Types.Keys) { $converted = $converted -replace ('(dataRange=")' + [regex]::Escape($type) + '(")'), ('${1}' + $Types[$type] + '${2}') }
        $out = "$prefix-$name$suffix"
        [IO.File]::WriteAllText((Join-Path $root "models\$out.xml"), $converted, $utf8)
        $made.Add($out)
    }
}
Write-Host ('made ' + $made.Count + ' models:')
Write-Host ($made -join ',')
