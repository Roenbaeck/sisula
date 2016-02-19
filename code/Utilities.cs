// In order to compile this code:
// C:\sisula\code>C:\WINDOWS\Microsoft.NET\Framework64\v3.5\csc.exe /optimize /debug- /target:library /out:Utilities.dll Utilities.cs
using System;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;
using Microsoft.SqlServer.Types;

/*
 * 2016-01-19 Added support for groups with quantifiers that capture multiple substrings
 * 2016-01-26 Added index of match as output (so we can sort the matches using it)
 */
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
		ICollection<Capture> captures = new Collection<Capture>();
		bool first = true;
		foreach (Group group in Regex.Match(row.ToString(), pattern.ToString(), RegexOptions.None).Groups) {
			if(first) {
				first = false;
			}
			else {
				foreach(Capture capture in group.Captures) {
					captures.Add(capture);
				}
			}
		}
        return captures;
    }
    public static void FillRow(Object fromEnumeration, [SqlFacet(MaxSize = -1)] out SqlString match, out SqlInt32 index) {
        Capture capture = (Capture) fromEnumeration;
        if(capture.Value == String.Empty) {
            match = SqlString.Null;
            index = -1;
        }
        else {
            match = new SqlString(capture.Value);
            index = new SqlInt32(capture.Index);
        }
    }
}

/*
 * 2015-12-08 Added by Lars Rönnbäck
 * 2015-12-09 Bug fixes
 */
public partial class ColumnSplitter
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void InitMethod(SqlString table, SqlString column, SqlString pattern, SqlString includeColumns)
    {
        string[] extraColumns;
        if(includeColumns.IsNull)
        {
            // if the includeColumns parameter has been omitted
            extraColumns = new string[0];
        }
        else
        {
            // allow columns to be delimited in a few different ways
            string[] delimiters = new string[3] {" ", ",", ";"};
            extraColumns = includeColumns.ToString().Split(delimiters, StringSplitOptions.RemoveEmptyEntries);
        }

        // compile the regex, since it will be used on a lot of rows
        // this trades a slower instantiation for faster execution
        Regex split = new Regex(pattern.ToString(), RegexOptions.Singleline | RegexOptions.Compiled);
        // find the group names in the provided regex (or numbers for not named capturing groups)
        string[] groupNamesAndEntireMatch = split.GetGroupNames();
        // allocate storage for the actual group names (-1 for removing the entire match)
        string[] groupNames = new string[groupNamesAndEntireMatch.Length - 1];
        Array.Copy(groupNamesAndEntireMatch, 1, groupNames, 0, groupNames.Length);

        // open a connection in the same context as we are executing
        using (SqlConnection connection = new SqlConnection("context connection=true"))
        {
            connection.Open();
            // set up the query to fetch data
            string query =
                " SELECT " +
                    (extraColumns.Length == 0 ? "" : string.Join(",", extraColumns) + ",") +
                    column.ToString() +
                " FROM " +
                    table.ToString();

            SqlCommand command = new SqlCommand(query, connection);
            SqlDataReader reader = command.ExecuteReader(CommandBehavior.KeyInfo);

            // set up the columns expected to be returned
            SqlMetaData[] md = new SqlMetaData[extraColumns.Length + groupNames.Length];
            SqlDbType providerType;
            int columnSize;
            byte numericPrecision, numericScale;
            int i;
            // first add the extra columns
            for (i = 0; i < extraColumns.Length; i++)
            {
                extraColumns[i] = extraColumns[i].Replace("[", "").Replace("]", "");
                providerType = (SqlDbType)(int)reader.GetSchemaTable().Rows[i]["ProviderType"];
                switch(providerType) {
                    case SqlDbType.Bit:
                    case SqlDbType.BigInt:
                    case SqlDbType.DateTime:
                    case SqlDbType.Float:
                    case SqlDbType.Int:
                    case SqlDbType.Money:
                    case SqlDbType.SmallDateTime:
                    case SqlDbType.SmallInt:
                    case SqlDbType.SmallMoney:
                    case SqlDbType.Timestamp:
                    case SqlDbType.TinyInt:
                    case SqlDbType.UniqueIdentifier:
                    case SqlDbType.Xml:
                        md[i] = new SqlMetaData(extraColumns[i], providerType);
                        break;
                    case SqlDbType.Binary:
                    case SqlDbType.Char:
                    case SqlDbType.Image:
                    case SqlDbType.NChar:
                    case SqlDbType.NText:
                    case SqlDbType.NVarChar:
                    case SqlDbType.Text:
                    case SqlDbType.VarBinary:
                    case SqlDbType.VarChar:
                        columnSize = (int)reader.GetSchemaTable().Rows[i]["ColumnSize"];
                        columnSize = columnSize == 2147483647 ? -1 : columnSize;
                        md[i] = new SqlMetaData(extraColumns[i], providerType, columnSize);
                        break;
                    case SqlDbType.Decimal:
                        numericPrecision = (byte)reader.GetSchemaTable().Rows[i]["NumericPrecision"];
                        numericScale     = (byte)reader.GetSchemaTable().Rows[i]["NumericScale"];
                        md[i] = new SqlMetaData(extraColumns[i], providerType, numericPrecision, numericScale);
                        break;
                    default:
                        md[i] = new SqlMetaData(extraColumns[i], providerType);
                        break;
                }
            }
            // then the expected columms created by the split operation
            for (i = 0; i < groupNames.Length; i++)
            {
                md[i + extraColumns.Length] = new SqlMetaData(groupNames[i], SqlDbType.NVarChar, -1);
            }
            SqlDataRecord writer = new SqlDataRecord(md);

            SqlString columnValue;   // holds a value from the column to be matched against
            GroupCollection groups;  // holds the results of the match
            using (reader)
            {
                SqlContext.Pipe.SendResultsStart(writer);
                // iterate through the result set
                while (reader.Read())
                {
                    for (i = 0; i < extraColumns.Length; i++)
                    {
                        // pass through the extra columns
                        writer.SetValue(i, reader.GetValue(i));
                    }
                    // read column to matched against
                    columnValue = reader.GetSqlString(extraColumns.Length);
                    // split column according to pattern
                    groups = split.Match(columnValue.ToString()).Groups;
                    for (i = 0; i < groupNames.Length; i++)
                    {
                        // write content of capturing group
                        if(groups[groupNames[i]].Value == String.Empty)
                            // an empty string is no match, and should be a null value
                            writer.SetSqlString(i + extraColumns.Length, SqlString.Null);
                        else
                            // if the string is non-empty, write the actual value
                            writer.SetSqlString(i + extraColumns.Length, groups[groupNames[i]].Value);
                    }
                    // send the row to the result set
                    SqlContext.Pipe.SendResultsRow(writer);
                }
                SqlContext.Pipe.SendResultsEnd();
            }
        }
    }
};

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
            switch (typeText.ToLower()) {
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

/*
    
*/
public partial class ToLocalTime {
    [
        Microsoft.SqlServer.Server.SqlFunction (
            SystemDataAccess  = SystemDataAccessKind.None,
            DataAccess        = DataAccessKind.None,
            IsDeterministic   = true,
            IsPrecise         = true
        )
    ]
    public static SqlDateTime InitMethod(SqlDateTime sqlDatetime) {
        try {
            return TimeZone.CurrentTimeZone.ToLocalTime(sqlDatetime.Value);
        }
        catch {
            return SqlDateTime.Null;
        }
    }
}
