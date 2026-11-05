-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tSU_holder_OB_item_GRD_grade" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Positor" smallint,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_holder_OB_item_GRD_grade_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_ID_holder",
    t."OB_ID_item",
    "kGRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "kGRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    t."GRD_ID_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Positor",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_holder_OB_item_GRD_grade_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."SU_holder_OB_item_GRD_grade_Positor",
                s."SU_ID_holder",
                s."OB_ID_item"
            ORDER BY
                s."SU_holder_OB_item_GRD_grade_ChangedAt" DESC,
                s."SU_holder_OB_item_GRD_grade_PositedAt" DESC,
                s."SU_holder_OB_item_GRD_grade_Reliability" DESC,
                s."SU_holder_OB_item_GRD_grade_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."SU_holder_OB_item_GRD_grade_Assertion" <> '?' THEN r."SU_holder_OB_item_GRD_grade_ChangedAt" END) OVER (
                PARTITION BY
                    r."SU_holder_OB_item_GRD_grade_Positor",
                    r."SU_ID_holder",
                    r."OB_ID_item"
            ) AS "inEffect"
        FROM
            public."rSU_holder_OB_item_GRD_grade"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."SU_holder_OB_item_GRD_grade_Assertion" = coalesce(assertion, s."SU_holder_OB_item_GRD_grade_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."SU_holder_OB_item_GRD_grade_ChangedAt" = s."inEffect"
    )
) t
LEFT JOIN
    public."GRD_Grade" "kGRD_grade"
ON
    "kGRD_grade"."GRD_ID" = t."GRD_ID_grade"
WHERE
    t."SU_holder_OB_item_GRD_grade_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_holder_OB_item_GRD_grade" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tSU_holder_OB_item_GRD_grade"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Positor" smallint,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_holder_OB_item_GRD_grade_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_ID_holder",
    t."OB_ID_item",
    t."grade_GRD_Grade",
    t."grade_Metadata_GRD",
    t."GRD_ID_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Positor",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_holder_OB_item_GRD_grade_Assertion"
FROM
    public."_Positor" p,
    public."tSU_holder_OB_item_GRD_grade"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_holder_OB_item_GRD_grade" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tSU_holder_OB_item_GRD_grade"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_holder_OB_item_GRD_grade" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Positor" smallint,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_holder_OB_item_GRD_grade_Assertion" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_ID_holder",
    t."OB_ID_item",
    "kGRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "kGRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    t."GRD_ID_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Positor",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_holder_OB_item_GRD_grade_Assertion"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "SU_holder_OB_item_GRD_grade_Positor" AS positor,
        "SU_holder_OB_item_GRD_grade_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        public."SU_holder_OB_item_GRD_grade"
    WHERE
        "SU_holder_OB_item_GRD_grade_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."SU_holder_OB_item_GRD_grade_ChangedAt") OVER (
            PARTITION BY
                y."SU_holder_OB_item_GRD_grade_Positor",
                y."SU_ID_holder",
                y."OB_ID_item"
            ORDER BY y."SU_holder_OB_item_GRD_grade_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."SU_holder_OB_item_GRD_grade_Positor",
                    r."SU_ID_holder",
                    r."OB_ID_item",
                    r."SU_holder_OB_item_GRD_grade_ChangedAt")
            r.*
        FROM
            public."rSU_holder_OB_item_GRD_grade"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_holder_OB_item_GRD_grade_Assertion" <> '?'
        ORDER BY
    r."SU_holder_OB_item_GRD_grade_Positor",
                    r."SU_ID_holder",
                    r."OB_ID_item",
                    r."SU_holder_OB_item_GRD_grade_ChangedAt",
    CASE WHEN r."SU_holder_OB_item_GRD_grade_Assertion" = '+' THEN 0 ELSE 1 END,
    r."SU_holder_OB_item_GRD_grade_PositedAt" DESC,
    r."SU_holder_OB_item_GRD_grade_Reliability" DESC,
    r."SU_holder_OB_item_GRD_grade_ID" DESC
    ) y
) t
ON
    t."SU_holder_OB_item_GRD_grade_Positor" = tp.positor
