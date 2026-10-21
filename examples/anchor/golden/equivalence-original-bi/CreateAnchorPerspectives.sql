-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION anchors."tST_Stage" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Reliability" decimal(5,2),
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
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "Metadata_UTL",
    "AVG"."UTL_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "Metadata_UTL",
    "MIN"."UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rST_NAM_Stage_Name"(
            changingTimepoint::datetime,
            positingTimepoint::datetime
        )) r
    WHERE
        r."ST_NAM_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."ST_ID"
            ORDER BY
                r."ST_NAM_ChangedAt" DESC,
                r."ST_NAM_PositedAt" DESC
        ) = 1
) "NAM"
ON
    "NAM"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rST_LOC_Stage_Location"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."ST_LOC_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."ST_ID"
            ORDER BY
                r."ST_LOC_PositedAt" DESC
        ) = 1
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rST_AVG_Stage_Average"(
            changingTimepoint::datetime,
            positingTimepoint::datetime
        )) r
    WHERE
        r."ST_AVG_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."ST_ID"
            ORDER BY
                r."ST_AVG_ChangedAt" DESC,
                r."ST_AVG_PositedAt" DESC
        ) = 1
) "AVG"
ON
    "AVG"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rST_MIN_Stage_Minimum"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."ST_MIN_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."ST_ID"
            ORDER BY
                r."ST_MIN_PositedAt" DESC
        ) = 1
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$
;
CREATE OR REPLACE VIEW anchors."lST_Stage" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    TABLE(anchors."tST_Stage"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "ST"
;
CREATE OR REPLACE FUNCTION anchors."pST_Stage" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "ST"."Metadata_ST_NAM",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Stage_Name",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Stage_Location",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Reliability",
    "ST"."UTL_Utilization",
    "ST"."Metadata_UTL",
    "ST"."UTL_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Reliability",
    "ST"."UTL_Utilization",
    "ST"."Metadata_UTL",
    "ST"."UTL_ID"
FROM
    TABLE(anchors."tST_Stage"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "ST"
$$
;
CREATE OR REPLACE VIEW anchors."nST_Stage" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    TABLE(anchors."tST_Stage"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "ST"
;
CREATE OR REPLACE FUNCTION anchors."dST_Stage" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    "ST_ID" int,
    "Metadata_ST" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Stage_Name" varchar(42),
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Stage_Location" geography,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Reliability" decimal(5,2),
    "UTL_Utilization" tinyint,
    "Metadata_UTL" int,
    "UTL_ID" tinyint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. Snowflake cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "Metadata_UTL",
    "AVG"."UTL_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "Metadata_UTL",
    "MIN"."UTL_ID"
FROM (
    SELECT DISTINCT
        "ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."ST_NAM_Stage_Name"
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
        attributes."ST_AVG_Stage_Average"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Stage" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."ST_NAM_ChangedAt") OVER (
            PARTITION BY x."ST_ID"
            ORDER BY x."ST_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            TABLE(attributes."rST_NAM_Stage_Name"(
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."ST_NAM_Reliability" = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r."ST_ID", r."ST_NAM_ChangedAt"
                ORDER BY r."ST_NAM_PositedAt" DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rST_LOC_Stage_Location"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."ST_LOC_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."ST_ID"
            ORDER BY r."ST_LOC_PositedAt" DESC
        ) = 1
) "LOC"
ON
    "LOC"."ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."ST_AVG_ChangedAt") OVER (
            PARTITION BY x."ST_ID"
            ORDER BY x."ST_AVG_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            TABLE(attributes."rST_AVG_Stage_Average"(
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."ST_AVG_Reliability" = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r."ST_ID", r."ST_AVG_ChangedAt"
                ORDER BY r."ST_AVG_PositedAt" DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rST_MIN_Stage_Minimum"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."ST_MIN_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."ST_ID"
            ORDER BY r."ST_MIN_PositedAt" DESC
        ) = 1
) "MIN"
ON
    "MIN"."ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."UTL_ID"
$$
;
CREATE OR REPLACE FUNCTION anchors."tAC_Actor" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Reliability" decimal(5,2),
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Reliability" decimal(5,2),
    "PLV_Checksum" numeric(19,0),
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
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "GEN_Checksum",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "kGEN"."Metadata_GEN" AS "Metadata_GEN",
    "GEN"."GEN_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "Metadata_PLV",
    "PLV"."PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rAC_NAM_Actor_Name"(
            changingTimepoint::datetime,
            positingTimepoint::datetime
        )) r
    WHERE
        r."AC_NAM_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."AC_ID"
            ORDER BY
                r."AC_NAM_ChangedAt" DESC,
                r."AC_NAM_PositedAt" DESC
        ) = 1
) "NAM"
ON
    "NAM"."AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rAC_GEN_Actor_Gender"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."AC_GEN_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."AC_ID"
            ORDER BY
                r."AC_GEN_PositedAt" DESC
        ) = 1
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rAC_PLV_Actor_ProfessionalLevel"(
            changingTimepoint::datetime,
            positingTimepoint::datetime
        )) r
    WHERE
        r."AC_PLV_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."AC_ID"
            ORDER BY
                r."AC_PLV_ChangedAt" DESC,
                r."AC_PLV_PositedAt" DESC
        ) = 1
) "PLV"
ON
    "PLV"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$
