-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
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
-- it_lSU_Subject instead of INSERT trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_Subject] ON [dbo].[lSU_Subject]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @SU TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        SU_ID int not null
    );
    INSERT INTO [dbo].[SU_Subject] (
        Metadata_SU 
    )
    OUTPUT
        inserted.SU_ID
    INTO
        @SU
    SELECT
        Metadata_SU 
    FROM
        inserted
    WHERE
        inserted.SU_ID is null;
    DECLARE @inserted TABLE (
        SU_ID int not null,
        Metadata_SU int not null,
        SU_NAM_SU_ID int null,
        Metadata_SU_NAM int null,
        SU_NAM_Positor tinyint null,
        SU_NAM_PositedAt datetime2 null,
        SU_NAM_Reliability decimal(5,2) null,
        SU_NAM_Subject_Name nvarchar(42) null,
        SU_COD_SU_ID int null,
        Metadata_SU_COD int null,
        SU_COD_Positor tinyint null,
        SU_COD_PositedAt datetime2 null,
        SU_COD_Reliability decimal(5,2) null,
        SU_COD_Subject_Code nvarchar(42) null,
        SU_GRD_SU_ID int null,
        Metadata_SU_GRD int null,
        SU_GRD_Positor tinyint null,
        SU_GRD_PositedAt datetime2 null,
        SU_GRD_Reliability decimal(5,2) null,
        SU_GRD_GRD_Grade nvarchar(42) null,
        SU_GRD_Metadata_GRD int null,
        SU_GRD_GRD_ID tinyint null,
        SU_NOT_SU_ID int null,
        Metadata_SU_NOT int null,
        SU_NOT_Positor tinyint null,
        SU_NOT_PositedAt datetime2 null,
        SU_NOT_Reliability decimal(5,2) null,
        SU_NOT_Subject_Note nvarchar(max) null,
        SU_TTL_SU_ID int null,
        Metadata_SU_TTL int null,
        SU_TTL_ChangedAt datetime2 null,
        SU_TTL_Positor tinyint null,
        SU_TTL_PositedAt datetime2 null,
        SU_TTL_Reliability decimal(5,2) null,
        SU_TTL_Subject_Title nvarchar(42) null,
        SU_STA_SU_ID int null,
        Metadata_SU_STA int null,
        SU_STA_ChangedAt datetime2 null,
        SU_STA_Positor tinyint null,
        SU_STA_PositedAt datetime2 null,
        SU_STA_Reliability decimal(5,2) null,
        SU_STA_Subject_State nvarchar(42) null,
        SU_LBL_SU_ID int null,
        Metadata_SU_LBL int null,
        SU_LBL_ChangedAt datetime2 null,
        SU_LBL_Positor tinyint null,
        SU_LBL_PositedAt datetime2 null,
        SU_LBL_Reliability decimal(5,2) null,
        SU_LBL_Subject_Label nvarchar(42) null,
        SU_TAG_SU_ID int null,
        Metadata_SU_TAG int null,
        SU_TAG_ChangedAt datetime2 null,
        SU_TAG_Positor tinyint null,
        SU_TAG_PositedAt datetime2 null,
        SU_TAG_Reliability decimal(5,2) null,
        SU_TAG_Subject_Tag nvarchar(42) null,
        SU_LVL_SU_ID int null,
        Metadata_SU_LVL int null,
        SU_LVL_ChangedAt datetime2 null,
        SU_LVL_Positor tinyint null,
        SU_LVL_PositedAt datetime2 null,
        SU_LVL_Reliability decimal(5,2) null,
        SU_LVL_GRD_Grade nvarchar(42) null,
        SU_LVL_Metadata_GRD int null,
        SU_LVL_GRD_ID tinyint null,
        SU_TXT_SU_ID int null,
        Metadata_SU_TXT int null,
        SU_TXT_ChangedAt datetime2 null,
        SU_TXT_Positor tinyint null,
        SU_TXT_PositedAt datetime2 null,
        SU_TXT_Reliability decimal(5,2) null,
        SU_TXT_Subject_Text nvarchar(max) null,
        SU_ASR_SU_ID int null,
        Metadata_SU_ASR int null,
        SU_ASR_ChangedAt datetime2 null,
        SU_ASR_Positor tinyint null,
        SU_ASR_PositedAt datetime2 null,
        SU_ASR_Reliability decimal(5,2) null,
        SU_ASR_Subject_Assessment nvarchar(42) null,
        SU_ERS_SU_ID int null,
        Metadata_SU_ERS int null,
        SU_ERS_ChangedAt datetime2 null,
        SU_ERS_Positor tinyint null,
        SU_ERS_PositedAt datetime2 null,
        SU_ERS_Reliability decimal(5,2) null,
        SU_ERS_Subject_Erasable nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.SU_ID, a.SU_ID),
        i.Metadata_SU,
        ISNULL(ISNULL(i.SU_NAM_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NAM, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_NAM_Positor, i.Positor), 0),
        ISNULL(i.SU_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.SU_NAM_Reliability, i.Reliability), 1),
        i.SU_NAM_Subject_Name,
        ISNULL(ISNULL(i.SU_COD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_COD, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_COD_Positor, i.Positor), 0),
        ISNULL(i.SU_COD_PositedAt, @now),
        ISNULL(ISNULL(i.SU_COD_Reliability, i.Reliability), 1),
        i.SU_COD_Subject_Code,
        ISNULL(ISNULL(i.SU_GRD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_GRD, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_GRD_Positor, i.Positor), 0),
        ISNULL(i.SU_GRD_PositedAt, @now),
        ISNULL(ISNULL(i.SU_GRD_Reliability, i.Reliability), 1),
        i.SU_GRD_GRD_Grade,
        ISNULL(i.SU_GRD_Metadata_GRD, i.Metadata_SU),
        i.SU_GRD_GRD_ID,
        ISNULL(ISNULL(i.SU_NOT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NOT, i.Metadata_SU),
        ISNULL(ISNULL(i.SU_NOT_Positor, i.Positor), 0),
        ISNULL(i.SU_NOT_PositedAt, @now),
        ISNULL(ISNULL(i.SU_NOT_Reliability, i.Reliability), 1),
        i.SU_NOT_Subject_Note,
        ISNULL(ISNULL(i.SU_TTL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TTL, i.Metadata_SU),
        ISNULL(i.SU_TTL_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_TTL_Positor, i.Positor), 0),
        ISNULL(i.SU_TTL_PositedAt, @now),
        ISNULL(ISNULL(i.SU_TTL_Reliability, i.Reliability), 1),
        i.SU_TTL_Subject_Title,
        ISNULL(ISNULL(i.SU_STA_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_STA, i.Metadata_SU),
        ISNULL(i.SU_STA_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_STA_Positor, i.Positor), 0),
        ISNULL(i.SU_STA_PositedAt, @now),
        ISNULL(ISNULL(i.SU_STA_Reliability, i.Reliability), 1),
        i.SU_STA_Subject_State,
        ISNULL(ISNULL(i.SU_LBL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LBL, i.Metadata_SU),
        ISNULL(i.SU_LBL_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_LBL_Positor, i.Positor), 0),
        ISNULL(i.SU_LBL_PositedAt, @now),
        ISNULL(ISNULL(i.SU_LBL_Reliability, i.Reliability), 1),
        i.SU_LBL_Subject_Label,
        ISNULL(ISNULL(i.SU_TAG_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TAG, i.Metadata_SU),
        ISNULL(i.SU_TAG_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_TAG_Positor, i.Positor), 0),
        ISNULL(i.SU_TAG_PositedAt, @now),
        ISNULL(ISNULL(i.SU_TAG_Reliability, i.Reliability), 1),
        i.SU_TAG_Subject_Tag,
        ISNULL(ISNULL(i.SU_LVL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LVL, i.Metadata_SU),
        ISNULL(i.SU_LVL_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_LVL_Positor, i.Positor), 0),
        ISNULL(i.SU_LVL_PositedAt, @now),
        ISNULL(ISNULL(i.SU_LVL_Reliability, i.Reliability), 1),
        i.SU_LVL_GRD_Grade,
        ISNULL(i.SU_LVL_Metadata_GRD, i.Metadata_SU),
        i.SU_LVL_GRD_ID,
        ISNULL(ISNULL(i.SU_TXT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TXT, i.Metadata_SU),
        ISNULL(i.SU_TXT_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_TXT_Positor, i.Positor), 0),
        ISNULL(i.SU_TXT_PositedAt, @now),
        ISNULL(ISNULL(i.SU_TXT_Reliability, i.Reliability), 1),
        i.SU_TXT_Subject_Text,
        ISNULL(ISNULL(i.SU_ASR_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ASR, i.Metadata_SU),
        ISNULL(i.SU_ASR_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_ASR_Positor, i.Positor), 0),
        ISNULL(i.SU_ASR_PositedAt, @now),
        ISNULL(ISNULL(i.SU_ASR_Reliability, i.Reliability), 1),
        i.SU_ASR_Subject_Assessment,
        ISNULL(ISNULL(i.SU_ERS_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ERS, i.Metadata_SU),
        ISNULL(i.SU_ERS_ChangedAt, @now),
        ISNULL(ISNULL(i.SU_ERS_Positor, i.Positor), 0),
        ISNULL(i.SU_ERS_PositedAt, @now),
        ISNULL(ISNULL(i.SU_ERS_Reliability, i.Reliability), 1),
        i.SU_ERS_Subject_Erasable
    FROM (
        SELECT
            Positor,
            Reliability,
            SU_ID,
            Metadata_SU,
            SU_NAM_SU_ID,
            Metadata_SU_NAM,
            SU_NAM_Positor,
            SU_NAM_PositedAt,
            SU_NAM_Reliability,
            SU_NAM_Subject_Name,
            SU_COD_SU_ID,
            Metadata_SU_COD,
            SU_COD_Positor,
            SU_COD_PositedAt,
            SU_COD_Reliability,
            SU_COD_Subject_Code,
            SU_GRD_SU_ID,
            Metadata_SU_GRD,
            SU_GRD_Positor,
            SU_GRD_PositedAt,
            SU_GRD_Reliability,
            SU_GRD_GRD_Grade,
            SU_GRD_Metadata_GRD,
            SU_GRD_GRD_ID,
            SU_NOT_SU_ID,
            Metadata_SU_NOT,
            SU_NOT_Positor,
            SU_NOT_PositedAt,
            SU_NOT_Reliability,
            SU_NOT_Subject_Note,
            SU_TTL_SU_ID,
            Metadata_SU_TTL,
            SU_TTL_ChangedAt,
            SU_TTL_Positor,
            SU_TTL_PositedAt,
            SU_TTL_Reliability,
            SU_TTL_Subject_Title,
            SU_STA_SU_ID,
            Metadata_SU_STA,
            SU_STA_ChangedAt,
            SU_STA_Positor,
            SU_STA_PositedAt,
            SU_STA_Reliability,
            SU_STA_Subject_State,
            SU_LBL_SU_ID,
            Metadata_SU_LBL,
            SU_LBL_ChangedAt,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability,
            SU_LBL_Subject_Label,
            SU_TAG_SU_ID,
            Metadata_SU_TAG,
            SU_TAG_ChangedAt,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability,
            SU_TAG_Subject_Tag,
            SU_LVL_SU_ID,
            Metadata_SU_LVL,
            SU_LVL_ChangedAt,
            SU_LVL_Positor,
            SU_LVL_PositedAt,
            SU_LVL_Reliability,
            SU_LVL_GRD_Grade,
            SU_LVL_Metadata_GRD,
            SU_LVL_GRD_ID,
            SU_TXT_SU_ID,
            Metadata_SU_TXT,
            SU_TXT_ChangedAt,
            SU_TXT_Positor,
            SU_TXT_PositedAt,
            SU_TXT_Reliability,
            SU_TXT_Subject_Text,
            SU_ASR_SU_ID,
            Metadata_SU_ASR,
            SU_ASR_ChangedAt,
            SU_ASR_Positor,
            SU_ASR_PositedAt,
            SU_ASR_Reliability,
            SU_ASR_Subject_Assessment,
            SU_ERS_SU_ID,
            Metadata_SU_ERS,
            SU_ERS_ChangedAt,
            SU_ERS_Positor,
            SU_ERS_PositedAt,
            SU_ERS_Reliability,
            SU_ERS_Subject_Erasable,
            ROW_NUMBER() OVER (PARTITION BY SU_ID ORDER BY SU_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @SU a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[SU_NAM_Subject_Name] (
        Metadata_SU_NAM,
        SU_NAM_SU_ID,
        SU_NAM_Subject_Name,
        SU_NAM_PositedAt,
        SU_NAM_Positor,
        SU_NAM_Reliability
    )
    SELECT
        i.Metadata_SU_NAM,
        i.SU_NAM_SU_ID,
        i.SU_NAM_Subject_Name,
        i.SU_NAM_PositedAt,
        i.SU_NAM_Positor,
        i.SU_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_NAM_Subject_Name is not null;
    INSERT INTO [dbo].[SU_COD_Subject_Code] (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code,
        SU_COD_PositedAt,
        SU_COD_Positor,
        SU_COD_Reliability
    )
    SELECT
        i.Metadata_SU_COD,
        i.SU_COD_SU_ID,
        i.SU_COD_Subject_Code,
        i.SU_COD_PositedAt,
        i.SU_COD_Positor,
        i.SU_COD_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_COD_Subject_Code is not null;
    INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID,
        SU_GRD_PositedAt,
        SU_GRD_Positor,
        SU_GRD_Reliability
    )
    SELECT
        i.Metadata_SU_GRD,
        i.SU_GRD_SU_ID,
        ISNULL(i.SU_GRD_GRD_ID, [kGRD].GRD_ID), 
        i.SU_GRD_PositedAt,
        i.SU_GRD_Positor,
        i.SU_GRD_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [kGRD]
    ON
        [kGRD].GRD_Grade = i.SU_GRD_GRD_Grade
    WHERE
        ISNULL(i.SU_GRD_GRD_ID, [kGRD].GRD_ID) is not null;
    INSERT INTO [dbo].[SU_NOT_Subject_Note] (
        Metadata_SU_NOT,
        SU_NOT_SU_ID,
        SU_NOT_Subject_Note,
        SU_NOT_PositedAt,
        SU_NOT_Positor,
        SU_NOT_Reliability
    )
    SELECT
        i.Metadata_SU_NOT,
        i.SU_NOT_SU_ID,
        i.SU_NOT_Subject_Note,
        i.SU_NOT_PositedAt,
        i.SU_NOT_Positor,
        i.SU_NOT_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_NOT_Subject_Note is not null;
    INSERT INTO [dbo].[SU_TTL_Subject_Title] (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_Subject_Title,
        SU_TTL_ChangedAt,
        SU_TTL_PositedAt,
        SU_TTL_Positor,
        SU_TTL_Reliability
    )
    SELECT
        i.Metadata_SU_TTL,
        i.SU_TTL_SU_ID,
        i.SU_TTL_Subject_Title,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_PositedAt,
        i.SU_TTL_Positor,
        i.SU_TTL_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_TTL_Subject_Title is not null;
    INSERT INTO [dbo].[SU_STA_Subject_State] (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_Subject_State,
        SU_STA_ChangedAt,
        SU_STA_PositedAt,
        SU_STA_Positor,
        SU_STA_Reliability
    )
    SELECT
        i.Metadata_SU_STA,
        i.SU_STA_SU_ID,
        i.SU_STA_Subject_State,
        i.SU_STA_ChangedAt,
        i.SU_STA_PositedAt,
        i.SU_STA_Positor,
        i.SU_STA_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_STA_Subject_State is not null;
    INSERT INTO [dbo].[SU_LBL_Subject_Label] (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_Subject_Label,
        SU_LBL_ChangedAt,
        SU_LBL_PositedAt,
        SU_LBL_Positor,
        SU_LBL_Reliability
    )
    SELECT
        i.Metadata_SU_LBL,
        i.SU_LBL_SU_ID,
        i.SU_LBL_Subject_Label,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_PositedAt,
        i.SU_LBL_Positor,
        i.SU_LBL_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_LBL_Subject_Label is not null;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_Subject_Tag,
        SU_TAG_ChangedAt,
        SU_TAG_PositedAt,
        SU_TAG_Positor,
        SU_TAG_Reliability
    )
    SELECT
        i.Metadata_SU_TAG,
        i.SU_TAG_SU_ID,
        i.SU_TAG_Subject_Tag,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_PositedAt,
        i.SU_TAG_Positor,
        i.SU_TAG_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_TAG_Subject_Tag is not null;
    INSERT INTO [dbo].[SU_LVL_Subject_Level] (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_GRD_ID,
        SU_LVL_ChangedAt,
        SU_LVL_PositedAt,
        SU_LVL_Positor,
        SU_LVL_Reliability
    )
    SELECT
        i.Metadata_SU_LVL,
        i.SU_LVL_SU_ID,
        ISNULL(i.SU_LVL_GRD_ID, [kGRD].GRD_ID), 
        i.SU_LVL_ChangedAt,
        i.SU_LVL_PositedAt,
        i.SU_LVL_Positor,
        i.SU_LVL_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [kGRD]
    ON
        [kGRD].GRD_Grade = i.SU_LVL_GRD_Grade
    WHERE
        ISNULL(i.SU_LVL_GRD_ID, [kGRD].GRD_ID) is not null;
    INSERT INTO [dbo].[SU_TXT_Subject_Text] (
        Metadata_SU_TXT,
        SU_TXT_SU_ID,
        SU_TXT_Subject_Text,
        SU_TXT_ChangedAt,
        SU_TXT_PositedAt,
        SU_TXT_Positor,
        SU_TXT_Reliability
    )
    SELECT
        i.Metadata_SU_TXT,
        i.SU_TXT_SU_ID,
        i.SU_TXT_Subject_Text,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_PositedAt,
        i.SU_TXT_Positor,
        i.SU_TXT_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_TXT_Subject_Text is not null;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_Subject_Assessment,
        SU_ASR_ChangedAt,
        SU_ASR_PositedAt,
        SU_ASR_Positor,
        SU_ASR_Reliability
    )
    SELECT
        i.Metadata_SU_ASR,
        i.SU_ASR_SU_ID,
        i.SU_ASR_Subject_Assessment,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_PositedAt,
        i.SU_ASR_Positor,
        i.SU_ASR_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_ASR_Subject_Assessment is not null;
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_Subject_Erasable,
        SU_ERS_ChangedAt,
        SU_ERS_PositedAt,
        SU_ERS_Positor,
        SU_ERS_Reliability
    )
    SELECT
        i.Metadata_SU_ERS,
        i.SU_ERS_SU_ID,
        i.SU_ERS_Subject_Erasable,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_PositedAt,
        i.SU_ERS_Positor,
        i.SU_ERS_Reliability
    FROM
        @inserted i
    WHERE
        i.SU_ERS_Subject_Erasable is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_Subject instead of UPDATE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_Subject] ON [dbo].[lSU_Subject]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_ID))
        RAISERROR('The identity column SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_ID))
        RAISERROR('The identity column SU_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_SU_ID))
        RAISERROR('The foreign key column SU_NAM_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_Assertion))
        RAISERROR('The computed assertion column SU_NAM_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_NAM_Subject_Name) OR
        UPDATE(SU_NAM_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NAM_Subject_Name] (
            Metadata_SU_NAM,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name,
            SU_NAM_PositedAt,
            SU_NAM_Positor,
            SU_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NAM)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NAM
            END, i.Metadata_SU),
            ISNULL(i.SU_NAM_SU_ID, i.SU_ID),
            i.SU_NAM_Subject_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NAM_PositedAt) THEN i.SU_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NAM_Positor) THEN i.SU_NAM_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_NAM_Reliability) THEN i.SU_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_NAM_Subject_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_NAM_PositedAt) OR
            UPDATE(SU_NAM_Positor) OR
            UPDATE(Positor) OR
            d.SU_NAM_Subject_Name is null OR
            d.SU_NAM_Subject_Name <> i.SU_NAM_Subject_Name OR
            d.SU_NAM_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_NAM_Reliability) THEN i.SU_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_NAM_Subject_Name) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_NAM_Subject_Name] (
            Metadata_SU_NAM,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name,
            SU_NAM_PositedAt,
            SU_NAM_Positor,
            SU_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NAM)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NAM
            END, i.Metadata_SU),
            p.SU_NAM_SU_ID,
            p.SU_NAM_Subject_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NAM_PositedAt) THEN i.SU_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NAM_Positor) THEN i.SU_NAM_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_ID = i.SU_NAM_ID
        WHERE
            i.SU_NAM_Subject_Name is null
    END
    IF(UPDATE(SU_COD_ID))
        RAISERROR('The identity column SU_COD_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_COD_SU_ID))
        RAISERROR('The foreign key column SU_COD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_COD_Assertion))
        RAISERROR('The computed assertion column SU_COD_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_COD_Subject_Code) OR
        UPDATE(SU_COD_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_COD_Subject_Code] (
            Metadata_SU_COD,
            SU_COD_SU_ID,
            SU_COD_Subject_Code,
            SU_COD_PositedAt,
            SU_COD_Positor,
            SU_COD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_COD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_COD
            END, i.Metadata_SU),
            ISNULL(i.SU_COD_SU_ID, i.SU_ID),
            i.SU_COD_Subject_Code,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_COD_PositedAt) THEN i.SU_COD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_COD_Positor) THEN i.SU_COD_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_COD_Reliability) THEN i.SU_COD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_COD_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_COD_Subject_Code is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_COD_PositedAt) OR
            UPDATE(SU_COD_Positor) OR
            UPDATE(Positor) OR
            d.SU_COD_Subject_Code is null OR
            d.SU_COD_Subject_Code <> i.SU_COD_Subject_Code OR
            d.SU_COD_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_COD_Reliability) THEN i.SU_COD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_COD_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_COD_Subject_Code) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_COD_Subject_Code] (
            Metadata_SU_COD,
            SU_COD_SU_ID,
            SU_COD_Subject_Code,
            SU_COD_PositedAt,
            SU_COD_Positor,
            SU_COD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_COD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_COD
            END, i.Metadata_SU),
            p.SU_COD_SU_ID,
            p.SU_COD_Subject_Code,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_COD_PositedAt) THEN i.SU_COD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_COD_Positor) THEN i.SU_COD_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_ID = i.SU_COD_ID
        WHERE
            i.SU_COD_Subject_Code is null
    END
    IF(UPDATE(SU_GRD_ID))
        RAISERROR('The identity column SU_GRD_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_GRD_SU_ID))
        RAISERROR('The foreign key column SU_GRD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_GRD_Assertion))
        RAISERROR('The computed assertion column SU_GRD_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_GRD_GRD_ID) OR
        UPDATE(SU_GRD_GRD_Grade) OR
        UPDATE(SU_GRD_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
            Metadata_SU_GRD,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Positor,
            SU_GRD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_GRD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_GRD
            END, i.Metadata_SU),
            ISNULL(i.SU_GRD_SU_ID, i.SU_ID),
            CASE
                WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID
                ELSE [kGRD].GRD_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_GRD_PositedAt) THEN i.SU_GRD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_GRD_Positor) THEN i.SU_GRD_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_GRD_Reliability) THEN i.SU_GRD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_GRD_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GRD_Grade] [kGRD]
        ON
            [kGRD].GRD_Grade = i.SU_GRD_GRD_Grade
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID
                ELSE [kGRD].GRD_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_GRD_PositedAt) OR
            UPDATE(SU_GRD_Positor) OR
            UPDATE(Positor) OR
            d.SU_GRD_GRD_ID is null OR
            d.SU_GRD_GRD_ID <> CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END OR
            d.SU_GRD_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_GRD_Reliability) THEN i.SU_GRD_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_GRD_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_GRD_GRD_ID) OR
        UPDATE(SU_GRD_GRD_Grade) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
            Metadata_SU_GRD,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Positor,
            SU_GRD_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_GRD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_GRD
            END, i.Metadata_SU),
            p.SU_GRD_SU_ID,
            p.SU_GRD_GRD_ID,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_GRD_PositedAt) THEN i.SU_GRD_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_GRD_Positor) THEN i.SU_GRD_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_ID = i.SU_GRD_ID
        WHERE
            (UPDATE(SU_GRD_GRD_ID) AND i.SU_GRD_GRD_ID is null)
        OR 
            (UPDATE(SU_GRD_GRD_Grade) AND i.SU_GRD_GRD_Grade is null);
    END
    IF(UPDATE(SU_NOT_ID))
        RAISERROR('The identity column SU_NOT_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NOT_SU_ID))
        RAISERROR('The foreign key column SU_NOT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NOT_Assertion))
        RAISERROR('The computed assertion column SU_NOT_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_NOT_Subject_Note) OR
        UPDATE(SU_NOT_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_NOT_Subject_Note] (
            Metadata_SU_NOT,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note,
            SU_NOT_PositedAt,
            SU_NOT_Positor,
            SU_NOT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NOT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NOT
            END, i.Metadata_SU),
            ISNULL(i.SU_NOT_SU_ID, i.SU_ID),
            i.SU_NOT_Subject_Note,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NOT_PositedAt) THEN i.SU_NOT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NOT_Positor) THEN i.SU_NOT_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_NOT_Reliability) THEN i.SU_NOT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NOT_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_NOT_Subject_Note is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_NOT_PositedAt) OR
            UPDATE(SU_NOT_Positor) OR
            UPDATE(Positor) OR
            d.SU_NOT_Subject_Note is null OR
            d.SU_NOT_Checksum <> dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max))) OR 
            d.SU_NOT_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_NOT_Reliability) THEN i.SU_NOT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_NOT_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_NOT_Subject_Note) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_NOT_Subject_Note] (
            Metadata_SU_NOT,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note,
            SU_NOT_PositedAt,
            SU_NOT_Positor,
            SU_NOT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NOT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NOT
            END, i.Metadata_SU),
            p.SU_NOT_SU_ID,
            p.SU_NOT_Subject_Note,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_NOT_PositedAt) THEN i.SU_NOT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_NOT_Positor) THEN i.SU_NOT_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_ID = i.SU_NOT_ID
        WHERE
            i.SU_NOT_Subject_Note is null
    END
    IF(UPDATE(SU_TTL_ID))
        RAISERROR('The identity column SU_TTL_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TTL_SU_ID))
        RAISERROR('The foreign key column SU_TTL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TTL_Assertion))
        RAISERROR('The computed assertion column SU_TTL_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_TTL_Subject_Title) OR
        UPDATE(SU_TTL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TTL_Subject_Title] (
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TTL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TTL
            END, i.Metadata_SU),
            ISNULL(i.SU_TTL_SU_ID, i.SU_ID),
            i.SU_TTL_Subject_Title,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_ChangedAt) THEN i.SU_TTL_ChangedAt
                WHEN d.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
                THEN i.SU_TTL_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_PositedAt) THEN i.SU_TTL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TTL_Positor) THEN i.SU_TTL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_TTL_Reliability) THEN i.SU_TTL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TTL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_TTL_Subject_Title is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_TTL_ChangedAt) OR
            UPDATE(SU_TTL_PositedAt) OR
            UPDATE(SU_TTL_Positor) OR
            UPDATE(Positor) OR
            d.SU_TTL_Subject_Title is null OR
            d.SU_TTL_Subject_Title <> i.SU_TTL_Subject_Title OR
            d.SU_TTL_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_TTL_Reliability) THEN i.SU_TTL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TTL_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_TTL_Subject_Title) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_TTL_Subject_Title] (
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TTL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TTL
            END, i.Metadata_SU),
            p.SU_TTL_SU_ID,
            p.SU_TTL_Subject_Title,
            p.SU_TTL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TTL_PositedAt) THEN i.SU_TTL_PositedAt
                WHEN UPDATE(SU_TTL_ChangedAt) THEN i.SU_TTL_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TTL_Positor) THEN i.SU_TTL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_ID = i.SU_TTL_ID
        WHERE
            i.SU_TTL_Subject_Title is null
    END
    IF(UPDATE(SU_STA_ID))
        RAISERROR('The identity column SU_STA_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_STA_SU_ID))
        RAISERROR('The foreign key column SU_STA_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_STA_Assertion))
        RAISERROR('The computed assertion column SU_STA_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_STA_Subject_State) OR
        UPDATE(SU_STA_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_STA_Subject_State] (
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_STA)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_STA
            END, i.Metadata_SU),
            ISNULL(i.SU_STA_SU_ID, i.SU_ID),
            i.SU_STA_Subject_State,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_ChangedAt) THEN i.SU_STA_ChangedAt
                WHEN d.SU_STA_Subject_State = i.SU_STA_Subject_State
                THEN i.SU_STA_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_PositedAt) THEN i.SU_STA_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_STA_Positor) THEN i.SU_STA_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_STA_Reliability) THEN i.SU_STA_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_STA_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_STA_Subject_State is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_STA_ChangedAt) OR
            UPDATE(SU_STA_PositedAt) OR
            UPDATE(SU_STA_Positor) OR
            UPDATE(Positor) OR
            d.SU_STA_Subject_State is null OR
            d.SU_STA_Subject_State <> i.SU_STA_Subject_State OR
            d.SU_STA_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_STA_Reliability) THEN i.SU_STA_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_STA_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_STA_Subject_State) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_STA_Subject_State] (
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_STA)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_STA
            END, i.Metadata_SU),
            p.SU_STA_SU_ID,
            p.SU_STA_Subject_State,
            p.SU_STA_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_STA_PositedAt) THEN i.SU_STA_PositedAt
                WHEN UPDATE(SU_STA_ChangedAt) THEN i.SU_STA_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_STA_Positor) THEN i.SU_STA_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_ID = i.SU_STA_ID
        WHERE
            i.SU_STA_Subject_State is null
    END
    IF(UPDATE(SU_LBL_ID))
        RAISERROR('The identity column SU_LBL_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LBL_SU_ID))
        RAISERROR('The foreign key column SU_LBL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LBL_Assertion))
        RAISERROR('The computed assertion column SU_LBL_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_LBL_Subject_Label) OR
        UPDATE(SU_LBL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LBL_Subject_Label] (
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LBL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LBL
            END, i.Metadata_SU),
            ISNULL(i.SU_LBL_SU_ID, i.SU_ID),
            i.SU_LBL_Subject_Label,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_ChangedAt) THEN i.SU_LBL_ChangedAt
                WHEN d.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
                THEN i.SU_LBL_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_PositedAt) THEN i.SU_LBL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LBL_Positor) THEN i.SU_LBL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_LBL_Reliability) THEN i.SU_LBL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LBL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_LBL_Subject_Label is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_LBL_ChangedAt) OR
            UPDATE(SU_LBL_PositedAt) OR
            UPDATE(SU_LBL_Positor) OR
            UPDATE(Positor) OR
            d.SU_LBL_Subject_Label is null OR
            d.SU_LBL_Subject_Label <> i.SU_LBL_Subject_Label OR
            d.SU_LBL_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_LBL_Reliability) THEN i.SU_LBL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LBL_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_LBL_Subject_Label) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_LBL_Subject_Label] (
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LBL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LBL
            END, i.Metadata_SU),
            p.SU_LBL_SU_ID,
            p.SU_LBL_Subject_Label,
            p.SU_LBL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LBL_PositedAt) THEN i.SU_LBL_PositedAt
                WHEN UPDATE(SU_LBL_ChangedAt) THEN i.SU_LBL_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LBL_Positor) THEN i.SU_LBL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_ID = i.SU_LBL_ID
        WHERE
            i.SU_LBL_Subject_Label is null
    END
    IF(UPDATE(SU_TAG_ID))
        RAISERROR('The identity column SU_TAG_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TAG_SU_ID))
        RAISERROR('The foreign key column SU_TAG_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TAG_Assertion))
        RAISERROR('The computed assertion column SU_TAG_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_TAG_Subject_Tag) OR
        UPDATE(SU_TAG_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TAG)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TAG
            END, i.Metadata_SU),
            ISNULL(i.SU_TAG_SU_ID, i.SU_ID),
            i.SU_TAG_Subject_Tag,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_ChangedAt) THEN i.SU_TAG_ChangedAt
                WHEN d.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
                THEN i.SU_TAG_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_PositedAt) THEN i.SU_TAG_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TAG_Positor) THEN i.SU_TAG_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_TAG_Reliability) THEN i.SU_TAG_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TAG_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_TAG_Subject_Tag is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_TAG_ChangedAt) OR
            UPDATE(SU_TAG_PositedAt) OR
            UPDATE(SU_TAG_Positor) OR
            UPDATE(Positor) OR
            d.SU_TAG_Subject_Tag is null OR
            d.SU_TAG_Subject_Tag <> i.SU_TAG_Subject_Tag OR
            d.SU_TAG_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_TAG_Reliability) THEN i.SU_TAG_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TAG_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_TAG_Subject_Tag) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TAG)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TAG
            END, i.Metadata_SU),
            p.SU_TAG_SU_ID,
            p.SU_TAG_Subject_Tag,
            p.SU_TAG_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TAG_PositedAt) THEN i.SU_TAG_PositedAt
                WHEN UPDATE(SU_TAG_ChangedAt) THEN i.SU_TAG_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TAG_Positor) THEN i.SU_TAG_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_ID = i.SU_TAG_ID
        WHERE
            i.SU_TAG_Subject_Tag is null
    END
    IF(UPDATE(SU_LVL_ID))
        RAISERROR('The identity column SU_LVL_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LVL_SU_ID))
        RAISERROR('The foreign key column SU_LVL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LVL_Assertion))
        RAISERROR('The computed assertion column SU_LVL_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_LVL_GRD_ID) OR
        UPDATE(SU_LVL_GRD_Grade) OR
        UPDATE(SU_LVL_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_LVL_Subject_Level] (
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LVL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LVL
            END, i.Metadata_SU),
            ISNULL(i.SU_LVL_SU_ID, i.SU_ID),
            CASE
                WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID
                ELSE [kGRD].GRD_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_ChangedAt) THEN i.SU_LVL_ChangedAt
                WHEN d.SU_LVL_GRD_ID = CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END
                THEN i.SU_LVL_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_PositedAt) THEN i.SU_LVL_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LVL_Positor) THEN i.SU_LVL_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_LVL_Reliability) THEN i.SU_LVL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LVL_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GRD_Grade] [kGRD]
        ON
            [kGRD].GRD_Grade = i.SU_LVL_GRD_Grade
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID
                ELSE [kGRD].GRD_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_LVL_ChangedAt) OR
            UPDATE(SU_LVL_PositedAt) OR
            UPDATE(SU_LVL_Positor) OR
            UPDATE(Positor) OR
            d.SU_LVL_GRD_ID is null OR
            d.SU_LVL_GRD_ID <> CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END OR
            d.SU_LVL_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_LVL_Reliability) THEN i.SU_LVL_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_LVL_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_LVL_GRD_ID) OR
        UPDATE(SU_LVL_GRD_Grade) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_LVL_Subject_Level] (
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LVL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LVL
            END, i.Metadata_SU),
            p.SU_LVL_SU_ID,
            p.SU_LVL_GRD_ID,
            p.SU_LVL_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_LVL_PositedAt) THEN i.SU_LVL_PositedAt
                WHEN UPDATE(SU_LVL_ChangedAt) THEN i.SU_LVL_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_LVL_Positor) THEN i.SU_LVL_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_ID = i.SU_LVL_ID
        WHERE
            (UPDATE(SU_LVL_GRD_ID) AND i.SU_LVL_GRD_ID is null)
        OR 
            (UPDATE(SU_LVL_GRD_Grade) AND i.SU_LVL_GRD_Grade is null);
    END
    IF(UPDATE(SU_TXT_ID))
        RAISERROR('The identity column SU_TXT_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TXT_SU_ID))
        RAISERROR('The foreign key column SU_TXT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TXT_Assertion))
        RAISERROR('The computed assertion column SU_TXT_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_TXT_Subject_Text) OR
        UPDATE(SU_TXT_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_TXT_Subject_Text] (
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TXT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TXT
            END, i.Metadata_SU),
            ISNULL(i.SU_TXT_SU_ID, i.SU_ID),
            i.SU_TXT_Subject_Text,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_ChangedAt) THEN i.SU_TXT_ChangedAt
                WHEN d.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))) 
                THEN i.SU_TXT_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_PositedAt) THEN i.SU_TXT_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TXT_Positor) THEN i.SU_TXT_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_TXT_Reliability) THEN i.SU_TXT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TXT_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_TXT_Subject_Text is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_TXT_ChangedAt) OR
            UPDATE(SU_TXT_PositedAt) OR
            UPDATE(SU_TXT_Positor) OR
            UPDATE(Positor) OR
            d.SU_TXT_Subject_Text is null OR
            d.SU_TXT_Checksum <> dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))) OR 
            d.SU_TXT_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_TXT_Reliability) THEN i.SU_TXT_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_TXT_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_TXT_Subject_Text) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_TXT_Subject_Text] (
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TXT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TXT
            END, i.Metadata_SU),
            p.SU_TXT_SU_ID,
            p.SU_TXT_Subject_Text,
            p.SU_TXT_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_TXT_PositedAt) THEN i.SU_TXT_PositedAt
                WHEN UPDATE(SU_TXT_ChangedAt) THEN i.SU_TXT_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_TXT_Positor) THEN i.SU_TXT_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_ID = i.SU_TXT_ID
        WHERE
            i.SU_TXT_Subject_Text is null
    END
    IF(UPDATE(SU_ASR_ID))
        RAISERROR('The identity column SU_ASR_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ASR_SU_ID))
        RAISERROR('The foreign key column SU_ASR_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ASR_Assertion))
        RAISERROR('The computed assertion column SU_ASR_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_ASR_Subject_Assessment) OR
        UPDATE(SU_ASR_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ASR)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ASR
            END, i.Metadata_SU),
            ISNULL(i.SU_ASR_SU_ID, i.SU_ID),
            i.SU_ASR_Subject_Assessment,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_ChangedAt) THEN i.SU_ASR_ChangedAt
                WHEN d.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
                THEN i.SU_ASR_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_PositedAt) THEN i.SU_ASR_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ASR_Positor) THEN i.SU_ASR_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_ASR_Reliability) THEN i.SU_ASR_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ASR_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_ASR_Subject_Assessment is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_ASR_ChangedAt) OR
            UPDATE(SU_ASR_PositedAt) OR
            UPDATE(SU_ASR_Positor) OR
            UPDATE(Positor) OR
            d.SU_ASR_Subject_Assessment is null OR
            d.SU_ASR_Subject_Assessment <> i.SU_ASR_Subject_Assessment OR
            d.SU_ASR_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_ASR_Reliability) THEN i.SU_ASR_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ASR_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_ASR_Subject_Assessment) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ASR)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ASR
            END, i.Metadata_SU),
            p.SU_ASR_SU_ID,
            p.SU_ASR_Subject_Assessment,
            p.SU_ASR_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ASR_PositedAt) THEN i.SU_ASR_PositedAt
                WHEN UPDATE(SU_ASR_ChangedAt) THEN i.SU_ASR_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ASR_Positor) THEN i.SU_ASR_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_ID = i.SU_ASR_ID
        WHERE
            i.SU_ASR_Subject_Assessment is null
    END
    IF(UPDATE(SU_ERS_ID))
        RAISERROR('The identity column SU_ERS_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ERS_SU_ID))
        RAISERROR('The foreign key column SU_ERS_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ERS_Assertion))
        RAISERROR('The computed assertion column SU_ERS_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(SU_ERS_Subject_Erasable) OR
        UPDATE(SU_ERS_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ERS)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ERS
            END, i.Metadata_SU),
            ISNULL(i.SU_ERS_SU_ID, i.SU_ID),
            i.SU_ERS_Subject_Erasable,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt
                WHEN d.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
                THEN i.SU_ERS_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_PositedAt) THEN i.SU_ERS_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ERS_Positor) THEN i.SU_ERS_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(SU_ERS_Reliability) THEN i.SU_ERS_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ERS_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.SU_ERS_Subject_Erasable is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_ERS_ChangedAt) OR
            UPDATE(SU_ERS_PositedAt) OR
            UPDATE(SU_ERS_Positor) OR
            UPDATE(Positor) OR
            d.SU_ERS_Subject_Erasable is null OR
            d.SU_ERS_Subject_Erasable <> i.SU_ERS_Subject_Erasable OR
            d.SU_ERS_Reliability <> ISNULL(CASE
                WHEN UPDATE(SU_ERS_Reliability) THEN i.SU_ERS_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.SU_ERS_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(SU_ERS_Subject_Erasable) 
    )
    BEGIN
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ERS)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ERS
            END, i.Metadata_SU),
            p.SU_ERS_SU_ID,
            p.SU_ERS_Subject_Erasable,
            p.SU_ERS_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(SU_ERS_PositedAt) THEN i.SU_ERS_PositedAt
                WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(SU_ERS_Positor) THEN i.SU_ERS_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_ID = i.SU_ERS_ID
        WHERE
            i.SU_ERS_Subject_Erasable is null
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_Subject] ON [dbo].[lSU_Subject]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_NAM_Subject_Name_Annex] (
        Metadata_SU_NAM,
        SU_NAM_ID,
        SU_NAM_Positor,
        SU_NAM_PositedAt,
        SU_NAM_Reliability
    )
    SELECT
        d.Metadata_SU_NAM,
        d.SU_NAM_ID,
        d.SU_NAM_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_NAM_ID is not null;
    INSERT INTO [dbo].[SU_COD_Subject_Code_Annex] (
        Metadata_SU_COD,
        SU_COD_ID,
        SU_COD_Positor,
        SU_COD_PositedAt,
        SU_COD_Reliability
    )
    SELECT
        d.Metadata_SU_COD,
        d.SU_COD_ID,
        d.SU_COD_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_COD_ID is not null;
    INSERT INTO [dbo].[SU_GRD_Subject_Grade_Annex] (
        Metadata_SU_GRD,
        SU_GRD_ID,
        SU_GRD_Positor,
        SU_GRD_PositedAt,
        SU_GRD_Reliability
    )
    SELECT
        d.Metadata_SU_GRD,
        d.SU_GRD_ID,
        d.SU_GRD_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_GRD_ID is not null;
    INSERT INTO [dbo].[SU_NOT_Subject_Note_Annex] (
        Metadata_SU_NOT,
        SU_NOT_ID,
        SU_NOT_Positor,
        SU_NOT_PositedAt,
        SU_NOT_Reliability
    )
    SELECT
        d.Metadata_SU_NOT,
        d.SU_NOT_ID,
        d.SU_NOT_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_NOT_ID is not null;
    INSERT INTO [dbo].[SU_TTL_Subject_Title_Annex] (
        Metadata_SU_TTL,
        SU_TTL_ID,
        SU_TTL_Positor,
        SU_TTL_PositedAt,
        SU_TTL_Reliability
    )
    SELECT
        d.Metadata_SU_TTL,
        d.SU_TTL_ID,
        d.SU_TTL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_TTL_ID is not null;
    INSERT INTO [dbo].[SU_STA_Subject_State_Annex] (
        Metadata_SU_STA,
        SU_STA_ID,
        SU_STA_Positor,
        SU_STA_PositedAt,
        SU_STA_Reliability
    )
    SELECT
        d.Metadata_SU_STA,
        d.SU_STA_ID,
        d.SU_STA_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_STA_ID is not null;
    INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
        Metadata_SU_LBL,
        SU_LBL_ID,
        SU_LBL_Positor,
        SU_LBL_PositedAt,
        SU_LBL_Reliability
    )
    SELECT
        d.Metadata_SU_LBL,
        d.SU_LBL_ID,
        d.SU_LBL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_LBL_ID is not null;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
        Metadata_SU_TAG,
        SU_TAG_ID,
        SU_TAG_Positor,
        SU_TAG_PositedAt,
        SU_TAG_Reliability
    )
    SELECT
        d.Metadata_SU_TAG,
        d.SU_TAG_ID,
        d.SU_TAG_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_TAG_ID is not null;
    INSERT INTO [dbo].[SU_LVL_Subject_Level_Annex] (
        Metadata_SU_LVL,
        SU_LVL_ID,
        SU_LVL_Positor,
        SU_LVL_PositedAt,
        SU_LVL_Reliability
    )
    SELECT
        d.Metadata_SU_LVL,
        d.SU_LVL_ID,
        d.SU_LVL_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_LVL_ID is not null;
    INSERT INTO [dbo].[SU_TXT_Subject_Text_Annex] (
        Metadata_SU_TXT,
        SU_TXT_ID,
        SU_TXT_Positor,
        SU_TXT_PositedAt,
        SU_TXT_Reliability
    )
    SELECT
        d.Metadata_SU_TXT,
        d.SU_TXT_ID,
        d.SU_TXT_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_TXT_ID is not null;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Annex] (
        Metadata_SU_ASR,
        SU_ASR_ID,
        SU_ASR_Positor,
        SU_ASR_PositedAt,
        SU_ASR_Reliability
    )
    SELECT
        d.Metadata_SU_ASR,
        d.SU_ASR_ID,
        d.SU_ASR_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_ASR_ID is not null;
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Annex] (
        Metadata_SU_ERS,
        SU_ERS_ID,
        SU_ERS_Positor,
        SU_ERS_PositedAt,
        SU_ERS_Reliability
    )
    SELECT
        d.Metadata_SU_ERS,
        d.SU_ERS_ID,
        d.SU_ERS_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.SU_ERS_ID is not null;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_Object instead of INSERT trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lOB_Object] ON [dbo].[lOB_Object]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @OB TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        OB_ID int not null
    );
    INSERT INTO [dbo].[OB_Object] (
        Metadata_OB 
    )
    OUTPUT
        inserted.OB_ID
    INTO
        @OB
    SELECT
        Metadata_OB 
    FROM
        inserted
    WHERE
        inserted.OB_ID is null;
    DECLARE @inserted TABLE (
        OB_ID int not null,
        Metadata_OB int not null,
        OB_NAM_OB_ID int null,
        Metadata_OB_NAM int null,
        OB_NAM_Positor tinyint null,
        OB_NAM_PositedAt datetime2 null,
        OB_NAM_Reliability decimal(5,2) null,
        OB_NAM_Object_Name nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.OB_ID, a.OB_ID),
        i.Metadata_OB,
        ISNULL(ISNULL(i.OB_NAM_OB_ID, i.OB_ID), a.OB_ID),
        ISNULL(i.Metadata_OB_NAM, i.Metadata_OB),
        ISNULL(ISNULL(i.OB_NAM_Positor, i.Positor), 0),
        ISNULL(i.OB_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.OB_NAM_Reliability, i.Reliability), 1),
        i.OB_NAM_Object_Name
    FROM (
        SELECT
            Positor,
            Reliability,
            OB_ID,
            Metadata_OB,
            OB_NAM_OB_ID,
            Metadata_OB_NAM,
            OB_NAM_Positor,
            OB_NAM_PositedAt,
            OB_NAM_Reliability,
            OB_NAM_Object_Name,
            ROW_NUMBER() OVER (PARTITION BY OB_ID ORDER BY OB_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @OB a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[OB_NAM_Object_Name] (
        Metadata_OB_NAM,
        OB_NAM_OB_ID,
        OB_NAM_Object_Name,
        OB_NAM_PositedAt,
        OB_NAM_Positor,
        OB_NAM_Reliability
    )
    SELECT
        i.Metadata_OB_NAM,
        i.OB_NAM_OB_ID,
        i.OB_NAM_Object_Name,
        i.OB_NAM_PositedAt,
        i.OB_NAM_Positor,
        i.OB_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.OB_NAM_Object_Name is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_Object instead of UPDATE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lOB_Object] ON [dbo].[lOB_Object]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(OB_ID))
        RAISERROR('The identity column OB_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_ID))
        RAISERROR('The identity column OB_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_OB_ID))
        RAISERROR('The foreign key column OB_NAM_OB_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_Assertion))
        RAISERROR('The computed assertion column OB_NAM_Assertion is not updatable.', 16, 1);
    IF (
        UPDATE(OB_NAM_Object_Name) OR
        UPDATE(OB_NAM_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[OB_NAM_Object_Name] (
            Metadata_OB_NAM,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name,
            OB_NAM_PositedAt,
            OB_NAM_Positor,
            OB_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_OB) AND NOT UPDATE(Metadata_OB_NAM)
                THEN i.Metadata_OB
                ELSE i.Metadata_OB_NAM
            END, i.Metadata_OB),
            ISNULL(i.OB_NAM_OB_ID, i.OB_ID),
            i.OB_NAM_Object_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(OB_NAM_PositedAt) THEN i.OB_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(OB_NAM_Positor) THEN i.OB_NAM_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN UPDATE(OB_NAM_Reliability) THEN i.OB_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.OB_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.OB_ID = i.OB_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.OB_NAM_Object_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            UPDATE(OB_NAM_PositedAt) OR
            UPDATE(OB_NAM_Positor) OR
            UPDATE(Positor) OR
            d.OB_NAM_Object_Name is null OR
            d.OB_NAM_Object_Name <> i.OB_NAM_Object_Name OR
            d.OB_NAM_Reliability <> ISNULL(CASE
                WHEN UPDATE(OB_NAM_Reliability) THEN i.OB_NAM_Reliability
                WHEN UPDATE(Reliability) THEN i.Reliability
                ELSE i.OB_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(OB_NAM_Object_Name) 
    )
    BEGIN
        INSERT INTO [dbo].[OB_NAM_Object_Name] (
            Metadata_OB_NAM,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name,
            OB_NAM_PositedAt,
            OB_NAM_Positor,
            OB_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN UPDATE(Metadata_OB) AND NOT UPDATE(Metadata_OB_NAM)
                THEN i.Metadata_OB
                ELSE i.Metadata_OB_NAM
            END, i.Metadata_OB),
            p.OB_NAM_OB_ID,
            p.OB_NAM_Object_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(OB_NAM_PositedAt) THEN i.OB_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(OB_NAM_Positor) THEN i.OB_NAM_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_ID = i.OB_NAM_ID
        WHERE
            i.OB_NAM_Object_Name is null
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_Object instead of DELETE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lOB_Object] ON [dbo].[lOB_Object]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[OB_NAM_Object_Name_Annex] (
        Metadata_OB_NAM,
        OB_NAM_ID,
        OB_NAM_Positor,
        OB_NAM_PositedAt,
        OB_NAM_Reliability
    )
    SELECT
        d.Metadata_OB_NAM,
        d.OB_NAM_ID,
        d.OB_NAM_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.OB_NAM_ID is not null;
END
GO
