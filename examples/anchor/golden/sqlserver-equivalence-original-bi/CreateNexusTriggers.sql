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
CREATE TRIGGER [nexuses].[it_lEV_Event] ON [nexuses].[lEV_Event]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        EV_ID numeric(12,0) not null,
        Metadata_EV int not null,
        Metadata_EV_DAT int null,
        EV_DAT_PositedAt datetime2 null,
        EV_DAT_Reliability decimal(5,2) null,
        EV_DAT_Event_Date datetime2 null,
        Metadata_EV_AUD int null,
        EV_AUD_PositedAt datetime2 null,
        EV_AUD_Reliability decimal(5,2) null,
        EV_AUD_Event_Audience int null,
        Metadata_EV_REV int null,
        EV_REV_PositedAt datetime2 null,
        EV_REV_Reliability decimal(5,2) null,
        EV_REV_Event_Revenue decimal(19,4) null,
        Metadata_EV_STA int null,
        EV_STA_ChangedAt datetime2 null,
        EV_STA_PositedAt datetime2 null,
        EV_STA_Reliability decimal(5,2) null,
        EV_STA_Event_Status nvarchar(20) null,
        Metadata_EV_UTL int null,
        EV_UTL_PositedAt datetime2 null,
        EV_UTL_Reliability decimal(5,2) null,
        UTL_Utilization tinyint null,
        Metadata_UTL int null,
        UTL_ID tinyint null,
        Metadata_EV_LVL int null,
        EV_LVL_ChangedAt date null,
        EV_LVL_PositedAt datetime2 null,
        EV_LVL_Reliability decimal(5,2) null,
        PLV_ProfessionalLevel nvarchar(max) null,
        PLV_Checksum varbinary(16) null,
        Metadata_PLV int null,
        PLV_ID tinyint null
    );
    -- a nexus row for each row without an identity; the merge outputs every new identity together with the values of
    -- the row it was made for, so each new row keeps its own attributes, also when several are inserted at once
    MERGE INTO [nexuses].[EV_Event]
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
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue,
        ISNULL(i.Metadata_EV_STA, i.Metadata_EV),
        ISNULL(i.EV_STA_ChangedAt, @now),
        ISNULL(i.EV_STA_PositedAt, @now),
        ISNULL(ISNULL(i.EV_STA_Reliability, i.Reliability), 1),
        i.EV_STA_Event_Status,
        ISNULL(i.Metadata_EV_UTL, i.Metadata_EV),
        ISNULL(i.EV_UTL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_UTL_Reliability, i.Reliability), 1),
        i.UTL_Utilization,
        ISNULL(i.Metadata_UTL, i.Metadata_EV),
        i.UTL_ID,
        ISNULL(i.Metadata_EV_LVL, i.Metadata_EV),
        ISNULL(i.EV_LVL_ChangedAt, @now),
        ISNULL(i.EV_LVL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_LVL_Reliability, i.Reliability), 1),
        i.PLV_ProfessionalLevel,
        ISNULL(i.PLV_Checksum, dw.MD5(cast(i.PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.Metadata_PLV, i.Metadata_EV),
        i.PLV_ID
    INTO
        @inserted;
    -- the rows that come with the identity of a nexus row
    INSERT INTO @inserted
    SELECT
        i.EV_ID,
        i.Metadata_EV,
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue,
        ISNULL(i.Metadata_EV_STA, i.Metadata_EV),
        ISNULL(i.EV_STA_ChangedAt, @now),
        ISNULL(i.EV_STA_PositedAt, @now),
        ISNULL(ISNULL(i.EV_STA_Reliability, i.Reliability), 1),
        i.EV_STA_Event_Status,
        ISNULL(i.Metadata_EV_UTL, i.Metadata_EV),
        ISNULL(i.EV_UTL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_UTL_Reliability, i.Reliability), 1),
        i.UTL_Utilization,
        ISNULL(i.Metadata_UTL, i.Metadata_EV),
        i.UTL_ID,
        ISNULL(i.Metadata_EV_LVL, i.Metadata_EV),
        ISNULL(i.EV_LVL_ChangedAt, @now),
        ISNULL(i.EV_LVL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_LVL_Reliability, i.Reliability), 1),
        i.PLV_ProfessionalLevel,
        ISNULL(i.PLV_Checksum, dw.MD5(cast(i.PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.Metadata_PLV, i.Metadata_EV),
        i.PLV_ID
    FROM
        inserted i
    WHERE
        i.EV_ID is not null;
    INSERT INTO [attributes].[EV_DAT_Event_Date] (
        Metadata_EV_DAT,
        EV_ID,
        EV_DAT_Event_Date,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        i.Metadata_EV_DAT,
        i.EV_ID,
        i.EV_DAT_Event_Date,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_DAT_Event_Date is not null;
    INSERT INTO [attributes].[EV_AUD_Event_Audience] (
        Metadata_EV_AUD,
        EV_ID,
        EV_AUD_Event_Audience,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        i.Metadata_EV_AUD,
        i.EV_ID,
        i.EV_AUD_Event_Audience,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_AUD_Event_Audience is not null;
    INSERT INTO [attributes].[EV_REV_Event_Revenue] (
        Metadata_EV_REV,
        EV_ID,
        EV_REV_Event_Revenue,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        i.Metadata_EV_REV,
        i.EV_ID,
        i.EV_REV_Event_Revenue,
        i.EV_REV_PositedAt,
        i.EV_REV_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_REV_Event_Revenue is not null;
    INSERT INTO [attributes].[EV_STA_Event_Status] (
        Metadata_EV_STA,
        EV_ID,
        EV_STA_Event_Status,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability
    )
    SELECT
        i.Metadata_EV_STA,
        i.EV_ID,
        i.EV_STA_Event_Status,
        i.EV_STA_ChangedAt,
        i.EV_STA_PositedAt,
        i.EV_STA_Reliability
    FROM
        @inserted i
    WHERE
        i.EV_STA_Event_Status is not null;
    INSERT INTO [attributes].[EV_UTL_Event_Utilization] (
        Metadata_EV_UTL,
        EV_ID,
        UTL_ID,
        EV_UTL_PositedAt,
        EV_UTL_Reliability
    )
    SELECT
        i.Metadata_EV_UTL,
        i.EV_ID,
        ISNULL(i.UTL_ID, [kUTL].UTL_ID), 
        i.EV_UTL_PositedAt,
        i.EV_UTL_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [knots].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.UTL_Utilization
    WHERE
        ISNULL(i.UTL_ID, [kUTL].UTL_ID) is not null;
    INSERT INTO [attributes].[EV_LVL_Event_Level] (
        Metadata_EV_LVL,
        EV_ID,
        PLV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability
    )
    SELECT
        i.Metadata_EV_LVL,
        i.EV_ID,
        ISNULL(i.PLV_ID, [kPLV].PLV_ID), 
        i.EV_LVL_ChangedAt,
        i.EV_LVL_PositedAt,
        i.EV_LVL_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [knots].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.PLV_Checksum 
    WHERE
        ISNULL(i.PLV_ID, [kPLV].PLV_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [nexuses].[ut_lEV_Event] ON [nexuses].[lEV_Event]
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
    IF(UPDATE(ETY_EventType))
        RAISERROR('The role column ETY_EventType is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_ID))
        RAISERROR('The identity column EV_DAT_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(EV_DAT_Event_Date) OR
        UPDATE(EV_DAT_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [attributes].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_ID,
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
            ISNULL(i.EV_ID, i.EV_ID),
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
        INSERT INTO [attributes].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_ID,
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
            p.EV_ID,
            p.EV_DAT_Event_Date,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_DAT_PositedAt) THEN i.EV_DAT_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_DAT_Event_Date_Posit] p
        ON
            p.EV_DAT_ID = i.EV_DAT_ID
        WHERE
            i.EV_DAT_Event_Date is null
    END
    IF(UPDATE(EV_AUD_ID))
        RAISERROR('The identity column EV_AUD_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(EV_AUD_Event_Audience) OR
        UPDATE(EV_AUD_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [attributes].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_ID,
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
            ISNULL(i.EV_ID, i.EV_ID),
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
        INSERT INTO [attributes].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_ID,
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
            p.EV_ID,
            p.EV_AUD_Event_Audience,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_AUD_PositedAt) THEN i.EV_AUD_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_AUD_Event_Audience_Posit] p
        ON
            p.EV_AUD_ID = i.EV_AUD_ID
        WHERE
            i.EV_AUD_Event_Audience is null
    END
    IF(UPDATE(EV_REV_ID))
        RAISERROR('The identity column EV_REV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(EV_REV_Event_Revenue) OR
        UPDATE(EV_REV_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [attributes].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_ID,
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
            ISNULL(i.EV_ID, i.EV_ID),
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
        INSERT INTO [attributes].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_ID,
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
            p.EV_ID,
            p.EV_REV_Event_Revenue,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_REV_PositedAt) THEN i.EV_REV_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_REV_Event_Revenue_Posit] p
        ON
            p.EV_REV_ID = i.EV_REV_ID
        WHERE
            i.EV_REV_Event_Revenue is null
    END
    IF(UPDATE(EV_STA_ID))
        RAISERROR('The identity column EV_STA_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(EV_STA_Event_Status) OR
        UPDATE(EV_STA_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [attributes].[EV_STA_Event_Status] (
            Metadata_EV_STA,
            EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt,
            EV_STA_PositedAt,
            EV_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_STA)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_STA
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_STA_Event_Status,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_STA_ChangedAt) THEN i.EV_STA_ChangedAt
                WHEN d.EV_STA_Event_Status = i.EV_STA_Event_Status
                THEN i.EV_STA_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(EV_STA_PositedAt) THEN i.EV_STA_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_STA_Reliability) THEN i.EV_STA_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_STA_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            i.EV_STA_Event_Status is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_STA_ChangedAt) OR
            UPDATE(EV_STA_PositedAt) OR
            d.EV_STA_Event_Status is null OR
            d.EV_STA_Event_Status <> i.EV_STA_Event_Status OR
            d.EV_STA_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_STA_Reliability) THEN i.EV_STA_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_STA_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(EV_STA_Event_Status)
    )
    BEGIN
        INSERT INTO [attributes].[EV_STA_Event_Status] (
            Metadata_EV_STA,
            EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt,
            EV_STA_PositedAt,
            EV_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_STA)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_STA
            END, i.Metadata_EV),
            p.EV_ID,
            p.EV_STA_Event_Status,
            p.EV_STA_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_STA_PositedAt) THEN i.EV_STA_PositedAt
                WHEN UPDATE(EV_STA_ChangedAt) THEN i.EV_STA_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_STA_Event_Status_Posit] p
        ON
            p.EV_STA_ID = i.EV_STA_ID
        WHERE
            i.EV_STA_Event_Status is null
    END
    IF(UPDATE(EV_UTL_ID))
        RAISERROR('The identity column EV_UTL_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(UTL_ID) OR
        UPDATE(UTL_Utilization) OR
        UPDATE(EV_UTL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [attributes].[EV_UTL_Event_Utilization] (
            Metadata_EV_UTL,
            EV_ID,
            UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_UTL)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_UTL
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            CASE
                WHEN UPDATE(UTL_ID) THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_UTL_PositedAt) THEN i.EV_UTL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_UTL_Reliability) THEN i.EV_UTL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_UTL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [knots].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.UTL_Utilization
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            CASE
                WHEN UPDATE(UTL_ID) THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_UTL_PositedAt) OR
            d.UTL_ID is null OR
            d.UTL_ID <> CASE WHEN UPDATE(UTL_ID) THEN i.UTL_ID ELSE [kUTL].UTL_ID END OR
            d.EV_UTL_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_UTL_Reliability) THEN i.EV_UTL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_UTL_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(UTL_ID) OR
        UPDATE(UTL_Utilization)
    )
    BEGIN
        INSERT INTO [attributes].[EV_UTL_Event_Utilization] (
            Metadata_EV_UTL,
            EV_ID,
            UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_UTL)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_UTL
            END, i.Metadata_EV),
            p.EV_ID,
            p.UTL_ID,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_UTL_PositedAt) THEN i.EV_UTL_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_UTL_Event_Utilization_Posit] p
        ON
            p.EV_UTL_ID = i.EV_UTL_ID
        WHERE
            (UPDATE(UTL_ID) AND i.UTL_ID is null)
        OR
            (UPDATE(UTL_Utilization) AND i.UTL_Utilization is null);
    END
    IF(UPDATE(EV_LVL_ID))
        RAISERROR('The identity column EV_LVL_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF (
        UPDATE(PLV_ID) OR
        UPDATE(PLV_ProfessionalLevel) OR
        UPDATE(EV_LVL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [attributes].[EV_LVL_Event_Level] (
            Metadata_EV_LVL,
            EV_ID,
            PLV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PositedAt,
            EV_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_LVL)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_LVL
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            CASE
                WHEN UPDATE(PLV_ID) THEN i.PLV_ID
                ELSE [kPLV].PLV_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_LVL_ChangedAt) THEN i.EV_LVL_ChangedAt
                WHEN d.PLV_ID = CASE WHEN UPDATE(PLV_ID) THEN i.PLV_ID ELSE [kPLV].PLV_ID END
                THEN i.EV_LVL_ChangedAt -- the shown version is asserted again
            END, @now) as date),
            cast(ISNULL(CASE
                WHEN UPDATE(EV_LVL_PositedAt) THEN i.EV_LVL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(EV_LVL_Reliability) THEN i.EV_LVL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_LVL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [knots].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dw.MD5(cast(i.PLV_ProfessionalLevel as varbinary(max)))
        LEFT JOIN
            deleted d
        ON
            d.EV_ID = i.EV_ID
        WHERE
            CASE
                WHEN UPDATE(PLV_ID) THEN i.PLV_ID
                ELSE [kPLV].PLV_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(EV_LVL_ChangedAt) OR
            UPDATE(EV_LVL_PositedAt) OR
            d.PLV_ID is null OR
            d.PLV_ID <> CASE WHEN UPDATE(PLV_ID) THEN i.PLV_ID ELSE [kPLV].PLV_ID END OR
            d.EV_LVL_Reliability <> ISNULL(CASE
                WHEN UPDATE(EV_LVL_Reliability) THEN i.EV_LVL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.EV_LVL_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(PLV_ID) OR
        UPDATE(PLV_ProfessionalLevel)
    )
    BEGIN
        INSERT INTO [attributes].[EV_LVL_Event_Level] (
            Metadata_EV_LVL,
            EV_ID,
            PLV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PositedAt,
            EV_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_LVL)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_LVL
            END, i.Metadata_EV),
            p.EV_ID,
            p.PLV_ID,
            p.EV_LVL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(EV_LVL_PositedAt) THEN i.EV_LVL_PositedAt
                WHEN UPDATE(EV_LVL_ChangedAt) THEN i.EV_LVL_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_LVL_Event_Level_Posit] p
        ON
            p.EV_LVL_ID = i.EV_LVL_ID
        WHERE
            (UPDATE(PLV_ID) AND i.PLV_ID is null)
        OR
            (UPDATE(PLV_ProfessionalLevel) AND i.PLV_ProfessionalLevel is null);
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [nexuses].[dt_lEV_Event] ON [nexuses].[lEV_Event]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [attributes].[EV_DAT_Event_Date_Annex] (
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
    INSERT INTO [attributes].[EV_AUD_Event_Audience_Annex] (
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
    INSERT INTO [attributes].[EV_REV_Event_Revenue_Annex] (
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
    INSERT INTO [attributes].[EV_STA_Event_Status_Annex] (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_PositedAt,
        EV_STA_Reliability
    )
    SELECT
        d.Metadata_EV_STA,
        d.EV_STA_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_STA_ID is not null;
    INSERT INTO [attributes].[EV_UTL_Event_Utilization_Annex] (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_PositedAt,
        EV_UTL_Reliability
    )
    SELECT
        d.Metadata_EV_UTL,
        d.EV_UTL_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_UTL_ID is not null;
    INSERT INTO [attributes].[EV_LVL_Event_Level_Annex] (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_PositedAt,
        EV_LVL_Reliability
    )
    SELECT
        d.Metadata_EV_LVL,
        d.EV_LVL_ID,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_LVL_ID is not null;
END
GO
