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
    IF(UPDATE(ST_ID_wasHeldAt))
        RAISERROR('The role column ST_ID_wasHeldAt is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_wasPlayed))
        RAISERROR('The role column PR_ID_wasPlayed is not updatable.', 16, 1);
    IF(UPDATE(ETY_ID_of))
        RAISERROR('The role column ETY_ID_of is not updatable.', 16, 1);
    IF(UPDATE(of_ETY_EventType))
        RAISERROR('The role column of_ETY_EventType is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_ID))
        RAISERROR('The identity column EV_DAT_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_EV_ID))
        RAISERROR('The foreign key column EV_DAT_EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(EV_DAT_Event_Date) OR
        UPDATE(EV_DAT_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_DAT)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_DAT
            END, i.Metadata_EV),
            ISNULL(i.EV_DAT_EV_ID, i.EV_ID),
            i.EV_DAT_Event_Date,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_DAT_PositedAt) THEN i.EV_DAT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_DAT_Reliability) THEN i.EV_DAT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_DAT_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_DAT_Event_Date is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_DAT_PositedAt) OR
            d.EV_DAT_Event_Date is null OR
            d.EV_DAT_Event_Date <> i.EV_DAT_Event_Date OR
            d.EV_DAT_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_DAT_Reliability) THEN i.EV_DAT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_DAT_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_DAT_Event_Date)
    )
    BEGIN
        INSERT INTO [dbo].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_DAT)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_DAT
            END, i.Metadata_EV),
            p.EV_DAT_EV_ID,
            p.EV_DAT_Event_Date,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_DAT_PositedAt) THEN i.EV_DAT_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_DAT_Event_Date_Posit] p
        ON
            p.EV_DAT_ID = i.EV_DAT_ID
        WHERE
            i.EV_DAT_Event_Date is null
    END
    IF(UPDATE(EV_AUD_ID))
        RAISERROR('The identity column EV_AUD_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_AUD_EV_ID))
        RAISERROR('The foreign key column EV_AUD_EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(EV_AUD_Event_Audience) OR
        UPDATE(EV_AUD_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_AUD)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            ISNULL(i.EV_AUD_EV_ID, i.EV_ID),
            i.EV_AUD_Event_Audience,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_AUD_PositedAt) THEN i.EV_AUD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_AUD_Reliability) THEN i.EV_AUD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_AUD_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_AUD_Event_Audience is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_AUD_PositedAt) OR
            d.EV_AUD_Event_Audience is null OR
            d.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience OR
            d.EV_AUD_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_AUD_Reliability) THEN i.EV_AUD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_AUD_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_AUD_Event_Audience)
    )
    BEGIN
        INSERT INTO [dbo].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_AUD)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            p.EV_AUD_EV_ID,
            p.EV_AUD_Event_Audience,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_AUD_PositedAt) THEN i.EV_AUD_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_AUD_Event_Audience_Posit] p
        ON
            p.EV_AUD_ID = i.EV_AUD_ID
        WHERE
            i.EV_AUD_Event_Audience is null
    END
    IF(UPDATE(EV_REV_ID))
        RAISERROR('The identity column EV_REV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_REV_EV_ID))
        RAISERROR('The foreign key column EV_REV_EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(EV_REV_Event_Revenue) OR
        UPDATE(EV_REV_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_REV)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_REV
            END, i.Metadata_EV),
            ISNULL(i.EV_REV_EV_ID, i.EV_ID),
            i.EV_REV_Event_Revenue,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_REV_PositedAt) THEN i.EV_REV_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_REV_Reliability) THEN i.EV_REV_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_REV_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_REV_Event_Revenue is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_REV_PositedAt) OR
            d.EV_REV_Event_Revenue is null OR
            d.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue OR
            d.EV_REV_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_REV_Reliability) THEN i.EV_REV_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_REV_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_REV_Event_Revenue)
    )
    BEGIN
        INSERT INTO [dbo].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_REV)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_REV
            END, i.Metadata_EV),
            p.EV_REV_EV_ID,
            p.EV_REV_Event_Revenue,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_REV_PositedAt) THEN i.EV_REV_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [dbo].[EV_REV_Event_Revenue_Posit] p
        ON
            p.EV_REV_ID = i.EV_REV_ID
        WHERE
            i.EV_REV_Event_Revenue is null
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
    INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
        Metadata_EV_DAT,
        EV_DAT_ID,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        d.Metadata_EV_DAT,
        d.EV_DAT_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_DAT_ID is not null;
    INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        d.Metadata_EV_AUD,
        d.EV_AUD_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_AUD_ID is not null;
    INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        d.Metadata_EV_REV,
        d.EV_REV_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_REV_ID is not null;
END
GO
