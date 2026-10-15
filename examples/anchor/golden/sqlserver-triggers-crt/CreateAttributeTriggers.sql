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
-- it_EV_QTY_Event_Quantity instead of INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_QTY_Event_Quantity', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_QTY_Event_Quantity];
GO
CREATE TRIGGER [dbo].[it_EV_QTY_Event_Quantity] ON [dbo].[EV_QTY_Event_Quantity]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_QTY_Event_Quantity TABLE (
        EV_QTY_EV_ID int not null,
        Metadata_EV_QTY int not null,
        EV_QTY_Positor tinyint not null,
        EV_QTY_PositedAt datetime2 not null,
        EV_QTY_Reliability decimal(5,2) not null,
        EV_QTY_Assertion char(1) not null,
        EV_QTY_Event_Quantity int not null,
        EV_QTY_Version bigint not null,
        EV_QTY_StatementType char(1) not null,
        primary key(
            EV_QTY_Version,
            EV_QTY_Positor,
            EV_QTY_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_QTY_EV_ID,
            i.EV_QTY_Positor,
            i.EV_QTY_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_QTY_Event_Quantity_Posit] p
            JOIN
                [dbo].[EV_QTY_Event_Quantity_Annex] a
            ON
                a.EV_QTY_ID = p.EV_QTY_ID
            WHERE
                p.EV_QTY_EV_ID = i.EV_QTY_EV_ID
            AND
                p.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
            AND
                a.EV_QTY_Positor = i.EV_QTY_Positor
            AND
                a.EV_QTY_PositedAt = i.EV_QTY_PositedAt
            AND
                a.EV_QTY_Reliability <> i.EV_QTY_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_QTY_Event_Quantity for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_QTY_Event_Quantity
    SELECT
        i.EV_QTY_EV_ID,
        i.Metadata_EV_QTY,
        i.EV_QTY_Positor,
        i.EV_QTY_PositedAt,
        i.EV_QTY_Reliability,
        case
            when i.EV_QTY_Reliability > 0 then '+'
            when i.EV_QTY_Reliability = 0 then '?'
            when i.EV_QTY_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_QTY_Event_Quantity,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_QTY_Positor,
                i.EV_QTY_EV_ID
            ORDER BY
                i.EV_QTY_PositedAt ASC,
                i.EV_QTY_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Annex] a
        ON
            a.EV_QTY_ID = p.EV_QTY_ID
        WHERE
            p.EV_QTY_EV_ID = i.EV_QTY_EV_ID
        AND
            p.EV_QTY_Event_Quantity = i.EV_QTY_Event_Quantity
        AND
            a.EV_QTY_Positor = i.EV_QTY_Positor
        AND
            a.EV_QTY_PositedAt = i.EV_QTY_PositedAt
    );
    SELECT
        @maxVersion = max(EV_QTY_Version),
        @currentVersion = 0
    FROM
        @EV_QTY_Event_Quantity;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_QTY_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_QTY_ID
                        FROM
                            [dbo].[tEV_Event](v.EV_QTY_Positor, DEFAULT, v.EV_QTY_PositedAt, v.EV_QTY_Assertion) t
                        WHERE
                            t.EV_QTY_EV_ID = v.EV_QTY_EV_ID
                        AND
                            t.EV_QTY_Reliability = v.EV_QTY_Reliability
                        AND
                            t.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_QTY_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_QTY_Event_Quantity v
        LEFT JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_EV_ID = v.EV_QTY_EV_ID
        AND
            p.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
        WHERE
            v.EV_QTY_Version = @currentVersion;
        INSERT INTO [dbo].[EV_QTY_Event_Quantity_Posit] (
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity
        )
        SELECT
            v.EV_QTY_EV_ID,
            v.EV_QTY_Event_Quantity
        FROM
            @EV_QTY_Event_Quantity v
        WHERE
            v.EV_QTY_Version = @currentVersion
        AND
            v.EV_QTY_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_QTY_Event_Quantity w
            WHERE
                w.EV_QTY_Version = v.EV_QTY_Version
            AND
                w.EV_QTY_Positor < v.EV_QTY_Positor
            AND
                w.EV_QTY_EV_ID = v.EV_QTY_EV_ID
            AND
                w.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
            AND
                w.EV_QTY_StatementType in ('N')
        );
        INSERT INTO [dbo].[EV_QTY_Event_Quantity_Annex] (
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_Positor,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
        )
        SELECT
            v.Metadata_EV_QTY,
            p.EV_QTY_ID,
            v.EV_QTY_Positor,
            v.EV_QTY_PositedAt,
            v.EV_QTY_Reliability
        FROM
            @EV_QTY_Event_Quantity v
        JOIN
            [dbo].[EV_QTY_Event_Quantity_Posit] p
        ON
            p.EV_QTY_EV_ID = v.EV_QTY_EV_ID
        AND
            p.EV_QTY_Event_Quantity = v.EV_QTY_Event_Quantity
        WHERE
            v.EV_QTY_Version = @currentVersion
        AND
            EV_QTY_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [dbo].[EV_QTY_Event_Quantity_Annex] (
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_Positor,
            EV_QTY_PositedAt,
            EV_QTY_Reliability
        )
        SELECT
            v.Metadata_EV_QTY,
            e.EV_QTY_ID,
            v.EV_QTY_Positor,
            v.EV_QTY_PositedAt,
            0
        FROM
            @EV_QTY_Event_Quantity v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_QTY_ID,
                p.EV_QTY_Event_Quantity
            FROM
                [dbo].[EV_QTY_Event_Quantity_Posit] p
            JOIN
                [dbo].[EV_QTY_Event_Quantity_Annex] a
            ON
                a.EV_QTY_ID = p.EV_QTY_ID
            AND
                a.EV_QTY_Positor = v.EV_QTY_Positor
            AND
                a.EV_QTY_PositedAt = (
                    SELECT
                        max(s.EV_QTY_PositedAt)
                    FROM
                        [dbo].[EV_QTY_Event_Quantity_Annex] s
                    WHERE
                        s.EV_QTY_ID = p.EV_QTY_ID
                    AND
                        s.EV_QTY_Positor = v.EV_QTY_Positor
                    AND
                        s.EV_QTY_PositedAt < v.EV_QTY_PositedAt
                )
            WHERE
                p.EV_QTY_EV_ID = v.EV_QTY_EV_ID
            AND
                a.EV_QTY_Reliability > 0
            ORDER BY
                a.EV_QTY_PositedAt DESC,
                a.EV_QTY_Reliability DESC
        ) e
        WHERE
            v.EV_QTY_Version = @currentVersion
        AND
            v.EV_QTY_StatementType in ('S','N','D')
        AND
            v.EV_QTY_Reliability > 0
        AND
            e.EV_QTY_Event_Quantity <> v.EV_QTY_Event_Quantity
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_QTY_Event_Quantity_Annex] x
            WHERE
                x.EV_QTY_ID = e.EV_QTY_ID
            AND
                x.EV_QTY_Positor = v.EV_QTY_Positor
            AND
                x.EV_QTY_PositedAt = v.EV_QTY_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place instead of INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_PLC_Event_Place', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_PLC_Event_Place];
GO
CREATE TRIGGER [dbo].[it_EV_PLC_Event_Place] ON [dbo].[EV_PLC_Event_Place]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @EV_PLC_Event_Place TABLE (
        EV_PLC_EV_ID int not null,
        Metadata_EV_PLC int not null,
        EV_PLC_ChangedAt datetime2 not null,
        EV_PLC_Positor tinyint not null,
        EV_PLC_PositedAt datetime2 not null,
        EV_PLC_Reliability decimal(5,2) not null,
        EV_PLC_Assertion char(1) not null,
        EV_PLC_Event_Place nvarchar(42) not null,
        EV_PLC_Version bigint not null,
        EV_PLC_StatementType char(1) not null,
        primary key(
            EV_PLC_Version,
            EV_PLC_Positor,
            EV_PLC_EV_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_PLC_EV_ID,
            i.EV_PLC_ChangedAt,
            i.EV_PLC_Positor,
            i.EV_PLC_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_PLC_Event_Place_Posit] p
            JOIN
                [dbo].[EV_PLC_Event_Place_Annex] a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            WHERE
                p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
            AND
                p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
            AND
                p.EV_PLC_Event_Place = i.EV_PLC_Event_Place
            AND
                a.EV_PLC_Positor = i.EV_PLC_Positor
            AND
                a.EV_PLC_PositedAt = i.EV_PLC_PositedAt
            AND
                a.EV_PLC_Reliability <> i.EV_PLC_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_PLC_Event_Place for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @EV_PLC_Event_Place
    SELECT
        i.EV_PLC_EV_ID,
        i.Metadata_EV_PLC,
        i.EV_PLC_ChangedAt,
        i.EV_PLC_Positor,
        i.EV_PLC_PositedAt,
        i.EV_PLC_Reliability,
        case
            when i.EV_PLC_Reliability > 0 then '+'
            when i.EV_PLC_Reliability = 0 then '?'
            when i.EV_PLC_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.EV_PLC_Event_Place,
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_PLC_Positor,
                i.EV_PLC_EV_ID
            ORDER BY
                i.EV_PLC_ChangedAt ASC,
                i.EV_PLC_PositedAt ASC,
                i.EV_PLC_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[EV_PLC_Event_Place_Posit] p
        JOIN
            [dbo].[EV_PLC_Event_Place_Annex] a
        ON
            a.EV_PLC_ID = p.EV_PLC_ID
        WHERE
            p.EV_PLC_EV_ID = i.EV_PLC_EV_ID
        AND
            p.EV_PLC_ChangedAt = i.EV_PLC_ChangedAt
        AND
            p.EV_PLC_Event_Place = i.EV_PLC_Event_Place
        AND
            a.EV_PLC_Positor = i.EV_PLC_Positor
        AND
            a.EV_PLC_PositedAt = i.EV_PLC_PositedAt
    );
    SELECT
        @maxVersion = max(EV_PLC_Version),
        @currentVersion = 0
    FROM
        @EV_PLC_Event_Place;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_PLC_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_PLC_ID
                        FROM
                            [dbo].[tEV_Event](v.EV_PLC_Positor, v.EV_PLC_ChangedAt, v.EV_PLC_PositedAt, v.EV_PLC_Assertion) t
                        WHERE
                            t.EV_PLC_EV_ID = v.EV_PLC_EV_ID
                        AND
                            t.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
                        AND
                            t.EV_PLC_Reliability = v.EV_PLC_Reliability
                        AND
                            t.EV_PLC_Event_Place = v.EV_PLC_Event_Place
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_PLC_EV_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.EV_PLC_Event_Place
                        WHERE
                            v.EV_PLC_Event_Place =
                                dbo.preEV_PLC_Event_Place (
                                    v.EV_PLC_EV_ID,
                                    v.EV_PLC_Positor,
                                    v.EV_PLC_ChangedAt,
                                    v.EV_PLC_PositedAt,
                                    v.EV_PLC_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.EV_PLC_Event_Place
                        WHERE
                            v.EV_PLC_Event_Place =
                                dbo.folEV_PLC_Event_Place (
                                    v.EV_PLC_EV_ID,
                                    v.EV_PLC_Positor,
                                    v.EV_PLC_ChangedAt,
                                    v.EV_PLC_PositedAt,
                                    v.EV_PLC_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @EV_PLC_Event_Place v
        LEFT JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_EV_ID = v.EV_PLC_EV_ID
        AND
            p.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
        AND
            p.EV_PLC_Event_Place = v.EV_PLC_Event_Place
        WHERE
            v.EV_PLC_Version = @currentVersion;
        INSERT INTO [dbo].[EV_PLC_Event_Place_Posit] (
            EV_PLC_EV_ID,
            EV_PLC_ChangedAt,
            EV_PLC_Event_Place
        )
        SELECT
            v.EV_PLC_EV_ID,
            v.EV_PLC_ChangedAt,
            v.EV_PLC_Event_Place
        FROM
            @EV_PLC_Event_Place v
        WHERE
            v.EV_PLC_Version = @currentVersion
        AND
            v.EV_PLC_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @EV_PLC_Event_Place w
            WHERE
                w.EV_PLC_Version = v.EV_PLC_Version
            AND
                w.EV_PLC_Positor < v.EV_PLC_Positor
            AND
                w.EV_PLC_EV_ID = v.EV_PLC_EV_ID
            AND
                w.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
            AND
                w.EV_PLC_Event_Place = v.EV_PLC_Event_Place
            AND
                w.EV_PLC_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[EV_PLC_Event_Place_Annex] (
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_Positor,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
        )
        SELECT
            v.Metadata_EV_PLC,
            p.EV_PLC_ID,
            v.EV_PLC_Positor,
            v.EV_PLC_PositedAt,
            v.EV_PLC_Reliability
        FROM
            @EV_PLC_Event_Place v
        JOIN
            [dbo].[EV_PLC_Event_Place_Posit] p
        ON
            p.EV_PLC_EV_ID = v.EV_PLC_EV_ID
        AND
            p.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
        AND
            p.EV_PLC_Event_Place = v.EV_PLC_Event_Place
        WHERE
            v.EV_PLC_Version = @currentVersion
        AND
            EV_PLC_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[EV_PLC_Event_Place_Annex] (
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_Positor,
            EV_PLC_PositedAt,
            EV_PLC_Reliability
        )
        SELECT
            v.Metadata_EV_PLC,
            e.EV_PLC_ID,
            v.EV_PLC_Positor,
            v.EV_PLC_PositedAt,
            0
        FROM
            @EV_PLC_Event_Place v
        CROSS APPLY (
            SELECT TOP 1
                p.EV_PLC_ID,
                p.EV_PLC_Event_Place
            FROM
                [dbo].[EV_PLC_Event_Place_Posit] p
            JOIN
                [dbo].[EV_PLC_Event_Place_Annex] a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            AND
                a.EV_PLC_Positor = v.EV_PLC_Positor
            AND
                a.EV_PLC_PositedAt = (
                    SELECT
                        max(s.EV_PLC_PositedAt)
                    FROM
                        [dbo].[EV_PLC_Event_Place_Annex] s
                    WHERE
                        s.EV_PLC_ID = p.EV_PLC_ID
                    AND
                        s.EV_PLC_Positor = v.EV_PLC_Positor
                    AND
                        s.EV_PLC_PositedAt < v.EV_PLC_PositedAt
                )
            WHERE
                p.EV_PLC_EV_ID = v.EV_PLC_EV_ID
            AND
                p.EV_PLC_ChangedAt = v.EV_PLC_ChangedAt
            AND
                a.EV_PLC_Reliability > 0
            ORDER BY
                a.EV_PLC_PositedAt DESC,
                a.EV_PLC_Reliability DESC
        ) e
        WHERE
            v.EV_PLC_Version = @currentVersion
        AND
            v.EV_PLC_StatementType in ('S','N','D','R')
        AND
            v.EV_PLC_Reliability > 0
        AND
            e.EV_PLC_Event_Place <> v.EV_PLC_Event_Place
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[EV_PLC_Event_Place_Annex] x
            WHERE
                x.EV_PLC_ID = e.EV_PLC_ID
            AND
                x.EV_PLC_Positor = v.EV_PLC_Positor
            AND
                x.EV_PLC_PositedAt = v.EV_PLC_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name instead of INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NAM_Subject_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NAM_Subject_Name];
GO
CREATE TRIGGER [dbo].[it_SU_NAM_Subject_Name] ON [dbo].[SU_NAM_Subject_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_NAM_Subject_Name TABLE (
        SU_NAM_SU_ID int not null,
        Metadata_SU_NAM int not null,
        SU_NAM_Positor tinyint not null,
        SU_NAM_PositedAt datetime2 not null,
        SU_NAM_Reliability decimal(5,2) not null,
        SU_NAM_Assertion char(1) not null,
        SU_NAM_Subject_Name nvarchar(42) not null,
        SU_NAM_Version bigint not null,
        SU_NAM_StatementType char(1) not null,
        primary key(
            SU_NAM_Version,
            SU_NAM_Positor,
            SU_NAM_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NAM_SU_ID,
            i.SU_NAM_Positor,
            i.SU_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NAM_Subject_Name_Posit] p
            JOIN
                [dbo].[SU_NAM_Subject_Name_Annex] a
            ON
                a.SU_NAM_ID = p.SU_NAM_ID
            WHERE
                p.SU_NAM_SU_ID = i.SU_NAM_SU_ID
            AND
                p.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
            AND
                a.SU_NAM_Positor = i.SU_NAM_Positor
            AND
                a.SU_NAM_PositedAt = i.SU_NAM_PositedAt
            AND
                a.SU_NAM_Reliability <> i.SU_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NAM_Subject_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_NAM_Subject_Name
    SELECT
        i.SU_NAM_SU_ID,
        i.Metadata_SU_NAM,
        i.SU_NAM_Positor,
        i.SU_NAM_PositedAt,
        i.SU_NAM_Reliability,
        case
            when i.SU_NAM_Reliability > 0 then '+'
            when i.SU_NAM_Reliability = 0 then '?'
            when i.SU_NAM_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_NAM_Subject_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_NAM_Positor,
                i.SU_NAM_SU_ID
            ORDER BY
                i.SU_NAM_PositedAt ASC,
                i.SU_NAM_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_NAM_Subject_Name_Posit] p
        JOIN
            [dbo].[SU_NAM_Subject_Name_Annex] a
        ON
            a.SU_NAM_ID = p.SU_NAM_ID
        WHERE
            p.SU_NAM_SU_ID = i.SU_NAM_SU_ID
        AND
            p.SU_NAM_Subject_Name = i.SU_NAM_Subject_Name
        AND
            a.SU_NAM_Positor = i.SU_NAM_Positor
        AND
            a.SU_NAM_PositedAt = i.SU_NAM_PositedAt
    );
    SELECT
        @maxVersion = max(SU_NAM_Version),
        @currentVersion = 0
    FROM
        @SU_NAM_Subject_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_NAM_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_NAM_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_NAM_Positor, DEFAULT, v.SU_NAM_PositedAt, v.SU_NAM_Assertion) t
                        WHERE
                            t.SU_NAM_SU_ID = v.SU_NAM_SU_ID
                        AND
                            t.SU_NAM_Reliability = v.SU_NAM_Reliability
                        AND
                            t.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_NAM_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_NAM_Subject_Name v
        LEFT JOIN
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_SU_ID = v.SU_NAM_SU_ID
        AND
            p.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
        WHERE
            v.SU_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[SU_NAM_Subject_Name_Posit] (
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        )
        SELECT
            v.SU_NAM_SU_ID,
            v.SU_NAM_Subject_Name
        FROM
            @SU_NAM_Subject_Name v
        WHERE
            v.SU_NAM_Version = @currentVersion
        AND
            v.SU_NAM_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_NAM_Subject_Name w
            WHERE
                w.SU_NAM_Version = v.SU_NAM_Version
            AND
                w.SU_NAM_Positor < v.SU_NAM_Positor
            AND
                w.SU_NAM_SU_ID = v.SU_NAM_SU_ID
            AND
                w.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
            AND
                w.SU_NAM_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_NAM_Subject_Name_Annex] (
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_Positor,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
        )
        SELECT
            v.Metadata_SU_NAM,
            p.SU_NAM_ID,
            v.SU_NAM_Positor,
            v.SU_NAM_PositedAt,
            v.SU_NAM_Reliability
        FROM
            @SU_NAM_Subject_Name v
        JOIN
            [dbo].[SU_NAM_Subject_Name_Posit] p
        ON
            p.SU_NAM_SU_ID = v.SU_NAM_SU_ID
        AND
            p.SU_NAM_Subject_Name = v.SU_NAM_Subject_Name
        WHERE
            v.SU_NAM_Version = @currentVersion
        AND
            SU_NAM_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [dbo].[SU_NAM_Subject_Name_Annex] (
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_Positor,
            SU_NAM_PositedAt,
            SU_NAM_Reliability
        )
        SELECT
            v.Metadata_SU_NAM,
            e.SU_NAM_ID,
            v.SU_NAM_Positor,
            v.SU_NAM_PositedAt,
            0
        FROM
            @SU_NAM_Subject_Name v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_NAM_ID,
                p.SU_NAM_Subject_Name
            FROM
                [dbo].[SU_NAM_Subject_Name_Posit] p
            JOIN
                [dbo].[SU_NAM_Subject_Name_Annex] a
            ON
                a.SU_NAM_ID = p.SU_NAM_ID
            AND
                a.SU_NAM_Positor = v.SU_NAM_Positor
            AND
                a.SU_NAM_PositedAt = (
                    SELECT
                        max(s.SU_NAM_PositedAt)
                    FROM
                        [dbo].[SU_NAM_Subject_Name_Annex] s
                    WHERE
                        s.SU_NAM_ID = p.SU_NAM_ID
                    AND
                        s.SU_NAM_Positor = v.SU_NAM_Positor
                    AND
                        s.SU_NAM_PositedAt < v.SU_NAM_PositedAt
                )
            WHERE
                p.SU_NAM_SU_ID = v.SU_NAM_SU_ID
            AND
                a.SU_NAM_Reliability > 0
            ORDER BY
                a.SU_NAM_PositedAt DESC,
                a.SU_NAM_Reliability DESC
        ) e
        WHERE
            v.SU_NAM_Version = @currentVersion
        AND
            v.SU_NAM_StatementType in ('S','N','D')
        AND
            v.SU_NAM_Reliability > 0
        AND
            e.SU_NAM_Subject_Name <> v.SU_NAM_Subject_Name
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NAM_Subject_Name_Annex] x
            WHERE
                x.SU_NAM_ID = e.SU_NAM_ID
            AND
                x.SU_NAM_Positor = v.SU_NAM_Positor
            AND
                x.SU_NAM_PositedAt = v.SU_NAM_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code instead of INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_COD_Subject_Code', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_COD_Subject_Code];