AND
    t."SU_holder_OB_item_GRD_grade_Assertion" = '+'
AND
    t."SU_holder_OB_item_GRD_grade_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."GRD_Grade" "kGRD_grade"
ON
    "kGRD_grade"."GRD_ID" = t."GRD_ID_grade"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tSU_keeper_OB_thing_GRD_rank" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Positor" smallint,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_keeper_OB_thing_GRD_rank_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    "kGRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "kGRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    t."GRD_ID_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Positor",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_keeper_OB_thing_GRD_rank_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."SU_keeper_OB_thing_GRD_rank_Positor",
                s."SU_ID_keeper",
                s."OB_ID_thing"
            ORDER BY
                s."SU_keeper_OB_thing_GRD_rank_ChangedAt" DESC,
                s."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC,
                s."SU_keeper_OB_thing_GRD_rank_Reliability" DESC,
                s."SU_keeper_OB_thing_GRD_rank_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."SU_keeper_OB_thing_GRD_rank_Assertion" <> '?' THEN r."SU_keeper_OB_thing_GRD_rank_ChangedAt" END) OVER (
                PARTITION BY
                    r."SU_keeper_OB_thing_GRD_rank_Positor",
                    r."SU_ID_keeper",
                    r."OB_ID_thing"
            ) AS "inEffect"
        FROM
            public."rSU_keeper_OB_thing_GRD_rank"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."SU_keeper_OB_thing_GRD_rank_Assertion" = coalesce(assertion, s."SU_keeper_OB_thing_GRD_rank_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."SU_keeper_OB_thing_GRD_rank_ChangedAt" = s."inEffect"
    )
) t
LEFT JOIN
    public."GRD_Grade" "kGRD_rank"
ON
    "kGRD_rank"."GRD_ID" = t."GRD_ID_rank"
WHERE
    t."SU_keeper_OB_thing_GRD_rank_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_keeper_OB_thing_GRD_rank" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tSU_keeper_OB_thing_GRD_rank"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Positor" smallint,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_keeper_OB_thing_GRD_rank_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    t."rank_GRD_Grade",
    t."rank_Metadata_GRD",
    t."GRD_ID_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Positor",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_keeper_OB_thing_GRD_rank_Assertion"
FROM
    public."_Positor" p,
    public."tSU_keeper_OB_thing_GRD_rank"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_keeper_OB_thing_GRD_rank" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tSU_keeper_OB_thing_GRD_rank"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_keeper_OB_thing_GRD_rank" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Positor" smallint,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_keeper_OB_thing_GRD_rank_Assertion" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    "kGRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "kGRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    t."GRD_ID_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Positor",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_keeper_OB_thing_GRD_rank_Assertion"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "SU_keeper_OB_thing_GRD_rank_Positor" AS positor,
        "SU_keeper_OB_thing_GRD_rank_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        public."SU_keeper_OB_thing_GRD_rank"
    WHERE
        "SU_keeper_OB_thing_GRD_rank_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."SU_keeper_OB_thing_GRD_rank_ChangedAt") OVER (
            PARTITION BY
                y."SU_keeper_OB_thing_GRD_rank_Positor",
                y."SU_ID_keeper",
                y."OB_ID_thing"
            ORDER BY y."SU_keeper_OB_thing_GRD_rank_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."SU_keeper_OB_thing_GRD_rank_Positor",
                    r."SU_ID_keeper",
                    r."OB_ID_thing",
                    r."SU_keeper_OB_thing_GRD_rank_ChangedAt")
            r.*
        FROM
            public."rSU_keeper_OB_thing_GRD_rank"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_keeper_OB_thing_GRD_rank_Assertion" <> '?'
        ORDER BY
    r."SU_keeper_OB_thing_GRD_rank_Positor",
                    r."SU_ID_keeper",
                    r."OB_ID_thing",
                    r."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    CASE WHEN r."SU_keeper_OB_thing_GRD_rank_Assertion" = '+' THEN 0 ELSE 1 END,
    r."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC,
    r."SU_keeper_OB_thing_GRD_rank_Reliability" DESC,
    r."SU_keeper_OB_thing_GRD_rank_ID" DESC
    ) y
) t
ON
    t."SU_keeper_OB_thing_GRD_rank_Positor" = tp.positor
