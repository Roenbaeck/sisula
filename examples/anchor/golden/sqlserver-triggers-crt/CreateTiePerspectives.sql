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
IF Object_ID('dbo.dSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.nSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.pSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.lSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.tSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_holder_OB_item_GRD_grade];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_holder_OB_item_GRD_grade viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_holder_OB_item_GRD_grade] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.SU_holder_OB_item_GRD_grade_ID,
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_Positor,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_holder_OB_item_GRD_grade_PositedAt,
    tie.SU_holder_OB_item_GRD_grade_Reliability,
    tie.SU_holder_OB_item_GRD_grade_Assertion,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    [dbo].[rSU_holder_OB_item_GRD_grade](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ID = (
        SELECT TOP 1
            sub.SU_holder_OB_item_GRD_grade_ID
        FROM
            [dbo].[rSU_holder_OB_item_GRD_grade](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ID_holder = tie.SU_ID_holder
        AND
            sub.OB_ID_item = tie.OB_ID_item
        AND
            sub.SU_holder_OB_item_GRD_grade_Assertion = isnull(@assertion, sub.SU_holder_OB_item_GRD_grade_Assertion)
        AND ( -- asked for positive or negative assertions: those at the latest changing time with an assertion that is
              -- not a retraction, which supersedes those at earlier changing times whatever its sign
            isnull(@assertion, '?') = '?'
        OR
            sub.SU_holder_OB_item_GRD_grade_ChangedAt = (
                SELECT
                    max(e.SU_holder_OB_item_GRD_grade_ChangedAt)
                FROM
                    [dbo].[rSU_holder_OB_item_GRD_grade](
                        @positor,
                        @changingTimepoint,
                        @positingTimepoint
                    ) e
                WHERE
                    e.SU_ID_holder = sub.SU_ID_holder
                AND
                    e.OB_ID_item = sub.OB_ID_item
                AND
                    e.SU_holder_OB_item_GRD_grade_Assertion <> '?'
            )
        )
        ORDER BY
            sub.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
            sub.SU_holder_OB_item_GRD_grade_PositedAt DESC,
            sub.SU_holder_OB_item_GRD_grade_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_holder_OB_item_GRD_grade] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_holder_OB_item_GRD_grade] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_holder_OB_item_GRD_grade] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_holder_OB_item_GRD_grade viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_holder_OB_item_GRD_grade]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_holder_OB_item_GRD_grade] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_holder_OB_item_GRD_grade showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_holder_OB_item_GRD_grade] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.*
FROM
    [dbo].[SU_holder_OB_item_GRD_grade] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dSU_keeper_OB_thing_GRD_rank', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.nSU_keeper_OB_thing_GRD_rank', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.pSU_keeper_OB_thing_GRD_rank', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.lSU_keeper_OB_thing_GRD_rank', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_keeper_OB_thing_GRD_rank];
IF Object_ID('dbo.tSU_keeper_OB_thing_GRD_rank', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_keeper_OB_thing_GRD_rank];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_keeper_OB_thing_GRD_rank viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_keeper_OB_thing_GRD_rank] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.SU_keeper_OB_thing_GRD_rank_ID,
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_Positor,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_keeper_OB_thing_GRD_rank_PositedAt,
    tie.SU_keeper_OB_thing_GRD_rank_Reliability,
    tie.SU_keeper_OB_thing_GRD_rank_Assertion,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    [dbo].[rSU_keeper_OB_thing_GRD_rank](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ID = (
        SELECT TOP 1
            sub.SU_keeper_OB_thing_GRD_rank_ID
        FROM
            [dbo].[rSU_keeper_OB_thing_GRD_rank](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
            sub.SU_ID_keeper = tie.SU_ID_keeper
        AND
            sub.OB_ID_thing = tie.OB_ID_thing
        AND
            sub.SU_keeper_OB_thing_GRD_rank_Assertion = isnull(@assertion, sub.SU_keeper_OB_thing_GRD_rank_Assertion)
        AND ( -- asked for positive or negative assertions: those at the latest changing time with an assertion that is
              -- not a retraction, which supersedes those at earlier changing times whatever its sign
            isnull(@assertion, '?') = '?'
        OR
            sub.SU_keeper_OB_thing_GRD_rank_ChangedAt = (
                SELECT
                    max(e.SU_keeper_OB_thing_GRD_rank_ChangedAt)
                FROM
                    [dbo].[rSU_keeper_OB_thing_GRD_rank](
                        @positor,
                        @changingTimepoint,
                        @positingTimepoint
                    ) e
                WHERE
                    e.SU_ID_keeper = sub.SU_ID_keeper
                AND
                    e.OB_ID_thing = sub.OB_ID_thing
                AND
                    e.SU_keeper_OB_thing_GRD_rank_Assertion <> '?'
            )
        )
        ORDER BY
            sub.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
            sub.SU_keeper_OB_thing_GRD_rank_PositedAt DESC,
            sub.SU_keeper_OB_thing_GRD_rank_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_keeper_OB_thing_GRD_rank] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_keeper_OB_thing_GRD_rank] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_keeper_OB_thing_GRD_rank] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_keeper_OB_thing_GRD_rank] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_keeper_OB_thing_GRD_rank viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_keeper_OB_thing_GRD_rank]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_keeper_OB_thing_GRD_rank] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_keeper_OB_thing_GRD_rank showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_keeper_OB_thing_GRD_rank] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.*