GO
CREATE TRIGGER [dbo].[it_SU_COD_Subject_Code] ON [dbo].[SU_COD_Subject_Code]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_COD_Subject_Code TABLE (
        SU_COD_SU_ID int not null,
        Metadata_SU_COD int not null,
        SU_COD_Positor tinyint not null,
        SU_COD_PositedAt datetime2 not null,
        SU_COD_Reliability decimal(5,2) not null,
        SU_COD_Assertion char(1) not null,
        SU_COD_Subject_Code nvarchar(42) not null,
        SU_COD_Version bigint not null,
        SU_COD_StatementType char(1) not null,
        primary key(
            SU_COD_Version,
            SU_COD_Positor,
            SU_COD_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_COD_SU_ID,
            i.SU_COD_Positor,
            i.SU_COD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_COD_Subject_Code_Posit] p
            JOIN
                [dbo].[SU_COD_Subject_Code_Annex] a
            ON
                a.SU_COD_ID = p.SU_COD_ID
            WHERE
                p.SU_COD_SU_ID = i.SU_COD_SU_ID
            AND
                p.SU_COD_Subject_Code = i.SU_COD_Subject_Code
            AND
                a.SU_COD_Positor = i.SU_COD_Positor
            AND
                a.SU_COD_PositedAt = i.SU_COD_PositedAt
            AND
                a.SU_COD_Reliability <> i.SU_COD_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_COD_Subject_Code for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_COD_Subject_Code
    SELECT
        i.SU_COD_SU_ID,
        i.Metadata_SU_COD,
        i.SU_COD_Positor,
        i.SU_COD_PositedAt,
        i.SU_COD_Reliability,
        case
            when i.SU_COD_Reliability > 0 then '+'
            when i.SU_COD_Reliability = 0 then '?'
            when i.SU_COD_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_COD_Subject_Code,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_COD_Positor,
                i.SU_COD_SU_ID
            ORDER BY
                i.SU_COD_PositedAt ASC,
                i.SU_COD_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_COD_Subject_Code_Posit] p
        JOIN
            [dbo].[SU_COD_Subject_Code_Annex] a
        ON
            a.SU_COD_ID = p.SU_COD_ID
        WHERE
            p.SU_COD_SU_ID = i.SU_COD_SU_ID
        AND
            p.SU_COD_Subject_Code = i.SU_COD_Subject_Code
        AND
            a.SU_COD_Positor = i.SU_COD_Positor
        AND
            a.SU_COD_PositedAt = i.SU_COD_PositedAt
    );
    SELECT
        @maxVersion = max(SU_COD_Version),
        @currentVersion = 0
    FROM
        @SU_COD_Subject_Code;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_COD_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_COD_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_COD_Positor, DEFAULT, v.SU_COD_PositedAt, v.SU_COD_Assertion) t
                        WHERE
                            t.SU_COD_SU_ID = v.SU_COD_SU_ID
                        AND
                            t.SU_COD_Reliability = v.SU_COD_Reliability
                        AND
                            t.SU_COD_Subject_Code = v.SU_COD_Subject_Code
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_COD_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_COD_Subject_Code v
        LEFT JOIN
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_SU_ID = v.SU_COD_SU_ID
        AND
            p.SU_COD_Subject_Code = v.SU_COD_Subject_Code
        WHERE
            v.SU_COD_Version = @currentVersion;
        INSERT INTO [dbo].[SU_COD_Subject_Code_Posit] (
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        )
        SELECT
            v.SU_COD_SU_ID,
            v.SU_COD_Subject_Code
        FROM
            @SU_COD_Subject_Code v
        WHERE
            v.SU_COD_Version = @currentVersion
        AND
            v.SU_COD_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_COD_Subject_Code w
            WHERE
                w.SU_COD_Version = v.SU_COD_Version
            AND
                w.SU_COD_Positor < v.SU_COD_Positor
            AND
                w.SU_COD_SU_ID = v.SU_COD_SU_ID
            AND
                w.SU_COD_Subject_Code = v.SU_COD_Subject_Code
            AND
                w.SU_COD_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_COD_Subject_Code_Annex] (
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_Positor,
            SU_COD_PositedAt,
            SU_COD_Reliability
        )
        SELECT
            v.Metadata_SU_COD,
            p.SU_COD_ID,
            v.SU_COD_Positor,
            v.SU_COD_PositedAt,
            v.SU_COD_Reliability
        FROM
            @SU_COD_Subject_Code v
        JOIN
            [dbo].[SU_COD_Subject_Code_Posit] p
        ON
            p.SU_COD_SU_ID = v.SU_COD_SU_ID
        AND
            p.SU_COD_Subject_Code = v.SU_COD_Subject_Code
        WHERE
            v.SU_COD_Version = @currentVersion
        AND
            SU_COD_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [dbo].[SU_COD_Subject_Code_Annex] (
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_Positor,
            SU_COD_PositedAt,
            SU_COD_Reliability
        )
        SELECT
            v.Metadata_SU_COD,
            e.SU_COD_ID,
            v.SU_COD_Positor,
            v.SU_COD_PositedAt,
            0
        FROM
            @SU_COD_Subject_Code v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_COD_ID,
                p.SU_COD_Subject_Code
            FROM
                [dbo].[SU_COD_Subject_Code_Posit] p
            JOIN
                [dbo].[SU_COD_Subject_Code_Annex] a
            ON
                a.SU_COD_ID = p.SU_COD_ID
            AND
                a.SU_COD_Positor = v.SU_COD_Positor
            AND
                a.SU_COD_PositedAt = (
                    SELECT
                        max(s.SU_COD_PositedAt)
                    FROM
                        [dbo].[SU_COD_Subject_Code_Annex] s
                    WHERE
                        s.SU_COD_ID = p.SU_COD_ID
                    AND
                        s.SU_COD_Positor = v.SU_COD_Positor
                    AND
                        s.SU_COD_PositedAt < v.SU_COD_PositedAt
                )
            WHERE
                p.SU_COD_SU_ID = v.SU_COD_SU_ID
            AND
                a.SU_COD_Reliability > 0
            ORDER BY
                a.SU_COD_PositedAt DESC,
                a.SU_COD_Reliability DESC
        ) e
        WHERE
            v.SU_COD_Version = @currentVersion
        AND
            v.SU_COD_StatementType in ('S','N','D')
        AND
            v.SU_COD_Reliability > 0
        AND
            e.SU_COD_Subject_Code <> v.SU_COD_Subject_Code
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_COD_Subject_Code_Annex] x
            WHERE
                x.SU_COD_ID = e.SU_COD_ID
            AND
                x.SU_COD_Positor = v.SU_COD_Positor
            AND
                x.SU_COD_PositedAt = v.SU_COD_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade instead of INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_GRD_Subject_Grade', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_GRD_Subject_Grade];
