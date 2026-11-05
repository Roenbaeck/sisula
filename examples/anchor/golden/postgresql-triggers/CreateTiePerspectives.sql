-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_holder_OB_item_GRD_grade" (
    "Metadata_SU_holder_OB_item_GRD_grade",
    "SU_holder_OB_item_GRD_grade_ChangedAt",
    "SU_ID_holder",
    "OB_ID_item",
    "grade_GRD_Grade",
    "grade_Metadata_GRD",
    "GRD_ID_grade"
)
AS
SELECT
    tie."Metadata_SU_holder_OB_item_GRD_grade",
    tie."SU_holder_OB_item_GRD_grade_ChangedAt",
    tie."SU_ID_holder",
    tie."OB_ID_item",
    "GRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "GRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    tie."GRD_ID_grade"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_holder_OB_item_GRD_grade_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_holder",
                    t."OB_ID_item"
            ) AS "latest"
        FROM
            public."SU_holder_OB_item_GRD_grade" t
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_grade"
ON
    "GRD_grade"."GRD_ID" = tie."GRD_ID_grade"
WHERE
    tie."SU_holder_OB_item_GRD_grade_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_holder_OB_item_GRD_grade",
    tie."SU_holder_OB_item_GRD_grade_ChangedAt",
    tie."SU_ID_holder",
    tie."OB_ID_item",
    "GRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "GRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    tie."GRD_ID_grade"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_holder_OB_item_GRD_grade_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_holder",
                    t."OB_ID_item"
            ) AS "latest"
        FROM
            public."SU_holder_OB_item_GRD_grade" t
        WHERE
            t."SU_holder_OB_item_GRD_grade_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_grade"
ON
    "GRD_grade"."GRD_ID" = tie."GRD_ID_grade"
WHERE
    tie."SU_holder_OB_item_GRD_grade_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_holder_OB_item_GRD_grade" AS
SELECT
    *
FROM
    public."pSU_holder_OB_item_GRD_grade"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_holder_OB_item_GRD_grade" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_holder_OB_item_GRD_grade",
    tie."SU_holder_OB_item_GRD_grade_ChangedAt",
    tie."SU_ID_holder",
    tie."OB_ID_item",
    "GRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "GRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    tie."GRD_ID_grade"
FROM
    public."SU_holder_OB_item_GRD_grade" tie
LEFT JOIN
    public."GRD_Grade" "GRD_grade"
ON
    "GRD_grade"."GRD_ID" = tie."GRD_ID_grade"
WHERE
    tie."SU_holder_OB_item_GRD_grade_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_keeper_OB_thing_GRD_rank" (
    "Metadata_SU_keeper_OB_thing_GRD_rank",
    "SU_keeper_OB_thing_GRD_rank_ChangedAt",
    "SU_ID_keeper",
    "OB_ID_thing",
    "rank_GRD_Grade",
    "rank_Metadata_GRD",
    "GRD_ID_rank"
)
AS
SELECT
    tie."Metadata_SU_keeper_OB_thing_GRD_rank",
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    tie."SU_ID_keeper",
    tie."OB_ID_thing",
    "GRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "GRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    tie."GRD_ID_rank"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_keeper_OB_thing_GRD_rank_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_keeper",
                    t."OB_ID_thing"
            ) AS "latest"
        FROM
            public."SU_keeper_OB_thing_GRD_rank" t
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_rank"
ON
    "GRD_rank"."GRD_ID" = tie."GRD_ID_rank"
WHERE
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt" = tie."latest"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_keeper_OB_thing_GRD_rank",
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    tie."SU_ID_keeper",
    tie."OB_ID_thing",
    "GRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "GRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    tie."GRD_ID_rank"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_keeper_OB_thing_GRD_rank_ChangedAt") OVER (
                PARTITION BY
                    t."SU_ID_keeper",
                    t."OB_ID_thing"
            ) AS "latest"
        FROM
            public."SU_keeper_OB_thing_GRD_rank" t
        WHERE
            t."SU_keeper_OB_thing_GRD_rank_ChangedAt" <= changingTimepoint
    ) tie
LEFT JOIN
    public."GRD_Grade" "GRD_rank"
ON
    "GRD_rank"."GRD_ID" = tie."GRD_ID_rank"
WHERE
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt" = tie."latest"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_keeper_OB_thing_GRD_rank" AS
SELECT
    *
FROM
    public."pSU_keeper_OB_thing_GRD_rank"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_keeper_OB_thing_GRD_rank" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    tie."Metadata_SU_keeper_OB_thing_GRD_rank",
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    tie."SU_ID_keeper",
    tie."OB_ID_thing",
    "GRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "GRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    tie."GRD_ID_rank"
FROM
    public."SU_keeper_OB_thing_GRD_rank" tie
LEFT JOIN
    public."GRD_Grade" "GRD_rank"
ON
    "GRD_rank"."GRD_ID" = tie."GRD_ID_rank"
WHERE
    tie."SU_keeper_OB_thing_GRD_rank_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lOB_part_SU_owner" (
    "Metadata_OB_part_SU_owner",
    "OB_ID_part",
    "SU_ID_owner"
)
AS
SELECT
    tie."Metadata_OB_part_SU_owner",
    tie."OB_ID_part",
    tie."SU_ID_owner"
FROM
    public."OB_part_SU_owner" tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pOB_part_SU_owner" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_ID_part" integer,
    "SU_ID_owner" integer
)
AS
$$
SELECT
    tie."Metadata_OB_part_SU_owner",
    tie."OB_ID_part",
    tie."SU_ID_owner"
FROM
    public."OB_part_SU_owner" tie
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nOB_part_SU_owner" AS
SELECT
    *
FROM
    public."pOB_part_SU_owner"(current_timestamp::timestamp)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_partner_SU_with" (
    "Metadata_SU_partner_SU_with",
    "SU_partner_SU_with_ChangedAt",
    "SU_ID_partner",
    "SU_ID_with"
)
AS
SELECT
    tie."Metadata_SU_partner_SU_with",
    tie."SU_partner_SU_with_ChangedAt",
    tie."SU_ID_partner",
    tie."SU_ID_with"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_partner") AS "latestSU_ID_partner",
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_with") AS "latestSU_ID_with"
        FROM
            public."SU_partner_SU_with" t
    ) tie
WHERE
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_partner"
AND
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_with"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_partner_SU_with" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    tie."Metadata_SU_partner_SU_with",
    tie."SU_partner_SU_with_ChangedAt",
    tie."SU_ID_partner",
    tie."SU_ID_with"
FROM
    (
        -- the latest changing time of the identifiers (of each anchor, in a tie without identifiers), as a column
        SELECT
            t.*,
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_partner") AS "latestSU_ID_partner",
            max(t."SU_partner_SU_with_ChangedAt") OVER (PARTITION BY t."SU_ID_with") AS "latestSU_ID_with"
        FROM
            public."SU_partner_SU_with" t
        WHERE
            t."SU_partner_SU_with_ChangedAt" <= changingTimepoint
    ) tie
WHERE
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_partner"
AND
    tie."SU_partner_SU_with_ChangedAt" = tie."latestSU_ID_with"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_partner_SU_with" AS
SELECT
    *
FROM
    public."pSU_partner_SU_with"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_partner_SU_with" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    tie."Metadata_SU_partner_SU_with",
    tie."SU_partner_SU_with_ChangedAt",
    tie."SU_ID_partner",
    tie."SU_ID_with"
FROM
    public."SU_partner_SU_with" tie
WHERE
    tie."SU_partner_SU_with_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
