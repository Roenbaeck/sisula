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
        _id int identity(1,1) not null,
        _file int not null default 0,
        _timestamp datetime2(2) not null default sysdatetime(),
        [row] nvarchar(max),
        constraint [pkSMHI_Weather_Raw] primary key(
            _id asc
        )
    );
END
GO
IF Object_ID('SMHI_Weather_CreateInsertView', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateInsertView];
GO
CREATE PROCEDURE [SMHI_Weather_CreateInsertView] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Insert', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Insert];
    EXEC('
    CREATE VIEW [SMHI_Weather_Insert]
    AS
    SELECT
        [row]
    FROM
        [SMHI_Weather_Raw];
    ');
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
    IF Object_ID('SMHI_Weather_Insert', 'V') IS NOT NULL
    BEGIN
	EXEC('
		BULK INSERT [SMHI_Weather_Insert]
		FROM ''' + @filename + '''
        WITH (
            CODEPAGE = ''ACP'',
            DATAFILETYPE = ''char'',
            FIELDTERMINATOR = ''\r\n'',
            TABLOCK 
        );
	');
    DECLARE @file int = 1 + (
        SELECT TOP 1
            _file
        FROM
            [SMHI_Weather_Raw]
        ORDER BY
            _file
        DESC
    );
    UPDATE [SMHI_Weather_Raw]
    SET
        _file = @file
    WHERE
        _file = 0;
    END 
END
GO
IF Object_ID('SMHI_Weather_CreateSplitViews', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateSplitViews];
GO
CREATE PROCEDURE [SMHI_Weather_CreateSplitViews] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_TemperatureNew_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_TemperatureNew_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_TemperatureNew_Split] 
    AS
    SELECT
        _id,
        _file,
        c1.[date] as [date_Raw],
        t.[date], 
        CASE
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        c2.[hour] as [hour_Raw],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        c3.[celsius1] as [celsius1_Raw],
        t.[celsius1], 
        CASE
            WHEN t.[celsius1] is not null AND TRY_CAST(t.[celsius1] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius1_Error],
        c4.[celsius2] as [celsius2_Raw],
        t.[celsius2], 
        CASE
            WHEN t.[celsius2] is not null AND TRY_CAST(t.[celsius2] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius2_Error],
        c5.[celsius3] as [celsius3_Raw],
        t.[celsius3], 
        CASE
            WHEN t.[celsius3] is not null AND TRY_CAST(t.[celsius3] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius3_Error],
        c6.[celsius4] as [celsius4_Raw],
        t.[celsius4], 
        CASE
            WHEN t.[celsius4] is not null AND TRY_CAST(t.[celsius4] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius4_Error]
    FROM (
        SELECT * from SMHI_Weather_Raw WHERE [row] LIKE ''[0-9][0-9][0-9][0-9][0-9][0-9],%''
    ) src
    CROSS APPLY (SELECT 0) d0 (p)
    CROSS APPLY (SELECT NULLIF(CHARINDEX('','', [row], d0.p + 1), 0)) d1 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d0.p + 1, d1.p - d0.p - 1)), '''')) c1 ([date])
    CROSS APPLY (SELECT NULLIF(CHARINDEX('','', [row], d1.p + 1), 0)) d2 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d1.p + 1, d2.p - d1.p - 1)), '''')) c2 ([hour])
    CROSS APPLY (SELECT NULLIF(CHARINDEX('','', [row], d2.p + 1), 0)) d3 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d2.p + 1, d3.p - d2.p - 1)), '''')) c3 ([celsius1])
    CROSS APPLY (SELECT NULLIF(CHARINDEX('','', [row], d3.p + 1), 0)) d4 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d3.p + 1, d4.p - d3.p - 1)), '''')) c4 ([celsius2])
    CROSS APPLY (SELECT NULLIF(CHARINDEX('','', [row], d4.p + 1), 0)) d5 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d4.p + 1, d5.p - d4.p - 1)), '''')) c5 ([celsius3])
    CROSS APPLY (SELECT NULLIF(CHARINDEX('','', [row], d5.p + 1), 0)) d6 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d5.p + 1, d6.p - d5.p - 1)), '''')) c6 ([celsius4])
    CROSS APPLY (
        SELECT 
            ''20'' + [date] AS [date], 
            LEFT([hour], 2) AS [hour], 
            [celsius1] AS [celsius1], 
            [celsius2] AS [celsius2], 
            [celsius3] AS [celsius3], 
            [celsius4] AS [celsius4]
    ) t;
    ');
    IF Object_ID('SMHI_Weather_Temperature_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Temperature_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_Temperature_Split] 
    AS
    SELECT
        _id,
        _file,
        c1.[date] as [date_Raw],
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        c2.[hour] as [hour_Raw],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        c3.[celsius] as [celsius_Raw],
        t.[celsius], 
        CASE
            WHEN t.[celsius] is not null AND TRY_CAST(t.[celsius] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius_Error],
        ROW_NUMBER() OVER (
            PARTITION BY
                t.[date],
                t.[hour]
            ORDER BY
                _id
        ) - 1 as measureTime_Duplicate
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''TEMP%''
    ) src
    CROSS APPLY (SELECT 4) d0 (p)
    CROSS APPLY (SELECT d0.p + 6) d1 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d0.p + 1, 6)), '''')) c1 ([date])
    CROSS APPLY (SELECT d1.p + 4) d2 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d1.p + 1, 4)), '''')) c2 ([hour])
    CROSS APPLY (SELECT NULLIF(CHARINDEX('' '', [row], d2.p + 1), 0)) d3 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d2.p + 1, d3.p - d2.p - 1)), '''')) c3 ([celsius])
    CROSS APPLY (
        SELECT 
            CASE LEFT([date],1) WHEN ''0'' THEN ''20'' + [date] ELSE ''19'' + [date] END AS [date], 
            LEFT([hour], 2) AS [hour], 
            REPLACE([celsius], '','', ''.'') AS [celsius]
    ) t;
    ');
    IF Object_ID('SMHI_Weather_Pressure_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Pressure_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_Pressure_Split] 
    AS
    SELECT
        _id,
        _file,
        c1.[date] as [date_Raw],
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        c2.[hour] as [hour_Raw],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        c3.[pressure] as [pressure_Raw],
        t.[pressure], 
        CASE
            WHEN t.[pressure] is not null AND TRY_CAST(t.[pressure] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [pressure_Error],
        ROW_NUMBER() OVER (
            PARTITION BY
                t.[date],
                t.[hour]
            ORDER BY
                _id
        ) - 1 as measureTime_Duplicate
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''PRSR%''
    ) src
    CROSS APPLY (SELECT 4) d0 (p)
    CROSS APPLY (SELECT d0.p + 6) d1 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d0.p + 1, 6)), '''')) c1 ([date])
    CROSS APPLY (SELECT d1.p + 4) d2 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d1.p + 1, 4)), '''')) c2 ([hour])
    CROSS APPLY (SELECT d2.p + 10) d3 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d2.p + 1, 10)), '''')) c3 ([pressure])
    CROSS APPLY (
        SELECT 
            CASE LEFT([date],1) WHEN ''0'' THEN ''20'' + [date] ELSE ''19'' + [date] END AS [date], 
            LEFT([hour], 2) AS [hour], 
            REPLACE([pressure], '','', ''.'') AS [pressure]
    ) t;
    ');
    IF Object_ID('SMHI_Weather_Wind_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Wind_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_Wind_Split] 
    AS
    SELECT
        _id,
        _file,
        c1.[date] as [date_Raw],
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        c2.[hour] as [hour_Raw],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        c3.[direction] as [direction_Raw],
        t.[direction], 
        CASE
            WHEN t.[direction] is not null AND TRY_CAST(t.[direction] AS decimal(5,2)) is null THEN ''Conversion to decimal(5,2) failed''
        END AS [direction_Error],
        c4.[speed] as [speed_Raw],
        t.[speed], 
        CASE
            WHEN t.[speed] is not null AND TRY_CAST(t.[speed] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [speed_Error],
        ROW_NUMBER() OVER (
            PARTITION BY
                t.[date],
                t.[hour]
            ORDER BY
                _id
        ) - 1 as measureTime_Duplicate
    FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''WNDS%''
    ) src
    CROSS APPLY (SELECT 4) d0 (p)
    CROSS APPLY (SELECT d0.p + 6) d1 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d0.p + 1, 6)), '''')) c1 ([date])
    CROSS APPLY (SELECT d1.p + 4) d2 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d1.p + 1, 4)), '''')) c2 ([hour])
    CROSS APPLY (SELECT d2.p + 10) d3 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d2.p + 1, 10)), '''')) c3 ([direction])
    CROSS APPLY (SELECT d3.p + 10) d4 (p)
    CROSS APPLY (SELECT NULLIF(LTRIM(SUBSTRING([row], d3.p + 1, 10)), '''')) c4 ([speed])
    CROSS APPLY (
        SELECT 
            CASE LEFT([date],1) WHEN ''0'' THEN ''20'' + [date] ELSE ''19'' + [date] END AS [date], 
            LEFT([hour], 2) AS [hour], 
            REPLACE([direction], '','', ''.'') AS [direction], 
            REPLACE([speed], '','', ''.'') AS [speed]
    ) t;
    ');
