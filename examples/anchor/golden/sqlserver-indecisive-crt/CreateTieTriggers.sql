-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- For idempotent ties, only changes that represent values different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itSU_holder_OB_item_GRD_grade instead of INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_holder_OB_item_GRD_grade', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_holder_OB_item_GRD_grade];
GO
CREATE TRIGGER [dbo].[it_SU_holder_OB_item_GRD_grade] ON [dbo].[SU_holder_OB_item_GRD_grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_SU_holder_OB_item_GRD_grade int not null,
        SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_Version bigint not null,
        SU_holder_OB_item_GRD_grade_StatementType char(1) not null,
        SU_holder_OB_item_GRD_grade_Positor tinyint not null,
        SU_holder_OB_item_GRD_grade_PositedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_Reliability decimal(5,2) not null,
        SU_holder_OB_item_GRD_grade_Assertion char(1) not null,
        SU_ID_holder int not null,
        OB_ID_item int not null,
        GRD_ID_grade tinyint not null,
        primary key (
            SU_holder_OB_item_GRD_grade_Version,
            SU_holder_OB_item_GRD_grade_Positor,
            -- all roles: without decisiveness a positor may state alternatives for the identifiers in one insert
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_holder,
            i.OB_ID_item,
            i.GRD_ID_grade,
            ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now) AS SU_holder_OB_item_GRD_grade_ChangedAt,
            ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0) AS SU_holder_OB_item_GRD_grade_Positor,
            ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now) AS SU_holder_OB_item_GRD_grade_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
            JOIN
                [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            WHERE
                p.SU_ID_holder = i.SU_ID_holder
            AND
                p.OB_ID_item = i.OB_ID_item
            AND
                p.GRD_ID_grade = i.GRD_ID_grade
            AND
                p.SU_holder_OB_item_GRD_grade_ChangedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now)
            AND
                a.SU_holder_OB_item_GRD_grade_Positor = ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0)
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now)
            AND
                a.SU_holder_OB_item_GRD_grade_Reliability <> ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_holder_OB_item_GRD_grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_holder_OB_item_GRD_grade, 0),
        ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_holder_OB_item_GRD_grade_Positor,
                i.SU_ID_holder,
                i.OB_ID_item
            ORDER BY
                ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now),
                i.SU_holder_OB_item_GRD_grade_PositedAt ASC,
                i.SU_holder_OB_item_GRD_grade_Reliability ASC
        ),
        'X',
        ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0),
        ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now),
        ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1),
        CAST(
            case
                when i.SU_holder_OB_item_GRD_grade_Reliability > 0 then '+'
                when i.SU_holder_OB_item_GRD_grade_Reliability = 0 then '?'
                when i.SU_holder_OB_item_GRD_grade_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.SU_ID_holder,
        i.OB_ID_item,
        i.GRD_ID_grade
    FROM
        inserted i
    WHERE
        i.SU_ID_holder is not null
    AND
        i.OB_ID_item is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
            JOIN
                [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            WHERE
                p.SU_ID_holder = i.SU_ID_holder
            AND
                p.OB_ID_item = i.OB_ID_item
            AND
                p.GRD_ID_grade = i.GRD_ID_grade
            AND
                p.SU_holder_OB_item_GRD_grade_ChangedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now)
            AND
                a.SU_holder_OB_item_GRD_grade_Positor = ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, 0)
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt = ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(SU_holder_OB_item_GRD_grade_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_holder_OB_item_GRD_grade_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_holder_OB_item_GRD_grade_ID
                        FROM
                            [dbo].[tSU_holder_OB_item_GRD_grade](v.SU_holder_OB_item_GRD_grade_Positor, v.SU_holder_OB_item_GRD_grade_ChangedAt, v.SU_holder_OB_item_GRD_grade_PositedAt, v.SU_holder_OB_item_GRD_grade_Assertion) t
                        WHERE
                            t.SU_holder_OB_item_GRD_grade_Reliability = v.SU_holder_OB_item_GRD_grade_Reliability
                        AND
                            t.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
                        AND
                            t.SU_ID_holder = v.SU_ID_holder
                        AND
                            t.OB_ID_item = v.OB_ID_item
                        AND
                            t.GRD_ID_grade = v.GRD_ID_grade
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_holder_OB_item_GRD_grade_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.GRD_ID_grade
                            FROM
                                [dbo].[rSU_holder_OB_item_GRD_grade] (
                                    v.SU_holder_OB_item_GRD_grade_Positor,
                                    v.SU_holder_OB_item_GRD_grade_ChangedAt,
                                    v.SU_holder_OB_item_GRD_grade_PositedAt
                                ) pre
                            WHERE
                                pre.SU_ID_holder = v.SU_ID_holder
                            AND
                                pre.OB_ID_item = v.OB_ID_item
                            AND
                                pre.SU_holder_OB_item_GRD_grade_ChangedAt < v.SU_holder_OB_item_GRD_grade_ChangedAt
                            AND
                                pre.SU_holder_OB_item_GRD_grade_Assertion = v.SU_holder_OB_item_GRD_grade_Assertion
                            ORDER BY
                                pre.SU_holder_OB_item_GRD_grade_ChangedAt DESC,
                                pre.SU_holder_OB_item_GRD_grade_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_grade = v.GRD_ID_grade
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.GRD_ID_grade
                            FROM
                                [dbo].[fSU_holder_OB_item_GRD_grade] (
                                    v.SU_holder_OB_item_GRD_grade_Positor,
                                    v.SU_holder_OB_item_GRD_grade_ChangedAt,
                                    v.SU_holder_OB_item_GRD_grade_PositedAt
                                ) fol
                            WHERE
                                fol.SU_ID_holder = v.SU_ID_holder
                            AND
                                fol.OB_ID_item = v.OB_ID_item
                            AND
                                fol.SU_holder_OB_item_GRD_grade_ChangedAt > v.SU_holder_OB_item_GRD_grade_ChangedAt
                            AND
                                fol.SU_holder_OB_item_GRD_grade_Assertion = v.SU_holder_OB_item_GRD_grade_Assertion
                            ORDER BY
                                fol.SU_holder_OB_item_GRD_grade_ChangedAt ASC,
                                fol.SU_holder_OB_item_GRD_grade_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_grade = v.GRD_ID_grade
                    )
                    THEN 'R' -- restatement of the following version
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
        ON
            p.SU_ID_holder = v.SU_ID_holder
        AND
            p.OB_ID_item = v.OB_ID_item
        AND
            p.GRD_ID_grade = v.GRD_ID_grade
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
        WHERE
            v.SU_holder_OB_item_GRD_grade_Version = @currentVersion;
        INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Posit] (
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade
        FROM
            @inserted
        WHERE
            SU_holder_OB_item_GRD_grade_Version = @currentVersion
        AND
            SU_holder_OB_item_GRD_grade_StatementType in ('N','R');
        INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Reliability
        )
        SELECT
            v.Metadata_SU_holder_OB_item_GRD_grade,
            p.SU_holder_OB_item_GRD_grade_ID,
            v.SU_holder_OB_item_GRD_grade_Positor,
            v.SU_holder_OB_item_GRD_grade_PositedAt,
            v.SU_holder_OB_item_GRD_grade_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
        ON
            p.SU_ID_holder = v.SU_ID_holder
        AND
            p.OB_ID_item = v.OB_ID_item
        AND
            p.GRD_ID_grade = v.GRD_ID_grade
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
        WHERE
            v.SU_holder_OB_item_GRD_grade_Version = @currentVersion
        AND
            v.SU_holder_OB_item_GRD_grade_StatementType in ('S','N','D','R');
        -- indecisive: what a positor holds for the identifiers at the same changing time may not contradict itself: a
        -- positive reliability counts as it is and a negative one as one plus it, and they may not sum up to more than one
        -- (non-contradiction)
        SET @message = (
            SELECT TOP 1
                v.SU_ID_holder,
                v.OB_ID_item,
                v.SU_holder_OB_item_GRD_grade_ChangedAt,
                v.SU_holder_OB_item_GRD_grade_Positor,
                v.SU_holder_OB_item_GRD_grade_PositedAt
            FROM
                @inserted v
            CROSS APPLY (
                SELECT
                    sum(CASE
                        WHEN a.SU_holder_OB_item_GRD_grade_Reliability > 0 THEN a.SU_holder_OB_item_GRD_grade_Reliability
                        ELSE 1 + a.SU_holder_OB_item_GRD_grade_Reliability
                    END) AS total
                FROM
                    [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
                JOIN
                    [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
                ON
                    a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
                AND
                    a.SU_holder_OB_item_GRD_grade_Positor = v.SU_holder_OB_item_GRD_grade_Positor
                AND
                    a.SU_holder_OB_item_GRD_grade_PositedAt = (
                        SELECT
                            max(s.SU_holder_OB_item_GRD_grade_PositedAt)
                        FROM
                            [dbo].[SU_holder_OB_item_GRD_grade_Annex] s
                        WHERE
                            s.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
                        AND
                            s.SU_holder_OB_item_GRD_grade_Positor = v.SU_holder_OB_item_GRD_grade_Positor
                        AND
                            s.SU_holder_OB_item_GRD_grade_PositedAt <= v.SU_holder_OB_item_GRD_grade_PositedAt
                    )
                WHERE
                    p.SU_ID_holder = v.SU_ID_holder
                AND
                    p.OB_ID_item = v.OB_ID_item
                AND
                    p.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
                AND
                    a.SU_holder_OB_item_GRD_grade_Reliability <> 0
            ) held
            WHERE
                v.SU_holder_OB_item_GRD_grade_Version = @currentVersion
            AND
                v.SU_holder_OB_item_GRD_grade_Reliability <> 0
            AND
                held.total > 1
            FOR XML PATH('')
        );
        IF @message is not null
        BEGIN
            SET @message = 'Contradiction in SU_holder_OB_item_GRD_grade for: ' + @message;
            RAISERROR(@message, 16, 1);
            ROLLBACK;
            RETURN;
        END
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_holder_OB_item_GRD_grade] ON [dbo].[lSU_holder_OB_item_GRD_grade]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ChangedAt,
        i.SU_ID_holder,
        i.OB_ID_item,
        ISNULL(i.GRD_ID_grade, [GRD_grade].GRD_ID),
        ISNULL(i.SU_holder_OB_item_GRD_grade_Positor, i.Positor),
        i.SU_holder_OB_item_GRD_grade_PositedAt,
        i.SU_holder_OB_item_GRD_grade_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_holder_OB_item_GRD_grade] ON [dbo].[lSU_holder_OB_item_GRD_grade]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_holder_OB_item_GRD_grade_Assertion))
        RAISERROR('The computed assertion column SU_holder_OB_item_GRD_grade_Assertion is not updatable.', 16, 1);
    IF(UPDATE(SU_holder_OB_item_GRD_grade_ID))
        RAISERROR('The identity column SU_holder_OB_item_GRD_grade_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ID_holder))
        RAISERROR('The identity column SU_ID_holder is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_item))
        RAISERROR('The identity column OB_ID_item is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ID,
        ISNULL(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_Positor) THEN i.SU_holder_OB_item_GRD_grade_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt
            WHEN UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    WHERE
        i.SU_holder_OB_item_GRD_grade_ID is not null
    AND (
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is null
    );
    -- indecisive: other values at the same changing time are a correction, which retracts the shown posit first, so
    -- that the new values are not taken for an alternative to it
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        d.SU_holder_OB_item_GRD_grade_ID,
        d.SU_holder_OB_item_GRD_grade_Positor,
        cast(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt ELSE @now END as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    JOIN
        deleted d
    ON
        d.SU_holder_OB_item_GRD_grade_ID = i.SU_holder_OB_item_GRD_grade_ID
    AND
        d.SU_holder_OB_item_GRD_grade_Positor = i.SU_holder_OB_item_GRD_grade_Positor
    WHERE (
        d.GRD_ID_grade <> CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
    )
    AND
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is not null
    AND
        UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt)
    AND
        d.SU_holder_OB_item_GRD_grade_ChangedAt = i.SU_holder_OB_item_GRD_grade_ChangedAt
    AND
        d.SU_holder_OB_item_GRD_grade_Positor = ISNULL(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_Positor) THEN i.SU_holder_OB_item_GRD_grade_Positor ELSE i.Positor END, 0)
    AND
        d.SU_holder_OB_item_GRD_grade_PositedAt < cast(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt ELSE @now END as datetime2)
    AND
        ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1) <> 0;
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        cast(CASE
            WHEN UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_holder_OB_item_GRD_grade_ID = i.SU_holder_OB_item_GRD_grade_ID
                AND
                    d.SU_holder_OB_item_GRD_grade_Positor = i.SU_holder_OB_item_GRD_grade_Positor
                AND
                    d.GRD_ID_grade = CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
            ) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_holder,
        i.OB_ID_item,
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END,
        ISNULL(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_Positor) THEN i.SU_holder_OB_item_GRD_grade_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) THEN i.SU_holder_OB_item_GRD_grade_PositedAt ELSE @now END as datetime2),
        ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    WHERE
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) OR
            UPDATE(SU_holder_OB_item_GRD_grade_PositedAt) OR
            UPDATE(SU_holder_OB_item_GRD_grade_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_holder_OB_item_GRD_grade_ID = i.SU_holder_OB_item_GRD_grade_ID
                AND
                    d.SU_holder_OB_item_GRD_grade_Positor = i.SU_holder_OB_item_GRD_grade_Positor
                AND
                    d.GRD_ID_grade = CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
                AND
                    d.SU_holder_OB_item_GRD_grade_Reliability = ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_holder_OB_item_GRD_grade] ON [dbo].[lSU_holder_OB_item_GRD_grade]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_Positor,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        d.Metadata_SU_holder_OB_item_GRD_grade,
        d.SU_holder_OB_item_GRD_grade_ID,
        d.SU_holder_OB_item_GRD_grade_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_keeper_OB_thing_GRD_rank', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_keeper_OB_thing_GRD_rank];
