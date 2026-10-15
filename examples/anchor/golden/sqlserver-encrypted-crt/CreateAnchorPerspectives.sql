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
-- changes in all or a selection of attributes, with latest positing time, for each positor, which each row names.
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
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
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
    [NAM].ST_NAM_Positor,
    [NAM].ST_NAM_Reliability,
    [NAM].ST_NAM_Assertion,
    [NAM].ST_NAM_Stage_Name,
    [LOC].ST_LOC_ST_ID,
    [LOC].Metadata_ST_LOC,
    [LOC].ST_LOC_ID,
    [LOC].ST_LOC_PositedAt,
    [LOC].ST_LOC_Positor,
    [LOC].ST_LOC_Reliability,
    [LOC].ST_LOC_Assertion,
    [LOC].ST_LOC_Checksum,
    [LOC].ST_LOC_Stage_Location,
    [AVG].ST_AVG_ST_ID,
    [AVG].Metadata_ST_AVG,
    [AVG].ST_AVG_ID,
    [AVG].ST_AVG_ChangedAt,
    [AVG].ST_AVG_PositedAt,
    [AVG].ST_AVG_Positor,
    [AVG].ST_AVG_Reliability,
    [AVG].ST_AVG_Assertion,
    [kAVG].UTL_Utilization AS ST_AVG_UTL_Utilization,
    [kAVG].Metadata_UTL AS ST_AVG_Metadata_UTL,
    [AVG].ST_AVG_UTL_ID,
    [MIN].ST_MIN_ST_ID,
    [MIN].Metadata_ST_MIN,
    [MIN].ST_MIN_ID,
    [MIN].ST_MIN_PositedAt,
    [MIN].ST_MIN_Positor,
    [MIN].ST_MIN_Reliability,
    [MIN].ST_MIN_Assertion,
    [kMIN].UTL_Utilization AS ST_MIN_UTL_Utilization,
    [kMIN].Metadata_UTL AS ST_MIN_Metadata_UTL,
    [MIN].ST_MIN_UTL_ID
FROM
    [anchors].[ST_Stage] [ST]