GO
CREATE TRIGGER [dbo].[it_SU_GRD_Subject_Grade] ON [dbo].[SU_GRD_Subject_Grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_GRD_Subject_Grade TABLE (
        SU_GRD_SU_ID int not null,
        Metadata_SU_GRD int not null,
        SU_GRD_Positor tinyint not null,
        SU_GRD_PositedAt datetime2 not null,
        SU_GRD_Reliability decimal(5,2) not null,
        SU_GRD_Assertion char(1) not null,
        SU_GRD_GRD_ID tinyint not null,
        SU_GRD_Version bigint not null,
        SU_GRD_StatementType char(1) not null,
        primary key(
            SU_GRD_Version,
            SU_GRD_Positor,
            SU_GRD_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_GRD_SU_ID,
            i.SU_GRD_Positor,
            i.SU_GRD_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_GRD_Subject_Grade_Posit] p
            JOIN
                [dbo].[SU_GRD_Subject_Grade_Annex] a
            ON
                a.SU_GRD_ID = p.SU_GRD_ID
            WHERE
                p.SU_GRD_SU_ID = i.SU_GRD_SU_ID
            AND
                p.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
            AND
                a.SU_GRD_Positor = i.SU_GRD_Positor
            AND
                a.SU_GRD_PositedAt = i.SU_GRD_PositedAt
            AND
                a.SU_GRD_Reliability <> i.SU_GRD_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_GRD_Subject_Grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_GRD_Subject_Grade
    SELECT
        i.SU_GRD_SU_ID,
        i.Metadata_SU_GRD,
        i.SU_GRD_Positor,
        i.SU_GRD_PositedAt,
        i.SU_GRD_Reliability,
        case
            when i.SU_GRD_Reliability > 0 then '+'
            when i.SU_GRD_Reliability = 0 then '?'
            when i.SU_GRD_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_GRD_GRD_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_GRD_Positor,
                i.SU_GRD_SU_ID
            ORDER BY
                i.SU_GRD_PositedAt ASC,
                i.SU_GRD_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Annex] a
        ON
            a.SU_GRD_ID = p.SU_GRD_ID
        WHERE
            p.SU_GRD_SU_ID = i.SU_GRD_SU_ID
        AND
            p.SU_GRD_GRD_ID = i.SU_GRD_GRD_ID
        AND
            a.SU_GRD_Positor = i.SU_GRD_Positor
        AND
            a.SU_GRD_PositedAt = i.SU_GRD_PositedAt
    );
    SELECT
        @maxVersion = max(SU_GRD_Version),
        @currentVersion = 0
    FROM
        @SU_GRD_Subject_Grade;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_GRD_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_GRD_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_GRD_Positor, DEFAULT, v.SU_GRD_PositedAt, v.SU_GRD_Assertion) t
                        WHERE
                            t.SU_GRD_SU_ID = v.SU_GRD_SU_ID
                        AND
                            t.SU_GRD_Reliability = v.SU_GRD_Reliability
                        AND
                            t.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_GRD_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_GRD_Subject_Grade v
        LEFT JOIN
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_SU_ID = v.SU_GRD_SU_ID
        AND
            p.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
        WHERE
            v.SU_GRD_Version = @currentVersion;
        INSERT INTO [dbo].[SU_GRD_Subject_Grade_Posit] (
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        )
        SELECT
            v.SU_GRD_SU_ID,
            v.SU_GRD_GRD_ID
        FROM
            @SU_GRD_Subject_Grade v
        WHERE
            v.SU_GRD_Version = @currentVersion
        AND
            v.SU_GRD_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_GRD_Subject_Grade w
            WHERE
                w.SU_GRD_Version = v.SU_GRD_Version
            AND
                w.SU_GRD_Positor < v.SU_GRD_Positor
            AND
                w.SU_GRD_SU_ID = v.SU_GRD_SU_ID
            AND
                w.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
            AND
                w.SU_GRD_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_GRD_Subject_Grade_Annex] (
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_Positor,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
        )
        SELECT
            v.Metadata_SU_GRD,
            p.SU_GRD_ID,
            v.SU_GRD_Positor,
            v.SU_GRD_PositedAt,
            v.SU_GRD_Reliability
        FROM
            @SU_GRD_Subject_Grade v
        JOIN
            [dbo].[SU_GRD_Subject_Grade_Posit] p
        ON
            p.SU_GRD_SU_ID = v.SU_GRD_SU_ID
        AND
            p.SU_GRD_GRD_ID = v.SU_GRD_GRD_ID
        WHERE
            v.SU_GRD_Version = @currentVersion
        AND
            SU_GRD_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [dbo].[SU_GRD_Subject_Grade_Annex] (
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_Positor,
            SU_GRD_PositedAt,
            SU_GRD_Reliability
        )
        SELECT
            v.Metadata_SU_GRD,
            e.SU_GRD_ID,
            v.SU_GRD_Positor,
            v.SU_GRD_PositedAt,
            0
        FROM
            @SU_GRD_Subject_Grade v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_GRD_ID,
                p.SU_GRD_GRD_ID
            FROM
                [dbo].[SU_GRD_Subject_Grade_Posit] p
            JOIN
                [dbo].[SU_GRD_Subject_Grade_Annex] a
            ON
                a.SU_GRD_ID = p.SU_GRD_ID
            AND
                a.SU_GRD_Positor = v.SU_GRD_Positor
            AND
                a.SU_GRD_PositedAt = (
                    SELECT
                        max(s.SU_GRD_PositedAt)
                    FROM
                        [dbo].[SU_GRD_Subject_Grade_Annex] s
                    WHERE
                        s.SU_GRD_ID = p.SU_GRD_ID
                    AND
                        s.SU_GRD_Positor = v.SU_GRD_Positor
                    AND
                        s.SU_GRD_PositedAt < v.SU_GRD_PositedAt
                )
            WHERE
                p.SU_GRD_SU_ID = v.SU_GRD_SU_ID
            AND
                a.SU_GRD_Reliability > 0
            ORDER BY
                a.SU_GRD_PositedAt DESC,
                a.SU_GRD_Reliability DESC
        ) e
        WHERE
            v.SU_GRD_Version = @currentVersion
        AND
            v.SU_GRD_StatementType in ('S','N','D')
        AND
            v.SU_GRD_Reliability > 0
        AND
            e.SU_GRD_GRD_ID <> v.SU_GRD_GRD_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_GRD_Subject_Grade_Annex] x
            WHERE
                x.SU_GRD_ID = e.SU_GRD_ID
            AND
                x.SU_GRD_Positor = v.SU_GRD_Positor
            AND
                x.SU_GRD_PositedAt = v.SU_GRD_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note instead of INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_NOT_Subject_Note', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_NOT_Subject_Note];
GO
CREATE TRIGGER [dbo].[it_SU_NOT_Subject_Note] ON [dbo].[SU_NOT_Subject_Note]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_NOT_Subject_Note TABLE (
        SU_NOT_SU_ID int not null,
        Metadata_SU_NOT int not null,
        SU_NOT_Positor tinyint not null,
        SU_NOT_PositedAt datetime2 not null,
        SU_NOT_Reliability decimal(5,2) not null,
        SU_NOT_Assertion char(1) not null,
        SU_NOT_Subject_Note nvarchar(max) not null,
        SU_NOT_Checksum varbinary(16) not null,
        SU_NOT_Version bigint not null,
        SU_NOT_StatementType char(1) not null,
        primary key(
            SU_NOT_Version,
            SU_NOT_Positor,
            SU_NOT_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_NOT_SU_ID,
            i.SU_NOT_Positor,
            i.SU_NOT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NOT_Subject_Note_Posit] p
            JOIN
                [dbo].[SU_NOT_Subject_Note_Annex] a
            ON
                a.SU_NOT_ID = p.SU_NOT_ID
            WHERE
                p.SU_NOT_SU_ID = i.SU_NOT_SU_ID
            AND
                p.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
            AND
                a.SU_NOT_Positor = i.SU_NOT_Positor
            AND
                a.SU_NOT_PositedAt = i.SU_NOT_PositedAt
            AND
                a.SU_NOT_Reliability <> i.SU_NOT_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_NOT_Subject_Note for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_NOT_Subject_Note
    SELECT
        i.SU_NOT_SU_ID,
        i.Metadata_SU_NOT,
        i.SU_NOT_Positor,
        i.SU_NOT_PositedAt,
        i.SU_NOT_Reliability,
        case
            when i.SU_NOT_Reliability > 0 then '+'
            when i.SU_NOT_Reliability = 0 then '?'
            when i.SU_NOT_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_NOT_Subject_Note,
        dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_NOT_Positor,
                i.SU_NOT_SU_ID
            ORDER BY
                i.SU_NOT_PositedAt ASC,
                i.SU_NOT_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_NOT_Subject_Note_Posit] p
        JOIN
            [dbo].[SU_NOT_Subject_Note_Annex] a
        ON
            a.SU_NOT_ID = p.SU_NOT_ID
        WHERE
            p.SU_NOT_SU_ID = i.SU_NOT_SU_ID
        AND
            p.SU_NOT_Checksum = dbo.MD5(cast(i.SU_NOT_Subject_Note as varbinary(max)))
        AND
            a.SU_NOT_Positor = i.SU_NOT_Positor
        AND
            a.SU_NOT_PositedAt = i.SU_NOT_PositedAt
    );
    SELECT
        @maxVersion = max(SU_NOT_Version),
        @currentVersion = 0
    FROM
        @SU_NOT_Subject_Note;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_NOT_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_NOT_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_NOT_Positor, DEFAULT, v.SU_NOT_PositedAt, v.SU_NOT_Assertion) t
                        WHERE
                            t.SU_NOT_SU_ID = v.SU_NOT_SU_ID
                        AND
                            t.SU_NOT_Reliability = v.SU_NOT_Reliability
                        AND
                            t.SU_NOT_Checksum = v.SU_NOT_Checksum
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_NOT_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_NOT_Subject_Note v
        LEFT JOIN
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_SU_ID = v.SU_NOT_SU_ID
        AND
            p.SU_NOT_Checksum = v.SU_NOT_Checksum
        WHERE
            v.SU_NOT_Version = @currentVersion;
        INSERT INTO [dbo].[SU_NOT_Subject_Note_Posit] (
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        )
        SELECT
            v.SU_NOT_SU_ID,
            v.SU_NOT_Subject_Note
        FROM
            @SU_NOT_Subject_Note v
        WHERE
            v.SU_NOT_Version = @currentVersion
        AND
            v.SU_NOT_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_NOT_Subject_Note w
            WHERE
                w.SU_NOT_Version = v.SU_NOT_Version
            AND
                w.SU_NOT_Positor < v.SU_NOT_Positor
            AND
                w.SU_NOT_SU_ID = v.SU_NOT_SU_ID
            AND
                w.SU_NOT_Checksum = v.SU_NOT_Checksum
            AND
                w.SU_NOT_StatementType in ('N')
        );
        INSERT INTO [dbo].[SU_NOT_Subject_Note_Annex] (
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_Positor,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
        )
        SELECT
            v.Metadata_SU_NOT,
            p.SU_NOT_ID,
            v.SU_NOT_Positor,
            v.SU_NOT_PositedAt,
            v.SU_NOT_Reliability
        FROM
            @SU_NOT_Subject_Note v
        JOIN
            [dbo].[SU_NOT_Subject_Note_Posit] p
        ON
            p.SU_NOT_SU_ID = v.SU_NOT_SU_ID
        AND
            p.SU_NOT_Checksum = v.SU_NOT_Checksum
        WHERE
            v.SU_NOT_Version = @currentVersion
        AND
            SU_NOT_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [dbo].[SU_NOT_Subject_Note_Annex] (
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_Positor,
            SU_NOT_PositedAt,
            SU_NOT_Reliability
        )
        SELECT
            v.Metadata_SU_NOT,
            e.SU_NOT_ID,
            v.SU_NOT_Positor,
            v.SU_NOT_PositedAt,
            0
        FROM
            @SU_NOT_Subject_Note v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_NOT_ID,
                p.SU_NOT_Checksum
            FROM
                [dbo].[SU_NOT_Subject_Note_Posit] p
            JOIN
                [dbo].[SU_NOT_Subject_Note_Annex] a
            ON
                a.SU_NOT_ID = p.SU_NOT_ID
            AND
                a.SU_NOT_Positor = v.SU_NOT_Positor
            AND
                a.SU_NOT_PositedAt = (
                    SELECT
                        max(s.SU_NOT_PositedAt)
                    FROM
                        [dbo].[SU_NOT_Subject_Note_Annex] s
                    WHERE
                        s.SU_NOT_ID = p.SU_NOT_ID
                    AND
                        s.SU_NOT_Positor = v.SU_NOT_Positor
                    AND
                        s.SU_NOT_PositedAt < v.SU_NOT_PositedAt
                )
            WHERE
                p.SU_NOT_SU_ID = v.SU_NOT_SU_ID
            AND
                a.SU_NOT_Reliability > 0
            ORDER BY
                a.SU_NOT_PositedAt DESC,
                a.SU_NOT_Reliability DESC
        ) e
        WHERE
            v.SU_NOT_Version = @currentVersion
        AND
            v.SU_NOT_StatementType in ('S','N','D')
        AND
            v.SU_NOT_Reliability > 0
        AND
            e.SU_NOT_Checksum <> v.SU_NOT_Checksum
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_NOT_Subject_Note_Annex] x
            WHERE
                x.SU_NOT_ID = e.SU_NOT_ID
            AND
                x.SU_NOT_Positor = v.SU_NOT_Positor
            AND
                x.SU_NOT_PositedAt = v.SU_NOT_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title instead of INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TTL_Subject_Title', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TTL_Subject_Title];
