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
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
-- @assertion whether to show positve, negative, uncertain, or all posits (defaults to all)
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
IF Object_ID('dbo.dPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPN_Person];
IF Object_ID('dbo.nPN_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[nPN_Person];
IF Object_ID('dbo.pPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPN_Person];
IF Object_ID('dbo.lPN_Person', 'V') IS NOT NULL
DROP VIEW [dbo].[lPN_Person];
IF Object_ID('dbo.tPN_Person', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tPN_Person];
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_Stage];
IF Object_ID('dbo.nST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_Stage];
IF Object_ID('dbo.pST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_Stage];
IF Object_ID('dbo.lST_Stage', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_Stage];
IF Object_ID('dbo.tST_Stage', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tST_Stage];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tST_Stage viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tST_Stage] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [ST].ST_ID,
    [NAM].ST_NAM_ST_ID,
    [NAM].ST_NAM_ID,
    [NAM].ST_NAM_ChangedAt,
    [NAM].ST_NAM_PositedAt,
    [NAM].ST_NAM_Positor,
    [NAM].ST_NAM_Reliability,
    [NAM].ST_NAM_Assertion,
    [NAM].ST_NAM_Checksum,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].ST_LOC_ID,
    [LOC].ST_LOC_PositedAt,
    [LOC].ST_LOC_Positor,
    [LOC].ST_LOC_Reliability,
    [LOC].ST_LOC_Assertion,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].ST_AVG_ID,
    [AVG].ST_AVG_ChangedAt,
    [AVG].ST_AVG_PositedAt,
    [AVG].ST_AVG_Positor,
    [AVG].ST_AVG_Reliability,
    [AVG].ST_AVG_Assertion,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [MIN].ST_MIN_ID,
    [MIN].ST_MIN_PositedAt,
    [MIN].ST_MIN_Positor,
    [MIN].ST_MIN_Reliability,
    [MIN].ST_MIN_Assertion,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [MIN].ST_MIN_UTL_ID
FROM
    [dbo].[ST_Stage] [ST]
LEFT JOIN
    [dbo].[rST_NAM_Stage_Name](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].ST_NAM_ID = (
        SELECT TOP 1
            sub.ST_NAM_ID
        FROM
            [dbo].[rST_NAM_Stage_Name](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.ST_NAM_ST_ID = [ST].ST_ID
        AND
            sub.ST_NAM_Assertion = isnull(@assertion, sub.ST_NAM_Assertion)
        ORDER BY
            sub.ST_NAM_ChangedAt DESC,
            sub.ST_NAM_PositedAt DESC,
            sub.ST_NAM_Reliability DESC
    )
LEFT JOIN
    [dbo].[rST_LOC_Stage_Location](
        @positor,
        @positingTimepoint
    ) [LOC]
ON
    [LOC].ST_LOC_ID = (
        SELECT TOP 1
            sub.ST_LOC_ID
        FROM
            [dbo].[rST_LOC_Stage_Location](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.ST_LOC_ST_ID = [ST].ST_ID
        AND
            sub.ST_LOC_Assertion = isnull(@assertion, sub.ST_LOC_Assertion)
        ORDER BY
            sub.ST_LOC_PositedAt DESC,
            sub.ST_LOC_Reliability DESC
    )
LEFT JOIN
    [dbo].[rST_AVG_Stage_Average](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [AVG]
ON
    [AVG].ST_AVG_ID = (
        SELECT TOP 1
            sub.ST_AVG_ID
        FROM
            [dbo].[rST_AVG_Stage_Average](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.ST_AVG_ST_ID = [ST].ST_ID
        AND
            sub.ST_AVG_Assertion = isnull(@assertion, sub.ST_AVG_Assertion)
        ORDER BY
            sub.ST_AVG_ChangedAt DESC,
            sub.ST_AVG_PositedAt DESC,
            sub.ST_AVG_Reliability DESC
    )
LEFT JOIN
    [dbo].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [dbo].[rST_MIN_Stage_Minimum](
        @positor,
        @positingTimepoint
    ) [MIN]
ON
    [MIN].ST_MIN_ID = (
        SELECT TOP 1
            sub.ST_MIN_ID
        FROM
            [dbo].[rST_MIN_Stage_Minimum](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.ST_MIN_ST_ID = [ST].ST_ID
        AND
            sub.ST_MIN_Assertion = isnull(@assertion, sub.ST_MIN_Assertion)
        ORDER BY
            sub.ST_MIN_PositedAt DESC,
            sub.ST_MIN_Reliability DESC
    )
LEFT JOIN
    [dbo].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Stage viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_Stage]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tST_Stage] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [ST];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_Stage viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_Stage] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tST_Stage] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [ST];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_Stage]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tST_Stage] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [ST];
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
    [ST].*
