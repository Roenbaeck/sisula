# Shared by the tools: what a model asks for, and which scripts and templates that means.
#
# A model says which database (metadata/@databaseTarget: Snowflake, SQLServer, ...) and which temporalization
# it is for (metadata/@temporalization: uni, bi or crt). From that follows the directive in the Anchor checkout,
# <Database>_<t>.directive: the scripts that prepare the schema first (Helpers.js, a NamingConvention.js,
# derive.js), then the .sisula templates, in the order to render. Entries that start with # are not run, and a
# template that is not ported stays in the list as a comment. While a database is being ported, the directive of
# the original sisulets is kept as <Database>_<t>.legacy.directive, which golden.ps1 runs.

$script:PreludePattern = '(^|/)(Helpers|NamingConvention|derive)\.js$'

function Get-ModelTemporalization([string] $ModelPath) {
    $xml = New-Object Xml.XmlDocument
    $xml.Load((Resolve-Path $ModelPath).Path)
    $value = $xml.DocumentElement.SelectSingleNode('metadata').GetAttribute('temporalization')
    if (@('uni', 'bi', 'crt') -notcontains $value) { throw "${ModelPath}: unknown temporalization '$value'" }
    $value
}

function Get-ModelDatabase([string] $ModelPath) {
    $xml = New-Object Xml.XmlDocument
    $xml.Load((Resolve-Path $ModelPath).Path)
    $value = $xml.DocumentElement.SelectSingleNode('metadata').GetAttribute('databaseTarget')
    if (-not $value) { throw "${ModelPath}: the model does not say which database it is for (databaseTarget)" }
    $value
}

function Read-DirectiveEntries([string] $Path) {
    ([IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) -replace "`r`n", "`n") -split "`n" |
        ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
}

# Returns Temporalization, Prelude (paths) and Templates (objects with Name and Path, the path relative to the checkout).
function Get-DirectiveInfo([string] $Anchor, [string] $Temporalization, [string] $Database = 'Snowflake') {
    $file = "${Database}_$Temporalization.directive"
    $entries = @(Read-DirectiveEntries (Join-Path $Anchor $file))
    $prelude = @($entries | Where-Object { $_ -match $script:PreludePattern })
    $others = @($entries | Where-Object { $_ -notmatch $script:PreludePattern })
    $notTemplates = @($others | Where-Object { $_ -notlike '*.sisula' })
    if ($notTemplates.Count -gt 0) { throw "$file lists something that is neither a prelude script nor a template: $($notTemplates -join ', ')" }
    $templates = @($others | ForEach-Object { [pscustomobject]@{ Name = [IO.Path]::GetFileNameWithoutExtension($_); Path = $_ } })
    [pscustomobject]@{ Database = $Database; Temporalization = $Temporalization; File = $file; LegacyFile = "${Database}_$Temporalization.legacy.directive"; Prelude = $prelude; Templates = $templates }
}
