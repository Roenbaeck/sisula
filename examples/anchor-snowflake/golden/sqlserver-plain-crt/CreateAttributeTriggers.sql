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
-- it_EV_DAT_Event_Date instead of INSERT trigger on EV_DAT_Event_Date
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_DAT_Event_Date', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_DAT_Event_Date];
GO
CREATE TRIGGER [dbo].[it_EV_DAT_Event_Date] ON [dbo].[EV_DAT_Event_Date]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_DAT_Event_Date TABLE (
        EV_ID int not null,
        EV_DAT_Positor tinyint not null,
        EV_DAT_PositedAt datetime2 not null,
        EV_DAT_Reliability decimal(5,2) not null,
        EV_DAT_Assertion char(1) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_Version bigint not null,
        EV_DAT_StatementType char(1) not null,
        primary key(
            EV_DAT_Version,
            EV_DAT_Positor,
            EV_ID
        )
    );
    INSERT INTO @EV_DAT_Event_Date
    SELECT
        i.EV_ID,
        i.EV_DAT_Positor,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Reliability,
        case
            when i.EV_DAT_Reliability > 0 then '+'
            when i.EV_DAT_Reliability = 0 then '?'
            when i.EV_DAT_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_DAT_Event_Date,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_DAT_Positor,
                i.EV_ID
            ORDER BY
                i.EV_DAT_PositedAt ASC,
                i.EV_DAT_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_DAT_Event_Date_Posit] p
        JOIN
            [dbo].[EV_DAT_Event_Date_Annex] a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_ID = i.EV_ID
        AND
            p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
        AND
            a.EV_DAT_Positor = i.EV_DAT_Positor
        AND
            a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
    );
    SELECT
        @maxVersion = max(EV_DAT_Version),
        @currentVersion = 0
    FROM
        @EV_DAT_Event_Date;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_DAT_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_DAT_ID
                        FROM
                            [dbo].[tEV_Event](v.EV_DAT_Positor, DEFAULT, v.EV_DAT_PositedAt, v.EV_DAT_Assertion) t
                        WHERE
                            t.EV_ID = v.EV_ID
                        AND
                            t.EV_DAT_Reliability = v.EV_DAT_Reliability
                        AND
                            t.EV_DAT_Event_Date = v.EV_DAT_Event_Date
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_DAT_Event_Date v
        LEFT JOIN
            [dbo].[EV_DAT_Event_Date_Posit] p
        ON
            p.EV_ID = v.EV_ID
        AND
            p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
        WHERE
            v.EV_DAT_Version = @currentVersion;
        INSERT INTO [dbo].[EV_DAT_Event_Date_Posit] (
            EV_ID,
            EV_DAT_Event_Date
        )
        SELECT
            EV_ID,
            EV_DAT_Event_Date
        FROM
            @EV_DAT_Event_Date
        WHERE
            EV_DAT_Version = @currentVersion
        AND
            EV_DAT_StatementType in ('N');
        INSERT INTO [dbo].[EV_DAT_Event_Date_Annex] (
            EV_DAT_ID,
            EV_DAT_Positor,
            EV_DAT_PositedAt,
            EV_DAT_Reliability
        )
        SELECT
            p.EV_DAT_ID,
            v.EV_DAT_Positor,
            v.EV_DAT_PositedAt,
            v.EV_DAT_Reliability
        FROM
            @EV_DAT_Event_Date v
        JOIN
            [dbo].[EV_DAT_Event_Date_Posit] p
        ON
            p.EV_ID = v.EV_ID
        AND
            p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
        WHERE
            v.EV_DAT_Version = @currentVersion
        AND
            EV_DAT_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_AUD_Event_Audience', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_AUD_Event_Audience];
GO
CREATE TRIGGER [dbo].[it_EV_AUD_Event_Audience] ON [dbo].[EV_AUD_Event_Audience]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_AUD_Event_Audience TABLE (
        EV_ID int not null,
        EV_AUD_Positor tinyint not null,
        EV_AUD_PositedAt datetime2 not null,
        EV_AUD_Reliability decimal(5,2) not null,
        EV_AUD_Assertion char(1) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_Version bigint not null,
        EV_AUD_StatementType char(1) not null,
        primary key(
            EV_AUD_Version,
            EV_AUD_Positor,
            EV_ID
        )
    );
    INSERT INTO @EV_AUD_Event_Audience
    SELECT
        i.EV_ID,
        i.EV_AUD_Positor,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Reliability,
        case
            when i.EV_AUD_Reliability > 0 then '+'
            when i.EV_AUD_Reliability = 0 then '?'
            when i.EV_AUD_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_AUD_Event_Audience,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_AUD_Positor,
                i.EV_ID
            ORDER BY
                i.EV_AUD_PositedAt ASC,
                i.EV_AUD_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_AUD_Event_Audience_Posit] p
        JOIN
            [dbo].[EV_AUD_Event_Audience_Annex] a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_ID = i.EV_ID
        AND
            p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
        AND
            a.EV_AUD_Positor = i.EV_AUD_Positor
        AND
            a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
    );
    SELECT
        @maxVersion = max(EV_AUD_Version),
        @currentVersion = 0
    FROM
        @EV_AUD_Event_Audience;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_AUD_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_AUD_ID
                        FROM
                            [dbo].[tEV_Event](v.EV_AUD_Positor, DEFAULT, v.EV_AUD_PositedAt, v.EV_AUD_Assertion) t
                        WHERE
                            t.EV_ID = v.EV_ID
                        AND
                            t.EV_AUD_Reliability = v.EV_AUD_Reliability
                        AND
                            t.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_AUD_Event_Audience v
        LEFT JOIN
            [dbo].[EV_AUD_Event_Audience_Posit] p
        ON
            p.EV_ID = v.EV_ID
        AND
            p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
        WHERE
            v.EV_AUD_Version = @currentVersion;
        INSERT INTO [dbo].[EV_AUD_Event_Audience_Posit] (
            EV_ID,
            EV_AUD_Event_Audience
        )
        SELECT
            EV_ID,
            EV_AUD_Event_Audience
        FROM
            @EV_AUD_Event_Audience
        WHERE
            EV_AUD_Version = @currentVersion
        AND
            EV_AUD_StatementType in ('N');
        INSERT INTO [dbo].[EV_AUD_Event_Audience_Annex] (
            EV_AUD_ID,
            EV_AUD_Positor,
            EV_AUD_PositedAt,
            EV_AUD_Reliability
        )
        SELECT
            p.EV_AUD_ID,
            v.EV_AUD_Positor,
            v.EV_AUD_PositedAt,
            v.EV_AUD_Reliability
        FROM
            @EV_AUD_Event_Audience v
        JOIN
            [dbo].[EV_AUD_Event_Audience_Posit] p
        ON
            p.EV_ID = v.EV_ID
        AND
            p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
        WHERE
            v.EV_AUD_Version = @currentVersion
        AND
            EV_AUD_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_REV_Event_Revenue', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_REV_Event_Revenue];
