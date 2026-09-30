<#
    Derives the variant models from models/base.xml, the Anchor Modeler's Snowflake example, and
    then saves each of them through the modeler itself (browser-check.ps1 -Canonicalize), so that
    every model is one the modeler would have written. Needs Microsoft Edge and an Anchor checkout.

    The edits are plain text replacements. Each states how many places it must change, and the
    script stops if a pattern matches anything else, so a change to base.xml cannot silently
    produce a different variant. Saving through the modeler matters because the modeler fills in
    every flag a file leaves out, from its defaults, and applies its own rules when it loads a
    model; an edited file can mean something else to it than to a direct reading. Flags the
    variants rely on are therefore set explicitly, including equivalent="false" where equivalence
    is on and a construct should not be equivalent.

      equivalence            equivalence on: equivalent and non-equivalent knots (one equivalent
                             knot is also a generator), a generator knot, equivalent and
                             non-equivalent historized and static attributes, checksums
      equivalence-plain      the same without metadata columns, which reaches the dummy columns
      plain                  no metadata columns, the original naming convention, partitioning
      undescribed            no descriptions anywhere, so no comments and no COMMENT clauses
      distinct               a different capsule for every kind of construct and a different
                             identity type for every anchor and nexus, so a template that takes a
                             name or type from the wrong construct shows; also non-generator
                             anchors and nexus, checksummed knots, historized and knotted nexus
                             attributes, a historized tie with a nexus role and no identifiers, an
                             encrypted attribute, and some constructs without descriptions
      distinct-equivalence   distinct with equivalence on, and equivalent and non-equivalent
                             knots and attributes of every kind, nexus attributes included
      equivalence-original   distinct-equivalence with the original naming convention, where
                             knotted columns have no equivalent or checksum names

    One model is deliberately left as edited and not saved through the modeler:

      handwritten            distinct-equivalence with equivalence off, so knots and attributes
                             keep equivalent flags the modeler would drop, and tie and nexus roles
                             keep the missing descriptions the modeler would fill in. It is checked
                             against the original engine only: it shows that the templates test
                             exactly what the sisulets test, also on files the modeler did not write.
