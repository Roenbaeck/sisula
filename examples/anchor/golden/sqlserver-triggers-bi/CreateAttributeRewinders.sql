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
-- rEV_QTY_Event_Quantity_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_QTY_Event_Quantity_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_QTY_Event_Quantity_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    FROM
        [dbo].[EV_QTY_Event_Quantity_Annex]
    WHERE
        EV_QTY_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_QTY_Event_Quantity rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_QTY_Event_Quantity','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_QTY_Event_Quantity] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_QTY,
        p.EV_QTY_ID,
        a.EV_QTY_PositedAt,
        a.EV_QTY_Reliability,
        p.EV_QTY_EV_ID,
        p.EV_QTY_Event_Quantity
    FROM
        [dbo].[EV_QTY_Event_Quantity_Posit] p
    JOIN
        [dbo].[rEV_QTY_Event_Quantity_Annex](@positingTimepoint) a
    ON
        a.EV_QTY_ID = p.EV_QTY_ID
    AND
        a.EV_QTY_PositedAt = (
            SELECT TOP 1
                sub.EV_QTY_PositedAt
            FROM
                [dbo].[rEV_QTY_Event_Quantity_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_QTY_ID = p.EV_QTY_ID
            ORDER BY
                sub.EV_QTY_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rEV_PLC_Event_Place_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_PLC_Event_Place_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_PLC_Event_Place_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_PLC_ID,
        EV_PLC_EV_ID,
        EV_PLC_Event_Place,
        EV_PLC_ChangedAt
    FROM
        [dbo].[EV_PLC_Event_Place_Posit]
    WHERE
        EV_PLC_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fEV_PLC_Event_Place_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fEV_PLC_Event_Place_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fEV_PLC_Event_Place_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_PLC_ID,
        EV_PLC_EV_ID,
        EV_PLC_Event_Place,
        EV_PLC_ChangedAt
    FROM
        [dbo].[EV_PLC_Event_Place_Posit]
    WHERE
        EV_PLC_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_PLC_Event_Place_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_PLC_Event_Place_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_PLC_Event_Place_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    FROM
        [dbo].[EV_PLC_Event_Place_Annex]
    WHERE
        EV_PLC_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_PLC_Event_Place rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rEV_PLC_Event_Place','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rEV_PLC_Event_Place] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_PLC,
        p.EV_PLC_ID,
        a.EV_PLC_PositedAt,
        a.EV_PLC_Reliability,
        p.EV_PLC_EV_ID,
        p.EV_PLC_Event_Place,
        p.EV_PLC_ChangedAt
    FROM
        [dbo].[rEV_PLC_Event_Place_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) a
    ON
        a.EV_PLC_ID = p.EV_PLC_ID
    AND
        a.EV_PLC_PositedAt = (
            SELECT TOP 1
                sub.EV_PLC_PositedAt
            FROM
                [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_PLC_ID = p.EV_PLC_ID
            ORDER BY
                sub.EV_PLC_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fEV_PLC_Event_Place forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fEV_PLC_Event_Place','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fEV_PLC_Event_Place] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_PLC,
        p.EV_PLC_ID,
        a.EV_PLC_PositedAt,
        a.EV_PLC_Reliability,
        p.EV_PLC_EV_ID,
        p.EV_PLC_Event_Place,
        p.EV_PLC_ChangedAt
    FROM
        [dbo].[fEV_PLC_Event_Place_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) a
    ON
        a.EV_PLC_ID = p.EV_PLC_ID
    AND
        a.EV_PLC_PositedAt = (
            SELECT TOP 1
                sub.EV_PLC_PositedAt
            FROM
                [dbo].[rEV_PLC_Event_Place_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_PLC_ID = p.EV_PLC_ID
            ORDER BY
                sub.EV_PLC_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preEV_PLC_Event_Place function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preEV_PLC_Event_Place','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preEV_PLC_Event_Place] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.EV_PLC_Event_Place
        FROM
            [dbo].[rEV_PLC_Event_Place](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.EV_PLC_EV_ID = @id
        AND
            pre.EV_PLC_ChangedAt < @changingTimepoint
        AND
            pre.EV_PLC_Reliability = 1
        ORDER BY
            pre.EV_PLC_ChangedAt DESC,
            pre.EV_PLC_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folEV_PLC_Event_Place function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folEV_PLC_Event_Place','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folEV_PLC_Event_Place] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.EV_PLC_Event_Place
        FROM
            [dbo].[fEV_PLC_Event_Place](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.EV_PLC_EV_ID = @id
        AND
            fol.EV_PLC_ChangedAt > @changingTimepoint
        AND
            fol.EV_PLC_Reliability = 1
        ORDER BY
            fol.EV_PLC_ChangedAt ASC,
            fol.EV_PLC_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_NAM_Subject_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NAM_Subject_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NAM_Subject_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    FROM
        [dbo].[SU_NAM_Subject_Name_Annex]
    WHERE
        SU_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_NAM_Subject_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NAM_Subject_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NAM_Subject_Name] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_NAM,
        p.SU_NAM_ID,
        a.SU_NAM_PositedAt,
        a.SU_NAM_Reliability,
        p.SU_NAM_SU_ID,
        p.SU_NAM_Subject_Name
    FROM
        [dbo].[SU_NAM_Subject_Name_Posit] p
    JOIN
        [dbo].[rSU_NAM_Subject_Name_Annex](@positingTimepoint) a
    ON
        a.SU_NAM_ID = p.SU_NAM_ID
    AND
        a.SU_NAM_PositedAt = (
            SELECT TOP 1
                sub.SU_NAM_PositedAt
            FROM
                [dbo].[rSU_NAM_Subject_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_NAM_ID = p.SU_NAM_ID
            ORDER BY
                sub.SU_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_COD_Subject_Code_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_COD_Subject_Code_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_COD_Subject_Code_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_PositedAt,
        SU_COD_Reliability
    FROM
        [dbo].[SU_COD_Subject_Code_Annex]
    WHERE
        SU_COD_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_COD_Subject_Code rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_COD_Subject_Code','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_COD_Subject_Code] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_COD,
        p.SU_COD_ID,
        a.SU_COD_PositedAt,
        a.SU_COD_Reliability,
        p.SU_COD_SU_ID,
        p.SU_COD_Subject_Code
    FROM
        [dbo].[SU_COD_Subject_Code_Posit] p
    JOIN
        [dbo].[rSU_COD_Subject_Code_Annex](@positingTimepoint) a
    ON
        a.SU_COD_ID = p.SU_COD_ID
    AND
        a.SU_COD_PositedAt = (
            SELECT TOP 1
                sub.SU_COD_PositedAt
            FROM
                [dbo].[rSU_COD_Subject_Code_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_COD_ID = p.SU_COD_ID
            ORDER BY
                sub.SU_COD_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_GRD_Subject_Grade_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_GRD_Subject_Grade_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_GRD_Subject_Grade_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    FROM
        [dbo].[SU_GRD_Subject_Grade_Annex]
    WHERE
        SU_GRD_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_GRD_Subject_Grade rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_GRD_Subject_Grade','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_GRD_Subject_Grade] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_GRD,
        p.SU_GRD_ID,
        a.SU_GRD_PositedAt,
        a.SU_GRD_Reliability,
        p.SU_GRD_SU_ID,
        p.SU_GRD_GRD_ID
    FROM
        [dbo].[SU_GRD_Subject_Grade_Posit] p
    JOIN
        [dbo].[rSU_GRD_Subject_Grade_Annex](@positingTimepoint) a
    ON
        a.SU_GRD_ID = p.SU_GRD_ID
    AND
        a.SU_GRD_PositedAt = (
            SELECT TOP 1
                sub.SU_GRD_PositedAt
            FROM
                [dbo].[rSU_GRD_Subject_Grade_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_GRD_ID = p.SU_GRD_ID
            ORDER BY
                sub.SU_GRD_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_NOT_Subject_Note_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NOT_Subject_Note_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NOT_Subject_Note_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    FROM
        [dbo].[SU_NOT_Subject_Note_Annex]
    WHERE
        SU_NOT_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_NOT_Subject_Note rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_NOT_Subject_Note','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_NOT_Subject_Note] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_NOT,
        p.SU_NOT_ID,
        a.SU_NOT_PositedAt,
        a.SU_NOT_Reliability,
        p.SU_NOT_SU_ID,
        p.SU_NOT_Checksum,
        p.SU_NOT_Subject_Note
    FROM
        [dbo].[SU_NOT_Subject_Note_Posit] p
    JOIN
        [dbo].[rSU_NOT_Subject_Note_Annex](@positingTimepoint) a
    ON
        a.SU_NOT_ID = p.SU_NOT_ID
    AND
        a.SU_NOT_PositedAt = (
            SELECT TOP 1
                sub.SU_NOT_PositedAt
            FROM
                [dbo].[rSU_NOT_Subject_Note_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_NOT_ID = p.SU_NOT_ID
            ORDER BY
                sub.SU_NOT_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TTL_Subject_Title_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TTL_Subject_Title_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TTL_ID,
        SU_TTL_SU_ID,
        SU_TTL_Subject_Title,
        SU_TTL_ChangedAt
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit]
    WHERE
        SU_TTL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_TTL_Subject_Title_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TTL_Subject_Title_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TTL_Subject_Title_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TTL_ID,
        SU_TTL_SU_ID,
        SU_TTL_Subject_Title,
        SU_TTL_ChangedAt
    FROM
        [dbo].[SU_TTL_Subject_Title_Posit]
    WHERE
        SU_TTL_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TTL_Subject_Title_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TTL_Subject_Title_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    FROM
        [dbo].[SU_TTL_Subject_Title_Annex]
    WHERE
        SU_TTL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TTL_Subject_Title','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TTL_Subject_Title] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TTL,
        p.SU_TTL_ID,
        a.SU_TTL_PositedAt,
        a.SU_TTL_Reliability,
        p.SU_TTL_SU_ID,
        p.SU_TTL_Subject_Title,
        p.SU_TTL_ChangedAt
    FROM
        [dbo].[rSU_TTL_Subject_Title_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) a
    ON
        a.SU_TTL_ID = p.SU_TTL_ID
    AND
        a.SU_TTL_PositedAt = (
            SELECT TOP 1
                sub.SU_TTL_PositedAt
            FROM
                [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TTL_ID = p.SU_TTL_ID
            ORDER BY
                sub.SU_TTL_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_TTL_Subject_Title forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TTL_Subject_Title','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TTL_Subject_Title] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TTL,
        p.SU_TTL_ID,
        a.SU_TTL_PositedAt,
        a.SU_TTL_Reliability,
        p.SU_TTL_SU_ID,
        p.SU_TTL_Subject_Title,
        p.SU_TTL_ChangedAt
    FROM
        [dbo].[fSU_TTL_Subject_Title_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) a
    ON
        a.SU_TTL_ID = p.SU_TTL_ID
    AND
        a.SU_TTL_PositedAt = (
            SELECT TOP 1
                sub.SU_TTL_PositedAt
            FROM
                [dbo].[rSU_TTL_Subject_Title_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TTL_ID = p.SU_TTL_ID
            ORDER BY
                sub.SU_TTL_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_TTL_Subject_Title function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_TTL_Subject_Title','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_TTL_Subject_Title] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_TTL_Subject_Title
        FROM
            [dbo].[rSU_TTL_Subject_Title](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_TTL_SU_ID = @id
        AND
            pre.SU_TTL_ChangedAt < @changingTimepoint
        AND
            pre.SU_TTL_Reliability = 1
        ORDER BY
            pre.SU_TTL_ChangedAt DESC,
            pre.SU_TTL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_TTL_Subject_Title function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_TTL_Subject_Title','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_TTL_Subject_Title] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_TTL_Subject_Title
        FROM
            [dbo].[fSU_TTL_Subject_Title](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_TTL_SU_ID = @id
        AND
            fol.SU_TTL_ChangedAt > @changingTimepoint
        AND
            fol.SU_TTL_Reliability = 1
        ORDER BY
            fol.SU_TTL_ChangedAt ASC,
            fol.SU_TTL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_STA_Subject_State_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_STA_Subject_State_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_STA_ID,
        SU_STA_SU_ID,
        SU_STA_Subject_State,
        SU_STA_ChangedAt
    FROM
        [dbo].[SU_STA_Subject_State_Posit]
    WHERE
        SU_STA_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_STA_Subject_State_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_STA_Subject_State_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_STA_Subject_State_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_STA_ID,
        SU_STA_SU_ID,
        SU_STA_Subject_State,
        SU_STA_ChangedAt
    FROM
        [dbo].[SU_STA_Subject_State_Posit]
    WHERE
        SU_STA_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_STA_Subject_State_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_STA_Subject_State_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_PositedAt,
        SU_STA_Reliability
    FROM
        [dbo].[SU_STA_Subject_State_Annex]
    WHERE
        SU_STA_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_STA_Subject_State rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_STA_Subject_State','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_STA_Subject_State] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_STA,
        p.SU_STA_ID,
        a.SU_STA_PositedAt,
        a.SU_STA_Reliability,
        p.SU_STA_SU_ID,
        p.SU_STA_Subject_State,
        p.SU_STA_ChangedAt
    FROM
        [dbo].[rSU_STA_Subject_State_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) a
    ON
        a.SU_STA_ID = p.SU_STA_ID
    AND
        a.SU_STA_PositedAt = (
            SELECT TOP 1
                sub.SU_STA_PositedAt
            FROM
                [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_STA_ID = p.SU_STA_ID
            ORDER BY
                sub.SU_STA_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_STA_Subject_State forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_STA_Subject_State','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_STA_Subject_State] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_STA,
        p.SU_STA_ID,
        a.SU_STA_PositedAt,
        a.SU_STA_Reliability,
        p.SU_STA_SU_ID,
        p.SU_STA_Subject_State,
        p.SU_STA_ChangedAt
    FROM
        [dbo].[fSU_STA_Subject_State_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) a
    ON
        a.SU_STA_ID = p.SU_STA_ID
    AND
        a.SU_STA_PositedAt = (
            SELECT TOP 1
                sub.SU_STA_PositedAt
            FROM
                [dbo].[rSU_STA_Subject_State_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_STA_ID = p.SU_STA_ID
            ORDER BY
                sub.SU_STA_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_STA_Subject_State function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_STA_Subject_State','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_STA_Subject_State] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_STA_Subject_State
        FROM
            [dbo].[rSU_STA_Subject_State](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_STA_SU_ID = @id
        AND
            pre.SU_STA_ChangedAt < @changingTimepoint
        AND
            pre.SU_STA_Reliability = 1
        ORDER BY
            pre.SU_STA_ChangedAt DESC,
            pre.SU_STA_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_STA_Subject_State function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_STA_Subject_State','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_STA_Subject_State] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_STA_Subject_State
        FROM
            [dbo].[fSU_STA_Subject_State](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_STA_SU_ID = @id
        AND
            fol.SU_STA_ChangedAt > @changingTimepoint
        AND
            fol.SU_STA_Reliability = 1
        ORDER BY
            fol.SU_STA_ChangedAt ASC,
            fol.SU_STA_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LBL_Subject_Label_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LBL_Subject_Label_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LBL_ID,
        SU_LBL_SU_ID,
        SU_LBL_Subject_Label,
        SU_LBL_ChangedAt
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit]
    WHERE
        SU_LBL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_LBL_Subject_Label_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LBL_Subject_Label_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LBL_Subject_Label_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LBL_ID,
        SU_LBL_SU_ID,
        SU_LBL_Subject_Label,
        SU_LBL_ChangedAt
    FROM
        [dbo].[SU_LBL_Subject_Label_Posit]
    WHERE
        SU_LBL_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LBL_Subject_Label_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LBL_Subject_Label_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    FROM
        [dbo].[SU_LBL_Subject_Label_Annex]
    WHERE
        SU_LBL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LBL_Subject_Label','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LBL_Subject_Label] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LBL,
        p.SU_LBL_ID,
        a.SU_LBL_PositedAt,
        a.SU_LBL_Reliability,
        p.SU_LBL_SU_ID,
        p.SU_LBL_Subject_Label,
        p.SU_LBL_ChangedAt
    FROM
        [dbo].[rSU_LBL_Subject_Label_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID
    AND
        a.SU_LBL_PositedAt = (
            SELECT TOP 1
                sub.SU_LBL_PositedAt
            FROM
                [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LBL_ID = p.SU_LBL_ID
            ORDER BY
                sub.SU_LBL_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_LBL_Subject_Label forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LBL_Subject_Label','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LBL_Subject_Label] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LBL,
        p.SU_LBL_ID,
        a.SU_LBL_PositedAt,
        a.SU_LBL_Reliability,
        p.SU_LBL_SU_ID,
        p.SU_LBL_Subject_Label,
        p.SU_LBL_ChangedAt
    FROM
        [dbo].[fSU_LBL_Subject_Label_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) a
    ON
        a.SU_LBL_ID = p.SU_LBL_ID
    AND
        a.SU_LBL_PositedAt = (
            SELECT TOP 1
                sub.SU_LBL_PositedAt
            FROM
                [dbo].[rSU_LBL_Subject_Label_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LBL_ID = p.SU_LBL_ID
            ORDER BY
                sub.SU_LBL_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_LBL_Subject_Label function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_LBL_Subject_Label','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_LBL_Subject_Label] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_LBL_Subject_Label
        FROM
            [dbo].[rSU_LBL_Subject_Label](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_LBL_SU_ID = @id
        AND
            pre.SU_LBL_ChangedAt < @changingTimepoint
        AND
            pre.SU_LBL_Reliability = 1
        ORDER BY
            pre.SU_LBL_ChangedAt DESC,
            pre.SU_LBL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_LBL_Subject_Label function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_LBL_Subject_Label','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_LBL_Subject_Label] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_LBL_Subject_Label
        FROM
            [dbo].[fSU_LBL_Subject_Label](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_LBL_SU_ID = @id
        AND
            fol.SU_LBL_ChangedAt > @changingTimepoint
        AND
            fol.SU_LBL_Reliability = 1
        ORDER BY
            fol.SU_LBL_ChangedAt ASC,
            fol.SU_LBL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TAG_Subject_Tag_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TAG_Subject_Tag_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TAG_ID,
        SU_TAG_SU_ID,
        SU_TAG_Subject_Tag,
        SU_TAG_ChangedAt
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit]
    WHERE
        SU_TAG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_TAG_Subject_Tag_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TAG_Subject_Tag_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TAG_Subject_Tag_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TAG_ID,
        SU_TAG_SU_ID,
        SU_TAG_Subject_Tag,
        SU_TAG_ChangedAt
    FROM
        [dbo].[SU_TAG_Subject_Tag_Posit]
    WHERE
        SU_TAG_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TAG_Subject_Tag_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TAG_Subject_Tag_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    FROM
        [dbo].[SU_TAG_Subject_Tag_Annex]
    WHERE
        SU_TAG_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TAG_Subject_Tag','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TAG_Subject_Tag] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TAG,
        p.SU_TAG_ID,
        a.SU_TAG_PositedAt,
        a.SU_TAG_Reliability,
        p.SU_TAG_SU_ID,
        p.SU_TAG_Subject_Tag,
        p.SU_TAG_ChangedAt
    FROM
        [dbo].[rSU_TAG_Subject_Tag_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID
    AND
        a.SU_TAG_PositedAt = (
            SELECT TOP 1
                sub.SU_TAG_PositedAt
            FROM
                [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TAG_ID = p.SU_TAG_ID
            ORDER BY
                sub.SU_TAG_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_TAG_Subject_Tag forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TAG_Subject_Tag','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TAG_Subject_Tag] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TAG,
        p.SU_TAG_ID,
        a.SU_TAG_PositedAt,
        a.SU_TAG_Reliability,
        p.SU_TAG_SU_ID,
        p.SU_TAG_Subject_Tag,
        p.SU_TAG_ChangedAt
    FROM
        [dbo].[fSU_TAG_Subject_Tag_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) a
    ON
        a.SU_TAG_ID = p.SU_TAG_ID
    AND
        a.SU_TAG_PositedAt = (
            SELECT TOP 1
                sub.SU_TAG_PositedAt
            FROM
                [dbo].[rSU_TAG_Subject_Tag_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TAG_ID = p.SU_TAG_ID
            ORDER BY
                sub.SU_TAG_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_TAG_Subject_Tag function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_TAG_Subject_Tag','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_TAG_Subject_Tag] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_TAG_Subject_Tag
        FROM
            [dbo].[rSU_TAG_Subject_Tag](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_TAG_SU_ID = @id
        AND
            pre.SU_TAG_ChangedAt < @changingTimepoint
        AND
            pre.SU_TAG_Reliability = 1
        ORDER BY
            pre.SU_TAG_ChangedAt DESC,
            pre.SU_TAG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_TAG_Subject_Tag function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_TAG_Subject_Tag','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_TAG_Subject_Tag] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_TAG_Subject_Tag
        FROM
            [dbo].[fSU_TAG_Subject_Tag](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_TAG_SU_ID = @id
        AND
            fol.SU_TAG_ChangedAt > @changingTimepoint
        AND
            fol.SU_TAG_Reliability = 1
        ORDER BY
            fol.SU_TAG_ChangedAt ASC,
            fol.SU_TAG_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LVL_Subject_Level_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LVL_Subject_Level_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LVL_ID,
        SU_LVL_SU_ID,
        SU_LVL_GRD_ID,
        SU_LVL_ChangedAt
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit]
    WHERE
        SU_LVL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_LVL_Subject_Level_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LVL_Subject_Level_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LVL_Subject_Level_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_LVL_ID,
        SU_LVL_SU_ID,
        SU_LVL_GRD_ID,
        SU_LVL_ChangedAt
    FROM
        [dbo].[SU_LVL_Subject_Level_Posit]
    WHERE
        SU_LVL_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LVL_Subject_Level_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LVL_Subject_Level_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    FROM
        [dbo].[SU_LVL_Subject_Level_Annex]
    WHERE
        SU_LVL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_LVL_Subject_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_LVL_Subject_Level] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LVL,
        p.SU_LVL_ID,
        a.SU_LVL_PositedAt,
        a.SU_LVL_Reliability,
        p.SU_LVL_SU_ID,
        p.SU_LVL_GRD_ID,
        p.SU_LVL_ChangedAt
    FROM
        [dbo].[rSU_LVL_Subject_Level_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) a
    ON
        a.SU_LVL_ID = p.SU_LVL_ID
    AND
        a.SU_LVL_PositedAt = (
            SELECT TOP 1
                sub.SU_LVL_PositedAt
            FROM
                [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LVL_ID = p.SU_LVL_ID
            ORDER BY
                sub.SU_LVL_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_LVL_Subject_Level forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_LVL_Subject_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_LVL_Subject_Level] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_LVL,
        p.SU_LVL_ID,
        a.SU_LVL_PositedAt,
        a.SU_LVL_Reliability,
        p.SU_LVL_SU_ID,
        p.SU_LVL_GRD_ID,
        p.SU_LVL_ChangedAt
    FROM
        [dbo].[fSU_LVL_Subject_Level_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) a
    ON
        a.SU_LVL_ID = p.SU_LVL_ID
    AND
        a.SU_LVL_PositedAt = (
            SELECT TOP 1
                sub.SU_LVL_PositedAt
            FROM
                [dbo].[rSU_LVL_Subject_Level_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_LVL_ID = p.SU_LVL_ID
            ORDER BY
                sub.SU_LVL_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_LVL_Subject_Level function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_LVL_Subject_Level','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_LVL_Subject_Level] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_LVL_GRD_ID
        FROM
            [dbo].[rSU_LVL_Subject_Level](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_LVL_SU_ID = @id
        AND
            pre.SU_LVL_ChangedAt < @changingTimepoint
        AND
            pre.SU_LVL_Reliability = 1
        ORDER BY
            pre.SU_LVL_ChangedAt DESC,
            pre.SU_LVL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_LVL_Subject_Level function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_LVL_Subject_Level','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_LVL_Subject_Level] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_LVL_GRD_ID
        FROM
            [dbo].[fSU_LVL_Subject_Level](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_LVL_SU_ID = @id
        AND
            fol.SU_LVL_ChangedAt > @changingTimepoint
        AND
            fol.SU_LVL_Reliability = 1
        ORDER BY
            fol.SU_LVL_ChangedAt ASC,
            fol.SU_LVL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TXT_Subject_Text_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TXT_Subject_Text_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TXT_ID,
        SU_TXT_SU_ID,
        SU_TXT_Checksum,
        SU_TXT_Subject_Text,
        SU_TXT_ChangedAt
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit]
    WHERE
        SU_TXT_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_TXT_Subject_Text_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TXT_Subject_Text_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TXT_Subject_Text_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_TXT_ID,
        SU_TXT_SU_ID,
        SU_TXT_Checksum,
        SU_TXT_Subject_Text,
        SU_TXT_ChangedAt
    FROM
        [dbo].[SU_TXT_Subject_Text_Posit]
    WHERE
        SU_TXT_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TXT_Subject_Text_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TXT_Subject_Text_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    FROM
        [dbo].[SU_TXT_Subject_Text_Annex]
    WHERE
        SU_TXT_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_TXT_Subject_Text','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_TXT_Subject_Text] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TXT,
        p.SU_TXT_ID,
        a.SU_TXT_PositedAt,
        a.SU_TXT_Reliability,
        p.SU_TXT_SU_ID,
        p.SU_TXT_Checksum,
        p.SU_TXT_Subject_Text,
        p.SU_TXT_ChangedAt
    FROM
        [dbo].[rSU_TXT_Subject_Text_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) a
    ON
        a.SU_TXT_ID = p.SU_TXT_ID
    AND
        a.SU_TXT_PositedAt = (
            SELECT TOP 1
                sub.SU_TXT_PositedAt
            FROM
                [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TXT_ID = p.SU_TXT_ID
            ORDER BY
                sub.SU_TXT_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_TXT_Subject_Text forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_TXT_Subject_Text','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_TXT_Subject_Text] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_TXT,
        p.SU_TXT_ID,
        a.SU_TXT_PositedAt,
        a.SU_TXT_Reliability,
        p.SU_TXT_SU_ID,
        p.SU_TXT_Checksum,
        p.SU_TXT_Subject_Text,
        p.SU_TXT_ChangedAt
    FROM
        [dbo].[fSU_TXT_Subject_Text_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) a
    ON
        a.SU_TXT_ID = p.SU_TXT_ID
    AND
        a.SU_TXT_PositedAt = (
            SELECT TOP 1
                sub.SU_TXT_PositedAt
            FROM
                [dbo].[rSU_TXT_Subject_Text_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_TXT_ID = p.SU_TXT_ID
            ORDER BY
                sub.SU_TXT_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_TXT_Subject_Text function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_TXT_Subject_Text','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_TXT_Subject_Text] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_TXT_Checksum
        FROM
            [dbo].[rSU_TXT_Subject_Text](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_TXT_SU_ID = @id
        AND
            pre.SU_TXT_ChangedAt < @changingTimepoint
        AND
            pre.SU_TXT_Reliability = 1
        ORDER BY
            pre.SU_TXT_ChangedAt DESC,
            pre.SU_TXT_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_TXT_Subject_Text function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_TXT_Subject_Text','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_TXT_Subject_Text] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS varbinary(16)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_TXT_Checksum
        FROM
            [dbo].[fSU_TXT_Subject_Text](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_TXT_SU_ID = @id
        AND
            fol.SU_TXT_ChangedAt > @changingTimepoint
        AND
            fol.SU_TXT_Reliability = 1
        ORDER BY
            fol.SU_TXT_ChangedAt ASC,
            fol.SU_TXT_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ASR_Subject_Assessment_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ASR_Subject_Assessment_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ASR_ID,
        SU_ASR_SU_ID,
        SU_ASR_Subject_Assessment,
        SU_ASR_ChangedAt
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit]
    WHERE
        SU_ASR_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_ASR_Subject_Assessment_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ASR_Subject_Assessment_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ASR_Subject_Assessment_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ASR_ID,
        SU_ASR_SU_ID,
        SU_ASR_Subject_Assessment,
        SU_ASR_ChangedAt
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Posit]
    WHERE
        SU_ASR_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ASR_Subject_Assessment_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ASR_Subject_Assessment_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    FROM
        [dbo].[SU_ASR_Subject_Assessment_Annex]
    WHERE
        SU_ASR_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ASR_Subject_Assessment','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ASR_Subject_Assessment] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ASR,
        p.SU_ASR_ID,
        a.SU_ASR_PositedAt,
        a.SU_ASR_Reliability,
        p.SU_ASR_SU_ID,
        p.SU_ASR_Subject_Assessment,
        p.SU_ASR_ChangedAt
    FROM
        [dbo].[rSU_ASR_Subject_Assessment_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID
    AND
        a.SU_ASR_PositedAt = (
            SELECT TOP 1
                sub.SU_ASR_PositedAt
            FROM
                [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ASR_ID = p.SU_ASR_ID
            ORDER BY
                sub.SU_ASR_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_ASR_Subject_Assessment forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ASR_Subject_Assessment','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ASR_Subject_Assessment] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ASR,
        p.SU_ASR_ID,
        a.SU_ASR_PositedAt,
        a.SU_ASR_Reliability,
        p.SU_ASR_SU_ID,
        p.SU_ASR_Subject_Assessment,
        p.SU_ASR_ChangedAt
    FROM
        [dbo].[fSU_ASR_Subject_Assessment_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) a
    ON
        a.SU_ASR_ID = p.SU_ASR_ID
    AND
        a.SU_ASR_PositedAt = (
            SELECT TOP 1
                sub.SU_ASR_PositedAt
            FROM
                [dbo].[rSU_ASR_Subject_Assessment_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ASR_ID = p.SU_ASR_ID
            ORDER BY
                sub.SU_ASR_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_ASR_Subject_Assessment function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_ASR_Subject_Assessment','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_ASR_Subject_Assessment] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_ASR_Subject_Assessment
        FROM
            [dbo].[rSU_ASR_Subject_Assessment](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_ASR_SU_ID = @id
        AND
            pre.SU_ASR_ChangedAt < @changingTimepoint
        AND
            pre.SU_ASR_Reliability = 1
        ORDER BY
            pre.SU_ASR_ChangedAt DESC,
            pre.SU_ASR_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_ASR_Subject_Assessment function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_ASR_Subject_Assessment','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_ASR_Subject_Assessment] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_ASR_Subject_Assessment
        FROM
            [dbo].[fSU_ASR_Subject_Assessment](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_ASR_SU_ID = @id
        AND
            fol.SU_ASR_ChangedAt > @changingTimepoint
        AND
            fol.SU_ASR_Reliability = 1
        ORDER BY
            fol.SU_ASR_ChangedAt ASC,
            fol.SU_ASR_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ERS_Subject_Erasable_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ERS_Subject_Erasable_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ERS_ID,
        SU_ERS_SU_ID,
        SU_ERS_Subject_Erasable,
        SU_ERS_ChangedAt
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit]
    WHERE
        SU_ERS_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fSU_ERS_Subject_Erasable_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ERS_Subject_Erasable_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ERS_Subject_Erasable_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        SU_ERS_ID,
        SU_ERS_SU_ID,
        SU_ERS_Subject_Erasable,
        SU_ERS_ChangedAt
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Posit]
    WHERE
        SU_ERS_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ERS_Subject_Erasable_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ERS_Subject_Erasable_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    FROM
        [dbo].[SU_ERS_Subject_Erasable_Annex]
    WHERE
        SU_ERS_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rSU_ERS_Subject_Erasable','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rSU_ERS_Subject_Erasable] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ERS,
        p.SU_ERS_ID,
        a.SU_ERS_PositedAt,
        a.SU_ERS_Reliability,
        p.SU_ERS_SU_ID,
        p.SU_ERS_Subject_Erasable,
        p.SU_ERS_ChangedAt
    FROM
        [dbo].[rSU_ERS_Subject_Erasable_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) a
    ON
        a.SU_ERS_ID = p.SU_ERS_ID
    AND
        a.SU_ERS_PositedAt = (
            SELECT TOP 1
                sub.SU_ERS_PositedAt
            FROM
                [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ERS_ID = p.SU_ERS_ID
            ORDER BY
                sub.SU_ERS_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fSU_ERS_Subject_Erasable forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.fSU_ERS_Subject_Erasable','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[fSU_ERS_Subject_Erasable] (
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_SU_ERS,
        p.SU_ERS_ID,
        a.SU_ERS_PositedAt,
        a.SU_ERS_Reliability,
        p.SU_ERS_SU_ID,
        p.SU_ERS_Subject_Erasable,
        p.SU_ERS_ChangedAt
    FROM
        [dbo].[fSU_ERS_Subject_Erasable_Posit](@changingTimepoint) p
    JOIN
        [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) a
    ON
        a.SU_ERS_ID = p.SU_ERS_ID
    AND
        a.SU_ERS_PositedAt = (
            SELECT TOP 1
                sub.SU_ERS_PositedAt
            FROM
                [dbo].[rSU_ERS_Subject_Erasable_Annex](@positingTimepoint) sub
            WHERE
                sub.SU_ERS_ID = p.SU_ERS_ID
            ORDER BY
                sub.SU_ERS_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preSU_ERS_Subject_Erasable function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.preSU_ERS_Subject_Erasable','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[preSU_ERS_Subject_Erasable] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.SU_ERS_Subject_Erasable
        FROM
            [dbo].[rSU_ERS_Subject_Erasable](
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.SU_ERS_SU_ID = @id
        AND
            pre.SU_ERS_ChangedAt < @changingTimepoint
        AND
            pre.SU_ERS_Reliability = 1
        ORDER BY
            pre.SU_ERS_ChangedAt DESC,
            pre.SU_ERS_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folSU_ERS_Subject_Erasable function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.folSU_ERS_Subject_Erasable','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[folSU_ERS_Subject_Erasable] (
        @id int,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS nvarchar(42)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.SU_ERS_Subject_Erasable
        FROM
            [dbo].[fSU_ERS_Subject_Erasable](
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.SU_ERS_SU_ID = @id
        AND
            fol.SU_ERS_ChangedAt > @changingTimepoint
        AND
            fol.SU_ERS_Reliability = 1
        ORDER BY
            fol.SU_ERS_ChangedAt ASC,
            fol.SU_ERS_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rOB_NAM_Object_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_NAM_Object_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_NAM_Object_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    FROM
        [dbo].[OB_NAM_Object_Name_Annex]
    WHERE
        OB_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rOB_NAM_Object_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rOB_NAM_Object_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [dbo].[rOB_NAM_Object_Name] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_OB_NAM,
        p.OB_NAM_ID,
        a.OB_NAM_PositedAt,
        a.OB_NAM_Reliability,
        p.OB_NAM_OB_ID,
        p.OB_NAM_Object_Name
    FROM
        [dbo].[OB_NAM_Object_Name_Posit] p
    JOIN
        [dbo].[rOB_NAM_Object_Name_Annex](@positingTimepoint) a
    ON
        a.OB_NAM_ID = p.OB_NAM_ID
    AND
        a.OB_NAM_PositedAt = (
            SELECT TOP 1
                sub.OB_NAM_PositedAt
            FROM
                [dbo].[rOB_NAM_Object_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.OB_NAM_ID = p.OB_NAM_ID
            ORDER BY
                sub.OB_NAM_PositedAt DESC
        )
    ');
END
GO
