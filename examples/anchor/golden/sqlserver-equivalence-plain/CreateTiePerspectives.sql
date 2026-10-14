-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- These table valued functions simplify temporal querying by providing a temporal
-- perspective of each tie. There are four types of perspectives: latest,
-- point-in-time, difference, and now.
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
-- Under equivalence all these views default to equivalent = 0, however, corresponding
-- prepended-e perspectives are provided in order to select a specific equivalent.
--
-- @equivalent the equivalent for which to retrieve data
--
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.enAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.epAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.elAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.dAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.nAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.pAC_partner_AC_with_ONG_currently', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_partner_AC_with_ONG_currently];
IF Object_ID('dbo.lAC_partner_AC_with_ONG_currently', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_partner_AC_with_ONG_currently];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_partner_AC_with_ONG_currently] WITH SCHEMABINDING AS
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[eONG_Ongoing](0) [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            [dbo].[AC_partner_AC_with_ONG_currently] sub
        WHERE
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_partner_AC_with_ONG_currently] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[eONG_Ongoing](0) [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            [dbo].[AC_partner_AC_with_ONG_currently] sub
        WHERE
        (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
        )
        AND
            sub.AC_partner_AC_with_ONG_currently_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_partner_AC_with_ONG_currently viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_partner_AC_with_ONG_currently]
AS
SELECT
    *
FROM
    [dbo].[pAC_partner_AC_with_ONG_currently](sysdatetime());
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
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[eONG_Ongoing](0) [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elAC_partner_AC_with_ONG_currently] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[eONG_Ongoing](@equivalent) [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            [dbo].[AC_partner_AC_with_ONG_currently] sub
        WHERE
            sub.AC_ID_partner = tie.AC_ID_partner
        OR
            sub.AC_ID_with = tie.AC_ID_with
   );
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------------------
-- epAC_partner_AC_with_ONG_currently viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epAC_partner_AC_with_ONG_currently] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[eONG_Ongoing](@equivalent) [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            max(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            [dbo].[AC_partner_AC_with_ONG_currently] sub
        WHERE
        (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
        )
        AND
            sub.AC_partner_AC_with_ONG_currently_ChangedAt <= @changingTimepoint
   );
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enAC_partner_AC_with_ONG_currently viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enAC_partner_AC_with_ONG_currently] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epAC_partner_AC_with_ONG_currently](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edAC_partner_AC_with_ONG_currently showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[edAC_partner_AC_with_ONG_currently] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    [ONG_currently].ONG_Ongoing AS currently_ONG_Ongoing,
    [ONG_currently].ONG_EQ AS currently_ONG_EQ,
    tie.ONG_ID_currently
FROM
    [dbo].[AC_partner_AC_with_ONG_currently] tie
LEFT JOIN
    [dbo].[eONG_Ongoing](@equivalent) [ONG_currently]
ON
    [ONG_currently].ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edAC_subset_PN_of];
