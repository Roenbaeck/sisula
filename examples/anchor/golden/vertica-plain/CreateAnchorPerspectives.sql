-- ANCHOR TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- Uni-temporal anchor perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the
-- perspectives that take a time (point-in-time and difference) are not made; the latest and the now perspectives take
-- none, and are views. The latest shows the value with the latest changing time of every historized attribute, which may
-- be in the future; the now shows the latest that is not.
--
CREATE OR REPLACE VIEW public."lST_Stage" AS
SELECT
    "ST"."ST_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "AVG"."UTL_ID",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."ST_NAM_Stage_Name" h
    LIMIT 1 OVER (
        PARTITION BY h."ST_ID"
        ORDER BY h."ST_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."ST_AVG_Stage_Average" h
    LIMIT 1 OVER (
        PARTITION BY h."ST_ID"
        ORDER BY h."ST_AVG_ChangedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
;
CREATE OR REPLACE VIEW public."nST_Stage" AS
SELECT
    "ST"."ST_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "AVG"."UTL_ID",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "MIN"."UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."ST_NAM_Stage_Name" h
    WHERE
        h."ST_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."ST_ID"
        ORDER BY h."ST_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."ST_AVG_Stage_Average" h
    WHERE
        h."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."ST_ID"
        ORDER BY h."ST_AVG_ChangedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
;
CREATE OR REPLACE VIEW public."lAC_Actor" AS
SELECT
    "AC"."AC_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."AC_NAM_Actor_Name" h
    LIMIT 1 OVER (
        PARTITION BY h."AC_ID"
        ORDER BY h."AC_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."AC_PLV_Actor_ProfessionalLevel" h
    LIMIT 1 OVER (
        PARTITION BY h."AC_ID"
        ORDER BY h."AC_PLV_ChangedAt" DESC
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
    "AC"."AC_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."AC_NAM_Actor_Name" h
    WHERE
        h."AC_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."AC_ID"
        ORDER BY h."AC_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        h."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."AC_ID"
        ORDER BY h."AC_PLV_ChangedAt" DESC
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
    "PR"."PR_ID",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."PR_LEN_Program_Length" h
    LIMIT 1 OVER (
        PARTITION BY h."PR_ID"
        ORDER BY h."PR_LEN_ChangedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
;
CREATE OR REPLACE VIEW public."nPR_Program" AS
SELECT
    "PR"."PR_ID",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."PR_LEN_Program_Length" h
    WHERE
        h."PR_LEN_ChangedAt" <= current_timestamp::date
    LIMIT 1 OVER (
        PARTITION BY h."PR_ID"
        ORDER BY h."PR_LEN_ChangedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
;