FROM
    [dbo].[_Positor] p
JOIN (
    SELECT DISTINCT
        ST_NAM_Positor AS positor,
        ST_NAM_ST_ID AS ST_ID,
        ST_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[ST_NAM_Stage_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        ST_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        ST_AVG_Positor AS positor,
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
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [dbo].[tST_Stage] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [ST]
 WHERE
    [ST].ST_ID = timepoints.ST_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_Actor];
IF Object_ID('dbo.nAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_Actor];
IF Object_ID('dbo.pAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_Actor];
IF Object_ID('dbo.lAC_Actor', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_Actor];
IF Object_ID('dbo.tAC_Actor', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_Actor];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_Actor viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_Actor] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [AC].AC_ID,
    [NAM].AC_NAM_AC_ID,
    [NAM].AC_NAM_ID,
    [NAM].AC_NAM_ChangedAt,
    [NAM].AC_NAM_PositedAt,
    [NAM].AC_NAM_Positor,
    [NAM].AC_NAM_Reliability,
    [NAM].AC_NAM_Assertion,
    [NAM].AC_NAM_Checksum,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [GEN].AC_GEN_ID,
    [GEN].AC_GEN_PositedAt,
    [GEN].AC_GEN_Positor,
    [GEN].AC_GEN_Reliability,
    [GEN].AC_GEN_Assertion,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].AC_PLV_ID,
    [PLV].AC_PLV_ChangedAt,
    [PLV].AC_PLV_PositedAt,
    [PLV].AC_PLV_Positor,
    [PLV].AC_PLV_Reliability,
    [PLV].AC_PLV_Assertion,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [PLV].AC_PLV_PLV_ID
FROM
    [dbo].[AC_Actor] [AC]
LEFT JOIN
    [dbo].[rAC_NAM_Actor_Name](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].AC_NAM_ID = (
        SELECT TOP 1
            sub.AC_NAM_ID
        FROM
            [dbo].[rAC_NAM_Actor_Name](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_NAM_AC_ID = [AC].AC_ID
        AND
            sub.AC_NAM_Assertion = isnull(@assertion, sub.AC_NAM_Assertion)
        ORDER BY
            sub.AC_NAM_ChangedAt DESC,
            sub.AC_NAM_PositedAt DESC,
            sub.AC_NAM_Reliability DESC
    )
LEFT JOIN
    [dbo].[rAC_GEN_Actor_Gender](
        @positor,
        @positingTimepoint
    ) [GEN]
ON
    [GEN].AC_GEN_ID = (
        SELECT TOP 1
            sub.AC_GEN_ID
        FROM
            [dbo].[rAC_GEN_Actor_Gender](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_GEN_AC_ID = [AC].AC_ID
        AND
            sub.AC_GEN_Assertion = isnull(@assertion, sub.AC_GEN_Assertion)
        ORDER BY
            sub.AC_GEN_PositedAt DESC,
            sub.AC_GEN_Reliability DESC
    )
LEFT JOIN
    [dbo].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [dbo].[rAC_PLV_Actor_ProfessionalLevel](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [PLV]
ON
    [PLV].AC_PLV_ID = (
        SELECT TOP 1
            sub.AC_PLV_ID
        FROM
            [dbo].[rAC_PLV_Actor_ProfessionalLevel](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_PLV_AC_ID = [AC].AC_ID
        AND
            sub.AC_PLV_Assertion = isnull(@assertion, sub.AC_PLV_Assertion)
        ORDER BY
            sub.AC_PLV_ChangedAt DESC,
            sub.AC_PLV_PositedAt DESC,
            sub.AC_PLV_Reliability DESC
    )
LEFT JOIN
    [dbo].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_Actor viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_Actor]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tAC_Actor] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [AC];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_Actor viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_Actor] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tAC_Actor] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [AC];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_Actor]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tAC_Actor] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [AC];
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
    [AC].*
