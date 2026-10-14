-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tST_Stage" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "UTL_ID" tinyint,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "UTL_ID" tinyint
)
AS
$$
SELECT
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
LEFT JOIN
    TABLE(public."rST_NAM_Stage_Name"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."ST_NAM_ID" = (
        SELECT
            sub."ST_NAM_ID"
        FROM
            TABLE(public."rST_NAM_Stage_Name"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_NAM_Reliability" = 1
        ORDER BY
            sub."ST_NAM_ChangedAt" DESC,
            sub."ST_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public."rST_LOC_Stage_Location"(
        positingTimepoint::datetime
    )) "LOC"
ON
    "LOC"."ST_LOC_ID" = (
        SELECT
            sub."ST_LOC_ID"
        FROM
            TABLE(public."rST_LOC_Stage_Location"(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_LOC_Reliability" = 1
        ORDER BY
            sub."ST_LOC_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public."rST_AVG_Stage_Average"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "AVG"
ON
    "AVG"."ST_AVG_ID" = (
        SELECT
            sub."ST_AVG_ID"
        FROM
            TABLE(public."rST_AVG_Stage_Average"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_AVG_Reliability" = 1
        ORDER BY
            sub."ST_AVG_ChangedAt" DESC,
            sub."ST_AVG_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    TABLE(public."rST_MIN_Stage_Minimum"(
        positingTimepoint::datetime
    )) "MIN"
ON
    "MIN"."ST_MIN_ID" = (
        SELECT
            sub."ST_MIN_ID"
        FROM
            TABLE(public."rST_MIN_Stage_Minimum"(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_MIN_Reliability" = 1
        ORDER BY
            sub."ST_MIN_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$
;
CREATE OR REPLACE VIEW public."lST_Stage" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    TABLE(public."tST_Stage"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "ST"
;
CREATE OR REPLACE FUNCTION public."pST_Stage" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "ST_ID" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "UTL_ID" tinyint,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "UTL_ID" tinyint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST"."ST_ID",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Stage_Name",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Reliability",
    "ST"."UTL_Utilization",
    "ST"."UTL_ID",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Reliability",
    "ST"."UTL_Utilization",
    "ST"."UTL_ID"
FROM
    TABLE(public."tST_Stage"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "ST"
$$
;
CREATE OR REPLACE VIEW public."nST_Stage" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    TABLE(public."tST_Stage"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "ST"
;
CREATE OR REPLACE FUNCTION public."dST_Stage" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    "ST_ID" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "UTL_ID" tinyint,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "UTL_ID" tinyint
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    "ST"."ST_ID",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Stage_Name",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Reliability",
    "ST"."UTL_Utilization",
    "ST"."UTL_ID",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Reliability",
    "ST"."UTL_Utilization",
    "ST"."UTL_ID"
FROM (
    SELECT DISTINCT
        "ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."ST_NAM_Stage_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public."ST_AVG_Stage_Average"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp,
    TABLE(public."tST_Stage"(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "ST"
WHERE
    "ST"."ST_ID" = tp."ST_ID"
$$
;
CREATE OR REPLACE FUNCTION public."tAC_Actor" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Reliability" decimal(5,2),
    "GEN_Gender" varchar(42),
    "GEN_ID" number(1,0),
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Reliability" decimal(5,2),
    "PLV_Checksum" numeric(19,0),
    "PLV_ProfessionalLevel" string,
    "PLV_ID" tinyint
)
AS
$$
SELECT
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
LEFT JOIN
    TABLE(public."rAC_NAM_Actor_Name"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."AC_NAM_ID" = (
        SELECT
            sub."AC_NAM_ID"
        FROM
            TABLE(public."rAC_NAM_Actor_Name"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_NAM_Reliability" = 1
        ORDER BY
            sub."AC_NAM_ChangedAt" DESC,
            sub."AC_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public."rAC_GEN_Actor_Gender"(
        positingTimepoint::datetime
    )) "GEN"
ON
    "GEN"."AC_GEN_ID" = (
        SELECT
            sub."AC_GEN_ID"
        FROM
            TABLE(public."rAC_GEN_Actor_Gender"(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_GEN_Reliability" = 1
        ORDER BY
            sub."AC_GEN_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN
    TABLE(public."rAC_PLV_Actor_ProfessionalLevel"(
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "PLV"
ON
    "PLV"."AC_PLV_ID" = (
        SELECT
            sub."AC_PLV_ID"
        FROM
            TABLE(public."rAC_PLV_Actor_ProfessionalLevel"(
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_PLV_Reliability" = 1
        ORDER BY
            sub."AC_PLV_ChangedAt" DESC,
            sub."AC_PLV_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$
;
CREATE OR REPLACE VIEW public."lAC_Actor" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    TABLE(public."tAC_Actor"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "AC"
;
CREATE OR REPLACE FUNCTION public."pAC_Actor" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "AC_ID" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Reliability" decimal(5,2),
    "GEN_Gender" varchar(42),
    "GEN_ID" number(1,0),
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Reliability" decimal(5,2),
    "PLV_Checksum" numeric(19,0),
    "PLV_ProfessionalLevel" string,
    "PLV_ID" tinyint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC"."AC_ID",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Actor_Name",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Reliability",
    "AC"."GEN_Gender",
    "AC"."GEN_ID",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Reliability",
    "AC"."PLV_Checksum",
    "AC"."PLV_ProfessionalLevel",
    "AC"."PLV_ID"
FROM
    TABLE(public."tAC_Actor"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "AC"
$$
;
CREATE OR REPLACE VIEW public."nAC_Actor" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    TABLE(public."tAC_Actor"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "AC"
;
CREATE OR REPLACE FUNCTION public."dAC_Actor" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    "AC_ID" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Reliability" decimal(5,2),
    "GEN_Gender" varchar(42),
    "GEN_ID" number(1,0),
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Reliability" decimal(5,2),
    "PLV_Checksum" numeric(19,0),
    "PLV_ProfessionalLevel" string,
    "PLV_ID" tinyint
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    "AC"."AC_ID",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Actor_Name",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Reliability",
    "AC"."GEN_Gender",
    "AC"."GEN_ID",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Reliability",
    "AC"."PLV_Checksum",
    "AC"."PLV_ProfessionalLevel",
    "AC"."PLV_ID"
FROM (
    SELECT DISTINCT
        "AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."AC_NAM_Actor_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp,
    TABLE(public."tAC_Actor"(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "AC"
WHERE
    "AC"."AC_ID" = tp."AC_ID"
$$
;
CREATE OR REPLACE FUNCTION public."tPR_Program" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
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
LEFT JOIN
    TABLE(public."rPR_NAM_Program_Name"(
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."PR_NAM_ID" = (
        SELECT
            sub."PR_NAM_ID"
        FROM
            TABLE(public."rPR_NAM_Program_Name"(
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."PR_ID" = "PR"."PR_ID"
        AND
            sub."PR_NAM_Reliability" = 1
        ORDER BY
            sub."PR_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(public."rPR_LEN_Program_Length"(
        changingTimepoint::date,
        positingTimepoint::datetime
    )) "LEN"
ON
    "LEN"."PR_LEN_ID" = (
        SELECT
            sub."PR_LEN_ID"
        FROM
            TABLE(public."rPR_LEN_Program_Length"(
                changingTimepoint::date,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."PR_ID" = "PR"."PR_ID"
        AND
            sub."PR_LEN_Reliability" = 1
        ORDER BY
            sub."PR_LEN_ChangedAt" DESC,
            sub."PR_LEN_PositedAt" DESC
        LIMIT 1
    )
$$
;
CREATE OR REPLACE VIEW public."lPR_Program" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    TABLE(public."tPR_Program"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "PR"
;
CREATE OR REPLACE FUNCTION public."pPR_Program" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "PR_ID" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR"."PR_ID",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Program_Name",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Program_Length"
FROM
    TABLE(public."tPR_Program"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "PR"
$$
;
CREATE OR REPLACE VIEW public."nPR_Program" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    TABLE(public."tPR_Program"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "PR"
;
CREATE OR REPLACE FUNCTION public."dPR_Program" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    "PR_ID" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    tp.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Program_Name",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        "PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public."PR_LEN_Program_Length"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp,
    TABLE(public."tPR_Program"(
        tp.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "PR"
WHERE
    "PR"."PR_ID" = tp."PR_ID"
$$
;
