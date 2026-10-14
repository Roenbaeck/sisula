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
IF Object_ID('dbo.dSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[dSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.nSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[nSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.pSU_holder_OB_item_GRD_grade', 'IF') IS NOT NULL
DROP FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade];
IF Object_ID('dbo.lSU_holder_OB_item_GRD_grade', 'V') IS NOT NULL
DROP VIEW [dbo].[lSU_holder_OB_item_GRD_grade];
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_holder_OB_item_GRD_grade] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    [dbo].[SU_holder_OB_item_GRD_grade] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt = (
        SELECT
            max(sub.SU_holder_OB_item_GRD_grade_ChangedAt)
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade] sub
        WHERE
            sub.SU_ID_holder = tie.SU_ID_holder
        AND
            sub.OB_ID_item = tie.OB_ID_item
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_holder_OB_item_GRD_grade viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_holder_OB_item_GRD_grade] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
FROM
    [dbo].[SU_holder_OB_item_GRD_grade] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_grade]
ON
    [GRD_grade].GRD_ID = tie.GRD_ID_grade
WHERE
    tie.SU_holder_OB_item_GRD_grade_ChangedAt = (
        SELECT
            max(sub.SU_holder_OB_item_GRD_grade_ChangedAt)
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade] sub
        WHERE
            sub.SU_ID_holder = tie.SU_ID_holder
        AND
            sub.OB_ID_item = tie.OB_ID_item
        AND
            sub.SU_holder_OB_item_GRD_grade_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_holder_OB_item_GRD_grade viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_holder_OB_item_GRD_grade]
AS
SELECT
    *
FROM
    [dbo].[pSU_holder_OB_item_GRD_grade](sysdatetime());
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
    tie.Metadata_SU_holder_OB_item_GRD_grade,
    tie.SU_holder_OB_item_GRD_grade_ChangedAt,
    tie.SU_ID_holder,
    tie.OB_ID_item,
    [GRD_grade].GRD_Grade AS grade_GRD_Grade,
    [GRD_grade].Metadata_GRD AS grade_Metadata_GRD,
    tie.GRD_ID_grade
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_keeper_OB_thing_GRD_rank] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    [dbo].[SU_keeper_OB_thing_GRD_rank] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = (
        SELECT
            max(sub.SU_keeper_OB_thing_GRD_rank_ChangedAt)
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank] sub
        WHERE
            sub.SU_ID_keeper = tie.SU_ID_keeper
        AND
            sub.OB_ID_thing = tie.OB_ID_thing
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_keeper_OB_thing_GRD_rank viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_keeper_OB_thing_GRD_rank] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
FROM
    [dbo].[SU_keeper_OB_thing_GRD_rank] tie
LEFT JOIN
    [dbo].[GRD_Grade] [GRD_rank]
ON
    [GRD_rank].GRD_ID = tie.GRD_ID_rank
WHERE
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt = (
        SELECT
            max(sub.SU_keeper_OB_thing_GRD_rank_ChangedAt)
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank] sub
        WHERE
            sub.SU_ID_keeper = tie.SU_ID_keeper
        AND
            sub.OB_ID_thing = tie.OB_ID_thing
        AND
            sub.SU_keeper_OB_thing_GRD_rank_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_keeper_OB_thing_GRD_rank viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_keeper_OB_thing_GRD_rank]
AS
SELECT
    *
FROM
    [dbo].[pSU_keeper_OB_thing_GRD_rank](sysdatetime());
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
    tie.Metadata_SU_keeper_OB_thing_GRD_rank,
    tie.SU_keeper_OB_thing_GRD_rank_ChangedAt,
    tie.SU_ID_keeper,
    tie.OB_ID_thing,
    [GRD_rank].GRD_Grade AS rank_GRD_Grade,
    [GRD_rank].Metadata_GRD AS rank_Metadata_GRD,
    tie.GRD_ID_rank
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lOB_part_SU_owner] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_OB_part_SU_owner,
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    [dbo].[OB_part_SU_owner] tie;
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pOB_part_SU_owner viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pOB_part_SU_owner] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_OB_part_SU_owner,
    tie.OB_ID_part,
    tie.SU_ID_owner
FROM
    [dbo].[OB_part_SU_owner] tie;
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nOB_part_SU_owner viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nOB_part_SU_owner]
AS
SELECT
    *
FROM
    [dbo].[pOB_part_SU_owner](sysdatetime());
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
GO
-- Latest perspective -------------------------------------------------------------------------------------------------
-- lSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[lSU_partner_SU_with] WITH SCHEMABINDING AS
SELECT
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt = (
        SELECT
            max(sub.SU_partner_SU_with_ChangedAt)
        FROM
            [dbo].[SU_partner_SU_with] sub
        WHERE
            sub.SU_ID_partner = tie.SU_ID_partner
        OR
            sub.SU_ID_with = tie.SU_ID_with
   );
GO
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- pSU_partner_SU_with viewed by the latest available information (may include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[pSU_partner_SU_with] (
    @changingTimepoint datetime2
)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt = (
        SELECT
            max(sub.SU_partner_SU_with_ChangedAt)
        FROM
            [dbo].[SU_partner_SU_with] sub
        WHERE
        (
                sub.SU_ID_partner = tie.SU_ID_partner
            OR
                sub.SU_ID_with = tie.SU_ID_with
        )
        AND
            sub.SU_partner_SU_with_ChangedAt <= @changingTimepoint
   );
GO
-- Now perspective ----------------------------------------------------------------------------------------------------
-- nSU_partner_SU_with viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[nSU_partner_SU_with]
AS
SELECT
    *
FROM
    [dbo].[pSU_partner_SU_with](sysdatetime());
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
    tie.Metadata_SU_partner_SU_with,
    tie.SU_partner_SU_with_ChangedAt,
    tie.SU_ID_partner,
    tie.SU_ID_with
FROM
    [dbo].[SU_partner_SU_with] tie
WHERE
    tie.SU_partner_SU_with_ChangedAt BETWEEN @intervalStart AND @intervalEnd;
GO
