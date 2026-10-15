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
    DECLARE @inserted TABLE (
        Metadata_SU_holder_OB_item_GRD_grade int not null,
        SU_holder_OB_item_GRD_grade_StatementType char(1) not null,
        SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_PositedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_Reliability decimal(5,2) not null,
        SU_ID_holder int not null,
        OB_ID_item int not null,
        GRD_ID_grade tinyint not null,
        primary key (
            SU_ID_holder asc,
            OB_ID_item asc,
            SU_holder_OB_item_GRD_grade_ChangedAt desc,
            SU_holder_OB_item_GRD_grade_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_holder,
            i.OB_ID_item,
            i.GRD_ID_grade,
            ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now) AS SU_holder_OB_item_GRD_grade_ChangedAt,
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
        CASE
            WHEN p.SU_holder_OB_item_GRD_grade_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_holder_OB_item_GRD_grade_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now),
        ISNULL(i.SU_holder_OB_item_GRD_grade_PositedAt, @now),
        ISNULL(i.SU_holder_OB_item_GRD_grade_Reliability, 1),
        i.SU_ID_holder,
        i.OB_ID_item,
        i.GRD_ID_grade
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
    ON
        p.SU_ID_holder = i.SU_ID_holder
    AND
        p.OB_ID_item = i.OB_ID_item
    AND
        p.GRD_ID_grade = i.GRD_ID_grade
    AND
        p.SU_holder_OB_item_GRD_grade_ChangedAt = i.SU_holder_OB_item_GRD_grade_ChangedAt
    LEFT JOIN
        [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
    ON
        a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
    AND
        a.SU_holder_OB_item_GRD_grade_PositedAt = i.SU_holder_OB_item_GRD_grade_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_holder_OB_item_GRD_grade_ID is null OR a.SU_holder_OB_item_GRD_grade_ID is null)
    AND
        i.SU_ID_holder is not null
    AND
        i.OB_ID_item is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_SU_holder_OB_item_GRD_grade,
        'X', -- existing data
        x.SU_holder_OB_item_GRD_grade_ChangedAt,
        x.SU_holder_OB_item_GRD_grade_PositedAt,
        x.SU_holder_OB_item_GRD_grade_Reliability,
        x.SU_ID_holder,
        x.OB_ID_item,
        x.GRD_ID_grade
    FROM (
        SELECT
            a.Metadata_SU_holder_OB_item_GRD_grade,
            p.SU_holder_OB_item_GRD_grade_ChangedAt,
            a.SU_holder_OB_item_GRD_grade_PositedAt,
            a.SU_holder_OB_item_GRD_grade_Reliability,
            p.SU_ID_holder,
            p.OB_ID_item,
            p.GRD_ID_grade,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.SU_ID_holder,
                    p.OB_ID_item,
                    p.SU_holder_OB_item_GRD_grade_ChangedAt,
                    a.SU_holder_OB_item_GRD_grade_PositedAt
                ORDER BY
                    a.SU_holder_OB_item_GRD_grade_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                SU_ID_holder,
                OB_ID_item
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
        ON
            p.SU_ID_holder = i.SU_ID_holder
        AND
            p.OB_ID_item = i.OB_ID_item
        JOIN
            [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
        ON
            a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        Metadata_SU_holder_OB_item_GRD_grade int not null,
        SU_holder_OB_item_GRD_grade_StatementType char(1) not null,
        SU_holder_OB_item_GRD_grade_ChangedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_PositedAt datetime2 not null,
        SU_holder_OB_item_GRD_grade_Reliability decimal(5,2) not null,
        SU_ID_holder int not null,
        OB_ID_item int not null,
        GRD_ID_grade tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_StatementType,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    SELECT
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_StatementType,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_holder_OB_item_GRD_grade_Reliability as previous_SU_holder_OB_item_GRD_grade_Reliability,
            fol.SU_holder_OB_item_GRD_grade_Reliability as following_SU_holder_OB_item_GRD_grade_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_holder_OB_item_GRD_grade_Reliability
            FROM
                @inserted p
            WHERE
                p.SU_ID_holder = a.SU_ID_holder
            AND
                p.OB_ID_item = a.OB_ID_item
            AND
                p.SU_holder_OB_item_GRD_grade_ChangedAt = a.SU_holder_OB_item_GRD_grade_ChangedAt
            AND
                p.SU_holder_OB_item_GRD_grade_PositedAt < a.SU_holder_OB_item_GRD_grade_PositedAt
            ORDER BY
                p.SU_holder_OB_item_GRD_grade_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_holder_OB_item_GRD_grade_Reliability
            FROM
                @inserted p
            WHERE
                p.SU_ID_holder = a.SU_ID_holder
            AND
                p.OB_ID_item = a.OB_ID_item
            AND
                p.SU_holder_OB_item_GRD_grade_ChangedAt = a.SU_holder_OB_item_GRD_grade_ChangedAt
            AND
                p.SU_holder_OB_item_GRD_grade_PositedAt > a.SU_holder_OB_item_GRD_grade_PositedAt
            ORDER BY
                p.SU_holder_OB_item_GRD_grade_PositedAt ASC
        ) fol
        WHERE
            (a.SU_holder_OB_item_GRD_grade_Reliability = 0 AND isnull(pre.SU_holder_OB_item_GRD_grade_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_holder_OB_item_GRD_grade_Reliability = 1 AND fol.SU_holder_OB_item_GRD_grade_Reliability = 0)
    ) i
    WHERE
        i.SU_holder_OB_item_GRD_grade_StatementType <> 'X'
    AND (
            (i.SU_holder_OB_item_GRD_grade_Reliability = 0 AND i.previous_SU_holder_OB_item_GRD_grade_Reliability = 1)
        OR
            (i.SU_holder_OB_item_GRD_grade_Reliability = 1 AND i.following_SU_holder_OB_item_GRD_grade_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Posit] (
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    FROM
        @inserted
    WHERE
        SU_holder_OB_item_GRD_grade_StatementType = 'P';
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        v.Metadata_SU_holder_OB_item_GRD_grade,
        p.SU_holder_OB_item_GRD_grade_ID,
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
        v.SU_holder_OB_item_GRD_grade_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect for the identifiers at the same changing time when
    -- that has other values (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade_Annex] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ID,
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        v.Metadata_SU_holder_OB_item_GRD_grade,
        e.SU_holder_OB_item_GRD_grade_ID,
        v.SU_holder_OB_item_GRD_grade_PositedAt,
        0
    FROM
        @inserted v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_holder_OB_item_GRD_grade_ID,
            p.GRD_ID_grade
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
        JOIN
            [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
        ON
            a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
        AND
            a.SU_holder_OB_item_GRD_grade_PositedAt = (
                SELECT
                    max(s.SU_holder_OB_item_GRD_grade_PositedAt)
                FROM
                    [dbo].[SU_holder_OB_item_GRD_grade_Annex] s
                WHERE
                    s.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
                AND
                    s.SU_holder_OB_item_GRD_grade_PositedAt < v.SU_holder_OB_item_GRD_grade_PositedAt
            )
        WHERE
            p.SU_ID_holder = v.SU_ID_holder
        AND
            p.OB_ID_item = v.OB_ID_item
        AND
            p.SU_holder_OB_item_GRD_grade_ChangedAt = v.SU_holder_OB_item_GRD_grade_ChangedAt
        AND
            a.SU_holder_OB_item_GRD_grade_Reliability = 1
        ORDER BY
            a.SU_holder_OB_item_GRD_grade_PositedAt DESC
    ) e
    WHERE
        v.SU_holder_OB_item_GRD_grade_StatementType in ('P', 'A')
    AND
        v.SU_holder_OB_item_GRD_grade_Reliability = 1
    AND (
        e.GRD_ID_grade <> v.GRD_ID_grade
    )
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade_Annex] x
        WHERE
            x.SU_holder_OB_item_GRD_grade_ID = e.SU_holder_OB_item_GRD_grade_ID
        AND
            x.SU_holder_OB_item_GRD_grade_PositedAt = v.SU_holder_OB_item_GRD_grade_PositedAt
    );
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
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ChangedAt,
        i.SU_ID_holder,
        i.OB_ID_item,
        ISNULL(i.GRD_ID_grade, [GRD_grade].GRD_ID),
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
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ID,
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
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade,
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
                    d.GRD_ID_grade = CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
            ) THEN i.SU_holder_OB_item_GRD_grade_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_holder,
        i.OB_ID_item,
        CASE WHEN UPDATE(grade_GRD_Grade) THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END,
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
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_holder_OB_item_GRD_grade_ID = i.SU_holder_OB_item_GRD_grade_ID
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
        SU_holder_OB_item_GRD_grade_PositedAt,
        SU_holder_OB_item_GRD_grade_Reliability
    )
    SELECT
        d.Metadata_SU_holder_OB_item_GRD_grade,
        d.SU_holder_OB_item_GRD_grade_ID,
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
    DECLARE @inserted TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_StatementType char(1) not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_ID_keeper asc,
            OB_ID_thing asc,
            SU_keeper_OB_thing_GRD_rank_ChangedAt desc,
            SU_keeper_OB_thing_GRD_rank_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_keeper,
            i.OB_ID_thing,
            i.GRD_ID_rank,
            ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now) AS SU_keeper_OB_thing_GRD_rank_ChangedAt,
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
        CASE
            WHEN p.SU_keeper_OB_thing_GRD_rank_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_keeper_OB_thing_GRD_rank_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_PositedAt, @now),
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_Reliability, 1),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        i.GRD_ID_rank
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    ON
        p.SU_ID_keeper = i.SU_ID_keeper
    AND
        p.OB_ID_thing = i.OB_ID_thing
    AND
        p.GRD_ID_rank = i.GRD_ID_rank
    AND
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
    LEFT JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = i.SU_keeper_OB_thing_GRD_rank_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_keeper_OB_thing_GRD_rank_ID is null OR a.SU_keeper_OB_thing_GRD_rank_ID is null)
    AND
        i.SU_ID_keeper is not null
    AND
        i.OB_ID_thing is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_SU_keeper_OB_thing_GRD_rank,
        'X', -- existing data
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        x.SU_keeper_OB_thing_GRD_rank_PositedAt,
        x.SU_keeper_OB_thing_GRD_rank_Reliability,
        x.SU_ID_keeper,
        x.OB_ID_thing,
        x.GRD_ID_rank
    FROM (
        SELECT
            a.Metadata_SU_keeper_OB_thing_GRD_rank,
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
            a.SU_keeper_OB_thing_GRD_rank_PositedAt,
            a.SU_keeper_OB_thing_GRD_rank_Reliability,
            p.SU_ID_keeper,
            p.OB_ID_thing,
            p.GRD_ID_rank,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.SU_ID_keeper,
                    p.OB_ID_thing,
                    p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                    a.SU_keeper_OB_thing_GRD_rank_PositedAt
                ORDER BY
                    a.SU_keeper_OB_thing_GRD_rank_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                SU_ID_keeper,
                OB_ID_thing
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
        ON
            p.SU_ID_keeper = i.SU_ID_keeper
        AND
            p.OB_ID_thing = i.OB_ID_thing
        JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
        ON
            a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_StatementType char(1) not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_StatementType,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_StatementType,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_keeper_OB_thing_GRD_rank_Reliability as previous_SU_keeper_OB_thing_GRD_rank_Reliability,
            fol.SU_keeper_OB_thing_GRD_rank_Reliability as following_SU_keeper_OB_thing_GRD_rank_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_keeper_OB_thing_GRD_rank_Reliability
            FROM
                @inserted p
            WHERE
                p.SU_ID_keeper = a.SU_ID_keeper
            AND
                p.OB_ID_thing = a.OB_ID_thing
            AND
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt = a.SU_keeper_OB_thing_GRD_rank_ChangedAt
            AND
                p.SU_keeper_OB_thing_GRD_rank_PositedAt < a.SU_keeper_OB_thing_GRD_rank_PositedAt
            ORDER BY
                p.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_keeper_OB_thing_GRD_rank_Reliability
            FROM
                @inserted p
            WHERE
                p.SU_ID_keeper = a.SU_ID_keeper
            AND
                p.OB_ID_thing = a.OB_ID_thing
            AND
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt = a.SU_keeper_OB_thing_GRD_rank_ChangedAt
            AND
                p.SU_keeper_OB_thing_GRD_rank_PositedAt > a.SU_keeper_OB_thing_GRD_rank_PositedAt
            ORDER BY
                p.SU_keeper_OB_thing_GRD_rank_PositedAt ASC
        ) fol
        WHERE
            (a.SU_keeper_OB_thing_GRD_rank_Reliability = 0 AND isnull(pre.SU_keeper_OB_thing_GRD_rank_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_keeper_OB_thing_GRD_rank_Reliability = 1 AND fol.SU_keeper_OB_thing_GRD_rank_Reliability = 0)
    ) i
    WHERE
        i.SU_keeper_OB_thing_GRD_rank_StatementType <> 'X'
    AND (
            (i.SU_keeper_OB_thing_GRD_rank_Reliability = 0 AND i.previous_SU_keeper_OB_thing_GRD_rank_Reliability = 1)
        OR
            (i.SU_keeper_OB_thing_GRD_rank_Reliability = 1 AND i.following_SU_keeper_OB_thing_GRD_rank_Reliability = 0)
        );
    -- remove remaining (dangling) retractions
    DELETE @inserted
    WHERE
        SU_keeper_OB_thing_GRD_rank_Reliability = 0;
    IF EXISTS (
        SELECT TOP 1
            SU_keeper_OB_thing_GRD_rank_StatementType
        FROM
            @inserted
        WHERE
            SU_keeper_OB_thing_GRD_rank_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @updated TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        previous_SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_ID_keeper asc,
            OB_ID_thing asc,
            SU_keeper_OB_thing_GRD_rank_ChangedAt desc,
            SU_keeper_OB_thing_GRD_rank_PositedAt desc
        )
    );
    INSERT INTO @updated (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        previous_SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        previous_SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_keeper_OB_thing_GRD_rank_PositedAt AS previous_SU_keeper_OB_thing_GRD_rank_PositedAt,
            pre.SU_keeper_OB_thing_GRD_rank_StatementType AS previous_SU_keeper_OB_thing_GRD_rank_StatementType
        FROM
            @inserted a
        CROSS APPLY (
            SELECT TOP 1
                *
            FROM
                @inserted s
            WHERE
                s.SU_ID_keeper = a.SU_ID_keeper
            AND
                s.OB_ID_thing = a.OB_ID_thing
            AND
                s.SU_keeper_OB_thing_GRD_rank_ChangedAt = a.SU_keeper_OB_thing_GRD_rank_ChangedAt
            AND
                s.SU_keeper_OB_thing_GRD_rank_PositedAt < a.SU_keeper_OB_thing_GRD_rank_PositedAt
            ORDER BY
                s.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        ) pre -- what is shown just before
        WHERE
            a.GRD_ID_rank = pre.GRD_ID_rank
        AND
            a.SU_keeper_OB_thing_GRD_rank_Reliability = pre.SU_keeper_OB_thing_GRD_rank_Reliability
    ) u
    WHERE
        u.previous_SU_keeper_OB_thing_GRD_rank_StatementType = 'A';
    DELETE a
    FROM
        @inserted a
    JOIN
        @updated u
    ON
        u.SU_ID_keeper = a.SU_ID_keeper
    AND
        u.OB_ID_thing = a.OB_ID_thing
    AND
        u.GRD_ID_rank = a.GRD_ID_rank
    AND
        u.SU_keeper_OB_thing_GRD_rank_ChangedAt = a.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        u.previous_SU_keeper_OB_thing_GRD_rank_PositedAt = a.SU_keeper_OB_thing_GRD_rank_PositedAt;
    END --- (only run if necessary) ---
    IF EXISTS (
        SELECT TOP 1
            SU_keeper_OB_thing_GRD_rank_StatementType
        FROM
            @inserted
        WHERE
            SU_keeper_OB_thing_GRD_rank_StatementType IN ('P', 'A')
    )
    BEGIN --- (only run if necessary) ---
    DECLARE @restated TABLE (
        Metadata_SU_keeper_OB_thing_GRD_rank int not null,
        SU_keeper_OB_thing_GRD_rank_StatementType char(1) not null,
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_PositedAt datetime2 not null,
        SU_keeper_OB_thing_GRD_rank_Reliability decimal(5,2) not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null
    );
    INSERT INTO @restated (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_StatementType,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        x.Metadata_SU_keeper_OB_thing_GRD_rank,
        CASE
            WHEN x.previous_SU_keeper_OB_thing_GRD_rank_PositedAt < x.SU_keeper_OB_thing_GRD_rank_PositedAt THEN 'D' -- physical delete
            ELSE 'A' -- logical delete
        END,
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        CASE
            WHEN x.previous_SU_keeper_OB_thing_GRD_rank_PositedAt < x.SU_keeper_OB_thing_GRD_rank_PositedAt THEN x.SU_keeper_OB_thing_GRD_rank_PositedAt
            ELSE x.previous_SU_keeper_OB_thing_GRD_rank_PositedAt
        END,
        0, -- quench the existing restatements
        x.SU_ID_keeper,
        x.OB_ID_thing,
        x.GRD_ID_rank
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_keeper_OB_thing_GRD_rank_PositedAt as previous_SU_keeper_OB_thing_GRD_rank_PositedAt
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                h.*
            FROM
                @inserted h
            WHERE
                h.SU_ID_keeper = a.SU_ID_keeper
            AND
                h.OB_ID_thing = a.OB_ID_thing
            AND
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt < a.SU_keeper_OB_thing_GRD_rank_ChangedAt
            ORDER BY
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC,
                h.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
        ) pre
        WHERE
            a.SU_ID_keeper = pre.SU_ID_keeper
        AND
            a.OB_ID_thing = pre.OB_ID_thing
        AND
            a.GRD_ID_rank = pre.GRD_ID_rank
    ) x
    WHERE
        x.SU_keeper_OB_thing_GRD_rank_StatementType = 'X'; -- quench
    -- add the quenches
    INSERT INTO @inserted
    SELECT
        *
    FROM (
        DELETE @restated
        OUTPUT deleted.*
        WHERE SU_keeper_OB_thing_GRD_rank_StatementType = 'A'
    ) d;
    -- perform any remaining physical deletes
    DELETE a
    FROM
        @restated i
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    ON
        p.SU_ID_keeper = i.SU_ID_keeper
    AND
        p.OB_ID_thing = i.OB_ID_thing
    AND
        p.GRD_ID_rank = i.GRD_ID_rank
    AND
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = i.SU_keeper_OB_thing_GRD_rank_PositedAt;
    END --- (only run if necessary) ---
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] (
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    FROM
        @inserted
    WHERE
        SU_keeper_OB_thing_GRD_rank_StatementType = 'P';
    UPDATE a
    SET
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = u.previous_SU_keeper_OB_thing_GRD_rank_PositedAt
    FROM
        @updated u
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    ON
        p.SU_ID_keeper = u.SU_ID_keeper
    AND
        p.OB_ID_thing = u.OB_ID_thing
    AND
        p.GRD_ID_rank = u.GRD_ID_rank
    AND
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt = u.SU_keeper_OB_thing_GRD_rank_ChangedAt
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
    AND
        a.SU_keeper_OB_thing_GRD_rank_PositedAt = u.SU_keeper_OB_thing_GRD_rank_PositedAt;
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        v.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ID,
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
        v.SU_keeper_OB_thing_GRD_rank_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect for the identifiers at the same changing time when
    -- that has other values (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ID,
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        v.Metadata_SU_keeper_OB_thing_GRD_rank,
        e.SU_keeper_OB_thing_GRD_rank_ID,
        v.SU_keeper_OB_thing_GRD_rank_PositedAt,
        0
    FROM
        @inserted v
    CROSS APPLY (
        SELECT TOP 1
            p.SU_keeper_OB_thing_GRD_rank_ID,
            p.GRD_ID_rank
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
        JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
        ON
            a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
        AND
            a.SU_keeper_OB_thing_GRD_rank_PositedAt = (
                SELECT
                    max(s.SU_keeper_OB_thing_GRD_rank_PositedAt)
                FROM
                    [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] s
                WHERE
                    s.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
                AND
                    s.SU_keeper_OB_thing_GRD_rank_PositedAt < v.SU_keeper_OB_thing_GRD_rank_PositedAt
            )
        WHERE
            p.SU_ID_keeper = v.SU_ID_keeper
        AND
            p.OB_ID_thing = v.OB_ID_thing
        AND
            p.SU_keeper_OB_thing_GRD_rank_ChangedAt = v.SU_keeper_OB_thing_GRD_rank_ChangedAt
        AND
            a.SU_keeper_OB_thing_GRD_rank_Reliability = 1
        ORDER BY
            a.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
    ) e
    WHERE
        v.SU_keeper_OB_thing_GRD_rank_StatementType in ('P', 'A')
    AND
        v.SU_keeper_OB_thing_GRD_rank_Reliability = 1
    AND (
        e.GRD_ID_rank <> v.GRD_ID_rank
    )
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] x
        WHERE
            x.SU_keeper_OB_thing_GRD_rank_ID = e.SU_keeper_OB_thing_GRD_rank_ID
        AND
            x.SU_keeper_OB_thing_GRD_rank_PositedAt = v.SU_keeper_OB_thing_GRD_rank_PositedAt
    );
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
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        i.SU_ID_keeper,
        i.OB_ID_thing,
        ISNULL(i.GRD_ID_rank, [GRD_rank].GRD_ID),
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
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ID,
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
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank,
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
                    d.GRD_ID_rank = CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
            ) THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        CASE WHEN UPDATE(rank_GRD_Grade) THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END,
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
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_keeper_OB_thing_GRD_rank_ID = i.SU_keeper_OB_thing_GRD_rank_ID
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
        SU_keeper_OB_thing_GRD_rank_PositedAt,
        SU_keeper_OB_thing_GRD_rank_Reliability
    )
    SELECT
        d.Metadata_SU_keeper_OB_thing_GRD_rank,
        d.SU_keeper_OB_thing_GRD_rank_ID,
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
    DECLARE @inserted TABLE (
        Metadata_OB_part_SU_owner int not null,
        OB_part_SU_owner_StatementType char(1) not null,
        OB_part_SU_owner_PositedAt datetime2 not null,
        OB_part_SU_owner_Reliability decimal(5,2) not null,
        OB_ID_part int not null,
        SU_ID_owner int not null,
        primary key (
            OB_ID_part asc,
            OB_part_SU_owner_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_ID_part,
            i.SU_ID_owner,
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
        CASE
            WHEN p.OB_part_SU_owner_ID is null
            THEN 'P' -- new posit
            WHEN a.OB_part_SU_owner_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.OB_part_SU_owner_PositedAt, @now),
        ISNULL(i.OB_part_SU_owner_Reliability, 1),
        i.OB_ID_part,
        i.SU_ID_owner
    FROM
        inserted i
    LEFT JOIN
        [dbo].[OB_part_SU_owner_Posit] p
    ON
        p.OB_ID_part = i.OB_ID_part
    AND
        p.SU_ID_owner = i.SU_ID_owner
    LEFT JOIN
        [dbo].[OB_part_SU_owner_Annex] a
    ON
        a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
    AND
        a.OB_part_SU_owner_PositedAt = i.OB_part_SU_owner_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.OB_part_SU_owner_ID is null OR a.OB_part_SU_owner_ID is null)
    AND
        i.OB_ID_part is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_OB_part_SU_owner,
        'X', -- existing data
        x.OB_part_SU_owner_PositedAt,
        x.OB_part_SU_owner_Reliability,
        x.OB_ID_part,
        x.SU_ID_owner
    FROM (
        SELECT
            a.Metadata_OB_part_SU_owner,
            a.OB_part_SU_owner_PositedAt,
            a.OB_part_SU_owner_Reliability,
            p.OB_ID_part,
            p.SU_ID_owner,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.OB_ID_part,
                    a.OB_part_SU_owner_PositedAt
                ORDER BY
                    a.OB_part_SU_owner_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                OB_ID_part
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[OB_part_SU_owner_Posit] p
        ON
            p.OB_ID_part = i.OB_ID_part
        JOIN
            [dbo].[OB_part_SU_owner_Annex] a
        ON
            a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        Metadata_OB_part_SU_owner int not null,
        OB_part_SU_owner_StatementType char(1) not null,
        OB_part_SU_owner_PositedAt datetime2 not null,
        OB_part_SU_owner_Reliability decimal(5,2) not null,
        OB_ID_part int not null,
        SU_ID_owner int not null
    );
    INSERT INTO @retracted (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_StatementType,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability,
        OB_ID_part,
        SU_ID_owner
    )
    SELECT
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_StatementType,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability,
        OB_ID_part,
        SU_ID_owner
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.OB_part_SU_owner_Reliability as previous_OB_part_SU_owner_Reliability,
            fol.OB_part_SU_owner_Reliability as following_OB_part_SU_owner_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.OB_part_SU_owner_Reliability
            FROM
                @inserted p
            WHERE
                p.OB_ID_part = a.OB_ID_part
            AND
                p.OB_part_SU_owner_PositedAt < a.OB_part_SU_owner_PositedAt
            ORDER BY
                p.OB_part_SU_owner_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.OB_part_SU_owner_Reliability
            FROM
                @inserted p
            WHERE
                p.OB_ID_part = a.OB_ID_part
            AND
                p.OB_part_SU_owner_PositedAt > a.OB_part_SU_owner_PositedAt
            ORDER BY
                p.OB_part_SU_owner_PositedAt ASC
        ) fol
        WHERE
            (a.OB_part_SU_owner_Reliability = 0 AND isnull(pre.OB_part_SU_owner_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.OB_part_SU_owner_Reliability = 1 AND fol.OB_part_SU_owner_Reliability = 0)
    ) i
    WHERE
        i.OB_part_SU_owner_StatementType <> 'X'
    AND (
            (i.OB_part_SU_owner_Reliability = 0 AND i.previous_OB_part_SU_owner_Reliability = 1)
        OR
            (i.OB_part_SU_owner_Reliability = 1 AND i.following_OB_part_SU_owner_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[OB_part_SU_owner_Posit] (
        OB_ID_part,
        SU_ID_owner
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        OB_ID_part,
        SU_ID_owner
    FROM
        @inserted
    WHERE
        OB_part_SU_owner_StatementType = 'P';
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        v.Metadata_OB_part_SU_owner,
        p.OB_part_SU_owner_ID,
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
        v.OB_part_SU_owner_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect for the identifiers when
    -- that has other values (a correction), so that one posit at a time is asserted
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        v.Metadata_OB_part_SU_owner,
        e.OB_part_SU_owner_ID,
        v.OB_part_SU_owner_PositedAt,
        0
    FROM
        @inserted v
    CROSS APPLY (
        SELECT TOP 1
            p.OB_part_SU_owner_ID,
            p.SU_ID_owner
        FROM
            [dbo].[OB_part_SU_owner_Posit] p
        JOIN
            [dbo].[OB_part_SU_owner_Annex] a
        ON
            a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
        AND
            a.OB_part_SU_owner_PositedAt = (
                SELECT
                    max(s.OB_part_SU_owner_PositedAt)
                FROM
                    [dbo].[OB_part_SU_owner_Annex] s
                WHERE
                    s.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
                AND
                    s.OB_part_SU_owner_PositedAt < v.OB_part_SU_owner_PositedAt
            )
        WHERE
            p.OB_ID_part = v.OB_ID_part
        AND
            a.OB_part_SU_owner_Reliability = 1
        ORDER BY
            a.OB_part_SU_owner_PositedAt DESC
    ) e
    WHERE
        v.OB_part_SU_owner_StatementType in ('P', 'A')
    AND
        v.OB_part_SU_owner_Reliability = 1
    AND (
        e.SU_ID_owner <> v.SU_ID_owner
    )
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [dbo].[OB_part_SU_owner_Annex] x
        WHERE
            x.OB_part_SU_owner_ID = e.OB_part_SU_owner_ID
        AND
            x.OB_part_SU_owner_PositedAt = v.OB_part_SU_owner_PositedAt
    );
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
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner,
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
    IF(UPDATE(OB_part_SU_owner_ID))
        RAISERROR('The identity column OB_part_SU_owner_ID is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_part))
        RAISERROR('The identity column OB_ID_part is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[OB_part_SU_owner_Annex] (
        Metadata_OB_part_SU_owner,
        OB_part_SU_owner_ID,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_part_SU_owner_ID,
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
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner,
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner,
        cast(CASE WHEN UPDATE(OB_part_SU_owner_PositedAt) THEN i.OB_part_SU_owner_PositedAt ELSE @now END as datetime2),
        ISNULL(i.OB_part_SU_owner_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.SU_ID_owner is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(OB_part_SU_owner_PositedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.OB_part_SU_owner_ID = i.OB_part_SU_owner_ID
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
        OB_part_SU_owner_PositedAt,
        OB_part_SU_owner_Reliability
    )
    SELECT
        d.Metadata_OB_part_SU_owner,
        d.OB_part_SU_owner_ID,
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
    DECLARE @inserted TABLE (
        Metadata_SU_partner_SU_with int not null,
        SU_partner_SU_with_StatementType char(1) not null,
        SU_partner_SU_with_ChangedAt datetime2 not null,
        SU_partner_SU_with_PositedAt datetime2 not null,
        SU_partner_SU_with_Reliability decimal(5,2) not null,
        SU_ID_partner int not null,
        SU_ID_with int not null,
        primary key (
            SU_ID_partner asc,
            SU_ID_with asc,
            SU_partner_SU_with_ChangedAt desc,
            SU_partner_SU_with_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_partner,
            i.SU_ID_with,
            ISNULL(i.SU_partner_SU_with_ChangedAt, @now) AS SU_partner_SU_with_ChangedAt,
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
        CASE
            WHEN p.SU_partner_SU_with_ID is null
            THEN 'P' -- new posit
            WHEN a.SU_partner_SU_with_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.SU_partner_SU_with_ChangedAt, @now),
        ISNULL(i.SU_partner_SU_with_PositedAt, @now),
        ISNULL(i.SU_partner_SU_with_Reliability, 1),
        i.SU_ID_partner,
        i.SU_ID_with
    FROM
        inserted i
    LEFT JOIN
        [dbo].[SU_partner_SU_with_Posit] p
    ON
        p.SU_ID_partner = i.SU_ID_partner
    AND
        p.SU_ID_with = i.SU_ID_with
    AND
        p.SU_partner_SU_with_ChangedAt = i.SU_partner_SU_with_ChangedAt
    LEFT JOIN
        [dbo].[SU_partner_SU_with_Annex] a
    ON
        a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
    AND
        a.SU_partner_SU_with_PositedAt = i.SU_partner_SU_with_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.SU_partner_SU_with_ID is null OR a.SU_partner_SU_with_ID is null)
    AND
        i.SU_ID_partner is not null
    AND
        i.SU_ID_with is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_SU_partner_SU_with,
        'X', -- existing data
        x.SU_partner_SU_with_ChangedAt,
        x.SU_partner_SU_with_PositedAt,
        x.SU_partner_SU_with_Reliability,
        x.SU_ID_partner,
        x.SU_ID_with
    FROM (
        SELECT
            a.Metadata_SU_partner_SU_with,
            p.SU_partner_SU_with_ChangedAt,
            a.SU_partner_SU_with_PositedAt,
            a.SU_partner_SU_with_Reliability,
            p.SU_ID_partner,
            p.SU_ID_with,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.SU_ID_partner,
                    p.SU_ID_with,
                    p.SU_partner_SU_with_ChangedAt,
                    a.SU_partner_SU_with_PositedAt
                ORDER BY
                    a.SU_partner_SU_with_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                SU_ID_partner,
                SU_ID_with
            FROM
                @inserted
        ) i
        JOIN
            [dbo].[SU_partner_SU_with_Posit] p
        ON
            p.SU_ID_partner = i.SU_ID_partner
        AND
            p.SU_ID_with = i.SU_ID_with
        JOIN
            [dbo].[SU_partner_SU_with_Annex] a
        ON
            a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
    ) x
    WHERE
        x.shown = 1;
    DECLARE @retracted TABLE (
        Metadata_SU_partner_SU_with int not null,
        SU_partner_SU_with_StatementType char(1) not null,
        SU_partner_SU_with_ChangedAt datetime2 not null,
        SU_partner_SU_with_PositedAt datetime2 not null,
        SU_partner_SU_with_Reliability decimal(5,2) not null,
        SU_ID_partner int not null,
        SU_ID_with int not null
    );
    INSERT INTO @retracted (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_StatementType,
        SU_partner_SU_with_ChangedAt,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability,
        SU_ID_partner,
        SU_ID_with
    )
    SELECT
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_StatementType,
        SU_partner_SU_with_ChangedAt,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability,
        SU_ID_partner,
        SU_ID_with
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.SU_partner_SU_with_Reliability as previous_SU_partner_SU_with_Reliability,
            fol.SU_partner_SU_with_Reliability as following_SU_partner_SU_with_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.SU_partner_SU_with_Reliability
            FROM
                @inserted p
            WHERE
                p.SU_ID_partner = a.SU_ID_partner
            AND
                p.SU_ID_with = a.SU_ID_with
            AND
                p.SU_partner_SU_with_ChangedAt = a.SU_partner_SU_with_ChangedAt
            AND
                p.SU_partner_SU_with_PositedAt < a.SU_partner_SU_with_PositedAt
            ORDER BY
                p.SU_partner_SU_with_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.SU_partner_SU_with_Reliability
            FROM
                @inserted p
            WHERE
                p.SU_ID_partner = a.SU_ID_partner
            AND
                p.SU_ID_with = a.SU_ID_with
            AND
                p.SU_partner_SU_with_ChangedAt = a.SU_partner_SU_with_ChangedAt
            AND
                p.SU_partner_SU_with_PositedAt > a.SU_partner_SU_with_PositedAt
            ORDER BY
                p.SU_partner_SU_with_PositedAt ASC
        ) fol
        WHERE
            (a.SU_partner_SU_with_Reliability = 0 AND isnull(pre.SU_partner_SU_with_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.SU_partner_SU_with_Reliability = 1 AND fol.SU_partner_SU_with_Reliability = 0)
    ) i
    WHERE
        i.SU_partner_SU_with_StatementType <> 'X'
    AND (
            (i.SU_partner_SU_with_Reliability = 0 AND i.previous_SU_partner_SU_with_Reliability = 1)
        OR
            (i.SU_partner_SU_with_Reliability = 1 AND i.following_SU_partner_SU_with_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [dbo].[SU_partner_SU_with_Posit] (
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    FROM
        @inserted
    WHERE
        SU_partner_SU_with_StatementType = 'P';
    INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        v.Metadata_SU_partner_SU_with,
        p.SU_partner_SU_with_ID,
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
        v.SU_partner_SU_with_StatementType in ('P', 'A');
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
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ChangedAt,
        i.SU_ID_partner,
        i.SU_ID_with,
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
    IF(UPDATE(SU_partner_SU_with_ID))
        RAISERROR('The identity column SU_partner_SU_with_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[SU_partner_SU_with_Annex] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ID,
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ID,
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
                    d.SU_ID_partner = i.SU_ID_partner
                AND
                    d.SU_ID_with = i.SU_ID_with
            ) THEN i.SU_partner_SU_with_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.SU_ID_partner,
        i.SU_ID_with,
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
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_partner_SU_with_ID = i.SU_partner_SU_with_ID
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
        SU_partner_SU_with_PositedAt,
        SU_partner_SU_with_Reliability
    )
    SELECT
        d.Metadata_SU_partner_SU_with,
        d.SU_partner_SU_with_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
