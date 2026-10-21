-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The time traveling perspective shows information as it was or will be based on a number
-- of input parameters.
--
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
-- @assertion whether to show positve, negative, uncertain, or all posits (defaults to all)
--
-- The latest perspective shows the latest available information for each tie.
-- The now perspective shows the information as it is right now.
-- The point-in-time perspective lets you travel through the information to the given timepoint.
--
-- @changingTimepoint the point in changing time to travel to
--
-- The difference perspective shows changes between the two given timepoints.
--
-- @intervalStart the start of the interval for finding changes
-- @intervalEnd the end of the interval for finding changes
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.dAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [ties].[dAC_partner_AC_with_ONG_currently];
IF Object_ID('ties.nAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [ties].[nAC_partner_AC_with_ONG_currently];
IF Object_ID('ties.pAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [ties].[pAC_partner_AC_with_ONG_currently];
IF Object_ID('ties.lAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [ties].[lAC_partner_AC_with_ONG_currently];
IF Object_ID('ties.tAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [ties].[tAC_partner_AC_with_ONG_currently];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_partner_AC_with_ONG_currently viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[tAC_partner_AC_with_ONG_currently] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ID,
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_Positor,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_partner_AC_with_ONG_currently_PositedAt,
    tie.AC_partner_AC_with_ONG_currently_Reliability,
    tie.AC_partner_AC_with_ONG_currently_Assertion,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS Metadata_ONG,
    tie.ONG_ID_currently
FROM
    [ties].[rAC_partner_AC_with_ONG_currently](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
LEFT JOIN
    [knots].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ID = (
        SELECT TOP 1
            sub.AC_partner_AC_with_ONG_currently_ID
        FROM
            [ties].[rAC_partner_AC_with_ONG_currently](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
        (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
        )
        AND
            sub.AC_partner_AC_with_ONG_currently_Assertion = isnull(@assertion, sub.AC_partner_AC_with_ONG_currently_Assertion)
        AND ( -- asked for positive or negative assertions: those at the latest changing time with an assertion that is
              -- not a retraction, which supersedes those at earlier changing times whatever its sign
            isnull(@assertion, '?') = '?'
        OR
            sub.AC_partner_AC_with_ONG_currently_ChangedAt = (
                SELECT
                    max(e.AC_partner_AC_with_ONG_currently_ChangedAt)
                FROM
                    [ties].[rAC_partner_AC_with_ONG_currently](
                        @positor,
                        @changingTimepoint,
                        @positingTimepoint
                    ) e
                WHERE
                    e.AC_ID_partner = sub.AC_ID_partner
                AND
                    e.AC_ID_with = sub.AC_ID_with
                AND
                    e.ONG_ID_currently = sub.ONG_ID_currently
                AND
                    e.AC_partner_AC_with_ONG_currently_Assertion <> '?'
            )
        )
        ORDER BY
            sub.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
            sub.AC_partner_AC_with_ONG_currently_PositedAt DESC,
            sub.AC_partner_AC_with_ONG_currently_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[lAC_partner_AC_with_ONG_currently] AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_partner_AC_with_ONG_currently] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[pAC_partner_AC_with_ONG_currently] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_partner_AC_with_ONG_currently] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_partner_AC_with_ONG_currently viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[nAC_partner_AC_with_ONG_currently]
AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_partner_AC_with_ONG_currently] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_partner_AC_with_ONG_currently showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[dAC_partner_AC_with_ONG_currently] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ONG_currently].ONG_Ongoing AS ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS Metadata_ONG,
    tie.*
FROM
    [ties].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [knots].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.dAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[dAC_subset_PN_of];
IF Object_ID('ties.nAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [ties].[nAC_subset_PN_of];
IF Object_ID('ties.pAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[pAC_subset_PN_of];
IF Object_ID('ties.lAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [ties].[lAC_subset_PN_of];
IF Object_ID('ties.tAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[tAC_subset_PN_of];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_subset_PN_of viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[tAC_subset_PN_of] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_subset_PN_of_ID,
    tie.Metadata_AC_subset_PN_of,
    tie.AC_subset_PN_of_Positor,
    tie.AC_subset_PN_of_PositedAt,
    tie.AC_subset_PN_of_Reliability,
    tie.AC_subset_PN_of_Assertion,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [ties].[rAC_subset_PN_of](
        @positor,
        @positingTimepoint
    ) tie
WHERE
    tie.AC_subset_PN_of_ID = (
        SELECT TOP 1
            sub.AC_subset_PN_of_ID
        FROM
            [ties].[rAC_subset_PN_of](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
        (
                sub.AC_ID_subset = tie.AC_ID_subset
            OR
                sub.PN_ID_of = tie.PN_ID_of
        )
        AND
            sub.AC_subset_PN_of_Assertion = isnull(@assertion, sub.AC_subset_PN_of_Assertion)
        ORDER BY
            sub.AC_subset_PN_of_PositedAt DESC,
            sub.AC_subset_PN_of_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[lAC_subset_PN_of] AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_subset_PN_of] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[pAC_subset_PN_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_subset_PN_of] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_subset_PN_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[nAC_subset_PN_of]
AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_subset_PN_of] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.dEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[dEV_in_AC_wasCast];
IF Object_ID('ties.nEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [ties].[nEV_in_AC_wasCast];
IF Object_ID('ties.pEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[pEV_in_AC_wasCast];
IF Object_ID('ties.lEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [ties].[lEV_in_AC_wasCast];
IF Object_ID('ties.tEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [ties].[tEV_in_AC_wasCast];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tEV_in_AC_wasCast viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[tEV_in_AC_wasCast] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.EV_in_AC_wasCast_ID,
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_in_AC_wasCast_Positor,
    tie.EV_in_AC_wasCast_PositedAt,
    tie.EV_in_AC_wasCast_Reliability,
    tie.EV_in_AC_wasCast_Assertion,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    [ties].[rEV_in_AC_wasCast](
        @positor,
        @positingTimepoint
    ) tie
WHERE
    tie.EV_in_AC_wasCast_ID = (
        SELECT TOP 1
            sub.EV_in_AC_wasCast_ID
        FROM
            [ties].[rEV_in_AC_wasCast](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_ID_in = tie.EV_ID_in
        AND
            sub.AC_ID_wasCast = tie.AC_ID_wasCast
        AND
            sub.EV_in_AC_wasCast_Assertion = isnull(@assertion, sub.EV_in_AC_wasCast_Assertion)
        ORDER BY
            sub.EV_in_AC_wasCast_PositedAt DESC,
            sub.EV_in_AC_wasCast_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[lEV_in_AC_wasCast] AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tEV_in_AC_wasCast] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[pEV_in_AC_wasCast] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tEV_in_AC_wasCast] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_in_AC_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[nEV_in_AC_wasCast]
AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tEV_in_AC_wasCast] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.dAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [ties].[dAC_part_PR_in_RAT_got];
IF Object_ID('ties.nAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [ties].[nAC_part_PR_in_RAT_got];
IF Object_ID('ties.pAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [ties].[pAC_part_PR_in_RAT_got];
IF Object_ID('ties.lAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [ties].[lAC_part_PR_in_RAT_got];
IF Object_ID('ties.tAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [ties].[tAC_part_PR_in_RAT_got];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_part_PR_in_RAT_got viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[tAC_part_PR_in_RAT_got] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ID,
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_Positor,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_part_PR_in_RAT_got_PositedAt,
    tie.AC_part_PR_in_RAT_got_Reliability,
    tie.AC_part_PR_in_RAT_got_Assertion,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS RAT_Rating,
    [RAT_got].Metadata_RAT AS Metadata_RAT,
    tie.RAT_ID_got
FROM
    [ties].[rAC_part_PR_in_RAT_got](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
LEFT JOIN
    [knots].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ID = (
        SELECT TOP 1
            sub.AC_part_PR_in_RAT_got_ID
        FROM
            [ties].[rAC_part_PR_in_RAT_got](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        AND
            sub.AC_part_PR_in_RAT_got_Assertion = isnull(@assertion, sub.AC_part_PR_in_RAT_got_Assertion)
        AND ( -- asked for positive or negative assertions: those at the latest changing time with an assertion that is
              -- not a retraction, which supersedes those at earlier changing times whatever its sign
            isnull(@assertion, '?') = '?'
        OR
            sub.AC_part_PR_in_RAT_got_ChangedAt = (
                SELECT
                    max(e.AC_part_PR_in_RAT_got_ChangedAt)
                FROM
                    [ties].[rAC_part_PR_in_RAT_got](
                        @positor,
                        @changingTimepoint,
                        @positingTimepoint
                    ) e
                WHERE
                    e.AC_ID_part = sub.AC_ID_part
                AND
                    e.PR_ID_in = sub.PR_ID_in
                AND
                    e.AC_part_PR_in_RAT_got_Assertion <> '?'
            )
        )
        ORDER BY
            sub.AC_part_PR_in_RAT_got_ChangedAt DESC,
            sub.AC_part_PR_in_RAT_got_PositedAt DESC,
            sub.AC_part_PR_in_RAT_got_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[lAC_part_PR_in_RAT_got] AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_part_PR_in_RAT_got] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[pAC_part_PR_in_RAT_got] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_part_PR_in_RAT_got] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_part_PR_in_RAT_got viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[nAC_part_PR_in_RAT_got]
AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_part_PR_in_RAT_got] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_part_PR_in_RAT_got showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[dAC_part_PR_in_RAT_got] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [RAT_got].RAT_Rating AS RAT_Rating,
    [RAT_got].Metadata_RAT AS Metadata_RAT,
    tie.*
FROM
    [ties].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [knots].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.dST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[dST_at_PR_isPlaying];
IF Object_ID('ties.nST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [ties].[nST_at_PR_isPlaying];
IF Object_ID('ties.pST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[pST_at_PR_isPlaying];
IF Object_ID('ties.lST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [ties].[lST_at_PR_isPlaying];
IF Object_ID('ties.tST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [ties].[tST_at_PR_isPlaying];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tST_at_PR_isPlaying viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[tST_at_PR_isPlaying] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ID,
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_Positor,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_at_PR_isPlaying_PositedAt,
    tie.ST_at_PR_isPlaying_Reliability,
    tie.ST_at_PR_isPlaying_Assertion,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [ties].[rST_at_PR_isPlaying](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
WHERE
    tie.ST_at_PR_isPlaying_ID = (
        SELECT TOP 1
            sub.ST_at_PR_isPlaying_ID
        FROM
            [ties].[rST_at_PR_isPlaying](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        AND
            sub.ST_at_PR_isPlaying_Assertion = isnull(@assertion, sub.ST_at_PR_isPlaying_Assertion)
        AND ( -- asked for positive or negative assertions: those at the latest changing time with an assertion that is
              -- not a retraction, which supersedes those at earlier changing times whatever its sign
            isnull(@assertion, '?') = '?'
        OR
            sub.ST_at_PR_isPlaying_ChangedAt = (
                SELECT
                    max(e.ST_at_PR_isPlaying_ChangedAt)
                FROM
                    [ties].[rST_at_PR_isPlaying](
                        @positor,
                        @changingTimepoint,
                        @positingTimepoint
                    ) e
                WHERE
                    e.ST_ID_at = sub.ST_ID_at
                AND
                    e.PR_ID_isPlaying = sub.PR_ID_isPlaying
                AND
                    e.ST_at_PR_isPlaying_Assertion <> '?'
            )
        )
        ORDER BY
            sub.ST_at_PR_isPlaying_ChangedAt DESC,
            sub.ST_at_PR_isPlaying_PositedAt DESC,
            sub.ST_at_PR_isPlaying_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[lST_at_PR_isPlaying] AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tST_at_PR_isPlaying] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[pST_at_PR_isPlaying] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tST_at_PR_isPlaying] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_at_PR_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[nST_at_PR_isPlaying]
AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tST_at_PR_isPlaying] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_at_PR_isPlaying showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[dST_at_PR_isPlaying] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.*
FROM
    [ties].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.dAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [ties].[dAC_parent_AC_child_PAT_having];
IF Object_ID('ties.nAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [ties].[nAC_parent_AC_child_PAT_having];
IF Object_ID('ties.pAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [ties].[pAC_parent_AC_child_PAT_having];
IF Object_ID('ties.lAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [ties].[lAC_parent_AC_child_PAT_having];
IF Object_ID('ties.tAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [ties].[tAC_parent_AC_child_PAT_having];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_parent_AC_child_PAT_having viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[tAC_parent_AC_child_PAT_having] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_parent_AC_child_PAT_having_ID,
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_parent_AC_child_PAT_having_Positor,
    tie.AC_parent_AC_child_PAT_having_PositedAt,
    tie.AC_parent_AC_child_PAT_having_Reliability,
    tie.AC_parent_AC_child_PAT_having_Assertion,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS PAT_ParentalType,
    [PAT_having].Metadata_PAT AS Metadata_PAT,
    tie.PAT_ID_having
FROM
    [ties].[rAC_parent_AC_child_PAT_having](
        @positor,
        @positingTimepoint
    ) tie
LEFT JOIN
    [knots].[PAT_ParentalType] [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having
WHERE
    tie.AC_parent_AC_child_PAT_having_ID = (
        SELECT TOP 1
            sub.AC_parent_AC_child_PAT_having_ID
        FROM
            [ties].[rAC_parent_AC_child_PAT_having](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_ID_parent = tie.AC_ID_parent
        AND
            sub.AC_ID_child = tie.AC_ID_child
        AND
            sub.PAT_ID_having = tie.PAT_ID_having
        AND
            sub.AC_parent_AC_child_PAT_having_Assertion = isnull(@assertion, sub.AC_parent_AC_child_PAT_having_Assertion)
        ORDER BY
            sub.AC_parent_AC_child_PAT_having_PositedAt DESC,
            sub.AC_parent_AC_child_PAT_having_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[lAC_parent_AC_child_PAT_having] AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_parent_AC_child_PAT_having] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[pAC_parent_AC_child_PAT_having] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_parent_AC_child_PAT_having] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_parent_AC_child_PAT_having viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[nAC_parent_AC_child_PAT_having]
AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tAC_parent_AC_child_PAT_having] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('ties.dPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[dPR_content_ST_location_EV_of];
IF Object_ID('ties.nPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [ties].[nPR_content_ST_location_EV_of];
IF Object_ID('ties.pPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[pPR_content_ST_location_EV_of];
IF Object_ID('ties.lPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [ties].[lPR_content_ST_location_EV_of];
IF Object_ID('ties.tPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [ties].[tPR_content_ST_location_EV_of];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tPR_content_ST_location_EV_of viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[tPR_content_ST_location_EV_of] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.PR_content_ST_location_EV_of_ID,
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_Positor,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_content_ST_location_EV_of_PositedAt,
    tie.PR_content_ST_location_EV_of_Reliability,
    tie.PR_content_ST_location_EV_of_Assertion,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    [ties].[rPR_content_ST_location_EV_of](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
WHERE
    tie.PR_content_ST_location_EV_of_ID = (
        SELECT TOP 1
            sub.PR_content_ST_location_EV_of_ID
        FROM
            [ties].[rPR_content_ST_location_EV_of](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
        (
                sub.PR_ID_content = tie.PR_ID_content
            OR
                sub.ST_ID_location = tie.ST_ID_location
        )
        AND
            sub.PR_content_ST_location_EV_of_Assertion = isnull(@assertion, sub.PR_content_ST_location_EV_of_Assertion)
        AND ( -- asked for positive or negative assertions: those at the latest changing time with an assertion that is
              -- not a retraction, which supersedes those at earlier changing times whatever its sign
            isnull(@assertion, '?') = '?'
        OR
            sub.PR_content_ST_location_EV_of_ChangedAt = (
                SELECT
                    max(e.PR_content_ST_location_EV_of_ChangedAt)
                FROM
                    [ties].[rPR_content_ST_location_EV_of](
                        @positor,
                        @changingTimepoint,
                        @positingTimepoint
                    ) e
                WHERE
                    e.PR_ID_content = sub.PR_ID_content
                AND
                    e.ST_ID_location = sub.ST_ID_location
                AND
                    e.EV_ID_of = sub.EV_ID_of
                AND
                    e.PR_content_ST_location_EV_of_Assertion <> '?'
            )
        )
        ORDER BY
            sub.PR_content_ST_location_EV_of_ChangedAt DESC,
            sub.PR_content_ST_location_EV_of_PositedAt DESC,
            sub.PR_content_ST_location_EV_of_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[lPR_content_ST_location_EV_of] AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tPR_content_ST_location_EV_of] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[pPR_content_ST_location_EV_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tPR_content_ST_location_EV_of] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_content_ST_location_EV_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [ties].[nPR_content_ST_location_EV_of]
AS
SELECT
    *
FROM
    [dw].[_Positor] p
CROSS APPLY
    [ties].[tPR_content_ST_location_EV_of] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dPR_content_ST_location_EV_of showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [ties].[dPR_content_ST_location_EV_of] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.*
FROM
    [ties].[PR_content_ST_location_EV_of] tie
WHERE
    tie.PR_content_ST_location_EV_of_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
