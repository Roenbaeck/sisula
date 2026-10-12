-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines the posit and annex table of the tie.
-- It can be used to maintain entity integrity through a primary key, which cannot be
-- defined elsewhere.
--
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- SU_holder_OB_item_GRD_grade assembled view of the posit and annex tables,
-- pkSU_holder_OB_item_GRD_grade optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_holder_OB_item_GRD_grade', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_holder_OB_item_GRD_grade]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_holder_OB_item_GRD_grade,
        p.SU_holder_OB_item_GRD_grade_ID,
        p.SU_ID_holder,
        p.OB_ID_item,
        p.GRD_ID_grade,
        p.SU_holder_OB_item_GRD_grade_ChangedAt,
        a.SU_holder_OB_item_GRD_grade_PositedAt,
        a.SU_holder_OB_item_GRD_grade_Positor,
        a.SU_holder_OB_item_GRD_grade_Reliability,
        a.SU_holder_OB_item_GRD_grade_Assertion
    FROM
        [dbo].[SU_holder_OB_item_GRD_grade_Posit] p
    JOIN
        [dbo].[SU_holder_OB_item_GRD_grade_Annex] a
    ON
        a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_holder_OB_item_GRD_grade]
    ON [dbo].[SU_holder_OB_item_GRD_grade] (
        SU_holder_OB_item_GRD_grade_Assertion desc, 
        SU_ID_holder asc,
        OB_ID_item asc,
        SU_holder_OB_item_GRD_grade_ChangedAt desc,
        SU_holder_OB_item_GRD_grade_PositedAt desc,
        SU_holder_OB_item_GRD_grade_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- SU_keeper_OB_thing_GRD_rank assembled view of the posit and annex tables,
-- pkSU_keeper_OB_thing_GRD_rank optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_keeper_OB_thing_GRD_rank', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_keeper_OB_thing_GRD_rank]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_keeper_OB_thing_GRD_rank,
        p.SU_keeper_OB_thing_GRD_rank_ID,
        p.SU_ID_keeper,
        p.OB_ID_thing,
        p.GRD_ID_rank,
        p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
        a.SU_keeper_OB_thing_GRD_rank_PositedAt,
        a.SU_keeper_OB_thing_GRD_rank_Positor,
        a.SU_keeper_OB_thing_GRD_rank_Reliability,
        a.SU_keeper_OB_thing_GRD_rank_Assertion
    FROM
        [dbo].[SU_keeper_OB_thing_GRD_rank_Posit] p
    JOIN
        [dbo].[SU_keeper_OB_thing_GRD_rank_Annex] a
    ON
        a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_keeper_OB_thing_GRD_rank]
    ON [dbo].[SU_keeper_OB_thing_GRD_rank] (
        SU_keeper_OB_thing_GRD_rank_Assertion desc, 
        SU_ID_keeper asc,
        OB_ID_thing asc,
        SU_keeper_OB_thing_GRD_rank_ChangedAt desc,
        SU_keeper_OB_thing_GRD_rank_PositedAt desc,
        SU_keeper_OB_thing_GRD_rank_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- OB_part_SU_owner assembled view of the posit and annex tables,
-- pkOB_part_SU_owner optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.OB_part_SU_owner', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[OB_part_SU_owner]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_OB_part_SU_owner,
        p.OB_part_SU_owner_ID,
        p.OB_ID_part,
        p.SU_ID_owner,
        a.OB_part_SU_owner_PositedAt,
        a.OB_part_SU_owner_Positor,
        a.OB_part_SU_owner_Reliability,
        a.OB_part_SU_owner_Assertion
    FROM
        [dbo].[OB_part_SU_owner_Posit] p
    JOIN
        [dbo].[OB_part_SU_owner_Annex] a
    ON
        a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkOB_part_SU_owner]
    ON [dbo].[OB_part_SU_owner] (
        OB_part_SU_owner_Assertion desc, 
        OB_ID_part asc,
        OB_part_SU_owner_PositedAt desc,
        OB_part_SU_owner_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- SU_partner_SU_with assembled view of the posit and annex tables,
-- pkSU_partner_SU_with optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('dbo.SU_partner_SU_with', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [dbo].[SU_partner_SU_with]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_SU_partner_SU_with,
        p.SU_partner_SU_with_ID,
        p.SU_ID_partner,
        p.SU_ID_with,
        p.SU_partner_SU_with_ChangedAt,
        a.SU_partner_SU_with_PositedAt,
        a.SU_partner_SU_with_Positor,
        a.SU_partner_SU_with_Reliability,
        a.SU_partner_SU_with_Assertion
    FROM
        [dbo].[SU_partner_SU_with_Posit] p
    JOIN
        [dbo].[SU_partner_SU_with_Annex] a
    ON
        a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkSU_partner_SU_with]
    ON [dbo].[SU_partner_SU_with] (
        SU_partner_SU_with_Assertion desc, 
        SU_ID_partner asc,
        SU_ID_with asc,
        SU_partner_SU_with_ChangedAt desc,
        SU_partner_SU_with_PositedAt desc,
        SU_partner_SU_with_Positor asc
    );
    ');
END
GO
