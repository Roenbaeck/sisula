-- TIE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views for ties.
--
CREATE OR REPLACE VIEW public.rAC_partner_AC_with_ONG_currently AS
SELECT
    p.AC_partner_AC_with_ONG_currently_ID,
    p.AC_ID_partner,
    p.AC_ID_with,
    p.ONG_ID_currently,
    p.AC_partner_AC_with_ONG_currently_ChangedAt,
    a.AC_partner_AC_with_ONG_currently_PositedAt,
    a.AC_partner_AC_with_ONG_currently_Positor,
    a.AC_partner_AC_with_ONG_currently_Reliability,
    a.AC_partner_AC_with_ONG_currently_Assertion,
    a.
FROM
    public.AC_partner_AC_with_ONG_currently_Posit p
JOIN
    public.AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
WHERE
    a.AC_partner_AC_with_ONG_currently_Positor = 0
AND
    a.AC_partner_AC_with_ONG_currently_PositedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_PositedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently_Annex sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
        AND
            sub.AC_partner_AC_with_ONG_currently_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_subset_PN_of AS
SELECT
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion,
    a.
FROM
    public.AC_subset_PN_of_Posit p
JOIN
    public.AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
WHERE
    a.AC_subset_PN_of_Positor = 0
AND
    a.AC_subset_PN_of_PositedAt = (
        SELECT
            MAX(sub.AC_subset_PN_of_PositedAt)
        FROM
            public.AC_subset_PN_of_Annex sub
        WHERE
            sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
        AND
            sub.AC_subset_PN_of_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rEV_in_AC_wasCast AS
SELECT
    p.EV_in_AC_wasCast_ID,
    p.EV_ID_in,
    p.AC_ID_wasCast,
    a.EV_in_AC_wasCast_PositedAt,
    a.EV_in_AC_wasCast_Positor,
    a.EV_in_AC_wasCast_Reliability,
    a.EV_in_AC_wasCast_Assertion,
    a.
FROM
    public.EV_in_AC_wasCast_Posit p
JOIN
    public.EV_in_AC_wasCast_Annex a
ON
    a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
WHERE
    a.EV_in_AC_wasCast_Positor = 0
AND
    a.EV_in_AC_wasCast_PositedAt = (
        SELECT
            MAX(sub.EV_in_AC_wasCast_PositedAt)
        FROM
            public.EV_in_AC_wasCast_Annex sub
        WHERE
            sub.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
        AND
            sub.EV_in_AC_wasCast_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_part_PR_in_RAT_got AS
SELECT
    p.AC_part_PR_in_RAT_got_ID,
    p.AC_ID_part,
    p.PR_ID_in,
    p.RAT_ID_got,
    p.AC_part_PR_in_RAT_got_ChangedAt,
    a.AC_part_PR_in_RAT_got_PositedAt,
    a.AC_part_PR_in_RAT_got_Positor,
    a.AC_part_PR_in_RAT_got_Reliability,
    a.AC_part_PR_in_RAT_got_Assertion,
    a.
FROM
    public.AC_part_PR_in_RAT_got_Posit p
JOIN
    public.AC_part_PR_in_RAT_got_Annex a
ON
    a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
WHERE
    a.AC_part_PR_in_RAT_got_Positor = 0
AND
    a.AC_part_PR_in_RAT_got_PositedAt = (
        SELECT
            MAX(sub.AC_part_PR_in_RAT_got_PositedAt)
        FROM
            public.AC_part_PR_in_RAT_got_Annex sub
        WHERE
            sub.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
        AND
            sub.AC_part_PR_in_RAT_got_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rST_at_PR_isPlaying AS
SELECT
    p.ST_at_PR_isPlaying_ID,
    p.ST_ID_at,
    p.PR_ID_isPlaying,
    p.ST_at_PR_isPlaying_ChangedAt,
    a.ST_at_PR_isPlaying_PositedAt,
    a.ST_at_PR_isPlaying_Positor,
    a.ST_at_PR_isPlaying_Reliability,
    a.ST_at_PR_isPlaying_Assertion,
    a.
FROM
    public.ST_at_PR_isPlaying_Posit p
JOIN
    public.ST_at_PR_isPlaying_Annex a
ON
    a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
WHERE
    a.ST_at_PR_isPlaying_Positor = 0
AND
    a.ST_at_PR_isPlaying_PositedAt = (
        SELECT
            MAX(sub.ST_at_PR_isPlaying_PositedAt)
        FROM
            public.ST_at_PR_isPlaying_Annex sub
        WHERE
            sub.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
        AND
            sub.ST_at_PR_isPlaying_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rAC_parent_AC_child_PAT_having AS
SELECT
    p.AC_parent_AC_child_PAT_having_ID,
    p.AC_ID_parent,
    p.AC_ID_child,
    p.PAT_ID_having,
    a.AC_parent_AC_child_PAT_having_PositedAt,
    a.AC_parent_AC_child_PAT_having_Positor,
    a.AC_parent_AC_child_PAT_having_Reliability,
    a.AC_parent_AC_child_PAT_having_Assertion,
    a.
FROM
    public.AC_parent_AC_child_PAT_having_Posit p
JOIN
    public.AC_parent_AC_child_PAT_having_Annex a
ON
    a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
WHERE
    a.AC_parent_AC_child_PAT_having_Positor = 0
AND
    a.AC_parent_AC_child_PAT_having_PositedAt = (
        SELECT
            MAX(sub.AC_parent_AC_child_PAT_having_PositedAt)
        FROM
            public.AC_parent_AC_child_PAT_having_Annex sub
        WHERE
            sub.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
        AND
            sub.AC_parent_AC_child_PAT_having_Positor = 0
    )
;
CREATE OR REPLACE VIEW public.rPR_content_ST_location_EV_of AS
SELECT
    p.PR_content_ST_location_EV_of_ID,
    p.PR_ID_content,
    p.ST_ID_location,
    p.EV_ID_of,
    a.PR_content_ST_location_EV_of_PositedAt,
    a.PR_content_ST_location_EV_of_Positor,
    a.PR_content_ST_location_EV_of_Reliability,
    a.PR_content_ST_location_EV_of_Assertion,
    a.
FROM
    public.PR_content_ST_location_EV_of_Posit p
JOIN
    public.PR_content_ST_location_EV_of_Annex a
ON
    a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
WHERE
    a.PR_content_ST_location_EV_of_Positor = 0
AND
    a.PR_content_ST_location_EV_of_PositedAt = (
        SELECT
            MAX(sub.PR_content_ST_location_EV_of_PositedAt)
        FROM
            public.PR_content_ST_location_EV_of_Annex sub
        WHERE
            sub.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
        AND
            sub.PR_content_ST_location_EV_of_Positor = 0
    )
;
