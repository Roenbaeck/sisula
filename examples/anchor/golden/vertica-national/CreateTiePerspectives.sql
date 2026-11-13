-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- Uni-temporal tie perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the
-- perspectives that take a time (point-in-time and difference) are not made; the latest and the now perspectives take
-- none, and are views. The latest shows the version with the latest changing time of every historized tie, which may be in
-- the future; the now shows the latest that is not.
--
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" AS
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
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
        ties."AC_partner_AC_with_ONG_currently" r
) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
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
        ties."AC_partner_AC_with_ONG_currently" r
    WHERE
        r."AC_partner_AC_with_ONG_currently_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" AS
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    ties."AC_subset_PN_of" t
;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    ties."AC_subset_PN_of" t
;
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" AS
SELECT
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" t
;
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" AS
SELECT
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM
    ties."EV_in_AC_rollsattes" t
;
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" AS
SELECT
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_deltar",
                r."PR_ID_in"
            ORDER BY
                r."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."AC_deltar_PR_in_RAT_fick" r
) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" AS
SELECT
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_deltar",
                r."PR_ID_in"
            ORDER BY
                r."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."AC_deltar_PR_in_RAT_fick" r
    WHERE
        r."AC_deltar_PR_in_RAT_fick_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" AS
SELECT
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_spelas"
            ORDER BY
                r."ST_at_PR_spelas_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."ST_at_PR_spelas" r
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" AS
SELECT
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest version for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_spelas"
            ORDER BY
                r."ST_at_PR_spelas_ChangedAt" DESC
        ) AS "latest"
    FROM
        ties."ST_at_PR_spelas" r
    WHERE
        r."ST_at_PR_spelas_ChangedAt" <= current_timestamp::timestamp
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" AS
SELECT
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
;
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" AS
SELECT
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har"
FROM
    ties."AC_förälder_AC_barn_PAT_har" t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
;
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" AS
SELECT
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_innehåll"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY r."ST_ID_plats"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestST_ID_plats"
    FROM
        ties."PR_innehåll_ST_plats_EV_of" r
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
;
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" AS
SELECT
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
(
    -- the latest version, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest version for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_innehåll"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY r."ST_ID_plats"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC
        ) AS "latestST_ID_plats"
    FROM
        ties."PR_innehåll_ST_plats_EV_of" r
    WHERE
        r."PR_innehåll_ST_plats_EV_of_ChangedAt" <= current_timestamp::timestamp
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
;
