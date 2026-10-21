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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_AC_partner_AC_with_ONG_currently bigint not null,
        AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_Version bigint not null,
        AC_partner_AC_with_ONG_currently_StatementType char(1) not null,
        AC_partner_AC_with_ONG_currently_Who smallint not null,
        AC_partner_AC_with_ONG_currently_PositedAt datetime2(3) not null,
        AC_partner_AC_with_ONG_currently_Confidence decimal(7,3) not null,
        AC_partner_AC_with_ONG_currently_Stance char(1) not null,
        AC_ID_partner smallint not null,
        AC_ID_with smallint not null,
        ONG_ID_currently tinyint not null,
        primary key (
            AC_partner_AC_with_ONG_currently_Version,
            AC_partner_AC_with_ONG_currently_Who,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_partner,
            i.AC_ID_with,
            i.ONG_ID_currently,
            ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now) AS AC_partner_AC_with_ONG_currently_ChangedAt,
            ISNULL(i.AC_partner_AC_with_ONG_currently_Who, 0) AS AC_partner_AC_with_ONG_currently_Who,
            ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now) AS AC_partner_AC_with_ONG_currently_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_partner_AC_with_ONG_currently_Fact] p
            JOIN
                [ties].[AC_partner_AC_with_ONG_currently_Meta] a
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
                a.AC_partner_AC_with_ONG_currently_Who = ISNULL(i.AC_partner_AC_with_ONG_currently_Who, 0)
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt = ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now)
            AND
                a.AC_partner_AC_with_ONG_currently_Confidence <> ISNULL(i.AC_partner_AC_with_ONG_currently_Confidence, 0.75)
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
        ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_partner_AC_with_ONG_currently_Who,
                i.AC_ID_partner,
                i.AC_ID_with,
                i.ONG_ID_currently
            ORDER BY
                ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now),
                i.AC_partner_AC_with_ONG_currently_PositedAt ASC,
                i.AC_partner_AC_with_ONG_currently_Confidence ASC
        ),
        'X',
        ISNULL(i.AC_partner_AC_with_ONG_currently_Who, 0),
        ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Confidence, 0.75),
        CAST(
            case
                when i.AC_partner_AC_with_ONG_currently_Confidence > 0.25 then '+'
                when i.AC_partner_AC_with_ONG_currently_Confidence = 0.25 then '?'
                when i.AC_partner_AC_with_ONG_currently_Confidence < 0.25 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.AC_ID_partner,
        i.AC_ID_with,
        i.ONG_ID_currently
    FROM
        inserted i
    WHERE
        i.AC_ID_partner is not null
    AND
        i.AC_ID_with is not null
    AND
        i.ONG_ID_currently is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [ties].[AC_partner_AC_with_ONG_currently_Fact] p
            JOIN
                [ties].[AC_partner_AC_with_ONG_currently_Meta] a
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
                a.AC_partner_AC_with_ONG_currently_Who = ISNULL(i.AC_partner_AC_with_ONG_currently_Who, 0)
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt = ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(AC_partner_AC_with_ONG_currently_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.AC_partner_AC_with_ONG_currently_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.AC_partner_AC_with_ONG_currently_ID
                        FROM
                            [ties].[tAC_partner_AC_with_ONG_currently](v.AC_partner_AC_with_ONG_currently_Who, v.AC_partner_AC_with_ONG_currently_ChangedAt, v.AC_partner_AC_with_ONG_currently_PositedAt, v.AC_partner_AC_with_ONG_currently_Stance) t
                        WHERE
                            t.AC_partner_AC_with_ONG_currently_Confidence = v.AC_partner_AC_with_ONG_currently_Confidence
                        AND
                            t.AC_partner_AC_with_ONG_currently_ChangedAt = v.AC_partner_AC_with_ONG_currently_ChangedAt
                        AND
                            t.AC_ID_partner = v.AC_ID_partner
                        AND
                            t.AC_ID_with = v.AC_ID_with
                        AND
                            t.ONG_ID_currently = v.ONG_ID_currently
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_partner_AC_with_ONG_currently_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.AC_ID_partner,
                                pre.AC_ID_with,
                                pre.ONG_ID_currently
                            FROM
                                [ties].[rAC_partner_AC_with_ONG_currently] (
                                    v.AC_partner_AC_with_ONG_currently_Who,
                                    v.AC_partner_AC_with_ONG_currently_ChangedAt,
                                    v.AC_partner_AC_with_ONG_currently_PositedAt
                                ) pre
                            WHERE
                            (
                                    pre.AC_ID_partner = v.AC_ID_partner
                                AND
                                    pre.AC_ID_with = v.AC_ID_with
                                AND
                                    pre.ONG_ID_currently = v.ONG_ID_currently
                            )
                            AND
                                pre.AC_partner_AC_with_ONG_currently_ChangedAt < v.AC_partner_AC_with_ONG_currently_ChangedAt
                            AND
                                pre.AC_partner_AC_with_ONG_currently_Stance = v.AC_partner_AC_with_ONG_currently_Stance
                            ORDER BY
                                pre.AC_partner_AC_with_ONG_currently_ChangedAt DESC,
                                pre.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) s
                        WHERE
                            s.AC_ID_partner = v.AC_ID_partner
                        AND
                            s.AC_ID_with = v.AC_ID_with
                        AND
                            s.ONG_ID_currently = v.ONG_ID_currently
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.AC_ID_partner,
                                fol.AC_ID_with,
                                fol.ONG_ID_currently
                            FROM
                                [ties].[fAC_partner_AC_with_ONG_currently] (
                                    v.AC_partner_AC_with_ONG_currently_Who,
                                    v.AC_partner_AC_with_ONG_currently_ChangedAt,
                                    v.AC_partner_AC_with_ONG_currently_PositedAt
                                ) fol
                            WHERE
                            (
                                    fol.AC_ID_partner = v.AC_ID_partner
                                AND
                                    fol.AC_ID_with = v.AC_ID_with
                                AND
                                    fol.ONG_ID_currently = v.ONG_ID_currently
                            )
                            AND
                                fol.AC_partner_AC_with_ONG_currently_ChangedAt > v.AC_partner_AC_with_ONG_currently_ChangedAt
                            AND
                                fol.AC_partner_AC_with_ONG_currently_Stance = v.AC_partner_AC_with_ONG_currently_Stance
                            ORDER BY
                                fol.AC_partner_AC_with_ONG_currently_ChangedAt ASC,
                                fol.AC_partner_AC_with_ONG_currently_PositedAt DESC
                        ) s
                        WHERE
                            s.AC_ID_partner = v.AC_ID_partner
                        AND
                            s.AC_ID_with = v.AC_ID_with
                        AND
                            s.ONG_ID_currently = v.ONG_ID_currently
                    )
                    THEN 'R' -- restatement of the following version
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [ties].[AC_partner_AC_with_ONG_currently_Fact] p
        ON
            p.AC_ID_partner = v.AC_ID_partner
        AND
            p.AC_ID_with = v.AC_ID_with
        AND
            p.ONG_ID_currently = v.ONG_ID_currently
        AND
            p.AC_partner_AC_with_ONG_currently_ChangedAt = v.AC_partner_AC_with_ONG_currently_ChangedAt
        WHERE
            v.AC_partner_AC_with_ONG_currently_Version = @currentVersion;
        INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Fact] (
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently
        FROM
            @inserted
        WHERE
            AC_partner_AC_with_ONG_currently_Version = @currentVersion
        AND
            AC_partner_AC_with_ONG_currently_StatementType in ('N','R');
        INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Meta] (
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Who,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Confidence
        )
        SELECT
            v.Metadata_AC_partner_AC_with_ONG_currently,
            p.AC_partner_AC_with_ONG_currently_ID,
            v.AC_partner_AC_with_ONG_currently_Who,
            v.AC_partner_AC_with_ONG_currently_PositedAt,
            v.AC_partner_AC_with_ONG_currently_Confidence
        FROM
            @inserted v
        JOIN
            [ties].[AC_partner_AC_with_ONG_currently_Fact] p
        ON
            p.AC_ID_partner = v.AC_ID_partner
        AND
            p.AC_ID_with = v.AC_ID_with
        AND
            p.ONG_ID_currently = v.ONG_ID_currently
        AND
            p.AC_partner_AC_with_ONG_currently_ChangedAt = v.AC_partner_AC_with_ONG_currently_ChangedAt
        WHERE
            v.AC_partner_AC_with_ONG_currently_Version = @currentVersion
        AND
            v.AC_partner_AC_with_ONG_currently_StatementType in ('S','N','D','R');
    END
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
        AC_partner_AC_with_ONG_currently_Who,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Confidence
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        i.AC_partner_AC_with_ONG_currently_ChangedAt,
        i.AC_ID_partner,
        i.AC_ID_with,
        ISNULL(i.ONG_ID_currently, [ONG_currently].ONG_ID),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Who, i.Who),
        i.AC_partner_AC_with_ONG_currently_PositedAt,
        i.AC_partner_AC_with_ONG_currently_Confidence
    FROM
        inserted i
    LEFT JOIN
        [knots].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing;
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_AC_partner_AC_with_ONG_currently_Who bit = CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_Who) THEN 1 ELSE 0 END;
    DECLARE @updated_Who bit = CASE WHEN UPDATE(Who) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_partner_AC_with_ONG_currently_PositedAt bit = CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_partner_AC_with_ONG_currently_ChangedAt bit = CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_currently_ONG_Ongoing bit = CASE WHEN UPDATE(currently_ONG_Ongoing) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_partner_AC_with_ONG_currently_Stance))
        RAISERROR('The computed assertion column AC_partner_AC_with_ONG_currently_Stance is not updatable.', 16, 1);
    IF(UPDATE(AC_partner_AC_with_ONG_currently_ID))
        RAISERROR('The identity column AC_partner_AC_with_ONG_currently_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Meta] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Who,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Confidence
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        i.AC_partner_AC_with_ONG_currently_ID,
        ISNULL(CASE WHEN @updated_AC_partner_AC_with_ONG_currently_Who = 1 THEN i.AC_partner_AC_with_ONG_currently_Who ELSE i.Who END, 0),
        cast(ISNULL(CASE
            WHEN @updated_AC_partner_AC_with_ONG_currently_PositedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_PositedAt
            WHEN @updated_AC_partner_AC_with_ONG_currently_ChangedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_ChangedAt
        END, @now) as datetime2(3)),
        0.25
    FROM
        inserted i
    LEFT JOIN
        [knots].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing
    WHERE
        i.AC_partner_AC_with_ONG_currently_ID is not null
    AND (
        i.AC_ID_partner is null
    OR
        i.AC_ID_with is null
    OR
        CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_Who,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Confidence
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        cast(CASE
            WHEN @updated_AC_partner_AC_with_ONG_currently_ChangedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_partner_AC_with_ONG_currently_ID = i.AC_partner_AC_with_ONG_currently_ID
                AND
                    d.AC_partner_AC_with_ONG_currently_Who = i.AC_partner_AC_with_ONG_currently_Who
                AND
                    d.AC_ID_partner = i.AC_ID_partner
                AND
                    d.AC_ID_with = i.AC_ID_with
                AND
                    d.ONG_ID_currently = CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END
            ) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.AC_ID_partner,
        i.AC_ID_with,
        CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END,
        ISNULL(CASE WHEN @updated_AC_partner_AC_with_ONG_currently_Who = 1 THEN i.AC_partner_AC_with_ONG_currently_Who ELSE i.Who END, 0),
        cast(CASE WHEN @updated_AC_partner_AC_with_ONG_currently_PositedAt = 1 THEN i.AC_partner_AC_with_ONG_currently_PositedAt ELSE @now END as datetime2(3)),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Confidence, 0.75)
    FROM
        inserted i
    LEFT JOIN
        [knots].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing
    WHERE
        i.AC_ID_partner is not null
    AND
        i.AC_ID_with is not null
    AND
        CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            @updated_AC_partner_AC_with_ONG_currently_ChangedAt = 1 OR
            @updated_AC_partner_AC_with_ONG_currently_PositedAt = 1 OR
            @updated_AC_partner_AC_with_ONG_currently_Who = 1 OR
            @updated_Who = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_partner_AC_with_ONG_currently_ID = i.AC_partner_AC_with_ONG_currently_ID
                AND
                    d.AC_partner_AC_with_ONG_currently_Who = i.AC_partner_AC_with_ONG_currently_Who
                AND
                    d.AC_ID_partner = i.AC_ID_partner
                AND
                    d.AC_ID_with = i.AC_ID_with
                AND
                    d.ONG_ID_currently = CASE WHEN @updated_currently_ONG_Ongoing = 1 THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END
                AND
                    d.AC_partner_AC_with_ONG_currently_Confidence = ISNULL(i.AC_partner_AC_with_ONG_currently_Confidence, 0.75)
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
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently_Meta] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Who,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Confidence
    )
    SELECT
        d.Metadata_AC_partner_AC_with_ONG_currently,
        d.AC_partner_AC_with_ONG_currently_ID,
        d.AC_partner_AC_with_ONG_currently_Who,
        @now,
        0.25
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_AC_subset_PN_of bigint not null,
        AC_subset_PN_of_Version bigint not null,
        AC_subset_PN_of_StatementType char(1) not null,
        AC_subset_PN_of_Who smallint not null,
        AC_subset_PN_of_PositedAt datetime2(3) not null,
        AC_subset_PN_of_Confidence decimal(7,3) not null,
        AC_subset_PN_of_Stance char(1) not null,
        AC_ID_subset smallint not null,
        PN_ID_of bigint not null,
        primary key (
            AC_subset_PN_of_Version,
            AC_subset_PN_of_Who,
            AC_ID_subset,
            PN_ID_of
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_subset,
            i.PN_ID_of,
            ISNULL(i.AC_subset_PN_of_Who, 0) AS AC_subset_PN_of_Who,
            ISNULL(i.AC_subset_PN_of_PositedAt, @now) AS AC_subset_PN_of_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_subset_PN_of_Fact] p
            JOIN
                [ties].[AC_subset_PN_of_Meta] a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            WHERE
                p.AC_ID_subset = i.AC_ID_subset
            AND
                p.PN_ID_of = i.PN_ID_of
            AND
                a.AC_subset_PN_of_Who = ISNULL(i.AC_subset_PN_of_Who, 0)
            AND
                a.AC_subset_PN_of_PositedAt = ISNULL(i.AC_subset_PN_of_PositedAt, @now)
            AND
                a.AC_subset_PN_of_Confidence <> ISNULL(i.AC_subset_PN_of_Confidence, 0.75)
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
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_subset_PN_of_Who,
                i.AC_ID_subset,
                i.PN_ID_of
            ORDER BY
                i.AC_subset_PN_of_PositedAt ASC,
                i.AC_subset_PN_of_Confidence ASC
        ),
        'X',
        ISNULL(i.AC_subset_PN_of_Who, 0),
        ISNULL(i.AC_subset_PN_of_PositedAt, @now),
        ISNULL(i.AC_subset_PN_of_Confidence, 0.75),
        CAST(
            case
                when i.AC_subset_PN_of_Confidence > 0.25 then '+'
                when i.AC_subset_PN_of_Confidence = 0.25 then '?'
                when i.AC_subset_PN_of_Confidence < 0.25 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.AC_ID_subset,
        i.PN_ID_of
    FROM
        inserted i
    WHERE
        i.AC_ID_subset is not null
    AND
        i.PN_ID_of is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [ties].[AC_subset_PN_of_Fact] p
            JOIN
                [ties].[AC_subset_PN_of_Meta] a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            WHERE
                p.AC_ID_subset = i.AC_ID_subset
            AND
                p.PN_ID_of = i.PN_ID_of
            AND
                a.AC_subset_PN_of_Who = ISNULL(i.AC_subset_PN_of_Who, 0)
            AND
                a.AC_subset_PN_of_PositedAt = ISNULL(i.AC_subset_PN_of_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(AC_subset_PN_of_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.AC_subset_PN_of_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.AC_subset_PN_of_ID
                        FROM
                            [ties].[tAC_subset_PN_of](v.AC_subset_PN_of_Who, DEFAULT, v.AC_subset_PN_of_PositedAt, v.AC_subset_PN_of_Stance) t
                        WHERE
                            t.AC_subset_PN_of_Confidence = v.AC_subset_PN_of_Confidence
                        AND
                            t.AC_ID_subset = v.AC_ID_subset
                        AND
                            t.PN_ID_of = v.PN_ID_of
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_subset_PN_of_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [ties].[AC_subset_PN_of_Fact] p
        ON
            p.AC_ID_subset = v.AC_ID_subset
        AND
            p.PN_ID_of = v.PN_ID_of
        WHERE
            v.AC_subset_PN_of_Version = @currentVersion;
        INSERT INTO [ties].[AC_subset_PN_of_Fact] (
            AC_ID_subset,
            PN_ID_of
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            AC_ID_subset,
            PN_ID_of
        FROM
            @inserted
        WHERE
            AC_subset_PN_of_Version = @currentVersion
        AND
            AC_subset_PN_of_StatementType in ('N');
        INSERT INTO [ties].[AC_subset_PN_of_Meta] (
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Who,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Confidence
        )
        SELECT
            v.Metadata_AC_subset_PN_of,
            p.AC_subset_PN_of_ID,
            v.AC_subset_PN_of_Who,
            v.AC_subset_PN_of_PositedAt,
            v.AC_subset_PN_of_Confidence
        FROM
            @inserted v
        JOIN
            [ties].[AC_subset_PN_of_Fact] p
        ON
            p.AC_ID_subset = v.AC_ID_subset
        AND
            p.PN_ID_of = v.PN_ID_of
        WHERE
            v.AC_subset_PN_of_Version = @currentVersion
        AND
            v.AC_subset_PN_of_StatementType in ('S','N','D');
    END
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
        AC_subset_PN_of_Who,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Confidence
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of,
        ISNULL(i.AC_subset_PN_of_Who, i.Who),
        i.AC_subset_PN_of_PositedAt,
        i.AC_subset_PN_of_Confidence
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_AC_subset_PN_of_Who bit = CASE WHEN UPDATE(AC_subset_PN_of_Who) THEN 1 ELSE 0 END;
    DECLARE @updated_Who bit = CASE WHEN UPDATE(Who) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_subset_PN_of_PositedAt bit = CASE WHEN UPDATE(AC_subset_PN_of_PositedAt) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_subset_PN_of_Stance))
        RAISERROR('The computed assertion column AC_subset_PN_of_Stance is not updatable.', 16, 1);
    IF(UPDATE(AC_subset_PN_of_ID))
        RAISERROR('The identity column AC_subset_PN_of_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[AC_subset_PN_of_Meta] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Who,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Confidence
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_subset_PN_of_ID,
        ISNULL(CASE WHEN @updated_AC_subset_PN_of_Who = 1 THEN i.AC_subset_PN_of_Who ELSE i.Who END, 0),
        cast(ISNULL(CASE
            WHEN @updated_AC_subset_PN_of_PositedAt = 1 THEN i.AC_subset_PN_of_PositedAt
        END, @now) as datetime2(3)),
        0.25
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
        AC_subset_PN_of_Who,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Confidence
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of,
        ISNULL(CASE WHEN @updated_AC_subset_PN_of_Who = 1 THEN i.AC_subset_PN_of_Who ELSE i.Who END, 0),
        cast(CASE WHEN @updated_AC_subset_PN_of_PositedAt = 1 THEN i.AC_subset_PN_of_PositedAt ELSE @now END as datetime2(3)),
        ISNULL(i.AC_subset_PN_of_Confidence, 0.75)
    FROM
        inserted i
    WHERE
        i.AC_ID_subset is not null
    AND
        i.PN_ID_of is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            @updated_AC_subset_PN_of_PositedAt = 1 OR
            @updated_AC_subset_PN_of_Who = 1 OR
            @updated_Who = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_subset_PN_of_ID = i.AC_subset_PN_of_ID
                AND
                    d.AC_subset_PN_of_Who = i.AC_subset_PN_of_Who
                AND
                    d.AC_ID_subset = i.AC_ID_subset
                AND
                    d.PN_ID_of = i.PN_ID_of
                AND
                    d.AC_subset_PN_of_Confidence = ISNULL(i.AC_subset_PN_of_Confidence, 0.75)
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
    INSERT INTO [ties].[AC_subset_PN_of_Meta] (
        Metadata_AC_subset_PN_of,
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Who,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Confidence
    )
    SELECT
        d.Metadata_AC_subset_PN_of,
        d.AC_subset_PN_of_ID,
        d.AC_subset_PN_of_Who,
        @now,
        0.25
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_EV_in_AC_wasCast bigint not null,
        EV_in_AC_wasCast_Version bigint not null,
        EV_in_AC_wasCast_StatementType char(1) not null,
        EV_in_AC_wasCast_Who smallint not null,
        EV_in_AC_wasCast_PositedAt datetime2(3) not null,
        EV_in_AC_wasCast_Confidence decimal(7,3) not null,
        EV_in_AC_wasCast_Stance char(1) not null,
        EV_ID_in numeric(12,0) not null,
        AC_ID_wasCast smallint not null,
        primary key (
            EV_in_AC_wasCast_Version,
            EV_in_AC_wasCast_Who,
            EV_ID_in,
            AC_ID_wasCast
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.EV_ID_in,
            i.AC_ID_wasCast,
            ISNULL(i.EV_in_AC_wasCast_Who, 0) AS EV_in_AC_wasCast_Who,
            ISNULL(i.EV_in_AC_wasCast_PositedAt, @now) AS EV_in_AC_wasCast_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[EV_in_AC_wasCast_Fact] p
            JOIN
                [ties].[EV_in_AC_wasCast_Meta] a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            WHERE
                p.EV_ID_in = i.EV_ID_in
            AND
                p.AC_ID_wasCast = i.AC_ID_wasCast
            AND
                a.EV_in_AC_wasCast_Who = ISNULL(i.EV_in_AC_wasCast_Who, 0)
            AND
                a.EV_in_AC_wasCast_PositedAt = ISNULL(i.EV_in_AC_wasCast_PositedAt, @now)
            AND
                a.EV_in_AC_wasCast_Confidence <> ISNULL(i.EV_in_AC_wasCast_Confidence, 0.75)
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
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_in_AC_wasCast_Who,
                i.EV_ID_in,
                i.AC_ID_wasCast
            ORDER BY
                i.EV_in_AC_wasCast_PositedAt ASC,
                i.EV_in_AC_wasCast_Confidence ASC
        ),
        'X',
        ISNULL(i.EV_in_AC_wasCast_Who, 0),
        ISNULL(i.EV_in_AC_wasCast_PositedAt, @now),
        ISNULL(i.EV_in_AC_wasCast_Confidence, 0.75),
        CAST(
            case
                when i.EV_in_AC_wasCast_Confidence > 0.25 then '+'
                when i.EV_in_AC_wasCast_Confidence = 0.25 then '?'
                when i.EV_in_AC_wasCast_Confidence < 0.25 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.EV_ID_in,
        i.AC_ID_wasCast
    FROM
        inserted i
    WHERE
        i.EV_ID_in is not null
    AND
        i.AC_ID_wasCast is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [ties].[EV_in_AC_wasCast_Fact] p
            JOIN
                [ties].[EV_in_AC_wasCast_Meta] a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            WHERE
                p.EV_ID_in = i.EV_ID_in
            AND
                p.AC_ID_wasCast = i.AC_ID_wasCast
            AND
                a.EV_in_AC_wasCast_Who = ISNULL(i.EV_in_AC_wasCast_Who, 0)
            AND
                a.EV_in_AC_wasCast_PositedAt = ISNULL(i.EV_in_AC_wasCast_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(EV_in_AC_wasCast_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.EV_in_AC_wasCast_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.EV_in_AC_wasCast_ID
                        FROM
                            [ties].[tEV_in_AC_wasCast](v.EV_in_AC_wasCast_Who, DEFAULT, v.EV_in_AC_wasCast_PositedAt, v.EV_in_AC_wasCast_Stance) t
                        WHERE
                            t.EV_in_AC_wasCast_Confidence = v.EV_in_AC_wasCast_Confidence
                        AND
                            t.EV_ID_in = v.EV_ID_in
                        AND
                            t.AC_ID_wasCast = v.AC_ID_wasCast
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.EV_in_AC_wasCast_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [ties].[EV_in_AC_wasCast_Fact] p
        ON
            p.EV_ID_in = v.EV_ID_in
        AND
            p.AC_ID_wasCast = v.AC_ID_wasCast
        WHERE
            v.EV_in_AC_wasCast_Version = @currentVersion;
        INSERT INTO [ties].[EV_in_AC_wasCast_Fact] (
            EV_ID_in,
            AC_ID_wasCast
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            EV_ID_in,
            AC_ID_wasCast
        FROM
            @inserted
        WHERE
            EV_in_AC_wasCast_Version = @currentVersion
        AND
            EV_in_AC_wasCast_StatementType in ('N');
        INSERT INTO [ties].[EV_in_AC_wasCast_Meta] (
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_Who,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Confidence
        )
        SELECT
            v.Metadata_EV_in_AC_wasCast,
            p.EV_in_AC_wasCast_ID,
            v.EV_in_AC_wasCast_Who,
            v.EV_in_AC_wasCast_PositedAt,
            v.EV_in_AC_wasCast_Confidence
        FROM
            @inserted v
        JOIN
            [ties].[EV_in_AC_wasCast_Fact] p
        ON
            p.EV_ID_in = v.EV_ID_in
        AND
            p.AC_ID_wasCast = v.AC_ID_wasCast
        WHERE
            v.EV_in_AC_wasCast_Version = @currentVersion
        AND
            v.EV_in_AC_wasCast_StatementType in ('S','N','D');
    END
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
        EV_in_AC_wasCast_Who,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Confidence
    )
    SELECT
        i.Metadata_EV_in_AC_wasCast,
        i.EV_ID_in,
        i.AC_ID_wasCast,
        ISNULL(i.EV_in_AC_wasCast_Who, i.Who),
        i.EV_in_AC_wasCast_PositedAt,
        i.EV_in_AC_wasCast_Confidence
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
    INSERT INTO [ties].[EV_in_AC_wasCast_Meta] (
        Metadata_EV_in_AC_wasCast,
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Who,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Confidence
    )
    SELECT
        d.Metadata_EV_in_AC_wasCast,
        d.EV_in_AC_wasCast_ID,
        d.EV_in_AC_wasCast_Who,
        @now,
        0.25
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_AC_part_PR_in_RAT_got bigint not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Version bigint not null,
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_Who smallint not null,
        AC_part_PR_in_RAT_got_PositedAt datetime2(3) not null,
        AC_part_PR_in_RAT_got_Confidence decimal(7,3) not null,
        AC_part_PR_in_RAT_got_Stance char(1) not null,
        AC_ID_part smallint not null,
        PR_ID_in bigint not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_part_PR_in_RAT_got_Version,
            AC_part_PR_in_RAT_got_Who,
            AC_ID_part,
            PR_ID_in
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_part,
            i.PR_ID_in,
            i.RAT_ID_got,
            ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now) AS AC_part_PR_in_RAT_got_ChangedAt,
            ISNULL(i.AC_part_PR_in_RAT_got_Who, 0) AS AC_part_PR_in_RAT_got_Who,
            ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now) AS AC_part_PR_in_RAT_got_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_part_PR_in_RAT_got_Fact] p
            JOIN
                [ties].[AC_part_PR_in_RAT_got_Meta] a
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
                a.AC_part_PR_in_RAT_got_Who = ISNULL(i.AC_part_PR_in_RAT_got_Who, 0)
            AND
                a.AC_part_PR_in_RAT_got_PositedAt = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
            AND
                a.AC_part_PR_in_RAT_got_Confidence <> ISNULL(i.AC_part_PR_in_RAT_got_Confidence, 0.75)
        )
        -- and so, since a decisive positor holds one assertion at a time, is an assertion of other values at that time
        OR (
            ISNULL(i.AC_part_PR_in_RAT_got_Confidence, 0.75) <> 0.25
        AND (
            EXISTS (
                SELECT TOP 1
                    42
                FROM
                    [ties].[AC_part_PR_in_RAT_got_Fact] p
                JOIN
                    [ties].[AC_part_PR_in_RAT_got_Meta] a
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
                    a.AC_part_PR_in_RAT_got_Who = ISNULL(i.AC_part_PR_in_RAT_got_Who, 0)
                AND
                    a.AC_part_PR_in_RAT_got_PositedAt = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
                AND
                    a.AC_part_PR_in_RAT_got_Confidence <> 0.25
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
                    ISNULL(j.AC_part_PR_in_RAT_got_Who, 0) = ISNULL(i.AC_part_PR_in_RAT_got_Who, 0)
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_PositedAt, @now) = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
                AND
                    ISNULL(j.AC_part_PR_in_RAT_got_Confidence, 0.75) <> 0.25
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
        ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_part_PR_in_RAT_got_Who,
                i.AC_ID_part,
                i.PR_ID_in
            ORDER BY
                ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
                i.AC_part_PR_in_RAT_got_PositedAt ASC,
                i.AC_part_PR_in_RAT_got_Confidence ASC
        ),
        'X',
        ISNULL(i.AC_part_PR_in_RAT_got_Who, 0),
        ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now),
        ISNULL(i.AC_part_PR_in_RAT_got_Confidence, 0.75),
        CAST(
            case
                when i.AC_part_PR_in_RAT_got_Confidence > 0.25 then '+'
                when i.AC_part_PR_in_RAT_got_Confidence = 0.25 then '?'
                when i.AC_part_PR_in_RAT_got_Confidence < 0.25 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.AC_ID_part,
        i.PR_ID_in,
        i.RAT_ID_got
    FROM
        inserted i
    WHERE
        i.AC_ID_part is not null
    AND
        i.PR_ID_in is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [ties].[AC_part_PR_in_RAT_got_Fact] p
            JOIN
                [ties].[AC_part_PR_in_RAT_got_Meta] a
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
                a.AC_part_PR_in_RAT_got_Who = ISNULL(i.AC_part_PR_in_RAT_got_Who, 0)
            AND
                a.AC_part_PR_in_RAT_got_PositedAt = ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(AC_part_PR_in_RAT_got_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.AC_part_PR_in_RAT_got_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.AC_part_PR_in_RAT_got_ID
                        FROM
                            [ties].[tAC_part_PR_in_RAT_got](v.AC_part_PR_in_RAT_got_Who, v.AC_part_PR_in_RAT_got_ChangedAt, v.AC_part_PR_in_RAT_got_PositedAt, v.AC_part_PR_in_RAT_got_Stance) t
                        WHERE
                            t.AC_part_PR_in_RAT_got_Confidence = v.AC_part_PR_in_RAT_got_Confidence
                        AND
                            t.AC_part_PR_in_RAT_got_ChangedAt = v.AC_part_PR_in_RAT_got_ChangedAt
                        AND
                            t.AC_ID_part = v.AC_ID_part
                        AND
                            t.PR_ID_in = v.PR_ID_in
                        AND
                            t.RAT_ID_got = v.RAT_ID_got
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_part_PR_in_RAT_got_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.RAT_ID_got
                            FROM
                                [ties].[rAC_part_PR_in_RAT_got] (
                                    v.AC_part_PR_in_RAT_got_Who,
                                    v.AC_part_PR_in_RAT_got_ChangedAt,
                                    v.AC_part_PR_in_RAT_got_PositedAt
                                ) pre
                            WHERE
                                pre.AC_ID_part = v.AC_ID_part
                            AND
                                pre.PR_ID_in = v.PR_ID_in
                            AND
                                pre.AC_part_PR_in_RAT_got_ChangedAt < v.AC_part_PR_in_RAT_got_ChangedAt
                            AND
                                pre.AC_part_PR_in_RAT_got_Stance = v.AC_part_PR_in_RAT_got_Stance
                            ORDER BY
                                pre.AC_part_PR_in_RAT_got_ChangedAt DESC,
                                pre.AC_part_PR_in_RAT_got_PositedAt DESC
                        ) s
                        WHERE
                            s.RAT_ID_got = v.RAT_ID_got
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.RAT_ID_got
                            FROM
                                [ties].[fAC_part_PR_in_RAT_got] (
                                    v.AC_part_PR_in_RAT_got_Who,
                                    v.AC_part_PR_in_RAT_got_ChangedAt,
                                    v.AC_part_PR_in_RAT_got_PositedAt
                                ) fol
                            WHERE
                                fol.AC_ID_part = v.AC_ID_part
                            AND
                                fol.PR_ID_in = v.PR_ID_in
                            AND
                                fol.AC_part_PR_in_RAT_got_ChangedAt > v.AC_part_PR_in_RAT_got_ChangedAt
                            AND
                                fol.AC_part_PR_in_RAT_got_Stance = v.AC_part_PR_in_RAT_got_Stance
                            ORDER BY
                                fol.AC_part_PR_in_RAT_got_ChangedAt ASC,
                                fol.AC_part_PR_in_RAT_got_PositedAt DESC
                        ) s
                        WHERE
                            s.RAT_ID_got = v.RAT_ID_got
                    )
                    THEN 'R' -- restatement of the following version
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [ties].[AC_part_PR_in_RAT_got_Fact] p
        ON
            p.AC_ID_part = v.AC_ID_part
        AND
            p.PR_ID_in = v.PR_ID_in
        AND
            p.RAT_ID_got = v.RAT_ID_got
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v.AC_part_PR_in_RAT_got_ChangedAt
        WHERE
            v.AC_part_PR_in_RAT_got_Version = @currentVersion;
        INSERT INTO [ties].[AC_part_PR_in_RAT_got_Fact] (
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got
        FROM
            @inserted
        WHERE
            AC_part_PR_in_RAT_got_Version = @currentVersion
        AND
            AC_part_PR_in_RAT_got_StatementType in ('N','R');
        INSERT INTO [ties].[AC_part_PR_in_RAT_got_Meta] (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_Who,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Confidence
        )
        SELECT
            v.Metadata_AC_part_PR_in_RAT_got,
            p.AC_part_PR_in_RAT_got_ID,
            v.AC_part_PR_in_RAT_got_Who,
            v.AC_part_PR_in_RAT_got_PositedAt,
            v.AC_part_PR_in_RAT_got_Confidence
        FROM
            @inserted v
        JOIN
            [ties].[AC_part_PR_in_RAT_got_Fact] p
        ON
            p.AC_ID_part = v.AC_ID_part
        AND
            p.PR_ID_in = v.PR_ID_in
        AND
            p.RAT_ID_got = v.RAT_ID_got
        AND
            p.AC_part_PR_in_RAT_got_ChangedAt = v.AC_part_PR_in_RAT_got_ChangedAt
        WHERE
            v.AC_part_PR_in_RAT_got_Version = @currentVersion
        AND
            v.AC_part_PR_in_RAT_got_StatementType in ('S','N','D','R');
        -- decisive: a positor holds one assertion at a time for the identifiers, so an assertion that is not a retraction,
        -- positive or negative, retracts at its positing time the posit in effect for the positor at the same changing time
        -- when that has other values (a correction); also when the assertion is not stored, as the restatement an idempotent
        -- tie skips
        INSERT INTO [ties].[AC_part_PR_in_RAT_got_Meta] (
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_Who,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Confidence
        )
        SELECT
            v.Metadata_AC_part_PR_in_RAT_got,
            e.AC_part_PR_in_RAT_got_ID,
            v.AC_part_PR_in_RAT_got_Who,
            v.AC_part_PR_in_RAT_got_PositedAt,
            0.25
        FROM
            @inserted v
        CROSS APPLY (
            SELECT TOP 1
                p.AC_part_PR_in_RAT_got_ID,
                p.RAT_ID_got
            FROM
                [ties].[AC_part_PR_in_RAT_got_Fact] p
            JOIN
                [ties].[AC_part_PR_in_RAT_got_Meta] a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            AND
                a.AC_part_PR_in_RAT_got_Who = v.AC_part_PR_in_RAT_got_Who
            AND
                a.AC_part_PR_in_RAT_got_PositedAt = (
                    SELECT
                        max(s.AC_part_PR_in_RAT_got_PositedAt)
                    FROM
                        [ties].[AC_part_PR_in_RAT_got_Meta] s
                    WHERE
                        s.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
                    AND
                        s.AC_part_PR_in_RAT_got_Who = v.AC_part_PR_in_RAT_got_Who
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
                a.AC_part_PR_in_RAT_got_Confidence <> 0.25
            ORDER BY
                a.AC_part_PR_in_RAT_got_PositedAt DESC,
                a.AC_part_PR_in_RAT_got_Confidence DESC
        ) e
        WHERE
            v.AC_part_PR_in_RAT_got_Version = @currentVersion
        AND
            v.AC_part_PR_in_RAT_got_StatementType in ('S','N','D','R')
        AND
            v.AC_part_PR_in_RAT_got_Confidence <> 0.25
        AND (
            e.RAT_ID_got <> v.RAT_ID_got
        )
        AND NOT EXISTS ( -- not if it has an assertion at the positing time already
            SELECT TOP 1
                42
            FROM
                [ties].[AC_part_PR_in_RAT_got_Meta] x
            WHERE
                x.AC_part_PR_in_RAT_got_ID = e.AC_part_PR_in_RAT_got_ID
            AND
                x.AC_part_PR_in_RAT_got_Who = v.AC_part_PR_in_RAT_got_Who
            AND
                x.AC_part_PR_in_RAT_got_PositedAt = v.AC_part_PR_in_RAT_got_PositedAt
        );
    END
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
        AC_part_PR_in_RAT_got_Who,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Confidence
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_ID_part,
        i.PR_ID_in,
        ISNULL(i.RAT_ID_got, [RAT_got].RAT_ID),
        ISNULL(i.AC_part_PR_in_RAT_got_Who, i.Who),
        i.AC_part_PR_in_RAT_got_PositedAt,
        i.AC_part_PR_in_RAT_got_Confidence
    FROM
        inserted i
    LEFT JOIN
        [knots].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating;
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_AC_part_PR_in_RAT_got_Who bit = CASE WHEN UPDATE(AC_part_PR_in_RAT_got_Who) THEN 1 ELSE 0 END;
    DECLARE @updated_Who bit = CASE WHEN UPDATE(Who) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_part_PR_in_RAT_got_PositedAt bit = CASE WHEN UPDATE(AC_part_PR_in_RAT_got_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_AC_part_PR_in_RAT_got_ChangedAt bit = CASE WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_got_RAT_Rating bit = CASE WHEN UPDATE(got_RAT_Rating) THEN 1 ELSE 0 END;
    IF(UPDATE(AC_part_PR_in_RAT_got_Stance))
        RAISERROR('The computed assertion column AC_part_PR_in_RAT_got_Stance is not updatable.', 16, 1);
    IF(UPDATE(AC_part_PR_in_RAT_got_ID))
        RAISERROR('The identity column AC_part_PR_in_RAT_got_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_ID_part))
        RAISERROR('The identity column AC_ID_part is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_in))
        RAISERROR('The identity column PR_ID_in is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[AC_part_PR_in_RAT_got_Meta] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Who,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Confidence
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ID,
        ISNULL(CASE WHEN @updated_AC_part_PR_in_RAT_got_Who = 1 THEN i.AC_part_PR_in_RAT_got_Who ELSE i.Who END, 0),
        cast(ISNULL(CASE
            WHEN @updated_AC_part_PR_in_RAT_got_PositedAt = 1 THEN i.AC_part_PR_in_RAT_got_PositedAt
            WHEN @updated_AC_part_PR_in_RAT_got_ChangedAt = 1 THEN i.AC_part_PR_in_RAT_got_ChangedAt
        END, @now) as datetime2(3)),
        0.25
    FROM
        inserted i
    LEFT JOIN
        [knots].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating
    WHERE
        i.AC_part_PR_in_RAT_got_ID is not null
    AND (
        CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is null
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [ties].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_Who,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Confidence
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        cast(CASE
            WHEN @updated_AC_part_PR_in_RAT_got_ChangedAt = 1 THEN i.AC_part_PR_in_RAT_got_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID
                AND
                    d.AC_part_PR_in_RAT_got_Who = i.AC_part_PR_in_RAT_got_Who
                AND
                    d.RAT_ID_got = CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END
            ) THEN i.AC_part_PR_in_RAT_got_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.AC_ID_part,
        i.PR_ID_in,
        CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END,
        ISNULL(CASE WHEN @updated_AC_part_PR_in_RAT_got_Who = 1 THEN i.AC_part_PR_in_RAT_got_Who ELSE i.Who END, 0),
        cast(CASE WHEN @updated_AC_part_PR_in_RAT_got_PositedAt = 1 THEN i.AC_part_PR_in_RAT_got_PositedAt ELSE @now END as datetime2(3)),
        ISNULL(i.AC_part_PR_in_RAT_got_Confidence, 0.75)
    FROM
        inserted i
    LEFT JOIN
        [knots].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating
    WHERE
        CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            @updated_AC_part_PR_in_RAT_got_ChangedAt = 1 OR
            @updated_AC_part_PR_in_RAT_got_PositedAt = 1 OR
            @updated_AC_part_PR_in_RAT_got_Who = 1 OR
            @updated_Who = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID
                AND
                    d.AC_part_PR_in_RAT_got_Who = i.AC_part_PR_in_RAT_got_Who
                AND
                    d.RAT_ID_got = CASE WHEN @updated_got_RAT_Rating = 1 THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END
                AND
                    d.AC_part_PR_in_RAT_got_Confidence = ISNULL(i.AC_part_PR_in_RAT_got_Confidence, 0.75)
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
    INSERT INTO [ties].[AC_part_PR_in_RAT_got_Meta] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Who,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Confidence
    )
    SELECT
        d.Metadata_AC_part_PR_in_RAT_got,
        d.AC_part_PR_in_RAT_got_ID,
        d.AC_part_PR_in_RAT_got_Who,
        @now,
        0.25
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_ST_at_PR_isPlaying bigint not null,
        ST_at_PR_isPlaying_ChangedAt datetime2 not null,
        ST_at_PR_isPlaying_Version bigint not null,
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_Who smallint not null,
        ST_at_PR_isPlaying_PositedAt datetime2(3) not null,
        ST_at_PR_isPlaying_Confidence decimal(7,3) not null,
        ST_at_PR_isPlaying_Stance char(1) not null,
        ST_ID_at int not null,
        PR_ID_isPlaying bigint not null,
        primary key (
            ST_at_PR_isPlaying_Version,
            ST_at_PR_isPlaying_Who,
            ST_ID_at,
            PR_ID_isPlaying
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.ST_ID_at,
            i.PR_ID_isPlaying,
            ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now) AS ST_at_PR_isPlaying_ChangedAt,
            ISNULL(i.ST_at_PR_isPlaying_Who, 0) AS ST_at_PR_isPlaying_Who,
            ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now) AS ST_at_PR_isPlaying_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[ST_at_PR_isPlaying_Fact] p
            JOIN
                [ties].[ST_at_PR_isPlaying_Meta] a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            WHERE
                p.ST_ID_at = i.ST_ID_at
            AND
                p.PR_ID_isPlaying = i.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now)
            AND
                a.ST_at_PR_isPlaying_Who = ISNULL(i.ST_at_PR_isPlaying_Who, 0)
            AND
                a.ST_at_PR_isPlaying_PositedAt = ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now)
            AND
                a.ST_at_PR_isPlaying_Confidence <> ISNULL(i.ST_at_PR_isPlaying_Confidence, 0.75)
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
        ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_at_PR_isPlaying_Who,
                i.ST_ID_at,
                i.PR_ID_isPlaying
            ORDER BY
                ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
                i.ST_at_PR_isPlaying_PositedAt ASC,
                i.ST_at_PR_isPlaying_Confidence ASC
        ),
        'X',
        ISNULL(i.ST_at_PR_isPlaying_Who, 0),
        ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now),
        ISNULL(i.ST_at_PR_isPlaying_Confidence, 0.75),
        CAST(
            case
                when i.ST_at_PR_isPlaying_Confidence > 0.25 then '+'
                when i.ST_at_PR_isPlaying_Confidence = 0.25 then '?'
                when i.ST_at_PR_isPlaying_Confidence < 0.25 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.ST_ID_at,
        i.PR_ID_isPlaying
    FROM
        inserted i
    WHERE
        i.ST_ID_at is not null
    AND
        i.PR_ID_isPlaying is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [ties].[ST_at_PR_isPlaying_Fact] p
            JOIN
                [ties].[ST_at_PR_isPlaying_Meta] a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            WHERE
                p.ST_ID_at = i.ST_ID_at
            AND
                p.PR_ID_isPlaying = i.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now)
            AND
                a.ST_at_PR_isPlaying_Who = ISNULL(i.ST_at_PR_isPlaying_Who, 0)
            AND
                a.ST_at_PR_isPlaying_PositedAt = ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(ST_at_PR_isPlaying_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.ST_at_PR_isPlaying_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.ST_at_PR_isPlaying_ID
                        FROM
                            [ties].[tST_at_PR_isPlaying](v.ST_at_PR_isPlaying_Who, v.ST_at_PR_isPlaying_ChangedAt, v.ST_at_PR_isPlaying_PositedAt, v.ST_at_PR_isPlaying_Stance) t
                        WHERE
                            t.ST_at_PR_isPlaying_Confidence = v.ST_at_PR_isPlaying_Confidence
                        AND
                            t.ST_at_PR_isPlaying_ChangedAt = v.ST_at_PR_isPlaying_ChangedAt
                        AND
                            t.ST_ID_at = v.ST_ID_at
                        AND
                            t.PR_ID_isPlaying = v.PR_ID_isPlaying
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.ST_at_PR_isPlaying_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [ties].[ST_at_PR_isPlaying_Fact] p
        ON
            p.ST_ID_at = v.ST_ID_at
        AND
            p.PR_ID_isPlaying = v.PR_ID_isPlaying
        AND
            p.ST_at_PR_isPlaying_ChangedAt = v.ST_at_PR_isPlaying_ChangedAt
        WHERE
            v.ST_at_PR_isPlaying_Version = @currentVersion;
        INSERT INTO [ties].[ST_at_PR_isPlaying_Fact] (
            ST_at_PR_isPlaying_ChangedAt,
            ST_ID_at,
            PR_ID_isPlaying
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            ST_at_PR_isPlaying_ChangedAt,
            ST_ID_at,
            PR_ID_isPlaying
        FROM
            @inserted
        WHERE
            ST_at_PR_isPlaying_Version = @currentVersion
        AND
            ST_at_PR_isPlaying_StatementType in ('N','R');
        INSERT INTO [ties].[ST_at_PR_isPlaying_Meta] (
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_Who,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Confidence
        )
        SELECT
            v.Metadata_ST_at_PR_isPlaying,
            p.ST_at_PR_isPlaying_ID,
            v.ST_at_PR_isPlaying_Who,
            v.ST_at_PR_isPlaying_PositedAt,
            v.ST_at_PR_isPlaying_Confidence
        FROM
            @inserted v
        JOIN
            [ties].[ST_at_PR_isPlaying_Fact] p
        ON
            p.ST_ID_at = v.ST_ID_at
        AND
            p.PR_ID_isPlaying = v.PR_ID_isPlaying
        AND
            p.ST_at_PR_isPlaying_ChangedAt = v.ST_at_PR_isPlaying_ChangedAt
        WHERE
            v.ST_at_PR_isPlaying_Version = @currentVersion
        AND
            v.ST_at_PR_isPlaying_StatementType in ('S','N','D','R');
    END
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
        ST_at_PR_isPlaying_Who,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Confidence
    )
    SELECT
        i.Metadata_ST_at_PR_isPlaying,
        i.ST_at_PR_isPlaying_ChangedAt,
        i.ST_ID_at,
        i.PR_ID_isPlaying,
        ISNULL(i.ST_at_PR_isPlaying_Who, i.Who),
        i.ST_at_PR_isPlaying_PositedAt,
        i.ST_at_PR_isPlaying_Confidence
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
    INSERT INTO [ties].[ST_at_PR_isPlaying_Meta] (
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Who,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Confidence
    )
    SELECT
        d.Metadata_ST_at_PR_isPlaying,
        d.ST_at_PR_isPlaying_ID,
        d.ST_at_PR_isPlaying_Who,
        @now,
        0.25
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_AC_parent_AC_child_PAT_having bigint not null,
        AC_parent_AC_child_PAT_having_Version bigint not null,
        AC_parent_AC_child_PAT_having_StatementType char(1) not null,
        AC_parent_AC_child_PAT_having_Who smallint not null,
        AC_parent_AC_child_PAT_having_PositedAt datetime2(3) not null,
        AC_parent_AC_child_PAT_having_Confidence decimal(7,3) not null,
        AC_parent_AC_child_PAT_having_Stance char(1) not null,
        AC_ID_parent smallint not null,
        AC_ID_child smallint not null,
        PAT_ID_having tinyint not null,
        primary key (
            AC_parent_AC_child_PAT_having_Version,
            AC_parent_AC_child_PAT_having_Who,
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.AC_ID_parent,
            i.AC_ID_child,
            i.PAT_ID_having,
            ISNULL(i.AC_parent_AC_child_PAT_having_Who, 0) AS AC_parent_AC_child_PAT_having_Who,
            ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now) AS AC_parent_AC_child_PAT_having_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[AC_parent_AC_child_PAT_having_Fact] p
            JOIN
                [ties].[AC_parent_AC_child_PAT_having_Meta] a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            WHERE
                p.AC_ID_parent = i.AC_ID_parent
            AND
                p.AC_ID_child = i.AC_ID_child
            AND
                p.PAT_ID_having = i.PAT_ID_having
            AND
                a.AC_parent_AC_child_PAT_having_Who = ISNULL(i.AC_parent_AC_child_PAT_having_Who, 0)
            AND
                a.AC_parent_AC_child_PAT_having_PositedAt = ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now)
            AND
                a.AC_parent_AC_child_PAT_having_Confidence <> ISNULL(i.AC_parent_AC_child_PAT_having_Confidence, 0.75)
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
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_parent_AC_child_PAT_having_Who,
                i.AC_ID_parent,
                i.AC_ID_child,
                i.PAT_ID_having
            ORDER BY
                i.AC_parent_AC_child_PAT_having_PositedAt ASC,
                i.AC_parent_AC_child_PAT_having_Confidence ASC
        ),
        'X',
        ISNULL(i.AC_parent_AC_child_PAT_having_Who, 0),
        ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now),
        ISNULL(i.AC_parent_AC_child_PAT_having_Confidence, 0.75),
        CAST(
            case
                when i.AC_parent_AC_child_PAT_having_Confidence > 0.25 then '+'
                when i.AC_parent_AC_child_PAT_having_Confidence = 0.25 then '?'
                when i.AC_parent_AC_child_PAT_having_Confidence < 0.25 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.AC_ID_parent,
        i.AC_ID_child,
        i.PAT_ID_having
    FROM
        inserted i
    WHERE
        i.AC_ID_parent is not null
    AND
        i.AC_ID_child is not null
    AND
        i.PAT_ID_having is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [ties].[AC_parent_AC_child_PAT_having_Fact] p
            JOIN
                [ties].[AC_parent_AC_child_PAT_having_Meta] a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            WHERE
                p.AC_ID_parent = i.AC_ID_parent
            AND
                p.AC_ID_child = i.AC_ID_child
            AND
                p.PAT_ID_having = i.PAT_ID_having
            AND
                a.AC_parent_AC_child_PAT_having_Who = ISNULL(i.AC_parent_AC_child_PAT_having_Who, 0)
            AND
                a.AC_parent_AC_child_PAT_having_PositedAt = ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(AC_parent_AC_child_PAT_having_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.AC_parent_AC_child_PAT_having_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.AC_parent_AC_child_PAT_having_ID
                        FROM
                            [ties].[tAC_parent_AC_child_PAT_having](v.AC_parent_AC_child_PAT_having_Who, DEFAULT, v.AC_parent_AC_child_PAT_having_PositedAt, v.AC_parent_AC_child_PAT_having_Stance) t
                        WHERE
                            t.AC_parent_AC_child_PAT_having_Confidence = v.AC_parent_AC_child_PAT_having_Confidence
                        AND
                            t.AC_ID_parent = v.AC_ID_parent
                        AND
                            t.AC_ID_child = v.AC_ID_child
                        AND
                            t.PAT_ID_having = v.PAT_ID_having
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.AC_parent_AC_child_PAT_having_ID is not null
                    THEN 'S' -- duplicate statement
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [ties].[AC_parent_AC_child_PAT_having_Fact] p
        ON
            p.AC_ID_parent = v.AC_ID_parent
        AND
            p.AC_ID_child = v.AC_ID_child
        AND
            p.PAT_ID_having = v.PAT_ID_having
        WHERE
            v.AC_parent_AC_child_PAT_having_Version = @currentVersion;
        INSERT INTO [ties].[AC_parent_AC_child_PAT_having_Fact] (
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        FROM
            @inserted
        WHERE
            AC_parent_AC_child_PAT_having_Version = @currentVersion
        AND
            AC_parent_AC_child_PAT_having_StatementType in ('N');
        INSERT INTO [ties].[AC_parent_AC_child_PAT_having_Meta] (
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_Who,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Confidence
        )
        SELECT
            v.Metadata_AC_parent_AC_child_PAT_having,
            p.AC_parent_AC_child_PAT_having_ID,
            v.AC_parent_AC_child_PAT_having_Who,
            v.AC_parent_AC_child_PAT_having_PositedAt,
            v.AC_parent_AC_child_PAT_having_Confidence
        FROM
            @inserted v
        JOIN
            [ties].[AC_parent_AC_child_PAT_having_Fact] p
        ON
            p.AC_ID_parent = v.AC_ID_parent
        AND
            p.AC_ID_child = v.AC_ID_child
        AND
            p.PAT_ID_having = v.PAT_ID_having
        WHERE
            v.AC_parent_AC_child_PAT_having_Version = @currentVersion
        AND
            v.AC_parent_AC_child_PAT_having_StatementType in ('S','N','D');
    END
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
        AC_parent_AC_child_PAT_having_Who,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Confidence
    )
    SELECT
        i.Metadata_AC_parent_AC_child_PAT_having,
        i.AC_ID_parent,
        i.AC_ID_child,
        ISNULL(i.PAT_ID_having, [PAT_having].PAT_ID),
        ISNULL(i.AC_parent_AC_child_PAT_having_Who, i.Who),
        i.AC_parent_AC_child_PAT_having_PositedAt,
        i.AC_parent_AC_child_PAT_having_Confidence
    FROM
        inserted i
    LEFT JOIN
        [knots].[PAT_ParentalType] [PAT_having]
    ON
        [PAT_having].PAT_ParentalType = i.having_PAT_ParentalType;
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
    INSERT INTO [ties].[AC_parent_AC_child_PAT_having_Meta] (
        Metadata_AC_parent_AC_child_PAT_having,
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Who,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Confidence
    )
    SELECT
        d.Metadata_AC_parent_AC_child_PAT_having,
        d.AC_parent_AC_child_PAT_having_ID,
        d.AC_parent_AC_child_PAT_having_Who,
        @now,
        0.25
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
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        Metadata_PR_content_ST_location_EV_of bigint not null,
        PR_content_ST_location_EV_of_ChangedAt datetime2 not null,
        PR_content_ST_location_EV_of_Version bigint not null,
        PR_content_ST_location_EV_of_StatementType char(1) not null,
        PR_content_ST_location_EV_of_Who smallint not null,
        PR_content_ST_location_EV_of_PositedAt datetime2(3) not null,
        PR_content_ST_location_EV_of_Confidence decimal(7,3) not null,
        PR_content_ST_location_EV_of_Stance char(1) not null,
        PR_ID_content bigint not null,
        ST_ID_location int not null,
        EV_ID_of numeric(12,0) not null,
        primary key (
            PR_content_ST_location_EV_of_Version,
            PR_content_ST_location_EV_of_Who,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of
        )
    );
    -- another reliability at a positing time that already has an assertion of the posit by the positor is a contradiction
    DECLARE @message varchar(max);
    SET @message = (
        SELECT TOP 1
            i.PR_ID_content,
            i.ST_ID_location,
            i.EV_ID_of,
            ISNULL(i.PR_content_ST_location_EV_of_ChangedAt, @now) AS PR_content_ST_location_EV_of_ChangedAt,
            ISNULL(i.PR_content_ST_location_EV_of_Who, 0) AS PR_content_ST_location_EV_of_Who,
            ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now) AS PR_content_ST_location_EV_of_PositedAt
        FROM
            inserted i
        WHERE EXISTS (
            SELECT TOP 1
                42
            FROM
                [ties].[PR_content_ST_location_EV_of_Fact] p
            JOIN
                [ties].[PR_content_ST_location_EV_of_Meta] a
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
                a.PR_content_ST_location_EV_of_Who = ISNULL(i.PR_content_ST_location_EV_of_Who, 0)
            AND
                a.PR_content_ST_location_EV_of_PositedAt = ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now)
            AND
                a.PR_content_ST_location_EV_of_Confidence <> ISNULL(i.PR_content_ST_location_EV_of_Confidence, 0.75)
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
        ISNULL(i.PR_content_ST_location_EV_of_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.PR_content_ST_location_EV_of_Who,
                i.PR_ID_content,
                i.ST_ID_location,
                i.EV_ID_of
            ORDER BY
                ISNULL(i.PR_content_ST_location_EV_of_ChangedAt, @now),
                i.PR_content_ST_location_EV_of_PositedAt ASC,
                i.PR_content_ST_location_EV_of_Confidence ASC
        ),
        'X',
        ISNULL(i.PR_content_ST_location_EV_of_Who, 0),
        ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now),
        ISNULL(i.PR_content_ST_location_EV_of_Confidence, 0.75),
        CAST(
            case
                when i.PR_content_ST_location_EV_of_Confidence > 0.25 then '+'
                when i.PR_content_ST_location_EV_of_Confidence = 0.25 then '?'
                when i.PR_content_ST_location_EV_of_Confidence < 0.25 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of
    FROM
        inserted i
    WHERE
        i.PR_ID_content is not null
    AND
        i.ST_ID_location is not null
    AND
        i.EV_ID_of is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [ties].[PR_content_ST_location_EV_of_Fact] p
            JOIN
                [ties].[PR_content_ST_location_EV_of_Meta] a
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
                a.PR_content_ST_location_EV_of_Who = ISNULL(i.PR_content_ST_location_EV_of_Who, 0)
            AND
                a.PR_content_ST_location_EV_of_PositedAt = ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now)
        );
    SELECT
        @maxVersion = max(PR_content_ST_location_EV_of_Version),
        @currentVersion = 0
    FROM
        @inserted;
    WHILE (@currentVersion < @maxVersion)
    BEGIN
        SET @currentVersion = @currentVersion + 1;
        UPDATE v
        SET
            v.PR_content_ST_location_EV_of_StatementType =
                CASE
                    WHEN EXISTS (
                        SELECT TOP 1
                            t.PR_content_ST_location_EV_of_ID
                        FROM
                            [ties].[tPR_content_ST_location_EV_of](v.PR_content_ST_location_EV_of_Who, v.PR_content_ST_location_EV_of_ChangedAt, v.PR_content_ST_location_EV_of_PositedAt, v.PR_content_ST_location_EV_of_Stance) t
                        WHERE
                            t.PR_content_ST_location_EV_of_Confidence = v.PR_content_ST_location_EV_of_Confidence
                        AND
                            t.PR_content_ST_location_EV_of_ChangedAt = v.PR_content_ST_location_EV_of_ChangedAt
                        AND
                            t.PR_ID_content = v.PR_ID_content
                        AND
                            t.ST_ID_location = v.ST_ID_location
                        AND
                            t.EV_ID_of = v.EV_ID_of
                    )
                    THEN 'D' -- duplicate assertion
                    WHEN p.PR_content_ST_location_EV_of_ID is not null
                    THEN 'S' -- duplicate statement
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                pre.PR_ID_content,
                                pre.ST_ID_location,
                                pre.EV_ID_of
                            FROM
                                [ties].[rPR_content_ST_location_EV_of] (
                                    v.PR_content_ST_location_EV_of_Who,
                                    v.PR_content_ST_location_EV_of_ChangedAt,
                                    v.PR_content_ST_location_EV_of_PositedAt
                                ) pre
                            WHERE
                            (
                                    pre.PR_ID_content = v.PR_ID_content
                                AND
                                    pre.ST_ID_location = v.ST_ID_location
                                AND
                                    pre.EV_ID_of = v.EV_ID_of
                            )
                            AND
                                pre.PR_content_ST_location_EV_of_ChangedAt < v.PR_content_ST_location_EV_of_ChangedAt
                            AND
                                pre.PR_content_ST_location_EV_of_Stance = v.PR_content_ST_location_EV_of_Stance
                            ORDER BY
                                pre.PR_content_ST_location_EV_of_ChangedAt DESC,
                                pre.PR_content_ST_location_EV_of_PositedAt DESC
                        ) s
                        WHERE
                            s.PR_ID_content = v.PR_ID_content
                        AND
                            s.ST_ID_location = v.ST_ID_location
                        AND
                            s.EV_ID_of = v.EV_ID_of
                    )
                    THEN 'R' -- restatement of the previous version
                    WHEN EXISTS (
                        SELECT
                            42
                        FROM (
                            SELECT TOP 1
                                fol.PR_ID_content,
                                fol.ST_ID_location,
                                fol.EV_ID_of
                            FROM
                                [ties].[fPR_content_ST_location_EV_of] (
                                    v.PR_content_ST_location_EV_of_Who,
                                    v.PR_content_ST_location_EV_of_ChangedAt,
                                    v.PR_content_ST_location_EV_of_PositedAt
                                ) fol
                            WHERE
                            (
                                    fol.PR_ID_content = v.PR_ID_content
                                AND
                                    fol.ST_ID_location = v.ST_ID_location
                                AND
                                    fol.EV_ID_of = v.EV_ID_of
                            )
                            AND
                                fol.PR_content_ST_location_EV_of_ChangedAt > v.PR_content_ST_location_EV_of_ChangedAt
                            AND
                                fol.PR_content_ST_location_EV_of_Stance = v.PR_content_ST_location_EV_of_Stance
                            ORDER BY
                                fol.PR_content_ST_location_EV_of_ChangedAt ASC,
                                fol.PR_content_ST_location_EV_of_PositedAt DESC
                        ) s
                        WHERE
                            s.PR_ID_content = v.PR_ID_content
                        AND
                            s.ST_ID_location = v.ST_ID_location
                        AND
                            s.EV_ID_of = v.EV_ID_of
                    )
                    THEN 'R' -- restatement of the following version
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [ties].[PR_content_ST_location_EV_of_Fact] p
        ON
            p.PR_ID_content = v.PR_ID_content
        AND
            p.ST_ID_location = v.ST_ID_location
        AND
            p.EV_ID_of = v.EV_ID_of
        AND
            p.PR_content_ST_location_EV_of_ChangedAt = v.PR_content_ST_location_EV_of_ChangedAt
        WHERE
            v.PR_content_ST_location_EV_of_Version = @currentVersion;
        INSERT INTO [ties].[PR_content_ST_location_EV_of_Fact] (
            PR_content_ST_location_EV_of_ChangedAt,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of
        )
        SELECT DISTINCT -- a posit that several positors state is made once
            PR_content_ST_location_EV_of_ChangedAt,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of
        FROM
            @inserted
        WHERE
            PR_content_ST_location_EV_of_Version = @currentVersion
        AND
            PR_content_ST_location_EV_of_StatementType in ('N','R');
        INSERT INTO [ties].[PR_content_ST_location_EV_of_Meta] (
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_Who,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Confidence
        )
        SELECT
            v.Metadata_PR_content_ST_location_EV_of,
            p.PR_content_ST_location_EV_of_ID,
            v.PR_content_ST_location_EV_of_Who,
            v.PR_content_ST_location_EV_of_PositedAt,
            v.PR_content_ST_location_EV_of_Confidence
        FROM
            @inserted v
        JOIN
            [ties].[PR_content_ST_location_EV_of_Fact] p
        ON
            p.PR_ID_content = v.PR_ID_content
        AND
            p.ST_ID_location = v.ST_ID_location
        AND
            p.EV_ID_of = v.EV_ID_of
        AND
            p.PR_content_ST_location_EV_of_ChangedAt = v.PR_content_ST_location_EV_of_ChangedAt
        WHERE
            v.PR_content_ST_location_EV_of_Version = @currentVersion
        AND
            v.PR_content_ST_location_EV_of_StatementType in ('S','N','D','R');
    END
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
        PR_content_ST_location_EV_of_Who,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Confidence
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_content_ST_location_EV_of_ChangedAt,
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of,
        ISNULL(i.PR_content_ST_location_EV_of_Who, i.Who),
        i.PR_content_ST_location_EV_of_PositedAt,
        i.PR_content_ST_location_EV_of_Confidence
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
    -- whether a column is set is asked once, here: with UPDATE() in the statements below, which read inserted and
    -- deleted, SQL Server 2014 used gigabytes of memory to create a trigger like this one, and could run out
    DECLARE @updated_PR_content_ST_location_EV_of_Who bit = CASE WHEN UPDATE(PR_content_ST_location_EV_of_Who) THEN 1 ELSE 0 END;
    DECLARE @updated_Who bit = CASE WHEN UPDATE(Who) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_content_ST_location_EV_of_PositedAt bit = CASE WHEN UPDATE(PR_content_ST_location_EV_of_PositedAt) THEN 1 ELSE 0 END;
    DECLARE @updated_PR_content_ST_location_EV_of_ChangedAt bit = CASE WHEN UPDATE(PR_content_ST_location_EV_of_ChangedAt) THEN 1 ELSE 0 END;
    IF(UPDATE(PR_content_ST_location_EV_of_Stance))
        RAISERROR('The computed assertion column PR_content_ST_location_EV_of_Stance is not updatable.', 16, 1);
    IF(UPDATE(PR_content_ST_location_EV_of_ID))
        RAISERROR('The identity column PR_content_ST_location_EV_of_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [ties].[PR_content_ST_location_EV_of_Meta] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Who,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Confidence
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_content_ST_location_EV_of_ID,
        ISNULL(CASE WHEN @updated_PR_content_ST_location_EV_of_Who = 1 THEN i.PR_content_ST_location_EV_of_Who ELSE i.Who END, 0),
        cast(ISNULL(CASE
            WHEN @updated_PR_content_ST_location_EV_of_PositedAt = 1 THEN i.PR_content_ST_location_EV_of_PositedAt
            WHEN @updated_PR_content_ST_location_EV_of_ChangedAt = 1 THEN i.PR_content_ST_location_EV_of_ChangedAt
        END, @now) as datetime2(3)),
        0.25
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
        PR_content_ST_location_EV_of_Who,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Confidence
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        cast(CASE
            WHEN @updated_PR_content_ST_location_EV_of_ChangedAt = 1 THEN i.PR_content_ST_location_EV_of_ChangedAt
            WHEN EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.PR_content_ST_location_EV_of_ID = i.PR_content_ST_location_EV_of_ID
                AND
                    d.PR_content_ST_location_EV_of_Who = i.PR_content_ST_location_EV_of_Who
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
        ISNULL(CASE WHEN @updated_PR_content_ST_location_EV_of_Who = 1 THEN i.PR_content_ST_location_EV_of_Who ELSE i.Who END, 0),
        cast(CASE WHEN @updated_PR_content_ST_location_EV_of_PositedAt = 1 THEN i.PR_content_ST_location_EV_of_PositedAt ELSE @now END as datetime2(3)),
        ISNULL(i.PR_content_ST_location_EV_of_Confidence, 0.75)
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
            @updated_PR_content_ST_location_EV_of_ChangedAt = 1 OR
            @updated_PR_content_ST_location_EV_of_PositedAt = 1 OR
            @updated_PR_content_ST_location_EV_of_Who = 1 OR
            @updated_Who = 1 OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.PR_content_ST_location_EV_of_ID = i.PR_content_ST_location_EV_of_ID
                AND
                    d.PR_content_ST_location_EV_of_Who = i.PR_content_ST_location_EV_of_Who
                AND
                    d.PR_ID_content = i.PR_ID_content
                AND
                    d.ST_ID_location = i.ST_ID_location
                AND
                    d.EV_ID_of = i.EV_ID_of
                AND
                    d.PR_content_ST_location_EV_of_Confidence = ISNULL(i.PR_content_ST_location_EV_of_Confidence, 0.75)
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
    INSERT INTO [ties].[PR_content_ST_location_EV_of_Meta] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Who,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Confidence
    )
    SELECT
        d.Metadata_PR_content_ST_location_EV_of,
        d.PR_content_ST_location_EV_of_ID,
        d.PR_content_ST_location_EV_of_Who,
        @now,
        0.25
    FROM
        deleted d;
END
GO
