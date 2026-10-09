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
        ST_ID_wasHeldAt,
        PR_ID_wasPlayed,
        ETY_ID_of,
        Metadata_EV 
    )
    OUTPUT
        inserted.EV_ID
    INTO
        @EV
    SELECT
        ST_ID_wasHeldAt,
        PR_ID_wasPlayed,
        ETY_ID_of,
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
        EV_DAT_PositedAt datetime2 null,
        EV_DAT_Reliability decimal(5,2) null,
        EV_DAT_Event_Date datetime2 null,
        EV_AUD_EV_ID numeric(12,0) null,
        Metadata_EV_AUD int null,
        EV_AUD_PositedAt datetime2 null,
        EV_AUD_Reliability decimal(5,2) null,
        EV_AUD_Event_Audience int null,
        EV_REV_EV_ID numeric(12,0) null,
        Metadata_EV_REV int null,
        EV_REV_PositedAt datetime2 null,
        EV_REV_Reliability decimal(5,2) null,
        EV_REV_Event_Revenue decimal(19,4) null,
        EV_STA_EV_ID numeric(12,0) null,
        Metadata_EV_STA int null,
        EV_STA_ChangedAt datetime2 null,
        EV_STA_PositedAt datetime2 null,
        EV_STA_Reliability decimal(5,2) null,
        EV_STA_Event_Status nvarchar(20) null,
        EV_UTL_EV_ID numeric(12,0) null,
        Metadata_EV_UTL int null,
        EV_UTL_PositedAt datetime2 null,
        EV_UTL_Reliability decimal(5,2) null,
        EV_UTL_UTL_Utilization tinyint null,
        EV_UTL_Metadata_UTL int null,
        EV_UTL_UTL_ID tinyint null,
        EV_LVL_EV_ID numeric(12,0) null,
        Metadata_EV_LVL int null,
        EV_LVL_ChangedAt date null,
        EV_LVL_PositedAt datetime2 null,
        EV_LVL_Reliability decimal(5,2) null,
        EV_LVL_PLV_ProfessionalLevel nvarchar(max) null,
        EV_LVL_PLV_Checksum varbinary(16) null,
        EV_LVL_Metadata_PLV int null,
        EV_LVL_PLV_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.EV_ID, a.EV_ID),
        i.Metadata_EV,
        ISNULL(ISNULL(i.EV_DAT_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_DAT, i.Metadata_EV),
        ISNULL(i.EV_DAT_PositedAt, @now),
        ISNULL(ISNULL(i.EV_DAT_Reliability, i.Reliability), 1),
        i.EV_DAT_Event_Date,
        ISNULL(ISNULL(i.EV_AUD_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_AUD, i.Metadata_EV),
        ISNULL(i.EV_AUD_PositedAt, @now),
        ISNULL(ISNULL(i.EV_AUD_Reliability, i.Reliability), 1),
        i.EV_AUD_Event_Audience,
        ISNULL(ISNULL(i.EV_REV_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_REV, i.Metadata_EV),
        ISNULL(i.EV_REV_PositedAt, @now),
        ISNULL(ISNULL(i.EV_REV_Reliability, i.Reliability), 1),
        i.EV_REV_Event_Revenue,
        ISNULL(ISNULL(i.EV_STA_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_STA, i.Metadata_EV),
        ISNULL(i.EV_STA_ChangedAt, @now),
        ISNULL(i.EV_STA_PositedAt, @now),
        ISNULL(ISNULL(i.EV_STA_Reliability, i.Reliability), 1),
        i.EV_STA_Event_Status,
        ISNULL(ISNULL(i.EV_UTL_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_UTL, i.Metadata_EV),
        ISNULL(i.EV_UTL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_UTL_Reliability, i.Reliability), 1),
        i.EV_UTL_UTL_Utilization,
        ISNULL(i.EV_UTL_Metadata_UTL, i.Metadata_EV),
        i.EV_UTL_UTL_ID,
        ISNULL(ISNULL(i.EV_LVL_EV_ID, i.EV_ID), a.EV_ID),
        ISNULL(i.Metadata_EV_LVL, i.Metadata_EV),
        ISNULL(i.EV_LVL_ChangedAt, @now),
        ISNULL(i.EV_LVL_PositedAt, @now),
        ISNULL(ISNULL(i.EV_LVL_Reliability, i.Reliability), 1),
        i.EV_LVL_PLV_ProfessionalLevel,
        ISNULL(i.EV_LVL_PLV_Checksum, dw.MD5(cast(i.EV_LVL_PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.EV_LVL_Metadata_PLV, i.Metadata_EV),
        i.EV_LVL_PLV_ID
    FROM (
        SELECT
            Reliability,
            EV_ID,
            Metadata_EV,
            EV_DAT_EV_ID,
            Metadata_EV_DAT,
            EV_DAT_PositedAt,
            EV_DAT_Reliability,
            EV_DAT_Event_Date,
            EV_AUD_EV_ID,
            Metadata_EV_AUD,
            EV_AUD_PositedAt,
            EV_AUD_Reliability,
            EV_AUD_Event_Audience,
            EV_REV_EV_ID,
            Metadata_EV_REV,
            EV_REV_PositedAt,
            EV_REV_Reliability,
            EV_REV_Event_Revenue,
            EV_STA_EV_ID,
            Metadata_EV_STA,
            EV_STA_ChangedAt,
            EV_STA_PositedAt,
            EV_STA_Reliability,
            EV_STA_Event_Status,
            EV_UTL_EV_ID,
            Metadata_EV_UTL,
            EV_UTL_PositedAt,
            EV_UTL_Reliability,
            EV_UTL_UTL_Utilization,
            EV_UTL_Metadata_UTL,
            EV_UTL_UTL_ID,
            EV_LVL_EV_ID,
            Metadata_EV_LVL,
            EV_LVL_ChangedAt,
            EV_LVL_PositedAt,
            EV_LVL_Reliability,
            EV_LVL_PLV_ProfessionalLevel,
            EV_LVL_PLV_Checksum,
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
    INSERT INTO [attributes].[EV_AUD_Event_Audience] (
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
    INSERT INTO [attributes].[EV_REV_Event_Revenue] (
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
    INSERT INTO [attributes].[EV_STA_Event_Status] (
        Metadata_EV_STA,
        EV_STA_EV_ID,
        EV_STA_Event_Status,
        EV_STA_ChangedAt,
        EV_STA_PositedAt,
        EV_STA_Reliability
    )
    SELECT
        i.Metadata_EV_STA,
        i.EV_STA_EV_ID,
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
        EV_UTL_EV_ID,
        EV_UTL_UTL_ID,
        EV_UTL_PositedAt,
        EV_UTL_Reliability
    )
    SELECT
        i.Metadata_EV_UTL,
        i.EV_UTL_EV_ID,
        ISNULL(i.EV_UTL_UTL_ID, [kUTL].UTL_ID), 
        i.EV_UTL_PositedAt,
        i.EV_UTL_Reliability
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
        EV_LVL_PLV_ID,
        EV_LVL_ChangedAt,
        EV_LVL_PositedAt,
        EV_LVL_Reliability
    )
    SELECT
        i.Metadata_EV_LVL,
        i.EV_LVL_EV_ID,
        ISNULL(i.EV_LVL_PLV_ID, [kPLV].PLV_ID), 
        i.EV_LVL_ChangedAt,
        i.EV_LVL_PositedAt,
        i.EV_LVL_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [knots].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.EV_LVL_PLV_Checksum 
    WHERE
        ISNULL(i.EV_LVL_PLV_ID, [kPLV].PLV_ID) is not null;
END
GO