FROM
    [dbo].[_Positor] p
JOIN (
    SELECT DISTINCT
        AC_NAM_Positor AS positor,
        AC_NAM_AC_ID AS AC_ID,
        AC_NAM_ChangedAt AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        [dbo].[AC_NAM_Actor_Name]
    WHERE
        (@selection is null OR @selection like '%NAM%')
    AND
        AC_NAM_ChangedAt BETWEEN @intervalStart AND @intervalEnd
    UNION
    SELECT DISTINCT
        AC_PLV_Positor AS positor,
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
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [dbo].[tAC_Actor] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [AC]
 WHERE
    [AC].AC_ID = timepoints.AC_ID;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_Program];
IF Object_ID('dbo.nPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_Program];
IF Object_ID('dbo.pPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_Program];
IF Object_ID('dbo.lPR_Program', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_Program];
IF Object_ID('dbo.tPR_Program', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tPR_Program];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tPR_Program viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tPR_Program] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [NAM].PR_NAM_PR_ID,
    [NAM].PR_NAM_ID,
    [NAM].PR_NAM_PositedAt,
    [NAM].PR_NAM_Positor,
    [NAM].PR_NAM_Reliability,
    [NAM].PR_NAM_Assertion,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].PR_LEN_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_PositedAt,
    [LEN].PR_LEN_Positor,
    [LEN].PR_LEN_Reliability,
    [LEN].PR_LEN_Assertion,
    [LEN].PR_LEN_Program_Length
FROM
    [dbo].[PR_Program] [PR]
LEFT JOIN
    [dbo].[rPR_NAM_Program_Name](
        @positor,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].PR_NAM_ID = (
        SELECT TOP 1
            sub.PR_NAM_ID
        FROM
            [dbo].[rPR_NAM_Program_Name](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.PR_NAM_PR_ID = [PR].PR_ID
        AND
            sub.PR_NAM_Assertion = isnull(@assertion, sub.PR_NAM_Assertion)
        ORDER BY
            sub.PR_NAM_PositedAt DESC,
            sub.PR_NAM_Reliability DESC
    )
LEFT JOIN
    [dbo].[rPR_LEN_Program_Length](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [LEN]
ON
    [LEN].PR_LEN_ID = (
        SELECT TOP 1
            sub.PR_LEN_ID
        FROM
            [dbo].[rPR_LEN_Program_Length](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.PR_LEN_PR_ID = [PR].PR_ID
        AND
            sub.PR_LEN_Assertion = isnull(@assertion, sub.PR_LEN_Assertion)
        ORDER BY
            sub.PR_LEN_ChangedAt DESC,
            sub.PR_LEN_PositedAt DESC,
            sub.PR_LEN_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_Program viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_Program]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tPR_Program] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
    ) [PR];
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_Program viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_Program] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tPR_Program] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [PR];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_Program]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tPR_Program] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
    ) [PR];
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
    [PR].*
FROM
    [dbo].[_Positor] p
JOIN (
    SELECT DISTINCT
        PR_LEN_Positor AS positor,
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
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [dbo].[tPR_Program] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [PR]
 WHERE
    [PR].PR_ID = timepoints.PR_ID;
GO
