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
        EV_DAT_Positor tinyint null,
        EV_DAT_PositedAt datetime2 null,
        EV_DAT_Reliability decimal(5,2) null,
        EV_DAT_Event_Date datetime2 null,
        Metadata_EV_AUD int null,
        EV_AUD_Positor tinyint null,
        EV_AUD_PositedAt datetime2 null,
        EV_AUD_Reliability decimal(5,2) null,
        EV_AUD_Event_Audience int null,
        Metadata_EV_REV int null,
        EV_REV_Positor tinyint null,
        EV_REV_PositedAt datetime2 null,
        EV_REV_Reliability decimal(5,2) null,
        EV_REV_Event_Revenue decimal(19,4) null,
        Metadata_EV_STA int null,
        EV_STA_ChangedAt datetime2 null,
        EV_STA_Positor tinyint null,
        EV_STA_PositedAt datetime2 null,
        EV_STA_Reliability decimal(5,2) null,
        EV_STA_Event_Status nvarchar(20) null,
        Metadata_EV_UTL int null,
        EV_UTL_Positor tinyint null,
        EV_UTL_PositedAt datetime2 null,
        EV_UTL_Reliability decimal(5,2) null,
        UTL_Utilization tinyint null,
        Metadata_UTL int null,
        UTL_ID tinyint null,
        Metadata_EV_LVL int null,
        EV_LVL_ChangedAt date null,
        EV_LVL_Positor tinyint null,
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
        ISNULL(ISNULL(i.EV_DAT_Positor, i.Positor), 0),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_AUD_Positor, i.Positor), 0),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_REV_Positor, i.Positor), 0),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue,
        ISNULL(i.Metadata_EV_STA, i.Metadata_EV),
        ISNULL(i.EV_STA_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_STA_Positor, i.Positor), 0),
        ISNULL(i.EV_STA_PositedAt, @now),
        ISNULL(ISNULL(i.EV_STA_Reliability, i.Reliability), 1),
        i.EV_STA_Event_Status,
        ISNULL(i.Metadata_EV_UTL, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_UTL_Positor, i.Positor), 0),
        ISNULL(i.EV_UTL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_UTL_Reliability, i.Reliability), 1),
        i.UTL_Utilization,
        ISNULL(i.Metadata_UTL, i.Metadata_EV),
        i.UTL_ID,
        ISNULL(i.Metadata_EV_LVL, i.Metadata_EV),
        ISNULL(i.EV_LVL_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_LVL_Positor, i.Positor), 0),
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
        ISNULL(ISNULL(i.EV_DAT_Positor, i.Positor), 0),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_AUD_Positor, i.Positor), 0),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_REV_Positor, i.Positor), 0),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue,
        ISNULL(i.Metadata_EV_STA, i.Metadata_EV),
        ISNULL(i.EV_STA_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_STA_Positor, i.Positor), 0),
        ISNULL(i.EV_STA_PositedAt, @now),
        ISNULL(ISNULL(i.EV_STA_Reliability, i.Reliability), 1),
        i.EV_STA_Event_Status,
        ISNULL(i.Metadata_EV_UTL, i.Metadata_EV),
        ISNULL(ISNULL(i.EV_UTL_Positor, i.Positor), 0),
        ISNULL(i.EV_UTL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_UTL_Reliability, i.Reliability), 1),
        i.UTL_Utilization,
        ISNULL(i.Metadata_UTL, i.Metadata_EV),
        i.UTL_ID,
        ISNULL(i.Metadata_EV_LVL, i.Metadata_EV),
        ISNULL(i.EV_LVL_ChangedAt, @now),
        ISNULL(ISNULL(i.EV_LVL_Positor, i.Positor), 0),
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
        EV_DAT_Positor,
        EV_DAT_Reliability
    )
    SELECT
        i.Metadata_EV_DAT,
        i.EV_ID,
        i.EV_DAT_Event_Date,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Positor,
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
        EV_AUD_Positor,
        EV_AUD_Reliability
    )
    SELECT
        i.Metadata_EV_AUD,
        i.EV_ID,
        i.EV_AUD_Event_Audience,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Positor,
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
        EV_REV_Positor,
        EV_REV_Reliability
    )
    SELECT
        i.Metadata_EV_REV,
        i.EV_ID,
        i.EV_REV_Event_Revenue,
        i.EV_REV_PositedAt,
        i.EV_REV_Positor,
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
        EV_STA_Positor,
        EV_STA_Reliability
    )
    SELECT
        i.Metadata_EV_STA,
        i.EV_ID,
        i.EV_STA_Event_Status,
        i.EV_STA_ChangedAt,
        i.EV_STA_PositedAt,
        i.EV_STA_Positor,
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
        EV_UTL_Positor,
        EV_UTL_Reliability
    )
    SELECT
        i.Metadata_EV_UTL,
        i.EV_ID,
        ISNULL(i.UTL_ID, [kUTL].UTL_ID), 
        i.EV_UTL_PositedAt,
        i.EV_UTL_Positor,
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
        EV_LVL_Positor,
        EV_LVL_Reliability
    )
    SELECT
        i.Metadata_EV_LVL,
        i.EV_ID,
        ISNULL(i.PLV_ID, [kPLV].PLV_ID), 
        i.EV_LVL_ChangedAt,
        i.EV_LVL_PositedAt,
        i.EV_LVL_Positor,
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_EV bit = CASE WHEN UPDATE(Metadata_EV) THEN 1 ELSE 0 END;
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_Positor bit = CASE WHEN UPDATE(Positor) THEN 1 ELSE 0 END;
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
    DECLARE @updated_Metadata_EV_DAT bit = CASE WHEN UPDATE(Metadata_EV_DAT) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_DAT_PositedAt bit = CASE WHEN UPDATE(EV_DAT_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_DAT_Reliability bit = CASE WHEN UPDATE(EV_DAT_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_DAT_Positor bit = CASE WHEN UPDATE(EV_DAT_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_DAT_ID))
        RAISERROR('The identity column EV_DAT_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_Assertion))
        RAISERROR('The computed assertion column EV_DAT_Assertion is not updatable.', 16, 1);
    IF (
        @updated_EV_DAT_Event_Date = 1 OR
        @updated_EV_DAT_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_ID,
            EV_DAT_Event_Date,
            EV_DAT_PositedAt,
            EV_DAT_Positor,
            EV_DAT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_DAT = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_DAT
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_DAT_Event_Date,
            cast(ISNULL(CASE
                WHEN @updated_EV_DAT_PositedAt = 1 THEN i.EV_DAT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_DAT_Positor = 1 THEN i.EV_DAT_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_EV_DAT_Reliability = 1 THEN i.EV_DAT_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_DAT_Reliability
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
            i.EV_DAT_Event_Date is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_DAT_PositedAt = 1 OR
            @updated_EV_DAT_Positor = 1 OR
            @updated_Positor = 1 OR
            d.EV_DAT_Event_Date is null OR
            d.EV_DAT_Event_Date <> i.EV_DAT_Event_Date OR
            d.EV_DAT_Reliability <> ISNULL(CASE
                WHEN @updated_EV_DAT_Reliability = 1 THEN i.EV_DAT_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_DAT_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_EV_DAT_Event_Date = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_DAT_Event_Date] (
            Metadata_EV_DAT,
            EV_ID,
            EV_DAT_Event_Date,
            EV_DAT_PositedAt,
            EV_DAT_Positor,
            EV_DAT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_DAT = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_DAT
            END, i.Metadata_EV),
            p.EV_ID,
            p.EV_DAT_Event_Date,
            cast(ISNULL(CASE
                WHEN @updated_EV_DAT_PositedAt = 1 THEN i.EV_DAT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_DAT_Positor = 1 THEN i.EV_DAT_Positor
                ELSE i.Positor
            END, 0),
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
    DECLARE @updated_EV_AUD_Event_Audience bit = CASE WHEN UPDATE(EV_AUD_Event_Audience) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_AUD bit = CASE WHEN UPDATE(Metadata_EV_AUD) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_AUD_PositedAt bit = CASE WHEN UPDATE(EV_AUD_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_AUD_Reliability bit = CASE WHEN UPDATE(EV_AUD_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_AUD_Positor bit = CASE WHEN UPDATE(EV_AUD_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_AUD_ID))
        RAISERROR('The identity column EV_AUD_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_AUD_Assertion))
        RAISERROR('The computed assertion column EV_AUD_Assertion is not updatable.', 16, 1);
    IF (
        @updated_EV_AUD_Event_Audience = 1 OR
        @updated_EV_AUD_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_ID,
            EV_AUD_Event_Audience,
            EV_AUD_PositedAt,
            EV_AUD_Positor,
            EV_AUD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_AUD = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_AUD_Event_Audience,
            cast(ISNULL(CASE
                WHEN @updated_EV_AUD_PositedAt = 1 THEN i.EV_AUD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_AUD_Positor = 1 THEN i.EV_AUD_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_EV_AUD_Reliability = 1 THEN i.EV_AUD_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_AUD_Reliability
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
            i.EV_AUD_Event_Audience is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_AUD_PositedAt = 1 OR
            @updated_EV_AUD_Positor = 1 OR
            @updated_Positor = 1 OR
            d.EV_AUD_Event_Audience is null OR
            d.EV_AUD_Event_Audience <> i.EV_AUD_Event_Audience OR
            d.EV_AUD_Reliability <> ISNULL(CASE
                WHEN @updated_EV_AUD_Reliability = 1 THEN i.EV_AUD_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_AUD_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_EV_AUD_Event_Audience = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_ID,
            EV_AUD_Event_Audience,
            EV_AUD_PositedAt,
            EV_AUD_Positor,
            EV_AUD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_AUD = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            p.EV_ID,
            p.EV_AUD_Event_Audience,
            cast(ISNULL(CASE
                WHEN @updated_EV_AUD_PositedAt = 1 THEN i.EV_AUD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_AUD_Positor = 1 THEN i.EV_AUD_Positor
                ELSE i.Positor
            END, 0),
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
    DECLARE @updated_EV_REV_Event_Revenue bit = CASE WHEN UPDATE(EV_REV_Event_Revenue) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_REV bit = CASE WHEN UPDATE(Metadata_EV_REV) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_REV_PositedAt bit = CASE WHEN UPDATE(EV_REV_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_REV_Reliability bit = CASE WHEN UPDATE(EV_REV_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_REV_Positor bit = CASE WHEN UPDATE(EV_REV_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_REV_ID))
        RAISERROR('The identity column EV_REV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_REV_Assertion))
        RAISERROR('The computed assertion column EV_REV_Assertion is not updatable.', 16, 1);
    IF (
        @updated_EV_REV_Event_Revenue = 1 OR
        @updated_EV_REV_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_ID,
            EV_REV_Event_Revenue,
            EV_REV_PositedAt,
            EV_REV_Positor,
            EV_REV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_REV = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_REV
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_REV_Event_Revenue,
            cast(ISNULL(CASE
                WHEN @updated_EV_REV_PositedAt = 1 THEN i.EV_REV_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_REV_Positor = 1 THEN i.EV_REV_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_EV_REV_Reliability = 1 THEN i.EV_REV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_REV_Reliability
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
            i.EV_REV_Event_Revenue is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_REV_PositedAt = 1 OR
            @updated_EV_REV_Positor = 1 OR
            @updated_Positor = 1 OR
            d.EV_REV_Event_Revenue is null OR
            d.EV_REV_Event_Revenue <> i.EV_REV_Event_Revenue OR
            d.EV_REV_Reliability <> ISNULL(CASE
                WHEN @updated_EV_REV_Reliability = 1 THEN i.EV_REV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_REV_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_EV_REV_Event_Revenue = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_REV_Event_Revenue] (
            Metadata_EV_REV,
            EV_ID,
            EV_REV_Event_Revenue,
            EV_REV_PositedAt,
            EV_REV_Positor,
            EV_REV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_REV = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_REV
            END, i.Metadata_EV),
            p.EV_ID,
            p.EV_REV_Event_Revenue,
            cast(ISNULL(CASE
                WHEN @updated_EV_REV_PositedAt = 1 THEN i.EV_REV_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_REV_Positor = 1 THEN i.EV_REV_Positor
                ELSE i.Positor
            END, 0),
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
    DECLARE @updated_EV_STA_Event_Status bit = CASE WHEN UPDATE(EV_STA_Event_Status) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_STA bit = CASE WHEN UPDATE(Metadata_EV_STA) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_STA_ChangedAt bit = CASE WHEN UPDATE(EV_STA_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_STA_PositedAt bit = CASE WHEN UPDATE(EV_STA_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_STA_Reliability bit = CASE WHEN UPDATE(EV_STA_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_STA_Positor bit = CASE WHEN UPDATE(EV_STA_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_STA_ID))
        RAISERROR('The identity column EV_STA_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_STA_Assertion))
        RAISERROR('The computed assertion column EV_STA_Assertion is not updatable.', 16, 1);
    IF (
        @updated_EV_STA_Event_Status = 1 OR
        @updated_EV_STA_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_STA_Event_Status] (
            Metadata_EV_STA,
            EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt,
            EV_STA_PositedAt,
            EV_STA_Positor,
            EV_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_STA = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_STA
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            i.EV_STA_Event_Status,
            cast(ISNULL(CASE
                WHEN @updated_EV_STA_ChangedAt = 1 THEN i.EV_STA_ChangedAt
                WHEN d.EV_STA_Event_Status = i.EV_STA_Event_Status
                THEN i.EV_STA_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_EV_STA_PositedAt = 1 THEN i.EV_STA_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_STA_Positor = 1 THEN i.EV_STA_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_EV_STA_Reliability = 1 THEN i.EV_STA_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_STA_Reliability
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
            i.EV_STA_Event_Status is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_STA_ChangedAt = 1 OR
            @updated_EV_STA_PositedAt = 1 OR
            @updated_EV_STA_Positor = 1 OR
            @updated_Positor = 1 OR
            d.EV_STA_Event_Status is null OR
            d.EV_STA_Event_Status <> i.EV_STA_Event_Status OR
            d.EV_STA_Reliability <> ISNULL(CASE
                WHEN @updated_EV_STA_Reliability = 1 THEN i.EV_STA_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_STA_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_EV_STA_Event_Status = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_STA_Event_Status] (
            Metadata_EV_STA,
            EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt,
            EV_STA_PositedAt,
            EV_STA_Positor,
            EV_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_STA = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_STA
            END, i.Metadata_EV),
            p.EV_ID,
            p.EV_STA_Event_Status,
            p.EV_STA_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_EV_STA_PositedAt = 1 THEN i.EV_STA_PositedAt
                WHEN @updated_EV_STA_ChangedAt = 1 THEN i.EV_STA_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_STA_Positor = 1 THEN i.EV_STA_Positor
                ELSE i.Positor
            END, 0),
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
    DECLARE @updated_UTL_ID bit = CASE WHEN UPDATE(UTL_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_UTL_Utilization bit = CASE WHEN UPDATE(UTL_Utilization) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_UTL bit = CASE WHEN UPDATE(Metadata_EV_UTL) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_UTL_PositedAt bit = CASE WHEN UPDATE(EV_UTL_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_UTL_Reliability bit = CASE WHEN UPDATE(EV_UTL_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_UTL_Positor bit = CASE WHEN UPDATE(EV_UTL_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_UTL_ID))
        RAISERROR('The identity column EV_UTL_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_UTL_Assertion))
        RAISERROR('The computed assertion column EV_UTL_Assertion is not updatable.', 16, 1);
    IF (
        @updated_UTL_ID = 1 OR
        @updated_UTL_Utilization = 1 OR
        @updated_EV_UTL_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_UTL_Event_Utilization] (
            Metadata_EV_UTL,
            EV_ID,
            UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Positor,
            EV_UTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_UTL = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_UTL
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            CASE
                WHEN @updated_UTL_ID = 1 THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_EV_UTL_PositedAt = 1 THEN i.EV_UTL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_UTL_Positor = 1 THEN i.EV_UTL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_EV_UTL_Reliability = 1 THEN i.EV_UTL_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
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
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN @updated_UTL_ID = 1 THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_UTL_PositedAt = 1 OR
            @updated_EV_UTL_Positor = 1 OR
            @updated_Positor = 1 OR
            d.UTL_ID is null OR
            d.UTL_ID <> CASE WHEN @updated_UTL_ID = 1 THEN i.UTL_ID ELSE [kUTL].UTL_ID END OR
            d.EV_UTL_Reliability <> ISNULL(CASE
                WHEN @updated_EV_UTL_Reliability = 1 THEN i.EV_UTL_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_UTL_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_UTL_ID = 1 OR
        @updated_UTL_Utilization = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_UTL_Event_Utilization] (
            Metadata_EV_UTL,
            EV_ID,
            UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Positor,
            EV_UTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_UTL = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_UTL
            END, i.Metadata_EV),
            p.EV_ID,
            p.UTL_ID,
            cast(ISNULL(CASE
                WHEN @updated_EV_UTL_PositedAt = 1 THEN i.EV_UTL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_UTL_Positor = 1 THEN i.EV_UTL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_UTL_Event_Utilization_Posit] p
        ON
            p.EV_UTL_ID = i.EV_UTL_ID
        WHERE
            (@updated_UTL_ID = 1 AND i.UTL_ID is null)
        OR
            (@updated_UTL_Utilization = 1 AND i.UTL_Utilization is null);
    END
    DECLARE @updated_PLV_ID bit = CASE WHEN UPDATE(PLV_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_PLV_ProfessionalLevel bit = CASE WHEN UPDATE(PLV_ProfessionalLevel) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_EV_LVL bit = CASE WHEN UPDATE(Metadata_EV_LVL) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_LVL_ChangedAt bit = CASE WHEN UPDATE(EV_LVL_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_LVL_PositedAt bit = CASE WHEN UPDATE(EV_LVL_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_LVL_Reliability bit = CASE WHEN UPDATE(EV_LVL_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_EV_LVL_Positor bit = CASE WHEN UPDATE(EV_LVL_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(EV_LVL_ID))
        RAISERROR('The identity column EV_LVL_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID))
        RAISERROR('The foreign key column EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_LVL_Assertion))
        RAISERROR('The computed assertion column EV_LVL_Assertion is not updatable.', 16, 1);
    IF (
        @updated_PLV_ID = 1 OR
        @updated_PLV_ProfessionalLevel = 1 OR
        @updated_EV_LVL_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_LVL_Event_Level] (
            Metadata_EV_LVL,
            EV_ID,
            PLV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PositedAt,
            EV_LVL_Positor,
            EV_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_LVL = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_LVL
            END, i.Metadata_EV),
            ISNULL(i.EV_ID, i.EV_ID),
            CASE
                WHEN @updated_PLV_ID = 1 THEN i.PLV_ID
                ELSE [kPLV].PLV_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_EV_LVL_ChangedAt = 1 THEN i.EV_LVL_ChangedAt
                WHEN d.PLV_ID = CASE WHEN @updated_PLV_ID = 1 THEN i.PLV_ID ELSE [kPLV].PLV_ID END
                THEN i.EV_LVL_ChangedAt -- the shown version is asserted again
            END, @now) as date),
            cast(ISNULL(CASE
                WHEN @updated_EV_LVL_PositedAt = 1 THEN i.EV_LVL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_LVL_Positor = 1 THEN i.EV_LVL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_EV_LVL_Reliability = 1 THEN i.EV_LVL_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
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
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN @updated_PLV_ID = 1 THEN i.PLV_ID
                ELSE [kPLV].PLV_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_EV_LVL_ChangedAt = 1 OR
            @updated_EV_LVL_PositedAt = 1 OR
            @updated_EV_LVL_Positor = 1 OR
            @updated_Positor = 1 OR
            d.PLV_ID is null OR
            d.PLV_ID <> CASE WHEN @updated_PLV_ID = 1 THEN i.PLV_ID ELSE [kPLV].PLV_ID END OR
            d.EV_LVL_Reliability <> ISNULL(CASE
                WHEN @updated_EV_LVL_Reliability = 1 THEN i.EV_LVL_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.EV_LVL_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_PLV_ID = 1 OR
        @updated_PLV_ProfessionalLevel = 1
    )
    BEGIN
        INSERT INTO [attributes].[EV_LVL_Event_Level] (
            Metadata_EV_LVL,
            EV_ID,
            PLV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PositedAt,
            EV_LVL_Positor,
            EV_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_EV = 1 AND @updated_Metadata_EV_LVL = 0
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_LVL
            END, i.Metadata_EV),
            p.EV_ID,
            p.PLV_ID,
            p.EV_LVL_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_EV_LVL_PositedAt = 1 THEN i.EV_LVL_PositedAt
                WHEN @updated_EV_LVL_ChangedAt = 1 THEN i.EV_LVL_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_EV_LVL_Positor = 1 THEN i.EV_LVL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[EV_LVL_Event_Level_Posit] p
        ON
            p.EV_LVL_ID = i.EV_LVL_ID
        WHERE
            (@updated_PLV_ID = 1 AND i.PLV_ID is null)
        OR
            (@updated_PLV_ProfessionalLevel = 1 AND i.PLV_ProfessionalLevel is null);
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
        EV_DAT_Positor,
        EV_DAT_PositedAt,
        EV_DAT_Reliability
    )
    SELECT
        d.Metadata_EV_DAT,
        d.EV_DAT_ID,
        d.EV_DAT_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_DAT_ID is not null;
    INSERT INTO [attributes].[EV_AUD_Event_Audience_Annex] (
        Metadata_EV_AUD,
        EV_AUD_ID,
        EV_AUD_Positor,
        EV_AUD_PositedAt,
        EV_AUD_Reliability
    )
    SELECT
        d.Metadata_EV_AUD,
        d.EV_AUD_ID,
        d.EV_AUD_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_AUD_ID is not null;
    INSERT INTO [attributes].[EV_REV_Event_Revenue_Annex] (
        Metadata_EV_REV,
        EV_REV_ID,
        EV_REV_Positor,
        EV_REV_PositedAt,
        EV_REV_Reliability
    )
    SELECT
        d.Metadata_EV_REV,
        d.EV_REV_ID,
        d.EV_REV_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_REV_ID is not null;
    INSERT INTO [attributes].[EV_STA_Event_Status_Annex] (
        Metadata_EV_STA,
        EV_STA_ID,
        EV_STA_Positor,
        EV_STA_PositedAt,
        EV_STA_Reliability
    )
    SELECT
        d.Metadata_EV_STA,
        d.EV_STA_ID,
        d.EV_STA_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_STA_ID is not null;
    INSERT INTO [attributes].[EV_UTL_Event_Utilization_Annex] (
        Metadata_EV_UTL,
        EV_UTL_ID,
        EV_UTL_Positor,
        EV_UTL_PositedAt,
        EV_UTL_Reliability
    )
    SELECT
        d.Metadata_EV_UTL,
        d.EV_UTL_ID,
        d.EV_UTL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_UTL_ID is not null;
    INSERT INTO [attributes].[EV_LVL_Event_Level_Annex] (
        Metadata_EV_LVL,
        EV_LVL_ID,
        EV_LVL_Positor,
        EV_LVL_PositedAt,
        EV_LVL_Reliability
    )
    SELECT
        d.Metadata_EV_LVL,
        d.EV_LVL_ID,
        d.EV_LVL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.EV_LVL_ID is not null;
END
GO
