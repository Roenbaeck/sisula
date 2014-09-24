USE Stage;
GO
IF Object_ID('MM_Measurement__SMHI_Weather_TemperatureNew_Typed', 'P') IS NOT NULL
DROP PROCEDURE [MM_Measurement__SMHI_Weather_TemperatureNew_Typed];
GO
CREATE PROCEDURE [MM_Measurement__SMHI_Weather_TemperatureNew_Typed] 
AS
BEGIN
    SET NOCOUNT ON;
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
        t.[Metadata_MM] = s.[_file];
END
GO
IF Object_ID('MM_Measurement__SMHI_Weather_Temperature_Typed', 'P') IS NOT NULL
DROP PROCEDURE [MM_Measurement__SMHI_Weather_Temperature_Typed];
GO
CREATE PROCEDURE [MM_Measurement__SMHI_Weather_Temperature_Typed] 
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
