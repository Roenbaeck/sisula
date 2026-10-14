<#
    Makes models/keys.xml, keys-bi.xml and keys-crt.xml from models/base.xml: base with more natural keys, so that
    every rule a route follows (naturalKeys() in Anchor's SQL/Helpers.js) is reached, and every way a route can break
    one. base has keys on attributes of their own anchor and a route of the nexus through its roles; these add

      EV 2nd   the knot of a nexus role (event type), and an attribute (date) on a branch of its own
      EV 3rd   a tie, entered by "of" and left by "content", which is functional from EV (its only identifier),
               and an attribute of the program reached through it
      ST 3rd   a knotted attribute (minimum utilization, the value of its knot) and a historized one (name)
      ST 4th   into a nexus by its role (EV wasHeldAt), which is not functional, and the date of the event
      PN 1st   a person, which has no attributes and so no perspectives, by the name of the actor it is a subset of
      AC 2nd   a historized tie with no identifiers (partner, with), so one-to-one, to the name of the partner
      AC 3rd   two ties in a row (parent to child, then part in a program), neither functional, to the program's name
      PR 2nd   the knot of a tie role (the rating got for a part), through a tie that is not functional from PR

    and one route for each way a route breaks a rule, which is reported instead of generated:

      EV 4th   a tie with only the role it is entered by
      EV 5th   a stop on a knot, which the modeler allows and the XML schema does not
      ST 5th   two elements with the same stop
      AC 4th   an attribute of another anchor than the one the path has reached
      PR 3rd   a branch that ends in a tie role to an anchor, not in a value

    The bi and crt models differ from keys.xml only in metadata/@temporalization. Like the others, each model then
    has to be saved through the modeler.

    Usage:
      make-keys-models.ps1
      browser-check.ps1 -Canonicalize -Variant keys,keys-bi,keys-crt
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$models = Join-Path (Split-Path -Parent $PSScriptRoot) 'models'
$utf8 = New-Object Text.UTF8Encoding($false)
$xml = New-Object Xml.XmlDocument
$xml.PreserveWhitespace = $true
$xml.LoadXml([IO.File]::ReadAllText((Join-Path $models 'base.xml'), $utf8))
$schema = $xml.DocumentElement

function Find([string] $path) {
    $node = $schema.SelectSingleNode($path)
    if (-not $node) { throw "base.xml has no $path" }
    $node
}
# a role of the tie whose roles are exactly these, in order
function TieRole([string] $roles, [string] $role) {
    foreach ($tie in $schema.SelectNodes('tie')) {
        if ((@($tie.SelectNodes('role') | ForEach-Object { $_.GetAttribute('role') }) -join ',') -eq $roles) {
            return $tie.SelectSingleNode("role[@role='$role']")
        }
    }
    throw "base.xml has no tie with the roles $roles"
}
# a key element where the modeler writes it: after the metadata of an attribute or a knot, first in a role
function Key($element, [string] $of, [string] $route, [string] $stop, [string] $branch) {
    $key = $xml.CreateElement('key')
    $key.SetAttribute('stop', $stop)
    $key.SetAttribute('route', $route)
    $key.SetAttribute('of', $of)
    $key.SetAttribute('branch', $branch)
    $metadata = $element.SelectSingleNode('metadata')
    if ($metadata) { $element.InsertAfter($key, $metadata) | Out-Null } else { $element.PrependChild($key) | Out-Null }
}

Key (Find "nexus[@mnemonic='EV']/role[@role='of']") 'EV' '2nd' '1' '1'
Key (Find "nexus[@mnemonic='EV']/attribute[@mnemonic='DAT']") 'EV' '2nd' '2' '2'

Key (TieRole 'content,location,of' 'of') 'EV' '3rd' '1' '1'
Key (TieRole 'content,location,of' 'content') 'EV' '3rd' '2' '1'
Key (Find "anchor[@mnemonic='PR']/attribute[@mnemonic='NAM']") 'EV' '3rd' '3' '1'

Key (Find "anchor[@mnemonic='ST']/attribute[@mnemonic='MIN']") 'ST' '3rd' '1' '1'
Key (Find "anchor[@mnemonic='ST']/attribute[@mnemonic='NAM']") 'ST' '3rd' '2' '2'

Key (Find "nexus[@mnemonic='EV']/role[@role='wasHeldAt']") 'ST' '4th' '1' '1'
Key (Find "nexus[@mnemonic='EV']/attribute[@mnemonic='DAT']") 'ST' '4th' '2' '1'

Key (TieRole 'subset,of' 'of') 'PN' '1st' '1' '1'
Key (TieRole 'subset,of' 'subset') 'PN' '1st' '2' '1'
Key (Find "anchor[@mnemonic='AC']/attribute[@mnemonic='NAM']") 'PN' '1st' '3' '1'

Key (TieRole 'partner,with,currently' 'partner') 'AC' '2nd' '1' '1'
Key (TieRole 'partner,with,currently' 'with') 'AC' '2nd' '2' '1'
Key (Find "anchor[@mnemonic='AC']/attribute[@mnemonic='NAM']") 'AC' '2nd' '3' '1'

Key (TieRole 'parent,child,having' 'parent') 'AC' '3rd' '1' '1'
Key (TieRole 'parent,child,having' 'child') 'AC' '3rd' '2' '1'
Key (TieRole 'part,in,got' 'part') 'AC' '3rd' '3' '1'
Key (TieRole 'part,in,got' 'in') 'AC' '3rd' '4' '1'
Key (Find "anchor[@mnemonic='PR']/attribute[@mnemonic='NAM']") 'AC' '3rd' '5' '1'

Key (TieRole 'part,in,got' 'in') 'PR' '2nd' '1' '1'
Key (TieRole 'part,in,got' 'got') 'PR' '2nd' '2' '1'

# routes that break a rule
Key (TieRole 'in,wasCast' 'in') 'EV' '4th' '1' '1'
Key (Find "nexus[@mnemonic='EV']/attribute[@mnemonic='AUD']") 'EV' '4th' '2' '2'
Key (Find "knot[@mnemonic='ETY']") 'EV' '5th' '1' '1'
Key (Find "anchor[@mnemonic='ST']/attribute[@mnemonic='LOC']") 'ST' '5th' '1' '1'
Key (Find "anchor[@mnemonic='ST']/attribute[@mnemonic='NAM']") 'ST' '5th' '1' '2'
Key (Find "anchor[@mnemonic='ST']/attribute[@mnemonic='NAM']") 'AC' '4th' '1' '1'
Key (TieRole 'at,isPlaying' 'isPlaying') 'PR' '3rd' '1' '1'
Key (TieRole 'at,isPlaying' 'at') 'PR' '3rd' '2' '1'

$text = $xml.OuterXml
foreach ($t in 'uni', 'bi', 'crt') {
    $copy = $text
    if ($t -ne 'uni') {
        $count = ([regex]::Matches($copy, 'temporalization="uni"')).Count
        if ($count -ne 1) { throw "base.xml says temporalization=""uni"" $count times, not once" }
        $copy = $copy.Replace('temporalization="uni"', "temporalization=""$t""")
    }
    $name = $(if ($t -eq 'uni') { 'keys' } else { "keys-$t" })
    [IO.File]::WriteAllText((Join-Path $models "$name.xml"), $copy, $utf8)
    Write-Host "$name ($(@($xml.SelectNodes('//key')).Count) keys)"
}
