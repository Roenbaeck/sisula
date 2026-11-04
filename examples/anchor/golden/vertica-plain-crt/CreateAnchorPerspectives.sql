-- ANCHOR TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: latest (l) and now (n), for each positor. Vertica has no function that returns a table, so the
-- perspectives that take a time or a positor (time traveling, point-in-time and difference) are not made; the latest and the now
-- perspectives take none, and are views over the rewinders of the attributes (views that show the latest annex row of every posit
-- for each positor). The assertion that they show is the positive one.
--
CREATE OR REPLACE VIEW public."lST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rST_NAM_Stage_Name" r
    ) x
    WHERE
        x."ST_NAM_Assertion" = '+'
    AND
        x."ST_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_NAM_Positor", x."ST_ID"
        ORDER BY
            x."ST_NAM_ChangedAt" DESC,
            x."ST_NAM_PositedAt" DESC,
            x."ST_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_LOC_Stage_Location" r
    ) x
    WHERE
        x."ST_LOC_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_LOC_Positor", x."ST_ID"
        ORDER BY
            x."ST_LOC_PositedAt" DESC,
            x."ST_LOC_Reliability" DESC
    )
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rST_AVG_Stage_Average" r
    ) x
    WHERE
        x."ST_AVG_Assertion" = '+'
    AND
        x."ST_AVG_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_AVG_Positor", x."ST_ID"
        ORDER BY
            x."ST_AVG_ChangedAt" DESC,
            x."ST_AVG_PositedAt" DESC,
            x."ST_AVG_Reliability" DESC
    )
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
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_MIN_Stage_Minimum" r
    ) x
    WHERE
        x."ST_MIN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_MIN_Positor", x."ST_ID"
        ORDER BY
            x."ST_MIN_PositedAt" DESC,
            x."ST_MIN_Reliability" DESC
    )
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
;
CREATE OR REPLACE VIEW public."nST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rST_NAM_Stage_Name" r
        WHERE
            r."ST_NAM_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."ST_NAM_Assertion" = '+'
    AND
        x."ST_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_NAM_Positor", x."ST_ID"
        ORDER BY
            x."ST_NAM_ChangedAt" DESC,
            x."ST_NAM_PositedAt" DESC,
            x."ST_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_LOC_Stage_Location" r
    ) x
    WHERE
        x."ST_LOC_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_LOC_Positor", x."ST_ID"
        ORDER BY
            x."ST_LOC_PositedAt" DESC,
            x."ST_LOC_Reliability" DESC
    )
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rST_AVG_Stage_Average" r
        WHERE
            r."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."ST_AVG_Assertion" = '+'
    AND
        x."ST_AVG_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."ST_AVG_Positor", x."ST_ID"
        ORDER BY
            x."ST_AVG_ChangedAt" DESC,
            x."ST_AVG_PositedAt" DESC,
            x."ST_AVG_Reliability" DESC
    )
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
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."UTL_Utilization" AS "UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_MIN_Stage_Minimum" r
    ) x
    WHERE
        x."ST_MIN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."ST_MIN_Positor", x."ST_ID"
        ORDER BY
            x."ST_MIN_PositedAt" DESC,
            x."ST_MIN_Reliability" DESC
    )
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
;
CREATE OR REPLACE VIEW public."lAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rAC_NAM_Actor_Name" r
    ) x
    WHERE
        x."AC_NAM_Assertion" = '+'
    AND
        x."AC_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_NAM_Positor", x."AC_ID"
        ORDER BY
            x."AC_NAM_ChangedAt" DESC,
            x."AC_NAM_PositedAt" DESC,
            x."AC_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."GEN_Gender" AS "GEN_Gender"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_GEN_Actor_Gender" r
    ) x
    WHERE
        x."AC_GEN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."AC_GEN_Positor", x."AC_ID"
        ORDER BY
            x."AC_GEN_PositedAt" DESC,
            x."AC_GEN_Reliability" DESC
    )
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
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "PLV_Checksum",
        k."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rAC_PLV_Actor_ProfessionalLevel" r
    ) x
    WHERE
        x."AC_PLV_Assertion" = '+'
    AND
        x."AC_PLV_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_PLV_Positor", x."AC_ID"
        ORDER BY
            x."AC_PLV_ChangedAt" DESC,
            x."AC_PLV_PositedAt" DESC,
            x."AC_PLV_Reliability" DESC
    )
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
;
CREATE OR REPLACE VIEW public."nAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rAC_NAM_Actor_Name" r
        WHERE
            r."AC_NAM_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."AC_NAM_Assertion" = '+'
    AND
        x."AC_NAM_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_NAM_Positor", x."AC_ID"
        ORDER BY
            x."AC_NAM_ChangedAt" DESC,
            x."AC_NAM_PositedAt" DESC,
            x."AC_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."GEN_Gender" AS "GEN_Gender"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_GEN_Actor_Gender" r
    ) x
    WHERE
        x."AC_GEN_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."AC_GEN_Positor", x."AC_ID"
        ORDER BY
            x."AC_GEN_PositedAt" DESC,
            x."AC_GEN_Reliability" DESC
    )
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
    -- the knot is joined in here, with what is shown for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "PLV_Checksum",
        k."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rAC_PLV_Actor_ProfessionalLevel" r
        WHERE
            r."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    ) x
    WHERE
        x."AC_PLV_Assertion" = '+'
    AND
        x."AC_PLV_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."AC_PLV_Positor", x."AC_ID"
        ORDER BY
            x."AC_PLV_ChangedAt" DESC,
            x."AC_PLV_PositedAt" DESC,
            x."AC_PLV_Reliability" DESC
    )
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
;
CREATE OR REPLACE VIEW public."lPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_NAM_Program_Name" r
    ) x
    WHERE
        x."PR_NAM_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."PR_NAM_Positor", x."PR_ID"
        ORDER BY
            x."PR_NAM_PositedAt" DESC,
            x."PR_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rPR_LEN_Program_Length" r
    ) x
    WHERE
        x."PR_LEN_Assertion" = '+'
    AND
        x."PR_LEN_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."PR_LEN_Positor", x."PR_ID"
        ORDER BY
            x."PR_LEN_ChangedAt" DESC,
            x."PR_LEN_PositedAt" DESC,
            x."PR_LEN_Reliability" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = p."Positor"
;
CREATE OR REPLACE VIEW public."nPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
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
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_NAM_Program_Name" r
    ) x
    WHERE
        x."PR_NAM_Assertion" = '+'
    LIMIT 1 OVER (
        PARTITION BY x."PR_NAM_Positor", x."PR_ID"
        ORDER BY
            x."PR_NAM_PositedAt" DESC,
            x."PR_NAM_Reliability" DESC
    )
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor
    SELECT
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
            public."rPR_LEN_Program_Length" r
        WHERE
            r."PR_LEN_ChangedAt" <= current_timestamp::date
    ) x
    WHERE
        x."PR_LEN_Assertion" = '+'
    AND
        x."PR_LEN_ChangedAt" = x."inEffect"
    LIMIT 1 OVER (
        PARTITION BY x."PR_LEN_Positor", x."PR_ID"
        ORDER BY
            x."PR_LEN_ChangedAt" DESC,
            x."PR_LEN_PositedAt" DESC,
            x."PR_LEN_Reliability" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = p."Positor"
;
