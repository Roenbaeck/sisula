-- ATTRIBUTE RESTATEMENT CONSTRAINTS ----------------------------------------------------------------------------------
--
-- Attributes may be prevented from storing restatements.
-- A restatement is when the same value occurs for two adjacent points
-- in changing time. Note that restatement checking is not done for
-- unreliable information as this could prevent demotion.
--
-- If actual deletes are made, the remaining information will not
-- be checked for restatements.
--
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_EV_PLC_Event_Place (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_EV_PLC_Event_Place', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_EV_PLC_Event_Place];
GO
CREATE TRIGGER [dbo].[rt_EV_PLC_Event_Place] ON [dbo].[EV_PLC_Event_Place]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @EV_PLC_Event_Place TABLE (
        EV_PLC_EV_ID int not null,
        Metadata_EV_PLC int not null,
        EV_PLC_ChangedAt datetime2 not null,
        EV_PLC_Event_Place nvarchar(42) not null,
        primary key(
            EV_PLC_EV_ID asc,
            EV_PLC_ChangedAt desc
        )
    );
    INSERT INTO @EV_PLC_Event_Place (
        EV_PLC_EV_ID,
        Metadata_EV_PLC,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    )
    SELECT
        EV_PLC_EV_ID,
        Metadata_EV_PLC,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    FROM
        inserted;
    INSERT INTO @EV_PLC_Event_Place (
        EV_PLC_EV_ID,
        Metadata_EV_PLC,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    )
    SELECT
        p.EV_PLC_EV_ID,
        p.Metadata_EV_PLC,
        p.EV_PLC_ChangedAt,
        p.EV_PLC_Event_Place
    FROM (
        SELECT DISTINCT
            EV_PLC_EV_ID
        FROM
            @EV_PLC_Event_Place
    ) i
    JOIN
        [dbo].[EV_PLC_Event_Place] p
    ON
        p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_PLC_EV_ID
        FROM
            @EV_PLC_Event_Place x
        WHERE
            x.EV_PLC_EV_ID = p.EV_PLC_EV_ID
        AND
            x.EV_PLC_ChangedAt = p.EV_PLC_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @EV_PLC_Event_Place i
        CROSS APPLY (
            SELECT TOP 1
                h.EV_PLC_EV_ID,
                h.EV_PLC_ChangedAt,
                h.EV_PLC_Event_Place
            FROM
                @EV_PLC_Event_Place h
            WHERE
                h.EV_PLC_EV_ID = i.EV_PLC_EV_ID
            AND
                h.EV_PLC_ChangedAt < i.EV_PLC_ChangedAt
            ORDER BY
                h.EV_PLC_ChangedAt DESC
        ) pre
        WHERE
            i.EV_PLC_Event_Place = pre.EV_PLC_Event_Place
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in EV_PLC_Event_Place for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_SU_STA_Subject_State (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_STA_Subject_State', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_STA_Subject_State];
GO
CREATE TRIGGER [dbo].[rt_SU_STA_Subject_State] ON [dbo].[SU_STA_Subject_State]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @SU_STA_Subject_State TABLE (
        SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_Subject_State nvarchar(42) not null,
        primary key(
            SU_STA_SU_ID asc,
            SU_STA_ChangedAt desc
        )
    );
    INSERT INTO @SU_STA_Subject_State (
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    FROM
        inserted;
    INSERT INTO @SU_STA_Subject_State (
        SU_STA_SU_ID,
        Metadata_SU_STA,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT
        p.SU_STA_SU_ID,
        p.Metadata_SU_STA,
        p.SU_STA_ChangedAt,
        p.SU_STA_Subject_State
    FROM (
        SELECT DISTINCT
            SU_STA_SU_ID
        FROM
            @SU_STA_Subject_State
    ) i
    JOIN
        [dbo].[SU_STA_Subject_State] p
    ON
        p.SU_STA_SU_ID = i.SU_STA_SU_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_STA_SU_ID
        FROM
            @SU_STA_Subject_State x
        WHERE
            x.SU_STA_SU_ID = p.SU_STA_SU_ID
        AND
            x.SU_STA_ChangedAt = p.SU_STA_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @SU_STA_Subject_State i
        CROSS APPLY (
            SELECT TOP 1
                h.SU_STA_SU_ID,
                h.SU_STA_ChangedAt,
                h.SU_STA_Subject_State
            FROM
                @SU_STA_Subject_State h
            WHERE
                h.SU_STA_SU_ID = i.SU_STA_SU_ID
            AND
                h.SU_STA_ChangedAt < i.SU_STA_ChangedAt
            ORDER BY
                h.SU_STA_ChangedAt DESC
        ) pre
        WHERE
            i.SU_STA_Subject_State = pre.SU_STA_Subject_State
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
-- Restatement Checking Trigger ---------------------------------------------------------------------------------------
-- rt_SU_LBL_Subject_Label (available only in attributes that cannot have restatements)
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.rt_SU_LBL_Subject_Label', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[rt_SU_LBL_Subject_Label];
GO
CREATE TRIGGER [dbo].[rt_SU_LBL_Subject_Label] ON [dbo].[SU_LBL_Subject_Label]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message varchar(max);
    DECLARE @SU_LBL_Subject_Label TABLE (
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        primary key(
            SU_LBL_SU_ID asc,
            SU_LBL_ChangedAt desc
        )
    );
    INSERT INTO @SU_LBL_Subject_Label (
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    FROM
        inserted;
    INSERT INTO @SU_LBL_Subject_Label (
        SU_LBL_SU_ID,
        Metadata_SU_LBL,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT
        p.SU_LBL_SU_ID,
        p.Metadata_SU_LBL,
        p.SU_LBL_ChangedAt,
        p.SU_LBL_Subject_Label
    FROM (
        SELECT DISTINCT
            SU_LBL_SU_ID
        FROM
            @SU_LBL_Subject_Label
    ) i
    JOIN
        [dbo].[SU_LBL_Subject_Label] p
    ON
        p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_LBL_SU_ID
        FROM
            @SU_LBL_Subject_Label x
        WHERE
            x.SU_LBL_SU_ID = p.SU_LBL_SU_ID
        AND
            x.SU_LBL_ChangedAt = p.SU_LBL_ChangedAt
    );
    -- check previous values
    SET @message = (
        SELECT TOP 1
            pre.*
        FROM
            @SU_LBL_Subject_Label i
        CROSS APPLY (
            SELECT TOP 1
                h.SU_LBL_SU_ID,
                h.SU_LBL_ChangedAt,
                h.SU_LBL_Subject_Label
            FROM
                @SU_LBL_Subject_Label h
            WHERE
                h.SU_LBL_SU_ID = i.SU_LBL_SU_ID
            AND
                h.SU_LBL_ChangedAt < i.SU_LBL_ChangedAt
            ORDER BY
                h.SU_LBL_ChangedAt DESC
        ) pre
        WHERE
            i.SU_LBL_Subject_Label = pre.SU_LBL_Subject_Label
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Restatement in SU_LBL_Subject_Label for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
    END
END
GO
