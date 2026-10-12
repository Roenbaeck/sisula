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
CREATE TRIGGER [dbo].[it_lST_Stage] ON [dbo].[lST_Stage]
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
    INSERT INTO [dbo].[ST_Stage] (
        ST_Dummy
    )
    OUTPUT
        inserted.ST_ID
    INTO
        @ST
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.ST_ID is null;
    DECLARE @inserted TABLE (
        ST_ID int not null,
        ST_NAM_ChangedAt datetime2 null,
        ST_NAM_PositedAt datetime2 null,
        ST_NAM_Reliability decimal(5,2) null,
        ST_NAM_Stage_Name nvarchar(42) null,
        ST_LOC_PositedAt datetime2 null,
        ST_LOC_Reliability decimal(5,2) null,
        ST_LOC_Stage_Location geography null,
        ST_AVG_ChangedAt datetime2 null,
        ST_AVG_PositedAt datetime2 null,
        ST_AVG_Reliability decimal(5,2) null,
        UTL_Utilization tinyint null,
        UTL_ID tinyint null,
        ST_MIN_PositedAt datetime2 null,
        ST_MIN_Reliability decimal(5,2) null,
        UTL_Utilization tinyint null,
        UTL_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_ID, a.ST_ID),
        ISNULL(i.ST_NAM_ChangedAt, @now),
        ISNULL(i.ST_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.ST_NAM_Reliability, i.Reliability), 1),
        i.ST_NAM_Stage_Name,
        ISNULL(i.ST_LOC_PositedAt, @now),
        ISNULL(ISNULL(i.ST_LOC_Reliability, i.Reliability), 1),
        i.ST_LOC_Stage_Location,
        ISNULL(i.ST_AVG_ChangedAt, @now),
        ISNULL(i.ST_AVG_PositedAt, @now),
        ISNULL(ISNULL(i.ST_AVG_Reliability, i.Reliability), 1),
        i.UTL_Utilization,
        i.UTL_ID,
        ISNULL(i.ST_MIN_PositedAt, @now),
        ISNULL(ISNULL(i.ST_MIN_Reliability, i.Reliability), 1),
        i.UTL_Utilization,
        i.UTL_ID
    FROM (
        SELECT
            Reliability,
            ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Reliability,
            ST_NAM_Stage_Name,
            ST_LOC_PositedAt,
            ST_LOC_Reliability,
            ST_LOC_Stage_Location,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Reliability,
            UTL_Utilization,
            UTL_ID,
            ST_MIN_PositedAt,
            ST_MIN_Reliability,
            UTL_Utilization,
            UTL_ID,
            ROW_NUMBER() OVER (PARTITION BY ST_ID ORDER BY ST_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @ST a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[ST_NAM_Stage_Name] (
        ST_ID,
        ST_NAM_Stage_Name,
        ST_NAM_ChangedAt,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        i.ST_ID,
        i.ST_NAM_Stage_Name,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.ST_NAM_Stage_Name is not null;
    INSERT INTO [dbo].[ST_LOC_Stage_Location] (
        ST_ID,
        ST_LOC_Stage_Location,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        i.ST_ID,
        i.ST_LOC_Stage_Location,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Reliability
    FROM
        @inserted i
    WHERE
        i.ST_LOC_Stage_Location is not null;
    INSERT INTO [dbo].[ST_AVG_Stage_Average] (
        ST_ID,
        UTL_ID,
        ST_AVG_ChangedAt,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        i.ST_ID,
        ISNULL(i.UTL_ID, [kUTL].UTL_ID), 
        i.ST_AVG_ChangedAt,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.UTL_Utilization
    WHERE
        ISNULL(i.UTL_ID, [kUTL].UTL_ID) is not null;
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
        ST_ID,
        UTL_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        i.ST_ID,
        ISNULL(i.UTL_ID, [kUTL].UTL_ID), 
        i.ST_MIN_PositedAt,
        i.ST_MIN_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[UTL_Utilization] [kUTL]
    ON
        [kUTL].UTL_Utilization = i.UTL_Utilization
    WHERE
        ISNULL(i.UTL_ID, [kUTL].UTL_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Stage instead of UPDATE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(ST_ID))
        RAISERROR('The identity column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_ID))
        RAISERROR('The identity column ST_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF (
        UPDATE(ST_NAM_Stage_Name) OR
        UPDATE(ST_NAM_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[ST_NAM_Stage_Name] (
            ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            ISNULL(i.ST_ID, i.ST_ID),
            i.ST_NAM_Stage_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(Reliability) AND NOT UPDATE(ST_NAM_ChangedAt) THEN i.ST_NAM_ChangedAt
                WHEN UPDATE(ST_NAM_ChangedAt) THEN i.ST_NAM_ChangedAt
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(ST_NAM_PositedAt) THEN i.ST_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(ST_NAM_Reliability) THEN i.ST_NAM_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.ST_NAM_Reliability
            END, 1)
        FROM
            inserted i
        WHERE
            i.ST_NAM_Stage_Name is not null
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(ST_NAM_Stage_Name) 
    )
    BEGIN
        INSERT INTO [dbo].[ST_NAM_Stage_Name] (
            ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            p.ST_ID,
            p.ST_NAM_Stage_Name,
            p.ST_NAM_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(ST_NAM_PositedAt) THEN i.ST_NAM_PositedAt
                WHEN UPDATE(ST_NAM_ChangedAt) THEN i.ST_NAM_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[ST_NAM_Stage_Name_Posit] p
        ON
            p.ST_NAM_ID = i.ST_NAM_ID
        WHERE
            i.ST_NAM_Stage_Name is null
    END
    IF(UPDATE(ST_LOC_ID))
        RAISERROR('The identity column ST_LOC_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF (
        UPDATE(ST_LOC_Stage_Location) OR
        UPDATE(ST_LOC_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[ST_LOC_Stage_Location] (
            ST_ID,
            ST_LOC_Stage_Location,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            ISNULL(i.ST_ID, i.ST_ID),
            i.ST_LOC_Stage_Location,
            cast(ISNULL(CASE
                WHEN UPDATE(ST_LOC_PositedAt) THEN i.ST_LOC_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(ST_LOC_Reliability) THEN i.ST_LOC_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.ST_LOC_Reliability
            END, 1)
        FROM
            inserted i
        WHERE
            i.ST_LOC_ID is null
        AND
            i.ST_LOC_Stage_Location is not null
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(ST_LOC_Stage_Location) 
    )
    BEGIN
        INSERT INTO [dbo].[ST_LOC_Stage_Location] (
            ST_ID,
            ST_LOC_Stage_Location,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            p.ST_ID,
            p.ST_LOC_Stage_Location,
            cast(ISNULL(CASE
                WHEN UPDATE(ST_LOC_PositedAt) THEN i.ST_LOC_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[ST_LOC_Stage_Location_Posit] p
        ON
            p.ST_LOC_ID = i.ST_LOC_ID
        WHERE
            i.ST_LOC_Stage_Location is null
    END
    IF(UPDATE(ST_AVG_ID))
        RAISERROR('The identity column ST_AVG_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF (
        UPDATE(UTL_ID) OR
        UPDATE(UTL_Utilization) OR
        UPDATE(ST_AVG_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[ST_AVG_Stage_Average] (
            ST_ID,
            UTL_ID,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            ISNULL(i.ST_ID, i.ST_ID),
            CASE
                WHEN UPDATE(UTL_ID) THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(Reliability) AND NOT UPDATE(ST_AVG_ChangedAt) THEN i.ST_AVG_ChangedAt
                WHEN UPDATE(ST_AVG_ChangedAt) THEN i.ST_AVG_ChangedAt
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(ST_AVG_PositedAt) THEN i.ST_AVG_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(ST_AVG_Reliability) THEN i.ST_AVG_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.ST_AVG_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.UTL_Utilization
        WHERE
            CASE
                WHEN UPDATE(UTL_ID) THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(UTL_ID) OR
        UPDATE(UTL_Utilization) 
    )
    BEGIN
        INSERT INTO [dbo].[ST_AVG_Stage_Average] (
            ST_ID,
            UTL_ID,
            ST_AVG_ChangedAt,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            p.ST_ID,
            p.UTL_ID,
            p.ST_AVG_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(ST_AVG_PositedAt) THEN i.ST_AVG_PositedAt
                WHEN UPDATE(ST_AVG_ChangedAt) THEN i.ST_AVG_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[ST_AVG_Stage_Average_Posit] p
        ON
            p.ST_AVG_ID = i.ST_AVG_ID
        WHERE
            (UPDATE(UTL_ID) AND i.UTL_ID is null)
        OR 
            (UPDATE(UTL_Utilization) AND i.UTL_Utilization is null);
    END
    IF(UPDATE(ST_MIN_ID))
        RAISERROR('The identity column ST_MIN_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF (
        UPDATE(UTL_ID) OR
        UPDATE(UTL_Utilization) OR
        UPDATE(ST_MIN_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
            ST_ID,
            UTL_ID,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            ISNULL(i.ST_ID, i.ST_ID),
            CASE
                WHEN UPDATE(UTL_ID) THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(ST_MIN_PositedAt) THEN i.ST_MIN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(ST_MIN_Reliability) THEN i.ST_MIN_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.ST_MIN_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.UTL_Utilization
        WHERE
            i.ST_MIN_ID is null
        AND
            CASE
                WHEN UPDATE(UTL_ID) THEN i.UTL_ID
                ELSE [kUTL].UTL_ID
            END is not null;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(UTL_ID) OR
        UPDATE(UTL_Utilization) 
    )
    BEGIN
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
            ST_ID,
            UTL_ID,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            p.ST_ID,
            p.UTL_ID,
            cast(ISNULL(CASE
                WHEN UPDATE(ST_MIN_PositedAt) THEN i.ST_MIN_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        ON
            p.ST_MIN_ID = i.ST_MIN_ID
        WHERE
            (UPDATE(UTL_ID) AND i.UTL_ID is null)
        OR 
            (UPDATE(UTL_Utilization) AND i.UTL_Utilization is null);
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Stage instead of DELETE trigger on lST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_Stage] ON [dbo].[lST_Stage]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
        ST_NAM_ID,
        ST_NAM_PositedAt,
        ST_NAM_Reliability
    )
    SELECT
        p.ST_NAM_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[ST_NAM_Stage_Name_Annex] p
    ON
        p.ST_NAM_ID = d.ST_NAM_ID;
    INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
        ST_LOC_ID,
        ST_LOC_PositedAt,
        ST_LOC_Reliability
    )
    SELECT
        p.ST_LOC_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[ST_LOC_Stage_Location_Annex] p
    ON
        p.ST_LOC_ID = d.ST_LOC_ID;
    INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
        ST_AVG_ID,
        ST_AVG_PositedAt,
        ST_AVG_Reliability
    )
    SELECT
        p.ST_AVG_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[ST_AVG_Stage_Average_Annex] p
    ON
        p.ST_AVG_ID = d.ST_AVG_ID;
    INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
        ST_MIN_ID,
        ST_MIN_PositedAt,
        ST_MIN_Reliability
    )
    SELECT
        p.ST_MIN_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[ST_MIN_Stage_Minimum_Annex] p
    ON
        p.ST_MIN_ID = d.ST_MIN_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Actor instead of INSERT trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @AC TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        AC_ID int not null
    );
    INSERT INTO [dbo].[AC_Actor] (
        AC_Dummy
    )
    OUTPUT
        inserted.AC_ID
    INTO
        @AC
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.AC_ID is null;
    DECLARE @inserted TABLE (
        AC_ID int not null,
        AC_NAM_ChangedAt datetime2 null,
        AC_NAM_PositedAt datetime2 null,
        AC_NAM_Reliability decimal(5,2) null,
        AC_NAM_Actor_Name nvarchar(42) null,
        AC_GEN_PositedAt datetime2 null,
        AC_GEN_Reliability decimal(5,2) null,
        GEN_Gender nvarchar(42) null,
        GEN_ID tinyint null,
        AC_PLV_ChangedAt datetime2 null,
        AC_PLV_PositedAt datetime2 null,
        AC_PLV_Reliability decimal(5,2) null,
        PLV_ProfessionalLevel nvarchar(max) null,
        PLV_Checksum varbinary(16) null,
        PLV_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.AC_ID, a.AC_ID),
        ISNULL(i.AC_NAM_ChangedAt, @now),
        ISNULL(i.AC_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.AC_NAM_Reliability, i.Reliability), 1),
        i.AC_NAM_Actor_Name,
        ISNULL(i.AC_GEN_PositedAt, @now),
        ISNULL(ISNULL(i.AC_GEN_Reliability, i.Reliability), 1),
        i.GEN_Gender,
        i.GEN_ID,
        ISNULL(i.AC_PLV_ChangedAt, @now),
        ISNULL(i.AC_PLV_PositedAt, @now),
        ISNULL(ISNULL(i.AC_PLV_Reliability, i.Reliability), 1),
        i.PLV_ProfessionalLevel,
        ISNULL(i.PLV_Checksum, dbo.MD5(cast(i.PLV_ProfessionalLevel as varbinary(max)))),
        i.PLV_ID
    FROM (
        SELECT
            Reliability,
            AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Reliability,
            AC_NAM_Actor_Name,
            AC_GEN_PositedAt,
            AC_GEN_Reliability,
            GEN_Gender,
            GEN_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Reliability,
            PLV_ProfessionalLevel,
            PLV_Checksum,
            PLV_ID,
            ROW_NUMBER() OVER (PARTITION BY AC_ID ORDER BY AC_ID) AS Row
        FROM
            inserted
    ) i
    LEFT JOIN
        @AC a
    ON
        a.Row = i.Row;
    INSERT INTO [dbo].[AC_NAM_Actor_Name] (
        AC_ID,
        AC_NAM_Actor_Name,
        AC_NAM_ChangedAt,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        i.AC_ID,
        i.AC_NAM_Actor_Name,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.AC_NAM_Actor_Name is not null;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
        AC_ID,
        GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        i.AC_ID,
        ISNULL(i.GEN_ID, [kGEN].GEN_ID), 
        i.AC_GEN_PositedAt,
        i.AC_GEN_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[GEN_Gender] [kGEN]
    ON
        [kGEN].GEN_Gender = i.GEN_Gender
    WHERE
        ISNULL(i.GEN_ID, [kGEN].GEN_ID) is not null;
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
        AC_ID,
        PLV_ID,
        AC_PLV_ChangedAt,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        i.AC_ID,
        ISNULL(i.PLV_ID, [kPLV].PLV_ID), 
        i.AC_PLV_ChangedAt,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Reliability
    FROM
        @inserted i
    LEFT JOIN
        [dbo].[PLV_ProfessionalLevel] [kPLV]
    ON
        [kPLV].PLV_Checksum = i.PLV_Checksum 
    WHERE
        ISNULL(i.PLV_ID, [kPLV].PLV_ID) is not null;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Actor instead of UPDATE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(AC_ID))
        RAISERROR('The identity column AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_NAM_ID))
        RAISERROR('The identity column AC_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_ID))
        RAISERROR('The foreign key column AC_ID is not updatable.', 16, 1);
    IF (
        UPDATE(AC_NAM_Actor_Name) OR
        UPDATE(AC_NAM_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[AC_NAM_Actor_Name] (
            AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            ISNULL(i.AC_ID, i.AC_ID),
            i.AC_NAM_Actor_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(Reliability) AND NOT UPDATE(AC_NAM_ChangedAt) THEN i.AC_NAM_ChangedAt
                WHEN UPDATE(AC_NAM_ChangedAt) THEN i.AC_NAM_ChangedAt
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(AC_NAM_PositedAt) THEN i.AC_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(AC_NAM_Reliability) THEN i.AC_NAM_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.AC_NAM_Reliability
            END, 1)
        FROM
            inserted i
        WHERE
            i.AC_NAM_Actor_Name is not null
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(AC_NAM_Actor_Name) 
    )
    BEGIN
        INSERT INTO [dbo].[AC_NAM_Actor_Name] (
            AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            p.AC_ID,
            p.AC_NAM_Actor_Name,
            p.AC_NAM_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(AC_NAM_PositedAt) THEN i.AC_NAM_PositedAt
                WHEN UPDATE(AC_NAM_ChangedAt) THEN i.AC_NAM_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[AC_NAM_Actor_Name_Posit] p
        ON
            p.AC_NAM_ID = i.AC_NAM_ID
        WHERE
            i.AC_NAM_Actor_Name is null
    END
    IF(UPDATE(AC_GEN_ID))
        RAISERROR('The identity column AC_GEN_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_ID))
        RAISERROR('The foreign key column AC_ID is not updatable.', 16, 1);
    IF (
        UPDATE(GEN_ID) OR
        UPDATE(GEN_Gender) OR
        UPDATE(AC_GEN_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
            AC_ID,
            GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            ISNULL(i.AC_ID, i.AC_ID),
            CASE
                WHEN UPDATE(GEN_ID) THEN i.GEN_ID
                ELSE [kGEN].GEN_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(AC_GEN_PositedAt) THEN i.AC_GEN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(AC_GEN_Reliability) THEN i.AC_GEN_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.AC_GEN_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GEN_Gender] [kGEN]
        ON
            [kGEN].GEN_Gender = i.GEN_Gender
        WHERE
            i.AC_GEN_ID is null
        AND
            CASE
                WHEN UPDATE(GEN_ID) THEN i.GEN_ID
                ELSE [kGEN].GEN_ID
            END is not null;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(GEN_ID) OR
        UPDATE(GEN_Gender) 
    )
    BEGIN
        INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
            AC_ID,
            GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            p.AC_ID,
            p.GEN_ID,
            cast(ISNULL(CASE
                WHEN UPDATE(AC_GEN_PositedAt) THEN i.AC_GEN_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        ON
            p.AC_GEN_ID = i.AC_GEN_ID
        WHERE
            (UPDATE(GEN_ID) AND i.GEN_ID is null)
        OR 
            (UPDATE(GEN_Gender) AND i.GEN_Gender is null);
    END
    IF(UPDATE(AC_PLV_ID))
        RAISERROR('The identity column AC_PLV_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_ID))
        RAISERROR('The foreign key column AC_ID is not updatable.', 16, 1);
    IF (
        UPDATE(PLV_ID) OR
        UPDATE(PLV_ProfessionalLevel) OR
        UPDATE(AC_PLV_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
            AC_ID,
            PLV_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            ISNULL(i.AC_ID, i.AC_ID),
            CASE
                WHEN UPDATE(PLV_ID) THEN i.PLV_ID
                ELSE [kPLV].PLV_ID
            END,
            cast(ISNULL(CASE
                WHEN UPDATE(Reliability) AND NOT UPDATE(AC_PLV_ChangedAt) THEN i.AC_PLV_ChangedAt
                WHEN UPDATE(AC_PLV_ChangedAt) THEN i.AC_PLV_ChangedAt
            END, @now) as datetime2),
            cast(ISNULL(CASE
                WHEN UPDATE(AC_PLV_PositedAt) THEN i.AC_PLV_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(AC_PLV_Reliability) THEN i.AC_PLV_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.AC_PLV_Reliability
            END, 1)
        FROM
            inserted i
        LEFT JOIN
            [dbo].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dbo.MD5(cast(i.PLV_ProfessionalLevel as varbinary(max))) 
        WHERE
            CASE
                WHEN UPDATE(PLV_ID) THEN i.PLV_ID
                ELSE [kPLV].PLV_ID
            END is not null;
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(PLV_ID) OR
        UPDATE(PLV_ProfessionalLevel) 
    )
    BEGIN
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
            AC_ID,
            PLV_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            p.AC_ID,
            p.PLV_ID,
            p.AC_PLV_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(AC_PLV_PositedAt) THEN i.AC_PLV_PositedAt
                WHEN UPDATE(AC_PLV_ChangedAt) THEN i.AC_PLV_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        ON
            p.AC_PLV_ID = i.AC_PLV_ID
        WHERE
            (UPDATE(PLV_ID) AND i.PLV_ID is null)
        OR 
            (UPDATE(PLV_ProfessionalLevel) AND i.PLV_ProfessionalLevel is null);
    END
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Actor instead of DELETE trigger on lAC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_Actor] ON [dbo].[lAC_Actor]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
        AC_NAM_ID,
        AC_NAM_PositedAt,
        AC_NAM_Reliability
    )
    SELECT
        p.AC_NAM_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[AC_NAM_Actor_Name_Annex] p
    ON
        p.AC_NAM_ID = d.AC_NAM_ID;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
        AC_GEN_ID,
        AC_GEN_PositedAt,
        AC_GEN_Reliability
    )
    SELECT
        p.AC_GEN_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[AC_GEN_Actor_Gender_Annex] p
    ON
        p.AC_GEN_ID = d.AC_GEN_ID;
    INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
        AC_PLV_ID,
        AC_PLV_PositedAt,
        AC_PLV_Reliability
    )
    SELECT
        p.AC_PLV_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] p
    ON
        p.AC_PLV_ID = d.AC_PLV_ID;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Program instead of INSERT trigger on lPR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @PR TABLE (
        Row bigint IDENTITY(1,1) not null primary key,
        PR_ID int not null
    );
    INSERT INTO [dbo].[PR_Program] (
        PR_Dummy
    )
    OUTPUT
        inserted.PR_ID
    INTO
        @PR
    SELECT
        null
    FROM
        inserted
    WHERE
        inserted.PR_ID is null;
    DECLARE @inserted TABLE (
        PR_ID int not null,
        PR_NAM_PositedAt datetime2 null,
        PR_NAM_Reliability decimal(5,2) null,
        PR_NAM_Program_Name nvarchar(42) null,
        PR_LEN_ChangedAt date null,
        PR_LEN_PositedAt datetime2 null,
        PR_LEN_Reliability decimal(5,2) null,
        PR_LEN_Program_Length time null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PR_ID, a.PR_ID),
        ISNULL(i.PR_NAM_PositedAt, @now),
        ISNULL(ISNULL(i.PR_NAM_Reliability, i.Reliability), 1),
        i.PR_NAM_Program_Name,
        ISNULL(i.PR_LEN_ChangedAt, @now),
        ISNULL(i.PR_LEN_PositedAt, @now),
        ISNULL(ISNULL(i.PR_LEN_Reliability, i.Reliability), 1),
        i.PR_LEN_Program_Length
    FROM (
        SELECT
            Reliability,
            PR_ID,
            PR_NAM_PositedAt,
            PR_NAM_Reliability,
            PR_NAM_Program_Name,
            PR_LEN_ChangedAt,
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
    INSERT INTO [dbo].[PR_NAM_Program_Name] (
        PR_ID,
        PR_NAM_Program_Name,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        i.PR_ID,
        i.PR_NAM_Program_Name,
        i.PR_NAM_PositedAt,
        i.PR_NAM_Reliability
    FROM
        @inserted i
    WHERE
        i.PR_NAM_Program_Name is not null;
    INSERT INTO [dbo].[PR_LEN_Program_Length] (
        PR_ID,
        PR_LEN_Program_Length,
        PR_LEN_ChangedAt,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        i.PR_ID,
        i.PR_LEN_Program_Length,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_PositedAt,
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
CREATE TRIGGER [dbo].[ut_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(PR_ID))
        RAISERROR('The identity column PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_NAM_ID))
        RAISERROR('The identity column PR_NAM_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_ID))
        RAISERROR('The foreign key column PR_ID is not updatable.', 16, 1);
    IF (
        UPDATE(PR_NAM_Program_Name) OR
        UPDATE(PR_NAM_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[PR_NAM_Program_Name] (
            PR_ID,
            PR_NAM_Program_Name,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            ISNULL(i.PR_ID, i.PR_ID),
            i.PR_NAM_Program_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(PR_NAM_PositedAt) THEN i.PR_NAM_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(PR_NAM_Reliability) THEN i.PR_NAM_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.PR_NAM_Reliability
            END, 1)
        FROM
            inserted i
        WHERE
            i.PR_NAM_ID is null
        AND
            i.PR_NAM_Program_Name is not null
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(PR_NAM_Program_Name) 
    )
    BEGIN
        INSERT INTO [dbo].[PR_NAM_Program_Name] (
            PR_ID,
            PR_NAM_Program_Name,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            p.PR_ID,
            p.PR_NAM_Program_Name,
            cast(ISNULL(CASE
                WHEN UPDATE(PR_NAM_PositedAt) THEN i.PR_NAM_PositedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[PR_NAM_Program_Name_Posit] p
        ON
            p.PR_NAM_ID = i.PR_NAM_ID
        WHERE
            i.PR_NAM_Program_Name is null
    END
    IF(UPDATE(PR_LEN_ID))
        RAISERROR('The identity column PR_LEN_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_ID))
        RAISERROR('The foreign key column PR_ID is not updatable.', 16, 1);
    IF (
        UPDATE(PR_LEN_Program_Length) OR
        UPDATE(PR_LEN_Reliability) OR
        UPDATE(Reliability)
    )
    BEGIN
        INSERT INTO [dbo].[PR_LEN_Program_Length] (
            PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            ISNULL(i.PR_ID, i.PR_ID),
            i.PR_LEN_Program_Length,
            cast(ISNULL(CASE
                WHEN UPDATE(Reliability) AND NOT UPDATE(PR_LEN_ChangedAt) THEN i.PR_LEN_ChangedAt
                WHEN UPDATE(PR_LEN_ChangedAt) THEN i.PR_LEN_ChangedAt
            END, @now) as date),
            cast(ISNULL(CASE
                WHEN UPDATE(PR_LEN_PositedAt) THEN i.PR_LEN_PositedAt
            END, @now) as datetime2),
            ISNULL(CASE
                WHEN UPDATE(PR_LEN_Reliability) THEN i.PR_LEN_Reliability
                WHEN UPDATE(Reliability) THEN Reliability
                ELSE i.PR_LEN_Reliability
            END, 1)
        FROM
            inserted i
        WHERE
            i.PR_LEN_Program_Length is not null
    END
    -- logical delete by setting to value to null
    -- note that an UPDATE SET AN_ATT_Anchor_Attribute = NULL, AN_ATT_ChangedAt = @timepoint
    -- will use @timepoint as a proxy for positing time
    IF (
        UPDATE(PR_LEN_Program_Length) 
    )
    BEGIN
        INSERT INTO [dbo].[PR_LEN_Program_Length] (
            PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            p.PR_ID,
            p.PR_LEN_Program_Length,
            p.PR_LEN_ChangedAt,
            cast(ISNULL(CASE
                WHEN UPDATE(PR_LEN_PositedAt) THEN i.PR_LEN_PositedAt
                WHEN UPDATE(PR_LEN_ChangedAt) THEN i.PR_LEN_ChangedAt
            END, @now) as datetime2),
            0
        FROM
            inserted i
        JOIN 
            [dbo].[PR_LEN_Program_Length_Posit] p
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
CREATE TRIGGER [dbo].[dt_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
        PR_NAM_ID,
        PR_NAM_PositedAt,
        PR_NAM_Reliability
    )
    SELECT
        p.PR_NAM_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[PR_NAM_Program_Name_Annex] p
    ON
        p.PR_NAM_ID = d.PR_NAM_ID;
    INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
        PR_LEN_ID,
        PR_LEN_PositedAt,
        PR_LEN_Reliability
    )
    SELECT
        p.PR_LEN_ID,
        @now,
        0
    FROM
        deleted d
    JOIN
        [dbo].[PR_LEN_Program_Length_Annex] p
    ON
        p.PR_LEN_ID = d.PR_LEN_ID;
END
GO
