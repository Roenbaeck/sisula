-- ANCHOR TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI anchor perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that
-- take a time (time traveling, point-in-time and difference) are not made; the latest and the now perspectives take none,
-- and are views over the rewinders of the attributes (views that show the latest annex row of every posit).
--
CREATE OR REPLACE VIEW anchors."lST_Stage" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_NAM_Stage_Name" r
    WHERE
        r."ST_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_NAM_ST_ID"
        ORDER BY
            r."ST_NAM_ChangedAt" DESC,
            r."ST_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_LOC_Stage_Location" r
    WHERE
        r."ST_LOC_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_LOC_ST_ID"
        ORDER BY
            r."ST_LOC_PositedAt" DESC
    )
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_AVG_Stage_Average" r
    WHERE
        r."ST_AVG_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_AVG_ST_ID"
        ORDER BY
            r."ST_AVG_ChangedAt" DESC,
            r."ST_AVG_PositedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_MIN_Stage_Minimum" r
    WHERE
        r."ST_MIN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_MIN_ST_ID"
        ORDER BY
            r."ST_MIN_PositedAt" DESC
    )
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
;
CREATE OR REPLACE VIEW anchors."nST_Stage" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_NAM_Stage_Name" r
    WHERE
        r."ST_NAM_Reliability" = 1
    AND
        r."ST_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."ST_NAM_ST_ID"
        ORDER BY
            r."ST_NAM_ChangedAt" DESC,
            r."ST_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_LOC_Stage_Location" r
    WHERE
        r."ST_LOC_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_LOC_ST_ID"
        ORDER BY
            r."ST_LOC_PositedAt" DESC
    )
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_AVG_Stage_Average" r
    WHERE
        r."ST_AVG_Reliability" = 1
    AND
        r."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."ST_AVG_ST_ID"
        ORDER BY
            r."ST_AVG_ChangedAt" DESC,
            r."ST_AVG_PositedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_MIN_Stage_Minimum" r
    WHERE
        r."ST_MIN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_MIN_ST_ID"
        ORDER BY
            r."ST_MIN_PositedAt" DESC
    )
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
;
CREATE OR REPLACE VIEW anchors."lAC_Actor" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_NAM_Actor_Name" r
    WHERE
        r."AC_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_NAM_AC_ID"
        ORDER BY
            r."AC_NAM_ChangedAt" DESC,
            r."AC_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_GEN_Actor_Gender" r
    WHERE
        r."AC_GEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_GEN_AC_ID"
        ORDER BY
            r."AC_GEN_PositedAt" DESC
    )
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_PLV_Actor_ProfessionalLevel" r
    WHERE
        r."AC_PLV_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_PLV_AC_ID"
        ORDER BY
            r."AC_PLV_ChangedAt" DESC,
            r."AC_PLV_PositedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW anchors."nAC_Actor" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_NAM_Actor_Name" r
    WHERE
        r."AC_NAM_Reliability" = 1
    AND
        r."AC_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."AC_NAM_AC_ID"
        ORDER BY
            r."AC_NAM_ChangedAt" DESC,
            r."AC_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_GEN_Actor_Gender" r
    WHERE
        r."AC_GEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_GEN_AC_ID"
        ORDER BY
            r."AC_GEN_PositedAt" DESC
    )
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_PLV_Actor_ProfessionalLevel" r
    WHERE
        r."AC_PLV_Reliability" = 1
    AND
        r."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."AC_PLV_AC_ID"
        ORDER BY
            r."AC_PLV_ChangedAt" DESC,
            r."AC_PLV_PositedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW anchors."lPR_Program" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_NAM_Program_Name" r
    WHERE
        r."PR_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_NAM_PR_ID"
        ORDER BY
            r."PR_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_LEN_Program_Length" r
    WHERE
        r."PR_LEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_LEN_PR_ID"
        ORDER BY
            r."PR_LEN_ChangedAt" DESC,
            r."PR_LEN_PositedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
CREATE OR REPLACE VIEW anchors."nPR_Program" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_NAM_Program_Name" r
    WHERE
        r."PR_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_NAM_PR_ID"
        ORDER BY
            r."PR_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_LEN_Program_Length" r
    WHERE
        r."PR_LEN_Reliability" = 1
    AND
        r."PR_LEN_ChangedAt" <= current_timestamp::date
    LIMIT 1 OVER (
        PARTITION BY r."PR_LEN_PR_ID"
        ORDER BY
            r."PR_LEN_ChangedAt" DESC,
            r."PR_LEN_PositedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
