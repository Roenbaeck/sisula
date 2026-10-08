-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
--
-- The time traveling perspective shows information as it was or will be based on a number
-- of input parameters.
--
-- @changingTimepoint the point in changing time to travel to (defaults to End of Time)
-- @positingTimepoint the point in positing time to travel to (defaults to End of Time)
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
IF Object_ID('dbo.dAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.nAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.pAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.lAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.tAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_partner_AC_with_ONG_currently];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_partner_AC_with_ONG_currently viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_partner_AC_with_ONG_currently] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ID,
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_partner_AC_with_ONG_currently_PositedAt,
    tie.AC_partner_AC_with_ONG_currently_Reliability,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    [dbo].[rAC_partner_AC_with_ONG_currently](
        @changingTimepoint,
        @positingTimepoint
    ) tie
JOIN
    [dbo].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ID = (
        SELECT TOP 1
            sub.AC_partner_AC_with_ONG_currently_ID
        FROM
            [dbo].[rAC_partner_AC_with_ONG_currently](
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_Reliability = 1
        AND
        (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
        )
        ORDER BY
            sub.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
            sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_partner_AC_with_ONG_currently] AS
SELECT
    *
FROM
    [dbo].[tAC_partner_AC_with_ONG_currently] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_partner_AC_with_ONG_currently] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_partner_AC_with_ONG_currently] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_partner_AC_with_ONG_currently viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_partner_AC_with_ONG_currently]
AS
SELECT
    *
FROM
    [dbo].[tAC_partner_AC_with_ONG_currently] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_partner_AC_with_ONG_currently showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_partner_AC_with_ONG_currently] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].Metadata_ONG AS currently_Metadata_ONG,
    tie.*
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[ONG_Ongoing] [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_subset_PN_of];
IF Object_ID('dbo.nAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_subset_PN_of];
IF Object_ID('dbo.pAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_subset_PN_of];
IF Object_ID('dbo.lAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_subset_PN_of];
IF Object_ID('dbo.tAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_subset_PN_of];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_subset_PN_of viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_subset_PN_of] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_subset_PN_of_ID,
    tie.Metadata_AC_subset_PN_of,
    tie.AC_subset_PN_of_PositedAt,
    tie.AC_subset_PN_of_Reliability,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[rAC_subset_PN_of](
        @positingTimepoint
    ) tie
WHERE
    tie.AC_subset_PN_of_ID = (
        SELECT TOP 1
            sub.AC_subset_PN_of_ID
        FROM
            [dbo].[rAC_subset_PN_of](
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_subset_PN_of_Reliability = 1
        AND
        (
                sub.AC_ID_subset = tie.AC_ID_subset
            OR
                sub.PN_ID_of = tie.PN_ID_of
        )
        ORDER BY
            sub.AC_subset_PN_of_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_subset_PN_of] AS
SELECT
    *
FROM
    [dbo].[tAC_subset_PN_of] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_subset_PN_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_subset_PN_of] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_subset_PN_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_subset_PN_of]
AS
SELECT
    *
FROM
    [dbo].[tAC_subset_PN_of] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dEV_in_AC_wasCast];
IF Object_ID('dbo.nEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[nEV_in_AC_wasCast];
IF Object_ID('dbo.pEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pEV_in_AC_wasCast];
IF Object_ID('dbo.lEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[lEV_in_AC_wasCast];
IF Object_ID('dbo.tEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tEV_in_AC_wasCast];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tEV_in_AC_wasCast viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tEV_in_AC_wasCast] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.EV_in_AC_wasCast_ID,
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_in_AC_wasCast_PositedAt,
    tie.EV_in_AC_wasCast_Reliability,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[rEV_in_AC_wasCast](
        @positingTimepoint
    ) tie
WHERE
    tie.EV_in_AC_wasCast_ID = (
        SELECT TOP 1
            sub.EV_in_AC_wasCast_ID
        FROM
            [dbo].[rEV_in_AC_wasCast](
                @positingTimepoint
            ) sub
        WHERE
            sub.EV_in_AC_wasCast_Reliability = 1
        AND
            sub.EV_ID_in = tie.EV_ID_in
        AND
            sub.AC_ID_wasCast = tie.AC_ID_wasCast
        ORDER BY
            sub.EV_in_AC_wasCast_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_in_AC_wasCast] AS
SELECT
    *
FROM
    [dbo].[tEV_in_AC_wasCast] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pEV_in_AC_wasCast] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tEV_in_AC_wasCast] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_in_AC_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_in_AC_wasCast]
AS
SELECT
    *
FROM
    [dbo].[tEV_in_AC_wasCast] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_part_PR_in_RAT_got];
IF Object_ID('dbo.nAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_part_PR_in_RAT_got];
IF Object_ID('dbo.pAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_part_PR_in_RAT_got];
IF Object_ID('dbo.lAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_part_PR_in_RAT_got];
IF Object_ID('dbo.tAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_part_PR_in_RAT_got];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_part_PR_in_RAT_got viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_part_PR_in_RAT_got] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ID,
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_part_PR_in_RAT_got_PositedAt,
    tie.AC_part_PR_in_RAT_got_Reliability,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    [dbo].[rAC_part_PR_in_RAT_got](
        @changingTimepoint,
        @positingTimepoint
    ) tie
JOIN
    [dbo].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ID = (
        SELECT TOP 1
            sub.AC_part_PR_in_RAT_got_ID
        FROM
            [dbo].[rAC_part_PR_in_RAT_got](
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_part_PR_in_RAT_got_Reliability = 1
        AND
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        ORDER BY
            sub.AC_part_PR_in_RAT_got_ChangedAt DESC,
            sub.AC_part_PR_in_RAT_got_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_part_PR_in_RAT_got] AS
SELECT
    *
FROM
    [dbo].[tAC_part_PR_in_RAT_got] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_part_PR_in_RAT_got] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_part_PR_in_RAT_got] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_part_PR_in_RAT_got viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_part_PR_in_RAT_got]
AS
SELECT
    *
FROM
    [dbo].[tAC_part_PR_in_RAT_got] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dAC_part_PR_in_RAT_got showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dAC_part_PR_in_RAT_got] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].Metadata_RAT AS got_Metadata_RAT,
    tie.*
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[RAT_Rating] [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_at_PR_isPlaying];
IF Object_ID('dbo.nST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_at_PR_isPlaying];
IF Object_ID('dbo.pST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_at_PR_isPlaying];
IF Object_ID('dbo.lST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_at_PR_isPlaying];
IF Object_ID('dbo.tST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tST_at_PR_isPlaying];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tST_at_PR_isPlaying viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tST_at_PR_isPlaying] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ID,
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_at_PR_isPlaying_PositedAt,
    tie.ST_at_PR_isPlaying_Reliability,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[rST_at_PR_isPlaying](
        @changingTimepoint,
        @positingTimepoint
    ) tie
WHERE
    tie.ST_at_PR_isPlaying_ID = (
        SELECT TOP 1
            sub.ST_at_PR_isPlaying_ID
        FROM
            [dbo].[rST_at_PR_isPlaying](
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.ST_at_PR_isPlaying_Reliability = 1
        AND
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        ORDER BY
            sub.ST_at_PR_isPlaying_ChangedAt DESC,
            sub.ST_at_PR_isPlaying_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_at_PR_isPlaying] AS
SELECT
    *
FROM
    [dbo].[tST_at_PR_isPlaying] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_at_PR_isPlaying] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tST_at_PR_isPlaying] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_at_PR_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_at_PR_isPlaying]
AS
SELECT
    *
FROM
    [dbo].[tST_at_PR_isPlaying] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dST_at_PR_isPlaying showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dST_at_PR_isPlaying] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.*
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.nAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.pAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.lAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.tAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tAC_parent_AC_child_PAT_having];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tAC_parent_AC_child_PAT_having viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tAC_parent_AC_child_PAT_having] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_parent_AC_child_PAT_having_ID,
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_parent_AC_child_PAT_having_PositedAt,
    tie.AC_parent_AC_child_PAT_having_Reliability,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    [dbo].[rAC_parent_AC_child_PAT_having](
        @positingTimepoint
    ) tie
JOIN
    [dbo].[PAT_ParentalType] [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having
WHERE
    tie.AC_parent_AC_child_PAT_having_ID = (
        SELECT TOP 1
            sub.AC_parent_AC_child_PAT_having_ID
        FROM
            [dbo].[rAC_parent_AC_child_PAT_having](
                @positingTimepoint
            ) sub
        WHERE
            sub.AC_parent_AC_child_PAT_having_Reliability = 1
        AND
            sub.AC_ID_parent = tie.AC_ID_parent
        AND
            sub.AC_ID_child = tie.AC_ID_child
        AND
            sub.PAT_ID_having = tie.PAT_ID_having
        ORDER BY
            sub.AC_parent_AC_child_PAT_having_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_parent_AC_child_PAT_having] AS
SELECT
    *
FROM
    [dbo].[tAC_parent_AC_child_PAT_having] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_parent_AC_child_PAT_having] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tAC_parent_AC_child_PAT_having] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_parent_AC_child_PAT_having viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_parent_AC_child_PAT_having]
