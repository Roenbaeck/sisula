-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the attributes make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_QTY_Event_Quantity instead of INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_QTY_Event_Quantity', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_QTY_Event_Quantity];
GO
CREATE TRIGGER [dbo].[it_EV_QTY_Event_Quantity] ON [dbo].[EV_QTY_Event_Quantity]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_QTY_EV_ID
        FROM
            inserted i
        JOIN
            [dbo].[EV_QTY_Event_Quantity] x
        ON
            x.EV_QTY_EV_ID = i.EV_QTY_EV_ID
        WHERE NOT (
            x.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_QTY_Event_Quantity for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    )
    SELECT
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_QTY_EV_ID
        FROM
            [dbo].[EV_QTY_Event_Quantity] x
        WHERE
            x.EV_QTY_EV_ID = i.EV_QTY_EV_ID
        AND
            x.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place instead of INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_PLC_Event_Place', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_PLC_Event_Place];
GO
CREATE TRIGGER [dbo].[it_EV_PLC_Event_Place] ON [dbo].[EV_PLC_Event_Place]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @EV_PLC_Event_Place TABLE (
    EV_PLC_EV_ID int not null,
        Metadata_EV_PLC int not null,
        EV_PLC_ChangedAt datetime2 not null,
        EV_PLC_Event_Place nvarchar(42) not null,
        EV_PLC_StatementType char(1) not null,
        primary key (
            EV_PLC_EV_ID asc,
            EV_PLC_ChangedAt desc
        )
    );
    INSERT INTO @EV_PLC_Event_Place
    SELECT
        i.EV_PLC_EV_ID,
        i.Metadata_EV_PLC,
        i.EV_PLC_ChangedAt,
        i.EV_PLC_Event_Place,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.EV_PLC_EV_ID
        FROM
            [dbo].[EV_PLC_Event_Place] x
        WHERE
            x.EV_PLC_EV_ID = i.EV_PLC_EV_ID
        AND
            x.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
        AND
            x.EV_PLC_Event_Place = i.EV_PLC_Event_Place
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_PLC_EV_ID,
            i.EV_PLC_ChangedAt
        FROM
            @EV_PLC_Event_Place i
        JOIN
            [dbo].[EV_PLC_Event_Place] x
        ON
            x.EV_PLC_EV_ID = i.EV_PLC_EV_ID
        AND
            x.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_PLC_Event_Place for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[EV_PLC_Event_Place] (
        Metadata_EV_PLC,
        EV_PLC_EV_ID,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    )
    SELECT
        Metadata_EV_PLC,
        EV_PLC_EV_ID,
        EV_PLC_ChangedAt,
        EV_PLC_Event_Place
    FROM
        @EV_PLC_Event_Place
    WHERE
        EV_PLC_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name instead of INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NAM_Subject_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NAM_Subject_Name];
GO
CREATE TRIGGER [dbo].[it_SU_NAM_Subject_Name] ON [dbo].[SU_NAM_Subject_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NAM_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_NAM_Subject_Name] x
        ON
            x.SU_NAM_SU_ID = i.SU_NAM_SU_ID
        WHERE NOT (
            x.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NAM_Subject_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_NAM_Subject_Name] (
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name
    )
    SELECT
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_NAM_SU_ID
        FROM
            [dbo].[SU_NAM_Subject_Name] x
        WHERE
            x.SU_NAM_SU_ID = i.SU_NAM_SU_ID
        AND
            x.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code instead of INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_COD_Subject_Code', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_COD_Subject_Code];
GO
CREATE TRIGGER [dbo].[it_SU_COD_Subject_Code] ON [dbo].[SU_COD_Subject_Code]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_COD_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_COD_Subject_Code] x
        ON
            x.SU_COD_SU_ID = i.SU_COD_SU_ID
        WHERE NOT (
            x.SU_COD_Subject_Code = i.SU_COD_Subject_Code
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_COD_Subject_Code for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_COD_Subject_Code] (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    )
    SELECT
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_COD_SU_ID
        FROM
            [dbo].[SU_COD_Subject_Code] x
        WHERE
            x.SU_COD_SU_ID = i.SU_COD_SU_ID
        AND
            x.SU_COD_Subject_Code = i.SU_COD_Subject_Code
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade instead of INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_GRD_Subject_Grade', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_GRD_Subject_Grade];
GO
CREATE TRIGGER [dbo].[it_SU_GRD_Subject_Grade] ON [dbo].[SU_GRD_Subject_Grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_GRD_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_GRD_Subject_Grade] x
        ON
            x.SU_GRD_SU_ID = i.SU_GRD_SU_ID
        WHERE NOT (
            x.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_GRD_Subject_Grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    )
    SELECT
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_GRD_SU_ID
        FROM
            [dbo].[SU_GRD_Subject_Grade] x
        WHERE
            x.SU_GRD_SU_ID = i.SU_GRD_SU_ID
        AND
            x.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note instead of INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NOT_Subject_Note', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NOT_Subject_Note];
