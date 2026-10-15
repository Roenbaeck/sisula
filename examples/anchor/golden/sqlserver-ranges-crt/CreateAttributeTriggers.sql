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
IF Object_ID('attributes.it_EV_DAT_Event_Date', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_DAT_Event_Date];
GO
CREATE TRIGGER [attributes].[it_EV_DAT_Event_Date] ON [attributes].[EV_DAT_Event_Date]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_DAT_Event_Date TABLE (
        EV_DAT_EV_ID numeric(12,0) not null,
        Metadata_EV_DAT bigint not null,
        EV_DAT_Who smallint not null,
        EV_DAT_PositedAt datetime2(3) not null,
        EV_DAT_Confidence decimal(7,3) not null,
        EV_DAT_Stance char(1) not null,
        EV_DAT_Event_Date datetime2 not null,
        EV_DAT_Version bigint not null,
        EV_DAT_StatementType char(1) not null,
        primary key(
            EV_DAT_Version,
            EV_DAT_Who,
            EV_DAT_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_DAT_EV_ID,
            i.EV_DAT_Who,
            i.EV_DAT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_DAT_Event_Date_Fact] p
            JOIN
                [attributes].[EV_DAT_Event_Date_Meta] a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            WHERE
                p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
            AND
                p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
            AND
                a.EV_DAT_Who = i.EV_DAT_Who
            AND
                a.EV_DAT_PositedAt = i.EV_DAT_PositedAt
            AND
                a.EV_DAT_Confidence <> i.EV_DAT_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_DAT_Event_Date for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_DAT_Event_Date
    SELECT
        i.EV_DAT_EV_ID,
        i.Metadata_EV_DAT,
        i.EV_DAT_Who,
        i.EV_DAT_PositedAt,
        i.EV_DAT_Confidence,
        case
            when i.EV_DAT_Confidence > 0.25 then '+'
            when i.EV_DAT_Confidence = 0.25 then '?'
            when i.EV_DAT_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_DAT_Event_Date,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_DAT_Who,
                i.EV_DAT_EV_ID
            ORDER BY
                i.EV_DAT_PositedAt ASC,
                i.EV_DAT_Confidence ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[EV_DAT_Event_Date_Fact] p
        JOIN
            [attributes].[EV_DAT_Event_Date_Meta] a
        ON
            a.EV_DAT_ID = p.EV_DAT_ID
        WHERE
            p.EV_DAT_EV_ID = i.EV_DAT_EV_ID
        AND
            p.EV_DAT_Event_Date = i.EV_DAT_Event_Date
        AND
            a.EV_DAT_Who = i.EV_DAT_Who
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
                            [nexuses].[tEV_Event](v.EV_DAT_Who, DEFAULT, v.EV_DAT_PositedAt, v.EV_DAT_Stance) t
                        WHERE
                            t.EV_DAT_EV_ID = v.EV_DAT_EV_ID
                        AND
                            t.EV_DAT_Confidence = v.EV_DAT_Confidence
                        AND
                            t.EV_DAT_Event_Date = v.EV_DAT_Event_Date
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_DAT_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_DAT_Event_Date v
        LEFT JOIN
            [attributes].[EV_DAT_Event_Date_Fact] p
        ON
            p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
        AND
            p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
        WHERE
            v.EV_DAT_Version = @currentVersion;
        INSERT INTO [attributes].[EV_DAT_Event_Date_Fact] (
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        )
        SELECT
            v.EV_DAT_EV_ID,
            v.EV_DAT_Event_Date
        FROM
            @EV_DAT_Event_Date v
        WHERE
            v.EV_DAT_Version = @currentVersion
        AND
            v.EV_DAT_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_DAT_Event_Date w
            WHERE
                w.EV_DAT_Version = v.EV_DAT_Version
            AND
                w.EV_DAT_Who < v.EV_DAT_Who
            AND
                w.EV_DAT_EV_ID = v.EV_DAT_EV_ID
            AND
                w.EV_DAT_Event_Date = v.EV_DAT_Event_Date
            AND
                w.EV_DAT_StatementType in ('N')
        );
        INSERT INTO [attributes].[EV_DAT_Event_Date_Meta] (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Who,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
        )
        SELECT
            v.Metadata_EV_DAT,
            p.EV_DAT_ID,
            v.EV_DAT_Who,
            v.EV_DAT_PositedAt,
            v.EV_DAT_Confidence
        FROM
            @EV_DAT_Event_Date v
        JOIN
            [attributes].[EV_DAT_Event_Date_Fact] p
        ON
            p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
        AND
            p.EV_DAT_Event_Date = v.EV_DAT_Event_Date
        WHERE
            v.EV_DAT_Version = @currentVersion
        AND
            EV_DAT_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[EV_DAT_Event_Date_Meta] (
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_Who,
            EV_DAT_PositedAt,
            EV_DAT_Confidence
        )
        SELECT
            v.Metadata_EV_DAT,
            e.EV_DAT_ID,
            v.EV_DAT_Who,
            v.EV_DAT_PositedAt,
            0.25
        FROM
            @EV_DAT_Event_Date v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_DAT_ID,
                p.EV_DAT_Event_Date
            FROM
                [attributes].[EV_DAT_Event_Date_Fact] p
            JOIN
                [attributes].[EV_DAT_Event_Date_Meta] a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            AND
                a.EV_DAT_Who = v.EV_DAT_Who
            AND
                a.EV_DAT_PositedAt = (
                    SELECT
                        max(s.EV_DAT_PositedAt)
                    FROM
                        [attributes].[EV_DAT_Event_Date_Meta] s
                    WHERE
                        s.EV_DAT_ID = p.EV_DAT_ID
                    AND
                        s.EV_DAT_Who = v.EV_DAT_Who
                    AND
                        s.EV_DAT_PositedAt < v.EV_DAT_PositedAt
                )
            WHERE
                p.EV_DAT_EV_ID = v.EV_DAT_EV_ID
            AND
                a.EV_DAT_Confidence > 0.25
            ORDER BY
                a.EV_DAT_PositedAt DESC,
                a.EV_DAT_Confidence DESC
        ) e
        WHERE
            v.EV_DAT_Version = @currentVersion
        AND
            v.EV_DAT_StatementType in ('S','N','D')
        AND
            v.EV_DAT_Confidence > 0.25
        AND
            e.EV_DAT_Event_Date <> v.EV_DAT_Event_Date
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_DAT_Event_Date_Meta] x
            WHERE
                x.EV_DAT_ID = e.EV_DAT_ID
            AND
                x.EV_DAT_Who = v.EV_DAT_Who
            AND
                x.EV_DAT_PositedAt = v.EV_DAT_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Event_Audience instead of INSERT trigger on EV_AUD_Event_Audience
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_AUD_Event_Audience', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_AUD_Event_Audience];
GO
CREATE TRIGGER [attributes].[it_EV_AUD_Event_Audience] ON [attributes].[EV_AUD_Event_Audience]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_AUD_Event_Audience TABLE (
        EV_AUD_EV_ID numeric(12,0) not null,
        Metadata_EV_AUD bigint not null,
        EV_AUD_Who smallint not null,
        EV_AUD_PositedAt datetime2(3) not null,
        EV_AUD_Confidence decimal(7,3) not null,
        EV_AUD_Stance char(1) not null,
        EV_AUD_Event_Audience int not null,
        EV_AUD_Version bigint not null,
        EV_AUD_StatementType char(1) not null,
        primary key(
            EV_AUD_Version,
            EV_AUD_Who,
            EV_AUD_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_AUD_EV_ID,
            i.EV_AUD_Who,
            i.EV_AUD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_AUD_Event_Audience_Fact] p
            JOIN
                [attributes].[EV_AUD_Event_Audience_Meta] a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            WHERE
                p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
            AND
                p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
            AND
                a.EV_AUD_Who = i.EV_AUD_Who
            AND
                a.EV_AUD_PositedAt = i.EV_AUD_PositedAt
            AND
                a.EV_AUD_Confidence <> i.EV_AUD_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_AUD_Event_Audience for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_AUD_Event_Audience
    SELECT
        i.EV_AUD_EV_ID,
        i.Metadata_EV_AUD,
        i.EV_AUD_Who,
        i.EV_AUD_PositedAt,
        i.EV_AUD_Confidence,
        case
            when i.EV_AUD_Confidence > 0.25 then '+'
            when i.EV_AUD_Confidence = 0.25 then '?'
            when i.EV_AUD_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_AUD_Event_Audience,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_AUD_Who,
                i.EV_AUD_EV_ID
            ORDER BY
                i.EV_AUD_PositedAt ASC,
                i.EV_AUD_Confidence ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[EV_AUD_Event_Audience_Fact] p
        JOIN
            [attributes].[EV_AUD_Event_Audience_Meta] a
        ON
            a.EV_AUD_ID = p.EV_AUD_ID
        WHERE
            p.EV_AUD_EV_ID = i.EV_AUD_EV_ID
        AND
            p.EV_AUD_Event_Audience = i.EV_AUD_Event_Audience
        AND
            a.EV_AUD_Who = i.EV_AUD_Who
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
                            [nexuses].[tEV_Event](v.EV_AUD_Who, DEFAULT, v.EV_AUD_PositedAt, v.EV_AUD_Stance) t
                        WHERE
                            t.EV_AUD_EV_ID = v.EV_AUD_EV_ID
                        AND
                            t.EV_AUD_Confidence = v.EV_AUD_Confidence
                        AND
                            t.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_AUD_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_AUD_Event_Audience v
        LEFT JOIN
            [attributes].[EV_AUD_Event_Audience_Fact] p
        ON
            p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
        AND
            p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
        WHERE
            v.EV_AUD_Version = @currentVersion;
        INSERT INTO [attributes].[EV_AUD_Event_Audience_Fact] (
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        )
        SELECT
            v.EV_AUD_EV_ID,
            v.EV_AUD_Event_Audience
        FROM
            @EV_AUD_Event_Audience v
        WHERE
            v.EV_AUD_Version = @currentVersion
        AND
            v.EV_AUD_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_AUD_Event_Audience w
            WHERE
                w.EV_AUD_Version = v.EV_AUD_Version
            AND
                w.EV_AUD_Who < v.EV_AUD_Who
            AND
                w.EV_AUD_EV_ID = v.EV_AUD_EV_ID
            AND
                w.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
            AND
                w.EV_AUD_StatementType in ('N')
        );
        INSERT INTO [attributes].[EV_AUD_Event_Audience_Meta] (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Who,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
        )
        SELECT
            v.Metadata_EV_AUD,
            p.EV_AUD_ID,
            v.EV_AUD_Who,
            v.EV_AUD_PositedAt,
            v.EV_AUD_Confidence
        FROM
            @EV_AUD_Event_Audience v
        JOIN
            [attributes].[EV_AUD_Event_Audience_Fact] p
        ON
            p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
        AND
            p.EV_AUD_Event_Audience = v.EV_AUD_Event_Audience
        WHERE
            v.EV_AUD_Version = @currentVersion
        AND
            EV_AUD_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[EV_AUD_Event_Audience_Meta] (
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_Who,
            EV_AUD_PositedAt,
            EV_AUD_Confidence
        )
        SELECT
            v.Metadata_EV_AUD,
            e.EV_AUD_ID,
            v.EV_AUD_Who,
            v.EV_AUD_PositedAt,
            0.25
        FROM
            @EV_AUD_Event_Audience v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_AUD_ID,
                p.EV_AUD_Event_Audience
            FROM
                [attributes].[EV_AUD_Event_Audience_Fact] p
            JOIN
                [attributes].[EV_AUD_Event_Audience_Meta] a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            AND
                a.EV_AUD_Who = v.EV_AUD_Who
            AND
                a.EV_AUD_PositedAt = (
                    SELECT
                        max(s.EV_AUD_PositedAt)
                    FROM
                        [attributes].[EV_AUD_Event_Audience_Meta] s
                    WHERE
                        s.EV_AUD_ID = p.EV_AUD_ID
                    AND
                        s.EV_AUD_Who = v.EV_AUD_Who
                    AND
                        s.EV_AUD_PositedAt < v.EV_AUD_PositedAt
                )
            WHERE
                p.EV_AUD_EV_ID = v.EV_AUD_EV_ID
            AND
                a.EV_AUD_Confidence > 0.25
            ORDER BY
                a.EV_AUD_PositedAt DESC,
                a.EV_AUD_Confidence DESC
        ) e
        WHERE
            v.EV_AUD_Version = @currentVersion
        AND
            v.EV_AUD_StatementType in ('S','N','D')
        AND
            v.EV_AUD_Confidence > 0.25
        AND
            e.EV_AUD_Event_Audience <> v.EV_AUD_Event_Audience
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_AUD_Event_Audience_Meta] x
            WHERE
                x.EV_AUD_ID = e.EV_AUD_ID
            AND
                x.EV_AUD_Who = v.EV_AUD_Who
            AND
                x.EV_AUD_PositedAt = v.EV_AUD_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Event_Revenue instead of INSERT trigger on EV_REV_Event_Revenue
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_REV_Event_Revenue', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_REV_Event_Revenue];
GO
CREATE TRIGGER [attributes].[it_EV_REV_Event_Revenue] ON [attributes].[EV_REV_Event_Revenue]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_REV_Event_Revenue TABLE (
        EV_REV_EV_ID numeric(12,0) not null,
        Metadata_EV_REV bigint not null,
        EV_REV_Who smallint not null,
        EV_REV_PositedAt datetime2(3) not null,
        EV_REV_Confidence decimal(7,3) not null,
        EV_REV_Stance char(1) not null,
        EV_REV_Event_Revenue decimal(19,4) not null,
        EV_REV_Version bigint not null,
        EV_REV_StatementType char(1) not null,
        primary key(
            EV_REV_Version,
            EV_REV_Who,
            EV_REV_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_REV_EV_ID,
            i.EV_REV_Who,
            i.EV_REV_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_REV_Event_Revenue_Fact] p
            JOIN
                [attributes].[EV_REV_Event_Revenue_Meta] a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            WHERE
                p.EV_REV_EV_ID = i.EV_REV_EV_ID
            AND
                p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
            AND
                a.EV_REV_Who = i.EV_REV_Who
            AND
                a.EV_REV_PositedAt = i.EV_REV_PositedAt
            AND
                a.EV_REV_Confidence <> i.EV_REV_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_REV_Event_Revenue for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_REV_Event_Revenue
    SELECT
        i.EV_REV_EV_ID,
        i.Metadata_EV_REV,
        i.EV_REV_Who,
        i.EV_REV_PositedAt,
        i.EV_REV_Confidence,
        case
            when i.EV_REV_Confidence > 0.25 then '+'
            when i.EV_REV_Confidence = 0.25 then '?'
            when i.EV_REV_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_REV_Event_Revenue,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_REV_Who,
                i.EV_REV_EV_ID
            ORDER BY
                i.EV_REV_PositedAt ASC,
                i.EV_REV_Confidence ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[EV_REV_Event_Revenue_Fact] p
        JOIN
            [attributes].[EV_REV_Event_Revenue_Meta] a
        ON
            a.EV_REV_ID = p.EV_REV_ID
        WHERE
            p.EV_REV_EV_ID = i.EV_REV_EV_ID
        AND
            p.EV_REV_Event_Revenue = i.EV_REV_Event_Revenue
        AND
            a.EV_REV_Who = i.EV_REV_Who
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
                            [nexuses].[tEV_Event](v.EV_REV_Who, DEFAULT, v.EV_REV_PositedAt, v.EV_REV_Stance) t
                        WHERE
                            t.EV_REV_EV_ID = v.EV_REV_EV_ID
                        AND
                            t.EV_REV_Confidence = v.EV_REV_Confidence
                        AND
                            t.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_REV_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_REV_Event_Revenue v
        LEFT JOIN
            [attributes].[EV_REV_Event_Revenue_Fact] p
        ON
            p.EV_REV_EV_ID = v.EV_REV_EV_ID
        AND
            p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
        WHERE
            v.EV_REV_Version = @currentVersion;
        INSERT INTO [attributes].[EV_REV_Event_Revenue_Fact] (
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        )
        SELECT
            v.EV_REV_EV_ID,
            v.EV_REV_Event_Revenue
        FROM
            @EV_REV_Event_Revenue v
        WHERE
            v.EV_REV_Version = @currentVersion
        AND
            v.EV_REV_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_REV_Event_Revenue w
            WHERE
                w.EV_REV_Version = v.EV_REV_Version
            AND
                w.EV_REV_Who < v.EV_REV_Who
            AND
                w.EV_REV_EV_ID = v.EV_REV_EV_ID
            AND
                w.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
            AND
                w.EV_REV_StatementType in ('N')
        );
        INSERT INTO [attributes].[EV_REV_Event_Revenue_Meta] (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Who,
            EV_REV_PositedAt,
            EV_REV_Confidence
        )
        SELECT
            v.Metadata_EV_REV,
            p.EV_REV_ID,
            v.EV_REV_Who,
            v.EV_REV_PositedAt,
            v.EV_REV_Confidence
        FROM
            @EV_REV_Event_Revenue v
        JOIN
            [attributes].[EV_REV_Event_Revenue_Fact] p
        ON
            p.EV_REV_EV_ID = v.EV_REV_EV_ID
        AND
            p.EV_REV_Event_Revenue = v.EV_REV_Event_Revenue
        WHERE
            v.EV_REV_Version = @currentVersion
        AND
            EV_REV_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[EV_REV_Event_Revenue_Meta] (
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_Who,
            EV_REV_PositedAt,
            EV_REV_Confidence
        )
        SELECT
            v.Metadata_EV_REV,
            e.EV_REV_ID,
            v.EV_REV_Who,
            v.EV_REV_PositedAt,
            0.25
        FROM
            @EV_REV_Event_Revenue v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_REV_ID,
                p.EV_REV_Event_Revenue
            FROM
                [attributes].[EV_REV_Event_Revenue_Fact] p
            JOIN
                [attributes].[EV_REV_Event_Revenue_Meta] a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            AND
                a.EV_REV_Who = v.EV_REV_Who
            AND
                a.EV_REV_PositedAt = (
                    SELECT
                        max(s.EV_REV_PositedAt)
                    FROM
                        [attributes].[EV_REV_Event_Revenue_Meta] s
                    WHERE
                        s.EV_REV_ID = p.EV_REV_ID
                    AND
                        s.EV_REV_Who = v.EV_REV_Who
                    AND
                        s.EV_REV_PositedAt < v.EV_REV_PositedAt
                )
            WHERE
                p.EV_REV_EV_ID = v.EV_REV_EV_ID
            AND
                a.EV_REV_Confidence > 0.25
            ORDER BY
                a.EV_REV_PositedAt DESC,
                a.EV_REV_Confidence DESC
        ) e
        WHERE
            v.EV_REV_Version = @currentVersion
        AND
            v.EV_REV_StatementType in ('S','N','D')
        AND
            v.EV_REV_Confidence > 0.25
        AND
            e.EV_REV_Event_Revenue <> v.EV_REV_Event_Revenue
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_REV_Event_Revenue_Meta] x
            WHERE
                x.EV_REV_ID = e.EV_REV_ID
            AND
                x.EV_REV_Who = v.EV_REV_Who
            AND
                x.EV_REV_PositedAt = v.EV_REV_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Event_Status instead of INSERT trigger on EV_STA_Event_Status
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_STA_Event_Status', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_STA_Event_Status];
GO
CREATE TRIGGER [attributes].[it_EV_STA_Event_Status] ON [attributes].[EV_STA_Event_Status]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_STA_Event_Status TABLE (
        EV_STA_EV_ID numeric(12,0) not null,
        Metadata_EV_STA bigint not null,
        EV_STA_ChangedAt datetime2 not null,
        EV_STA_Who smallint not null,
        EV_STA_PositedAt datetime2(3) not null,
        EV_STA_Confidence decimal(7,3) not null,
        EV_STA_Stance char(1) not null,
        EV_STA_Event_Status nvarchar(20) not null,
        EV_STA_Version bigint not null,
        EV_STA_StatementType char(1) not null,
        primary key(
            EV_STA_Version,
            EV_STA_Who,
            EV_STA_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_STA_EV_ID,
            i.EV_STA_ChangedAt,
            i.EV_STA_Who,
            i.EV_STA_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_STA_Event_Status_Fact] p
            JOIN
                [attributes].[EV_STA_Event_Status_Meta] a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            WHERE
                p.EV_STA_EV_ID = i.EV_STA_EV_ID
            AND
                p.EV_STA_ChangedAt = i.EV_STA_ChangedAt
            AND
                p.EV_STA_Event_Status = i.EV_STA_Event_Status
            AND
                a.EV_STA_Who = i.EV_STA_Who
            AND
                a.EV_STA_PositedAt = i.EV_STA_PositedAt
            AND
                a.EV_STA_Confidence <> i.EV_STA_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_STA_Event_Status for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_STA_Event_Status
    SELECT
        i.EV_STA_EV_ID,
        i.Metadata_EV_STA,
        i.EV_STA_ChangedAt,
        i.EV_STA_Who,
        i.EV_STA_PositedAt,
        i.EV_STA_Confidence,
        case
            when i.EV_STA_Confidence > 0.25 then '+'
            when i.EV_STA_Confidence = 0.25 then '?'
            when i.EV_STA_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_STA_Event_Status,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_STA_Who,
                i.EV_STA_EV_ID
            ORDER BY
                i.EV_STA_ChangedAt ASC,
                i.EV_STA_PositedAt ASC,
                i.EV_STA_Confidence ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[EV_STA_Event_Status_Fact] p
        JOIN
            [attributes].[EV_STA_Event_Status_Meta] a
        ON
            a.EV_STA_ID = p.EV_STA_ID
        WHERE
            p.EV_STA_EV_ID = i.EV_STA_EV_ID
        AND
            p.EV_STA_ChangedAt = i.EV_STA_ChangedAt
        AND
            p.EV_STA_Event_Status = i.EV_STA_Event_Status
        AND
            a.EV_STA_Who = i.EV_STA_Who
        AND
            a.EV_STA_PositedAt = i.EV_STA_PositedAt
    );
    SELECT
        @maxVersion = max(EV_STA_Version),
        @currentVersion = 0
    FROM
        @EV_STA_Event_Status;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_STA_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_STA_ID
                        FROM
                            [nexuses].[tEV_Event](v.EV_STA_Who, v.EV_STA_ChangedAt, v.EV_STA_PositedAt, v.EV_STA_Stance) t
                        WHERE
                            t.EV_STA_EV_ID = v.EV_STA_EV_ID
                        AND
                            t.EV_STA_ChangedAt = v.EV_STA_ChangedAt
                        AND
                            t.EV_STA_Confidence = v.EV_STA_Confidence
                        AND
                            t.EV_STA_Event_Status = v.EV_STA_Event_Status
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_STA_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.EV_STA_Event_Status
                        WHERE
                            v.EV_STA_Event_Status =
                                attributes.preEV_STA_Event_Status (
                                    v.EV_STA_EV_ID,
                                    v.EV_STA_Who,
                                    v.EV_STA_ChangedAt,
                                    v.EV_STA_PositedAt,
                                    v.EV_STA_Stance
                                )
                    ) OR EXISTS (
                        SELECT
                            v.EV_STA_Event_Status
                        WHERE
                            v.EV_STA_Event_Status =
                                attributes.folEV_STA_Event_Status (
                                    v.EV_STA_EV_ID,
                                    v.EV_STA_Who,
                                    v.EV_STA_ChangedAt,
                                    v.EV_STA_PositedAt,
                                    v.EV_STA_Stance
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_STA_Event_Status v
        LEFT JOIN
            [attributes].[EV_STA_Event_Status_Fact] p
        ON
            p.EV_STA_EV_ID = v.EV_STA_EV_ID
        AND
            p.EV_STA_ChangedAt = v.EV_STA_ChangedAt
        AND
            p.EV_STA_Event_Status = v.EV_STA_Event_Status
        WHERE
            v.EV_STA_Version = @currentVersion;
        INSERT INTO [attributes].[EV_STA_Event_Status_Fact] (
            EV_STA_EV_ID,
            EV_STA_ChangedAt,
            EV_STA_Event_Status
        )
        SELECT
            v.EV_STA_EV_ID,
            v.EV_STA_ChangedAt,
            v.EV_STA_Event_Status
        FROM
            @EV_STA_Event_Status v
        WHERE
            v.EV_STA_Version = @currentVersion
        AND
            v.EV_STA_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_STA_Event_Status w
            WHERE
                w.EV_STA_Version = v.EV_STA_Version
            AND
                w.EV_STA_Who < v.EV_STA_Who
            AND
                w.EV_STA_EV_ID = v.EV_STA_EV_ID
            AND
                w.EV_STA_ChangedAt = v.EV_STA_ChangedAt
            AND
                w.EV_STA_Event_Status = v.EV_STA_Event_Status
            AND
                w.EV_STA_StatementType in ('N','R')
        );
        INSERT INTO [attributes].[EV_STA_Event_Status_Meta] (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Who,
            EV_STA_PositedAt,
            EV_STA_Confidence
        )
        SELECT
            v.Metadata_EV_STA,
            p.EV_STA_ID,
            v.EV_STA_Who,
            v.EV_STA_PositedAt,
            v.EV_STA_Confidence
        FROM
            @EV_STA_Event_Status v
        JOIN
            [attributes].[EV_STA_Event_Status_Fact] p
        ON
            p.EV_STA_EV_ID = v.EV_STA_EV_ID
        AND
            p.EV_STA_ChangedAt = v.EV_STA_ChangedAt
        AND
            p.EV_STA_Event_Status = v.EV_STA_Event_Status
        WHERE
            v.EV_STA_Version = @currentVersion
        AND
            EV_STA_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [attributes].[EV_STA_Event_Status_Meta] (
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_Who,
            EV_STA_PositedAt,
            EV_STA_Confidence
        )
        SELECT
            v.Metadata_EV_STA,
            e.EV_STA_ID,
            v.EV_STA_Who,
            v.EV_STA_PositedAt,
            0.25
        FROM
            @EV_STA_Event_Status v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_STA_ID,
                p.EV_STA_Event_Status
            FROM
                [attributes].[EV_STA_Event_Status_Fact] p
            JOIN
                [attributes].[EV_STA_Event_Status_Meta] a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            AND
                a.EV_STA_Who = v.EV_STA_Who
            AND
                a.EV_STA_PositedAt = (
                    SELECT
                        max(s.EV_STA_PositedAt)
                    FROM
                        [attributes].[EV_STA_Event_Status_Meta] s
                    WHERE
                        s.EV_STA_ID = p.EV_STA_ID
                    AND
                        s.EV_STA_Who = v.EV_STA_Who
                    AND
                        s.EV_STA_PositedAt < v.EV_STA_PositedAt
                )
            WHERE
                p.EV_STA_EV_ID = v.EV_STA_EV_ID
            AND
                p.EV_STA_ChangedAt = v.EV_STA_ChangedAt
            AND
                a.EV_STA_Confidence > 0.25
            ORDER BY
                a.EV_STA_PositedAt DESC,
                a.EV_STA_Confidence DESC
        ) e
        WHERE
            v.EV_STA_Version = @currentVersion
        AND
            v.EV_STA_StatementType in ('S','N','D','R')
        AND
            v.EV_STA_Confidence > 0.25
        AND
            e.EV_STA_Event_Status <> v.EV_STA_Event_Status
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_STA_Event_Status_Meta] x
            WHERE
                x.EV_STA_ID = e.EV_STA_ID
            AND
                x.EV_STA_Who = v.EV_STA_Who
            AND
                x.EV_STA_PositedAt = v.EV_STA_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Event_Utilization instead of INSERT trigger on EV_UTL_Event_Utilization
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_UTL_Event_Utilization', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_UTL_Event_Utilization];
GO
CREATE TRIGGER [attributes].[it_EV_UTL_Event_Utilization] ON [attributes].[EV_UTL_Event_Utilization]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_UTL_Event_Utilization TABLE (
        EV_UTL_EV_ID numeric(12,0) not null,
        Metadata_EV_UTL bigint not null,
        EV_UTL_Who smallint not null,
        EV_UTL_PositedAt datetime2(3) not null,
        EV_UTL_Confidence decimal(7,3) not null,
        EV_UTL_Stance char(1) not null,
        EV_UTL_UTL_ID tinyint not null,
        EV_UTL_Version bigint not null,
        EV_UTL_StatementType char(1) not null,
        primary key(
            EV_UTL_Version,
            EV_UTL_Who,
            EV_UTL_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_UTL_EV_ID,
            i.EV_UTL_Who,
            i.EV_UTL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_UTL_Event_Utilization_Fact] p
            JOIN
                [attributes].[EV_UTL_Event_Utilization_Meta] a
            ON
                a.EV_UTL_ID = p.EV_UTL_ID
            WHERE
                p.EV_UTL_EV_ID = i.EV_UTL_EV_ID
            AND
                p.EV_UTL_UTL_ID = i.EV_UTL_UTL_ID
            AND
                a.EV_UTL_Who = i.EV_UTL_Who
            AND
                a.EV_UTL_PositedAt = i.EV_UTL_PositedAt
            AND
                a.EV_UTL_Confidence <> i.EV_UTL_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_UTL_Event_Utilization for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_UTL_Event_Utilization
    SELECT
        i.EV_UTL_EV_ID,
        i.Metadata_EV_UTL,
        i.EV_UTL_Who,
        i.EV_UTL_PositedAt,
        i.EV_UTL_Confidence,
        case
            when i.EV_UTL_Confidence > 0.25 then '+'
            when i.EV_UTL_Confidence = 0.25 then '?'
            when i.EV_UTL_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_UTL_UTL_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_UTL_Who,
                i.EV_UTL_EV_ID
            ORDER BY
                i.EV_UTL_PositedAt ASC,
                i.EV_UTL_Confidence ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[EV_UTL_Event_Utilization_Fact] p
        JOIN
            [attributes].[EV_UTL_Event_Utilization_Meta] a
        ON
            a.EV_UTL_ID = p.EV_UTL_ID
        WHERE
            p.EV_UTL_EV_ID = i.EV_UTL_EV_ID
        AND
            p.EV_UTL_UTL_ID = i.EV_UTL_UTL_ID
        AND
            a.EV_UTL_Who = i.EV_UTL_Who
        AND
            a.EV_UTL_PositedAt = i.EV_UTL_PositedAt
    );
    SELECT
        @maxVersion = max(EV_UTL_Version),
        @currentVersion = 0
    FROM
        @EV_UTL_Event_Utilization;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_UTL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_UTL_ID
                        FROM
                            [nexuses].[tEV_Event](v.EV_UTL_Who, DEFAULT, v.EV_UTL_PositedAt, v.EV_UTL_Stance) t
                        WHERE
                            t.EV_UTL_EV_ID = v.EV_UTL_EV_ID
                        AND
                            t.EV_UTL_Confidence = v.EV_UTL_Confidence
                        AND
                            t.EV_UTL_UTL_ID = v.EV_UTL_UTL_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_UTL_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_UTL_Event_Utilization v
        LEFT JOIN
            [attributes].[EV_UTL_Event_Utilization_Fact] p
        ON
            p.EV_UTL_EV_ID = v.EV_UTL_EV_ID
        AND
            p.EV_UTL_UTL_ID = v.EV_UTL_UTL_ID
        WHERE
            v.EV_UTL_Version = @currentVersion;
        INSERT INTO [attributes].[EV_UTL_Event_Utilization_Fact] (
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        )
        SELECT
            v.EV_UTL_EV_ID,
            v.EV_UTL_UTL_ID
        FROM
            @EV_UTL_Event_Utilization v
        WHERE
            v.EV_UTL_Version = @currentVersion
        AND
            v.EV_UTL_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_UTL_Event_Utilization w
            WHERE
                w.EV_UTL_Version = v.EV_UTL_Version
            AND
                w.EV_UTL_Who < v.EV_UTL_Who
            AND
                w.EV_UTL_EV_ID = v.EV_UTL_EV_ID
            AND
                w.EV_UTL_UTL_ID = v.EV_UTL_UTL_ID
            AND
                w.EV_UTL_StatementType in ('N')
        );
        INSERT INTO [attributes].[EV_UTL_Event_Utilization_Meta] (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Who,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
        )
        SELECT
            v.Metadata_EV_UTL,
            p.EV_UTL_ID,
            v.EV_UTL_Who,
            v.EV_UTL_PositedAt,
            v.EV_UTL_Confidence
        FROM
            @EV_UTL_Event_Utilization v
        JOIN
            [attributes].[EV_UTL_Event_Utilization_Fact] p
        ON
            p.EV_UTL_EV_ID = v.EV_UTL_EV_ID
        AND
            p.EV_UTL_UTL_ID = v.EV_UTL_UTL_ID
        WHERE
            v.EV_UTL_Version = @currentVersion
        AND
            EV_UTL_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[EV_UTL_Event_Utilization_Meta] (
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_Who,
            EV_UTL_PositedAt,
            EV_UTL_Confidence
        )
        SELECT
            v.Metadata_EV_UTL,
            e.EV_UTL_ID,
            v.EV_UTL_Who,
            v.EV_UTL_PositedAt,
            0.25
        FROM
            @EV_UTL_Event_Utilization v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_UTL_ID,
                p.EV_UTL_UTL_ID
            FROM
                [attributes].[EV_UTL_Event_Utilization_Fact] p
            JOIN
                [attributes].[EV_UTL_Event_Utilization_Meta] a
            ON
                a.EV_UTL_ID = p.EV_UTL_ID
            AND
                a.EV_UTL_Who = v.EV_UTL_Who
            AND
                a.EV_UTL_PositedAt = (
                    SELECT
                        max(s.EV_UTL_PositedAt)
                    FROM
                        [attributes].[EV_UTL_Event_Utilization_Meta] s
                    WHERE
                        s.EV_UTL_ID = p.EV_UTL_ID
                    AND
                        s.EV_UTL_Who = v.EV_UTL_Who
                    AND
                        s.EV_UTL_PositedAt < v.EV_UTL_PositedAt
                )
            WHERE
                p.EV_UTL_EV_ID = v.EV_UTL_EV_ID
            AND
                a.EV_UTL_Confidence > 0.25
            ORDER BY
                a.EV_UTL_PositedAt DESC,
                a.EV_UTL_Confidence DESC
        ) e
        WHERE
            v.EV_UTL_Version = @currentVersion
        AND
            v.EV_UTL_StatementType in ('S','N','D')
        AND
            v.EV_UTL_Confidence > 0.25
        AND
            e.EV_UTL_UTL_ID <> v.EV_UTL_UTL_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_UTL_Event_Utilization_Meta] x
            WHERE
                x.EV_UTL_ID = e.EV_UTL_ID
            AND
                x.EV_UTL_Who = v.EV_UTL_Who
            AND
                x.EV_UTL_PositedAt = v.EV_UTL_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Event_Level instead of INSERT trigger on EV_LVL_Event_Level
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('attributes.it_EV_LVL_Event_Level', 'TR') IS NOT NULL
DROP TRIGGER [attributes].[it_EV_LVL_Event_Level];
GO
CREATE TRIGGER [attributes].[it_EV_LVL_Event_Level] ON [attributes].[EV_LVL_Event_Level]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_LVL_Event_Level TABLE (
        EV_LVL_EV_ID numeric(12,0) not null,
        Metadata_EV_LVL bigint not null,
        EV_LVL_ChangedAt date not null,
        EV_LVL_Who smallint not null,
        EV_LVL_PositedAt datetime2(3) not null,
        EV_LVL_Confidence decimal(7,3) not null,
        EV_LVL_Stance char(1) not null,
        EV_LVL_PLV_ID tinyint not null,
        EV_LVL_Version bigint not null,
        EV_LVL_StatementType char(1) not null,
        primary key(
            EV_LVL_Version,
            EV_LVL_Who,
            EV_LVL_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_LVL_EV_ID,
            i.EV_LVL_ChangedAt,
            i.EV_LVL_Who,
            i.EV_LVL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_LVL_Event_Level_Fact] p
            JOIN
                [attributes].[EV_LVL_Event_Level_Meta] a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            WHERE
                p.EV_LVL_EV_ID = i.EV_LVL_EV_ID
            AND
                p.EV_LVL_ChangedAt = i.EV_LVL_ChangedAt
            AND
                p.EV_LVL_PLV_ID = i.EV_LVL_PLV_ID
            AND
                a.EV_LVL_Who = i.EV_LVL_Who
            AND
                a.EV_LVL_PositedAt = i.EV_LVL_PositedAt
            AND
                a.EV_LVL_Confidence <> i.EV_LVL_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_LVL_Event_Level for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_LVL_Event_Level
    SELECT
        i.EV_LVL_EV_ID,
        i.Metadata_EV_LVL,
        i.EV_LVL_ChangedAt,
        i.EV_LVL_Who,
        i.EV_LVL_PositedAt,
        i.EV_LVL_Confidence,
        case
            when i.EV_LVL_Confidence > 0.25 then '+'
            when i.EV_LVL_Confidence = 0.25 then '?'
            when i.EV_LVL_Confidence < 0.25 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_LVL_PLV_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_LVL_Who,
                i.EV_LVL_EV_ID
            ORDER BY
                i.EV_LVL_ChangedAt ASC,
                i.EV_LVL_PositedAt ASC,
                i.EV_LVL_Confidence ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[EV_LVL_Event_Level_Fact] p
        JOIN
            [attributes].[EV_LVL_Event_Level_Meta] a
        ON
            a.EV_LVL_ID = p.EV_LVL_ID
        WHERE
            p.EV_LVL_EV_ID = i.EV_LVL_EV_ID
        AND
            p.EV_LVL_ChangedAt = i.EV_LVL_ChangedAt
        AND
            p.EV_LVL_PLV_ID = i.EV_LVL_PLV_ID
        AND
            a.EV_LVL_Who = i.EV_LVL_Who
        AND
            a.EV_LVL_PositedAt = i.EV_LVL_PositedAt
    );
    SELECT
        @maxVersion = max(EV_LVL_Version),
        @currentVersion = 0
    FROM
        @EV_LVL_Event_Level;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_LVL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_LVL_ID
                        FROM
                            [nexuses].[tEV_Event](v.EV_LVL_Who, v.EV_LVL_ChangedAt, v.EV_LVL_PositedAt, v.EV_LVL_Stance) t
                        WHERE
                            t.EV_LVL_EV_ID = v.EV_LVL_EV_ID
                        AND
                            t.EV_LVL_ChangedAt = v.EV_LVL_ChangedAt
                        AND
                            t.EV_LVL_Confidence = v.EV_LVL_Confidence
                        AND
                            t.EV_LVL_PLV_ID = v.EV_LVL_PLV_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_LVL_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.EV_LVL_PLV_ID
                        WHERE
                            v.EV_LVL_PLV_ID =
                                attributes.preEV_LVL_Event_Level (
                                    v.EV_LVL_EV_ID,
                                    v.EV_LVL_Who,
                                    v.EV_LVL_ChangedAt,
                                    v.EV_LVL_PositedAt,
                                    v.EV_LVL_Stance
                                )
                    ) OR EXISTS (
                        SELECT
                            v.EV_LVL_PLV_ID
                        WHERE
                            v.EV_LVL_PLV_ID =
                                attributes.folEV_LVL_Event_Level (
                                    v.EV_LVL_EV_ID,
                                    v.EV_LVL_Who,
                                    v.EV_LVL_ChangedAt,
                                    v.EV_LVL_PositedAt,
                                    v.EV_LVL_Stance
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_LVL_Event_Level v
        LEFT JOIN
            [attributes].[EV_LVL_Event_Level_Fact] p
        ON
            p.EV_LVL_EV_ID = v.EV_LVL_EV_ID
        AND
            p.EV_LVL_ChangedAt = v.EV_LVL_ChangedAt
        AND
            p.EV_LVL_PLV_ID = v.EV_LVL_PLV_ID
        WHERE
            v.EV_LVL_Version = @currentVersion;
        INSERT INTO [attributes].[EV_LVL_Event_Level_Fact] (
            EV_LVL_EV_ID,
            EV_LVL_ChangedAt,
            EV_LVL_PLV_ID
        )
        SELECT
            v.EV_LVL_EV_ID,
            v.EV_LVL_ChangedAt,
            v.EV_LVL_PLV_ID
        FROM
            @EV_LVL_Event_Level v
        WHERE
            v.EV_LVL_Version = @currentVersion
        AND
            v.EV_LVL_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_LVL_Event_Level w
            WHERE
                w.EV_LVL_Version = v.EV_LVL_Version
            AND
                w.EV_LVL_Who < v.EV_LVL_Who
            AND
                w.EV_LVL_EV_ID = v.EV_LVL_EV_ID
            AND
                w.EV_LVL_ChangedAt = v.EV_LVL_ChangedAt
            AND
                w.EV_LVL_PLV_ID = v.EV_LVL_PLV_ID
            AND
                w.EV_LVL_StatementType in ('N','R')
        );
        INSERT INTO [attributes].[EV_LVL_Event_Level_Meta] (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Who,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
        )
        SELECT
            v.Metadata_EV_LVL,
            p.EV_LVL_ID,
            v.EV_LVL_Who,
            v.EV_LVL_PositedAt,
            v.EV_LVL_Confidence
        FROM
            @EV_LVL_Event_Level v
        JOIN
            [attributes].[EV_LVL_Event_Level_Fact] p
        ON
            p.EV_LVL_EV_ID = v.EV_LVL_EV_ID
        AND
            p.EV_LVL_ChangedAt = v.EV_LVL_ChangedAt
        AND
            p.EV_LVL_PLV_ID = v.EV_LVL_PLV_ID
        WHERE
            v.EV_LVL_Version = @currentVersion
        AND
            EV_LVL_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [attributes].[EV_LVL_Event_Level_Meta] (
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_Who,
            EV_LVL_PositedAt,
            EV_LVL_Confidence
        )
        SELECT
            v.Metadata_EV_LVL,
            e.EV_LVL_ID,
            v.EV_LVL_Who,
            v.EV_LVL_PositedAt,
            0.25
        FROM
            @EV_LVL_Event_Level v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_LVL_ID,
                p.EV_LVL_PLV_ID
            FROM
                [attributes].[EV_LVL_Event_Level_Fact] p
            JOIN
                [attributes].[EV_LVL_Event_Level_Meta] a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            AND
                a.EV_LVL_Who = v.EV_LVL_Who
            AND
                a.EV_LVL_PositedAt = (
                    SELECT
                        max(s.EV_LVL_PositedAt)
                    FROM
                        [attributes].[EV_LVL_Event_Level_Meta] s
                    WHERE
                        s.EV_LVL_ID = p.EV_LVL_ID
                    AND
                        s.EV_LVL_Who = v.EV_LVL_Who
                    AND
                        s.EV_LVL_PositedAt < v.EV_LVL_PositedAt
                )
            WHERE
                p.EV_LVL_EV_ID = v.EV_LVL_EV_ID
            AND
                p.EV_LVL_ChangedAt = v.EV_LVL_ChangedAt
            AND
                a.EV_LVL_Confidence > 0.25
            ORDER BY
                a.EV_LVL_PositedAt DESC,
                a.EV_LVL_Confidence DESC
        ) e
        WHERE
            v.EV_LVL_Version = @currentVersion
        AND
            v.EV_LVL_StatementType in ('S','N','D','R')
        AND
            v.EV_LVL_Confidence > 0.25
        AND
            e.EV_LVL_PLV_ID <> v.EV_LVL_PLV_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[EV_LVL_Event_Level_Meta] x
            WHERE
                x.EV_LVL_ID = e.EV_LVL_ID
            AND
                x.EV_LVL_Who = v.EV_LVL_Who
            AND
                x.EV_LVL_PositedAt = v.EV_LVL_PositedAt
        );
    END
