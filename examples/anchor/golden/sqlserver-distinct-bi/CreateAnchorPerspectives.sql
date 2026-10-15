-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are five types of perspectives: time traveling, latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The time traveling perspective shows information as it was or will be based on a number
-- of input parameters.
--
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
--
-- The latest perspective shows the latest available (changing & positing) information for each anchor.
-- The now perspective shows the information as it is right now, with latest positing time.
-- The point-in-time perspective lets you travel through the information to the given timepoint,
-- with latest positing time and the given point in changing time.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes, with latest positing time.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.dPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[dPN_Person];
IF Object_ID('anchors.nPN_Person', 'V') IS NOT NULL
DROP VIEW [anchors].[nPN_Person];
IF Object_ID('anchors.pPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pPN_Person];
IF Object_ID('anchors.lPN_Person', 'V') IS NOT NULL
DROP VIEW [anchors].[lPN_Person];
IF Object_ID('anchors.tPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[tPN_Person];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.dST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[dST_Stage];
IF Object_ID('anchors.nST_Stage', 'V') IS NOT NULL
DROP VIEW [anchors].[nST_Stage];
IF Object_ID('anchors.pST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pST_Stage];
IF Object_ID('anchors.lST_Stage', 'V') IS NOT NULL
DROP VIEW [anchors].[lST_Stage];
IF Object_ID('anchors.tST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[tST_Stage];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tST_Stage viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[tST_Stage] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].ST_NAM_ST_ID,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ID,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_PositedAt,
    [NAM].ST_NAM_Reliability,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_ID,
    [LOC].ST_LOC_PositedAt,
    [LOC].ST_LOC_Reliability,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ID,
    [AVG].ST_AVG_ChangedAt,
    [AVG].ST_AVG_PositedAt,
    [AVG].ST_AVG_Reliability,
    [AVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [AVG].Metadata_UTL AS ST_AVG_Metadata_UTL,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [MIN].Metadata_ST_MIN,
    [MIN].ST_MIN_ID,
    [MIN].ST_MIN_PositedAt,
    [MIN].ST_MIN_Reliability,
    [MIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [MIN].Metadata_UTL AS ST_MIN_Metadata_UTL,
    [MIN].ST_MIN_UTL_ID
FROM
    [anchors].[ST_Stage] [ST]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].ST_NAM_ST_ID,
        [rNAM].Metadata_ST_NAM,
        [rNAM].ST_NAM_ID,
        [rNAM].ST_NAM_ChangedAt,
        [rNAM].ST_NAM_PositedAt,
        [rNAM].ST_NAM_Reliability,
        [rNAM].ST_NAM_Stage_Name
    FROM
        [attributes].[rST_NAM_Stage_Name](
            @changingTimepoint,
            @positingTimepoint
        ) [rNAM]
    WHERE
        [rNAM].ST_NAM_ST_ID = [ST].ST_ID
    AND
        [rNAM].ST_NAM_Reliability = 1
    ORDER BY
        [rNAM].ST_NAM_ChangedAt DESC,
        [rNAM].ST_NAM_PositedAt DESC
) [NAM]
OUTER APPLY (
    SELECT TOP 1
        [rLOC].ST_LOC_ST_ID,
        [rLOC].Metadata_ST_LOC,
        [rLOC].ST_LOC_ID,
        [rLOC].ST_LOC_PositedAt,
        [rLOC].ST_LOC_Reliability,
        [rLOC].ST_LOC_Checksum,
        [rLOC].ST_LOC_Stage_Location
    FROM
        [attributes].[rST_LOC_Stage_Location](
            @positingTimepoint
        ) [rLOC]
    WHERE
        [rLOC].ST_LOC_ST_ID = [ST].ST_ID
    AND
        [rLOC].ST_LOC_Reliability = 1
    ORDER BY
        [rLOC].ST_LOC_PositedAt DESC
) [LOC]
OUTER APPLY (
    SELECT TOP 1
        [rAVG].ST_AVG_ST_ID,
        [rAVG].Metadata_ST_AVG,
        [rAVG].ST_AVG_ID,
        [rAVG].ST_AVG_ChangedAt,
        [rAVG].ST_AVG_PositedAt,
        [rAVG].ST_AVG_Reliability,
        [kAVG].UTL_Utilization,
        [kAVG].Metadata_UTL,
        [rAVG].ST_AVG_UTL_ID
    FROM
        [attributes].[rST_AVG_Stage_Average](
            @changingTimepoint,
            @positingTimepoint
        ) [rAVG]
    JOIN
        [knots].[UTL_Utilization] [kAVG]
    ON
        [kAVG].UTL_ID = [rAVG].ST_AVG_UTL_ID
    WHERE
        [rAVG].ST_AVG_ST_ID = [ST].ST_ID
    AND
        [rAVG].ST_AVG_Reliability = 1
    ORDER BY
        [rAVG].ST_AVG_ChangedAt DESC,
        [rAVG].ST_AVG_PositedAt DESC
) [AVG]
OUTER APPLY (
    SELECT TOP 1
        [rMIN].ST_MIN_ST_ID,
        [rMIN].Metadata_ST_MIN,
        [rMIN].ST_MIN_ID,
        [rMIN].ST_MIN_PositedAt,
        [rMIN].ST_MIN_Reliability,
        [kMIN].UTL_Utilization,
        [kMIN].Metadata_UTL,
        [rMIN].ST_MIN_UTL_ID
    FROM
        [attributes].[rST_MIN_Stage_Minimum](
            @positingTimepoint
        ) [rMIN]
    JOIN
        [knots].[UTL_Utilization] [kMIN]
    ON
        [kMIN].UTL_ID = [rMIN].ST_MIN_UTL_ID
    WHERE
        [rMIN].ST_MIN_ST_ID = [ST].ST_ID
    AND
        [rMIN].ST_MIN_Reliability = 1
    ORDER BY
        [rMIN].ST_MIN_PositedAt DESC
) [MIN];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lST_Stage]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [anchors].[tST_Stage] (
        DEFAULT,
        DEFAULT
    ) [ST];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[pST_Stage] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [anchors].[tST_Stage] (
        @changingTimepoint,
        DEFAULT
    ) [ST];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nST_Stage]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [anchors].[tST_Stage] (
        sysdatetime(),
        DEFAULT
    ) [ST];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[dST_Stage] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [ST].*
FROM (
    SELECT DISTINCT
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [attributes].[ST_NAM_Stage_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_ST_ID AS ST_ID,
        ST_AVG_ChangedAt AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        [attributes].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[tST_Stage] (
        timepoints.inspectedTimepoint,
        DEFAULT
    ) [ST]
 WHERE
    [ST].ST_ID = timepoints.ST_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.dAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[dAC_Actor];
IF Object_ID('anchors.nAC_Actor', 'V') IS NOT NULL
DROP VIEW [anchors].[nAC_Actor];
IF Object_ID('anchors.pAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pAC_Actor];
IF Object_ID('anchors.lAC_Actor', 'V') IS NOT NULL
DROP VIEW [anchors].[lAC_Actor];
IF Object_ID('anchors.tAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[tAC_Actor];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_Actor viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[tAC_Actor] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].AC_NAM_AC_ID,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ID,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_PositedAt,
    [NAM].AC_NAM_Reliability,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [GEN].Metadata_AC_GEN,
    [GEN].AC_GEN_ID,
    [GEN].AC_GEN_PositedAt,
    [GEN].AC_GEN_Reliability,
    [GEN].GEN_Checksum AS AC_GEN_GEN_Checksum,
    [GEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [GEN].Metadata_GEN AS AC_GEN_Metadata_GEN,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ID,
    [PLV].AC_PLV_ChangedAt,
    [PLV].AC_PLV_PositedAt,
    [PLV].AC_PLV_Reliability,
    [PLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [PLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [PLV].Metadata_PLV AS AC_PLV_Metadata_PLV,
    [PLV].AC_PLV_PLV_ID
FROM
    [anchors].[AC_Actor] [AC]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].AC_NAM_AC_ID,
        [rNAM].Metadata_AC_NAM,
        [rNAM].AC_NAM_ID,
        [rNAM].AC_NAM_ChangedAt,
        [rNAM].AC_NAM_PositedAt,
        [rNAM].AC_NAM_Reliability,
        [rNAM].AC_NAM_Actor_Name
    FROM
        [attributes].[rAC_NAM_Actor_Name](
            @changingTimepoint,
            @positingTimepoint
        ) [rNAM]
    WHERE
        [rNAM].AC_NAM_AC_ID = [AC].AC_ID
    AND
        [rNAM].AC_NAM_Reliability = 1
    ORDER BY
        [rNAM].AC_NAM_ChangedAt DESC,
        [rNAM].AC_NAM_PositedAt DESC
) [NAM]
OUTER APPLY (
    SELECT TOP 1
        [rGEN].AC_GEN_AC_ID,
        [rGEN].Metadata_AC_GEN,
        [rGEN].AC_GEN_ID,
        [rGEN].AC_GEN_PositedAt,
        [rGEN].AC_GEN_Reliability,
        [kGEN].GEN_Checksum,
        [kGEN].GEN_Gender,
        [kGEN].Metadata_GEN,
        [rGEN].AC_GEN_GEN_ID
    FROM
        [attributes].[rAC_GEN_Actor_Gender](
            @positingTimepoint
        ) [rGEN]
    JOIN
        [knots].[GEN_Gender] [kGEN]
    ON
        [kGEN].GEN_ID = [rGEN].AC_GEN_GEN_ID
    WHERE
        [rGEN].AC_GEN_AC_ID = [AC].AC_ID
    AND
        [rGEN].AC_GEN_Reliability = 1
    ORDER BY
        [rGEN].AC_GEN_PositedAt DESC
) [GEN]
OUTER APPLY (
    SELECT TOP 1
        [rPLV].AC_PLV_AC_ID,
        [rPLV].Metadata_AC_PLV,
        [rPLV].AC_PLV_ID,
        [rPLV].AC_PLV_ChangedAt,
        [rPLV].AC_PLV_PositedAt,
        [rPLV].AC_PLV_Reliability,
        [kPLV].PLV_Checksum,
        [kPLV].PLV_ProfessionalLevel,
        [kPLV].Metadata_PLV,
        [rPLV].AC_PLV_PLV_ID
    FROM
        [attributes].[rAC_PLV_Actor_ProfessionalLevel](
            @changingTimepoint,
            @positingTimepoint
        ) [rPLV]
    JOIN
        [knots].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_ID = [rPLV].AC_PLV_PLV_ID
    WHERE
        [rPLV].AC_PLV_AC_ID = [AC].AC_ID
    AND
        [rPLV].AC_PLV_Reliability = 1
    ORDER BY
        [rPLV].AC_PLV_ChangedAt DESC,
        [rPLV].AC_PLV_PositedAt DESC
) [PLV];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lAC_Actor]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [anchors].[tAC_Actor] (
        DEFAULT,
        DEFAULT
    ) [AC];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[pAC_Actor] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [anchors].[tAC_Actor] (
        @changingTimepoint,
        DEFAULT
    ) [AC];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nAC_Actor]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [anchors].[tAC_Actor] (
        sysdatetime(),
        DEFAULT
    ) [AC];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[dAC_Actor] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [AC].*
FROM (
    SELECT DISTINCT
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [attributes].[AC_NAM_Actor_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_AC_ID AS AC_ID,
        AC_PLV_ChangedAt AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[tAC_Actor] (
        timepoints.inspectedTimepoint,
        DEFAULT
    ) [AC]
 WHERE
    [AC].AC_ID = timepoints.AC_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.dPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[dPR_Program];
IF Object_ID('anchors.nPR_Program', 'V') IS NOT NULL
DROP VIEW [anchors].[nPR_Program];
IF Object_ID('anchors.pPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pPR_Program];
IF Object_ID('anchors.lPR_Program', 'V') IS NOT NULL
DROP VIEW [anchors].[lPR_Program];
IF Object_ID('anchors.tPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[tPR_Program];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tPR_Program viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[tPR_Program] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].PR_NAM_PR_ID,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_ID,
    [NAM].PR_NAM_PositedAt,
    [NAM].PR_NAM_Reliability,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].Metadata_PR_LEN,
    [LEN].PR_LEN_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_PositedAt,
    [LEN].PR_LEN_Reliability,
    [LEN].PR_LEN_Program_Length
FROM
    [anchors].[PR_Program] [PR]
OUTER APPLY (
    SELECT TOP 1
        [rNAM].PR_NAM_PR_ID,
        [rNAM].Metadata_PR_NAM,
        [rNAM].PR_NAM_ID,
        [rNAM].PR_NAM_PositedAt,
        [rNAM].PR_NAM_Reliability,
        [rNAM].PR_NAM_Program_Name
    FROM
        [attributes].[rPR_NAM_Program_Name](
            @positingTimepoint
        ) [rNAM]
    WHERE
        [rNAM].PR_NAM_PR_ID = [PR].PR_ID
    AND
        [rNAM].PR_NAM_Reliability = 1
    ORDER BY
        [rNAM].PR_NAM_PositedAt DESC
) [NAM]
OUTER APPLY (
    SELECT TOP 1
        [rLEN].PR_LEN_PR_ID,
        [rLEN].Metadata_PR_LEN,
        [rLEN].PR_LEN_ID,
        [rLEN].PR_LEN_ChangedAt,
        [rLEN].PR_LEN_PositedAt,
        [rLEN].PR_LEN_Reliability,
        [rLEN].PR_LEN_Program_Length
    FROM
        [attributes].[rPR_LEN_Program_Length](
            @changingTimepoint,
            @positingTimepoint
        ) [rLEN]
    WHERE
        [rLEN].PR_LEN_PR_ID = [PR].PR_ID
    AND
        [rLEN].PR_LEN_Reliability = 1
    ORDER BY
        [rLEN].PR_LEN_ChangedAt DESC,
        [rLEN].PR_LEN_PositedAt DESC
) [LEN];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lPR_Program]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [anchors].[tPR_Program] (
        DEFAULT,
        DEFAULT
    ) [PR];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[pPR_Program] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [anchors].[tPR_Program] (
        @changingTimepoint,
        DEFAULT
    ) [PR];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nPR_Program]
AS
SELECT
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [anchors].[tPR_Program] (
        sysdatetime(),
        DEFAULT
    ) [PR];
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dPR_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[dPR_Program] (
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    [PR].*
FROM (
    SELECT DISTINCT
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        [attributes].[PR_LEN_Program_Length]
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[tPR_Program] (
        timepoints.inspectedTimepoint,
        DEFAULT
    ) [PR]
 WHERE
    [PR].PR_ID = timepoints.PR_ID;
GO