AS
SELECT
    *
FROM
    [dbo].[tAC_parent_AC_child_PAT_having] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_content_ST_location_EV_of];
IF Object_ID('dbo.nPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_content_ST_location_EV_of];
IF Object_ID('dbo.pPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_content_ST_location_EV_of];
IF Object_ID('dbo.lPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_content_ST_location_EV_of];
IF Object_ID('dbo.tPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tPR_content_ST_location_EV_of];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tPR_content_ST_location_EV_of viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tPR_content_ST_location_EV_of] (
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31'
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.PR_content_ST_location_EV_of_ID,
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_PositedAt,
    tie.PR_content_ST_location_EV_of_Reliability,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    [dbo].[rPR_content_ST_location_EV_of](
        @positingTimepoint
    ) tie
WHERE
    tie.PR_content_ST_location_EV_of_ID = (
        SELECT TOP 1
            sub.PR_content_ST_location_EV_of_ID
        FROM
            [dbo].[rPR_content_ST_location_EV_of](
                @positingTimepoint
            ) sub
        WHERE
            sub.PR_content_ST_location_EV_of_Reliability = 1
        AND
            sub.EV_ID_of = tie.EV_ID_of
        ORDER BY
            sub.PR_content_ST_location_EV_of_PositedAt DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_content_ST_location_EV_of] AS
SELECT
    *
FROM
    [dbo].[tPR_content_ST_location_EV_of] (
        DEFAULT,
        DEFAULT
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_content_ST_location_EV_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[tPR_content_ST_location_EV_of] (
        @changingTimepoint,
        DEFAULT
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_content_ST_location_EV_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_content_ST_location_EV_of]
AS
SELECT
    *
FROM
    [dbo].[tPR_content_ST_location_EV_of] (
        sysdatetime(),
        DEFAULT
    ) tie;
GO
