USE Stage;
GO
IF Object_ID('lMM_Measurement__SMHI_Weather_TemperatureNew_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_Measurement__SMHI_Weather_TemperatureNew_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lMM_Measurement__SMHI_Weather_TemperatureNew_Typed
-- Source: SMHI_Weather_TemperatureNew_Typed
-- Target: lMM_Measurement
--
-- Map: date to MM_DAT_Measurement_Date (as natural key)
-- Map: hour to MM_HOU_Measurement_Hour (as natural key)
-- Map: temperature to MM_TMP_Measurement_Temperature 
-- Map: _file to Metadata_MM (as metadata)
--
-- Generated: Tue Oct 7 13:51:26 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [lMM_Measurement__SMHI_Weather_TemperatureNew_Typed] (
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
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Meteo', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lMM_Measurement__SMHI_Weather_TemperatureNew_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'SMHI_Weather_TemperatureNew_Typed', 
    @targetName = 'lMM_Measurement', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    MERGE INTO [Meteo]..[lMM_Measurement] AS t
    USING (
        select
            _id, 
            _file, 
            _timestamp, 
            [date],
            [hour], 
            [celsius1] as temperature
        from
            SMHI_Weather_TemperatureNew_Typed 
    ) AS s
    ON (
        s.[date] = t.[MM_DAT_Measurement_Date]
    AND
        s.[hour] = t.[MM_HOU_Measurement_Hour]
    )
    WHEN NOT MATCHED THEN INSERT (
        [MM_DAT_Measurement_Date],
        [MM_HOU_Measurement_Hour],
        [MM_TMP_Measurement_Temperature],
        [Metadata_MM]
    )
    VALUES (
        s.[date],
        s.[hour],
        s.[temperature],
        s.[_file]
    )
    WHEN MATCHED AND (
        (t.[MM_TMP_Measurement_Temperature] is null OR s.[temperature] <> t.[MM_TMP_Measurement_Temperature])
    ) 
    THEN UPDATE
    SET
        t.[MM_TMP_Measurement_Temperature] = s.[temperature],
        t.[Metadata_MM] = s.[_file]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC metadata._WorkStopping @workId, 'Success';
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
IF Object_ID('lMM_Measurement__SMHI_Weather_Temperature_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_Measurement__SMHI_Weather_Temperature_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lMM_Measurement__SMHI_Weather_Temperature_Typed
-- Source: SMHI_Weather_Temperature_Typed
-- Target: lMM_Measurement
--
-- Map: date to MM_DAT_Measurement_Date (as natural key)
-- Map: hour to MM_HOU_Measurement_Hour (as natural key)
-- Map: celsius to MM_TMP_Measurement_Temperature 
-- Map: _file to Metadata_MM (as metadata)
--
-- Generated: Tue Oct 7 13:51:26 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [lMM_Measurement__SMHI_Weather_Temperature_Typed] (
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
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Meteo', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lMM_Measurement__SMHI_Weather_Temperature_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'SMHI_Weather_Temperature_Typed', 
    @targetName = 'lMM_Measurement', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    MERGE INTO [Meteo]..[lMM_Measurement] AS t
    USING
        SMHI_Weather_Temperature_Typed AS s
    ON (
        s.[date] = t.[MM_DAT_Measurement_Date]
    AND
        s.[hour] = t.[MM_HOU_Measurement_Hour]
    )
    WHEN NOT MATCHED THEN INSERT (
        [MM_DAT_Measurement_Date],
        [MM_HOU_Measurement_Hour],
        [MM_TMP_Measurement_Temperature],
        [Metadata_MM]
    )
    VALUES (
        s.[date],
        s.[hour],
        s.[celsius],
        s.[_file]
    )
    WHEN MATCHED AND (
        (t.[MM_TMP_Measurement_Temperature] is null OR s.[celsius] <> t.[MM_TMP_Measurement_Temperature])
    ) 
    THEN UPDATE
    SET
        t.[MM_TMP_Measurement_Temperature] = s.[celsius],
        t.[Metadata_MM] = s.[_file]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC metadata._WorkStopping @workId, 'Success';
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
IF Object_ID('lMM_Measurement__SMHI_Weather_Pressure_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_Measurement__SMHI_Weather_Pressure_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lMM_Measurement__SMHI_Weather_Pressure_Typed
-- Source: SMHI_Weather_Pressure_Typed
-- Target: lMM_Measurement
--
-- Map: date to MM_DAT_Measurement_Date (as natural key)
-- Map: hour to MM_HOU_Measurement_Hour (as natural key)
-- Map: pressure to MM_PRS_Measurement_Pressure 
-- Map: _file to Metadata_MM (as metadata)
--
-- Generated: Tue Oct 7 13:51:26 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [lMM_Measurement__SMHI_Weather_Pressure_Typed] (
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
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Meteo', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lMM_Measurement__SMHI_Weather_Pressure_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'SMHI_Weather_Pressure_Typed', 
    @targetName = 'lMM_Measurement', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    MERGE INTO [Meteo]..[lMM_Measurement] AS t
    USING
        SMHI_Weather_Pressure_Typed AS s
    ON (
        s.[date] = t.[MM_DAT_Measurement_Date]
    AND
        s.[hour] = t.[MM_HOU_Measurement_Hour]
    )
    WHEN NOT MATCHED THEN INSERT (
        [MM_DAT_Measurement_Date],
        [MM_HOU_Measurement_Hour],
        [MM_PRS_Measurement_Pressure],
        [Metadata_MM]
    )
    VALUES (
        s.[date],
        s.[hour],
        s.[pressure],
        s.[_file]
    )
    WHEN MATCHED AND (
        (t.[MM_PRS_Measurement_Pressure] is null OR s.[pressure] <> t.[MM_PRS_Measurement_Pressure])
    ) 
    THEN UPDATE
    SET
        t.[MM_PRS_Measurement_Pressure] = s.[pressure],
        t.[Metadata_MM] = s.[_file]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC metadata._WorkStopping @workId, 'Success';
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
IF Object_ID('lMM_Measurement__SMHI_Weather_Wind_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_Measurement__SMHI_Weather_Wind_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lMM_Measurement__SMHI_Weather_Wind_Typed
-- Source: SMHI_Weather_Wind_Typed
-- Target: lMM_Measurement
--
-- Map: date to MM_DAT_Measurement_Date (as natural key)
-- Map: hour to MM_HOU_Measurement_Hour (as natural key)
-- Map: speed to MM_WND_Measurement_WindSpeed 
-- Map: direction to MM_DIR_Measurement_Direction 
-- Map: _file to Metadata_MM (as metadata)
--
-- Generated: Tue Oct 7 13:51:26 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [lMM_Measurement__SMHI_Weather_Wind_Typed] (
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
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Meteo', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lMM_Measurement__SMHI_Weather_Wind_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'SMHI_Weather_Wind_Typed', 
    @targetName = 'lMM_Measurement', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    MERGE INTO [Meteo]..[lMM_Measurement] AS t
    USING
        SMHI_Weather_Wind_Typed AS s
    ON (
        s.[date] = t.[MM_DAT_Measurement_Date]
    AND
        s.[hour] = t.[MM_HOU_Measurement_Hour]
    )
    WHEN NOT MATCHED THEN INSERT (
        [MM_DAT_Measurement_Date],
        [MM_HOU_Measurement_Hour],
        [MM_WND_Measurement_WindSpeed],
        [MM_DIR_Measurement_Direction],
        [Metadata_MM]
    )
    VALUES (
        s.[date],
        s.[hour],
        s.[speed],
        s.[direction],
        s.[_file]
    )
    WHEN MATCHED AND (
        (t.[MM_WND_Measurement_WindSpeed] is null OR s.[speed] <> t.[MM_WND_Measurement_WindSpeed])
    OR 
        (t.[MM_DIR_Measurement_Direction] is null OR s.[direction] <> t.[MM_DIR_Measurement_Direction])
    ) 
    THEN UPDATE
    SET
        t.[MM_WND_Measurement_WindSpeed] = s.[speed],
        t.[MM_DIR_Measurement_Direction] = s.[direction],
        t.[Metadata_MM] = s.[_file]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC metadata._WorkStopping @workId, 'Success';
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
IF Object_ID('lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed
-- Source: SMHI_Weather_TemperatureNewMetadata_Typed
-- Target: lOC_Occasion
--
-- Map: weekday to OC_WDY_Occasion_Weekday (as natural key)
-- Map: graphType to OC_TYP_Occasion_Type (as natural key)
-- Map: _file to Metadata_OC (as metadata)
--
-- Generated: Tue Oct 7 13:51:26 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed] (
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
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Meteo', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'SMHI_Weather_TemperatureNewMetadata_Typed', 
    @targetName = 'lOC_Occasion', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    MERGE INTO [Meteo]..[lOC_Occasion] AS t
    USING
        SMHI_Weather_TemperatureNewMetadata_Typed AS s
    ON (
        s.[weekday] = t.[OC_WDY_Occasion_Weekday]
    AND
        s.[graphType] = t.[OC_TYP_Occasion_Type]
    )
    WHEN NOT MATCHED THEN INSERT (
        [OC_WDY_Occasion_Weekday],
        [OC_TYP_Occasion_Type],
        [Metadata_OC]
    )
    VALUES (
        s.[weekday],
        s.[graphType],
        s.[_file]
    )
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC metadata._WorkStopping @workId, 'Success';
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
IF Object_ID('lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed];
GO
--------------------------------------------------------------------------
-- Procedure: lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed
-- Source: SMHI_Weather_TemperatureNew_Typed
-- Target: lMM_taken_OC_on
--
-- Map: MM_ID to MM_ID_taken (as natural key)
-- Map: OC_ID to OC_ID_on 
-- Map: _file to Metadata_MM_taken_OC_on (as metadata)
--
-- Generated: Tue Oct 7 13:51:26 UTC+0200 2014 by Lars
-- From: WARP in the WARP domain
--------------------------------------------------------------------------
CREATE PROCEDURE [lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed] (
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
EXEC Stage.metadata._WorkStarting
    @configurationName = 'Meteo', 
    @configurationType = 'Target', 
    @WO_ID = @workId OUTPUT, 
    @name = 'lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed',
    @agentStepId = @agentStepId,
    @agentJobId = @agentJobId
BEGIN TRY
EXEC Stage.metadata._WorkSourceToTarget
    @OP_ID = @operationsId OUTPUT,
    @WO_ID = @workId, 
    @sourceName = 'SMHI_Weather_TemperatureNew_Typed', 
    @targetName = 'lMM_taken_OC_on', 
    @sourceType = 'Table', 
    @targetType = 'Table', 
    @sourceCreated = DEFAULT,
    @targetCreated = DEFAULT;
    MERGE INTO [Meteo]..[lMM_taken_OC_on] AS t
    USING (
        select
            mm.MM_ID,
            oc.OC_ID,
            src._file
        from
            SMHI_Weather_TemperatureNew_Typed src
        join
            Meteo..lMM_Measurement mm
        on
            mm.MM_DAT_Measurement_Date = src.date
        and
            mm.MM_HOU_Measurement_Hour = src.hour
        join
            Meteo..lOC_Occasion oc 
        on 
            oc.Metadata_OC = src._file
    ) AS s
    ON (
        s.[MM_ID] = t.[MM_ID_taken]
    )
    WHEN NOT MATCHED THEN INSERT (
        [MM_ID_taken],
        [OC_ID_on],
        [Metadata_MM_taken_OC_on]
    )
    VALUES (
        s.[MM_ID],
        s.[OC_ID],
        s.[_file]
    )
    WHEN MATCHED AND (
        (t.[OC_ID_on] is null OR s.[OC_ID] <> t.[OC_ID_on])
    ) 
    THEN UPDATE
    SET
        t.[OC_ID_on] = s.[OC_ID],
        t.[Metadata_MM_taken_OC_on] = s.[_file]
    OUTPUT
        LEFT($action, 1) INTO @actions;
    SELECT
        @inserts = NULLIF(COUNT(CASE WHEN [action] = 'I' THEN 1 END), 0),
        @updates = NULLIF(COUNT(CASE WHEN [action] = 'U' THEN 1 END), 0),
        @deletes = NULLIF(COUNT(CASE WHEN [action] = 'D' THEN 1 END), 0)
    FROM
        @actions;
    EXEC metadata._WorkSetInserts @workId, @operationsId, @inserts;
    EXEC metadata._WorkSetUpdates @workId, @operationsId, @updates;
    EXEC metadata._WorkSetDeletes @workId, @operationsId, @deletes;
    EXEC metadata._WorkStopping @workId, 'Success';
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
-- The target definition used when generating the above
DECLARE @xml XML = N'<target name="Meteo" database="Meteo">
	<load source="SMHI_Weather_TemperatureNew_Typed" target="lMM_Measurement">
        select
            _id, 
            _file, 
            _timestamp, 
            [date],
            [hour], 
            [celsius1] as temperature
        from
            SMHI_Weather_TemperatureNew_Typed 
        <map source="date" target="MM_DAT_Measurement_Date" as="natural key"/>
		<map source="hour" target="MM_HOU_Measurement_Hour" as="natural key"/>
		<map source="temperature" target="MM_TMP_Measurement_Temperature"/>
		<map source="_file" target="Metadata_MM" as="metadata"/>
	</load>
	<load source="SMHI_Weather_Temperature_Typed" target="lMM_Measurement">
		<map source="date" target="MM_DAT_Measurement_Date" as="natural key"/>
		<map source="hour" target="MM_HOU_Measurement_Hour" as="natural key"/>
		<map source="celsius" target="MM_TMP_Measurement_Temperature"/>
		<map source="_file" target="Metadata_MM" as="metadata"/>
	</load>
	<load source="SMHI_Weather_Pressure_Typed" target="lMM_Measurement">
		<map source="date" target="MM_DAT_Measurement_Date" as="natural key"/>
		<map source="hour" target="MM_HOU_Measurement_Hour" as="natural key"/>
		<map source="pressure" target="MM_PRS_Measurement_Pressure"/>
		<map source="_file" target="Metadata_MM" as="metadata"/>
	</load>
	<load source="SMHI_Weather_Wind_Typed" target="lMM_Measurement">
		<map source="date" target="MM_DAT_Measurement_Date" as="natural key"/>
		<map source="hour" target="MM_HOU_Measurement_Hour" as="natural key"/>
		<map source="speed" target="MM_WND_Measurement_WindSpeed"/>
		<map source="direction" target="MM_DIR_Measurement_Direction"/>
		<map source="_file" target="Metadata_MM" as="metadata"/>
	</load>
	<load source="SMHI_Weather_TemperatureNewMetadata_Typed" target="lOC_Occasion">
		<map source="weekday" target="OC_WDY_Occasion_Weekday" as="natural key"/>
		<map source="graphType" target="OC_TYP_Occasion_Type" as="natural key"/>
		<map source="_file" target="Metadata_OC" as="metadata"/>
	</load>
	<load source="SMHI_Weather_TemperatureNew_Typed" target="lMM_taken_OC_on">
        select
            mm.MM_ID,
            oc.OC_ID,
            src._file
        from
            SMHI_Weather_TemperatureNew_Typed src
        join
            Meteo..lMM_Measurement mm
        on
            mm.MM_DAT_Measurement_Date = src.date
        and
            mm.MM_HOU_Measurement_Hour = src.hour
        join
            Meteo..lOC_Occasion oc 
        on 
            oc.Metadata_OC = src._file
        <map source="MM_ID" target="MM_ID_taken" as="natural key"/>
		<map source="OC_ID" target="OC_ID_on"/>
		<map source="_file" target="Metadata_MM_taken_OC_on" as="metadata"/>
	</load>
</target>
';
DECLARE @name varchar(255) = @xml.value('/target[1]/@name', 'varchar(255)');
DECLARE @CF_ID int;
SELECT
    @CF_ID = CF_ID
FROM
    metadata.lCF_Configuration
WHERE
    CF_NAM_Configuration_Name = @name;
IF(@CF_ID is null) 
BEGIN
    INSERT INTO metadata.lCF_Configuration (
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
    UPDATE metadata.lCF_Configuration
    SET
        CF_XML_Configuration_XMLDefinition = @xml
    WHERE
        CF_NAM_Configuration_Name = @name;
END
