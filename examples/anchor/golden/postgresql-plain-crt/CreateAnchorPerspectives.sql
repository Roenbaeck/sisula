-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tST_Stage" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "ST_ID" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "UTL_Utilization" smallint,
    "UTL_ID" smallint,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1),
    "UTL_Utilization" smallint,
    "UTL_ID" smallint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Positor",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Assertion",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "AVG"."UTL_Utilization",
    "AVG"."UTL_ID",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "MIN"."UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."ST_Stage" "ST"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_NAM_Positor", x."ST_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_NAM_Assertion" <> '?' THEN r."ST_NAM_ChangedAt" END) OVER (
                PARTITION BY r."ST_NAM_Positor", r."ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_NAM_Stage_Name"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_NAM_Assertion" = coalesce(assertion, x."ST_NAM_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."ST_NAM_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."ST_NAM_Positor", x."ST_ID",
    x."ST_NAM_ChangedAt" DESC,
    x."ST_NAM_PositedAt" DESC,
    x."ST_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_LOC_Positor", x."ST_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_LOC_Stage_Location"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_LOC_Assertion" = coalesce(assertion, x."ST_LOC_Assertion")
    ORDER BY
    x."ST_LOC_Positor", x."ST_ID",
    x."ST_LOC_PositedAt" DESC,
    x."ST_LOC_Reliability" DESC
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_AVG_Positor", x."ST_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_AVG_Assertion" <> '?' THEN r."ST_AVG_ChangedAt" END) OVER (
                PARTITION BY r."ST_AVG_Positor", r."ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_AVG_Stage_Average"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_AVG_Assertion" = coalesce(assertion, x."ST_AVG_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."ST_AVG_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."ST_AVG_Positor", x."ST_ID",
    x."ST_AVG_ChangedAt" DESC,
    x."ST_AVG_PositedAt" DESC,
    x."ST_AVG_Reliability" DESC
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."UTL_ID"
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_MIN_Positor", x."ST_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_MIN_Stage_Minimum"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_MIN_Assertion" = coalesce(assertion, x."ST_MIN_Assertion")
    ORDER BY
    x."ST_MIN_Positor", x."ST_ID",
    x."ST_MIN_PositedAt" DESC,
    x."ST_MIN_Reliability" DESC
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."UTL_ID"
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    public."_Positor" p,
    public."tST_Stage"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "ST"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_Stage" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "ST_ID" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "UTL_Utilization" smallint,
    "UTL_ID" smallint,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1),
    "UTL_Utilization" smallint,
    "UTL_ID" smallint
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST"."ST_ID",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Positor",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Assertion",
    "ST"."ST_NAM_Stage_Name",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Positor",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Assertion",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Positor",
    "ST"."ST_AVG_Reliability",
    "ST"."ST_AVG_Assertion",
    "ST"."UTL_Utilization",
    "ST"."UTL_ID",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Positor",
    "ST"."ST_MIN_Reliability",
    "ST"."ST_MIN_Assertion",
    "ST"."UTL_Utilization",
    "ST"."UTL_ID"
FROM
    public."_Positor" p,
    public."tST_Stage"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "ST"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    public."_Positor" p,
    public."tST_Stage"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "ST"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_Stage" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "ST_ID" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "UTL_Utilization" smallint,
    "UTL_ID" smallint,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1),
    "UTL_Utilization" smallint,
    "UTL_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "ST"."ST_ID",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Positor",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Assertion",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "AVG"."UTL_ID",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."_Positor" p
