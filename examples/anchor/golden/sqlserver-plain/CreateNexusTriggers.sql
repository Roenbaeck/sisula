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
    DECLARE @inserted TABLE (
        EV_ID int not null,
        EV_DAT_Event_Date datetime2 null,
        EV_AUD_Event_Audience int null,
        EV_REV_Event_Revenue decimal(19,4) null
    );
    -- a nexus row for each row without an identity; the merge outputs every new identity together with the values of
    -- the row it was made for, so each new row keeps its own attributes, also when several are inserted at once
    MERGE INTO [dbo].[EV_Event]
    USING inserted AS i
    ON 1 = 0
    WHEN NOT MATCHED AND i.EV_ID is null THEN INSERT (
        ST_ID_wasHeldAt,
        PR_ID_wasPlayed,
        ETY_ID_of,
        EV_Dummy
    )
    VALUES (
        i.ST_ID_wasHeldAt,
        i.PR_ID_wasPlayed,
        i.ETY_ID_of,
        null
    )
    OUTPUT
        inserted.EV_ID,
        i.EV_DAT_Event_Date,
        i.EV_AUD_Event_Audience,
        i.EV_REV_Event_Revenue
    INTO
        @inserted;
    -- the rows that come with the identity of a nexus row
    INSERT INTO @inserted
    SELECT
        i.EV_ID,
        i.EV_DAT_Event_Date,
        i.EV_AUD_Event_Audience,
        i.EV_REV_Event_Revenue
    FROM
        inserted i
    WHERE
        i.EV_ID is not null;
    INSERT INTO [dbo].[EV_DAT_Event_Date] (
        EV_ID,
        EV_DAT_Event_Date
    )
    SELECT DISTINCT
        i.EV_ID,
        i.EV_DAT_Event_Date
    FROM
        @inserted i
    WHERE
        i.EV_DAT_Event_Date is not null;
    INSERT INTO [dbo].[EV_AUD_Event_Audience] (
        EV_ID,
        EV_AUD_Event_Audience
    )
    SELECT DISTINCT
        i.EV_ID,
        i.EV_AUD_Event_Audience
    FROM
        @inserted i
    WHERE
        i.EV_AUD_Event_Audience is not null;
    INSERT INTO [dbo].[EV_REV_Event_Revenue] (
        EV_ID,
        EV_REV_Event_Revenue
    )
    SELECT DISTINCT
        i.EV_ID,
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    IF(UPDATE(EV_ID))
        RAISERROR('The identity column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_ID_wasHeldAt))
        RAISERROR('The role column ST_ID_wasHeldAt is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_wasPlayed))
        RAISERROR('The role column PR_ID_wasPlayed is not updatable.', 16, 1);
    IF(UPDATE(ETY_ID_of))
        RAISERROR('The role column ETY_ID_of is not updatable.', 16, 1);
    IF(UPDATE(ETY_EventType))
        RAISERROR('The role column ETY_EventType is not updatable.', 16, 1);
    DECLARE @updated_EV_DAT_Event_Date bit = CASE WHEN UPDATE(EV_DAT_Event_Date) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(@updated_EV_DAT_Event_Date = 1)
    BEGIN
        INSERT INTO [dbo].[EV_DAT_Event_Date] (
            EV_ID,
            EV_DAT_Event_Date
        )
        SELECT DISTINCT
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_DAT_Event_Date
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_DAT_Event_Date is not null
        AND ( -- a value that is left as it is states nothing
            d.EV_DAT_Event_Date is null OR
            d.EV_DAT_Event_Date <> i.EV_DAT_Event_Date
        );
    END
    DECLARE @updated_EV_AUD_Event_Audience bit = CASE WHEN UPDATE(EV_AUD_Event_Audience) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(@updated_EV_AUD_Event_Audience = 1)
    BEGIN
        INSERT INTO [dbo].[EV_AUD_Event_Audience] (
            EV_ID,
            EV_AUD_Event_Audience
        )
        SELECT DISTINCT
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_AUD_Event_Audience
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_AUD_Event_Audience is not null
        AND ( -- a value that is left as it is states nothing
            d.EV_AUD_Event_Audience is null OR
            d.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience
        );
    END
    DECLARE @updated_EV_REV_Event_Revenue bit = CASE WHEN UPDATE(EV_REV_Event_Revenue) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(@updated_EV_REV_Event_Revenue = 1)
    BEGIN
        INSERT INTO [dbo].[EV_REV_Event_Revenue] (
            EV_ID,
            EV_REV_Event_Revenue
        )
        SELECT DISTINCT
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_REV_Event_Revenue
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_REV_Event_Revenue is not null
        AND ( -- a value that is left as it is states nothing
            d.EV_REV_Event_Revenue is null OR
            d.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue
        );
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
        d.EV_ID = [DAT].EV_ID;
    DELETE [AUD]
    FROM
        [dbo].[EV_AUD_Event_Audience] [AUD]
    JOIN
        deleted d
    ON
        d.EV_ID = [AUD].EV_ID;
    DELETE [REV]
    FROM
        [dbo].[EV_REV_Event_Revenue] [REV]
    JOIN
        deleted d
    ON
        d.EV_ID = [REV].EV_ID;
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
            SELECT TOP 1 EV_ID
            FROM [dbo].[EV_DAT_Event_Date] WITH(NOLOCK)
            WHERE EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_ID
            FROM [dbo].[EV_AUD_Event_Audience] WITH(NOLOCK)
            WHERE EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_ID
            FROM [dbo].[EV_REV_Event_Revenue] WITH(NOLOCK)
            WHERE EV_ID = [EV].EV_ID
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