GO
CREATE TRIGGER [dbo].[it_SU_TTL_Subject_Title] ON [dbo].[SU_TTL_Subject_Title]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_TTL_Subject_Title TABLE (
        SU_TTL_SU_ID int not null,
        Metadata_SU_TTL int not null,
        SU_TTL_ChangedAt datetime2 not null,
        SU_TTL_Positor tinyint not null,
        SU_TTL_PositedAt datetime2 not null,
        SU_TTL_Reliability decimal(5,2) not null,
        SU_TTL_Assertion char(1) not null,
        SU_TTL_Subject_Title nvarchar(42) not null,
        SU_TTL_Version bigint not null,
        SU_TTL_StatementType char(1) not null,
        primary key(
            SU_TTL_Version,
            SU_TTL_Positor,
            SU_TTL_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TTL_SU_ID,
            i.SU_TTL_ChangedAt,
            i.SU_TTL_Positor,
            i.SU_TTL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TTL_Subject_Title_Posit] p
            JOIN
                [dbo].[SU_TTL_Subject_Title_Annex] a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            WHERE
                p.SU_TTL_SU_ID = i.SU_TTL_SU_ID
            AND
                p.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
            AND
                p.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
            AND
                a.SU_TTL_Positor = i.SU_TTL_Positor
            AND
                a.SU_TTL_PositedAt = i.SU_TTL_PositedAt
            AND
                a.SU_TTL_Reliability <> i.SU_TTL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TTL_Subject_Title for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TTL_Subject_Title
    SELECT
        i.SU_TTL_SU_ID,
        i.Metadata_SU_TTL,
        i.SU_TTL_ChangedAt,
        i.SU_TTL_Positor,
        i.SU_TTL_PositedAt,
        i.SU_TTL_Reliability,
        case
            when i.SU_TTL_Reliability > 0 then '+'
            when i.SU_TTL_Reliability = 0 then '?'
            when i.SU_TTL_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_TTL_Subject_Title,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_TTL_Positor,
                i.SU_TTL_SU_ID
            ORDER BY
                i.SU_TTL_ChangedAt ASC,
                i.SU_TTL_PositedAt ASC,
                i.SU_TTL_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TTL_Subject_Title_Posit] p
        JOIN
            [dbo].[SU_TTL_Subject_Title_Annex] a
        ON
            a.SU_TTL_ID = p.SU_TTL_ID
        WHERE
            p.SU_TTL_SU_ID = i.SU_TTL_SU_ID
        AND
            p.SU_TTL_ChangedAt = i.SU_TTL_ChangedAt
        AND
            p.SU_TTL_Subject_Title = i.SU_TTL_Subject_Title
        AND
            a.SU_TTL_Positor = i.SU_TTL_Positor
        AND
            a.SU_TTL_PositedAt = i.SU_TTL_PositedAt
    );
    SELECT
        @maxVersion = max(SU_TTL_Version),
        @currentVersion = 0
    FROM
        @SU_TTL_Subject_Title;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_TTL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_TTL_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_TTL_Positor, v.SU_TTL_ChangedAt, v.SU_TTL_PositedAt, v.SU_TTL_Assertion) t
                        WHERE
                            t.SU_TTL_SU_ID = v.SU_TTL_SU_ID
                        AND
                            t.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
                        AND
                            t.SU_TTL_Reliability = v.SU_TTL_Reliability
                        AND
                            t.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_TTL_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_TTL_Subject_Title
                        WHERE
                            v.SU_TTL_Subject_Title =
                                dbo.preSU_TTL_Subject_Title (
                                    v.SU_TTL_SU_ID,
                                    v.SU_TTL_Positor,
                                    v.SU_TTL_ChangedAt,
                                    v.SU_TTL_PositedAt,
                                    v.SU_TTL_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_TTL_Subject_Title
                        WHERE
                            v.SU_TTL_Subject_Title =
                                dbo.folSU_TTL_Subject_Title (
                                    v.SU_TTL_SU_ID,
                                    v.SU_TTL_Positor,
                                    v.SU_TTL_ChangedAt,
                                    v.SU_TTL_PositedAt,
                                    v.SU_TTL_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_TTL_Subject_Title v
        LEFT JOIN
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_SU_ID = v.SU_TTL_SU_ID
        AND
            p.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
        AND
            p.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
        WHERE
            v.SU_TTL_Version = @currentVersion;
        INSERT INTO [dbo].[SU_TTL_Subject_Title_Posit] (
            SU_TTL_SU_ID,
            SU_TTL_ChangedAt,
            SU_TTL_Subject_Title
        )
        SELECT
            v.SU_TTL_SU_ID,
            v.SU_TTL_ChangedAt,
            v.SU_TTL_Subject_Title
        FROM
            @SU_TTL_Subject_Title v
        WHERE
            v.SU_TTL_Version = @currentVersion
        AND
            v.SU_TTL_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_TTL_Subject_Title w
            WHERE
                w.SU_TTL_Version = v.SU_TTL_Version
            AND
                w.SU_TTL_Positor < v.SU_TTL_Positor
            AND
                w.SU_TTL_SU_ID = v.SU_TTL_SU_ID
            AND
                w.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
            AND
                w.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
            AND
                w.SU_TTL_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_TTL_Subject_Title_Annex] (
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_Positor,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
        )
        SELECT
            v.Metadata_SU_TTL,
            p.SU_TTL_ID,
            v.SU_TTL_Positor,
            v.SU_TTL_PositedAt,
            v.SU_TTL_Reliability
        FROM
            @SU_TTL_Subject_Title v
        JOIN
            [dbo].[SU_TTL_Subject_Title_Posit] p
        ON
            p.SU_TTL_SU_ID = v.SU_TTL_SU_ID
        AND
            p.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
        AND
            p.SU_TTL_Subject_Title = v.SU_TTL_Subject_Title
        WHERE
            v.SU_TTL_Version = @currentVersion
        AND
            SU_TTL_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_TTL_Subject_Title_Annex] (
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_Positor,
            SU_TTL_PositedAt,
            SU_TTL_Reliability
        )
        SELECT
            v.Metadata_SU_TTL,
            e.SU_TTL_ID,
            v.SU_TTL_Positor,
            v.SU_TTL_PositedAt,
            0
        FROM
            @SU_TTL_Subject_Title v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_TTL_ID,
                p.SU_TTL_Subject_Title
            FROM
                [dbo].[SU_TTL_Subject_Title_Posit] p
            JOIN
                [dbo].[SU_TTL_Subject_Title_Annex] a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            AND
                a.SU_TTL_Positor = v.SU_TTL_Positor
            AND
                a.SU_TTL_PositedAt = (
                    SELECT
                        max(s.SU_TTL_PositedAt)
                    FROM
                        [dbo].[SU_TTL_Subject_Title_Annex] s
                    WHERE
                        s.SU_TTL_ID = p.SU_TTL_ID
                    AND
                        s.SU_TTL_Positor = v.SU_TTL_Positor
                    AND
                        s.SU_TTL_PositedAt < v.SU_TTL_PositedAt
                )
            WHERE
                p.SU_TTL_SU_ID = v.SU_TTL_SU_ID
            AND
                p.SU_TTL_ChangedAt = v.SU_TTL_ChangedAt
            AND
                a.SU_TTL_Reliability > 0
            ORDER BY
                a.SU_TTL_PositedAt DESC,
                a.SU_TTL_Reliability DESC
        ) e
        WHERE
            v.SU_TTL_Version = @currentVersion
        AND
            v.SU_TTL_StatementType in ('S','N','D','R')
        AND
            v.SU_TTL_Reliability > 0
        AND
            e.SU_TTL_Subject_Title <> v.SU_TTL_Subject_Title
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TTL_Subject_Title_Annex] x
            WHERE
                x.SU_TTL_ID = e.SU_TTL_ID
            AND
                x.SU_TTL_Positor = v.SU_TTL_Positor
            AND
                x.SU_TTL_PositedAt = v.SU_TTL_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State instead of INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_STA_Subject_State', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_STA_Subject_State];
GO
CREATE TRIGGER [dbo].[it_SU_STA_Subject_State] ON [dbo].[SU_STA_Subject_State]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_STA_Subject_State TABLE (
        SU_STA_SU_ID int not null,
        Metadata_SU_STA int not null,
        SU_STA_ChangedAt datetime2 not null,
        SU_STA_Positor tinyint not null,
        SU_STA_PositedAt datetime2 not null,
        SU_STA_Reliability decimal(5,2) not null,
        SU_STA_Assertion char(1) not null,
        SU_STA_Subject_State nvarchar(42) not null,
        SU_STA_Version bigint not null,
        SU_STA_StatementType char(1) not null,
        primary key(
            SU_STA_Version,
            SU_STA_Positor,
            SU_STA_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_STA_SU_ID,
            i.SU_STA_ChangedAt,
            i.SU_STA_Positor,
            i.SU_STA_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_STA_Subject_State_Posit] p
            JOIN
                [dbo].[SU_STA_Subject_State_Annex] a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            WHERE
                p.SU_STA_SU_ID = i.SU_STA_SU_ID
            AND
                p.SU_STA_ChangedAt = i.SU_STA_ChangedAt
            AND
                p.SU_STA_Subject_State = i.SU_STA_Subject_State
            AND
                a.SU_STA_Positor = i.SU_STA_Positor
            AND
                a.SU_STA_PositedAt = i.SU_STA_PositedAt
            AND
                a.SU_STA_Reliability <> i.SU_STA_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_STA_Subject_State for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_STA_Subject_State
    SELECT
        i.SU_STA_SU_ID,
        i.Metadata_SU_STA,
        i.SU_STA_ChangedAt,
        i.SU_STA_Positor,
        i.SU_STA_PositedAt,
        i.SU_STA_Reliability,
        case
            when i.SU_STA_Reliability > 0 then '+'
            when i.SU_STA_Reliability = 0 then '?'
            when i.SU_STA_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_STA_Subject_State,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_STA_Positor,
                i.SU_STA_SU_ID
            ORDER BY
                i.SU_STA_ChangedAt ASC,
                i.SU_STA_PositedAt ASC,
                i.SU_STA_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_STA_Subject_State_Posit] p
        JOIN
            [dbo].[SU_STA_Subject_State_Annex] a
        ON
            a.SU_STA_ID = p.SU_STA_ID
        WHERE
            p.SU_STA_SU_ID = i.SU_STA_SU_ID
        AND
            p.SU_STA_ChangedAt = i.SU_STA_ChangedAt
        AND
            p.SU_STA_Subject_State = i.SU_STA_Subject_State
        AND
            a.SU_STA_Positor = i.SU_STA_Positor
        AND
            a.SU_STA_PositedAt = i.SU_STA_PositedAt
    );
    SELECT
        @maxVersion = max(SU_STA_Version),
        @currentVersion = 0
    FROM
        @SU_STA_Subject_State;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_STA_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_STA_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_STA_Positor, v.SU_STA_ChangedAt, v.SU_STA_PositedAt, v.SU_STA_Assertion) t
                        WHERE
                            t.SU_STA_SU_ID = v.SU_STA_SU_ID
                        AND
                            t.SU_STA_ChangedAt = v.SU_STA_ChangedAt
                        AND
                            t.SU_STA_Reliability = v.SU_STA_Reliability
                        AND
                            t.SU_STA_Subject_State = v.SU_STA_Subject_State
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_STA_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_STA_Subject_State
                        WHERE
                            v.SU_STA_Subject_State =
                                dbo.preSU_STA_Subject_State (
                                    v.SU_STA_SU_ID,
                                    v.SU_STA_Positor,
                                    v.SU_STA_ChangedAt,
                                    v.SU_STA_PositedAt,
                                    v.SU_STA_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_STA_Subject_State
                        WHERE
                            v.SU_STA_Subject_State =
                                dbo.folSU_STA_Subject_State (
                                    v.SU_STA_SU_ID,
                                    v.SU_STA_Positor,
                                    v.SU_STA_ChangedAt,
                                    v.SU_STA_PositedAt,
                                    v.SU_STA_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_STA_Subject_State v
        LEFT JOIN
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_SU_ID = v.SU_STA_SU_ID
        AND
            p.SU_STA_ChangedAt = v.SU_STA_ChangedAt
        AND
            p.SU_STA_Subject_State = v.SU_STA_Subject_State
        WHERE
            v.SU_STA_Version = @currentVersion;
        INSERT INTO [dbo].[SU_STA_Subject_State_Posit] (
            SU_STA_SU_ID,
            SU_STA_ChangedAt,
            SU_STA_Subject_State
        )
        SELECT
            v.SU_STA_SU_ID,
            v.SU_STA_ChangedAt,
            v.SU_STA_Subject_State
        FROM
            @SU_STA_Subject_State v
        WHERE
            v.SU_STA_Version = @currentVersion
        AND
            v.SU_STA_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_STA_Subject_State w
            WHERE
                w.SU_STA_Version = v.SU_STA_Version
            AND
                w.SU_STA_Positor < v.SU_STA_Positor
            AND
                w.SU_STA_SU_ID = v.SU_STA_SU_ID
            AND
                w.SU_STA_ChangedAt = v.SU_STA_ChangedAt
            AND
                w.SU_STA_Subject_State = v.SU_STA_Subject_State
            AND
                w.SU_STA_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_STA_Subject_State_Annex] (
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_Positor,
            SU_STA_PositedAt,
            SU_STA_Reliability
        )
        SELECT
            v.Metadata_SU_STA,
            p.SU_STA_ID,
            v.SU_STA_Positor,
            v.SU_STA_PositedAt,
            v.SU_STA_Reliability
        FROM
            @SU_STA_Subject_State v
        JOIN
            [dbo].[SU_STA_Subject_State_Posit] p
        ON
            p.SU_STA_SU_ID = v.SU_STA_SU_ID
        AND
            p.SU_STA_ChangedAt = v.SU_STA_ChangedAt
        AND
            p.SU_STA_Subject_State = v.SU_STA_Subject_State
        WHERE
            v.SU_STA_Version = @currentVersion
        AND
            SU_STA_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_STA_Subject_State_Annex] (
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_Positor,
            SU_STA_PositedAt,
            SU_STA_Reliability
        )
        SELECT
            v.Metadata_SU_STA,
            e.SU_STA_ID,
            v.SU_STA_Positor,
            v.SU_STA_PositedAt,
            0
        FROM
            @SU_STA_Subject_State v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_STA_ID,
                p.SU_STA_Subject_State
            FROM
                [dbo].[SU_STA_Subject_State_Posit] p
            JOIN
                [dbo].[SU_STA_Subject_State_Annex] a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            AND
                a.SU_STA_Positor = v.SU_STA_Positor
            AND
                a.SU_STA_PositedAt = (
                    SELECT
                        max(s.SU_STA_PositedAt)
                    FROM
                        [dbo].[SU_STA_Subject_State_Annex] s
                    WHERE
                        s.SU_STA_ID = p.SU_STA_ID
                    AND
                        s.SU_STA_Positor = v.SU_STA_Positor
                    AND
                        s.SU_STA_PositedAt < v.SU_STA_PositedAt
                )
            WHERE
                p.SU_STA_SU_ID = v.SU_STA_SU_ID
            AND
                p.SU_STA_ChangedAt = v.SU_STA_ChangedAt
            AND
                a.SU_STA_Reliability > 0
            ORDER BY
                a.SU_STA_PositedAt DESC,
                a.SU_STA_Reliability DESC
        ) e
        WHERE
            v.SU_STA_Version = @currentVersion
        AND
            v.SU_STA_StatementType in ('S','N','D','R')
        AND
            v.SU_STA_Reliability > 0
        AND
            e.SU_STA_Subject_State <> v.SU_STA_Subject_State
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_STA_Subject_State_Annex] x
            WHERE
                x.SU_STA_ID = e.SU_STA_ID
            AND
                x.SU_STA_Positor = v.SU_STA_Positor
            AND
                x.SU_STA_PositedAt = v.SU_STA_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label instead of INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LBL_Subject_Label', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LBL_Subject_Label];