END
GO
IF Object_ID('SMHI_Weather_CreateErrorViews', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateErrorViews];
GO
CREATE PROCEDURE [SMHI_Weather_CreateErrorViews] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_TemperatureNew_Error', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_TemperatureNew_Error];
    EXEC('
    CREATE VIEW [SMHI_Weather_TemperatureNew_Error] 
    AS
    SELECT
        *
    FROM
        [SMHI_Weather_TemperatureNew_Split]
    WHERE
        [date_Error] is not null
    OR
        [hour_Error] is not null
    OR
        [celsius1_Error] is not null
    OR
        [celsius2_Error] is not null
    OR
        [celsius3_Error] is not null
    OR
        [celsius4_Error] is not null;
    ');
    IF Object_ID('SMHI_Weather_Temperature_Error', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Temperature_Error];
    EXEC('
    CREATE VIEW [SMHI_Weather_Temperature_Error] 
    AS
    SELECT
        *
    FROM
        [SMHI_Weather_Temperature_Split]
    WHERE
        measureTime_Duplicate > 0
    OR
        [date_Error] is not null
    OR
        [hour_Error] is not null
    OR
        [celsius_Error] is not null;
    ');
    IF Object_ID('SMHI_Weather_Pressure_Error', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Pressure_Error];
    EXEC('
    CREATE VIEW [SMHI_Weather_Pressure_Error] 
    AS
    SELECT
        *
    FROM
        [SMHI_Weather_Pressure_Split]
    WHERE
        measureTime_Duplicate > 0
    OR
        [date_Error] is not null
    OR
        [hour_Error] is not null
    OR
        [pressure_Error] is not null;
    ');
    IF Object_ID('SMHI_Weather_Wind_Error', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_Wind_Error];
    EXEC('
    CREATE VIEW [SMHI_Weather_Wind_Error] 
    AS
    SELECT
        *
    FROM
        [SMHI_Weather_Wind_Split]
    WHERE
        measureTime_Duplicate > 0
    OR
        [date_Error] is not null
    OR
        [hour_Error] is not null
    OR
        [direction_Error] is not null
    OR
        [speed_Error] is not null;
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
    IF Object_ID('SMHI_Weather_TemperatureNew_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_TemperatureNew_Typed];
    CREATE TABLE [SMHI_Weather_TemperatureNew_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
        [date] date null, 
        [hour] char(2) null, 
        [celsius1] decimal(19,10) null, 
        [celsius2] decimal(19,10) null, 
        [celsius3] decimal(19,10) null, 
        [celsius4] decimal(19,10) null
    );
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Temperature_Typed];
    CREATE TABLE [SMHI_Weather_Temperature_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
        [date] date not null, 
        [hour] char(2) not null, 
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
    CREATE TABLE [SMHI_Weather_Pressure_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
        [date] date not null, 
        [hour] char(2) not null, 
        [pressure] decimal(19,10) null
    );
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_Wind_Typed];
    CREATE TABLE [SMHI_Weather_Wind_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
        [date] date not null, 
        [hour] char(2) not null, 
        [direction] decimal(5,2) null, 
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
    IF Object_ID('SMHI_Weather_TemperatureNew_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_TemperatureNew_Typed] (
        _id,
        _file,
        [date], 
        [hour], 
        [celsius1], 
        [celsius2], 
        [celsius3], 
        [celsius4]
    )
    SELECT
        _id,
        _file,
        [date], 
        [hour], 
        [celsius1], 
        [celsius2], 
        [celsius3], 
        [celsius4]
    FROM 
        [SMHI_Weather_TemperatureNew_Split]
    WHERE
        [date_Error] is null
    AND
        [hour_Error] is null
    AND
        [celsius1_Error] is null
    AND
        [celsius2_Error] is null
    AND
        [celsius3_Error] is null
    AND
        [celsius4_Error] is null;
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Temperature_Typed] (
        _id,
        _file,
        [date], 
        [hour], 
        [celsius]
    )
    SELECT
        _id,
        _file,
        [date], 
        [hour], 
        [celsius]
    FROM 
        [SMHI_Weather_Temperature_Split]
    WHERE
        measureTime_Duplicate = 0
    AND
        [date_Error] is null
    AND
        [hour_Error] is null
    AND
        [celsius_Error] is null;
    IF Object_ID('SMHI_Weather_Pressure_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Pressure_Typed] (
        _id,
        _file,
        [date], 
        [hour], 
        [pressure]
    )
    SELECT
        _id,
        _file,
        [date], 
        [hour], 
        [pressure]
    FROM 
        [SMHI_Weather_Pressure_Split]
    WHERE
        measureTime_Duplicate = 0
    AND
        [date_Error] is null
    AND
        [hour_Error] is null
    AND
        [pressure_Error] is null;
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_Wind_Typed] (
        _id,
        _file,
        [date], 
        [hour], 
        [direction], 
        [speed]
    )
    SELECT
        _id,
        _file,
        [date], 
        [hour], 
        [direction], 
        [speed]
    FROM 
        [SMHI_Weather_Wind_Split]
    WHERE
        measureTime_Duplicate = 0
    AND
        [date_Error] is null
    AND
        [hour_Error] is null
    AND
        [direction_Error] is null
    AND
        [speed_Error] is null;
END
GO
IF Object_ID('SMHI_Weather_AddKeysToTyped', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_AddKeysToTyped];
GO
CREATE PROCEDURE [SMHI_Weather_AddKeysToTyped] 
AS
BEGIN
    SET NOCOUNT ON;
    IF Object_ID('SMHI_Weather_Temperature_Typed', 'U') IS NOT NULL
    ALTER TABLE [SMHI_Weather_Temperature_Typed]
    ADD
        CONSTRAINT [measureTime_SMHI_Weather_Temperature_Typed] primary key (
            [date],
            [hour]
        );
    IF Object_ID('SMHI_Weather_Pressure_Typed', 'U') IS NOT NULL
    ALTER TABLE [SMHI_Weather_Pressure_Typed]
    ADD
        CONSTRAINT [measureTime_SMHI_Weather_Pressure_Typed] primary key (
            [date],
            [hour]
        );
    IF Object_ID('SMHI_Weather_Wind_Typed', 'U') IS NOT NULL
    ALTER TABLE [SMHI_Weather_Wind_Typed]
    ADD
        CONSTRAINT [measureTime_SMHI_Weather_Wind_Typed] primary key (
            [date],
            [hour]
        );
END
GO