GO
CREATE TRIGGER [dbo].[it_EV_REV_Event_Revenue] ON [dbo].[EV_REV_Event_Revenue]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_REV_Event_Revenue TABLE (
        EV_ID int not null,
        EV_REV_Positor tinyint not null,
        EV_REV_PositedAt datetime2 not null,
        EV_REV_Reliability decimal(5,2) not null,
        EV_REV_Assertion char(1) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_Version bigint not null,
        EV_REV_StatementType char(1) not null,
        primary key(
            EV_REV_Version,
            EV_REV_Positor,
            EV_ID
        )
    );
    INSERT INTO @EV_REV_Event_Revenue
    SELECT
        i.EV_ID,
        i.EV_REV_Positor,
        i.EV_REV_PositedAt,
        i.EV_REV_Reliability,
        case
            when i.EV_REV_Reliability > 0 then '+'
            when i.EV_REV_Reliability = 0 then '?'
            when i.EV_REV_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_REV_Event_Revenue,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_REV_Positor,
                i.EV_ID
            ORDER BY
                i.EV_REV_PositedAt ASC,
                i.EV_REV_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_REV_Event_Revenue_Posit] p
        JOIN
            [dbo].[EV_REV_Event_Revenue_Annex] a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_ID = i.EV_ID
        AND
            p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
        AND
            a.EV_REV_Positor = i.EV_REV_Positor
        AND
            a.EV_REV_PositedAt = i.EV_REV_PositedAt
    );
    SELECT
        @maxVersion = max(EV_REV_Version),
        @currentVersion = 0
    FROM
        @EV_REV_Event_Revenue;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_REV_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_REV_ID
                        FROM
                            [dbo].[tEV_Event](v.EV_REV_Positor, DEFAULT, v.EV_REV_PositedAt, v.EV_REV_Assertion) t
                        WHERE
                            t.EV_ID = v.EV_ID
                        AND
                            t.EV_REV_Reliability = v.EV_REV_Reliability
                        AND
                            t.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_REV_Event_Revenue v
        LEFT JOIN
            [dbo].[EV_REV_Event_Revenue_Posit] p
        ON
            p.EV_ID = v.EV_ID
        AND
            p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
        WHERE
            v.EV_REV_Version = @currentVersion;
        INSERT INTO [dbo].[EV_REV_Event_Revenue_Posit] (
            EV_ID,
            EV_REV_Event_Revenue
        )
        SELECT
            EV_ID,
            EV_REV_Event_Revenue
        FROM
            @EV_REV_Event_Revenue
        WHERE
            EV_REV_Version = @currentVersion
        AND
            EV_REV_StatementType in ('N');
        INSERT INTO [dbo].[EV_REV_Event_Revenue_Annex] (
            EV_REV_ID,
            EV_REV_Positor,
            EV_REV_PositedAt,
            EV_REV_Reliability
        )
        SELECT
            p.EV_REV_ID,
            v.EV_REV_Positor,
            v.EV_REV_PositedAt,
            v.EV_REV_Reliability
        FROM
            @EV_REV_Event_Revenue v
        JOIN
            [dbo].[EV_REV_Event_Revenue_Posit] p
        ON
            p.EV_ID = v.EV_ID
        AND
            p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
        WHERE
            v.EV_REV_Version = @currentVersion
        AND
            EV_REV_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Stage_Name instead of INSERT trigger on ST_NAM_Stage_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_NAM_Stage_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_NAM_Stage_Name];
