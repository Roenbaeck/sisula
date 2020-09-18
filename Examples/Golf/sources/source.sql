USE GolfStage;
GO
-- create schema if it does not exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dbo')
BEGIN
    EXEC( 'CREATE SCHEMA dbo' );
END
GO
-- creates utility functions needed in the staging
IF Object_Id('dbo.Splitter', 'FT') IS NOT NULL
DROP FUNCTION [dbo].[Splitter];
GO
IF Object_Id('dbo.MultiSplitter', 'FT') IS NOT NULL
DROP FUNCTION [dbo].[MultiSplitter];
GO
IF Object_Id('dbo.ColumnSplitter', 'PC') IS NOT NULL
DROP PROCEDURE [dbo].[ColumnSplitter];
GO
IF Object_Id('dbo.IsType', 'FS') IS NOT NULL
DROP FUNCTION [dbo].[IsType];
GO
IF Object_Id('dbo.ToLocalTime', 'FS') IS NOT NULL
DROP FUNCTION [dbo].[ToLocalTime];
GO
IF Object_Id('dbo.ToUniversalTime', 'FS') IS NOT NULL 
DROP FUNCTION [dbo].[ToUniversalTime]; 
GO
-- BEGIN! LEGACY --
IF EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = 'dboUtilities'
)
DROP ASSEMBLY dboUtilities;
-- END! LEGACY --
declare @version char(4) =
	case 
		when patindex('% 2[0-2][0-9][0-9] %', @@VERSION) > 0
		then substring(@@VERSION, patindex('% 2[0-2][0-9][0-9] %', @@VERSION) + 1, 4)
		else '????'
	end
IF EXISTS (
	SELECT
		*
	FROM
		sys.assemblies
	WHERE
		name = 'Utilities'
)
BEGIN TRY
	ALTER ASSEMBLY Utilities
	FROM 'H:\GitHub\sisula\code\Utilities' + @version + '.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server ' + @version + ' was updated.'
END TRY BEGIN CATCH 
	DECLARE @msg VARCHAR(2000) = ERROR_MESSAGE();
	IF(PATINDEX('%identical%', @msg) = 0) PRINT ERROR_MESSAGE();
END CATCH
ELSE -- assembly does not exist
BEGIN TRY
    -- since some version of 2017 assemblies must be explicitly whitelisted
    IF(@version >= 2017 AND OBJECT_ID('sys.sp_add_trusted_assembly') IS NOT NULL) 
    BEGIN
		CREATE TABLE #hash([hash] varbinary(64));
		EXEC('INSERT INTO #hash SELECT CONVERT(varbinary(64), ''0x'' + H, 1) FROM OPENROWSET(BULK ''H:\GitHub\sisula\code\Utilities' + @version + '.SHA512'', SINGLE_CLOB) T(H);');
		DECLARE @hash varbinary(64);
		SELECT @hash = [hash] FROM #hash;
        IF NOT EXISTS(SELECT [hash] FROM sys.trusted_assemblies WHERE [hash] = @hash)
            EXEC sys.sp_add_trusted_assembly @hash, N'Utilities';
	END
	CREATE ASSEMBLY Utilities
	AUTHORIZATION dbo
	FROM 'H:\GitHub\sisula\code\Utilities' + @version + '.dll'
	WITH PERMISSION_SET = SAFE;
	PRINT 'The .NET CLR for SQL Server ' + @version + ' was installed.'
END TRY BEGIN CATCH 
	PRINT ERROR_MESSAGE();
END CATCH
GO
CREATE FUNCTION [dbo].Splitter(@row AS nvarchar(max), @pattern AS nvarchar(4000))
RETURNS TABLE (
	[match] nvarchar(max),
	[index] int
) AS EXTERNAL NAME Utilities.Splitter.InitMethod;
GO
CREATE FUNCTION [dbo].MultiSplitter(@row AS nvarchar(max), @pattern AS nvarchar(4000))
RETURNS TABLE (
	[match] nvarchar(max),
	[index] int
) AS EXTERNAL NAME Utilities.MultiSplitter.InitMethod;
GO
CREATE FUNCTION [dbo].IsType(@dataValue AS nvarchar(max), @dataType AS nvarchar(4000))
RETURNS bit
AS EXTERNAL NAME Utilities.IsType.InitMethod;
GO
CREATE FUNCTION [dbo].ToLocalTime(@sqlDatetime AS datetime)
RETURNS datetime
AS EXTERNAL NAME Utilities.ToLocalTime.InitMethod;
GO
CREATE FUNCTION [dbo].ToUniversalTime(@sqlDatetime AS datetime) 
RETURNS datetime 
AS EXTERNAL NAME Utilities.ToUniversalTime.InitMethod;
GO
CREATE PROCEDURE [dbo].ColumnSplitter(
	@table AS nvarchar(4000),
	@column AS nvarchar(4000),
	@pattern AS nvarchar(4000),
	@includeColumns AS nvarchar(4000) = null
)
AS EXTERNAL NAME Utilities.ColumnSplitter.InitMethod;
GO
IF NOT EXISTS (
    SELECT value
    FROM sys.configurations
    WHERE name = 'clr enabled'
      AND value = 1
)
BEGIN
    EXEC sp_configure 'clr enabled', 1;
    reconfigure with override;
