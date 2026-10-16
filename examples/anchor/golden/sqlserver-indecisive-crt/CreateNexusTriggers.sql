-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- The roles of a nexus are part of its identity, so they are not updatable.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
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
        Metadata_EV int not null,
        EV_QTY_EV_ID int null,
        Metadata_EV_QTY int null,
        EV_QTY_Positor tinyint null,
        EV_QTY_PositedAt datetime2 null,
        EV_QTY_Reliability decimal(5,2) null,
        EV_QTY_Event_Quantity int null,
        EV_PLC_EV_ID int null,
        Metadata_EV_PLC int null,
        EV_PLC_ChangedAt datetime2 null,
        EV_PLC_Positor tinyint null,
        EV_PLC_PositedAt datetime2 null,
        EV_PLC_Reliability decimal(5,2) null,
        EV_PLC_Event_Place nvarchar(42) null
    );
    -- a nexus row for each row without an identity; the merge outputs every new identity together with the values of
    -- the row it was made for, so each new row keeps its own attributes, also when several are inserted at once
    MERGE INTO [dbo].[EV_Event]
    USING inserted AS i
    ON 1 = 0
    WHEN NOT MATCHED AND i.EV_ID is null THEN INSERT (
        SU_ID_for,
        Metadata_EV 
    )
    VALUES (
        i.SU_ID_for,
        i.Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_QTY_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_QTY, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_QTY_Positor, i.Positor), 0),
        ISNULL(i.EV_QTY_PositedAt, @now),
        ISNULL(ISNULL(i.EV_QTY_Reliability, i.Reliability), 1),
        i.EV_QTY_Event_Quantity,
        ISNULL(i.EV_PLC_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_PLC, i.Metadata_EV),
        ISNULL(i.EV_PLC_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Positor, i.Positor), 0),
        ISNULL(i.EV_PLC_PositedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Reliability, i.Reliability), 1),
        i.EV_PLC_Event_Place
    INTO
        @inserted;
    -- the rows that come with the identity of a nexus row
    INSERT INTO @inserted
    SELECT
        i.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_QTY_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_QTY, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_QTY_Positor, i.Positor), 0),
        ISNULL(i.EV_QTY_PositedAt, @now),
        ISNULL(ISNULL(i.EV_QTY_Reliability, i.Reliability), 1),
        i.EV_QTY_Event_Quantity,
        ISNULL(i.EV_PLC_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_PLC, i.Metadata_EV),
        ISNULL(i.EV_PLC_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Positor, i.Positor), 0),
        ISNULL(i.EV_PLC_PositedAt, @now),
        ISNULL(ISNULL(i.EV_PLC_Reliability, i.Reliability), 1),
        i.EV_PLC_Event_Place
    FROM
        inserted i
    WHERE
        i.EV_ID is not null;
    INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity,
        EV_QTY_PositedAt,
        EV_QTY_Positor,
        EV_QTY_Reliability
    )
    SELECT
        i.Metadata_EV_QTY,
        i.EV_QTY_EV_ID,
        i.EV_QTY_Event_Quantity,
        i.EV_QTY_PositedAt,
        i.EV_QTY_Positor,
        i.EV_QTY_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_QTY_Event_Quantity is not null;
    INSERT INTO [dbo].[EV_PLC_Event_Place] (
        Metadata_EV_PLC,
        EV_PLC_EV_ID,
        EV_PLC_Event_Place,
        EV_PLC_ChangedAt,
        EV_PLC_PositedAt,
        EV_PLC_Positor,
        EV_PLC_Reliability
    )
    SELECT
        i.Metadata_EV_PLC,
        i.EV_PLC_EV_ID,
        i.EV_PLC_Event_Place,
        i.EV_PLC_ChangedAt,
        i.EV_PLC_PositedAt,
        i.EV_PLC_Positor,
        i.EV_PLC_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_PLC_Event_Place is not null;
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
    IF(UPDATE(SU_ID_for))
        RAISERROR('The role column SU_ID_for is not updatable.', 16, 1);
    IF(UPDATE(EV_QTY_ID))
        RAISERROR('The identity column EV_QTY_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_QTY_EV_ID))
        RAISERROR('The foreign key column EV_QTY_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_QTY_Assertion))
        RAISERROR('The computed assertion column EV_QTY_Assertion is not updatable.', 16, 1);
    -- indecisive: another value is a correction, which retracts the shown one first, so that the new value is not taken
    -- for an alternative to it
    IF (
        UPDATE(EV_QTY_Event_Quantity)
    )
    BEGIN
        INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
            Metadata_EV_QTY,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_QTY)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_QTY
            END, i.Metadata_EV),
            p.EV_QTY_EV_ID,
            p.EV_QTY_Event_Quantity,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2),
            d.EV_QTY_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_ID = d.EV_QTY_ID
        WHERE
            p.EV_QTY_Event_Quantity <> i.EV_QTY_Event_Quantity
        AND
            d.EV_QTY_Positor = ISNULL(CASE
                WHEN UPDATE(EV_QTY_Positor) THEN i.EV_QTY_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.EV_QTY_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Reliability) THEN i.EV_QTY_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_QTY_Reliability
            END, 1) <> 0;
    END
    IF (
        UPDATE(EV_QTY_Event_Quantity) OR
        UPDATE(EV_QTY_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
            Metadata_EV_QTY,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_QTY)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_QTY
            END, i.Metadata_EV),
            ISNULL(i.EV_QTY_EV_ID, i.EV_ID),
            i.EV_QTY_Event_Quantity,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Positor) THEN i.EV_QTY_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Reliability) THEN i.EV_QTY_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_QTY_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.EV_QTY_Event_Quantity is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_QTY_PositedAt) OR
            UPDATE(EV_QTY_Positor) OR
            UPDATE(Positor) OR
            d.EV_QTY_Event_Quantity is null OR
            d.EV_QTY_Event_Quantity <> i.EV_QTY_Event_Quantity OR
            d.EV_QTY_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_QTY_Reliability) THEN i.EV_QTY_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_QTY_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_QTY_Event_Quantity)
    )
    BEGIN
        INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
            Metadata_EV_QTY,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_QTY)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_QTY
            END, i.Metadata_EV),
            p.EV_QTY_EV_ID,
            p.EV_QTY_Event_Quantity,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_QTY_PositedAt) THEN i.EV_QTY_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_QTY_Positor) THEN i.EV_QTY_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_ID = i.EV_QTY_ID
        WHERE
            i.EV_QTY_Event_Quantity is null
    END
    IF(UPDATE(EV_PLC_ID))
        RAISERROR('The identity column EV_PLC_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_PLC_EV_ID))
        RAISERROR('The foreign key column EV_PLC_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_PLC_Assertion))
        RAISERROR('The computed assertion column EV_PLC_Assertion is not updatable.', 16, 1);
    -- indecisive: another value at the same changing time is a correction, which retracts the shown one first, so that
    -- the new value is not taken for an alternative to it
    IF (
        UPDATE(EV_PLC_Event_Place)
    )
    BEGIN
        INSERT INTO [dbo].[EV_PLC_Event_Place] (
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_PLC)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_PLC
            END, i.Metadata_EV),
            p.EV_PLC_EV_ID,
            p.EV_PLC_Event_Place,
            p.EV_PLC_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
            END, @now) as datetime2),
            d.EV_PLC_Positor,
            0
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_ID = d.EV_PLC_ID
        WHERE
            p.EV_PLC_Event_Place <> i.EV_PLC_Event_Place
        AND
            UPDATE(EV_PLC_ChangedAt)
        AND
            p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
        AND
            d.EV_PLC_Positor = ISNULL(CASE
                WHEN UPDATE(EV_PLC_Positor) THEN i.EV_PLC_Positor
                ELSE i.Positor
            END, 0)
        AND
            d.EV_PLC_PositedAt < cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
            END, @now) as datetime2)
        AND
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Reliability) THEN i.EV_PLC_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_PLC_Reliability
            END, 1) <> 0;
    END
    IF (
        UPDATE(EV_PLC_Event_Place) OR
        UPDATE(EV_PLC_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[EV_PLC_Event_Place] (
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_PLC)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_PLC
            END, i.Metadata_EV),
            ISNULL(i.EV_PLC_EV_ID, i.EV_ID),
            i.EV_PLC_Event_Place,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_ChangedAt) THEN i.EV_PLC_ChangedAt
                WHEN d.EV_PLC_Event_Place = i.EV_PLC_Event_Place
                THEN i.EV_PLC_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Positor) THEN i.EV_PLC_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Reliability) THEN i.EV_PLC_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_PLC_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.EV_PLC_Event_Place is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_PLC_ChangedAt) OR
            UPDATE(EV_PLC_PositedAt) OR
            UPDATE(EV_PLC_Positor) OR
            UPDATE(Positor) OR
            d.EV_PLC_Event_Place is null OR
            d.EV_PLC_Event_Place <> i.EV_PLC_Event_Place OR
            d.EV_PLC_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_PLC_Reliability) THEN i.EV_PLC_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_PLC_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_PLC_Event_Place)
    )
    BEGIN
        INSERT INTO [dbo].[EV_PLC_Event_Place] (
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_PLC)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_PLC
            END, i.Metadata_EV),
            p.EV_PLC_EV_ID,
            p.EV_PLC_Event_Place,
            p.EV_PLC_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_PLC_PositedAt) THEN i.EV_PLC_PositedAt
                WHEN UPDATE(EV_PLC_ChangedAt) THEN i.EV_PLC_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_PLC_Positor) THEN i.EV_PLC_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_ID = i.EV_PLC_ID
        WHERE
            i.EV_PLC_Event_Place is null
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[EV_QTY_Event_Quantity_Annex] (
        Metadata_EV_QTY,
        EV_QTY_ID,
        EV_QTY_Positor,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    SELECT
        d.Metadata_EV_QTY,
        d.EV_QTY_ID,
        d.EV_QTY_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_QTY_ID is not null;
    INSERT INTO [dbo].[EV_PLC_Event_Place_Annex] (
        Metadata_EV_PLC,
        EV_PLC_ID,
        EV_PLC_Positor,
        EV_PLC_PositedAt,
        EV_PLC_Reliability
    )
    SELECT
        d.Metadata_EV_PLC,
        d.EV_PLC_ID,
        d.EV_PLC_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_PLC_ID is not null;
END
GO