AND
    t."SU_keeper_OB_thing_GRD_rank_Assertion" = '+'
AND
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."GRD_Grade" "kGRD_rank"
ON
    "kGRD_rank"."GRD_ID" = t."GRD_ID_rank"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tOB_part_SU_owner" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_ID_part" integer,
    "SU_ID_owner" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Positor" smallint,
    "OB_part_SU_owner_Reliability" decimal(5,2),
    "OB_part_SU_owner_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_OB_part_SU_owner",
    t."OB_ID_part",
    t."SU_ID_owner",
    t."OB_part_SU_owner_PositedAt",
    t."OB_part_SU_owner_Positor",
    t."OB_part_SU_owner_Reliability",
    t."OB_part_SU_owner_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."OB_part_SU_owner_Positor",
                s."OB_ID_part"
            ORDER BY
                s."OB_part_SU_owner_PositedAt" DESC,
                s."OB_part_SU_owner_Reliability" DESC,
                s."OB_part_SU_owner_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rOB_part_SU_owner"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."OB_part_SU_owner_Assertion" = coalesce(assertion, s."OB_part_SU_owner_Assertion")
) t
WHERE
    t."OB_part_SU_owner_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lOB_part_SU_owner" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tOB_part_SU_owner"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pOB_part_SU_owner" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_OB_part_SU_owner" integer,
    "OB_ID_part" integer,
    "SU_ID_owner" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Positor" smallint,
    "OB_part_SU_owner_Reliability" decimal(5,2),
    "OB_part_SU_owner_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_OB_part_SU_owner",
    t."OB_ID_part",
    t."SU_ID_owner",
    t."OB_part_SU_owner_PositedAt",
    t."OB_part_SU_owner_Positor",
    t."OB_part_SU_owner_Reliability",
    t."OB_part_SU_owner_Assertion"
FROM
    public."_Positor" p,
    public."tOB_part_SU_owner"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nOB_part_SU_owner" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tOB_part_SU_owner"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tSU_partner_SU_with" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_ID_partner" integer,
    "SU_ID_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Positor" smallint,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_partner_SU_with_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_SU_partner_SU_with",
    t."SU_ID_partner",
    t."SU_ID_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Positor",
    t."SU_partner_SU_with_Reliability",
    t."SU_partner_SU_with_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."SU_partner_SU_with_Positor", s."SU_ID_partner"
            ORDER BY
                s."SU_partner_SU_with_ChangedAt" DESC,
                s."SU_partner_SU_with_PositedAt" DESC,
                s."SU_partner_SU_with_Reliability" DESC,
                s."SU_partner_SU_with_ID" DESC
        ) AS "latestSU_ID_partner",
        row_number() OVER (
            PARTITION BY s."SU_partner_SU_with_Positor", s."SU_ID_with"
            ORDER BY
                s."SU_partner_SU_with_ChangedAt" DESC,
                s."SU_partner_SU_with_PositedAt" DESC,
                s."SU_partner_SU_with_Reliability" DESC,
                s."SU_partner_SU_with_ID" DESC
        ) AS "latestSU_ID_with"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."SU_partner_SU_with_Assertion" <> '?' THEN r."SU_partner_SU_with_ChangedAt" END) OVER (
                PARTITION BY
                    r."SU_partner_SU_with_Positor",
                    r."SU_ID_partner",
                    r."SU_ID_with"
            ) AS "inEffect"
        FROM
            public."rSU_partner_SU_with"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."SU_partner_SU_with_Assertion" = coalesce(assertion, s."SU_partner_SU_with_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."SU_partner_SU_with_ChangedAt" = s."inEffect"
    )
) t
WHERE
    t."SU_partner_SU_with_Positor" = positor