END
GO
-- Dropping raw split table to enforce Deferred Name Resolution: PGA_Kaggle_RawSplit
IF Object_ID('dbo.PGA_Kaggle_RawSplit', 'U') IS NOT NULL
DROP TABLE [dbo].[PGA_Kaggle_RawSplit];
IF Object_ID('dbo.PGA_Kaggle_CreateRawSplitTable', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_CreateRawSplitTable];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_CreateRawSplitTable
--
-- The split table is populated by a bulk insert with a format file that
-- split rows from the source file into columns.
--
-- Create: PGA_Kaggle_Stats_RawSplit
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_CreateRawSplitTable] (
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
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_CreateRawSplitTable',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('dbo.PGA_Kaggle_RawSplit', 'U') IS NOT NULL
    DROP TABLE [dbo].[PGA_Kaggle_RawSplit];
    EXEC('
    CREATE TABLE [dbo].[PGA_Kaggle_RawSplit] (
        _id int identity(1,1) not null,
        _file AS metadata_CO_ID, -- keep an alias for backwards compatibility
        metadata_CO_ID int not null default 0,
        metadata_JB_ID int not null default 0,
        _timestamp datetime not null default SYSUTCDATETIME(),
        [Player Name] varchar(1000), 
        [Date] varchar(1000), 
        [Statistic] varchar(1000), 
        [Variable] varchar(1000), 
        [Value] varchar(1000), 
        constraint [pkdbo_PGA_Kaggle_RawSplit] primary key (
            _id asc
        )
    )
    ');
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
-- Dropping insert view to enforce Deferred Name Resolution: PGA_Kaggle_Insert
IF Object_ID('dbo.PGA_Kaggle_Insert', 'V') IS NOT NULL
DROP VIEW [dbo].[PGA_Kaggle_Insert];
IF Object_ID('dbo.PGA_Kaggle_CreateInsertView', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_CreateInsertView];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_CreateInsertView
--
-- This view is created as exposing the single column that will be
-- the target of the BULK INSERT operation, since it cannot insert
-- into a table with multiple columns without a format file.
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_CreateInsertView] (
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
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_CreateInsertView',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('dbo.PGA_Kaggle_Insert', 'V') IS NOT NULL
    DROP VIEW [dbo].[PGA_Kaggle_Insert];
    EXEC('
    CREATE VIEW [dbo].[PGA_Kaggle_Insert]
    AS
    SELECT
        [Player Name],
        [Date],
        [Statistic],
        [Variable],
        [Value]
    FROM
        [dbo].[PGA_Kaggle_RawSplit];
    ');
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
IF Object_ID('dbo.PGA_Kaggle_BulkInsert', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_BulkInsert];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_BulkInsert
--
-- This procedure performs a BULK INSERT of the given filename into
-- the PGA_Kaggle_Insert view. The file is loaded row by row
-- into a single column holding the entire row. This ensures that no
-- data is lost when loading.
--
-- This job may called multiple times in a workflow when more than
-- one file matching a given filename pattern is found.
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_BulkInsert] (
	@filename varchar(2000),
    @lastModified datetime,
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @CO_ID int;
DECLARE @JB_ID int;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_BulkInsert',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC GolfDW.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = @filename, 
    @targetName = 'PGA_Kaggle_Insert', 
    @sourceType = 'File', 
    @targetType = 'View', 
    @sourceCreated = @lastModified, 
    @targetCreated = DEFAULT;
    IF Object_ID('dbo.PGA_Kaggle_Insert', 'V') IS NOT NULL
    BEGIN
    EXEC('
        BULK INSERT [dbo].[PGA_Kaggle_Insert]
        FROM ''' + @filename + '''
        WITH (
            FORMAT = ''CSV'',
            CODEPAGE = ''ACP'',
            FIELDQUOTE = ''"'',
            FORMATFILE = ''H:\GitHub\sisula\Examples\Golf\formats\source.xml'',
            FIRSTROW = 2,
            TABLOCK
        );
    ');
    SET @inserts = @@ROWCOUNT;
    EXEC GolfDW.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    SET @CO_ID = ISNULL((
        SELECT TOP 1
            CO_ID
        FROM
            GolfDW.metadata.lCO_Container
        WHERE
            CO_NAM_Container_Name = @filename
        AND
            CO_CRE_Container_Created = @lastModified
    ), 0);
    SET @JB_ID = ISNULL((
        SELECT
            jb.JB_ID
        FROM
            GolfDW.metadata.lWO_part_JB_of wojb
        JOIN
            GolfDW.metadata.lJB_Job jb
        ON
            jb.JB_ID = wojb.JB_ID_of
        AND
            jb.JB_AID_AID_AgentJobId = @agentJobId
        WHERE
            wojb.WO_ID_part = @workId
    ), 0);
    UPDATE [dbo].[PGA_Kaggle_RawSplit]
    SET
        metadata_CO_ID =
          case when metadata_CO_ID = 0 then @CO_ID else metadata_CO_ID end,
        metadata_JB_ID =
          case when metadata_JB_ID = 0 then @JB_ID else metadata_JB_ID end;
    SET @updates = @@ROWCOUNT;
    EXEC GolfDW.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    END
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
-- Dropping split view to enforce Deferred Name Resolution: PGA_Kaggle_Stats_Split
IF Object_ID('dbo.PGA_Kaggle_Stats_Split', 'V') IS NOT NULL
DROP VIEW [dbo].[PGA_Kaggle_Stats_Split];
IF Object_ID('dbo.PGA_Kaggle_CreateSplitViews', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_CreateSplitViews];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_CreateSplitViews
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
-- Create: PGA_Kaggle_Stats_Split
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_CreateSplitViews] (
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
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_CreateSplitViews',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('dbo.PGA_Kaggle_Stats_Split', 'V') IS NOT NULL
    DROP VIEW [dbo].[PGA_Kaggle_Stats_Split];
    EXEC('
    CREATE VIEW [dbo].[PGA_Kaggle_Stats_Split]
    AS
    SELECT
        t._id,
        t.metadata_CO_ID,
        t.metadata_JB_ID,
        t._timestamp,
        m.[Player Name] as [Player Name_Match],
        t.[Player Name],
        CASE
            WHEN t.[Player Name] is null THEN ''Null value not allowed''
            WHEN t.[Player Name] is not null AND [dbo].IsType(t.[Player Name], ''varchar(555)'') = 0 THEN ''Conversion to varchar(555) failed''
        END AS [Player Name_Error],
        m.[Date] as [Date_Match],
        t.[Date],
        CASE
            WHEN t.[Date] is null THEN ''Null value not allowed''
            WHEN t.[Date] is not null AND [dbo].IsType(t.[Date], ''date'') = 0 THEN ''Conversion to date failed''
        END AS [Date_Error],
        m.[Statistic] as [Statistic_Match],
        t.[Statistic],
        CASE
            WHEN t.[Statistic] is null THEN ''Null value not allowed''
            WHEN t.[Statistic] is not null AND [dbo].IsType(t.[Statistic], ''varchar(555)'') = 0 THEN ''Conversion to varchar(555) failed''
        END AS [Statistic_Error],
        m.[Variable] as [Variable_Match],
        t.[Variable],
        CASE
            WHEN t.[Variable] is null THEN ''Null value not allowed''
            WHEN t.[Variable] is not null AND [dbo].IsType(t.[Variable], ''varchar(555)'') = 0 THEN ''Conversion to varchar(555) failed''
        END AS [Variable_Error],
        m.[Value] as [Value_Match],
        t.[Value],
        CASE
            WHEN t.[Value] is not null AND [dbo].IsType(t.[Value], ''varchar(555)'') = 0 THEN ''Conversion to varchar(555) failed''
        END AS [Value_Error],
        ROW_NUMBER() OVER (
            PARTITION BY
                t.[Statistic],
                t.[Variable],
                t.[Player Name],
                t.[Date]
            ORDER BY
                t._id
        ) - 1 as statKey_Duplicate
    FROM (
        SELECT
            _id,
            metadata_CO_ID,
            metadata_JB_ID,
            _timestamp,
			NULLIF([Player Name], '''') AS [Player Name],
			NULLIF([Date], '''') AS [Date],
			NULLIF([Statistic], '''') AS [Statistic],
			NULLIF([Variable], '''') AS [Variable],
			NULLIF([Value], '''') AS [Value]
        FROM 
            [dbo].[PGA_Kaggle_RawSplit]
    ) m
    CROSS APPLY (
        SELECT
            _id,
            metadata_CO_ID,
            metadata_JB_ID,
            _timestamp,
            [Player Name] AS [Player Name],
            [Date] AS [Date],
            [Statistic] AS [Statistic],
            [Variable] AS [Variable],
            [Value] AS [Value]
    ) t;
    ');
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
-- Dropping error view to enforce Deferred Name Resolution: PGA_Kaggle_Stats_Error
IF Object_ID('dbo.PGA_Kaggle_Stats_Error', 'V') IS NOT NULL
DROP VIEW [dbo].[PGA_Kaggle_Stats_Error];
IF Object_ID('dbo.PGA_Kaggle_CreateErrorViews', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_CreateErrorViews];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_CreateErrorViews
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
-- Create: PGA_Kaggle_Stats_Error
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_CreateErrorViews] (
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
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_CreateInsertView',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('dbo.PGA_Kaggle_Stats_Error', 'V') IS NOT NULL
    DROP VIEW [dbo].[PGA_Kaggle_Stats_Error];
    EXEC('
    CREATE VIEW [dbo].[PGA_Kaggle_Stats_Error] 
    AS
    SELECT
        *
    FROM
        [dbo].[PGA_Kaggle_Stats_Split]
    WHERE
        statKey_Duplicate > 0
    OR
        [Player Name_Error] is not null
    OR
        [Date_Error] is not null
    OR
        [Statistic_Error] is not null
    OR
        [Variable_Error] is not null
    OR
        [Value_Error] is not null;
    ');
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
-- Dropping table to enforce Deferred Name Resolution: PGA_Kaggle_Stats_Typed
IF Object_ID('dbo.PGA_Kaggle_Stats_Typed', 'U') IS NOT NULL
DROP TABLE [dbo].[PGA_Kaggle_Stats_Typed];
IF Object_ID('dbo.PGA_Kaggle_CreateTypedTables', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_CreateTypedTables];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_CreateTypedTables
--
-- The typed tables hold the data that make it through the process
-- without errors. Columns here have the data types defined in the
-- source XML definition.
--
-- Metadata columns, such as _id, can be used to backtrack from
-- a value to the actual row from where it came.
--
-- Create: PGA_Kaggle_Stats_Typed
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_CreateTypedTables] (
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
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_CreateTypedTables',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('dbo.PGA_Kaggle_Stats_Typed', 'U') IS NOT NULL
    DROP TABLE [dbo].[PGA_Kaggle_Stats_Typed];
    CREATE TABLE [dbo].[PGA_Kaggle_Stats_Typed] (
        _id int not null,
        _file AS metadata_CO_ID, -- keep an alias for backwards compatibility
        metadata_CO_ID int not null,
        metadata_JB_ID int not null,
        _timestamp datetime not null default SYSUTCDATETIME(),
        _statKey as cast(HashBytes('MD5', CONVERT(varchar(max), [Statistic], 126) + CHAR(183) + CONVERT(varchar(max), [Variable], 126) + CHAR(183) + CONVERT(varchar(max), [Player Name], 126) + CHAR(183) + CONVERT(varchar(max), [Date], 126)) as varbinary(16)),
        [Player Name] varchar(555) not null,
        [Date] date not null,
        [Statistic] varchar(555) not null,
        [Variable] varchar(555) not null,
        [Value] varchar(555) null
    );
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
IF Object_ID('dbo.PGA_Kaggle_SplitRawIntoTyped', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_SplitRawIntoTyped];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_SplitRawIntoTyped
--
-- This procedure loads data from the 'Split' views into the 'Typed'
-- tables, with the condition that data must conform to the given
-- data types and have no duplicates for defined keys.
--
-- Load: PGA_Kaggle_Stats_Split into PGA_Kaggle_Stats_Typed
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_SplitRawIntoTyped] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @JB_ID int;
DECLARE @insert int;
DECLARE @updates int;
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_SplitRawIntoTyped',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('dbo.PGA_Kaggle_Stats_Typed', 'U') IS NOT NULL
    BEGIN
EXEC GolfDW.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'PGA_Kaggle_Stats_Split', 
    @targetName = 'PGA_Kaggle_Stats_Typed', 
    @sourceType = 'View', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    INSERT INTO [dbo].[PGA_Kaggle_Stats_Typed] (
        _id,
        metadata_CO_ID,
        metadata_JB_ID,
        [Player Name],
        [Date],
        [Statistic],
        [Variable],
        [Value]
    )
    SELECT
        _id,
        metadata_CO_ID,
        metadata_JB_ID,
        [Player Name],
        [Date],
        [Statistic],
        [Variable],
        [Value]
    FROM
        [dbo].[PGA_Kaggle_Stats_Split]
    WHERE
        statKey_Duplicate = 0
    SET @insert = @insert + @@ROWCOUNT;
    EXEC GolfDW.metadata._WorkSetInserts @workId, @operationsId, @insert;
    SET @JB_ID = ISNULL((
        SELECT TOP 1
            JB_ID
        FROM
            GolfDW.metadata.lJB_Job
        WHERE
            JB_AID_AID_AgentJobId = @agentJobId
    ), 0);
    UPDATE [dbo].[PGA_Kaggle_Stats_Typed]
    SET
      metadata_JB_ID = @JB_ID
    WHERE
      metadata_JB_ID <> @JB_ID;
    SET @updates = @@ROWCOUNT;
    EXEC GolfDW.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    END
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
IF Object_ID('dbo.PGA_Kaggle_AddKeysToTyped', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[PGA_Kaggle_AddKeysToTyped];
GO
--------------------------------------------------------------------------
-- Procedure: PGA_Kaggle_AddKeysToTyped
--
-- This procedure adds keys defined in the source xml definition to the 
-- typed staging tables. Keys boost performance when loading is made 
-- using MERGE statements on the target with a search condition that 
-- matches the key composition. Primary keys also guarantee uniquness
-- among its values.
--
-- Table: PGA_Kaggle_Stats_Typed
-- Key: Statistic (as primary key)
-- Key: Variable (as primary key)
-- Key: Player Name (as primary key)
-- Key: Date (as primary key)
--
-- Generated: Fri Sep 18 09:42:45 UTC+0200 2020 by <username>
-- From: <computer> in the <domainname> domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[PGA_Kaggle_AddKeysToTyped] (
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
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Kaggle', 
    @configurationType = 'Source', 
    @WO_ID = @workId OUTPUT, 
    @name = 'PGA_Kaggle_AddKeysToTyped',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
    IF Object_ID('dbo.PGA_Kaggle_Stats_Typed', 'U') IS NOT NULL
    ALTER TABLE [dbo].[PGA_Kaggle_Stats_Typed]
    ADD
        CONSTRAINT [dbo_statKey_PGA_Kaggle_Stats_Typed] primary key (
            [Statistic],
            [Variable],
            [Player Name],
            [Date]
        );
    EXEC GolfDW.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC GolfDW.metadata._WorkStopping
        @WO_ID = @workId, 
        @status = 'Failure', 
        @errorLine = @theErrorLine, 
        @errorMessage = @theErrorMessage;
    -- Propagate the error
    RAISERROR(
        @theErrorMessage,
        @theErrorSeverity,
        @theErrorState
    ); 
END CATCH
END
GO
-- The source definition used when generating the above
DECLARE @xml XML = N'
<source name="Kaggle" codepage="ACP" format="CSV" fieldquote="&quot;" datafiletype="char" fieldterminator="\n" rowlength="1000" split="bulk" firstrow="2">
	<part name="Stats" nulls="" typeCheck="false" keyCheck="true">
		<term name="Player Name" delimiter="," format="varchar(555)"/>
		<term name="Date" delimiter="," format="date"/>
		<term name="Statistic" delimiter="," format="varchar(555)"/>
		<term name="Variable" delimiter="," format="varchar(555)"/>
		<term name="Value" format="varchar(555)"/>
		<key name="statKey" type="primary key">
			<component of="Statistic"/>
			<component of="Variable"/>
			<component of="Player Name"/>
			<component of="Date"/>
		</key>
	</part>
</source>
';
DECLARE @name varchar(255) = @xml.value('/source[1]/@name', 'varchar(255)');
DECLARE @CF_ID int;
SELECT
    @CF_ID = CF_ID
FROM
    GolfDW.metadata.lCF_Configuration
WHERE
    CF_NAM_Configuration_Name = @name;
IF(@CF_ID is null) 
BEGIN
    INSERT INTO GolfDW.metadata.lCF_Configuration (
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
    UPDATE GolfDW.metadata.lCF_Configuration
    SET
        CF_XML_Configuration_XMLDefinition = @xml
    WHERE
        CF_NAM_Configuration_Name = @name;
END
