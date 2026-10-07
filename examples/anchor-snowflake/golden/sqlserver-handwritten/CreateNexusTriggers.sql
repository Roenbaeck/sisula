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
CREATE TRIGGER [nexuses].[it_lEV_Event] ON [nexuses].[lEV_Event]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @EV TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        EV_ID numeric(12,0) not null
    );
    INSERT INTO [nexuses].[EV_Event] (
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
        EV_ID numeric(12,0) not null,
        Metadata_EV int not null,
        EV_DAT_EV_ID numeric(12,0) null,
        Metadata_EV_DAT int null,
        EV_DAT_Event_Date datetime2 null,
        EV_AUD_EV_ID numeric(12,0) null,
        Metadata_EV_AUD int null,
        EV_AUD_EQ tinyint null,
        EV_AUD_Event_Audience int null,
        EV_REV_EV_ID numeric(12,0) null,
        Metadata_EV_REV int null,
        EV_REV_Event_Revenue decimal(19,4) null,
        EV_STA_EV_ID numeric(12,0) null,
        Metadata_EV_STA int null,
        EV_STA_ChangedAt datetime2 null,
        EV_STA_EQ tinyint null,
        EV_STA_Event_Status nvarchar(20) null,
        EV_UTL_EV_ID numeric(12,0) null,
        Metadata_EV_UTL int null,
        EV_UTL_UTL_Utilization tinyint null,
        EV_UTL_Metadata_UTL int null,
        EV_UTL_UTL_ID tinyint null,
        EV_LVL_EV_ID numeric(12,0) null,
        Metadata_EV_LVL int null,
        EV_LVL_ChangedAt date null,
        EV_LVL_PLV_ProfessionalLevel nvarchar(max) null,
        EV_LVL_PLV_Checksum varbinary(16) null,
        EV_LVL_PLV_EQ tinyint null,
        EV_LVL_Metadata_PLV int null,
        EV_LVL_PLV_ID tinyint null
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
        ISNULL(i.EV_AUD_EQ, 0),
        i.EV_AUD_Event_Audience,
        ISNULL(ISNULL(i.EV_REV_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        i.EV_REV_Event_Revenue,
        ISNULL(ISNULL(i.EV_STA_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_STA, i.Metadata_EV),
        ISNULL(i.EV_STA_ChangedAt, @now),
        ISNULL(i.EV_STA_EQ, 0),
        i.EV_STA_Event_Status,
        ISNULL(ISNULL(i.EV_UTL_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_UTL, i.Metadata_EV),
        i.EV_UTL_UTL_Utilization,
        ISNULL(i.EV_UTL_Metadata_UTL, i.Metadata_EV),
        i.EV_UTL_UTL_ID,
        ISNULL(ISNULL(i.EV_LVL_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_LVL, i.Metadata_EV),
        ISNULL(i.EV_LVL_ChangedAt, @now),
        i.EV_LVL_PLV_ProfessionalLevel,
        ISNULL(i.EV_LVL_PLV_Checksum, dw.MD5(cast(i.EV_LVL_PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.EV_LVL_PLV_EQ, 0),
        ISNULL(i.EV_LVL_Metadata_PLV, i.Metadata_EV),
        i.EV_LVL_PLV_ID
    FROM (
        SELECT
            EV_ID,
            Metadata_EV,
            EV_DAT_EV_ID,
            Metadata_EV_DAT,
            EV_DAT_Event_Date,
            EV_AUD_EV_ID,
            Metadata_EV_AUD,
            EV_AUD_EQ,
            EV_AUD_Event_Audience,
            EV_REV_EV_ID,
            Metadata_EV_REV,
            EV_REV_Event_Revenue,
            EV_STA_EV_ID,
            Metadata_EV_STA,
            EV_STA_ChangedAt,
            EV_STA_EQ,
            EV_STA_Event_Status,
            EV_UTL_EV_ID,
            Metadata_EV_UTL,
            EV_UTL_UTL_Utilization,
            EV_UTL_Metadata_UTL,
            EV_UTL_UTL_ID,
            EV_LVL_EV_ID,
            Metadata_EV_LVL,
            EV_LVL_ChangedAt,
            EV_LVL_PLV_ProfessionalLevel,
            EV_LVL_PLV_Checksum,
            EV_LVL_PLV_EQ,
            EV_LVL_Metadata_PLV,
            EV_LVL_PLV_ID,
            ROW_NUMBER() OVER (PARTITION BY EV_ID ORDER BY EV_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @EV a
    ON
        a.Row = i.Row;
    INSERT INTO [attributes].[EV_DAT_Event_Date] (
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
    INSERT INTO [attributes].[EV_AUD_Event_Audience] (
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
    INSERT INTO [attributes].[EV_REV_Event_Revenue] (
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
    INSERT INTO [attributes].[EV_STA_Event_Status] (
        Metadata_EV_STA,
        EV_STA_EV_ID,
        EV_STA_ChangedAt,
        EV_STA_Event_Status
    )
    SELECT DISTINCT
        i.Metadata_EV_STA,
        i.EV_STA_EV_ID,
        i.EV_STA_ChangedAt,
        i.EV_STA_Event_Status
    FROM
        @inserted i
    WHERE
        i.EV_STA_Event_Status is not null;
    INSERT INTO [attributes].[EV_UTL_Event_Utilization] (
        Metadata_EV_UTL,
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID
    )
    SELECT DISTINCT
        i.Metadata_EV_UTL,
        i.EV_UTL_EV_ID,
        ISNULL(i.EV_UTL_UTL_ID, [kUTL].UTL_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [knots].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.EV_UTL_UTL_Utilization
    WHERE
        ISNULL(i.EV_UTL_UTL_ID, [kUTL].UTL_ID) is not null;
    INSERT INTO [attributes].[EV_LVL_Event_Level] (
        Metadata_EV_LVL,
        EV_LVL_EV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PLV_ID
    )
    SELECT DISTINCT
        i.Metadata_EV_LVL,
        i.EV_LVL_EV_ID,
        i.EV_LVL_ChangedAt,
        ISNULL(i.EV_LVL_PLV_ID, [kPLV].PLV_ID) 
    FROM
        @inserted i
    LEFT JOIN
        [knots].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.EV_LVL_PLV_Checksum 
    AND
        [kPLV].PLV_EQ = i.EV_LVL_PLV_EQ
    WHERE
        ISNULL(i.EV_LVL_PLV_ID, [kPLV].PLV_ID) is not null;
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
    IF(UPDATE(EV_DAT_EV_ID))
        RAISERROR('The foreign key column EV_DAT_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_DAT_Event_Date))
    BEGIN
        INSERT INTO [attributes].[EV_DAT_Event_Date] (
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
        INSERT INTO [attributes].[EV_AUD_Event_Audience] (
            Metadata_EV_AUD,
            EV_AUD_EV_ID,
            EV_AUD_EQ,
            EV_AUD_Event_Audience
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_AUD)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_AUD
            END, i.Metadata_EV),
            ISNULL(i.EV_AUD_EV_ID, i.EV_ID),
            i.EV_AUD_EQ,
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
        INSERT INTO [attributes].[EV_REV_Event_Revenue] (
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
    IF(UPDATE(EV_STA_EV_ID))
        RAISERROR('The foreign key column EV_STA_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_STA_Event_Status))
    BEGIN
        INSERT INTO [attributes].[EV_STA_Event_Status] (
            Metadata_EV_STA,
            EV_STA_EV_ID,
            EV_STA_EQ,
            EV_STA_ChangedAt,
            EV_STA_Event_Status
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_STA)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_STA
            END, i.Metadata_EV),
            ISNULL(i.EV_STA_EV_ID, i.EV_ID),
            i.EV_STA_EQ,
            cast(ISNULL(CASE
                WHEN i.EV_STA_Event_Status is null THEN i.EV_STA_ChangedAt
                WHEN UPDATE(EV_STA_ChangedAt) THEN i.EV_STA_ChangedAt
            END, @now) as datetime2),
            i.EV_STA_Event_Status
        FROM
            inserted i
        WHERE
            i.EV_STA_Event_Status is not null;
    END
    IF(UPDATE(EV_UTL_EV_ID))
        RAISERROR('The foreign key column EV_UTL_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_UTL_UTL_ID) OR UPDATE(EV_UTL_UTL_Utilization))
    BEGIN
        INSERT INTO [attributes].[EV_UTL_Event_Utilization] (
            Metadata_EV_UTL,
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_UTL)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_UTL
            END, i.Metadata_EV),
            ISNULL(i.EV_UTL_EV_ID, i.EV_ID),
            CASE WHEN UPDATE(EV_UTL_UTL_ID) THEN i.EV_UTL_UTL_ID ELSE [kUTL].UTL_ID END
        FROM
            inserted i
        LEFT JOIN
            [knots].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.EV_UTL_UTL_Utilization
        WHERE
            CASE WHEN UPDATE(EV_UTL_UTL_ID) THEN i.EV_UTL_UTL_ID ELSE [kUTL].UTL_ID END is not null;
    END
    IF(UPDATE(EV_LVL_EV_ID))
        RAISERROR('The foreign key column EV_LVL_EV_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_LVL_PLV_ID) OR UPDATE(EV_LVL_PLV_ProfessionalLevel))
    BEGIN
        INSERT INTO [attributes].[EV_LVL_Event_Level] (
            Metadata_EV_LVL,
            EV_LVL_EV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PLV_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_EV) AND NOT UPDATE(Metadata_EV_LVL)
                THEN i.Metadata_EV
                ELSE i.Metadata_EV_LVL
            END, i.Metadata_EV),
            ISNULL(i.EV_LVL_EV_ID, i.EV_ID),
            cast(ISNULL(CASE
                WHEN i.EV_LVL_PLV_ID is null AND [kPLV].PLV_ID is null THEN i.EV_LVL_ChangedAt
                WHEN UPDATE(EV_LVL_ChangedAt) THEN i.EV_LVL_ChangedAt
            END, @now) as date),
            CASE WHEN UPDATE(EV_LVL_PLV_ID) THEN i.EV_LVL_PLV_ID ELSE [kPLV].PLV_ID END
        FROM
            inserted i
        LEFT JOIN
            [knots].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dw.MD5(cast(i.EV_LVL_PLV_ProfessionalLevel as varbinary(max))) 
        AND
            [kPLV].PLV_EQ = i.EV_LVL_PLV_EQ
        WHERE
            CASE WHEN UPDATE(EV_LVL_PLV_ID) THEN i.EV_LVL_PLV_ID ELSE [kPLV].PLV_ID END is not null;
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
    DELETE [DAT]
    FROM
        [attributes].[EV_DAT_Event_Date] [DAT]
    JOIN
        deleted d
    ON
        d.EV_DAT_EV_ID = [DAT].EV_DAT_EV_ID;
    DELETE [AUD]
    FROM
        [attributes].[EV_AUD_Event_Audience] [AUD]
    JOIN
        deleted d
    ON
        d.EV_AUD_EQ = [AUD].EV_AUD_EQ
    AND
        d.EV_AUD_EV_ID = [AUD].EV_AUD_EV_ID;
    DELETE [REV]
    FROM
        [attributes].[EV_REV_Event_Revenue] [REV]
    JOIN
        deleted d
    ON
        d.EV_REV_EV_ID = [REV].EV_REV_EV_ID;
    DELETE [STA]
    FROM
        [attributes].[EV_STA_Event_Status] [STA]
    JOIN
        deleted d
    ON
        d.EV_STA_EQ = [STA].EV_STA_EQ
    AND
        d.EV_STA_ChangedAt = [STA].EV_STA_ChangedAt
    AND
        d.EV_STA_EV_ID = [STA].EV_STA_EV_ID;
    DELETE [UTL]
    FROM
        [attributes].[EV_UTL_Event_Utilization] [UTL]
    JOIN
        deleted d
    ON
        d.EV_UTL_EV_ID = [UTL].EV_UTL_EV_ID;
    DELETE [LVL]
    FROM
        [attributes].[EV_LVL_Event_Level] [LVL]
    JOIN
        deleted d
    ON
        d.EV_LVL_ChangedAt = [LVL].EV_LVL_ChangedAt
    AND
        d.EV_LVL_EV_ID = [LVL].EV_LVL_EV_ID;
    DECLARE @deleted TABLE (
        EV_ID numeric(12,0) NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (EV_ID)
    SELECT a.EV_ID
    FROM (
        SELECT [EV].EV_ID
        FROM [nexuses].[EV_Event] [EV] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 EV_DAT_EV_ID
            FROM [attributes].[EV_DAT_Event_Date] WITH(NOLOCK)
            WHERE EV_DAT_EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_AUD_EV_ID
            FROM [attributes].[EV_AUD_Event_Audience] WITH(NOLOCK)
            WHERE EV_AUD_EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_REV_EV_ID
            FROM [attributes].[EV_REV_Event_Revenue] WITH(NOLOCK)
            WHERE EV_REV_EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_STA_EV_ID
            FROM [attributes].[EV_STA_Event_Status] WITH(NOLOCK)
            WHERE EV_STA_EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_UTL_EV_ID
            FROM [attributes].[EV_UTL_Event_Utilization] WITH(NOLOCK)
            WHERE EV_UTL_EV_ID = [EV].EV_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 EV_LVL_EV_ID
            FROM [attributes].[EV_LVL_Event_Level] WITH(NOLOCK)
            WHERE EV_LVL_EV_ID = [EV].EV_ID
        )
    ) a
    JOIN deleted d
    ON d.EV_ID = a.EV_ID;
    DELETE [EV]
    FROM [nexuses].[EV_Event] [EV]
    JOIN @deleted d
    ON d.EV_ID = [EV].EV_ID;
END
GO
