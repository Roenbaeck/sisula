USE Stage;
GO
IF Object_ID('etl.lST_Street__NYPD_Vehicle_Collision_Typed', 'P') IS NOT NULL
DROP PROCEDURE [etl].[lST_Street__NYPD_Vehicle_Collision_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lST_Street__NYPD_Vehicle_Collision_Typed
-- Source: NYPD_Vehicle_Collision_Typed
-- Target: lST_Street
--
-- Map: StreetName to ST_NAM_Street_Name (as natural key)
-- Map: metadata_CO_ID to Metadata_ST (as metadata)
--
-- Generated: Fri May 5 08:37:09 UTC+0200 2017 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [etl].[lST_Street__NYPD_Vehicle_Collision_Typed] (
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
EXEC Traffic.metadata._WorkStarting
    @configurationName = 'Traffic', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lST_Street__NYPD_Vehicle_Collision_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Traffic.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'NYPD_Vehicle_Collision_Typed', 
    @targetName = 'lST_Street', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Preparations before the merge -----------------
        -- preparations can be put here
    -- Perform the actual merge ----------------------
    MERGE INTO [Traffic].[dbo].[lST_Street] AS [target]
    USING (
        select
            StreetName, 
            min(metadata_CO_ID) as metadata_CO_ID
        from (
            select distinct
                IntersectingStreet as StreetName,
                metadata_CO_ID
            from 
                etl.NYPD_Vehicle_Collision_Typed
            union 
            select distinct
                CrossStreet as StreetName,
                metadata_CO_ID
            from
                etl.NYPD_Vehicle_Collision_Typed
        ) s
        group by
            StreetName
    ) AS [source]
    ON (
        [source].[StreetName] = [target].[ST_NAM_Street_Name]
    AND (
            [target].ST_NAM_Street_Name != 'TESTING CONDITIONS'
        )
    )
    WHEN NOT MATCHED THEN INSERT (
        [ST_NAM_Street_Name],
        [Metadata_ST]
    )
    VALUES (
        [source].[StreetName],
        [source].[metadata_CO_ID]
    )
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC Traffic.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC Traffic.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC Traffic.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    -- Post processing after the merge ---------------
        -- post processing can be put here
    EXEC Traffic.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC Traffic.metadata._WorkStopping
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
IF Object_ID('etl.lIS_Intersection__NYPD_Vehicle_Collision_Typed__1', 'P') IS NOT NULL
DROP PROCEDURE [etl].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__1];
GO
--------------------------------------------------------------------------
-- Procedure: lIS_Intersection__NYPD_Vehicle_Collision_Typed__1
-- Source: NYPD_Vehicle_Collision_Typed
-- Target: lIS_Intersection
--
-- Map: IS_ID_of to IS_ID (as surrogate key)
-- Map: metadata_CO_ID to Metadata_IS (as metadata)
--
-- Generated: Fri May 5 08:37:09 UTC+0200 2017 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [etl].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__1] (
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
EXEC Traffic.metadata._WorkStarting
    @configurationName = 'Traffic', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lIS_Intersection__NYPD_Vehicle_Collision_Typed__1',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Traffic.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'NYPD_Vehicle_Collision_Typed', 
    @targetName = 'lIS_Intersection', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Perform the actual merge ----------------------
    MERGE INTO [Traffic].[dbo].[lIS_Intersection] AS [target]
    USING (
        select 
            src.IntersectingStreet,
            src.CrossStreet,
            src.metadata_CO_ID,
            stst.IS_ID_of
        from (
            select 
                IntersectingStreet,
                CrossStreet,
                min(metadata_CO_ID) as metadata_CO_ID
            from
                etl.NYPD_Vehicle_Collision_Typed 
            group by
                IntersectingStreet,
                CrossStreet 
        ) src
        left join
            [Traffic].dbo.lST_Street st_i
        on
            st_i.ST_NAM_Street_Name = src.IntersectingStreet
        left join
            [Traffic].dbo.lST_Street st_c
        on
            st_c.ST_NAM_Street_Name = src.CrossStreet
        left join
            [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
        on
            stst.ST_ID_intersecting = st_i.ST_ID
        and
            stst.ST_ID_crossing = st_c.ST_ID 
    ) AS [source]
    ON (
        [source].[IS_ID_of] = [target].[IS_ID]
    )
    WHEN NOT MATCHED THEN INSERT (
        [Metadata_IS]
    )
    VALUES (
        [source].[metadata_CO_ID]
    )
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC Traffic.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC Traffic.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC Traffic.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC Traffic.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC Traffic.metadata._WorkStopping
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
IF Object_ID('etl.lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed', 'P') IS NOT NULL
DROP PROCEDURE [etl].[lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed
-- Source: NYPD_Vehicle_Collision_Typed
-- Target: lST_intersecting_IS_of_ST_crossing
--
-- Map: ST_ID_intersecting to ST_ID_intersecting (as natural key)
-- Map: ST_ID_crossing to ST_ID_crossing (as natural key)
-- Map: IS_ID_of to IS_ID_of 
-- Map: metadata_CO_ID to Metadata_ST_intersecting_IS_of_ST_crossing (as metadata)
--
-- Generated: Fri May 5 08:37:09 UTC+0200 2017 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [etl].[lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed] (
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
EXEC Traffic.metadata._WorkStarting
    @configurationName = 'Traffic', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lST_intersecting_IS_of_ST_crossing__NYPD_Vehicle_Collision_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Traffic.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'NYPD_Vehicle_Collision_Typed', 
    @targetName = 'lST_intersecting_IS_of_ST_crossing', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Perform the actual merge ----------------------
    MERGE INTO [Traffic].[dbo].[lST_intersecting_IS_of_ST_crossing] AS [target]
    USING (
        select
            i.IS_ID_of,
            t.ST_ID_intersecting,
            t.ST_ID_crossing,
            t.metadata_CO_ID
        from (
            select
                i.IS_ID as IS_ID_of,
                row_number() over (order by i.IS_ID) as _rowId
            from
                [Traffic].dbo.lIS_Intersection i
            left join
                [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
            on
                stst.IS_ID_of = i.IS_ID
        ) i
        join (
            select 
                src.metadata_CO_ID,
                st_i.ST_ID as ST_ID_intersecting,
                st_c.ST_ID as ST_ID_crossing,
                row_number() over (order by st_i.ST_ID, st_c.ST_ID) as _rowId
            from (
                select 
                    IntersectingStreet,
                    CrossStreet,
                    min(metadata_CO_ID) as metadata_CO_ID
                from
                    etl.NYPD_Vehicle_Collision_Typed 
                group by
                    IntersectingStreet,
                    CrossStreet 
            ) src
            left join
                [Traffic].dbo.lST_Street st_i
            on
                st_i.ST_NAM_Street_Name = src.IntersectingStreet
            left join
                [Traffic].dbo.lST_Street st_c
            on
                st_c.ST_NAM_Street_Name = src.CrossStreet
            left join
                [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
            on
                stst.ST_ID_intersecting = st_i.ST_ID
            and
                stst.ST_ID_crossing = st_c.ST_ID 
            where
                stst.IS_ID_of is null
        ) t
        on
            t._rowId = i._rowId
    ) AS [source]
    ON (
        [source].[ST_ID_intersecting] = [target].[ST_ID_intersecting]
    AND
        [source].[ST_ID_crossing] = [target].[ST_ID_crossing]
    )
    WHEN NOT MATCHED THEN INSERT (
        [ST_ID_intersecting],
        [ST_ID_crossing],
        [IS_ID_of],
        [Metadata_ST_intersecting_IS_of_ST_crossing]
    )
    VALUES (
        [source].[ST_ID_intersecting],
        [source].[ST_ID_crossing],
        [source].[IS_ID_of],
        [source].[metadata_CO_ID]
    )
    WHEN MATCHED AND (
        ([target].[IS_ID_of] is null OR [source].[IS_ID_of] <> [target].[IS_ID_of])
    ) 
    THEN UPDATE
    SET
        [target].[IS_ID_of] = [source].[IS_ID_of],
        [target].[Metadata_ST_intersecting_IS_of_ST_crossing] = [source].[metadata_CO_ID]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC Traffic.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC Traffic.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC Traffic.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC Traffic.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC Traffic.metadata._WorkStopping
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
IF Object_ID('etl.lIS_Intersection__NYPD_Vehicle_Collision_Typed__2', 'P') IS NOT NULL
DROP PROCEDURE [etl].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__2];
GO
--------------------------------------------------------------------------
-- Procedure: lIS_Intersection__NYPD_Vehicle_Collision_Typed__2
-- Source: NYPD_Vehicle_Collision_Typed
-- Target: lIS_Intersection
--
-- Map: IS_ID_of to IS_ID (as surrogate key)
-- Map: CollisionCount to IS_COL_Intersection_CollisionCount 
-- Map: ChangedAt to IS_COL_ChangedAt 
-- Map: CollisionVehicleCount to IS_VEH_Intersection_VehicleCount 
-- Map: ChangedAt to IS_VEH_ChangedAt 
-- Map: CollisionInjuredCount to IS_INJ_Intersection_InjuredCount 
-- Map: ChangedAt to IS_INJ_ChangedAt 
-- Map: CollisionKilledCount to IS_KIL_Intersection_KilledCount 
-- Map: ChangedAt to IS_KIL_ChangedAt 
--
-- Generated: Fri May 5 08:37:09 UTC+0200 2017 by e-lronnback
-- From: TSE-9B50TY1 in the CORPNET domain
--------------------------------------------------------------------------
CREATE PROCEDURE [etl].[lIS_Intersection__NYPD_Vehicle_Collision_Typed__2] (
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
EXEC Traffic.metadata._WorkStarting
    @configurationName = 'Traffic', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lIS_Intersection__NYPD_Vehicle_Collision_Typed__2',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Traffic.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'NYPD_Vehicle_Collision_Typed', 
    @targetName = 'lIS_Intersection', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    -- Perform the actual merge ----------------------
    MERGE INTO [Traffic].[dbo].[lIS_Intersection] AS [target]
    USING (
        select
            md.ChangedAt,
            stst.IS_ID_of,
            count(*) as CollisionCount,
            sum(src.CollisionVehicleCount) as CollisionVehicleCount,
            sum(src.CollisionInjuredCount) as CollisionInjuredCount,
            sum(src.CollisionKilledCount) as CollisionKilledCount
        from
            etl.NYPD_Vehicle_Collision_Typed src
        join
            etl.NYPD_Vehicle_CollisionMetadata_Typed md
        on
            md.metadata_CO_ID = src.metadata_CO_ID
        join
            [Traffic].dbo.lST_Street st_i
        on
            st_i.ST_NAM_Street_Name = src.IntersectingStreet
        join
            [Traffic].dbo.lST_Street st_c
        on
            st_c.ST_NAM_Street_Name = src.CrossStreet
        join
            [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
        on
            stst.ST_ID_intersecting = st_i.ST_ID
        and
            stst.ST_ID_crossing = st_c.ST_ID
        group by
            md.ChangedAt,
            stst.IS_ID_of
    ) AS [source]
    ON (
        [source].[IS_ID_of] = [target].[IS_ID]
    )
    WHEN NOT MATCHED THEN INSERT (
        [IS_COL_Intersection_CollisionCount],
        [IS_COL_ChangedAt],
        [IS_VEH_Intersection_VehicleCount],
        [IS_VEH_ChangedAt],
        [IS_INJ_Intersection_InjuredCount],
        [IS_INJ_ChangedAt],
        [IS_KIL_Intersection_KilledCount],
        [IS_KIL_ChangedAt]
    )
    VALUES (
        [source].[CollisionCount],
        [source].[ChangedAt],
        [source].[CollisionVehicleCount],
        [source].[ChangedAt],
        [source].[CollisionInjuredCount],
        [source].[ChangedAt],
        [source].[CollisionKilledCount],
        [source].[ChangedAt]
    )
    WHEN MATCHED AND (
        ([target].[IS_COL_Intersection_CollisionCount] is null OR [source].[CollisionCount] <> [target].[IS_COL_Intersection_CollisionCount])
    OR 
        ([target].[IS_COL_ChangedAt] is null OR [source].[ChangedAt] <> [target].[IS_COL_ChangedAt])
    OR 
        ([target].[IS_VEH_Intersection_VehicleCount] is null OR [source].[CollisionVehicleCount] <> [target].[IS_VEH_Intersection_VehicleCount])
    OR 
        ([target].[IS_VEH_ChangedAt] is null OR [source].[ChangedAt] <> [target].[IS_VEH_ChangedAt])
    OR 
        ([target].[IS_INJ_Intersection_InjuredCount] is null OR [source].[CollisionInjuredCount] <> [target].[IS_INJ_Intersection_InjuredCount])
    OR 
        ([target].[IS_INJ_ChangedAt] is null OR [source].[ChangedAt] <> [target].[IS_INJ_ChangedAt])
    OR 
        ([target].[IS_KIL_Intersection_KilledCount] is null OR [source].[CollisionKilledCount] <> [target].[IS_KIL_Intersection_KilledCount])
    OR 
        ([target].[IS_KIL_ChangedAt] is null OR [source].[ChangedAt] <> [target].[IS_KIL_ChangedAt])
    ) 
    THEN UPDATE
    SET
        [target].[IS_COL_Intersection_CollisionCount] = [source].[CollisionCount],
        [target].[IS_COL_ChangedAt] = [source].[ChangedAt],
        [target].[IS_VEH_Intersection_VehicleCount] = [source].[CollisionVehicleCount],
        [target].[IS_VEH_ChangedAt] = [source].[ChangedAt],
        [target].[IS_INJ_Intersection_InjuredCount] = [source].[CollisionInjuredCount],
        [target].[IS_INJ_ChangedAt] = [source].[ChangedAt],
        [target].[IS_KIL_Intersection_KilledCount] = [source].[CollisionKilledCount],
        [target].[IS_KIL_ChangedAt] = [source].[ChangedAt]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC Traffic.metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC Traffic.metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC Traffic.metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC Traffic.metadata._WorkStopping @workId, 'Success';
END TRY
BEGIN CATCH
	SELECT
		@theErrorLine = ERROR_LINE(),
		@theErrorMessage = ERROR_MESSAGE(),
        @theErrorSeverity = ERROR_SEVERITY(),
        @theErrorState = ERROR_STATE();
    EXEC Traffic.metadata._WorkStopping
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
DECLARE @xml XML = N'<target name="Traffic" database="Traffic">
	<load source="NYPD_Vehicle_Collision_Typed" target="lST_Street">
		<sql position="before">
        -- preparations can be put here
        </sql>
        select
            StreetName, 
            min(metadata_CO_ID) as metadata_CO_ID
        from (
            select distinct
                IntersectingStreet as StreetName,
                metadata_CO_ID
            from 
                etl.NYPD_Vehicle_Collision_Typed
            union 
            select distinct
                CrossStreet as StreetName,
                metadata_CO_ID
            from
                etl.NYPD_Vehicle_Collision_Typed
        ) s
        group by
            StreetName
        <map source="StreetName" target="ST_NAM_Street_Name" as="natural key"/>
		<map source="metadata_CO_ID" target="Metadata_ST" as="metadata"/>
		<condition>
            [target].ST_NAM_Street_Name != ''TESTING CONDITIONS''
        </condition>
		<sql position="after">
        -- post processing can be put here
        </sql>
	</load>
	<load source="NYPD_Vehicle_Collision_Typed" target="lIS_Intersection" pass="1">
        select 
            src.IntersectingStreet,
            src.CrossStreet,
            src.metadata_CO_ID,
            stst.IS_ID_of
        from (
            select 
                IntersectingStreet,
                CrossStreet,
                min(metadata_CO_ID) as metadata_CO_ID
            from
                etl.NYPD_Vehicle_Collision_Typed 
            group by
                IntersectingStreet,
                CrossStreet 
        ) src
        left join
            [Traffic].dbo.lST_Street st_i
        on
            st_i.ST_NAM_Street_Name = src.IntersectingStreet
        left join
            [Traffic].dbo.lST_Street st_c
        on
            st_c.ST_NAM_Street_Name = src.CrossStreet
        left join
            [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
        on
            stst.ST_ID_intersecting = st_i.ST_ID
        and
            stst.ST_ID_crossing = st_c.ST_ID 
        <map source="IS_ID_of" target="IS_ID" as="surrogate key"/>
		<map source="metadata_CO_ID" target="Metadata_IS" as="metadata"/>
	</load>
	<load source="NYPD_Vehicle_Collision_Typed" target="lST_intersecting_IS_of_ST_crossing">
        select
            i.IS_ID_of,
            t.ST_ID_intersecting,
            t.ST_ID_crossing,
            t.metadata_CO_ID
        from (
            select
                i.IS_ID as IS_ID_of,
                row_number() over (order by i.IS_ID) as _rowId
            from
                [Traffic].dbo.lIS_Intersection i
            left join
                [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
            on
                stst.IS_ID_of = i.IS_ID
        ) i
        join (
            select 
                src.metadata_CO_ID,
                st_i.ST_ID as ST_ID_intersecting,
                st_c.ST_ID as ST_ID_crossing,
                row_number() over (order by st_i.ST_ID, st_c.ST_ID) as _rowId
            from (
                select 
                    IntersectingStreet,
                    CrossStreet,
                    min(metadata_CO_ID) as metadata_CO_ID
                from
                    etl.NYPD_Vehicle_Collision_Typed 
                group by
                    IntersectingStreet,
                    CrossStreet 
            ) src
            left join
                [Traffic].dbo.lST_Street st_i
            on
                st_i.ST_NAM_Street_Name = src.IntersectingStreet
            left join
                [Traffic].dbo.lST_Street st_c
            on
                st_c.ST_NAM_Street_Name = src.CrossStreet
            left join
                [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
            on
                stst.ST_ID_intersecting = st_i.ST_ID
            and
                stst.ST_ID_crossing = st_c.ST_ID 
            where
                stst.IS_ID_of is null
        ) t
        on
            t._rowId = i._rowId
        <map source="ST_ID_intersecting" target="ST_ID_intersecting" as="natural key"/>
		<map source="ST_ID_crossing" target="ST_ID_crossing" as="natural key"/>
		<map source="IS_ID_of" target="IS_ID_of"/>
		<map source="metadata_CO_ID" target="Metadata_ST_intersecting_IS_of_ST_crossing" as="metadata"/>
	</load>
	<load source="NYPD_Vehicle_Collision_Typed" target="lIS_Intersection" pass="2">
        select
            md.ChangedAt,
            stst.IS_ID_of,
            count(*) as CollisionCount,
            sum(src.CollisionVehicleCount) as CollisionVehicleCount,
            sum(src.CollisionInjuredCount) as CollisionInjuredCount,
            sum(src.CollisionKilledCount) as CollisionKilledCount
        from
            etl.NYPD_Vehicle_Collision_Typed src
        join
            etl.NYPD_Vehicle_CollisionMetadata_Typed md
        on
            md.metadata_CO_ID = src.metadata_CO_ID
        join
            [Traffic].dbo.lST_Street st_i
        on
            st_i.ST_NAM_Street_Name = src.IntersectingStreet
        join
            [Traffic].dbo.lST_Street st_c
        on
            st_c.ST_NAM_Street_Name = src.CrossStreet
        join
            [Traffic].dbo.ST_intersecting_IS_of_ST_crossing stst
        on
            stst.ST_ID_intersecting = st_i.ST_ID
        and
            stst.ST_ID_crossing = st_c.ST_ID
        group by
            md.ChangedAt,
            stst.IS_ID_of
        <map source="IS_ID_of" target="IS_ID" as="surrogate key"/>
		<map source="CollisionCount" target="IS_COL_Intersection_CollisionCount"/>
		<map source="ChangedAt" target="IS_COL_ChangedAt"/>
		<map source="CollisionVehicleCount" target="IS_VEH_Intersection_VehicleCount"/>
		<map source="ChangedAt" target="IS_VEH_ChangedAt"/>
		<map source="CollisionInjuredCount" target="IS_INJ_Intersection_InjuredCount"/>
		<map source="ChangedAt" target="IS_INJ_ChangedAt"/>
		<map source="CollisionKilledCount" target="IS_KIL_Intersection_KilledCount"/>
		<map source="ChangedAt" target="IS_KIL_ChangedAt"/>
	</load>
</target>
';
DECLARE @name varchar(255) = @xml.value('/target[1]/@name', 'varchar(255)');
DECLARE @CF_ID int;
SELECT
    @CF_ID = CF_ID
FROM
    Traffic.metadata.lCF_Configuration
WHERE
    CF_NAM_Configuration_Name = @name;
IF(@CF_ID is null) 
BEGIN
    INSERT INTO Traffic.metadata.lCF_Configuration (
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
    UPDATE Traffic.metadata.lCF_Configuration
    SET
        CF_XML_Configuration_XMLDefinition = @xml
    WHERE
        CF_NAM_Configuration_Name = @name;
END
