# Shared by the tools: what a model asks for, and which scripts and templates that means.
#
# A model says which temporalization it is for (metadata/@temporalization: uni, bi or crt). From that
# follow the directives in the Anchor checkout:
#
#   Snowflake_<t>.legacy.directive   the original sisulets, in the original dialect. The golden files
#                                    are made from it. Until a temporalization has been switched to the
#                                    Sisula engine there is no such file, and Snowflake_<t>.directive
#                                    itself is the original list.
#   Snowflake_<t>.directive          after the switch: the prelude scripts, then the .sisula templates.
#
# The prelude is every entry that prepares the schema (Helpers.js, a NamingConvention.js, derive.js).
# The templates are the other entries; the template for SQL/Snowflake/bi/CreateKnots.js is
# SQL/Snowflake/bi/CreateKnots.sisula, next to it.

$script:PreludePattern = '(^|/)(Helpers|NamingConvention|derive)\.js$'

function Get-ModelTemporalization([string] $ModelPath) {
    $xml = New-Object Xml.XmlDocument
    $xml.Load((Resolve-Path $ModelPath).Path)
    $value = $xml.DocumentElement.SelectSingleNode('metadata').GetAttribute('temporalization')
    if (@('uni', 'bi', 'crt') -notcontains $value) { throw "${ModelPath}: unknown temporalization '$value'" }
    $value
}

function Read-DirectiveEntries([string] $Path) {
    ([IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) -replace "`r`n", "`n") -split "`n" |
        ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
}

# Returns Temporalization, LegacyFile (name), Prelude (paths), Templates (objects with Name, Legacy and
# Path, the paths relative to the checkout) and Switched (whether Snowflake_<t>.directive lists templates).
# Throws if a switched directive does not list exactly the prelude and templates of the legacy one.
function Get-DirectiveInfo([string] $Anchor, [string] $Temporalization) {
    $current = "Snowflake_$Temporalization.directive"
    $legacyFile = "Snowflake_$Temporalization.legacy.directive"
    if (-not (Test-Path (Join-Path $Anchor $legacyFile))) { $legacyFile = $current }
    $legacy = @(Read-DirectiveEntries (Join-Path $Anchor $legacyFile))
    $prelude = @($legacy | Where-Object { $_ -match $script:PreludePattern })
    # derive.js is new: the original directives do not know it.
    if ($prelude -notcontains 'SQL/Snowflake/derive.js') { $prelude += 'SQL/Snowflake/derive.js' }
    $templates = @($legacy | Where-Object { $_ -notmatch $script:PreludePattern } | ForEach-Object {
        [pscustomobject]@{
            Name = [IO.Path]::GetFileNameWithoutExtension($_)
            Legacy = $_
            Path = ($_ -replace '\.js$', '.sisula')
        }
    })
    $entries = @(Read-DirectiveEntries (Join-Path $Anchor $current))
    $switched = (@($entries | Where-Object { $_ -like '*.sisula' }).Count -gt 0)
    if ($switched) {
        $expected = @($prelude) + @($templates | ForEach-Object { $_.Path })
        if (($entries -join ',') -cne ($expected -join ',')) {
            throw ("$current does not list the prelude and templates of $legacyFile.`n  directive: {0}`n  expected:  {1}" -f ($entries -join ', '), ($expected -join ', '))
        }
    }
    [pscustomobject]@{
        Temporalization = $Temporalization
        LegacyFile = $legacyFile
        Prelude = $prelude
        Templates = $templates
        Switched = $switched
    }
}
