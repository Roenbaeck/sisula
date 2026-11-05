-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    t."SU_holder_OB_item_GRD_grade_ID",
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_ID_holder",
    t."OB_ID_item",
    "kGRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "kGRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    t."GRD_ID_grade"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."SU_ID_holder",
                r."OB_ID_item"
            ORDER BY
                r."SU_holder_OB_item_GRD_grade_ChangedAt" DESC,
                r."SU_holder_OB_item_GRD_grade_PositedAt" DESC,
                r."SU_holder_OB_item_GRD_grade_ID" DESC
        ) AS "latest"
    FROM
        public."rSU_holder_OB_item_GRD_grade"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_holder_OB_item_GRD_grade_Reliability" = 1
) t
LEFT JOIN
    public."GRD_Grade" "kGRD_grade"
ON
    "kGRD_grade"."GRD_ID" = t."GRD_ID_grade"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_holder_OB_item_GRD_grade" AS
SELECT
    *
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    t."SU_holder_OB_item_GRD_grade_ID",
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_ID_holder",
    t."OB_ID_item",
    t."grade_GRD_Grade",
    t."grade_Metadata_GRD",
    t."GRD_ID_grade"
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_holder_OB_item_GRD_grade" AS
SELECT
    *
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dSU_holder_OB_item_GRD_grade" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    t."SU_holder_OB_item_GRD_grade_ID",
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_ID_holder",
    t."OB_ID_item",
    t."grade_GRD_Grade",
    t."grade_Metadata_GRD",
    t."GRD_ID_grade"
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."SU_holder_OB_item_GRD_grade_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    t."SU_keeper_OB_thing_GRD_rank_ID",
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    "kGRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "kGRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    t."GRD_ID_rank"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."SU_ID_keeper",
                r."OB_ID_thing"
            ORDER BY
                r."SU_keeper_OB_thing_GRD_rank_ChangedAt" DESC,
                r."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC,
                r."SU_keeper_OB_thing_GRD_rank_ID" DESC
        ) AS "latest"
    FROM
        public."rSU_keeper_OB_thing_GRD_rank"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_keeper_OB_thing_GRD_rank_Reliability" = 1
) t
LEFT JOIN
    public."GRD_Grade" "kGRD_rank"
ON
    "kGRD_rank"."GRD_ID" = t."GRD_ID_rank"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_keeper_OB_thing_GRD_rank" AS
SELECT
    *
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    t."SU_keeper_OB_thing_GRD_rank_ID",
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    t."rank_GRD_Grade",
    t."rank_Metadata_GRD",
    t."GRD_ID_rank"
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_keeper_OB_thing_GRD_rank" AS
SELECT
    *
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dSU_keeper_OB_thing_GRD_rank" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    t."SU_keeper_OB_thing_GRD_rank_ID",
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    t."rank_GRD_Grade",
    t."rank_Metadata_GRD",
    t."GRD_ID_rank"
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tOB_part_SU_owner" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "OB_part_SU_owner_ID" integer,
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2),
    "OB_ID_part" integer,
    "SU_ID_owner" integer
)
AS
$$
SELECT
    t."OB_part_SU_owner_ID",
    t."Metadata_OB_part_SU_owner",
    t."OB_part_SU_owner_PositedAt",
    t."OB_part_SU_owner_Reliability",
    t."OB_ID_part",
    t."SU_ID_owner"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."OB_ID_part"
            ORDER BY
                r."OB_part_SU_owner_PositedAt" DESC,
                r."OB_part_SU_owner_ID" DESC
        ) AS "latest"
    FROM
        public."rOB_part_SU_owner"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."OB_part_SU_owner_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lOB_part_SU_owner" AS
SELECT
    *
FROM
    public."tOB_part_SU_owner"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pOB_part_SU_owner" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "OB_part_SU_owner_ID" integer,
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2),
    "OB_ID_part" integer,
    "SU_ID_owner" integer
)
AS
$$
SELECT
    t."OB_part_SU_owner_ID",
    t."Metadata_OB_part_SU_owner",
    t."OB_part_SU_owner_PositedAt",
    t."OB_part_SU_owner_Reliability",
    t."OB_ID_part",
    t."SU_ID_owner"
FROM
    public."tOB_part_SU_owner"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nOB_part_SU_owner" AS
SELECT
    *
FROM
    public."tOB_part_SU_owner"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."tSU_partner_SU_with" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    t."SU_partner_SU_with_ID",
    t."Metadata_SU_partner_SU_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Reliability",
    t."SU_ID_partner",
    t."SU_ID_with"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."SU_ID_partner"
            ORDER BY
                r."SU_partner_SU_with_ChangedAt" DESC,
                r."SU_partner_SU_with_PositedAt" DESC,
                r."SU_partner_SU_with_ID" DESC
        ) AS "latestSU_ID_partner",
        row_number() OVER (
            PARTITION BY r."SU_ID_with"
            ORDER BY
                r."SU_partner_SU_with_ChangedAt" DESC,
                r."SU_partner_SU_with_PositedAt" DESC,
                r."SU_partner_SU_with_ID" DESC
        ) AS "latestSU_ID_with"
    FROM
        public."rSU_partner_SU_with"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_partner_SU_with_Reliability" = 1
) t
WHERE
    t."latestSU_ID_partner" = 1
AND
    t."latestSU_ID_with" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_partner_SU_with" AS
SELECT
    *
FROM
    public."tSU_partner_SU_with"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pSU_partner_SU_with" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    t."SU_partner_SU_with_ID",
    t."Metadata_SU_partner_SU_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Reliability",
    t."SU_ID_partner",
    t."SU_ID_with"
FROM
    public."tSU_partner_SU_with"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_partner_SU_with" AS
SELECT
    *
FROM
    public."tSU_partner_SU_with"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dSU_partner_SU_with" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    t."SU_partner_SU_with_ID",
    t."Metadata_SU_partner_SU_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Reliability",
    t."SU_ID_partner",
    t."SU_ID_with"
FROM
    public."tSU_partner_SU_with"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."SU_partner_SU_with_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
