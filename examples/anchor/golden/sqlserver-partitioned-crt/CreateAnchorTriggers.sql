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
        ST_NAM_Positor tinyint null,
        ST_NAM_PositedAt datetime2 null,
        ST_NAM_Reliability decimal(5,2) null,
        ST_NAM_Stage_Name nvarchar(42) null,
        ST_LOC_ST_ID int null,
        Metadata_ST_LOC int null,
        ST_LOC_Positor tinyint null,
        ST_LOC_PositedAt datetime2 null,
        ST_LOC_Reliability decimal(5,2) null,
        ST_LOC_Stage_Location geography null,
        ST_AVG_ST_ID int null,
        Metadata_ST_AVG int null,
        ST_AVG_ChangedAt datetime2 null,
        ST_AVG_Positor tinyint null,
        ST_AVG_PositedAt datetime2 null,
        ST_AVG_Reliability decimal(5,2) null,
        ST_AVG_UTL_Utilization tinyint null,
        ST_AVG_Metadata_UTL int null,
        ST_AVG_UTL_ID tinyint null,
        ST_MIN_ST_ID int null,
        Metadata_ST_MIN int null,
        ST_MIN_Positor tinyint null,
        ST_MIN_PositedAt datetime2 null,
        ST_MIN_Reliability decimal(5,2) null,
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
        ISNULL(ISNULL(i.ST_NAM_Positor, i.Positor), 0),
        ISNULL(i.ST_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.ST_NAM_Reliability, i.Reliability), 1),
        i.ST_NAM_Stage_Name,
        ISNULL(ISNULL(i.ST_LOC_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_LOC, i.Metadata_ST),
        ISNULL(ISNULL(i.ST_LOC_Positor, i.Positor), 0),
        ISNULL(i.ST_LOC_PositedAt, @now),
        ISNULL(ISNULL(i.ST_LOC_Reliability, i.Reliability), 1),
        i.ST_LOC_Stage_Location,
        ISNULL(ISNULL(i.ST_AVG_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_AVG, i.Metadata_ST),
        ISNULL(i.ST_AVG_ChangedAt, @now),
        ISNULL(ISNULL(i.ST_AVG_Positor, i.Positor), 0),
        ISNULL(i.ST_AVG_PositedAt, @now),
        ISNULL(ISNULL(i.ST_AVG_Reliability, i.Reliability), 1),
        i.ST_AVG_UTL_Utilization,
        ISNULL(i.ST_AVG_Metadata_UTL, i.Metadata_ST),
        i.ST_AVG_UTL_ID,
        ISNULL(ISNULL(i.ST_MIN_ST_ID, i.ST_ID), a.ST_ID),
        ISNULL(i.Metadata_ST_MIN, i.Metadata_ST),
        ISNULL(ISNULL(i.ST_MIN_Positor, i.Positor), 0),
        ISNULL(i.ST_MIN_PositedAt, @now),
        ISNULL(ISNULL(i.ST_MIN_Reliability, i.Reliability), 1),
        i.ST_MIN_UTL_Utilization,
        ISNULL(i.ST_MIN_Metadata_UTL, i.Metadata_ST),
        i.ST_MIN_UTL_ID
    FROM (
        SELECT
            Positor,
            Reliability,
            ST_ID,
            Metadata_ST,
            ST_NAM_ST_ID,
            Metadata_ST_NAM,
            ST_NAM_ChangedAt,
            ST_NAM_Positor,
            ST_NAM_PositedAt,
            ST_NAM_Reliability,
            ST_NAM_Stage_Name,
            ST_LOC_ST_ID,
            Metadata_ST_LOC,
            ST_LOC_Positor,
            ST_LOC_PositedAt,
            ST_LOC_Reliability,
            ST_LOC_Stage_Location,
            ST_AVG_ST_ID,
            Metadata_ST_AVG,
            ST_AVG_ChangedAt,
            ST_AVG_Positor,
            ST_AVG_PositedAt,
            ST_AVG_Reliability,
            ST_AVG_UTL_Utilization,
            ST_AVG_Metadata_UTL,
            ST_AVG_UTL_ID,
            ST_MIN_ST_ID,
            Metadata_ST_MIN,
            ST_MIN_Positor,
            ST_MIN_PositedAt,
            ST_MIN_Reliability,
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
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Positor,
        ST_NAM_Reliability
    )
    SELECT
        i.Metadata_ST_NAM,
        i.ST_NAM_ST_ID,
        i.ST_NAM_Stage_Name,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Positor,
        i.ST_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.ST_NAM_Stage_Name is not null;
    INSERT INTO [attributes].[ST_LOC_Stage_Location] (
        Metadata_ST_LOC,
        ST_LOC_ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_PositedAt,
        ST_LOC_Positor,
        ST_LOC_Reliability
    )
    SELECT
        i.Metadata_ST_LOC,
        i.ST_LOC_ST_ID,
        i.ST_LOC_Stage_Location,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Positor,
        i.ST_LOC_Reliability
    FROM
        @inserted i
    WHERE
        i.ST_LOC_Stage_Location is not null;
    INSERT INTO [attributes].[ST_AVG_Stage_Average] (
        Metadata_ST_AVG,
        ST_AVG_ST_ID,
        ST_AVG_UTL_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Positor,
        ST_AVG_Reliability
    )
    SELECT
        i.Metadata_ST_AVG,
        i.ST_AVG_ST_ID,
        ISNULL(i.ST_AVG_UTL_ID, [kUTL].UTL_ID),
        i.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Positor,
        i.ST_AVG_Reliability
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
        ST_MIN_UTL_ID,
        ST_MIN_PositedAt,
        ST_MIN_Positor,
        ST_MIN_Reliability
    )
    SELECT
        i.Metadata_ST_MIN,
        i.ST_MIN_ST_ID,
        ISNULL(i.ST_MIN_UTL_ID, [kUTL].UTL_ID),
        i.ST_MIN_PositedAt,
        i.ST_MIN_Positor,
        i.ST_MIN_Reliability
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
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_Positor bit = CASE WHEN UPDATE(Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_ID))
        RAISERROR('The identity column ST_ID is not updatable.', 16, 1);
    DECLARE @updated_ST_NAM_Stage_Name bit = CASE WHEN UPDATE(ST_NAM_Stage_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_NAM bit = CASE WHEN UPDATE(Metadata_ST_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_ChangedAt bit = CASE WHEN UPDATE(ST_NAM_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_PositedAt bit = CASE WHEN UPDATE(ST_NAM_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_Reliability bit = CASE WHEN UPDATE(ST_NAM_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_NAM_Positor bit = CASE WHEN UPDATE(ST_NAM_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_NAM_ID))
        RAISERROR('The identity column ST_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_ST_ID))
        RAISERROR('The foreign key column ST_NAM_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_Assertion))
        RAISERROR('The computed assertion column ST_NAM_Assertion is not updatable.', 16, 1);
    IF (
        @updated_ST_NAM_Stage_Name = 1 OR
        @updated_ST_NAM_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_NAM_Stage_Name] (
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_NAM = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_NAM
            END, i.Metadata_ST),
            ISNULL(i.ST_NAM_ST_ID, i.ST_ID),
            i.ST_NAM_Stage_Name,
            cast(ISNULL(CASE
                WHEN @updated_ST_NAM_ChangedAt = 1 THEN i.ST_NAM_ChangedAt
                WHEN d.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
                THEN i.ST_NAM_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_ST_NAM_PositedAt = 1 THEN i.ST_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_NAM_Positor = 1 THEN i.ST_NAM_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_ST_NAM_Reliability = 1 THEN i.ST_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.ST_NAM_Stage_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_NAM_ChangedAt = 1 OR
            @updated_ST_NAM_PositedAt = 1 OR
            @updated_ST_NAM_Positor = 1 OR
            @updated_Positor = 1 OR
            d.ST_NAM_Stage_Name is null OR
            d.ST_NAM_Stage_Name <> i.ST_NAM_Stage_Name OR
            d.ST_NAM_Reliability <> ISNULL(CASE
                WHEN @updated_ST_NAM_Reliability = 1 THEN i.ST_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_NAM_Stage_Name = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_NAM_Stage_Name] (
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_NAM = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_NAM
            END, i.Metadata_ST),
            p.ST_NAM_ST_ID,
            p.ST_NAM_Stage_Name,
            p.ST_NAM_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_ST_NAM_PositedAt = 1 THEN i.ST_NAM_PositedAt
                WHEN @updated_ST_NAM_ChangedAt = 1 THEN i.ST_NAM_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_NAM_Positor = 1 THEN i.ST_NAM_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[ST_NAM_Stage_Name_Posit] p
        ON
            p.ST_NAM_ID = i.ST_NAM_ID
        WHERE
            i.ST_NAM_Stage_Name is null
    END
    DECLARE @updated_ST_LOC_Stage_Location bit = CASE WHEN UPDATE(ST_LOC_Stage_Location) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_LOC bit = CASE WHEN UPDATE(Metadata_ST_LOC) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_LOC_PositedAt bit = CASE WHEN UPDATE(ST_LOC_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_LOC_Reliability bit = CASE WHEN UPDATE(ST_LOC_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_LOC_Positor bit = CASE WHEN UPDATE(ST_LOC_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_LOC_ID))
        RAISERROR('The identity column ST_LOC_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_LOC_ST_ID))
        RAISERROR('The foreign key column ST_LOC_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_LOC_Assertion))
        RAISERROR('The computed assertion column ST_LOC_Assertion is not updatable.', 16, 1);
    IF (
        @updated_ST_LOC_Stage_Location = 1 OR
        @updated_ST_LOC_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_LOC_Stage_Location] (
            Metadata_ST_LOC,
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location,
            ST_LOC_PositedAt,
            ST_LOC_Positor,
            ST_LOC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_LOC = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_LOC
            END, i.Metadata_ST),
            ISNULL(i.ST_LOC_ST_ID, i.ST_ID),
            i.ST_LOC_Stage_Location,
            cast(ISNULL(CASE
                WHEN @updated_ST_LOC_PositedAt = 1 THEN i.ST_LOC_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_LOC_Positor = 1 THEN i.ST_LOC_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_ST_LOC_Reliability = 1 THEN i.ST_LOC_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_LOC_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.ST_LOC_Stage_Location is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_LOC_PositedAt = 1 OR
            @updated_ST_LOC_Positor = 1 OR
            @updated_Positor = 1 OR
            d.ST_LOC_Stage_Location is null OR
            d.ST_LOC_Checksum <> dw.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) OR
            d.ST_LOC_Reliability <> ISNULL(CASE
                WHEN @updated_ST_LOC_Reliability = 1 THEN i.ST_LOC_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_LOC_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_LOC_Stage_Location = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_LOC_Stage_Location] (
            Metadata_ST_LOC,
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location,
            ST_LOC_PositedAt,
            ST_LOC_Positor,
            ST_LOC_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_LOC = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_LOC
            END, i.Metadata_ST),
            p.ST_LOC_ST_ID,
            p.ST_LOC_Stage_Location,
            cast(ISNULL(CASE
                WHEN @updated_ST_LOC_PositedAt = 1 THEN i.ST_LOC_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_LOC_Positor = 1 THEN i.ST_LOC_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[ST_LOC_Stage_Location_Posit] p
        ON
            p.ST_LOC_ID = i.ST_LOC_ID
        WHERE
            i.ST_LOC_Stage_Location is null
    END
    DECLARE @updated_ST_AVG_UTL_ID bit = CASE WHEN UPDATE(ST_AVG_UTL_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_UTL_Utilization bit = CASE WHEN UPDATE(ST_AVG_UTL_Utilization) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_AVG bit = CASE WHEN UPDATE(Metadata_ST_AVG) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_ChangedAt bit = CASE WHEN UPDATE(ST_AVG_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_PositedAt bit = CASE WHEN UPDATE(ST_AVG_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_Reliability bit = CASE WHEN UPDATE(ST_AVG_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_AVG_Positor bit = CASE WHEN UPDATE(ST_AVG_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_AVG_ID))
        RAISERROR('The identity column ST_AVG_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_AVG_ST_ID))
        RAISERROR('The foreign key column ST_AVG_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_AVG_Assertion))
        RAISERROR('The computed assertion column ST_AVG_Assertion is not updatable.', 16, 1);
    IF (
        @updated_ST_AVG_UTL_ID = 1 OR
        @updated_ST_AVG_UTL_Utilization = 1 OR
        @updated_ST_AVG_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_AVG_Stage_Average] (
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_AVG = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_AVG
            END, i.Metadata_ST),
            ISNULL(i.ST_AVG_ST_ID, i.ST_ID),
            CASE
                WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_ST_AVG_ChangedAt = 1 THEN i.ST_AVG_ChangedAt
                WHEN d.ST_AVG_UTL_ID = CASE WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END
                THEN i.ST_AVG_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_ST_AVG_PositedAt = 1 THEN i.ST_AVG_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_AVG_Positor = 1 THEN i.ST_AVG_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_ST_AVG_Reliability = 1 THEN i.ST_AVG_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_AVG_Reliability
            END, 1)
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
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_AVG_ChangedAt = 1 OR
            @updated_ST_AVG_PositedAt = 1 OR
            @updated_ST_AVG_Positor = 1 OR
            @updated_Positor = 1 OR
            d.ST_AVG_UTL_ID is null OR
            d.ST_AVG_UTL_ID <> CASE WHEN @updated_ST_AVG_UTL_ID = 1 THEN i.ST_AVG_UTL_ID ELSE [kUTL].UTL_ID END OR
            d.ST_AVG_Reliability <> ISNULL(CASE
                WHEN @updated_ST_AVG_Reliability = 1 THEN i.ST_AVG_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_AVG_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_AVG_UTL_ID = 1 OR
        @updated_ST_AVG_UTL_Utilization = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_AVG_Stage_Average] (
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_AVG = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_AVG
            END, i.Metadata_ST),
            p.ST_AVG_ST_ID,
            p.ST_AVG_UTL_ID,
            p.ST_AVG_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_ST_AVG_PositedAt = 1 THEN i.ST_AVG_PositedAt
                WHEN @updated_ST_AVG_ChangedAt = 1 THEN i.ST_AVG_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_AVG_Positor = 1 THEN i.ST_AVG_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[ST_AVG_Stage_Average_Posit] p
        ON
            p.ST_AVG_ID = i.ST_AVG_ID
        WHERE
            (@updated_ST_AVG_UTL_ID = 1 AND i.ST_AVG_UTL_ID is null)
        OR
            (@updated_ST_AVG_UTL_Utilization = 1 AND i.ST_AVG_UTL_Utilization is null);
    END
    DECLARE @updated_ST_MIN_UTL_ID bit = CASE WHEN UPDATE(ST_MIN_UTL_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_UTL_Utilization bit = CASE WHEN UPDATE(ST_MIN_UTL_Utilization) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_ST_MIN bit = CASE WHEN UPDATE(Metadata_ST_MIN) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_PositedAt bit = CASE WHEN UPDATE(ST_MIN_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_Reliability bit = CASE WHEN UPDATE(ST_MIN_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_ST_MIN_Positor bit = CASE WHEN UPDATE(ST_MIN_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(ST_MIN_ID))
        RAISERROR('The identity column ST_MIN_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_MIN_ST_ID))
        RAISERROR('The foreign key column ST_MIN_ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_MIN_Assertion))
        RAISERROR('The computed assertion column ST_MIN_Assertion is not updatable.', 16, 1);
    IF (
        @updated_ST_MIN_UTL_ID = 1 OR
        @updated_ST_MIN_UTL_Utilization = 1 OR
        @updated_ST_MIN_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_MIN_Stage_Minimum] (
            Metadata_ST_MIN,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID,
            ST_MIN_PositedAt,
            ST_MIN_Positor,
            ST_MIN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_MIN = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_MIN
            END, i.Metadata_ST),
            ISNULL(i.ST_MIN_ST_ID, i.ST_ID),
            CASE
                WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_ST_MIN_PositedAt = 1 THEN i.ST_MIN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_MIN_Positor = 1 THEN i.ST_MIN_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_ST_MIN_Reliability = 1 THEN i.ST_MIN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_MIN_Reliability
            END, 1)
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
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_ST_MIN_PositedAt = 1 OR
            @updated_ST_MIN_Positor = 1 OR
            @updated_Positor = 1 OR
            d.ST_MIN_UTL_ID is null OR
            d.ST_MIN_UTL_ID <> CASE WHEN @updated_ST_MIN_UTL_ID = 1 THEN i.ST_MIN_UTL_ID ELSE [kUTL].UTL_ID END OR
            d.ST_MIN_Reliability <> ISNULL(CASE
                WHEN @updated_ST_MIN_Reliability = 1 THEN i.ST_MIN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.ST_MIN_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_ST_MIN_UTL_ID = 1 OR
        @updated_ST_MIN_UTL_Utilization = 1
    )
    BEGIN
        INSERT INTO [attributes].[ST_MIN_Stage_Minimum] (
            Metadata_ST_MIN,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID,
            ST_MIN_PositedAt,
            ST_MIN_Positor,
            ST_MIN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_ST = 1 AND @updated_Metadata_ST_MIN = 0
                THEN i.Metadata_ST
                ELSE i.Metadata_ST_MIN
            END, i.Metadata_ST),
            p.ST_MIN_ST_ID,
            p.ST_MIN_UTL_ID,
            cast(ISNULL(CASE
                WHEN @updated_ST_MIN_PositedAt = 1 THEN i.ST_MIN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_ST_MIN_Positor = 1 THEN i.ST_MIN_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[ST_MIN_Stage_Minimum_Posit] p
        ON
            p.ST_MIN_ID = i.ST_MIN_ID
        WHERE
            (@updated_ST_MIN_UTL_ID = 1 AND i.ST_MIN_UTL_ID is null)
        OR
            (@updated_ST_MIN_UTL_Utilization = 1 AND i.ST_MIN_UTL_Utilization is null);
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [attributes].[ST_NAM_Stage_Name_Annex] (
        Metadata_ST_NAM,
        ST_NAM_ID,
        ST_NAM_Positor,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        d.Metadata_ST_NAM,
        d.ST_NAM_ID,
        d.ST_NAM_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_NAM_ID is not null;
    INSERT INTO [attributes].[ST_LOC_Stage_Location_Annex] (
        Metadata_ST_LOC,
        ST_LOC_ID,
        ST_LOC_Positor,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        d.Metadata_ST_LOC,
        d.ST_LOC_ID,
        d.ST_LOC_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_LOC_ID is not null;
    INSERT INTO [attributes].[ST_AVG_Stage_Average_Annex] (
        Metadata_ST_AVG,
        ST_AVG_ID,
        ST_AVG_Positor,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        d.Metadata_ST_AVG,
        d.ST_AVG_ID,
        d.ST_AVG_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_AVG_ID is not null;
    INSERT INTO [attributes].[ST_MIN_Stage_Minimum_Annex] (
        Metadata_ST_MIN,
        ST_MIN_ID,
        ST_MIN_Positor,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        d.Metadata_ST_MIN,
        d.ST_MIN_ID,
        d.ST_MIN_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.ST_MIN_ID is not null;
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
        AC_NAM_Positor tinyint null,
        AC_NAM_PositedAt datetime2 null,
        AC_NAM_Reliability decimal(5,2) null,
        AC_NAM_Actor_Name varbinary(max) null,
        AC_GEN_AC_ID smallint null,
        Metadata_AC_GEN int null,
        AC_GEN_Positor tinyint null,
        AC_GEN_PositedAt datetime2 null,
        AC_GEN_Reliability decimal(5,2) null,
        AC_GEN_GEN_Gender nvarchar(42) null,
        AC_GEN_GEN_Checksum varbinary(16) null,
        AC_GEN_Metadata_GEN int null,
        AC_GEN_GEN_ID tinyint null,
        AC_PLV_AC_ID smallint null,
        Metadata_AC_PLV int null,
        AC_PLV_ChangedAt datetime2 null,
        AC_PLV_Positor tinyint null,
        AC_PLV_PositedAt datetime2 null,
        AC_PLV_Reliability decimal(5,2) null,
        AC_PLV_PLV_ProfessionalLevel nvarchar(max) null,
        AC_PLV_PLV_Checksum varbinary(16) null,
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
        ISNULL(ISNULL(i.AC_NAM_Positor, i.Positor), 0),
        ISNULL(i.AC_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.AC_NAM_Reliability, i.Reliability), 1),
        i.AC_NAM_Actor_Name,
        ISNULL(ISNULL(i.AC_GEN_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_GEN, i.Metadata_AC),
        ISNULL(ISNULL(i.AC_GEN_Positor, i.Positor), 0),
        ISNULL(i.AC_GEN_PositedAt, @now),
        ISNULL(ISNULL(i.AC_GEN_Reliability, i.Reliability), 1),
        i.AC_GEN_GEN_Gender,
        ISNULL(i.AC_GEN_GEN_Checksum, dw.MD5(cast(i.AC_GEN_GEN_Gender as varbinary(max)))),
        ISNULL(i.AC_GEN_Metadata_GEN, i.Metadata_AC),
        i.AC_GEN_GEN_ID,
        ISNULL(ISNULL(i.AC_PLV_AC_ID, i.AC_ID), a.AC_ID),
        ISNULL(i.Metadata_AC_PLV, i.Metadata_AC),
        ISNULL(i.AC_PLV_ChangedAt, @now),
        ISNULL(ISNULL(i.AC_PLV_Positor, i.Positor), 0),
        ISNULL(i.AC_PLV_PositedAt, @now),
        ISNULL(ISNULL(i.AC_PLV_Reliability, i.Reliability), 1),
        i.AC_PLV_PLV_ProfessionalLevel,
        ISNULL(i.AC_PLV_PLV_Checksum, dw.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max)))),
        ISNULL(i.AC_PLV_Metadata_PLV, i.Metadata_AC),
        i.AC_PLV_PLV_ID
    FROM (
        SELECT
            Positor,
            Reliability,
            AC_ID,
            Metadata_AC,
            AC_NAM_AC_ID,
            Metadata_AC_NAM,
            AC_NAM_ChangedAt,
            AC_NAM_Positor,
            AC_NAM_PositedAt,
            AC_NAM_Reliability,
            AC_NAM_Actor_Name,
            AC_GEN_AC_ID,
            Metadata_AC_GEN,
            AC_GEN_Positor,
            AC_GEN_PositedAt,
            AC_GEN_Reliability,
            AC_GEN_GEN_Gender,
            AC_GEN_GEN_Checksum,
            AC_GEN_Metadata_GEN,
            AC_GEN_GEN_ID,
            AC_PLV_AC_ID,
            Metadata_AC_PLV,
            AC_PLV_ChangedAt,
            AC_PLV_Positor,
            AC_PLV_PositedAt,
            AC_PLV_Reliability,
            AC_PLV_PLV_ProfessionalLevel,
            AC_PLV_PLV_Checksum,
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
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Positor,
        AC_NAM_Reliability
    )
    SELECT
        i.Metadata_AC_NAM,
        i.AC_NAM_AC_ID,
        i.AC_NAM_Actor_Name,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Positor,
        i.AC_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.AC_NAM_Actor_Name is not null;
    INSERT INTO [attributes].[AC_GEN_Actor_Gender] (
        Metadata_AC_GEN,
        AC_GEN_AC_ID,
        AC_GEN_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Positor,
        AC_GEN_Reliability
    )
    SELECT
        i.Metadata_AC_GEN,
        i.AC_GEN_AC_ID,
        ISNULL(i.AC_GEN_GEN_ID, [kGEN].GEN_ID),
        i.AC_GEN_PositedAt,
        i.AC_GEN_Positor,
        i.AC_GEN_Reliability
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
        AC_PLV_PLV_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Positor,
        AC_PLV_Reliability
    )
    SELECT
        i.Metadata_AC_PLV,
        i.AC_PLV_AC_ID,
        ISNULL(i.AC_PLV_PLV_ID, [kPLV].PLV_ID),
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Positor,
        i.AC_PLV_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [knots].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.AC_PLV_PLV_Checksum
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
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_Positor bit = CASE WHEN UPDATE(Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_ID))
        RAISERROR('The identity column AC_ID is not updatable.', 16, 1);
    DECLARE @updated_AC_NAM_Actor_Name bit = CASE WHEN UPDATE(AC_NAM_Actor_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_NAM bit = CASE WHEN UPDATE(Metadata_AC_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_ChangedAt bit = CASE WHEN UPDATE(AC_NAM_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_PositedAt bit = CASE WHEN UPDATE(AC_NAM_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_Reliability bit = CASE WHEN UPDATE(AC_NAM_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_NAM_Positor bit = CASE WHEN UPDATE(AC_NAM_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_NAM_ID))
        RAISERROR('The identity column AC_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_NAM_AC_ID))
        RAISERROR('The foreign key column AC_NAM_AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_NAM_Assertion))
        RAISERROR('The computed assertion column AC_NAM_Assertion is not updatable.', 16, 1);
    IF (
        @updated_AC_NAM_Actor_Name = 1 OR
        @updated_AC_NAM_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[AC_NAM_Actor_Name] (
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_NAM = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_NAM
            END, i.Metadata_AC),
            ISNULL(i.AC_NAM_AC_ID, i.AC_ID),
            i.AC_NAM_Actor_Name,
            cast(ISNULL(CASE
                WHEN @updated_AC_NAM_ChangedAt = 1 THEN i.AC_NAM_ChangedAt
                WHEN d.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
                THEN i.AC_NAM_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_AC_NAM_PositedAt = 1 THEN i.AC_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_NAM_Positor = 1 THEN i.AC_NAM_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_AC_NAM_Reliability = 1 THEN i.AC_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.AC_NAM_Actor_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_AC_NAM_ChangedAt = 1 OR
            @updated_AC_NAM_PositedAt = 1 OR
            @updated_AC_NAM_Positor = 1 OR
            @updated_Positor = 1 OR
            d.AC_NAM_Actor_Name is null OR
            d.AC_NAM_Actor_Name <> i.AC_NAM_Actor_Name OR
            d.AC_NAM_Reliability <> ISNULL(CASE
                WHEN @updated_AC_NAM_Reliability = 1 THEN i.AC_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_AC_NAM_Actor_Name = 1
    )
    BEGIN
        INSERT INTO [attributes].[AC_NAM_Actor_Name] (
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_NAM = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_NAM
            END, i.Metadata_AC),
            p.AC_NAM_AC_ID,
            p.AC_NAM_Actor_Name,
            p.AC_NAM_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_AC_NAM_PositedAt = 1 THEN i.AC_NAM_PositedAt
                WHEN @updated_AC_NAM_ChangedAt = 1 THEN i.AC_NAM_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_NAM_Positor = 1 THEN i.AC_NAM_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[AC_NAM_Actor_Name_Posit] p
        ON
            p.AC_NAM_ID = i.AC_NAM_ID
        WHERE
            i.AC_NAM_Actor_Name is null
    END
    DECLARE @updated_AC_GEN_GEN_ID bit = CASE WHEN UPDATE(AC_GEN_GEN_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_GEN_Gender bit = CASE WHEN UPDATE(AC_GEN_GEN_Gender) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_GEN bit = CASE WHEN UPDATE(Metadata_AC_GEN) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_PositedAt bit = CASE WHEN UPDATE(AC_GEN_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_Reliability bit = CASE WHEN UPDATE(AC_GEN_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_GEN_Positor bit = CASE WHEN UPDATE(AC_GEN_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_GEN_ID))
        RAISERROR('The identity column AC_GEN_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_GEN_AC_ID))
        RAISERROR('The foreign key column AC_GEN_AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_GEN_Assertion))
        RAISERROR('The computed assertion column AC_GEN_Assertion is not updatable.', 16, 1);
    IF (
        @updated_AC_GEN_GEN_ID = 1 OR
        @updated_AC_GEN_GEN_Gender = 1 OR
        @updated_AC_GEN_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[AC_GEN_Actor_Gender] (
            Metadata_AC_GEN,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Positor,
            AC_GEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_GEN = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_GEN
            END, i.Metadata_AC),
            ISNULL(i.AC_GEN_AC_ID, i.AC_ID),
            CASE
                WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID
                ELSE [kGEN].GEN_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_AC_GEN_PositedAt = 1 THEN i.AC_GEN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_GEN_Positor = 1 THEN i.AC_GEN_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_AC_GEN_Reliability = 1 THEN i.AC_GEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_GEN_Reliability
            END, 1)
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
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID
                ELSE [kGEN].GEN_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_AC_GEN_PositedAt = 1 OR
            @updated_AC_GEN_Positor = 1 OR
            @updated_Positor = 1 OR
            d.AC_GEN_GEN_ID is null OR
            d.AC_GEN_GEN_ID <> CASE WHEN @updated_AC_GEN_GEN_ID = 1 THEN i.AC_GEN_GEN_ID ELSE [kGEN].GEN_ID END OR
            d.AC_GEN_Reliability <> ISNULL(CASE
                WHEN @updated_AC_GEN_Reliability = 1 THEN i.AC_GEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_GEN_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_AC_GEN_GEN_ID = 1 OR
        @updated_AC_GEN_GEN_Gender = 1
    )
    BEGIN
        INSERT INTO [attributes].[AC_GEN_Actor_Gender] (
            Metadata_AC_GEN,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Positor,
            AC_GEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_GEN = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_GEN
            END, i.Metadata_AC),
            p.AC_GEN_AC_ID,
            p.AC_GEN_GEN_ID,
            cast(ISNULL(CASE
                WHEN @updated_AC_GEN_PositedAt = 1 THEN i.AC_GEN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_GEN_Positor = 1 THEN i.AC_GEN_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[AC_GEN_Actor_Gender_Posit] p
        ON
            p.AC_GEN_ID = i.AC_GEN_ID
        WHERE
            (@updated_AC_GEN_GEN_ID = 1 AND i.AC_GEN_GEN_ID is null)
        OR
            (@updated_AC_GEN_GEN_Gender = 1 AND i.AC_GEN_GEN_Gender is null);
    END
    DECLARE @updated_AC_PLV_PLV_ID bit = CASE WHEN UPDATE(AC_PLV_PLV_ID) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_PLV_ProfessionalLevel bit = CASE WHEN UPDATE(AC_PLV_PLV_ProfessionalLevel) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_AC_PLV bit = CASE WHEN UPDATE(Metadata_AC_PLV) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_ChangedAt bit = CASE WHEN UPDATE(AC_PLV_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_PositedAt bit = CASE WHEN UPDATE(AC_PLV_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_Reliability bit = CASE WHEN UPDATE(AC_PLV_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_PLV_Positor bit = CASE WHEN UPDATE(AC_PLV_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_PLV_ID))
        RAISERROR('The identity column AC_PLV_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_PLV_AC_ID))
        RAISERROR('The foreign key column AC_PLV_AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_PLV_Assertion))
        RAISERROR('The computed assertion column AC_PLV_Assertion is not updatable.', 16, 1);
    IF (
        @updated_AC_PLV_PLV_ID = 1 OR
        @updated_AC_PLV_PLV_ProfessionalLevel = 1 OR
        @updated_AC_PLV_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel] (
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_PLV = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_PLV
            END, i.Metadata_AC),
            ISNULL(i.AC_PLV_AC_ID, i.AC_ID),
            CASE
                WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID
                ELSE [kPLV].PLV_ID
            END,
            cast(ISNULL(CASE
                WHEN @updated_AC_PLV_ChangedAt = 1 THEN i.AC_PLV_ChangedAt
                WHEN d.AC_PLV_PLV_ID = CASE WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END
                THEN i.AC_PLV_ChangedAt -- the shown version is asserted again
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN @updated_AC_PLV_PositedAt = 1 THEN i.AC_PLV_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_PLV_Positor = 1 THEN i.AC_PLV_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_AC_PLV_Reliability = 1 THEN i.AC_PLV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_PLV_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [knots].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dw.MD5(cast(i.AC_PLV_PLV_ProfessionalLevel as varbinary(max)))
        LEFT JOIN
            deleted d
        ON
            d.AC_ID = i.AC_ID
        AND
            d.Positor = i.Positor
        WHERE
            CASE
                WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID
                ELSE [kPLV].PLV_ID
            END is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_AC_PLV_ChangedAt = 1 OR
            @updated_AC_PLV_PositedAt = 1 OR
            @updated_AC_PLV_Positor = 1 OR
            @updated_Positor = 1 OR
            d.AC_PLV_PLV_ID is null OR
            d.AC_PLV_PLV_ID <> CASE WHEN @updated_AC_PLV_PLV_ID = 1 THEN i.AC_PLV_PLV_ID ELSE [kPLV].PLV_ID END OR
            d.AC_PLV_Reliability <> ISNULL(CASE
                WHEN @updated_AC_PLV_Reliability = 1 THEN i.AC_PLV_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.AC_PLV_Reliability
            END, 1)
        );
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_AC_PLV_PLV_ID = 1 OR
        @updated_AC_PLV_PLV_ProfessionalLevel = 1
    )
    BEGIN
        INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel] (
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_AC = 1 AND @updated_Metadata_AC_PLV = 0
                THEN i.Metadata_AC
                ELSE i.Metadata_AC_PLV
            END, i.Metadata_AC),
            p.AC_PLV_AC_ID,
            p.AC_PLV_PLV_ID,
            p.AC_PLV_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_AC_PLV_PositedAt = 1 THEN i.AC_PLV_PositedAt
                WHEN @updated_AC_PLV_ChangedAt = 1 THEN i.AC_PLV_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_AC_PLV_Positor = 1 THEN i.AC_PLV_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        ON
            p.AC_PLV_ID = i.AC_PLV_ID
        WHERE
            (@updated_AC_PLV_PLV_ID = 1 AND i.AC_PLV_PLV_ID is null)
        OR
            (@updated_AC_PLV_PLV_ProfessionalLevel = 1 AND i.AC_PLV_PLV_ProfessionalLevel is null);
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [attributes].[AC_NAM_Actor_Name_Annex] (
        Metadata_AC_NAM,
        AC_NAM_ID,
        AC_NAM_Positor,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        d.Metadata_AC_NAM,
        d.AC_NAM_ID,
        d.AC_NAM_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.AC_NAM_ID is not null;
    INSERT INTO [attributes].[AC_GEN_Actor_Gender_Annex] (
        Metadata_AC_GEN,
        AC_GEN_ID,
        AC_GEN_Positor,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        d.Metadata_AC_GEN,
        d.AC_GEN_ID,
        d.AC_GEN_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.AC_GEN_ID is not null;
    INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        Metadata_AC_PLV,
        AC_PLV_ID,
        AC_PLV_Positor,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        d.Metadata_AC_PLV,
        d.AC_PLV_ID,
        d.AC_PLV_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.AC_PLV_ID is not null;
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
        PR_NAM_Positor tinyint null,
        PR_NAM_PositedAt datetime2 null,
        PR_NAM_Reliability decimal(5,2) null,
        PR_NAM_Program_Name nvarchar(42) null,
        PR_LEN_PR_ID bigint null,
        Metadata_PR_LEN int null,
        PR_LEN_ChangedAt date null,
        PR_LEN_Positor tinyint null,
        PR_LEN_PositedAt datetime2 null,
        PR_LEN_Reliability decimal(5,2) null,
        PR_LEN_Program_Length time null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PR_ID, a.PR_ID),
        i.Metadata_PR,
        ISNULL(ISNULL(i.PR_NAM_PR_ID, i.PR_ID), a.PR_ID),
        ISNULL(i.Metadata_PR_NAM, i.Metadata_PR),
        ISNULL(ISNULL(i.PR_NAM_Positor, i.Positor), 0),
        ISNULL(i.PR_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.PR_NAM_Reliability, i.Reliability), 1),
        i.PR_NAM_Program_Name,
        ISNULL(ISNULL(i.PR_LEN_PR_ID, i.PR_ID), a.PR_ID),
        ISNULL(i.Metadata_PR_LEN, i.Metadata_PR),
        ISNULL(i.PR_LEN_ChangedAt, @now),
        ISNULL(ISNULL(i.PR_LEN_Positor, i.Positor), 0),
        ISNULL(i.PR_LEN_PositedAt, @now),
        ISNULL(ISNULL(i.PR_LEN_Reliability, i.Reliability), 1),
        i.PR_LEN_Program_Length
    FROM (
        SELECT
            Positor,
            Reliability,
            PR_ID,
            Metadata_PR,
            PR_NAM_PR_ID,
            Metadata_PR_NAM,
            PR_NAM_Positor,
            PR_NAM_PositedAt,
            PR_NAM_Reliability,
            PR_NAM_Program_Name,
            PR_LEN_PR_ID,
            Metadata_PR_LEN,
            PR_LEN_ChangedAt,
            PR_LEN_Positor,
            PR_LEN_PositedAt,
            PR_LEN_Reliability,
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
        PR_NAM_Program_Name,
        PR_NAM_PositedAt,
        PR_NAM_Positor,
        PR_NAM_Reliability
    )
    SELECT
        i.Metadata_PR_NAM,
        i.PR_NAM_PR_ID,
        i.PR_NAM_Program_Name,
        i.PR_NAM_PositedAt,
        i.PR_NAM_Positor,
        i.PR_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.PR_NAM_Program_Name is not null;
    INSERT INTO [attributes].[PR_LEN_Program_Length] (
        Metadata_PR_LEN,
        PR_LEN_PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Positor,
        PR_LEN_Reliability
    )
    SELECT
        i.Metadata_PR_LEN,
        i.PR_LEN_PR_ID,
        i.PR_LEN_Program_Length,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_PositedAt,
        i.PR_LEN_Positor,
        i.PR_LEN_Reliability
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
    DECLARE @updated_Reliability bit = CASE WHEN UPDATE(Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_Positor bit = CASE WHEN UPDATE(Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_ID))
        RAISERROR('The identity column PR_ID is not updatable.', 16, 1);
    DECLARE @updated_PR_NAM_Program_Name bit = CASE WHEN UPDATE(PR_NAM_Program_Name) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_PR_NAM bit = CASE WHEN UPDATE(Metadata_PR_NAM) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_NAM_PositedAt bit = CASE WHEN UPDATE(PR_NAM_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_NAM_Reliability bit = CASE WHEN UPDATE(PR_NAM_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_NAM_Positor bit = CASE WHEN UPDATE(PR_NAM_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_NAM_ID))
        RAISERROR('The identity column PR_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_NAM_PR_ID))
        RAISERROR('The foreign key column PR_NAM_PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_NAM_Assertion))
        RAISERROR('The computed assertion column PR_NAM_Assertion is not updatable.', 16, 1);
    IF (
        @updated_PR_NAM_Program_Name = 1 OR
        @updated_PR_NAM_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[PR_NAM_Program_Name] (
            Metadata_PR_NAM,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name,
            PR_NAM_PositedAt,
            PR_NAM_Positor,
            PR_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_NAM = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_NAM
            END, i.Metadata_PR),
            ISNULL(i.PR_NAM_PR_ID, i.PR_ID),
            i.PR_NAM_Program_Name,
            cast(ISNULL(CASE
                WHEN @updated_PR_NAM_PositedAt = 1 THEN i.PR_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_PR_NAM_Positor = 1 THEN i.PR_NAM_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_PR_NAM_Reliability = 1 THEN i.PR_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_NAM_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.PR_ID = i.PR_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.PR_NAM_Program_Name is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_PR_NAM_PositedAt = 1 OR
            @updated_PR_NAM_Positor = 1 OR
            @updated_Positor = 1 OR
            d.PR_NAM_Program_Name is null OR
            d.PR_NAM_Program_Name <> i.PR_NAM_Program_Name OR
            d.PR_NAM_Reliability <> ISNULL(CASE
                WHEN @updated_PR_NAM_Reliability = 1 THEN i.PR_NAM_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_NAM_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_PR_NAM_Program_Name = 1
    )
    BEGIN
        INSERT INTO [attributes].[PR_NAM_Program_Name] (
            Metadata_PR_NAM,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name,
            PR_NAM_PositedAt,
            PR_NAM_Positor,
            PR_NAM_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_NAM = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_NAM
            END, i.Metadata_PR),
            p.PR_NAM_PR_ID,
            p.PR_NAM_Program_Name,
            cast(ISNULL(CASE
                WHEN @updated_PR_NAM_PositedAt = 1 THEN i.PR_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_PR_NAM_Positor = 1 THEN i.PR_NAM_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[PR_NAM_Program_Name_Posit] p
        ON
            p.PR_NAM_ID = i.PR_NAM_ID
        WHERE
            i.PR_NAM_Program_Name is null
    END
    DECLARE @updated_PR_LEN_Program_Length bit = CASE WHEN UPDATE(PR_LEN_Program_Length) THEN 1 ELSE 0 END;
    DECLARE @updated_Metadata_PR_LEN bit = CASE WHEN UPDATE(Metadata_PR_LEN) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_ChangedAt bit = CASE WHEN UPDATE(PR_LEN_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_PositedAt bit = CASE WHEN UPDATE(PR_LEN_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_Reliability bit = CASE WHEN UPDATE(PR_LEN_Reliability) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_LEN_Positor bit = CASE WHEN UPDATE(PR_LEN_Positor) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_LEN_ID))
        RAISERROR('The identity column PR_LEN_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_LEN_PR_ID))
        RAISERROR('The foreign key column PR_LEN_PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_LEN_Assertion))
        RAISERROR('The computed assertion column PR_LEN_Assertion is not updatable.', 16, 1);
    IF (
        @updated_PR_LEN_Program_Length = 1 OR
        @updated_PR_LEN_Reliability = 1 OR
        @updated_Reliability = 1
    )
    BEGIN
        INSERT INTO [attributes].[PR_LEN_Program_Length] (
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_LEN = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_LEN
            END, i.Metadata_PR),
            ISNULL(i.PR_LEN_PR_ID, i.PR_ID),
            i.PR_LEN_Program_Length,
            cast(ISNULL(CASE
                WHEN @updated_PR_LEN_ChangedAt = 1 THEN i.PR_LEN_ChangedAt
                WHEN d.PR_LEN_Program_Length = i.PR_LEN_Program_Length
                THEN i.PR_LEN_ChangedAt -- the shown version is asserted again
            END, @now) as date),
            cast(ISNULL(CASE
                WHEN @updated_PR_LEN_PositedAt = 1 THEN i.PR_LEN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_PR_LEN_Positor = 1 THEN i.PR_LEN_Positor
                ELSE i.Positor
            END, 0),
            ISNULL(CASE
                WHEN @updated_PR_LEN_Reliability = 1 THEN i.PR_LEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_LEN_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            deleted d
        ON
            d.PR_ID = i.PR_ID
        AND
            d.Positor = i.Positor
        WHERE
            i.PR_LEN_Program_Length is not null
        AND ( -- a statement that leaves everything as it is states nothing
            @updated_PR_LEN_ChangedAt = 1 OR
            @updated_PR_LEN_PositedAt = 1 OR
            @updated_PR_LEN_Positor = 1 OR
            @updated_Positor = 1 OR
            d.PR_LEN_Program_Length is null OR
            d.PR_LEN_Program_Length <> i.PR_LEN_Program_Length OR
            d.PR_LEN_Reliability <> ISNULL(CASE
                WHEN @updated_PR_LEN_Reliability = 1 THEN i.PR_LEN_Reliability
                WHEN @updated_Reliability = 1 THEN i.Reliability
                ELSE i.PR_LEN_Reliability
            END, 1)
        )
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        @updated_PR_LEN_Program_Length = 1
    )
    BEGIN
        INSERT INTO [attributes].[PR_LEN_Program_Length] (
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability
        )
        SELECT
            ISNULL(CASE
                WHEN @updated_Metadata_PR = 1 AND @updated_Metadata_PR_LEN = 0
                THEN i.Metadata_PR
                ELSE i.Metadata_PR_LEN
            END, i.Metadata_PR),
            p.PR_LEN_PR_ID,
            p.PR_LEN_Program_Length,
            p.PR_LEN_ChangedAt,
            cast(ISNULL(CASE
                WHEN @updated_PR_LEN_PositedAt = 1 THEN i.PR_LEN_PositedAt
                WHEN @updated_PR_LEN_ChangedAt = 1 THEN i.PR_LEN_ChangedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN @updated_PR_LEN_Positor = 1 THEN i.PR_LEN_Positor
                ELSE i.Positor
            END, 0),
            0
        FROM
            inserted i
        JOIN
            [attributes].[PR_LEN_Program_Length_Posit] p
        ON
            p.PR_LEN_ID = i.PR_LEN_ID
        WHERE
            i.PR_LEN_Program_Length is null
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
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [attributes].[PR_NAM_Program_Name_Annex] (
        Metadata_PR_NAM,
        PR_NAM_ID,
        PR_NAM_Positor,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        d.Metadata_PR_NAM,
        d.PR_NAM_ID,
        d.PR_NAM_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.PR_NAM_ID is not null;
    INSERT INTO [attributes].[PR_LEN_Program_Length_Annex] (
        Metadata_PR_LEN,
        PR_LEN_ID,
        PR_LEN_Positor,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        d.Metadata_PR_LEN,
        d.PR_LEN_ID,
        d.PR_LEN_Positor,
        @now,
        0
    FROM
        deleted d
    WHERE
        d.PR_LEN_ID is not null;
END
GO