LEFT JOIN
    [attributes].[rST_NAM_Stage_Name](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].ST_NAM_ID = (
        SELECT TOP 1
            sub.ST_NAM_ID
        FROM
            [attributes].[rST_NAM_Stage_Name](
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
    [attributes].[rST_LOC_Stage_Location](
        @positor,
        @positingTimepoint
    ) [LOC]
ON
    [LOC].ST_LOC_ID = (
        SELECT TOP 1
            sub.ST_LOC_ID
        FROM
            [attributes].[rST_LOC_Stage_Location](
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
    [attributes].[rST_AVG_Stage_Average](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [AVG]
ON
    [AVG].ST_AVG_ID = (
        SELECT TOP 1
            sub.ST_AVG_ID
        FROM
            [attributes].[rST_AVG_Stage_Average](
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
    [knots].[UTL_Utilization] [kAVG]
ON
    [kAVG].UTL_ID = [AVG].ST_AVG_UTL_ID
LEFT JOIN
    [attributes].[rST_MIN_Stage_Minimum](
        @positor,
        @positingTimepoint
    ) [MIN]
ON
    [MIN].ST_MIN_ID = (
        SELECT TOP 1
            sub.ST_MIN_ID
        FROM
            [attributes].[rST_MIN_Stage_Minimum](
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
    [knots].[UTL_Utilization] [kMIN]
ON
    [kMIN].UTL_ID = [MIN].ST_MIN_UTL_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_Stage viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lST_Stage]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tST_Stage] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
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
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tST_Stage] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [ST];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_Stage viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nST_Stage]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [ST].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tST_Stage] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
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
    p.Positor,
    timepoints.inspectedTimepoint,
    [ST].*
FROM
    [dw].[_Positor] p
JOIN (
    SELECT DISTINCT
        ST_NAM_Positor AS positor,
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
        ST_AVG_Positor AS positor,
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
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [anchors].[tST_Stage] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
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
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
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
    [NAM].AC_NAM_Positor,
    [NAM].AC_NAM_Reliability,
    [NAM].AC_NAM_Assertion,
    [NAM].AC_NAM_Actor_Name,
    [GEN].AC_GEN_AC_ID,
    [GEN].Metadata_AC_GEN,
    [GEN].AC_GEN_ID,
    [GEN].AC_GEN_PositedAt,
    [GEN].AC_GEN_Positor,
    [GEN].AC_GEN_Reliability,
    [GEN].AC_GEN_Assertion,
    [kGEN].GEN_Checksum AS AC_GEN_GEN_Checksum,
    [kGEN].GEN_Gender AS AC_GEN_GEN_Gender,
    [kGEN].Metadata_GEN AS AC_GEN_Metadata_GEN,
    [GEN].AC_GEN_GEN_ID,
    [PLV].AC_PLV_AC_ID,
    [PLV].Metadata_AC_PLV,
    [PLV].AC_PLV_ID,
    [PLV].AC_PLV_ChangedAt,
    [PLV].AC_PLV_PositedAt,
    [PLV].AC_PLV_Positor,
    [PLV].AC_PLV_Reliability,
    [PLV].AC_PLV_Assertion,
    [kPLV].PLV_Checksum AS AC_PLV_PLV_Checksum,
    [kPLV].PLV_ProfessionalLevel AS AC_PLV_PLV_ProfessionalLevel,
    [kPLV].Metadata_PLV AS AC_PLV_Metadata_PLV,
    [PLV].AC_PLV_PLV_ID
FROM
    [anchors].[AC_Actor] [AC]
LEFT JOIN
    [attributes].[rAC_NAM_Actor_Name](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].AC_NAM_ID = (
        SELECT TOP 1
            sub.AC_NAM_ID
        FROM
            [attributes].[rAC_NAM_Actor_Name](
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
    [attributes].[rAC_GEN_Actor_Gender](
        @positor,
        @positingTimepoint
    ) [GEN]
ON
    [GEN].AC_GEN_ID = (
        SELECT TOP 1
            sub.AC_GEN_ID
        FROM
            [attributes].[rAC_GEN_Actor_Gender](
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
    [knots].[GEN_Gender] [kGEN]
ON
    [kGEN].GEN_ID = [GEN].AC_GEN_GEN_ID
LEFT JOIN
    [attributes].[rAC_PLV_Actor_ProfessionalLevel](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [PLV]
ON
    [PLV].AC_PLV_ID = (
        SELECT TOP 1
            sub.AC_PLV_ID
        FROM
            [attributes].[rAC_PLV_Actor_ProfessionalLevel](
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
    [knots].[PLV_ProfessionalLevel] [kPLV]
ON
    [kPLV].PLV_ID = [PLV].AC_PLV_PLV_ID;
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_Actor viewed by the latest available information for all positors (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[lAC_Actor]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tAC_Actor] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
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
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tAC_Actor] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [AC];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_Actor viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nAC_Actor]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [AC].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tAC_Actor] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
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
    p.Positor,
    timepoints.inspectedTimepoint,
    [AC].*
FROM
    [dw].[_Positor] p
JOIN (
    SELECT DISTINCT
        AC_NAM_Positor AS positor,
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
        AC_PLV_Positor AS positor,
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
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [anchors].[tAC_Actor] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
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
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    [PR].PR_ID,
    [PR].Metadata_PR,
    [NAM].PR_NAM_PR_ID,
    [NAM].Metadata_PR_NAM,
    [NAM].PR_NAM_ID,
    [NAM].PR_NAM_PositedAt,
    [NAM].PR_NAM_Positor,
    [NAM].PR_NAM_Reliability,
    [NAM].PR_NAM_Assertion,
    [NAM].PR_NAM_Program_Name,
    [LEN].PR_LEN_PR_ID,
    [LEN].Metadata_PR_LEN,
    [LEN].PR_LEN_ID,
    [LEN].PR_LEN_ChangedAt,
    [LEN].PR_LEN_PositedAt,
    [LEN].PR_LEN_Positor,
    [LEN].PR_LEN_Reliability,
    [LEN].PR_LEN_Assertion,
    [LEN].PR_LEN_Program_Length
FROM
    [anchors].[PR_Program] [PR]
LEFT JOIN
    [attributes].[rPR_NAM_Program_Name](
        @positor,
        @positingTimepoint
    ) [NAM]
ON
    [NAM].PR_NAM_ID = (
        SELECT TOP 1
            sub.PR_NAM_ID
        FROM
            [attributes].[rPR_NAM_Program_Name](
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
    [attributes].[rPR_LEN_Program_Length](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) [LEN]
ON
    [LEN].PR_LEN_ID = (
        SELECT TOP 1
            sub.PR_LEN_ID
        FROM
            [attributes].[rPR_LEN_Program_Length](
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
CREATE VIEW [anchors].[lPR_Program]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tPR_Program] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+' -- positve assertions only
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
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tPR_Program] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [PR];
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_Program viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [anchors].[nPR_Program]
AS
SELECT
    p.*,
    cast(null as decimal(5,2)) as Reliability,
    [PR].*
FROM
    [dw].[_Positor] p
CROSS APPLY
    [anchors].[tPR_Program] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+' -- positve assertions only
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
    p.Positor,
    timepoints.inspectedTimepoint,
    [PR].*
FROM
    [dw].[_Positor] p
JOIN (
    SELECT DISTINCT
        PR_LEN_Positor AS positor,
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
ON
    timepoints.positor = p.Positor
CROSS APPLY
    [anchors].[tPR_Program] (
        timepoints.positor,
        timepoints.inspectedTimepoint,
        DEFAULT,
        '+' -- positve assertions only
    ) [PR]
 WHERE
    [PR].PR_ID = timepoints.PR_ID;
GO
