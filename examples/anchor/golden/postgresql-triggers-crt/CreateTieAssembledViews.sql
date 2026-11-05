-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public."SU_holder_OB_item_GRD_grade" AS
SELECT
    a."Metadata_SU_holder_OB_item_GRD_grade",
    p."SU_holder_OB_item_GRD_grade_ID",
    p."SU_ID_holder",
    p."OB_ID_item",
    p."GRD_ID_grade",
    p."SU_holder_OB_item_GRD_grade_ChangedAt",
    a."SU_holder_OB_item_GRD_grade_PositedAt",
    a."SU_holder_OB_item_GRD_grade_Positor",
    a."SU_holder_OB_item_GRD_grade_Reliability",
    a."SU_holder_OB_item_GRD_grade_Assertion"
FROM
    public."SU_holder_OB_item_GRD_grade_Posit" p
JOIN
    public."SU_holder_OB_item_GRD_grade_Annex" a
ON
    a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
;
CREATE OR REPLACE VIEW public."SU_keeper_OB_thing_GRD_rank" AS
SELECT
    a."Metadata_SU_keeper_OB_thing_GRD_rank",
    p."SU_keeper_OB_thing_GRD_rank_ID",
    p."SU_ID_keeper",
    p."OB_ID_thing",
    p."GRD_ID_rank",
    p."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt",
    a."SU_keeper_OB_thing_GRD_rank_Positor",
    a."SU_keeper_OB_thing_GRD_rank_Reliability",
    a."SU_keeper_OB_thing_GRD_rank_Assertion"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Posit" p
JOIN
    public."SU_keeper_OB_thing_GRD_rank_Annex" a
ON
    a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
;
CREATE OR REPLACE VIEW public."OB_part_SU_owner" AS
SELECT
    a."Metadata_OB_part_SU_owner",
    p."OB_part_SU_owner_ID",
    p."OB_ID_part",
    p."SU_ID_owner",
    a."OB_part_SU_owner_PositedAt",
    a."OB_part_SU_owner_Positor",
    a."OB_part_SU_owner_Reliability",
    a."OB_part_SU_owner_Assertion"
FROM
    public."OB_part_SU_owner_Posit" p
JOIN
    public."OB_part_SU_owner_Annex" a
ON
    a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
;
CREATE OR REPLACE VIEW public."SU_partner_SU_with" AS
SELECT
    a."Metadata_SU_partner_SU_with",
    p."SU_partner_SU_with_ID",
    p."SU_ID_partner",
    p."SU_ID_with",
    p."SU_partner_SU_with_ChangedAt",
    a."SU_partner_SU_with_PositedAt",
    a."SU_partner_SU_with_Positor",
    a."SU_partner_SU_with_Reliability",
    a."SU_partner_SU_with_Assertion"
FROM
    public."SU_partner_SU_with_Posit" p
JOIN
    public."SU_partner_SU_with_Annex" a
ON
    a."SU_partner_SU_with_ID" = p."SU_partner_SU_with_ID"
;
