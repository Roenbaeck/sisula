-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines the posit and annex table of the tie.
-- It can be used to maintain entity integrity through a primary key, which cannot be
-- defined elsewhere.
--
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently assembled view of the posit and annex tables,
-- pkAC_partner_AC_with_ONG_currently optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.AC_partner_AC_with_ONG_currently', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [ties].[AC_partner_AC_with_ONG_currently]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_partner_AC_with_ONG_currently,
        p.AC_partner_AC_with_ONG_currently_ID,
        p.AC_ID_partner,
        p.AC_ID_with,
        p.ONG_ID_currently,
        p.AC_partner_AC_with_ONG_currently_ChangedAt,
        a.AC_partner_AC_with_ONG_currently_PositedAt,
        a.AC_partner_AC_with_ONG_currently_Positor,
        a.AC_partner_AC_with_ONG_currently_Reliability,
        a.AC_partner_AC_with_ONG_currently_Assertion
    FROM
        [ties].[AC_partner_AC_with_ONG_currently_Posit] p
    JOIN
        [ties].[AC_partner_AC_with_ONG_currently_Annex] a
    ON
        a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_partner_AC_with_ONG_currently]
    ON [ties].[AC_partner_AC_with_ONG_currently] (
        AC_partner_AC_with_ONG_currently_Assertion desc, 
        AC_ID_partner asc,
        AC_ID_with asc,
        ONG_ID_currently asc,
        AC_partner_AC_with_ONG_currently_ChangedAt desc,
        AC_partner_AC_with_ONG_currently_PositedAt desc,
        AC_partner_AC_with_ONG_currently_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_subset_PN_of assembled view of the posit and annex tables,
-- pkAC_subset_PN_of optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.AC_subset_PN_of', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [ties].[AC_subset_PN_of]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_subset_PN_of,
        p.AC_subset_PN_of_ID,
        p.AC_ID_subset,
        p.PN_ID_of,
        a.AC_subset_PN_of_PositedAt,
        a.AC_subset_PN_of_Positor,
        a.AC_subset_PN_of_Reliability,
        a.AC_subset_PN_of_Assertion
    FROM
        [ties].[AC_subset_PN_of_Posit] p
    JOIN
        [ties].[AC_subset_PN_of_Annex] a
    ON
        a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_subset_PN_of]
    ON [ties].[AC_subset_PN_of] (
        AC_subset_PN_of_Assertion desc, 
        AC_ID_subset asc,
        PN_ID_of asc,
        AC_subset_PN_of_PositedAt desc,
        AC_subset_PN_of_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast assembled view of the posit and annex tables,
-- pkEV_in_AC_wasCast optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.EV_in_AC_wasCast', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [ties].[EV_in_AC_wasCast]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_EV_in_AC_wasCast,
        p.EV_in_AC_wasCast_ID,
        p.EV_ID_in,
        p.AC_ID_wasCast,
        a.EV_in_AC_wasCast_PositedAt,
        a.EV_in_AC_wasCast_Positor,
        a.EV_in_AC_wasCast_Reliability,
        a.EV_in_AC_wasCast_Assertion
    FROM
        [ties].[EV_in_AC_wasCast_Posit] p
    JOIN
        [ties].[EV_in_AC_wasCast_Annex] a
    ON
        a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkEV_in_AC_wasCast]
    ON [ties].[EV_in_AC_wasCast] (
        EV_in_AC_wasCast_Assertion desc, 
        EV_ID_in asc,
        AC_ID_wasCast asc,
        EV_in_AC_wasCast_PositedAt desc,
        EV_in_AC_wasCast_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got assembled view of the posit and annex tables,
-- pkAC_part_PR_in_RAT_got optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.AC_part_PR_in_RAT_got', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [ties].[AC_part_PR_in_RAT_got]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_part_PR_in_RAT_got,
        p.AC_part_PR_in_RAT_got_ID,
        p.AC_ID_part,
        p.PR_ID_in,
        p.RAT_ID_got,
        p.AC_part_PR_in_RAT_got_ChangedAt,
        a.AC_part_PR_in_RAT_got_PositedAt,
        a.AC_part_PR_in_RAT_got_Positor,
        a.AC_part_PR_in_RAT_got_Reliability,
        a.AC_part_PR_in_RAT_got_Assertion
    FROM
        [ties].[AC_part_PR_in_RAT_got_Posit] p
    JOIN
        [ties].[AC_part_PR_in_RAT_got_Annex] a
    ON
        a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_part_PR_in_RAT_got]
    ON [ties].[AC_part_PR_in_RAT_got] (
        AC_part_PR_in_RAT_got_Assertion desc, 
        AC_ID_part asc,
        PR_ID_in asc,
        AC_part_PR_in_RAT_got_ChangedAt desc,
        AC_part_PR_in_RAT_got_PositedAt desc,
        AC_part_PR_in_RAT_got_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying assembled view of the posit and annex tables,
-- pkST_at_PR_isPlaying optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.ST_at_PR_isPlaying', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [ties].[ST_at_PR_isPlaying]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_ST_at_PR_isPlaying,
        p.ST_at_PR_isPlaying_ID,
        p.ST_ID_at,
        p.PR_ID_isPlaying,
        p.ST_at_PR_isPlaying_ChangedAt,
        a.ST_at_PR_isPlaying_PositedAt,
        a.ST_at_PR_isPlaying_Positor,
        a.ST_at_PR_isPlaying_Reliability,
        a.ST_at_PR_isPlaying_Assertion
    FROM
        [ties].[ST_at_PR_isPlaying_Posit] p
    JOIN
        [ties].[ST_at_PR_isPlaying_Annex] a
    ON
        a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkST_at_PR_isPlaying]
    ON [ties].[ST_at_PR_isPlaying] (
        ST_at_PR_isPlaying_Assertion desc, 
        ST_ID_at asc,
        PR_ID_isPlaying asc,
        ST_at_PR_isPlaying_ChangedAt desc,
        ST_at_PR_isPlaying_PositedAt desc,
        ST_at_PR_isPlaying_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having assembled view of the posit and annex tables,
-- pkAC_parent_AC_child_PAT_having optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.AC_parent_AC_child_PAT_having', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [ties].[AC_parent_AC_child_PAT_having]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_AC_parent_AC_child_PAT_having,
        p.AC_parent_AC_child_PAT_having_ID,
        p.AC_ID_parent,
        p.AC_ID_child,
        p.PAT_ID_having,
        a.AC_parent_AC_child_PAT_having_PositedAt,
        a.AC_parent_AC_child_PAT_having_Positor,
        a.AC_parent_AC_child_PAT_having_Reliability,
        a.AC_parent_AC_child_PAT_having_Assertion
    FROM
        [ties].[AC_parent_AC_child_PAT_having_Posit] p
    JOIN
        [ties].[AC_parent_AC_child_PAT_having_Annex] a
    ON
        a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkAC_parent_AC_child_PAT_having]
    ON [ties].[AC_parent_AC_child_PAT_having] (
        AC_parent_AC_child_PAT_having_Assertion desc, 
        AC_ID_parent asc,
        AC_ID_child asc,
        PAT_ID_having asc,
        AC_parent_AC_child_PAT_having_PositedAt desc,
        AC_parent_AC_child_PAT_having_Positor asc
    );
    ');
