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
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."ST_NAM_Stage_Name" h
    LIMIT 1 OVER (
        PARTITION BY h."ST_NAM_ST_ID"
        ORDER BY h."ST_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."ST_AVG_Stage_Average" h
    LIMIT 1 OVER (
        PARTITION BY h."ST_AVG_ST_ID"
        ORDER BY h."ST_AVG_ChangedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
;
CREATE OR REPLACE VIEW public."nST_Stage" AS
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
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
        PARTITION BY h."ST_NAM_ST_ID"
        ORDER BY h."ST_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."ST_AVG_Stage_Average" h
    WHERE
        h."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."ST_AVG_ST_ID"
        ORDER BY h."ST_AVG_ChangedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
;
CREATE OR REPLACE VIEW public."lAC_Actor" AS
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."AC_NAM_Actor_Name" h
    LIMIT 1 OVER (
        PARTITION BY h."AC_NAM_AC_ID"
        ORDER BY h."AC_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."AC_PLV_Actor_ProfessionalLevel" h
    LIMIT 1 OVER (
        PARTITION BY h."AC_PLV_AC_ID"
        ORDER BY h."AC_PLV_ChangedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW public."nAC_Actor" AS
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
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
        PARTITION BY h."AC_NAM_AC_ID"
        ORDER BY h."AC_NAM_ChangedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        h."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY h."AC_PLV_AC_ID"
        ORDER BY h."AC_PLV_ChangedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW public."lPR_Program" AS
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."PR_LEN_Program_Length" h
    LIMIT 1 OVER (
        PARTITION BY h."PR_LEN_PR_ID"
        ORDER BY h."PR_LEN_ChangedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
CREATE OR REPLACE VIEW public."nPR_Program" AS
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest value of each anchor
    SELECT
        h.*
    FROM
        public."PR_LEN_Program_Length" h
    WHERE
        h."PR_LEN_ChangedAt" <= current_timestamp::date
    LIMIT 1 OVER (
        PARTITION BY h."PR_LEN_PR_ID"
        ORDER BY h."PR_LEN_ChangedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
