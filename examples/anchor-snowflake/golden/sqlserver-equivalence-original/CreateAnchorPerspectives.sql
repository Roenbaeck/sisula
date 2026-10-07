-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each anchor. There are four types of perspectives: latest,
-- point-in-time, difference, and now. They also denormalize the anchor, its attributes,
-- and referenced knots from sixth to third normal form.
--
-- The latest perspective shows the latest available information for each anchor.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints, and for
-- changes in all or a selection of attributes.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
-- @selection a list of mnemonics for tracked attributes, ie 'MNE MON ICS', or null for all
--
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.edST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[edST_Stage];
IF Object_ID('anchors.enST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[enST_Stage];
IF Object_ID('anchors.epST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[epST_Stage];
IF Object_ID('anchors.elST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[elST_Stage];
IF Object_ID('anchors.dST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[dST_Stage];
IF Object_ID('anchors.nST_Stage', 'V') IS NOT NULL
DROP VIEW [anchors].[nST_Stage];
IF Object_ID('anchors.pST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pST_Stage];
IF Object_ID('anchors.lST_Stage', 'V') IS NOT NULL
DROP VIEW [anchors].[lST_Stage];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lST_Stage] WITH SCHEMABINDING AS
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Stage_Name,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS UTL_Utilization,
    [kAVG].Metadata_UTL AS Metadata_UTL,
    [AVG].UTL_ID,
    [MIN].Metadata_ST_MIN,
    cast(null as bit) as Deletable_ST_MIN,
    [kMIN].UTL_Utilization AS UTL_Utilization,
    [kMIN].Metadata_UTL AS Metadata_UTL,
    [MIN].UTL_ID
FROM
    [anchors].[ST_Stage] [ST]
LEFT JOIN
    [attributes].[eST_NAM_Stage_Name](0) [NAM]
ON
    [NAM].ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [attributes].[eST_NAM_Stage_Name](0) sub 
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [attributes].[eST_LOC_Stage_Location](0) [LOC]
ON
    [LOC].ST_ID = [ST].ST_ID
LEFT JOIN
    [attributes].[ST_AVG_Stage_Average] [AVG]
ON
    [AVG].ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [attributes].[ST_AVG_Stage_Average] sub
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [knots].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].UTL_ID
LEFT JOIN
    [attributes].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_ID = [ST].ST_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].UTL_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[pST_Stage] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Stage_Name,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS UTL_Utilization,
    [kAVG].Metadata_UTL AS Metadata_UTL,
    [AVG].UTL_ID,
    [MIN].Metadata_ST_MIN,
    [kMIN].UTL_Utilization AS UTL_Utilization,
    [kMIN].Metadata_UTL AS Metadata_UTL,
    [MIN].UTL_ID
FROM
    [anchors].[ST_Stage] [ST]
LEFT JOIN
    [attributes].[rST_NAM_Stage_Name](0, @changingTimepoint) [NAM]
ON
    [NAM].ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [attributes].[rST_NAM_Stage_Name](0, @changingTimepoint) sub 
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [attributes].[eST_LOC_Stage_Location](0) [LOC]
ON
    [LOC].ST_ID = [ST].ST_ID
LEFT JOIN
    [attributes].[rST_AVG_Stage_Average](@changingTimepoint) [AVG]
ON
    [AVG].ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [attributes].[rST_AVG_Stage_Average](@changingTimepoint) sub
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [knots].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].UTL_ID
LEFT JOIN
    [attributes].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_ID = [ST].ST_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].UTL_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nST_Stage]
AS
SELECT
    *
FROM
    [anchors].[pST_Stage](sysdatetime());
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
    timepoints.mnemonic,
    [pST].*
