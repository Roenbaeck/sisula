// Name the file XLS2TAB.js so that Windows Scripting Host recognizes it
var adOpenStatic = 3;
var adLockOptimistic = 3;
var adCmdText = 1;

//var provider = 'Microsoft.Jet.OLEDB.4.0'; // XLS
var provider = 'Microsoft.ACE.OLEDB.12.0'; // XLS & XLSX

var XLSFile = WScript.Arguments.Item(0);

var objConnection = new ActiveXObject("ADODB.Connection");
var objRecordSet = new ActiveXObject("ADODB.Recordset");

objConnection.Open('Provider=' + provider + ';Data Source="' + XLSFile + '";Extended Properties="Excel 8.0;HDR=No;IMEX=1";');
objRecordSet.Open("Select * FROM [Data$]", objConnection, adOpenStatic, adLockOptimistic, adCmdText);

WScript.Echo("Converting " + objRecordSet.RecordCount + " records...");

var converted = objRecordSet.GetString(2, objRecordSet.RecordCount, "\t", "\r\n", "");
var writer = new ActiveXObject("Scripting.FileSystemObject");
var outputFilename = writer.GetParentFolderName(XLSFile) + '\\' + writer.GetBaseName(XLSFile) + '.txt';

WScript.Echo("Writing result to: ");
WScript.Echo(outputFilename);

var outputFile = writer.CreateTextFile(outputFilename, true);
outputFile.Write(converted);
outputFile.Close();
