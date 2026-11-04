-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the
-- now perspectives take none, and are views over the rewinder of the tie (a view that shows the latest annex row of every
-- posit for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW public."lAC_partner_AC_with_ONG_currently" AS
SELECT
    t."AC_partner_AC_with_ONG_currently_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "ONG_Ongoing",
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
            public."rAC_partner_AC_with_ONG_currently" r
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = '+'
    AND
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
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
    t."AC_partner_AC_with_ONG_currently_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "ONG_Ongoing",
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
            public."rAC_partner_AC_with_ONG_currently" r
        WHERE
            r."AC_partner_AC_with_ONG_currently_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = '+'
    AND
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
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
    t."AC_subset_PN_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
            public."rAC_subset_PN_of" r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = '+'
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW public."nAC_subset_PN_of" AS
SELECT
    t."AC_subset_PN_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
            public."rAC_subset_PN_of" r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = '+'
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW public."lEV_in_AC_wasCast" AS
SELECT
    t."EV_in_AC_wasCast_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_wasCast_Positor",
                s."EV_ID_in",
                s."AC_ID_wasCast"
            ORDER BY
                s."EV_in_AC_wasCast_PositedAt" DESC,
                s."EV_in_AC_wasCast_Reliability" DESC,
                s."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_in_AC_wasCast" r
    ) s
    WHERE
        s."EV_in_AC_wasCast_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nEV_in_AC_wasCast" AS
SELECT
    t."EV_in_AC_wasCast_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_wasCast_Positor",
                s."EV_ID_in",
                s."AC_ID_wasCast"
            ORDER BY
                s."EV_in_AC_wasCast_PositedAt" DESC,
                s."EV_in_AC_wasCast_Reliability" DESC,
                s."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_in_AC_wasCast" r
    ) s
    WHERE
        s."EV_in_AC_wasCast_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lAC_part_PR_in_RAT_got" AS
SELECT
    t."AC_part_PR_in_RAT_got_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "RAT_Rating",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_part_PR_in_RAT_got_Positor",
                s."AC_ID_part",
                s."PR_ID_in"
            ORDER BY
                s."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                s."AC_part_PR_in_RAT_got_PositedAt" DESC,
                s."AC_part_PR_in_RAT_got_Reliability" DESC,
                s."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_part_PR_in_RAT_got_Assertion" <> '?' THEN r."AC_part_PR_in_RAT_got_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            public."rAC_part_PR_in_RAT_got" r
    ) s
    WHERE
        s."AC_part_PR_in_RAT_got_Assertion" = '+'
    AND
        s."AC_part_PR_in_RAT_got_ChangedAt" = s."inEffect"
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
    t."AC_part_PR_in_RAT_got_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "RAT_Rating",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_part_PR_in_RAT_got_Positor",
                s."AC_ID_part",
                s."PR_ID_in"
            ORDER BY
                s."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                s."AC_part_PR_in_RAT_got_PositedAt" DESC,
                s."AC_part_PR_in_RAT_got_Reliability" DESC,
                s."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_part_PR_in_RAT_got_Assertion" <> '?' THEN r."AC_part_PR_in_RAT_got_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            public."rAC_part_PR_in_RAT_got" r
        WHERE
            r."AC_part_PR_in_RAT_got_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."AC_part_PR_in_RAT_got_Assertion" = '+'
    AND
        s."AC_part_PR_in_RAT_got_ChangedAt" = s."inEffect"
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
    t."ST_at_PR_isPlaying_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_isPlaying_Positor",
                s."ST_ID_at",
                s."PR_ID_isPlaying"
            ORDER BY
                s."ST_at_PR_isPlaying_ChangedAt" DESC,
                s."ST_at_PR_isPlaying_PositedAt" DESC,
                s."ST_at_PR_isPlaying_Reliability" DESC,
                s."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_isPlaying_Assertion" <> '?' THEN r."ST_at_PR_isPlaying_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying"
            ) AS "inEffect"
        FROM
            public."rST_at_PR_isPlaying" r
    ) s
    WHERE
        s."ST_at_PR_isPlaying_Assertion" = '+'
    AND
        s."ST_at_PR_isPlaying_ChangedAt" = s."inEffect"
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nST_at_PR_isPlaying" AS
SELECT
    t."ST_at_PR_isPlaying_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_isPlaying_Positor",
                s."ST_ID_at",
                s."PR_ID_isPlaying"
            ORDER BY
                s."ST_at_PR_isPlaying_ChangedAt" DESC,
                s."ST_at_PR_isPlaying_PositedAt" DESC,
                s."ST_at_PR_isPlaying_Reliability" DESC,
                s."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_isPlaying_Assertion" <> '?' THEN r."ST_at_PR_isPlaying_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying"
            ) AS "inEffect"
        FROM
            public."rST_at_PR_isPlaying" r
        WHERE
            r."ST_at_PR_isPlaying_ChangedAt" <= current_timestamp::timestamp
    ) s
    WHERE
        s."ST_at_PR_isPlaying_Assertion" = '+'
    AND
        s."ST_at_PR_isPlaying_ChangedAt" = s."inEffect"
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lAC_parent_AC_child_PAT_having" AS
SELECT
    t."AC_parent_AC_child_PAT_having_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "PAT_ParentalType",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_parent_AC_child_PAT_having_Positor",
                s."AC_ID_parent",
                s."AC_ID_child",
                s."PAT_ID_having"
            ORDER BY
                s."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                s."AC_parent_AC_child_PAT_having_Reliability" DESC,
                s."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_parent_AC_child_PAT_having" r
    ) s
    WHERE
        s."AC_parent_AC_child_PAT_having_Assertion" = '+'
) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nAC_parent_AC_child_PAT_having" AS
SELECT
    t."AC_parent_AC_child_PAT_having_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "PAT_ParentalType",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_parent_AC_child_PAT_having_Positor",
                s."AC_ID_parent",
                s."AC_ID_child",
                s."PAT_ID_having"
            ORDER BY
                s."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                s."AC_parent_AC_child_PAT_having_Reliability" DESC,
                s."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_parent_AC_child_PAT_having" r
    ) s
    WHERE
        s."AC_parent_AC_child_PAT_having_Assertion" = '+'
) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."lPR_content_ST_location_EV_of" AS
SELECT
    t."PR_content_ST_location_EV_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."PR_content_ST_location_EV_of_Positor",
                s."EV_ID_of"
            ORDER BY
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Reliability" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_content_ST_location_EV_of" r
    ) s
    WHERE
        s."PR_content_ST_location_EV_of_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW public."nPR_content_ST_location_EV_of" AS
SELECT
    t."PR_content_ST_location_EV_of_Positor" AS "Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM (
    -- the posit in effect for each of the identifiers and positor, picked by a window and kept by the filter outside it
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."PR_content_ST_location_EV_of_Positor",
                s."EV_ID_of"
            ORDER BY
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Reliability" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_content_ST_location_EV_of" r
    ) s
    WHERE
        s."PR_content_ST_location_EV_of_Assertion" = '+'
) t
WHERE
    t."latest" = 1
;
