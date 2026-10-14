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
        EV_DAT_EV_ID int null,
        Metadata_EV_DAT int null,
        EV_DAT_PositedAt datetime2 null,
        EV_DAT_Reliability decimal(5,2) null,
        EV_DAT_Event_Date datetime2 null,
        EV_AUD_EV_ID int null,
        Metadata_EV_AUD int null,
        EV_AUD_PositedAt datetime2 null,
        EV_AUD_Reliability decimal(5,2) null,
        EV_AUD_Event_Audience int null,
        EV_REV_EV_ID int null,
        Metadata_EV_REV int null,
        EV_REV_PositedAt datetime2 null,
        EV_REV_Reliability decimal(5,2) null,
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
        Metadata_EV 
    )
    VALUES (
        i.ST_ID_wasHeldAt,
        i.PR_ID_wasPlayed,
        i.ETY_ID_of,
        i.Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_DAT_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.EV_AUD_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.EV_REV_EV_ID, inserted.EV_ID),
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue
    INTO
        @inserted;
    -- the rows that come with the identity of a nexus row
    INSERT INTO @inserted
    SELECT
        i.EV_ID,
        i.Metadata_EV,
        ISNULL(i.EV_DAT_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.EV_AUD_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.EV_REV_EV_ID, i.EV_ID),
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue
    FROM
        inserted i
    WHERE
        i.EV_ID is not null;
    INSERT INTO [dbo].[EV_DAT_Event_Date] (
        Metadata_EV_DAT,
        EV_DAT_EV_ID,
        EV_DAT_Event_Date,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        i.Metadata_EV_DAT,
        i.EV_DAT_EV_ID,
        i.EV_DAT_Event_Date,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_DAT_Event_Date is not null;
    INSERT INTO [dbo].[EV_AUD_Event_Audience] (
        Metadata_EV_AUD,
        EV_AUD_EV_ID,
        EV_AUD_Event_Audience,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        i.Metadata_EV_AUD,
        i.EV_AUD_EV_ID,
        i.EV_AUD_Event_Audience,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_AUD_Event_Audience is not null;
    INSERT INTO [dbo].[EV_REV_Event_Revenue] (
        Metadata_EV_REV,
        EV_REV_EV_ID,
        EV_REV_Event_Revenue,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        i.Metadata_EV_REV,
        i.EV_REV_EV_ID,
        i.EV_REV_Event_Revenue,
        i.EV_REV_PositedAt,
        i.EV_REV_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_REV_Event_Revenue is not null;
END
GO
