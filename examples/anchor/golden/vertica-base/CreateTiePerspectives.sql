-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Uni-temporal tie perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the
-- perspectives that take a time (point-in-time and difference) are not made; the latest and the now perspectives take
-- none, and are views. The latest shows the version with the latest changing time of every historized tie, which may be in
-- the future; the now shows the latest that is not.
--
CREATE OR REPLACE VIEW public."lAC_partner_AC_with_ONG_currently" AS
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_with"
    FROM
        public."AC_partner_AC_with_ONG_currently" r
) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW public."nAC_partner_AC_with_ONG_currently" AS
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC
        ) AS "latestAC_ID_with"
    FROM
        public."AC_partner_AC_with_ONG_currently" r
    WHERE
        r."AC_partner_AC_with_ONG_currently_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW public."lAC_subset_PN_of" AS
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    public."AC_subset_PN_of" t
;
CREATE OR REPLACE VIEW public."nAC_subset_PN_of" AS
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    public."AC_subset_PN_of" t
;
CREATE OR REPLACE VIEW public."lEV_in_AC_wasCast" AS
SELECT
    t."Metadata_EV_in_AC_wasCast",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM
    public."EV_in_AC_wasCast" t
;
CREATE OR REPLACE VIEW public."nEV_in_AC_wasCast" AS
SELECT
    t."Metadata_EV_in_AC_wasCast",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM
    public."EV_in_AC_wasCast" t
;
CREATE OR REPLACE VIEW public."lAC_part_PR_in_RAT_got" AS
SELECT
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_part",
                r."PR_ID_in"
            ORDER BY
                r."AC_part_PR_in_RAT_got_ChangedAt" DESC
        ) AS "latest"
    FROM
        public."AC_part_PR_in_RAT_got" r
) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nAC_part_PR_in_RAT_got" AS
SELECT
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_part",
                r."PR_ID_in"
            ORDER BY
                r."AC_part_PR_in_RAT_got_ChangedAt" DESC
        ) AS "latest"
    FROM
        public."AC_part_PR_in_RAT_got" r
    WHERE
        r."AC_part_PR_in_RAT_got_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lST_at_PR_isPlaying" AS
SELECT
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_isPlaying"
            ORDER BY
                r."ST_at_PR_isPlaying_ChangedAt" DESC
        ) AS "latest"
    FROM
        public."ST_at_PR_isPlaying" r
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nST_at_PR_isPlaying" AS
SELECT
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_isPlaying"
            ORDER BY
                r."ST_at_PR_isPlaying_ChangedAt" DESC
        ) AS "latest"
    FROM
        public."ST_at_PR_isPlaying" r
    WHERE
        r."ST_at_PR_isPlaying_ChangedAt" <= current_timestamp::timestamp
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lAC_parent_AC_child_PAT_having" AS
SELECT
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having"
FROM
    public."AC_parent_AC_child_PAT_having" t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
;
CREATE OR REPLACE VIEW public."nAC_parent_AC_child_PAT_having" AS
SELECT
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having"
FROM
    public."AC_parent_AC_child_PAT_having" t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
;
CREATE OR REPLACE VIEW public."lPR_content_ST_location_EV_of" AS
SELECT
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM
    public."PR_content_ST_location_EV_of" t
;
CREATE OR REPLACE VIEW public."nPR_content_ST_location_EV_of" AS
SELECT
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM
    public."PR_content_ST_location_EV_of" t
;