GO
CREATE TRIGGER [dbo].[it_SU_NOT_Subject_Note] ON [dbo].[SU_NOT_Subject_Note]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NOT_SU_ID
        FROM
            inserted i
        JOIN
            [dbo].[SU_NOT_Subject_Note] x
        ON
            x.SU_NOT_SU_ID = i.SU_NOT_SU_ID
        WHERE NOT (
            x.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NOT_Subject_Note for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_NOT_Subject_Note] (
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note
    )
    SELECT
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_NOT_SU_ID
        FROM
            [dbo].[SU_NOT_Subject_Note] x
        WHERE
            x.SU_NOT_SU_ID = i.SU_NOT_SU_ID
        AND
            x.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title instead of INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TTL_Subject_Title', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TTL_Subject_Title];
GO
CREATE TRIGGER [dbo].[it_SU_TTL_Subject_Title] ON [dbo].[SU_TTL_Subject_Title]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_TTL_Subject_Title TABLE (
    SU_TTL_SU_ID int not null,
        Metadata_SU_TTL int not null,
        SU_TTL_ChangedAt datetime2 not null,
        SU_TTL_Subject_Title nvarchar(42) not null,
        SU_TTL_StatementType char(1) not null,
        primary key (
            SU_TTL_SU_ID asc,
            SU_TTL_ChangedAt desc
        )
    );
    INSERT INTO @SU_TTL_Subject_Title
    SELECT
        i.SU_TTL_SU_ID,
        i.Metadata_SU_TTL,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_Subject_Title,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_TTL_SU_ID
        FROM
            [dbo].[SU_TTL_Subject_Title] x
        WHERE
            x.SU_TTL_SU_ID = i.SU_TTL_SU_ID
        AND
            x.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
        AND
            x.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TTL_SU_ID,
            i.SU_TTL_ChangedAt
        FROM
            @SU_TTL_Subject_Title i
        JOIN
            [dbo].[SU_TTL_Subject_Title] x
        ON
            x.SU_TTL_SU_ID = i.SU_TTL_SU_ID
        AND
            x.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TTL_Subject_Title for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_TTL_Subject_Title] (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    )
    SELECT
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    FROM
        @SU_TTL_Subject_Title
    WHERE
        SU_TTL_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State instead of INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_STA_Subject_State', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_STA_Subject_State];
