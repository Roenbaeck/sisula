-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW AC_partner_AC_with_ONG_currently AS
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
    AC_partner_AC_with_ONG_currently_Posit p
JOIN
    AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
;
CREATE OR REPLACE VIEW AC_subset_PN_of AS
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
    AC_subset_PN_of_Posit p
JOIN
    AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
;
CREATE OR REPLACE VIEW EV_in_AC_wasCast AS
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
    EV_in_AC_wasCast_Posit p
JOIN
    EV_in_AC_wasCast_Annex a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
;
CREATE OR REPLACE VIEW AC_part_PR_in_RAT_got AS
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
    AC_part_PR_in_RAT_got_Posit p
JOIN
    AC_part_PR_in_RAT_got_Annex a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
;
CREATE OR REPLACE VIEW ST_at_PR_isPlaying AS
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
    ST_at_PR_isPlaying_Posit p
JOIN
    ST_at_PR_isPlaying_Annex a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
;
CREATE OR REPLACE VIEW AC_parent_AC_child_PAT_having AS
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
    AC_parent_AC_child_PAT_having_Posit p
JOIN
    AC_parent_AC_child_PAT_having_Annex a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
;
CREATE OR REPLACE VIEW PR_content_ST_location_EV_of AS
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Positor,
    a.PR_content_ST_location_EV_of_Reliability,
    a.PR_content_ST_location_EV_of_Assertion
FROM
    PR_content_ST_location_EV_of_Posit p
JOIN
    PR_content_ST_location_EV_of_Annex a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
;