GO
CREATE TRIGGER [dbo].[it_SU_LBL_Subject_Label] ON [dbo].[SU_LBL_Subject_Label]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_LBL_Subject_Label TABLE (
        SU_LBL_SU_ID int not null,
        Metadata_SU_LBL int not null,
        SU_LBL_ChangedAt datetime2 not null,
        SU_LBL_Positor tinyint not null,
        SU_LBL_PositedAt datetime2 not null,
        SU_LBL_Reliability decimal(5,2) not null,
        SU_LBL_Assertion char(1) not null,
        SU_LBL_Subject_Label nvarchar(42) not null,
        SU_LBL_Version bigint not null,
        SU_LBL_StatementType char(1) not null,
        primary key(
            SU_LBL_Version,
            SU_LBL_Positor,
            SU_LBL_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LBL_SU_ID,
            i.SU_LBL_ChangedAt,
            i.SU_LBL_Positor,
            i.SU_LBL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LBL_Subject_Label_Posit] p
            JOIN
                [dbo].[SU_LBL_Subject_Label_Annex] a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            WHERE
                p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
            AND
                p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
            AND
                p.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
            AND
                a.SU_LBL_Positor = i.SU_LBL_Positor
            AND
                a.SU_LBL_PositedAt = i.SU_LBL_PositedAt
            AND
                a.SU_LBL_Reliability <> i.SU_LBL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LBL_Subject_Label for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_LBL_Subject_Label
    SELECT
        i.SU_LBL_SU_ID,
        i.Metadata_SU_LBL,
        i.SU_LBL_ChangedAt,
        i.SU_LBL_Positor,
        i.SU_LBL_PositedAt,
        i.SU_LBL_Reliability,
        case
            when i.SU_LBL_Reliability > 0 then '+'
            when i.SU_LBL_Reliability = 0 then '?'
            when i.SU_LBL_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_LBL_Subject_Label,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_LBL_Positor,
                i.SU_LBL_SU_ID
            ORDER BY
                i.SU_LBL_ChangedAt ASC,
                i.SU_LBL_PositedAt ASC,
                i.SU_LBL_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_LBL_Subject_Label_Posit] p
        JOIN
            [dbo].[SU_LBL_Subject_Label_Annex] a
        ON
            a.SU_LBL_ID = p.SU_LBL_ID
        WHERE
            p.SU_LBL_SU_ID = i.SU_LBL_SU_ID
        AND
            p.SU_LBL_ChangedAt = i.SU_LBL_ChangedAt
        AND
            p.SU_LBL_Subject_Label = i.SU_LBL_Subject_Label
        AND
            a.SU_LBL_Positor = i.SU_LBL_Positor
        AND
            a.SU_LBL_PositedAt = i.SU_LBL_PositedAt
    );
    SELECT
        @maxVersion = max(SU_LBL_Version),
        @currentVersion = 0
    FROM
        @SU_LBL_Subject_Label;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_LBL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_LBL_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_LBL_Positor, v.SU_LBL_ChangedAt, v.SU_LBL_PositedAt, v.SU_LBL_Assertion) t
                        WHERE
                            t.SU_LBL_SU_ID = v.SU_LBL_SU_ID
                        AND
                            t.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
                        AND
                            t.SU_LBL_Reliability = v.SU_LBL_Reliability
                        AND
                            t.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_LBL_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_LBL_Subject_Label
                        WHERE
                            v.SU_LBL_Subject_Label =
                                dbo.preSU_LBL_Subject_Label (
                                    v.SU_LBL_SU_ID,
                                    v.SU_LBL_Positor,
                                    v.SU_LBL_ChangedAt,
                                    v.SU_LBL_PositedAt,
                                    v.SU_LBL_Assertion
                                )
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            v.SU_LBL_Subject_Label
                        WHERE
                            v.SU_LBL_Subject_Label =
                                dbo.folSU_LBL_Subject_Label (
                                    v.SU_LBL_SU_ID,
                                    v.SU_LBL_Positor,
                                    v.SU_LBL_ChangedAt,
                                    v.SU_LBL_PositedAt,
                                    v.SU_LBL_Assertion
                                )
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_LBL_Subject_Label v
        LEFT JOIN
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_SU_ID = v.SU_LBL_SU_ID
        AND
            p.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
        AND
            p.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
        WHERE
            v.SU_LBL_Version = @currentVersion;
        INSERT INTO [dbo].[SU_LBL_Subject_Label_Posit] (
            SU_LBL_SU_ID,
            SU_LBL_ChangedAt,
            SU_LBL_Subject_Label
        )
        SELECT
            v.SU_LBL_SU_ID,
            v.SU_LBL_ChangedAt,
            v.SU_LBL_Subject_Label
        FROM
            @SU_LBL_Subject_Label v
        WHERE
            v.SU_LBL_Version = @currentVersion
        AND
            v.SU_LBL_StatementType in ('N','F')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_LBL_Subject_Label w
            WHERE
                w.SU_LBL_Version = v.SU_LBL_Version
            AND
                w.SU_LBL_Positor < v.SU_LBL_Positor
            AND
                w.SU_LBL_SU_ID = v.SU_LBL_SU_ID
            AND
                w.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
            AND
                w.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
            AND
                w.SU_LBL_StatementType in ('N','F')
        );
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
        )
        SELECT
            v.Metadata_SU_LBL,
            fol.SU_LBL_ID,
            v.SU_LBL_Positor,
            v.SU_LBL_PositedAt,
            0
        FROM
            @SU_LBL_Subject_Label v
        CROSS APPLY (
            SELECT TOP 1
                f.SU_LBL_ID,
                f.SU_LBL_Subject_Label
            FROM
                [dbo].[fSU_LBL_Subject_Label](
                    v.SU_LBL_Positor,
                    v.SU_LBL_ChangedAt,
                    v.SU_LBL_PositedAt
                ) f
            WHERE
                f.SU_LBL_SU_ID = v.SU_LBL_SU_ID
            AND
                f.SU_LBL_ChangedAt > v.SU_LBL_ChangedAt
            AND
                f.SU_LBL_Assertion = v.SU_LBL_Assertion
            ORDER BY
                f.SU_LBL_ChangedAt ASC,
                f.SU_LBL_PositedAt DESC
        ) fol
        WHERE
            v.SU_LBL_Version = @currentVersion
        AND
            v.SU_LBL_StatementType = 'F'
        AND
            fol.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label;
        INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
        )
        SELECT
            v.Metadata_SU_LBL,
            p.SU_LBL_ID,
            v.SU_LBL_Positor,
            v.SU_LBL_PositedAt,
            v.SU_LBL_Reliability
        FROM
            @SU_LBL_Subject_Label v
        JOIN
            [dbo].[SU_LBL_Subject_Label_Posit] p
        ON
            p.SU_LBL_SU_ID = v.SU_LBL_SU_ID
        AND
            p.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
        AND
            p.SU_LBL_Subject_Label = v.SU_LBL_Subject_Label
        WHERE
            v.SU_LBL_Version = @currentVersion
        AND
            SU_LBL_StatementType in ('S','N','D','F');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_LBL_Subject_Label_Annex] (
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_Positor,
            SU_LBL_PositedAt,
            SU_LBL_Reliability
        )
        SELECT
            v.Metadata_SU_LBL,
            e.SU_LBL_ID,
            v.SU_LBL_Positor,
            v.SU_LBL_PositedAt,
            0
        FROM
            @SU_LBL_Subject_Label v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_LBL_ID,
                p.SU_LBL_Subject_Label
            FROM
                [dbo].[SU_LBL_Subject_Label_Posit] p
            JOIN
                [dbo].[SU_LBL_Subject_Label_Annex] a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            AND
                a.SU_LBL_Positor = v.SU_LBL_Positor
            AND
                a.SU_LBL_PositedAt = (
                    SELECT
                        max(s.SU_LBL_PositedAt)
                    FROM
                        [dbo].[SU_LBL_Subject_Label_Annex] s
                    WHERE
                        s.SU_LBL_ID = p.SU_LBL_ID
                    AND
                        s.SU_LBL_Positor = v.SU_LBL_Positor
                    AND
                        s.SU_LBL_PositedAt < v.SU_LBL_PositedAt
                )
            WHERE
                p.SU_LBL_SU_ID = v.SU_LBL_SU_ID
            AND
                p.SU_LBL_ChangedAt = v.SU_LBL_ChangedAt
            AND
                a.SU_LBL_Reliability > 0
            ORDER BY
                a.SU_LBL_PositedAt DESC,
                a.SU_LBL_Reliability DESC
        ) e
        WHERE
            v.SU_LBL_Version = @currentVersion
        AND
            v.SU_LBL_StatementType in ('S','N','D','F')
        AND
            v.SU_LBL_Reliability > 0
        AND
            e.SU_LBL_Subject_Label <> v.SU_LBL_Subject_Label
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LBL_Subject_Label_Annex] x
            WHERE
                x.SU_LBL_ID = e.SU_LBL_ID
            AND
                x.SU_LBL_Positor = v.SU_LBL_Positor
            AND
                x.SU_LBL_PositedAt = v.SU_LBL_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag instead of INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TAG_Subject_Tag', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TAG_Subject_Tag];
GO
CREATE TRIGGER [dbo].[it_SU_TAG_Subject_Tag] ON [dbo].[SU_TAG_Subject_Tag]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_TAG_Subject_Tag TABLE (
        SU_TAG_SU_ID int not null,
        Metadata_SU_TAG int not null,
        SU_TAG_ChangedAt datetime2 not null,
        SU_TAG_Positor tinyint not null,
        SU_TAG_PositedAt datetime2 not null,
        SU_TAG_Reliability decimal(5,2) not null,
        SU_TAG_Assertion char(1) not null,
        SU_TAG_Subject_Tag nvarchar(42) not null,
        SU_TAG_Version bigint not null,
        SU_TAG_StatementType char(1) not null,
        primary key(
            SU_TAG_Version,
            SU_TAG_Positor,
            SU_TAG_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TAG_SU_ID,
            i.SU_TAG_ChangedAt,
            i.SU_TAG_Positor,
            i.SU_TAG_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TAG_Subject_Tag_Posit] p
            JOIN
                [dbo].[SU_TAG_Subject_Tag_Annex] a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            WHERE
                p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
            AND
                p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
            AND
                p.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
            AND
                a.SU_TAG_Positor = i.SU_TAG_Positor
            AND
                a.SU_TAG_PositedAt = i.SU_TAG_PositedAt
            AND
                a.SU_TAG_Reliability <> i.SU_TAG_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TAG_Subject_Tag for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TAG_Subject_Tag
    SELECT
        i.SU_TAG_SU_ID,
        i.Metadata_SU_TAG,
        i.SU_TAG_ChangedAt,
        i.SU_TAG_Positor,
        i.SU_TAG_PositedAt,
        i.SU_TAG_Reliability,
        case
            when i.SU_TAG_Reliability > 0 then '+'
            when i.SU_TAG_Reliability = 0 then '?'
            when i.SU_TAG_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_TAG_Subject_Tag,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_TAG_Positor,
                i.SU_TAG_SU_ID
            ORDER BY
                i.SU_TAG_ChangedAt ASC,
                i.SU_TAG_PositedAt ASC,
                i.SU_TAG_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Annex] a
        ON
            a.SU_TAG_ID = p.SU_TAG_ID
        WHERE
            p.SU_TAG_SU_ID = i.SU_TAG_SU_ID
        AND
            p.SU_TAG_ChangedAt = i.SU_TAG_ChangedAt
        AND
            p.SU_TAG_Subject_Tag = i.SU_TAG_Subject_Tag
        AND
            a.SU_TAG_Positor = i.SU_TAG_Positor
        AND
            a.SU_TAG_PositedAt = i.SU_TAG_PositedAt
    );
    SELECT
        @maxVersion = max(SU_TAG_Version),
        @currentVersion = 0
    FROM
        @SU_TAG_Subject_Tag;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_TAG_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_TAG_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_TAG_Positor, v.SU_TAG_ChangedAt, v.SU_TAG_PositedAt, v.SU_TAG_Assertion) t
                        WHERE
                            t.SU_TAG_SU_ID = v.SU_TAG_SU_ID
                        AND
                            t.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
                        AND
                            t.SU_TAG_Reliability = v.SU_TAG_Reliability
                        AND
                            t.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_TAG_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_TAG_Subject_Tag
                        WHERE
                            v.SU_TAG_Subject_Tag =
                                dbo.preSU_TAG_Subject_Tag (
                                    v.SU_TAG_SU_ID,
                                    v.SU_TAG_Positor,
                                    v.SU_TAG_ChangedAt,
                                    v.SU_TAG_PositedAt,
                                    v.SU_TAG_Assertion
                                )
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            v.SU_TAG_Subject_Tag
                        WHERE
                            v.SU_TAG_Subject_Tag =
                                dbo.folSU_TAG_Subject_Tag (
                                    v.SU_TAG_SU_ID,
                                    v.SU_TAG_Positor,
                                    v.SU_TAG_ChangedAt,
                                    v.SU_TAG_PositedAt,
                                    v.SU_TAG_Assertion
                                )
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_TAG_Subject_Tag v
        LEFT JOIN
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_SU_ID = v.SU_TAG_SU_ID
        AND
            p.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
        AND
            p.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
        WHERE
            v.SU_TAG_Version = @currentVersion;
        INSERT INTO [dbo].[SU_TAG_Subject_Tag_Posit] (
            SU_TAG_SU_ID,
            SU_TAG_ChangedAt,
            SU_TAG_Subject_Tag
        )
        SELECT
            v.SU_TAG_SU_ID,
            v.SU_TAG_ChangedAt,
            v.SU_TAG_Subject_Tag
        FROM
            @SU_TAG_Subject_Tag v
        WHERE
            v.SU_TAG_Version = @currentVersion
        AND
            v.SU_TAG_StatementType in ('N','F')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_TAG_Subject_Tag w
            WHERE
                w.SU_TAG_Version = v.SU_TAG_Version
            AND
                w.SU_TAG_Positor < v.SU_TAG_Positor
            AND
                w.SU_TAG_SU_ID = v.SU_TAG_SU_ID
            AND
                w.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
            AND
                w.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
            AND
                w.SU_TAG_StatementType in ('N','F')
        );
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
        )
        SELECT
            v.Metadata_SU_TAG,
            fol.SU_TAG_ID,
            v.SU_TAG_Positor,
            v.SU_TAG_PositedAt,
            0
        FROM
            @SU_TAG_Subject_Tag v
        CROSS APPLY (
            SELECT TOP 1
                f.SU_TAG_ID,
                f.SU_TAG_Subject_Tag
            FROM
                [dbo].[fSU_TAG_Subject_Tag](
                    v.SU_TAG_Positor,
                    v.SU_TAG_ChangedAt,
                    v.SU_TAG_PositedAt
                ) f
            WHERE
                f.SU_TAG_SU_ID = v.SU_TAG_SU_ID
            AND
                f.SU_TAG_ChangedAt > v.SU_TAG_ChangedAt
            AND
                f.SU_TAG_Assertion = v.SU_TAG_Assertion
            ORDER BY
                f.SU_TAG_ChangedAt ASC,
                f.SU_TAG_PositedAt DESC
        ) fol
        WHERE
            v.SU_TAG_Version = @currentVersion
        AND
            v.SU_TAG_StatementType = 'F'
        AND
            fol.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag;
        INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
        )
        SELECT
            v.Metadata_SU_TAG,
            p.SU_TAG_ID,
            v.SU_TAG_Positor,
            v.SU_TAG_PositedAt,
            v.SU_TAG_Reliability
        FROM
            @SU_TAG_Subject_Tag v
        JOIN
            [dbo].[SU_TAG_Subject_Tag_Posit] p
        ON
            p.SU_TAG_SU_ID = v.SU_TAG_SU_ID
        AND
            p.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
        AND
            p.SU_TAG_Subject_Tag = v.SU_TAG_Subject_Tag
        WHERE
            v.SU_TAG_Version = @currentVersion
        AND
            SU_TAG_StatementType in ('S','N','D','F');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_TAG_Subject_Tag_Annex] (
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_Positor,
            SU_TAG_PositedAt,
            SU_TAG_Reliability
        )
        SELECT
            v.Metadata_SU_TAG,
            e.SU_TAG_ID,
            v.SU_TAG_Positor,
            v.SU_TAG_PositedAt,
            0
        FROM
            @SU_TAG_Subject_Tag v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_TAG_ID,
                p.SU_TAG_Subject_Tag
            FROM
                [dbo].[SU_TAG_Subject_Tag_Posit] p
            JOIN
                [dbo].[SU_TAG_Subject_Tag_Annex] a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            AND
                a.SU_TAG_Positor = v.SU_TAG_Positor
            AND
                a.SU_TAG_PositedAt = (
                    SELECT
                        max(s.SU_TAG_PositedAt)
                    FROM
                        [dbo].[SU_TAG_Subject_Tag_Annex] s
                    WHERE
                        s.SU_TAG_ID = p.SU_TAG_ID
                    AND
                        s.SU_TAG_Positor = v.SU_TAG_Positor
                    AND
                        s.SU_TAG_PositedAt < v.SU_TAG_PositedAt
                )
            WHERE
                p.SU_TAG_SU_ID = v.SU_TAG_SU_ID
            AND
                p.SU_TAG_ChangedAt = v.SU_TAG_ChangedAt
            AND
                a.SU_TAG_Reliability > 0
            ORDER BY
                a.SU_TAG_PositedAt DESC,
                a.SU_TAG_Reliability DESC
        ) e
        WHERE
            v.SU_TAG_Version = @currentVersion
        AND
            v.SU_TAG_StatementType in ('S','N','D','F')
        AND
            v.SU_TAG_Reliability > 0
        AND
            e.SU_TAG_Subject_Tag <> v.SU_TAG_Subject_Tag
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TAG_Subject_Tag_Annex] x
            WHERE
                x.SU_TAG_ID = e.SU_TAG_ID
            AND
                x.SU_TAG_Positor = v.SU_TAG_Positor
            AND
                x.SU_TAG_PositedAt = v.SU_TAG_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level instead of INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_LVL_Subject_Level', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_LVL_Subject_Level];
