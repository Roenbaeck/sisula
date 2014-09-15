USE Test;
GO
IF Object_ID('SMHI_Weather_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateRawTable];
GO
CREATE PROCEDURE [SMHI_Weather_CreateRawTable] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Raw', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Raw];
    CREATE TABLE [SMHI_Weather_Raw] (
        [row] nvarchar(max)
    );
END
GO
IF Object_ID('SMHI_Weather_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_BulkInsert];
GO
CREATE PROCEDURE [SMHI_Weather_BulkInsert] (
	@filename varchar(2000)
)
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Raw', 'U') IS NOT NULL
	EXEC('
		BULK INSERT [SMHI_Weather_Raw]
		FROM ''' + @filename + '''
        WITH (
            CODEPAGE = ''ACP'',
            DATAFILETYPE = ''char'',
            FIELDTERMINATOR = ''\r\n'',
            TABLOCK 
        );
	');
END
GO
IF Object_ID('SMHI_Weather_AddKeyToRawTable', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_AddKeyToRawTable];
GO
CREATE PROCEDURE [SMHI_Weather_AddKeyToRawTable] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Raw', 'U') IS NOT NULL
    ALTER TABLE [SMHI_Weather_Raw]
    ADD _id int identity(1,1) not null primary key;
END
GO
IF Object_ID('SMHI_Weather_CreateSplitView', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateSplitView];
GO
CREATE PROCEDURE [SMHI_Weather_CreateSplitView] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Temperature_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Temperature_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_Temperature_Split] 
    AS
    SELECT
        _id,
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        t.[celsius], 
        CASE
            WHEN t.[celsius] is not null AND TRY_CAST(t.[celsius] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius_Error]
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''TEMP%''
    ) src
    CROSS APPLY (SELECT SUBSTRING(src.[row], 5, 2147483647)) c0 ([row])
    CROSS APPLY (SELECT NULLIF(LEFT(c0.[row], 6), ''''), SUBSTRING(c0.[row], 7, 2147483647)) c1 ([date], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c1.[row], 4), ''''), SUBSTRING(c1.[row], 5, 2147483647)) c2 ([hour], [row])
    CROSS APPLY (SELECT NULLIF(CHARINDEX('' '', c2.[row]), 0)) d2 (p)
    CROSS APPLY (SELECT NULLIF(LEFT(c2.[row], d2.p - 1), ''''), SUBSTRING(c2.[row], d2.p + 1, 2147483647)) c3 ([celsius], [row])
    CROSS APPLY (
        SELECT 
            CASE LEFT([date],1) WHEN ''0'' THEN ''20'' + [date] ELSE ''19'' + [date] END AS [date], 
            LEFT([hour], 2) AS [hour], 
            [celsius] AS [celsius]
    ) t;
    ');
    IF Object_ID('SMHI_Weather_Pressure_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Pressure_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_Pressure_Split] 
    AS
    SELECT
        _id,
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        t.[pressure], 
        CASE
            WHEN t.[pressure] is not null AND TRY_CAST(t.[pressure] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [pressure_Error]
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''PRSR%''
    ) src
    CROSS APPLY (SELECT [row]) c0 ([row])
    CROSS APPLY (SELECT NULLIF(LEFT(c0.[row], 6), ''''), SUBSTRING(c0.[row], 7, 2147483647)) c1 ([date], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c1.[row], 4), ''''), SUBSTRING(c1.[row], 5, 2147483647)) c2 ([hour], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c2.[row], 10), ''''), SUBSTRING(c2.[row], 11, 2147483647)) c3 ([pressure], [row])
    CROSS APPLY (
        SELECT 
            CASE LEFT([date],1) WHEN ''0'' THEN ''20'' + [date] ELSE ''19'' + [date] END AS [date], 
            LEFT([hour], 2) AS [hour], 
            [pressure] AS [pressure]
    ) t;
    ');
    IF Object_ID('SMHI_Weather_Wind_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Wind_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_Wind_Split] 
    AS
    SELECT
        _id,
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        t.[direction], 
        CASE
            WHEN t.[direction] is not null AND TRY_CAST(t.[direction] AS int) is null THEN ''Conversion to int failed''
        END AS [direction_Error],
        t.[speed], 
        CASE
            WHEN t.[speed] is not null AND TRY_CAST(t.[speed] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [speed_Error]
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''WNDS%''
    ) src
    CROSS APPLY (SELECT [row]) c0 ([row])
    CROSS APPLY (SELECT NULLIF(LEFT(c0.[row], 6), ''''), SUBSTRING(c0.[row], 7, 2147483647)) c1 ([date], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c1.[row], 4), ''''), SUBSTRING(c1.[row], 5, 2147483647)) c2 ([hour], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c2.[row], 10), ''''), SUBSTRING(c2.[row], 11, 2147483647)) c3 ([direction], [row])
    CROSS APPLY (SELECT NULLIF(LEFT(c3.[row], 10), ''''), SUBSTRING(c3.[row], 11, 2147483647)) c4 ([speed], [row])
    CROSS APPLY (
        SELECT 
            CASE LEFT([date],1) WHEN ''0'' THEN ''20'' + [date] ELSE ''19'' + [date] END AS [date], 
            LEFT([hour], 2) AS [hour], 
            [direction] AS [direction], 
            [speed] AS [speed]
    ) t;
    ');
END
GO
IF Object_ID('SMHI_Weather_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateTypedTables];
GO
CREATE PROCEDURE [SMHI_Weather_CreateTypedTables] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Temperature_Typed];
    CREATE TABLE SMHI_Weather_Temperature_Typed (
        _id int not null,
        [date] date not null, 
        [hour] char(2) null, 
        [celsius] decimal(19,10) null, 
        [fahrenheit] as CAST(9 / 5 * [celsius] + 32 AS decimal(19,10)) PERSISTED, 
        [freezing] as CAST(CASE 
                WHEN [celsius] > 0 THEN 'A' 
                WHEN [celsius] < 0 THEN 'B' 
                WHEN [celsius] = 0 THEN 'Z' 
                ELSE '?' 
            END AS char(1)) PERSISTED
    );
    IF Object_ID('SMHI_Weather_Pressure_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Pressure_Typed];
    CREATE TABLE SMHI_Weather_Pressure_Typed (
        _id int not null,
        [date] date not null, 
        [hour] char(2) null, 
        [pressure] decimal(19,10) null
    );
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Wind_Typed];
    CREATE TABLE SMHI_Weather_Wind_Typed (
        _id int not null,
        [date] date not null, 
        [hour] char(2) null, 
        [direction] int null, 
        [speed] decimal(19,10) null
    );
END
GO
IF Object_ID('SMHI_Weather_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_SplitRawIntoTyped];
GO
CREATE PROCEDURE [SMHI_Weather_SplitRawIntoTyped] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Temperature_Typed] (
        _id,
        [date], 
        [hour], 
        [celsius]
    )
    SELECT
        _id,
        [date], 
        [hour], 
        [celsius]
    FROM 
        [SMHI_Weather_Temperature_Split]
    WHERE
        [date_Error] is null
    AND
        [hour_Error] is null
    AND
        [celsius_Error] is null;
    IF Object_ID('SMHI_Weather_Pressure_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Pressure_Typed] (
        _id,
        [date], 
        [hour], 
        [pressure]
    )
    SELECT
        _id,
        [date], 
        [hour], 
        [pressure]
    FROM 
        [SMHI_Weather_Pressure_Split]
    WHERE
        [date_Error] is null
    AND
        [hour_Error] is null
    AND
        [pressure_Error] is null;
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Wind_Typed] (
        _id,
        [date], 
        [hour], 
        [direction], 
        [speed]
    )
    SELECT
        _id,
        [date], 
        [hour], 
        [direction], 
        [speed]
    FROM 
        [SMHI_Weather_Wind_Split]
    WHERE
        [date_Error] is null
    AND
        [hour_Error] is null
    AND
        [direction_Error] is null
    AND
        [speed_Error] is null;
END
GO
