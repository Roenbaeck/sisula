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
        SU_NAM_Subject_Name nvarchar(42) null,
        SU_COD_SU_ID int null,
        Metadata_SU_COD int null,
        SU_COD_Subject_Code nvarchar(42) null,
        SU_GRD_SU_ID int null,
        Metadata_SU_GRD int null,
        SU_GRD_GRD_Grade nvarchar(42) null,
        SU_GRD_Metadata_GRD int null,
        SU_GRD_GRD_ID tinyint null,
        SU_NOT_SU_ID int null,
        Metadata_SU_NOT int null,
        SU_NOT_Subject_Note nvarchar(max) null,
        SU_TTL_SU_ID int null,
        Metadata_SU_TTL int null,
        SU_TTL_ChangedAt datetime2 null,
        SU_TTL_Subject_Title nvarchar(42) null,
        SU_STA_SU_ID int null,
        Metadata_SU_STA int null,
        SU_STA_ChangedAt datetime2 null,
        SU_STA_Subject_State nvarchar(42) null,
        SU_LBL_SU_ID int null,
        Metadata_SU_LBL int null,
        SU_LBL_ChangedAt datetime2 null,
        SU_LBL_Subject_Label nvarchar(42) null,
        SU_TAG_SU_ID int null,
        Metadata_SU_TAG int null,
        SU_TAG_ChangedAt datetime2 null,
        SU_TAG_Subject_Tag nvarchar(42) null,
        SU_LVL_SU_ID int null,
        Metadata_SU_LVL int null,
        SU_LVL_ChangedAt datetime2 null,
        SU_LVL_GRD_Grade nvarchar(42) null,
        SU_LVL_Metadata_GRD int null,
        SU_LVL_GRD_ID tinyint null,
        SU_TXT_SU_ID int null,
        Metadata_SU_TXT int null,
        SU_TXT_ChangedAt datetime2 null,
        SU_TXT_Subject_Text nvarchar(max) null,
        SU_ASR_SU_ID int null,
        Metadata_SU_ASR int null,
        SU_ASR_ChangedAt datetime2 null,
        SU_ASR_Subject_Assessment nvarchar(42) null,
        SU_ERS_SU_ID int null,
        Metadata_SU_ERS int null,
        SU_ERS_ChangedAt datetime2 null,
        SU_ERS_Subject_Erasable nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.SU_ID, a.SU_ID),
        i.Metadata_SU,
        ISNULL(ISNULL(i.SU_NAM_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NAM, i.Metadata_SU),
        i.SU_NAM_Subject_Name,
        ISNULL(ISNULL(i.SU_COD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_COD, i.Metadata_SU),
        i.SU_COD_Subject_Code,
        ISNULL(ISNULL(i.SU_GRD_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_GRD, i.Metadata_SU),
        i.SU_GRD_GRD_Grade,
        ISNULL(i.SU_GRD_Metadata_GRD, i.Metadata_SU),
        i.SU_GRD_GRD_ID,
        ISNULL(ISNULL(i.SU_NOT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_NOT, i.Metadata_SU),
        i.SU_NOT_Subject_Note,
        ISNULL(ISNULL(i.SU_TTL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TTL, i.Metadata_SU),
        ISNULL(i.SU_TTL_ChangedAt, @now),
        i.SU_TTL_Subject_Title,
        ISNULL(ISNULL(i.SU_STA_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_STA, i.Metadata_SU),
        ISNULL(i.SU_STA_ChangedAt, @now),
        i.SU_STA_Subject_State,
        ISNULL(ISNULL(i.SU_LBL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LBL, i.Metadata_SU),
        ISNULL(i.SU_LBL_ChangedAt, @now),
        i.SU_LBL_Subject_Label,
        ISNULL(ISNULL(i.SU_TAG_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TAG, i.Metadata_SU),
        ISNULL(i.SU_TAG_ChangedAt, @now),
        i.SU_TAG_Subject_Tag,
        ISNULL(ISNULL(i.SU_LVL_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_LVL, i.Metadata_SU),
        ISNULL(i.SU_LVL_ChangedAt, @now),
        i.SU_LVL_GRD_Grade,
        ISNULL(i.SU_LVL_Metadata_GRD, i.Metadata_SU),
        i.SU_LVL_GRD_ID,
        ISNULL(ISNULL(i.SU_TXT_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_TXT, i.Metadata_SU),
        ISNULL(i.SU_TXT_ChangedAt, @now),
        i.SU_TXT_Subject_Text,
        ISNULL(ISNULL(i.SU_ASR_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ASR, i.Metadata_SU),
        ISNULL(i.SU_ASR_ChangedAt, @now),
        i.SU_ASR_Subject_Assessment,
        ISNULL(ISNULL(i.SU_ERS_SU_ID, i.SU_ID), a.SU_ID),
        ISNULL(i.Metadata_SU_ERS, i.Metadata_SU),
        ISNULL(i.SU_ERS_ChangedAt, @now),
        i.SU_ERS_Subject_Erasable
    FROM (
        SELECT
            SU_ID,
            Metadata_SU,
            SU_NAM_SU_ID,
            Metadata_SU_NAM,
            SU_NAM_Subject_Name,
            SU_COD_SU_ID,
            Metadata_SU_COD,
            SU_COD_Subject_Code,
            SU_GRD_SU_ID,
            Metadata_SU_GRD,
            SU_GRD_GRD_Grade,
            SU_GRD_Metadata_GRD,
            SU_GRD_GRD_ID,
            SU_NOT_SU_ID,
            Metadata_SU_NOT,
            SU_NOT_Subject_Note,
            SU_TTL_SU_ID,
            Metadata_SU_TTL,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title,
            SU_STA_SU_ID,
            Metadata_SU_STA,
            SU_STA_ChangedAt,
            SU_STA_Subject_State,
            SU_LBL_SU_ID,
            Metadata_SU_LBL,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label,
            SU_TAG_SU_ID,
            Metadata_SU_TAG,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag,
            SU_LVL_SU_ID,
            Metadata_SU_LVL,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_Grade,
            SU_LVL_Metadata_GRD,
            SU_LVL_GRD_ID,
            SU_TXT_SU_ID,
            Metadata_SU_TXT,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text,
            SU_ASR_SU_ID,
            Metadata_SU_ASR,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment,
            SU_ERS_SU_ID,
            Metadata_SU_ERS,
            SU_ERS_ChangedAt,
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
        SU_NAM_Subject_Name
    )
    SELECT DISTINCT
        i.Metadata_SU_NAM,
        i.SU_NAM_SU_ID,
        i.SU_NAM_Subject_Name
    FROM
        @inserted i
    WHERE
        i.SU_NAM_Subject_Name is not null;
    INSERT INTO [dbo].[SU_COD_Subject_Code] (
        Metadata_SU_COD,
        SU_COD_SU_ID,
        SU_COD_Subject_Code
    )
    SELECT DISTINCT
        i.Metadata_SU_COD,
        i.SU_COD_SU_ID,
        i.SU_COD_Subject_Code
    FROM
        @inserted i
    WHERE
        i.SU_COD_Subject_Code is not null;
    INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
        Metadata_SU_GRD,
        SU_GRD_SU_ID,
        SU_GRD_GRD_ID
    )
    SELECT DISTINCT
        i.Metadata_SU_GRD,
        i.SU_GRD_SU_ID,
        ISNULL(i.SU_GRD_GRD_ID, [kGRD].GRD_ID)
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
        SU_NOT_Subject_Note
    )
    SELECT 
        i.Metadata_SU_NOT,
        i.SU_NOT_SU_ID,
        i.SU_NOT_Subject_Note
    FROM
        @inserted i
    WHERE
        i.SU_NOT_Subject_Note is not null;
    INSERT INTO [dbo].[SU_TTL_Subject_Title] (
        Metadata_SU_TTL,
        SU_TTL_SU_ID,
        SU_TTL_ChangedAt,
        SU_TTL_Subject_Title
    )
    SELECT DISTINCT
        i.Metadata_SU_TTL,
        i.SU_TTL_SU_ID,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_Subject_Title
    FROM
        @inserted i
    WHERE
        i.SU_TTL_Subject_Title is not null;
    INSERT INTO [dbo].[SU_STA_Subject_State] (
        Metadata_SU_STA,
        SU_STA_SU_ID,
        SU_STA_ChangedAt,
        SU_STA_Subject_State
    )
    SELECT DISTINCT
        i.Metadata_SU_STA,
        i.SU_STA_SU_ID,
        i.SU_STA_ChangedAt,
        i.SU_STA_Subject_State
    FROM
        @inserted i
    WHERE
        i.SU_STA_Subject_State is not null;
    INSERT INTO [dbo].[SU_LBL_Subject_Label] (
        Metadata_SU_LBL,
        SU_LBL_SU_ID,
        SU_LBL_ChangedAt,
        SU_LBL_Subject_Label
    )
    SELECT DISTINCT
        i.Metadata_SU_LBL,
        i.SU_LBL_SU_ID,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_Subject_Label
    FROM
        @inserted i
    WHERE
        i.SU_LBL_Subject_Label is not null;
    INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
        Metadata_SU_TAG,
        SU_TAG_SU_ID,
        SU_TAG_ChangedAt,
        SU_TAG_Subject_Tag
    )
    SELECT DISTINCT
        i.Metadata_SU_TAG,
        i.SU_TAG_SU_ID,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_Subject_Tag
    FROM
        @inserted i
    WHERE
        i.SU_TAG_Subject_Tag is not null;
    INSERT INTO [dbo].[SU_LVL_Subject_Level] (
        Metadata_SU_LVL,
        SU_LVL_SU_ID,
        SU_LVL_ChangedAt,
        SU_LVL_GRD_ID
    )
    SELECT DISTINCT
        i.Metadata_SU_LVL,
        i.SU_LVL_SU_ID,
        i.SU_LVL_ChangedAt,
        ISNULL(i.SU_LVL_GRD_ID, [kGRD].GRD_ID)
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
        SU_TXT_ChangedAt,
        SU_TXT_Subject_Text
    )
    SELECT 
        i.Metadata_SU_TXT,
        i.SU_TXT_SU_ID,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_Subject_Text
    FROM
        @inserted i
    WHERE
        i.SU_TXT_Subject_Text is not null;
    INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
        Metadata_SU_ASR,
        SU_ASR_SU_ID,
        SU_ASR_ChangedAt,
        SU_ASR_Subject_Assessment
    )
    SELECT DISTINCT
        i.Metadata_SU_ASR,
        i.SU_ASR_SU_ID,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_Subject_Assessment
    FROM
        @inserted i
    WHERE
        i.SU_ASR_Subject_Assessment is not null;
    INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
        Metadata_SU_ERS,
        SU_ERS_SU_ID,
        SU_ERS_ChangedAt,
        SU_ERS_Subject_Erasable
    )
    SELECT DISTINCT
        i.Metadata_SU_ERS,
        i.SU_ERS_SU_ID,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_Subject_Erasable
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
    IF(UPDATE(SU_NAM_SU_ID))
        RAISERROR('The foreign key column SU_NAM_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NAM_Subject_Name))
    BEGIN
        INSERT INTO [dbo].[SU_NAM_Subject_Name] (
            Metadata_SU_NAM,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NAM)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NAM
            END, i.Metadata_SU),
            ISNULL(i.SU_NAM_SU_ID, i.SU_ID),
            i.SU_NAM_Subject_Name
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_NAM_Subject_Name is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_NAM_Subject_Name is null OR
            d.SU_NAM_Subject_Name <> i.SU_NAM_Subject_Name
        );
    END
    IF(UPDATE(SU_COD_SU_ID))
        RAISERROR('The foreign key column SU_COD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_COD_Subject_Code))
    BEGIN
        INSERT INTO [dbo].[SU_COD_Subject_Code] (
            Metadata_SU_COD,
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_COD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_COD
            END, i.Metadata_SU),
            ISNULL(i.SU_COD_SU_ID, i.SU_ID),
            i.SU_COD_Subject_Code
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_COD_Subject_Code is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_COD_Subject_Code is null OR
            d.SU_COD_Subject_Code <> i.SU_COD_Subject_Code
        );
    END
    IF(UPDATE(SU_GRD_SU_ID))
        RAISERROR('The foreign key column SU_GRD_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_GRD_GRD_ID) OR UPDATE(SU_GRD_GRD_Grade))
    BEGIN
        INSERT INTO [dbo].[SU_GRD_Subject_Grade] (
            Metadata_SU_GRD,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_GRD)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_GRD
            END, i.Metadata_SU),
            ISNULL(i.SU_GRD_SU_ID, i.SU_ID),
            CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END
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
        WHERE
            CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_GRD_GRD_ID is null OR
            d.SU_GRD_GRD_ID <> CASE WHEN UPDATE(SU_GRD_GRD_ID) THEN i.SU_GRD_GRD_ID ELSE [kGRD].GRD_ID END
        );
    END
    IF(UPDATE(SU_NOT_SU_ID))
        RAISERROR('The foreign key column SU_NOT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_NOT_Subject_Note))
    BEGIN
        INSERT INTO [dbo].[SU_NOT_Subject_Note] (
            Metadata_SU_NOT,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        )
        SELECT 
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_NOT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_NOT
            END, i.Metadata_SU),
            ISNULL(i.SU_NOT_SU_ID, i.SU_ID),
            i.SU_NOT_Subject_Note
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_NOT_Subject_Note is not null
        AND ( -- a value that is left as it is states nothing
            d.SU_NOT_Subject_Note is null OR
            d.SU_NOT_Checksum <> dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
        );
    END
    IF(UPDATE(SU_TTL_SU_ID))
        RAISERROR('The foreign key column SU_TTL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TTL_Subject_Title))
    BEGIN
        INSERT INTO [dbo].[SU_TTL_Subject_Title] (
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TTL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TTL
            END, i.Metadata_SU),
            ISNULL(i.SU_TTL_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_TTL_Subject_Title is null THEN i.SU_TTL_ChangedAt
                WHEN UPDATE(SU_TTL_ChangedAt) THEN i.SU_TTL_ChangedAt
            END, @now) as datetime2),
            i.SU_TTL_Subject_Title
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_TTL_Subject_Title is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_TTL_ChangedAt) OR
            d.SU_TTL_Subject_Title is null OR
            d.SU_TTL_Subject_Title <> i.SU_TTL_Subject_Title
        );
    END
    IF(UPDATE(SU_STA_SU_ID))
        RAISERROR('The foreign key column SU_STA_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_STA_Subject_State))
    BEGIN
        INSERT INTO [dbo].[SU_STA_Subject_State] (
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_ChangedAt,
            SU_STA_Subject_State
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_STA)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_STA
            END, i.Metadata_SU),
            ISNULL(i.SU_STA_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_STA_Subject_State is null THEN i.SU_STA_ChangedAt
                WHEN UPDATE(SU_STA_ChangedAt) THEN i.SU_STA_ChangedAt
            END, @now) as datetime2),
            i.SU_STA_Subject_State
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_STA_Subject_State is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_STA_ChangedAt) OR
            d.SU_STA_Subject_State is null OR
            d.SU_STA_Subject_State <> i.SU_STA_Subject_State
        );
    END
    IF(UPDATE(SU_LBL_SU_ID))
        RAISERROR('The foreign key column SU_LBL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LBL_Subject_Label))
    BEGIN
        INSERT INTO [dbo].[SU_LBL_Subject_Label] (
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LBL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LBL
            END, i.Metadata_SU),
            ISNULL(i.SU_LBL_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_LBL_Subject_Label is null THEN i.SU_LBL_ChangedAt
                WHEN UPDATE(SU_LBL_ChangedAt) THEN i.SU_LBL_ChangedAt
            END, @now) as datetime2),
            i.SU_LBL_Subject_Label
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_LBL_Subject_Label is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_LBL_ChangedAt) OR
            d.SU_LBL_Subject_Label is null OR
            d.SU_LBL_Subject_Label <> i.SU_LBL_Subject_Label
        );
    END
    IF(UPDATE(SU_TAG_SU_ID))
        RAISERROR('The foreign key column SU_TAG_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TAG_Subject_Tag))
    BEGIN
        INSERT INTO [dbo].[SU_TAG_Subject_Tag] (
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TAG)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TAG
            END, i.Metadata_SU),
            ISNULL(i.SU_TAG_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_TAG_Subject_Tag is null THEN i.SU_TAG_ChangedAt
                WHEN UPDATE(SU_TAG_ChangedAt) THEN i.SU_TAG_ChangedAt
            END, @now) as datetime2),
            i.SU_TAG_Subject_Tag
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_TAG_Subject_Tag is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_TAG_ChangedAt) OR
            d.SU_TAG_Subject_Tag is null OR
            d.SU_TAG_Subject_Tag <> i.SU_TAG_Subject_Tag
        );
    END
    IF(UPDATE(SU_LVL_SU_ID))
        RAISERROR('The foreign key column SU_LVL_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_LVL_GRD_ID) OR UPDATE(SU_LVL_GRD_Grade))
    BEGIN
        INSERT INTO [dbo].[SU_LVL_Subject_Level] (
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_LVL)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_LVL
            END, i.Metadata_SU),
            ISNULL(i.SU_LVL_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_LVL_GRD_ID is null AND [kGRD].GRD_ID is null THEN i.SU_LVL_ChangedAt
                WHEN UPDATE(SU_LVL_ChangedAt) THEN i.SU_LVL_ChangedAt
            END, @now) as datetime2),
            CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END
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
        WHERE
            CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_LVL_ChangedAt) OR
            d.SU_LVL_GRD_ID is null OR
            d.SU_LVL_GRD_ID <> CASE WHEN UPDATE(SU_LVL_GRD_ID) THEN i.SU_LVL_GRD_ID ELSE [kGRD].GRD_ID END
        );
    END
    IF(UPDATE(SU_TXT_SU_ID))
        RAISERROR('The foreign key column SU_TXT_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_TXT_Subject_Text))
    BEGIN
        INSERT INTO [dbo].[SU_TXT_Subject_Text] (
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text
        )
        SELECT 
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_TXT)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_TXT
            END, i.Metadata_SU),
            ISNULL(i.SU_TXT_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_TXT_Subject_Text is null THEN i.SU_TXT_ChangedAt
                WHEN UPDATE(SU_TXT_ChangedAt) THEN i.SU_TXT_ChangedAt
            END, @now) as datetime2),
            i.SU_TXT_Subject_Text
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_TXT_Subject_Text is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_TXT_ChangedAt) OR
            d.SU_TXT_Subject_Text is null OR
            d.SU_TXT_Checksum <> dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
        );
    END
    IF(UPDATE(SU_ASR_SU_ID))
        RAISERROR('The foreign key column SU_ASR_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ASR_Subject_Assessment))
    BEGIN
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment] (
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ASR)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ASR
            END, i.Metadata_SU),
            ISNULL(i.SU_ASR_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_ASR_Subject_Assessment is null THEN i.SU_ASR_ChangedAt
                WHEN UPDATE(SU_ASR_ChangedAt) THEN i.SU_ASR_ChangedAt
            END, @now) as datetime2),
            i.SU_ASR_Subject_Assessment
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_ASR_Subject_Assessment is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_ASR_ChangedAt) OR
            d.SU_ASR_Subject_Assessment is null OR
            d.SU_ASR_Subject_Assessment <> i.SU_ASR_Subject_Assessment
        );
    END
    IF(UPDATE(SU_ERS_SU_ID))
        RAISERROR('The foreign key column SU_ERS_SU_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ERS_Subject_Erasable))
    BEGIN
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable] (
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_ChangedAt,
            SU_ERS_Subject_Erasable
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_SU) AND NOT UPDATE(Metadata_SU_ERS)
                THEN i.Metadata_SU
                ELSE i.Metadata_SU_ERS
            END, i.Metadata_SU),
            ISNULL(i.SU_ERS_SU_ID, i.SU_ID),
            cast(ISNULL(CASE
                WHEN i.SU_ERS_Subject_Erasable is null THEN i.SU_ERS_ChangedAt
                WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt
            END, @now) as datetime2),
            i.SU_ERS_Subject_Erasable
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.SU_ID = i.SU_ID
        WHERE
            i.SU_ERS_Subject_Erasable is not null
        AND ( -- a value that is left as it is states nothing
            UPDATE(SU_ERS_ChangedAt) OR
            d.SU_ERS_Subject_Erasable is null OR
            d.SU_ERS_Subject_Erasable <> i.SU_ERS_Subject_Erasable
        );
        SELECT
            cast(CASE WHEN UPDATE(SU_ERS_ChangedAt) THEN i.SU_ERS_ChangedAt ELSE @now END as datetime2) as SU_ERS_Deleted,
            i.SU_ERS_SU_ID
        INTO
            #SU_ERS
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            d.SU_ERS_Subject_Erasable is not null
        WHERE
            i.SU_ERS_Subject_Erasable is null
        AND
            i.Deletable_SU_ERS = 1;
        IF(@@ROWCOUNT > 0)
        BEGIN
            IF OBJECT_ID('[dbo].[SU_ERS_Subject_Erasable_Deleted]') is null
            SELECT TOP 0
                *,
                CAST(null as datetime2) as SU_ERS_Deleted
            INTO
                [dbo].[SU_ERS_Subject_Erasable_Deleted]
            FROM
                [dbo].[SU_ERS_Subject_Erasable];
            DELETE [ERS]
            OUTPUT
                deleted.*,
                ISNULL(d.SU_ERS_Deleted, @now)
            INTO
                [dbo].[SU_ERS_Subject_Erasable_Deleted]
            FROM
                [dbo].[SU_ERS_Subject_Erasable] [ERS]
            JOIN
                #SU_ERS d
            ON
                d.SU_ERS_SU_ID = [ERS].SU_ERS_SU_ID
        END
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
    DELETE [NAM]
    FROM
        [dbo].[SU_NAM_Subject_Name] [NAM]
    JOIN
        deleted d
    ON
        d.SU_NAM_SU_ID = [NAM].SU_NAM_SU_ID;
    DELETE [COD]
    FROM
        [dbo].[SU_COD_Subject_Code] [COD]
    JOIN
        deleted d
    ON
        d.SU_COD_SU_ID = [COD].SU_COD_SU_ID;
    DELETE [GRD]
    FROM
        [dbo].[SU_GRD_Subject_Grade] [GRD]
    JOIN
        deleted d
    ON
        d.SU_GRD_SU_ID = [GRD].SU_GRD_SU_ID;
    DELETE [NOT]
    FROM
        [dbo].[SU_NOT_Subject_Note] [NOT]
    JOIN
        deleted d
    ON
        d.SU_NOT_SU_ID = [NOT].SU_NOT_SU_ID;
    DELETE [TTL]
    FROM
        [dbo].[SU_TTL_Subject_Title] [TTL]
    JOIN
        deleted d
    ON
        d.SU_TTL_ChangedAt = [TTL].SU_TTL_ChangedAt
    AND
        d.SU_TTL_SU_ID = [TTL].SU_TTL_SU_ID;
    DELETE [STA]
    FROM
        [dbo].[SU_STA_Subject_State] [STA]
    JOIN
        deleted d
    ON
        d.SU_STA_ChangedAt = [STA].SU_STA_ChangedAt
    AND
        d.SU_STA_SU_ID = [STA].SU_STA_SU_ID;
    DELETE [LBL]
    FROM
        [dbo].[SU_LBL_Subject_Label] [LBL]
    JOIN
        deleted d
    ON
        d.SU_LBL_ChangedAt = [LBL].SU_LBL_ChangedAt
    AND
        d.SU_LBL_SU_ID = [LBL].SU_LBL_SU_ID;
    DELETE [TAG]
    FROM
        [dbo].[SU_TAG_Subject_Tag] [TAG]
    JOIN
        deleted d
    ON
        d.SU_TAG_ChangedAt = [TAG].SU_TAG_ChangedAt
    AND
        d.SU_TAG_SU_ID = [TAG].SU_TAG_SU_ID;
    DELETE [LVL]
    FROM
        [dbo].[SU_LVL_Subject_Level] [LVL]
    JOIN
        deleted d
    ON
        d.SU_LVL_ChangedAt = [LVL].SU_LVL_ChangedAt
    AND
        d.SU_LVL_SU_ID = [LVL].SU_LVL_SU_ID;
    DELETE [TXT]
    FROM
        [dbo].[SU_TXT_Subject_Text] [TXT]
    JOIN
        deleted d
    ON
        d.SU_TXT_ChangedAt = [TXT].SU_TXT_ChangedAt
    AND
        d.SU_TXT_SU_ID = [TXT].SU_TXT_SU_ID;
    DELETE [ASR]
    FROM
        [dbo].[SU_ASR_Subject_Assessment] [ASR]
    JOIN
        deleted d
    ON
        d.SU_ASR_ChangedAt = [ASR].SU_ASR_ChangedAt
    AND
        d.SU_ASR_SU_ID = [ASR].SU_ASR_SU_ID;
    DELETE [ERS]
    FROM
        [dbo].[SU_ERS_Subject_Erasable] [ERS]
    JOIN
        deleted d
    ON
        d.SU_ERS_ChangedAt = [ERS].SU_ERS_ChangedAt
    AND
        d.SU_ERS_SU_ID = [ERS].SU_ERS_SU_ID;
    DECLARE @deleted TABLE (
        SU_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (SU_ID)
    SELECT a.SU_ID
    FROM (
        SELECT [SU].SU_ID
        FROM [dbo].[SU_Subject] [SU] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 SU_NAM_SU_ID
            FROM [dbo].[SU_NAM_Subject_Name] WITH(NOLOCK)
            WHERE SU_NAM_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_COD_SU_ID
            FROM [dbo].[SU_COD_Subject_Code] WITH(NOLOCK)
            WHERE SU_COD_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_GRD_SU_ID
            FROM [dbo].[SU_GRD_Subject_Grade] WITH(NOLOCK)
            WHERE SU_GRD_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_NOT_SU_ID
            FROM [dbo].[SU_NOT_Subject_Note] WITH(NOLOCK)
            WHERE SU_NOT_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_TTL_SU_ID
            FROM [dbo].[SU_TTL_Subject_Title] WITH(NOLOCK)
            WHERE SU_TTL_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_STA_SU_ID
            FROM [dbo].[SU_STA_Subject_State] WITH(NOLOCK)
            WHERE SU_STA_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_LBL_SU_ID
            FROM [dbo].[SU_LBL_Subject_Label] WITH(NOLOCK)
            WHERE SU_LBL_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_TAG_SU_ID
            FROM [dbo].[SU_TAG_Subject_Tag] WITH(NOLOCK)
            WHERE SU_TAG_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_LVL_SU_ID
            FROM [dbo].[SU_LVL_Subject_Level] WITH(NOLOCK)
            WHERE SU_LVL_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_TXT_SU_ID
            FROM [dbo].[SU_TXT_Subject_Text] WITH(NOLOCK)
            WHERE SU_TXT_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_ASR_SU_ID
            FROM [dbo].[SU_ASR_Subject_Assessment] WITH(NOLOCK)
            WHERE SU_ASR_SU_ID = [SU].SU_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 SU_ERS_SU_ID
            FROM [dbo].[SU_ERS_Subject_Erasable] WITH(NOLOCK)
            WHERE SU_ERS_SU_ID = [SU].SU_ID
        )
    ) a
    JOIN deleted d
    ON d.SU_ID = a.SU_ID;
    DELETE [SU]
    FROM [dbo].[SU_Subject] [SU]
    JOIN @deleted d
    ON d.SU_ID = [SU].SU_ID;
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
        OB_NAM_Object_Name nvarchar(42) null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.OB_ID, a.OB_ID),
        i.Metadata_OB,
        ISNULL(ISNULL(i.OB_NAM_OB_ID, i.OB_ID), a.OB_ID),
        ISNULL(i.Metadata_OB_NAM, i.Metadata_OB),
        i.OB_NAM_Object_Name
    FROM (
        SELECT
            OB_ID,
            Metadata_OB,
            OB_NAM_OB_ID,
            Metadata_OB_NAM,
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
        OB_NAM_Object_Name
    )
    SELECT DISTINCT
        i.Metadata_OB_NAM,
        i.OB_NAM_OB_ID,
        i.OB_NAM_Object_Name
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
    IF(UPDATE(OB_NAM_OB_ID))
        RAISERROR('The foreign key column OB_NAM_OB_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_NAM_Object_Name))
    BEGIN
        INSERT INTO [dbo].[OB_NAM_Object_Name] (
            Metadata_OB_NAM,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN UPDATE(Metadata_OB) AND NOT UPDATE(Metadata_OB_NAM)
                THEN i.Metadata_OB
                ELSE i.Metadata_OB_NAM
            END, i.Metadata_OB),
            ISNULL(i.OB_NAM_OB_ID, i.OB_ID),
            i.OB_NAM_Object_Name
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.OB_ID = i.OB_ID
        WHERE
            i.OB_NAM_Object_Name is not null
        AND ( -- a value that is left as it is states nothing
            d.OB_NAM_Object_Name is null OR
            d.OB_NAM_Object_Name <> i.OB_NAM_Object_Name
        );
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
    DELETE [NAM]
    FROM
        [dbo].[OB_NAM_Object_Name] [NAM]
    JOIN
        deleted d
    ON
        d.OB_NAM_OB_ID = [NAM].OB_NAM_OB_ID;
    DECLARE @deleted TABLE (
        OB_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (OB_ID)
    SELECT a.OB_ID
    FROM (
        SELECT [OB].OB_ID
        FROM [dbo].[OB_Object] [OB] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 OB_NAM_OB_ID
            FROM [dbo].[OB_NAM_Object_Name] WITH(NOLOCK)
            WHERE OB_NAM_OB_ID = [OB].OB_ID
        )
    ) a
    JOIN deleted d
    ON d.OB_ID = a.OB_ID;
    DELETE [OB]
    FROM [dbo].[OB_Object] [OB]
    JOIN @deleted d
    ON d.OB_ID = [OB].OB_ID;
END
GO
