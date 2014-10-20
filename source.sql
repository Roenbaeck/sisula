USE Stage;
GO
IF Object_ID('NYPD_Vehicle_CreateRawTable', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_CreateRawTable];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_CreateRawTable
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
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_CreateRawTable] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_CreateRawTable',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('NYPD_Vehicle_Raw', 'U') IS NOT NULL
    DROP TABLE [NYPD_Vehicle_Raw];
    CREATE TABLE [NYPD_Vehicle_Raw] (
        _id int identity(1,1) not null,
        _file int not null default 0,
        _timestamp datetime2(2) not null default sysdatetime(),
        [row] nvarchar(max),
        constraint [pkNYPD_Vehicle_Raw] primary key(
            _id asc
        )
    );
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('NYPD_Vehicle_CreateInsertView', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_CreateInsertView];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_CreateInsertView
--
-- This view is created as exposing the single column that will be 
-- the target of the BULK INSERT operation, since it cannot insert
-- into a table with multiple columns without a format file.
--
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_CreateInsertView] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_CreateInsertView',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('NYPD_Vehicle_Insert', 'V') IS NOT NULL
    DROP VIEW [NYPD_Vehicle_Insert];
    EXEC('
    CREATE VIEW [NYPD_Vehicle_Insert]
    AS
    SELECT
        [row]
    FROM
        [NYPD_Vehicle_Raw];
    ');
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('NYPD_Vehicle_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_BulkInsert];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_BulkInsert
--
-- This procedure performs a BULK INSERT of the given filename into 
-- the NYPD_Vehicle_Insert view. The file is loaded row by row
-- into a single column holding the entire row. This ensures that no 
-- data is lost when loading.
--
-- This job may called multiple times in a workflow when more than 
-- one file matching a given filename pattern is found.
--
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_BulkInsert] (
	@filename varchar(2000),
    @lastModified datetime,
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @file int;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_BulkInsert',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = @filename, 
    @targetName = 'NYPD_Vehicle_Insert', 
    @sourceType = 'File', 
    @targetType = 'View', 
    @sourceCreated = @lastModified, 
    @targetCreated = DEFAULT;
    IF Object_ID('NYPD_Vehicle_Insert', 'V') IS NOT NULL
    BEGIN
    EXEC('
        BULK INSERT [NYPD_Vehicle_Insert]
        FROM ''' + @filename + '''
        WITH (
            CODEPAGE = ''ACP'',
            DATAFILETYPE = ''char'',
            FIELDTERMINATOR = ''\r\n'',
            TABLOCK 
        );
    ');
    SET @inserts = @@ROWCOUNT;
    EXEC Stage.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    SET @file = (
        SELECT
            CO_ID
        FROM
            metadata.lCO_Container
        WHERE
            CO_NAM_Container_Name = @filename
        AND
            CO_CRE_Container_Created = @lastModified
    );
    UPDATE [NYPD_Vehicle_Raw]
    SET
        _file = @file
    WHERE
        _file = 0;
    SET @updates = @@ROWCOUNT;
    EXEC Stage.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    END 
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('NYPD_Vehicle_CreateSplitViews', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_CreateSplitViews];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_CreateSplitViews
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
-- Create: NYPD_Vehicle_Collision_Split
-- Create: NYPD_Vehicle_CollisionMetadata_Split
--
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_CreateSplitViews] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_CreateSplitViews',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('NYPD_Vehicle_Collision_Split', 'V') IS NOT NULL
    DROP VIEW [NYPD_Vehicle_Collision_Split];
    EXEC('
    CREATE VIEW [NYPD_Vehicle_Collision_Split] 
    AS
    SELECT
        _id,
        _file,
        m.[OccurrencePrecinctCode] as [OccurrencePrecinctCode_Match],
        t.[OccurrencePrecinctCode], 
        CASE
            WHEN t.[OccurrencePrecinctCode] is not null AND TRY_CAST(t.[OccurrencePrecinctCode] AS int) is null THEN ''Conversion to int failed''
        END AS [OccurrencePrecinctCode_Error],
        m.[CollisionID] as [CollisionID_Match],
        t.[CollisionID], 
        CASE
            WHEN t.[CollisionID] is not null AND TRY_CAST(t.[CollisionID] AS int) is null THEN ''Conversion to int failed''
        END AS [CollisionID_Error],
        m.[CollisionKey] as [CollisionKey_Match],
        t.[CollisionKey], 
        CASE
            WHEN t.[CollisionKey] is not null AND TRY_CAST(t.[CollisionKey] AS int) is null THEN ''Conversion to int failed''
        END AS [CollisionKey_Error],
        m.[CollisionOrder] as [CollisionOrder_Match],
        t.[CollisionOrder], 
        CASE
            WHEN t.[CollisionOrder] is not null AND TRY_CAST(t.[CollisionOrder] AS tinyint) is null THEN ''Conversion to tinyint failed''
        END AS [CollisionOrder_Error],
        m.[IntersectionAddress] as [IntersectionAddress_Match],
        t.[IntersectionAddress], 
        CASE
            WHEN t.[IntersectionAddress] is not null AND TRY_CAST(t.[IntersectionAddress] AS varchar(555)) is null THEN ''Conversion to varchar(555) failed''
        END AS [IntersectionAddress_Error],
        m.[IntersectingStreet] as [IntersectingStreet_Match],
        t.[IntersectingStreet], 
        CASE
            WHEN t.[IntersectingStreet] is not null AND TRY_CAST(t.[IntersectingStreet] AS varchar(555)) is null THEN ''Conversion to varchar(555) failed''
        END AS [IntersectingStreet_Error],
        m.[CrossStreet] as [CrossStreet_Match],
        t.[CrossStreet], 
        CASE
            WHEN t.[CrossStreet] is not null AND TRY_CAST(t.[CrossStreet] AS varchar(555)) is null THEN ''Conversion to varchar(555) failed''
        END AS [CrossStreet_Error],
        m.[CollisionVehicleCount] as [CollisionVehicleCount_Match],
        t.[CollisionVehicleCount], 
        CASE
            WHEN t.[CollisionVehicleCount] is not null AND TRY_CAST(t.[CollisionVehicleCount] AS tinyint) is null THEN ''Conversion to tinyint failed''
        END AS [CollisionVehicleCount_Error],
        m.[CollisionInjuredCount] as [CollisionInjuredCount_Match],
        t.[CollisionInjuredCount], 
        CASE
            WHEN t.[CollisionInjuredCount] is not null AND TRY_CAST(t.[CollisionInjuredCount] AS tinyint) is null THEN ''Conversion to tinyint failed''
        END AS [CollisionInjuredCount_Error],
        m.[CollisionKilledCount] as [CollisionKilledCount_Match],
        t.[CollisionKilledCount], 
        CASE
            WHEN t.[CollisionKilledCount] is not null AND TRY_CAST(t.[CollisionKilledCount] AS tinyint) is null THEN ''Conversion to tinyint failed''
        END AS [CollisionKilledCount_Error]
    FROM (
        SELECT TOP(2147483647) 
            * 
        FROM (
        -- this matches the data rows
        SELECT * from NYPD_Vehicle_Raw WHERE [row] LIKE ''[0-9][0-9][0-9];%''
        ) src
        ORDER BY 
            _id ASC 
    ) forcedMaterializationTrick
    CROSS APPLY (
		SELECT
			NULLIF(LTRIM([2]), '''') AS [OccurrencePrecinctCode],
			NULLIF(LTRIM([3]), '''') AS [CollisionID],
			NULLIF(LTRIM([4]), '''') AS [CollisionKey],
			NULLIF(LTRIM([5]), '''') AS [CollisionOrder],
			NULLIF(LTRIM([6]), '''') AS [IntersectionAddress],
			NULLIF(LTRIM([7]), '''') AS [IntersectingStreet],
			NULLIF(LTRIM([8]), '''') AS [CrossStreet],
			NULLIF(LTRIM([9]), '''') AS [CollisionVehicleCount],
			NULLIF(LTRIM([10]), '''') AS [CollisionInjuredCount],
			NULLIF(LTRIM([11]), '''') AS [CollisionKilledCount]
		FROM (
            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(ISNULL(forcedMaterializationTrick.[row], ''''), N''(.*?);[0-9]{4}([0-9]{9})[^;]*;(.*?);(.*?);(.*?);(.*?);(.*?);(.*?);(.*?);(.*?);'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ([2], [3], [4], [5], [6], [7], [8], [9], [10], [11])
        ) p
    ) m
    CROSS APPLY (
        SELECT 
            [OccurrencePrecinctCode] AS [OccurrencePrecinctCode], 
            [CollisionID] AS [CollisionID], 
            [CollisionKey] AS [CollisionKey], 
            [CollisionOrder] AS [CollisionOrder], 
            [IntersectionAddress] AS [IntersectionAddress], 
            [IntersectingStreet] AS [IntersectingStreet], 
            [CrossStreet] AS [CrossStreet], 
            [CollisionVehicleCount] AS [CollisionVehicleCount], 
            [CollisionInjuredCount] AS [CollisionInjuredCount], 
            [CollisionKilledCount] AS [CollisionKilledCount]
    ) t;
    ');
    IF Object_ID('NYPD_Vehicle_CollisionMetadata_Split', 'V') IS NOT NULL
    DROP VIEW [NYPD_Vehicle_CollisionMetadata_Split];
    EXEC('
    CREATE VIEW [NYPD_Vehicle_CollisionMetadata_Split] 
    AS
    SELECT
        _id,
        _file,
        m.[month] as [month_Match],
        t.[month], 
        CASE
            WHEN t.[month] is not null AND TRY_CAST(t.[month] AS varchar(42)) is null THEN ''Conversion to varchar(42) failed''
        END AS [month_Error],
        m.[year] as [year_Match],
        t.[year], 
        CASE
            WHEN t.[year] is not null AND TRY_CAST(t.[year] AS smallint) is null THEN ''Conversion to smallint failed''
        END AS [year_Error],
        m.[notes] as [notes_Match],
        t.[notes], 
        CASE
            WHEN t.[notes] is not null AND TRY_CAST(t.[notes] AS varchar(max)) is null THEN ''Conversion to varchar(max) failed''
        END AS [notes_Error]
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
                    NYPD_Vehicle_Raw
                WHERE 
                    [row] NOT LIKE ''[0-9][0-9][0-9];%''
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
                    NYPD_Vehicle_Raw
                WHERE 
					[row] NOT LIKE ''[0-9][0-9][0-9];%''
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
			NULLIF(LTRIM([2]), '''') AS [month],
			NULLIF(LTRIM([3]), '''') AS [year],
			NULLIF(LTRIM([4]), '''') AS [notes]
		FROM (
            SELECT 
                [match],
                ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS idx
            FROM
                dbo.Splitter(ISNULL(forcedMaterializationTrick.[row], ''''), N''(?=.*?(\w+)\s+[0-9]{4})?(?=.*?\w+\s+([0-9]{4}))?(?=.*?NOTES[^:]*:(.*))?'')
        ) s
        PIVOT (
            MAX([match]) FOR idx IN ([2], [3], [4])
        ) p
    ) m
    CROSS APPLY (
        SELECT 
            [month] AS [month], 
            [year] AS [year], 
            LTRIM(REPLACE([notes], ''�'', '' '')) AS [notes]
    ) t;
    ');
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('NYPD_Vehicle_CreateErrorViews', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_CreateErrorViews];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_CreateErrorViews
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
-- Create: NYPD_Vehicle_Collision_Error
-- Create: NYPD_Vehicle_CollisionMetadata_Error
--
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_CreateErrorViews] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_CreateInsertView',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('NYPD_Vehicle_Collision_Error', 'V') IS NOT NULL
    DROP VIEW [NYPD_Vehicle_Collision_Error];
    EXEC('
    CREATE VIEW [NYPD_Vehicle_Collision_Error] 
    AS
    SELECT
        *
    FROM
        [NYPD_Vehicle_Collision_Split]
    WHERE
        [OccurrencePrecinctCode_Error] is not null
    OR
        [CollisionID_Error] is not null
    OR
        [CollisionKey_Error] is not null
    OR
        [CollisionOrder_Error] is not null
    OR
        [IntersectionAddress_Error] is not null
    OR
        [IntersectingStreet_Error] is not null
    OR
        [CrossStreet_Error] is not null
    OR
        [CollisionVehicleCount_Error] is not null
    OR
        [CollisionInjuredCount_Error] is not null
    OR
        [CollisionKilledCount_Error] is not null;
    ');
    IF Object_ID('NYPD_Vehicle_CollisionMetadata_Error', 'V') IS NOT NULL
    DROP VIEW [NYPD_Vehicle_CollisionMetadata_Error];
    EXEC('
    CREATE VIEW [NYPD_Vehicle_CollisionMetadata_Error] 
    AS
    SELECT
        *
    FROM
        [NYPD_Vehicle_CollisionMetadata_Split]
    WHERE
        [month_Error] is not null
    OR
        [year_Error] is not null
    OR
        [notes_Error] is not null;
    ');
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('NYPD_Vehicle_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_CreateTypedTables];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_CreateTypedTables
--
-- The typed tables hold the data that make it through the process 
-- without errors. Columns here have the data types defined in the 
-- source XML definition. 
--
-- Metadata columns, such as _id, can be used to backtrack from 
-- a value to the actual row from where it came.
--
-- Create: NYPD_Vehicle_Collision_Typed
-- Create: NYPD_Vehicle_CollisionMetadata_Typed
--
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_CreateTypedTables] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_CreateTypedTables',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('NYPD_Vehicle_Collision_Typed', 'U') IS NOT NULL
    DROP TABLE [NYPD_Vehicle_Collision_Typed];
    CREATE TABLE [NYPD_Vehicle_Collision_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
        [OccurrencePrecinctCode] int null, 
        [CollisionID] int null, 
        [CollisionKey] int null, 
        [CollisionOrder] tinyint null, 
        [IntersectionAddress] varchar(555) null, 
        [IntersectingStreet] varchar(555) null, 
        [CrossStreet] varchar(555) null, 
        [CollisionVehicleCount] tinyint null, 
        [CollisionInjuredCount] tinyint null, 
        [CollisionKilledCount] tinyint null
    );
    IF Object_ID('NYPD_Vehicle_CollisionMetadata_Typed', 'U') IS NOT NULL
    DROP TABLE [NYPD_Vehicle_CollisionMetadata_Typed];
    CREATE TABLE [NYPD_Vehicle_CollisionMetadata_Typed] (
        _id int not null,
        _file int not null,
        _timestamp datetime2(2) not null default sysdatetime(),
        [month] varchar(42) null, 
        [year] smallint null, 
        [notes] varchar(max) null, 
        [changedAt] as CAST(dateadd(day, -1, 
            dateadd(month, 1, 
            cast([year] as char(4)) + 
            case left([month], 3)
                when 'Jan' then '01'
                when 'Feb' then '02'
                when 'Mar' then '03'
                when 'Apr' then '04'
                when 'May' then '05'
                when 'Jun' then '06'
                when 'Jul' then '07'
                when 'Aug' then '08'
                when 'Sep' then '09'
                when 'Okt' then '10'
                when 'Nov' then '11'
                when 'Dec' then '12'
            end + 
            '01')) AS date) 
    );
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('NYPD_Vehicle_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_SplitRawIntoTyped];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_SplitRawIntoTyped
--
-- This procedure loads data from the 'Split' views into the 'Typed'
-- tables, with the condition that data must conform to the given
-- data types and have no duplicates for defined keys.
--
-- Load: NYPD_Vehicle_Collision_Split into NYPD_Vehicle_Collision_Typed
-- Load: NYPD_Vehicle_CollisionMetadata_Split into NYPD_Vehicle_CollisionMetadata_Typed
--
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_SplitRawIntoTyped] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @insert int = 0;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_SplitRawIntoTyped',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('NYPD_Vehicle_Collision_Typed', 'U') IS NOT NULL
    BEGIN
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'NYPD_Vehicle_Collision_Split', 
    @targetName = 'NYPD_Vehicle_Collision_Typed', 
    @sourceType = 'View', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    INSERT INTO [NYPD_Vehicle_Collision_Typed] (
        _id,
        _file,
        [OccurrencePrecinctCode], 
        [CollisionID], 
        [CollisionKey], 
        [CollisionOrder], 
        [IntersectionAddress], 
        [IntersectingStreet], 
        [CrossStreet], 
        [CollisionVehicleCount], 
        [CollisionInjuredCount], 
        [CollisionKilledCount]
    )
    SELECT
        _id,
        _file,
        [OccurrencePrecinctCode], 
        [CollisionID], 
        [CollisionKey], 
        [CollisionOrder], 
        [IntersectionAddress], 
        [IntersectingStreet], 
        [CrossStreet], 
        [CollisionVehicleCount], 
        [CollisionInjuredCount], 
        [CollisionKilledCount]
    FROM 
        [NYPD_Vehicle_Collision_Split]
    WHERE
        [OccurrencePrecinctCode_Error] is null
    AND
        [CollisionID_Error] is null
    AND
        [CollisionKey_Error] is null
    AND
        [CollisionOrder_Error] is null
    AND
        [IntersectionAddress_Error] is null
    AND
        [IntersectingStreet_Error] is null
    AND
        [CrossStreet_Error] is null
    AND
        [CollisionVehicleCount_Error] is null
    AND
        [CollisionInjuredCount_Error] is null
    AND
        [CollisionKilledCount_Error] is null;
    SET @insert = @insert + @@ROWCOUNT;
    EXEC Stage.metadata._WorkSetInserts @workId, @operationsId, @insert;
    END
    IF Object_ID('NYPD_Vehicle_CollisionMetadata_Typed', 'U') IS NOT NULL
    BEGIN
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'NYPD_Vehicle_CollisionMetadata_Split', 
    @targetName = 'NYPD_Vehicle_CollisionMetadata_Typed', 
    @sourceType = 'View', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    INSERT INTO [NYPD_Vehicle_CollisionMetadata_Typed] (
        _id,
        _file,
        [month], 
        [year], 
        [notes]
    )
    SELECT
        _id,
        _file,
        [month], 
        [year], 
        [notes]
    FROM 
        [NYPD_Vehicle_CollisionMetadata_Split]
    WHERE
        [month_Error] is null
    AND
        [year_Error] is null
    AND
        [notes_Error] is null;
    SET @insert = @insert + @@ROWCOUNT;
    EXEC Stage.metadata._WorkSetInserts @workId, @operationsId, @insert;
    END
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
IF Object_ID('NYPD_Vehicle_AddKeysToTyped', 'P') IS NOT NULL
DROP PROCEDURE [NYPD_Vehicle_AddKeysToTyped];
GO
--------------------------------------------------------------------------
-- Procedure: NYPD_Vehicle_AddKeysToTyped
--
-- This procedure adds keys defined in the source xml definition to the 
-- typed staging tables. Keys boost performance when loading is made 
-- using MERGE statements on the target with a search condition that 
-- matches the key composition. Primary keys also guarantee uniquness
-- among its values.
--
--
-- Generated: Mon Oct 20 14:07:37 UTC+0200 2014 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [NYPD_Vehicle_AddKeysToTyped] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
    SET NOCOUNT ON;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Vehicle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'NYPD_Vehicle_AddKeysToTyped',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    EXEC Stage.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE();
    EXEC Stage.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    THROW; -- Propagate the error
END CATCH
END
GO
-- The source definition used when generating the above
DECLARE @xml XML = N'<source name="Vehicle" codepage="ACP" datafiletype="char" fieldterminator="\r\n">
	<description>http://www.nyc.gov/html/nypd/html/traffic_reports/motor_vehicle_collision_data.shtml</description>
	<part name="Collision" nulls="">
        -- this matches the data rows
        SELECT * from NYPD_Vehicle_Raw WHERE [row] LIKE ''[0-9][0-9][0-9];%''
        <term name="OccurrencePrecinctCode" delimiter=";" format="int"/>
		<term name="CollisionID" pattern="[0-9]{4}([0-9]{9})[^;]*;" format="int"/>
		<term name="CollisionKey" delimiter=";" format="int"/>
		<term name="CollisionOrder" delimiter=";" format="tinyint"/>
		<term name="IntersectionAddress" delimiter=";" format="varchar(555)"/>
		<term name="IntersectingStreet" delimiter=";" format="varchar(555)"/>
		<term name="CrossStreet" delimiter=";" format="varchar(555)"/>
		<term name="CollisionVehicleCount" delimiter=";" format="tinyint"/>
		<term name="CollisionInjuredCount" delimiter=";" format="tinyint"/>
		<term name="CollisionKilledCount" delimiter=";" format="tinyint"/>
	</part>
	<part name="CollisionMetadata">
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
                    NYPD_Vehicle_Raw
                WHERE 
                    [row] NOT LIKE ''[0-9][0-9][0-9];%''
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
                    NYPD_Vehicle_Raw
                WHERE 
					[row] NOT LIKE ''[0-9][0-9][0-9];%''
		    ) src
			WHERE
				src._file = f._file
			FOR XML PATH('''')
		) c ([row])
        <term name="month" pattern="(?=.*?(\w+)\s+[0-9]{4})?" format="varchar(42)"/>
		<term name="year" pattern="(?=.*?\w+\s+([0-9]{4}))?" format="smallint"/>
		<calculation name="changedAt" format="date" persisted="false">
            dateadd(day, -1, 
            dateadd(month, 1, 
            cast([year] as char(4)) + 
            case left([month], 3)
                when ''Jan'' then ''01''
                when ''Feb'' then ''02''
                when ''Mar'' then ''03''
                when ''Apr'' then ''04''
                when ''May'' then ''05''
                when ''Jun'' then ''06''
                when ''Jul'' then ''07''
                when ''Aug'' then ''08''
                when ''Sep'' then ''09''
                when ''Okt'' then ''10''
                when ''Nov'' then ''11''
                when ''Dec'' then ''12''
            end + 
            ''01''))
        </calculation>
		<term name="notes" pattern="(?=.*?NOTES[^:]*:(.*))?" format="varchar(max)">
            LTRIM(REPLACE([notes], ''�'', '' ''))
        </term>
	</part>
</source>
';
DECLARE @name varchar(255) = @xml.value('/source[1]/@name', 'varchar(255)');
DECLARE @CF_ID int;
SELECT
    @CF_ID = CF_ID
FROM
    Stage.metadata.lCF_Configuration
WHERE
    CF_NAM_Configuration_Name = @name;
IF(@CF_ID is null) 
BEGIN
    INSERT INTO Stage.metadata.lCF_Configuration (
        CF_TYP_CFT_ConfigurationType,
        CF_NAM_Configuration_Name,
        CF_XML_Configuration_XMLDefinition
    )
    VALUES (
        'Source',
        @name,
        @xml
    );
END
ELSE
BEGIN
    UPDATE Stage.metadata.lCF_Configuration
    SET
        CF_XML_Configuration_XMLDefinition = @xml
    WHERE
        CF_NAM_Configuration_Name = @name;
END
