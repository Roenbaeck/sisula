-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the 
-- union of the two will produce all rows in a posit table.
--
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_DAT_Event_Date_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_DAT_Event_Date_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_DAT_Event_Date_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    FROM
        [dbo].[EV_DAT_Event_Date_Annex]
    WHERE
        EV_DAT_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_DAT_Event_Date rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_DAT_Event_Date','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_DAT_Event_Date] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_DAT,
        p.EV_DAT_ID,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Reliability,
        p.EV_DAT_EV_ID,
        p.EV_DAT_Event_Date
    FROM
        [dbo].[EV_DAT_Event_Date_Posit] p
    JOIN
        [dbo].[rEV_DAT_Event_Date_Annex](@positingTimepoint) a
    ON
        a.EV_DAT_ID = p.EV_DAT_ID
    AND
        a.EV_DAT_PositedAt = (
            SELECT TOP 1
                sub.EV_DAT_PositedAt
            FROM
                [dbo].[rEV_DAT_Event_Date_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_DAT_ID = p.EV_DAT_ID
            ORDER BY
                sub.EV_DAT_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_AUD_Event_Audience_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_AUD_Event_Audience_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_AUD_Event_Audience_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    FROM
        [dbo].[EV_AUD_Event_Audience_Annex]
    WHERE
        EV_AUD_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_AUD_Event_Audience rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_AUD_Event_Audience','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_AUD_Event_Audience] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_AUD,
        p.EV_AUD_ID,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Reliability,
        p.EV_AUD_EV_ID,
        p.EV_AUD_Event_Audience
    FROM
        [dbo].[EV_AUD_Event_Audience_Posit] p
    JOIN
        [dbo].[rEV_AUD_Event_Audience_Annex](@positingTimepoint) a
    ON
        a.EV_AUD_ID = p.EV_AUD_ID
    AND
        a.EV_AUD_PositedAt = (
            SELECT TOP 1
                sub.EV_AUD_PositedAt
            FROM
                [dbo].[rEV_AUD_Event_Audience_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_AUD_ID = p.EV_AUD_ID
            ORDER BY
                sub.EV_AUD_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_REV_Event_Revenue_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_REV_Event_Revenue_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_REV_Event_Revenue_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    FROM
        [dbo].[EV_REV_Event_Revenue_Annex]
    WHERE
        EV_REV_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_REV_Event_Revenue rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_REV_Event_Revenue','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_REV_Event_Revenue] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_REV,
        p.EV_REV_ID,
        a.EV_REV_PositedAt,
        a.EV_REV_Reliability,
        p.EV_REV_EV_ID,
        p.EV_REV_Event_Revenue
    FROM
        [dbo].[EV_REV_Event_Revenue_Posit] p
    JOIN
        [dbo].[rEV_REV_Event_Revenue_Annex](@positingTimepoint) a
    ON
        a.EV_REV_ID = p.EV_REV_ID
    AND
        a.EV_REV_PositedAt = (
            SELECT TOP 1
                sub.EV_REV_PositedAt
            FROM
                [dbo].[rEV_REV_Event_Revenue_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_REV_ID = p.EV_REV_ID
            ORDER BY
                sub.EV_REV_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_NAM_ID,
        ST_NAM_ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [dbo].[ST_NAM_Stage_Name_Posit]
    WHERE
        ST_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fST_NAM_Stage_Name_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_NAM_Stage_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_NAM_Stage_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_NAM_ID,
        ST_NAM_ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [dbo].[ST_NAM_Stage_Name_Posit]
    WHERE
        ST_NAM_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    FROM
        [dbo].[ST_NAM_Stage_Name_Annex]
    WHERE
        ST_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_NAM_Stage_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt
    FROM
        [dbo].[rST_NAM_Stage_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = (
            SELECT TOP 1
                sub.ST_NAM_PositedAt
            FROM
                [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_NAM_ID = p.ST_NAM_ID
            ORDER BY
                sub.ST_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fST_NAM_Stage_Name forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_NAM_Stage_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Reliability,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt
    FROM
        [dbo].[fST_NAM_Stage_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_PositedAt = (
            SELECT TOP 1
                sub.ST_NAM_PositedAt
            FROM
                [dbo].[rST_NAM_Stage_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_NAM_ID = p.ST_NAM_ID
            ORDER BY
                sub.ST_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preST_NAM_Stage_Name function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preST_NAM_Stage_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preST_NAM_Stage_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.ST_NAM_Stage_Name
        FROM
            [dbo].[rST_NAM_Stage_Name](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.ST_NAM_ST_ID = @id
        AND
            pre.ST_NAM_ChangedAt < @changingTimepoint
        AND
            pre.ST_NAM_Reliability = 1
        ORDER BY
            pre.ST_NAM_ChangedAt DESC,
            pre.ST_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folST_NAM_Stage_Name function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folST_NAM_Stage_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folST_NAM_Stage_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.ST_NAM_Stage_Name
        FROM
            [dbo].[fST_NAM_Stage_Name](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.ST_NAM_ST_ID = @id
        AND
            fol.ST_NAM_ChangedAt > @changingTimepoint
        AND
            fol.ST_NAM_Reliability = 1
        ORDER BY
            fol.ST_NAM_ChangedAt ASC,
            fol.ST_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_LOC_Stage_Location_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_LOC_Stage_Location_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_LOC_Stage_Location_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    FROM
        [dbo].[ST_LOC_Stage_Location_Annex]
    WHERE
        ST_LOC_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_LOC_Stage_Location rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_LOC_Stage_Location','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_LOC_Stage_Location] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_LOC,
        p.ST_LOC_ID,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Reliability,
        p.ST_LOC_ST_ID,
        p.ST_LOC_Checksum,
        p.ST_LOC_Stage_Location
    FROM
        [dbo].[ST_LOC_Stage_Location_Posit] p
    JOIN
        [dbo].[rST_LOC_Stage_Location_Annex](@positingTimepoint) a
    ON
        a.ST_LOC_ID = p.ST_LOC_ID
    AND
        a.ST_LOC_PositedAt = (
            SELECT TOP 1
                sub.ST_LOC_PositedAt
            FROM
                [dbo].[rST_LOC_Stage_Location_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_LOC_ID = p.ST_LOC_ID
            ORDER BY
                sub.ST_LOC_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [dbo].[ST_AVG_Stage_Average_Posit]
    WHERE
        ST_AVG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fST_AVG_Stage_Average_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_AVG_Stage_Average_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_AVG_Stage_Average_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [dbo].[ST_AVG_Stage_Average_Posit]
    WHERE
        ST_AVG_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    FROM
        [dbo].[ST_AVG_Stage_Average_Annex]
    WHERE
        ST_AVG_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_AVG_Stage_Average] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt
    FROM
        [dbo].[rST_AVG_Stage_Average_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = (
            SELECT TOP 1
                sub.ST_AVG_PositedAt
            FROM
                [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_AVG_ID = p.ST_AVG_ID
            ORDER BY
                sub.ST_AVG_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fST_AVG_Stage_Average forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fST_AVG_Stage_Average] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Reliability,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt
    FROM
        [dbo].[fST_AVG_Stage_Average_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_PositedAt = (
            SELECT TOP 1
                sub.ST_AVG_PositedAt
            FROM
                [dbo].[rST_AVG_Stage_Average_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_AVG_ID = p.ST_AVG_ID
            ORDER BY
                sub.ST_AVG_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preST_AVG_Stage_Average function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preST_AVG_Stage_Average','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preST_AVG_Stage_Average] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.ST_AVG_UTL_ID
        FROM
            [dbo].[rST_AVG_Stage_Average](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.ST_AVG_ST_ID = @id
        AND
            pre.ST_AVG_ChangedAt < @changingTimepoint
        AND
            pre.ST_AVG_Reliability = 1
        ORDER BY
            pre.ST_AVG_ChangedAt DESC,
            pre.ST_AVG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folST_AVG_Stage_Average function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folST_AVG_Stage_Average','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folST_AVG_Stage_Average] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.ST_AVG_UTL_ID
        FROM
            [dbo].[fST_AVG_Stage_Average](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.ST_AVG_ST_ID = @id
        AND
            fol.ST_AVG_ChangedAt > @changingTimepoint
        AND
            fol.ST_AVG_Reliability = 1
        ORDER BY
            fol.ST_AVG_ChangedAt ASC,
            fol.ST_AVG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_MIN_Stage_Minimum_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_MIN_Stage_Minimum_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_MIN_Stage_Minimum_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    FROM
        [dbo].[ST_MIN_Stage_Minimum_Annex]
    WHERE
        ST_MIN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_MIN_Stage_Minimum rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rST_MIN_Stage_Minimum','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rST_MIN_Stage_Minimum] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_MIN,
        p.ST_MIN_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Reliability,
        p.ST_MIN_ST_ID,
        p.ST_MIN_UTL_ID
    FROM
        [dbo].[ST_MIN_Stage_Minimum_Posit] p
    JOIN
        [dbo].[rST_MIN_Stage_Minimum_Annex](@positingTimepoint) a
    ON
        a.ST_MIN_ID = p.ST_MIN_ID
    AND
        a.ST_MIN_PositedAt = (
            SELECT TOP 1
                sub.ST_MIN_PositedAt
            FROM
                [dbo].[rST_MIN_Stage_Minimum_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_MIN_ID = p.ST_MIN_ID
            ORDER BY
                sub.ST_MIN_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [dbo].[AC_NAM_Actor_Name_Posit]
    WHERE
        AC_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fAC_NAM_Actor_Name_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_NAM_Actor_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_NAM_Actor_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [dbo].[AC_NAM_Actor_Name_Posit]
    WHERE
        AC_NAM_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    FROM
        [dbo].[AC_NAM_Actor_Name_Annex]
    WHERE
        AC_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_NAM_Actor_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt
    FROM
        [dbo].[rAC_NAM_Actor_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = (
            SELECT TOP 1
                sub.AC_NAM_PositedAt
            FROM
                [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_NAM_ID = p.AC_NAM_ID
            ORDER BY
                sub.AC_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fAC_NAM_Actor_Name forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_NAM_Actor_Name] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Reliability,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt
    FROM
        [dbo].[fAC_NAM_Actor_Name_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_PositedAt = (
            SELECT TOP 1
                sub.AC_NAM_PositedAt
            FROM
                [dbo].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_NAM_ID = p.AC_NAM_ID
            ORDER BY
                sub.AC_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preAC_NAM_Actor_Name function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preAC_NAM_Actor_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preAC_NAM_Actor_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.AC_NAM_Actor_Name
        FROM
            [dbo].[rAC_NAM_Actor_Name](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.AC_NAM_AC_ID = @id
        AND
            pre.AC_NAM_ChangedAt < @changingTimepoint
        AND
            pre.AC_NAM_Reliability = 1
        ORDER BY
            pre.AC_NAM_ChangedAt DESC,
            pre.AC_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folAC_NAM_Actor_Name function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folAC_NAM_Actor_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folAC_NAM_Actor_Name] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.AC_NAM_Actor_Name
        FROM
            [dbo].[fAC_NAM_Actor_Name](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.AC_NAM_AC_ID = @id
        AND
            fol.AC_NAM_ChangedAt > @changingTimepoint
        AND
            fol.AC_NAM_Reliability = 1
        ORDER BY
            fol.AC_NAM_ChangedAt ASC,
            fol.AC_NAM_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_GEN_Actor_Gender_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_GEN_Actor_Gender_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_GEN_Actor_Gender_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    FROM
        [dbo].[AC_GEN_Actor_Gender_Annex]
    WHERE
        AC_GEN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_GEN_Actor_Gender rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_GEN_Actor_Gender','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_GEN_Actor_Gender] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_GEN,
        p.AC_GEN_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Reliability,
        p.AC_GEN_AC_ID,
        p.AC_GEN_GEN_ID
    FROM
        [dbo].[AC_GEN_Actor_Gender_Posit] p
    JOIN
        [dbo].[rAC_GEN_Actor_Gender_Annex](@positingTimepoint) a
    ON
        a.AC_GEN_ID = p.AC_GEN_ID
    AND
        a.AC_GEN_PositedAt = (
            SELECT TOP 1
                sub.AC_GEN_PositedAt
            FROM
                [dbo].[rAC_GEN_Actor_Gender_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_GEN_ID = p.AC_GEN_ID
            ORDER BY
                sub.AC_GEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_PLV_ID,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit]
    WHERE
        AC_PLV_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fAC_PLV_Actor_ProfessionalLevel_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_PLV_Actor_ProfessionalLevel_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_PLV_Actor_ProfessionalLevel_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_PLV_ID,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit]
    WHERE
        AC_PLV_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex]
    WHERE
        AC_PLV_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rAC_PLV_Actor_ProfessionalLevel] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt
    FROM
        [dbo].[rAC_PLV_Actor_ProfessionalLevel_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = (
            SELECT TOP 1
                sub.AC_PLV_PositedAt
            FROM
                [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_PLV_ID = p.AC_PLV_ID
            ORDER BY
                sub.AC_PLV_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fAC_PLV_Actor_ProfessionalLevel forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fAC_PLV_Actor_ProfessionalLevel] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Reliability,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt
    FROM
        [dbo].[fAC_PLV_Actor_ProfessionalLevel_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_PositedAt = (
            SELECT TOP 1
                sub.AC_PLV_PositedAt
            FROM
                [dbo].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_PLV_ID = p.AC_PLV_ID
            ORDER BY
                sub.AC_PLV_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preAC_PLV_Actor_ProfessionalLevel function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preAC_PLV_Actor_ProfessionalLevel','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preAC_PLV_Actor_ProfessionalLevel] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.AC_PLV_PLV_ID
        FROM
            [dbo].[rAC_PLV_Actor_ProfessionalLevel](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.AC_PLV_AC_ID = @id
        AND
            pre.AC_PLV_ChangedAt < @changingTimepoint
        AND
            pre.AC_PLV_Reliability = 1
        ORDER BY
            pre.AC_PLV_ChangedAt DESC,
            pre.AC_PLV_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folAC_PLV_Actor_ProfessionalLevel function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folAC_PLV_Actor_ProfessionalLevel','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folAC_PLV_Actor_ProfessionalLevel] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.AC_PLV_PLV_ID
        FROM
            [dbo].[fAC_PLV_Actor_ProfessionalLevel](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.AC_PLV_AC_ID = @id
        AND
            fol.AC_PLV_ChangedAt > @changingTimepoint
        AND
            fol.AC_PLV_Reliability = 1
        ORDER BY
            fol.AC_PLV_ChangedAt ASC,
            fol.AC_PLV_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rPR_NAM_Program_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_NAM_Program_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_NAM_Program_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    FROM
        [dbo].[PR_NAM_Program_Name_Annex]
    WHERE
        PR_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rPR_NAM_Program_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_NAM_Program_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_NAM_Program_Name] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_NAM,
        p.PR_NAM_ID,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Reliability,
        p.PR_NAM_PR_ID,
        p.PR_NAM_Program_Name
    FROM
        [dbo].[PR_NAM_Program_Name_Posit] p
    JOIN
        [dbo].[rPR_NAM_Program_Name_Annex](@positingTimepoint) a
    ON
        a.PR_NAM_ID = p.PR_NAM_ID
    AND
        a.PR_NAM_PositedAt = (
            SELECT TOP 1
                sub.PR_NAM_PositedAt
            FROM
                [dbo].[rPR_NAM_Program_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_NAM_ID = p.PR_NAM_ID
            ORDER BY
                sub.PR_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_LEN_Program_Length_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_LEN_Program_Length_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_LEN_ID,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [dbo].[PR_LEN_Program_Length_Posit]
    WHERE
        PR_LEN_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fPR_LEN_Program_Length_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fPR_LEN_Program_Length_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fPR_LEN_Program_Length_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_LEN_ID,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [dbo].[PR_LEN_Program_Length_Posit]
    WHERE
        PR_LEN_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_LEN_Program_Length_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_LEN_Program_Length_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    FROM
        [dbo].[PR_LEN_Program_Length_Annex]
    WHERE
        PR_LEN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rPR_LEN_Program_Length] (
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt
    FROM
        [dbo].[rPR_LEN_Program_Length_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = (
            SELECT TOP 1
                sub.PR_LEN_PositedAt
            FROM
                [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_LEN_ID = p.PR_LEN_ID
            ORDER BY
                sub.PR_LEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fPR_LEN_Program_Length forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fPR_LEN_Program_Length] (
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Reliability,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt
    FROM
        [dbo].[fPR_LEN_Program_Length_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_PositedAt = (
            SELECT TOP 1
                sub.PR_LEN_PositedAt
            FROM
                [dbo].[rPR_LEN_Program_Length_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_LEN_ID = p.PR_LEN_ID
            ORDER BY
                sub.PR_LEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- prePR_LEN_Program_Length function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.prePR_LEN_Program_Length','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[prePR_LEN_Program_Length] (
        @id int,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS time
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.PR_LEN_Program_Length
        FROM
            [dbo].[rPR_LEN_Program_Length](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.PR_LEN_PR_ID = @id
        AND
            pre.PR_LEN_ChangedAt < @changingTimepoint
        AND
            pre.PR_LEN_Reliability = 1
        ORDER BY
            pre.PR_LEN_ChangedAt DESC,
            pre.PR_LEN_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folPR_LEN_Program_Length function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folPR_LEN_Program_Length','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folPR_LEN_Program_Length] (
        @id int,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS time
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.PR_LEN_Program_Length
        FROM
            [dbo].[fPR_LEN_Program_Length](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.PR_LEN_PR_ID = @id
        AND
            fol.PR_LEN_ChangedAt > @changingTimepoint
        AND
            fol.PR_LEN_Reliability = 1
        ORDER BY
            fol.PR_LEN_ChangedAt ASC,
            fol.PR_LEN_PositedAt DESC
    );
    END
    ');
END
GO