JOIN
(
    SELECT DISTINCT
        "ST_NAM_Positor" AS positor,
        "ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."ST_NAM_Stage_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_AVG_Positor" AS positor,
        "ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public."ST_AVG_Stage_Average"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor"
JOIN
    public."ST_Stage" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."ST_NAM_ChangedAt") OVER (
            PARTITION BY y."ST_NAM_Positor", y."ST_ID"
            ORDER BY y."ST_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_NAM_Positor", r."ST_ID", r."ST_NAM_ChangedAt")
            r.*
        FROM
            public."rST_NAM_Stage_Name"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."ST_NAM_Assertion" <> '?'
        ORDER BY
    r."ST_NAM_Positor", r."ST_ID", r."ST_NAM_ChangedAt",
    CASE WHEN r."ST_NAM_Assertion" = '+' THEN 0 ELSE 1 END,
    r."ST_NAM_PositedAt" DESC,
    r."ST_NAM_Reliability" DESC
    ) y
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = timepoints.positor
AND
    "NAM"."ST_NAM_Assertion" = '+'
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_LOC_Positor", r."ST_ID")
        r.*
    FROM
        public."rST_LOC_Stage_Location"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."ST_LOC_Assertion" = '+'
    ORDER BY
    r."ST_LOC_Positor", r."ST_ID",
    r."ST_LOC_PositedAt" DESC,
    r."ST_LOC_Reliability" DESC
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."ST_AVG_ChangedAt") OVER (
            PARTITION BY y."ST_AVG_Positor", y."ST_ID"
            ORDER BY y."ST_AVG_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_AVG_Positor", r."ST_ID", r."ST_AVG_ChangedAt")
            r.*
        FROM
            public."rST_AVG_Stage_Average"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."ST_AVG_Assertion" <> '?'
        ORDER BY
    r."ST_AVG_Positor", r."ST_ID", r."ST_AVG_ChangedAt",
    CASE WHEN r."ST_AVG_Assertion" = '+' THEN 0 ELSE 1 END,
    r."ST_AVG_PositedAt" DESC,
    r."ST_AVG_Reliability" DESC
    ) y
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Positor" = timepoints.positor
AND
    "AVG"."ST_AVG_Assertion" = '+'
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_MIN_Positor", r."ST_ID")
        r.*
    FROM
        public."rST_MIN_Stage_Minimum"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."ST_MIN_Assertion" = '+'
    ORDER BY
    r."ST_MIN_Positor", r."ST_ID",
    r."ST_MIN_PositedAt" DESC,
    r."ST_MIN_Reliability" DESC
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Positor" = timepoints.positor
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_Actor" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "AC_ID" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1),
    "GEN_Gender" varchar(42),
    "GEN_ID" smallint,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "PLV_Checksum" bytea,
    "PLV_ProfessionalLevel" text,
    "PLV_ID" smallint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Positor",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Assertion",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "GEN"."GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Positor",
    "PLV"."AC_PLV_Reliability",
    "PLV"."AC_PLV_Assertion",
    "PLV"."PLV_Checksum",
    "PLV"."PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."AC_Actor" "AC"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_NAM_Positor", x."AC_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_NAM_Assertion" <> '?' THEN r."AC_NAM_ChangedAt" END) OVER (
                PARTITION BY r."AC_NAM_Positor", r."AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_NAM_Actor_Name"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."AC_NAM_Assertion" = coalesce(assertion, x."AC_NAM_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."AC_NAM_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."AC_NAM_Positor", x."AC_ID",
    x."AC_NAM_ChangedAt" DESC,
    x."AC_NAM_PositedAt" DESC,
    x."AC_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."GEN_Gender" AS "GEN_Gender"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_GEN_Positor", x."AC_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_GEN_Actor_Gender"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."AC_GEN_Assertion" = coalesce(assertion, x."AC_GEN_Assertion")
    ORDER BY
    x."AC_GEN_Positor", x."AC_ID",
    x."AC_GEN_PositedAt" DESC,
    x."AC_GEN_Reliability" DESC
    ) y
    LEFT JOIN
        public."GEN_Gender" k
    ON
        k."GEN_ID" = y."GEN_ID"
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "PLV_Checksum",
        k."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_PLV_Positor", x."AC_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_PLV_Assertion" <> '?' THEN r."AC_PLV_ChangedAt" END) OVER (
                PARTITION BY r."AC_PLV_Positor", r."AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."AC_PLV_Assertion" = coalesce(assertion, x."AC_PLV_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."AC_PLV_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."AC_PLV_Positor", x."AC_ID",
    x."AC_PLV_ChangedAt" DESC,
    x."AC_PLV_PositedAt" DESC,
    x."AC_PLV_Reliability" DESC
    ) y
    LEFT JOIN
        public."PLV_ProfessionalLevel" k
    ON
        k."PLV_ID" = y."PLV_ID"
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    public."_Positor" p,
    public."tAC_Actor"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "AC"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_Actor" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "AC_ID" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1),
    "GEN_Gender" varchar(42),
    "GEN_ID" smallint,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "PLV_Checksum" bytea,
    "PLV_ProfessionalLevel" text,
    "PLV_ID" smallint
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC"."AC_ID",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Positor",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Assertion",
    "AC"."AC_NAM_Actor_Name",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Positor",
    "AC"."AC_GEN_Reliability",
    "AC"."AC_GEN_Assertion",
    "AC"."GEN_Gender",
    "AC"."GEN_ID",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Positor",
    "AC"."AC_PLV_Reliability",
    "AC"."AC_PLV_Assertion",
    "AC"."PLV_Checksum",
    "AC"."PLV_ProfessionalLevel",
    "AC"."PLV_ID"
FROM
    public."_Positor" p,
    public."tAC_Actor"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "AC"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    public."_Positor" p,
    public."tAC_Actor"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "AC"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_Actor" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "AC_ID" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1),
    "GEN_Gender" varchar(42),
    "GEN_ID" smallint,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "PLV_Checksum" bytea,
    "PLV_ProfessionalLevel" text,
    "PLV_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "AC"."AC_ID",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Positor",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Assertion",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Positor",
    "PLV"."AC_PLV_Reliability",
    "PLV"."AC_PLV_Assertion",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."_Positor" p
