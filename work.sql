USE Stage;
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
        m.[date] as [date_Match],
        t.[date], 
        CASE
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        m.[hour] as [hour_Match],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        m.[celsius1] as [celsius1_Match],
        t.[celsius1], 
        CASE
            WHEN t.[celsius1] is not null AND TRY_CAST(t.[celsius1] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius1_Error],
        m.[celsius2] as [celsius2_Match],
        t.[celsius2], 
        CASE
            WHEN t.[celsius2] is not null AND TRY_CAST(t.[celsius2] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius2_Error],
        m.[celsius3] as [celsius3_Match],
        t.[celsius3], 
        CASE
            WHEN t.[celsius3] is not null AND TRY_CAST(t.[celsius3] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius3_Error],
        m.[celsius4] as [celsius4_Match],
        t.[celsius4], 
        CASE
            WHEN t.[celsius4] is not null AND TRY_CAST(t.[celsius4] AS decimal(19,10)) is null THEN ''Conversion to decimal(19,10) failed''
        END AS [celsius4_Error]
    FROM (
        SELECT TOP(2147483647) 
            * 
        FROM (
        SELECT * from SMHI_Weather_Raw WHERE [row] LIKE ''[0-9][0-9][0-9][0-9][0-9][0-9],%''
        ) src
        ORDER BY 
            _id ASC 
    ) forcedMaterializationTrick
    CROSS APPLY (
		SELECT
			NULLIF(LTRIM([2]), '''') AS [date],
			NULLIF(LTRIM([3]), '''') AS [hour],
			NULLIF(LTRIM([4]), '''') AS [celsius1],
			NULLIF(LTRIM([5]), '''') AS [celsius2],
			NULLIF(LTRIM([6]), '''') AS [celsius3],
			NULLIF(LTRIM([7]), '''') AS [celsius4]
		FROM (
            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(forcedMaterializationTrick.[row], N''(.*?),\s*([0-9]{2})[0-9]{2},(.*?),(.*?),(.*?),(.*?),'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ([2], [3], [4], [5], [6], [7])
        ) p
    ) m
    CROSS APPLY (
        SELECT 
            ''20'' + [date] AS [date], 
            [hour] AS [hour], 
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
        m.[date] as [date_Match],
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        m.[hour] as [hour_Match],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        m.[celsius] as [celsius_Match],
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
        SELECT TOP(2147483647) 
            * 
        FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''TEMP%''
        ) src
        ORDER BY 
            _id ASC 
    ) forcedMaterializationTrick
    CROSS APPLY (
		SELECT
			NULLIF(LTRIM([2]), '''') AS [date],
			NULLIF(LTRIM([3]), '''') AS [hour],
			NULLIF(LTRIM([4]), '''') AS [celsius]
		FROM (
            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(forcedMaterializationTrick.[row], N''.{4}(.{6})(.{4})(.*?) '')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ([2], [3], [4])
        ) p
    ) m
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
        m.[date] as [date_Match],
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        m.[hour] as [hour_Match],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        m.[pressure] as [pressure_Match],
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
        SELECT TOP(2147483647) 
            * 
        FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''PRSR%''
        ) src
        ORDER BY 
            _id ASC 
    ) forcedMaterializationTrick
    CROSS APPLY (
		SELECT
			NULLIF(LTRIM([2]), '''') AS [date],
			NULLIF(LTRIM([3]), '''') AS [hour],
			NULLIF(LTRIM([4]), '''') AS [pressure]
		FROM (
            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(forcedMaterializationTrick.[row], N''.{4}(.{6})(.{4})(.{10})'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ([2], [3], [4])
        ) p
    ) m
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
        m.[date] as [date_Match],
        t.[date], 
        CASE
            WHEN t.[date] is null THEN ''Null value not allowed''
            WHEN t.[date] is not null AND TRY_CAST(t.[date] AS date) is null THEN ''Conversion to date failed''
        END AS [date_Error],
        m.[hour] as [hour_Match],
        t.[hour], 
        CASE
            WHEN t.[hour] is not null AND TRY_CAST(t.[hour] AS char(2)) is null THEN ''Conversion to char(2) failed''
        END AS [hour_Error],
        m.[direction] as [direction_Match],
        t.[direction], 
        CASE
            WHEN t.[direction] is not null AND TRY_CAST(t.[direction] AS decimal(5,2)) is null THEN ''Conversion to decimal(5,2) failed''
        END AS [direction_Error],
        m.[speed] as [speed_Match],
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
        SELECT TOP(2147483647) 
            * 
        FROM (
        SELECT * FROM SMHI_Weather_Raw WHERE [row] LIKE ''WNDS%''
        ) src
        ORDER BY 
            _id ASC 
    ) forcedMaterializationTrick
    CROSS APPLY (
		SELECT
			NULLIF(LTRIM([2]), '''') AS [date],
			NULLIF(LTRIM([3]), '''') AS [hour],
			NULLIF(LTRIM([4]), '''') AS [direction],
			NULLIF(LTRIM([5]), '''') AS [speed]
		FROM (
            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(forcedMaterializationTrick.[row], N''.{4}(.{6})(.{4})(.{10})(.{10})'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ([2], [3], [4], [5])
        ) p
    ) m
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