END
GO
-- Tie assembled view -------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of assembled view of the posit and annex tables,
-- pkPR_content_ST_location_EV_of optional temporal consistency constraint
-----------------------------------------------------------------------------------------------------------------------
IF Object_ID('ties.PR_content_ST_location_EV_of', 'V') IS NULL
BEGIN
    EXEC('
    CREATE VIEW [ties].[PR_content_ST_location_EV_of]
    WITH SCHEMABINDING AS
    SELECT
        a.Metadata_PR_content_ST_location_EV_of,
        p.PR_content_ST_location_EV_of_ID,
        p.PR_ID_content,
        p.ST_ID_location,
        p.EV_ID_of,
        p.PR_content_ST_location_EV_of_ChangedAt,
        a.PR_content_ST_location_EV_of_PositedAt,
        a.PR_content_ST_location_EV_of_Positor,
        a.PR_content_ST_location_EV_of_Reliability,
        a.PR_content_ST_location_EV_of_Assertion
    FROM
        [ties].[PR_content_ST_location_EV_of_Posit] p
    JOIN
        [ties].[PR_content_ST_location_EV_of_Annex] a
    ON
        a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID;
    ');
    -- Constraint ensuring that recorded and erased posits are temporally consistent
    EXEC('
    CREATE UNIQUE CLUSTERED INDEX [pkPR_content_ST_location_EV_of]
    ON [ties].[PR_content_ST_location_EV_of] (
        PR_content_ST_location_EV_of_Assertion desc, 
        PR_ID_content asc,
        ST_ID_location asc,
        EV_ID_of asc,
        PR_content_ST_location_EV_of_ChangedAt desc,
        PR_content_ST_location_EV_of_PositedAt desc,
        PR_content_ST_location_EV_of_Positor asc
    );
    ');
END
GO
