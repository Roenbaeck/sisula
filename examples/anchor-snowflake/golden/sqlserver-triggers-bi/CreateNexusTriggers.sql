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
    DECLARE @EV TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        EV_ID int not null
    );
    INSERT INTO [dbo].[EV_Event] (
        SU_ID_for,
        Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID
    INTO
        @EV
    SELECT
        SU_ID_for,
        Metadata_EV 
    FROM
        inserted
    WHERE
        inserted.EV_ID is null;
    DECLARE @inserted TABLE (
        EV_ID int not null,
        Metadata_EV int not null,
        EV_QTY_EV_ID int null,
        Metadata_EV_QTY int null,
        EV_QTY_PositedAt datetime2 null,
        EV_QTY_Reliability decimal(5,2) null,
        EV_QTY_Event_Quantity int null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.EV_ID, a.EV_ID),
        i.Metadata_EV,
        ISNULL(ISNULL(i.EV_QTY_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_QTY, i.Metadata_EV),
        ISNULL(i.EV_QTY_PositedAt, @now),
        ISNULL(ISNULL(i.EV_QTY_Reliability, i.Reliability), 1),
        i.EV_QTY_Event_Quantity
    FROM (
        SELECT
            Reliability,
            EV_ID,
            Metadata_EV,
            EV_QTY_EV_ID,
            Metadata_EV_QTY,
            EV_QTY_PositedAt,
            EV_QTY_Reliability,
            EV_QTY_Event_Quantity,
            ROW_NUMBER() OVER (PARTITION BY EV_ID ORDER BY EV_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @EV a
    ON
        a.Row = i.Row;
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