GO
CREATE TRIGGER [dbo].[it_SU_STA_Subject_State] ON [dbo].[SU_STA_Subject_State]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_STA_Subject_State TABLE (
    SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_Subject_State nvarchar(42) not null,
        SU_STA_StatementType char(1) not null,
        primary key (
            SU_STA_SU_ID asc,
            SU_STA_ChangedAt desc
        )
    );
    INSERT INTO @SU_STA_Subject_State
    SELECT
        i.SU_STA_SU_ID,
        i.Metadata_SU_STA,
        i.SU_STA_ChangedAt,
        i.SU_STA_Subject_State,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_STA_SU_ID
        FROM
            [dbo].[SU_STA_Subject_State] x
        WHERE
            x.SU_STA_SU_ID = i.SU_STA_SU_ID
        AND
            x.SU_STA_ChangedAt = i.SU_STA_ChangedAt
        AND
            x.SU_STA_Subject_State = i.SU_STA_Subject_State
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_STA_SU_ID,
            i.SU_STA_ChangedAt
        FROM
            @SU_STA_Subject_State i
        JOIN
            [dbo].[SU_STA_Subject_State] x
        ON
            x.SU_STA_SU_ID = i.SU_STA_SU_ID
        AND
            x.SU_STA_ChangedAt = i.SU_STA_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_STA_Subject_State] (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    FROM
        @SU_STA_Subject_State
    WHERE
        SU_STA_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label instead of INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LBL_Subject_Label', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LBL_Subject_Label];
GO
CREATE TRIGGER [dbo].[it_SU_LBL_Subject_Label] ON [dbo].[SU_LBL_Subject_Label]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_LBL_Subject_Label TABLE (
    SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        SU_LBL_StatementType char(1) not null,
        primary key (
            SU_LBL_SU_ID asc,
            SU_LBL_ChangedAt desc
        )
    );
    INSERT INTO @SU_LBL_Subject_Label
    SELECT
        i.SU_LBL_SU_ID,
        i.Metadata_SU_LBL,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_Subject_Label,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_LBL_SU_ID
        FROM
            [dbo].[SU_LBL_Subject_Label] x
        WHERE
            x.SU_LBL_SU_ID = i.SU_LBL_SU_ID
        AND
            x.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
        AND
            x.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LBL_SU_ID,
            i.SU_LBL_ChangedAt
        FROM
            @SU_LBL_Subject_Label i
        JOIN
            [dbo].[SU_LBL_Subject_Label] x
        ON
            x.SU_LBL_SU_ID = i.SU_LBL_SU_ID
        AND
            x.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LBL_Subject_Label for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_LBL_Subject_Label
    SELECT
        i.SU_LBL_SU_ID,
        p.Metadata_SU_LBL,
        p.SU_LBL_ChangedAt,
        p.SU_LBL_Subject_Label,
        'X' -- existing data
    FROM (
        SELECT DISTINCT
            SU_LBL_SU_ID
        FROM
            @SU_LBL_Subject_Label
    ) i
    JOIN
        [dbo].[SU_LBL_Subject_Label] p
    ON
        p.SU_LBL_SU_ID = i.SU_LBL_SU_ID;
    DECLARE @restated TABLE (
    SU_LBL_SU_ID int not null,
        SU_LBL_ChangedAt datetime2 not null
    );
    INSERT INTO @restated
    SELECT
        x.SU_LBL_SU_ID,
        x.SU_LBL_ChangedAt
    FROM (
        DELETE a
        OUTPUT
            deleted.*
        FROM
            @SU_LBL_Subject_Label a
        OUTER APPLY (
            SELECT TOP 1
                h.SU_LBL_Subject_Label
            FROM
                @SU_LBL_Subject_Label h
            WHERE
                h.SU_LBL_SU_ID = a.SU_LBL_SU_ID
            AND
                h.SU_LBL_ChangedAt < a.SU_LBL_ChangedAt
            ORDER BY
                h.SU_LBL_ChangedAt DESC
        ) pre
        WHERE
            a.SU_LBL_Subject_Label = pre.SU_LBL_Subject_Label
    ) x
    WHERE
        x.SU_LBL_StatementType = 'X';
    -- remove the quenches (should happen rarely)
    DELETE a
    FROM
        [dbo].[SU_LBL_Subject_Label] a
    JOIN
        @restated d
    ON
        d.SU_LBL_SU_ID = a.SU_LBL_SU_ID
    AND
        d.SU_LBL_ChangedAt = a.SU_LBL_ChangedAt;
    INSERT INTO [dbo].[SU_LBL_Subject_Label] (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    FROM
        @SU_LBL_Subject_Label
    WHERE
        SU_LBL_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag instead of INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TAG_Subject_Tag', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TAG_Subject_Tag];
GO
CREATE TRIGGER [dbo].[it_SU_TAG_Subject_Tag] ON [dbo].[SU_TAG_Subject_Tag]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_TAG_Subject_Tag TABLE (
    SU_TAG_SU_ID int not null,
        Metadata_SU_TAG int not null,
        SU_TAG_ChangedAt datetime2 not null,
        SU_TAG_Subject_Tag nvarchar(42) not null,
        SU_TAG_StatementType char(1) not null,
        primary key (
            SU_TAG_SU_ID asc,
            SU_TAG_ChangedAt desc
        )
    );
    INSERT INTO @SU_TAG_Subject_Tag
    SELECT
        i.SU_TAG_SU_ID,
        i.Metadata_SU_TAG,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_Subject_Tag,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_TAG_SU_ID
        FROM
            [dbo].[SU_TAG_Subject_Tag] x
        WHERE
            x.SU_TAG_SU_ID = i.SU_TAG_SU_ID
        AND
            x.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
        AND
            x.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TAG_SU_ID,
            i.SU_TAG_ChangedAt
        FROM
            @SU_TAG_Subject_Tag i
        JOIN
            [dbo].[SU_TAG_Subject_Tag] x
        ON
            x.SU_TAG_SU_ID = i.SU_TAG_SU_ID
        AND
            x.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TAG_Subject_Tag for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TAG_Subject_Tag
    SELECT
        i.SU_TAG_SU_ID,
        p.Metadata_SU_TAG,
        p.SU_TAG_ChangedAt,
        p.SU_TAG_Subject_Tag,
        'X' -- existing data
    FROM (
        SELECT DISTINCT
            SU_TAG_SU_ID
        FROM
            @SU_TAG_Subject_Tag
    ) i
    JOIN
        [dbo].[SU_TAG_Subject_Tag] p
    ON
        p.SU_TAG_SU_ID = i.SU_TAG_SU_ID;
    DECLARE @restated TABLE (
    SU_TAG_SU_ID int not null,
        SU_TAG_ChangedAt datetime2 not null
    );
    INSERT INTO @restated
    SELECT
        x.SU_TAG_SU_ID,
        x.SU_TAG_ChangedAt
    FROM (
        DELETE a
        OUTPUT
            deleted.*
        FROM
            @SU_TAG_Subject_Tag a
        OUTER APPLY (
            SELECT TOP 1
                h.SU_TAG_Subject_Tag
            FROM
                @SU_TAG_Subject_Tag h
            WHERE
                h.SU_TAG_SU_ID = a.SU_TAG_SU_ID
            AND
                h.SU_TAG_ChangedAt < a.SU_TAG_ChangedAt
            ORDER BY
                h.SU_TAG_ChangedAt DESC
        ) pre
        WHERE
            a.SU_TAG_Subject_Tag = pre.SU_TAG_Subject_Tag
    ) x
    WHERE
        x.SU_TAG_StatementType = 'X';
    -- remove the quenches (should happen rarely)
    DELETE a
    FROM
        [dbo].[SU_TAG_Subject_Tag] a
    JOIN
        @restated d
    ON
        d.SU_TAG_SU_ID = a.SU_TAG_SU_ID
    AND
        d.SU_TAG_ChangedAt = a.SU_TAG_ChangedAt;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    )
    SELECT
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    FROM
        @SU_TAG_Subject_Tag
    WHERE
        SU_TAG_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level instead of INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LVL_Subject_Level', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LVL_Subject_Level];
GO
CREATE TRIGGER [dbo].[it_SU_LVL_Subject_Level] ON [dbo].[SU_LVL_Subject_Level]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_LVL_Subject_Level TABLE (
    SU_LVL_SU_ID int not null,
        Metadata_SU_LVL int not null,
        SU_LVL_ChangedAt datetime2 not null,
        SU_LVL_GRD_ID tinyint not null,
        SU_LVL_StatementType char(1) not null,
        primary key (
            SU_LVL_SU_ID asc,
            SU_LVL_ChangedAt desc
        )
    );
    INSERT INTO @SU_LVL_Subject_Level
    SELECT
        i.SU_LVL_SU_ID,
        i.Metadata_SU_LVL,
        i.SU_LVL_ChangedAt,
        i.SU_LVL_GRD_ID,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_LVL_SU_ID
        FROM
            [dbo].[SU_LVL_Subject_Level] x
        WHERE
            x.SU_LVL_SU_ID = i.SU_LVL_SU_ID
        AND
            x.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
        AND
            x.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LVL_SU_ID,
            i.SU_LVL_ChangedAt
        FROM
            @SU_LVL_Subject_Level i
        JOIN
            [dbo].[SU_LVL_Subject_Level] x
        ON
            x.SU_LVL_SU_ID = i.SU_LVL_SU_ID
        AND
            x.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LVL_Subject_Level for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_LVL_Subject_Level] (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    )
    SELECT
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    FROM
        @SU_LVL_Subject_Level
    WHERE
        SU_LVL_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text instead of INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TXT_Subject_Text', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TXT_Subject_Text];