FROM (
    SELECT DISTINCT
        ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [attributes].[eST_NAM_Stage_Name](0) 
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_ID AS ST_ID,
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
    [anchors].[pST_Stage](timepoints.inspectedTimepoint) [pST]
WHERE
    [pST].ST_ID = timepoints.ST_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elST_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[elST_Stage] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Stage_Name,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS UTL_Utilization,
    [kAVG].Metadata_UTL AS Metadata_UTL,
    [AVG].UTL_ID,
    [MIN].Metadata_ST_MIN,
    [kMIN].UTL_Utilization AS UTL_Utilization,
    [kMIN].Metadata_UTL AS Metadata_UTL,
    [MIN].UTL_ID
FROM
    [anchors].[ST_Stage] [ST]
LEFT JOIN
    [attributes].[eST_NAM_Stage_Name](@equivalent) [NAM]
ON
    [NAM].ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [attributes].[eST_NAM_Stage_Name](@equivalent) sub 
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [attributes].[eST_LOC_Stage_Location](@equivalent) [LOC]
ON
    [LOC].ST_ID = [ST].ST_ID
LEFT JOIN
    [attributes].[ST_AVG_Stage_Average] [AVG]
ON
    [AVG].ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [attributes].[ST_AVG_Stage_Average] sub
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [knots].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].UTL_ID
LEFT JOIN
    [attributes].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_ID = [ST].ST_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].UTL_ID;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- epST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[epST_Stage] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [ST].Metadata_ST,
    [NAM].Metadata_ST_NAM,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Stage_Name,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS UTL_Utilization,
    [kAVG].Metadata_UTL AS Metadata_UTL,
    [AVG].UTL_ID,
    [MIN].Metadata_ST_MIN,
    [kMIN].UTL_Utilization AS UTL_Utilization,
    [kMIN].Metadata_UTL AS Metadata_UTL,
    [MIN].UTL_ID
FROM
    [anchors].[ST_Stage] [ST]
LEFT JOIN
    [attributes].[rST_NAM_Stage_Name](@equivalent, @changingTimepoint) [NAM]
ON
    [NAM].ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [attributes].[rST_NAM_Stage_Name](@equivalent, @changingTimepoint) sub 
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [attributes].[eST_LOC_Stage_Location](@equivalent) [LOC]
ON
    [LOC].ST_ID = [ST].ST_ID
LEFT JOIN
    [attributes].[rST_AVG_Stage_Average](@changingTimepoint) [AVG]
ON
    [AVG].ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [attributes].[rST_AVG_Stage_Average](@changingTimepoint) sub
        WHERE
            sub.ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [knots].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].UTL_ID
LEFT JOIN
    [attributes].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_ID = [ST].ST_ID
LEFT JOIN
    [knots].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].UTL_ID;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[enST_Stage] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [anchors].[epST_Stage](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edST_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[edST_Stage] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pST].*
FROM (
    SELECT DISTINCT
        ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [attributes].[eST_NAM_Stage_Name](@equivalent) 
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_ID AS ST_ID,
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
    [anchors].[epST_Stage](@equivalent, timepoints.inspectedTimepoint) [pST]
WHERE
    [pST].ST_ID = timepoints.ST_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.edAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[edAC_Actor];
IF Object_ID('anchors.enAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[enAC_Actor];
IF Object_ID('anchors.epAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[epAC_Actor];
IF Object_ID('anchors.elAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[elAC_Actor];
IF Object_ID('anchors.dAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[dAC_Actor];
IF Object_ID('anchors.nAC_Actor', 'V') IS NOT NULL
DROP VIEW [anchors].[nAC_Actor];
IF Object_ID('anchors.pAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pAC_Actor];
IF Object_ID('anchors.lAC_Actor', 'V') IS NOT NULL
DROP VIEW [anchors].[lAC_Actor];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lAC_Actor] WITH SCHEMABINDING AS
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ChangedAt,
    CAST(DECRYPTBYKEY([NAM].AC_NAM_Actor_Name) AS nvarchar(42)) AS AC_NAM_Actor_Name,
    [GEN].Metadata_AC_GEN,
    [kGEN].GEN_Checksum AS GEN_Checksum,
    [kGEN].GEN_Gender AS GEN_Gender,
    [kGEN].Metadata_GEN AS Metadata_GEN,
    [GEN].GEN_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS PLV_Checksum,
    [kPLV].PLV_EQ AS PLV_EQ,
    [kPLV].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kPLV].Metadata_PLV AS Metadata_PLV,
    [PLV].PLV_ID
FROM
    [anchors].[AC_Actor] [AC]
LEFT JOIN
    [attributes].[AC_NAM_Actor_Name] [NAM]
ON
    [NAM].AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [attributes].[AC_NAM_Actor_Name] sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [attributes].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_ID = [AC].AC_ID
LEFT JOIN
    [knots].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].GEN_ID
LEFT JOIN
    [attributes].[AC_PLV_Actor_ProfessionalLevel] [PLV]
ON
    [PLV].AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [attributes].[AC_PLV_Actor_ProfessionalLevel] sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](0) [kPLV]
ON
    [kPLV].PLV_ID = [PLV].PLV_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[pAC_Actor] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ChangedAt,
    CAST(DECRYPTBYKEY([NAM].AC_NAM_Actor_Name) AS nvarchar(42)) AS AC_NAM_Actor_Name,
    [GEN].Metadata_AC_GEN,
    [kGEN].GEN_Checksum AS GEN_Checksum,
    [kGEN].GEN_Gender AS GEN_Gender,
    [kGEN].Metadata_GEN AS Metadata_GEN,
    [GEN].GEN_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS PLV_Checksum,
    [kPLV].PLV_EQ AS PLV_EQ,
    [kPLV].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kPLV].Metadata_PLV AS Metadata_PLV,
    [PLV].PLV_ID
FROM
    [anchors].[AC_Actor] [AC]
LEFT JOIN
    [attributes].[rAC_NAM_Actor_Name](@changingTimepoint) [NAM]
ON
    [NAM].AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [attributes].[rAC_NAM_Actor_Name](@changingTimepoint) sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [attributes].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_ID = [AC].AC_ID
LEFT JOIN
    [knots].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].GEN_ID
