-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION anchors."tST_Stage" (
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" bigint,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" bigint,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" bigint,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Confidence",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Confidence",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Confidence",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Confidence",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_NAM_ST_ID")
        r.*
    FROM
        attributes."rST_NAM_Stage_Name"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."ST_NAM_Confidence" = 1
    ORDER BY
    r."ST_NAM_ST_ID",
    r."ST_NAM_ChangedAt" DESC,
    r."ST_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_LOC_ST_ID")
        r.*
    FROM
        attributes."rST_LOC_Stage_Location"(
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."ST_LOC_Confidence" = 1
    ORDER BY
    r."ST_LOC_ST_ID",
    r."ST_LOC_PositedAt" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_AVG_ST_ID")
        r.*
    FROM
        attributes."rST_AVG_Stage_Average"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."ST_AVG_Confidence" = 1
    ORDER BY
    r."ST_AVG_ST_ID",
    r."ST_AVG_ChangedAt" DESC,
    r."ST_AVG_PositedAt" DESC
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_MIN_ST_ID")
        r.*
    FROM
        attributes."rST_MIN_Stage_Minimum"(
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."ST_MIN_Confidence" = 1
    ORDER BY
    r."ST_MIN_ST_ID",
    r."ST_MIN_PositedAt" DESC
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."lST_Stage" AS
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "ST".*
FROM
    anchors."tST_Stage"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3)
    ) "ST"
;
CREATE OR REPLACE FUNCTION anchors."pST_Stage" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Confidence" decimal(7,3),
    "ST_ID" integer,
    "Metadata_ST" bigint,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" bigint,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" bigint,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "ST"."ST_NAM_ST_ID",
    "ST"."Metadata_ST_NAM",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Confidence",
    "ST"."ST_NAM_Stage_Name",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Confidence",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Confidence",
    "ST"."ST_AVG_UTL_Utilization",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Confidence",
    "ST"."ST_MIN_UTL_Utilization",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    anchors."tST_Stage"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3)
    ) "ST"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."nST_Stage" AS
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "ST".*
FROM
    anchors."tST_Stage"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3)
    ) "ST"
;
CREATE OR REPLACE FUNCTION anchors."dST_Stage" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "ST_ID" integer,
    "Metadata_ST" bigint,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" bigint,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" bigint,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Confidence",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Confidence",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Confidence",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Confidence",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM (
    SELECT DISTINCT
        "ST_NAM_ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."ST_NAM_Stage_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_AVG_ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
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
            PARTITION BY x."ST_NAM_ST_ID"
            ORDER BY x."ST_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt")
            r.*
        FROM
            attributes."rST_NAM_Stage_Name"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."ST_NAM_Confidence" = 1
        ORDER BY
    r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt",
    r."ST_NAM_PositedAt" DESC
    ) x
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_LOC_ST_ID")
        r.*
    FROM
        attributes."rST_LOC_Stage_Location"(
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."ST_LOC_Confidence" = 1
    ORDER BY
    r."ST_LOC_ST_ID",
    r."ST_LOC_PositedAt" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."ST_AVG_ChangedAt") OVER (
            PARTITION BY x."ST_AVG_ST_ID"
            ORDER BY x."ST_AVG_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt")
            r.*
        FROM
            attributes."rST_AVG_Stage_Average"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."ST_AVG_Confidence" = 1
        ORDER BY
    r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt",
    r."ST_AVG_PositedAt" DESC
    ) x
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_MIN_ST_ID")
        r.*
    FROM
        attributes."rST_MIN_Stage_Minimum"(
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."ST_MIN_Confidence" = 1
    ORDER BY
    r."ST_MIN_ST_ID",
    r."ST_MIN_PositedAt" DESC
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION anchors."tAC_Actor" (
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" bigint,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" bigint,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" bigint,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Confidence",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Confidence",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Confidence",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."AC_NAM_AC_ID")
        r.*
    FROM
        attributes."rAC_NAM_Actor_Name"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."AC_NAM_Confidence" = 1
    ORDER BY
    r."AC_NAM_AC_ID",
    r."AC_NAM_ChangedAt" DESC,
    r."AC_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."AC_GEN_AC_ID")
        r.*
    FROM
        attributes."rAC_GEN_Actor_Gender"(
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."AC_GEN_Confidence" = 1
    ORDER BY
    r."AC_GEN_AC_ID",
    r."AC_GEN_PositedAt" DESC
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."AC_PLV_AC_ID")
        r.*
    FROM
        attributes."rAC_PLV_Actor_ProfessionalLevel"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."AC_PLV_Confidence" = 1
    ORDER BY
    r."AC_PLV_AC_ID",
    r."AC_PLV_ChangedAt" DESC,
    r."AC_PLV_PositedAt" DESC
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."lAC_Actor" AS
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "AC".*
FROM
    anchors."tAC_Actor"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3)
    ) "AC"
