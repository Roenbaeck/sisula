-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
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
        EV_QTY_PositedAt datetime2 null,
        EV_QTY_Reliability decimal(5,2) null,
        EV_QTY_Event_Quantity int null
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
        ISNULL(i.EV_QTY_PositedAt, @now),
        ISNULL(ISNULL(i.EV_QTY_Reliability, i.Reliability), 1),
        i.EV_QTY_Event_Quantity
    INTO
        @inserted;
    -- the rows that come with the identity of a nexus row
    INSERT INTO @inserted
    SELECT
        i.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_QTY_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_QTY, i.Metadata_EV),
        ISNULL(i.EV_QTY_PositedAt, @now),
        ISNULL(ISNULL(i.EV_QTY_Reliability, i.Reliability), 1),
        i.EV_QTY_Event_Quantity
    FROM
        inserted i
    WHERE
        i.EV_ID is not null;
    INSERT INTO [dbo].[EV_QTY_Event_Quantity] (
        Metadata_EV_QTY,
        EV_QTY_EV_ID,
        EV_QTY_Event_Quantity,
        EV_QTY_PositedAt,
        EV_QTY_Reliability
    )
    SELECT
        i.Metadata_EV_QTY,
        i.EV_QTY_EV_ID,
        i.EV_QTY_Event_Quantity,
        i.EV_QTY_PositedAt,
        i.EV_QTY_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_QTY_Event_Quantity is not null;
END
GO
