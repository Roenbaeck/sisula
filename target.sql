USE Stage;
GO
IF Object_ID('lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed];
GO
CREATE PROCEDURE [lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed] 
AS
BEGIN
    SET NOCOUNT ON;
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
        t.[Metadata_MM_taken_OC_on] = s.[_file];
END
GO
IF Object_ID('lMM_Measurement__SMHI_Weather_Temperature_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_Measurement__SMHI_Weather_Temperature_Typed];
GO
CREATE PROCEDURE [lMM_Measurement__SMHI_Weather_Temperature_Typed] 
AS
BEGIN
    SET NOCOUNT ON;
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
        t.[Metadata_MM] = s.[_file];
END
GO
IF Object_ID('lMM_Measurement__SMHI_Weather_Pressure_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_Measurement__SMHI_Weather_Pressure_Typed];
GO
CREATE PROCEDURE [lMM_Measurement__SMHI_Weather_Pressure_Typed] 
AS
BEGIN
    SET NOCOUNT ON;
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
        t.[Metadata_MM] = s.[_file];
END
GO
IF Object_ID('lMM_Measurement__SMHI_Weather_Wind_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_Measurement__SMHI_Weather_Wind_Typed];
GO
CREATE PROCEDURE [lMM_Measurement__SMHI_Weather_Wind_Typed] 
AS
BEGIN
    SET NOCOUNT ON;
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
        t.[Metadata_MM] = s.[_file];
END
GO
IF Object_ID('lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed];
GO
CREATE PROCEDURE [lOC_Occasion__SMHI_Weather_TemperatureNewMetadata_Typed] 
AS
BEGIN
    SET NOCOUNT ON;
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
    );
END
GO
IF Object_ID('lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed', 'P') IS NOT NULL
DROP PROCEDURE [lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed];
GO
CREATE PROCEDURE [lMM_taken_OC_on__SMHI_Weather_TemperatureNew_Typed] 
AS
BEGIN
    SET NOCOUNT ON;
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
        t.[Metadata_MM_taken_OC_on] = s.[_file];
END
GO
