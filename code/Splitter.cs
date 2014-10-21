// In order to compile this code:
// C:\sisula\code>C:\WINDOWS\Microsoft.NET\Framework64\v3.5\csc.exe /optimize /debug- /target:library /out:Splitter.dll Splitter.cs
using System;
using System.Data.Sql;
using Microsoft.SqlServer.Server;
using System.Collections;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;

public partial class Splitter {
    [
        Microsoft.SqlServer.Server.SqlFunction (
            SystemDataAccess  = SystemDataAccessKind.None,
            DataAccess        = DataAccessKind.None,
            IsDeterministic   = true,
            IsPrecise         = true,
            FillRowMethodName = "FillRow"
        )
    ]
    // GroupCollection
    public static IEnumerable InitMethod([SqlFacet(MaxSize = -1)] SqlString row, SqlString pattern) {
        return Regex.Match(row.ToString(), pattern.ToString(), RegexOptions.None).Groups;
    }
    public static void FillRow(Object fromEnumeration, [SqlFacet(MaxSize = -1)] out SqlString match) {
        Group group = (Group) fromEnumeration;
        if(group.Value == String.Empty) 
            match = SqlString.Null;
        else
            match = new SqlString(group.Value);
    }
}
