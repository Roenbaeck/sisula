-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- These table valued functions rewind a tie posit table to the given
-- point in changing time, or a tie annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that 
-- their union corresponds to all rows in the posit table.
--
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_partner_AC_with_ONG_currently_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_partner_AC_with_ONG_currently_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_partner_AC_with_ONG_currently_ID,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Posit]
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fAC_partner_AC_with_ONG_currently_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_partner_AC_with_ONG_currently_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_partner_AC_with_ONG_currently_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_partner_AC_with_ONG_currently_ID,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Posit]
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_partner_AC_with_ONG_currently_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_partner_AC_with_ONG_currently_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently_Annex]
    WHERE
        AC_partner_AC_with_ONG_currently_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_partner_AC_with_ONG_currently','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_partner_AC_with_ONG_currently] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        [dbo].[rAC_partner_AC_with_ONG_currently_Posit](@changingTimepoint) p 
    JOIN
        [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = (
            SELECT TOP 1
                sub.AC_partner_AC_with_ONG_currently_PositedAt
            FROM
                [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            ORDER BY
                sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_partner_AC_with_ONG_currently forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_partner_AC_with_ONG_currently','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_partner_AC_with_ONG_currently] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        [dbo].[fAC_partner_AC_with_ONG_currently_Posit](@changingTimepoint) p 
    JOIN
        [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = (
            SELECT TOP 1
                sub.AC_partner_AC_with_ONG_currently_PositedAt
            FROM
                [dbo].[rAC_partner_AC_with_ONG_currently_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            ORDER BY
                sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_subset_PN_of_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_subset_PN_of_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_subset_PN_of_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    FROM
        [dbo].[AC_subset_PN_of_Annex]
    WHERE
        AC_subset_PN_of_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_subset_PN_of rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_subset_PN_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_subset_PN_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Reliability
    FROM
        [dbo].[AC_subset_PN_of_Posit] p
    JOIN
        [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_PositedAt = (
            SELECT TOP 1
                sub.AC_subset_PN_of_PositedAt
            FROM
                [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            ORDER BY
                sub.AC_subset_PN_of_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_subset_PN_of forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_subset_PN_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_subset_PN_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Reliability
    FROM
        [dbo].[AC_subset_PN_of_Posit] p
    JOIN
        [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_PositedAt = (
            SELECT TOP 1
                sub.AC_subset_PN_of_PositedAt
            FROM
                [dbo].[rAC_subset_PN_of_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            ORDER BY
                sub.AC_subset_PN_of_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rEV_in_AC_wasCast_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_in_AC_wasCast_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_in_AC_wasCast_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    FROM
        [dbo].[EV_in_AC_wasCast_Annex]
    WHERE
        EV_in_AC_wasCast_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rEV_in_AC_wasCast rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_in_AC_wasCast','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_in_AC_wasCast] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Reliability
    FROM
        [dbo].[EV_in_AC_wasCast_Posit] p
    JOIN
        [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_PositedAt = (
            SELECT TOP 1
                sub.EV_in_AC_wasCast_PositedAt
            FROM
                [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            ORDER BY
                sub.EV_in_AC_wasCast_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fEV_in_AC_wasCast forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fEV_in_AC_wasCast','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fEV_in_AC_wasCast] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Reliability
    FROM
        [dbo].[EV_in_AC_wasCast_Posit] p
    JOIN
        [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_PositedAt = (
            SELECT TOP 1
                sub.EV_in_AC_wasCast_PositedAt
            FROM
                [dbo].[rEV_in_AC_wasCast_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            ORDER BY
                sub.EV_in_AC_wasCast_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_part_PR_in_RAT_got_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_part_PR_in_RAT_got_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_part_PR_in_RAT_got_ID,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedAt
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Posit]
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fAC_part_PR_in_RAT_got_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_part_PR_in_RAT_got_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_part_PR_in_RAT_got_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_part_PR_in_RAT_got_ID,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_ChangedAt
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Posit]
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_part_PR_in_RAT_got_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_part_PR_in_RAT_got_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    FROM
        [dbo].[AC_part_PR_in_RAT_got_Annex]
    WHERE
        AC_part_PR_in_RAT_got_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_part_PR_in_RAT_got','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_part_PR_in_RAT_got] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Reliability
    FROM
        [dbo].[rAC_part_PR_in_RAT_got_Posit](@changingTimepoint) p 
    JOIN
        [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = (
            SELECT TOP 1
                sub.AC_part_PR_in_RAT_got_PositedAt
            FROM
                [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            ORDER BY
                sub.AC_part_PR_in_RAT_got_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_part_PR_in_RAT_got forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_part_PR_in_RAT_got','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_part_PR_in_RAT_got] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Reliability
    FROM
        [dbo].[fAC_part_PR_in_RAT_got_Posit](@changingTimepoint) p 
    JOIN
        [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = (
            SELECT TOP 1
                sub.AC_part_PR_in_RAT_got_PositedAt
            FROM
                [dbo].[rAC_part_PR_in_RAT_got_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            ORDER BY
                sub.AC_part_PR_in_RAT_got_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_at_PR_isPlaying_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_at_PR_isPlaying_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_at_PR_isPlaying_ID,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    FROM
        [dbo].[ST_at_PR_isPlaying_Posit]
    WHERE
        ST_at_PR_isPlaying_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fST_at_PR_isPlaying_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_at_PR_isPlaying_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_at_PR_isPlaying_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_at_PR_isPlaying_ID,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    FROM
        [dbo].[ST_at_PR_isPlaying_Posit]
    WHERE
        ST_at_PR_isPlaying_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_at_PR_isPlaying_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_at_PR_isPlaying_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    FROM
        [dbo].[ST_at_PR_isPlaying_Annex]
    WHERE
        ST_at_PR_isPlaying_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_at_PR_isPlaying','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_at_PR_isPlaying] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Reliability
    FROM
        [dbo].[rST_at_PR_isPlaying_Posit](@changingTimepoint) p 
    JOIN
        [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_PositedAt = (
            SELECT TOP 1
                sub.ST_at_PR_isPlaying_PositedAt
            FROM
                [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            ORDER BY
                sub.ST_at_PR_isPlaying_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fST_at_PR_isPlaying forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_at_PR_isPlaying','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_at_PR_isPlaying] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Reliability
    FROM
        [dbo].[fST_at_PR_isPlaying_Posit](@changingTimepoint) p 
    JOIN
        [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_PositedAt = (
            SELECT TOP 1
                sub.ST_at_PR_isPlaying_PositedAt
            FROM
                [dbo].[rST_at_PR_isPlaying_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            ORDER BY
                sub.ST_at_PR_isPlaying_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_parent_AC_child_PAT_having_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_parent_AC_child_PAT_having_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_parent_AC_child_PAT_having_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    FROM
        [dbo].[AC_parent_AC_child_PAT_having_Annex]
    WHERE
        AC_parent_AC_child_PAT_having_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_parent_AC_child_PAT_having rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_parent_AC_child_PAT_having','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_parent_AC_child_PAT_having] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Reliability
    FROM
        [dbo].[AC_parent_AC_child_PAT_having_Posit] p
    JOIN
        [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = (
            SELECT TOP 1
                sub.AC_parent_AC_child_PAT_having_PositedAt
            FROM
                [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            ORDER BY
                sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_parent_AC_child_PAT_having forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_parent_AC_child_PAT_having','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_parent_AC_child_PAT_having] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Reliability
    FROM
        [dbo].[AC_parent_AC_child_PAT_having_Posit] p
    JOIN
        [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = (
            SELECT TOP 1
                sub.AC_parent_AC_child_PAT_having_PositedAt
            FROM
                [dbo].[rAC_parent_AC_child_PAT_having_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            ORDER BY
                sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rPR_content_ST_location_EV_of_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_content_ST_location_EV_of_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_content_ST_location_EV_of_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    FROM
        [dbo].[PR_content_ST_location_EV_of_Annex]
    WHERE
        PR_content_ST_location_EV_of_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rPR_content_ST_location_EV_of rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_content_ST_location_EV_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_content_ST_location_EV_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Reliability
    FROM
        [dbo].[PR_content_ST_location_EV_of_Posit] p
    JOIN
        [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_PositedAt = (
            SELECT TOP 1
                sub.PR_content_ST_location_EV_of_PositedAt
            FROM
                [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            ORDER BY
                sub.PR_content_ST_location_EV_of_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fPR_content_ST_location_EV_of forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fPR_content_ST_location_EV_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fPR_content_ST_location_EV_of] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Reliability
    FROM
        [dbo].[PR_content_ST_location_EV_of_Posit] p
    JOIN
        [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_PositedAt = (
            SELECT TOP 1
                sub.PR_content_ST_location_EV_of_PositedAt
            FROM
                [dbo].[rPR_content_ST_location_EV_of_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            ORDER BY
                sub.PR_content_ST_location_EV_of_PositedAt DESC
        )
    ');
END
GO
