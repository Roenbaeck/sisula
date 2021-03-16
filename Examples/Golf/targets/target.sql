USE GolfStage;
GO
IF Object_ID('dbo.lPL_Player__PGA_Kaggle_Stats_Typed', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[lPL_Player__PGA_Kaggle_Stats_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lPL_Player__PGA_Kaggle_Stats_Typed
-- Source: PGA_Kaggle_Stats_Typed
-- Target: lPL_Player ()
--
-- Map: Player Name to PL_NAM_Player_Name (as natural key)
-- Map: Birth Date to PL_BID_Player_BirthDate (as static)
-- Map: WorkId to Metadata_PL (as metadata)
-- 
-- Generated: Tue Mar 16 13:06:49 UTC+0100 2021 by eldle
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[lPL_Player__PGA_Kaggle_Stats_Typed] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @deletes int;
DECLARE @actions TABLE (
    [action] char(1) not null
);
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Stats', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lPL_Player__PGA_Kaggle_Stats_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC GolfDW.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'PGA_Kaggle_Stats_Typed', 
    @targetName = 'lPL_Player', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Preparations before the merge -----------------
        -- preparations can be put here
    -- Perform the actual merge ----------------------
    MERGE INTO [GolfDW].[dbo].[lPL_Player] AS [target]
    USING (
        select distinct 
            [Player Name], 
            '1972-08-20' as [Birth Date],
            @WorkID as WorkId 
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed
    ) AS [source]
    ON (
        [source].[Player Name] = [target].[PL_NAM_Player_Name]
    )
    WHEN NOT MATCHED THEN INSERT (
        [PL_NAM_Player_Name],
        [PL_BID_Player_BirthDate],
        [Metadata_PL]
    )
    VALUES (
        [source].[Player Name],
        [source].[Birth Date],
        [source].[WorkId]
    )
    WHEN MATCHED AND (
        ([target].[PL_BID_Player_BirthDate] is null)
    ) 
    THEN UPDATE
    SET
        [target].[PL_BID_Player_BirthDate] = 
            CASE 
                WHEN ([target].[PL_BID_Player_BirthDate] is null) 
                THEN [source].[Birth Date] 
                ELSE [target].[PL_BID_Player_BirthDate] 
            END,
        [target].[Metadata_PL] = [source].[WorkId]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC GolfDW.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC GolfDW.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC GolfDW.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    -- Post processing after the merge ---------------
        -- post processing can be put here
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
IF Object_ID('dbo.SGR_StatisticGroup__PGA_Kaggle_Stats_Typed', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[SGR_StatisticGroup__PGA_Kaggle_Stats_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: SGR_StatisticGroup__PGA_Kaggle_Stats_Typed
-- Source: PGA_Kaggle_Stats_Typed
-- Target: SGR_StatisticGroup ()
--
-- Map: Statistic to SGR_StatisticGroup (as natural key)
-- Map: WorkId to Metadata_SGR (as metadata)
-- 
-- Generated: Tue Mar 16 13:06:49 UTC+0100 2021 by eldle
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SGR_StatisticGroup__PGA_Kaggle_Stats_Typed] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @deletes int;
DECLARE @actions TABLE (
    [action] char(1) not null
);
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Stats', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'SGR_StatisticGroup__PGA_Kaggle_Stats_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC GolfDW.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'PGA_Kaggle_Stats_Typed', 
    @targetName = 'SGR_StatisticGroup', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Preparations before the merge -----------------
        -- preparations can be put here
    -- Perform the actual merge ----------------------
    MERGE INTO [GolfDW].[dbo].[SGR_StatisticGroup] AS [target]
    USING (
        select distinct 
            [Statistic], 
            @WorkID as WorkId 
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed
    ) AS [source]
    ON (
        [source].[Statistic] = [target].[SGR_StatisticGroup]
    )
    WHEN NOT MATCHED THEN INSERT (
        [SGR_StatisticGroup],
        [Metadata_SGR]
    )
    VALUES (
        [source].[Statistic],
        [source].[WorkId]
    )
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC GolfDW.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC GolfDW.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC GolfDW.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    -- Post processing after the merge ---------------
        -- post processing can be put here
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
IF Object_ID('dbo.lST_Statistic__PGA_Kaggle_Stats_Typed', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[lST_Statistic__PGA_Kaggle_Stats_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lST_Statistic__PGA_Kaggle_Stats_Typed
-- Source: PGA_Kaggle_Stats_Typed
-- Target: lST_Statistic ()
--
-- Map: Statistic to ST_GRP_SGR_StatisticGroup (as natural key)
-- Map: Variable to ST_DET_Statistic_Detail (as natural key)
-- Map: WorkId to Metadata_ST (as metadata)
-- 
-- Generated: Tue Mar 16 13:06:49 UTC+0100 2021 by eldle
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[lST_Statistic__PGA_Kaggle_Stats_Typed] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @deletes int;
DECLARE @actions TABLE (
    [action] char(1) not null
);
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Stats', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lST_Statistic__PGA_Kaggle_Stats_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC GolfDW.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'PGA_Kaggle_Stats_Typed', 
    @targetName = 'lST_Statistic', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Preparations before the merge -----------------
        -- preparations can be put here
    -- Perform the actual merge ----------------------
    MERGE INTO [GolfDW].[dbo].[lST_Statistic] AS [target]
    USING (
        select distinct 
            [Statistic], 
            [Variable], 
            @WorkID as WorkId 
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed
    ) AS [source]
    ON (
        [source].[Statistic] = [target].[ST_GRP_SGR_StatisticGroup]
    AND
        [source].[Variable] = [target].[ST_DET_Statistic_Detail]
    )
    WHEN NOT MATCHED THEN INSERT (
        [ST_GRP_SGR_StatisticGroup],
        [ST_DET_Statistic_Detail],
        [Metadata_ST]
    )
    VALUES (
        [source].[Statistic],
        [source].[Variable],
        [source].[WorkId]
    )
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC GolfDW.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC GolfDW.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC GolfDW.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    -- Post processing after the merge ---------------
        -- post processing can be put here
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
IF Object_ID('dbo.lME_Measurement__PGA_Kaggle_Stats_Typed__Instance', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[lME_Measurement__PGA_Kaggle_Stats_Typed__Instance];
GO
--------------------------------------------------------------------------
-- Procedure: lME_Measurement__PGA_Kaggle_Stats_Typed__Instance
-- Source: PGA_Kaggle_Stats_Typed
-- Target: lME_Measurement ()
--
-- Map: ME_ID to ME_ID (as surrogate key)
-- Map: WorkId to Metadata_ME (as metadata)
-- 
-- Generated: Tue Mar 16 13:06:49 UTC+0100 2021 by eldle
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[lME_Measurement__PGA_Kaggle_Stats_Typed__Instance] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @deletes int;
DECLARE @actions TABLE (
    [action] char(1) not null
);
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Stats', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lME_Measurement__PGA_Kaggle_Stats_Typed__Instance',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC GolfDW.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'PGA_Kaggle_Stats_Typed', 
    @targetName = 'lME_Measurement', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Preparations before the merge -----------------
        -- preparations can be put here
        select distinct
            [Player Name], 
            [Statistic], 
            [Variable]
        into
            #key
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed;
        create unique clustered index pk_key on #key (
            [Player Name], 
            [Statistic], 
            [Variable]
        ); 
        select
            mest.[ME_ID_for] as ME_ID,
            k.*
        into
            #known
        from 
            #key k
        join
            GolfDW.dbo.lPL_Player lPL
        on
            lPL.[PL_NAM_Player_Name] = k.[Player Name]
        join 
            GolfDW.dbo.lST_Statistic lST
        on
            lST.[ST_GRP_SGR_StatisticGroup] = k.[Statistic]
        and 
            lST.[ST_DET_Statistic_Detail] = k.[Variable]
        join
            GolfDW.dbo.[lPL_was_ME_measured] plme
        on
            plme.[PL_ID_was] = lPL.PL_ID
        join
            GolfDW.dbo.[lME_for_ST_the] mest
        on 
            mest.[ST_ID_the] = lST.ST_ID
        where
            mest.[ME_ID_for] = plme.[ME_ID_measured];
        create unique clustered index pk_known on #known (ME_ID);
    -- Perform the actual merge ----------------------
    MERGE INTO [GolfDW].[dbo].[lME_Measurement] AS [target]
    USING (
        select
            kn.ME_ID, -- always null
            @WorkId as WorkId
        from 
            #key k
        left join
            #known kn
        on
            kn.[Player Name] = k.[Player Name]
        and
            kn.[Statistic] = k.[Statistic]
        and
            kn.[Variable] = k.[Variable]
        where
            kn.ME_ID is null
    ) AS [source]
    ON (
        [source].[ME_ID] = [target].[ME_ID]
    )
    WHEN NOT MATCHED THEN INSERT (
        [Metadata_ME]
    )
    VALUES (
        [source].[WorkId]
    )
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC GolfDW.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC GolfDW.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC GolfDW.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    -- Post processing after the merge ---------------
        -- post processing can be put here
        select
            lME.ME_ID, 
            row_number() over (order by lME.ME_ID) as R
        into
            #created
        from
            GolfDW.dbo.lME_Measurement lME
        where
            lME.Metadata_ME = @WorkId;
        select
            c.ME_ID,
            k.[Player Name], 
            k.[Statistic], 
            k.[Variable]
        into
            #new
        from (
            select 
                *,
                row_number() over (order by 
                    [Player Name], 
                    [Statistic], 
                    [Variable]
                ) as R
            from
                #key 
        ) k
        join
            #created c
        on 
            c.R = k.R;
        insert into GolfDW.dbo.[lPL_was_ME_measured](
            [Metadata_PL_was_ME_measured], 
            [PL_ID_was], 
            [ME_ID_measured]
        )
        select
            @WorkId,
            lPL.PL_ID,
            n.ME_ID
        from
            #new n
        join
            GolfDW.dbo.lPL_Player lPL
        on
            lPL.[PL_NAM_Player_Name] = n.[Player Name];
        insert into GolfDW.dbo.[lME_for_ST_the](
            [Metadata_ME_for_ST_the], 
            [ME_ID_for], 
            [ST_ID_the]
        )
        select
            @WorkId,
            n.ME_ID,
            lST.ST_ID
        from
            #new n
        join
            GolfDW.dbo.lST_Statistic lST
        on
            lST.[ST_GRP_SGR_StatisticGroup] = n.[Statistic]
        and 
            lST.[ST_DET_Statistic_Detail] = n.[Variable]; 
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
IF Object_ID('dbo.lME_Measurement__PGA_Kaggle_Stats_Typed__Value', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[lME_Measurement__PGA_Kaggle_Stats_Typed__Value];
GO
--------------------------------------------------------------------------
-- Procedure: lME_Measurement__PGA_Kaggle_Stats_Typed__Value
-- Source: PGA_Kaggle_Stats_Typed
-- Target: lME_Measurement ()
--
-- Map: ME_ID to ME_ID (as surrogate key)
-- Map: Value to ME_VAL_Measurement_Value 
-- Map: Date to ME_VAL_ChangedAt (as history)
-- Map: WorkId to Metadata_ME (as metadata)
-- 
-- Generated: Tue Mar 16 13:06:49 UTC+0100 2021 by eldle
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[lME_Measurement__PGA_Kaggle_Stats_Typed__Value] (
    @agentJobId uniqueidentifier = null,
    @agentStepId smallint = null
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @inserts int;
DECLARE @updates int;
DECLARE @deletes int;
DECLARE @actions TABLE (
    [action] char(1) not null
);
DECLARE @workId int;
DECLARE @operationsId int;
DECLARE @theErrorLine int;
DECLARE @theErrorMessage varchar(555);
DECLARE @theErrorSeverity int;
DECLARE @theErrorState int;
EXEC GolfDW.metadata._WorkStarting
    @configurationName = 'Stats', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lME_Measurement__PGA_Kaggle_Stats_Typed__Value',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC GolfDW.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'PGA_Kaggle_Stats_Typed', 
    @targetName = 'lME_Measurement', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Preparations before the merge -----------------
        -- preparations can be put here
    -- Perform the actual merge ----------------------
    MERGE INTO [GolfDW].[dbo].[lME_Measurement] AS [target]
    USING (
        select
            mest.[ME_ID_for] as ME_ID,
            src.[Date],
            src.[Value], 
            @WorkId as WorkId
        from
            GolfStage.dbo.PGA_Kaggle_Stats_Typed src
        join
            GolfDW.dbo.lPL_Player lPL
        on
            lPL.[PL_NAM_Player_Name] = src.[Player Name]
        join 
            GolfDW.dbo.lST_Statistic lST
        on
            lST.[ST_GRP_SGR_StatisticGroup] = src.[Statistic]
        and 
            lST.[ST_DET_Statistic_Detail] = src.[Variable]
        join
            GolfDW.dbo.[lPL_was_ME_measured] plme
        on
            plme.[PL_ID_was] = lPL.PL_ID
        join
            GolfDW.dbo.[lME_for_ST_the] mest
        on 
            mest.[ST_ID_the] = lST.ST_ID
        where
            mest.[ME_ID_for] = plme.[ME_ID_measured]
    ) AS [source]
    ON (
        [source].[ME_ID] = [target].[ME_ID]
    )
    WHEN NOT MATCHED THEN INSERT (
        [ME_VAL_Measurement_Value],
        [ME_VAL_ChangedAt],
        [Metadata_ME]
    )
    VALUES (
        [source].[Value],
        [source].[Date],
        [source].[WorkId]
    )
    WHEN MATCHED AND (
        ([target].[ME_VAL_Measurement_Value] is null OR [source].[Value] <> [target].[ME_VAL_Measurement_Value])
    ) 
    THEN UPDATE
    SET
        [target].[ME_VAL_Measurement_Value] = [source].[Value],
        [target].[ME_VAL_ChangedAt] = [source].[Date],
        [target].[Metadata_ME] = [source].[WorkId]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC GolfDW.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC GolfDW.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC GolfDW.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    -- Post processing after the merge ---------------
        -- post processing can be put here
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
-- The target definition used when generating the above
DECLARE @xml XML = N'<target name="Stats" database="GolfDW">
	<load source="PGA_Kaggle_Stats_Typed" target="lPL_Player">
		<sql position="before">
        -- preparations can be put here
        </sql>
        select distinct 
            [Player Name], 
            ''1972-08-20'' as [Birth Date],
            @WorkID as WorkId 
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed
        <map source="Player Name" target="PL_NAM_Player_Name" as="natural key"/>
		<map source="Birth Date" target="PL_BID_Player_BirthDate" as="static"/>
		<map source="WorkId" target="Metadata_PL" as="metadata"/>
		<sql position="after">
        -- post processing can be put here
        </sql>
	</load>
	<load source="PGA_Kaggle_Stats_Typed" target="SGR_StatisticGroup">
		<sql position="before">
        -- preparations can be put here
        </sql>
        select distinct 
            [Statistic], 
            @WorkID as WorkId 
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed
        <map source="Statistic" target="SGR_StatisticGroup" as="natural key"/>
		<map source="WorkId" target="Metadata_SGR" as="metadata"/>
		<sql position="after">
        -- post processing can be put here
        </sql>
	</load>
	<load source="PGA_Kaggle_Stats_Typed" target="lST_Statistic">
		<sql position="before">
        -- preparations can be put here
        </sql>
        select distinct 
            [Statistic], 
            [Variable], 
            @WorkID as WorkId 
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed
        <map source="Statistic" target="ST_GRP_SGR_StatisticGroup" as="natural key"/>
		<map source="Variable" target="ST_DET_Statistic_Detail" as="natural key"/>
		<map source="WorkId" target="Metadata_ST" as="metadata"/>
		<sql position="after">
        -- post processing can be put here
        </sql>
	</load>
	<load source="PGA_Kaggle_Stats_Typed" target="lME_Measurement" pass="Instance">
		<sql position="before">
        -- preparations can be put here
        select distinct
            [Player Name], 
            [Statistic], 
            [Variable]
        into
            #key
        from 
            GolfStage.dbo.PGA_Kaggle_Stats_Typed;
        create unique clustered index pk_key on #key (
            [Player Name], 
            [Statistic], 
            [Variable]
        ); 
        select
            mest.[ME_ID_for] as ME_ID,
            k.*
        into
            #known
        from 
            #key k
        join
            GolfDW.dbo.lPL_Player lPL
        on
            lPL.[PL_NAM_Player_Name] = k.[Player Name]
        join 
            GolfDW.dbo.lST_Statistic lST
        on
            lST.[ST_GRP_SGR_StatisticGroup] = k.[Statistic]
        and 
            lST.[ST_DET_Statistic_Detail] = k.[Variable]
        join
            GolfDW.dbo.[lPL_was_ME_measured] plme
        on
            plme.[PL_ID_was] = lPL.PL_ID
        join
            GolfDW.dbo.[lME_for_ST_the] mest
        on 
            mest.[ST_ID_the] = lST.ST_ID
        where
            mest.[ME_ID_for] = plme.[ME_ID_measured];
        create unique clustered index pk_known on #known (ME_ID);
        </sql>
        select
            kn.ME_ID, -- always null
            @WorkId as WorkId
        from 
            #key k
        left join
            #known kn
        on
            kn.[Player Name] = k.[Player Name]
        and
            kn.[Statistic] = k.[Statistic]
        and
            kn.[Variable] = k.[Variable]
        where
            kn.ME_ID is null
        <map source="ME_ID" target="ME_ID" as="surrogate key"/>
		<map source="WorkId" target="Metadata_ME" as="metadata"/>
		<sql position="after">
        -- post processing can be put here
        select
            lME.ME_ID, 
            row_number() over (order by lME.ME_ID) as R
        into
            #created
        from
            GolfDW.dbo.lME_Measurement lME
        where
            lME.Metadata_ME = @WorkId;
        select
            c.ME_ID,
            k.[Player Name], 
            k.[Statistic], 
            k.[Variable]
        into
            #new
        from (
            select 
                *,
                row_number() over (order by 
                    [Player Name], 
                    [Statistic], 
                    [Variable]
                ) as R
            from
                #key 
        ) k
        join
            #created c
        on 
            c.R = k.R;
        insert into GolfDW.dbo.[lPL_was_ME_measured](
            [Metadata_PL_was_ME_measured], 
            [PL_ID_was], 
            [ME_ID_measured]
        )
        select
            @WorkId,
            lPL.PL_ID,
            n.ME_ID
        from
            #new n
        join
            GolfDW.dbo.lPL_Player lPL
        on
            lPL.[PL_NAM_Player_Name] = n.[Player Name];
        insert into GolfDW.dbo.[lME_for_ST_the](
            [Metadata_ME_for_ST_the], 
            [ME_ID_for], 
            [ST_ID_the]
        )
        select
            @WorkId,
            n.ME_ID,
            lST.ST_ID
        from
            #new n
        join
            GolfDW.dbo.lST_Statistic lST
        on
            lST.[ST_GRP_SGR_StatisticGroup] = n.[Statistic]
        and 
            lST.[ST_DET_Statistic_Detail] = n.[Variable]; 
        </sql>
	</load>
	<load source="PGA_Kaggle_Stats_Typed" target="lME_Measurement" pass="Value">
		<sql position="before">
        -- preparations can be put here
        </sql>
        select
            mest.[ME_ID_for] as ME_ID,
            src.[Date],
            src.[Value], 
            @WorkId as WorkId
        from
            GolfStage.dbo.PGA_Kaggle_Stats_Typed src
        join
            GolfDW.dbo.lPL_Player lPL
        on
            lPL.[PL_NAM_Player_Name] = src.[Player Name]
        join 
            GolfDW.dbo.lST_Statistic lST
        on
            lST.[ST_GRP_SGR_StatisticGroup] = src.[Statistic]
        and 
            lST.[ST_DET_Statistic_Detail] = src.[Variable]
        join
            GolfDW.dbo.[lPL_was_ME_measured] plme
        on
            plme.[PL_ID_was] = lPL.PL_ID
        join
            GolfDW.dbo.[lME_for_ST_the] mest
        on 
            mest.[ST_ID_the] = lST.ST_ID
        where
            mest.[ME_ID_for] = plme.[ME_ID_measured]
        <map source="ME_ID" target="ME_ID" as="surrogate key"/>
		<map source="Value" target="ME_VAL_Measurement_Value"/>
		<map source="Date" target="ME_VAL_ChangedAt" as="history"/>
		<map source="WorkId" target="Metadata_ME" as="metadata"/>
		<sql position="after">
        -- post processing can be put here
        </sql>
	</load>
</target>
';
DECLARE @name varchar(255) = @xml.value('/target[1]/@name', 'varchar(255)');
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
        'Target',
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
