' In order to compile this code:
' C:\sisula\code>C:\WINDOWS\Microsoft.NET\Framework64\v3.5\vbc.exe /optimize /debug- /target:library /out:Splitter.dll Splitter.vb
Imports System
Imports System.Data.Sql
Imports Microsoft.SqlServer.Server
Imports System.Collections
Imports System.Data.SqlTypes
Imports System.Text.RegularExpressions

Public Class Splitter
    <SqlFunction(FillRowMethodName:="FillRow", IsDeterministic:=True, IsPrecise:=True)> _
    Public Shared Function InitMethod(ByVal row As String, ByVal pattern As String) As IEnumerable
        Dim groups As GroupCollection = Regex.Match(row, pattern, RegexOptions.IgnorePatternWhitespace).Groups
        Return groups
    End Function

    Public Shared Sub FillRow(ByVal obj As Object, ByRef match As SqlChars)
        Dim group As Group = CType(obj, Group)
        match = New SqlChars(group.Value)
    End Sub
End Class