GO
CREATE TRIGGER [dbo].[it_SU_LVL_Subject_Level] ON [dbo].[SU_LVL_Subject_Level]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_LVL_Subject_Level TABLE (
        SU_LVL_SU_ID int not null,
        Metadata_SU_LVL int not null,
        SU_LVL_ChangedAt datetime2 not null,
        SU_LVL_Positor tinyint not null,
        SU_LVL_PositedAt datetime2 not null,
        SU_LVL_Reliability decimal(5,2) not null,
        SU_LVL_Assertion char(1) not null,
        SU_LVL_GRD_ID tinyint not null,
        SU_LVL_Version bigint not null,
        SU_LVL_StatementType char(1) not null,
        primary key(
            SU_LVL_Version,
            SU_LVL_Positor,
            SU_LVL_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_LVL_SU_ID,
            i.SU_LVL_ChangedAt,
            i.SU_LVL_Positor,
            i.SU_LVL_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LVL_Subject_Level_Posit] p
            JOIN
                [dbo].[SU_LVL_Subject_Level_Annex] a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            WHERE
                p.SU_LVL_SU_ID = i.SU_LVL_SU_ID
            AND
                p.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
            AND
                p.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
            AND
                a.SU_LVL_Positor = i.SU_LVL_Positor
            AND
                a.SU_LVL_PositedAt = i.SU_LVL_PositedAt
            AND
                a.SU_LVL_Reliability <> i.SU_LVL_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_LVL_Subject_Level for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_LVL_Subject_Level
    SELECT
        i.SU_LVL_SU_ID,
        i.Metadata_SU_LVL,
        i.SU_LVL_ChangedAt,
        i.SU_LVL_Positor,
        i.SU_LVL_PositedAt,
        i.SU_LVL_Reliability,
        case
            when i.SU_LVL_Reliability > 0 then '+'
            when i.SU_LVL_Reliability = 0 then '?'
            when i.SU_LVL_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_LVL_GRD_ID,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_LVL_Positor,
                i.SU_LVL_SU_ID
            ORDER BY
                i.SU_LVL_ChangedAt ASC,
                i.SU_LVL_PositedAt ASC,
                i.SU_LVL_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_LVL_Subject_Level_Posit] p
        JOIN
            [dbo].[SU_LVL_Subject_Level_Annex] a
        ON
            a.SU_LVL_ID = p.SU_LVL_ID
        WHERE
            p.SU_LVL_SU_ID = i.SU_LVL_SU_ID
        AND
            p.SU_LVL_ChangedAt = i.SU_LVL_ChangedAt
        AND
            p.SU_LVL_GRD_ID = i.SU_LVL_GRD_ID
        AND
            a.SU_LVL_Positor = i.SU_LVL_Positor
        AND
            a.SU_LVL_PositedAt = i.SU_LVL_PositedAt
    );
    SELECT
        @maxVersion = max(SU_LVL_Version),
        @currentVersion = 0
    FROM
        @SU_LVL_Subject_Level;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_LVL_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_LVL_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_LVL_Positor, v.SU_LVL_ChangedAt, v.SU_LVL_PositedAt, v.SU_LVL_Assertion) t
                        WHERE
                            t.SU_LVL_SU_ID = v.SU_LVL_SU_ID
                        AND
                            t.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
                        AND
                            t.SU_LVL_Reliability = v.SU_LVL_Reliability
                        AND
                            t.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_LVL_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_LVL_GRD_ID
                        WHERE
                            v.SU_LVL_GRD_ID =
                                dbo.preSU_LVL_Subject_Level (
                                    v.SU_LVL_SU_ID,
                                    v.SU_LVL_Positor,
                                    v.SU_LVL_ChangedAt,
                                    v.SU_LVL_PositedAt,
                                    v.SU_LVL_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_LVL_GRD_ID
                        WHERE
                            v.SU_LVL_GRD_ID =
                                dbo.folSU_LVL_Subject_Level (
                                    v.SU_LVL_SU_ID,
                                    v.SU_LVL_Positor,
                                    v.SU_LVL_ChangedAt,
                                    v.SU_LVL_PositedAt,
                                    v.SU_LVL_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_LVL_Subject_Level v
        LEFT JOIN
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_SU_ID = v.SU_LVL_SU_ID
        AND
            p.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
        AND
            p.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
        WHERE
            v.SU_LVL_Version = @currentVersion;
        INSERT INTO [dbo].[SU_LVL_Subject_Level_Posit] (
            SU_LVL_SU_ID,
            SU_LVL_ChangedAt,
            SU_LVL_GRD_ID
        )
        SELECT
            v.SU_LVL_SU_ID,
            v.SU_LVL_ChangedAt,
            v.SU_LVL_GRD_ID
        FROM
            @SU_LVL_Subject_Level v
        WHERE
            v.SU_LVL_Version = @currentVersion
        AND
            v.SU_LVL_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_LVL_Subject_Level w
            WHERE
                w.SU_LVL_Version = v.SU_LVL_Version
            AND
                w.SU_LVL_Positor < v.SU_LVL_Positor
            AND
                w.SU_LVL_SU_ID = v.SU_LVL_SU_ID
            AND
                w.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
            AND
                w.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
            AND
                w.SU_LVL_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_LVL_Subject_Level_Annex] (
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_Positor,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
        )
        SELECT
            v.Metadata_SU_LVL,
            p.SU_LVL_ID,
            v.SU_LVL_Positor,
            v.SU_LVL_PositedAt,
            v.SU_LVL_Reliability
        FROM
            @SU_LVL_Subject_Level v
        JOIN
            [dbo].[SU_LVL_Subject_Level_Posit] p
        ON
            p.SU_LVL_SU_ID = v.SU_LVL_SU_ID
        AND
            p.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
        AND
            p.SU_LVL_GRD_ID = v.SU_LVL_GRD_ID
        WHERE
            v.SU_LVL_Version = @currentVersion
        AND
            SU_LVL_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_LVL_Subject_Level_Annex] (
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_Positor,
            SU_LVL_PositedAt,
            SU_LVL_Reliability
        )
        SELECT
            v.Metadata_SU_LVL,
            e.SU_LVL_ID,
            v.SU_LVL_Positor,
            v.SU_LVL_PositedAt,
            0
        FROM
            @SU_LVL_Subject_Level v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_LVL_ID,
                p.SU_LVL_GRD_ID
            FROM
                [dbo].[SU_LVL_Subject_Level_Posit] p
            JOIN
                [dbo].[SU_LVL_Subject_Level_Annex] a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            AND
                a.SU_LVL_Positor = v.SU_LVL_Positor
            AND
                a.SU_LVL_PositedAt = (
                    SELECT
                        max(s.SU_LVL_PositedAt)
                    FROM
                        [dbo].[SU_LVL_Subject_Level_Annex] s
                    WHERE
                        s.SU_LVL_ID = p.SU_LVL_ID
                    AND
                        s.SU_LVL_Positor = v.SU_LVL_Positor
                    AND
                        s.SU_LVL_PositedAt < v.SU_LVL_PositedAt
                )
            WHERE
                p.SU_LVL_SU_ID = v.SU_LVL_SU_ID
            AND
                p.SU_LVL_ChangedAt = v.SU_LVL_ChangedAt
            AND
                a.SU_LVL_Reliability > 0
            ORDER BY
                a.SU_LVL_PositedAt DESC,
                a.SU_LVL_Reliability DESC
        ) e
        WHERE
            v.SU_LVL_Version = @currentVersion
        AND
            v.SU_LVL_StatementType in ('S','N','D','R')
        AND
            v.SU_LVL_Reliability > 0
        AND
            e.SU_LVL_GRD_ID <> v.SU_LVL_GRD_ID
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_LVL_Subject_Level_Annex] x
            WHERE
                x.SU_LVL_ID = e.SU_LVL_ID
            AND
                x.SU_LVL_Positor = v.SU_LVL_Positor
            AND
                x.SU_LVL_PositedAt = v.SU_LVL_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text instead of INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_TXT_Subject_Text', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_TXT_Subject_Text];