GO
CREATE TRIGGER [dbo].[it_SU_keeper_OB_thing_GRD_rank] ON [dbo].[SU_keeper_OB_thing_GRD_rank]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Version bigint not null,
        SU_keeper_OB_thing_GRD_rank_StatementType char(1) not null,
        SU_keeper_OB_thing_GRD_rank_Positor tinyint not null,
        SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
        SU_keeper_OB_thing_GRD_rank_Assertion char(1) not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_keeper_OB_thing_GRD_rank_Version,
            SU_keeper_OB_thing_GRD_rank_Positor,
            -- all roles: without decisiveness a positor may state alternatives for the identifiers in one insert
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_keeper,
            i.OB_ID_thing,
            i.GRD_ID_rank,
            ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now) AS SU_keeper_OB_thing_GRD_rank_ChangedAt,
            ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0) AS SU_keeper_OB_thing_GRD_rank_Positor,
            ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now) AS SU_keeper_OB_thing_GRD_rank_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
            JOIN
                [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            WHERE
                p.SU_ID_keeper = i.SU_ID_keeper
            AND
                p.OB_ID_thing = i.OB_ID_thing
            AND
                p.GRD_ID_rank = i.GRD_ID_rank
            AND
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now)
            AND
                a.SU_keeper_OB_thing_GRD_rank_Positor = ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0)
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now)
            AND
                a.SU_keeper_OB_thing_GRD_rank_Reliability <> ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_keeper_OB_thing_GRD_rank for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_keeper_OB_thing_GRD_rank, 0),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_keeper_OB_thing_GRD_rank_Positor,
                i.SU_ID_keeper,
                i.OB_ID_thing
            ORDER BY
                ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now),
                i.SU_keeper_OB_thing_GRD_rank_PositedAt ASC,
                i.SU_keeper_OB_thing_GRD_rank_Reliability ASC
        ),
        'X',
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1),
        CAST(
            case
                when i.SU_keeper_OB_thing_GRD_rank_Reliability > 0 then '+'
                when i.SU_keeper_OB_thing_GRD_rank_Reliability = 0 then '?'
                when i.SU_keeper_OB_thing_GRD_rank_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        i.GRD_ID_rank
    FROM
        inserted i
    WHERE
        i.SU_ID_keeper is not null
    AND
        i.OB_ID_thing is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
            JOIN
                [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            WHERE
                p.SU_ID_keeper = i.SU_ID_keeper
            AND
                p.OB_ID_thing = i.OB_ID_thing
            AND
                p.GRD_ID_rank = i.GRD_ID_rank
            AND
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now)
            AND
                a.SU_keeper_OB_thing_GRD_rank_Positor = ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, 0)
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt = ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(SU_keeper_OB_thing_GRD_rank_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_keeper_OB_thing_GRD_rank_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_keeper_OB_thing_GRD_rank_ID
                        FROM
                            [dbo].[tSU_keeper_OB_thing_GRD_rank](v.SU_keeper_OB_thing_GRD_rank_Positor, v.SU_keeper_OB_thing_GRD_rank_ChangedAt, v.SU_keeper_OB_thing_GRD_rank_PositedAt, v.SU_keeper_OB_thing_GRD_rank_Assertion) t
                        WHERE
                            t.SU_keeper_OB_thing_GRD_rank_Reliability = v.SU_keeper_OB_thing_GRD_rank_Reliability
                        AND
                            t.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
                        AND
                            t.SU_ID_keeper = v.SU_ID_keeper
                        AND
                            t.OB_ID_thing = v.OB_ID_thing
                        AND
                            t.GRD_ID_rank = v.GRD_ID_rank
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_keeper_OB_thing_GRD_rank_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.GRD_ID_rank
                            FROM
                                [dbo].[rSU_keeper_OB_thing_GRD_rank] (
                                    v.SU_keeper_OB_thing_GRD_rank_Positor,
                                    v.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                                    v.SU_keeper_OB_thing_GRD_rank_PositedAt
                                ) pre
                            WHERE
                                pre.SU_ID_keeper = v.SU_ID_keeper
                            AND
                                pre.OB_ID_thing = v.OB_ID_thing
                            AND
                                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt < v.SU_keeper_OB_thing_GRD_rank_ChangedAt
                            AND
                                pre.SU_keeper_OB_thing_GRD_rank_Assertion = v.SU_keeper_OB_thing_GRD_rank_Assertion
                            ORDER BY
                                pre.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                                pre.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_rank = v.GRD_ID_rank
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.GRD_ID_rank
                            FROM
                                [dbo].[fSU_keeper_OB_thing_GRD_rank] (
                                    v.SU_keeper_OB_thing_GRD_rank_Positor,
                                    v.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                                    v.SU_keeper_OB_thing_GRD_rank_PositedAt
                                ) fol
                            WHERE
                                fol.SU_ID_keeper = v.SU_ID_keeper
                            AND
                                fol.OB_ID_thing = v.OB_ID_thing
                            AND
                                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt > v.SU_keeper_OB_thing_GRD_rank_ChangedAt
                            AND
                                fol.SU_keeper_OB_thing_GRD_rank_Assertion = v.SU_keeper_OB_thing_GRD_rank_Assertion
                            ORDER BY
                                fol.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC,
                                fol.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                        ) s
                        WHERE
                            s.GRD_ID_rank = v.GRD_ID_rank
                    )
                    THEN 'F' -- the following version restates this one, so it is retracted
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
        ON
            p.SU_ID_keeper = v.SU_ID_keeper
        AND
            p.OB_ID_thing = v.OB_ID_thing
        AND
            p.GRD_ID_rank = v.GRD_ID_rank
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
        WHERE
            v.SU_keeper_OB_thing_GRD_rank_Version = @currentVersion;
        INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] (
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank
        FROM
            @inserted
        WHERE
            SU_keeper_OB_thing_GRD_rank_Version = @currentVersion
        AND
            SU_keeper_OB_thing_GRD_rank_StatementType in ('N','F');
        -- retract the following versions that the new ones make restatements
        INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        )
        SELECT
            v.Metadata_SU_keeper_OB_thing_GRD_rank,
            fol.SU_keeper_OB_thing_GRD_rank_ID,
            v.SU_keeper_OB_thing_GRD_rank_Positor,
            v.SU_keeper_OB_thing_GRD_rank_PositedAt,
            0
        FROM
            @inserted v
        CROSS APPLY (
            SELECT TOP 1
                f.SU_keeper_OB_thing_GRD_rank_ID,
                f.GRD_ID_rank
            FROM
                [dbo].[fSU_keeper_OB_thing_GRD_rank] (
                    v.SU_keeper_OB_thing_GRD_rank_Positor,
                    v.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    v.SU_keeper_OB_thing_GRD_rank_PositedAt
                ) f
            WHERE
                f.SU_ID_keeper = v.SU_ID_keeper
            AND
                f.OB_ID_thing = v.OB_ID_thing
            AND
                f.SU_keeper_OB_thing_GRD_rank_ChangedAt > v.SU_keeper_OB_thing_GRD_rank_ChangedAt
            AND
                f.SU_keeper_OB_thing_GRD_rank_Assertion = v.SU_keeper_OB_thing_GRD_rank_Assertion
            ORDER BY
                f.SU_keeper_OB_thing_GRD_rank_ChangedAt ASC,
                f.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        ) fol
        WHERE
            v.SU_keeper_OB_thing_GRD_rank_Version = @currentVersion
        AND
            v.SU_keeper_OB_thing_GRD_rank_StatementType = 'F'
        AND
            fol.GRD_ID_rank = v.GRD_ID_rank;
        INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Reliability
        )
        SELECT
            v.Metadata_SU_keeper_OB_thing_GRD_rank,
            p.SU_keeper_OB_thing_GRD_rank_ID,
            v.SU_keeper_OB_thing_GRD_rank_Positor,
            v.SU_keeper_OB_thing_GRD_rank_PositedAt,
            v.SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
        ON
            p.SU_ID_keeper = v.SU_ID_keeper
        AND
            p.OB_ID_thing = v.OB_ID_thing
        AND
            p.GRD_ID_rank = v.GRD_ID_rank
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
        WHERE
            v.SU_keeper_OB_thing_GRD_rank_Version = @currentVersion
        AND
            v.SU_keeper_OB_thing_GRD_rank_StatementType in ('S','N','F');
        -- indecisive: what a positor holds for the identifiers at the same changing time may not contradict itself: a
        -- positive reliability counts as it is and a negative one as one plus it, and they may not sum up to more than one
        -- (non-contradiction)
        SET @message = (
            SELECT TOP 1
                v.SU_ID_keeper,
                v.OB_ID_thing,
                v.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                v.SU_keeper_OB_thing_GRD_rank_Positor,
                v.SU_keeper_OB_thing_GRD_rank_PositedAt
            FROM
                @inserted v
            CROSS APPLY (
                SELECT
                    sum(CASE
                        WHEN a.SU_keeper_OB_thing_GRD_rank_Reliability > 0 THEN a.SU_keeper_OB_thing_GRD_rank_Reliability
                        ELSE 1 + a.SU_keeper_OB_thing_GRD_rank_Reliability
                    END) AS total
                FROM
                    [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
                JOIN
                    [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
                ON
                    a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Positor = v.SU_keeper_OB_thing_GRD_rank_Positor
                AND
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt = (
                        SELECT
                            max(s.SU_keeper_OB_thing_GRD_rank_PositedAt)
                        FROM
                            [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] s
                        WHERE
                            s.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
                        AND
                            s.SU_keeper_OB_thing_GRD_rank_Positor = v.SU_keeper_OB_thing_GRD_rank_Positor
                        AND
                            s.SU_keeper_OB_thing_GRD_rank_PositedAt <= v.SU_keeper_OB_thing_GRD_rank_PositedAt
                    )
                WHERE
                    p.SU_ID_keeper = v.SU_ID_keeper
                AND
                    p.OB_ID_thing = v.OB_ID_thing
                AND
                    p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
                AND
                    a.SU_keeper_OB_thing_GRD_rank_Reliability <> 0
            ) held
            WHERE
                v.SU_keeper_OB_thing_GRD_rank_Version = @currentVersion
            AND
                v.SU_keeper_OB_thing_GRD_rank_Reliability <> 0
            AND
                held.total > 1
            FOR XML PATH('')
        );
        IF @message is not null
        BEGIN
            SET @message = 'Contradiction in SU_keeper_OB_thing_GRD_rank for: ' + @message;
            RAISERROR(@message, 16, 1);
            ROLLBACK;
            RETURN;
        END
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_keeper_OB_thing_GRD_rank] ON [dbo].[lSU_keeper_OB_thing_GRD_rank]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        i.SU_ID_keeper,
        i.OB_ID_thing,
        ISNULL(i.GRD_ID_rank, [GRD_rank].GRD_ID),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Positor, i.Positor),
        i.SU_keeper_OB_thing_GRD_rank_PositedAt,
        i.SU_keeper_OB_thing_GRD_rank_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_keeper_OB_thing_GRD_rank] ON [dbo].[lSU_keeper_OB_thing_GRD_rank]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_keeper_OB_thing_GRD_rank_Assertion))
        RAISERROR('The computed assertion column SU_keeper_OB_thing_GRD_rank_Assertion is not updatable.', 16, 1);
    IF(UPDATE(SU_keeper_OB_thing_GRD_rank_ID))
        RAISERROR('The identity column SU_keeper_OB_thing_GRD_rank_ID is not updatable.', 16, 1);
    IF(UPDATE(SU_ID_keeper))
        RAISERROR('The identity column SU_ID_keeper is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_thing))
        RAISERROR('The identity column OB_ID_thing is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ID,
        ISNULL(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) THEN i.SU_keeper_OB_thing_GRD_rank_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt
            WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    WHERE
        i.SU_keeper_OB_thing_GRD_rank_ID is not null
    AND (
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is null
    );
    -- indecisive: other values at the same changing time are a correction, which retracts the shown posit first, so
    -- that the new values are not taken for an alternative to it
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        d.SU_keeper_OB_thing_GRD_rank_ID,
        d.SU_keeper_OB_thing_GRD_rank_Positor,
        cast(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt ELSE @now END as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    JOIN
        deleted d
    ON
        d.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID
    AND
        d.SU_keeper_OB_thing_GRD_rank_Positor = i.SU_keeper_OB_thing_GRD_rank_Positor
    WHERE (
        d.GRD_ID_rank <> CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
    )
    AND
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is not null
    AND
        UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt)
    AND
        d.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        d.SU_keeper_OB_thing_GRD_rank_Positor = ISNULL(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) THEN i.SU_keeper_OB_thing_GRD_rank_Positor ELSE i.Positor END, 0)
    AND
        d.SU_keeper_OB_thing_GRD_rank_PositedAt < cast(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt ELSE @now END as datetime2)
    AND
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1) <> 0;
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        cast(CASE
            WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID
                AND
                    d.SU_keeper_OB_thing_GRD_rank_Positor = i.SU_keeper_OB_thing_GRD_rank_Positor
                AND
                    d.GRD_ID_rank = CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
            ) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END,
        ISNULL(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) THEN i.SU_keeper_OB_thing_GRD_rank_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) THEN i.SU_keeper_OB_thing_GRD_rank_PositedAt ELSE @now END as datetime2),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    WHERE
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) OR
            UPDATE(SU_keeper_OB_thing_GRD_rank_PositedAt) OR
            UPDATE(SU_keeper_OB_thing_GRD_rank_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID
                AND
                    d.SU_keeper_OB_thing_GRD_rank_Positor = i.SU_keeper_OB_thing_GRD_rank_Positor
                AND
                    d.GRD_ID_rank = CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
                AND
                    d.SU_keeper_OB_thing_GRD_rank_Reliability = ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_keeper_OB_thing_GRD_rank] ON [dbo].[lSU_keeper_OB_thing_GRD_rank]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_Positor,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        d.Metadata_SU_keeper_OB_thing_GRD_rank,
        d.SU_keeper_OB_thing_GRD_rank_ID,
        d.SU_keeper_OB_thing_GRD_rank_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itOB_part_SU_owner instead of INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_OB_part_SU_owner', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_OB_part_SU_owner];