GO
CREATE TRIGGER [dbo].[it_SU_TXT_Subject_Text] ON [dbo].[SU_TXT_Subject_Text]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_TXT_Subject_Text TABLE (
    SU_TXT_SU_ID int not null,
        Metadata_SU_TXT int not null,
        SU_TXT_ChangedAt datetime2 not null,
        SU_TXT_Subject_Text nvarchar(max) not null,
        SU_TXT_Checksum varbinary(16) not null,
        SU_TXT_StatementType char(1) not null,
        primary key (
            SU_TXT_SU_ID asc,
            SU_TXT_ChangedAt desc
        )
    );
    INSERT INTO @SU_TXT_Subject_Text
    SELECT
        i.SU_TXT_SU_ID,
        i.Metadata_SU_TXT,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_Subject_Text,
        dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))),
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_TXT_SU_ID
        FROM
            [dbo].[SU_TXT_Subject_Text] x
        WHERE
            x.SU_TXT_SU_ID = i.SU_TXT_SU_ID
        AND
            x.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
        AND
            x.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TXT_SU_ID,
            i.SU_TXT_ChangedAt
        FROM
            @SU_TXT_Subject_Text i
        JOIN
            [dbo].[SU_TXT_Subject_Text] x
        ON
            x.SU_TXT_SU_ID = i.SU_TXT_SU_ID
        AND
            x.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TXT_Subject_Text for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_TXT_Subject_Text] (
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    )
    SELECT
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    FROM
        @SU_TXT_Subject_Text
    WHERE
        SU_TXT_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment instead of INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ASR_Subject_Assessment', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ASR_Subject_Assessment];