LEFT JOIN
    [attributes].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) [PLV]
ON
    [PLV].AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [attributes].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](0) [kPLV]
ON
    [kPLV].PLV_ID = [PLV].PLV_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nAC_Actor]
AS
SELECT
    *
FROM
    [anchors].[pAC_Actor](sysdatetime());
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
    timepoints.mnemonic,
    [pAC].*
FROM (
    SELECT DISTINCT
        AC_ID AS AC_ID,
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
        AC_ID AS AC_ID,
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
    [anchors].[pAC_Actor](timepoints.inspectedTimepoint) [pAC]
WHERE
    [pAC].AC_ID = timepoints.AC_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elAC_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[elAC_Actor] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ChangedAt,
    CAST(DECRYPTBYKEY([NAM].AC_NAM_Actor_Name) AS nvarchar(42)) AS AC_NAM_Actor_Name,
    [GEN].Metadata_AC_GEN,
    [kGEN].GEN_Checksum AS GEN_Checksum,
    [kGEN].GEN_Gender AS GEN_Gender,
    [kGEN].Metadata_GEN AS Metadata_GEN,
    [GEN].GEN_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS PLV_Checksum,
    [kPLV].PLV_EQ AS PLV_EQ,
    [kPLV].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kPLV].Metadata_PLV AS Metadata_PLV,
    [PLV].PLV_ID
FROM
    [anchors].[AC_Actor] [AC]
LEFT JOIN
    [attributes].[AC_NAM_Actor_Name] [NAM]
ON
    [NAM].AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [attributes].[AC_NAM_Actor_Name] sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [attributes].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_ID = [AC].AC_ID
LEFT JOIN
    [knots].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].GEN_ID
LEFT JOIN
    [attributes].[AC_PLV_Actor_ProfessionalLevel] [PLV]
ON
    [PLV].AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [attributes].[AC_PLV_Actor_ProfessionalLevel] sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](@equivalent) [kPLV]
ON
    [kPLV].PLV_ID = [PLV].PLV_ID;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- epAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[epAC_Actor] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [AC].Metadata_AC,
    [NAM].Metadata_AC_NAM,
    [NAM].AC_NAM_ChangedAt,
    CAST(DECRYPTBYKEY([NAM].AC_NAM_Actor_Name) AS nvarchar(42)) AS AC_NAM_Actor_Name,
    [GEN].Metadata_AC_GEN,
    [kGEN].GEN_Checksum AS GEN_Checksum,
    [kGEN].GEN_Gender AS GEN_Gender,
    [kGEN].Metadata_GEN AS Metadata_GEN,
    [GEN].GEN_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS PLV_Checksum,
    [kPLV].PLV_EQ AS PLV_EQ,
    [kPLV].PLV_ProfessionalLevel AS PLV_ProfessionalLevel,
    [kPLV].Metadata_PLV AS Metadata_PLV,
    [PLV].PLV_ID
FROM
    [anchors].[AC_Actor] [AC]
LEFT JOIN
    [attributes].[rAC_NAM_Actor_Name](@changingTimepoint) [NAM]
ON
    [NAM].AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [attributes].[rAC_NAM_Actor_Name](@changingTimepoint) sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [attributes].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_ID = [AC].AC_ID
LEFT JOIN
    [knots].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].GEN_ID
LEFT JOIN
    [attributes].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) [PLV]
ON
    [PLV].AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [attributes].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) sub
        WHERE
            sub.AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [knots].[ePLV_ProfessionalLevel](@equivalent) [kPLV]