IF Object_ID('dbo.enAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enAC_subset_PN_of];
IF Object_ID('dbo.epAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epAC_subset_PN_of];
IF Object_ID('dbo.elAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elAC_subset_PN_of];
IF Object_ID('dbo.dAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_subset_PN_of];
IF Object_ID('dbo.nAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_subset_PN_of];
IF Object_ID('dbo.pAC_subset_PN_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_subset_PN_of];
IF Object_ID('dbo.lAC_subset_PN_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_subset_PN_of];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_subset_PN_of] WITH SCHEMABINDING AS
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[AC_subset_PN_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_subset_PN_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[AC_subset_PN_of] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_subset_PN_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_subset_PN_of]
AS
SELECT
    *
FROM
    [dbo].[pAC_subset_PN_of](sysdatetime());
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elAC_subset_PN_of] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[AC_subset_PN_of] tie;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------------------
-- epAC_subset_PN_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epAC_subset_PN_of] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    [dbo].[AC_subset_PN_of] tie;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enAC_subset_PN_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enAC_subset_PN_of] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epAC_subset_PN_of](@equivalent, sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edEV_in_AC_wasCast];
IF Object_ID('dbo.enEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enEV_in_AC_wasCast];
IF Object_ID('dbo.epEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epEV_in_AC_wasCast];
IF Object_ID('dbo.elEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elEV_in_AC_wasCast];
IF Object_ID('dbo.dEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dEV_in_AC_wasCast];
IF Object_ID('dbo.nEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[nEV_in_AC_wasCast];
IF Object_ID('dbo.pEV_in_AC_wasCast', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pEV_in_AC_wasCast];
IF Object_ID('dbo.lEV_in_AC_wasCast', 'V') IS NOT NULL
DROP VIEW [dbo].[lEV_in_AC_wasCast];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lEV_in_AC_wasCast] WITH SCHEMABINDING AS
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[EV_in_AC_wasCast] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pEV_in_AC_wasCast] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[EV_in_AC_wasCast] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nEV_in_AC_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nEV_in_AC_wasCast]
AS
SELECT
    *
FROM
    [dbo].[pEV_in_AC_wasCast](sysdatetime());
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elEV_in_AC_wasCast] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[EV_in_AC_wasCast] tie;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------------------
-- epEV_in_AC_wasCast viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epEV_in_AC_wasCast] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    [dbo].[EV_in_AC_wasCast] tie;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enEV_in_AC_wasCast viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enEV_in_AC_wasCast] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epEV_in_AC_wasCast](@equivalent, sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edAC_part_PR_in_RAT_got];
IF Object_ID('dbo.enAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enAC_part_PR_in_RAT_got];
IF Object_ID('dbo.epAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epAC_part_PR_in_RAT_got];
IF Object_ID('dbo.elAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elAC_part_PR_in_RAT_got];
IF Object_ID('dbo.dAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_part_PR_in_RAT_got];
IF Object_ID('dbo.nAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_part_PR_in_RAT_got];
IF Object_ID('dbo.pAC_part_PR_in_RAT_got', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_part_PR_in_RAT_got];
IF Object_ID('dbo.lAC_part_PR_in_RAT_got', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_part_PR_in_RAT_got];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_part_PR_in_RAT_got] WITH SCHEMABINDING AS
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[eRAT_Rating](0) [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            [dbo].[AC_part_PR_in_RAT_got] sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_part_PR_in_RAT_got] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[eRAT_Rating](0) [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            [dbo].[AC_part_PR_in_RAT_got] sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        AND
            sub.AC_part_PR_in_RAT_got_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_part_PR_in_RAT_got viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_part_PR_in_RAT_got]
AS
SELECT
    *
FROM
    [dbo].[pAC_part_PR_in_RAT_got](sysdatetime());
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
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[eRAT_Rating](0) [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elAC_part_PR_in_RAT_got] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[eRAT_Rating](@equivalent) [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            [dbo].[AC_part_PR_in_RAT_got] sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
   );
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------------------
-- epAC_part_PR_in_RAT_got viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epAC_part_PR_in_RAT_got] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[eRAT_Rating](@equivalent) [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            max(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            [dbo].[AC_part_PR_in_RAT_got] sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
        AND
            sub.AC_part_PR_in_RAT_got_ChangedAt <= @changingTimepoint
   );
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enAC_part_PR_in_RAT_got viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enAC_part_PR_in_RAT_got] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epAC_part_PR_in_RAT_got](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edAC_part_PR_in_RAT_got showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[edAC_part_PR_in_RAT_got] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    [RAT_got].RAT_Rating AS got_RAT_Rating,
    [RAT_got].RAT_EQ AS got_RAT_EQ,
    tie.RAT_ID_got
FROM
    [dbo].[AC_part_PR_in_RAT_got] tie
LEFT JOIN
    [dbo].[eRAT_Rating](@equivalent) [RAT_got]
ON
    [RAT_got].RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edST_at_PR_isPlaying];
IF Object_ID('dbo.enST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enST_at_PR_isPlaying];
IF Object_ID('dbo.epST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epST_at_PR_isPlaying];
IF Object_ID('dbo.elST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elST_at_PR_isPlaying];
IF Object_ID('dbo.dST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dST_at_PR_isPlaying];
IF Object_ID('dbo.nST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[nST_at_PR_isPlaying];
IF Object_ID('dbo.pST_at_PR_isPlaying', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pST_at_PR_isPlaying];
IF Object_ID('dbo.lST_at_PR_isPlaying', 'V') IS NOT NULL
DROP VIEW [dbo].[lST_at_PR_isPlaying];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lST_at_PR_isPlaying] WITH SCHEMABINDING AS
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            [dbo].[ST_at_PR_isPlaying] sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pST_at_PR_isPlaying] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            [dbo].[ST_at_PR_isPlaying] sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        AND
            sub.ST_at_PR_isPlaying_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nST_at_PR_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nST_at_PR_isPlaying]
AS
SELECT
    *
FROM
    [dbo].[pST_at_PR_isPlaying](sysdatetime());
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
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elST_at_PR_isPlaying] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            [dbo].[ST_at_PR_isPlaying] sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
   );
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------------------
-- epST_at_PR_isPlaying viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epST_at_PR_isPlaying] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            max(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            [dbo].[ST_at_PR_isPlaying] sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
        AND
            sub.ST_at_PR_isPlaying_ChangedAt <= @changingTimepoint
   );
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enST_at_PR_isPlaying viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enST_at_PR_isPlaying] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epST_at_PR_isPlaying](@equivalent, sysdatetime());
GO
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-- edST_at_PR_isPlaying showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[edST_at_PR_isPlaying] (
    @equivalent tinyint,
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    [dbo].[ST_at_PR_isPlaying] tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.enAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.epAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.elAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.dAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.nAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[nAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.pAC_parent_AC_child_PAT_having', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pAC_parent_AC_child_PAT_having];
IF Object_ID('dbo.lAC_parent_AC_child_PAT_having', 'V') IS NOT NULL
DROP VIEW [dbo].[lAC_parent_AC_child_PAT_having];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lAC_parent_AC_child_PAT_having] WITH SCHEMABINDING AS
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].PAT_EQ AS having_PAT_EQ,
    tie.PAT_ID_having
