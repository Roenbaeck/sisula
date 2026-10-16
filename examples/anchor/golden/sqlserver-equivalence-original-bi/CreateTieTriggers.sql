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
-- itAC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.it_AC_partner_AC_with_ONG_currently', 'TR') IS NOT NULL
DROP TRIGGER [ties].[it_AC_partner_AC_with_ONG_currently];
GO
CREATE TRIGGER [ties].[it_AC_partner_AC_with_ONG_currently] ON [ties].[AC_partner_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_partner_AC_with_ONG_currently int not null,
        AC_partner_AC_with_ONG_currently_StatementType char(1) not null,
        AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_PositedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
        AC_ID_partner smallint not null,
        AC_ID_with smallint not null,
        ONG_ID_currently tinyint not null,
        primary key (
            AC_ID_partner asc,
            AC_ID_with asc,
            ONG_ID_currently asc,
            AC_partner_AC_with_ONG_currently_ChangedAt desc,
            AC_partner_AC_with_ONG_currently_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_partner,
            i.AC_ID_with,
            i.ONG_ID_currently,
            ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now) AS AC_partner_AC_with_ONG_currently_ChangedAt,
            ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now) AS AC_partner_AC_with_ONG_currently_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_partner_AC_with_ONG_currently_Posit] p
            JOIN
                [ties].[AC_partner_AC_with_ONG_currently_Annex] a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            WHERE
                p.AC_ID_partner = i.AC_ID_partner
            AND
                p.AC_ID_with = i.AC_ID_with
            AND
                p.ONG_ID_currently = i.ONG_ID_currently
            AND
                p.AC_partner_AC_with_ONG_currently_ChangedAt = ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now)
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt = ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now)
            AND
                a.AC_partner_AC_with_ONG_currently_Reliability <> ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_partner_AC_with_ONG_currently for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_partner_AC_with_ONG_currently, 0),
        CASE
            WHEN p.AC_partner_AC_with_ONG_currently_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_partner_AC_with_ONG_currently_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now),
        ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1),
        i.AC_ID_partner,
        i.AC_ID_with,
        i.ONG_ID_currently
    FROM
        inserted i
    LEFT JOIN
        [ties].[AC_partner_AC_with_ONG_currently_Posit] p
    ON
        p.AC_ID_partner = i.AC_ID_partner
    AND
        p.AC_ID_with = i.AC_ID_with
    AND
        p.ONG_ID_currently = i.ONG_ID_currently
    AND
        p.AC_partner_AC_with_ONG_currently_ChangedAt = i.AC_partner_AC_with_ONG_currently_ChangedAt
    LEFT JOIN
        [ties].[AC_partner_AC_with_ONG_currently_Annex] a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    AND
        a.AC_partner_AC_with_ONG_currently_PositedAt = i.AC_partner_AC_with_ONG_currently_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_partner_AC_with_ONG_currently_ID is null OR a.AC_partner_AC_with_ONG_currently_ID is null)
    AND
        i.AC_ID_partner is not null
    AND
        i.AC_ID_with is not null
    AND
        i.ONG_ID_currently is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_partner_AC_with_ONG_currently,
        'X', -- existing data
        x.AC_partner_AC_with_ONG_currently_ChangedAt,
        x.AC_partner_AC_with_ONG_currently_PositedAt,
        x.AC_partner_AC_with_ONG_currently_Reliability,
        x.AC_ID_partner,
        x.AC_ID_with,
        x.ONG_ID_currently
    FROM (
        SELECT
            a.Metadata_AC_partner_AC_with_ONG_currently,
            p.AC_partner_AC_with_ONG_currently_ChangedAt,
            a.AC_partner_AC_with_ONG_currently_PositedAt,
            a.AC_partner_AC_with_ONG_currently_Reliability,
            p.AC_ID_partner,
            p.AC_ID_with,
            p.ONG_ID_currently,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_partner,
                    p.AC_ID_with,
                    p.ONG_ID_currently,
                    p.AC_partner_AC_with_ONG_currently_ChangedAt,
                    a.AC_partner_AC_with_ONG_currently_PositedAt
                ORDER BY
                    a.AC_partner_AC_with_ONG_currently_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_partner,
                AC_ID_with,
                ONG_ID_currently
            FROM
                @inserted
        ) i
        JOIN
            [ties].[AC_partner_AC_with_ONG_currently_Posit] p
        ON
            p.AC_ID_partner = i.AC_ID_partner
        AND
            p.AC_ID_with = i.AC_ID_with
        AND
            p.ONG_ID_currently = i.ONG_ID_currently
        JOIN
            [ties].[AC_partner_AC_with_ONG_currently_Annex] a
        ON
            a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_partner = x.AC_ID_partner
        AND
            n.AC_ID_with = x.AC_ID_with
        AND
            n.ONG_ID_currently = x.ONG_ID_currently
        AND
            n.AC_partner_AC_with_ONG_currently_ChangedAt = x.AC_partner_AC_with_ONG_currently_ChangedAt
        AND
            n.AC_partner_AC_with_ONG_currently_PositedAt = x.AC_partner_AC_with_ONG_currently_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_partner_AC_with_ONG_currently int not null,
        AC_partner_AC_with_ONG_currently_StatementType char(1) not null,
        AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_PositedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
        AC_ID_partner smallint not null,
        AC_ID_with smallint not null,
        ONG_ID_currently tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_StatementType,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_StatementType,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_partner_AC_with_ONG_currently_Reliability as previous_AC_partner_AC_with_ONG_currently_Reliability,
            fol.AC_partner_AC_with_ONG_currently_Reliability as following_AC_partner_AC_with_ONG_currently_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_partner_AC_with_ONG_currently_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_partner = a.AC_ID_partner
            AND
                p.AC_ID_with = a.AC_ID_with
            AND
                p.ONG_ID_currently = a.ONG_ID_currently
            AND
                p.AC_partner_AC_with_ONG_currently_ChangedAt = a.AC_partner_AC_with_ONG_currently_ChangedAt
            AND
                p.AC_partner_AC_with_ONG_currently_PositedAt < a.AC_partner_AC_with_ONG_currently_PositedAt
            ORDER BY
                p.AC_partner_AC_with_ONG_currently_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_partner_AC_with_ONG_currently_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_partner = a.AC_ID_partner
            AND
                p.AC_ID_with = a.AC_ID_with
            AND
                p.ONG_ID_currently = a.ONG_ID_currently
            AND
                p.AC_partner_AC_with_ONG_currently_ChangedAt = a.AC_partner_AC_with_ONG_currently_ChangedAt
            AND
                p.AC_partner_AC_with_ONG_currently_PositedAt > a.AC_partner_AC_with_ONG_currently_PositedAt
            ORDER BY
                p.AC_partner_AC_with_ONG_currently_PositedAt ASC
        ) fol
        WHERE
            (a.AC_partner_AC_with_ONG_currently_Reliability = 0 AND isnull(pre.AC_partner_AC_with_ONG_currently_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_partner_AC_with_ONG_currently_Reliability = 1 AND fol.AC_partner_AC_with_ONG_currently_Reliability = 0)
    ) i
    WHERE
        i.AC_partner_AC_with_ONG_currently_StatementType <> 'X'
    AND (
            (i.AC_partner_AC_with_ONG_currently_Reliability = 0 AND i.previous_AC_partner_AC_with_ONG_currently_Reliability = 1)
        OR
            (i.AC_partner_AC_with_ONG_currently_Reliability = 1 AND i.following_AC_partner_AC_with_ONG_currently_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Posit] (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    FROM
        @inserted
    WHERE
        AC_partner_AC_with_ONG_currently_StatementType = 'P';
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Annex] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        v.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        v.AC_partner_AC_with_ONG_currently_PositedAt,
        v.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        @inserted v
    JOIN
        [ties].[AC_partner_AC_with_ONG_currently_Posit] p
    ON
        p.AC_ID_partner = v.AC_ID_partner
    AND
        p.AC_ID_with = v.AC_ID_with
    AND
        p.ONG_ID_currently = v.ONG_ID_currently
    AND
        p.AC_partner_AC_with_ONG_currently_ChangedAt = v.AC_partner_AC_with_ONG_currently_ChangedAt
    WHERE
        v.AC_partner_AC_with_ONG_currently_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[it_lAC_partner_AC_with_ONG_currently] ON [ties].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        i.AC_partner_AC_with_ONG_currently_ChangedAt,
        i.AC_ID_partner,
        i.AC_ID_with,
        ISNULL(i.ONG_ID_currently, [ONG_currently].ONG_ID),
        i.AC_partner_AC_with_ONG_currently_PositedAt,
        i.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        inserted i
    LEFT JOIN
        [knots].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.ONG_Ongoing;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[ut_lAC_partner_AC_with_ONG_currently] ON [ties].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(AC_partner_AC_with_ONG_currently_ID))
        RAISERROR('The identity column AC_partner_AC_with_ONG_currently_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Annex] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        i.AC_partner_AC_with_ONG_currently_ID,
        cast(ISNULL(CASE
            WHEN UPDATE(AC_partner_AC_with_ONG_currently_PositedAt) THEN i.AC_partner_AC_with_ONG_currently_PositedAt
            WHEN UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [knots].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.ONG_Ongoing
    WHERE
        i.AC_partner_AC_with_ONG_currently_ID is not null
    AND (
        i.AC_ID_partner is null
    OR
        i.AC_ID_with is null
    OR
        CASE WHEN UPDATE(ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        cast(CASE
            WHEN UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_partner_AC_with_ONG_currently_ID = i.AC_partner_AC_with_ONG_currently_ID
                AND
                    d.AC_ID_partner = i.AC_ID_partner
                AND
                    d.AC_ID_with = i.AC_ID_with
                AND
                    d.ONG_ID_currently = CASE WHEN UPDATE(ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END
            ) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.AC_ID_partner,
        i.AC_ID_with,
        CASE WHEN UPDATE(ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END,
        cast(CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_PositedAt) THEN i.AC_partner_AC_with_ONG_currently_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [knots].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.ONG_Ongoing
    WHERE
        i.AC_ID_partner is not null
    AND
        i.AC_ID_with is not null
    AND
        CASE WHEN UPDATE(ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) OR
            UPDATE(AC_partner_AC_with_ONG_currently_PositedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_partner_AC_with_ONG_currently_ID = i.AC_partner_AC_with_ONG_currently_ID
                AND
                    d.AC_ID_partner = i.AC_ID_partner
                AND
                    d.AC_ID_with = i.AC_ID_with
                AND
                    d.ONG_ID_currently = CASE WHEN UPDATE(ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END
                AND
                    d.AC_partner_AC_with_ONG_currently_Reliability = ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[dt_lAC_partner_AC_with_ONG_currently] ON [ties].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Annex] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        d.Metadata_AC_partner_AC_with_ONG_currently,
        d.AC_partner_AC_with_ONG_currently_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.it_AC_subset_PN_of', 'TR') IS NOT NULL
DROP TRIGGER [ties].[it_AC_subset_PN_of];
GO
CREATE TRIGGER [ties].[it_AC_subset_PN_of] ON [ties].[AC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_subset_PN_of int not null,
        AC_subset_PN_of_StatementType char(1) not null,
        AC_subset_PN_of_PositedAt datetime2 not null,
        AC_subset_PN_of_Reliability decimal(5,2) not null,
        AC_ID_subset smallint not null,
        PN_ID_of bigint not null,
        primary key (
            AC_ID_subset asc,
            PN_ID_of asc,
            AC_subset_PN_of_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_subset,
            i.PN_ID_of,
            ISNULL(i.AC_subset_PN_of_PositedAt, @now) AS AC_subset_PN_of_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_subset_PN_of_Posit] p
            JOIN
                [ties].[AC_subset_PN_of_Annex] a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            WHERE
                p.AC_ID_subset = i.AC_ID_subset
            AND
                p.PN_ID_of = i.PN_ID_of
            AND
                a.AC_subset_PN_of_PositedAt = ISNULL(i.AC_subset_PN_of_PositedAt, @now)
            AND
                a.AC_subset_PN_of_Reliability <> ISNULL(i.AC_subset_PN_of_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_subset_PN_of for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_subset_PN_of, 0),
        CASE
            WHEN p.AC_subset_PN_of_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_subset_PN_of_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_subset_PN_of_PositedAt, @now),
        ISNULL(i.AC_subset_PN_of_Reliability, 1),
        i.AC_ID_subset,
        i.PN_ID_of
    FROM
        inserted i
    LEFT JOIN
        [ties].[AC_subset_PN_of_Posit] p
    ON
        p.AC_ID_subset = i.AC_ID_subset
    AND
        p.PN_ID_of = i.PN_ID_of
    LEFT JOIN
        [ties].[AC_subset_PN_of_Annex] a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    AND
        a.AC_subset_PN_of_PositedAt = i.AC_subset_PN_of_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_subset_PN_of_ID is null OR a.AC_subset_PN_of_ID is null)
    AND
        i.AC_ID_subset is not null
    AND
        i.PN_ID_of is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_subset_PN_of,
        'X', -- existing data
        x.AC_subset_PN_of_PositedAt,
        x.AC_subset_PN_of_Reliability,
        x.AC_ID_subset,
        x.PN_ID_of
    FROM (
        SELECT
            a.Metadata_AC_subset_PN_of,
            a.AC_subset_PN_of_PositedAt,
            a.AC_subset_PN_of_Reliability,
            p.AC_ID_subset,
            p.PN_ID_of,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_subset,
                    p.PN_ID_of,
                    a.AC_subset_PN_of_PositedAt
                ORDER BY
                    a.AC_subset_PN_of_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_subset,
                PN_ID_of
            FROM
                @inserted
        ) i
        JOIN
            [ties].[AC_subset_PN_of_Posit] p
        ON
            p.AC_ID_subset = i.AC_ID_subset
        AND
            p.PN_ID_of = i.PN_ID_of
        JOIN
            [ties].[AC_subset_PN_of_Annex] a
        ON
            a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_subset = x.AC_ID_subset
        AND
            n.PN_ID_of = x.PN_ID_of
        AND
            n.AC_subset_PN_of_PositedAt = x.AC_subset_PN_of_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_subset_PN_of int not null,
        AC_subset_PN_of_StatementType char(1) not null,
        AC_subset_PN_of_PositedAt datetime2 not null,
        AC_subset_PN_of_Reliability decimal(5,2) not null,
        AC_ID_subset smallint not null,
        PN_ID_of bigint not null
    );
    INSERT INTO @retracted (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_StatementType,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability,
        AC_ID_subset,
        PN_ID_of
    )
    SELECT
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_StatementType,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability,
        AC_ID_subset,
        PN_ID_of
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_subset_PN_of_Reliability as previous_AC_subset_PN_of_Reliability,
            fol.AC_subset_PN_of_Reliability as following_AC_subset_PN_of_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_subset_PN_of_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_subset = a.AC_ID_subset
            AND
                p.PN_ID_of = a.PN_ID_of
            AND
                p.AC_subset_PN_of_PositedAt < a.AC_subset_PN_of_PositedAt
            ORDER BY
                p.AC_subset_PN_of_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_subset_PN_of_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_subset = a.AC_ID_subset
            AND
                p.PN_ID_of = a.PN_ID_of
            AND
                p.AC_subset_PN_of_PositedAt > a.AC_subset_PN_of_PositedAt
            ORDER BY
                p.AC_subset_PN_of_PositedAt ASC
        ) fol
        WHERE
            (a.AC_subset_PN_of_Reliability = 0 AND isnull(pre.AC_subset_PN_of_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_subset_PN_of_Reliability = 1 AND fol.AC_subset_PN_of_Reliability = 0)
    ) i
    WHERE
        i.AC_subset_PN_of_StatementType <> 'X'
    AND (
            (i.AC_subset_PN_of_Reliability = 0 AND i.previous_AC_subset_PN_of_Reliability = 1)
        OR
            (i.AC_subset_PN_of_Reliability = 1 AND i.following_AC_subset_PN_of_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [ties].[AC_subset_PN_of_Posit] (
        AC_ID_subset,
        PN_ID_of
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_ID_subset,
        PN_ID_of
    FROM
        @inserted
    WHERE
        AC_subset_PN_of_StatementType = 'P';
    INSERT INTO [ties].[AC_subset_PN_of_Annex] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        v.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        v.AC_subset_PN_of_PositedAt,
        v.AC_subset_PN_of_Reliability
    FROM
        @inserted v
    JOIN
        [ties].[AC_subset_PN_of_Posit] p
    ON
        p.AC_ID_subset = v.AC_ID_subset
    AND
        p.PN_ID_of = v.PN_ID_of
    WHERE
        v.AC_subset_PN_of_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[it_lAC_subset_PN_of] ON [ties].[lAC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_subset_PN_of] (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of,
        i.AC_subset_PN_of_PositedAt,
        i.AC_subset_PN_of_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[ut_lAC_subset_PN_of] ON [ties].[lAC_subset_PN_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(AC_subset_PN_of_ID))
        RAISERROR('The identity column AC_subset_PN_of_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[AC_subset_PN_of_Annex] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_subset_PN_of_ID,
        cast(ISNULL(CASE
            WHEN UPDATE(AC_subset_PN_of_PositedAt) THEN i.AC_subset_PN_of_PositedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.AC_subset_PN_of_ID is not null
    AND (
        i.AC_ID_subset is null
    OR
        i.PN_ID_of is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [ties].[AC_subset_PN_of] (
        Metadata_AC_subset_PN_of,
        AC_ID_subset,
        PN_ID_of,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of,
        cast(CASE WHEN UPDATE(AC_subset_PN_of_PositedAt) THEN i.AC_subset_PN_of_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_subset_PN_of_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.AC_ID_subset is not null
    AND
        i.PN_ID_of is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(AC_subset_PN_of_PositedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_subset_PN_of_ID = i.AC_subset_PN_of_ID
                AND
                    d.AC_ID_subset = i.AC_ID_subset
                AND
                    d.PN_ID_of = i.PN_ID_of
                AND
                    d.AC_subset_PN_of_Reliability = ISNULL(i.AC_subset_PN_of_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[dt_lAC_subset_PN_of] ON [ties].[lAC_subset_PN_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_subset_PN_of_Annex] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        d.Metadata_AC_subset_PN_of,
        d.AC_subset_PN_of_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itEV_in_AC_wasCast instead of INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.it_EV_in_AC_wasCast', 'TR') IS NOT NULL
DROP TRIGGER [ties].[it_EV_in_AC_wasCast];
GO
CREATE TRIGGER [ties].[it_EV_in_AC_wasCast] ON [ties].[EV_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_EV_in_AC_wasCast int not null,
        EV_in_AC_wasCast_StatementType char(1) not null,
        EV_in_AC_wasCast_PositedAt datetime2 not null,
        EV_in_AC_wasCast_Reliability decimal(5,2) not null,
        EV_ID_in numeric(12,0) not null,
        AC_ID_wasCast smallint not null,
        primary key (
            EV_ID_in asc,
            AC_ID_wasCast asc,
            EV_in_AC_wasCast_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_ID_in,
            i.AC_ID_wasCast,
            ISNULL(i.EV_in_AC_wasCast_PositedAt, @now) AS EV_in_AC_wasCast_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[EV_in_AC_wasCast_Posit] p
            JOIN
                [ties].[EV_in_AC_wasCast_Annex] a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            WHERE
                p.EV_ID_in = i.EV_ID_in
            AND
                p.AC_ID_wasCast = i.AC_ID_wasCast
            AND
                a.EV_in_AC_wasCast_PositedAt = ISNULL(i.EV_in_AC_wasCast_PositedAt, @now)
            AND
                a.EV_in_AC_wasCast_Reliability <> ISNULL(i.EV_in_AC_wasCast_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in EV_in_AC_wasCast for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_EV_in_AC_wasCast, 0),
        CASE
            WHEN p.EV_in_AC_wasCast_ID is null
            THEN 'P' -- new posit
            WHEN a.EV_in_AC_wasCast_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.EV_in_AC_wasCast_PositedAt, @now),
        ISNULL(i.EV_in_AC_wasCast_Reliability, 1),
        i.EV_ID_in,
        i.AC_ID_wasCast
    FROM
        inserted i
    LEFT JOIN
        [ties].[EV_in_AC_wasCast_Posit] p
    ON
        p.EV_ID_in = i.EV_ID_in
    AND
        p.AC_ID_wasCast = i.AC_ID_wasCast
    LEFT JOIN
        [ties].[EV_in_AC_wasCast_Annex] a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    AND
        a.EV_in_AC_wasCast_PositedAt = i.EV_in_AC_wasCast_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.EV_in_AC_wasCast_ID is null OR a.EV_in_AC_wasCast_ID is null)
    AND
        i.EV_ID_in is not null
    AND
        i.AC_ID_wasCast is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_EV_in_AC_wasCast,
        'X', -- existing data
        x.EV_in_AC_wasCast_PositedAt,
        x.EV_in_AC_wasCast_Reliability,
        x.EV_ID_in,
        x.AC_ID_wasCast
    FROM (
        SELECT
            a.Metadata_EV_in_AC_wasCast,
            a.EV_in_AC_wasCast_PositedAt,
            a.EV_in_AC_wasCast_Reliability,
            p.EV_ID_in,
            p.AC_ID_wasCast,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.EV_ID_in,
                    p.AC_ID_wasCast,
                    a.EV_in_AC_wasCast_PositedAt
                ORDER BY
                    a.EV_in_AC_wasCast_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                EV_ID_in,
                AC_ID_wasCast
            FROM
                @inserted
        ) i
        JOIN
            [ties].[EV_in_AC_wasCast_Posit] p
        ON
            p.EV_ID_in = i.EV_ID_in
        AND
            p.AC_ID_wasCast = i.AC_ID_wasCast
        JOIN
            [ties].[EV_in_AC_wasCast_Annex] a
        ON
            a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.EV_ID_in = x.EV_ID_in
        AND
            n.AC_ID_wasCast = x.AC_ID_wasCast
        AND
            n.EV_in_AC_wasCast_PositedAt = x.EV_in_AC_wasCast_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_EV_in_AC_wasCast int not null,
        EV_in_AC_wasCast_StatementType char(1) not null,
        EV_in_AC_wasCast_PositedAt datetime2 not null,
        EV_in_AC_wasCast_Reliability decimal(5,2) not null,
        EV_ID_in numeric(12,0) not null,
        AC_ID_wasCast smallint not null
    );
    INSERT INTO @retracted (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_StatementType,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability,
        EV_ID_in,
        AC_ID_wasCast
    )
    SELECT
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_StatementType,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability,
        EV_ID_in,
        AC_ID_wasCast
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.EV_in_AC_wasCast_Reliability as previous_EV_in_AC_wasCast_Reliability,
            fol.EV_in_AC_wasCast_Reliability as following_EV_in_AC_wasCast_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.EV_in_AC_wasCast_Reliability
            FROM
                @inserted p
            WHERE
                p.EV_ID_in = a.EV_ID_in
            AND
                p.AC_ID_wasCast = a.AC_ID_wasCast
            AND
                p.EV_in_AC_wasCast_PositedAt < a.EV_in_AC_wasCast_PositedAt
            ORDER BY
                p.EV_in_AC_wasCast_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.EV_in_AC_wasCast_Reliability
            FROM
                @inserted p
            WHERE
                p.EV_ID_in = a.EV_ID_in
            AND
                p.AC_ID_wasCast = a.AC_ID_wasCast
            AND
                p.EV_in_AC_wasCast_PositedAt > a.EV_in_AC_wasCast_PositedAt
            ORDER BY
                p.EV_in_AC_wasCast_PositedAt ASC
        ) fol
        WHERE
            (a.EV_in_AC_wasCast_Reliability = 0 AND isnull(pre.EV_in_AC_wasCast_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.EV_in_AC_wasCast_Reliability = 1 AND fol.EV_in_AC_wasCast_Reliability = 0)
    ) i
    WHERE
        i.EV_in_AC_wasCast_StatementType <> 'X'
    AND (
            (i.EV_in_AC_wasCast_Reliability = 0 AND i.previous_EV_in_AC_wasCast_Reliability = 1)
        OR
            (i.EV_in_AC_wasCast_Reliability = 1 AND i.following_EV_in_AC_wasCast_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [ties].[EV_in_AC_wasCast_Posit] (
        EV_ID_in,
        AC_ID_wasCast
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        EV_ID_in,
        AC_ID_wasCast
    FROM
        @inserted
    WHERE
        EV_in_AC_wasCast_StatementType = 'P';
    INSERT INTO [ties].[EV_in_AC_wasCast_Annex] (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        v.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        v.EV_in_AC_wasCast_PositedAt,
        v.EV_in_AC_wasCast_Reliability
    FROM
        @inserted v
    JOIN
        [ties].[EV_in_AC_wasCast_Posit] p
    ON
        p.EV_ID_in = v.EV_ID_in
    AND
        p.AC_ID_wasCast = v.AC_ID_wasCast
    WHERE
        v.EV_in_AC_wasCast_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_wasCast instead of INSERT trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[it_lEV_in_AC_wasCast] ON [ties].[lEV_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[EV_in_AC_wasCast] (
        Metadata_EV_in_AC_wasCast,
        EV_ID_in,
        AC_ID_wasCast,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        i.Metadata_EV_in_AC_wasCast,
        i.EV_ID_in,
        i.AC_ID_wasCast,
        i.EV_in_AC_wasCast_PositedAt,
        i.EV_in_AC_wasCast_Reliability
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[dt_lEV_in_AC_wasCast] ON [ties].[lEV_in_AC_wasCast]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[EV_in_AC_wasCast_Annex] (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        d.Metadata_EV_in_AC_wasCast,
        d.EV_in_AC_wasCast_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.it_AC_part_PR_in_RAT_got', 'TR') IS NOT NULL
DROP TRIGGER [ties].[it_AC_part_PR_in_RAT_got];
GO
CREATE TRIGGER [ties].[it_AC_part_PR_in_RAT_got] ON [ties].[AC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_part_PR_in_RAT_got int not null,
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
        AC_ID_part smallint not null,
        PR_ID_in bigint not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_ID_part asc,
            PR_ID_in asc,
            AC_part_PR_in_RAT_got_ChangedAt desc,
            AC_part_PR_in_RAT_got_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_part,
            i.PR_ID_in,
            i.RAT_ID_got,
            ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now) AS AC_part_PR_in_RAT_got_ChangedAt,
            ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now) AS AC_part_PR_in_RAT_got_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_part_PR_in_RAT_got_Posit] p
            JOIN
                [ties].[AC_part_PR_in_RAT_got_Annex] a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            WHERE
                p.AC_ID_part = i.AC_ID_part
            AND
                p.PR_ID_in = i.PR_ID_in
            AND
                p.RAT_ID_got = i.RAT_ID_got
            AND
                p.AC_part_PR_in_RAT_got_ChangedAt = ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now)
            AND
                a.AC_part_PR_in_RAT_got_PositedAt = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
            AND
                a.AC_part_PR_in_RAT_got_Reliability <> ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1)
        )
        -- and so, since one posit at a time is asserted for the identifiers, is an assertion of other values at that time
        OR (
            ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1) = 1
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [ties].[AC_part_PR_in_RAT_got_Posit] p
                JOIN
                    [ties].[AC_part_PR_in_RAT_got_Annex] a
                ON
                    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
                WHERE
                    p.AC_ID_part = i.AC_ID_part
                AND
                    p.PR_ID_in = i.PR_ID_in
                AND
                    p.AC_part_PR_in_RAT_got_ChangedAt = ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now)
                AND
                    (
                        p.RAT_ID_got <> i.RAT_ID_got
                    )
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
                AND
                    a.AC_part_PR_in_RAT_got_Reliability = 1
            )
            OR EXISTS (
                SELECT TOP 1
                    42
                FROM
                    inserted j
                WHERE
                    j.AC_ID_part = i.AC_ID_part
                AND
                    j.PR_ID_in = i.PR_ID_in
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_ChangedAt, @now) = ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now)
                AND
                    (
                        j.RAT_ID_got <> i.RAT_ID_got
                    )
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_PositedAt, @now) = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_Reliability, 1) = 1
            )
        )
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_part_PR_in_RAT_got for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_part_PR_in_RAT_got, 0),
        CASE
            WHEN p.AC_part_PR_in_RAT_got_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_part_PR_in_RAT_got_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
        ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now),
        ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1),
        i.AC_ID_part,
        i.PR_ID_in,
        i.RAT_ID_got
    FROM
        inserted i
    LEFT JOIN
        [ties].[AC_part_PR_in_RAT_got_Posit] p
    ON
        p.AC_ID_part = i.AC_ID_part
    AND
        p.PR_ID_in = i.PR_ID_in
    AND
        p.RAT_ID_got = i.RAT_ID_got
    AND
        p.AC_part_PR_in_RAT_got_ChangedAt = i.AC_part_PR_in_RAT_got_ChangedAt
    LEFT JOIN
        [ties].[AC_part_PR_in_RAT_got_Annex] a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    AND
        a.AC_part_PR_in_RAT_got_PositedAt = i.AC_part_PR_in_RAT_got_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_part_PR_in_RAT_got_ID is null OR a.AC_part_PR_in_RAT_got_ID is null)
    AND
        i.AC_ID_part is not null
    AND
        i.PR_ID_in is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_part_PR_in_RAT_got,
        'X', -- existing data
        x.AC_part_PR_in_RAT_got_ChangedAt,
        x.AC_part_PR_in_RAT_got_PositedAt,
        x.AC_part_PR_in_RAT_got_Reliability,
        x.AC_ID_part,
        x.PR_ID_in,
        x.RAT_ID_got
    FROM (
        SELECT
            a.Metadata_AC_part_PR_in_RAT_got,
            p.AC_part_PR_in_RAT_got_ChangedAt,
            a.AC_part_PR_in_RAT_got_PositedAt,
            a.AC_part_PR_in_RAT_got_Reliability,
            p.AC_ID_part,
            p.PR_ID_in,
            p.RAT_ID_got,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_part,
                    p.PR_ID_in,
                    p.AC_part_PR_in_RAT_got_ChangedAt,
                    a.AC_part_PR_in_RAT_got_PositedAt
                ORDER BY
                    a.AC_part_PR_in_RAT_got_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_part,
                PR_ID_in
            FROM
                @inserted
        ) i
        JOIN
            [ties].[AC_part_PR_in_RAT_got_Posit] p
        ON
            p.AC_ID_part = i.AC_ID_part
        AND
            p.PR_ID_in = i.PR_ID_in
        JOIN
            [ties].[AC_part_PR_in_RAT_got_Annex] a
        ON
            a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_part = x.AC_ID_part
        AND
            n.PR_ID_in = x.PR_ID_in
        AND
            n.AC_part_PR_in_RAT_got_ChangedAt = x.AC_part_PR_in_RAT_got_ChangedAt
        AND
            n.AC_part_PR_in_RAT_got_PositedAt = x.AC_part_PR_in_RAT_got_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_part_PR_in_RAT_got int not null,
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
        AC_ID_part smallint not null,
        PR_ID_in bigint not null,
        RAT_ID_got tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_StatementType,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_StatementType,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_part_PR_in_RAT_got_Reliability as previous_AC_part_PR_in_RAT_got_Reliability,
            fol.AC_part_PR_in_RAT_got_Reliability as following_AC_part_PR_in_RAT_got_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_part_PR_in_RAT_got_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_part = a.AC_ID_part
            AND
                p.PR_ID_in = a.PR_ID_in
            AND
                p.AC_part_PR_in_RAT_got_ChangedAt = a.AC_part_PR_in_RAT_got_ChangedAt
            AND
                p.AC_part_PR_in_RAT_got_PositedAt < a.AC_part_PR_in_RAT_got_PositedAt
            ORDER BY
                p.AC_part_PR_in_RAT_got_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_part_PR_in_RAT_got_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_part = a.AC_ID_part
            AND
                p.PR_ID_in = a.PR_ID_in
            AND
                p.AC_part_PR_in_RAT_got_ChangedAt = a.AC_part_PR_in_RAT_got_ChangedAt
            AND
                p.AC_part_PR_in_RAT_got_PositedAt > a.AC_part_PR_in_RAT_got_PositedAt
            ORDER BY
                p.AC_part_PR_in_RAT_got_PositedAt ASC
        ) fol
        WHERE
            (a.AC_part_PR_in_RAT_got_Reliability = 0 AND isnull(pre.AC_part_PR_in_RAT_got_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_part_PR_in_RAT_got_Reliability = 1 AND fol.AC_part_PR_in_RAT_got_Reliability = 0)
    ) i
    WHERE
        i.AC_part_PR_in_RAT_got_StatementType <> 'X'
    AND (
            (i.AC_part_PR_in_RAT_got_Reliability = 0 AND i.previous_AC_part_PR_in_RAT_got_Reliability = 1)
        OR
            (i.AC_part_PR_in_RAT_got_Reliability = 1 AND i.following_AC_part_PR_in_RAT_got_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [ties].[AC_part_PR_in_RAT_got_Posit] (
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    FROM
        @inserted
    WHERE
        AC_part_PR_in_RAT_got_StatementType = 'P';
    INSERT INTO [ties].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        v.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        v.AC_part_PR_in_RAT_got_PositedAt,
        v.AC_part_PR_in_RAT_got_Reliability
    FROM
        @inserted v
    JOIN
        [ties].[AC_part_PR_in_RAT_got_Posit] p
    ON
        p.AC_ID_part = v.AC_ID_part
    AND
        p.PR_ID_in = v.PR_ID_in
    AND
        p.RAT_ID_got = v.RAT_ID_got
    AND
        p.AC_part_PR_in_RAT_got_ChangedAt = v.AC_part_PR_in_RAT_got_ChangedAt
    WHERE
        v.AC_part_PR_in_RAT_got_StatementType in ('P', 'A');
    -- an assertion retracts, at its positing time, the posit in effect for the identifiers at the same changing time when
    -- that has other values (a correction), so that one posit at a time is asserted; also when the assertion is a
    -- restatement that an idempotent tie skips
    INSERT INTO [ties].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        v.Metadata_AC_part_PR_in_RAT_got,
        e.AC_part_PR_in_RAT_got_ID,
        v.AC_part_PR_in_RAT_got_PositedAt,
        0
    FROM (
        SELECT
            n.Metadata_AC_part_PR_in_RAT_got,
            n.AC_part_PR_in_RAT_got_ChangedAt,
            n.AC_part_PR_in_RAT_got_PositedAt,
            n.AC_ID_part,
            n.PR_ID_in,
            n.RAT_ID_got
        FROM
            @inserted n
        WHERE
            n.AC_part_PR_in_RAT_got_StatementType in ('P', 'A')
        AND
            n.AC_part_PR_in_RAT_got_Reliability = 1
    ) v
    CROSS APPLY (
        SELECT TOP 1
            p.AC_part_PR_in_RAT_got_ID,
            p.RAT_ID_got
        FROM
            [ties].[AC_part_PR_in_RAT_got_Posit] p
        JOIN
            [ties].[AC_part_PR_in_RAT_got_Annex] a
        ON
            a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
        AND
            a.AC_part_PR_in_RAT_got_PositedAt = (
                SELECT
                    max(s.AC_part_PR_in_RAT_got_PositedAt)
                FROM
                    [ties].[AC_part_PR_in_RAT_got_Annex] s
                WHERE
                    s.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
                AND
                    s.AC_part_PR_in_RAT_got_PositedAt < v.AC_part_PR_in_RAT_got_PositedAt
            )
        WHERE
            p.AC_ID_part = v.AC_ID_part
        AND
            p.PR_ID_in = v.PR_ID_in
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v.AC_part_PR_in_RAT_got_ChangedAt
        AND
            a.AC_part_PR_in_RAT_got_Reliability = 1
        ORDER BY
            a.AC_part_PR_in_RAT_got_PositedAt DESC
    ) e
    WHERE (
        e.RAT_ID_got <> v.RAT_ID_got
    )
    AND NOT EXISTS ( -- not if it has an assertion at the positing time already
        SELECT TOP 1
            42
        FROM
            [ties].[AC_part_PR_in_RAT_got_Annex] x
        WHERE
            x.AC_part_PR_in_RAT_got_ID = e.AC_part_PR_in_RAT_got_ID
        AND
            x.AC_part_PR_in_RAT_got_PositedAt = v.AC_part_PR_in_RAT_got_PositedAt
    );
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[it_lAC_part_PR_in_RAT_got] ON [ties].[lAC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_ID_part,
        i.PR_ID_in,
        ISNULL(i.RAT_ID_got, [RAT_got].RAT_ID),
        i.AC_part_PR_in_RAT_got_PositedAt,
        i.AC_part_PR_in_RAT_got_Reliability
    FROM
        inserted i
    LEFT JOIN
        [knots].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.RAT_Rating;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[ut_lAC_part_PR_in_RAT_got] ON [ties].[lAC_part_PR_in_RAT_got]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(AC_part_PR_in_RAT_got_ID))
        RAISERROR('The identity column AC_part_PR_in_RAT_got_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_ID_part))
        RAISERROR('The identity column AC_ID_part is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_in))
        RAISERROR('The identity column PR_ID_in is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ID,
        cast(ISNULL(CASE
            WHEN UPDATE(AC_part_PR_in_RAT_got_PositedAt) THEN i.AC_part_PR_in_RAT_got_PositedAt
            WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN i.AC_part_PR_in_RAT_got_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [knots].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.RAT_Rating
    WHERE
        i.AC_part_PR_in_RAT_got_ID is not null
    AND (
        CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [ties].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        cast(CASE
            WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN i.AC_part_PR_in_RAT_got_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID
                AND
                    d.RAT_ID_got = CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END
            ) THEN i.AC_part_PR_in_RAT_got_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.AC_ID_part,
        i.PR_ID_in,
        CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END,
        cast(CASE WHEN UPDATE(AC_part_PR_in_RAT_got_PositedAt) THEN i.AC_part_PR_in_RAT_got_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [knots].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.RAT_Rating
    WHERE
        CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(AC_part_PR_in_RAT_got_ChangedAt) OR
            UPDATE(AC_part_PR_in_RAT_got_PositedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID
                AND
                    d.RAT_ID_got = CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END
                AND
                    d.AC_part_PR_in_RAT_got_Reliability = ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_part_PR_in_RAT_got instead of DELETE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[dt_lAC_part_PR_in_RAT_got] ON [ties].[lAC_part_PR_in_RAT_got]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_part_PR_in_RAT_got_Annex] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        d.Metadata_AC_part_PR_in_RAT_got,
        d.AC_part_PR_in_RAT_got_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.it_ST_at_PR_isPlaying', 'TR') IS NOT NULL
DROP TRIGGER [ties].[it_ST_at_PR_isPlaying];
GO
CREATE TRIGGER [ties].[it_ST_at_PR_isPlaying] ON [ties].[ST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_ST_at_PR_isPlaying int not null,
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_ChangedAt datetime2 not null,
        ST_at_PR_isPlaying_PositedAt datetime2 not null,
        ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
        ST_ID_at int not null,
        PR_ID_isPlaying bigint not null,
        primary key (
            ST_ID_at asc,
            PR_ID_isPlaying asc,
            ST_at_PR_isPlaying_ChangedAt desc,
            ST_at_PR_isPlaying_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_ID_at,
            i.PR_ID_isPlaying,
            ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now) AS ST_at_PR_isPlaying_ChangedAt,
            ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now) AS ST_at_PR_isPlaying_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[ST_at_PR_isPlaying_Posit] p
            JOIN
                [ties].[ST_at_PR_isPlaying_Annex] a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            WHERE
                p.ST_ID_at = i.ST_ID_at
            AND
                p.PR_ID_isPlaying = i.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now)
            AND
                a.ST_at_PR_isPlaying_PositedAt = ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now)
            AND
                a.ST_at_PR_isPlaying_Reliability <> ISNULL(i.ST_at_PR_isPlaying_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in ST_at_PR_isPlaying for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_ST_at_PR_isPlaying, 0),
        CASE
            WHEN p.ST_at_PR_isPlaying_ID is null
            THEN 'P' -- new posit
            WHEN a.ST_at_PR_isPlaying_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
        ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now),
        ISNULL(i.ST_at_PR_isPlaying_Reliability, 1),
        i.ST_ID_at,
        i.PR_ID_isPlaying
    FROM
        inserted i
    LEFT JOIN
        [ties].[ST_at_PR_isPlaying_Posit] p
    ON
        p.ST_ID_at = i.ST_ID_at
    AND
        p.PR_ID_isPlaying = i.PR_ID_isPlaying
    AND
        p.ST_at_PR_isPlaying_ChangedAt = i.ST_at_PR_isPlaying_ChangedAt
    LEFT JOIN
        [ties].[ST_at_PR_isPlaying_Annex] a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    AND
        a.ST_at_PR_isPlaying_PositedAt = i.ST_at_PR_isPlaying_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.ST_at_PR_isPlaying_ID is null OR a.ST_at_PR_isPlaying_ID is null)
    AND
        i.ST_ID_at is not null
    AND
        i.PR_ID_isPlaying is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_ST_at_PR_isPlaying,
        'X', -- existing data
        x.ST_at_PR_isPlaying_ChangedAt,
        x.ST_at_PR_isPlaying_PositedAt,
        x.ST_at_PR_isPlaying_Reliability,
        x.ST_ID_at,
        x.PR_ID_isPlaying
    FROM (
        SELECT
            a.Metadata_ST_at_PR_isPlaying,
            p.ST_at_PR_isPlaying_ChangedAt,
            a.ST_at_PR_isPlaying_PositedAt,
            a.ST_at_PR_isPlaying_Reliability,
            p.ST_ID_at,
            p.PR_ID_isPlaying,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.ST_ID_at,
                    p.PR_ID_isPlaying,
                    p.ST_at_PR_isPlaying_ChangedAt,
                    a.ST_at_PR_isPlaying_PositedAt
                ORDER BY
                    a.ST_at_PR_isPlaying_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                ST_ID_at,
                PR_ID_isPlaying
            FROM
                @inserted
        ) i
        JOIN
            [ties].[ST_at_PR_isPlaying_Posit] p
        ON
            p.ST_ID_at = i.ST_ID_at
        AND
            p.PR_ID_isPlaying = i.PR_ID_isPlaying
        JOIN
            [ties].[ST_at_PR_isPlaying_Annex] a
        ON
            a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.ST_ID_at = x.ST_ID_at
        AND
            n.PR_ID_isPlaying = x.PR_ID_isPlaying
        AND
            n.ST_at_PR_isPlaying_ChangedAt = x.ST_at_PR_isPlaying_ChangedAt
        AND
            n.ST_at_PR_isPlaying_PositedAt = x.ST_at_PR_isPlaying_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_ST_at_PR_isPlaying int not null,
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_ChangedAt datetime2 not null,
        ST_at_PR_isPlaying_PositedAt datetime2 not null,
        ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
        ST_ID_at int not null,
        PR_ID_isPlaying bigint not null
    );
    INSERT INTO @retracted (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_StatementType,
        ST_at_PR_isPlaying_ChangedAt,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability,
        ST_ID_at,
        PR_ID_isPlaying
    )
    SELECT
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_StatementType,
        ST_at_PR_isPlaying_ChangedAt,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability,
        ST_ID_at,
        PR_ID_isPlaying
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.ST_at_PR_isPlaying_Reliability as previous_ST_at_PR_isPlaying_Reliability,
            fol.ST_at_PR_isPlaying_Reliability as following_ST_at_PR_isPlaying_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.ST_at_PR_isPlaying_Reliability
            FROM
                @inserted p
            WHERE
                p.ST_ID_at = a.ST_ID_at
            AND
                p.PR_ID_isPlaying = a.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = a.ST_at_PR_isPlaying_ChangedAt
            AND
                p.ST_at_PR_isPlaying_PositedAt < a.ST_at_PR_isPlaying_PositedAt
            ORDER BY
                p.ST_at_PR_isPlaying_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.ST_at_PR_isPlaying_Reliability
            FROM
                @inserted p
            WHERE
                p.ST_ID_at = a.ST_ID_at
            AND
                p.PR_ID_isPlaying = a.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = a.ST_at_PR_isPlaying_ChangedAt
            AND
                p.ST_at_PR_isPlaying_PositedAt > a.ST_at_PR_isPlaying_PositedAt
            ORDER BY
                p.ST_at_PR_isPlaying_PositedAt ASC
        ) fol
        WHERE
            (a.ST_at_PR_isPlaying_Reliability = 0 AND isnull(pre.ST_at_PR_isPlaying_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.ST_at_PR_isPlaying_Reliability = 1 AND fol.ST_at_PR_isPlaying_Reliability = 0)
    ) i
    WHERE
        i.ST_at_PR_isPlaying_StatementType <> 'X'
    AND (
            (i.ST_at_PR_isPlaying_Reliability = 0 AND i.previous_ST_at_PR_isPlaying_Reliability = 1)
        OR
            (i.ST_at_PR_isPlaying_Reliability = 1 AND i.following_ST_at_PR_isPlaying_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [ties].[ST_at_PR_isPlaying_Posit] (
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    FROM
        @inserted
    WHERE
        ST_at_PR_isPlaying_StatementType = 'P';
    INSERT INTO [ties].[ST_at_PR_isPlaying_Annex] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        v.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        v.ST_at_PR_isPlaying_PositedAt,
        v.ST_at_PR_isPlaying_Reliability
    FROM
        @inserted v
    JOIN
        [ties].[ST_at_PR_isPlaying_Posit] p
    ON
        p.ST_ID_at = v.ST_ID_at
    AND
        p.PR_ID_isPlaying = v.PR_ID_isPlaying
    AND
        p.ST_at_PR_isPlaying_ChangedAt = v.ST_at_PR_isPlaying_ChangedAt
    WHERE
        v.ST_at_PR_isPlaying_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_isPlaying instead of INSERT trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[it_lST_at_PR_isPlaying] ON [ties].[lST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[ST_at_PR_isPlaying] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        i.Metadata_ST_at_PR_isPlaying,
        i.ST_at_PR_isPlaying_ChangedAt,
        i.ST_ID_at,
        i.PR_ID_isPlaying,
        i.ST_at_PR_isPlaying_PositedAt,
        i.ST_at_PR_isPlaying_Reliability
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[dt_lST_at_PR_isPlaying] ON [ties].[lST_at_PR_isPlaying]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[ST_at_PR_isPlaying_Annex] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        d.Metadata_ST_at_PR_isPlaying,
        d.ST_at_PR_isPlaying_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_parent_AC_child_PAT_having instead of INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.it_AC_parent_AC_child_PAT_having', 'TR') IS NOT NULL
DROP TRIGGER [ties].[it_AC_parent_AC_child_PAT_having];
GO
CREATE TRIGGER [ties].[it_AC_parent_AC_child_PAT_having] ON [ties].[AC_parent_AC_child_PAT_having]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_AC_parent_AC_child_PAT_having int not null,
        AC_parent_AC_child_PAT_having_StatementType char(1) not null,
        AC_parent_AC_child_PAT_having_PositedAt datetime2 not null,
        AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
        AC_ID_parent smallint not null,
        AC_ID_child smallint not null,
        PAT_ID_having tinyint not null,
        primary key (
            AC_ID_parent asc,
            AC_ID_child asc,
            PAT_ID_having asc,
            AC_parent_AC_child_PAT_having_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_parent,
            i.AC_ID_child,
            i.PAT_ID_having,
            ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now) AS AC_parent_AC_child_PAT_having_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_parent_AC_child_PAT_having_Posit] p
            JOIN
                [ties].[AC_parent_AC_child_PAT_having_Annex] a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            WHERE
                p.AC_ID_parent = i.AC_ID_parent
            AND
                p.AC_ID_child = i.AC_ID_child
            AND
                p.PAT_ID_having = i.PAT_ID_having
            AND
                a.AC_parent_AC_child_PAT_having_PositedAt = ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now)
            AND
                a.AC_parent_AC_child_PAT_having_Reliability <> ISNULL(i.AC_parent_AC_child_PAT_having_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in AC_parent_AC_child_PAT_having for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_parent_AC_child_PAT_having, 0),
        CASE
            WHEN p.AC_parent_AC_child_PAT_having_ID is null
            THEN 'P' -- new posit
            WHEN a.AC_parent_AC_child_PAT_having_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now),
        ISNULL(i.AC_parent_AC_child_PAT_having_Reliability, 1),
        i.AC_ID_parent,
        i.AC_ID_child,
        i.PAT_ID_having
    FROM
        inserted i
    LEFT JOIN
        [ties].[AC_parent_AC_child_PAT_having_Posit] p
    ON
        p.AC_ID_parent = i.AC_ID_parent
    AND
        p.AC_ID_child = i.AC_ID_child
    AND
        p.PAT_ID_having = i.PAT_ID_having
    LEFT JOIN
        [ties].[AC_parent_AC_child_PAT_having_Annex] a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    AND
        a.AC_parent_AC_child_PAT_having_PositedAt = i.AC_parent_AC_child_PAT_having_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.AC_parent_AC_child_PAT_having_ID is null OR a.AC_parent_AC_child_PAT_having_ID is null)
    AND
        i.AC_ID_parent is not null
    AND
        i.AC_ID_child is not null
    AND
        i.PAT_ID_having is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_AC_parent_AC_child_PAT_having,
        'X', -- existing data
        x.AC_parent_AC_child_PAT_having_PositedAt,
        x.AC_parent_AC_child_PAT_having_Reliability,
        x.AC_ID_parent,
        x.AC_ID_child,
        x.PAT_ID_having
    FROM (
        SELECT
            a.Metadata_AC_parent_AC_child_PAT_having,
            a.AC_parent_AC_child_PAT_having_PositedAt,
            a.AC_parent_AC_child_PAT_having_Reliability,
            p.AC_ID_parent,
            p.AC_ID_child,
            p.PAT_ID_having,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.AC_ID_parent,
                    p.AC_ID_child,
                    p.PAT_ID_having,
                    a.AC_parent_AC_child_PAT_having_PositedAt
                ORDER BY
                    a.AC_parent_AC_child_PAT_having_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                AC_ID_parent,
                AC_ID_child,
                PAT_ID_having
            FROM
                @inserted
        ) i
        JOIN
            [ties].[AC_parent_AC_child_PAT_having_Posit] p
        ON
            p.AC_ID_parent = i.AC_ID_parent
        AND
            p.AC_ID_child = i.AC_ID_child
        AND
            p.PAT_ID_having = i.PAT_ID_having
        JOIN
            [ties].[AC_parent_AC_child_PAT_having_Annex] a
        ON
            a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.AC_ID_parent = x.AC_ID_parent
        AND
            n.AC_ID_child = x.AC_ID_child
        AND
            n.PAT_ID_having = x.PAT_ID_having
        AND
            n.AC_parent_AC_child_PAT_having_PositedAt = x.AC_parent_AC_child_PAT_having_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_AC_parent_AC_child_PAT_having int not null,
        AC_parent_AC_child_PAT_having_StatementType char(1) not null,
        AC_parent_AC_child_PAT_having_PositedAt datetime2 not null,
        AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
        AC_ID_parent smallint not null,
        AC_ID_child smallint not null,
        PAT_ID_having tinyint not null
    );
    INSERT INTO @retracted (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_StatementType,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    SELECT
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_StatementType,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.AC_parent_AC_child_PAT_having_Reliability as previous_AC_parent_AC_child_PAT_having_Reliability,
            fol.AC_parent_AC_child_PAT_having_Reliability as following_AC_parent_AC_child_PAT_having_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.AC_parent_AC_child_PAT_having_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_parent = a.AC_ID_parent
            AND
                p.AC_ID_child = a.AC_ID_child
            AND
                p.PAT_ID_having = a.PAT_ID_having
            AND
                p.AC_parent_AC_child_PAT_having_PositedAt < a.AC_parent_AC_child_PAT_having_PositedAt
            ORDER BY
                p.AC_parent_AC_child_PAT_having_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.AC_parent_AC_child_PAT_having_Reliability
            FROM
                @inserted p
            WHERE
                p.AC_ID_parent = a.AC_ID_parent
            AND
                p.AC_ID_child = a.AC_ID_child
            AND
                p.PAT_ID_having = a.PAT_ID_having
            AND
                p.AC_parent_AC_child_PAT_having_PositedAt > a.AC_parent_AC_child_PAT_having_PositedAt
            ORDER BY
                p.AC_parent_AC_child_PAT_having_PositedAt ASC
        ) fol
        WHERE
            (a.AC_parent_AC_child_PAT_having_Reliability = 0 AND isnull(pre.AC_parent_AC_child_PAT_having_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.AC_parent_AC_child_PAT_having_Reliability = 1 AND fol.AC_parent_AC_child_PAT_having_Reliability = 0)
    ) i
    WHERE
        i.AC_parent_AC_child_PAT_having_StatementType <> 'X'
    AND (
            (i.AC_parent_AC_child_PAT_having_Reliability = 0 AND i.previous_AC_parent_AC_child_PAT_having_Reliability = 1)
        OR
            (i.AC_parent_AC_child_PAT_having_Reliability = 1 AND i.following_AC_parent_AC_child_PAT_having_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [ties].[AC_parent_AC_child_PAT_having_Posit] (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having
    FROM
        @inserted
    WHERE
        AC_parent_AC_child_PAT_having_StatementType = 'P';
    INSERT INTO [ties].[AC_parent_AC_child_PAT_having_Annex] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        v.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        v.AC_parent_AC_child_PAT_having_PositedAt,
        v.AC_parent_AC_child_PAT_having_Reliability
    FROM
        @inserted v
    JOIN
        [ties].[AC_parent_AC_child_PAT_having_Posit] p
    ON
        p.AC_ID_parent = v.AC_ID_parent
    AND
        p.AC_ID_child = v.AC_ID_child
    AND
        p.PAT_ID_having = v.PAT_ID_having
    WHERE
        v.AC_parent_AC_child_PAT_having_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_parent_AC_child_PAT_having instead of INSERT trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[it_lAC_parent_AC_child_PAT_having] ON [ties].[lAC_parent_AC_child_PAT_having]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_parent_AC_child_PAT_having] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        i.Metadata_AC_parent_AC_child_PAT_having,
        i.AC_ID_parent,
        i.AC_ID_child,
        ISNULL(i.PAT_ID_having, [PAT_having].PAT_ID),
        i.AC_parent_AC_child_PAT_having_PositedAt,
        i.AC_parent_AC_child_PAT_having_Reliability
    FROM
        inserted i
    LEFT JOIN
        [knots].[PAT_ParentalType] [PAT_having]
    ON
        [PAT_having].PAT_ParentalType = i.PAT_ParentalType;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[dt_lAC_parent_AC_child_PAT_having] ON [ties].[lAC_parent_AC_child_PAT_having]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[AC_parent_AC_child_PAT_having_Annex] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        d.Metadata_AC_parent_AC_child_PAT_having,
        d.AC_parent_AC_child_PAT_having_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_content_ST_location_EV_of instead of INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.it_PR_content_ST_location_EV_of', 'TR') IS NOT NULL
DROP TRIGGER [ties].[it_PR_content_ST_location_EV_of];
GO
CREATE TRIGGER [ties].[it_PR_content_ST_location_EV_of] ON [ties].[PR_content_ST_location_EV_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @inserted TABLE (
        Metadata_PR_content_ST_location_EV_of int not null,
        PR_content_ST_location_EV_of_StatementType char(1) not null,
        PR_content_ST_location_EV_of_ChangedAt datetime2 not null,
        PR_content_ST_location_EV_of_PositedAt datetime2 not null,
        PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
        PR_ID_content bigint not null,
        ST_ID_location int not null,
        EV_ID_of numeric(12,0) not null,
        primary key (
            PR_ID_content asc,
            ST_ID_location asc,
            EV_ID_of asc,
            PR_content_ST_location_EV_of_ChangedAt desc,
            PR_content_ST_location_EV_of_PositedAt desc
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_ID_content,
            i.ST_ID_location,
            i.EV_ID_of,
            ISNULL(i.PR_content_ST_location_EV_of_ChangedAt, @now) AS PR_content_ST_location_EV_of_ChangedAt,
            ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now) AS PR_content_ST_location_EV_of_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[PR_content_ST_location_EV_of_Posit] p
            JOIN
                [ties].[PR_content_ST_location_EV_of_Annex] a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            WHERE
                p.PR_ID_content = i.PR_ID_content
            AND
                p.ST_ID_location = i.ST_ID_location
            AND
                p.EV_ID_of = i.EV_ID_of
            AND
                p.PR_content_ST_location_EV_of_ChangedAt = ISNULL(i.PR_content_ST_location_EV_of_ChangedAt, @now)
            AND
                a.PR_content_ST_location_EV_of_PositedAt = ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now)
            AND
                a.PR_content_ST_location_EV_of_Reliability <> ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
        )
        FOR XML PATH('')
    );
    IF @message is not null
    BEGIN
        SET @message = 'Contradiction in PR_content_ST_location_EV_of for: ' + @message;
        RAISERROR(@message, 16, 1);
        ROLLBACK;
        RETURN;
    END
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_PR_content_ST_location_EV_of, 0),
        CASE
            WHEN p.PR_content_ST_location_EV_of_ID is null
            THEN 'P' -- new posit
            WHEN a.PR_content_ST_location_EV_of_ID is null
            THEN 'A' -- new assertion
        END,
        ISNULL(i.PR_content_ST_location_EV_of_ChangedAt, @now),
        ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now),
        ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1),
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of
    FROM
        inserted i
    LEFT JOIN
        [ties].[PR_content_ST_location_EV_of_Posit] p
    ON
        p.PR_ID_content = i.PR_ID_content
    AND
        p.ST_ID_location = i.ST_ID_location
    AND
        p.EV_ID_of = i.EV_ID_of
    AND
        p.PR_content_ST_location_EV_of_ChangedAt = i.PR_content_ST_location_EV_of_ChangedAt
    LEFT JOIN
        [ties].[PR_content_ST_location_EV_of_Annex] a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    AND
        a.PR_content_ST_location_EV_of_PositedAt = i.PR_content_ST_location_EV_of_PositedAt
    WHERE -- either the posit or the assertion must be different (exclude the identical)
        (p.PR_content_ST_location_EV_of_ID is null OR a.PR_content_ST_location_EV_of_ID is null)
    AND
        i.PR_ID_content is not null
    AND
        i.ST_ID_location is not null
    AND
        i.EV_ID_of is not null;
    INSERT INTO @inserted
    SELECT
        x.Metadata_PR_content_ST_location_EV_of,
        'X', -- existing data
        x.PR_content_ST_location_EV_of_ChangedAt,
        x.PR_content_ST_location_EV_of_PositedAt,
        x.PR_content_ST_location_EV_of_Reliability,
        x.PR_ID_content,
        x.ST_ID_location,
        x.EV_ID_of
    FROM (
        SELECT
            a.Metadata_PR_content_ST_location_EV_of,
            p.PR_content_ST_location_EV_of_ChangedAt,
            a.PR_content_ST_location_EV_of_PositedAt,
            a.PR_content_ST_location_EV_of_Reliability,
            p.PR_ID_content,
            p.ST_ID_location,
            p.EV_ID_of,
            -- a correction retracts what it corrects at its own positing time, where the assertion is what is shown
            ROW_NUMBER() OVER (
                PARTITION BY
                    p.PR_ID_content,
                    p.ST_ID_location,
                    p.EV_ID_of,
                    p.PR_content_ST_location_EV_of_ChangedAt,
                    a.PR_content_ST_location_EV_of_PositedAt
                ORDER BY
                    a.PR_content_ST_location_EV_of_Reliability DESC
            ) as shown
        FROM (
            SELECT DISTINCT
                PR_ID_content,
                ST_ID_location,
                EV_ID_of
            FROM
                @inserted
        ) i
        JOIN
            [ties].[PR_content_ST_location_EV_of_Posit] p
        ON
            p.PR_ID_content = i.PR_ID_content
        AND
            p.ST_ID_location = i.ST_ID_location
        AND
            p.EV_ID_of = i.EV_ID_of
        JOIN
            [ties].[PR_content_ST_location_EV_of_Annex] a
        ON
            a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
    ) x
    WHERE
        x.shown = 1
    AND NOT EXISTS ( -- at a positing time that a new row has, the new row is what counts
        SELECT TOP 1
            42
        FROM
            @inserted n
        WHERE
            n.PR_ID_content = x.PR_ID_content
        AND
            n.ST_ID_location = x.ST_ID_location
        AND
            n.EV_ID_of = x.EV_ID_of
        AND
            n.PR_content_ST_location_EV_of_ChangedAt = x.PR_content_ST_location_EV_of_ChangedAt
        AND
            n.PR_content_ST_location_EV_of_PositedAt = x.PR_content_ST_location_EV_of_PositedAt
    );
    DECLARE @retracted TABLE (
        Metadata_PR_content_ST_location_EV_of int not null,
        PR_content_ST_location_EV_of_StatementType char(1) not null,
        PR_content_ST_location_EV_of_ChangedAt datetime2 not null,
        PR_content_ST_location_EV_of_PositedAt datetime2 not null,
        PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
        PR_ID_content bigint not null,
        ST_ID_location int not null,
        EV_ID_of numeric(12,0) not null
    );
    INSERT INTO @retracted (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_StatementType,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_StatementType,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    FROM (
        DELETE a
        OUTPUT
            deleted.*,
            pre.PR_content_ST_location_EV_of_Reliability as previous_PR_content_ST_location_EV_of_Reliability,
            fol.PR_content_ST_location_EV_of_Reliability as following_PR_content_ST_location_EV_of_Reliability
        FROM
            @inserted a
        OUTER APPLY (
            SELECT TOP 1
                p.PR_content_ST_location_EV_of_Reliability
            FROM
                @inserted p
            WHERE
                p.PR_ID_content = a.PR_ID_content
            AND
                p.ST_ID_location = a.ST_ID_location
            AND
                p.EV_ID_of = a.EV_ID_of
            AND
                p.PR_content_ST_location_EV_of_ChangedAt = a.PR_content_ST_location_EV_of_ChangedAt
            AND
                p.PR_content_ST_location_EV_of_PositedAt < a.PR_content_ST_location_EV_of_PositedAt
            ORDER BY
                p.PR_content_ST_location_EV_of_PositedAt DESC
        ) pre
        OUTER APPLY (
            SELECT TOP 1
                p.PR_content_ST_location_EV_of_Reliability
            FROM
                @inserted p
            WHERE
                p.PR_ID_content = a.PR_ID_content
            AND
                p.ST_ID_location = a.ST_ID_location
            AND
                p.EV_ID_of = a.EV_ID_of
            AND
                p.PR_content_ST_location_EV_of_ChangedAt = a.PR_content_ST_location_EV_of_ChangedAt
            AND
                p.PR_content_ST_location_EV_of_PositedAt > a.PR_content_ST_location_EV_of_PositedAt
            ORDER BY
                p.PR_content_ST_location_EV_of_PositedAt ASC
        ) fol
        WHERE
            (a.PR_content_ST_location_EV_of_Reliability = 0 AND isnull(pre.PR_content_ST_location_EV_of_Reliability, 1) = 1) -- a retraction with nothing before it is dropped, also when assertive
        OR
            (a.PR_content_ST_location_EV_of_Reliability = 1 AND fol.PR_content_ST_location_EV_of_Reliability = 0)
    ) i
    WHERE
        i.PR_content_ST_location_EV_of_StatementType <> 'X'
    AND (
            (i.PR_content_ST_location_EV_of_Reliability = 0 AND i.previous_PR_content_ST_location_EV_of_Reliability = 1)
        OR
            (i.PR_content_ST_location_EV_of_Reliability = 1 AND i.following_PR_content_ST_location_EV_of_Reliability = 0)
        );
    -- add the retractions
    INSERT INTO @inserted SELECT * FROM @retracted;
    INSERT INTO [ties].[PR_content_ST_location_EV_of_Posit] (
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT DISTINCT -- a posit stated at several positing times is made once
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    FROM
        @inserted
    WHERE
        PR_content_ST_location_EV_of_StatementType = 'P';
    INSERT INTO [ties].[PR_content_ST_location_EV_of_Annex] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        v.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        v.PR_content_ST_location_EV_of_PositedAt,
        v.PR_content_ST_location_EV_of_Reliability
    FROM
        @inserted v
    JOIN
        [ties].[PR_content_ST_location_EV_of_Posit] p
    ON
        p.PR_ID_content = v.PR_ID_content
    AND
        p.ST_ID_location = v.ST_ID_location
    AND
        p.EV_ID_of = v.EV_ID_of
    AND
        p.PR_content_ST_location_EV_of_ChangedAt = v.PR_content_ST_location_EV_of_ChangedAt
    WHERE
        v.PR_content_ST_location_EV_of_StatementType in ('P', 'A');
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[it_lPR_content_ST_location_EV_of] ON [ties].[lPR_content_ST_location_EV_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[PR_content_ST_location_EV_of] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_content_ST_location_EV_of_ChangedAt,
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of,
        i.PR_content_ST_location_EV_of_PositedAt,
        i.PR_content_ST_location_EV_of_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[ut_lPR_content_ST_location_EV_of] ON [ties].[lPR_content_ST_location_EV_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(PR_content_ST_location_EV_of_ID))
        RAISERROR('The identity column PR_content_ST_location_EV_of_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[PR_content_ST_location_EV_of_Annex] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_content_ST_location_EV_of_ID,
        cast(ISNULL(CASE
            WHEN UPDATE(PR_content_ST_location_EV_of_PositedAt) THEN i.PR_content_ST_location_EV_of_PositedAt
            WHEN UPDATE(PR_content_ST_location_EV_of_ChangedAt) THEN i.PR_content_ST_location_EV_of_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    WHERE
        i.PR_content_ST_location_EV_of_ID is not null
    AND (
        i.PR_ID_content is null
    OR
        i.ST_ID_location is null
    OR
        i.EV_ID_of is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [ties].[PR_content_ST_location_EV_of] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        cast(CASE
            WHEN UPDATE(PR_content_ST_location_EV_of_ChangedAt) THEN i.PR_content_ST_location_EV_of_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.PR_content_ST_location_EV_of_ID = i.PR_content_ST_location_EV_of_ID
                AND
                    d.PR_ID_content = i.PR_ID_content
                AND
                    d.ST_ID_location = i.ST_ID_location
                AND
                    d.EV_ID_of = i.EV_ID_of
            ) THEN i.PR_content_ST_location_EV_of_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of,
        cast(CASE WHEN UPDATE(PR_content_ST_location_EV_of_PositedAt) THEN i.PR_content_ST_location_EV_of_PositedAt ELSE @now END as datetime2),
        ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.PR_ID_content is not null
    AND
        i.ST_ID_location is not null
    AND
        i.EV_ID_of is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(PR_content_ST_location_EV_of_ChangedAt) OR
            UPDATE(PR_content_ST_location_EV_of_PositedAt) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.PR_content_ST_location_EV_of_ID = i.PR_content_ST_location_EV_of_ID
                AND
                    d.PR_ID_content = i.PR_ID_content
                AND
                    d.ST_ID_location = i.ST_ID_location
                AND
                    d.EV_ID_of = i.EV_ID_of
                AND
                    d.PR_content_ST_location_EV_of_Reliability = ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [ties].[dt_lPR_content_ST_location_EV_of] ON [ties].[lPR_content_ST_location_EV_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [ties].[PR_content_ST_location_EV_of_Annex] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        d.Metadata_PR_content_ST_location_EV_of,
        d.PR_content_ST_location_EV_of_ID,
        @now,
        0
    FROM
        deleted d;
END
GO