FROM
    [dbo].[SU_keeper_OB_thing_GRD_rank] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dOB_part_SU_owner', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dOB_part_SU_owner];
IF Object_ID('dbo.nOB_part_SU_owner', 'V') IS NOT NULL
DROP VIEW [dbo].[nOB_part_SU_owner];
IF Object_ID('dbo.pOB_part_SU_owner', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pOB_part_SU_owner];
IF Object_ID('dbo.lOB_part_SU_owner', 'V') IS NOT NULL
DROP VIEW [dbo].[lOB_part_SU_owner];
IF Object_ID('dbo.tOB_part_SU_owner', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tOB_part_SU_owner];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tOB_part_SU_owner viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tOB_part_SU_owner] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.OB_part_SU_owner_ID,
    tie.Metadata_OB_part_SU_owner,
    tie.OB_part_SU_owner_Positor,
    tie.OB_part_SU_owner_PositedAt,
    tie.OB_part_SU_owner_Reliability,
    tie.OB_part_SU_owner_Assertion,
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    [dbo].[rOB_part_SU_owner](
        @positor,
        @positingTimepoint
    ) tie
WHERE
    tie.OB_part_SU_owner_ID = (
        SELECT TOP 1
            sub.OB_part_SU_owner_ID
        FROM
            [dbo].[rOB_part_SU_owner](
                @positor,
                @positingTimepoint
            ) sub
        WHERE
            sub.OB_ID_part = tie.OB_ID_part
        AND
            sub.OB_part_SU_owner_Assertion = isnull(@assertion, sub.OB_part_SU_owner_Assertion)
        ORDER BY
            sub.OB_part_SU_owner_PositedAt DESC,
            sub.OB_part_SU_owner_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_part_SU_owner] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_part_SU_owner] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_part_SU_owner] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_part_SU_owner] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_part_SU_owner viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_part_SU_owner]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tOB_part_SU_owner] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Drop perspectives --------------------------------------------------------------------------------------------------
IF Object_ID('dbo.dSU_partner_SU_with', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_partner_SU_with];
IF Object_ID('dbo.nSU_partner_SU_with', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_partner_SU_with];
IF Object_ID('dbo.pSU_partner_SU_with', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_partner_SU_with];
IF Object_ID('dbo.lSU_partner_SU_with', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_partner_SU_with];
IF Object_ID('dbo.tSU_partner_SU_with', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[tSU_partner_SU_with];
GO
-- Time traveling perspective -----------------------------------------------------------------------------------------
-- tSU_partner_SU_with viewed as given by the input parameters
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[tSU_partner_SU_with] (
    @positor tinyint = 0,
    @changingTimepoint datetime2 = '9999-12-31',
    @positingTimepoint datetime2 = '9999-12-31',
    @assertion char(1) = null
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.SU_partner_SU_with_ID,
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_Positor,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_partner_SU_with_PositedAt,
    tie.SU_partner_SU_with_Reliability,
    tie.SU_partner_SU_with_Assertion,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[rSU_partner_SU_with](
        @positor,
        @changingTimepoint,
        @positingTimepoint
    ) tie
WHERE
    tie.SU_partner_SU_with_ID = (
        SELECT TOP 1
            sub.SU_partner_SU_with_ID
        FROM
            [dbo].[rSU_partner_SU_with](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) sub
        WHERE
        (
                sub.SU_ID_partner = tie.SU_ID_partner
            OR
                sub.SU_ID_with = tie.SU_ID_with
        )
        AND
            sub.SU_partner_SU_with_Assertion = isnull(@assertion, sub.SU_partner_SU_with_Assertion)
        AND ( -- asked for positive or negative assertions: those at the latest changing time with an assertion that is
              -- not a retraction, which supersedes those at earlier changing times whatever its sign
            isnull(@assertion, '?') = '?'
        OR
            sub.SU_partner_SU_with_ChangedAt = (
                SELECT
                    max(e.SU_partner_SU_with_ChangedAt)
                FROM
                    [dbo].[rSU_partner_SU_with](
                        @positor,
                        @changingTimepoint,
                        @positingTimepoint
                    ) e
                WHERE
                    e.SU_ID_partner = sub.SU_ID_partner
                AND
                    e.SU_ID_with = sub.SU_ID_with
                AND
                    e.SU_partner_SU_with_Assertion <> '?'
            )
        )
        ORDER BY
            sub.SU_partner_SU_with_ChangedAt DESC,
            sub.SU_partner_SU_with_PositedAt DESC,
            sub.SU_partner_SU_with_Reliability DESC
    );
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_partner_SU_with] AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_partner_SU_with] (
        p.Positor,
        DEFAULT,
        DEFAULT,
        '+'
    ) tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_partner_SU_with] (
    @changingTimepoint datetime2
)
RETURNS TABLE AS RETURN
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_partner_SU_with] (
        p.Positor,
        @changingTimepoint,
        DEFAULT,
        '+'
    ) tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_partner_SU_with viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_partner_SU_with]
AS
SELECT
    *
FROM
    [dbo].[_Positor] p
CROSS APPLY
    [dbo].[tSU_partner_SU_with] (
        p.Positor,
        sysdatetime(),
        DEFAULT,
        '+'
    ) tie;
GO
-- Difference perspective ---------------------------------------------------------------------------------------------
-- dSU_partner_SU_with showing all differences between the given timepoints
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[dSU_partner_SU_with] (
    @intervalStart datetime2,
    @intervalEnd datetime2
)
RETURNS TABLE AS RETURN
SELECT
    tie.*
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