GO
CREATE TRIGGER [dbo].[it_SU_TXT_Subject_Text] ON [dbo].[SU_TXT_Subject_Text]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_TXT_Subject_Text TABLE (
        SU_TXT_SU_ID int not null,
        Metadata_SU_TXT int not null,
        SU_TXT_ChangedAt datetime2 not null,
        SU_TXT_Positor tinyint not null,
        SU_TXT_PositedAt datetime2 not null,
        SU_TXT_Reliability decimal(5,2) not null,
        SU_TXT_Assertion char(1) not null,
        SU_TXT_Subject_Text nvarchar(max) not null,
        SU_TXT_Checksum varbinary(16) not null,
        SU_TXT_Version bigint not null,
        SU_TXT_StatementType char(1) not null,
        primary key(
            SU_TXT_Version,
            SU_TXT_Positor,
            SU_TXT_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_TXT_SU_ID,
            i.SU_TXT_ChangedAt,
            i.SU_TXT_Positor,
            i.SU_TXT_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TXT_Subject_Text_Posit] p
            JOIN
                [dbo].[SU_TXT_Subject_Text_Annex] a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            WHERE
                p.SU_TXT_SU_ID = i.SU_TXT_SU_ID
            AND
                p.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
            AND
                p.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
            AND
                a.SU_TXT_Positor = i.SU_TXT_Positor
            AND
                a.SU_TXT_PositedAt = i.SU_TXT_PositedAt
            AND
                a.SU_TXT_Reliability <> i.SU_TXT_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_TXT_Subject_Text for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_TXT_Subject_Text
    SELECT
        i.SU_TXT_SU_ID,
        i.Metadata_SU_TXT,
        i.SU_TXT_ChangedAt,
        i.SU_TXT_Positor,
        i.SU_TXT_PositedAt,
        i.SU_TXT_Reliability,
        case
            when i.SU_TXT_Reliability > 0 then '+'
            when i.SU_TXT_Reliability = 0 then '?'
            when i.SU_TXT_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_TXT_Subject_Text,
        dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max))),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_TXT_Positor,
                i.SU_TXT_SU_ID
            ORDER BY
                i.SU_TXT_ChangedAt ASC,
                i.SU_TXT_PositedAt ASC,
                i.SU_TXT_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_TXT_Subject_Text_Posit] p
        JOIN
            [dbo].[SU_TXT_Subject_Text_Annex] a
        ON
            a.SU_TXT_ID = p.SU_TXT_ID
        WHERE
            p.SU_TXT_SU_ID = i.SU_TXT_SU_ID
        AND
            p.SU_TXT_ChangedAt = i.SU_TXT_ChangedAt
        AND
            p.SU_TXT_Checksum = dbo.MD5(cast(i.SU_TXT_Subject_Text as varbinary(max)))
        AND
            a.SU_TXT_Positor = i.SU_TXT_Positor
        AND
            a.SU_TXT_PositedAt = i.SU_TXT_PositedAt
    );
    SELECT
        @maxVersion = max(SU_TXT_Version),
        @currentVersion = 0
    FROM
        @SU_TXT_Subject_Text;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_TXT_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_TXT_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_TXT_Positor, v.SU_TXT_ChangedAt, v.SU_TXT_PositedAt, v.SU_TXT_Assertion) t
                        WHERE
                            t.SU_TXT_SU_ID = v.SU_TXT_SU_ID
                        AND
                            t.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
                        AND
                            t.SU_TXT_Reliability = v.SU_TXT_Reliability
                        AND
                            t.SU_TXT_Checksum = v.SU_TXT_Checksum
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_TXT_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_TXT_Checksum
                        WHERE
                            v.SU_TXT_Checksum =
                                dbo.preSU_TXT_Subject_Text (
                                    v.SU_TXT_SU_ID,
                                    v.SU_TXT_Positor,
                                    v.SU_TXT_ChangedAt,
                                    v.SU_TXT_PositedAt,
                                    v.SU_TXT_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_TXT_Checksum
                        WHERE
                            v.SU_TXT_Checksum =
                                dbo.folSU_TXT_Subject_Text (
                                    v.SU_TXT_SU_ID,
                                    v.SU_TXT_Positor,
                                    v.SU_TXT_ChangedAt,
                                    v.SU_TXT_PositedAt,
                                    v.SU_TXT_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_TXT_Subject_Text v
        LEFT JOIN
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_SU_ID = v.SU_TXT_SU_ID
        AND
            p.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
        AND
            p.SU_TXT_Checksum = v.SU_TXT_Checksum
        WHERE
            v.SU_TXT_Version = @currentVersion;
        INSERT INTO [dbo].[SU_TXT_Subject_Text_Posit] (
            SU_TXT_SU_ID,
            SU_TXT_ChangedAt,
            SU_TXT_Subject_Text
        )
        SELECT
            v.SU_TXT_SU_ID,
            v.SU_TXT_ChangedAt,
            v.SU_TXT_Subject_Text
        FROM
            @SU_TXT_Subject_Text v
        WHERE
            v.SU_TXT_Version = @currentVersion
        AND
            v.SU_TXT_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_TXT_Subject_Text w
            WHERE
                w.SU_TXT_Version = v.SU_TXT_Version
            AND
                w.SU_TXT_Positor < v.SU_TXT_Positor
            AND
                w.SU_TXT_SU_ID = v.SU_TXT_SU_ID
            AND
                w.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
            AND
                w.SU_TXT_Checksum = v.SU_TXT_Checksum
            AND
                w.SU_TXT_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_TXT_Subject_Text_Annex] (
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_Positor,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
        )
        SELECT
            v.Metadata_SU_TXT,
            p.SU_TXT_ID,
            v.SU_TXT_Positor,
            v.SU_TXT_PositedAt,
            v.SU_TXT_Reliability
        FROM
            @SU_TXT_Subject_Text v
        JOIN
            [dbo].[SU_TXT_Subject_Text_Posit] p
        ON
            p.SU_TXT_SU_ID = v.SU_TXT_SU_ID
        AND
            p.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
        AND
            p.SU_TXT_Checksum = v.SU_TXT_Checksum
        WHERE
            v.SU_TXT_Version = @currentVersion
        AND
            SU_TXT_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_TXT_Subject_Text_Annex] (
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_Positor,
            SU_TXT_PositedAt,
            SU_TXT_Reliability
        )
        SELECT
            v.Metadata_SU_TXT,
            e.SU_TXT_ID,
            v.SU_TXT_Positor,
            v.SU_TXT_PositedAt,
            0
        FROM
            @SU_TXT_Subject_Text v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_TXT_ID,
                p.SU_TXT_Checksum
            FROM
                [dbo].[SU_TXT_Subject_Text_Posit] p
            JOIN
                [dbo].[SU_TXT_Subject_Text_Annex] a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            AND
                a.SU_TXT_Positor = v.SU_TXT_Positor
            AND
                a.SU_TXT_PositedAt = (
                    SELECT
                        max(s.SU_TXT_PositedAt)
                    FROM
                        [dbo].[SU_TXT_Subject_Text_Annex] s
                    WHERE
                        s.SU_TXT_ID = p.SU_TXT_ID
                    AND
                        s.SU_TXT_Positor = v.SU_TXT_Positor
                    AND
                        s.SU_TXT_PositedAt < v.SU_TXT_PositedAt
                )
            WHERE
                p.SU_TXT_SU_ID = v.SU_TXT_SU_ID
            AND
                p.SU_TXT_ChangedAt = v.SU_TXT_ChangedAt
            AND
                a.SU_TXT_Reliability > 0
            ORDER BY
                a.SU_TXT_PositedAt DESC,
                a.SU_TXT_Reliability DESC
        ) e
        WHERE
            v.SU_TXT_Version = @currentVersion
        AND
            v.SU_TXT_StatementType in ('S','N','D','R')
        AND
            v.SU_TXT_Reliability > 0
        AND
            e.SU_TXT_Checksum <> v.SU_TXT_Checksum
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_TXT_Subject_Text_Annex] x
            WHERE
                x.SU_TXT_ID = e.SU_TXT_ID
            AND
                x.SU_TXT_Positor = v.SU_TXT_Positor
            AND
                x.SU_TXT_PositedAt = v.SU_TXT_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment instead of INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ASR_Subject_Assessment', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ASR_Subject_Assessment];
GO
CREATE TRIGGER [dbo].[it_SU_ASR_Subject_Assessment] ON [dbo].[SU_ASR_Subject_Assessment]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_ASR_Subject_Assessment TABLE (
        SU_ASR_SU_ID int not null,
        Metadata_SU_ASR int not null,
        SU_ASR_ChangedAt datetime2 not null,
        SU_ASR_Positor tinyint not null,
        SU_ASR_PositedAt datetime2 not null,
        SU_ASR_Reliability decimal(5,2) not null,
        SU_ASR_Assertion char(1) not null,
        SU_ASR_Subject_Assessment nvarchar(42) not null,
        SU_ASR_Version bigint not null,
        SU_ASR_StatementType char(1) not null,
        primary key(
            SU_ASR_Version,
            SU_ASR_Positor,
            SU_ASR_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ASR_SU_ID,
            i.SU_ASR_ChangedAt,
            i.SU_ASR_Positor,
            i.SU_ASR_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ASR_Subject_Assessment_Posit] p
            JOIN
                [dbo].[SU_ASR_Subject_Assessment_Annex] a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            WHERE
                p.SU_ASR_SU_ID = i.SU_ASR_SU_ID
            AND
                p.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
            AND
                p.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
            AND
                a.SU_ASR_Positor = i.SU_ASR_Positor
            AND
                a.SU_ASR_PositedAt = i.SU_ASR_PositedAt
            AND
                a.SU_ASR_Reliability <> i.SU_ASR_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ASR_Subject_Assessment for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_ASR_Subject_Assessment
    SELECT
        i.SU_ASR_SU_ID,
        i.Metadata_SU_ASR,
        i.SU_ASR_ChangedAt,
        i.SU_ASR_Positor,
        i.SU_ASR_PositedAt,
        i.SU_ASR_Reliability,
        case
            when i.SU_ASR_Reliability > 0 then '+'
            when i.SU_ASR_Reliability = 0 then '?'
            when i.SU_ASR_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_ASR_Subject_Assessment,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_ASR_Positor,
                i.SU_ASR_SU_ID
            ORDER BY
                i.SU_ASR_ChangedAt ASC,
                i.SU_ASR_PositedAt ASC,
                i.SU_ASR_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Annex] a
        ON
            a.SU_ASR_ID = p.SU_ASR_ID
        WHERE
            p.SU_ASR_SU_ID = i.SU_ASR_SU_ID
        AND
            p.SU_ASR_ChangedAt = i.SU_ASR_ChangedAt
        AND
            p.SU_ASR_Subject_Assessment = i.SU_ASR_Subject_Assessment
        AND
            a.SU_ASR_Positor = i.SU_ASR_Positor
        AND
            a.SU_ASR_PositedAt = i.SU_ASR_PositedAt
    );
    SELECT
        @maxVersion = max(SU_ASR_Version),
        @currentVersion = 0
    FROM
        @SU_ASR_Subject_Assessment;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_ASR_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_ASR_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_ASR_Positor, v.SU_ASR_ChangedAt, v.SU_ASR_PositedAt, v.SU_ASR_Assertion) t
                        WHERE
                            t.SU_ASR_SU_ID = v.SU_ASR_SU_ID
                        AND
                            t.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
                        AND
                            t.SU_ASR_Reliability = v.SU_ASR_Reliability
                        AND
                            t.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_ASR_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_ASR_Subject_Assessment
                        WHERE
                            v.SU_ASR_Subject_Assessment =
                                dbo.preSU_ASR_Subject_Assessment (
                                    v.SU_ASR_SU_ID,
                                    v.SU_ASR_Positor,
                                    v.SU_ASR_ChangedAt,
                                    v.SU_ASR_PositedAt,
                                    v.SU_ASR_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_ASR_Subject_Assessment
                        WHERE
                            v.SU_ASR_Subject_Assessment =
                                dbo.folSU_ASR_Subject_Assessment (
                                    v.SU_ASR_SU_ID,
                                    v.SU_ASR_Positor,
                                    v.SU_ASR_ChangedAt,
                                    v.SU_ASR_PositedAt,
                                    v.SU_ASR_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_ASR_Subject_Assessment v
        LEFT JOIN
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_SU_ID = v.SU_ASR_SU_ID
        AND
            p.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
        AND
            p.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
        WHERE
            v.SU_ASR_Version = @currentVersion;
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Posit] (
            SU_ASR_SU_ID,
            SU_ASR_ChangedAt,
            SU_ASR_Subject_Assessment
        )
        SELECT
            v.SU_ASR_SU_ID,
            v.SU_ASR_ChangedAt,
            v.SU_ASR_Subject_Assessment
        FROM
            @SU_ASR_Subject_Assessment v
        WHERE
            v.SU_ASR_Version = @currentVersion
        AND
            v.SU_ASR_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_ASR_Subject_Assessment w
            WHERE
                w.SU_ASR_Version = v.SU_ASR_Version
            AND
                w.SU_ASR_Positor < v.SU_ASR_Positor
            AND
                w.SU_ASR_SU_ID = v.SU_ASR_SU_ID
            AND
                w.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
            AND
                w.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
            AND
                w.SU_ASR_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Annex] (
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_Positor,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
        )
        SELECT
            v.Metadata_SU_ASR,
            p.SU_ASR_ID,
            v.SU_ASR_Positor,
            v.SU_ASR_PositedAt,
            v.SU_ASR_Reliability
        FROM
            @SU_ASR_Subject_Assessment v
        JOIN
            [dbo].[SU_ASR_Subject_Assessment_Posit] p
        ON
            p.SU_ASR_SU_ID = v.SU_ASR_SU_ID
        AND
            p.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
        AND
            p.SU_ASR_Subject_Assessment = v.SU_ASR_Subject_Assessment
        WHERE
            v.SU_ASR_Version = @currentVersion
        AND
            SU_ASR_StatementType in ('S','N','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_ASR_Subject_Assessment_Annex] (
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_Positor,
            SU_ASR_PositedAt,
            SU_ASR_Reliability
        )
        SELECT
            v.Metadata_SU_ASR,
            e.SU_ASR_ID,
            v.SU_ASR_Positor,
            v.SU_ASR_PositedAt,
            0
        FROM
            @SU_ASR_Subject_Assessment v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_ASR_ID,
                p.SU_ASR_Subject_Assessment
            FROM
                [dbo].[SU_ASR_Subject_Assessment_Posit] p
            JOIN
                [dbo].[SU_ASR_Subject_Assessment_Annex] a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            AND
                a.SU_ASR_Positor = v.SU_ASR_Positor
            AND
                a.SU_ASR_PositedAt = (
                    SELECT
                        max(s.SU_ASR_PositedAt)
                    FROM
                        [dbo].[SU_ASR_Subject_Assessment_Annex] s
                    WHERE
                        s.SU_ASR_ID = p.SU_ASR_ID
                    AND
                        s.SU_ASR_Positor = v.SU_ASR_Positor
                    AND
                        s.SU_ASR_PositedAt < v.SU_ASR_PositedAt
                )
            WHERE
                p.SU_ASR_SU_ID = v.SU_ASR_SU_ID
            AND
                p.SU_ASR_ChangedAt = v.SU_ASR_ChangedAt
            AND
                a.SU_ASR_Reliability > 0
            ORDER BY
                a.SU_ASR_PositedAt DESC,
                a.SU_ASR_Reliability DESC
        ) e
        WHERE
            v.SU_ASR_Version = @currentVersion
        AND
            v.SU_ASR_StatementType in ('S','N','R')
        AND
            v.SU_ASR_Reliability > 0
        AND
            e.SU_ASR_Subject_Assessment <> v.SU_ASR_Subject_Assessment
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ASR_Subject_Assessment_Annex] x
            WHERE
                x.SU_ASR_ID = e.SU_ASR_ID
            AND
                x.SU_ASR_Positor = v.SU_ASR_Positor
            AND
                x.SU_ASR_PositedAt = v.SU_ASR_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable instead of INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_ERS_Subject_Erasable', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_ERS_Subject_Erasable];
