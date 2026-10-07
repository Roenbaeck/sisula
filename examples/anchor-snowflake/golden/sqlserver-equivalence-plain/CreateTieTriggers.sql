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
    DECLARE @inserted TABLE (
        AC_partner_AC_with_ONG_currently_StatementType char(1) not null,
        AC_partner_AC_with_ONG_currently_ChangedAt datetime2 not null,
        AC_ID_partner int not null,
        AC_ID_with int not null,
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
            [dbo].[AC_partner_AC_with_ONG_currently] x
        WHERE 
            x.AC_ID_partner = i.AC_ID_partner
        AND
            x.AC_ID_with = i.AC_ID_with
        AND
            x.ONG_ID_currently = i.ONG_ID_currently
        AND
            x.AC_partner_AC_with_ONG_currently_ChangedAt = i.AC_partner_AC_with_ONG_currently_ChangedAt
    );
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently] (
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
        AC_partner_AC_with_ONG_currently_StatementType = 'P';
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
        ONG_ID_currently
    )
    SELECT
        i.AC_partner_AC_with_ONG_currently_ChangedAt,
        i.AC_ID_partner,
        i.AC_ID_with,
        ISNULL(i.ONG_ID_currently, [ONG_currently].ONG_ID) 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing;
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
    INSERT INTO [dbo].[AC_partner_AC_with_ONG_currently] (
        AC_partner_AC_with_ONG_currently_ChangedAt,
        AC_ID_partner,
        AC_ID_with,
        ONG_ID_currently
    )
    SELECT
        cast(CASE WHEN UPDATE(AC_partner_AC_with_ONG_currently_ChangedAt) THEN i.AC_partner_AC_with_ONG_currently_ChangedAt ELSE @now END as datetime2),
        i.AC_ID_partner,
        i.AC_ID_with,
        CASE WHEN UPDATE(currently_ONG_Ongoing) THEN [ONG_currently].ONG_ID ELSE i.ONG_ID_currently END 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[ONG_Ongoing] [ONG_currently]
    ON
        [ONG_currently].ONG_Ongoing = i.currently_ONG_Ongoing; 
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
    DELETE tie
    FROM
        [dbo].[AC_partner_AC_with_ONG_currently] tie
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
CREATE TRIGGER [dbo].[it_lAC_subset_PN_of] ON [dbo].[lAC_subset_PN_of]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[AC_subset_PN_of] (
        AC_ID_subset,
        PN_ID_of
    )
    SELECT
        i.AC_ID_subset,
        i.PN_ID_of
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
    DELETE tie
    FROM
        [dbo].[AC_subset_PN_of] tie
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
CREATE TRIGGER [dbo].[it_lEV_in_AC_wasCast] ON [dbo].[lEV_in_AC_wasCast]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    INSERT INTO [dbo].[EV_in_AC_wasCast] (
        EV_ID_in,
        AC_ID_wasCast
    )
    SELECT
        i.EV_ID_in,
        i.AC_ID_wasCast
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
    DELETE tie
    FROM
        [dbo].[EV_in_AC_wasCast] tie
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
    DECLARE @inserted TABLE (
        AC_part_PR_in_RAT_got_StatementType char(1) not null,
        AC_part_PR_in_RAT_got_ChangedAt datetime2 not null,
        AC_ID_part int not null,
        PR_ID_in int not null,
        RAT_ID_got tinyint not null,
        primary key (
            AC_ID_part asc,
            PR_ID_in asc,
            AC_part_PR_in_RAT_got_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
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
            [dbo].[AC_part_PR_in_RAT_got] x
        WHERE 
            x.AC_ID_part = i.AC_ID_part
        AND
            x.PR_ID_in = i.PR_ID_in
        AND
            x.RAT_ID_got = i.RAT_ID_got
        AND
            x.AC_part_PR_in_RAT_got_ChangedAt = i.AC_part_PR_in_RAT_got_ChangedAt
    );
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
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
        AC_part_PR_in_RAT_got_StatementType = 'P';
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
        RAT_ID_got
    )
    SELECT
        i.AC_part_PR_in_RAT_got_ChangedAt,
        i.AC_ID_part,
        i.PR_ID_in,
        ISNULL(i.RAT_ID_got, [RAT_got].RAT_ID) 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating;
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
    IF(UPDATE(AC_ID_part))
        RAISERROR('The identity column AC_ID_part is not updatable.', 16, 1);
    IF(UPDATE(PR_ID_in))
        RAISERROR('The identity column PR_ID_in is not updatable.', 16, 1);
    INSERT INTO [dbo].[AC_part_PR_in_RAT_got] (
        AC_part_PR_in_RAT_got_ChangedAt,
        AC_ID_part,
        PR_ID_in,
        RAT_ID_got
    )
    SELECT
        cast(CASE WHEN UPDATE(AC_part_PR_in_RAT_got_ChangedAt) THEN i.AC_part_PR_in_RAT_got_ChangedAt ELSE @now END as datetime2),
        i.AC_ID_part,
        i.PR_ID_in,
        CASE WHEN UPDATE(got_RAT_Rating) THEN [RAT_got].RAT_ID ELSE i.RAT_ID_got END 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[RAT_Rating] [RAT_got]
    ON
        [RAT_got].RAT_Rating = i.got_RAT_Rating; 
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
    DELETE tie
    FROM
        [dbo].[AC_part_PR_in_RAT_got] tie
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
    DECLARE @inserted TABLE (
        ST_at_PR_isPlaying_StatementType char(1) not null,
        ST_at_PR_isPlaying_ChangedAt datetime2 not null,
        ST_ID_at int not null,
        PR_ID_isPlaying int not null,
        primary key (
            ST_ID_at asc,
            PR_ID_isPlaying asc,
            ST_at_PR_isPlaying_ChangedAt desc
        )
    );
    INSERT INTO @inserted
    SELECT
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
            [dbo].[ST_at_PR_isPlaying] x
        WHERE 
            x.ST_ID_at = i.ST_ID_at
        AND
            x.PR_ID_isPlaying = i.PR_ID_isPlaying
        AND
            x.ST_at_PR_isPlaying_ChangedAt = i.ST_at_PR_isPlaying_ChangedAt
    );
    INSERT INTO [dbo].[ST_at_PR_isPlaying] (
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
        ST_at_PR_isPlaying_StatementType = 'P';
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
        PR_ID_isPlaying
    )
    SELECT
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
CREATE TRIGGER [dbo].[dt_lST_at_PR_isPlaying] ON [dbo].[lST_at_PR_isPlaying]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE tie
    FROM
        [dbo].[ST_at_PR_isPlaying] tie
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
        PAT_ID_having
    )
    SELECT
        i.AC_ID_parent,
        i.AC_ID_child,
        ISNULL(i.PAT_ID_having, [PAT_having].PAT_ID) 
    FROM
        inserted i
    LEFT JOIN
        [dbo].[PAT_ParentalType] [PAT_having]
    ON
        [PAT_having].PAT_ParentalType = i.having_PAT_ParentalType;
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
    DELETE tie
    FROM
        [dbo].[AC_parent_AC_child_PAT_having] tie
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
        EV_ID_of
    )
    SELECT
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
CREATE TRIGGER [dbo].[ut_lPR_content_ST_location_EV_of] ON [dbo].[lPR_content_ST_location_EV_of]
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now datetime2;
    SET @now = sysdatetime();
    IF(UPDATE(EV_ID_of))
        RAISERROR('The identity column EV_ID_of is not updatable.', 16, 1);
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
    DELETE tie
    FROM
        [dbo].[PR_content_ST_location_EV_of] tie
    JOIN
        deleted d
    ON
        d.EV_ID_of = tie.EV_ID_of;
END
GO
