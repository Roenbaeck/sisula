-- TIE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views for ties.
--
CREATE OR REPLACE VIEW ties.rAC_partner_AC_with_ONG_currently AS
SELECT
    a.Metadata_AC_partner_AC_with_ONG_currently,
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Who,
    a.AC_partner_AC_with_ONG_currently_Confidence,
    a.AC_partner_AC_with_ONG_currently_Stance,
    a.
FROM
    ties.AC_partner_AC_with_ONG_currently_Fact p
JOIN
    ties.AC_partner_AC_with_ONG_currently_Meta a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
WHERE
    a.AC_partner_AC_with_ONG_currently_Who = 0
AND
    a.AC_partner_AC_with_ONG_currently_PositedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_PositedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently_Meta sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
        AND
            sub.AC_partner_AC_with_ONG_currently_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Who,
    a.AC_subset_PN_of_Confidence,
    a.AC_subset_PN_of_Stance,
    a.
FROM
    ties.AC_subset_PN_of_Fact p
JOIN
    ties.AC_subset_PN_of_Meta a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
WHERE
    a.AC_subset_PN_of_Who = 0
AND
    a.AC_subset_PN_of_PositedAt = (
        SELECT
            MAX(sub.AC_subset_PN_of_PositedAt)
        FROM
            ties.AC_subset_PN_of_Meta sub
        WHERE
            sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
        AND
            sub.AC_subset_PN_of_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rEV_in_AC_wasCast AS
SELECT
    a.Metadata_EV_in_AC_wasCast,
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Who,
    a.EV_in_AC_wasCast_Confidence,
    a.EV_in_AC_wasCast_Stance,
    a.
FROM
    ties.EV_in_AC_wasCast_Fact p
JOIN
    ties.EV_in_AC_wasCast_Meta a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
WHERE
    a.EV_in_AC_wasCast_Who = 0
AND
    a.EV_in_AC_wasCast_PositedAt = (
        SELECT
            MAX(sub.EV_in_AC_wasCast_PositedAt)
        FROM
            ties.EV_in_AC_wasCast_Meta sub
        WHERE
            sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
        AND
            sub.EV_in_AC_wasCast_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_part_PR_in_RAT_got AS
SELECT
    a.Metadata_AC_part_PR_in_RAT_got,
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Who,
    a.AC_part_PR_in_RAT_got_Confidence,
    a.AC_part_PR_in_RAT_got_Stance,
    a.
FROM
    ties.AC_part_PR_in_RAT_got_Fact p
JOIN
    ties.AC_part_PR_in_RAT_got_Meta a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
WHERE
    a.AC_part_PR_in_RAT_got_Who = 0
AND
    a.AC_part_PR_in_RAT_got_PositedAt = (
        SELECT
            MAX(sub.AC_part_PR_in_RAT_got_PositedAt)
        FROM
            ties.AC_part_PR_in_RAT_got_Meta sub
        WHERE
            sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
        AND
            sub.AC_part_PR_in_RAT_got_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rST_at_PR_isPlaying AS
SELECT
    a.Metadata_ST_at_PR_isPlaying,
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Who,
    a.ST_at_PR_isPlaying_Confidence,
    a.ST_at_PR_isPlaying_Stance,
    a.
FROM
    ties.ST_at_PR_isPlaying_Fact p
JOIN
    ties.ST_at_PR_isPlaying_Meta a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
WHERE
    a.ST_at_PR_isPlaying_Who = 0
AND
    a.ST_at_PR_isPlaying_PositedAt = (
        SELECT
            MAX(sub.ST_at_PR_isPlaying_PositedAt)
        FROM
            ties.ST_at_PR_isPlaying_Meta sub
        WHERE
            sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
        AND
            sub.ST_at_PR_isPlaying_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_parent_AC_child_PAT_having AS
SELECT
    a.Metadata_AC_parent_AC_child_PAT_having,
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Who,
    a.AC_parent_AC_child_PAT_having_Confidence,
    a.AC_parent_AC_child_PAT_having_Stance,
    a.
FROM
    ties.AC_parent_AC_child_PAT_having_Fact p
JOIN
    ties.AC_parent_AC_child_PAT_having_Meta a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
WHERE
    a.AC_parent_AC_child_PAT_having_Who = 0
AND
    a.AC_parent_AC_child_PAT_having_PositedAt = (
        SELECT
            MAX(sub.AC_parent_AC_child_PAT_having_PositedAt)
        FROM
            ties.AC_parent_AC_child_PAT_having_Meta sub
        WHERE
            sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
        AND
            sub.AC_parent_AC_child_PAT_having_Who = 0
    )
;
CREATE OR REPLACE VIEW ties.rPR_content_ST_location_EV_of AS
SELECT
    a.Metadata_PR_content_ST_location_EV_of,
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    p.PR_content_ST_location_EV_of_ChangedAt,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Who,
    a.PR_content_ST_location_EV_of_Confidence,
    a.PR_content_ST_location_EV_of_Stance,
    a.
FROM
    ties.PR_content_ST_location_EV_of_Fact p
JOIN
    ties.PR_content_ST_location_EV_of_Meta a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
WHERE
    a.PR_content_ST_location_EV_of_Who = 0
AND
    a.PR_content_ST_location_EV_of_PositedAt = (
        SELECT
            MAX(sub.PR_content_ST_location_EV_of_PositedAt)
        FROM
            ties.PR_content_ST_location_EV_of_Meta sub
        WHERE
            sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
        AND
            sub.PR_content_ST_location_EV_of_Who = 0
    )
;
