-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the
-- now perspectives take none, and are views over the rewinder of the tie (a view that shows the latest annex row of every
-- posit for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" AS
SELECT
    t."AC_partner_AC_with_ONG_currently_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_partner"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_with"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_partner_AC_with_ONG_currently_Assertion" <> '?' THEN r."AC_partner_AC_with_ONG_currently_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently"
            ) AS "inEffect"
        FROM
            ties."rAC_partner_AC_with_ONG_currently" r
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = '+'
    AND
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
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
    t."AC_partner_AC_with_ONG_currently_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_partner"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_with"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_partner_AC_with_ONG_currently_Assertion" <> '?' THEN r."AC_partner_AC_with_ONG_currently_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently"
            ) AS "inEffect"
        FROM
            ties."rAC_partner_AC_with_ONG_currently" r
        WHERE
            r."AC_partner_AC_with_ONG_currently_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = '+'
    AND
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
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
    t."AC_subset_PN_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."AC_ID_subset"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."PN_ID_of"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM (
        SELECT
            r.*
        FROM
            ties."rAC_subset_PN_of" r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = '+'
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    t."AC_subset_PN_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."AC_ID_subset"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."PN_ID_of"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM (
        SELECT
            r.*
        FROM
            ties."rAC_subset_PN_of" r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = '+'
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" AS
SELECT
    t."EV_in_AC_rollsattes_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Positor",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_in_AC_rollsattes_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_rollsattes_Positor",
                s."EV_ID_in",
                s."AC_ID_rollsattes"
            ORDER BY
                s."EV_in_AC_rollsattes_PositedAt" DESC,
                s."EV_in_AC_rollsattes_Reliability" DESC,
                s."EV_in_AC_rollsattes_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            ties."rEV_in_AC_rollsattes" r
    ) s
    WHERE
        s."EV_in_AC_rollsattes_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" AS
SELECT
    t."EV_in_AC_rollsattes_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_ID_in",
    t."AC_ID_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Positor",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_in_AC_rollsattes_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_rollsattes_Positor",
                s."EV_ID_in",
                s."AC_ID_rollsattes"
            ORDER BY
                s."EV_in_AC_rollsattes_PositedAt" DESC,
                s."EV_in_AC_rollsattes_Reliability" DESC,
                s."EV_in_AC_rollsattes_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            ties."rEV_in_AC_rollsattes" r
    ) s
    WHERE
        s."EV_in_AC_rollsattes_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" AS
