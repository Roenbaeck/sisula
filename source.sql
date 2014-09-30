USE Stage;
GO
IF Object_ID('SMHI_Weather_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateRawTable];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_CreateRawTable
--
-- This table holds the 'raw' loaded data.
--
-- row
-- Holds a row loaded from a file.
--
-- _id
-- This sequence is generated in order to keep a lineage through the 
-- staging process. If a single file has been loaded, this corresponds
-- to the row number in the file.
--
-- _file
-- A number containing the file id, which either points to metadata
-- if its used or is otherwise an incremented number per file.
--
-- _timestamp
-- The time the row was created.
-- 
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_CreateRawTable] 
AS
BEGIN
SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_CreateRawTable';
BEGIN TRY
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('SMHI_Weather_CreateInsertView', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateInsertView];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_CreateInsertView
--
-- This view is created as exposing the single column that will be 
-- the target of the BULK INSERT operation, since it cannot insert
-- into a table with multiple columns without a format file.
--
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_CreateInsertView] 
AS
BEGIN
SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_CreateInsertView';
BEGIN TRY
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('SMHI_Weather_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_BulkInsert];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_BulkInsert
--
-- This procedure performs a BULK INSERT of the given filename into 
-- the SMHI_Weather_Insert view. The file is loaded row by row
-- into a single column holding the entire row. This ensures that no 
-- data is lost when loading.
--
-- This job may called multiple times in a workflow when more than 
-- one file matching a given filename pattern is found.
--
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_BulkInsert] (
	@filename varchar(2000)
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_BulkInsert';
BEGIN TRY
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('SMHI_Weather_CreateSplitViews', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateSplitViews];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_CreateSplitViews
--
-- The split view uses a CLR called the Splitter to split rows in the
-- 'raw' table into columns. The Splitter uses a regular expression in
-- which groups indicate which parts should be cut out as columns.
--
-- The view also checks data types and provide the results as well as 
-- show the 'raw' cut column value, before any given transformations
-- have taken place.
-- 
-- If keys are defined, these keys are checked for duplicates and the 
-- duplicate number can be found through the view.
--
-- Create: SMHI_Weather_TemperatureNew_Split
-- Create: SMHI_Weather_TemperatureNewMetadata_Split
-- Create: SMHI_Weather_Temperature_Split
-- Create: SMHI_Weather_Pressure_Split
-- Create: SMHI_Weather_Wind_Split
--
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_CreateSplitViews] 
AS
BEGIN
SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_CreateSplitViews';
BEGIN TRY
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
    IF Object_ID('SMHI_Weather_TemperatureNewMetadata_Split', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_TemperatureNewMetadata_Split];
    EXEC('
    CREATE VIEW [SMHI_Weather_TemperatureNewMetadata_Split] 
    AS
    SELECT
        _id,
        _file,
        m.[graphType] as [graphType_Match],
        t.[graphType], 
        CASE
            WHEN t.[graphType] is not null AND TRY_CAST(t.[graphType] AS varchar(42)) is null THEN ''Conversion to varchar(42) failed''
        END AS [graphType_Error],
        m.[weekday] as [weekday_Match],
        t.[weekday], 
        CASE
            WHEN t.[weekday] is not null AND TRY_CAST(t.[weekday] AS varchar(42)) is null THEN ''Conversion to varchar(42) failed''
        END AS [weekday_Error]
    FROM (
        SELECT TOP(2147483647) 
            * 
        FROM (
        SELECT
			*
		FROM (
			SELECT 
				_file,
				MIN(_id) as _id,
				MIN(_timestamp) as _timestamp
			FROM (
                SELECT
                    *
                FROM
                    SMHI_Weather_Raw
                WHERE 
                    [row] LIKE ''#%''
		    ) src
			GROUP BY
				_file
		) f
		CROSS APPLY (
			SELECT
				[row] + CHAR(183) AS [text()]
			FROM (
                SELECT
                    *
                FROM
                    SMHI_Weather_Raw
                WHERE 
					[row] LIKE ''#%''
		    ) src
			WHERE
				src._file = f._file
			FOR XML PATH('''')
		) c ([row])
        ) src
        ORDER BY 
            _id ASC 
    ) forcedMaterializationTrick
    CROSS APPLY (
		SELECT
			NULLIF(LTRIM([2]), '''') AS [graphType],
			NULLIF(LTRIM([3]), '''') AS [weekday]
		FROM (
            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(forcedMaterializationTrick.[row], N''(?=.*?Graftyp[^:]*:\s*([^·]*))?(?=.*?Veckodag[^:]*:\s*([^·]*))?'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ([2], [3])
        ) p
    ) m
    CROSS APPLY (
        SELECT 
            [graphType] AS [graphType], 
            [weekday] AS [weekday]
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('SMHI_Weather_CreateErrorViews', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateErrorViews];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_CreateErrorViews
--
-- The created error views can be used to find rows that have errors of
-- the following kinds: 
-- 
-- Type casting errors
-- These errors occur when a value cannot be cast to its designated 
-- datatype, for example when trying to cast 'A' to an int.
--
-- Key duplicate errors
-- These errors occur when a primary key is defined and duplicates of
-- that key is found in the tables.
--
-- Create: SMHI_Weather_TemperatureNew_Error
-- Create: SMHI_Weather_TemperatureNewMetadata_Error
-- Create: SMHI_Weather_Temperature_Error
-- Create: SMHI_Weather_Pressure_Error
-- Create: SMHI_Weather_Wind_Error
--
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_CreateErrorViews] 
AS
BEGIN
SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_CreateInsertView';
BEGIN TRY
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
    IF Object_ID('SMHI_Weather_TemperatureNewMetadata_Error', 'V') IS NOT NULL
    DROP VIEW [SMHI_Weather_TemperatureNewMetadata_Error];
    EXEC('
    CREATE VIEW [SMHI_Weather_TemperatureNewMetadata_Error] 
    AS
    SELECT
        *
    FROM
        [SMHI_Weather_TemperatureNewMetadata_Split]
    WHERE
        [graphType_Error] is not null
    OR
        [weekday_Error] is not null;
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('SMHI_Weather_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_CreateTypedTables];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_CreateTypedTables
--
-- The typed tables hold the data that make it through the process 
-- without errors. Columns here have the data types defined in the 
-- source XML definition. 
--
-- Metadata columns, such as _id, can be used to backtrack from 
-- a value to the actual row from where it came.
--
-- Create: SMHI_Weather_TemperatureNew_Typed
-- Create: SMHI_Weather_TemperatureNewMetadata_Typed
-- Create: SMHI_Weather_Temperature_Typed
-- Create: SMHI_Weather_Pressure_Typed
-- Create: SMHI_Weather_Wind_Typed
--
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_CreateTypedTables] 
AS
BEGIN
SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_CreateTypedTables';
BEGIN TRY
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
    IF Object_ID('SMHI_Weather_TemperatureNewMetadata_Typed', 'U') IS NOT NULL
    DROP TABLE [SMHI_Weather_TemperatureNewMetadata_Typed];
    CREATE TABLE [SMHI_Weather_TemperatureNewMetadata_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
        [graphType] varchar(42) null, 
        [weekday] varchar(42) null
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('SMHI_Weather_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_SplitRawIntoTyped];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_SplitRawIntoTyped
--
-- This procedure loads data from the 'Split' views into the 'Typed'
-- tables, with the condition that data must conform to the given
-- data types and have no duplicates for defined keys.
--
-- Load: SMHI_Weather_TemperatureNew_Split into SMHI_Weather_TemperatureNew_Typed
-- Load: SMHI_Weather_TemperatureNewMetadata_Split into SMHI_Weather_TemperatureNewMetadata_Typed
-- Load: SMHI_Weather_Temperature_Split into SMHI_Weather_Temperature_Typed
-- Load: SMHI_Weather_Pressure_Split into SMHI_Weather_Pressure_Typed
-- Load: SMHI_Weather_Wind_Split into SMHI_Weather_Wind_Typed
--
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_SplitRawIntoTyped] 
AS
BEGIN
SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_SplitRawIntoTyped';
BEGIN TRY
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
    IF Object_ID('SMHI_Weather_TemperatureNewMetadata_Typed', 'U') IS NOT NULL
    INSERT INTO [SMHI_Weather_TemperatureNewMetadata_Typed] (
        _id,
        _file,
        [graphType], 
        [weekday]
    )
    SELECT
        _id,
        _file,
        [graphType], 
        [weekday]
    FROM 
        [SMHI_Weather_TemperatureNewMetadata_Split]
    WHERE
        [graphType_Error] is null
    AND
        [weekday_Error] is null;
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('SMHI_Weather_AddKeysToTyped', 'P') IS NOT NULL
DROP PROCEDURE [SMHI_Weather_AddKeysToTyped];
GO
--------------------------------------------------------------------------
-- Procedure: SMHI_Weather_AddKeysToTyped
--
-- This procedure adds keys defined in the source xml definition to the 
-- typed staging tables. Keys boost performance when loading is made 
-- using MERGE statements on the target with a search condition that 
-- matches the key composition. Primary keys also guarantee uniquness
-- among its values.
--
-- Table: SMHI_Weather_Temperature_Typed
-- Key: date (as primary key)
-- Key: hour (as primary key)
-- Table: SMHI_Weather_Pressure_Typed
-- Key: date (as primary key)
-- Key: hour (as primary key)
-- Table: SMHI_Weather_Wind_Typed
-- Key: date (as primary key)
-- Key: hour (as primary key)
--
-- Generated: Tue Sep 30 16:51:05 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [SMHI_Weather_AddKeysToTyped] 
AS
BEGIN
    SET NOCOUNT ON;
DECLARE @metadataId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._StartingWork 
    @WO_ID = @metadataId OUTPUT, 
    @name = 'SMHI_Weather_AddKeysToTyped';
BEGIN TRY
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
    EXEC metadata._StoppingWork @metadataId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._StoppingWork 
        @WO_ID = @metadataId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
