-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled views make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_ST_NAM_Stage_Name', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_NAM_Stage_Name];
GO
CREATE TRIGGER [attributes].[it_ST_NAM_Stage_Name] ON [attributes].[ST_NAM_Stage_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_NAM_Stage_Name TABLE (
        ST_NAM_ST_ID int not null,
        Metadata_ST_NAM bigint not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_Who smallint not null,
        ST_NAM_PositedAt datetime2(3) not null,
        ST_NAM_Confidence decimal(7,3) not null,
        ST_NAM_Stance char(1) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_Version bigint not null,
        ST_NAM_StatementType char(1) not null,
        primary key(
            ST_NAM_Version,
            ST_NAM_Who,
            ST_NAM_ST_ID
        )
    );
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_NAM_ST_ID,
        i.Metadata_ST_NAM,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Who,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Confidence,
        case
            when i.ST_NAM_Confidence > 0.25 then '+'
            when i.ST_NAM_Confidence = 0.25 then '?'
            when i.ST_NAM_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.ST_NAM_Stage_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_NAM_Who,
                i.ST_NAM_ST_ID
            ORDER BY
                i.ST_NAM_ChangedAt ASC,
                i.ST_NAM_PositedAt ASC,
                i.ST_NAM_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(ST_NAM_Version),
        @currentVersion = 0
    FROM
        @ST_NAM_Stage_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_NAM_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.ST_NAM_ID
                        FROM
                            [anchors].[tST_Stage](v.ST_NAM_Who, v.ST_NAM_ChangedAt, v.ST_NAM_PositedAt, v.ST_NAM_Stance) t
                        WHERE
                            t.ST_NAM_ST_ID = v.ST_NAM_ST_ID
                        AND
                            t.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
                        AND
                            t.ST_NAM_Confidence = v.ST_NAM_Confidence
                        AND
                            t.ST_NAM_Stage_Name = v.ST_NAM_Stage_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_NAM_ST_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.ST_NAM_Stage_Name
                        WHERE
                            v.ST_NAM_Stage_Name =
                                attributes.preST_NAM_Stage_Name (
                                    v.ST_NAM_ST_ID,
                                    v.ST_NAM_Who,
                                    v.ST_NAM_ChangedAt,
                                    v.ST_NAM_PositedAt,
                                    v.ST_NAM_Stance
                                )
                    ) OR EXISTS (
                        SELECT
                            v.ST_NAM_Stage_Name
                        WHERE
                            v.ST_NAM_Stage_Name =
                                attributes.folST_NAM_Stage_Name (
                                    v.ST_NAM_ST_ID,
                                    v.ST_NAM_Who,
                                    v.ST_NAM_ChangedAt,
                                    v.ST_NAM_PositedAt,
                                    v.ST_NAM_Stance
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_NAM_Stage_Name v
        LEFT JOIN
            [attributes].[ST_NAM_Stage_Name_Fact] p
        ON
            p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
        AND
            p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
        AND
            p.ST_NAM_Stage_Name = v.ST_NAM_Stage_Name
        WHERE
            v.ST_NAM_Version = @currentVersion;
        INSERT INTO [attributes].[ST_NAM_Stage_Name_Fact] (
            ST_NAM_ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        SELECT
            ST_NAM_ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        FROM
            @ST_NAM_Stage_Name
        WHERE
            ST_NAM_Version = @currentVersion
        AND
            ST_NAM_StatementType in ('N','R');
        INSERT INTO [attributes].[ST_NAM_Stage_Name_Meta] (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Who,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
        )
        SELECT
            v.Metadata_ST_NAM,
            p.ST_NAM_ID,
            v.ST_NAM_Who,
            v.ST_NAM_PositedAt,
            v.ST_NAM_Confidence
        FROM
            @ST_NAM_Stage_Name v
        JOIN
            [attributes].[ST_NAM_Stage_Name_Fact] p
        ON
            p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
        AND
            p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
        AND
            p.ST_NAM_Stage_Name = v.ST_NAM_Stage_Name
        WHERE
            v.ST_NAM_Version = @currentVersion
        AND
            ST_NAM_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Stage_Location instead of INSERT trigger on ST_LOC_Stage_Location
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_ST_LOC_Stage_Location', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_LOC_Stage_Location];
GO
CREATE TRIGGER [attributes].[it_ST_LOC_Stage_Location] ON [attributes].[ST_LOC_Stage_Location]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_LOC_Stage_Location TABLE (
        ST_LOC_ST_ID int not null,
        Metadata_ST_LOC bigint not null,
        ST_LOC_Who smallint not null,
        ST_LOC_PositedAt datetime2(3) not null,
        ST_LOC_Confidence decimal(7,3) not null,
        ST_LOC_Stance char(1) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_Version bigint not null,
        ST_LOC_StatementType char(1) not null,
        primary key(
            ST_LOC_Version,
            ST_LOC_Who,
            ST_LOC_ST_ID
        )
    );
    INSERT INTO @ST_LOC_Stage_Location
    SELECT
        i.ST_LOC_ST_ID,
        i.Metadata_ST_LOC,
        i.ST_LOC_Who,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Confidence,
        case
            when i.ST_LOC_Confidence > 0.25 then '+'
            when i.ST_LOC_Confidence = 0.25 then '?'
            when i.ST_LOC_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.ST_LOC_Stage_Location,
        dw.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_LOC_Who,
                i.ST_LOC_ST_ID
            ORDER BY
                i.ST_LOC_PositedAt ASC,
                i.ST_LOC_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(ST_LOC_Version),
        @currentVersion = 0
    FROM
        @ST_LOC_Stage_Location;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_LOC_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.ST_LOC_ID
                        FROM
                            [anchors].[tST_Stage](v.ST_LOC_Who, DEFAULT, v.ST_LOC_PositedAt, v.ST_LOC_Stance) t
                        WHERE
                            t.ST_LOC_ST_ID = v.ST_LOC_ST_ID
                        AND
                            t.ST_LOC_Confidence = v.ST_LOC_Confidence
                        AND
                            t.ST_LOC_Checksum = v.ST_LOC_Checksum 
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_LOC_ST_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_LOC_Stage_Location v
        LEFT JOIN
            [attributes].[ST_LOC_Stage_Location_Fact] p
        ON
            p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
        AND
            p.ST_LOC_Checksum = v.ST_LOC_Checksum 
        WHERE
            v.ST_LOC_Version = @currentVersion;
        INSERT INTO [attributes].[ST_LOC_Stage_Location_Fact] (
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        )
        SELECT
            ST_LOC_ST_ID,
            ST_LOC_Stage_Location
        FROM
            @ST_LOC_Stage_Location
        WHERE
            ST_LOC_Version = @currentVersion
        AND
            ST_LOC_StatementType in ('N');
        INSERT INTO [attributes].[ST_LOC_Stage_Location_Meta] (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Who,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
        )
        SELECT
            v.Metadata_ST_LOC,
            p.ST_LOC_ID,
            v.ST_LOC_Who,
            v.ST_LOC_PositedAt,
            v.ST_LOC_Confidence
        FROM
            @ST_LOC_Stage_Location v
        JOIN
            [attributes].[ST_LOC_Stage_Location_Fact] p
        ON
            p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
        AND
            p.ST_LOC_Checksum = v.ST_LOC_Checksum 
        WHERE
            v.ST_LOC_Version = @currentVersion
        AND
            ST_LOC_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Stage_Average instead of INSERT trigger on ST_AVG_Stage_Average
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [attributes].[it_ST_AVG_Stage_Average] ON [attributes].[ST_AVG_Stage_Average]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_AVG_ST_ID int not null,
        Metadata_ST_AVG bigint not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_Who smallint not null,
        ST_AVG_PositedAt datetime2(3) not null,
        ST_AVG_Confidence decimal(7,3) not null,
        ST_AVG_Stance char(1) not null,
        ST_AVG_UTL_ID tinyint not null, 
        ST_AVG_Version bigint not null,
        ST_AVG_StatementType char(1) not null,
        primary key(
            ST_AVG_Version,
            ST_AVG_Who,
            ST_AVG_ST_ID
        )
    );
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_AVG_ST_ID,
        i.Metadata_ST_AVG,
        i.ST_AVG_ChangedAt,
        i.ST_AVG_Who,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Confidence,
        case
            when i.ST_AVG_Confidence > 0.25 then '+'
            when i.ST_AVG_Confidence = 0.25 then '?'
            when i.ST_AVG_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.ST_AVG_UTL_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_AVG_Who,
                i.ST_AVG_ST_ID
            ORDER BY
                i.ST_AVG_ChangedAt ASC,
                i.ST_AVG_PositedAt ASC,
                i.ST_AVG_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(ST_AVG_Version),
        @currentVersion = 0
    FROM
        @ST_AVG_Stage_Average;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_AVG_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.ST_AVG_ID
                        FROM
                            [anchors].[tST_Stage](v.ST_AVG_Who, v.ST_AVG_ChangedAt, v.ST_AVG_PositedAt, v.ST_AVG_Stance) t
                        WHERE
                            t.ST_AVG_ST_ID = v.ST_AVG_ST_ID
                        AND
                            t.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
                        AND
                            t.ST_AVG_Confidence = v.ST_AVG_Confidence
                        AND
                            t.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_AVG_ST_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.ST_AVG_UTL_ID
                        WHERE
                            v.ST_AVG_UTL_ID =
                                attributes.preST_AVG_Stage_Average (
                                    v.ST_AVG_ST_ID,
                                    v.ST_AVG_Who,
                                    v.ST_AVG_ChangedAt,
                                    v.ST_AVG_PositedAt,
                                    v.ST_AVG_Stance
                                )
                    ) OR EXISTS (
                        SELECT
                            v.ST_AVG_UTL_ID
                        WHERE
                            v.ST_AVG_UTL_ID =
                                attributes.folST_AVG_Stage_Average (
                                    v.ST_AVG_ST_ID,
                                    v.ST_AVG_Who,
                                    v.ST_AVG_ChangedAt,
                                    v.ST_AVG_PositedAt,
                                    v.ST_AVG_Stance
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_AVG_Stage_Average v
        LEFT JOIN
            [attributes].[ST_AVG_Stage_Average_Fact] p
        ON
            p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
        AND
            p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            p.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
        WHERE
            v.ST_AVG_Version = @currentVersion;
        INSERT INTO [attributes].[ST_AVG_Stage_Average_Fact] (
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        )
        SELECT
            ST_AVG_ST_ID,
            ST_AVG_ChangedAt,
            ST_AVG_UTL_ID
        FROM
            @ST_AVG_Stage_Average
        WHERE
            ST_AVG_Version = @currentVersion
        AND
            ST_AVG_StatementType in ('N');
        INSERT INTO [attributes].[ST_AVG_Stage_Average_Meta] (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Who,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        SELECT
            v.Metadata_ST_AVG,
            p.ST_AVG_ID,
            v.ST_AVG_Who,
            v.ST_AVG_PositedAt,
            v.ST_AVG_Confidence
        FROM
            @ST_AVG_Stage_Average v
        JOIN
            [attributes].[ST_AVG_Stage_Average_Fact] p
        ON
            p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
        AND
            p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            p.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
        WHERE
            v.ST_AVG_Version = @currentVersion
        AND
            ST_AVG_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_ST_MIN_Stage_Minimum', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_ST_MIN_Stage_Minimum];
GO
CREATE TRIGGER [attributes].[it_ST_MIN_Stage_Minimum] ON [attributes].[ST_MIN_Stage_Minimum]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_MIN_Stage_Minimum TABLE (
        ST_MIN_ST_ID int not null,
        Metadata_ST_MIN bigint not null,
        ST_MIN_Who smallint not null,
        ST_MIN_PositedAt datetime2(3) not null,
        ST_MIN_Confidence decimal(7,3) not null,
        ST_MIN_Stance char(1) not null,
        ST_MIN_UTL_ID tinyint not null, 
        ST_MIN_Version bigint not null,
        ST_MIN_StatementType char(1) not null,
        primary key(
            ST_MIN_Version,
            ST_MIN_Who,
            ST_MIN_ST_ID
        )
    );
    INSERT INTO @ST_MIN_Stage_Minimum
    SELECT
        i.ST_MIN_ST_ID,
        i.Metadata_ST_MIN,
        i.ST_MIN_Who,
        i.ST_MIN_PositedAt,
        i.ST_MIN_Confidence,
        case
            when i.ST_MIN_Confidence > 0.25 then '+'
            when i.ST_MIN_Confidence = 0.25 then '?'
            when i.ST_MIN_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.ST_MIN_UTL_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_MIN_Who,
                i.ST_MIN_ST_ID
            ORDER BY
                i.ST_MIN_PositedAt ASC,
                i.ST_MIN_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(ST_MIN_Version),
        @currentVersion = 0
    FROM
        @ST_MIN_Stage_Minimum;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_MIN_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.ST_MIN_ID
                        FROM
                            [anchors].[tST_Stage](v.ST_MIN_Who, DEFAULT, v.ST_MIN_PositedAt, v.ST_MIN_Stance) t
                        WHERE
                            t.ST_MIN_ST_ID = v.ST_MIN_ST_ID
                        AND
                            t.ST_MIN_Confidence = v.ST_MIN_Confidence
                        AND
                            t.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_MIN_ST_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_MIN_Stage_Minimum v
        LEFT JOIN
            [attributes].[ST_MIN_Stage_Minimum_Fact] p
        ON
            p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
        AND
            p.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
        WHERE
            v.ST_MIN_Version = @currentVersion;
        INSERT INTO [attributes].[ST_MIN_Stage_Minimum_Fact] (
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        )
        SELECT
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        FROM
            @ST_MIN_Stage_Minimum
        WHERE
            ST_MIN_Version = @currentVersion
        AND
            ST_MIN_StatementType in ('N');
        INSERT INTO [attributes].[ST_MIN_Stage_Minimum_Meta] (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Who,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
        )
        SELECT
            v.Metadata_ST_MIN,
            p.ST_MIN_ID,
            v.ST_MIN_Who,
            v.ST_MIN_PositedAt,
            v.ST_MIN_Confidence
        FROM
            @ST_MIN_Stage_Minimum v
        JOIN
            [attributes].[ST_MIN_Stage_Minimum_Fact] p
        ON
            p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
        AND
            p.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
        WHERE
            v.ST_MIN_Version = @currentVersion
        AND
            ST_MIN_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Actor_Name instead of INSERT trigger on AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [attributes].[it_AC_NAM_Actor_Name] ON [attributes].[AC_NAM_Actor_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_NAM_AC_ID smallint not null,
        Metadata_AC_NAM bigint not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_Who smallint not null,
        AC_NAM_PositedAt datetime2(3) not null,
        AC_NAM_Confidence decimal(7,3) not null,
        AC_NAM_Stance char(1) not null,
        AC_NAM_Actor_Name varbinary(max) not null,
        AC_NAM_Version bigint not null,
        AC_NAM_StatementType char(1) not null,
        primary key(
            AC_NAM_Version,
            AC_NAM_Who,
            AC_NAM_AC_ID
        )
    );
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_NAM_AC_ID,
        i.Metadata_AC_NAM,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_Who,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Confidence,
        case
            when i.AC_NAM_Confidence > 0.25 then '+'
            when i.AC_NAM_Confidence = 0.25 then '?'
            when i.AC_NAM_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.AC_NAM_Actor_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_NAM_Who,
                i.AC_NAM_AC_ID
            ORDER BY
                i.AC_NAM_ChangedAt ASC,
                i.AC_NAM_PositedAt ASC,
                i.AC_NAM_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(AC_NAM_Version),
        @currentVersion = 0
    FROM
        @AC_NAM_Actor_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.AC_NAM_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.AC_NAM_ID
                        FROM
                            [anchors].[tAC_Actor](v.AC_NAM_Who, v.AC_NAM_ChangedAt, v.AC_NAM_PositedAt, v.AC_NAM_Stance) t
                        WHERE
                            t.AC_NAM_AC_ID = v.AC_NAM_AC_ID
                        AND
                            t.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
                        AND
                            t.AC_NAM_Confidence = v.AC_NAM_Confidence
                        AND
                            t.AC_NAM_Actor_Name = v.AC_NAM_Actor_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_NAM_AC_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.AC_NAM_Actor_Name
                        WHERE
                            v.AC_NAM_Actor_Name =
                                attributes.preAC_NAM_Actor_Name (
                                    v.AC_NAM_AC_ID,
                                    v.AC_NAM_Who,
                                    v.AC_NAM_ChangedAt,
                                    v.AC_NAM_PositedAt,
                                    v.AC_NAM_Stance
                                )
                    ) OR EXISTS (
                        SELECT
                            v.AC_NAM_Actor_Name
                        WHERE
                            v.AC_NAM_Actor_Name =
                                attributes.folAC_NAM_Actor_Name (
                                    v.AC_NAM_AC_ID,
                                    v.AC_NAM_Who,
                                    v.AC_NAM_ChangedAt,
                                    v.AC_NAM_PositedAt,
                                    v.AC_NAM_Stance
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @AC_NAM_Actor_Name v
        LEFT JOIN
            [attributes].[AC_NAM_Actor_Name_Fact] p
        ON
            p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
        AND
            p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
        AND
            p.AC_NAM_Actor_Name = v.AC_NAM_Actor_Name
        WHERE
            v.AC_NAM_Version = @currentVersion;
        INSERT INTO [attributes].[AC_NAM_Actor_Name_Fact] (
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        SELECT
            AC_NAM_AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        FROM
            @AC_NAM_Actor_Name
        WHERE
            AC_NAM_Version = @currentVersion
        AND
            AC_NAM_StatementType in ('N','R');
        INSERT INTO [attributes].[AC_NAM_Actor_Name_Meta] (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Who,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
        )
        SELECT
            v.Metadata_AC_NAM,
            p.AC_NAM_ID,
            v.AC_NAM_Who,
            v.AC_NAM_PositedAt,
            v.AC_NAM_Confidence
        FROM
            @AC_NAM_Actor_Name v
        JOIN
            [attributes].[AC_NAM_Actor_Name_Fact] p
        ON
            p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
        AND
            p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
        AND
            p.AC_NAM_Actor_Name = v.AC_NAM_Actor_Name
        WHERE
            v.AC_NAM_Version = @currentVersion
        AND
            AC_NAM_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Actor_Gender instead of INSERT trigger on AC_GEN_Actor_Gender
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_AC_GEN_Actor_Gender', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_AC_GEN_Actor_Gender];
GO
CREATE TRIGGER [attributes].[it_AC_GEN_Actor_Gender] ON [attributes].[AC_GEN_Actor_Gender]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @AC_GEN_Actor_Gender TABLE (
        AC_GEN_AC_ID smallint not null,
        Metadata_AC_GEN bigint not null,
        AC_GEN_Who smallint not null,
        AC_GEN_PositedAt datetime2(3) not null,
        AC_GEN_Confidence decimal(7,3) not null,
        AC_GEN_Stance char(1) not null,
        AC_GEN_GEN_ID tinyint not null, 
        AC_GEN_Version bigint not null,
        AC_GEN_StatementType char(1) not null,
        primary key(
            AC_GEN_Version,
            AC_GEN_Who,
            AC_GEN_AC_ID
        )
    );
    INSERT INTO @AC_GEN_Actor_Gender
    SELECT
        i.AC_GEN_AC_ID,
        i.Metadata_AC_GEN,
        i.AC_GEN_Who,
        i.AC_GEN_PositedAt,
        i.AC_GEN_Confidence,
        case
            when i.AC_GEN_Confidence > 0.25 then '+'
            when i.AC_GEN_Confidence = 0.25 then '?'
            when i.AC_GEN_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.AC_GEN_GEN_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_GEN_Who,
                i.AC_GEN_AC_ID
            ORDER BY
                i.AC_GEN_PositedAt ASC,
                i.AC_GEN_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(AC_GEN_Version),
        @currentVersion = 0
    FROM
        @AC_GEN_Actor_Gender;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.AC_GEN_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.AC_GEN_ID
                        FROM
                            [anchors].[tAC_Actor](v.AC_GEN_Who, DEFAULT, v.AC_GEN_PositedAt, v.AC_GEN_Stance) t
                        WHERE
                            t.AC_GEN_AC_ID = v.AC_GEN_AC_ID
                        AND
                            t.AC_GEN_Confidence = v.AC_GEN_Confidence
                        AND
                            t.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_GEN_AC_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @AC_GEN_Actor_Gender v
        LEFT JOIN
            [attributes].[AC_GEN_Actor_Gender_Fact] p
        ON
            p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
        AND
            p.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
        WHERE
            v.AC_GEN_Version = @currentVersion;
        INSERT INTO [attributes].[AC_GEN_Actor_Gender_Fact] (
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        )
        SELECT
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        FROM
            @AC_GEN_Actor_Gender
        WHERE
            AC_GEN_Version = @currentVersion
        AND
            AC_GEN_StatementType in ('N');
        INSERT INTO [attributes].[AC_GEN_Actor_Gender_Meta] (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Who,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
        )
        SELECT
            v.Metadata_AC_GEN,
            p.AC_GEN_ID,
            v.AC_GEN_Who,
            v.AC_GEN_PositedAt,
            v.AC_GEN_Confidence
        FROM
            @AC_GEN_Actor_Gender v
        JOIN
            [attributes].[AC_GEN_Actor_Gender_Fact] p
        ON
            p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
        AND
            p.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
        WHERE
            v.AC_GEN_Version = @currentVersion
        AND
            AC_GEN_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Actor_ProfessionalLevel instead of INSERT trigger on AC_PLV_Actor_ProfessionalLevel
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_AC_PLV_Actor_ProfessionalLevel', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_AC_PLV_Actor_ProfessionalLevel];
GO
CREATE TRIGGER [attributes].[it_AC_PLV_Actor_ProfessionalLevel] ON [attributes].[AC_PLV_Actor_ProfessionalLevel]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @AC_PLV_Actor_ProfessionalLevel TABLE (
        AC_PLV_AC_ID smallint not null,
        Metadata_AC_PLV bigint not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_Who smallint not null,
        AC_PLV_PositedAt datetime2(3) not null,
        AC_PLV_Confidence decimal(7,3) not null,
        AC_PLV_Stance char(1) not null,
        AC_PLV_PLV_ID tinyint not null, 
        AC_PLV_Version bigint not null,
        AC_PLV_StatementType char(1) not null,
        primary key(
            AC_PLV_Version,
            AC_PLV_Who,
            AC_PLV_AC_ID
        )
    );
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_PLV_AC_ID,
        i.Metadata_AC_PLV,
        i.AC_PLV_ChangedAt,
        i.AC_PLV_Who,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Confidence,
        case
            when i.AC_PLV_Confidence > 0.25 then '+'
            when i.AC_PLV_Confidence = 0.25 then '?'
            when i.AC_PLV_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.AC_PLV_PLV_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_PLV_Who,
                i.AC_PLV_AC_ID
            ORDER BY
                i.AC_PLV_ChangedAt ASC,
                i.AC_PLV_PositedAt ASC,
                i.AC_PLV_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(AC_PLV_Version),
        @currentVersion = 0
    FROM
        @AC_PLV_Actor_ProfessionalLevel;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.AC_PLV_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.AC_PLV_ID
                        FROM
                            [anchors].[tAC_Actor](v.AC_PLV_Who, v.AC_PLV_ChangedAt, v.AC_PLV_PositedAt, v.AC_PLV_Stance) t
                        WHERE
                            t.AC_PLV_AC_ID = v.AC_PLV_AC_ID
                        AND
                            t.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
                        AND
                            t.AC_PLV_Confidence = v.AC_PLV_Confidence
                        AND
                            t.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_PLV_AC_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.AC_PLV_PLV_ID
                        WHERE
                            v.AC_PLV_PLV_ID =
                                attributes.preAC_PLV_Actor_ProfessionalLevel (
                                    v.AC_PLV_AC_ID,
                                    v.AC_PLV_Who,
                                    v.AC_PLV_ChangedAt,
                                    v.AC_PLV_PositedAt,
                                    v.AC_PLV_Stance
                                )
                    ) OR EXISTS (
                        SELECT
                            v.AC_PLV_PLV_ID
                        WHERE
                            v.AC_PLV_PLV_ID =
                                attributes.folAC_PLV_Actor_ProfessionalLevel (
                                    v.AC_PLV_AC_ID,
                                    v.AC_PLV_Who,
                                    v.AC_PLV_ChangedAt,
                                    v.AC_PLV_PositedAt,
                                    v.AC_PLV_Stance
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @AC_PLV_Actor_ProfessionalLevel v
        LEFT JOIN
            [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact] p
        ON
            p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
        AND
            p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            p.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
        WHERE
            v.AC_PLV_Version = @currentVersion;
        INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact] (
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        )
        SELECT
            AC_PLV_AC_ID,
            AC_PLV_ChangedAt,
            AC_PLV_PLV_ID
        FROM
            @AC_PLV_Actor_ProfessionalLevel
        WHERE
            AC_PLV_Version = @currentVersion
        AND
            AC_PLV_StatementType in ('N','R');
        INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Who,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
        )
        SELECT
            v.Metadata_AC_PLV,
            p.AC_PLV_ID,
            v.AC_PLV_Who,
            v.AC_PLV_PositedAt,
            v.AC_PLV_Confidence
        FROM
            @AC_PLV_Actor_ProfessionalLevel v
        JOIN
            [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact] p
        ON
            p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
        AND
            p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            p.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
        WHERE
            v.AC_PLV_Version = @currentVersion
        AND
            AC_PLV_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Program_Name instead of INSERT trigger on PR_NAM_Program_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_PR_NAM_Program_Name', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_PR_NAM_Program_Name];
GO
CREATE TRIGGER [attributes].[it_PR_NAM_Program_Name] ON [attributes].[PR_NAM_Program_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @PR_NAM_Program_Name TABLE (
        PR_NAM_PR_ID bigint not null,
        Metadata_PR_NAM bigint not null,
        PR_NAM_Who smallint not null,
        PR_NAM_PositedAt datetime2(3) not null,
        PR_NAM_Confidence decimal(7,3) not null,
        PR_NAM_Stance char(1) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_Version bigint not null,
        PR_NAM_StatementType char(1) not null,
        primary key(
            PR_NAM_Version,
            PR_NAM_Who,
            PR_NAM_PR_ID
        )
    );
    INSERT INTO @PR_NAM_Program_Name
    SELECT
        i.PR_NAM_PR_ID,
        i.Metadata_PR_NAM,
        i.PR_NAM_Who,
        i.PR_NAM_PositedAt,
        i.PR_NAM_Confidence,
        case
            when i.PR_NAM_Confidence > 0.25 then '+'
            when i.PR_NAM_Confidence = 0.25 then '?'
            when i.PR_NAM_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.PR_NAM_Program_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.PR_NAM_Who,
                i.PR_NAM_PR_ID
            ORDER BY
                i.PR_NAM_PositedAt ASC,
                i.PR_NAM_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(PR_NAM_Version),
        @currentVersion = 0
    FROM
        @PR_NAM_Program_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.PR_NAM_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.PR_NAM_ID
                        FROM
                            [anchors].[tPR_Program](v.PR_NAM_Who, DEFAULT, v.PR_NAM_PositedAt, v.PR_NAM_Stance) t
                        WHERE
                            t.PR_NAM_PR_ID = v.PR_NAM_PR_ID
                        AND
                            t.PR_NAM_Confidence = v.PR_NAM_Confidence
                        AND
                            t.PR_NAM_Program_Name = v.PR_NAM_Program_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.PR_NAM_PR_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @PR_NAM_Program_Name v
        LEFT JOIN
            [attributes].[PR_NAM_Program_Name_Fact] p
        ON
            p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
        AND
            p.PR_NAM_Program_Name = v.PR_NAM_Program_Name
        WHERE
            v.PR_NAM_Version = @currentVersion;
        INSERT INTO [attributes].[PR_NAM_Program_Name_Fact] (
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        )
        SELECT
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        FROM
            @PR_NAM_Program_Name
        WHERE
            PR_NAM_Version = @currentVersion
        AND
            PR_NAM_StatementType in ('N');
        INSERT INTO [attributes].[PR_NAM_Program_Name_Meta] (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Who,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
        )
        SELECT
            v.Metadata_PR_NAM,
            p.PR_NAM_ID,
            v.PR_NAM_Who,
            v.PR_NAM_PositedAt,
            v.PR_NAM_Confidence
        FROM
            @PR_NAM_Program_Name v
        JOIN
            [attributes].[PR_NAM_Program_Name_Fact] p
        ON
            p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
        AND
            p.PR_NAM_Program_Name = v.PR_NAM_Program_Name
        WHERE
            v.PR_NAM_Version = @currentVersion
        AND
            PR_NAM_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Program_Length instead of INSERT trigger on PR_LEN_Program_Length
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_PR_LEN_Program_Length', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_PR_LEN_Program_Length];
GO
CREATE TRIGGER [attributes].[it_PR_LEN_Program_Length] ON [attributes].[PR_LEN_Program_Length]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @PR_LEN_Program_Length TABLE (
        PR_LEN_PR_ID bigint not null,
        Metadata_PR_LEN bigint not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_Who smallint not null,
        PR_LEN_PositedAt datetime2(3) not null,
        PR_LEN_Confidence decimal(7,3) not null,
        PR_LEN_Stance char(1) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_Version bigint not null,
        PR_LEN_StatementType char(1) not null,
        primary key(
            PR_LEN_Version,
            PR_LEN_Who,
            PR_LEN_PR_ID
        )
    );
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_LEN_PR_ID,
        i.Metadata_PR_LEN,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_Who,
        i.PR_LEN_PositedAt,
        i.PR_LEN_Confidence,
        case
            when i.PR_LEN_Confidence > 0.25 then '+'
            when i.PR_LEN_Confidence = 0.25 then '?'
            when i.PR_LEN_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.PR_LEN_Program_Length,
        DENSE_RANK() OVER (
            PARTITION BY
                i.PR_LEN_Who,
                i.PR_LEN_PR_ID
            ORDER BY
                i.PR_LEN_ChangedAt ASC,
                i.PR_LEN_PositedAt ASC,
                i.PR_LEN_Confidence ASC
        ),
        'X'
    FROM
        inserted i;
    SELECT
        @maxVersion = max(PR_LEN_Version),
        @currentVersion = 0
    FROM
        @PR_LEN_Program_Length;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.PR_LEN_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.PR_LEN_ID
                        FROM
                            [anchors].[tPR_Program](v.PR_LEN_Who, v.PR_LEN_ChangedAt, v.PR_LEN_PositedAt, v.PR_LEN_Stance) t
                        WHERE
                            t.PR_LEN_PR_ID = v.PR_LEN_PR_ID
                        AND
                            t.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
                        AND
                            t.PR_LEN_Confidence = v.PR_LEN_Confidence
                        AND
                            t.PR_LEN_Program_Length = v.PR_LEN_Program_Length
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.PR_LEN_PR_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.PR_LEN_Program_Length
                        WHERE
                            v.PR_LEN_Program_Length =
                                attributes.prePR_LEN_Program_Length (
                                    v.PR_LEN_PR_ID,
                                    v.PR_LEN_Who,
                                    v.PR_LEN_ChangedAt,
                                    v.PR_LEN_PositedAt,
                                    v.PR_LEN_Stance
                                )
                    ) OR EXISTS (
                        SELECT
                            v.PR_LEN_Program_Length
                        WHERE
                            v.PR_LEN_Program_Length =
                                attributes.folPR_LEN_Program_Length (
                                    v.PR_LEN_PR_ID,
                                    v.PR_LEN_Who,
                                    v.PR_LEN_ChangedAt,
                                    v.PR_LEN_PositedAt,
                                    v.PR_LEN_Stance
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @PR_LEN_Program_Length v
        LEFT JOIN
            [attributes].[PR_LEN_Program_Length_Fact] p
        ON
            p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
        AND
            p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
        WHERE
            v.PR_LEN_Version = @currentVersion;
        INSERT INTO [attributes].[PR_LEN_Program_Length_Fact] (
            PR_LEN_PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        )
        SELECT
            PR_LEN_PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        FROM
            @PR_LEN_Program_Length
        WHERE
            PR_LEN_Version = @currentVersion
        AND
            PR_LEN_StatementType in ('N');
        INSERT INTO [attributes].[PR_LEN_Program_Length_Meta] (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Who,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        SELECT
            v.Metadata_PR_LEN,
            p.PR_LEN_ID,
            v.PR_LEN_Who,
            v.PR_LEN_PositedAt,
            v.PR_LEN_Confidence
        FROM
            @PR_LEN_Program_Length v
        JOIN
            [attributes].[PR_LEN_Program_Length_Fact] p
        ON
            p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
        AND
            p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
        WHERE
            v.PR_LEN_Version = @currentVersion
        AND
            PR_LEN_StatementType in ('S','N','D');
    END
END
GO