GO
CREATE TRIGGER [dbo].[it_OB_part_SU_owner] ON [dbo].[OB_part_SU_owner]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_OB_part_SU_owner int not null,
        OB_part_SU_owner_Version bigint not null,
        OB_part_SU_owner_StatementType char(1) not null,
        OB_part_SU_owner_Positor tinyint not null,
        OB_part_SU_owner_PositedAt datetime2 not null,
        OB_part_SU_owner_Reliability decimal(5,2) not null,
        OB_part_SU_owner_Assertion char(1) not null,
        OB_ID_part int not null,
        SU_ID_owner int not null,
        primary key (
            OB_part_SU_owner_Version,
            OB_part_SU_owner_Positor,
            -- all roles: without decisiveness a positor may state alternatives for the identifiers in one insert
            OB_ID_part,
            SU_ID_owner
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_ID_part,
            i.SU_ID_owner,
            ISNULL(i.OB_part_SU_owner_Positor, 0) AS OB_part_SU_owner_Positor,
            ISNULL(i.OB_part_SU_owner_PositedAt, @now) AS OB_part_SU_owner_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_part_SU_owner_Posit] p
            JOIN
                [dbo].[OB_part_SU_owner_Annex] a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            WHERE
                p.OB_ID_part = i.OB_ID_part
            AND
                p.SU_ID_owner = i.SU_ID_owner
            AND
                a.OB_part_SU_owner_Positor = ISNULL(i.OB_part_SU_owner_Positor, 0)
            AND
                a.OB_part_SU_owner_PositedAt = ISNULL(i.OB_part_SU_owner_PositedAt, @now)
            AND
                a.OB_part_SU_owner_Reliability <> ISNULL(i.OB_part_SU_owner_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in OB_part_SU_owner for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_OB_part_SU_owner, 0),
        DENSE_RANK() OVER (
            PARTITION BY
                i.OB_part_SU_owner_Positor,
                i.OB_ID_part
            ORDER BY
                i.OB_part_SU_owner_PositedAt ASC,
                i.OB_part_SU_owner_Reliability ASC
        ),
        'X',
        ISNULL(i.OB_part_SU_owner_Positor, 0),
        ISNULL(i.OB_part_SU_owner_PositedAt, @now),
        ISNULL(i.OB_part_SU_owner_Reliability, 1),
        CAST(
            case
                when i.OB_part_SU_owner_Reliability > 0 then '+'
                when i.OB_part_SU_owner_Reliability = 0 then '?'
                when i.OB_part_SU_owner_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.OB_ID_part,
        i.SU_ID_owner
    FROM
        inserted i
    WHERE
        i.OB_ID_part is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[OB_part_SU_owner_Posit] p
            JOIN
                [dbo].[OB_part_SU_owner_Annex] a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            WHERE
                p.OB_ID_part = i.OB_ID_part
            AND
                p.SU_ID_owner = i.SU_ID_owner
            AND
                a.OB_part_SU_owner_Positor = ISNULL(i.OB_part_SU_owner_Positor, 0)
            AND
                a.OB_part_SU_owner_PositedAt = ISNULL(i.OB_part_SU_owner_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(OB_part_SU_owner_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.OB_part_SU_owner_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.OB_part_SU_owner_ID
                        FROM
                            [dbo].[tOB_part_SU_owner](v.OB_part_SU_owner_Positor, DEFAULT, v.OB_part_SU_owner_PositedAt, v.OB_part_SU_owner_Assertion) t
                        WHERE
                            t.OB_part_SU_owner_Reliability = v.OB_part_SU_owner_Reliability
                        AND
                            t.OB_ID_part = v.OB_ID_part
                        AND
                            t.SU_ID_owner = v.SU_ID_owner
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.OB_part_SU_owner_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[OB_part_SU_owner_Posit] p
        ON
            p.OB_ID_part = v.OB_ID_part
        AND
            p.SU_ID_owner = v.SU_ID_owner
        WHERE
            v.OB_part_SU_owner_Version = @currentVersion;
        INSERT INTO [dbo].[OB_part_SU_owner_Posit] (
            OB_ID_part,
            SU_ID_owner
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            OB_ID_part,
            SU_ID_owner
        FROM
            @inserted
        WHERE
            OB_part_SU_owner_Version = @currentVersion
        AND
            OB_part_SU_owner_StatementType in ('N');
        INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_Positor,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Reliability
        )
        SELECT
            v.Metadata_OB_part_SU_owner,
            p.OB_part_SU_owner_ID,
            v.OB_part_SU_owner_Positor,
            v.OB_part_SU_owner_PositedAt,
            v.OB_part_SU_owner_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[OB_part_SU_owner_Posit] p
        ON
            p.OB_ID_part = v.OB_ID_part
        AND
            p.SU_ID_owner = v.SU_ID_owner
        WHERE
            v.OB_part_SU_owner_Version = @currentVersion
        AND
            v.OB_part_SU_owner_StatementType in ('S','N','D');
        -- indecisive: what a positor holds for the identifiers may not contradict itself: a
        -- positive reliability counts as it is and a negative one as one plus it, and they may not sum up to more than one
        -- (non-contradiction)
        SET @message = (
            SELECT TOP 1
                v.OB_ID_part,
                v.OB_part_SU_owner_Positor,
                v.OB_part_SU_owner_PositedAt
            FROM
                @inserted v
            CROSS APPLY (
                SELECT
                    sum(CASE
                        WHEN a.OB_part_SU_owner_Reliability > 0 THEN a.OB_part_SU_owner_Reliability
                        ELSE 1 + a.OB_part_SU_owner_Reliability
                    END) AS total
                FROM
                    [dbo].[OB_part_SU_owner_Posit] p
                JOIN
                    [dbo].[OB_part_SU_owner_Annex] a
                ON
                    a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
                AND
                    a.OB_part_SU_owner_Positor = v.OB_part_SU_owner_Positor
                AND
                    a.OB_part_SU_owner_PositedAt = (
                        SELECT
                            max(s.OB_part_SU_owner_PositedAt)
                        FROM
                            [dbo].[OB_part_SU_owner_Annex] s
                        WHERE
                            s.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
                        AND
                            s.OB_part_SU_owner_Positor = v.OB_part_SU_owner_Positor
                        AND
                            s.OB_part_SU_owner_PositedAt <= v.OB_part_SU_owner_PositedAt
                    )
                WHERE
                    p.OB_ID_part = v.OB_ID_part
                AND
                    a.OB_part_SU_owner_Reliability <> 0
            ) held
            WHERE
                v.OB_part_SU_owner_Version = @currentVersion
            AND
                v.OB_part_SU_owner_Reliability <> 0
            AND
                held.total > 1
            FOR XML PATH('')
        );
        IF @message is not null
        BEGIN
            SET @message = 'Contradiction in OB_part_SU_owner for: ' + @message;
            RAISERROR(@message, 16, 1);
            ROLLBACK;
            RETURN;
        END
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lOB_part_SU_owner] ON [dbo].[lOB_part_SU_owner]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner,
        ISNULL(i.OB_part_SU_owner_Positor, i.Positor),
        i.OB_part_SU_owner_PositedAt,
        i.OB_part_SU_owner_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lOB_part_SU_owner] ON [dbo].[lOB_part_SU_owner]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(OB_part_SU_owner_Assertion))
        RAISERROR('The computed assertion column OB_part_SU_owner_Assertion is not updatable.', 16, 1);
    IF(UPDATE(OB_part_SU_owner_ID))
        RAISERROR('The identity column OB_part_SU_owner_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_part))
        RAISERROR('The identity column OB_ID_part is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_part_SU_owner_ID,
        ISNULL(CASE WHEN UPDATE(OB_part_SU_owner_Positor) THEN i.OB_part_SU_owner_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.OB_part_SU_owner_ID is not null
    AND (
        i.SU_ID_owner is null
    );
    -- indecisive: other values are a correction, which retracts the shown posit first, so that the new values are not
    -- taken for an alternative to it
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        d.OB_part_SU_owner_ID,
        d.OB_part_SU_owner_Positor,
        cast(CASE WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt ELSE @now END as datetime2),
        0
    FROM
        inserted i
    JOIN
        deleted d
    ON
        d.OB_part_SU_owner_ID = i.OB_part_SU_owner_ID
    AND
        d.OB_part_SU_owner_Positor = i.OB_part_SU_owner_Positor
    WHERE (
        d.SU_ID_owner <> i.SU_ID_owner
    )
    AND
        i.SU_ID_owner is not null
    AND
        d.OB_part_SU_owner_Positor = ISNULL(CASE WHEN UPDATE(OB_part_SU_owner_Positor) THEN i.OB_part_SU_owner_Positor ELSE i.Positor END, 0)
    AND
        d.OB_part_SU_owner_PositedAt < cast(CASE WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt ELSE @now END as datetime2)
    AND
        ISNULL(i.OB_part_SU_owner_Reliability, 1) <> 0;
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner,
        ISNULL(CASE WHEN UPDATE(OB_part_SU_owner_Positor) THEN i.OB_part_SU_owner_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt ELSE @now END as datetime2),
        ISNULL(i.OB_part_SU_owner_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.SU_ID_owner is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(OB_part_SU_owner_PositedAt) OR
            UPDATE(OB_part_SU_owner_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.OB_part_SU_owner_ID = i.OB_part_SU_owner_ID
                AND
                    d.OB_part_SU_owner_Positor = i.OB_part_SU_owner_Positor
                AND
                    d.SU_ID_owner = i.SU_ID_owner
                AND
                    d.OB_part_SU_owner_Reliability = ISNULL(i.OB_part_SU_owner_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lOB_part_SU_owner] ON [dbo].[lOB_part_SU_owner]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_Positor,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        d.Metadata_OB_part_SU_owner,
        d.OB_part_SU_owner_ID,
        d.OB_part_SU_owner_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itSU_partner_SU_with instead of INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_SU_partner_SU_with', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_SU_partner_SU_with];
GO
CREATE TRIGGER [dbo].[it_SU_partner_SU_with] ON [dbo].[SU_partner_SU_with]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_SU_partner_SU_with int not null,
        SU_partner_SU_with_ChangedAt datetime2 not null,
        SU_partner_SU_with_Version bigint not null,
        SU_partner_SU_with_StatementType char(1) not null,
        SU_partner_SU_with_Positor tinyint not null,
        SU_partner_SU_with_PositedAt datetime2 not null,
        SU_partner_SU_with_Reliability decimal(5,2) not null,
        SU_partner_SU_with_Assertion char(1) not null,
        SU_ID_partner int not null,
        SU_ID_with int not null,
        primary key (
            SU_partner_SU_with_Version,
            SU_partner_SU_with_Positor,
            SU_ID_partner,
            SU_ID_with
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_partner,
            i.SU_ID_with,
            ISNULL(i.SU_partner_SU_with_ChangedAt, @now) AS SU_partner_SU_with_ChangedAt,
            ISNULL(i.SU_partner_SU_with_Positor, 0) AS SU_partner_SU_with_Positor,
            ISNULL(i.SU_partner_SU_with_PositedAt, @now) AS SU_partner_SU_with_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_partner_SU_with_Posit] p
            JOIN
                [dbo].[SU_partner_SU_with_Annex] a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            WHERE
                p.SU_ID_partner = i.SU_ID_partner
            AND
                p.SU_ID_with = i.SU_ID_with
            AND
                p.SU_partner_SU_with_ChangedAt = ISNULL(i.SU_partner_SU_with_ChangedAt, @now)
            AND
                a.SU_partner_SU_with_Positor = ISNULL(i.SU_partner_SU_with_Positor, 0)
            AND
                a.SU_partner_SU_with_PositedAt = ISNULL(i.SU_partner_SU_with_PositedAt, @now)
            AND
                a.SU_partner_SU_with_Reliability <> ISNULL(i.SU_partner_SU_with_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_partner_SU_with for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_partner_SU_with, 0),
        ISNULL(i.SU_partner_SU_with_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.SU_partner_SU_with_Positor,
                i.SU_ID_partner,
                i.SU_ID_with
            ORDER BY
                ISNULL(i.SU_partner_SU_with_ChangedAt, @now),
                i.SU_partner_SU_with_PositedAt ASC,
                i.SU_partner_SU_with_Reliability ASC
        ),
        'X',
        ISNULL(i.SU_partner_SU_with_Positor, 0),
        ISNULL(i.SU_partner_SU_with_PositedAt, @now),
        ISNULL(i.SU_partner_SU_with_Reliability, 1),
        CAST(
            case
                when i.SU_partner_SU_with_Reliability > 0 then '+'
                when i.SU_partner_SU_with_Reliability = 0 then '?'
                when i.SU_partner_SU_with_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.SU_ID_partner,
        i.SU_ID_with
    FROM
        inserted i
    WHERE
        i.SU_ID_partner is not null
    AND
        i.SU_ID_with is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[SU_partner_SU_with_Posit] p
            JOIN
                [dbo].[SU_partner_SU_with_Annex] a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            WHERE
                p.SU_ID_partner = i.SU_ID_partner
            AND
                p.SU_ID_with = i.SU_ID_with
            AND
                p.SU_partner_SU_with_ChangedAt = ISNULL(i.SU_partner_SU_with_ChangedAt, @now)
            AND
                a.SU_partner_SU_with_Positor = ISNULL(i.SU_partner_SU_with_Positor, 0)
            AND
                a.SU_partner_SU_with_PositedAt = ISNULL(i.SU_partner_SU_with_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(SU_partner_SU_with_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.SU_partner_SU_with_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.SU_partner_SU_with_ID
                        FROM
                            [dbo].[tSU_partner_SU_with](v.SU_partner_SU_with_Positor, v.SU_partner_SU_with_ChangedAt, v.SU_partner_SU_with_PositedAt, v.SU_partner_SU_with_Assertion) t
                        WHERE
                            t.SU_partner_SU_with_Reliability = v.SU_partner_SU_with_Reliability
                        AND
                            t.SU_partner_SU_with_ChangedAt = v.SU_partner_SU_with_ChangedAt
                        AND
                            t.SU_ID_partner = v.SU_ID_partner
                        AND
                            t.SU_ID_with = v.SU_ID_with
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.SU_partner_SU_with_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.SU_ID_partner,
                                pre.SU_ID_with
                            FROM
                                [dbo].[rSU_partner_SU_with] (
                                    v.SU_partner_SU_with_Positor,
                                    v.SU_partner_SU_with_ChangedAt,
                                    v.SU_partner_SU_with_PositedAt
                                ) pre
                            WHERE
                            (
                                    pre.SU_ID_partner = v.SU_ID_partner
                                AND
                                    pre.SU_ID_with = v.SU_ID_with
                            )
                            AND
                                pre.SU_partner_SU_with_ChangedAt < v.SU_partner_SU_with_ChangedAt
                            AND
                                pre.SU_partner_SU_with_Assertion = v.SU_partner_SU_with_Assertion
                            ORDER BY
                                pre.SU_partner_SU_with_ChangedAt DESC,
                                pre.SU_partner_SU_with_PositedAt DESC
                        ) s
                        WHERE
                            s.SU_ID_partner = v.SU_ID_partner
                        AND
                            s.SU_ID_with = v.SU_ID_with
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.SU_ID_partner,
                                fol.SU_ID_with
                            FROM
                                [dbo].[fSU_partner_SU_with] (
                                    v.SU_partner_SU_with_Positor,
                                    v.SU_partner_SU_with_ChangedAt,
                                    v.SU_partner_SU_with_PositedAt
                                ) fol
                            WHERE
                            (
                                    fol.SU_ID_partner = v.SU_ID_partner
                                AND
                                    fol.SU_ID_with = v.SU_ID_with
                            )
                            AND
                                fol.SU_partner_SU_with_ChangedAt > v.SU_partner_SU_with_ChangedAt
                            AND
                                fol.SU_partner_SU_with_Assertion = v.SU_partner_SU_with_Assertion
                            ORDER BY
                                fol.SU_partner_SU_with_ChangedAt ASC,
                                fol.SU_partner_SU_with_PositedAt DESC
                        ) s
                        WHERE
                            s.SU_ID_partner = v.SU_ID_partner
                        AND
                            s.SU_ID_with = v.SU_ID_with
                    )
                    THEN 'R' -- restatement of the following version
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[SU_partner_SU_with_Posit] p
        ON
            p.SU_ID_partner = v.SU_ID_partner
        AND
            p.SU_ID_with = v.SU_ID_with
        AND
            p.SU_partner_SU_with_ChangedAt = v.SU_partner_SU_with_ChangedAt
        WHERE
            v.SU_partner_SU_with_Version = @currentVersion;
        INSERT INTO [dbo].[SU_partner_SU_with_Posit] (
            SU_partner_SU_with_ChangedAt,
            SU_ID_partner,
            SU_ID_with
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            SU_partner_SU_with_ChangedAt,
            SU_ID_partner,
            SU_ID_with
        FROM
            @inserted
        WHERE
            SU_partner_SU_with_Version = @currentVersion
        AND
            SU_partner_SU_with_StatementType in ('N','R');
        INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_Positor,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Reliability
        )
        SELECT
            v.Metadata_SU_partner_SU_with,
            p.SU_partner_SU_with_ID,
            v.SU_partner_SU_with_Positor,
            v.SU_partner_SU_with_PositedAt,
            v.SU_partner_SU_with_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[SU_partner_SU_with_Posit] p
        ON
            p.SU_ID_partner = v.SU_ID_partner
        AND
            p.SU_ID_with = v.SU_ID_with
        AND
            p.SU_partner_SU_with_ChangedAt = v.SU_partner_SU_with_ChangedAt
        WHERE
            v.SU_partner_SU_with_Version = @currentVersion
        AND
            v.SU_partner_SU_with_StatementType in ('S','N','D','R');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lSU_partner_SU_with] ON [dbo].[lSU_partner_SU_with]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ChangedAt,
        i.SU_ID_partner,
        i.SU_ID_with,
        ISNULL(i.SU_partner_SU_with_Positor, i.Positor),
        i.SU_partner_SU_with_PositedAt,
        i.SU_partner_SU_with_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lSU_partner_SU_with] ON [dbo].[lSU_partner_SU_with]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(SU_partner_SU_with_Assertion))
        RAISERROR('The computed assertion column SU_partner_SU_with_Assertion is not updatable.', 16, 1);
    IF(UPDATE(SU_partner_SU_with_ID))
        RAISERROR('The identity column SU_partner_SU_with_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ID,
        ISNULL(CASE WHEN UPDATE(SU_partner_SU_with_Positor) THEN i.SU_partner_SU_with_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(SU_partner_SU_with_PositedAt) THEN i.SU_partner_SU_with_PositedAt
            WHEN UPDATE(SU_partner_SU_with_ChangedAt) THEN i.SU_partner_SU_with_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.SU_partner_SU_with_ID is not null
    AND (
        i.SU_ID_partner is null
    OR
        i.SU_ID_with is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        cast(CASE
            WHEN UPDATE(SU_partner_SU_with_ChangedAt) THEN i.SU_partner_SU_with_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_partner_SU_with_ID = i.SU_partner_SU_with_ID
                AND
                    d.SU_partner_SU_with_Positor = i.SU_partner_SU_with_Positor
                AND
                    d.SU_ID_partner = i.SU_ID_partner
                AND
                    d.SU_ID_with = i.SU_ID_with
            ) THEN i.SU_partner_SU_with_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_partner,
        i.SU_ID_with,
        ISNULL(CASE WHEN UPDATE(SU_partner_SU_with_Positor) THEN i.SU_partner_SU_with_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(SU_partner_SU_with_PositedAt) THEN i.SU_partner_SU_with_PositedAt ELSE @now END as datetime2),
        ISNULL(i.SU_partner_SU_with_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.SU_ID_partner is not null
    AND
        i.SU_ID_with is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(SU_partner_SU_with_ChangedAt) OR
            UPDATE(SU_partner_SU_with_PositedAt) OR
            UPDATE(SU_partner_SU_with_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_partner_SU_with_ID = i.SU_partner_SU_with_ID
                AND
                    d.SU_partner_SU_with_Positor = i.SU_partner_SU_with_Positor
                AND
                    d.SU_ID_partner = i.SU_ID_partner
                AND
                    d.SU_ID_with = i.SU_ID_with
                AND
                    d.SU_partner_SU_with_Reliability = ISNULL(i.SU_partner_SU_with_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lSU_partner_SU_with] ON [dbo].[lSU_partner_SU_with]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_Positor,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        d.Metadata_SU_partner_SU_with,
        d.SU_partner_SU_with_ID,
        d.SU_partner_SU_with_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
