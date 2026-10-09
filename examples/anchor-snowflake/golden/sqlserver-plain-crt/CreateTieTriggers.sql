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
IF Object_ID('dbo.it_AC_partner_AC_with_ONG_currently', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_partner_AC_with_ONG_currently];
GO
CREATE TRIGGER [dbo].[it_AC_partner_AC_with_ONG_currently] ON [dbo].[AC_partner_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_Version bigint not null,
        AC_partner_AC_with_ONG_currently_StatementType char(1) not null,
        AC_partner_AC_with_ONG_currently_Positor tinyint not null,
        AC_partner_AC_with_ONG_currently_PositedAt datetime2 not null,
        AC_partner_AC_with_ONG_currently_Reliability decimal(5,2) not null,
        AC_partner_AC_with_ONG_currently_Assertion char(1) not null,
        AC_ID_partner int not null,
        AC_ID_with int not null,
        ONG_ID_currently tinyint not null,
        primary key (
            AC_partner_AC_with_ONG_currently_Version,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_partner_AC_with_ONG_currently_Positor,
                i.AC_ID_partner,
                i.AC_ID_with,
                i.ONG_ID_currently
            ORDER BY
                ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now),
                i.AC_partner_AC_with_ONG_currently_PositedAt ASC,
                i.AC_partner_AC_with_ONG_currently_Reliability ASC
        ),
        'X',
        ISNULL(i.AC_partner_AC_with_ONG_currently_Positor, 0),
        ISNULL(i.AC_partner_AC_with_ONG_currently_PositedAt, @now),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1),
        CAST(
            case
                when i.AC_partner_AC_with_ONG_currently_Reliability > 0 then '+'
                when i.AC_partner_AC_with_ONG_currently_Reliability = 0 then '?'
                when i.AC_partner_AC_with_ONG_currently_Reliability < 0 then '-'
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
                [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
            JOIN
                [dbo].[AC_partner_AC_with_ONG_currently_Annex] a
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
                a.AC_partner_AC_with_ONG_currently_Positor = ISNULL(i.AC_partner_AC_with_ONG_currently_Positor, 0)
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
                            [dbo].[tAC_partner_AC_with_ONG_currently](v.AC_partner_AC_with_ONG_currently_Positor, v.AC_partner_AC_with_ONG_currently_ChangedAt, v.AC_partner_AC_with_ONG_currently_PositedAt, v.AC_partner_AC_with_ONG_currently_Assertion) t
                        WHERE
                            t.AC_partner_AC_with_ONG_currently_Reliability = v.AC_partner_AC_with_ONG_currently_Reliability
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
                                [dbo].[rAC_partner_AC_with_ONG_currently] (
                                    v.AC_partner_AC_with_ONG_currently_Positor,
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
                                pre.AC_partner_AC_with_ONG_currently_Assertion = v.AC_partner_AC_with_ONG_currently_Assertion
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
                                [dbo].[fAC_partner_AC_with_ONG_currently] (
                                    v.AC_partner_AC_with_ONG_currently_Positor,
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
                                fol.AC_partner_AC_with_ONG_currently_Assertion = v.AC_partner_AC_with_ONG_currently_Assertion
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
            [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
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
        INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Posit] (
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently
        )
        SELECT
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
        INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        )
        SELECT
            p.AC_partner_AC_with_ONG_currently_ID,
            v.AC_partner_AC_with_ONG_currently_Positor,
            v.AC_partner_AC_with_ONG_currently_PositedAt,
            v.AC_partner_AC_with_ONG_currently_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[AC_partner_AC_with_ONG_currently_Posit] p
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
CREATE TRIGGER [dbo].[it_lAC_partner_AC_with_ONG_currently] ON [dbo].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently] (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.AC_partner_AC_with_ONG_currently_ChangedAt,
        i.AC_ID_partner,
        i.AC_ID_with,
        ISNULL(i.ONG_ID_currently, [ONG_currently].ONG_ID), 
        ISNULL(i.AC_partner_AC_with_ONG_currently_Positor, i.Positor),
        i.AC_partner_AC_with_ONG_currently_PositedAt,
        i.AC_partner_AC_with_ONG_currently_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.ONG_Ongoing;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_partner_AC_with_ONG_currently] ON [dbo].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(AC_partner_AC_with_ONG_currently_Assertion))
        RAISERROR('The computed assertion column AC_partner_AC_with_ONG_currently_Assertion is not updatable.', 16, 1);
    IF(UPDATE(AC_partner_AC_with_ONG_currently_ID))
        RAISERROR('The identity column AC_partner_AC_with_ONG_currently_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        i.AC_partner_AC_with_ONG_currently_ID,
        ISNULL(CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_Positor) THEN i.AC_partner_AC_with_ONG_currently_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(AC_partner_AC_with_ONG_currently_PositedAt) THEN i.AC_partner_AC_with_ONG_currently_PositedAt
            WHEN UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
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
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently] (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
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
                    d.AC_partner_AC_with_ONG_currently_Positor = i.AC_partner_AC_with_ONG_currently_Positor
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
        ISNULL(CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_Positor) THEN i.AC_partner_AC_with_ONG_currently_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_PositedAt) THEN i.AC_partner_AC_with_ONG_currently_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_partner_AC_with_ONG_currently_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
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
            UPDATE(AC_partner_AC_with_ONG_currently_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_partner_AC_with_ONG_currently_ID = i.AC_partner_AC_with_ONG_currently_ID
                AND
                    d.AC_partner_AC_with_ONG_currently_Positor = i.AC_partner_AC_with_ONG_currently_Positor
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
CREATE TRIGGER [dbo].[dt_lAC_partner_AC_with_ONG_currently] ON [dbo].[lAC_partner_AC_with_ONG_currently]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently_Annex] (
        AC_partner_AC_with_ONG_currently_ID,
        AC_partner_AC_with_ONG_currently_Positor,
        AC_partner_AC_with_ONG_currently_PositedAt,
        AC_partner_AC_with_ONG_currently_Reliability
    )
    SELECT
        d.AC_partner_AC_with_ONG_currently_ID,
        d.AC_partner_AC_with_ONG_currently_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_subset_PN_of', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_subset_PN_of];
GO
CREATE TRIGGER [dbo].[it_AC_subset_PN_of] ON [dbo].[AC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        AC_subset_PN_of_Version bigint not null,
        AC_subset_PN_of_StatementType char(1) not null,
        AC_subset_PN_of_Positor tinyint not null,
        AC_subset_PN_of_PositedAt datetime2 not null,
        AC_subset_PN_of_Reliability decimal(5,2) not null,
        AC_subset_PN_of_Assertion char(1) not null,
        AC_ID_subset int not null,
        PN_ID_of int not null,
        primary key (
            AC_ID_subset,
            PN_ID_of
        )
    );
    INSERT INTO @inserted
    SELECT
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_subset_PN_of_Positor,
                i.AC_ID_subset,
                i.PN_ID_of
            ORDER BY
                i.AC_subset_PN_of_PositedAt ASC,
                i.AC_subset_PN_of_Reliability ASC
        ),
        'X',
        ISNULL(i.AC_subset_PN_of_Positor, 0),
        ISNULL(i.AC_subset_PN_of_PositedAt, @now),
        ISNULL(i.AC_subset_PN_of_Reliability, 1),
        CAST(
            case
                when i.AC_subset_PN_of_Reliability > 0 then '+'
                when i.AC_subset_PN_of_Reliability = 0 then '?'
                when i.AC_subset_PN_of_Reliability < 0 then '-'
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
                [dbo].[AC_subset_PN_of_Posit] p
            JOIN
                [dbo].[AC_subset_PN_of_Annex] a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            WHERE
                p.AC_ID_subset = i.AC_ID_subset
            AND
                p.PN_ID_of = i.PN_ID_of
            AND
                a.AC_subset_PN_of_Positor = ISNULL(i.AC_subset_PN_of_Positor, 0)
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
                            [dbo].[tAC_subset_PN_of](v.AC_subset_PN_of_Positor, DEFAULT, v.AC_subset_PN_of_PositedAt, v.AC_subset_PN_of_Assertion) t
                        WHERE
                            t.AC_subset_PN_of_Reliability = v.AC_subset_PN_of_Reliability
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
            [dbo].[AC_subset_PN_of_Posit] p
        ON
            p.AC_ID_subset = v.AC_ID_subset
        AND
            p.PN_ID_of = v.PN_ID_of
        WHERE
            v.AC_subset_PN_of_Version = @currentVersion;
        INSERT INTO [dbo].[AC_subset_PN_of_Posit] (
            AC_ID_subset,
            PN_ID_of
        )
        SELECT
            AC_ID_subset,
            PN_ID_of
        FROM
            @inserted
        WHERE
            AC_subset_PN_of_Version = @currentVersion
        AND
            AC_subset_PN_of_StatementType in ('N');
        INSERT INTO [dbo].[AC_subset_PN_of_Annex] (
            AC_subset_PN_of_ID,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        )
        SELECT
            p.AC_subset_PN_of_ID,
            v.AC_subset_PN_of_Positor,
            v.AC_subset_PN_of_PositedAt,
            v.AC_subset_PN_of_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[AC_subset_PN_of_Posit] p
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
CREATE TRIGGER [dbo].[it_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_subset_PN_of] (
        AC_ID_subset,
        PN_ID_of,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.AC_ID_subset,
        i.PN_ID_of,
        ISNULL(i.AC_subset_PN_of_Positor, i.Positor),
        i.AC_subset_PN_of_PositedAt,
        i.AC_subset_PN_of_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(AC_subset_PN_of_Assertion))
        RAISERROR('The computed assertion column AC_subset_PN_of_Assertion is not updatable.', 16, 1);
    IF(UPDATE(AC_subset_PN_of_ID))
        RAISERROR('The identity column AC_subset_PN_of_ID is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[AC_subset_PN_of_Annex] (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.AC_subset_PN_of_ID,
        ISNULL(CASE WHEN UPDATE(AC_subset_PN_of_Positor) THEN i.AC_subset_PN_of_Positor ELSE i.Positor END, 0),
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
    INSERT INTO [dbo].[AC_subset_PN_of] (
        AC_ID_subset,
        PN_ID_of,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        i.AC_ID_subset,
        i.PN_ID_of,
        ISNULL(CASE WHEN UPDATE(AC_subset_PN_of_Positor) THEN i.AC_subset_PN_of_Positor ELSE i.Positor END, 0),
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
            UPDATE(AC_subset_PN_of_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_subset_PN_of_ID = i.AC_subset_PN_of_ID
                AND
                    d.AC_subset_PN_of_Positor = i.AC_subset_PN_of_Positor
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
CREATE TRIGGER [dbo].[dt_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_subset_PN_of_Annex] (
        AC_subset_PN_of_ID,
        AC_subset_PN_of_Positor,
        AC_subset_PN_of_PositedAt,
        AC_subset_PN_of_Reliability
    )
    SELECT
        d.AC_subset_PN_of_ID,
        d.AC_subset_PN_of_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itEV_in_AC_wasCast instead of INSERT trigger on EV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_EV_in_AC_wasCast', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_EV_in_AC_wasCast];
GO
CREATE TRIGGER [dbo].[it_EV_in_AC_wasCast] ON [dbo].[EV_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        EV_in_AC_wasCast_Version bigint not null,
        EV_in_AC_wasCast_StatementType char(1) not null,
        EV_in_AC_wasCast_Positor tinyint not null,
        EV_in_AC_wasCast_PositedAt datetime2 not null,
        EV_in_AC_wasCast_Reliability decimal(5,2) not null,
        EV_in_AC_wasCast_Assertion char(1) not null,
        EV_ID_in int not null,
        AC_ID_wasCast int not null,
        primary key (
            EV_ID_in,
            AC_ID_wasCast
        )
    );
    INSERT INTO @inserted
    SELECT
        DENSE_RANK() OVER (
            PARTITION BY
                i.EV_in_AC_wasCast_Positor,
                i.EV_ID_in,
                i.AC_ID_wasCast
            ORDER BY
                i.EV_in_AC_wasCast_PositedAt ASC,
                i.EV_in_AC_wasCast_Reliability ASC
        ),
        'X',
        ISNULL(i.EV_in_AC_wasCast_Positor, 0),
        ISNULL(i.EV_in_AC_wasCast_PositedAt, @now),
        ISNULL(i.EV_in_AC_wasCast_Reliability, 1),
        CAST(
            case
                when i.EV_in_AC_wasCast_Reliability > 0 then '+'
                when i.EV_in_AC_wasCast_Reliability = 0 then '?'
                when i.EV_in_AC_wasCast_Reliability < 0 then '-'
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
                [dbo].[EV_in_AC_wasCast_Posit] p
            JOIN
                [dbo].[EV_in_AC_wasCast_Annex] a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            WHERE
                p.EV_ID_in = i.EV_ID_in
            AND
                p.AC_ID_wasCast = i.AC_ID_wasCast
            AND
                a.EV_in_AC_wasCast_Positor = ISNULL(i.EV_in_AC_wasCast_Positor, 0)
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
                            [dbo].[tEV_in_AC_wasCast](v.EV_in_AC_wasCast_Positor, DEFAULT, v.EV_in_AC_wasCast_PositedAt, v.EV_in_AC_wasCast_Assertion) t
                        WHERE
                            t.EV_in_AC_wasCast_Reliability = v.EV_in_AC_wasCast_Reliability
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
            [dbo].[EV_in_AC_wasCast_Posit] p
        ON
            p.EV_ID_in = v.EV_ID_in
        AND
            p.AC_ID_wasCast = v.AC_ID_wasCast
        WHERE
            v.EV_in_AC_wasCast_Version = @currentVersion;
        INSERT INTO [dbo].[EV_in_AC_wasCast_Posit] (
            EV_ID_in,
            AC_ID_wasCast
        )
        SELECT
            EV_ID_in,
            AC_ID_wasCast
        FROM
            @inserted
        WHERE
            EV_in_AC_wasCast_Version = @currentVersion
        AND
            EV_in_AC_wasCast_StatementType in ('N');
        INSERT INTO [dbo].[EV_in_AC_wasCast_Annex] (
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_Positor,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        )
        SELECT
            p.EV_in_AC_wasCast_ID,
            v.EV_in_AC_wasCast_Positor,
            v.EV_in_AC_wasCast_PositedAt,
            v.EV_in_AC_wasCast_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[EV_in_AC_wasCast_Posit] p
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
CREATE TRIGGER [dbo].[it_lEV_in_AC_wasCast] ON [dbo].[lEV_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[EV_in_AC_wasCast] (
        EV_ID_in,
        AC_ID_wasCast,
        EV_in_AC_wasCast_Positor,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        i.EV_ID_in,
        i.AC_ID_wasCast,
        ISNULL(i.EV_in_AC_wasCast_Positor, i.Positor),
        i.EV_in_AC_wasCast_PositedAt,
        i.EV_in_AC_wasCast_Reliability
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_wasCast instead of DELETE trigger on lEV_in_AC_wasCast
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lEV_in_AC_wasCast] ON [dbo].[lEV_in_AC_wasCast]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[EV_in_AC_wasCast_Annex] (
        EV_in_AC_wasCast_ID,
        EV_in_AC_wasCast_Positor,
        EV_in_AC_wasCast_PositedAt,
        EV_in_AC_wasCast_Reliability
    )
    SELECT
        d.EV_in_AC_wasCast_ID,
        d.EV_in_AC_wasCast_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_part_PR_in_RAT_got instead of INSERT trigger on AC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_part_PR_in_RAT_got', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_part_PR_in_RAT_got];
GO
CREATE TRIGGER [dbo].[it_AC_part_PR_in_RAT_got] ON [dbo].[AC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Version bigint not null,
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_Positor tinyint not null,
        AC_part_PR_in_RAT_got_PositedAt datetime2 not null,
        AC_part_PR_in_RAT_got_Reliability decimal(5,2) not null,
        AC_part_PR_in_RAT_got_Assertion char(1) not null,
        AC_ID_part int not null,
        PR_ID_in int not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_part_PR_in_RAT_got_Version,
            AC_ID_part,
            PR_ID_in
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_part_PR_in_RAT_got_Positor,
                i.AC_ID_part,
                i.PR_ID_in
            ORDER BY
                ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
                i.AC_part_PR_in_RAT_got_PositedAt ASC,
                i.AC_part_PR_in_RAT_got_Reliability ASC
        ),
        'X',
        ISNULL(i.AC_part_PR_in_RAT_got_Positor, 0),
        ISNULL(i.AC_part_PR_in_RAT_got_PositedAt, @now),
        ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1),
        CAST(
            case
                when i.AC_part_PR_in_RAT_got_Reliability > 0 then '+'
                when i.AC_part_PR_in_RAT_got_Reliability = 0 then '?'
                when i.AC_part_PR_in_RAT_got_Reliability < 0 then '-'
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
                [dbo].[AC_part_PR_in_RAT_got_Posit] p
            JOIN
                [dbo].[AC_part_PR_in_RAT_got_Annex] a
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
                a.AC_part_PR_in_RAT_got_Positor = ISNULL(i.AC_part_PR_in_RAT_got_Positor, 0)
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
                            [dbo].[tAC_part_PR_in_RAT_got](v.AC_part_PR_in_RAT_got_Positor, v.AC_part_PR_in_RAT_got_ChangedAt, v.AC_part_PR_in_RAT_got_PositedAt, v.AC_part_PR_in_RAT_got_Assertion) t
                        WHERE
                            t.AC_part_PR_in_RAT_got_Reliability = v.AC_part_PR_in_RAT_got_Reliability
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
                                [dbo].[rAC_part_PR_in_RAT_got] (
                                    v.AC_part_PR_in_RAT_got_Positor,
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
                                pre.AC_part_PR_in_RAT_got_Assertion = v.AC_part_PR_in_RAT_got_Assertion
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
                                [dbo].[fAC_part_PR_in_RAT_got] (
                                    v.AC_part_PR_in_RAT_got_Positor,
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
                                fol.AC_part_PR_in_RAT_got_Assertion = v.AC_part_PR_in_RAT_got_Assertion
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
            [dbo].[AC_part_PR_in_RAT_got_Posit] p
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
        INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Posit] (
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got
        )
        SELECT
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
        INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Annex] (
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_Positor,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        )
        SELECT
            p.AC_part_PR_in_RAT_got_ID,
            v.AC_part_PR_in_RAT_got_Positor,
            v.AC_part_PR_in_RAT_got_PositedAt,
            v.AC_part_PR_in_RAT_got_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[AC_part_PR_in_RAT_got_Posit] p
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
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_part_PR_in_RAT_got instead of INSERT trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_ID_part,
        i.PR_ID_in,
        ISNULL(i.RAT_ID_got, [RAT_got].RAT_ID), 
        ISNULL(i.AC_part_PR_in_RAT_got_Positor, i.Positor),
        i.AC_part_PR_in_RAT_got_PositedAt,
        i.AC_part_PR_in_RAT_got_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.RAT_Rating;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_part_PR_in_RAT_got instead of UPDATE trigger on lAC_part_PR_in_RAT_got
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(AC_part_PR_in_RAT_got_Assertion))
        RAISERROR('The computed assertion column AC_part_PR_in_RAT_got_Assertion is not updatable.', 16, 1);
    IF(UPDATE(AC_part_PR_in_RAT_got_ID))
        RAISERROR('The identity column AC_part_PR_in_RAT_got_ID is not updatable.', 16, 1);
    IF(UPDATE(AC_ID_part))
        RAISERROR('The identity column AC_ID_part is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_in))
        RAISERROR('The identity column PR_ID_in is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Annex] (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        i.AC_part_PR_in_RAT_got_ID,
        ISNULL(CASE WHEN UPDATE(AC_part_PR_in_RAT_got_Positor) THEN i.AC_part_PR_in_RAT_got_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(AC_part_PR_in_RAT_got_PositedAt) THEN i.AC_part_PR_in_RAT_got_PositedAt
            WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN i.AC_part_PR_in_RAT_got_ChangedAt
        END, @now) as datetime2),
        0
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.RAT_Rating
    WHERE
        i.AC_part_PR_in_RAT_got_ID is not null
    AND (
        CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is null 
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
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
                    d.AC_part_PR_in_RAT_got_Positor = i.AC_part_PR_in_RAT_got_Positor
                AND
                    d.RAT_ID_got = CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END 
            ) THEN i.AC_part_PR_in_RAT_got_ChangedAt -- the shown version is asserted again
            ELSE @now
        END as datetime2),
        i.AC_ID_part,
        i.PR_ID_in,
        CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END, 
        ISNULL(CASE WHEN UPDATE(AC_part_PR_in_RAT_got_Positor) THEN i.AC_part_PR_in_RAT_got_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(AC_part_PR_in_RAT_got_PositedAt) THEN i.AC_part_PR_in_RAT_got_PositedAt ELSE @now END as datetime2),
        ISNULL(i.AC_part_PR_in_RAT_got_Reliability, 1)
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.RAT_Rating
    WHERE
        CASE WHEN UPDATE(RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END is not null 
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(AC_part_PR_in_RAT_got_ChangedAt) OR
            UPDATE(AC_part_PR_in_RAT_got_PositedAt) OR
            UPDATE(AC_part_PR_in_RAT_got_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.AC_part_PR_in_RAT_got_ID = i.AC_part_PR_in_RAT_got_ID
                AND
                    d.AC_part_PR_in_RAT_got_Positor = i.AC_part_PR_in_RAT_got_Positor
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
CREATE TRIGGER [dbo].[dt_lAC_part_PR_in_RAT_got] ON [dbo].[lAC_part_PR_in_RAT_got]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got_Annex] (
        AC_part_PR_in_RAT_got_ID,
        AC_part_PR_in_RAT_got_Positor,
        AC_part_PR_in_RAT_got_PositedAt,
        AC_part_PR_in_RAT_got_Reliability
    )
    SELECT
        d.AC_part_PR_in_RAT_got_ID,
        d.AC_part_PR_in_RAT_got_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itST_at_PR_isPlaying instead of INSERT trigger on ST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_ST_at_PR_isPlaying', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_ST_at_PR_isPlaying];
GO
CREATE TRIGGER [dbo].[it_ST_at_PR_isPlaying] ON [dbo].[ST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        ST_at_PR_isPlaying_ChangedAt datetime2 not null,
        ST_at_PR_isPlaying_Version bigint not null,
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_Positor tinyint not null,
        ST_at_PR_isPlaying_PositedAt datetime2 not null,
        ST_at_PR_isPlaying_Reliability decimal(5,2) not null,
        ST_at_PR_isPlaying_Assertion char(1) not null,
        ST_ID_at int not null,
        PR_ID_isPlaying int not null,
        primary key (
            ST_at_PR_isPlaying_Version,
            ST_ID_at,
            PR_ID_isPlaying
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
        DENSE_RANK() OVER (
            PARTITION BY
                i.ST_at_PR_isPlaying_Positor,
                i.ST_ID_at,
                i.PR_ID_isPlaying
            ORDER BY
                ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
                i.ST_at_PR_isPlaying_PositedAt ASC,
                i.ST_at_PR_isPlaying_Reliability ASC
        ),
        'X',
        ISNULL(i.ST_at_PR_isPlaying_Positor, 0),
        ISNULL(i.ST_at_PR_isPlaying_PositedAt, @now),
        ISNULL(i.ST_at_PR_isPlaying_Reliability, 1),
        CAST(
            case
                when i.ST_at_PR_isPlaying_Reliability > 0 then '+'
                when i.ST_at_PR_isPlaying_Reliability = 0 then '?'
                when i.ST_at_PR_isPlaying_Reliability < 0 then '-'
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
                [dbo].[ST_at_PR_isPlaying_Posit] p
            JOIN
                [dbo].[ST_at_PR_isPlaying_Annex] a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            WHERE
                p.ST_ID_at = i.ST_ID_at
            AND
                p.PR_ID_isPlaying = i.PR_ID_isPlaying
            AND
                p.ST_at_PR_isPlaying_ChangedAt = ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now)
            AND
                a.ST_at_PR_isPlaying_Positor = ISNULL(i.ST_at_PR_isPlaying_Positor, 0)
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
                            [dbo].[tST_at_PR_isPlaying](v.ST_at_PR_isPlaying_Positor, v.ST_at_PR_isPlaying_ChangedAt, v.ST_at_PR_isPlaying_PositedAt, v.ST_at_PR_isPlaying_Assertion) t
                        WHERE
                            t.ST_at_PR_isPlaying_Reliability = v.ST_at_PR_isPlaying_Reliability
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
            [dbo].[ST_at_PR_isPlaying_Posit] p
        ON
            p.ST_ID_at = v.ST_ID_at
        AND
            p.PR_ID_isPlaying = v.PR_ID_isPlaying
        AND
            p.ST_at_PR_isPlaying_ChangedAt = v.ST_at_PR_isPlaying_ChangedAt
        WHERE
            v.ST_at_PR_isPlaying_Version = @currentVersion;
        INSERT INTO [dbo].[ST_at_PR_isPlaying_Posit] (
            ST_at_PR_isPlaying_ChangedAt,
            ST_ID_at,
            PR_ID_isPlaying
        )
        SELECT
            ST_at_PR_isPlaying_ChangedAt,
            ST_ID_at,
            PR_ID_isPlaying
        FROM
            @inserted
        WHERE
            ST_at_PR_isPlaying_Version = @currentVersion
        AND
            ST_at_PR_isPlaying_StatementType in ('N','R');
        INSERT INTO [dbo].[ST_at_PR_isPlaying_Annex] (
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_Positor,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        )
        SELECT
            p.ST_at_PR_isPlaying_ID,
            v.ST_at_PR_isPlaying_Positor,
            v.ST_at_PR_isPlaying_PositedAt,
            v.ST_at_PR_isPlaying_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[ST_at_PR_isPlaying_Posit] p
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
CREATE TRIGGER [dbo].[it_lST_at_PR_isPlaying] ON [dbo].[lST_at_PR_isPlaying]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_at_PR_isPlaying] (
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying,
        ST_at_PR_isPlaying_Positor,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        i.ST_at_PR_isPlaying_ChangedAt,
        i.ST_ID_at,
        i.PR_ID_isPlaying,
        ISNULL(i.ST_at_PR_isPlaying_Positor, i.Positor),
        i.ST_at_PR_isPlaying_PositedAt,
        i.ST_at_PR_isPlaying_Reliability
    FROM
        inserted i;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_isPlaying instead of DELETE trigger on lST_at_PR_isPlaying
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lST_at_PR_isPlaying] ON [dbo].[lST_at_PR_isPlaying]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[ST_at_PR_isPlaying_Annex] (
        ST_at_PR_isPlaying_ID,
        ST_at_PR_isPlaying_Positor,
        ST_at_PR_isPlaying_PositedAt,
        ST_at_PR_isPlaying_Reliability
    )
    SELECT
        d.ST_at_PR_isPlaying_ID,
        d.ST_at_PR_isPlaying_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itAC_parent_AC_child_PAT_having instead of INSERT trigger on AC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_AC_parent_AC_child_PAT_having', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_AC_parent_AC_child_PAT_having];
GO
CREATE TRIGGER [dbo].[it_AC_parent_AC_child_PAT_having] ON [dbo].[AC_parent_AC_child_PAT_having]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        AC_parent_AC_child_PAT_having_Version bigint not null,
        AC_parent_AC_child_PAT_having_StatementType char(1) not null,
        AC_parent_AC_child_PAT_having_Positor tinyint not null,
        AC_parent_AC_child_PAT_having_PositedAt datetime2 not null,
        AC_parent_AC_child_PAT_having_Reliability decimal(5,2) not null,
        AC_parent_AC_child_PAT_having_Assertion char(1) not null,
        AC_ID_parent int not null,
        AC_ID_child int not null,
        PAT_ID_having tinyint not null,
        primary key (
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        )
    );
    INSERT INTO @inserted
    SELECT
        DENSE_RANK() OVER (
            PARTITION BY
                i.AC_parent_AC_child_PAT_having_Positor,
                i.AC_ID_parent,
                i.AC_ID_child,
                i.PAT_ID_having
            ORDER BY
                i.AC_parent_AC_child_PAT_having_PositedAt ASC,
                i.AC_parent_AC_child_PAT_having_Reliability ASC
        ),
        'X',
        ISNULL(i.AC_parent_AC_child_PAT_having_Positor, 0),
        ISNULL(i.AC_parent_AC_child_PAT_having_PositedAt, @now),
        ISNULL(i.AC_parent_AC_child_PAT_having_Reliability, 1),
        CAST(
            case
                when i.AC_parent_AC_child_PAT_having_Reliability > 0 then '+'
                when i.AC_parent_AC_child_PAT_having_Reliability = 0 then '?'
                when i.AC_parent_AC_child_PAT_having_Reliability < 0 then '-'
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
                [dbo].[AC_parent_AC_child_PAT_having_Posit] p
            JOIN
                [dbo].[AC_parent_AC_child_PAT_having_Annex] a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            WHERE
                p.AC_ID_parent = i.AC_ID_parent
            AND
                p.AC_ID_child = i.AC_ID_child
            AND
                p.PAT_ID_having = i.PAT_ID_having
            AND
                a.AC_parent_AC_child_PAT_having_Positor = ISNULL(i.AC_parent_AC_child_PAT_having_Positor, 0)
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
                            [dbo].[tAC_parent_AC_child_PAT_having](v.AC_parent_AC_child_PAT_having_Positor, DEFAULT, v.AC_parent_AC_child_PAT_having_PositedAt, v.AC_parent_AC_child_PAT_having_Assertion) t
                        WHERE
                            t.AC_parent_AC_child_PAT_having_Reliability = v.AC_parent_AC_child_PAT_having_Reliability
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
            [dbo].[AC_parent_AC_child_PAT_having_Posit] p
        ON
            p.AC_ID_parent = v.AC_ID_parent
        AND
            p.AC_ID_child = v.AC_ID_child
        AND
            p.PAT_ID_having = v.PAT_ID_having
        WHERE
            v.AC_parent_AC_child_PAT_having_Version = @currentVersion;
        INSERT INTO [dbo].[AC_parent_AC_child_PAT_having_Posit] (
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        )
        SELECT
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having
        FROM
            @inserted
        WHERE
            AC_parent_AC_child_PAT_having_Version = @currentVersion
        AND
            AC_parent_AC_child_PAT_having_StatementType in ('N');
        INSERT INTO [dbo].[AC_parent_AC_child_PAT_having_Annex] (
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_Positor,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        )
        SELECT
            p.AC_parent_AC_child_PAT_having_ID,
            v.AC_parent_AC_child_PAT_having_Positor,
            v.AC_parent_AC_child_PAT_having_PositedAt,
            v.AC_parent_AC_child_PAT_having_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[AC_parent_AC_child_PAT_having_Posit] p
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
CREATE TRIGGER [dbo].[it_lAC_parent_AC_child_PAT_having] ON [dbo].[lAC_parent_AC_child_PAT_having]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_parent_AC_child_PAT_having] (
        AC_ID_parent,
        AC_ID_child,
        PAT_ID_having,
        AC_parent_AC_child_PAT_having_Positor,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        i.AC_ID_parent,
        i.AC_ID_child,
        ISNULL(i.PAT_ID_having, [PAT_having].PAT_ID), 
        ISNULL(i.AC_parent_AC_child_PAT_having_Positor, i.Positor),
        i.AC_parent_AC_child_PAT_having_PositedAt,
        i.AC_parent_AC_child_PAT_having_Reliability
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PAT_ParentalType] [PAT_having]
    ON
        [PAT_having].PAT_ParentalType = i.PAT_ParentalType;
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_parent_AC_child_PAT_having instead of DELETE trigger on lAC_parent_AC_child_PAT_having
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lAC_parent_AC_child_PAT_having] ON [dbo].[lAC_parent_AC_child_PAT_having]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_parent_AC_child_PAT_having_Annex] (
        AC_parent_AC_child_PAT_having_ID,
        AC_parent_AC_child_PAT_having_Positor,
        AC_parent_AC_child_PAT_having_PositedAt,
        AC_parent_AC_child_PAT_having_Reliability
    )
    SELECT
        d.AC_parent_AC_child_PAT_having_ID,
        d.AC_parent_AC_child_PAT_having_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- itPR_content_ST_location_EV_of instead of INSERT trigger on PR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.it_PR_content_ST_location_EV_of', 'TR') IS NOT NULL
DROP TRIGGER [dbo].[it_PR_content_ST_location_EV_of];
GO
CREATE TRIGGER [dbo].[it_PR_content_ST_location_EV_of] ON [dbo].[PR_content_ST_location_EV_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    DECLARE @maxVersion int;
    DECLARE @currentVersion int;
    DECLARE @inserted TABLE (
        PR_content_ST_location_EV_of_Version bigint not null,
        PR_content_ST_location_EV_of_StatementType char(1) not null,
        PR_content_ST_location_EV_of_Positor tinyint not null,
        PR_content_ST_location_EV_of_PositedAt datetime2 not null,
        PR_content_ST_location_EV_of_Reliability decimal(5,2) not null,
        PR_content_ST_location_EV_of_Assertion char(1) not null,
        PR_ID_content int not null,
        ST_ID_location int not null,
        EV_ID_of int not null,
        primary key (
            EV_ID_of
        )
    );
    INSERT INTO @inserted
    SELECT
        DENSE_RANK() OVER (
            PARTITION BY
                i.PR_content_ST_location_EV_of_Positor,
                i.EV_ID_of
            ORDER BY
                i.PR_content_ST_location_EV_of_PositedAt ASC,
                i.PR_content_ST_location_EV_of_Reliability ASC
        ),
        'X',
        ISNULL(i.PR_content_ST_location_EV_of_Positor, 0),
        ISNULL(i.PR_content_ST_location_EV_of_PositedAt, @now),
        ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1),
        CAST(
            case
                when i.PR_content_ST_location_EV_of_Reliability > 0 then '+'
                when i.PR_content_ST_location_EV_of_Reliability = 0 then '?'
                when i.PR_content_ST_location_EV_of_Reliability < 0 then '-'
                else '+' -- assume that unspecified reliability (NULL) means default
            end
        as char(1)),
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of
    FROM
        inserted i
    WHERE
        i.EV_ID_of is not null
    AND
        NOT EXISTS ( -- exclude the identical, which is already stored
            SELECT TOP 1
                42
            FROM
                [dbo].[PR_content_ST_location_EV_of_Posit] p
            JOIN
                [dbo].[PR_content_ST_location_EV_of_Annex] a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            WHERE
                p.PR_ID_content = i.PR_ID_content
            AND
                p.ST_ID_location = i.ST_ID_location
            AND
                p.EV_ID_of = i.EV_ID_of
            AND
                a.PR_content_ST_location_EV_of_Positor = ISNULL(i.PR_content_ST_location_EV_of_Positor, 0)
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
                            [dbo].[tPR_content_ST_location_EV_of](v.PR_content_ST_location_EV_of_Positor, DEFAULT, v.PR_content_ST_location_EV_of_PositedAt, v.PR_content_ST_location_EV_of_Assertion) t
                        WHERE
                            t.PR_content_ST_location_EV_of_Reliability = v.PR_content_ST_location_EV_of_Reliability
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
                    ELSE 'N' -- new statement
                END
        FROM
            @inserted v
        LEFT JOIN
            [dbo].[PR_content_ST_location_EV_of_Posit] p
        ON
            p.PR_ID_content = v.PR_ID_content
        AND
            p.ST_ID_location = v.ST_ID_location
        AND
            p.EV_ID_of = v.EV_ID_of
        WHERE
            v.PR_content_ST_location_EV_of_Version = @currentVersion;
        INSERT INTO [dbo].[PR_content_ST_location_EV_of_Posit] (
            PR_ID_content,
            ST_ID_location,
            EV_ID_of
        )
        SELECT
            PR_ID_content,
            ST_ID_location,
            EV_ID_of
        FROM
            @inserted
        WHERE
            PR_content_ST_location_EV_of_Version = @currentVersion
        AND
            PR_content_ST_location_EV_of_StatementType in ('N');
        INSERT INTO [dbo].[PR_content_ST_location_EV_of_Annex] (
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_Positor,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        )
        SELECT
            p.PR_content_ST_location_EV_of_ID,
            v.PR_content_ST_location_EV_of_Positor,
            v.PR_content_ST_location_EV_of_PositedAt,
            v.PR_content_ST_location_EV_of_Reliability
        FROM
            @inserted v
        JOIN
            [dbo].[PR_content_ST_location_EV_of_Posit] p
        ON
            p.PR_ID_content = v.PR_ID_content
        AND
            p.ST_ID_location = v.ST_ID_location
        AND
            p.EV_ID_of = v.EV_ID_of
        WHERE
            v.PR_content_ST_location_EV_of_Version = @currentVersion
        AND
            v.PR_content_ST_location_EV_of_StatementType in ('S','N','D');
    END
END
GO
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_content_ST_location_EV_of instead of INSERT trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[it_lPR_content_ST_location_EV_of] ON [dbo].[lPR_content_ST_location_EV_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PR_content_ST_location_EV_of] (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of,
        ISNULL(i.PR_content_ST_location_EV_of_Positor, i.Positor),
        i.PR_content_ST_location_EV_of_PositedAt,
        i.PR_content_ST_location_EV_of_Reliability
    FROM
        inserted i;
END
GO
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_content_ST_location_EV_of instead of UPDATE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[ut_lPR_content_ST_location_EV_of] ON [dbo].[lPR_content_ST_location_EV_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(PR_content_ST_location_EV_of_Assertion))
        RAISERROR('The computed assertion column PR_content_ST_location_EV_of_Assertion is not updatable.', 16, 1);
    IF(UPDATE(PR_content_ST_location_EV_of_ID))
        RAISERROR('The identity column PR_content_ST_location_EV_of_ID is not updatable.', 16, 1);
    IF(UPDATE(EV_ID_of))
        RAISERROR('The identity column EV_ID_of is not updatable.', 16, 1);
    -- a value set to null retracts the shown posit
    INSERT INTO [dbo].[PR_content_ST_location_EV_of_Annex] (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.PR_content_ST_location_EV_of_ID,
        ISNULL(CASE WHEN UPDATE(PR_content_ST_location_EV_of_Positor) THEN i.PR_content_ST_location_EV_of_Positor ELSE i.Positor END, 0),
        cast(ISNULL(CASE
            WHEN UPDATE(PR_content_ST_location_EV_of_PositedAt) THEN i.PR_content_ST_location_EV_of_PositedAt
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
    );
    -- the other rows are statements, unless they leave everything as it is
    INSERT INTO [dbo].[PR_content_ST_location_EV_of] (
        PR_ID_content,
        ST_ID_location,
        EV_ID_of,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of,
        ISNULL(CASE WHEN UPDATE(PR_content_ST_location_EV_of_Positor) THEN i.PR_content_ST_location_EV_of_Positor ELSE i.Positor END, 0),
        cast(CASE WHEN UPDATE(PR_content_ST_location_EV_of_PositedAt) THEN i.PR_content_ST_location_EV_of_PositedAt ELSE @now END as datetime2),
        ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
    FROM
        inserted i
    WHERE
        i.PR_ID_content is not null
    AND
        i.ST_ID_location is not null
    AND
        ( -- a statement that leaves everything as it is states nothing
            UPDATE(PR_content_ST_location_EV_of_PositedAt) OR
            UPDATE(PR_content_ST_location_EV_of_Positor) OR
            UPDATE(Positor) OR
            NOT EXISTS (
                SELECT TOP 1
                    42
                FROM
                    deleted d
                WHERE
                    d.PR_content_ST_location_EV_of_ID = i.PR_content_ST_location_EV_of_ID
                AND
                    d.PR_content_ST_location_EV_of_Positor = i.PR_content_ST_location_EV_of_Positor
                AND
                    d.PR_ID_content = i.PR_ID_content
                AND
                    d.ST_ID_location = i.ST_ID_location
                AND
                    d.PR_content_ST_location_EV_of_Reliability = ISNULL(i.PR_content_ST_location_EV_of_Reliability, 1)
            )
        );
END
GO
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_content_ST_location_EV_of instead of DELETE trigger on lPR_content_ST_location_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER [dbo].[dt_lPR_content_ST_location_EV_of] ON [dbo].[lPR_content_ST_location_EV_of]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[PR_content_ST_location_EV_of_Annex] (
        PR_content_ST_location_EV_of_ID,
        PR_content_ST_location_EV_of_Positor,
        PR_content_ST_location_EV_of_PositedAt,
        PR_content_ST_location_EV_of_Reliability
    )
    SELECT
        d.PR_content_ST_location_EV_of_ID,
        d.PR_content_ST_location_EV_of_Positor,
        @now,
        0
    FROM
        deleted d;
END
GO
