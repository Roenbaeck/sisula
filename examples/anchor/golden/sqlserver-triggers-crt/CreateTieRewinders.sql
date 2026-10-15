-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- These table valued functions rewind a tie posit table to the given
-- point in changing time, or a tie annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that
-- their union corresponds to all rows in the posit table.
--
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rSU_holder_OB_item_GRD_grade_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_holder_OB_item_GRD_grade_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_holder_OB_item_GRD_grade_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_holder_OB_item_GRD_grade_ID,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit]
    WHERE
        SU_holder_OB_item_GRD_grade_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fSU_holder_OB_item_GRD_grade_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_holder_OB_item_GRD_grade_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_holder_OB_item_GRD_grade_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_holder_OB_item_GRD_grade_ID,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit]
    WHERE
        SU_holder_OB_item_GRD_grade_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rSU_holder_OB_item_GRD_grade_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_holder_OB_item_GRD_grade_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_holder_OB_item_GRD_grade_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_Reliability,
        SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Annex]
    WHERE
        SU_holder_OB_item_GRD_grade_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rSU_holder_OB_item_GRD_grade rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_holder_OB_item_GRD_grade','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_holder_OB_item_GRD_grade] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_holder_OB_item_GRD_grade,
        p.SU_holder_OB_item_GRD_grade_ID,
        p.SU_ID_holder,
        p.OB_ID_item,
        p.GRD_ID_grade,
        p.SU_holder_OB_item_GRD_grade_ChangedAt,
        a.SU_holder_OB_item_GRD_grade_PositedAt,
        a.SU_holder_OB_item_GRD_grade_Positor,
        a.SU_holder_OB_item_GRD_grade_Reliability,
        a.SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[rSU_holder_OB_item_GRD_grade_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) a
    ON
        a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
    AND
        a.SU_holder_OB_item_GRD_grade_Positor = @positor
    AND
        a.SU_holder_OB_item_GRD_grade_PositedAt = (
            SELECT TOP 1
                sub.SU_holder_OB_item_GRD_grade_PositedAt
            FROM
                [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            AND
                sub.SU_holder_OB_item_GRD_grade_Positor = @positor
            ORDER BY
                sub.SU_holder_OB_item_GRD_grade_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fSU_holder_OB_item_GRD_grade forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_holder_OB_item_GRD_grade','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_holder_OB_item_GRD_grade] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_holder_OB_item_GRD_grade,
        p.SU_holder_OB_item_GRD_grade_ID,
        p.SU_ID_holder,
        p.OB_ID_item,
        p.GRD_ID_grade,
        p.SU_holder_OB_item_GRD_grade_ChangedAt,
        a.SU_holder_OB_item_GRD_grade_PositedAt,
        a.SU_holder_OB_item_GRD_grade_Positor,
        a.SU_holder_OB_item_GRD_grade_Reliability,
        a.SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[fSU_holder_OB_item_GRD_grade_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) a
    ON
        a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
    AND
        a.SU_holder_OB_item_GRD_grade_Positor = @positor
    AND
        a.SU_holder_OB_item_GRD_grade_PositedAt = (
            SELECT TOP 1
                sub.SU_holder_OB_item_GRD_grade_PositedAt
            FROM
                [dbo].[rSU_holder_OB_item_GRD_grade_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            AND
                sub.SU_holder_OB_item_GRD_grade_Positor = @positor
            ORDER BY
                sub.SU_holder_OB_item_GRD_grade_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rSU_keeper_OB_thing_GRD_rank_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_keeper_OB_thing_GRD_rank_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_keeper_OB_thing_GRD_rank_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit]
    WHERE
        SU_keeper_OB_thing_GRD_rank_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fSU_keeper_OB_thing_GRD_rank_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_keeper_OB_thing_GRD_rank_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_keeper_OB_thing_GRD_rank_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit]
    WHERE
        SU_keeper_OB_thing_GRD_rank_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rSU_keeper_OB_thing_GRD_rank_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_keeper_OB_thing_GRD_rank_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Annex]
    WHERE
        SU_keeper_OB_thing_GRD_rank_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rSU_keeper_OB_thing_GRD_rank rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_keeper_OB_thing_GRD_rank','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_keeper_OB_thing_GRD_rank] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ID,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        a.SU_keeper_OB_thing_GRD_rank_PositedAt,
        a.SU_keeper_OB_thing_GRD_rank_Positor,
        a.SU_keeper_OB_thing_GRD_rank_Reliability,
        a.SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[rSU_keeper_OB_thing_GRD_rank_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        a.SU_keeper_OB_thing_GRD_rank_Positor = @positor
    AND
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = (
            SELECT TOP 1
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt
            FROM
                [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            AND
                sub.SU_keeper_OB_thing_GRD_rank_Positor = @positor
            ORDER BY
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fSU_keeper_OB_thing_GRD_rank forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_keeper_OB_thing_GRD_rank','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_keeper_OB_thing_GRD_rank] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ID,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        a.SU_keeper_OB_thing_GRD_rank_PositedAt,
        a.SU_keeper_OB_thing_GRD_rank_Positor,
        a.SU_keeper_OB_thing_GRD_rank_Reliability,
        a.SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[fSU_keeper_OB_thing_GRD_rank_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        a.SU_keeper_OB_thing_GRD_rank_Positor = @positor
    AND
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = (
            SELECT TOP 1
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt
            FROM
                [dbo].[rSU_keeper_OB_thing_GRD_rank_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            AND
                sub.SU_keeper_OB_thing_GRD_rank_Positor = @positor
            ORDER BY
                sub.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rOB_part_SU_owner_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_part_SU_owner_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_part_SU_owner_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_Reliability,
        OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Annex]
    WHERE
        OB_part_SU_owner_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rOB_part_SU_owner rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_part_SU_owner','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_part_SU_owner] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_OB_part_SU_owner,
        p.OB_part_SU_owner_ID,
        p.OB_ID_part,
        p.SU_ID_owner,
        a.OB_part_SU_owner_PositedAt,
        a.OB_part_SU_owner_Positor,
        a.OB_part_SU_owner_Reliability,
        a.OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Posit] p
    JOIN
        [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) a
    ON
        a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
    AND
        a.OB_part_SU_owner_Positor = @positor
    AND
        a.OB_part_SU_owner_PositedAt = (
            SELECT TOP 1
                sub.OB_part_SU_owner_PositedAt
            FROM
                [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) sub
            WHERE
                sub.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            AND
                sub.OB_part_SU_owner_Positor = @positor
            ORDER BY
                sub.OB_part_SU_owner_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fOB_part_SU_owner forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fOB_part_SU_owner','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fOB_part_SU_owner] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_OB_part_SU_owner,
        p.OB_part_SU_owner_ID,
        p.OB_ID_part,
        p.SU_ID_owner,
        a.OB_part_SU_owner_PositedAt,
        a.OB_part_SU_owner_Positor,
        a.OB_part_SU_owner_Reliability,
        a.OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Posit] p
    JOIN
        [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) a
    ON
        a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
    AND
        a.OB_part_SU_owner_Positor = @positor
    AND
        a.OB_part_SU_owner_PositedAt = (
            SELECT TOP 1
                sub.OB_part_SU_owner_PositedAt
            FROM
                [dbo].[rOB_part_SU_owner_Annex](@positingTimepoint) sub
            WHERE
                sub.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            AND
                sub.OB_part_SU_owner_Positor = @positor
            ORDER BY
                sub.OB_part_SU_owner_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rSU_partner_SU_with_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_partner_SU_with_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_partner_SU_with_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_partner_SU_with_ID,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    FROM
        [dbo].[SU_partner_SU_with_Posit]
    WHERE
        SU_partner_SU_with_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fSU_partner_SU_with_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_partner_SU_with_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_partner_SU_with_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_partner_SU_with_ID,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_ChangedAt
    FROM
        [dbo].[SU_partner_SU_with_Posit]
    WHERE
        SU_partner_SU_with_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rSU_partner_SU_with_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_partner_SU_with_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_partner_SU_with_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_Reliability,
        SU_partner_SU_with_Assertion
    FROM
        [dbo].[SU_partner_SU_with_Annex]
    WHERE
        SU_partner_SU_with_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rSU_partner_SU_with rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_partner_SU_with','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_partner_SU_with] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_partner_SU_with,
        p.SU_partner_SU_with_ID,
        p.SU_ID_partner,
        p.SU_ID_with,
        p.SU_partner_SU_with_ChangedAt,
        a.SU_partner_SU_with_PositedAt,
        a.SU_partner_SU_with_Positor,
        a.SU_partner_SU_with_Reliability,
        a.SU_partner_SU_with_Assertion
    FROM
        [dbo].[rSU_partner_SU_with_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) a
    ON
        a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
    AND
        a.SU_partner_SU_with_Positor = @positor
    AND
        a.SU_partner_SU_with_PositedAt = (
            SELECT TOP 1
                sub.SU_partner_SU_with_PositedAt
            FROM
                [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            AND
                sub.SU_partner_SU_with_Positor = @positor
            ORDER BY
                sub.SU_partner_SU_with_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fSU_partner_SU_with forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_partner_SU_with','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_partner_SU_with] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_partner_SU_with,
        p.SU_partner_SU_with_ID,
        p.SU_ID_partner,
        p.SU_ID_with,
        p.SU_partner_SU_with_ChangedAt,
        a.SU_partner_SU_with_PositedAt,
        a.SU_partner_SU_with_Positor,
        a.SU_partner_SU_with_Reliability,
        a.SU_partner_SU_with_Assertion
    FROM
        [dbo].[fSU_partner_SU_with_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) a
    ON
        a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
    AND
        a.SU_partner_SU_with_Positor = @positor
    AND
        a.SU_partner_SU_with_PositedAt = (
            SELECT TOP 1
                sub.SU_partner_SU_with_PositedAt
            FROM
                [dbo].[rSU_partner_SU_with_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            AND
                sub.SU_partner_SU_with_Positor = @positor
            ORDER BY
                sub.SU_partner_SU_with_PositedAt DESC
        )
    ');
END
GO