FROM
    [dbo].[AC_parent_AC_child_PAT_having] tie
LEFT JOIN
    [dbo].[ePAT_ParentalType](0) [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pAC_parent_AC_child_PAT_having] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].PAT_EQ AS having_PAT_EQ,
    tie.PAT_ID_having
FROM
    [dbo].[AC_parent_AC_child_PAT_having] tie
LEFT JOIN
    [dbo].[ePAT_ParentalType](0) [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nAC_parent_AC_child_PAT_having viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nAC_parent_AC_child_PAT_having]
AS
SELECT
    *
FROM
    [dbo].[pAC_parent_AC_child_PAT_having](sysdatetime());
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elAC_parent_AC_child_PAT_having] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].PAT_EQ AS having_PAT_EQ,
    tie.PAT_ID_having
FROM
    [dbo].[AC_parent_AC_child_PAT_having] tie
LEFT JOIN
    [dbo].[ePAT_ParentalType](@equivalent) [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------------------
-- epAC_parent_AC_child_PAT_having viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epAC_parent_AC_child_PAT_having] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    [PAT_having].PAT_ParentalType AS having_PAT_ParentalType,
    [PAT_having].PAT_EQ AS having_PAT_EQ,
    tie.PAT_ID_having
FROM
    [dbo].[AC_parent_AC_child_PAT_having] tie
LEFT JOIN
    [dbo].[ePAT_ParentalType](@equivalent) [PAT_having]
ON
    [PAT_having].PAT_ID = tie.PAT_ID_having;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enAC_parent_AC_child_PAT_having viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enAC_parent_AC_child_PAT_having] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epAC_parent_AC_child_PAT_having](@equivalent, sysdatetime());
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.edPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[edPR_content_ST_location_EV_of];
IF Object_ID('dbo.enPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[enPR_content_ST_location_EV_of];
IF Object_ID('dbo.epPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[epPR_content_ST_location_EV_of];
IF Object_ID('dbo.elPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[elPR_content_ST_location_EV_of];
IF Object_ID('dbo.dPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dPR_content_ST_location_EV_of];
IF Object_ID('dbo.nPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [dbo].[nPR_content_ST_location_EV_of];
IF Object_ID('dbo.pPR_content_ST_location_EV_of', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pPR_content_ST_location_EV_of];
IF Object_ID('dbo.lPR_content_ST_location_EV_of', 'V') IS NOT NULL
DROP VIEW [dbo].[lPR_content_ST_location_EV_of];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lPR_content_ST_location_EV_of] WITH SCHEMABINDING AS
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    [dbo].[PR_content_ST_location_EV_of] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pPR_content_ST_location_EV_of] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    [dbo].[PR_content_ST_location_EV_of] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nPR_content_ST_location_EV_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nPR_content_ST_location_EV_of]
AS
SELECT
    *
FROM
    [dbo].[pPR_content_ST_location_EV_of](sysdatetime());
GO
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-- elPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[elPR_content_ST_location_EV_of] (
    @equivalent tinyint
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    [dbo].[PR_content_ST_location_EV_of] tie;
GO
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------------------
-- epPR_content_ST_location_EV_of viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[epPR_content_ST_location_EV_of] (
    @equivalent tinyint,
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    [dbo].[PR_content_ST_location_EV_of] tie;
GO
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-- enPR_content_ST_location_EV_of viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[enPR_content_ST_location_EV_of] (
    @equivalent tinyint
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[epPR_content_ST_location_EV_of](@equivalent, sysdatetime());
GO
