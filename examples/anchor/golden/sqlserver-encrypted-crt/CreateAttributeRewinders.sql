-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the
-- union of the two will produce all rows in a posit table.
--
-- @positor the view of which positor to adopt (defaults to 0)
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_DAT_Event_Date_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_DAT_Event_Date_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_DAT_Event_Date_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Positor,
        EV_DAT_Reliability,
        EV_DAT_Assertion
    FROM
        [attributes].[EV_DAT_Event_Date_Annex]
    WHERE
        EV_DAT_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_DAT_Event_Date rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_DAT_Event_Date','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_DAT_Event_Date] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_DAT,
        p.EV_DAT_ID,
        a.EV_DAT_PositedAt,
        a.EV_DAT_Positor,
        a.EV_DAT_Reliability,
        a.EV_DAT_Assertion,
        p.EV_DAT_EV_ID,
        p.EV_DAT_Event_Date
    FROM
        [attributes].[EV_DAT_Event_Date_Posit] p
    JOIN
        [attributes].[rEV_DAT_Event_Date_Annex](@positingTimepoint) a
    ON
        a.EV_DAT_ID = p.EV_DAT_ID
    AND
        a.EV_DAT_Positor = @positor
    AND
        a.EV_DAT_PositedAt = (
            SELECT TOP 1
                sub.EV_DAT_PositedAt
            FROM
                [attributes].[rEV_DAT_Event_Date_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_DAT_ID = p.EV_DAT_ID
            AND
                sub.EV_DAT_Positor = @positor
            ORDER BY
                sub.EV_DAT_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_AUD_Event_Audience_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_AUD_Event_Audience_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_AUD_Event_Audience_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Positor,
        EV_AUD_Reliability,
        EV_AUD_Assertion
    FROM
        [attributes].[EV_AUD_Event_Audience_Annex]
    WHERE
        EV_AUD_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_AUD_Event_Audience rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_AUD_Event_Audience','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_AUD_Event_Audience] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_AUD,
        p.EV_AUD_ID,
        a.EV_AUD_PositedAt,
        a.EV_AUD_Positor,
        a.EV_AUD_Reliability,
        a.EV_AUD_Assertion,
        p.EV_AUD_EV_ID,
        p.EV_AUD_Event_Audience
    FROM
        [attributes].[EV_AUD_Event_Audience_Posit] p
    JOIN
        [attributes].[rEV_AUD_Event_Audience_Annex](@positingTimepoint) a
    ON
        a.EV_AUD_ID = p.EV_AUD_ID
    AND
        a.EV_AUD_Positor = @positor
    AND
        a.EV_AUD_PositedAt = (
            SELECT TOP 1
                sub.EV_AUD_PositedAt
            FROM
                [attributes].[rEV_AUD_Event_Audience_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_AUD_ID = p.EV_AUD_ID
            AND
                sub.EV_AUD_Positor = @positor
            ORDER BY
                sub.EV_AUD_PositedAt DESC
        )
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_REV_Event_Revenue_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_REV_Event_Revenue_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_REV_Event_Revenue_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Positor,
        EV_REV_Reliability,
        EV_REV_Assertion
    FROM
        [attributes].[EV_REV_Event_Revenue_Annex]
    WHERE
        EV_REV_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_REV_Event_Revenue rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_REV_Event_Revenue','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_REV_Event_Revenue] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_REV,
        p.EV_REV_ID,
        a.EV_REV_PositedAt,
        a.EV_REV_Positor,
        a.EV_REV_Reliability,
        a.EV_REV_Assertion,
        p.EV_REV_EV_ID,
        p.EV_REV_Event_Revenue
    FROM
        [attributes].[EV_REV_Event_Revenue_Posit] p
    JOIN
        [attributes].[rEV_REV_Event_Revenue_Annex](@positingTimepoint) a
    ON
        a.EV_REV_ID = p.EV_REV_ID
    AND
        a.EV_REV_Positor = @positor
    AND
        a.EV_REV_PositedAt = (
            SELECT TOP 1
                sub.EV_REV_PositedAt
            FROM
                [attributes].[rEV_REV_Event_Revenue_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_REV_ID = p.EV_REV_ID
            AND
                sub.EV_REV_Positor = @positor
            ORDER BY
                sub.EV_REV_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rEV_STA_Event_Status_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_STA_Event_Status_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_STA_Event_Status_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_STA_ID,
        EV_STA_EV_ID,
        EV_STA_Event_Status,
        EV_STA_ChangedAt
    FROM
        [attributes].[EV_STA_Event_Status_Posit]
    WHERE
        EV_STA_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fEV_STA_Event_Status_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fEV_STA_Event_Status_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fEV_STA_Event_Status_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_STA_ID,
        EV_STA_EV_ID,
        EV_STA_Event_Status,
        EV_STA_ChangedAt
    FROM
        [attributes].[EV_STA_Event_Status_Posit]
    WHERE
        EV_STA_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_STA_Event_Status_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_STA_Event_Status_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_STA_Event_Status_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_PositedAt,
        EV_STA_Positor,
        EV_STA_Reliability,
        EV_STA_Assertion
    FROM
        [attributes].[EV_STA_Event_Status_Annex]
    WHERE
        EV_STA_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_STA_Event_Status rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_STA_Event_Status','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_STA_Event_Status] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_STA,
        p.EV_STA_ID,
        a.EV_STA_PositedAt,
        a.EV_STA_Positor,
        a.EV_STA_Reliability,
        a.EV_STA_Assertion,
        p.EV_STA_EV_ID,
        p.EV_STA_Event_Status,
        p.EV_STA_ChangedAt
    FROM
        [attributes].[rEV_STA_Event_Status_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rEV_STA_Event_Status_Annex](@positingTimepoint) a
    ON
        a.EV_STA_ID = p.EV_STA_ID
    AND
        a.EV_STA_Positor = @positor
    AND
        a.EV_STA_PositedAt = (
            SELECT TOP 1
                sub.EV_STA_PositedAt
            FROM
                [attributes].[rEV_STA_Event_Status_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_STA_ID = p.EV_STA_ID
            AND
                sub.EV_STA_Positor = @positor
            ORDER BY
                sub.EV_STA_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fEV_STA_Event_Status forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fEV_STA_Event_Status','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fEV_STA_Event_Status] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_STA,
        p.EV_STA_ID,
        a.EV_STA_PositedAt,
        a.EV_STA_Positor,
        a.EV_STA_Reliability,
        a.EV_STA_Assertion,
        p.EV_STA_EV_ID,
        p.EV_STA_Event_Status,
        p.EV_STA_ChangedAt
    FROM
        [attributes].[fEV_STA_Event_Status_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rEV_STA_Event_Status_Annex](@positingTimepoint) a
    ON
        a.EV_STA_ID = p.EV_STA_ID
    AND
        a.EV_STA_Positor = @positor
    AND
        a.EV_STA_PositedAt = (
            SELECT TOP 1
                sub.EV_STA_PositedAt
            FROM
                [attributes].[rEV_STA_Event_Status_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_STA_ID = p.EV_STA_ID
            AND
                sub.EV_STA_Positor = @positor
            ORDER BY
                sub.EV_STA_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preEV_STA_Event_Status function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.preEV_STA_Event_Status','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[preEV_STA_Event_Status] (
        @id numeric(12,0),
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(20)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.EV_STA_Event_Status
        FROM
            [attributes].[rEV_STA_Event_Status](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.EV_STA_EV_ID = @id
        AND
            pre.EV_STA_ChangedAt < @changingTimepoint
        AND
            pre.EV_STA_Assertion = isnull(@assertion, pre.EV_STA_Assertion)
        ORDER BY
            pre.EV_STA_ChangedAt DESC,
            pre.EV_STA_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folEV_STA_Event_Status function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.folEV_STA_Event_Status','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[folEV_STA_Event_Status] (
        @id numeric(12,0),
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS nvarchar(20)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.EV_STA_Event_Status
        FROM
            [attributes].[fEV_STA_Event_Status](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.EV_STA_EV_ID = @id
        AND
            fol.EV_STA_ChangedAt > @changingTimepoint
        AND
            fol.EV_STA_Assertion = isnull(@assertion, fol.EV_STA_Assertion)
        ORDER BY
            fol.EV_STA_ChangedAt ASC,
            fol.EV_STA_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_UTL_Event_Utilization_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_UTL_Event_Utilization_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_UTL_Event_Utilization_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_PositedAt,
        EV_UTL_Positor,
        EV_UTL_Reliability,
        EV_UTL_Assertion
    FROM
        [attributes].[EV_UTL_Event_Utilization_Annex]
    WHERE
        EV_UTL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_UTL_Event_Utilization rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_UTL_Event_Utilization','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_UTL_Event_Utilization] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_UTL,
        p.EV_UTL_ID,
        a.EV_UTL_PositedAt,
        a.EV_UTL_Positor,
        a.EV_UTL_Reliability,
        a.EV_UTL_Assertion,
        p.EV_UTL_EV_ID,
        p.EV_UTL_UTL_ID
    FROM
        [attributes].[EV_UTL_Event_Utilization_Posit] p
    JOIN
        [attributes].[rEV_UTL_Event_Utilization_Annex](@positingTimepoint) a
    ON
        a.EV_UTL_ID = p.EV_UTL_ID
    AND
        a.EV_UTL_Positor = @positor
    AND
        a.EV_UTL_PositedAt = (
            SELECT TOP 1
                sub.EV_UTL_PositedAt
            FROM
                [attributes].[rEV_UTL_Event_Utilization_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_UTL_ID = p.EV_UTL_ID
            AND
                sub.EV_UTL_Positor = @positor
            ORDER BY
                sub.EV_UTL_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_LVL_Event_Level_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_LVL_Event_Level_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_LVL_ID,
        EV_LVL_EV_ID,
        EV_LVL_PLV_ID,
        EV_LVL_ChangedAt
    FROM
        [attributes].[EV_LVL_Event_Level_Posit]
    WHERE
        EV_LVL_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fEV_LVL_Event_Level_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fEV_LVL_Event_Level_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fEV_LVL_Event_Level_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        EV_LVL_ID,
        EV_LVL_EV_ID,
        EV_LVL_PLV_ID,
        EV_LVL_ChangedAt
    FROM
        [attributes].[EV_LVL_Event_Level_Posit]
    WHERE
        EV_LVL_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_LVL_Event_Level_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_LVL_Event_Level_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_PositedAt,
        EV_LVL_Positor,
        EV_LVL_Reliability,
        EV_LVL_Assertion
    FROM
        [attributes].[EV_LVL_Event_Level_Annex]
    WHERE
        EV_LVL_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rEV_LVL_Event_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rEV_LVL_Event_Level] (
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_LVL,
        p.EV_LVL_ID,
        a.EV_LVL_PositedAt,
        a.EV_LVL_Positor,
        a.EV_LVL_Reliability,
        a.EV_LVL_Assertion,
        p.EV_LVL_EV_ID,
        p.EV_LVL_PLV_ID,
        p.EV_LVL_ChangedAt
    FROM
        [attributes].[rEV_LVL_Event_Level_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rEV_LVL_Event_Level_Annex](@positingTimepoint) a
    ON
        a.EV_LVL_ID = p.EV_LVL_ID
    AND
        a.EV_LVL_Positor = @positor
    AND
        a.EV_LVL_PositedAt = (
            SELECT TOP 1
                sub.EV_LVL_PositedAt
            FROM
                [attributes].[rEV_LVL_Event_Level_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_LVL_ID = p.EV_LVL_ID
            AND
                sub.EV_LVL_Positor = @positor
            ORDER BY
                sub.EV_LVL_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fEV_LVL_Event_Level forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fEV_LVL_Event_Level','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fEV_LVL_Event_Level] (
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_EV_LVL,
        p.EV_LVL_ID,
        a.EV_LVL_PositedAt,
        a.EV_LVL_Positor,
        a.EV_LVL_Reliability,
        a.EV_LVL_Assertion,
        p.EV_LVL_EV_ID,
        p.EV_LVL_PLV_ID,
        p.EV_LVL_ChangedAt
    FROM
        [attributes].[fEV_LVL_Event_Level_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rEV_LVL_Event_Level_Annex](@positingTimepoint) a
    ON
        a.EV_LVL_ID = p.EV_LVL_ID
    AND
        a.EV_LVL_Positor = @positor
    AND
        a.EV_LVL_PositedAt = (
            SELECT TOP 1
                sub.EV_LVL_PositedAt
            FROM
                [attributes].[rEV_LVL_Event_Level_Annex](@positingTimepoint) sub
            WHERE
                sub.EV_LVL_ID = p.EV_LVL_ID
            AND
                sub.EV_LVL_Positor = @positor
            ORDER BY
                sub.EV_LVL_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preEV_LVL_Event_Level function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.preEV_LVL_Event_Level','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[preEV_LVL_Event_Level] (
        @id numeric(12,0),
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.EV_LVL_PLV_ID
        FROM
            [attributes].[rEV_LVL_Event_Level](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.EV_LVL_EV_ID = @id
        AND
            pre.EV_LVL_ChangedAt < @changingTimepoint
        AND
            pre.EV_LVL_Assertion = isnull(@assertion, pre.EV_LVL_Assertion)
        ORDER BY
            pre.EV_LVL_ChangedAt DESC,
            pre.EV_LVL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute following value ------------------------------------------------------------------------------------------
-- folEV_LVL_Event_Level function for getting following value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.folEV_LVL_Event_Level','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[folEV_LVL_Event_Level] (
        @id numeric(12,0),
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.EV_LVL_PLV_ID
        FROM
            [attributes].[fEV_LVL_Event_Level](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.EV_LVL_EV_ID = @id
        AND
            fol.EV_LVL_ChangedAt > @changingTimepoint
        AND
            fol.EV_LVL_Assertion = isnull(@assertion, fol.EV_LVL_Assertion)
        ORDER BY
            fol.EV_LVL_ChangedAt ASC,
            fol.EV_LVL_PositedAt DESC
    );
    END
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_NAM_Stage_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_NAM_Stage_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_NAM_ID,
        ST_NAM_ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [attributes].[ST_NAM_Stage_Name_Posit]
    WHERE
        ST_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fST_NAM_Stage_Name_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fST_NAM_Stage_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fST_NAM_Stage_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_NAM_ID,
        ST_NAM_ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt
    FROM
        [attributes].[ST_NAM_Stage_Name_Posit]
    WHERE
        ST_NAM_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_NAM_Stage_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_NAM_Stage_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Positor,
        ST_NAM_Reliability,
        ST_NAM_Assertion
    FROM
        [attributes].[ST_NAM_Stage_Name_Annex]
    WHERE
        ST_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_NAM_Stage_Name] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Positor,
        a.ST_NAM_Reliability,
        a.ST_NAM_Assertion,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt
    FROM
        [attributes].[rST_NAM_Stage_Name_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rST_NAM_Stage_Name_Annex](@positingTimepoint) a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_Positor = @positor
    AND
        a.ST_NAM_PositedAt = (
            SELECT TOP 1
                sub.ST_NAM_PositedAt
            FROM
                [attributes].[rST_NAM_Stage_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_NAM_ID = p.ST_NAM_ID
            AND
                sub.ST_NAM_Positor = @positor
            ORDER BY
                sub.ST_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fST_NAM_Stage_Name forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fST_NAM_Stage_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fST_NAM_Stage_Name] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_NAM,
        p.ST_NAM_ID,
        a.ST_NAM_PositedAt,
        a.ST_NAM_Positor,
        a.ST_NAM_Reliability,
        a.ST_NAM_Assertion,
        p.ST_NAM_ST_ID,
        p.ST_NAM_Stage_Name,
        p.ST_NAM_ChangedAt
    FROM
        [attributes].[fST_NAM_Stage_Name_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rST_NAM_Stage_Name_Annex](@positingTimepoint) a
    ON
        a.ST_NAM_ID = p.ST_NAM_ID
    AND
        a.ST_NAM_Positor = @positor
    AND
        a.ST_NAM_PositedAt = (
            SELECT TOP 1
                sub.ST_NAM_PositedAt
            FROM
                [attributes].[rST_NAM_Stage_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_NAM_ID = p.ST_NAM_ID
            AND
                sub.ST_NAM_Positor = @positor
            ORDER BY
                sub.ST_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preST_NAM_Stage_Name function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.preST_NAM_Stage_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[preST_NAM_Stage_Name] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS varbinary(max)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.ST_NAM_Stage_Name
        FROM
            [attributes].[rST_NAM_Stage_Name](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.ST_NAM_ST_ID = @id
        AND
            pre.ST_NAM_ChangedAt < @changingTimepoint
        AND
            pre.ST_NAM_Assertion = isnull(@assertion, pre.ST_NAM_Assertion)
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
IF Object_ID('attributes.folST_NAM_Stage_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[folST_NAM_Stage_Name] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS varbinary(max)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.ST_NAM_Stage_Name
        FROM
            [attributes].[fST_NAM_Stage_Name](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.ST_NAM_ST_ID = @id
        AND
            fol.ST_NAM_ChangedAt > @changingTimepoint
        AND
            fol.ST_NAM_Assertion = isnull(@assertion, fol.ST_NAM_Assertion)
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
IF Object_ID('attributes.rST_LOC_Stage_Location_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_LOC_Stage_Location_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Positor,
        ST_LOC_Reliability,
        ST_LOC_Assertion
    FROM
        [attributes].[ST_LOC_Stage_Location_Annex]
    WHERE
        ST_LOC_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_LOC_Stage_Location rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_LOC_Stage_Location','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_LOC_Stage_Location] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_LOC,
        p.ST_LOC_ID,
        a.ST_LOC_PositedAt,
        a.ST_LOC_Positor,
        a.ST_LOC_Reliability,
        a.ST_LOC_Assertion,
        p.ST_LOC_ST_ID,
        p.ST_LOC_Checksum,
        p.ST_LOC_Stage_Location
    FROM
        [attributes].[ST_LOC_Stage_Location_Posit] p
    JOIN
        [attributes].[rST_LOC_Stage_Location_Annex](@positingTimepoint) a
    ON
        a.ST_LOC_ID = p.ST_LOC_ID
    AND
        a.ST_LOC_Positor = @positor
    AND
        a.ST_LOC_PositedAt = (
            SELECT TOP 1
                sub.ST_LOC_PositedAt
            FROM
                [attributes].[rST_LOC_Stage_Location_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_LOC_ID = p.ST_LOC_ID
            AND
                sub.ST_LOC_Positor = @positor
            ORDER BY
                sub.ST_LOC_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_AVG_Stage_Average_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_AVG_Stage_Average_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [attributes].[ST_AVG_Stage_Average_Posit]
    WHERE
        ST_AVG_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fST_AVG_Stage_Average_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fST_AVG_Stage_Average_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fST_AVG_Stage_Average_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        ST_AVG_ID,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt
    FROM
        [attributes].[ST_AVG_Stage_Average_Posit]
    WHERE
        ST_AVG_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_AVG_Stage_Average_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_AVG_Stage_Average_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Positor,
        ST_AVG_Reliability,
        ST_AVG_Assertion
    FROM
        [attributes].[ST_AVG_Stage_Average_Annex]
    WHERE
        ST_AVG_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_AVG_Stage_Average] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Positor,
        a.ST_AVG_Reliability,
        a.ST_AVG_Assertion,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt
    FROM
        [attributes].[rST_AVG_Stage_Average_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rST_AVG_Stage_Average_Annex](@positingTimepoint) a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_Positor = @positor
    AND
        a.ST_AVG_PositedAt = (
            SELECT TOP 1
                sub.ST_AVG_PositedAt
            FROM
                [attributes].[rST_AVG_Stage_Average_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_AVG_ID = p.ST_AVG_ID
            AND
                sub.ST_AVG_Positor = @positor
            ORDER BY
                sub.ST_AVG_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fST_AVG_Stage_Average forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fST_AVG_Stage_Average','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fST_AVG_Stage_Average] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_AVG,
        p.ST_AVG_ID,
        a.ST_AVG_PositedAt,
        a.ST_AVG_Positor,
        a.ST_AVG_Reliability,
        a.ST_AVG_Assertion,
        p.ST_AVG_ST_ID,
        p.ST_AVG_UTL_ID,
        p.ST_AVG_ChangedAt
    FROM
        [attributes].[fST_AVG_Stage_Average_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rST_AVG_Stage_Average_Annex](@positingTimepoint) a
    ON
        a.ST_AVG_ID = p.ST_AVG_ID
    AND
        a.ST_AVG_Positor = @positor
    AND
        a.ST_AVG_PositedAt = (
            SELECT TOP 1
                sub.ST_AVG_PositedAt
            FROM
                [attributes].[rST_AVG_Stage_Average_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_AVG_ID = p.ST_AVG_ID
            AND
                sub.ST_AVG_Positor = @positor
            ORDER BY
                sub.ST_AVG_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preST_AVG_Stage_Average function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.preST_AVG_Stage_Average','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[preST_AVG_Stage_Average] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.ST_AVG_UTL_ID
        FROM
            [attributes].[rST_AVG_Stage_Average](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.ST_AVG_ST_ID = @id
        AND
            pre.ST_AVG_ChangedAt < @changingTimepoint
        AND
            pre.ST_AVG_Assertion = isnull(@assertion, pre.ST_AVG_Assertion)
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
IF Object_ID('attributes.folST_AVG_Stage_Average','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[folST_AVG_Stage_Average] (
        @id int,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.ST_AVG_UTL_ID
        FROM
            [attributes].[fST_AVG_Stage_Average](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.ST_AVG_ST_ID = @id
        AND
            fol.ST_AVG_ChangedAt > @changingTimepoint
        AND
            fol.ST_AVG_Assertion = isnull(@assertion, fol.ST_AVG_Assertion)
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
IF Object_ID('attributes.rST_MIN_Stage_Minimum_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_MIN_Stage_Minimum_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Positor,
        ST_MIN_Reliability,
        ST_MIN_Assertion
    FROM
        [attributes].[ST_MIN_Stage_Minimum_Annex]
    WHERE
        ST_MIN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rST_MIN_Stage_Minimum rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rST_MIN_Stage_Minimum','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rST_MIN_Stage_Minimum] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_ST_MIN,
        p.ST_MIN_ID,
        a.ST_MIN_PositedAt,
        a.ST_MIN_Positor,
        a.ST_MIN_Reliability,
        a.ST_MIN_Assertion,
        p.ST_MIN_ST_ID,
        p.ST_MIN_UTL_ID
    FROM
        [attributes].[ST_MIN_Stage_Minimum_Posit] p
    JOIN
        [attributes].[rST_MIN_Stage_Minimum_Annex](@positingTimepoint) a
    ON
        a.ST_MIN_ID = p.ST_MIN_ID
    AND
        a.ST_MIN_Positor = @positor
    AND
        a.ST_MIN_PositedAt = (
            SELECT TOP 1
                sub.ST_MIN_PositedAt
            FROM
                [attributes].[rST_MIN_Stage_Minimum_Annex](@positingTimepoint) sub
            WHERE
                sub.ST_MIN_ID = p.ST_MIN_ID
            AND
                sub.ST_MIN_Positor = @positor
            ORDER BY
                sub.ST_MIN_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_NAM_Actor_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_NAM_Actor_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [attributes].[AC_NAM_Actor_Name_Posit]
    WHERE
        AC_NAM_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fAC_NAM_Actor_Name_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fAC_NAM_Actor_Name_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fAC_NAM_Actor_Name_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_NAM_ID,
        AC_NAM_AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt
    FROM
        [attributes].[AC_NAM_Actor_Name_Posit]
    WHERE
        AC_NAM_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_NAM_Actor_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_NAM_Actor_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Positor,
        AC_NAM_Reliability,
        AC_NAM_Assertion
    FROM
        [attributes].[AC_NAM_Actor_Name_Annex]
    WHERE
        AC_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_NAM_Actor_Name] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Positor,
        a.AC_NAM_Reliability,
        a.AC_NAM_Assertion,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt
    FROM
        [attributes].[rAC_NAM_Actor_Name_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_Positor = @positor
    AND
        a.AC_NAM_PositedAt = (
            SELECT TOP 1
                sub.AC_NAM_PositedAt
            FROM
                [attributes].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_NAM_ID = p.AC_NAM_ID
            AND
                sub.AC_NAM_Positor = @positor
            ORDER BY
                sub.AC_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fAC_NAM_Actor_Name forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fAC_NAM_Actor_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fAC_NAM_Actor_Name] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_NAM,
        p.AC_NAM_ID,
        a.AC_NAM_PositedAt,
        a.AC_NAM_Positor,
        a.AC_NAM_Reliability,
        a.AC_NAM_Assertion,
        p.AC_NAM_AC_ID,
        p.AC_NAM_Actor_Name,
        p.AC_NAM_ChangedAt
    FROM
        [attributes].[fAC_NAM_Actor_Name_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) a
    ON
        a.AC_NAM_ID = p.AC_NAM_ID
    AND
        a.AC_NAM_Positor = @positor
    AND
        a.AC_NAM_PositedAt = (
            SELECT TOP 1
                sub.AC_NAM_PositedAt
            FROM
                [attributes].[rAC_NAM_Actor_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_NAM_ID = p.AC_NAM_ID
            AND
                sub.AC_NAM_Positor = @positor
            ORDER BY
                sub.AC_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preAC_NAM_Actor_Name function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.preAC_NAM_Actor_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[preAC_NAM_Actor_Name] (
        @id smallint,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS varbinary(max)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.AC_NAM_Actor_Name
        FROM
            [attributes].[rAC_NAM_Actor_Name](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.AC_NAM_AC_ID = @id
        AND
            pre.AC_NAM_ChangedAt < @changingTimepoint
        AND
            pre.AC_NAM_Assertion = isnull(@assertion, pre.AC_NAM_Assertion)
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
IF Object_ID('attributes.folAC_NAM_Actor_Name','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[folAC_NAM_Actor_Name] (
        @id smallint,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS varbinary(max)
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.AC_NAM_Actor_Name
        FROM
            [attributes].[fAC_NAM_Actor_Name](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.AC_NAM_AC_ID = @id
        AND
            fol.AC_NAM_ChangedAt > @changingTimepoint
        AND
            fol.AC_NAM_Assertion = isnull(@assertion, fol.AC_NAM_Assertion)
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
IF Object_ID('attributes.rAC_GEN_Actor_Gender_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_GEN_Actor_Gender_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Positor,
        AC_GEN_Reliability,
        AC_GEN_Assertion
    FROM
        [attributes].[AC_GEN_Actor_Gender_Annex]
    WHERE
        AC_GEN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_GEN_Actor_Gender rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_GEN_Actor_Gender','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_GEN_Actor_Gender] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_GEN,
        p.AC_GEN_ID,
        a.AC_GEN_PositedAt,
        a.AC_GEN_Positor,
        a.AC_GEN_Reliability,
        a.AC_GEN_Assertion,
        p.AC_GEN_AC_ID,
        p.AC_GEN_GEN_ID
    FROM
        [attributes].[AC_GEN_Actor_Gender_Posit] p
    JOIN
        [attributes].[rAC_GEN_Actor_Gender_Annex](@positingTimepoint) a
    ON
        a.AC_GEN_ID = p.AC_GEN_ID
    AND
        a.AC_GEN_Positor = @positor
    AND
        a.AC_GEN_PositedAt = (
            SELECT TOP 1
                sub.AC_GEN_PositedAt
            FROM
                [attributes].[rAC_GEN_Actor_Gender_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_GEN_ID = p.AC_GEN_ID
            AND
                sub.AC_GEN_Positor = @positor
            ORDER BY
                sub.AC_GEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_PLV_Actor_ProfessionalLevel_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_PLV_Actor_ProfessionalLevel_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_PLV_ID,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit]
    WHERE
        AC_PLV_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fAC_PLV_Actor_ProfessionalLevel_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fAC_PLV_Actor_ProfessionalLevel_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fAC_PLV_Actor_ProfessionalLevel_Posit] (
        @changingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        AC_PLV_ID,
        AC_PLV_AC_ID,
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit]
    WHERE
        AC_PLV_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_PLV_Actor_ProfessionalLevel_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_PLV_Actor_ProfessionalLevel_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Positor,
        AC_PLV_Reliability,
        AC_PLV_Assertion
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex]
    WHERE
        AC_PLV_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rAC_PLV_Actor_ProfessionalLevel] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Positor,
        a.AC_PLV_Reliability,
        a.AC_PLV_Assertion,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt
    FROM
        [attributes].[rAC_PLV_Actor_ProfessionalLevel_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_Positor = @positor
    AND
        a.AC_PLV_PositedAt = (
            SELECT TOP 1
                sub.AC_PLV_PositedAt
            FROM
                [attributes].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_PLV_ID = p.AC_PLV_ID
            AND
                sub.AC_PLV_Positor = @positor
            ORDER BY
                sub.AC_PLV_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fAC_PLV_Actor_ProfessionalLevel forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fAC_PLV_Actor_ProfessionalLevel','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fAC_PLV_Actor_ProfessionalLevel] (
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_AC_PLV,
        p.AC_PLV_ID,
        a.AC_PLV_PositedAt,
        a.AC_PLV_Positor,
        a.AC_PLV_Reliability,
        a.AC_PLV_Assertion,
        p.AC_PLV_AC_ID,
        p.AC_PLV_PLV_ID,
        p.AC_PLV_ChangedAt
    FROM
        [attributes].[fAC_PLV_Actor_ProfessionalLevel_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) a
    ON
        a.AC_PLV_ID = p.AC_PLV_ID
    AND
        a.AC_PLV_Positor = @positor
    AND
        a.AC_PLV_PositedAt = (
            SELECT TOP 1
                sub.AC_PLV_PositedAt
            FROM
                [attributes].[rAC_PLV_Actor_ProfessionalLevel_Annex](@positingTimepoint) sub
            WHERE
                sub.AC_PLV_ID = p.AC_PLV_ID
            AND
                sub.AC_PLV_Positor = @positor
            ORDER BY
                sub.AC_PLV_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- preAC_PLV_Actor_ProfessionalLevel function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.preAC_PLV_Actor_ProfessionalLevel','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[preAC_PLV_Actor_ProfessionalLevel] (
        @id smallint,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.AC_PLV_PLV_ID
        FROM
            [attributes].[rAC_PLV_Actor_ProfessionalLevel](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.AC_PLV_AC_ID = @id
        AND
            pre.AC_PLV_ChangedAt < @changingTimepoint
        AND
            pre.AC_PLV_Assertion = isnull(@assertion, pre.AC_PLV_Assertion)
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
IF Object_ID('attributes.folAC_PLV_Actor_ProfessionalLevel','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[folAC_PLV_Actor_ProfessionalLevel] (
        @id smallint,
        @positor tinyint = 0,
        @changingTimepoint datetime2 = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS tinyint
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.AC_PLV_PLV_ID
        FROM
            [attributes].[fAC_PLV_Actor_ProfessionalLevel](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.AC_PLV_AC_ID = @id
        AND
            fol.AC_PLV_ChangedAt > @changingTimepoint
        AND
            fol.AC_PLV_Assertion = isnull(@assertion, fol.AC_PLV_Assertion)
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
IF Object_ID('attributes.rPR_NAM_Program_Name_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rPR_NAM_Program_Name_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Positor,
        PR_NAM_Reliability,
        PR_NAM_Assertion
    FROM
        [attributes].[PR_NAM_Program_Name_Annex]
    WHERE
        PR_NAM_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rPR_NAM_Program_Name rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rPR_NAM_Program_Name','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rPR_NAM_Program_Name] (
        @positor tinyint = 0,
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_NAM,
        p.PR_NAM_ID,
        a.PR_NAM_PositedAt,
        a.PR_NAM_Positor,
        a.PR_NAM_Reliability,
        a.PR_NAM_Assertion,
        p.PR_NAM_PR_ID,
        p.PR_NAM_Program_Name
    FROM
        [attributes].[PR_NAM_Program_Name_Posit] p
    JOIN
        [attributes].[rPR_NAM_Program_Name_Annex](@positingTimepoint) a
    ON
        a.PR_NAM_ID = p.PR_NAM_ID
    AND
        a.PR_NAM_Positor = @positor
    AND
        a.PR_NAM_PositedAt = (
            SELECT TOP 1
                sub.PR_NAM_PositedAt
            FROM
                [attributes].[rPR_NAM_Program_Name_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_NAM_ID = p.PR_NAM_ID
            AND
                sub.PR_NAM_Positor = @positor
            ORDER BY
                sub.PR_NAM_PositedAt DESC
        )
    ');
END
GO
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length_Posit rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rPR_LEN_Program_Length_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rPR_LEN_Program_Length_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_LEN_ID,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [attributes].[PR_LEN_Program_Length_Posit]
    WHERE
        PR_LEN_ChangedAt <= @changingTimepoint;
    ');
END
GO
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-- fPR_LEN_Program_Length_Posit forwarding over changing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fPR_LEN_Program_Length_Posit','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fPR_LEN_Program_Length_Posit] (
        @changingTimepoint date = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        PR_LEN_ID,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt
    FROM
        [attributes].[PR_LEN_Program_Length_Posit]
    WHERE
        PR_LEN_ChangedAt > @changingTimepoint;
    ');
END
GO
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length_Annex rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rPR_LEN_Program_Length_Annex','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rPR_LEN_Program_Length_Annex] (
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Positor,
        PR_LEN_Reliability,
        PR_LEN_Assertion
    FROM
        [attributes].[PR_LEN_Program_Length_Annex]
    WHERE
        PR_LEN_PositedAt <= @positingTimepoint;
    ');
END
GO
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing and positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.rPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[rPR_LEN_Program_Length] (
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Positor,
        a.PR_LEN_Reliability,
        a.PR_LEN_Assertion,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt
    FROM
        [attributes].[rPR_LEN_Program_Length_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rPR_LEN_Program_Length_Annex](@positingTimepoint) a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_Positor = @positor
    AND
        a.PR_LEN_PositedAt = (
            SELECT TOP 1
                sub.PR_LEN_PositedAt
            FROM
                [attributes].[rPR_LEN_Program_Length_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_LEN_ID = p.PR_LEN_ID
            AND
                sub.PR_LEN_Positor = @positor
            ORDER BY
                sub.PR_LEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-- fPR_LEN_Program_Length forwarding over changing and rewinding over positing time function
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.fPR_LEN_Program_Length','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[fPR_LEN_Program_Length] (
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31''
    )
    RETURNS TABLE WITH SCHEMABINDING AS RETURN
    SELECT
        a.Metadata_PR_LEN,
        p.PR_LEN_ID,
        a.PR_LEN_PositedAt,
        a.PR_LEN_Positor,
        a.PR_LEN_Reliability,
        a.PR_LEN_Assertion,
        p.PR_LEN_PR_ID,
        p.PR_LEN_Program_Length,
        p.PR_LEN_ChangedAt
    FROM
        [attributes].[fPR_LEN_Program_Length_Posit](@changingTimepoint) p
    JOIN
        [attributes].[rPR_LEN_Program_Length_Annex](@positingTimepoint) a
    ON
        a.PR_LEN_ID = p.PR_LEN_ID
    AND
        a.PR_LEN_Positor = @positor
    AND
        a.PR_LEN_PositedAt = (
            SELECT TOP 1
                sub.PR_LEN_PositedAt
            FROM
                [attributes].[rPR_LEN_Program_Length_Annex](@positingTimepoint) sub
            WHERE
                sub.PR_LEN_ID = p.PR_LEN_ID
            AND
                sub.PR_LEN_Positor = @positor
            ORDER BY
                sub.PR_LEN_PositedAt DESC
        )
    ');
END
GO
-- Attribute previous value -------------------------------------------------------------------------------------------
-- prePR_LEN_Program_Length function for getting previous value
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.prePR_LEN_Program_Length','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[prePR_LEN_Program_Length] (
        @id bigint,
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS time
    AS
    BEGIN RETURN (
        SELECT TOP 1
            pre.PR_LEN_Program_Length
        FROM
            [attributes].[rPR_LEN_Program_Length](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) pre
        WHERE
            pre.PR_LEN_PR_ID = @id
        AND
            pre.PR_LEN_ChangedAt < @changingTimepoint
        AND
            pre.PR_LEN_Assertion = isnull(@assertion, pre.PR_LEN_Assertion)
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
IF Object_ID('attributes.folPR_LEN_Program_Length','FN') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION [attributes].[folPR_LEN_Program_Length] (
        @id bigint,
        @positor tinyint = 0,
        @changingTimepoint date = ''9999-12-31'',
        @positingTimepoint datetime2 = ''9999-12-31'',
        @assertion char(1) = null
    )
    RETURNS time
    AS
    BEGIN RETURN (
        SELECT TOP 1
            fol.PR_LEN_Program_Length
        FROM
            [attributes].[fPR_LEN_Program_Length](
                @positor,
                @changingTimepoint,
                @positingTimepoint
            ) fol
        WHERE
            fol.PR_LEN_PR_ID = @id
        AND
            fol.PR_LEN_ChangedAt > @changingTimepoint
        AND
            fol.PR_LEN_Assertion = isnull(@assertion, fol.PR_LEN_Assertion)
        ORDER BY
            fol.PR_LEN_ChangedAt ASC,
            fol.PR_LEN_PositedAt DESC
    );
    END
    ');
END
GO
