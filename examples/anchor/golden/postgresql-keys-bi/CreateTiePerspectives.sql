-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM
        public."rAC_partner_AC_with_ONG_currently"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_partner_AC_with_ONG_currently_Reliability" = 1
) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    public."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    public."tAC_partner_AC_with_ONG_currently"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    public."tAC_partner_AC_with_ONG_currently"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    public."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tAC_subset_PN_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_subset_PN_of_ID" integer,
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_ID_subset" integer,
    "PN_ID_of" integer
)
AS
$$
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Reliability",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_subset"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY r."PN_ID_of"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM
        public."rAC_subset_PN_of"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_subset_PN_of_Reliability" = 1
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lAC_subset_PN_of" AS
SELECT
    *
FROM
    public."tAC_subset_PN_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pAC_subset_PN_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_subset_PN_of_ID" integer,
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_ID_subset" integer,
    "PN_ID_of" integer
)
AS
$$
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Reliability",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    public."tAC_subset_PN_of"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nAC_subset_PN_of" AS
SELECT
    *
FROM
    public."tAC_subset_PN_of"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."tEV_in_AC_wasCast" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "EV_in_AC_wasCast_ID" integer,
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_ID_in" integer,
    "AC_ID_wasCast" integer
)
AS
$$
SELECT
    t."EV_in_AC_wasCast_ID",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."EV_ID_in",
                r."AC_ID_wasCast"
            ORDER BY
                r."EV_in_AC_wasCast_PositedAt" DESC,
                r."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM
        public."rEV_in_AC_wasCast"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_in_AC_wasCast_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lEV_in_AC_wasCast" AS
SELECT
    *
FROM
    public."tEV_in_AC_wasCast"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pEV_in_AC_wasCast" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_in_AC_wasCast_ID" integer,
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_ID_in" integer,
    "AC_ID_wasCast" integer
)
AS
$$
SELECT
    t."EV_in_AC_wasCast_ID",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM
    public."tEV_in_AC_wasCast"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nEV_in_AC_wasCast" AS
SELECT
    *
FROM
    public."tEV_in_AC_wasCast"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."tAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" integer,
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_part",
                r."PR_ID_in"
            ORDER BY
                r."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                r."AC_part_PR_in_RAT_got_PositedAt" DESC,
                r."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM
        public."rAC_part_PR_in_RAT_got"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_part_PR_in_RAT_got_Reliability" = 1
) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lAC_part_PR_in_RAT_got" AS
SELECT
    *
FROM
    public."tAC_part_PR_in_RAT_got"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" integer,
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
    t."RAT_ID_got"
FROM
    public."tAC_part_PR_in_RAT_got"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nAC_part_PR_in_RAT_got" AS
SELECT
    *
FROM
    public."tAC_part_PR_in_RAT_got"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" integer,
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint
)
AS
$$
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
    t."RAT_ID_got"
FROM
    public."tAC_part_PR_in_RAT_got"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tST_at_PR_isPlaying" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" integer,
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer
)
AS
$$
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_isPlaying"
            ORDER BY
                r."ST_at_PR_isPlaying_ChangedAt" DESC,
                r."ST_at_PR_isPlaying_PositedAt" DESC,
                r."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM
        public."rST_at_PR_isPlaying"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."ST_at_PR_isPlaying_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lST_at_PR_isPlaying" AS
SELECT
    *
FROM
    public."tST_at_PR_isPlaying"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pST_at_PR_isPlaying" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" integer,
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer
)
AS
$$
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM
    public."tST_at_PR_isPlaying"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nST_at_PR_isPlaying" AS
SELECT
    *
FROM
    public."tST_at_PR_isPlaying"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dST_at_PR_isPlaying" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" integer,
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer
)
AS
$$
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM
    public."tST_at_PR_isPlaying"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_parent_AC_child_PAT_having_ID" integer,
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_ID_parent" integer,
    "AC_ID_child" integer,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint
)
AS
$$
SELECT
    t."AC_parent_AC_child_PAT_having_ID",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_parent",
                r."AC_ID_child",
                r."PAT_ID_having"
            ORDER BY
                r."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                r."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM
        public."rAC_parent_AC_child_PAT_having"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_parent_AC_child_PAT_having_Reliability" = 1
) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lAC_parent_AC_child_PAT_having" AS
SELECT
    *
FROM
    public."tAC_parent_AC_child_PAT_having"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_parent_AC_child_PAT_having_ID" integer,
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_ID_parent" integer,
    "AC_ID_child" integer,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint
)
AS
$$
SELECT
    t."AC_parent_AC_child_PAT_having_ID",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    t."having_PAT_ParentalType",
    t."having_Metadata_PAT",
    t."PAT_ID_having"
FROM
    public."tAC_parent_AC_child_PAT_having"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nAC_parent_AC_child_PAT_having" AS
SELECT
    *
FROM
    public."tAC_parent_AC_child_PAT_having"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."tPR_content_ST_location_EV_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "PR_content_ST_location_EV_of_ID" integer,
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_ID_content" integer,
    "ST_ID_location" integer,
    "EV_ID_of" integer
)
AS
$$
SELECT
    t."PR_content_ST_location_EV_of_ID",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."EV_ID_of"
            ORDER BY
                r."PR_content_ST_location_EV_of_PositedAt" DESC,
                r."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latest"
    FROM
        public."rPR_content_ST_location_EV_of"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."PR_content_ST_location_EV_of_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lPR_content_ST_location_EV_of" AS
SELECT
    *
FROM
    public."tPR_content_ST_location_EV_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_content_ST_location_EV_of_ID" integer,
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_ID_content" integer,
    "ST_ID_location" integer,
    "EV_ID_of" integer
)
AS
$$
SELECT
    t."PR_content_ST_location_EV_of_ID",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM
    public."tPR_content_ST_location_EV_of"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nPR_content_ST_location_EV_of" AS
SELECT
    *
FROM
    public."tPR_content_ST_location_EV_of"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
