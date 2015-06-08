var adTypeBinary = 1;
var adSaveCreateOverWrite = 2;
var adSaveCreateNotExist = 1;

try 
{
    var args = WScript.Arguments;

    if(args.length < 3)
    {
        WScript.Echo("Usage: transform.js input.xml transform.xsl output.xml");
        WScript.Quit(1);
    }
    else
    {
        var xml = args(0);
        var xsl = args(1);
        var out = args(2);

        var xmlDoc = new ActiveXObject("Msxml2.DOMDocument.6.0");
        var xslDoc = new ActiveXObject("Msxml2.DOMDocument.6.0");

        /* Create a binary IStream */
        var outDoc = new ActiveXObject("ADODB.Stream");
        outDoc.type = adTypeBinary;
        outDoc.open();

        if(xmlDoc.load(xml) == false)
        {
            throw new Error("Could not load XML document " + xmlDoc.parseError.reason);
        }

        if(xslDoc.load(xsl) == false)
        {
            throw new Error("Could not load XSL document " + xslDoc.parseError.reason);         
        }

        xmlDoc.transformNodeToObject(xslDoc, outDoc);
        outDoc.SaveToFile(out, adSaveCreateOverWrite);
    }
}
catch(e)
{
    WScript.Echo(e.message);
    WScript.Quit(1);
}