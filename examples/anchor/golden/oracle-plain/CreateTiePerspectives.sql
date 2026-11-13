-- TIE PERSPECTIVES ---------------------------------------------------------------------------------------------------
--
-- Oracle latest (l) and now (n) perspectives.
--
CREATE OR REPLACE VIEW public.lAC_partner_AC_with_ONG_currently AS
SELECT
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Ongoing AS ONG_Ongoing,
    tie.ONG_ID_currently
FROM
    public.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    public.ONG_Ongoing ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE (
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            public.AC_partner_AC_with_ONG_currently sub
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

CREATE OR REPLACE VIEW public.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    public.lAC_partner_AC_with_ONG_currently
;
CREATE OR REPLACE VIEW public.lAC_subset_PN_of AS
SELECT
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    public.AC_subset_PN_of tie
;

CREATE OR REPLACE VIEW public.nAC_subset_PN_of AS
SELECT
    *
FROM
    public.lAC_subset_PN_of
;
CREATE OR REPLACE VIEW public.lEV_in_AC_wasCast AS
SELECT
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    public.EV_in_AC_wasCast tie
;

CREATE OR REPLACE VIEW public.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    public.lEV_in_AC_wasCast
;
CREATE OR REPLACE VIEW public.lAC_part_PR_in_RAT_got AS
SELECT
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    RAT_got.RAT_Rating AS RAT_Rating,
    tie.RAT_ID_got
FROM
    public.AC_part_PR_in_RAT_got tie
LEFT JOIN
    public.RAT_Rating RAT_got
ON
    RAT_got.RAT_ID = tie.RAT_ID_got
WHERE (
    tie.AC_part_PR_in_RAT_got_ChangedAt = (
        SELECT
            MAX(sub.AC_part_PR_in_RAT_got_ChangedAt)
        FROM
            public.AC_part_PR_in_RAT_got sub
        WHERE
            sub.AC_ID_part = tie.AC_ID_part
        AND
            sub.PR_ID_in = tie.PR_ID_in
    )
    OR tie.AC_part_PR_in_RAT_got_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    public.lAC_part_PR_in_RAT_got
;
CREATE OR REPLACE VIEW public.lST_at_PR_isPlaying AS
SELECT
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    public.ST_at_PR_isPlaying tie
WHERE (
    tie.ST_at_PR_isPlaying_ChangedAt = (
        SELECT
            MAX(sub.ST_at_PR_isPlaying_ChangedAt)
        FROM
            public.ST_at_PR_isPlaying sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_isPlaying = tie.PR_ID_isPlaying
    )
    OR tie.ST_at_PR_isPlaying_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW public.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    public.lST_at_PR_isPlaying
;
CREATE OR REPLACE VIEW public.lAC_parent_AC_child_PAT_having AS
SELECT
    tie.AC_ID_parent,
    tie.AC_ID_child,
    PAT_having.PAT_ParentalType AS PAT_ParentalType,
    tie.PAT_ID_having
FROM
    public.AC_parent_AC_child_PAT_having tie
LEFT JOIN
    public.PAT_ParentalType PAT_having
ON
    PAT_having.PAT_ID = tie.PAT_ID_having
;

CREATE OR REPLACE VIEW public.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    public.lAC_parent_AC_child_PAT_having
;
CREATE OR REPLACE VIEW public.lPR_content_ST_location_EV_of AS
SELECT
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    public.PR_content_ST_location_EV_of tie
;

CREATE OR REPLACE VIEW public.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    public.lPR_content_ST_location_EV_of
;
