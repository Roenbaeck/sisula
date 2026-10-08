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
IF Object_ID('dbo.edST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edST_Stage];
IF Object_ID('dbo.enST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enST_Stage];
IF Object_ID('dbo.epST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epST_Stage];
IF Object_ID('dbo.elST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elST_Stage];
IF Object_ID('dbo.dST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_Stage];
IF Object_ID('dbo.nST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_Stage];
IF Object_ID('dbo.pST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_Stage];
IF Object_ID('dbo.lST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_Stage];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_Stage] WITH SCHEMABINDING AS
SELECT
    [ST].ST_ID,
    [NAM].ST_NAM_ST_ID,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Checksum,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    cast(null as bit) as Deletable_ST_MIN,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN
    [dbo].[eST_NAM_Stage_Name](0) [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [dbo].[eST_NAM_Stage_Name](0) sub 
        WHERE
            sub.ST_NAM_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[eST_LOC_Stage_Location](0) [LOC]
ON
    [LOC].ST_LOC_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[ST_AVG_Stage_Average] [AVG]
ON
    [AVG].ST_AVG_ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [dbo].[ST_AVG_Stage_Average] sub
        WHERE
            sub.ST_AVG_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [dbo].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_MIN_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_Stage] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [NAM].ST_NAM_ST_ID,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Checksum,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN
    [dbo].[rST_NAM_Stage_Name](0, @changingTimepoint) [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [dbo].[rST_NAM_Stage_Name](0, @changingTimepoint) sub 
        WHERE
            sub.ST_NAM_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[eST_LOC_Stage_Location](0) [LOC]
ON
    [LOC].ST_LOC_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[rST_AVG_Stage_Average](@changingTimepoint) [AVG]
ON
    [AVG].ST_AVG_ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [dbo].[rST_AVG_Stage_Average](@changingTimepoint) sub
        WHERE
            sub.ST_AVG_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [dbo].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_MIN_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_Stage]
AS
SELECT
    *
FROM
    [dbo].[pST_Stage](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dST_Stage] (
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
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[eST_NAM_Stage_Name](0) 
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
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pST_Stage](timepoints.inspectedTimepoint) [pST]
WHERE
    [pST].ST_ID = timepoints.ST_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elST_Stage viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elST_Stage] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [NAM].ST_NAM_ST_ID,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Checksum,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN
    [dbo].[eST_NAM_Stage_Name](@equivalent) [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [dbo].[eST_NAM_Stage_Name](@equivalent) sub 
        WHERE
            sub.ST_NAM_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[eST_LOC_Stage_Location](@equivalent) [LOC]
ON
    [LOC].ST_LOC_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[ST_AVG_Stage_Average] [AVG]
ON
    [AVG].ST_AVG_ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [dbo].[ST_AVG_Stage_Average] sub
        WHERE
            sub.ST_AVG_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [dbo].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_MIN_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- epST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epST_Stage] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [NAM].ST_NAM_ST_ID,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_EQ,
    [NAM].ST_NAM_Checksum,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].ST_LOC_EQ,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].ST_AVG_ChangedAt,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN
    [dbo].[rST_NAM_Stage_Name](@equivalent, @changingTimepoint) [NAM]
ON
    [NAM].ST_NAM_ST_ID = [ST].ST_ID
AND
    [NAM].ST_NAM_ChangedAt = (
        SELECT
            max(sub.ST_NAM_ChangedAt)
        FROM
            [dbo].[rST_NAM_Stage_Name](@equivalent, @changingTimepoint) sub 
        WHERE
            sub.ST_NAM_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[eST_LOC_Stage_Location](@equivalent) [LOC]
ON
    [LOC].ST_LOC_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[rST_AVG_Stage_Average](@changingTimepoint) [AVG]
ON
    [AVG].ST_AVG_ST_ID = [ST].ST_ID
AND
    [AVG].ST_AVG_ChangedAt = (
        SELECT
            max(sub.ST_AVG_ChangedAt)
        FROM
            [dbo].[rST_AVG_Stage_Average](@changingTimepoint) sub
        WHERE
            sub.ST_AVG_ST_ID = [ST].ST_ID
   )
LEFT JOIN
    [dbo].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [dbo].[ST_MIN_Stage_Minimum] [MIN]
ON
    [MIN].ST_MIN_ST_ID = [ST].ST_ID
LEFT JOIN
    [dbo].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enST_Stage] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epST_Stage](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edST_Stage showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[edST_Stage] (
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
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[eST_NAM_Stage_Name](@equivalent) 
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
        [dbo].[ST_AVG_Stage_Average]
    WHERE
        (@selection is null OR @selection like '%AVG%')
    AND
        ST_AVG_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[epST_Stage](@equivalent, timepoints.inspectedTimepoint) [pST]
WHERE
    [pST].ST_ID = timepoints.ST_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edAC_Actor];
IF Object_ID('dbo.enAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enAC_Actor];
IF Object_ID('dbo.epAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epAC_Actor];
IF Object_ID('dbo.elAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elAC_Actor];
IF Object_ID('dbo.dAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_Actor];
IF Object_ID('dbo.nAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_Actor];
IF Object_ID('dbo.pAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_Actor];
IF Object_ID('dbo.lAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_Actor];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_Actor] WITH SCHEMABINDING AS
SELECT
    [AC].AC_ID,
    [NAM].AC_NAM_AC_ID,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_EQ,
    [NAM].AC_NAM_Checksum,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [kGEN].GEN_EQ AS AC_GEN_GEN_EQ,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN
    [dbo].[eAC_NAM_Actor_Name](0) [NAM]
ON
    [NAM].AC_NAM_AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [dbo].[eAC_NAM_Actor_Name](0) sub 
        WHERE
            sub.AC_NAM_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_GEN_AC_ID = [AC].AC_ID
LEFT JOIN
    [dbo].[eGEN_Gender](0) [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [dbo].[AC_PLV_Actor_ProfessionalLevel] [PLV]
ON
    [PLV].AC_PLV_AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel] sub
        WHERE
            sub.AC_PLV_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_Actor] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [NAM].AC_NAM_AC_ID,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_EQ,
    [NAM].AC_NAM_Checksum,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [kGEN].GEN_EQ AS AC_GEN_GEN_EQ,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN
    [dbo].[rAC_NAM_Actor_Name](0, @changingTimepoint) [NAM]
ON
    [NAM].AC_NAM_AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [dbo].[rAC_NAM_Actor_Name](0, @changingTimepoint) sub 
        WHERE
            sub.AC_NAM_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_GEN_AC_ID = [AC].AC_ID
LEFT JOIN
    [dbo].[eGEN_Gender](0) [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [dbo].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) [PLV]
ON
    [PLV].AC_PLV_AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [dbo].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) sub
        WHERE
            sub.AC_PLV_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_Actor]
AS
SELECT
    *
FROM
    [dbo].[pAC_Actor](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_Actor] (
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
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[eAC_NAM_Actor_Name](0) 
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
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pAC_Actor](timepoints.inspectedTimepoint) [pAC]
WHERE
    [pAC].AC_ID = timepoints.AC_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elAC_Actor viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elAC_Actor] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [NAM].AC_NAM_AC_ID,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_EQ,
    [NAM].AC_NAM_Checksum,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [kGEN].GEN_EQ AS AC_GEN_GEN_EQ,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN
    [dbo].[eAC_NAM_Actor_Name](@equivalent) [NAM]
ON
    [NAM].AC_NAM_AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [dbo].[eAC_NAM_Actor_Name](@equivalent) sub 
        WHERE
            sub.AC_NAM_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_GEN_AC_ID = [AC].AC_ID
LEFT JOIN
    [dbo].[eGEN_Gender](@equivalent) [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [dbo].[AC_PLV_Actor_ProfessionalLevel] [PLV]
ON
    [PLV].AC_PLV_AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel] sub
        WHERE
            sub.AC_PLV_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- epAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epAC_Actor] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [NAM].AC_NAM_AC_ID,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_EQ,
    [NAM].AC_NAM_Checksum,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [kGEN].GEN_EQ AS AC_GEN_GEN_EQ,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].AC_PLV_ChangedAt,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN
    [dbo].[rAC_NAM_Actor_Name](@equivalent, @changingTimepoint) [NAM]
ON
    [NAM].AC_NAM_AC_ID = [AC].AC_ID
AND
    [NAM].AC_NAM_ChangedAt = (
        SELECT
            max(sub.AC_NAM_ChangedAt)
        FROM
            [dbo].[rAC_NAM_Actor_Name](@equivalent, @changingTimepoint) sub 
        WHERE
            sub.AC_NAM_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[AC_GEN_Actor_Gender] [GEN]
ON
    [GEN].AC_GEN_AC_ID = [AC].AC_ID
LEFT JOIN
    [dbo].[eGEN_Gender](@equivalent) [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [dbo].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) [PLV]
ON
    [PLV].AC_PLV_AC_ID = [AC].AC_ID
AND
    [PLV].AC_PLV_ChangedAt = (
        SELECT
            max(sub.AC_PLV_ChangedAt)
        FROM
            [dbo].[rAC_PLV_Actor_ProfessionalLevel](@changingTimepoint) sub
        WHERE
            sub.AC_PLV_AC_ID = [AC].AC_ID
   )
LEFT JOIN
    [dbo].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enAC_Actor] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epAC_Actor](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edAC_Actor showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[edAC_Actor] (
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
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[eAC_NAM_Actor_Name](@equivalent) 
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
        [dbo].[AC_PLV_Actor_ProfessionalLevel]
    WHERE
        (@selection is null OR @selection like '%PLV%')
    AND
        AC_PLV_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[epAC_Actor](@equivalent, timepoints.inspectedTimepoint) [pAC]
WHERE
    [pAC].AC_ID = timepoints.AC_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edPR_Program];
IF Object_ID('dbo.enPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enPR_Program];
IF Object_ID('dbo.epPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epPR_Program];
IF Object_ID('dbo.elPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elPR_Program];
IF Object_ID('dbo.dPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_Program];
IF Object_ID('dbo.nPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_Program];
IF Object_ID('dbo.pPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_Program];
IF Object_ID('dbo.lPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_Program];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_Program] WITH SCHEMABINDING AS
SELECT
    [PR].PR_ID,
    [NAM].PR_NAM_PR_ID,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_Program_Length
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN
    [dbo].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_NAM_PR_ID = [PR].PR_ID
LEFT JOIN
    [dbo].[PR_LEN_Program_Length] [LEN]
ON
    [LEN].PR_LEN_PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [dbo].[PR_LEN_Program_Length] sub
        WHERE
            sub.PR_LEN_PR_ID = [PR].PR_ID
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_Program] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [NAM].PR_NAM_PR_ID,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_Program_Length
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN
    [dbo].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_NAM_PR_ID = [PR].PR_ID
LEFT JOIN
    [dbo].[rPR_LEN_Program_Length](@changingTimepoint) [LEN]
ON
    [LEN].PR_LEN_PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [dbo].[rPR_LEN_Program_Length](@changingTimepoint) sub
        WHERE
            sub.PR_LEN_PR_ID = [PR].PR_ID
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_Program]
AS
SELECT
    *
FROM
    [dbo].[pPR_Program](sysdatetime());
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dPR_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dPR_Program] (
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
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        [dbo].[PR_LEN_Program_Length]
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[pPR_Program](timepoints.inspectedTimepoint) [pPR]
WHERE
    [pPR].PR_ID = timepoints.PR_ID;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elPR_Program viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elPR_Program] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [NAM].PR_NAM_PR_ID,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_Program_Length
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN
    [dbo].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_NAM_PR_ID = [PR].PR_ID
LEFT JOIN
    [dbo].[PR_LEN_Program_Length] [LEN]
ON
    [LEN].PR_LEN_PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [dbo].[PR_LEN_Program_Length] sub
        WHERE
            sub.PR_LEN_PR_ID = [PR].PR_ID
   );
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-- epPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epPR_Program] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [NAM].PR_NAM_PR_ID,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_Program_Length
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN
    [dbo].[PR_NAM_Program_Name] [NAM]
ON
    [NAM].PR_NAM_PR_ID = [PR].PR_ID
LEFT JOIN
    [dbo].[rPR_LEN_Program_Length](@changingTimepoint) [LEN]
ON
    [LEN].PR_LEN_PR_ID = [PR].PR_ID
AND
    [LEN].PR_LEN_ChangedAt = (
        SELECT
            max(sub.PR_LEN_ChangedAt)
        FROM
            [dbo].[rPR_LEN_Program_Length](@changingTimepoint) sub
        WHERE
            sub.PR_LEN_PR_ID = [PR].PR_ID
   );
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enPR_Program] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epPR_Program](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edPR_Program showing all differences between the given timepoints and optionally for a subset of attributes
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[edPR_Program] (
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
        PR_LEN_PR_ID AS PR_ID,
        PR_LEN_ChangedAt AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        [dbo].[PR_LEN_Program_Length]
    WHERE
        (@selection is null OR @selection like '%LEN%')
    AND
        PR_LEN_ChangedAt BETWEEN @intervalStart AND @intervalEnd
) timepoints
CROSS APPLY
    [dbo].[epPR_Program](@equivalent, timepoints.inspectedTimepoint) [pPR]
WHERE
    [pPR].PR_ID = timepoints.PR_ID;
GO
