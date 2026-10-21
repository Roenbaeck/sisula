-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
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
        SU_ID_holder int not null,
        OB_ID_item int not null,
        GRD_ID_grade tinyint not null,
        primary key (
            SU_ID_holder asc,
            OB_ID_item asc,
            SU_holder_OB_item_GRD_grade_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_holder_OB_item_GRD_grade, 0),
        'P', -- new posit
        ISNULL(i.SU_holder_OB_item_GRD_grade_ChangedAt, @now),
        i.SU_ID_holder,
        i.OB_ID_item,
        i.GRD_ID_grade
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_holder_OB_item_GRD_grade] x
        WHERE
            x.SU_ID_holder = i.SU_ID_holder
        AND
            x.OB_ID_item = i.OB_ID_item
        AND
            x.GRD_ID_grade = i.GRD_ID_grade
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = i.SU_holder_OB_item_GRD_grade_ChangedAt
    );
    -- other values for identifiers that already have values at that time are a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_holder,
            i.OB_ID_item,
            i.SU_holder_OB_item_GRD_grade_ChangedAt
        FROM
            @inserted i
        JOIN
            [dbo].[SU_holder_OB_item_GRD_grade] x
        ON
            x.SU_ID_holder = i.SU_ID_holder
        AND
            x.OB_ID_item = i.OB_ID_item
        AND
            x.SU_holder_OB_item_GRD_grade_ChangedAt = i.SU_holder_OB_item_GRD_grade_ChangedAt
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in SU_holder_OB_item_GRD_grade for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    SELECT
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    FROM
        @inserted
    WHERE
        SU_holder_OB_item_GRD_grade_StatementType = 'P';
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
        GRD_ID_grade
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        i.SU_holder_OB_item_GRD_grade_ChangedAt,
        i.SU_ID_holder,
        i.OB_ID_item,
        ISNULL(i.GRD_ID_grade, [GRD_grade].GRD_ID)
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_SU_holder_OB_item_GRD_grade_ChangedAt bit = CASE WHEN UPDATE(SU_holder_OB_item_GRD_grade_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_grade_GRD_Grade bit = CASE WHEN UPDATE(grade_GRD_Grade) THEN 1 ELSE 0 END;
    IF(UPDATE(SU_ID_holder))
        RAISERROR('The identity column SU_ID_holder is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_item))
        RAISERROR('The identity column OB_ID_item is not updatable.', 16, 1);
    INSERT INTO [dbo].[SU_holder_OB_item_GRD_grade] (
        Metadata_SU_holder_OB_item_GRD_grade,
        SU_holder_OB_item_GRD_grade_ChangedAt,
        SU_ID_holder,
        OB_ID_item,
        GRD_ID_grade
    )
    SELECT
        i.Metadata_SU_holder_OB_item_GRD_grade,
        cast(CASE WHEN @updated_SU_holder_OB_item_GRD_grade_ChangedAt = 1 THEN i.SU_holder_OB_item_GRD_grade_ChangedAt ELSE @now END as datetime2),
        i.SU_ID_holder,
        i.OB_ID_item,
        CASE WHEN @updated_grade_GRD_Grade = 1 THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_grade]
    ON
        [GRD_grade].GRD_Grade = i.grade_GRD_Grade
    WHERE
        CASE WHEN @updated_grade_GRD_Grade = 1 THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END is not null
    AND
        ( -- values that are left as they are state nothing
            @updated_SU_holder_OB_item_GRD_grade_ChangedAt = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_ID_holder = i.SU_ID_holder
                AND
                    d.OB_ID_item = i.OB_ID_item
                AND
                    d.GRD_ID_grade = CASE WHEN @updated_grade_GRD_Grade = 1 THEN [GRD_grade].GRD_ID ELSE i.GRD_ID_grade END
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
    DELETE tie
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade] tie
    JOIN
        deleted d
    ON
        d.SU_holder_OB_item_GRD_grade_ChangedAt = tie.SU_holder_OB_item_GRD_grade_ChangedAt
    AND
        d.SU_ID_holder = tie.SU_ID_holder
    AND
        d.OB_ID_item = tie.OB_ID_item;
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
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null,
        primary key (
            SU_ID_keeper asc,
            OB_ID_thing asc,
            SU_keeper_OB_thing_GRD_rank_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_keeper_OB_thing_GRD_rank, 0),
        'P', -- new posit
        ISNULL(i.SU_keeper_OB_thing_GRD_rank_ChangedAt, @now),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        i.GRD_ID_rank
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_keeper_OB_thing_GRD_rank] x
        WHERE
            x.SU_ID_keeper = i.SU_ID_keeper
        AND
            x.OB_ID_thing = i.OB_ID_thing
        AND
            x.GRD_ID_rank = i.GRD_ID_rank
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
    );
    -- other values for identifiers that already have values at that time are a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.SU_ID_keeper,
            i.OB_ID_thing,
            i.SU_keeper_OB_thing_GRD_rank_ChangedAt
        FROM
            @inserted i
        JOIN
            [dbo].[SU_keeper_OB_thing_GRD_rank] x
        ON
            x.SU_ID_keeper = i.SU_ID_keeper
        AND
            x.OB_ID_thing = i.OB_ID_thing
        AND
            x.SU_keeper_OB_thing_GRD_rank_ChangedAt = i.SU_keeper_OB_thing_GRD_rank_ChangedAt
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
        p.Metadata_SU_keeper_OB_thing_GRD_rank,
        'X', -- existing data
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank
    FROM (
        SELECT DISTINCT
            SU_ID_keeper,
            OB_ID_thing
        FROM
            @inserted
    ) i
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank] p
    ON
        p.SU_ID_keeper = i.SU_ID_keeper
    AND
        p.OB_ID_thing = i.OB_ID_thing
    DECLARE @restated TABLE (
        SU_keeper_OB_thing_GRD_rank_ChangedAt datetime2 not null,
        SU_ID_keeper int not null,
        OB_ID_thing int not null,
        GRD_ID_rank tinyint not null
    );
    INSERT INTO @restated
    SELECT
        x.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        x.SU_ID_keeper,
        x.OB_ID_thing,
        x.GRD_ID_rank
    FROM (
        DELETE t
        OUTPUT
            deleted.*
        FROM
            @inserted t
        OUTER APPLY (
            SELECT TOP 1
                SU_ID_keeper,
                OB_ID_thing,
                GRD_ID_rank
            FROM
                @inserted h
            WHERE
                h.SU_ID_keeper = t.SU_ID_keeper
            AND
                h.OB_ID_thing = t.OB_ID_thing
            AND
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt < t.SU_keeper_OB_thing_GRD_rank_ChangedAt
            ORDER BY
                h.SU_keeper_OB_thing_GRD_rank_ChangedAt DESC
        ) pre
        WHERE
            t.SU_ID_keeper = pre.SU_ID_keeper
        AND
            t.OB_ID_thing = pre.OB_ID_thing
        AND
            t.GRD_ID_rank = pre.GRD_ID_rank
    ) x
    WHERE
        x.SU_keeper_OB_thing_GRD_rank_StatementType = 'X';
    -- delete the quenches (should be rare)
    DELETE t
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank] t
    JOIN
        @restated d
    ON
        d.SU_keeper_OB_thing_GRD_rank_ChangedAt = t.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        d.SU_ID_keeper = t.SU_ID_keeper
    AND
        d.OB_ID_thing = t.OB_ID_thing
    AND
        d.GRD_ID_rank = t.GRD_ID_rank
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    FROM
        @inserted
    WHERE
        SU_keeper_OB_thing_GRD_rank_StatementType = 'P';
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
        GRD_ID_rank
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        i.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        i.SU_ID_keeper,
        i.OB_ID_thing,
        ISNULL(i.GRD_ID_rank, [GRD_rank].GRD_ID)
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_SU_keeper_OB_thing_GRD_rank_ChangedAt bit = CASE WHEN UPDATE(SU_keeper_OB_thing_GRD_rank_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_rank_GRD_Grade bit = CASE WHEN UPDATE(rank_GRD_Grade) THEN 1 ELSE 0 END;
    IF(UPDATE(SU_ID_keeper))
        RAISERROR('The identity column SU_ID_keeper is not updatable.', 16, 1);
    IF(UPDATE(OB_ID_thing))
        RAISERROR('The identity column OB_ID_thing is not updatable.', 16, 1);
    INSERT INTO [dbo].[SU_keeper_OB_thing_GRD_rank] (
        Metadata_SU_keeper_OB_thing_GRD_rank,
        SU_keeper_OB_thing_GRD_rank_ChangedAt,
        SU_ID_keeper,
        OB_ID_thing,
        GRD_ID_rank
    )
    SELECT
        i.Metadata_SU_keeper_OB_thing_GRD_rank,
        cast(CASE WHEN @updated_SU_keeper_OB_thing_GRD_rank_ChangedAt = 1 THEN i.SU_keeper_OB_thing_GRD_rank_ChangedAt ELSE @now END as datetime2),
        i.SU_ID_keeper,
        i.OB_ID_thing,
        CASE WHEN @updated_rank_GRD_Grade = 1 THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
    FROM
        inserted i
    LEFT JOIN
        [dbo].[GRD_Grade] [GRD_rank]
    ON
        [GRD_rank].GRD_Grade = i.rank_GRD_Grade
    WHERE
        CASE WHEN @updated_rank_GRD_Grade = 1 THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END is not null
    AND
        ( -- values that are left as they are state nothing
            @updated_SU_keeper_OB_thing_GRD_rank_ChangedAt = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_ID_keeper = i.SU_ID_keeper
                AND
                    d.OB_ID_thing = i.OB_ID_thing
                AND
                    d.GRD_ID_rank = CASE WHEN @updated_rank_GRD_Grade = 1 THEN [GRD_rank].GRD_ID ELSE i.GRD_ID_rank END
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
    DELETE tie
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank] tie
    JOIN
        deleted d
    ON
        d.SU_keeper_OB_thing_GRD_rank_ChangedAt = tie.SU_keeper_OB_thing_GRD_rank_ChangedAt
    AND
        d.SU_ID_keeper = tie.SU_ID_keeper
    AND
        d.OB_ID_thing = tie.OB_ID_thing;
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
    -- other values for identifiers that already have values are a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.OB_ID_part
        FROM
            inserted i
        JOIN
            [dbo].[OB_part_SU_owner] x
        ON
            x.OB_ID_part = i.OB_ID_part
        WHERE NOT (
            x.SU_ID_owner = i.SU_ID_owner
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
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner
    )
    SELECT
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[OB_part_SU_owner] x
        WHERE
            x.OB_ID_part = i.OB_ID_part
        AND
            x.SU_ID_owner = i.SU_ID_owner
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
        SU_ID_owner
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    IF(UPDATE(OB_ID_part))
        RAISERROR('The identity column OB_ID_part is not updatable.', 16, 1);
    INSERT INTO [dbo].[OB_part_SU_owner] (
        Metadata_OB_part_SU_owner,
        OB_ID_part,
        SU_ID_owner
    )
    SELECT
        i.Metadata_OB_part_SU_owner,
        i.OB_ID_part,
        i.SU_ID_owner
    FROM
        inserted i
    WHERE
        i.SU_ID_owner is not null
    AND
        ( -- values that are left as they are state nothing
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.OB_ID_part = i.OB_ID_part
                AND
                    d.SU_ID_owner = i.SU_ID_owner
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
    DELETE tie
    FROM
        [dbo].[OB_part_SU_owner] tie
    JOIN
        deleted d
    ON
        d.OB_ID_part = tie.OB_ID_part;
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
        SU_ID_partner int not null,
        SU_ID_with int not null,
        primary key (
            SU_ID_partner asc,
            SU_ID_with asc,
            SU_partner_SU_with_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_SU_partner_SU_with, 0),
        'P', -- new posit
        ISNULL(i.SU_partner_SU_with_ChangedAt, @now),
        i.SU_ID_partner,
        i.SU_ID_with
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [dbo].[SU_partner_SU_with] x
        WHERE
            x.SU_ID_partner = i.SU_ID_partner
        AND
            x.SU_ID_with = i.SU_ID_with
        AND
            x.SU_partner_SU_with_ChangedAt = i.SU_partner_SU_with_ChangedAt
    );
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    )
    SELECT
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    FROM
        @inserted
    WHERE
        SU_partner_SU_with_StatementType = 'P';
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
        SU_ID_with
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        i.SU_partner_SU_with_ChangedAt,
        i.SU_ID_partner,
        i.SU_ID_with
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_SU_partner_SU_with_ChangedAt bit = CASE WHEN UPDATE(SU_partner_SU_with_ChangedAt) THEN 1 ELSE 0 END;
    INSERT INTO [dbo].[SU_partner_SU_with] (
        Metadata_SU_partner_SU_with,
        SU_partner_SU_with_ChangedAt,
        SU_ID_partner,
        SU_ID_with
    )
    SELECT
        i.Metadata_SU_partner_SU_with,
        cast(CASE WHEN @updated_SU_partner_SU_with_ChangedAt = 1 THEN i.SU_partner_SU_with_ChangedAt ELSE @now END as datetime2),
        i.SU_ID_partner,
        i.SU_ID_with
    FROM
        inserted i
    WHERE
        i.SU_ID_partner is not null
    AND
        i.SU_ID_with is not null
    AND
        ( -- values that are left as they are state nothing
            @updated_SU_partner_SU_with_ChangedAt = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.SU_ID_partner = i.SU_ID_partner
                AND
                    d.SU_ID_with = i.SU_ID_with
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
    DELETE tie
    FROM
        [dbo].[SU_partner_SU_with] tie
    JOIN
        deleted d
    ON
        d.SU_partner_SU_with_ChangedAt = tie.SU_partner_SU_with_ChangedAt
    AND
       (
            d.SU_ID_partner = tie.SU_ID_partner
        AND
            d.SU_ID_with = tie.SU_ID_with
       );
END
GO