END
GO
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_NAM_ST_ID,
            i.ST_NAM_ChangedAt,
            i.ST_NAM_Who,
            i.ST_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_NAM_Stage_Name_Fact] p
            JOIN
                [attributes].[ST_NAM_Stage_Name_Meta] a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            WHERE
                p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
            AND
                p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
            AND
                p.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
            AND
                a.ST_NAM_Who = i.ST_NAM_Who
            AND
                a.ST_NAM_PositedAt = i.ST_NAM_PositedAt
            AND
                a.ST_NAM_Confidence <> i.ST_NAM_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_NAM_Stage_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[ST_NAM_Stage_Name_Fact] p
        JOIN
            [attributes].[ST_NAM_Stage_Name_Meta] a
        ON
            a.ST_NAM_ID = p.ST_NAM_ID
        WHERE
            p.ST_NAM_ST_ID = i.ST_NAM_ST_ID
        AND
            p.ST_NAM_ChangedAt = i.ST_NAM_ChangedAt
        AND
            p.ST_NAM_Stage_Name = i.ST_NAM_Stage_Name
        AND
            a.ST_NAM_Who = i.ST_NAM_Who
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
            v.ST_NAM_ST_ID,
            v.ST_NAM_ChangedAt,
            v.ST_NAM_Stage_Name
        FROM
            @ST_NAM_Stage_Name v
        WHERE
            v.ST_NAM_Version = @currentVersion
        AND
            v.ST_NAM_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @ST_NAM_Stage_Name w
            WHERE
                w.ST_NAM_Version = v.ST_NAM_Version
            AND
                w.ST_NAM_Who < v.ST_NAM_Who
            AND
                w.ST_NAM_ST_ID = v.ST_NAM_ST_ID
            AND
                w.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
            AND
                w.ST_NAM_Stage_Name = v.ST_NAM_Stage_Name
            AND
                w.ST_NAM_StatementType in ('N','R')
        );
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
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [attributes].[ST_NAM_Stage_Name_Meta] (
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_Who,
            ST_NAM_PositedAt,
            ST_NAM_Confidence
        )
        SELECT
            v.Metadata_ST_NAM,
            e.ST_NAM_ID,
            v.ST_NAM_Who,
            v.ST_NAM_PositedAt,
            0.25
        FROM
            @ST_NAM_Stage_Name v
        CROSS APPLY (
            SELECT TOP 1
                p.ST_NAM_ID,
                p.ST_NAM_Stage_Name
            FROM
                [attributes].[ST_NAM_Stage_Name_Fact] p
            JOIN
                [attributes].[ST_NAM_Stage_Name_Meta] a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Who = v.ST_NAM_Who
            AND
                a.ST_NAM_PositedAt = (
                    SELECT
                        max(s.ST_NAM_PositedAt)
                    FROM
                        [attributes].[ST_NAM_Stage_Name_Meta] s
                    WHERE
                        s.ST_NAM_ID = p.ST_NAM_ID
                    AND
                        s.ST_NAM_Who = v.ST_NAM_Who
                    AND
                        s.ST_NAM_PositedAt < v.ST_NAM_PositedAt
                )
            WHERE
                p.ST_NAM_ST_ID = v.ST_NAM_ST_ID
            AND
                p.ST_NAM_ChangedAt = v.ST_NAM_ChangedAt
            AND
                a.ST_NAM_Confidence > 0.25
            ORDER BY
                a.ST_NAM_PositedAt DESC,
                a.ST_NAM_Confidence DESC
        ) e
        WHERE
            v.ST_NAM_Version = @currentVersion
        AND
            v.ST_NAM_StatementType in ('S','N','D','R')
        AND
            v.ST_NAM_Confidence > 0.25
        AND
            e.ST_NAM_Stage_Name <> v.ST_NAM_Stage_Name
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_NAM_Stage_Name_Meta] x
            WHERE
                x.ST_NAM_ID = e.ST_NAM_ID
            AND
                x.ST_NAM_Who = v.ST_NAM_Who
            AND
                x.ST_NAM_PositedAt = v.ST_NAM_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_LOC_ST_ID,
            i.ST_LOC_Who,
            i.ST_LOC_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_LOC_Stage_Location_Fact] p
            JOIN
                [attributes].[ST_LOC_Stage_Location_Meta] a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            WHERE
                p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
            AND
                p.ST_LOC_Checksum = dw.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
            AND
                a.ST_LOC_Who = i.ST_LOC_Who
            AND
                a.ST_LOC_PositedAt = i.ST_LOC_PositedAt
            AND
                a.ST_LOC_Confidence <> i.ST_LOC_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_LOC_Stage_Location for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[ST_LOC_Stage_Location_Fact] p
        JOIN
            [attributes].[ST_LOC_Stage_Location_Meta] a
        ON
            a.ST_LOC_ID = p.ST_LOC_ID
        WHERE
            p.ST_LOC_ST_ID = i.ST_LOC_ST_ID
        AND
            p.ST_LOC_Checksum = dw.MD5(cast(i.ST_LOC_Stage_Location as varbinary(max)))
        AND
            a.ST_LOC_Who = i.ST_LOC_Who
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
            v.ST_LOC_ST_ID,
            v.ST_LOC_Stage_Location
        FROM
            @ST_LOC_Stage_Location v
        WHERE
            v.ST_LOC_Version = @currentVersion
        AND
            v.ST_LOC_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @ST_LOC_Stage_Location w
            WHERE
                w.ST_LOC_Version = v.ST_LOC_Version
            AND
                w.ST_LOC_Who < v.ST_LOC_Who
            AND
                w.ST_LOC_ST_ID = v.ST_LOC_ST_ID
            AND
                w.ST_LOC_Checksum = v.ST_LOC_Checksum
            AND
                w.ST_LOC_StatementType in ('N')
        );
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
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[ST_LOC_Stage_Location_Meta] (
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_Who,
            ST_LOC_PositedAt,
            ST_LOC_Confidence
        )
        SELECT
            v.Metadata_ST_LOC,
            e.ST_LOC_ID,
            v.ST_LOC_Who,
            v.ST_LOC_PositedAt,
            0.25
        FROM
            @ST_LOC_Stage_Location v
        CROSS APPLY (
            SELECT TOP 1
                p.ST_LOC_ID,
                p.ST_LOC_Checksum
            FROM
                [attributes].[ST_LOC_Stage_Location_Fact] p
            JOIN
                [attributes].[ST_LOC_Stage_Location_Meta] a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            AND
                a.ST_LOC_Who = v.ST_LOC_Who
            AND
                a.ST_LOC_PositedAt = (
                    SELECT
                        max(s.ST_LOC_PositedAt)
                    FROM
                        [attributes].[ST_LOC_Stage_Location_Meta] s
                    WHERE
                        s.ST_LOC_ID = p.ST_LOC_ID
                    AND
                        s.ST_LOC_Who = v.ST_LOC_Who
                    AND
                        s.ST_LOC_PositedAt < v.ST_LOC_PositedAt
                )
            WHERE
                p.ST_LOC_ST_ID = v.ST_LOC_ST_ID
            AND
                a.ST_LOC_Confidence > 0.25
            ORDER BY
                a.ST_LOC_PositedAt DESC,
                a.ST_LOC_Confidence DESC
        ) e
        WHERE
            v.ST_LOC_Version = @currentVersion
        AND
            v.ST_LOC_StatementType in ('S','N','D')
        AND
            v.ST_LOC_Confidence > 0.25
        AND
            e.ST_LOC_Checksum <> v.ST_LOC_Checksum
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_LOC_Stage_Location_Meta] x
            WHERE
                x.ST_LOC_ID = e.ST_LOC_ID
            AND
                x.ST_LOC_Who = v.ST_LOC_Who
            AND
                x.ST_LOC_PositedAt = v.ST_LOC_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_AVG_ST_ID,
            i.ST_AVG_ChangedAt,
            i.ST_AVG_Who,
            i.ST_AVG_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_AVG_Stage_Average_Fact] p
            JOIN
                [attributes].[ST_AVG_Stage_Average_Meta] a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            WHERE
                p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
            AND
                p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
            AND
                p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
            AND
                a.ST_AVG_Who = i.ST_AVG_Who
            AND
                a.ST_AVG_PositedAt = i.ST_AVG_PositedAt
            AND
                a.ST_AVG_Confidence <> i.ST_AVG_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_AVG_Stage_Average for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[ST_AVG_Stage_Average_Fact] p
        JOIN
            [attributes].[ST_AVG_Stage_Average_Meta] a
        ON
            a.ST_AVG_ID = p.ST_AVG_ID
        WHERE
            p.ST_AVG_ST_ID = i.ST_AVG_ST_ID
        AND
            p.ST_AVG_ChangedAt = i.ST_AVG_ChangedAt
        AND
            p.ST_AVG_UTL_ID = i.ST_AVG_UTL_ID
        AND
            a.ST_AVG_Who = i.ST_AVG_Who
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
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
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
                    THEN 'F' -- the following version restates this one, so it is retracted
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
            v.ST_AVG_ST_ID,
            v.ST_AVG_ChangedAt,
            v.ST_AVG_UTL_ID
        FROM
            @ST_AVG_Stage_Average v
        WHERE
            v.ST_AVG_Version = @currentVersion
        AND
            v.ST_AVG_StatementType in ('N','F')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @ST_AVG_Stage_Average w
            WHERE
                w.ST_AVG_Version = v.ST_AVG_Version
            AND
                w.ST_AVG_Who < v.ST_AVG_Who
            AND
                w.ST_AVG_ST_ID = v.ST_AVG_ST_ID
            AND
                w.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
            AND
                w.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID
            AND
                w.ST_AVG_StatementType in ('N','F')
        );
        -- retract the following versions that the new ones make restatements
        INSERT INTO [attributes].[ST_AVG_Stage_Average_Meta] (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Who,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        SELECT
            v.Metadata_ST_AVG,
            fol.ST_AVG_ID,
            v.ST_AVG_Who,
            v.ST_AVG_PositedAt,
            0.25
        FROM
            @ST_AVG_Stage_Average v
        CROSS APPLY (
            SELECT TOP 1
                f.ST_AVG_ID,
                f.ST_AVG_UTL_ID
            FROM
                [attributes].[fST_AVG_Stage_Average](
                    v.ST_AVG_Who,
                    v.ST_AVG_ChangedAt,
                    v.ST_AVG_PositedAt
                ) f
            WHERE
                f.ST_AVG_ST_ID = v.ST_AVG_ST_ID
            AND
                f.ST_AVG_ChangedAt > v.ST_AVG_ChangedAt
            AND
                f.ST_AVG_Stance = v.ST_AVG_Stance
            ORDER BY
                f.ST_AVG_ChangedAt ASC,
                f.ST_AVG_PositedAt DESC
        ) fol
        WHERE
            v.ST_AVG_Version = @currentVersion
        AND
            v.ST_AVG_StatementType = 'F'
        AND
            fol.ST_AVG_UTL_ID = v.ST_AVG_UTL_ID;
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
            ST_AVG_StatementType in ('S','N','D','F');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [attributes].[ST_AVG_Stage_Average_Meta] (
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_Who,
            ST_AVG_PositedAt,
            ST_AVG_Confidence
        )
        SELECT
            v.Metadata_ST_AVG,
            e.ST_AVG_ID,
            v.ST_AVG_Who,
            v.ST_AVG_PositedAt,
            0.25
        FROM
            @ST_AVG_Stage_Average v
        CROSS APPLY (
            SELECT TOP 1
                p.ST_AVG_ID,
                p.ST_AVG_UTL_ID
            FROM
                [attributes].[ST_AVG_Stage_Average_Fact] p
            JOIN
                [attributes].[ST_AVG_Stage_Average_Meta] a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Who = v.ST_AVG_Who
            AND
                a.ST_AVG_PositedAt = (
                    SELECT
                        max(s.ST_AVG_PositedAt)
                    FROM
                        [attributes].[ST_AVG_Stage_Average_Meta] s
                    WHERE
                        s.ST_AVG_ID = p.ST_AVG_ID
                    AND
                        s.ST_AVG_Who = v.ST_AVG_Who
                    AND
                        s.ST_AVG_PositedAt < v.ST_AVG_PositedAt
                )
            WHERE
                p.ST_AVG_ST_ID = v.ST_AVG_ST_ID
            AND
                p.ST_AVG_ChangedAt = v.ST_AVG_ChangedAt
            AND
                a.ST_AVG_Confidence > 0.25
            ORDER BY
                a.ST_AVG_PositedAt DESC,
                a.ST_AVG_Confidence DESC
        ) e
        WHERE
            v.ST_AVG_Version = @currentVersion
        AND
            v.ST_AVG_StatementType in ('S','N','D','F')
        AND
            v.ST_AVG_Confidence > 0.25
        AND
            e.ST_AVG_UTL_ID <> v.ST_AVG_UTL_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_AVG_Stage_Average_Meta] x
            WHERE
                x.ST_AVG_ID = e.ST_AVG_ID
            AND
                x.ST_AVG_Who = v.ST_AVG_Who
            AND
                x.ST_AVG_PositedAt = v.ST_AVG_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_MIN_ST_ID,
            i.ST_MIN_Who,
            i.ST_MIN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_MIN_Stage_Minimum_Fact] p
            JOIN
                [attributes].[ST_MIN_Stage_Minimum_Meta] a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            WHERE
                p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
            AND
                p.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
            AND
                a.ST_MIN_Who = i.ST_MIN_Who
            AND
                a.ST_MIN_PositedAt = i.ST_MIN_PositedAt
            AND
                a.ST_MIN_Confidence <> i.ST_MIN_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_MIN_Stage_Minimum for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[ST_MIN_Stage_Minimum_Fact] p
        JOIN
            [attributes].[ST_MIN_Stage_Minimum_Meta] a
        ON
            a.ST_MIN_ID = p.ST_MIN_ID
        WHERE
            p.ST_MIN_ST_ID = i.ST_MIN_ST_ID
        AND
            p.ST_MIN_UTL_ID = i.ST_MIN_UTL_ID
        AND
            a.ST_MIN_Who = i.ST_MIN_Who
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
            v.ST_MIN_ST_ID,
            v.ST_MIN_UTL_ID
        FROM
            @ST_MIN_Stage_Minimum v
        WHERE
            v.ST_MIN_Version = @currentVersion
        AND
            v.ST_MIN_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @ST_MIN_Stage_Minimum w
            WHERE
                w.ST_MIN_Version = v.ST_MIN_Version
            AND
                w.ST_MIN_Who < v.ST_MIN_Who
            AND
                w.ST_MIN_ST_ID = v.ST_MIN_ST_ID
            AND
                w.ST_MIN_UTL_ID = v.ST_MIN_UTL_ID
            AND
                w.ST_MIN_StatementType in ('N')
        );
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
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[ST_MIN_Stage_Minimum_Meta] (
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_Who,
            ST_MIN_PositedAt,
            ST_MIN_Confidence
        )
        SELECT
            v.Metadata_ST_MIN,
            e.ST_MIN_ID,
            v.ST_MIN_Who,
            v.ST_MIN_PositedAt,
            0.25
        FROM
            @ST_MIN_Stage_Minimum v
        CROSS APPLY (
            SELECT TOP 1
                p.ST_MIN_ID,
                p.ST_MIN_UTL_ID
            FROM
                [attributes].[ST_MIN_Stage_Minimum_Fact] p
            JOIN
                [attributes].[ST_MIN_Stage_Minimum_Meta] a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            AND
                a.ST_MIN_Who = v.ST_MIN_Who
            AND
                a.ST_MIN_PositedAt = (
                    SELECT
                        max(s.ST_MIN_PositedAt)
                    FROM
                        [attributes].[ST_MIN_Stage_Minimum_Meta] s
                    WHERE
                        s.ST_MIN_ID = p.ST_MIN_ID
                    AND
                        s.ST_MIN_Who = v.ST_MIN_Who
                    AND
                        s.ST_MIN_PositedAt < v.ST_MIN_PositedAt
                )
            WHERE
                p.ST_MIN_ST_ID = v.ST_MIN_ST_ID
            AND
                a.ST_MIN_Confidence > 0.25
            ORDER BY
                a.ST_MIN_PositedAt DESC,
                a.ST_MIN_Confidence DESC
        ) e
        WHERE
            v.ST_MIN_Version = @currentVersion
        AND
            v.ST_MIN_StatementType in ('S','N','D')
        AND
            v.ST_MIN_Confidence > 0.25
        AND
            e.ST_MIN_UTL_ID <> v.ST_MIN_UTL_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[ST_MIN_Stage_Minimum_Meta] x
            WHERE
                x.ST_MIN_ID = e.ST_MIN_ID
            AND
                x.ST_MIN_Who = v.ST_MIN_Who
            AND
                x.ST_MIN_PositedAt = v.ST_MIN_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_NAM_AC_ID,
            i.AC_NAM_ChangedAt,
            i.AC_NAM_Who,
            i.AC_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[AC_NAM_Actor_Name_Fact] p
            JOIN
                [attributes].[AC_NAM_Actor_Name_Meta] a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            WHERE
                p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
            AND
                p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
            AND
                p.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
            AND
                a.AC_NAM_Who = i.AC_NAM_Who
            AND
                a.AC_NAM_PositedAt = i.AC_NAM_PositedAt
            AND
                a.AC_NAM_Confidence <> i.AC_NAM_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_NAM_Actor_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[AC_NAM_Actor_Name_Fact] p
        JOIN
            [attributes].[AC_NAM_Actor_Name_Meta] a
        ON
            a.AC_NAM_ID = p.AC_NAM_ID
        WHERE
            p.AC_NAM_AC_ID = i.AC_NAM_AC_ID
        AND
            p.AC_NAM_ChangedAt = i.AC_NAM_ChangedAt
        AND
            p.AC_NAM_Actor_Name = i.AC_NAM_Actor_Name
        AND
            a.AC_NAM_Who = i.AC_NAM_Who
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
            v.AC_NAM_AC_ID,
            v.AC_NAM_ChangedAt,
            v.AC_NAM_Actor_Name
        FROM
            @AC_NAM_Actor_Name v
        WHERE
            v.AC_NAM_Version = @currentVersion
        AND
            v.AC_NAM_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @AC_NAM_Actor_Name w
            WHERE
                w.AC_NAM_Version = v.AC_NAM_Version
            AND
                w.AC_NAM_Who < v.AC_NAM_Who
            AND
                w.AC_NAM_AC_ID = v.AC_NAM_AC_ID
            AND
                w.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
            AND
                w.AC_NAM_Actor_Name = v.AC_NAM_Actor_Name
            AND
                w.AC_NAM_StatementType in ('N','R')
        );
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
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [attributes].[AC_NAM_Actor_Name_Meta] (
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_Who,
            AC_NAM_PositedAt,
            AC_NAM_Confidence
        )
        SELECT
            v.Metadata_AC_NAM,
            e.AC_NAM_ID,
            v.AC_NAM_Who,
            v.AC_NAM_PositedAt,
            0.25
        FROM
            @AC_NAM_Actor_Name v
        CROSS APPLY (
            SELECT TOP 1
                p.AC_NAM_ID,
                p.AC_NAM_Actor_Name
            FROM
                [attributes].[AC_NAM_Actor_Name_Fact] p
            JOIN
                [attributes].[AC_NAM_Actor_Name_Meta] a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Who = v.AC_NAM_Who
            AND
                a.AC_NAM_PositedAt = (
                    SELECT
                        max(s.AC_NAM_PositedAt)
                    FROM
                        [attributes].[AC_NAM_Actor_Name_Meta] s
                    WHERE
                        s.AC_NAM_ID = p.AC_NAM_ID
                    AND
                        s.AC_NAM_Who = v.AC_NAM_Who
                    AND
                        s.AC_NAM_PositedAt < v.AC_NAM_PositedAt
                )
            WHERE
                p.AC_NAM_AC_ID = v.AC_NAM_AC_ID
            AND
                p.AC_NAM_ChangedAt = v.AC_NAM_ChangedAt
            AND
                a.AC_NAM_Confidence > 0.25
            ORDER BY
                a.AC_NAM_PositedAt DESC,
                a.AC_NAM_Confidence DESC
        ) e
        WHERE
            v.AC_NAM_Version = @currentVersion
        AND
            v.AC_NAM_StatementType in ('S','N','D','R')
        AND
            v.AC_NAM_Confidence > 0.25
        AND
            e.AC_NAM_Actor_Name <> v.AC_NAM_Actor_Name
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[AC_NAM_Actor_Name_Meta] x
            WHERE
                x.AC_NAM_ID = e.AC_NAM_ID
            AND
                x.AC_NAM_Who = v.AC_NAM_Who
            AND
                x.AC_NAM_PositedAt = v.AC_NAM_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_GEN_AC_ID,
            i.AC_GEN_Who,
            i.AC_GEN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[AC_GEN_Actor_Gender_Fact] p
            JOIN
                [attributes].[AC_GEN_Actor_Gender_Meta] a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            WHERE
                p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
            AND
                p.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
            AND
                a.AC_GEN_Who = i.AC_GEN_Who
            AND
                a.AC_GEN_PositedAt = i.AC_GEN_PositedAt
            AND
                a.AC_GEN_Confidence <> i.AC_GEN_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_GEN_Actor_Gender for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[AC_GEN_Actor_Gender_Fact] p
        JOIN
            [attributes].[AC_GEN_Actor_Gender_Meta] a
        ON
            a.AC_GEN_ID = p.AC_GEN_ID
        WHERE
            p.AC_GEN_AC_ID = i.AC_GEN_AC_ID
        AND
            p.AC_GEN_GEN_ID = i.AC_GEN_GEN_ID
        AND
            a.AC_GEN_Who = i.AC_GEN_Who
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
            v.AC_GEN_AC_ID,
            v.AC_GEN_GEN_ID
        FROM
            @AC_GEN_Actor_Gender v
        WHERE
            v.AC_GEN_Version = @currentVersion
        AND
            v.AC_GEN_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @AC_GEN_Actor_Gender w
            WHERE
                w.AC_GEN_Version = v.AC_GEN_Version
            AND
                w.AC_GEN_Who < v.AC_GEN_Who
            AND
                w.AC_GEN_AC_ID = v.AC_GEN_AC_ID
            AND
                w.AC_GEN_GEN_ID = v.AC_GEN_GEN_ID
            AND
                w.AC_GEN_StatementType in ('N')
        );
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
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[AC_GEN_Actor_Gender_Meta] (
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_Who,
            AC_GEN_PositedAt,
            AC_GEN_Confidence
        )
        SELECT
            v.Metadata_AC_GEN,
            e.AC_GEN_ID,
            v.AC_GEN_Who,
            v.AC_GEN_PositedAt,
            0.25
        FROM
            @AC_GEN_Actor_Gender v
        CROSS APPLY (
            SELECT TOP 1
                p.AC_GEN_ID,
                p.AC_GEN_GEN_ID
            FROM
                [attributes].[AC_GEN_Actor_Gender_Fact] p
            JOIN
                [attributes].[AC_GEN_Actor_Gender_Meta] a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            AND
                a.AC_GEN_Who = v.AC_GEN_Who
            AND
                a.AC_GEN_PositedAt = (
                    SELECT
                        max(s.AC_GEN_PositedAt)
                    FROM
                        [attributes].[AC_GEN_Actor_Gender_Meta] s
                    WHERE
                        s.AC_GEN_ID = p.AC_GEN_ID
                    AND
                        s.AC_GEN_Who = v.AC_GEN_Who
                    AND
                        s.AC_GEN_PositedAt < v.AC_GEN_PositedAt
                )
            WHERE
                p.AC_GEN_AC_ID = v.AC_GEN_AC_ID
            AND
                a.AC_GEN_Confidence > 0.25
            ORDER BY
                a.AC_GEN_PositedAt DESC,
                a.AC_GEN_Confidence DESC
        ) e
        WHERE
            v.AC_GEN_Version = @currentVersion
        AND
            v.AC_GEN_StatementType in ('S','N','D')
        AND
            v.AC_GEN_Confidence > 0.25
        AND
            e.AC_GEN_GEN_ID <> v.AC_GEN_GEN_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[AC_GEN_Actor_Gender_Meta] x
            WHERE
                x.AC_GEN_ID = e.AC_GEN_ID
            AND
                x.AC_GEN_Who = v.AC_GEN_Who
            AND
                x.AC_GEN_PositedAt = v.AC_GEN_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_PLV_AC_ID,
            i.AC_PLV_ChangedAt,
            i.AC_PLV_Who,
            i.AC_PLV_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact] p
            JOIN
                [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            WHERE
                p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
            AND
                p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
            AND
                p.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
            AND
                a.AC_PLV_Who = i.AC_PLV_Who
            AND
                a.AC_PLV_PositedAt = i.AC_PLV_PositedAt
            AND
                a.AC_PLV_Confidence <> i.AC_PLV_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_PLV_Actor_ProfessionalLevel for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact] p
        JOIN
            [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] a
        ON
            a.AC_PLV_ID = p.AC_PLV_ID
        WHERE
            p.AC_PLV_AC_ID = i.AC_PLV_AC_ID
        AND
            p.AC_PLV_ChangedAt = i.AC_PLV_ChangedAt
        AND
            p.AC_PLV_PLV_ID = i.AC_PLV_PLV_ID
        AND
            a.AC_PLV_Who = i.AC_PLV_Who
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
            v.AC_PLV_AC_ID,
            v.AC_PLV_ChangedAt,
            v.AC_PLV_PLV_ID
        FROM
            @AC_PLV_Actor_ProfessionalLevel v
        WHERE
            v.AC_PLV_Version = @currentVersion
        AND
            v.AC_PLV_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @AC_PLV_Actor_ProfessionalLevel w
            WHERE
                w.AC_PLV_Version = v.AC_PLV_Version
            AND
                w.AC_PLV_Who < v.AC_PLV_Who
            AND
                w.AC_PLV_AC_ID = v.AC_PLV_AC_ID
            AND
                w.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
            AND
                w.AC_PLV_PLV_ID = v.AC_PLV_PLV_ID
            AND
                w.AC_PLV_StatementType in ('N','R')
        );
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
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] (
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_Who,
            AC_PLV_PositedAt,
            AC_PLV_Confidence
        )
        SELECT
            v.Metadata_AC_PLV,
            e.AC_PLV_ID,
            v.AC_PLV_Who,
            v.AC_PLV_PositedAt,
            0.25
        FROM
            @AC_PLV_Actor_ProfessionalLevel v
        CROSS APPLY (
            SELECT TOP 1
                p.AC_PLV_ID,
                p.AC_PLV_PLV_ID
            FROM
                [attributes].[AC_PLV_Actor_ProfessionalLevel_Fact] p
            JOIN
                [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Who = v.AC_PLV_Who
            AND
                a.AC_PLV_PositedAt = (
                    SELECT
                        max(s.AC_PLV_PositedAt)
                    FROM
                        [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] s
                    WHERE
                        s.AC_PLV_ID = p.AC_PLV_ID
                    AND
                        s.AC_PLV_Who = v.AC_PLV_Who
                    AND
                        s.AC_PLV_PositedAt < v.AC_PLV_PositedAt
                )
            WHERE
                p.AC_PLV_AC_ID = v.AC_PLV_AC_ID
            AND
                p.AC_PLV_ChangedAt = v.AC_PLV_ChangedAt
            AND
                a.AC_PLV_Confidence > 0.25
            ORDER BY
                a.AC_PLV_PositedAt DESC,
                a.AC_PLV_Confidence DESC
        ) e
        WHERE
            v.AC_PLV_Version = @currentVersion
        AND
            v.AC_PLV_StatementType in ('S','N','D','R')
        AND
            v.AC_PLV_Confidence > 0.25
        AND
            e.AC_PLV_PLV_ID <> v.AC_PLV_PLV_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[AC_PLV_Actor_ProfessionalLevel_Meta] x
            WHERE
                x.AC_PLV_ID = e.AC_PLV_ID
            AND
                x.AC_PLV_Who = v.AC_PLV_Who
            AND
                x.AC_PLV_PositedAt = v.AC_PLV_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_NAM_PR_ID,
            i.PR_NAM_Who,
            i.PR_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[PR_NAM_Program_Name_Fact] p
            JOIN
                [attributes].[PR_NAM_Program_Name_Meta] a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            WHERE
                p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
            AND
                p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
            AND
                a.PR_NAM_Who = i.PR_NAM_Who
            AND
                a.PR_NAM_PositedAt = i.PR_NAM_PositedAt
            AND
                a.PR_NAM_Confidence <> i.PR_NAM_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_NAM_Program_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[PR_NAM_Program_Name_Fact] p
        JOIN
            [attributes].[PR_NAM_Program_Name_Meta] a
        ON
            a.PR_NAM_ID = p.PR_NAM_ID
        WHERE
            p.PR_NAM_PR_ID = i.PR_NAM_PR_ID
        AND
            p.PR_NAM_Program_Name = i.PR_NAM_Program_Name
        AND
            a.PR_NAM_Who = i.PR_NAM_Who
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
            v.PR_NAM_PR_ID,
            v.PR_NAM_Program_Name
        FROM
            @PR_NAM_Program_Name v
        WHERE
            v.PR_NAM_Version = @currentVersion
        AND
            v.PR_NAM_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @PR_NAM_Program_Name w
            WHERE
                w.PR_NAM_Version = v.PR_NAM_Version
            AND
                w.PR_NAM_Who < v.PR_NAM_Who
            AND
                w.PR_NAM_PR_ID = v.PR_NAM_PR_ID
            AND
                w.PR_NAM_Program_Name = v.PR_NAM_Program_Name
            AND
                w.PR_NAM_StatementType in ('N')
        );
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
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [attributes].[PR_NAM_Program_Name_Meta] (
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_Who,
            PR_NAM_PositedAt,
            PR_NAM_Confidence
        )
        SELECT
            v.Metadata_PR_NAM,
            e.PR_NAM_ID,
            v.PR_NAM_Who,
            v.PR_NAM_PositedAt,
            0.25
        FROM
            @PR_NAM_Program_Name v
        CROSS APPLY (
            SELECT TOP 1
                p.PR_NAM_ID,
                p.PR_NAM_Program_Name
            FROM
                [attributes].[PR_NAM_Program_Name_Fact] p
            JOIN
                [attributes].[PR_NAM_Program_Name_Meta] a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            AND
                a.PR_NAM_Who = v.PR_NAM_Who
            AND
                a.PR_NAM_PositedAt = (
                    SELECT
                        max(s.PR_NAM_PositedAt)
                    FROM
                        [attributes].[PR_NAM_Program_Name_Meta] s
                    WHERE
                        s.PR_NAM_ID = p.PR_NAM_ID
                    AND
                        s.PR_NAM_Who = v.PR_NAM_Who
                    AND
                        s.PR_NAM_PositedAt < v.PR_NAM_PositedAt
                )
            WHERE
                p.PR_NAM_PR_ID = v.PR_NAM_PR_ID
            AND
                a.PR_NAM_Confidence > 0.25
            ORDER BY
                a.PR_NAM_PositedAt DESC,
                a.PR_NAM_Confidence DESC
        ) e
        WHERE
            v.PR_NAM_Version = @currentVersion
        AND
            v.PR_NAM_StatementType in ('S','N','D')
        AND
            v.PR_NAM_Confidence > 0.25
        AND
            e.PR_NAM_Program_Name <> v.PR_NAM_Program_Name
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[PR_NAM_Program_Name_Meta] x
            WHERE
                x.PR_NAM_ID = e.PR_NAM_ID
            AND
                x.PR_NAM_Who = v.PR_NAM_Who
            AND
                x.PR_NAM_PositedAt = v.PR_NAM_PositedAt
        );
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
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_LEN_PR_ID,
            i.PR_LEN_ChangedAt,
            i.PR_LEN_Who,
            i.PR_LEN_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [attributes].[PR_LEN_Program_Length_Fact] p
            JOIN
                [attributes].[PR_LEN_Program_Length_Meta] a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            WHERE
                p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
            AND
                p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
            AND
                p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
            AND
                a.PR_LEN_Who = i.PR_LEN_Who
            AND
                a.PR_LEN_PositedAt = i.PR_LEN_PositedAt
            AND
                a.PR_LEN_Confidence <> i.PR_LEN_Confidence
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_LEN_Program_Length for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
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
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [attributes].[PR_LEN_Program_Length_Fact] p
        JOIN
            [attributes].[PR_LEN_Program_Length_Meta] a
        ON
            a.PR_LEN_ID = p.PR_LEN_ID
        WHERE
            p.PR_LEN_PR_ID = i.PR_LEN_PR_ID
        AND
            p.PR_LEN_ChangedAt = i.PR_LEN_ChangedAt
        AND
            p.PR_LEN_Program_Length = i.PR_LEN_Program_Length
        AND
            a.PR_LEN_Who = i.PR_LEN_Who
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
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
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
                    THEN 'F' -- the following version restates this one, so it is retracted
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
            v.PR_LEN_PR_ID,
            v.PR_LEN_ChangedAt,
            v.PR_LEN_Program_Length
        FROM
            @PR_LEN_Program_Length v
        WHERE
            v.PR_LEN_Version = @currentVersion
        AND
            v.PR_LEN_StatementType in ('N','F')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @PR_LEN_Program_Length w
            WHERE
                w.PR_LEN_Version = v.PR_LEN_Version
            AND
                w.PR_LEN_Who < v.PR_LEN_Who
            AND
                w.PR_LEN_PR_ID = v.PR_LEN_PR_ID
            AND
                w.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
            AND
                w.PR_LEN_Program_Length = v.PR_LEN_Program_Length
            AND
                w.PR_LEN_StatementType in ('N','F')
        );
        -- retract the following versions that the new ones make restatements
        INSERT INTO [attributes].[PR_LEN_Program_Length_Meta] (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Who,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        SELECT
            v.Metadata_PR_LEN,
            fol.PR_LEN_ID,
            v.PR_LEN_Who,
            v.PR_LEN_PositedAt,
            0.25
        FROM
            @PR_LEN_Program_Length v
        CROSS APPLY (
            SELECT TOP 1
                f.PR_LEN_ID,
                f.PR_LEN_Program_Length
            FROM
                [attributes].[fPR_LEN_Program_Length](
                    v.PR_LEN_Who,
                    v.PR_LEN_ChangedAt,
                    v.PR_LEN_PositedAt
                ) f
            WHERE
                f.PR_LEN_PR_ID = v.PR_LEN_PR_ID
            AND
                f.PR_LEN_ChangedAt > v.PR_LEN_ChangedAt
            AND
                f.PR_LEN_Stance = v.PR_LEN_Stance
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
            PR_LEN_StatementType in ('S','N','D','F');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [attributes].[PR_LEN_Program_Length_Meta] (
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_Who,
            PR_LEN_PositedAt,
            PR_LEN_Confidence
        )
        SELECT
            v.Metadata_PR_LEN,
            e.PR_LEN_ID,
            v.PR_LEN_Who,
            v.PR_LEN_PositedAt,
            0.25
        FROM
            @PR_LEN_Program_Length v
        CROSS APPLY (
            SELECT TOP 1
                p.PR_LEN_ID,
                p.PR_LEN_Program_Length
            FROM
                [attributes].[PR_LEN_Program_Length_Fact] p
            JOIN
                [attributes].[PR_LEN_Program_Length_Meta] a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Who = v.PR_LEN_Who
            AND
                a.PR_LEN_PositedAt = (
                    SELECT
                        max(s.PR_LEN_PositedAt)
                    FROM
                        [attributes].[PR_LEN_Program_Length_Meta] s
                    WHERE
                        s.PR_LEN_ID = p.PR_LEN_ID
                    AND
                        s.PR_LEN_Who = v.PR_LEN_Who
                    AND
                        s.PR_LEN_PositedAt < v.PR_LEN_PositedAt
                )
            WHERE
                p.PR_LEN_PR_ID = v.PR_LEN_PR_ID
            AND
                p.PR_LEN_ChangedAt = v.PR_LEN_ChangedAt
            AND
                a.PR_LEN_Confidence > 0.25
            ORDER BY
                a.PR_LEN_PositedAt DESC,
                a.PR_LEN_Confidence DESC
        ) e
        WHERE
            v.PR_LEN_Version = @currentVersion
        AND
            v.PR_LEN_StatementType in ('S','N','D','F')
        AND
            v.PR_LEN_Confidence > 0.25
        AND
            e.PR_LEN_Program_Length <> v.PR_LEN_Program_Length
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [attributes].[PR_LEN_Program_Length_Meta] x
            WHERE
                x.PR_LEN_ID = e.PR_LEN_ID
            AND
                x.PR_LEN_Who = v.PR_LEN_Who
            AND
                x.PR_LEN_PositedAt = v.PR_LEN_PositedAt
        );
    END
END
GO
