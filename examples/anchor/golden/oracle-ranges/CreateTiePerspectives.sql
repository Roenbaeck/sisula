-- TIE PERSPECTIVES ---------------------------------------------------------------------------------------------------
--
-- Oracle latest (l) and now (n) perspectives.
--
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE (
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently sub
        WHERE
            (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
            OR
                sub.ONG_ID_currently = tie.ONG_ID_currently
            )
    )
    OR tie.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    ties.lAC_partner_AC_with_ONG_currently
;
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    ties.AC_subset_PN_of tie
;

CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    *
FROM
    ties.lAC_subset_PN_of
;
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast AS
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    ties.EV_in_AC_wasCast tie
;

CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    ties.lEV_in_AC_wasCast
;
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS got_RAT_Rating,
    RAT_got.Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    ties.AC_part_PR_in_RAT_got tie
LEFT JOIN
    knots.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE (
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            MAX(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            ties.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
    )
    OR tie.AC_part_PR_in_RAT_got_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    ties.lAC_part_PR_in_RAT_got
;
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    ties.ST_at_PR_isPlaying tie
WHERE (
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            MAX(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            ties.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
    )
    OR tie.ST_at_PR_isPlaying_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    ties.lST_at_PR_isPlaying
;
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    PAT_having.Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    ties.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    knots.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;

CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    ties.lAC_parent_AC_child_PAT_having
;
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of AS
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_content_ST_location_EV_of_ChangedAt,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    ties.PR_content_ST_location_EV_of tie
WHERE (
    tie.PR_content_ST_location_EV_of_ChangedAt = (
        SELECT
            MAX(sub.PR_content_ST_location_EV_of_ChangedAt)
        FROM
            ties.PR_content_ST_location_EV_of sub
        WHERE
            (
                sub.PR_ID_content = tie.PR_ID_content
            OR
                sub.ST_ID_location = tie.ST_ID_location
            OR
                sub.EV_ID_of = tie.EV_ID_of
            )
    )
    OR tie.PR_content_ST_location_EV_of_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    ties.lPR_content_ST_location_EV_of
;
