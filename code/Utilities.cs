// In order to compile this code:
// C:\sisula\code>C:\WINDOWS\Microsoft.NET\Framework64\v3.5\csc.exe /optimize /debug- /target:library /out:Utilities.dll Utilities.cs
using System;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Collections;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;
using Microsoft.SqlServer.Types;


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

public partial class IsType {
    [
        Microsoft.SqlServer.Server.SqlFunction (
            SystemDataAccess  = SystemDataAccessKind.None,
            DataAccess        = DataAccessKind.None,
            IsDeterministic   = true,
            IsPrecise         = true
        )
    ]
    public static SqlBoolean InitMethod([SqlFacet(MaxSize = -1)] SqlString sqlDataValue, SqlString sqlDataType) {
        String dataValue = sqlDataValue.ToString().Trim();
        String dataType = sqlDataType.ToString().Trim();
        GroupCollection typeGroups = splitType.Match(dataType).Groups;
        String typeText = typeGroups["type"].Value;
        String typePrecision = typeGroups["precision"].Value;
        String typeScale = typeGroups["scale"].Value;
        try {
            switch (typeText) {
                case "bit":
                    SqlBoolean.Parse(dataValue);
                    break;
                case "tinyint": 
                    SqlByte.Parse(dataValue);
                    break;
                case "smallint":
                    SqlInt16.Parse(dataValue);
                    break;
                case "int":
                    SqlInt32.Parse(dataValue);
                    break;
                case "bigint":
                    SqlInt64.Parse(dataValue);
                    break;
                case "smallmoney":
                    if(NumberOfDecimals(dataValue) > 4)
                        throw new OverflowException();
                    SqlMoney smallmoneyValue = SqlMoney.Parse(dataValue);
                    if(SqlMoney.LessThan(smallmoneyValue, smallmoneyMinValue) || SqlMoney.GreaterThan(smallmoneyValue, smallmoneyMaxValue))
                        throw new OverflowException();
                    break;
                case "money":
                    if(NumberOfDecimals(dataValue) > 4)
                        throw new OverflowException();
                    SqlMoney.Parse(dataValue);
                    break;
                case "decimal":
                case "numeric":
                    if(NumberOfDecimals(dataValue) > Convert.ToInt32(typeScale))
                        throw new OverflowException();
                    SqlDecimal.Parse(dataValue);
                    break;
                case "real":
                    SqlSingle singleValue = SqlSingle.Parse(dataValue);
                    if(singleValue.ToString().Length != dataValue.Length + (NumberOfWholes(dataValue) == 0 ? 1 : 0))
                        throw new OverflowException();
                    break;
                case "float":
                    SqlDouble doubleValue = SqlDouble.Parse(dataValue);
                    if(doubleValue.ToString().Length != dataValue.Length + (NumberOfWholes(dataValue) == 0 ? 1 : 0))
                        throw new OverflowException();
                    break;
                case "date":
                case "datetime":
                case "datetime2":
                    SqlDateTime.Parse(dataValue);
                    break;
                case "char":
                case "varchar":
                case "nchar":
                case "nvarchar":
                    if(typePrecision != "max" && dataValue.Length > Convert.ToInt32(typePrecision))
                        throw new OverflowException();
                    break;            
                case "uniqueidentifier":
                    SqlGuid.Parse(dataValue);
                    break;
                case "geometry":
                    SqlGeometry.Parse(dataValue);
                    break;
                case "geography":
                    SqlGeography.Parse(dataValue);
                    break;
                // we do not handle these at this time
                case "xml":
                case "time":
                case "datetimeoffset":
                case "hierarchyid":
                case "image":
                case "text":
                case "ntext":
                case "rowversion":
                case "sql_variant":
                case "table":
                case "timestamp":
                case "varbinary":
                default:
                    break;                
            }
            return SqlBoolean.True;
        }
        catch {
            return SqlBoolean.False;
        }
    }
    private static int NumberOfDecimals(String dataValue) {
        GroupCollection valueGroups = splitValue.Match(dataValue).Groups;
        return valueGroups["scale"].Length;
    }
    private static int NumberOfWholes(String dataValue) {
        GroupCollection valueGroups = splitValue.Match(dataValue).Groups;
        return valueGroups["whole"].Length;
    }
    private static readonly SqlMoney smallmoneyMinValue = new SqlMoney(-214748.3648);
    private static readonly SqlMoney smallmoneyMaxValue = new SqlMoney(214748.3647);
    private static readonly Regex splitValue = new Regex("(?<whole>[0-9]+)?(?:[^0-9](?<scale>[0-9]+))?", RegexOptions.Compiled);
    private static readonly Regex splitType = new Regex("(?<type>[^()]+)(?:\\s*\\((?<precision>[^,()]*),?(?<scale>[^)]*)\\))?", RegexOptions.Compiled);
}
