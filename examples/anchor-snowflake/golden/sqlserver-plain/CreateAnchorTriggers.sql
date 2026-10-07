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
        ST_NAM_Stage_Name nvarchar(42) null,
        ST_LOC_Stage_Location geography null,
        ST_AVG_ChangedAt datetime2 null,
        UTL_Utilization tinyint null,
        UTL_ID tinyint null,
        UTL_Utilization tinyint null,
        UTL_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_ID, a.ST_ID),
        ISNULL(i.ST_NAM_ChangedAt, @now),
        i.ST_NAM_Stage_Name,
        i.ST_LOC_Stage_Location,
        ISNULL(i.ST_AVG_ChangedAt, @now),
        i.UTL_Utilization,
        i.UTL_ID,
        i.UTL_Utilization,
        i.UTL_ID
    FROM (
        SELECT
            ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name,
            ST_LOC_Stage_Location,
            ST_AVG_ChangedAt,
            UTL_Utilization,
            UTL_ID,
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
        ST_NAM_ChangedAt,
        ST_NAM_Stage_Name
    )
    SELECT DISTINCT
        i.ST_ID,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Stage_Name
    FROM
        @inserted i
    WHERE
        i.ST_NAM_Stage_Name is not null;
    INSERT INTO [dbo].[ST_LOC_Stage_Location] (
        ST_ID,
        ST_LOC_Stage_Location
    )
    SELECT 
        i.ST_ID,
        i.ST_LOC_Stage_Location
    FROM
        @inserted i
    WHERE
        i.ST_LOC_Stage_Location is not null;
    INSERT INTO [dbo].[ST_AVG_Stage_Average] (
        ST_ID,
        ST_AVG_ChangedAt,
        UTL_ID
    )
    SELECT DISTINCT
        i.ST_ID,
        i.ST_AVG_ChangedAt,
        ISNULL(i.UTL_ID, [kUTL].UTL_ID) 
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
        UTL_ID
    )
    SELECT DISTINCT
        i.ST_ID,
        ISNULL(i.UTL_ID, [kUTL].UTL_ID) 
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
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_NAM_Stage_Name))
    BEGIN
        INSERT INTO [dbo].[ST_NAM_Stage_Name] (
            ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        SELECT DISTINCT
            ISNULL(i.ST_ID, i.ST_ID),
            cast(ISNULL(CASE
                WHEN i.ST_NAM_Stage_Name is null THEN i.ST_NAM_ChangedAt
                WHEN UPDATE(ST_NAM_ChangedAt) THEN i.ST_NAM_ChangedAt
            END, @now) as datetime2),
            i.ST_NAM_Stage_Name
        FROM
            inserted i
        WHERE
            i.ST_NAM_Stage_Name is not null;
    END
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(ST_LOC_Stage_Location))
    BEGIN
        INSERT INTO [dbo].[ST_LOC_Stage_Location] (
            ST_ID,
            ST_LOC_Stage_Location
        )
        SELECT 
            ISNULL(i.ST_ID, i.ST_ID),
            i.ST_LOC_Stage_Location
        FROM
            inserted i
        WHERE
            i.ST_LOC_Stage_Location is not null;
    END
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(UTL_ID) OR UPDATE(UTL_Utilization))
    BEGIN
        INSERT INTO [dbo].[ST_AVG_Stage_Average] (
            ST_ID,
            ST_AVG_ChangedAt,
            UTL_ID
        )
        SELECT DISTINCT
            ISNULL(i.ST_ID, i.ST_ID),
            cast(ISNULL(CASE
                WHEN i.UTL_ID is null AND [kUTL].UTL_ID is null THEN i.ST_AVG_ChangedAt
                WHEN UPDATE(ST_AVG_ChangedAt) THEN i.ST_AVG_ChangedAt
            END, @now) as datetime2),
            CASE WHEN UPDATE(UTL_ID) THEN i.UTL_ID ELSE [kUTL].UTL_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.UTL_Utilization
        WHERE
            CASE WHEN UPDATE(UTL_ID) THEN i.UTL_ID ELSE [kUTL].UTL_ID END is not null;
    END
    IF(UPDATE(ST_ID))
        RAISERROR('The foreign key column ST_ID is not updatable.', 16, 1);
    IF(UPDATE(UTL_ID) OR UPDATE(UTL_Utilization))
    BEGIN
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum] (
            ST_ID,
            UTL_ID
        )
        SELECT DISTINCT
            ISNULL(i.ST_ID, i.ST_ID),
            CASE WHEN UPDATE(UTL_ID) THEN i.UTL_ID ELSE [kUTL].UTL_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[UTL_Utilization] [kUTL]
        ON
            [kUTL].UTL_Utilization = i.UTL_Utilization
        WHERE
            CASE WHEN UPDATE(UTL_ID) THEN i.UTL_ID ELSE [kUTL].UTL_ID END is not null;
        SELECT
            i.ST_ID
        INTO
            #ST_MIN
        FROM
            inserted i
        JOIN
            deleted d
        ON
            d.ST_ID = i.ST_ID
        AND
            d.UTL_ID is not null
        WHERE
            ((UPDATE(UTL_ID) AND i.UTL_ID is null) OR (UPDATE(UTL_Utilization) AND i.UTL_Utilization is null))
        AND
            i.Deletable_ST_MIN = 1;
        IF(@@ROWCOUNT > 0)
        BEGIN
            IF OBJECT_ID('[dbo].[ST_MIN_Stage_Minimum_Deleted]') is null
            SELECT TOP 0 
                *, 
                CAST(null as datetime2) as ST_MIN_Deleted
            INTO 
                [dbo].[ST_MIN_Stage_Minimum_Deleted]
            FROM 
                [dbo].[ST_MIN_Stage_Minimum];
            DELETE [MIN]
            OUTPUT
                deleted.*,
                @now
            INTO
                [dbo].[ST_MIN_Stage_Minimum_Deleted]
            FROM
                [dbo].[ST_MIN_Stage_Minimum] [MIN]
            JOIN
                #ST_MIN d
            ON
                d.ST_ID = [MIN].ST_ID
        END
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
    DELETE [NAM]
    FROM
        [dbo].[ST_NAM_Stage_Name] [NAM]
    JOIN
        deleted d
    ON
        d.ST_NAM_ChangedAt = [NAM].ST_NAM_ChangedAt
    AND
        d.ST_ID = [NAM].ST_ID;
    DELETE [LOC]
    FROM
        [dbo].[ST_LOC_Stage_Location] [LOC]
    JOIN
        deleted d
    ON
        d.ST_ID = [LOC].ST_ID;
    DELETE [AVG]
    FROM
        [dbo].[ST_AVG_Stage_Average] [AVG]
    JOIN
        deleted d
    ON
        d.ST_AVG_ChangedAt = [AVG].ST_AVG_ChangedAt
    AND
        d.ST_ID = [AVG].ST_ID;
    DELETE [MIN]
    FROM
        [dbo].[ST_MIN_Stage_Minimum] [MIN]
    JOIN
        deleted d
    ON
        d.ST_ID = [MIN].ST_ID;
    DECLARE @deleted TABLE (
        ST_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (ST_ID)
    SELECT a.ST_ID
    FROM (
        SELECT [ST].ST_ID
        FROM [dbo].[ST_Stage] [ST] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 ST_ID
            FROM [dbo].[ST_NAM_Stage_Name] WITH(NOLOCK)
            WHERE ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_ID
            FROM [dbo].[ST_LOC_Stage_Location] WITH(NOLOCK)
            WHERE ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_ID
            FROM [dbo].[ST_AVG_Stage_Average] WITH(NOLOCK)
            WHERE ST_ID = [ST].ST_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 ST_ID
            FROM [dbo].[ST_MIN_Stage_Minimum] WITH(NOLOCK)
            WHERE ST_ID = [ST].ST_ID
        )
    ) a
    JOIN deleted d
    ON d.ST_ID = a.ST_ID;
    DELETE [ST]
    FROM [dbo].[ST_Stage] [ST]
    JOIN @deleted d
    ON d.ST_ID = [ST].ST_ID;
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
        AC_NAM_Actor_Name nvarchar(42) null,
        GEN_Gender nvarchar(42) null,
        GEN_ID tinyint null,
        AC_PLV_ChangedAt datetime2 null,
        PLV_ProfessionalLevel nvarchar(max) null,
        PLV_Checksum varbinary(16) null,
        PLV_ID tinyint null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.AC_ID, a.AC_ID),
        ISNULL(i.AC_NAM_ChangedAt, @now),
        i.AC_NAM_Actor_Name,
        i.GEN_Gender,
        i.GEN_ID,
        ISNULL(i.AC_PLV_ChangedAt, @now),
        i.PLV_ProfessionalLevel,
        ISNULL(i.PLV_Checksum, dbo.MD5(cast(i.PLV_ProfessionalLevel as varbinary(max)))),
        i.PLV_ID
    FROM (
        SELECT
            AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name,
            GEN_Gender,
            GEN_ID,
            AC_PLV_ChangedAt,
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
        AC_NAM_ChangedAt,
        AC_NAM_Actor_Name
    )
    SELECT DISTINCT
        i.AC_ID,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_Actor_Name
    FROM
        @inserted i
    WHERE
        i.AC_NAM_Actor_Name is not null;
    INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
        AC_ID,
        GEN_ID
    )
    SELECT DISTINCT
        i.AC_ID,
        ISNULL(i.GEN_ID, [kGEN].GEN_ID) 
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
        AC_PLV_ChangedAt,
        PLV_ID
    )
    SELECT DISTINCT
        i.AC_ID,
        i.AC_PLV_ChangedAt,
        ISNULL(i.PLV_ID, [kPLV].PLV_ID) 
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
    IF(UPDATE(AC_ID))
        RAISERROR('The foreign key column AC_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_NAM_Actor_Name))
    BEGIN
        INSERT INTO [dbo].[AC_NAM_Actor_Name] (
            AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        SELECT DISTINCT
            ISNULL(i.AC_ID, i.AC_ID),
            cast(ISNULL(CASE
                WHEN i.AC_NAM_Actor_Name is null THEN i.AC_NAM_ChangedAt
                WHEN UPDATE(AC_NAM_ChangedAt) THEN i.AC_NAM_ChangedAt
            END, @now) as datetime2),
            i.AC_NAM_Actor_Name
        FROM
            inserted i
        WHERE
            i.AC_NAM_Actor_Name is not null;
    END
    IF(UPDATE(AC_ID))
        RAISERROR('The foreign key column AC_ID is not updatable.', 16, 1);
    IF(UPDATE(GEN_ID) OR UPDATE(GEN_Gender))
    BEGIN
        INSERT INTO [dbo].[AC_GEN_Actor_Gender] (
            AC_ID,
            GEN_ID
        )
        SELECT DISTINCT
            ISNULL(i.AC_ID, i.AC_ID),
            CASE WHEN UPDATE(GEN_ID) THEN i.GEN_ID ELSE [kGEN].GEN_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[GEN_Gender] [kGEN]
        ON
            [kGEN].GEN_Gender = i.GEN_Gender
        WHERE
            CASE WHEN UPDATE(GEN_ID) THEN i.GEN_ID ELSE [kGEN].GEN_ID END is not null;
    END
    IF(UPDATE(AC_ID))
        RAISERROR('The foreign key column AC_ID is not updatable.', 16, 1);
    IF(UPDATE(PLV_ID) OR UPDATE(PLV_ProfessionalLevel))
    BEGIN
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel] (
            AC_ID,
            AC_PLV_ChangedAt,
            PLV_ID
        )
        SELECT DISTINCT
            ISNULL(i.AC_ID, i.AC_ID),
            cast(ISNULL(CASE
                WHEN i.PLV_ID is null AND [kPLV].PLV_ID is null THEN i.AC_PLV_ChangedAt
                WHEN UPDATE(AC_PLV_ChangedAt) THEN i.AC_PLV_ChangedAt
            END, @now) as datetime2),
            CASE WHEN UPDATE(PLV_ID) THEN i.PLV_ID ELSE [kPLV].PLV_ID END
        FROM
            inserted i
        LEFT JOIN
            [dbo].[PLV_ProfessionalLevel] [kPLV]
        ON
            [kPLV].PLV_Checksum = dbo.MD5(cast(i.PLV_ProfessionalLevel as varbinary(max))) 
        WHERE
            CASE WHEN UPDATE(PLV_ID) THEN i.PLV_ID ELSE [kPLV].PLV_ID END is not null;
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
    DELETE [NAM]
    FROM
        [dbo].[AC_NAM_Actor_Name] [NAM]
    JOIN
        deleted d
    ON
        d.AC_NAM_ChangedAt = [NAM].AC_NAM_ChangedAt
    AND
        d.AC_ID = [NAM].AC_ID;
    DELETE [GEN]
    FROM
        [dbo].[AC_GEN_Actor_Gender] [GEN]
    JOIN
        deleted d
    ON
        d.AC_ID = [GEN].AC_ID;
    DELETE [PLV]
    FROM
        [dbo].[AC_PLV_Actor_ProfessionalLevel] [PLV]
    JOIN
        deleted d
    ON
        d.AC_PLV_ChangedAt = [PLV].AC_PLV_ChangedAt
    AND
        d.AC_ID = [PLV].AC_ID;
    DECLARE @deleted TABLE (
        AC_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (AC_ID)
    SELECT a.AC_ID
    FROM (
        SELECT [AC].AC_ID
        FROM [dbo].[AC_Actor] [AC] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 AC_ID
            FROM [dbo].[AC_NAM_Actor_Name] WITH(NOLOCK)
            WHERE AC_ID = [AC].AC_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 AC_ID
            FROM [dbo].[AC_GEN_Actor_Gender] WITH(NOLOCK)
            WHERE AC_ID = [AC].AC_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 AC_ID
            FROM [dbo].[AC_PLV_Actor_ProfessionalLevel] WITH(NOLOCK)
            WHERE AC_ID = [AC].AC_ID
        )
    ) a
    JOIN deleted d
    ON d.AC_ID = a.AC_ID;
    DELETE [AC]
    FROM [dbo].[AC_Actor] [AC]
    JOIN @deleted d
    ON d.AC_ID = [AC].AC_ID;
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
        PR_NAM_Program_Name nvarchar(42) null,
        PR_LEN_ChangedAt date null,
        PR_LEN_Program_Length time null
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.PR_ID, a.PR_ID),
        i.PR_NAM_Program_Name,
        ISNULL(i.PR_LEN_ChangedAt, @now),
        i.PR_LEN_Program_Length
    FROM (
        SELECT
            PR_ID,
            PR_NAM_Program_Name,
            PR_LEN_ChangedAt,
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
        PR_NAM_Program_Name
    )
    SELECT DISTINCT
        i.PR_ID,
        i.PR_NAM_Program_Name
    FROM
        @inserted i
    WHERE
        i.PR_NAM_Program_Name is not null;
    INSERT INTO [dbo].[PR_LEN_Program_Length] (
        PR_ID,
        PR_LEN_ChangedAt,
        PR_LEN_Program_Length
    )
    SELECT DISTINCT
        i.PR_ID,
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
CREATE TRIGGER [dbo].[ut_lPR_Program] ON [dbo].[lPR_Program]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(PR_ID))
        RAISERROR('The identity column PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_ID))
        RAISERROR('The foreign key column PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_NAM_Program_Name))
    BEGIN
        INSERT INTO [dbo].[PR_NAM_Program_Name] (
            PR_ID,
            PR_NAM_Program_Name
        )
        SELECT DISTINCT
            ISNULL(i.PR_ID, i.PR_ID),
            i.PR_NAM_Program_Name
        FROM
            inserted i
        WHERE
            i.PR_NAM_Program_Name is not null;
    END
    IF(UPDATE(PR_ID))
        RAISERROR('The foreign key column PR_ID is not updatable.', 16, 1);
    IF(UPDATE(PR_LEN_Program_Length))
    BEGIN
        INSERT INTO [dbo].[PR_LEN_Program_Length] (
            PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        )
        SELECT DISTINCT
            ISNULL(i.PR_ID, i.PR_ID),
            cast(ISNULL(CASE
                WHEN i.PR_LEN_Program_Length is null THEN i.PR_LEN_ChangedAt
                WHEN UPDATE(PR_LEN_ChangedAt) THEN i.PR_LEN_ChangedAt
            END, @now) as date),
            i.PR_LEN_Program_Length
        FROM
            inserted i
        WHERE
            i.PR_LEN_Program_Length is not null;
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
    DELETE [NAM]
    FROM
        [dbo].[PR_NAM_Program_Name] [NAM]
    JOIN
        deleted d
    ON
        d.PR_ID = [NAM].PR_ID;
    DELETE [LEN]
    FROM
        [dbo].[PR_LEN_Program_Length] [LEN]
    JOIN
        deleted d
    ON
        d.PR_LEN_ChangedAt = [LEN].PR_LEN_ChangedAt
    AND
        d.PR_ID = [LEN].PR_ID;
    DECLARE @deleted TABLE (
        PR_ID int NOT NULL PRIMARY KEY
    );
    INSERT INTO @deleted (PR_ID)
    SELECT a.PR_ID
    FROM (
        SELECT [PR].PR_ID
        FROM [dbo].[PR_Program] [PR] WITH(NOLOCK)
        WHERE
        NOT EXISTS (
            SELECT TOP 1 PR_ID
            FROM [dbo].[PR_NAM_Program_Name] WITH(NOLOCK)
            WHERE PR_ID = [PR].PR_ID
        )
        AND
        NOT EXISTS (
            SELECT TOP 1 PR_ID
            FROM [dbo].[PR_LEN_Program_Length] WITH(NOLOCK)
            WHERE PR_ID = [PR].PR_ID
        )
    ) a
    JOIN deleted d
    ON d.PR_ID = a.PR_ID;
    DELETE [PR]
    FROM [dbo].[PR_Program] [PR]
    JOIN @deleted d
    ON d.PR_ID = [PR].PR_ID;
END
GO