;
CREATE OR REPLACE FUNCTION anchors."pAC_Actor" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Confidence" decimal(7,3),
    "AC_ID" smallint,
    "Metadata_AC" bigint,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" bigint,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" bigint,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "AC"."AC_NAM_AC_ID",
    "AC"."Metadata_AC_NAM",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Confidence",
    "AC"."AC_NAM_Actor_Name",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Confidence",
    "AC"."AC_GEN_GEN_Checksum",
    "AC"."AC_GEN_GEN_Gender",
    "AC"."AC_GEN_Metadata_GEN",
    "AC"."AC_GEN_GEN_ID",
    "AC"."AC_PLV_AC_ID",
    "AC"."Metadata_AC_PLV",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Confidence",
    "AC"."AC_PLV_PLV_Checksum",
    "AC"."AC_PLV_PLV_ProfessionalLevel",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    anchors."tAC_Actor"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3)
    ) "AC"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."nAC_Actor" AS
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "AC".*
FROM
    anchors."tAC_Actor"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3)
    ) "AC"
;
CREATE OR REPLACE FUNCTION anchors."dAC_Actor" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "AC_ID" smallint,
    "Metadata_AC" bigint,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" bigint,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" bigint,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Confidence",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Confidence",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Confidence",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM (
    SELECT DISTINCT
        "AC_NAM_AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Actor_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_PLV_AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
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
            PARTITION BY x."AC_NAM_AC_ID"
            ORDER BY x."AC_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt")
            r.*
        FROM
            attributes."rAC_NAM_Actor_Name"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."AC_NAM_Confidence" = 1
        ORDER BY
    r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt",
    r."AC_NAM_PositedAt" DESC
    ) x
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."AC_GEN_AC_ID")
        r.*
    FROM
        attributes."rAC_GEN_Actor_Gender"(
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."AC_GEN_Confidence" = 1
    ORDER BY
    r."AC_GEN_AC_ID",
    r."AC_GEN_PositedAt" DESC
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."AC_PLV_ChangedAt") OVER (
            PARTITION BY x."AC_PLV_AC_ID"
            ORDER BY x."AC_PLV_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt")
            r.*
        FROM
            attributes."rAC_PLV_Actor_ProfessionalLevel"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."AC_PLV_Confidence" = 1
        ORDER BY
    r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt",
    r."AC_PLV_PositedAt" DESC
    ) x
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION anchors."tPR_Program" (
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" bigint,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Confidence",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Confidence",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."PR_NAM_PR_ID")
        r.*
    FROM
        attributes."rPR_NAM_Program_Name"(
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."PR_NAM_Confidence" = 1
    ORDER BY
    r."PR_NAM_PR_ID",
    r."PR_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."PR_LEN_PR_ID")
        r.*
    FROM
        attributes."rPR_LEN_Program_Length"(
            changingTimepoint::date,
            positingTimepoint::timestamp(3)
        ) r
    WHERE
        r."PR_LEN_Confidence" = 1
    ORDER BY
    r."PR_LEN_PR_ID",
    r."PR_LEN_ChangedAt" DESC,
    r."PR_LEN_PositedAt" DESC
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."lPR_Program" AS
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "PR".*
FROM
    anchors."tPR_Program"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3)
    ) "PR"
;
CREATE OR REPLACE FUNCTION anchors."pPR_Program" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Confidence" decimal(7,3),
    "PR_ID" bigint,
    "Metadata_PR" bigint,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "PR"."PR_NAM_PR_ID",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Confidence",
    "PR"."PR_NAM_Program_Name",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Confidence",
    "PR"."PR_LEN_Program_Length"
FROM
    anchors."tPR_Program"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3)
    ) "PR"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."nPR_Program" AS
SELECT
    cast(null as decimal(7,3)) as "Confidence",
    "PR".*
FROM
    anchors."tPR_Program"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3)
    ) "PR"
;
CREATE OR REPLACE FUNCTION anchors."dPR_Program" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "PR_ID" bigint,
    "Metadata_PR" bigint,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Program_Length" time
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Confidence",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Confidence",
    "LEN"."PR_LEN_Program_Length"
FROM (
    SELECT DISTINCT
        "PR_LEN_PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
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
    SELECT DISTINCT ON (r."PR_NAM_PR_ID")
        r.*
    FROM
        attributes."rPR_NAM_Program_Name"(
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."PR_NAM_Confidence" = 1
    ORDER BY
    r."PR_NAM_PR_ID",
    r."PR_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."PR_LEN_ChangedAt") OVER (
            PARTITION BY x."PR_LEN_PR_ID"
            ORDER BY x."PR_LEN_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt")
            r.*
        FROM
            attributes."rPR_LEN_Program_Length"(
                '9999-12-31'::date,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."PR_LEN_Confidence" = 1
        ORDER BY
    r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt",
    r."PR_LEN_PositedAt" DESC
    ) x
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LEN"."until" IS NULL
OR
    "LEN"."until" > timepoints.inspectedTimepoint::date
)
$$ LANGUAGE sql STABLE;
