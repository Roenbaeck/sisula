-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lST_Stage" (
    "ST_ID",
    "ST_NAM_ST_ID",
    "ST_NAM_ChangedAt",
    "ST_NAM_EQ",
    "ST_NAM_Checksum",
    "ST_NAM_Stage_Name" COMMENT 'Name of the stage. Historized, since a stage may be renamed over time.',
    "ST_LOC_ST_ID",
    "ST_LOC_EQ",
    "ST_LOC_Checksum",
    "ST_LOC_Stage_Location" COMMENT 'Geographic location of the stage as a geography point.',
    "ST_AVG_ST_ID",
    "ST_AVG_ChangedAt",
    "ST_AVG_UTL_Utilization" COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    "ST_AVG_UTL_ID" COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    "ST_MIN_ST_ID",
    "ST_MIN_UTL_Utilization" COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.',
    "ST_MIN_UTL_ID" COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.'
) COPY GRANTS COMMENT = 'A stage or venue where programs are played and events are held.'
AS
SELECT
    "ST"."ST_ID",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Checksum",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "MIN"."ST_MIN_UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN
    TABLE(public."eST_NAM_Stage_Name"(0)) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(public."eST_NAM_Stage_Name"(0)) sub 
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(public."eST_LOC_Stage_Location"(0)) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."ST_AVG_Stage_Average" "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            public."ST_AVG_Stage_Average" sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
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
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_Stage" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Checksum" numeric(19,0),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utilization" tinyint,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "ST_MIN_UTL_Utilization" tinyint,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Checksum",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "MIN"."ST_MIN_UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN
    TABLE(public."rST_NAM_Stage_Name"(0, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(public."rST_NAM_Stage_Name"(0, changingTimepoint::datetime)) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(public."eST_LOC_Stage_Location"(0)) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    TABLE(public."rST_AVG_Stage_Average"(changingTimepoint::datetime)) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            TABLE(public."rST_AVG_Stage_Average"(changingTimepoint::datetime)) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
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
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_Stage" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(public."pST_Stage"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_Stage" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "ST_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Checksum" numeric(19,0),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utilization" tinyint,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "ST_MIN_UTL_Utilization" tinyint,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pST"."ST_ID",
    "pST"."ST_NAM_ST_ID",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Checksum",
    "pST"."ST_NAM_Stage_Name",
    "pST"."ST_LOC_ST_ID",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Stage_Location",
    "pST"."ST_AVG_ST_ID",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utilization",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."ST_MIN_UTL_Utilization",
    "pST"."ST_MIN_UTL_ID"
FROM
    TABLE(public."eST_NAM_Stage_Name"(0)) "hNAM", 
    TABLE(public."pST_Stage"("hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hNAM"."ST_NAM_ST_ID"
UNION
SELECT DISTINCT
    "hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'AVG' AS mnemonic,
    "pST"."ST_ID",
    "pST"."ST_NAM_ST_ID",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Checksum",
    "pST"."ST_NAM_Stage_Name",
    "pST"."ST_LOC_ST_ID",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Stage_Location",
    "pST"."ST_AVG_ST_ID",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utilization",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."ST_MIN_UTL_Utilization",
    "pST"."ST_MIN_UTL_ID"
FROM
    public."ST_AVG_Stage_Average" "hAVG",
    TABLE(public."pST_Stage"("hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%AVG%')
AND
    "hAVG"."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hAVG"."ST_AVG_ST_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."epST_Stage" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Checksum" numeric(19,0),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utilization" tinyint,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "ST_MIN_UTL_Utilization" tinyint,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Checksum",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "MIN"."ST_MIN_UTL_ID"
FROM
    public."ST_Stage" "ST"
LEFT JOIN
    TABLE(public."rST_NAM_Stage_Name"(equivalent, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(public."rST_NAM_Stage_Name"(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(public."eST_LOC_Stage_Location"(equivalent)) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    TABLE(public."rST_AVG_Stage_Average"(changingTimepoint::datetime)) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            TABLE(public."rST_AVG_Stage_Average"(changingTimepoint::datetime)) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
   )
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
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."elST_Stage" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Checksum" numeric(19,0),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utilization" tinyint,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "ST_MIN_UTL_Utilization" tinyint,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public."epST_Stage"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."enST_Stage" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Checksum" numeric(19,0),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utilization" tinyint,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "ST_MIN_UTL_Utilization" tinyint,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public."epST_Stage"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."edST_Stage" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "ST_ID" int,
    "ST_NAM_ST_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Checksum" numeric(19,0),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_UTL_Utilization" tinyint,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "ST_MIN_UTL_Utilization" tinyint,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pST"."ST_ID",
    "pST"."ST_NAM_ST_ID",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Checksum",
    "pST"."ST_NAM_Stage_Name",
    "pST"."ST_LOC_ST_ID",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Stage_Location",
    "pST"."ST_AVG_ST_ID",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utilization",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."ST_MIN_UTL_Utilization",
    "pST"."ST_MIN_UTL_ID"
FROM
    TABLE(public."eST_NAM_Stage_Name"(equivalent)) "hNAM", 
    TABLE(public."epST_Stage"(equivalent, "hNAM"."ST_NAM_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hNAM"."ST_NAM_ST_ID"
UNION
SELECT DISTINCT
    "hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'AVG' AS mnemonic,
    "pST"."ST_ID",
    "pST"."ST_NAM_ST_ID",
    "pST"."ST_NAM_ChangedAt",
    "pST"."ST_NAM_EQ",
    "pST"."ST_NAM_Checksum",
    "pST"."ST_NAM_Stage_Name",
    "pST"."ST_LOC_ST_ID",
    "pST"."ST_LOC_EQ",
    "pST"."ST_LOC_Checksum",
    "pST"."ST_LOC_Stage_Location",
    "pST"."ST_AVG_ST_ID",
    "pST"."ST_AVG_ChangedAt",
    "pST"."ST_AVG_UTL_Utilization",
    "pST"."ST_AVG_UTL_ID",
    "pST"."ST_MIN_ST_ID",
    "pST"."ST_MIN_UTL_Utilization",
    "pST"."ST_MIN_UTL_ID"
FROM
    public."ST_AVG_Stage_Average" "hAVG",
    TABLE(public."epST_Stage"(equivalent, "hAVG"."ST_AVG_ChangedAt"::timestamp_ntz(9))) "pST"
WHERE
    (selection IS NULL OR selection LIKE '%AVG%')
AND
    "hAVG"."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pST"."ST_ID" = "hAVG"."ST_AVG_ST_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_Actor" (
    "AC_ID",
    "AC_NAM_AC_ID",
    "AC_NAM_ChangedAt",
    "AC_NAM_EQ",
    "AC_NAM_Checksum",
    "AC_NAM_Actor_Name" COMMENT 'Name of the actor, such as a stage name. Historized, since it may change over time.',
    "AC_GEN_AC_ID",
    "AC_GEN_GEN_EQ",
    "AC_GEN_GEN_Gender" COMMENT 'Gender of the actor.',
    "AC_GEN_GEN_ID" COMMENT 'Gender of the actor.',
    "AC_PLV_AC_ID",
    "AC_PLV_ChangedAt",
    "AC_PLV_PLV_Checksum",
    "AC_PLV_PLV_ProfessionalLevel" COMMENT 'Professional level of the actor, which may change as the actor gains experience.',
    "AC_PLV_PLV_ID" COMMENT 'Professional level of the actor, which may change as the actor gains experience.'
) COPY GRANTS COMMENT = 'An actor, a person who performs parts in programs and is cast in events.'
AS
SELECT
    "AC"."AC_ID",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_EQ",
    "NAM"."AC_NAM_Checksum",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "kGEN"."GEN_EQ" AS "AC_GEN_GEN_EQ",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN
    TABLE(public."eAC_NAM_Actor_Name"(0)) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            TABLE(public."eAC_NAM_Actor_Name"(0)) sub 
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    TABLE(public."eGEN_Gender"(0)) "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    public."AC_PLV_Actor_ProfessionalLevel" "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            public."AC_PLV_Actor_ProfessionalLevel" sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_Actor" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "AC_NAM_AC_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_EQ" tinyint,
    "AC_NAM_Checksum" numeric(19,0),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" int,
    "AC_GEN_GEN_EQ" tinyint,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_ProfessionalLevel" string,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_EQ",
    "NAM"."AC_NAM_Checksum",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "kGEN"."GEN_EQ" AS "AC_GEN_GEN_EQ",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN
    TABLE(public."rAC_NAM_Actor_Name"(0, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            TABLE(public."rAC_NAM_Actor_Name"(0, changingTimepoint::datetime)) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    TABLE(public."eGEN_Gender"(0)) "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    TABLE(public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            TABLE(public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_Actor" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(public."pAC_Actor"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_Actor" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "AC_ID" int,
    "AC_NAM_AC_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_EQ" tinyint,
    "AC_NAM_Checksum" numeric(19,0),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" int,
    "AC_GEN_GEN_EQ" tinyint,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_ProfessionalLevel" string,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_EQ",
    "pAC"."AC_NAM_Checksum",
    "pAC"."AC_NAM_Actor_Name",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."AC_GEN_GEN_EQ",
    "pAC"."AC_GEN_GEN_Gender",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_ProfessionalLevel",
    "pAC"."AC_PLV_PLV_ID"
FROM
    TABLE(public."eAC_NAM_Actor_Name"(0)) "hNAM", 
    TABLE(public."pAC_Actor"("hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hNAM"."AC_NAM_AC_ID"
UNION
SELECT DISTINCT
    "hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'PLV' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_EQ",
    "pAC"."AC_NAM_Checksum",
    "pAC"."AC_NAM_Actor_Name",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."AC_GEN_GEN_EQ",
    "pAC"."AC_GEN_GEN_Gender",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_ProfessionalLevel",
    "pAC"."AC_PLV_PLV_ID"
FROM
    public."AC_PLV_Actor_ProfessionalLevel" "hPLV",
    TABLE(public."pAC_Actor"("hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%PLV%')
AND
    "hPLV"."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hPLV"."AC_PLV_AC_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."epAC_Actor" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "AC_NAM_AC_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_EQ" tinyint,
    "AC_NAM_Checksum" numeric(19,0),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" int,
    "AC_GEN_GEN_EQ" tinyint,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_ProfessionalLevel" string,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_EQ",
    "NAM"."AC_NAM_Checksum",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "kGEN"."GEN_EQ" AS "AC_GEN_GEN_EQ",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."AC_Actor" "AC"
LEFT JOIN
    TABLE(public."rAC_NAM_Actor_Name"(equivalent, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            TABLE(public."rAC_NAM_Actor_Name"(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    TABLE(public."eGEN_Gender"(equivalent)) "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    TABLE(public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            TABLE(public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."elAC_Actor" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "AC_NAM_AC_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_EQ" tinyint,
    "AC_NAM_Checksum" numeric(19,0),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" int,
    "AC_GEN_GEN_EQ" tinyint,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_ProfessionalLevel" string,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public."epAC_Actor"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."enAC_Actor" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" int,
    "AC_NAM_AC_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_EQ" tinyint,
    "AC_NAM_Checksum" numeric(19,0),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" int,
    "AC_GEN_GEN_EQ" tinyint,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_ProfessionalLevel" string,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(public."epAC_Actor"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."edAC_Actor" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "AC_ID" int,
    "AC_NAM_AC_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_EQ" tinyint,
    "AC_NAM_Checksum" numeric(19,0),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" int,
    "AC_GEN_GEN_EQ" tinyint,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_ProfessionalLevel" string,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT DISTINCT
    "hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'NAM' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_EQ",
    "pAC"."AC_NAM_Checksum",
    "pAC"."AC_NAM_Actor_Name",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."AC_GEN_GEN_EQ",
    "pAC"."AC_GEN_GEN_Gender",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_ProfessionalLevel",
    "pAC"."AC_PLV_PLV_ID"
FROM
    TABLE(public."eAC_NAM_Actor_Name"(equivalent)) "hNAM", 
    TABLE(public."epAC_Actor"(equivalent, "hNAM"."AC_NAM_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%NAM%')
AND
    "hNAM"."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hNAM"."AC_NAM_AC_ID"
UNION
SELECT DISTINCT
    "hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'PLV' AS mnemonic,
    "pAC"."AC_ID",
    "pAC"."AC_NAM_AC_ID",
    "pAC"."AC_NAM_ChangedAt",
    "pAC"."AC_NAM_EQ",
    "pAC"."AC_NAM_Checksum",
    "pAC"."AC_NAM_Actor_Name",
    "pAC"."AC_GEN_AC_ID",
    "pAC"."AC_GEN_GEN_EQ",
    "pAC"."AC_GEN_GEN_Gender",
    "pAC"."AC_GEN_GEN_ID",
    "pAC"."AC_PLV_AC_ID",
    "pAC"."AC_PLV_ChangedAt",
    "pAC"."AC_PLV_PLV_Checksum",
    "pAC"."AC_PLV_PLV_ProfessionalLevel",
    "pAC"."AC_PLV_PLV_ID"
FROM
    public."AC_PLV_Actor_ProfessionalLevel" "hPLV",
    TABLE(public."epAC_Actor"(equivalent, "hPLV"."AC_PLV_ChangedAt"::timestamp_ntz(9))) "pAC"
WHERE
    (selection IS NULL OR selection LIKE '%PLV%')
AND
    "hPLV"."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pAC"."AC_ID" = "hPLV"."AC_PLV_AC_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_Program" (
    "PR_ID",
    "PR_NAM_PR_ID",
    "PR_NAM_Program_Name" COMMENT 'Name or title of the program.',
    "PR_LEN_PR_ID",
    "PR_LEN_ChangedAt",
    "PR_LEN_Program_Length" COMMENT 'Running time of the program. Historized, since the program may be shortened or extended over time.'
) COPY GRANTS COMMENT = 'A program, such as a play, show or concert, that can be played on stages.'
AS
SELECT
    "PR"."PR_ID",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    public."PR_LEN_Program_Length" "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            public."PR_LEN_Program_Length" sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_Program" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" int,
    "PR_NAM_PR_ID" int,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(public."rPR_LEN_Program_Length"(changingTimepoint::date)) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(public."rPR_LEN_Program_Length"(changingTimepoint::date)) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_Program" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(public."pPR_Program"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dPR_Program" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "PR_ID" int,
    "PR_NAM_PR_ID" int,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT DISTINCT
    "hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    "pPR"."PR_ID",
    "pPR"."PR_NAM_PR_ID",
    "pPR"."PR_NAM_Program_Name",
    "pPR"."PR_LEN_PR_ID",
    "pPR"."PR_LEN_ChangedAt",
    "pPR"."PR_LEN_Program_Length"
FROM
    public."PR_LEN_Program_Length" "hLEN",
    TABLE(public."pPR_Program"("hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9))) "pPR"
WHERE
    (selection IS NULL OR selection LIKE '%LEN%')
AND
    "hLEN"."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pPR"."PR_ID" = "hLEN"."PR_LEN_PR_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."epPR_Program" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" int,
    "PR_NAM_PR_ID" int,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(public."rPR_LEN_Program_Length"(changingTimepoint::date)) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(public."rPR_LEN_Program_Length"(changingTimepoint::date)) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."elPR_Program" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" int,
    "PR_NAM_PR_ID" int,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    *
FROM
    TABLE(public."epPR_Program"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."enPR_Program" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" int,
    "PR_NAM_PR_ID" int,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    *
FROM
    TABLE(public."epPR_Program"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."edPR_Program" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "PR_ID" int,
    "PR_NAM_PR_ID" int,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT DISTINCT
    "hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
    'LEN' AS mnemonic,
    "pPR"."PR_ID",
    "pPR"."PR_NAM_PR_ID",
    "pPR"."PR_NAM_Program_Name",
    "pPR"."PR_LEN_PR_ID",
    "pPR"."PR_LEN_ChangedAt",
    "pPR"."PR_LEN_Program_Length"
FROM
    public."PR_LEN_Program_Length" "hLEN",
    TABLE(public."epPR_Program"(equivalent, "hLEN"."PR_LEN_ChangedAt"::timestamp_ntz(9))) "pPR"
WHERE
    (selection IS NULL OR selection LIKE '%LEN%')
AND
    "hLEN"."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
AND
    "pPR"."PR_ID" = "hLEN"."PR_LEN_PR_ID"
$$
;