JOIN
(
    SELECT DISTINCT
        "AC_NAM_Positor" AS positor,
        "AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."AC_NAM_Actor_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_PLV_Positor" AS positor,
        "AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor"
JOIN
    public."AC_Actor" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."AC_NAM_ChangedAt") OVER (
            PARTITION BY y."AC_NAM_Positor", y."AC_ID"
            ORDER BY y."AC_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_NAM_Positor", r."AC_ID", r."AC_NAM_ChangedAt")
            r.*
        FROM
            public."rAC_NAM_Actor_Name"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_NAM_Assertion" <> '?'
        ORDER BY
    r."AC_NAM_Positor", r."AC_ID", r."AC_NAM_ChangedAt",
    CASE WHEN r."AC_NAM_Assertion" = '+' THEN 0 ELSE 1 END,
    r."AC_NAM_PositedAt" DESC,
    r."AC_NAM_Reliability" DESC
    ) y
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = timepoints.positor
AND
    "NAM"."AC_NAM_Assertion" = '+'
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."AC_GEN_Positor", r."AC_ID")
        r.*
    FROM
        public."rAC_GEN_Actor_Gender"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."AC_GEN_Assertion" = '+'
    ORDER BY
    r."AC_GEN_Positor", r."AC_ID",
    r."AC_GEN_PositedAt" DESC,
    r."AC_GEN_Reliability" DESC
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Positor" = timepoints.positor
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."AC_PLV_ChangedAt") OVER (
            PARTITION BY y."AC_PLV_Positor", y."AC_ID"
            ORDER BY y."AC_PLV_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_PLV_Positor", r."AC_ID", r."AC_PLV_ChangedAt")
            r.*
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_PLV_Assertion" <> '?'
        ORDER BY
    r."AC_PLV_Positor", r."AC_ID", r."AC_PLV_ChangedAt",
    CASE WHEN r."AC_PLV_Assertion" = '+' THEN 0 ELSE 1 END,
    r."AC_PLV_PositedAt" DESC,
    r."AC_PLV_Reliability" DESC
    ) y
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Positor" = timepoints.positor
AND
    "PLV"."AC_PLV_Assertion" = '+'
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tPR_Program" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "PR_ID" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."PR_NAM_Positor", x."PR_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_NAM_Program_Name"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."PR_NAM_Assertion" = coalesce(assertion, x."PR_NAM_Assertion")
    ORDER BY
    x."PR_NAM_Positor", x."PR_ID",
    x."PR_NAM_PositedAt" DESC,
    x."PR_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."PR_LEN_Positor", x."PR_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_LEN_Assertion" <> '?' THEN r."PR_LEN_ChangedAt" END) OVER (
                PARTITION BY r."PR_LEN_Positor", r."PR_ID"
            ) AS "inEffect"
        FROM
            public."rPR_LEN_Program_Length"(
                null::smallint,
                changingTimepoint::date,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."PR_LEN_Assertion" = coalesce(assertion, x."PR_LEN_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."PR_LEN_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."PR_LEN_Positor", x."PR_ID",
    x."PR_LEN_ChangedAt" DESC,
    x."PR_LEN_PositedAt" DESC,
    x."PR_LEN_Reliability" DESC
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    public."_Positor" p,
    public."tPR_Program"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "PR"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_Program" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "PR_ID" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR"."PR_ID",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Positor",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Assertion",
    "PR"."PR_NAM_Program_Name",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Positor",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Assertion",
    "PR"."PR_LEN_Program_Length"
FROM
    public."_Positor" p,
    public."tPR_Program"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "PR"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    public."_Positor" p,
    public."tPR_Program"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "PR"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dPR_Program" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "PR_ID" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."_Positor" p
JOIN
(
    SELECT DISTINCT
        "PR_LEN_Positor" AS positor,
        "PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public."PR_LEN_Program_Length"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor"
JOIN
    public."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."PR_NAM_Positor", r."PR_ID")
        r.*
    FROM
        public."rPR_NAM_Program_Name"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."PR_NAM_Assertion" = '+'
    ORDER BY
    r."PR_NAM_Positor", r."PR_ID",
    r."PR_NAM_PositedAt" DESC,
    r."PR_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."PR_LEN_ChangedAt") OVER (
            PARTITION BY y."PR_LEN_Positor", y."PR_ID"
            ORDER BY y."PR_LEN_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."PR_LEN_Positor", r."PR_ID", r."PR_LEN_ChangedAt")
            r.*
        FROM
            public."rPR_LEN_Program_Length"(
                null::smallint,
                '9999-12-31'::date,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."PR_LEN_Assertion" <> '?'
        ORDER BY
    r."PR_LEN_Positor", r."PR_ID", r."PR_LEN_ChangedAt",
    CASE WHEN r."PR_LEN_Assertion" = '+' THEN 0 ELSE 1 END,
    r."PR_LEN_PositedAt" DESC,
    r."PR_LEN_Reliability" DESC
    ) y
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = timepoints.positor
AND
    "LEN"."PR_LEN_Assertion" = '+'
AND
    "LEN"."PR_LEN_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LEN"."until" IS NULL
OR
    "LEN"."until" > timepoints.inspectedTimepoint::date
)
$$ LANGUAGE sql STABLE;
