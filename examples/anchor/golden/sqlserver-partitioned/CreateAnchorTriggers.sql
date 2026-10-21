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
-- it_lST_Stage instead of INSERT trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[it_lST_Stage] ON [anchors].[lST_Stage]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @ST TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        ST_ID int not null
    );
    INSERT INTO [anchors].[ST_Stage] (
        Metadata_ST
    )
    OUTPUT
        inserted.ST_ID
    INTO
        @ST
    SELECT
        Metadata_ST
    FROM
        inserted
    WHERE
        inserted.ST_ID is null;
    DECLARE @inserted TABLE (
        ST_ID int not null,
        Metadata_ST int not null,
        ST_NAM_ST_ID int null,
        Metadata_ST_NAM int null,
        ST_NAM_ChangedAt datetime2 null,
        ST_NAM_EQ tinyint null,
        ST_NAM_Stage_Name nvarchar(42) null,
        ST_LOC_ST_ID int null,
        Metadata_ST_LOC int null,
        ST_LOC_EQ tinyint null,
        ST_LOC_Stage_Location geography null,
        ST_AVG_ST_ID int null,
        Metadata_ST_AVG int null,
        ST_AVG_ChangedAt datetime2 null,
        ST_AVG_UTL_Utilization tinyint null,
        ST_AVG_Metadata_UTL int null,
        ST_AVG_UTL_ID tinyint null,
        ST_MIN_ST_ID int null,
        Metadata_ST_MIN int null,
        ST_MIN_UTL_Utilization tinyint null,
        ST_MIN_Metadata_UTL int null,
        ST_MIN_UTL_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_ID, a.ST_ID),
        i.Metadata_ST,
        ISNULL(ISNULL(i.ST_NAM_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_NAM, i.Metadata_ST),
        ISNULL(i.ST_NAM_ChangedAt, @now),
        ISNULL(i.ST_NAM_EQ, 0),
        i.ST_NAM_Stage_Name,
        ISNULL(ISNULL(i.ST_LOC_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_LOC, i.Metadata_ST),
        ISNULL(i.ST_LOC_EQ, 0),
        i.ST_LOC_Stage_Location,
        ISNULL(ISNULL(i.ST_AVG_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_AVG, i.Metadata_ST),
        ISNULL(i.ST_AVG_ChangedAt, @now),
        i.ST_AVG_UTL_Utilization,
        ISNULL(i.ST_AVG_Metadata_UTL, i.Metadata_ST),
        i.ST_AVG_UTL_ID,
        ISNULL(ISNULL(i.ST_MIN_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_MIN, i.Metadata_ST),
        i.ST_MIN_UTL_Utilization,
        ISNULL(i.ST_MIN_Metadata_UTL, i.Metadata_ST),
        i.ST_MIN_UTL_ID
    FROM (
        SELECT
            ST_ID,
            Metadata_ST,
            ST_NAM_ST_ID,
            Metadata_ST_NAM,
            ST_NAM_ChangedAt,
            ST_NAM_EQ,
            ST_NAM_Stage_Name,
            ST_LOC_ST_ID,
            Metadata_ST_LOC,
            ST_LOC_EQ,
            ST_LOC_Stage_Location,
            ST_AVG_ST_ID,
            Metadata_ST_AVG,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_Utilization,
            ST_AVG_Metadata_UTL,
            ST_AVG_UTL_ID,
            ST_MIN_ST_ID,
            Metadata_ST_MIN,
            ST_MIN_UTL_Utilization,
            ST_MIN_Metadata_UTL,
            ST_MIN_UTL_ID,
            ROW_NUMBER() OVER (PARTITION BY ST_ID ORDER BY ST_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @ST a
    ON
        a.Row = i.Row;
    INSERT INTO [attributes].[ST_NAM_Stage_Name] (
        Metadata_ST_NAM,
        ST_NAM_ST_ID,
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT DISTINCT
        i.Metadata_ST_NAM,
        i.ST_NAM_ST_ID,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Stage_Name
    FROM
        @inserted i
    WHERE
        i.ST_NAM_Stage_Name is not null;
    INSERT INTO [attributes].[ST_LOC_Stage_Location] (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location
    )
    SELECT 
        i.Metadata_ST_LOC,
        i.ST_LOC_ST_ID,
        i.ST_LOC_Stage_Location
    FROM
        @inserted i
    WHERE
        i.ST_LOC_Stage_Location is not null;
    INSERT INTO [attributes].[ST_AVG_Stage_Average] (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_ChangedAt,
        ST_AVG_UTL_ID
    )
    SELECT DISTINCT
        i.Metadata_ST_AVG,
        i.ST_AVG_ST_ID,
        i.ST_AVG_ChangedAt,
        ISNULL(i.ST_AVG_UTL_ID, [kUTL].UTL_ID)
    FROM
        @inserted i
    LEFT JOIN
        [knots].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.ST_AVG_UTL_Utilization
    WHERE
        ISNULL(i.ST_AVG_UTL_ID, [kUTL].UTL_ID) is not null;
    INSERT INTO [attributes].[ST_MIN_Stage_Minimum] (
        Metadata_ST_MIN,
        ST_MIN_ST_ID,
        ST_MIN_UTL_ID
    )
    SELECT DISTINCT
        i.Metadata_ST_MIN,
        i.ST_MIN_ST_ID,
        ISNULL(i.ST_MIN_UTL_ID, [kUTL].UTL_ID)
    FROM
        @inserted i
    LEFT JOIN
        [knots].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.ST_MIN_UTL_Utilization
    WHERE
        ISNULL(i.ST_MIN_UTL_ID, [kUTL].UTL_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[ut_lST_Stage] ON [anchors].[lST_Stage]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_ST bit = CASE WHEN UPDATE(Metadata_ST) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_ID))
        RAISERROR('The identity column ST_ID is not updatable.', 16, 1);
    DECLARE @updated_ST_NAM_Stage_Name bit = CASE WHEN UPDATE(ST_NAM_Stage_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_NAM bit = CASE WHEN UPDATE(Metadata_ST_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_ChangedAt bit = CASE WHEN UPDATE(ST_NAM_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_EQ bit = CASE WHEN UPDATE(ST_NAM_EQ) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_NAM_ST_ID))
        RAISERROR('The foreign key column ST_NAM_ST_ID is not updatable.', 16, 1);
    IF(@updated_ST_NAM_Stage_Name = 1)
    BEGIN
        INSERT INTO [attributes].[ST_NAM_Stage_Name] (
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_EQ,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_NAM = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_NAM
            END, i.Metadata_ST),
            ISNULL(i.ST_NAM_ST_ID, i.ST_ID),
            ISNULL(i.ST_NAM_EQ, 0),
            cast(ISNULL(CASE
                WHEN i.ST_NAM_Stage_Name is null THEN i.ST_NAM_ChangedAt
                WHEN @updated_ST_NAM_ChangedAt = 1 THEN i.ST_NAM_ChangedAt
            END, @now) as datetime2),
            i.ST_NAM_Stage_Name
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            i.ST_NAM_Stage_Name is not null
        AND ( -- a value that is left as it is states nothing
            @updated_ST_NAM_ChangedAt = 1 OR
            @updated_ST_NAM_EQ = 1 OR
            d.ST_NAM_Stage_Name is null OR
            d.ST_NAM_Stage_Name <> i.ST_NAM_Stage_Name
        );
    END
    DECLARE @updated_ST_LOC_Stage_Location bit = CASE WHEN UPDATE(ST_LOC_Stage_Location) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_LOC bit = CASE WHEN UPDATE(Metadata_ST_LOC) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_LOC_EQ bit = CASE WHEN UPDATE(ST_LOC_EQ) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_LOC_ST_ID))
        RAISERROR('The foreign key column ST_LOC_ST_ID is not updatable.', 16, 1);
    IF(@updated_ST_LOC_Stage_Location = 1)
    BEGIN
        INSERT INTO [attributes].[ST_LOC_Stage_Location] (
            Metadata_ST_LOC,
            ST_LOC_ST_ID,
            ST_LOC_EQ,
            ST_LOC_Stage_Location
        )
        SELECT 
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_LOC = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_LOC
            END, i.Metadata_ST),
            ISNULL(i.ST_LOC_ST_ID, i.ST_ID),
            ISNULL(i.ST_LOC_EQ, 0),
            i.ST_LOC_Stage_Location
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            i.ST_LOC_Stage_Location is not null
        AND ( -- a value that is left as it is states nothing
            @updated_ST_LOC_EQ = 1 OR
            d.ST_LOC_Stage_Location is null OR
            d.ST_LOC_Checksum <> dw.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
        );
    END
    DECLARE @updated_ST_AVG_UTL_ID bit = CASE WHEN UPDATE(ST_AVG_UTL_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_UTL_Utilization bit = CASE WHEN UPDATE(ST_AVG_UTL_Utilization) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_AVG bit = CASE WHEN UPDATE(Metadata_ST_AVG) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_ChangedAt bit = CASE WHEN UPDATE(ST_AVG_ChangedAt) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_AVG_ST_ID))
        RAISERROR('The foreign key column ST_AVG_ST_ID is not updatable.', 16, 1);
    IF(@updated_ST_AVG_UTL_ID = 1 OR @updated_ST_AVG_UTL_Utilization = 1)
    BEGIN
        INSERT INTO [attributes].[ST_AVG_Stage_Average] (
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_AVG = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_AVG
            END, i.Metadata_ST),
            ISNULL(i.ST_AVG_ST_ID, i.ST_ID),
            cast(ISNULL(CASE
                WHEN i.ST_AVG_UTL_ID is null AND [kUTL].UTL_ID is null THEN i.ST_AVG_ChangedAt
                WHEN @updated_ST_AVG_ChangedAt = 1 THEN i.ST_AVG_ChangedAt
            END, @now) as datetime2),
            CASE WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END
        FROM
            inserted i
        LEFT JOIN
            [knots].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.ST_AVG_UTL_Utilization
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            CASE WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END is not null
        AND ( -- a value that is left as it is states nothing
            @updated_ST_AVG_ChangedAt = 1 OR
            d.ST_AVG_UTL_ID is null OR
            d.ST_AVG_UTL_ID <> CASE WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END
        );
    END
    DECLARE @updated_ST_MIN_UTL_ID bit = CASE WHEN UPDATE(ST_MIN_UTL_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_UTL_Utilization bit = CASE WHEN UPDATE(ST_MIN_UTL_Utilization) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_MIN bit = CASE WHEN UPDATE(Metadata_ST_MIN) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_MIN_ST_ID))
        RAISERROR('The foreign key column ST_MIN_ST_ID is not updatable.', 16, 1);
    IF(@updated_ST_MIN_UTL_ID = 1 OR @updated_ST_MIN_UTL_Utilization = 1)
    BEGIN
        INSERT INTO [attributes].[ST_MIN_Stage_Minimum] (
            Metadata_ST_MIN,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_MIN = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_MIN
            END, i.Metadata_ST),
            ISNULL(i.ST_MIN_ST_ID, i.ST_ID),
            CASE WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID ELSE [kUTL].UTL_ID END
        FROM
            inserted i
        LEFT JOIN
            [knots].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.ST_MIN_UTL_Utilization
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        WHERE
            CASE WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID ELSE [kUTL].UTL_ID END is not null
        AND ( -- a value that is left as it is states nothing
            d.ST_MIN_UTL_ID is null OR
            d.ST_MIN_UTL_ID <> CASE WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID ELSE [kUTL].UTL_ID END
        );
        SELECT
            i.ST_MIN_ST_ID
        INTO
            #ST_MIN
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.ST_MIN_ST_ID = i.ST_MIN_ST_ID
        AND
            d.ST_MIN_UTL_ID is not null
        WHERE
            ((@updated_ST_MIN_UTL_ID = 1 AND i.ST_MIN_UTL_ID is null) OR (@updated_ST_MIN_UTL_Utilization = 1 AND i.ST_MIN_UTL_Utilization is null))
        AND
            i.Deletable_ST_MIN = 1;
        IF(@@ROWCOUNT > 0)
        BEGIN
            IF OBJECT_ID('[attributes].[ST_MIN_Stage_Minimum_Deleted]') is null
            SELECT TOP 0
                *,
                CAST(null as datetime2) as ST_MIN_Deleted
            INTO
                [attributes].[ST_MIN_Stage_Minimum_Deleted]
            FROM
                [attributes].[ST_MIN_Stage_Minimum];
            DELETE [MIN]
            OUTPUT
                deleted.*,
                @now
            INTO
                [attributes].[ST_MIN_Stage_Minimum_Deleted]
            FROM
                [attributes].[ST_MIN_Stage_Minimum] [MIN]
            JOIN
                #ST_MIN d
            ON
                d.ST_MIN_ST_ID = [MIN].ST_MIN_ST_ID
        END
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[dt_lST_Stage] ON [anchors].[lST_Stage]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [attributes].[ST_NAM_Stage_Name] [NAM]
    JOIN
        deleted d
    ON
        d.ST_NAM_EQ = [NAM].ST_NAM_EQ
    AND
        d.ST_NAM_ChangedAt = [NAM].ST_NAM_ChangedAt
    AND
        d.ST_NAM_ST_ID = [NAM].ST_NAM_ST_ID;
    DELETE [LOC]
    FROM
        [attributes].[ST_LOC_Stage_Location] [LOC]
    JOIN
        deleted d
    ON
        d.ST_LOC_EQ = [LOC].ST_LOC_EQ
    AND
        d.ST_LOC_ST_ID = [LOC].ST_LOC_ST_ID;
    DELETE [AVG]
    FROM
        [attributes].[ST_AVG_Stage_Average] [AVG]
    JOIN
        deleted d
    ON
        d.ST_AVG_ChangedAt = [AVG].ST_AVG_ChangedAt
    AND
        d.ST_AVG_ST_ID = [AVG].ST_AVG_ST_ID;
    DELETE [MIN]
    FROM
        [attributes].[ST_MIN_Stage_Minimum] [MIN]
    JOIN
        deleted d
    ON
        d.ST_MIN_ST_ID = [MIN].ST_MIN_ST_ID;
    DECLARE @deleted TABLE (
        ST_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (ST_ID)
    SELECT a.ST_ID
    FROM (
        SELECT [ST].ST_ID
        FROM [anchors].[ST_Stage] [ST] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 ST_NAM_ST_ID
            FROM [attributes].[ST_NAM_Stage_Name] WITH(NOLOCK)
            WHERE ST_NAM_ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_LOC_ST_ID
            FROM [attributes].[ST_LOC_Stage_Location] WITH(NOLOCK)
            WHERE ST_LOC_ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_AVG_ST_ID
            FROM [attributes].[ST_AVG_Stage_Average] WITH(NOLOCK)
            WHERE ST_AVG_ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_MIN_ST_ID
            FROM [attributes].[ST_MIN_Stage_Minimum] WITH(NOLOCK)
            WHERE ST_MIN_ST_ID = [ST].ST_ID
        )
    ) a
    JOIN deleted d
    ON d.ST_ID = a.ST_ID;
    DELETE [ST]
    FROM [anchors].[ST_Stage] [ST]
    JOIN @deleted d
    ON d.ST_ID = [ST].ST_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[it_lAC_Actor] ON [anchors].[lAC_Actor]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @AC TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        AC_ID smallint not null
    );
    INSERT INTO [anchors].[AC_Actor] (
        Metadata_AC
    )
    OUTPUT
        inserted.AC_ID
    INTO
        @AC
    SELECT
        Metadata_AC
    FROM
        inserted
    WHERE
        inserted.AC_ID is null;
    DECLARE @inserted TABLE (
        AC_ID smallint not null,
        Metadata_AC int not null,
        AC_NAM_AC_ID smallint null,
        Metadata_AC_NAM int null,
        AC_NAM_ChangedAt datetime2 null,
        AC_NAM_Actor_Name nvarchar(42) null,
        AC_GEN_AC_ID smallint null,
        Metadata_AC_GEN int null,
        AC_GEN_GEN_Gender nvarchar(42) null,
        AC_GEN_GEN_Checksum varbinary(16) null,
        AC_GEN_Metadata_GEN int null,
        AC_GEN_GEN_ID tinyint null,
        AC_PLV_AC_ID smallint null,
        Metadata_AC_PLV int null,
        AC_PLV_ChangedAt datetime2 null,
        AC_PLV_PLV_ProfessionalLevel nvarchar(max) null,
        AC_PLV_PLV_Checksum varbinary(16) null,
        AC_PLV_PLV_EQ tinyint null,
        AC_PLV_Metadata_PLV int null,
        AC_PLV_PLV_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.AC_ID, a.AC_ID),
        i.Metadata_AC,
        ISNULL(ISNULL(i.AC_NAM_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_NAM, i.Metadata_AC),
        ISNULL(i.AC_NAM_ChangedAt, @now),
        i.AC_NAM_Actor_Name,
        ISNULL(ISNULL(i.AC_GEN_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_GEN, i.Metadata_AC),
        i.AC_GEN_GEN_Gender,
        ISNULL(i.AC_GEN_GEN_Checksum, dw.MD5(cast(i.AC_GEN_GEN_Gender as varbinary(max)))),
        ISNULL(i.AC_GEN_Metadata_GEN, i.Metadata_AC),
        i.AC_GEN_GEN_ID,
        ISNULL(ISNULL(i.AC_PLV_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_PLV, i.Metadata_AC),
        ISNULL(i.AC_PLV_ChangedAt, @now),
        i.AC_PLV_PLV_ProfessionalLevel,
        ISNULL(i.AC_PLV_PLV_Checksum, dw.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.AC_PLV_PLV_EQ, 0),
        ISNULL(i.AC_PLV_Metadata_PLV, i.Metadata_AC),
        i.AC_PLV_PLV_ID
    FROM (
        SELECT
            AC_ID,
            Metadata_AC,
            AC_NAM_AC_ID,
            Metadata_AC_NAM,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name,
            AC_GEN_AC_ID,
            Metadata_AC_GEN,
            AC_GEN_GEN_Gender,
            AC_GEN_GEN_Checksum,
            AC_GEN_Metadata_GEN,
            AC_GEN_GEN_ID,
            AC_PLV_AC_ID,
            Metadata_AC_PLV,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ProfessionalLevel,
            AC_PLV_PLV_Checksum,
            AC_PLV_PLV_EQ,
            AC_PLV_Metadata_PLV,
            AC_PLV_PLV_ID,
            ROW_NUMBER() OVER (PARTITION BY AC_ID ORDER BY AC_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @AC a
    ON
        a.Row = i.Row;
    INSERT INTO [attributes].[AC_NAM_Actor_Name] (
        Metadata_AC_NAM,
        AC_NAM_AC_ID,
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT DISTINCT
        i.Metadata_AC_NAM,
        i.AC_NAM_AC_ID,
        i.AC_NAM_ChangedAt,
        ENCRYPTBYKEY(KEY_GUID('PII'), cast(i.AC_NAM_Actor_Name as varbinary(max)))
    FROM
        @inserted i
    WHERE
        i.AC_NAM_Actor_Name is not null;
    INSERT INTO [attributes].[AC_GEN_Actor_Gender] (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID
    )
    SELECT DISTINCT
        i.Metadata_AC_GEN,
        i.AC_GEN_AC_ID,
        ISNULL(i.AC_GEN_GEN_ID, [kGEN].GEN_ID)
    FROM
        @inserted i
    LEFT JOIN
        [knots].[GEN_Gender] [kGEN]
    ON
        [kGEN].GEN_Checksum = i.AC_GEN_GEN_Checksum
    WHERE
        ISNULL(i.AC_GEN_GEN_ID, [kGEN].GEN_ID) is not null;
    INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel] (
        Metadata_AC_PLV,
        AC_PLV_AC_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PLV_ID
    )
    SELECT DISTINCT
        i.Metadata_AC_PLV,
        i.AC_PLV_AC_ID,
        i.AC_PLV_ChangedAt,
        ISNULL(i.AC_PLV_PLV_ID, [kPLV].PLV_ID)
    FROM
        @inserted i
    LEFT JOIN
        [knots].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.AC_PLV_PLV_Checksum
    AND
        [kPLV].PLV_EQ = i.AC_PLV_PLV_EQ
    WHERE
        ISNULL(i.AC_PLV_PLV_ID, [kPLV].PLV_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[ut_lAC_Actor] ON [anchors].[lAC_Actor]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_AC bit = CASE WHEN UPDATE(Metadata_AC) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_ID))
        RAISERROR('The identity column AC_ID is not updatable.', 16, 1);
    DECLARE @updated_AC_NAM_Actor_Name bit = CASE WHEN UPDATE(AC_NAM_Actor_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_NAM bit = CASE WHEN UPDATE(Metadata_AC_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_ChangedAt bit = CASE WHEN UPDATE(AC_NAM_ChangedAt) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_NAM_AC_ID))
        RAISERROR('The foreign key column AC_NAM_AC_ID is not updatable.', 16, 1);
    IF(@updated_AC_NAM_Actor_Name = 1)
    BEGIN
        INSERT INTO [attributes].[AC_NAM_Actor_Name] (
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_NAM = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_NAM
            END, i.Metadata_AC),
            ISNULL(i.AC_NAM_AC_ID, i.AC_ID),
            cast(ISNULL(CASE
                WHEN i.AC_NAM_Actor_Name is null THEN i.AC_NAM_ChangedAt
                WHEN @updated_AC_NAM_ChangedAt = 1 THEN i.AC_NAM_ChangedAt
            END, @now) as datetime2),
        ENCRYPTBYKEY(KEY_GUID('PII'), cast(i.AC_NAM_Actor_Name as varbinary(max)))
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        WHERE
            i.AC_NAM_Actor_Name is not null
        AND ( -- a value that is left as it is states nothing
            @updated_AC_NAM_ChangedAt = 1 OR
            d.AC_NAM_Actor_Name is null OR
            d.AC_NAM_Actor_Name <> i.AC_NAM_Actor_Name
        );
    END
    DECLARE @updated_AC_GEN_GEN_ID bit = CASE WHEN UPDATE(AC_GEN_GEN_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_GEN_Gender bit = CASE WHEN UPDATE(AC_GEN_GEN_Gender) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_GEN bit = CASE WHEN UPDATE(Metadata_AC_GEN) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_GEN_AC_ID))
        RAISERROR('The foreign key column AC_GEN_AC_ID is not updatable.', 16, 1);
    IF(@updated_AC_GEN_GEN_ID = 1 OR @updated_AC_GEN_GEN_Gender = 1)
    BEGIN
        INSERT INTO [attributes].[AC_GEN_Actor_Gender] (
            Metadata_AC_GEN,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_GEN = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_GEN
            END, i.Metadata_AC),
            ISNULL(i.AC_GEN_AC_ID, i.AC_ID),
            CASE WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID ELSE [kGEN].GEN_ID END
        FROM
            inserted i
        LEFT JOIN
            [knots].[GEN_Gender] [kGEN]
        ON
            [kGEN].GEN_Checksum = dw.MD5(cast(i.AC_GEN_GEN_Gender as varbinary(max)))
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        WHERE
            CASE WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID ELSE [kGEN].GEN_ID END is not null
        AND ( -- a value that is left as it is states nothing
            d.AC_GEN_GEN_ID is null OR
            d.AC_GEN_GEN_ID <> CASE WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID ELSE [kGEN].GEN_ID END
        );
    END
    DECLARE @updated_AC_PLV_PLV_ID bit = CASE WHEN UPDATE(AC_PLV_PLV_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_PLV_ProfessionalLevel bit = CASE WHEN UPDATE(AC_PLV_PLV_ProfessionalLevel) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_PLV bit = CASE WHEN UPDATE(Metadata_AC_PLV) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_ChangedAt bit = CASE WHEN UPDATE(AC_PLV_ChangedAt) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_PLV_AC_ID))
        RAISERROR('The foreign key column AC_PLV_AC_ID is not updatable.', 16, 1);
    IF(@updated_AC_PLV_PLV_ID = 1 OR @updated_AC_PLV_PLV_ProfessionalLevel = 1)
    BEGIN
        INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel] (
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_PLV = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_PLV
            END, i.Metadata_AC),
            ISNULL(i.AC_PLV_AC_ID, i.AC_ID),
            cast(ISNULL(CASE
                WHEN i.AC_PLV_PLV_ID is null AND [kPLV].PLV_ID is null THEN i.AC_PLV_ChangedAt
                WHEN @updated_AC_PLV_ChangedAt = 1 THEN i.AC_PLV_ChangedAt
            END, @now) as datetime2),
            CASE WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END
        FROM
            inserted i
        LEFT JOIN
            [knots].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dw.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max)))
        AND
            [kPLV].PLV_EQ = i.AC_PLV_PLV_EQ
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        WHERE
            CASE WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END is not null
        AND ( -- a value that is left as it is states nothing
            @updated_AC_PLV_ChangedAt = 1 OR
            d.AC_PLV_PLV_ID is null OR
            d.AC_PLV_PLV_ID <> CASE WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END
        );
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[dt_lAC_Actor] ON [anchors].[lAC_Actor]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [attributes].[AC_NAM_Actor_Name] [NAM]
    JOIN
        deleted d
    ON
        d.AC_NAM_ChangedAt = [NAM].AC_NAM_ChangedAt
    AND
        d.AC_NAM_AC_ID = [NAM].AC_NAM_AC_ID;
    DELETE [GEN]
    FROM
        [attributes].[AC_GEN_Actor_Gender] [GEN]
    JOIN
        deleted d
    ON
        d.AC_GEN_AC_ID = [GEN].AC_GEN_AC_ID;
    DELETE [PLV]
    FROM
        [attributes].[AC_PLV_Actor_ProfessionalLevel] [PLV]
    JOIN
        deleted d
    ON
        d.AC_PLV_ChangedAt = [PLV].AC_PLV_ChangedAt
    AND
        d.AC_PLV_AC_ID = [PLV].AC_PLV_AC_ID;
    DECLARE @deleted TABLE (
        AC_ID smallint NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (AC_ID)
    SELECT a.AC_ID
    FROM (
        SELECT [AC].AC_ID
        FROM [anchors].[AC_Actor] [AC] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 AC_NAM_AC_ID
            FROM [attributes].[AC_NAM_Actor_Name] WITH(NOLOCK)
            WHERE AC_NAM_AC_ID = [AC].AC_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 AC_GEN_AC_ID
            FROM [attributes].[AC_GEN_Actor_Gender] WITH(NOLOCK)
            WHERE AC_GEN_AC_ID = [AC].AC_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 AC_PLV_AC_ID
            FROM [attributes].[AC_PLV_Actor_ProfessionalLevel] WITH(NOLOCK)
            WHERE AC_PLV_AC_ID = [AC].AC_ID
        )
    ) a
    JOIN deleted d
    ON d.AC_ID = a.AC_ID;
    DELETE [AC]
    FROM [anchors].[AC_Actor] [AC]
    JOIN @deleted d
    ON d.AC_ID = [AC].AC_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[it_lPR_Program] ON [anchors].[lPR_Program]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @PR TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        PR_ID bigint not null
    );
    INSERT INTO [anchors].[PR_Program] (
        Metadata_PR
    )
    OUTPUT
        inserted.PR_ID
    INTO
        @PR
    SELECT
        Metadata_PR
    FROM
        inserted
    WHERE
        inserted.PR_ID is null;
    DECLARE @inserted TABLE (
        PR_ID bigint not null,
        Metadata_PR int not null,
        PR_NAM_PR_ID bigint null,
        Metadata_PR_NAM int null,
        PR_NAM_Program_Name nvarchar(42) null,
        PR_LEN_PR_ID bigint null,
        Metadata_PR_LEN int null,
        PR_LEN_ChangedAt date null,
        PR_LEN_EQ tinyint null,
        PR_LEN_Program_Length time null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PR_ID, a.PR_ID),
        i.Metadata_PR,
        ISNULL(ISNULL(i.PR_NAM_PR_ID, i.PR_ID), a.PR_ID),
        ISNULL(i.Metadata_PR_NAM, i.Metadata_PR),
        i.PR_NAM_Program_Name,
        ISNULL(ISNULL(i.PR_LEN_PR_ID, i.PR_ID), a.PR_ID),
        ISNULL(i.Metadata_PR_LEN, i.Metadata_PR),
        ISNULL(i.PR_LEN_ChangedAt, @now),
        ISNULL(i.PR_LEN_EQ, 0),
        i.PR_LEN_Program_Length
    FROM (
        SELECT
            PR_ID,
            Metadata_PR,
            PR_NAM_PR_ID,
            Metadata_PR_NAM,
            PR_NAM_Program_Name,
            PR_LEN_PR_ID,
            Metadata_PR_LEN,
            PR_LEN_ChangedAt,
            PR_LEN_EQ,
            PR_LEN_Program_Length,
            ROW_NUMBER() OVER (PARTITION BY PR_ID ORDER BY PR_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @PR a
    ON
        a.Row = i.Row;
    INSERT INTO [attributes].[PR_NAM_Program_Name] (
        Metadata_PR_NAM,
        PR_NAM_PR_ID,
        PR_NAM_Program_Name
    )
    SELECT DISTINCT
        i.Metadata_PR_NAM,
        i.PR_NAM_PR_ID,
        i.PR_NAM_Program_Name
    FROM
        @inserted i
    WHERE
        i.PR_NAM_Program_Name is not null;
    INSERT INTO [attributes].[PR_LEN_Program_Length] (
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT DISTINCT
        i.Metadata_PR_LEN,
        i.PR_LEN_PR_ID,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_Program_Length
    FROM
        @inserted i
    WHERE
        i.PR_LEN_Program_Length is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Program instead of UPDATE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[ut_lPR_Program] ON [anchors].[lPR_Program]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_Metadata_PR bit = CASE WHEN UPDATE(Metadata_PR) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_ID))
        RAISERROR('The identity column PR_ID is not updatable.', 16, 1);
    DECLARE @updated_PR_NAM_Program_Name bit = CASE WHEN UPDATE(PR_NAM_Program_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_PR_NAM bit = CASE WHEN UPDATE(Metadata_PR_NAM) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_NAM_PR_ID))
        RAISERROR('The foreign key column PR_NAM_PR_ID is not updatable.', 16, 1);
    IF(@updated_PR_NAM_Program_Name = 1)
    BEGIN
        INSERT INTO [attributes].[PR_NAM_Program_Name] (
            Metadata_PR_NAM,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_NAM = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_NAM
            END, i.Metadata_PR),
            ISNULL(i.PR_NAM_PR_ID, i.PR_ID),
            i.PR_NAM_Program_Name
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.PR_ID = i.PR_ID
        WHERE
            i.PR_NAM_Program_Name is not null
        AND ( -- a value that is left as it is states nothing
            d.PR_NAM_Program_Name is null OR
            d.PR_NAM_Program_Name <> i.PR_NAM_Program_Name
        );
    END
    DECLARE @updated_PR_LEN_Program_Length bit = CASE WHEN UPDATE(PR_LEN_Program_Length) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_PR_LEN bit = CASE WHEN UPDATE(Metadata_PR_LEN) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_ChangedAt bit = CASE WHEN UPDATE(PR_LEN_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_EQ bit = CASE WHEN UPDATE(PR_LEN_EQ) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_LEN_PR_ID))
        RAISERROR('The foreign key column PR_LEN_PR_ID is not updatable.', 16, 1);
    IF(@updated_PR_LEN_Program_Length = 1)
    BEGIN
        INSERT INTO [attributes].[PR_LEN_Program_Length] (
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_EQ,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        )
        SELECT DISTINCT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_LEN = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_LEN
            END, i.Metadata_PR),
            ISNULL(i.PR_LEN_PR_ID, i.PR_ID),
            ISNULL(i.PR_LEN_EQ, 0),
            cast(ISNULL(CASE
                WHEN i.PR_LEN_Program_Length is null THEN i.PR_LEN_ChangedAt
                WHEN @updated_PR_LEN_ChangedAt = 1 THEN i.PR_LEN_ChangedAt
            END, @now) as date),
            i.PR_LEN_Program_Length
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.PR_ID = i.PR_ID
        WHERE
            i.PR_LEN_Program_Length is not null
        AND ( -- a value that is left as it is states nothing
            @updated_PR_LEN_ChangedAt = 1 OR
            @updated_PR_LEN_EQ = 1 OR
            d.PR_LEN_Program_Length is null OR
            d.PR_LEN_Program_Length <> i.PR_LEN_Program_Length
        );
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Program instead of DELETE trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [anchors].[dt_lPR_Program] ON [anchors].[lPR_Program]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE [NAM]
    FROM
        [attributes].[PR_NAM_Program_Name] [NAM]
    JOIN
        deleted d
    ON
        d.PR_NAM_PR_ID = [NAM].PR_NAM_PR_ID;
    DELETE [LEN]
    FROM
        [attributes].[PR_LEN_Program_Length] [LEN]
    JOIN
        deleted d
    ON
        d.PR_LEN_EQ = [LEN].PR_LEN_EQ
    AND
        d.PR_LEN_ChangedAt = [LEN].PR_LEN_ChangedAt
    AND
        d.PR_LEN_PR_ID = [LEN].PR_LEN_PR_ID;
    DECLARE @deleted TABLE (
        PR_ID bigint NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (PR_ID)
    SELECT a.PR_ID
    FROM (
        SELECT [PR].PR_ID
        FROM [anchors].[PR_Program] [PR] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 PR_NAM_PR_ID
            FROM [attributes].[PR_NAM_Program_Name] WITH(NOLOCK)
            WHERE PR_NAM_PR_ID = [PR].PR_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 PR_LEN_PR_ID
            FROM [attributes].[PR_LEN_Program_Length] WITH(NOLOCK)
            WHERE PR_LEN_PR_ID = [PR].PR_ID
        )
    ) a
    JOIN deleted d
    ON d.PR_ID = a.PR_ID;
    DELETE [PR]
    FROM [anchors].[PR_Program] [PR]
    JOIN @deleted d
    ON d.PR_ID = [PR].PR_ID;
END
GO
