# Converts an XML file to the neutral tree JSON that modules/DomFacade.js (in Anchor) consumes.
# Whitespace-only text nodes are kept, as DOMParser keeps them, because the modeler's
# objectify records text content and the generated SQL can depend on it.

function ConvertTo-JsonString([string] $s) {
    $sb = New-Object Text.StringBuilder
    [void] $sb.Append('"')
    foreach ($ch in $s.ToCharArray()) {
        switch ($ch) {
            '"'  { [void] $sb.Append('\"') }
            '\'  { [void] $sb.Append('\') }
            "`n" { [void] $sb.Append('\n') }
            "`r" { [void] $sb.Append('\r') }
            "`t" { [void] $sb.Append('\t') }
            default {
                if ([int] $ch -lt 32) { [void] $sb.AppendFormat('\u{0:x4}', [int] $ch) } else { [void] $sb.Append($ch) }
            }
        }
    }
    [void] $sb.Append('"')
    $sb.ToString()
}

function ConvertTo-NeutralNode([Xml.XmlNode] $node, [Text.StringBuilder] $sb) {
    if ($node.NodeType -eq [Xml.XmlNodeType]::Text -or $node.NodeType -eq [Xml.XmlNodeType]::Whitespace -or $node.NodeType -eq [Xml.XmlNodeType]::SignificantWhitespace) {
        [void] $sb.Append('{"t":3,"v":' + (ConvertTo-JsonString $node.Value) + '}')
        return
    }
    [void] $sb.Append('{"t":1,"n":' + (ConvertTo-JsonString $node.Name) + ',"a":[')
    $first = $true
    foreach ($attr in $node.Attributes) {
        if (-not $first) { [void] $sb.Append(',') }
        $first = $false
        [void] $sb.Append('[' + (ConvertTo-JsonString $attr.Name) + ',' + (ConvertTo-JsonString $attr.Value) + ']')
    }
    [void] $sb.Append('],"c":[')
    $first = $true
    foreach ($child in $node.ChildNodes) {
        if ($child.NodeType -ne [Xml.XmlNodeType]::Element -and
            $child.NodeType -ne [Xml.XmlNodeType]::Text -and
            $child.NodeType -ne [Xml.XmlNodeType]::Whitespace -and
            $child.NodeType -ne [Xml.XmlNodeType]::SignificantWhitespace) { continue }
        if (-not $first) { [void] $sb.Append(',') }
        $first = $false
        ConvertTo-NeutralNode $child $sb
    }
    [void] $sb.Append(']}')
}

# -WithSerialization adds what the modeler adds when it generates SQL (Model.toXML(true)): a <serialization> element
# that holds the model's own XML as text, which the schema tracking of SQL Server reads. The text is the model as it
# is in the file, where the modeler would write it as it is at that moment, with the time stamp of the moment.
function Convert-XmlFileToTreeJson([string] $Path, [switch] $WithSerialization) {
    $doc = New-Object Xml.XmlDocument
    $doc.PreserveWhitespace = $true
    $doc.Load((Resolve-Path $Path).Path)
    if ($WithSerialization) {
        $element = $doc.CreateElement('serialization')
        [void] $element.AppendChild($doc.CreateTextNode($doc.DocumentElement.OuterXml))
        [void] $doc.DocumentElement.AppendChild($element)
    }
    $sb = New-Object Text.StringBuilder
    ConvertTo-NeutralNode $doc.DocumentElement $sb
    $sb.ToString()
}
