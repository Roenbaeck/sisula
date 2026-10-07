-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest nexus perspective make it behave like a table for CRUD
-- operations over the nexus and its attributes. A nexus base row is immutable apart from its metadata dummy column;
-- historization only applies to its historized attributes (the base row has no changing column). Roles (anchor/nexus
-- /knot foreign keys) are part of the immutable nexus identity row and therefore are not updatable once set.
--
-- Three INSTEAD OF triggers are created when a nexus has attributes: insert, update, delete.
-- Insert: creates base nexus rows for NULL identity inputs and inserts attribute rows (knotted or not) with defaults.
-- Update: only allows changing attribute values (including knotted values); role foreign keys and identity are not
-- updatable. Historized attributes get a new version row; non-historized ones behave idempotently.
-- Delete: deletes attribute rows and conditionally deletes the base nexus row if it becomes orphaned (no attributes).
--
-- Deletable attributes (soft delete semantics) follow the same pattern as anchors: if attribute value set to NULL and
-- deletable flag = 1, a deletion record is stored in a parallel deletion table capturing deletion time.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lEV_Event] ON [dbo].[lEV_Event]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @EV TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        EV_ID int not null
    );
    INSERT INTO [dbo].[EV_Event] (
        Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID
    INTO
        @EV
    SELECT
        Metadata_EV 
    FROM
        inserted
    WHERE
        inserted.EV_ID is null;
    DECLARE @inserted TABLE (
        EV_ID int not null,
        Metadata_EV int not null,
        EV_DAT_EV_ID int null,
        Metadata_EV_DAT int null,
        EV_DAT_Event_Date datetime2 null,
        EV_AUD_EV_ID int null,
        Metadata_EV_AUD int null,
        EV_AUD_Event_Audience int null,
        EV_REV_EV_ID int null,
        Metadata_EV_REV int null,
        EV_REV_Event_Revenue decimal(19,4) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.EV_ID, a.EV_ID),
        i.Metadata_EV,
        ISNULL(ISNULL(i.EV_DAT_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        i.EV_DAT_Event_Date,
        ISNULL(ISNULL(i.EV_AUD_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        i.EV_AUD_Event_Audience,
        ISNULL(ISNULL(i.EV_REV_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        i.EV_REV_Event_Revenue
    FROM (
        SELECT
            EV_ID,
            Metadata_EV,
            EV_DAT_EV_ID,
            Metadata_EV_DAT,
            EV_DAT_Event_Date,
            EV_AUD_EV_ID,
            Metadata_EV_AUD,
            EV_AUD_Event_Audience,
            EV_REV_EV_ID,
            Metadata_EV_REV,
            EV_REV_Event_Revenue,
            ROW_NUMBER() OVER (PARTITION BY EV_ID ORDER BY EV_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @EV a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[EV_DAT_Event_Date] (
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_Event_Date
    )
    SELECT DISTINCT
        i.Metadata_EV_DAT,
        i.EV_DAT_EV_ID,
        i.EV_DAT_Event_Date
    FROM
        @inserted i
    WHERE
        i.EV_DAT_Event_Date is not null;
    INSERT INTO [dbo].[EV_AUD_Event_Audience] (
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience
    )
    SELECT DISTINCT
        i.Metadata_EV_AUD,
        i.EV_AUD_EV_ID,
        i.EV_AUD_Event_Audience
    FROM
        @inserted i
    WHERE
        i.EV_AUD_Event_Audience is not null;
    INSERT INTO [dbo].[EV_REV_Event_Revenue] (
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_Event_Revenue
    )
    SELECT DISTINCT
        i.Metadata_EV_REV,
        i.EV_REV_EV_ID,
        i.EV_REV_Event_Revenue
    FROM
        @inserted i
    WHERE
        i.EV_REV_Event_Revenue is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lEV_Event] ON [dbo].[lEV_Event]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(EV_ID))
        RAISERROR('The identity column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_EV_ID))
        RAISERROR('The foreign key column EV_DAT_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_Event_Date))
    BEGIN
        INSERT INTO [dbo].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_DAT)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_DAT
            END, i.Metadata_EV),
            ISNULL(i.EV_DAT_EV_ID, i.EV_ID),
            i.EV_DAT_Event_Date
        FROM
            inserted i
        WHERE
            i.EV_DAT_Event_Date is not null;
    END
    IF(UPDATE(EV_AUD_EV_ID))
        RAISERROR('The foreign key column EV_AUD_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_AUD_Event_Audience))
    BEGIN
        INSERT INTO [dbo].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_AUD)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            ISNULL(i.EV_AUD_EV_ID, i.EV_ID),
            i.EV_AUD_Event_Audience
        FROM
            inserted i
        WHERE
            i.EV_AUD_Event_Audience is not null;
    END
    IF(UPDATE(EV_REV_EV_ID))
        RAISERROR('The foreign key column EV_REV_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_REV_Event_Revenue))
    BEGIN
        INSERT INTO [dbo].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_REV)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_REV
            END, i.Metadata_EV),
            ISNULL(i.EV_REV_EV_ID, i.EV_ID),
            i.EV_REV_Event_Revenue
        FROM
            inserted i
        WHERE
            i.EV_REV_Event_Revenue is not null;
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lEV_Event] ON [dbo].[lEV_Event]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [DAT]
    FROM
        [dbo].[EV_DAT_Event_Date] [DAT]
    JOIN
        deleted d
    ON
        d.EV_DAT_EV_ID = [DAT].EV_DAT_EV_ID;
    DELETE [AUD]
    FROM
        [dbo].[EV_AUD_Event_Audience] [AUD]
    JOIN
        deleted d
    ON
        d.EV_AUD_EV_ID = [AUD].EV_AUD_EV_ID;
    DELETE [REV]
    FROM
        [dbo].[EV_REV_Event_Revenue] [REV]
    JOIN
        deleted d
    ON
        d.EV_REV_EV_ID = [REV].EV_REV_EV_ID;
    DECLARE @deleted TABLE (
        EV_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (EV_ID)
    SELECT a.EV_ID
    FROM (
        SELECT [EV].EV_ID
        FROM [dbo].[EV_Event] [EV] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 EV_DAT_EV_ID
            FROM [dbo].[EV_DAT_Event_Date] WITH(NOLOCK)
            WHERE EV_DAT_EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_AUD_EV_ID
            FROM [dbo].[EV_AUD_Event_Audience] WITH(NOLOCK)
            WHERE EV_AUD_EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_REV_EV_ID
            FROM [dbo].[EV_REV_Event_Revenue] WITH(NOLOCK)
            WHERE EV_REV_EV_ID = [EV].EV_ID
        )
    ) a
    JOIN deleted d
    ON d.EV_ID = a.EV_ID;
    DELETE [EV]
    FROM [dbo].[EV_Event] [EV]
    JOIN @deleted d
    ON d.EV_ID = [EV].EV_ID;
END
GO
