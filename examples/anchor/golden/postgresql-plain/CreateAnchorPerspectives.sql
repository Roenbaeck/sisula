-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lST_Stage" (
    "ST_ID",
    "ST_NAM_ChangedAt",
    "ST_NAM_Stage_Name",
    "ST_LOC_Checksum",
    "ST_LOC_Stage_Location",
    "ST_AVG_ChangedAt",
    "UTL_Utilization",
    "UTL_ID",
    "UTL_Utilization",
    "UTL_ID"
)
AS
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
LEFT JOIN
    public."ST_NAM_Stage_Name" "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            public."ST_NAM_Stage_Name" sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."ST_AVG_Stage_Average" "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            public."ST_AVG_Stage_Average" sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
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
    "kMIN"."UTL_ID" = "MIN"."UTL_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_Stage" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ChangedAt" timestamp,
    "UTL_Utilization" smallint,
    "UTL_ID" smallint,
    "UTL_Utilization" smallint,
    "UTL_ID" smallint
)
AS
$$
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
LEFT JOIN
    public."rST_NAM_Stage_Name"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            public."rST_NAM_Stage_Name"(changingTimepoint::timestamp) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."rST_AVG_Stage_Average"(changingTimepoint::timestamp) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            public."rST_AVG_Stage_Average"(changingTimepoint::timestamp) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
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
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_Stage"
AS
SELECT
    *
FROM
    public."pST_Stage"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_Stage" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "ST_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ChangedAt" timestamp,
    "UTL_Utilization" smallint,
    "UTL_ID" smallint,
    "UTL_Utilization" smallint,
    "UTL_ID" smallint
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
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
FROM (
    SELECT DISTINCT
        h."ST_ID" AS "ST_ID",
        h."ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."ST_NAM_Stage_Name" h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."ST_ID" AS "ST_ID",
        h."ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public."ST_AVG_Stage_Average" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."ST_Stage" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."ST_NAM_ChangedAt") OVER (
            PARTITION BY h."ST_ID"
            ORDER BY h."ST_NAM_ChangedAt"
        ) AS "until"
    FROM
        public."ST_NAM_Stage_Name" h
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."ST_LOC_Stage_Location" "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."ST_AVG_ChangedAt") OVER (
            PARTITION BY h."ST_ID"
            ORDER BY h."ST_AVG_ChangedAt"
        ) AS "until"
    FROM
        public."ST_AVG_Stage_Average" h
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
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
LEFT JOIN
    public."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_Actor" (
    "AC_ID",
    "AC_NAM_ChangedAt",
    "AC_NAM_Actor_Name",
    "GEN_Gender",
    "GEN_ID",
    "AC_PLV_ChangedAt",
    "PLV_Checksum",
    "PLV_ProfessionalLevel",
    "PLV_ID"
)
AS
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
LEFT JOIN
    public."AC_NAM_Actor_Name" "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            public."AC_NAM_Actor_Name" sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN
    public."AC_PLV_Actor_ProfessionalLevel" "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            public."AC_PLV_Actor_ProfessionalLevel" sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_Actor" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "GEN_Gender" varchar(42),
    "GEN_ID" smallint,
    "AC_PLV_ChangedAt" timestamp,
    "PLV_Checksum" bytea,
    "PLV_ProfessionalLevel" text,
    "PLV_ID" smallint
)
AS
$$
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
LEFT JOIN
    public."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            public."rAC_NAM_Actor_Name"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN
    public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::timestamp) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_Actor"
AS
SELECT
    *
FROM
    public."pAC_Actor"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_Actor" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "AC_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_Actor_Name" varchar(42),
    "GEN_Gender" varchar(42),
    "GEN_ID" smallint,
    "AC_PLV_ChangedAt" timestamp,
    "PLV_Checksum" bytea,
    "PLV_ProfessionalLevel" text,
    "PLV_ID" smallint
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "AC"."AC_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "GEN"."GEN_ID",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "PLV"."PLV_ID"
FROM (
    SELECT DISTINCT
        h."AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."AC_NAM_Actor_Name" h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."AC_ID" AS "AC_ID",
        h."AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."AC_Actor" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."AC_NAM_ChangedAt") OVER (
            PARTITION BY h."AC_ID"
            ORDER BY h."AC_NAM_ChangedAt"
        ) AS "until"
    FROM
        public."AC_NAM_Actor_Name" h
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."AC_PLV_ChangedAt") OVER (
            PARTITION BY h."AC_ID"
            ORDER BY h."AC_PLV_ChangedAt"
        ) AS "until"
    FROM
        public."AC_PLV_Actor_ProfessionalLevel" h
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_Program" (
    "PR_ID",
    "PR_NAM_Program_Name",
    "PR_LEN_ChangedAt",
    "PR_LEN_Program_Length"
)
AS
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
LEFT JOIN
    public."PR_LEN_Program_Length" "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            public."PR_LEN_Program_Length" sub
        WHERE
            sub."PR_ID" = "PR"."PR_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_Program" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_ID" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
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
LEFT JOIN
    public."rPR_LEN_Program_Length"(changingTimepoint::date) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            public."rPR_LEN_Program_Length"(changingTimepoint::date) sub
        WHERE
            sub."PR_ID" = "PR"."PR_ID"
   )
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_Program"
AS
SELECT
    *
FROM
    public."pPR_Program"(current_timestamp::timestamp)
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dPR_Program" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    mnemonic text,
    "PR_ID" integer,
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_ChangedAt" date,
    "PR_LEN_Program_Length" time
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. The point-in-time perspective is not called for each change; the values are worked out
-- for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "PR"."PR_ID",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        h."PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public."PR_LEN_Program_Length" h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    public."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    SELECT
        h.*,
        lead(h."PR_LEN_ChangedAt") OVER (
            PARTITION BY h."PR_ID"
            ORDER BY h."PR_LEN_ChangedAt"
        ) AS "until"
    FROM
        public."PR_LEN_Program_Length" h
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LEN"."until" IS NULL
OR
    "LEN"."until" > timepoints.inspectedTimepoint::date
)
$$ LANGUAGE sql STABLE;
