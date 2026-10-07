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
        AC_ID_partner smallint not null,
        AC_ID_with smallint not null,
        ONG_ID_currently tinyint not null,
        primary key (
            AC_ID_partner asc,
            AC_ID_with asc,
            ONG_ID_currently asc,
            AC_partner_AC_with_ONG_currently_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_partner_AC_with_ONG_currently, 0),
        'P', -- new posit
        ISNULL(i.AC_partner_AC_with_ONG_currently_ChangedAt, @now),
        i.AC_ID_partner,
        i.AC_ID_with,
        i.ONG_ID_currently
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [ties].[AC_partner_AC_with_ONG_currently] x
        WHERE 
            x.AC_ID_partner = i.AC_ID_partner
        AND
            x.AC_ID_with = i.AC_ID_with
        AND
            x.ONG_ID_currently = i.ONG_ID_currently
        AND
            x.AC_partner_AC_with_ONG_currently_ChangedAt = i.AC_partner_AC_with_ONG_currently_ChangedAt
    );
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently] (
        Metadata_AC_partner_AC_with_ONG_currently, 
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    FROM
        @inserted
    WHERE
        AC_partner_AC_with_ONG_currently_StatementType = 'P';
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
        ONG_ID_currently
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        i.AC_partner_AC_with_ONG_currently_ChangedAt,
        i.AC_ID_partner,
        i.AC_ID_with,
        ISNULL(i.ONG_ID_currently, [ONG_currently].ONG_ID) 
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
    INSERT INTO [ties].[AC_partner_AC_with_ONG_currently] (
        Metadata_AC_partner_AC_with_ONG_currently,
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        i.Metadata_AC_partner_AC_with_ONG_currently,
        cast(CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt ELSE @now END as datetime2),
        i.AC_ID_partner,
        i.AC_ID_with,
        CASE WHEN UPDATE(currently_ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END 
    FROM
        inserted i
    LEFT JOIN
        [knots].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing; 
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
    DELETE tie
    FROM
        [ties].[AC_partner_AC_with_ONG_currently] tie
    JOIN
        deleted d
    ON
        d.AC_partner_AC_with_ONG_currently_ChangedAt = tie.AC_partner_AC_with_ONG_currently_ChangedAt
    AND
       (
            d.AC_ID_partner = tie.AC_ID_partner
        AND
            d.AC_ID_with = tie.AC_ID_with
        AND
            d.ONG_ID_currently = tie.ONG_ID_currently
       );
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
        PN_ID_of
    )
    SELECT
        i.Metadata_AC_subset_PN_of,
        i.AC_ID_subset,
        i.PN_ID_of
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
    DELETE tie
    FROM
        [ties].[AC_subset_PN_of] tie
    JOIN
        deleted d
    ON
       (
            d.AC_ID_subset = tie.AC_ID_subset
        AND
            d.PN_ID_of = tie.PN_ID_of
       );
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
        AC_ID_wasCast
    )
    SELECT
        i.Metadata_EV_in_AC_wasCast,
        i.EV_ID_in,
        i.AC_ID_wasCast
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
    DELETE tie
    FROM
        [ties].[EV_in_AC_wasCast] tie
    JOIN
        deleted d
    ON
        d.EV_ID_in = tie.EV_ID_in
    AND
        d.AC_ID_wasCast = tie.AC_ID_wasCast;
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
        AC_ID_part smallint not null,
        PR_ID_in bigint not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_ID_part asc,
            PR_ID_in asc,
            AC_part_PR_in_RAT_got_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_AC_part_PR_in_RAT_got, 0),
        'P', -- new posit
        ISNULL(i.AC_part_PR_in_RAT_got_ChangedAt, @now),
        i.AC_ID_part,
        i.PR_ID_in,
        i.RAT_ID_got
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [ties].[AC_part_PR_in_RAT_got] x
        WHERE 
            x.AC_ID_part = i.AC_ID_part
        AND
            x.PR_ID_in = i.PR_ID_in
        AND
            x.RAT_ID_got = i.RAT_ID_got
        AND
            x.AC_part_PR_in_RAT_got_ChangedAt = i.AC_part_PR_in_RAT_got_ChangedAt
    );
    INSERT INTO [ties].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got, 
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    FROM
        @inserted
    WHERE
        AC_part_PR_in_RAT_got_StatementType = 'P';
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
        RAT_ID_got
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        i.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_ID_part,
        i.PR_ID_in,
        ISNULL(i.RAT_ID_got, [RAT_got].RAT_ID) 
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
    IF(UPDATE(AC_ID_part))
        RAISERROR('The identity column AC_ID_part is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_in))
        RAISERROR('The identity column PR_ID_in is not updatable.', 16, 1);
    INSERT INTO [ties].[AC_part_PR_in_RAT_got] (
        Metadata_AC_part_PR_in_RAT_got,
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        i.Metadata_AC_part_PR_in_RAT_got,
        cast(CASE WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN i.AC_part_PR_in_RAT_got_ChangedAt ELSE @now END as datetime2),
        i.AC_ID_part,
        i.PR_ID_in,
        CASE WHEN UPDATE(got_RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END 
    FROM
        inserted i
    LEFT JOIN
        [knots].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating; 
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
    DELETE tie
    FROM
        [ties].[AC_part_PR_in_RAT_got] tie
    JOIN
        deleted d
    ON
        d.AC_part_PR_in_RAT_got_ChangedAt = tie.AC_part_PR_in_RAT_got_ChangedAt
    AND
        d.AC_ID_part = tie.AC_ID_part
    AND
        d.PR_ID_in = tie.PR_ID_in;
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
        ST_ID_at int not null,
        PR_ID_isPlaying bigint not null,
        primary key (
            ST_ID_at asc,
            PR_ID_isPlaying asc,
            ST_at_PR_isPlaying_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_ST_at_PR_isPlaying, 0),
        'P', -- new posit
        ISNULL(i.ST_at_PR_isPlaying_ChangedAt, @now),
        i.ST_ID_at,
        i.PR_ID_isPlaying
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [ties].[ST_at_PR_isPlaying] x
        WHERE 
            x.ST_ID_at = i.ST_ID_at
        AND
            x.PR_ID_isPlaying = i.PR_ID_isPlaying
        AND
            x.ST_at_PR_isPlaying_ChangedAt = i.ST_at_PR_isPlaying_ChangedAt
    );
    INSERT INTO [ties].[ST_at_PR_isPlaying] (
        Metadata_ST_at_PR_isPlaying, 
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    )
    SELECT
        Metadata_ST_at_PR_isPlaying,
        ST_at_PR_isPlaying_ChangedAt,
        ST_ID_at,
        PR_ID_isPlaying
    FROM
        @inserted
    WHERE
        ST_at_PR_isPlaying_StatementType = 'P';
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
        PR_ID_isPlaying
    )
    SELECT
        i.Metadata_ST_at_PR_isPlaying,
        i.ST_at_PR_isPlaying_ChangedAt,
        i.ST_ID_at,
        i.PR_ID_isPlaying
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
    DELETE tie
    FROM
        [ties].[ST_at_PR_isPlaying] tie
    JOIN
        deleted d
    ON
        d.ST_at_PR_isPlaying_ChangedAt = tie.ST_at_PR_isPlaying_ChangedAt
    AND
        d.ST_ID_at = tie.ST_ID_at
    AND
        d.PR_ID_isPlaying = tie.PR_ID_isPlaying;
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
        PAT_ID_having
    )
    SELECT
        i.Metadata_AC_parent_AC_child_PAT_having,
        i.AC_ID_parent,
        i.AC_ID_child,
        ISNULL(i.PAT_ID_having, [PAT_having].PAT_ID) 
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
    DELETE tie
    FROM
        [ties].[AC_parent_AC_child_PAT_having] tie
    JOIN
        deleted d
    ON
        d.AC_ID_parent = tie.AC_ID_parent
    AND
        d.AC_ID_child = tie.AC_ID_child
    AND
        d.PAT_ID_having = tie.PAT_ID_having;
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
        PR_ID_content bigint not null,
        ST_ID_location int not null,
        EV_ID_of numeric(12,0) not null,
        primary key (
            PR_ID_content asc,
            ST_ID_location asc,
            EV_ID_of asc,
            PR_content_ST_location_EV_of_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
        ISNULL(i.Metadata_PR_content_ST_location_EV_of, 0),
        'P', -- new posit
        ISNULL(i.PR_content_ST_location_EV_of_ChangedAt, @now),
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of
    FROM
        inserted i
    WHERE NOT EXISTS (
        SELECT TOP 1
            42
        FROM
            [ties].[PR_content_ST_location_EV_of] x
        WHERE 
            x.PR_ID_content = i.PR_ID_content
        AND
            x.ST_ID_location = i.ST_ID_location
        AND
            x.EV_ID_of = i.EV_ID_of
        AND
            x.PR_content_ST_location_EV_of_ChangedAt = i.PR_content_ST_location_EV_of_ChangedAt
    );
    INSERT INTO [ties].[PR_content_ST_location_EV_of] (
        Metadata_PR_content_ST_location_EV_of, 
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    FROM
        @inserted
    WHERE
        PR_content_ST_location_EV_of_StatementType = 'P';
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
        EV_ID_of
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        i.PR_content_ST_location_EV_of_ChangedAt,
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of
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
    INSERT INTO [ties].[PR_content_ST_location_EV_of] (
        Metadata_PR_content_ST_location_EV_of,
        PR_content_ST_location_EV_of_ChangedAt,
        PR_ID_content,
        ST_ID_location,
        EV_ID_of
    )
    SELECT
        i.Metadata_PR_content_ST_location_EV_of,
        cast(CASE WHEN UPDATE(PR_content_ST_location_EV_of_ChangedAt) THEN i.PR_content_ST_location_EV_of_ChangedAt ELSE @now END as datetime2),
        i.PR_ID_content,
        i.ST_ID_location,
        i.EV_ID_of
    FROM
        inserted i; 
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
    DELETE tie
    FROM
        [ties].[PR_content_ST_location_EV_of] tie
    JOIN
        deleted d
    ON
        d.PR_content_ST_location_EV_of_ChangedAt = tie.PR_content_ST_location_EV_of_ChangedAt
    AND
       (
            d.PR_ID_content = tie.PR_ID_content
        AND
            d.ST_ID_location = tie.ST_ID_location
        AND
            d.EV_ID_of = tie.EV_ID_of
       );
END
GO
