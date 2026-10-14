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
-- rAC_partner_AC_with_ONG_currently_Fact rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_partner_AC_with_ONG_currently_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_partner_AC_with_ONG_currently_Fact] (
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
        [ties].[AC_partner_AC_with_ONG_currently_Fact]
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fAC_partner_AC_with_ONG_currently_Fact forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fAC_partner_AC_with_ONG_currently_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fAC_partner_AC_with_ONG_currently_Fact] (
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
        [ties].[AC_partner_AC_with_ONG_currently_Fact]
    WHERE
        AC_partner_AC_with_ONG_currently_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently_Meta rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_partner_AC_with_ONG_currently_Meta','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_partner_AC_with_ONG_currently_Meta] (
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Who,
        AC_partner_AC_with_ONG_currently_Confidence,
        AC_partner_AC_with_ONG_currently_Stance
    FROM
        [ties].[AC_partner_AC_with_ONG_currently_Meta]
    WHERE
        AC_partner_AC_with_ONG_currently_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_partner_AC_with_ONG_currently rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_partner_AC_with_ONG_currently','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_partner_AC_with_ONG_currently] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Who,
        a.AC_partner_AC_with_ONG_currently_Confidence,
        a.AC_partner_AC_with_ONG_currently_Stance
    FROM
        [ties].[rAC_partner_AC_with_ONG_currently_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rAC_partner_AC_with_ONG_currently_Meta](@positingTimepoint) a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_Who = @positor
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = (
            SELECT TOP 1
                sub.AC_partner_AC_with_ONG_currently_PositedAt
            FROM
                [ties].[rAC_partner_AC_with_ONG_currently_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                sub.AC_partner_AC_with_ONG_currently_Who = @positor
            ORDER BY
                sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_partner_AC_with_ONG_currently forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fAC_partner_AC_with_ONG_currently','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fAC_partner_AC_with_ONG_currently] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Who,
        a.AC_partner_AC_with_ONG_currently_Confidence,
        a.AC_partner_AC_with_ONG_currently_Stance
    FROM
        [ties].[fAC_partner_AC_with_ONG_currently_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rAC_partner_AC_with_ONG_currently_Meta](@positingTimepoint) a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_Who = @positor
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = (
            SELECT TOP 1
                sub.AC_partner_AC_with_ONG_currently_PositedAt
            FROM
                [ties].[rAC_partner_AC_with_ONG_currently_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                sub.AC_partner_AC_with_ONG_currently_Who = @positor
            ORDER BY
                sub.AC_partner_AC_with_ONG_currently_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_subset_PN_of_Meta rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_subset_PN_of_Meta','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_subset_PN_of_Meta] (
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Who,
        AC_subset_PN_of_Confidence,
        AC_subset_PN_of_Stance
    FROM
        [ties].[AC_subset_PN_of_Meta]
    WHERE
        AC_subset_PN_of_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_subset_PN_of rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_subset_PN_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_subset_PN_of] (
        @positor smallint = 0,
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Who,
        a.AC_subset_PN_of_Confidence,
        a.AC_subset_PN_of_Stance
    FROM
        [ties].[AC_subset_PN_of_Fact] p
    JOIN
        [ties].[rAC_subset_PN_of_Meta](@positingTimepoint) a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_Who = @positor
    AND
        a.AC_subset_PN_of_PositedAt = (
            SELECT TOP 1
                sub.AC_subset_PN_of_PositedAt
            FROM
                [ties].[rAC_subset_PN_of_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                sub.AC_subset_PN_of_Who = @positor
            ORDER BY
                sub.AC_subset_PN_of_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_subset_PN_of forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fAC_subset_PN_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fAC_subset_PN_of] (
        @positor smallint = 0,
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Who,
        a.AC_subset_PN_of_Confidence,
        a.AC_subset_PN_of_Stance
    FROM
        [ties].[AC_subset_PN_of_Fact] p
    JOIN
        [ties].[rAC_subset_PN_of_Meta](@positingTimepoint) a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_Who = @positor
    AND
        a.AC_subset_PN_of_PositedAt = (
            SELECT TOP 1
                sub.AC_subset_PN_of_PositedAt
            FROM
                [ties].[rAC_subset_PN_of_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                sub.AC_subset_PN_of_Who = @positor
            ORDER BY
                sub.AC_subset_PN_of_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rEV_in_AC_wasCast_Meta rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rEV_in_AC_wasCast_Meta','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rEV_in_AC_wasCast_Meta] (
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Who,
        EV_in_AC_wasCast_Confidence,
        EV_in_AC_wasCast_Stance
    FROM
        [ties].[EV_in_AC_wasCast_Meta]
    WHERE
        EV_in_AC_wasCast_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rEV_in_AC_wasCast rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rEV_in_AC_wasCast','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rEV_in_AC_wasCast] (
        @positor smallint = 0,
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Who,
        a.EV_in_AC_wasCast_Confidence,
        a.EV_in_AC_wasCast_Stance
    FROM
        [ties].[EV_in_AC_wasCast_Fact] p
    JOIN
        [ties].[rEV_in_AC_wasCast_Meta](@positingTimepoint) a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_Who = @positor
    AND
        a.EV_in_AC_wasCast_PositedAt = (
            SELECT TOP 1
                sub.EV_in_AC_wasCast_PositedAt
            FROM
                [ties].[rEV_in_AC_wasCast_Meta](@positingTimepoint) sub
            WHERE
                sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            AND
                sub.EV_in_AC_wasCast_Who = @positor
            ORDER BY
                sub.EV_in_AC_wasCast_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fEV_in_AC_wasCast forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fEV_in_AC_wasCast','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fEV_in_AC_wasCast] (
        @positor smallint = 0,
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Who,
        a.EV_in_AC_wasCast_Confidence,
        a.EV_in_AC_wasCast_Stance
    FROM
        [ties].[EV_in_AC_wasCast_Fact] p
    JOIN
        [ties].[rEV_in_AC_wasCast_Meta](@positingTimepoint) a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_Who = @positor
    AND
        a.EV_in_AC_wasCast_PositedAt = (
            SELECT TOP 1
                sub.EV_in_AC_wasCast_PositedAt
            FROM
                [ties].[rEV_in_AC_wasCast_Meta](@positingTimepoint) sub
            WHERE
                sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            AND
                sub.EV_in_AC_wasCast_Who = @positor
            ORDER BY
                sub.EV_in_AC_wasCast_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got_Fact rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_part_PR_in_RAT_got_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_part_PR_in_RAT_got_Fact] (
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
        [ties].[AC_part_PR_in_RAT_got_Fact]
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fAC_part_PR_in_RAT_got_Fact forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fAC_part_PR_in_RAT_got_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fAC_part_PR_in_RAT_got_Fact] (
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
        [ties].[AC_part_PR_in_RAT_got_Fact]
    WHERE
        AC_part_PR_in_RAT_got_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got_Meta rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_part_PR_in_RAT_got_Meta','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_part_PR_in_RAT_got_Meta] (
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Who,
        AC_part_PR_in_RAT_got_Confidence,
        AC_part_PR_in_RAT_got_Stance
    FROM
        [ties].[AC_part_PR_in_RAT_got_Meta]
    WHERE
        AC_part_PR_in_RAT_got_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_part_PR_in_RAT_got rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_part_PR_in_RAT_got','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_part_PR_in_RAT_got] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Who,
        a.AC_part_PR_in_RAT_got_Confidence,
        a.AC_part_PR_in_RAT_got_Stance
    FROM
        [ties].[rAC_part_PR_in_RAT_got_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rAC_part_PR_in_RAT_got_Meta](@positingTimepoint) a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_Who = @positor
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = (
            SELECT TOP 1
                sub.AC_part_PR_in_RAT_got_PositedAt
            FROM
                [ties].[rAC_part_PR_in_RAT_got_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            AND
                sub.AC_part_PR_in_RAT_got_Who = @positor
            ORDER BY
                sub.AC_part_PR_in_RAT_got_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_part_PR_in_RAT_got forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fAC_part_PR_in_RAT_got','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fAC_part_PR_in_RAT_got] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Who,
        a.AC_part_PR_in_RAT_got_Confidence,
        a.AC_part_PR_in_RAT_got_Stance
    FROM
        [ties].[fAC_part_PR_in_RAT_got_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rAC_part_PR_in_RAT_got_Meta](@positingTimepoint) a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_Who = @positor
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = (
            SELECT TOP 1
                sub.AC_part_PR_in_RAT_got_PositedAt
            FROM
                [ties].[rAC_part_PR_in_RAT_got_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            AND
                sub.AC_part_PR_in_RAT_got_Who = @positor
            ORDER BY
                sub.AC_part_PR_in_RAT_got_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying_Fact rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rST_at_PR_isPlaying_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rST_at_PR_isPlaying_Fact] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_at_PR_isPlaying_ID,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    FROM
        [ties].[ST_at_PR_isPlaying_Fact]
    WHERE
        ST_at_PR_isPlaying_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fST_at_PR_isPlaying_Fact forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fST_at_PR_isPlaying_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fST_at_PR_isPlaying_Fact] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_at_PR_isPlaying_ID,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_ChangedAt
    FROM
        [ties].[ST_at_PR_isPlaying_Fact]
    WHERE
        ST_at_PR_isPlaying_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying_Meta rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rST_at_PR_isPlaying_Meta','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rST_at_PR_isPlaying_Meta] (
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Who,
        ST_at_PR_isPlaying_Confidence,
        ST_at_PR_isPlaying_Stance
    FROM
        [ties].[ST_at_PR_isPlaying_Meta]
    WHERE
        ST_at_PR_isPlaying_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rST_at_PR_isPlaying rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rST_at_PR_isPlaying','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rST_at_PR_isPlaying] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Who,
        a.ST_at_PR_isPlaying_Confidence,
        a.ST_at_PR_isPlaying_Stance
    FROM
        [ties].[rST_at_PR_isPlaying_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rST_at_PR_isPlaying_Meta](@positingTimepoint) a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_Who = @positor
    AND
        a.ST_at_PR_isPlaying_PositedAt = (
            SELECT TOP 1
                sub.ST_at_PR_isPlaying_PositedAt
            FROM
                [ties].[rST_at_PR_isPlaying_Meta](@positingTimepoint) sub
            WHERE
                sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            AND
                sub.ST_at_PR_isPlaying_Who = @positor
            ORDER BY
                sub.ST_at_PR_isPlaying_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fST_at_PR_isPlaying forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fST_at_PR_isPlaying','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fST_at_PR_isPlaying] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Who,
        a.ST_at_PR_isPlaying_Confidence,
        a.ST_at_PR_isPlaying_Stance
    FROM
        [ties].[fST_at_PR_isPlaying_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rST_at_PR_isPlaying_Meta](@positingTimepoint) a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_Who = @positor
    AND
        a.ST_at_PR_isPlaying_PositedAt = (
            SELECT TOP 1
                sub.ST_at_PR_isPlaying_PositedAt
            FROM
                [ties].[rST_at_PR_isPlaying_Meta](@positingTimepoint) sub
            WHERE
                sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            AND
                sub.ST_at_PR_isPlaying_Who = @positor
            ORDER BY
                sub.ST_at_PR_isPlaying_PositedAt DESC
        )
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rAC_parent_AC_child_PAT_having_Meta rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_parent_AC_child_PAT_having_Meta','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_parent_AC_child_PAT_having_Meta] (
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Who,
        AC_parent_AC_child_PAT_having_Confidence,
        AC_parent_AC_child_PAT_having_Stance
    FROM
        [ties].[AC_parent_AC_child_PAT_having_Meta]
    WHERE
        AC_parent_AC_child_PAT_having_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rAC_parent_AC_child_PAT_having rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rAC_parent_AC_child_PAT_having','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rAC_parent_AC_child_PAT_having] (
        @positor smallint = 0,
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Who,
        a.AC_parent_AC_child_PAT_having_Confidence,
        a.AC_parent_AC_child_PAT_having_Stance
    FROM
        [ties].[AC_parent_AC_child_PAT_having_Fact] p
    JOIN
        [ties].[rAC_parent_AC_child_PAT_having_Meta](@positingTimepoint) a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_Who = @positor
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = (
            SELECT TOP 1
                sub.AC_parent_AC_child_PAT_having_PositedAt
            FROM
                [ties].[rAC_parent_AC_child_PAT_having_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            AND
                sub.AC_parent_AC_child_PAT_having_Who = @positor
            ORDER BY
                sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fAC_parent_AC_child_PAT_having forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fAC_parent_AC_child_PAT_having','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fAC_parent_AC_child_PAT_having] (
        @positor smallint = 0,
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Who,
        a.AC_parent_AC_child_PAT_having_Confidence,
        a.AC_parent_AC_child_PAT_having_Stance
    FROM
        [ties].[AC_parent_AC_child_PAT_having_Fact] p
    JOIN
        [ties].[rAC_parent_AC_child_PAT_having_Meta](@positingTimepoint) a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_Who = @positor
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = (
            SELECT TOP 1
                sub.AC_parent_AC_child_PAT_having_PositedAt
            FROM
                [ties].[rAC_parent_AC_child_PAT_having_Meta](@positingTimepoint) sub
            WHERE
                sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            AND
                sub.AC_parent_AC_child_PAT_having_Who = @positor
            ORDER BY
                sub.AC_parent_AC_child_PAT_having_PositedAt DESC
        )
    ');
END
GO
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-- rPR_content_ST_location_EV_of_Fact rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rPR_content_ST_location_EV_of_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rPR_content_ST_location_EV_of_Fact] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_content_ST_location_EV_of_ID,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_ChangedAt
    FROM
        [ties].[PR_content_ST_location_EV_of_Fact]
    WHERE
        PR_content_ST_location_EV_of_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-- fPR_content_ST_location_EV_of_Fact forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fPR_content_ST_location_EV_of_Fact','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fPR_content_ST_location_EV_of_Fact] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_content_ST_location_EV_of_ID,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_ChangedAt
    FROM
        [ties].[PR_content_ST_location_EV_of_Fact]
    WHERE
        PR_content_ST_location_EV_of_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-- rPR_content_ST_location_EV_of_Meta rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rPR_content_ST_location_EV_of_Meta','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rPR_content_ST_location_EV_of_Meta] (
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Who,
        PR_content_ST_location_EV_of_Confidence,
        PR_content_ST_location_EV_of_Stance
    FROM
        [ties].[PR_content_ST_location_EV_of_Meta]
    WHERE
        PR_content_ST_location_EV_of_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-- rPR_content_ST_location_EV_of rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.rPR_content_ST_location_EV_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[rPR_content_ST_location_EV_of] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        p.PR_content_ST_location_EV_of_ChangedAt,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Who,
        a.PR_content_ST_location_EV_of_Confidence,
        a.PR_content_ST_location_EV_of_Stance
    FROM
        [ties].[rPR_content_ST_location_EV_of_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rPR_content_ST_location_EV_of_Meta](@positingTimepoint) a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_Who = @positor
    AND
        a.PR_content_ST_location_EV_of_PositedAt = (
            SELECT TOP 1
                sub.PR_content_ST_location_EV_of_PositedAt
            FROM
                [ties].[rPR_content_ST_location_EV_of_Meta](@positingTimepoint) sub
            WHERE
                sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            AND
                sub.PR_content_ST_location_EV_of_Who = @positor
            ORDER BY
                sub.PR_content_ST_location_EV_of_PositedAt DESC
        )
    ');
END
GO
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-- fPR_content_ST_location_EV_of forwarding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.fPR_content_ST_location_EV_of','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [ties].[fPR_content_ST_location_EV_of] (
        @positor smallint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2(3) = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        p.PR_content_ST_location_EV_of_ChangedAt,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Who,
        a.PR_content_ST_location_EV_of_Confidence,
        a.PR_content_ST_location_EV_of_Stance
    FROM
        [ties].[fPR_content_ST_location_EV_of_Fact](@changingTimepoint) p 
    JOIN
        [ties].[rPR_content_ST_location_EV_of_Meta](@positingTimepoint) a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_Who = @positor
    AND
        a.PR_content_ST_location_EV_of_PositedAt = (
            SELECT TOP 1
                sub.PR_content_ST_location_EV_of_PositedAt
            FROM
                [ties].[rPR_content_ST_location_EV_of_Meta](@positingTimepoint) sub
            WHERE
                sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            AND
                sub.PR_content_ST_location_EV_of_Who = @positor
            ORDER BY
                sub.PR_content_ST_location_EV_of_PositedAt DESC
        )
    ');
END
GO