GO
CREATE TRIGGER [dbo].[it_SU_ERS_Subject_Erasable] ON [dbo].[SU_ERS_Subject_Erasable]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @SU_ERS_Subject_Erasable TABLE (
        SU_ERS_SU_ID int not null,
        Metadata_SU_ERS int not null,
        SU_ERS_ChangedAt datetime2 not null,
        SU_ERS_Positor tinyint not null,
        SU_ERS_PositedAt datetime2 not null,
        SU_ERS_Reliability decimal(5,2) not null,
        SU_ERS_Assertion char(1) not null,
        SU_ERS_Subject_Erasable nvarchar(42) not null,
        SU_ERS_Version bigint not null,
        SU_ERS_StatementType char(1) not null,
        primary key(
            SU_ERS_Version,
            SU_ERS_Positor,
            SU_ERS_SU_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ERS_SU_ID,
            i.SU_ERS_ChangedAt,
            i.SU_ERS_Positor,
            i.SU_ERS_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ERS_Subject_Erasable_Posit] p
            JOIN
                [dbo].[SU_ERS_Subject_Erasable_Annex] a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            WHERE
                p.SU_ERS_SU_ID = i.SU_ERS_SU_ID
            AND
                p.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
            AND
                p.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
            AND
                a.SU_ERS_Positor = i.SU_ERS_Positor
            AND
                a.SU_ERS_PositedAt = i.SU_ERS_PositedAt
            AND
                a.SU_ERS_Reliability <> i.SU_ERS_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_ERS_Subject_Erasable for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @SU_ERS_Subject_Erasable
    SELECT
        i.SU_ERS_SU_ID,
        i.Metadata_SU_ERS,
        i.SU_ERS_ChangedAt,
        i.SU_ERS_Positor,
        i.SU_ERS_PositedAt,
        i.SU_ERS_Reliability,
        case
            when i.SU_ERS_Reliability > 0 then '+'
            when i.SU_ERS_Reliability = 0 then '?'
            when i.SU_ERS_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.SU_ERS_Subject_Erasable,
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_ERS_Positor,
                i.SU_ERS_SU_ID
            ORDER BY
                i.SU_ERS_ChangedAt ASC,
                i.SU_ERS_PositedAt ASC,
                i.SU_ERS_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Annex] a
        ON
            a.SU_ERS_ID = p.SU_ERS_ID
        WHERE
            p.SU_ERS_SU_ID = i.SU_ERS_SU_ID
        AND
            p.SU_ERS_ChangedAt = i.SU_ERS_ChangedAt
        AND
            p.SU_ERS_Subject_Erasable = i.SU_ERS_Subject_Erasable
        AND
            a.SU_ERS_Positor = i.SU_ERS_Positor
        AND
            a.SU_ERS_PositedAt = i.SU_ERS_PositedAt
    );
    SELECT
        @maxVersion = max(SU_ERS_Version),
        @currentVersion = 0
    FROM
        @SU_ERS_Subject_Erasable;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_ERS_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_ERS_ID
                        FROM
                            [dbo].[tSU_Subject](v.SU_ERS_Positor, v.SU_ERS_ChangedAt, v.SU_ERS_PositedAt, v.SU_ERS_Assertion) t
                        WHERE
                            t.SU_ERS_SU_ID = v.SU_ERS_SU_ID
                        AND
                            t.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
                        AND
                            t.SU_ERS_Reliability = v.SU_ERS_Reliability
                        AND
                            t.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_ERS_SU_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            v.SU_ERS_Subject_Erasable
                        WHERE
                            v.SU_ERS_Subject_Erasable =
                                dbo.preSU_ERS_Subject_Erasable (
                                    v.SU_ERS_SU_ID,
                                    v.SU_ERS_Positor,
                                    v.SU_ERS_ChangedAt,
                                    v.SU_ERS_PositedAt,
                                    v.SU_ERS_Assertion
                                )
                    ) OR EXISTS (
                        SELECT
                            v.SU_ERS_Subject_Erasable
                        WHERE
                            v.SU_ERS_Subject_Erasable =
                                dbo.folSU_ERS_Subject_Erasable (
                                    v.SU_ERS_SU_ID,
                                    v.SU_ERS_Positor,
                                    v.SU_ERS_ChangedAt,
                                    v.SU_ERS_PositedAt,
                                    v.SU_ERS_Assertion
                                )
                    )
                    THEN 'R' -- restatement
                    ELSE 'N' -- new statement
                END
        FROM
            @SU_ERS_Subject_Erasable v
        LEFT JOIN
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_SU_ID = v.SU_ERS_SU_ID
        AND
            p.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
        AND
            p.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
        WHERE
            v.SU_ERS_Version = @currentVersion;
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Posit] (
            SU_ERS_SU_ID,
            SU_ERS_ChangedAt,
            SU_ERS_Subject_Erasable
        )
        SELECT
            v.SU_ERS_SU_ID,
            v.SU_ERS_ChangedAt,
            v.SU_ERS_Subject_Erasable
        FROM
            @SU_ERS_Subject_Erasable v
        WHERE
            v.SU_ERS_Version = @currentVersion
        AND
            v.SU_ERS_StatementType in ('N','R')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @SU_ERS_Subject_Erasable w
            WHERE
                w.SU_ERS_Version = v.SU_ERS_Version
            AND
                w.SU_ERS_Positor < v.SU_ERS_Positor
            AND
                w.SU_ERS_SU_ID = v.SU_ERS_SU_ID
            AND
                w.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
            AND
                w.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
            AND
                w.SU_ERS_StatementType in ('N','R')
        );
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Annex] (
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_Positor,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
        )
        SELECT
            v.Metadata_SU_ERS,
            p.SU_ERS_ID,
            v.SU_ERS_Positor,
            v.SU_ERS_PositedAt,
            v.SU_ERS_Reliability
        FROM
            @SU_ERS_Subject_Erasable v
        JOIN
            [dbo].[SU_ERS_Subject_Erasable_Posit] p
        ON
            p.SU_ERS_SU_ID = v.SU_ERS_SU_ID
        AND
            p.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
        AND
            p.SU_ERS_Subject_Erasable = v.SU_ERS_Subject_Erasable
        WHERE
            v.SU_ERS_Version = @currentVersion
        AND
            SU_ERS_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor at the same changing time when that has another value (a correction)
        INSERT INTO [dbo].[SU_ERS_Subject_Erasable_Annex] (
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_Positor,
            SU_ERS_PositedAt,
            SU_ERS_Reliability
        )
        SELECT
            v.Metadata_SU_ERS,
            e.SU_ERS_ID,
            v.SU_ERS_Positor,
            v.SU_ERS_PositedAt,
            0
        FROM
            @SU_ERS_Subject_Erasable v
        CROSS APPLY (
            SELECT TOP 1
                p.SU_ERS_ID,
                p.SU_ERS_Subject_Erasable
            FROM
                [dbo].[SU_ERS_Subject_Erasable_Posit] p
            JOIN
                [dbo].[SU_ERS_Subject_Erasable_Annex] a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            AND
                a.SU_ERS_Positor = v.SU_ERS_Positor
            AND
                a.SU_ERS_PositedAt = (
                    SELECT
                        max(s.SU_ERS_PositedAt)
                    FROM
                        [dbo].[SU_ERS_Subject_Erasable_Annex] s
                    WHERE
                        s.SU_ERS_ID = p.SU_ERS_ID
                    AND
                        s.SU_ERS_Positor = v.SU_ERS_Positor
                    AND
                        s.SU_ERS_PositedAt < v.SU_ERS_PositedAt
                )
            WHERE
                p.SU_ERS_SU_ID = v.SU_ERS_SU_ID
            AND
                p.SU_ERS_ChangedAt = v.SU_ERS_ChangedAt
            AND
                a.SU_ERS_Reliability > 0
            ORDER BY
                a.SU_ERS_PositedAt DESC,
                a.SU_ERS_Reliability DESC
        ) e
        WHERE
            v.SU_ERS_Version = @currentVersion
        AND
            v.SU_ERS_StatementType in ('S','N','D','R')
        AND
            v.SU_ERS_Reliability > 0
        AND
            e.SU_ERS_Subject_Erasable <> v.SU_ERS_Subject_Erasable
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_ERS_Subject_Erasable_Annex] x
            WHERE
                x.SU_ERS_ID = e.SU_ERS_ID
            AND
                x.SU_ERS_Positor = v.SU_ERS_Positor
            AND
                x.SU_ERS_PositedAt = v.SU_ERS_PositedAt
        );
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name instead of INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_OB_NAM_Object_Name', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_OB_NAM_Object_Name];
GO
CREATE TRIGGER [dbo].[it_OB_NAM_Object_Name] ON [dbo].[OB_NAM_Object_Name]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @OB_NAM_Object_Name TABLE (
        OB_NAM_OB_ID int not null,
        Metadata_OB_NAM int not null,
        OB_NAM_Positor tinyint not null,
        OB_NAM_PositedAt datetime2 not null,
        OB_NAM_Reliability decimal(5,2) not null,
        OB_NAM_Assertion char(1) not null,
        OB_NAM_Object_Name nvarchar(42) not null,
        OB_NAM_Version bigint not null,
        OB_NAM_StatementType char(1) not null,
        primary key(
            OB_NAM_Version,
            OB_NAM_Positor,
            OB_NAM_OB_ID
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_NAM_OB_ID,
            i.OB_NAM_Positor,
            i.OB_NAM_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_NAM_Object_Name_Posit] p
            JOIN
                [dbo].[OB_NAM_Object_Name_Annex] a
            ON
                a.OB_NAM_ID = p.OB_NAM_ID
            WHERE
                p.OB_NAM_OB_ID = i.OB_NAM_OB_ID
            AND
                p.OB_NAM_Object_Name = i.OB_NAM_Object_Name
            AND
                a.OB_NAM_Positor = i.OB_NAM_Positor
            AND
                a.OB_NAM_PositedAt = i.OB_NAM_PositedAt
            AND
                a.OB_NAM_Reliability <> i.OB_NAM_Reliability
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in OB_NAM_Object_Name for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @OB_NAM_Object_Name
    SELECT
        i.OB_NAM_OB_ID,
        i.Metadata_OB_NAM,
        i.OB_NAM_Positor,
        i.OB_NAM_PositedAt,
        i.OB_NAM_Reliability,
        case
            when i.OB_NAM_Reliability > 0 then '+'
            when i.OB_NAM_Reliability = 0 then '?'
            when i.OB_NAM_Reliability < 0 then '-'
            else '+' -- assume that unspecified reliability (NULL) means default
        end,
        i.OB_NAM_Object_Name,
        DENSE_RANK() OVER (
            PARTITION BY
                i.OB_NAM_Positor,
                i.OB_NAM_OB_ID
            ORDER BY
                i.OB_NAM_PositedAt ASC,
                i.OB_NAM_Reliability ASC
        ),
        'X'
    FROM
        inserted i
    WHERE NOT EXISTS ( -- exclude the identical, which is already stored
        SELECT TOP 1
            42
        FROM
            [dbo].[OB_NAM_Object_Name_Posit] p
        JOIN
            [dbo].[OB_NAM_Object_Name_Annex] a
        ON
            a.OB_NAM_ID = p.OB_NAM_ID
        WHERE
            p.OB_NAM_OB_ID = i.OB_NAM_OB_ID
        AND
            p.OB_NAM_Object_Name = i.OB_NAM_Object_Name
        AND
            a.OB_NAM_Positor = i.OB_NAM_Positor
        AND
            a.OB_NAM_PositedAt = i.OB_NAM_PositedAt
    );
    SELECT
        @maxVersion = max(OB_NAM_Version),
        @currentVersion = 0
    FROM
        @OB_NAM_Object_Name;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.OB_NAM_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.OB_NAM_ID
                        FROM
                            [dbo].[tOB_Object](v.OB_NAM_Positor, DEFAULT, v.OB_NAM_PositedAt, v.OB_NAM_Assertion) t
                        WHERE
                            t.OB_NAM_OB_ID = v.OB_NAM_OB_ID
                        AND
                            t.OB_NAM_Reliability = v.OB_NAM_Reliability
                        AND
                            t.OB_NAM_Object_Name = v.OB_NAM_Object_Name
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.OB_NAM_OB_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @OB_NAM_Object_Name v
        LEFT JOIN
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_OB_ID = v.OB_NAM_OB_ID
        AND
            p.OB_NAM_Object_Name = v.OB_NAM_Object_Name
        WHERE
            v.OB_NAM_Version = @currentVersion;
        INSERT INTO [dbo].[OB_NAM_Object_Name_Posit] (
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        )
        SELECT
            v.OB_NAM_OB_ID,
            v.OB_NAM_Object_Name
        FROM
            @OB_NAM_Object_Name v
        WHERE
            v.OB_NAM_Version = @currentVersion
        AND
            v.OB_NAM_StatementType in ('N')
        AND NOT EXISTS ( -- a posit that several positors state is made once
            SELECT TOP 1
                42
            FROM
                @OB_NAM_Object_Name w
            WHERE
                w.OB_NAM_Version = v.OB_NAM_Version
            AND
                w.OB_NAM_Positor < v.OB_NAM_Positor
            AND
                w.OB_NAM_OB_ID = v.OB_NAM_OB_ID
            AND
                w.OB_NAM_Object_Name = v.OB_NAM_Object_Name
            AND
                w.OB_NAM_StatementType in ('N')
        );
        INSERT INTO [dbo].[OB_NAM_Object_Name_Annex] (
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_Positor,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
        )
        SELECT
            v.Metadata_OB_NAM,
            p.OB_NAM_ID,
            v.OB_NAM_Positor,
            v.OB_NAM_PositedAt,
            v.OB_NAM_Reliability
        FROM
            @OB_NAM_Object_Name v
        JOIN
            [dbo].[OB_NAM_Object_Name_Posit] p
        ON
            p.OB_NAM_OB_ID = v.OB_NAM_OB_ID
        AND
            p.OB_NAM_Object_Name = v.OB_NAM_Object_Name
        WHERE
            v.OB_NAM_Version = @currentVersion
        AND
            OB_NAM_StatementType in ('S','N','D');
        -- decisive: a positor holds one value at a time, so a positive assertion retracts, at its positing time, the posit
        -- in effect for the positor when that has another value (a correction)
        INSERT INTO [dbo].[OB_NAM_Object_Name_Annex] (
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_Positor,
            OB_NAM_PositedAt,
            OB_NAM_Reliability
        )
        SELECT
            v.Metadata_OB_NAM,
            e.OB_NAM_ID,
            v.OB_NAM_Positor,
            v.OB_NAM_PositedAt,
            0
        FROM
            @OB_NAM_Object_Name v
        CROSS APPLY (
            SELECT TOP 1
                p.OB_NAM_ID,
                p.OB_NAM_Object_Name
            FROM
                [dbo].[OB_NAM_Object_Name_Posit] p
            JOIN
                [dbo].[OB_NAM_Object_Name_Annex] a
            ON
                a.OB_NAM_ID = p.OB_NAM_ID
            AND
                a.OB_NAM_Positor = v.OB_NAM_Positor
            AND
                a.OB_NAM_PositedAt = (
                    SELECT
                        max(s.OB_NAM_PositedAt)
                    FROM
                        [dbo].[OB_NAM_Object_Name_Annex] s
                    WHERE
                        s.OB_NAM_ID = p.OB_NAM_ID
                    AND
                        s.OB_NAM_Positor = v.OB_NAM_Positor
                    AND
                        s.OB_NAM_PositedAt < v.OB_NAM_PositedAt
                )
            WHERE
                p.OB_NAM_OB_ID = v.OB_NAM_OB_ID
            AND
                a.OB_NAM_Reliability > 0
            ORDER BY
                a.OB_NAM_PositedAt DESC,
                a.OB_NAM_Reliability DESC
        ) e
        WHERE
            v.OB_NAM_Version = @currentVersion
        AND
            v.OB_NAM_StatementType in ('S','N','D')
        AND
            v.OB_NAM_Reliability > 0
        AND
            e.OB_NAM_Object_Name <> v.OB_NAM_Object_Name
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_NAM_Object_Name_Annex] x
            WHERE
                x.OB_NAM_ID = e.OB_NAM_ID
            AND
                x.OB_NAM_Positor = v.OB_NAM_Positor
            AND
                x.OB_NAM_PositedAt = v.OB_NAM_PositedAt
        );
    END
END
GO
