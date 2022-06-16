// Name the file XLS2TAB.js so that Windows Scripting Host recognizes it

// These have to be set manually, and they are options to various functions within the 
// Excel ADBODB provider. 
// Found online: 
// https://docs.microsoft.com/en-us/office/client-developer/access/desktop-database-reference/schemaenum 
var adOpenStatic = 3;
var adLockOptimistic = 3;
var adCmdText = 1;
var adSchemaTables = 20;

//var provider = 'Microsoft.Jet.OLEDB.4.0'; // XLS
//var provider = 'Microsoft.ACE.OLEDB.12.0'; // XLS & XLSX - from Redistributable 2010
var provider = 'Microsoft.ACE.OLEDB.16.0'; // XLS & XLSX - from Redistributable 2016

var XLSFile = WScript.Arguments.Item(0);

var objConnection = new ActiveXObject("ADODB.Connection");
var objRecordSet = new ActiveXObject("ADODB.Recordset");

// objConnection.Open('Provider=' + provider + ';Data Source="' + XLSFile + '";Extended Properties="Excel 8.0;HDR=No;IMEX=1";');
// Updating to Excel 12.0 here:
objConnection.Open('Provider=' + provider + ';Data Source="' + XLSFile + '";Extended Properties="Excel 12.0;HDR=No;IMEX=1";');

var objSchemas = objConnection.OpenSchema(adSchemaTables);
while(!objSchemas.EOF) {
    var worksheet = new String(objSchemas.Fields("table_name"));
    objRecordSet.Open("SELECT * FROM [" + worksheet + "]", objConnection, adOpenStatic, adLockOptimistic, adCmdText);
    WScript.Echo("Converting worksheet: " + worksheet + " with " + objRecordSet.RecordCount + " records...");
    var converted = objRecordSet.GetString(2, objRecordSet.RecordCount, "\t", "\r\n", "");
    var writer = new ActiveXObject("Scripting.FileSystemObject");
    var filename = writer.GetBaseName(XLSFile) + '_' + worksheet.replace('$', '') + '.txt';
    var outputFilename = writer.GetParentFolderName(XLSFile) + '\\' + filename;
    WScript.Echo("Writing result to: ");
    WScript.Echo(outputFilename);
    var outputFile = writer.CreateTextFile(outputFilename, true);
    outputFile.Write(converted);
    outputFile.Close();   
    objRecordSet.Close();         
    objSchemas.MoveNext();
}
objSchemas.Close();

