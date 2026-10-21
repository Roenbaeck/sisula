-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native anchor perspectives: latest (l), point-in-time (p), now (n), difference (d),
-- and their equivalence variants (el, ep, en, ed).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lST_Stage" (
    "ST_ID",
    "Metadata_ST",
    "Metadata_ST_NAM",
    "ST_NAM_ChangedAt",
    "ST_NAM_EQ",
    "ST_NAM_Stage_Name" COMMENT 'Name of the stage. Historized, since a stage may be renamed over time.',
    "Metadata_ST_LOC",
    "ST_LOC_EQ",
    "ST_LOC_Checksum",
    "ST_LOC_Stage_Location" COMMENT 'Geographic location of the stage as a geography point.',
    "Metadata_ST_AVG",
    "ST_AVG_ChangedAt",
    "UTL_Utilization" COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    "Metadata_UTL",
    "UTL_ID" COMMENT 'Average utilization of the stage capacity, recalculated over time.',
    "Metadata_ST_MIN",
    "UTL_Utilization" COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.',
    "Metadata_UTL",
    "UTL_ID" COMMENT 'Minimum utilization of the stage capacity required for a performance to take place.'
) COPY GRANTS COMMENT = 'A stage or venue where programs are played and events are held.'
AS
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "Metadata_UTL",
    "AVG"."UTL_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "Metadata_UTL",
    "MIN"."UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN
    TABLE(attributes."eST_NAM_Stage_Name"(0)) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(attributes."eST_NAM_Stage_Name"(0)) sub 
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(attributes."eST_LOC_Stage_Location"(0)) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    attributes."ST_AVG_Stage_Average" "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            attributes."ST_AVG_Stage_Average" sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pST_Stage" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "Metadata_UTL",
    "AVG"."UTL_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "Metadata_UTL",
    "MIN"."UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN
    TABLE(attributes."rST_NAM_Stage_Name"(0, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(attributes."rST_NAM_Stage_Name"(0, changingTimepoint::datetime)) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(attributes."eST_LOC_Stage_Location"(0)) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    TABLE(attributes."rST_AVG_Stage_Average"(changingTimepoint::datetime)) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            TABLE(attributes."rST_AVG_Stage_Average"(changingTimepoint::datetime)) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nST_Stage" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(anchors."pST_Stage"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dST_Stage" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. Snowflake cannot call the point-in-time perspective for each change, since it cannot
-- evaluate a function with an outer join on its argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "Metadata_UTL",
    "AVG"."UTL_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "Metadata_UTL",
    "MIN"."UTL_ID"
FROM (
    SELECT DISTINCT
        h."ST_ID" AS "ST_ID",
        h."ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        TABLE(attributes."eST_NAM_Stage_Name"(0)) h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."ST_ID" AS "ST_ID",
        h."ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Stage_Average" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Stage" "ST"
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
        TABLE(attributes."eST_NAM_Stage_Name"(0)) h
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    TABLE(attributes."eST_LOC_Stage_Location"(0)) "LOC"
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
        attributes."ST_AVG_Stage_Average" h
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epST_Stage" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "Metadata_UTL",
    "AVG"."UTL_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "Metadata_UTL",
    "MIN"."UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN
    TABLE(attributes."rST_NAM_Stage_Name"(equivalent, changingTimepoint::datetime)) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" = (
        SELECT
            max(sub."ST_NAM_ChangedAt")
        FROM
            TABLE(attributes."rST_NAM_Stage_Name"(equivalent, changingTimepoint::datetime)) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    TABLE(attributes."eST_LOC_Stage_Location"(equivalent)) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    TABLE(attributes."rST_AVG_Stage_Average"(changingTimepoint::datetime)) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" = (
        SELECT
            max(sub."ST_AVG_ChangedAt")
        FROM
            TABLE(attributes."rST_AVG_Stage_Average"(changingTimepoint::datetime)) sub
        WHERE
            sub."ST_ID" = "ST"."ST_ID"
   )
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elST_Stage" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epST_Stage"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enST_Stage" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epST_Stage"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edST_Stage" (
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
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_EQ" tinyint,
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_EQ" tinyint,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ChangedAt" datetime,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_EQ",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_EQ",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ChangedAt",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "Metadata_UTL",
    "AVG"."UTL_ID",
    "MIN"."Metadata_ST_MIN",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "Metadata_UTL",
    "MIN"."UTL_ID"
FROM (
    SELECT DISTINCT
        h."ST_ID" AS "ST_ID",
        h."ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        TABLE(attributes."eST_NAM_Stage_Name"(equivalent)) h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."ST_ID" AS "ST_ID",
        h."ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Stage_Average" h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h."ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Stage" "ST"
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
        TABLE(attributes."eST_NAM_Stage_Name"(equivalent)) h
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    TABLE(attributes."eST_LOC_Stage_Location"(equivalent)) "LOC"
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
        attributes."ST_AVG_Stage_Average" h
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN
    attributes."ST_MIN_Stage_Minimum" "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lAC_Actor" (
    "AC_ID",
    "Metadata_AC",
    "Metadata_AC_NAM",
    "AC_NAM_ChangedAt",
    "AC_NAM_Actor_Name" COMMENT 'Name of the actor, such as a stage name. Historized, since it may change over time.',
    "Metadata_AC_GEN",
    "GEN_Checksum",
    "GEN_Gender" COMMENT 'Gender of the actor.',
    "Metadata_GEN",
    "GEN_ID" COMMENT 'Gender of the actor.',
    "Metadata_AC_PLV",
    "AC_PLV_ChangedAt",
    "PLV_Checksum",
    "PLV_EQ",
    "PLV_ProfessionalLevel" COMMENT 'Professional level of the actor, which may change as the actor gains experience.',
    "Metadata_PLV",
    "PLV_ID" COMMENT 'Professional level of the actor, which may change as the actor gains experience.'
) COPY GRANTS COMMENT = 'An actor, a person who performs parts in programs and is cast in events.'
AS
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "GEN_Checksum",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "kGEN"."Metadata_GEN" AS "Metadata_GEN",
    "GEN"."GEN_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_EQ" AS "PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "Metadata_PLV",
    "PLV"."PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN
    attributes."AC_NAM_Actor_Name" "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            attributes."AC_NAM_Actor_Name" sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel" "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            attributes."AC_PLV_Actor_ProfessionalLevel" sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_ProfessionalLevel"(0)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID";
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pAC_Actor" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "PLV_Checksum" numeric(19,0),
    "PLV_EQ" tinyint,
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "GEN_Checksum",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "kGEN"."Metadata_GEN" AS "Metadata_GEN",
    "GEN"."GEN_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_EQ" AS "PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "Metadata_PLV",
    "PLV"."PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN
    TABLE(attributes."rAC_NAM_Actor_Name"(changingTimepoint::datetime)) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            TABLE(attributes."rAC_NAM_Actor_Name"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN
    TABLE(attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            TABLE(attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_ProfessionalLevel"(0)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nAC_Actor" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(anchors."pAC_Actor"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dAC_Actor" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "PLV_Checksum" numeric(19,0),
    "PLV_EQ" tinyint,
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. Snowflake cannot call the point-in-time perspective for each change, since it cannot
-- evaluate a function with an outer join on its argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "GEN_Checksum",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "kGEN"."Metadata_GEN" AS "Metadata_GEN",
    "GEN"."GEN_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_EQ" AS "PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "Metadata_PLV",
    "PLV"."PLV_ID"
FROM (
    SELECT DISTINCT
        h."AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Actor_Name" h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."AC_ID" AS "AC_ID",
        h."AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Actor" "AC"
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
        attributes."AC_NAM_Actor_Name" h
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
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
        attributes."AC_PLV_Actor_ProfessionalLevel" h
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    TABLE(knots."ePLV_ProfessionalLevel"(0)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epAC_Actor" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "PLV_Checksum" numeric(19,0),
    "PLV_EQ" tinyint,
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "GEN_Checksum",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "kGEN"."Metadata_GEN" AS "Metadata_GEN",
    "GEN"."GEN_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_EQ" AS "PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "Metadata_PLV",
    "PLV"."PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN
    TABLE(attributes."rAC_NAM_Actor_Name"(changingTimepoint::datetime)) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" = (
        SELECT
            max(sub."AC_NAM_ChangedAt")
        FROM
            TABLE(attributes."rAC_NAM_Actor_Name"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN
    TABLE(attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" = (
        SELECT
            max(sub."AC_PLV_ChangedAt")
        FROM
            TABLE(attributes."rAC_PLV_Actor_ProfessionalLevel"(changingTimepoint::datetime)) sub
        WHERE
            sub."AC_ID" = "AC"."AC_ID"
   )
LEFT JOIN
    TABLE(knots."ePLV_ProfessionalLevel"(equivalent)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elAC_Actor" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "PLV_Checksum" numeric(19,0),
    "PLV_EQ" tinyint,
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epAC_Actor"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enAC_Actor" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "PLV_Checksum" numeric(19,0),
    "PLV_EQ" tinyint,
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epAC_Actor"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edAC_Actor" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ChangedAt" datetime,
    "PLV_Checksum" numeric(19,0),
    "PLV_EQ" tinyint,
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."Metadata_AC_GEN",
    "kGEN"."GEN_Checksum" AS "GEN_Checksum",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "kGEN"."Metadata_GEN" AS "Metadata_GEN",
    "GEN"."GEN_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ChangedAt",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_EQ" AS "PLV_EQ",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "Metadata_PLV",
    "PLV"."PLV_ID"
FROM (
    SELECT DISTINCT
        h."AC_ID" AS "AC_ID",
        h."AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Actor_Name" h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h."AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        h."AC_ID" AS "AC_ID",
        h."AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Actor_ProfessionalLevel" h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h."AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Actor" "AC"
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
        attributes."AC_NAM_Actor_Name" h
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    attributes."AC_GEN_Actor_Gender" "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
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
        attributes."AC_PLV_Actor_ProfessionalLevel" h
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::datetime
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::datetime
)
LEFT JOIN
    TABLE(knots."ePLV_ProfessionalLevel"(equivalent)) "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lPR_Program" (
    "PR_ID",
    "Metadata_PR",
    "Metadata_PR_NAM",
    "PR_NAM_Program_Name" COMMENT 'Name or title of the program.',
    "Metadata_PR_LEN",
    "PR_LEN_ChangedAt",
    "PR_LEN_EQ",
    "PR_LEN_Program_Length" COMMENT 'Running time of the program. Historized, since the program may be shortened or extended over time.'
) COPY GRANTS 
AS
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(attributes."ePR_LEN_Program_Length"(0)) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(attributes."ePR_LEN_Program_Length"(0)) sub 
        WHERE
            sub."PR_ID" = "PR"."PR_ID"
   );
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pPR_Program" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(attributes."rPR_LEN_Program_Length"(0, changingTimepoint::date)) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(attributes."rPR_LEN_Program_Length"(0, changingTimepoint::date)) sub
        WHERE
            sub."PR_ID" = "PR"."PR_ID"
   )
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nPR_Program" COPY GRANTS
AS
SELECT
    *
FROM
    TABLE(anchors."pPR_Program"(sysdate()::timestamp_ntz(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dPR_Program" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Program_Length" time
)
AS
$$
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. Snowflake cannot call the point-in-time perspective for each change, since it cannot
-- evaluate a function with an outer join on its argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        h."PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        TABLE(attributes."ePR_LEN_Program_Length"(0)) h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
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
        TABLE(attributes."ePR_LEN_Program_Length"(0)) h
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
$$
;
-- Point-in-time equivalence perspective ------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."epPR_Program" (
    equivalent tinyint,
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN
    TABLE(attributes."rPR_LEN_Program_Length"(equivalent, changingTimepoint::date)) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" = (
        SELECT
            max(sub."PR_LEN_ChangedAt")
        FROM
            TABLE(attributes."rPR_LEN_Program_Length"(equivalent, changingTimepoint::date)) sub
        WHERE
            sub."PR_ID" = "PR"."PR_ID"
   )
$$
;
-- Latest equivalence perspective -------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."elPR_Program" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epPR_Program"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Now equivalence perspective ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."enPR_Program" (
    equivalent tinyint
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    *
FROM
    TABLE(anchors."epPR_Program"(equivalent, sysdate()::timestamp_ntz(9)))
$$
;
-- Difference equivalence perspective ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."edPR_Program" (
    equivalent tinyint,
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    mnemonic string,
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_EQ" tinyint,
    "PR_LEN_Program_Length" time
)
AS
$$
-- built as the difference perspective is, from the values of the equivalent
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_EQ",
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        h."PR_ID" AS "PR_ID",
        h."PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        TABLE(attributes."ePR_LEN_Program_Length"(equivalent)) h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h."PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN
    attributes."PR_NAM_Program_Name" "NAM"
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
        TABLE(attributes."ePR_LEN_Program_Length"(equivalent)) h
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
$$
;