GO
CREATE TRIGGER [dbo].[it_ST_NAM_Stage_Name] ON [dbo].[ST_NAM_Stage_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_NAM_Stage_Name TABLE (
        ST_ID int not null,
        ST_NAM_ChangedAt datetime2 not null,
        ST_NAM_Positor tinyint not null,
        ST_NAM_PositedAt datetime2 not null,
        ST_NAM_Reliability decimal(5,2) not null,
        ST_NAM_Assertion char(1) not null,
        ST_NAM_Stage_Name nvarchar(42) not null,
        ST_NAM_Version bigint not null,
        ST_NAM_StatementType char(1) not null,
        primary key(
            ST_NAM_Version,
            ST_NAM_Positor,
            ST_ID
        )
    );
    INSERT INTO @ST_NAM_Stage_Name
    SELECT
        i.ST_ID,
        i.ST_NAM_ChangedAt,
        i.ST_NAM_Positor,
        i.ST_NAM_PositedAt,
        i.ST_NAM_Reliability,
        case
            when i.ST_NAM_Reliability > 0 then '+'
            when i.ST_NAM_Reliability = 0 then '?'
            when i.ST_NAM_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.ST_NAM_Stage_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_NAM_Positor,
                i.ST_ID
            ORDER BY
                i.ST_NAM_ChangedAt ASC,
                i.ST_NAM_PositedAt ASC,
                i.ST_NAM_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_NAM_Stage_Name_Posit] p
        JOIN
            [dbo].[ST_NAM_Stage_Name_Annex] a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_ID = i.ST_ID
        AND
            p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
        AND
            p.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
        AND
            a.ST_NAM_Positor = i.ST_NAM_Positor
        AND
            a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
    );
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
                            [dbo].[tST_Stage](v.ST_NAM_Positor, v.ST_NAM_ChangedAt, v.ST_NAM_PositedAt, v.ST_NAM_Assertion) t
                        WHERE
                            t.ST_ID = v.ST_ID
                        AND
                            t.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
                        AND
                            t.ST_NAM_Reliability = v.ST_NAM_Reliability
                        AND
                            t.ST_NAM_Stage_Name = v.ST_NAM_Stage_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.ST_NAM_Stage_Name
                        WHERE
                            v.ST_NAM_Stage_Name =
                                dbo.preST_NAM_Stage_Name (
                                    v.ST_ID,
                                    v.ST_NAM_Positor,
                                    v.ST_NAM_ChangedAt,
                                    v.ST_NAM_PositedAt,
                                    v.ST_NAM_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.ST_NAM_Stage_Name
                        WHERE
                            v.ST_NAM_Stage_Name =
                                dbo.folST_NAM_Stage_Name (
                                    v.ST_ID,
                                    v.ST_NAM_Positor,
                                    v.ST_NAM_ChangedAt,
                                    v.ST_NAM_PositedAt,
                                    v.ST_NAM_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_NAM_Stage_Name v
        LEFT JOIN
            [dbo].[ST_NAM_Stage_Name_Posit] p
        ON
            p.ST_ID = v.ST_ID
        AND
            p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
        AND
            p.ST_NAM_Stage_Name = v.ST_NAM_Stage_Name
        WHERE
            v.ST_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[ST_NAM_Stage_Name_Posit] (
            ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        )
        SELECT
            ST_ID,
            ST_NAM_ChangedAt,
            ST_NAM_Stage_Name
        FROM
            @ST_NAM_Stage_Name
        WHERE
            ST_NAM_Version = @currentVersion
        AND
            ST_NAM_StatementType in ('N','R');
        INSERT INTO [dbo].[ST_NAM_Stage_Name_Annex] (
            ST_NAM_ID,
            ST_NAM_Positor,
            ST_NAM_PositedAt,
            ST_NAM_Reliability
        )
        SELECT
            p.ST_NAM_ID,
            v.ST_NAM_Positor,
            v.ST_NAM_PositedAt,
            v.ST_NAM_Reliability
        FROM
            @ST_NAM_Stage_Name v
        JOIN
            [dbo].[ST_NAM_Stage_Name_Posit] p
        ON
            p.ST_ID = v.ST_ID
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
IF Object_ID('dbo.it_ST_LOC_Stage_Location', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_LOC_Stage_Location];
GO
CREATE TRIGGER [dbo].[it_ST_LOC_Stage_Location] ON [dbo].[ST_LOC_Stage_Location]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_LOC_Stage_Location TABLE (
        ST_ID int not null,
        ST_LOC_Positor tinyint not null,
        ST_LOC_PositedAt datetime2 not null,
        ST_LOC_Reliability decimal(5,2) not null,
        ST_LOC_Assertion char(1) not null,
        ST_LOC_Stage_Location geography not null,
        ST_LOC_Checksum varbinary(16) not null,
        ST_LOC_Version bigint not null,
        ST_LOC_StatementType char(1) not null,
        primary key(
            ST_LOC_Version,
            ST_LOC_Positor,
            ST_ID
        )
    );
    INSERT INTO @ST_LOC_Stage_Location
    SELECT
        i.ST_ID,
        i.ST_LOC_Positor,
        i.ST_LOC_PositedAt,
        i.ST_LOC_Reliability,
        case
            when i.ST_LOC_Reliability > 0 then '+'
            when i.ST_LOC_Reliability = 0 then '?'
            when i.ST_LOC_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.ST_LOC_Stage_Location,
        dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_LOC_Positor,
                i.ST_ID
            ORDER BY
                i.ST_LOC_PositedAt ASC,
                i.ST_LOC_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_LOC_Stage_Location_Posit] p
        JOIN
            [dbo].[ST_LOC_Stage_Location_Annex] a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_ID = i.ST_ID
        AND
            p.ST_LOC_Checksum = dbo.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max))) 
        AND
            a.ST_LOC_Positor = i.ST_LOC_Positor
        AND
            a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
    );
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
                            [dbo].[tST_Stage](v.ST_LOC_Positor, DEFAULT, v.ST_LOC_PositedAt, v.ST_LOC_Assertion) t
                        WHERE
                            t.ST_ID = v.ST_ID
                        AND
                            t.ST_LOC_Reliability = v.ST_LOC_Reliability
                        AND
                            t.ST_LOC_Checksum = v.ST_LOC_Checksum 
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_LOC_Stage_Location v
        LEFT JOIN
            [dbo].[ST_LOC_Stage_Location_Posit] p
        ON
            p.ST_ID = v.ST_ID
        AND
            p.ST_LOC_Checksum = v.ST_LOC_Checksum 
        WHERE
            v.ST_LOC_Version = @currentVersion;
        INSERT INTO [dbo].[ST_LOC_Stage_Location_Posit] (
            ST_ID,
            ST_LOC_Stage_Location
        )
        SELECT
            ST_ID,
            ST_LOC_Stage_Location
        FROM
            @ST_LOC_Stage_Location
        WHERE
            ST_LOC_Version = @currentVersion
        AND
            ST_LOC_StatementType in ('N');
        INSERT INTO [dbo].[ST_LOC_Stage_Location_Annex] (
            ST_LOC_ID,
            ST_LOC_Positor,
            ST_LOC_PositedAt,
            ST_LOC_Reliability
        )
        SELECT
            p.ST_LOC_ID,
            v.ST_LOC_Positor,
            v.ST_LOC_PositedAt,
            v.ST_LOC_Reliability
        FROM
            @ST_LOC_Stage_Location v
        JOIN
            [dbo].[ST_LOC_Stage_Location_Posit] p
        ON
            p.ST_ID = v.ST_ID
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
IF Object_ID('dbo.it_ST_AVG_Stage_Average', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_AVG_Stage_Average];
GO
CREATE TRIGGER [dbo].[it_ST_AVG_Stage_Average] ON [dbo].[ST_AVG_Stage_Average]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_AVG_Stage_Average TABLE (
        ST_ID int not null,
        ST_AVG_ChangedAt datetime2 not null,
        ST_AVG_Positor tinyint not null,
        ST_AVG_PositedAt datetime2 not null,
        ST_AVG_Reliability decimal(5,2) not null,
        ST_AVG_Assertion char(1) not null,
        UTL_ID tinyint not null, 
        ST_AVG_Version bigint not null,
        ST_AVG_StatementType char(1) not null,
        primary key(
            ST_AVG_Version,
            ST_AVG_Positor,
            ST_ID
        )
    );
    INSERT INTO @ST_AVG_Stage_Average
    SELECT
        i.ST_ID,
        i.ST_AVG_ChangedAt,
        i.ST_AVG_Positor,
        i.ST_AVG_PositedAt,
        i.ST_AVG_Reliability,
        case
            when i.ST_AVG_Reliability > 0 then '+'
            when i.ST_AVG_Reliability = 0 then '?'
            when i.ST_AVG_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.UTL_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_AVG_Positor,
                i.ST_ID
            ORDER BY
                i.ST_AVG_ChangedAt ASC,
                i.ST_AVG_PositedAt ASC,
                i.ST_AVG_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_AVG_Stage_Average_Posit] p
        JOIN
            [dbo].[ST_AVG_Stage_Average_Annex] a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_ID = i.ST_ID
        AND
            p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
        AND
            p.UTL_ID = i.UTL_ID
        AND
            a.ST_AVG_Positor = i.ST_AVG_Positor
        AND
            a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
    );
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
                            [dbo].[tST_Stage](v.ST_AVG_Positor, v.ST_AVG_ChangedAt, v.ST_AVG_PositedAt, v.ST_AVG_Assertion) t
                        WHERE
                            t.ST_ID = v.ST_ID
                        AND
                            t.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
                        AND
                            t.ST_AVG_Reliability = v.ST_AVG_Reliability
                        AND
                            t.UTL_ID = v.UTL_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.UTL_ID
                        WHERE
                            v.UTL_ID =
                                dbo.preST_AVG_Stage_Average (
                                    v.ST_ID,
                                    v.ST_AVG_Positor,
                                    v.ST_AVG_ChangedAt,
                                    v.ST_AVG_PositedAt,
                                    v.ST_AVG_Assertion
                                )
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            v.UTL_ID
                        WHERE
                            v.UTL_ID =
                                dbo.folST_AVG_Stage_Average (
                                    v.ST_ID,
                                    v.ST_AVG_Positor,
                                    v.ST_AVG_ChangedAt,
                                    v.ST_AVG_PositedAt,
                                    v.ST_AVG_Assertion
                                )
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_AVG_Stage_Average v
        LEFT JOIN
            [dbo].[ST_AVG_Stage_Average_Posit] p
        ON
            p.ST_ID = v.ST_ID
        AND
            p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            p.UTL_ID = v.UTL_ID
        WHERE
            v.ST_AVG_Version = @currentVersion;
        INSERT INTO [dbo].[ST_AVG_Stage_Average_Posit] (
            ST_ID,
            ST_AVG_ChangedAt,
            UTL_ID
        )
        SELECT
            ST_ID,
            ST_AVG_ChangedAt,
            UTL_ID
        FROM
            @ST_AVG_Stage_Average
        WHERE
            ST_AVG_Version = @currentVersion
        AND
            ST_AVG_StatementType in ('N','F');
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
            ST_AVG_ID,
            ST_AVG_Positor,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            fol.ST_AVG_ID,
            v.ST_AVG_Positor,
            v.ST_AVG_PositedAt,
            0
        FROM
            @ST_AVG_Stage_Average v
        CROSS APPLY (
            SELECT TOP 1
                f.ST_AVG_ID,
                f.UTL_ID
            FROM
                [dbo].[fST_AVG_Stage_Average](
                    v.ST_AVG_Positor,
                    v.ST_AVG_ChangedAt,
                    v.ST_AVG_PositedAt
                ) f
            WHERE
                f.ST_ID = v.ST_ID
            AND
                f.ST_AVG_ChangedAt > v.ST_AVG_ChangedAt
            AND
                f.ST_AVG_Assertion = v.ST_AVG_Assertion
            ORDER BY
                f.ST_AVG_ChangedAt ASC,
                f.ST_AVG_PositedAt DESC
        ) fol
        WHERE
            v.ST_AVG_Version = @currentVersion
        AND
            v.ST_AVG_StatementType = 'F'
        AND
            fol.UTL_ID = v.UTL_ID;
        INSERT INTO [dbo].[ST_AVG_Stage_Average_Annex] (
            ST_AVG_ID,
            ST_AVG_Positor,
            ST_AVG_PositedAt,
            ST_AVG_Reliability
        )
        SELECT
            p.ST_AVG_ID,
            v.ST_AVG_Positor,
            v.ST_AVG_PositedAt,
            v.ST_AVG_Reliability
        FROM
            @ST_AVG_Stage_Average v
        JOIN
            [dbo].[ST_AVG_Stage_Average_Posit] p
        ON
            p.ST_ID = v.ST_ID
        AND
            p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
        AND
            p.UTL_ID = v.UTL_ID
        WHERE
            v.ST_AVG_Version = @currentVersion
        AND
            ST_AVG_StatementType in ('S','N','D','F');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Stage_Minimum instead of INSERT trigger on ST_MIN_Stage_Minimum
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_MIN_Stage_Minimum', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_MIN_Stage_Minimum];
GO
CREATE TRIGGER [dbo].[it_ST_MIN_Stage_Minimum] ON [dbo].[ST_MIN_Stage_Minimum]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @ST_MIN_Stage_Minimum TABLE (
        ST_ID int not null,
        ST_MIN_Positor tinyint not null,
        ST_MIN_PositedAt datetime2 not null,
        ST_MIN_Reliability decimal(5,2) not null,
        ST_MIN_Assertion char(1) not null,
        UTL_ID tinyint not null, 
        ST_MIN_Version bigint not null,
        ST_MIN_StatementType char(1) not null,
        primary key(
            ST_MIN_Version,
            ST_MIN_Positor,
            ST_ID
        )
    );
    INSERT INTO @ST_MIN_Stage_Minimum
    SELECT
        i.ST_ID,
        i.ST_MIN_Positor,
        i.ST_MIN_PositedAt,
        i.ST_MIN_Reliability,
        case
            when i.ST_MIN_Reliability > 0 then '+'
            when i.ST_MIN_Reliability = 0 then '?'
            when i.ST_MIN_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.UTL_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_MIN_Positor,
                i.ST_ID
            ORDER BY
                i.ST_MIN_PositedAt ASC,
                i.ST_MIN_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Annex] a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_ID = i.ST_ID
        AND
            p.UTL_ID = i.UTL_ID
        AND
            a.ST_MIN_Positor = i.ST_MIN_Positor
        AND
            a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
    );
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
                            [dbo].[tST_Stage](v.ST_MIN_Positor, DEFAULT, v.ST_MIN_PositedAt, v.ST_MIN_Assertion) t
                        WHERE
                            t.ST_ID = v.ST_ID
                        AND
                            t.ST_MIN_Reliability = v.ST_MIN_Reliability
                        AND
                            t.UTL_ID = v.UTL_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @ST_MIN_Stage_Minimum v
        LEFT JOIN
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        ON
            p.ST_ID = v.ST_ID
        AND
            p.UTL_ID = v.UTL_ID
        WHERE
            v.ST_MIN_Version = @currentVersion;
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Posit] (
            ST_ID,
            UTL_ID
        )
        SELECT
            ST_ID,
            UTL_ID
        FROM
            @ST_MIN_Stage_Minimum
        WHERE
            ST_MIN_Version = @currentVersion
        AND
            ST_MIN_StatementType in ('N');
        INSERT INTO [dbo].[ST_MIN_Stage_Minimum_Annex] (
            ST_MIN_ID,
            ST_MIN_Positor,
            ST_MIN_PositedAt,
            ST_MIN_Reliability
        )
        SELECT
            p.ST_MIN_ID,
            v.ST_MIN_Positor,
            v.ST_MIN_PositedAt,
            v.ST_MIN_Reliability
        FROM
            @ST_MIN_Stage_Minimum v
        JOIN
            [dbo].[ST_MIN_Stage_Minimum_Posit] p
        ON
            p.ST_ID = v.ST_ID
        AND
            p.UTL_ID = v.UTL_ID
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
IF Object_ID('dbo.it_AC_NAM_Actor_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_NAM_Actor_Name];
GO
CREATE TRIGGER [dbo].[it_AC_NAM_Actor_Name] ON [dbo].[AC_NAM_Actor_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @AC_NAM_Actor_Name TABLE (
        AC_ID int not null,
        AC_NAM_ChangedAt datetime2 not null,
        AC_NAM_Positor tinyint not null,
        AC_NAM_PositedAt datetime2 not null,
        AC_NAM_Reliability decimal(5,2) not null,
        AC_NAM_Assertion char(1) not null,
        AC_NAM_Actor_Name nvarchar(42) not null,
        AC_NAM_Version bigint not null,
        AC_NAM_StatementType char(1) not null,
        primary key(
            AC_NAM_Version,
            AC_NAM_Positor,
            AC_ID
        )
    );
    INSERT INTO @AC_NAM_Actor_Name
    SELECT
        i.AC_ID,
        i.AC_NAM_ChangedAt,
        i.AC_NAM_Positor,
        i.AC_NAM_PositedAt,
        i.AC_NAM_Reliability,
        case
            when i.AC_NAM_Reliability > 0 then '+'
            when i.AC_NAM_Reliability = 0 then '?'
            when i.AC_NAM_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.AC_NAM_Actor_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_NAM_Positor,
                i.AC_ID
            ORDER BY
                i.AC_NAM_ChangedAt ASC,
                i.AC_NAM_PositedAt ASC,
                i.AC_NAM_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_NAM_Actor_Name_Posit] p
        JOIN
            [dbo].[AC_NAM_Actor_Name_Annex] a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_ID = i.AC_ID
        AND
            p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
        AND
            p.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
        AND
            a.AC_NAM_Positor = i.AC_NAM_Positor
        AND
            a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
    );
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
                            [dbo].[tAC_Actor](v.AC_NAM_Positor, v.AC_NAM_ChangedAt, v.AC_NAM_PositedAt, v.AC_NAM_Assertion) t
                        WHERE
                            t.AC_ID = v.AC_ID
                        AND
                            t.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
                        AND
                            t.AC_NAM_Reliability = v.AC_NAM_Reliability
                        AND
                            t.AC_NAM_Actor_Name = v.AC_NAM_Actor_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.AC_NAM_Actor_Name
                        WHERE
                            v.AC_NAM_Actor_Name =
                                dbo.preAC_NAM_Actor_Name (
                                    v.AC_ID,
                                    v.AC_NAM_Positor,
                                    v.AC_NAM_ChangedAt,
                                    v.AC_NAM_PositedAt,
                                    v.AC_NAM_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.AC_NAM_Actor_Name
                        WHERE
                            v.AC_NAM_Actor_Name =
                                dbo.folAC_NAM_Actor_Name (
                                    v.AC_ID,
                                    v.AC_NAM_Positor,
                                    v.AC_NAM_ChangedAt,
                                    v.AC_NAM_PositedAt,
                                    v.AC_NAM_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @AC_NAM_Actor_Name v
        LEFT JOIN
            [dbo].[AC_NAM_Actor_Name_Posit] p
        ON
            p.AC_ID = v.AC_ID
        AND
            p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
        AND
            p.AC_NAM_Actor_Name = v.AC_NAM_Actor_Name
        WHERE
            v.AC_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[AC_NAM_Actor_Name_Posit] (
            AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        )
        SELECT
            AC_ID,
            AC_NAM_ChangedAt,
            AC_NAM_Actor_Name
        FROM
            @AC_NAM_Actor_Name
        WHERE
            AC_NAM_Version = @currentVersion
        AND
            AC_NAM_StatementType in ('N','R');
        INSERT INTO [dbo].[AC_NAM_Actor_Name_Annex] (
            AC_NAM_ID,
            AC_NAM_Positor,
            AC_NAM_PositedAt,
            AC_NAM_Reliability
        )
        SELECT
            p.AC_NAM_ID,
            v.AC_NAM_Positor,
            v.AC_NAM_PositedAt,
            v.AC_NAM_Reliability
        FROM
            @AC_NAM_Actor_Name v
        JOIN
            [dbo].[AC_NAM_Actor_Name_Posit] p
        ON
            p.AC_ID = v.AC_ID
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
IF Object_ID('dbo.it_AC_GEN_Actor_Gender', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_GEN_Actor_Gender];
GO
CREATE TRIGGER [dbo].[it_AC_GEN_Actor_Gender] ON [dbo].[AC_GEN_Actor_Gender]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @AC_GEN_Actor_Gender TABLE (
        AC_ID int not null,
        AC_GEN_Positor tinyint not null,
        AC_GEN_PositedAt datetime2 not null,
        AC_GEN_Reliability decimal(5,2) not null,
        AC_GEN_Assertion char(1) not null,
        GEN_ID tinyint not null, 
        AC_GEN_Version bigint not null,
        AC_GEN_StatementType char(1) not null,
        primary key(
            AC_GEN_Version,
            AC_GEN_Positor,
            AC_ID
        )
    );
    INSERT INTO @AC_GEN_Actor_Gender
    SELECT
        i.AC_ID,
        i.AC_GEN_Positor,
        i.AC_GEN_PositedAt,
        i.AC_GEN_Reliability,
        case
            when i.AC_GEN_Reliability > 0 then '+'
            when i.AC_GEN_Reliability = 0 then '?'
            when i.AC_GEN_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.GEN_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_GEN_Positor,
                i.AC_ID
            ORDER BY
                i.AC_GEN_PositedAt ASC,
                i.AC_GEN_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Annex] a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_ID = i.AC_ID
        AND
            p.GEN_ID = i.GEN_ID
        AND
            a.AC_GEN_Positor = i.AC_GEN_Positor
        AND
            a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
    );
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
                            [dbo].[tAC_Actor](v.AC_GEN_Positor, DEFAULT, v.AC_GEN_PositedAt, v.AC_GEN_Assertion) t
                        WHERE
                            t.AC_ID = v.AC_ID
                        AND
                            t.AC_GEN_Reliability = v.AC_GEN_Reliability
                        AND
                            t.GEN_ID = v.GEN_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @AC_GEN_Actor_Gender v
        LEFT JOIN
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        ON
            p.AC_ID = v.AC_ID
        AND
            p.GEN_ID = v.GEN_ID
        WHERE
            v.AC_GEN_Version = @currentVersion;
        INSERT INTO [dbo].[AC_GEN_Actor_Gender_Posit] (
            AC_ID,
            GEN_ID
        )
        SELECT
            AC_ID,
            GEN_ID
        FROM
            @AC_GEN_Actor_Gender
        WHERE
            AC_GEN_Version = @currentVersion
        AND
            AC_GEN_StatementType in ('N');
        INSERT INTO [dbo].[AC_GEN_Actor_Gender_Annex] (
            AC_GEN_ID,
            AC_GEN_Positor,
            AC_GEN_PositedAt,
            AC_GEN_Reliability
        )
        SELECT
            p.AC_GEN_ID,
            v.AC_GEN_Positor,
            v.AC_GEN_PositedAt,
            v.AC_GEN_Reliability
        FROM
            @AC_GEN_Actor_Gender v
        JOIN
            [dbo].[AC_GEN_Actor_Gender_Posit] p
        ON
            p.AC_ID = v.AC_ID
        AND
            p.GEN_ID = v.GEN_ID
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
IF Object_ID('dbo.it_AC_PLV_Actor_ProfessionalLevel', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel];
GO
CREATE TRIGGER [dbo].[it_AC_PLV_Actor_ProfessionalLevel] ON [dbo].[AC_PLV_Actor_ProfessionalLevel]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @AC_PLV_Actor_ProfessionalLevel TABLE (
        AC_ID int not null,
        AC_PLV_ChangedAt datetime2 not null,
        AC_PLV_Positor tinyint not null,
        AC_PLV_PositedAt datetime2 not null,
        AC_PLV_Reliability decimal(5,2) not null,
        AC_PLV_Assertion char(1) not null,
        PLV_ID tinyint not null, 
        AC_PLV_Version bigint not null,
        AC_PLV_StatementType char(1) not null,
        primary key(
            AC_PLV_Version,
            AC_PLV_Positor,
            AC_ID
        )
    );
    INSERT INTO @AC_PLV_Actor_ProfessionalLevel
    SELECT
        i.AC_ID,
        i.AC_PLV_ChangedAt,
        i.AC_PLV_Positor,
        i.AC_PLV_PositedAt,
        i.AC_PLV_Reliability,
        case
            when i.AC_PLV_Reliability > 0 then '+'
            when i.AC_PLV_Reliability = 0 then '?'
            when i.AC_PLV_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.PLV_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_PLV_Positor,
                i.AC_ID
            ORDER BY
                i.AC_PLV_ChangedAt ASC,
                i.AC_PLV_PositedAt ASC,
                i.AC_PLV_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_ID = i.AC_ID
        AND
            p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
        AND
            p.PLV_ID = i.PLV_ID
        AND
            a.AC_PLV_Positor = i.AC_PLV_Positor
        AND
            a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
    );
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
                            [dbo].[tAC_Actor](v.AC_PLV_Positor, v.AC_PLV_ChangedAt, v.AC_PLV_PositedAt, v.AC_PLV_Assertion) t
                        WHERE
                            t.AC_ID = v.AC_ID
                        AND
                            t.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
                        AND
                            t.AC_PLV_Reliability = v.AC_PLV_Reliability
                        AND
                            t.PLV_ID = v.PLV_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.PLV_ID
                        WHERE
                            v.PLV_ID =
                                dbo.preAC_PLV_Actor_ProfessionalLevel (
                                    v.AC_ID,
                                    v.AC_PLV_Positor,
                                    v.AC_PLV_ChangedAt,
                                    v.AC_PLV_PositedAt,
                                    v.AC_PLV_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.PLV_ID
                        WHERE
                            v.PLV_ID =
                                dbo.folAC_PLV_Actor_ProfessionalLevel (
                                    v.AC_ID,
                                    v.AC_PLV_Positor,
                                    v.AC_PLV_ChangedAt,
                                    v.AC_PLV_PositedAt,
                                    v.AC_PLV_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @AC_PLV_Actor_ProfessionalLevel v
        LEFT JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        ON
            p.AC_ID = v.AC_ID
        AND
            p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            p.PLV_ID = v.PLV_ID
        WHERE
            v.AC_PLV_Version = @currentVersion;
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] (
            AC_ID,
            AC_PLV_ChangedAt,
            PLV_ID
        )
        SELECT
            AC_ID,
            AC_PLV_ChangedAt,
            PLV_ID
        FROM
            @AC_PLV_Actor_ProfessionalLevel
        WHERE
            AC_PLV_Version = @currentVersion
        AND
            AC_PLV_StatementType in ('N','R');
        INSERT INTO [dbo].[AC_PLV_Actor_ProfessionalLevel_Annex] (
            AC_PLV_ID,
            AC_PLV_Positor,
            AC_PLV_PositedAt,
            AC_PLV_Reliability
        )
        SELECT
            p.AC_PLV_ID,
            v.AC_PLV_Positor,
            v.AC_PLV_PositedAt,
            v.AC_PLV_Reliability
        FROM
            @AC_PLV_Actor_ProfessionalLevel v
        JOIN
            [dbo].[AC_PLV_Actor_ProfessionalLevel_Posit] p
        ON
            p.AC_ID = v.AC_ID
        AND
            p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
        AND
            p.PLV_ID = v.PLV_ID
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
IF Object_ID('dbo.it_PR_NAM_Program_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_NAM_Program_Name];
GO
CREATE TRIGGER [dbo].[it_PR_NAM_Program_Name] ON [dbo].[PR_NAM_Program_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @PR_NAM_Program_Name TABLE (
        PR_ID int not null,
        PR_NAM_Positor tinyint not null,
        PR_NAM_PositedAt datetime2 not null,
        PR_NAM_Reliability decimal(5,2) not null,
        PR_NAM_Assertion char(1) not null,
        PR_NAM_Program_Name nvarchar(42) not null,
        PR_NAM_Version bigint not null,
        PR_NAM_StatementType char(1) not null,
        primary key(
            PR_NAM_Version,
            PR_NAM_Positor,
            PR_ID
        )
    );
    INSERT INTO @PR_NAM_Program_Name
    SELECT
        i.PR_ID,
        i.PR_NAM_Positor,
        i.PR_NAM_PositedAt,
        i.PR_NAM_Reliability,
        case
            when i.PR_NAM_Reliability > 0 then '+'
            when i.PR_NAM_Reliability = 0 then '?'
            when i.PR_NAM_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.PR_NAM_Program_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.PR_NAM_Positor,
                i.PR_ID
            ORDER BY
                i.PR_NAM_PositedAt ASC,
                i.PR_NAM_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[PR_NAM_Program_Name_Posit] p
        JOIN
            [dbo].[PR_NAM_Program_Name_Annex] a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_ID = i.PR_ID
        AND
            p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
        AND
            a.PR_NAM_Positor = i.PR_NAM_Positor
        AND
            a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
    );
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
                            [dbo].[tPR_Program](v.PR_NAM_Positor, DEFAULT, v.PR_NAM_PositedAt, v.PR_NAM_Assertion) t
                        WHERE
                            t.PR_ID = v.PR_ID
                        AND
                            t.PR_NAM_Reliability = v.PR_NAM_Reliability
                        AND
                            t.PR_NAM_Program_Name = v.PR_NAM_Program_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.PR_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @PR_NAM_Program_Name v
        LEFT JOIN
            [dbo].[PR_NAM_Program_Name_Posit] p
        ON
            p.PR_ID = v.PR_ID
        AND
            p.PR_NAM_Program_Name = v.PR_NAM_Program_Name
        WHERE
            v.PR_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[PR_NAM_Program_Name_Posit] (
            PR_ID,
            PR_NAM_Program_Name
        )
        SELECT
            PR_ID,
            PR_NAM_Program_Name
        FROM
            @PR_NAM_Program_Name
        WHERE
            PR_NAM_Version = @currentVersion
        AND
            PR_NAM_StatementType in ('N');
        INSERT INTO [dbo].[PR_NAM_Program_Name_Annex] (
            PR_NAM_ID,
            PR_NAM_Positor,
            PR_NAM_PositedAt,
            PR_NAM_Reliability
        )
        SELECT
            p.PR_NAM_ID,
            v.PR_NAM_Positor,
            v.PR_NAM_PositedAt,
            v.PR_NAM_Reliability
        FROM
            @PR_NAM_Program_Name v
        JOIN
            [dbo].[PR_NAM_Program_Name_Posit] p
        ON
            p.PR_ID = v.PR_ID
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
IF Object_ID('dbo.it_PR_LEN_Program_Length', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_LEN_Program_Length];
GO
CREATE TRIGGER [dbo].[it_PR_LEN_Program_Length] ON [dbo].[PR_LEN_Program_Length]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @PR_LEN_Program_Length TABLE (
        PR_ID int not null,
        PR_LEN_ChangedAt date not null,
        PR_LEN_Positor tinyint not null,
        PR_LEN_PositedAt datetime2 not null,
        PR_LEN_Reliability decimal(5,2) not null,
        PR_LEN_Assertion char(1) not null,
        PR_LEN_Program_Length time not null,
        PR_LEN_Version bigint not null,
        PR_LEN_StatementType char(1) not null,
        primary key(
            PR_LEN_Version,
            PR_LEN_Positor,
            PR_ID
        )
    );
    INSERT INTO @PR_LEN_Program_Length
    SELECT
        i.PR_ID,
        i.PR_LEN_ChangedAt,
        i.PR_LEN_Positor,
        i.PR_LEN_PositedAt,
        i.PR_LEN_Reliability,
        case
            when i.PR_LEN_Reliability > 0 then '+'
            when i.PR_LEN_Reliability = 0 then '?'
            when i.PR_LEN_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.PR_LEN_Program_Length,
        DENSE_RANK() OVER (
            PARTITION BY
                i.PR_LEN_Positor,
                i.PR_ID
            ORDER BY
                i.PR_LEN_ChangedAt ASC,
                i.PR_LEN_PositedAt ASC,
                i.PR_LEN_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[PR_LEN_Program_Length_Posit] p
        JOIN
            [dbo].[PR_LEN_Program_Length_Annex] a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_ID = i.PR_ID
        AND
            p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
        AND
            p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
        AND
            a.PR_LEN_Positor = i.PR_LEN_Positor
        AND
            a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
    );
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
                            [dbo].[tPR_Program](v.PR_LEN_Positor, v.PR_LEN_ChangedAt, v.PR_LEN_PositedAt, v.PR_LEN_Assertion) t
                        WHERE
                            t.PR_ID = v.PR_ID
                        AND
                            t.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
                        AND
                            t.PR_LEN_Reliability = v.PR_LEN_Reliability
                        AND
                            t.PR_LEN_Program_Length = v.PR_LEN_Program_Length
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.PR_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.PR_LEN_Program_Length
                        WHERE
                            v.PR_LEN_Program_Length =
                                dbo.prePR_LEN_Program_Length (
                                    v.PR_ID,
                                    v.PR_LEN_Positor,
                                    v.PR_LEN_ChangedAt,
                                    v.PR_LEN_PositedAt,
                                    v.PR_LEN_Assertion
                                )
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            v.PR_LEN_Program_Length
                        WHERE
                            v.PR_LEN_Program_Length =
                                dbo.folPR_LEN_Program_Length (
                                    v.PR_ID,
                                    v.PR_LEN_Positor,
                                    v.PR_LEN_ChangedAt,
                                    v.PR_LEN_PositedAt,
                                    v.PR_LEN_Assertion
                                )
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @PR_LEN_Program_Length v
        LEFT JOIN
            [dbo].[PR_LEN_Program_Length_Posit] p
        ON
            p.PR_ID = v.PR_ID
        AND
            p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
        WHERE
            v.PR_LEN_Version = @currentVersion;
        INSERT INTO [dbo].[PR_LEN_Program_Length_Posit] (
            PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        )
        SELECT
            PR_ID,
            PR_LEN_ChangedAt,
            PR_LEN_Program_Length
        FROM
            @PR_LEN_Program_Length
        WHERE
            PR_LEN_Version = @currentVersion
        AND
            PR_LEN_StatementType in ('N','F');
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
            PR_LEN_ID,
            PR_LEN_Positor,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            fol.PR_LEN_ID,
            v.PR_LEN_Positor,
            v.PR_LEN_PositedAt,
            0
        FROM
            @PR_LEN_Program_Length v
        CROSS APPLY (
            SELECT TOP 1
                f.PR_LEN_ID,
                f.PR_LEN_Program_Length
            FROM
                [dbo].[fPR_LEN_Program_Length](
                    v.PR_LEN_Positor,
                    v.PR_LEN_ChangedAt,
                    v.PR_LEN_PositedAt
                ) f
            WHERE
                f.PR_ID = v.PR_ID
            AND
                f.PR_LEN_ChangedAt > v.PR_LEN_ChangedAt
            AND
                f.PR_LEN_Assertion = v.PR_LEN_Assertion
            ORDER BY
                f.PR_LEN_ChangedAt ASC,
                f.PR_LEN_PositedAt DESC
        ) fol
        WHERE
            v.PR_LEN_Version = @currentVersion
        AND
            v.PR_LEN_StatementType = 'F'
        AND
            fol.PR_LEN_Program_Length = v.PR_LEN_Program_Length;
        INSERT INTO [dbo].[PR_LEN_Program_Length_Annex] (
            PR_LEN_ID,
            PR_LEN_Positor,
            PR_LEN_PositedAt,
            PR_LEN_Reliability
        )
        SELECT
            p.PR_LEN_ID,
            v.PR_LEN_Positor,
            v.PR_LEN_PositedAt,
            v.PR_LEN_Reliability
        FROM
            @PR_LEN_Program_Length v
        JOIN
            [dbo].[PR_LEN_Program_Length_Posit] p
        ON
            p.PR_ID = v.PR_ID
        AND
            p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
        AND
            p.PR_LEN_Program_Length = v.PR_LEN_Program_Length
        WHERE
            v.PR_LEN_Version = @currentVersion
        AND
            PR_LEN_StatementType in ('S','N','D','F');
    END
END
GO