AND
    t."latestSU_ID_partner" = 1
AND
    t."latestSU_ID_with" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lSU_partner_SU_with" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tSU_partner_SU_with"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pSU_partner_SU_with" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_SU_partner_SU_with" integer,
    "SU_ID_partner" integer,
    "SU_ID_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Positor" smallint,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_partner_SU_with_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_SU_partner_SU_with",
    t."SU_ID_partner",
    t."SU_ID_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Positor",
    t."SU_partner_SU_with_Reliability",
    t."SU_partner_SU_with_Assertion"
FROM
    public."_Positor" p,
    public."tSU_partner_SU_with"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nSU_partner_SU_with" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tSU_partner_SU_with"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dSU_partner_SU_with" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "Metadata_SU_partner_SU_with" integer,
    "SU_ID_partner" integer,
    "SU_ID_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Positor" smallint,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_partner_SU_with_Assertion" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
-- A tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors is kept, by a
-- window over the rows that are joined and the filter after it.
SELECT
    q."Positor",
    q.inspectedTimepoint,
    q."Metadata_SU_partner_SU_with",
    q."SU_ID_partner",
    q."SU_ID_with",
    q."SU_partner_SU_with_ChangedAt",
    q."SU_partner_SU_with_PositedAt",
    q."SU_partner_SU_with_Positor",
    q."SU_partner_SU_with_Reliability",
    q."SU_partner_SU_with_Assertion"
FROM (
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_SU_partner_SU_with",
    t."SU_ID_partner",
    t."SU_ID_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Positor",
    t."SU_partner_SU_with_Reliability",
    t."SU_partner_SU_with_Assertion",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."SU_ID_partner"
        ORDER BY
            t."SU_partner_SU_with_ChangedAt" DESC,
            t."SU_partner_SU_with_PositedAt" DESC,
            t."SU_partner_SU_with_Reliability" DESC,
            t."SU_partner_SU_with_ID" DESC
    ) AS "latestSU_ID_partner",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."SU_ID_with"
        ORDER BY
            t."SU_partner_SU_with_ChangedAt" DESC,
            t."SU_partner_SU_with_PositedAt" DESC,
            t."SU_partner_SU_with_Reliability" DESC,
            t."SU_partner_SU_with_ID" DESC
    ) AS "latestSU_ID_with"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "SU_partner_SU_with_Positor" AS positor,
        "SU_partner_SU_with_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        public."SU_partner_SU_with"
    WHERE
        "SU_partner_SU_with_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."SU_partner_SU_with_ChangedAt") OVER (
            PARTITION BY
                y."SU_partner_SU_with_Positor",
                y."SU_ID_partner",
                y."SU_ID_with"
            ORDER BY y."SU_partner_SU_with_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."SU_partner_SU_with_Positor",
                    r."SU_ID_partner",
                    r."SU_ID_with",
                    r."SU_partner_SU_with_ChangedAt")
            r.*
        FROM
            public."rSU_partner_SU_with"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_partner_SU_with_Assertion" <> '?'
        ORDER BY
    r."SU_partner_SU_with_Positor",
                    r."SU_ID_partner",
                    r."SU_ID_with",
                    r."SU_partner_SU_with_ChangedAt",
    CASE WHEN r."SU_partner_SU_with_Assertion" = '+' THEN 0 ELSE 1 END,
    r."SU_partner_SU_with_PositedAt" DESC,
    r."SU_partner_SU_with_Reliability" DESC,
    r."SU_partner_SU_with_ID" DESC
    ) y
) t
ON
    t."SU_partner_SU_with_Positor" = tp.positor
AND
    t."SU_partner_SU_with_Assertion" = '+'
AND
    t."SU_partner_SU_with_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
) q
WHERE
    q."latestSU_ID_partner" = 1
AND
    q."latestSU_ID_with" = 1
$$ LANGUAGE sql STABLE;
