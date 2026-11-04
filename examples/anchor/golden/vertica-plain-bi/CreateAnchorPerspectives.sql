-- ANCHOR TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI anchor perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that
-- take a time (time traveling, point-in-time and difference) are not made; the latest and the now perspectives take none,
-- and are views over the rewinders of the attributes (views that show the latest annex row of every posit).
--
CREATE OR REPLACE VIEW public."lST_Stage" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "AVG"."UTL_ID",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_NAM_Stage_Name" r
    WHERE
        r."ST_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_NAM_ChangedAt" DESC,
            r."ST_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_LOC_Stage_Location" r
    WHERE
        r."ST_LOC_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_LOC_PositedAt" DESC
    )
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_AVG_Stage_Average" r
    WHERE
        r."ST_AVG_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_AVG_ChangedAt" DESC,
            r."ST_AVG_PositedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_MIN_Stage_Minimum" r
    WHERE
        r."ST_MIN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_MIN_PositedAt" DESC
    )
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
;
CREATE OR REPLACE VIEW public."nST_Stage" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "AVG"."UTL_ID",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_NAM_Stage_Name" r
    WHERE
        r."ST_NAM_Reliability" = 1
    AND
        r."ST_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_NAM_ChangedAt" DESC,
            r."ST_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_LOC_Stage_Location" r
    WHERE
        r."ST_LOC_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_LOC_PositedAt" DESC
    )
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_AVG_Stage_Average" r
    WHERE
        r."ST_AVG_Reliability" = 1
    AND
        r."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_AVG_ChangedAt" DESC,
            r."ST_AVG_PositedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rST_MIN_Stage_Minimum" r
    WHERE
        r."ST_MIN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_ID"
        ORDER BY
            r."ST_MIN_PositedAt" DESC
    )
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
;
CREATE OR REPLACE VIEW public."lAC_Actor" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rAC_NAM_Actor_Name" r
    WHERE
        r."AC_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_ID"
        ORDER BY
            r."AC_NAM_ChangedAt" DESC,
            r."AC_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rAC_GEN_Actor_Gender" r
    WHERE
        r."AC_GEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_ID"
        ORDER BY
            r."AC_GEN_PositedAt" DESC
    )
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rAC_PLV_Actor_ProfessionalLevel" r
    WHERE
        r."AC_PLV_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_ID"
        ORDER BY
            r."AC_PLV_ChangedAt" DESC,
            r."AC_PLV_PositedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
;
CREATE OR REPLACE VIEW public."nAC_Actor" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rAC_NAM_Actor_Name" r
    WHERE
        r."AC_NAM_Reliability" = 1
    AND
        r."AC_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."AC_ID"
        ORDER BY
            r."AC_NAM_ChangedAt" DESC,
            r."AC_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rAC_GEN_Actor_Gender" r
    WHERE
        r."AC_GEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_ID"
        ORDER BY
            r."AC_GEN_PositedAt" DESC
    )
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rAC_PLV_Actor_ProfessionalLevel" r
    WHERE
        r."AC_PLV_Reliability" = 1
    AND
        r."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."AC_ID"
        ORDER BY
            r."AC_PLV_ChangedAt" DESC,
            r."AC_PLV_PositedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
;
CREATE OR REPLACE VIEW public."lPR_Program" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rPR_NAM_Program_Name" r
    WHERE
        r."PR_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_ID"
        ORDER BY
            r."PR_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rPR_LEN_Program_Length" r
    WHERE
        r."PR_LEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_ID"
        ORDER BY
            r."PR_LEN_ChangedAt" DESC,
            r."PR_LEN_PositedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
;
CREATE OR REPLACE VIEW public."nPR_Program" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rPR_NAM_Program_Name" r
    WHERE
        r."PR_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_ID"
        ORDER BY
            r."PR_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        public."rPR_LEN_Program_Length" r
    WHERE
        r."PR_LEN_Reliability" = 1
    AND
        r."PR_LEN_ChangedAt" <= current_timestamp::date
    LIMIT 1 OVER (
        PARTITION BY r."PR_ID"
        ORDER BY
            r."PR_LEN_ChangedAt" DESC,
            r."PR_LEN_PositedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
;