#>
[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$models = Join-Path (Split-Path -Parent $PSScriptRoot) 'models'
$base = [IO.File]::ReadAllText((Join-Path $models 'base.xml'))

function Edit([string] $text, [string] $pattern, [string] $replacement, [int] $expected = 1) {
    $count = [regex]::Matches($text, $pattern).Count
    if ($count -ne $expected) { throw "Expected $expected match(es) of '$pattern' but found $count" }
    [regex]::Replace($text, $pattern, $replacement)
}
function Save([string] $name, [string] $text) {
    [IO.File]::WriteAllText((Join-Path $models "$name.xml"), $text, (New-Object Text.UTF8Encoding($false)))
    Write-Host "wrote models\$name.xml"
}

# equivalence
$t = $base
$t = Edit $t 'equivalence="false"' 'equivalence="true"'
$t = Edit $t '(<knot mnemonic="PAT"[^>]*>\s*<metadata capsule="public" generator=")false(")' '${1}true" equivalent="true$2'
$t = Edit $t '(<knot mnemonic="GEN"[^>]*>\s*<metadata capsule="public" generator="false")' '$1 equivalent="true"'
$t = Edit $t '(<knot mnemonic="RAT"[^>]*>\s*<metadata capsule="public" generator=")false(")' '${1}true$2'
$t = Edit $t '(<knot mnemonic="(PLV|UTL|ETY)"[^>]*>\s*<metadata [^>]*?)/>' '$1 equivalent="false"/>' 3
$t = Edit $t '(<attribute mnemonic="NAM"[^>]*timeRange[^>]*>\s*<metadata privacy="Ignore" capsule="public")' '$1 equivalent="true" checksum="true"' 2
$t = Edit $t '(<attribute mnemonic="LOC"[^>]*>\s*<metadata privacy="Ignore" capsule="public")' '$1 equivalent="true"'
$t = Edit $t '(<attribute mnemonic="NAM" descriptor="Name" dataRange="varchar\(42\)">\s*<metadata privacy="Ignore" capsule="public")' '$1 equivalent="false"'
$t = Edit $t '(<attribute mnemonic="(LEN|AUD)"[^>]*>\s*<metadata privacy="Ignore" capsule="public")' '$1 equivalent="false"' 2
Save 'equivalence' $t

# equivalence-plain
$t = Edit $t 'metadataUsage="true"' 'metadataUsage="false"'
Save 'equivalence-plain' $t

# plain
$t = $base
$t = Edit $t 'metadataUsage="true"' 'metadataUsage="false"'
$t = Edit $t 'naming="improved"' 'naming="original"'
$t = Edit $t 'partitioning="false"' 'partitioning="true"'
Save 'plain' $t

# undescribed
Save 'undescribed' (Edit $base '\s*<description>[^<]*</description>' '' 53)

# distinct
$t = $base
$t = Edit $t 'encapsulation="public"' 'encapsulation="dw"'
$t = Edit $t '(<knot [^>]*>\s*<metadata )capsule="public"' '${1}capsule="knots"' 7
$t = Edit $t '(<anchor [^>]*>\s*<metadata )capsule="public"' '${1}capsule="anchors"' 4
$t = Edit $t '(<nexus [^>]*>\s*<metadata )capsule="public"' '${1}capsule="nexuses"'
$t = Edit $t '(<attribute [^>]*>\s*<metadata privacy="Ignore" )capsule="public"' '${1}capsule="attributes"' 12
$t = Edit $t '(</role>\s*<metadata )capsule="public"' '${1}capsule="ties"' 7
$t = Edit $t '(<anchor mnemonic="PN" descriptor="Person" identity=")int(")' '${1}bigint$2'
$t = Edit $t '(<anchor mnemonic="AC" descriptor="Actor" identity=")int(")' '${1}smallint$2'
$t = Edit $t '(<anchor mnemonic="PR" descriptor="Program" identity=")int(")' '${1}number(10,0)$2'
$t = Edit $t '(<nexus mnemonic="EV" descriptor="Event" identity=")int(")' '${1}numeric(12,0)$2'
$t = Edit $t '(<anchor mnemonic="(ST|PR)"[^>]*>\s*<metadata [^>]*generator=")true(")' '${1}false$3' 2
$t = Edit $t '(<nexus mnemonic="EV"[^>]*>\s*<metadata [^>]*generator=")true(")' '${1}false$2'
$t = Edit $t '(<knot mnemonic="RAT"[^>]*>\s*<metadata [^>]*generator=")false(")' '${1}true" checksum="true$2'
$t = Edit $t '(<knot mnemonic="(GEN|ETY)"[^>]*>\s*<metadata [^>]*generator="false")' '$1 checksum="true"' 2
$t = Edit $t '(<attribute mnemonic="NAM"[^>]*>\s*<metadata privacy="Ignore" capsule="attributes" restatable="false")' '$1 encryptionGroup="PII"'
$nexusAttributes = @'
<attribute mnemonic="STA" descriptor="Status" timeRange="datetime" dataRange="varchar(20)">
<metadata privacy="Ignore" capsule="attributes" idempotent="false" deletable="false"/>
<description>
Status of the event, which may change until it has taken place.
</description>
</attribute>
<attribute mnemonic="UTL" descriptor="Utilization" knotRange="UTL">
<metadata privacy="Ignore" capsule="attributes" idempotent="false" deletable="false"/>
</attribute>
<attribute mnemonic="LVL" descriptor="Level" timeRange="date" knotRange="PLV">
<metadata privacy="Ignore" capsule="attributes" idempotent="false" deletable="false"/>
<description>
Professional level required for the event, over time.
</description>
</attribute>

'@
$t = Edit $t '(</attribute>\s*)(<role role="wasHeldAt")' ('$1' + $nexusAttributes.Replace('$', '$$') + '$2')
$t = Edit $t '<tie>(\s*<role role="content" type="PR")' '<tie timeRange="datetime">$1'
$t = Edit $t '<role role="of" type="EV" identifier="true">' '<role role="of" type="EV" identifier="false">'
$t = Edit $t '(<knot mnemonic="ETY"[^>]*>\s*<metadata[^>]*/>\s*<layout[^>]*/>)\s*<description>[^<]*</description>' '$1'
$t = Edit $t '(<role role="of" type="ETY" identifier="false">)\s*<description>[^<]*</description>' '$1'
$t = Edit $t '(<role role="subset" type="AC" identifier="false">)\s*<description>[^<]*</description>' '$1'
$t = Edit $t '(<role role="of" type="PN" identifier="false">[\s\S]*?</role>\s*<metadata[^>]*/>\s*<layout[^>]*/>)\s*<description>[^<]*</description>' '$1'
$t = Edit $t '(<layout[^>]*/>)\s*<description>[^<]*</description>(\s*</anchor>\s*<nexus)' '$1$2'
Save 'distinct' $t

# distinct-equivalence
$t = Edit $t 'equivalence="false"' 'equivalence="true"'
$t = Edit $t '(<knot mnemonic="(PAT|PLV|RAT|ETY)"[^>]*>\s*<metadata [^>]*?)/>' '$1 equivalent="true"/>' 4
$t = Edit $t '(<knot mnemonic="(GEN|UTL)"[^>]*>\s*<metadata [^>]*?)/>' '$1 equivalent="false"/>' 2
$t = Edit $t '(<attribute mnemonic="NAM"[^>]*>\s*<metadata privacy="Ignore" capsule="attributes" restatable="true")' '$1 equivalent="true"'
$t = Edit $t '(<attribute mnemonic="NAM"[^>]*>\s*<metadata privacy="Ignore" capsule="attributes" restatable="false")' '$1 equivalent="false"'
$t = Edit $t '(<attribute mnemonic="NAM" descriptor="Name" dataRange="varchar\(42\)">\s*<metadata privacy="Ignore" capsule="attributes")' '$1 equivalent="false"'
$t = Edit $t '(<attribute mnemonic="(LOC|STA|AUD)"[^>]*>\s*<metadata privacy="Ignore" capsule="attributes")' '$1 equivalent="true"' 3
$t = Edit $t '(<attribute mnemonic="DAT"[^>]*>\s*<metadata privacy="Ignore" capsule="attributes")' '$1 equivalent="false"'
Save 'distinct-equivalence' $t

# handwritten: not saved through the modeler, see above
Save 'handwritten' (Edit $t 'equivalence="true"' 'equivalence="false"')

# equivalence-original
Save 'equivalence-original' (Edit $t 'naming="improved"' 'naming="original"')

# Save every variant except base and handwritten the way the modeler would.
$canonical = 'equivalence', 'equivalence-plain', 'plain', 'undescribed', 'distinct', 'distinct-equivalence', 'equivalence-original'
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'browser-check.ps1') -Canonicalize -Variant ($canonical -join ',')
if ($LASTEXITCODE -ne 0) { throw 'Saving the variants through the modeler failed.' }