SELECT
    t."AC_deltar_PR_in_RAT_fick_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_deltar_PR_in_RAT_fick_Positor",
                s."AC_ID_deltar",
                s."PR_ID_in"
            ORDER BY
                s."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC,
                s."AC_deltar_PR_in_RAT_fick_PositedAt" DESC,
                s."AC_deltar_PR_in_RAT_fick_Reliability" DESC,
                s."AC_deltar_PR_in_RAT_fick_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_deltar_PR_in_RAT_fick_Assertion" <> '?' THEN r."AC_deltar_PR_in_RAT_fick_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_deltar_PR_in_RAT_fick_Positor",
                    r."AC_ID_deltar",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            ties."rAC_deltar_PR_in_RAT_fick" r
    ) s
    WHERE
        s."AC_deltar_PR_in_RAT_fick_Assertion" = '+'
    AND
        s."AC_deltar_PR_in_RAT_fick_ChangedAt" = s."inEffect"
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
    t."AC_deltar_PR_in_RAT_fick_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Checksum" AS "fick_RAT_Checksum",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Positor",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_deltar_PR_in_RAT_fick_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_deltar_PR_in_RAT_fick_Positor",
                s."AC_ID_deltar",
                s."PR_ID_in"
            ORDER BY
                s."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC,
                s."AC_deltar_PR_in_RAT_fick_PositedAt" DESC,
                s."AC_deltar_PR_in_RAT_fick_Reliability" DESC,
                s."AC_deltar_PR_in_RAT_fick_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_deltar_PR_in_RAT_fick_Assertion" <> '?' THEN r."AC_deltar_PR_in_RAT_fick_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_deltar_PR_in_RAT_fick_Positor",
                    r."AC_ID_deltar",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            ties."rAC_deltar_PR_in_RAT_fick" r
        WHERE
            r."AC_deltar_PR_in_RAT_fick_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."AC_deltar_PR_in_RAT_fick_Assertion" = '+'
    AND
        s."AC_deltar_PR_in_RAT_fick_ChangedAt" = s."inEffect"
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
    t."ST_at_PR_spelas_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_spelas_Positor",
                s."ST_ID_at",
                s."PR_ID_spelas"
            ORDER BY
                s."ST_at_PR_spelas_ChangedAt" DESC,
                s."ST_at_PR_spelas_PositedAt" DESC,
                s."ST_at_PR_spelas_Reliability" DESC,
                s."ST_at_PR_spelas_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_spelas_Assertion" <> '?' THEN r."ST_at_PR_spelas_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_spelas_Positor",
                    r."ST_ID_at",
                    r."PR_ID_spelas"
            ) AS "inEffect"
        FROM
            ties."rST_at_PR_spelas" r
    ) s
    WHERE
        s."ST_at_PR_spelas_Assertion" = '+'
    AND
        s."ST_at_PR_spelas_ChangedAt" = s."inEffect"
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" AS
SELECT
    t."ST_at_PR_spelas_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_ST_at_PR_spelas",
    t."ST_ID_at",
    t."PR_ID_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Positor",
    t."ST_at_PR_spelas_Reliability",
    t."ST_at_PR_spelas_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_spelas_Positor",
                s."ST_ID_at",
                s."PR_ID_spelas"
            ORDER BY
                s."ST_at_PR_spelas_ChangedAt" DESC,
                s."ST_at_PR_spelas_PositedAt" DESC,
                s."ST_at_PR_spelas_Reliability" DESC,
                s."ST_at_PR_spelas_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_spelas_Assertion" <> '?' THEN r."ST_at_PR_spelas_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_spelas_Positor",
                    r."ST_ID_at",
                    r."PR_ID_spelas"
            ) AS "inEffect"
        FROM
            ties."rST_at_PR_spelas" r
        WHERE
            r."ST_at_PR_spelas_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."ST_at_PR_spelas_Assertion" = '+'
    AND
        s."ST_at_PR_spelas_ChangedAt" = s."inEffect"
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" AS
SELECT
    t."AC_förälder_AC_barn_PAT_har_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Positor",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_förälder_AC_barn_PAT_har_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_förälder_AC_barn_PAT_har_Positor",
                s."AC_ID_förälder",
                s."AC_ID_barn",
                s."PAT_ID_har"
            ORDER BY
                s."AC_förälder_AC_barn_PAT_har_PositedAt" DESC,
                s."AC_förälder_AC_barn_PAT_har_Reliability" DESC,
                s."AC_förälder_AC_barn_PAT_har_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            ties."rAC_förälder_AC_barn_PAT_har" r
    ) s
    WHERE
        s."AC_förälder_AC_barn_PAT_har_Assertion" = '+'
) t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" AS
SELECT
    t."AC_förälder_AC_barn_PAT_har_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Positor",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_förälder_AC_barn_PAT_har_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_förälder_AC_barn_PAT_har_Positor",
                s."AC_ID_förälder",
                s."AC_ID_barn",
                s."PAT_ID_har"
            ORDER BY
                s."AC_förälder_AC_barn_PAT_har_PositedAt" DESC,
                s."AC_förälder_AC_barn_PAT_har_Reliability" DESC,
                s."AC_förälder_AC_barn_PAT_har_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            ties."rAC_förälder_AC_barn_PAT_har" r
    ) s
    WHERE
        s."AC_förälder_AC_barn_PAT_har_Assertion" = '+'
) t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" AS
SELECT
    t."PR_innehåll_ST_plats_EV_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."PR_innehåll_ST_plats_EV_of_Positor", s."PR_ID_innehåll"
            ORDER BY
                s."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_Reliability" DESC,
                s."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY s."PR_innehåll_ST_plats_EV_of_Positor", s."ST_ID_plats"
            ORDER BY
                s."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_Reliability" DESC,
                s."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestST_ID_plats"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_innehåll_ST_plats_EV_of_Assertion" <> '?' THEN r."PR_innehåll_ST_plats_EV_of_ChangedAt" END) OVER (
                PARTITION BY
                    r."PR_innehåll_ST_plats_EV_of_Positor",
                    r."PR_ID_innehåll",
                    r."ST_ID_plats",
                    r."EV_ID_of"
            ) AS "inEffect"
        FROM
            ties."rPR_innehåll_ST_plats_EV_of" r
    ) s
    WHERE
        s."PR_innehåll_ST_plats_EV_of_Assertion" = '+'
    AND
        s."PR_innehåll_ST_plats_EV_of_ChangedAt" = s."inEffect"
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
;
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" AS
SELECT
    t."PR_innehåll_ST_plats_EV_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Positor",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_innehåll_ST_plats_EV_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."PR_innehåll_ST_plats_EV_of_Positor", s."PR_ID_innehåll"
            ORDER BY
                s."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_Reliability" DESC,
                s."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY s."PR_innehåll_ST_plats_EV_of_Positor", s."ST_ID_plats"
            ORDER BY
                s."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                s."PR_innehåll_ST_plats_EV_of_Reliability" DESC,
                s."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestST_ID_plats"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_innehåll_ST_plats_EV_of_Assertion" <> '?' THEN r."PR_innehåll_ST_plats_EV_of_ChangedAt" END) OVER (
                PARTITION BY
                    r."PR_innehåll_ST_plats_EV_of_Positor",
                    r."PR_ID_innehåll",
                    r."ST_ID_plats",
                    r."EV_ID_of"
            ) AS "inEffect"
        FROM
            ties."rPR_innehåll_ST_plats_EV_of" r
        WHERE
            r."PR_innehåll_ST_plats_EV_of_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."PR_innehåll_ST_plats_EV_of_Assertion" = '+'
    AND
        s."PR_innehåll_ST_plats_EV_of_ChangedAt" = s."inEffect"
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
;