;
CREATE OR REPLACE VIEW anchors."lAC_Actor" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    TABLE(anchors."tAC_Actor"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "AC"
;
CREATE OR REPLACE FUNCTION anchors."pAC_Actor" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Reliability" decimal(5,2),
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Reliability" decimal(5,2),
    "PLV_Checksum" numeric(19,0),
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "AC"."Metadata_AC_NAM",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Actor_Name",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Reliability",
    "AC"."GEN_Checksum",
    "AC"."GEN_Gender",
    "AC"."Metadata_GEN",
    "AC"."GEN_ID",
    "AC"."Metadata_AC_PLV",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Reliability",
    "AC"."PLV_Checksum",
    "AC"."PLV_ProfessionalLevel",
    "AC"."Metadata_PLV",
    "AC"."PLV_ID"
FROM
    TABLE(anchors."tAC_Actor"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "AC"
$$
;
CREATE OR REPLACE VIEW anchors."nAC_Actor" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    TABLE(anchors."tAC_Actor"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "AC"
;
CREATE OR REPLACE FUNCTION anchors."dAC_Actor" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    "AC_ID" smallint,
    "Metadata_AC" int,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Actor_Name" binary,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Reliability" decimal(5,2),
    "GEN_Checksum" numeric(19,0),
    "GEN_Gender" varchar(42),
    "Metadata_GEN" int,
    "GEN_ID" number(1,0),
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Reliability" decimal(5,2),
    "PLV_Checksum" numeric(19,0),
    "PLV_ProfessionalLevel" string,
    "Metadata_PLV" int,
    "PLV_ID" tinyint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. Snowflake cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "GEN_Checksum",
    "kGEN"."GEN_Gender" AS "GEN_Gender",
    "kGEN"."Metadata_GEN" AS "Metadata_GEN",
    "GEN"."GEN_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "Metadata_PLV",
    "PLV"."PLV_ID"
FROM (
    SELECT DISTINCT
        "AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Actor_Name"
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
        attributes."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Actor" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."AC_NAM_ChangedAt") OVER (
            PARTITION BY x."AC_ID"
            ORDER BY x."AC_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            TABLE(attributes."rAC_NAM_Actor_Name"(
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."AC_NAM_Reliability" = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r."AC_ID", r."AC_NAM_ChangedAt"
                ORDER BY r."AC_NAM_PositedAt" DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rAC_GEN_Actor_Gender"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."AC_GEN_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."AC_ID"
            ORDER BY r."AC_GEN_PositedAt" DESC
        ) = 1
) "GEN"
ON
    "GEN"."AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."GEN_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."AC_PLV_ChangedAt") OVER (
            PARTITION BY x."AC_ID"
            ORDER BY x."AC_PLV_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            TABLE(attributes."rAC_PLV_Actor_ProfessionalLevel"(
                '9999-12-31'::datetime,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."AC_PLV_Reliability" = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r."AC_ID", r."AC_PLV_ChangedAt"
                ORDER BY r."AC_PLV_PositedAt" DESC
            ) = 1
    ) x
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
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."PLV_ID"
$$
;
CREATE OR REPLACE FUNCTION anchors."tPR_Program" (
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
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
    "PR"."Metadata_PR",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rPR_NAM_Program_Name"(
            positingTimepoint::datetime
        )) r
    WHERE
        r."PR_NAM_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."PR_ID"
            ORDER BY
                r."PR_NAM_PositedAt" DESC
        ) = 1
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: Snowflake cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        TABLE(attributes."rPR_LEN_Program_Length"(
            changingTimepoint::date,
            positingTimepoint::datetime
        )) r
    WHERE
        r."PR_LEN_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."PR_ID"
            ORDER BY
                r."PR_LEN_ChangedAt" DESC,
                r."PR_LEN_PositedAt" DESC
        ) = 1
) "LEN"
ON
    "LEN"."PR_ID" = "PR"."PR_ID"
$$
;
CREATE OR REPLACE VIEW anchors."lPR_Program" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    TABLE(anchors."tPR_Program"(
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "PR"
;
CREATE OR REPLACE FUNCTION anchors."pPR_Program" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
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
    "PR"."Metadata_PR",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Program_Name",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Program_Length"
FROM
    TABLE(anchors."tPR_Program"(
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "PR"
$$
;
CREATE OR REPLACE VIEW anchors."nPR_Program" COPY GRANTS AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    TABLE(anchors."tPR_Program"(
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime
    )) "PR"
;
CREATE OR REPLACE FUNCTION anchors."dPR_Program" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    inspectedTimepoint timestamp_ntz(9),
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Program_Name" varchar(42),
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Program_Length" time
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. Snowflake cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        "PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."PR_LEN_Program_Length"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN (
    SELECT
        r.*
    FROM
        TABLE(attributes."rPR_NAM_Program_Name"(
            '9999-12-31'::datetime
        )) r
    WHERE
        r."PR_NAM_Reliability" = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r."PR_ID"
            ORDER BY r."PR_NAM_PositedAt" DESC
        ) = 1
) "NAM"
ON
    "NAM"."PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."PR_LEN_ChangedAt") OVER (
            PARTITION BY x."PR_ID"
            ORDER BY x."PR_LEN_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            TABLE(attributes."rPR_LEN_Program_Length"(
                '9999-12-31'::date,
                '9999-12-31'::datetime
            )) r
        WHERE
            r."PR_LEN_Reliability" = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r."PR_ID", r."PR_LEN_ChangedAt"
                ORDER BY r."PR_LEN_PositedAt" DESC
            ) = 1
    ) x
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