GO
CREATE TRIGGER [dbo].[it_SU_ASR_Subject_Assessment] ON [dbo].[SU_ASR_Subject_Assessment]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_ASR_Subject_Assessment TABLE (
    SU_ASR_SU_ID int not null,
        Metadata_SU_ASR int not null,
        SU_ASR_ChangedAt datetime2 not null,
        SU_ASR_Subject_Assessment nvarchar(42) not null,
        SU_ASR_StatementType char(1) not null,
        primary key (
            SU_ASR_SU_ID asc,
            SU_ASR_ChangedAt desc
        )
    );
    INSERT INTO @SU_ASR_Subject_Assessment
    SELECT
        i.SU_ASR_SU_ID,
        i.Metadata_SU_ASR,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_Subject_Assessment,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_ASR_SU_ID
        FROM
            [dbo].[SU_ASR_Subject_Assessment] x
        WHERE
            x.SU_ASR_SU_ID = i.SU_ASR_SU_ID
        AND
            x.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
        AND
            x.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ASR_SU_ID,
            i.SU_ASR_ChangedAt
        FROM
            @SU_ASR_Subject_Assessment i
        JOIN
            [dbo].[SU_ASR_Subject_Assessment] x
        ON
            x.SU_ASR_SU_ID = i.SU_ASR_SU_ID
        AND
            x.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ASR_Subject_Assessment for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    )
    SELECT
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    FROM
        @SU_ASR_Subject_Assessment
    WHERE
        SU_ASR_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable instead of INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ERS_Subject_Erasable', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ERS_Subject_Erasable];
GO
CREATE TRIGGER [dbo].[it_SU_ERS_Subject_Erasable] ON [dbo].[SU_ERS_Subject_Erasable]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU_ERS_Subject_Erasable TABLE (
    SU_ERS_SU_ID int not null,
        Metadata_SU_ERS int not null,
        SU_ERS_ChangedAt datetime2 not null,
        SU_ERS_Subject_Erasable nvarchar(42) not null,
        SU_ERS_StatementType char(1) not null,
        primary key (
            SU_ERS_SU_ID asc,
            SU_ERS_ChangedAt desc
        )
    );
    INSERT INTO @SU_ERS_Subject_Erasable
    SELECT
        i.SU_ERS_SU_ID,
        i.Metadata_SU_ERS,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_Subject_Erasable,
        'P' -- new posit
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.SU_ERS_SU_ID
        FROM
            [dbo].[SU_ERS_Subject_Erasable] x
        WHERE
            x.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            x.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
        AND
            x.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
    ); -- the posit must be different (exclude the identical)
    -- another value at a time that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ERS_SU_ID,
            i.SU_ERS_ChangedAt
        FROM
            @SU_ERS_Subject_Erasable i
        JOIN
            [dbo].[SU_ERS_Subject_Erasable] x
        ON
            x.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            x.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ERS_Subject_Erasable for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    )
    SELECT
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    FROM
        @SU_ERS_Subject_Erasable
    WHERE
        SU_ERS_StatementType = 'P';
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name instead of INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_OB_NAM_Object_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_OB_NAM_Object_Name];
GO
CREATE TRIGGER [dbo].[it_OB_NAM_Object_Name] ON [dbo].[OB_NAM_Object_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- another value for an entity that already has a value is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_NAM_OB_ID
        FROM
            inserted i
        JOIN
            [dbo].[OB_NAM_Object_Name] x
        ON
            x.OB_NAM_OB_ID = i.OB_NAM_OB_ID
        WHERE NOT (
            x.OB_NAM_Object_Name = i.OB_NAM_Object_Name
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in OB_NAM_Object_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[OB_NAM_Object_Name] (
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name
    )
    SELECT
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            x.OB_NAM_OB_ID
        FROM
            [dbo].[OB_NAM_Object_Name] x
        WHERE
            x.OB_NAM_OB_ID = i.OB_NAM_OB_ID
        AND
            x.OB_NAM_Object_Name = i.OB_NAM_Object_Name
    );
END
GO