ON
    [kPLV].PLV_ID = [PLV].PLV_ID;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[enAC_Actor] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [anchors].[epAC_Actor](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edAC_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[edAC_Actor] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pAC].*
FROM (
    SELECT DISTINCT
        AC_ID AS AC_ID,
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
        AC_ID AS AC_ID,
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
    [anchors].[epAC_Actor](@equivalent, timepoints.inspectedTimepoint) [pAC]
WHERE
    [pAC].AC_ID = timepoints.AC_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('anchors.edPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[edPR_Program];
IF Object_ID('anchors.enPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[enPR_Program];
IF Object_ID('anchors.epPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[epPR_Program];
IF Object_ID('anchors.elPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[elPR_Program];
IF Object_ID('anchors.dPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[dPR_Program];
IF Object_ID('anchors.nPR_Program', 'V') IS NOT NULL
DROP VIEW [anchors].[nPR_Program];
IF Object_ID('anchors.pPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [anchors].[pPR_Program];
IF Object_ID('anchors.lPR_Program', 'V') IS NOT NULL
DROP VIEW [anchors].[lPR_Program];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lPR_Program] WITH SCHEMABINDING AS
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_Program_Name,
    [LEN].Metadata_PR_LEN,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_EQ,
    [LEN].PR_LEN_Program_Length
FROM
    [anchors].[PR_Program] [PR]
LEFT JOIN
    [attributes].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_ID = [PR].PR_ID
LEFT JOIN
    [attributes].[ePR_LEN_Program_Length](0) [LEN]
ON
    [LEN].PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [attributes].[ePR_LEN_Program_Length](0) sub 
        WHERE
            sub.PR_ID = [PR].PR_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[pPR_Program] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_Program_Name,
    [LEN].Metadata_PR_LEN,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_EQ,
    [LEN].PR_LEN_Program_Length
FROM
    [anchors].[PR_Program] [PR]
LEFT JOIN
    [attributes].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_ID = [PR].PR_ID
LEFT JOIN
    [attributes].[rPR_LEN_Program_Length](0, @changingTimepoint) [LEN]
ON
    [LEN].PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [attributes].[rPR_LEN_Program_Length](0, @changingTimepoint) sub 
        WHERE
            sub.PR_ID = [PR].PR_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nPR_Program]
AS
SELECT
    *
FROM
    [anchors].[pPR_Program](sysdatetime());
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
    timepoints.mnemonic,
    [pPR].*
FROM (
    SELECT DISTINCT
        PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        [attributes].[ePR_LEN_Program_Length](0) 
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[pPR_Program](timepoints.inspectedTimepoint) [pPR]
WHERE
    [pPR].PR_ID = timepoints.PR_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elPR_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[elPR_Program] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_Program_Name,
    [LEN].Metadata_PR_LEN,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_EQ,
    [LEN].PR_LEN_Program_Length
FROM
    [anchors].[PR_Program] [PR]
LEFT JOIN
    [attributes].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_ID = [PR].PR_ID
LEFT JOIN
    [attributes].[ePR_LEN_Program_Length](@equivalent) [LEN]
ON
    [LEN].PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [attributes].[ePR_LEN_Program_Length](@equivalent) sub 
        WHERE
            sub.PR_ID = [PR].PR_ID
   );
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- epPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[epPR_Program] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_Program_Name,
    [LEN].Metadata_PR_LEN,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_EQ,
    [LEN].PR_LEN_Program_Length
FROM
    [anchors].[PR_Program] [PR]
LEFT JOIN
    [attributes].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_ID = [PR].PR_ID
LEFT JOIN
    [attributes].[rPR_LEN_Program_Length](@equivalent, @changingTimepoint) [LEN]
ON
    [LEN].PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [attributes].[rPR_LEN_Program_Length](@equivalent, @changingTimepoint) sub 
        WHERE
            sub.PR_ID = [PR].PR_ID
   );
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[enPR_Program] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [anchors].[epPR_Program](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edPR_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [anchors].[edPR_Program] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2,
    @selection varchar(max) = null
)
RETURNS TABLE AS RETURN
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    [pPR].*
FROM (
    SELECT DISTINCT
        PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        [attributes].[ePR_LEN_Program_Length](@equivalent) 
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [anchors].[epPR_Program](@equivalent, timepoints.inspectedTimepoint) [pPR]
WHERE
    [pPR].PR_ID = timepoints.PR_ID;
GO
