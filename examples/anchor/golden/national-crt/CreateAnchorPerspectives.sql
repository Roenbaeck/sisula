-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- Snowflake-native CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tST_Scen" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
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
    "NAM"."ST_NAM_Positor",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Assertion",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Scen_Plats",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "kAVG"."UTL_Utnyttjande" AS "ST_AVG_UTL_Utnyttjande",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "kMIN"."UTL_Utnyttjande" AS "ST_MIN_UTL_Utnyttjande",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Scen" "ST"
LEFT JOIN
    TABLE(attributes."rST_NAM_Scen_Namn"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."ST_NAM_ID" = (
        SELECT
            sub."ST_NAM_ID"
        FROM
            TABLE(attributes."rST_NAM_Scen_Namn"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_NAM_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_NAM_Assertion" = coalesce(assertion, sub."ST_NAM_Assertion")
        ORDER BY
            sub."ST_NAM_ChangedAt" DESC,
            sub."ST_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rST_LOC_Scen_Plats"(
        positor,
        positingTimepoint::datetime
    )) "LOC"
ON
    "LOC"."ST_LOC_ID" = (
        SELECT
            sub."ST_LOC_ID"
        FROM
            TABLE(attributes."rST_LOC_Scen_Plats"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_LOC_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_LOC_Assertion" = coalesce(assertion, sub."ST_LOC_Assertion")
        ORDER BY
            sub."ST_LOC_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rST_AVG_Scen_Medel"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "AVG"
ON
    "AVG"."ST_AVG_ID" = (
        SELECT
            sub."ST_AVG_ID"
        FROM
            TABLE(attributes."rST_AVG_Scen_Medel"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_AVG_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_AVG_Assertion" = coalesce(assertion, sub."ST_AVG_Assertion")
        ORDER BY
            sub."ST_AVG_ChangedAt" DESC,
            sub."ST_AVG_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."UTL_Utnyttjande" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN
    TABLE(attributes."rST_MIN_Scen_Minimum"(
        positor,
        positingTimepoint::datetime
    )) "MIN"
ON
    "MIN"."ST_MIN_ID" = (
        SELECT
            sub."ST_MIN_ID"
        FROM
            TABLE(attributes."rST_MIN_Scen_Minimum"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."ST_MIN_ST_ID" = "ST"."ST_ID"
        AND
            sub."ST_MIN_Assertion" = coalesce(assertion, sub."ST_MIN_Assertion")
        ORDER BY
            sub."ST_MIN_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."UTL_Utnyttjande" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lST_Scen" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tST_Scen"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pST_Scen" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "ST"."ST_NAM_ST_ID",
    "ST"."Metadata_ST_NAM",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Positor",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Assertion",
    "ST"."ST_NAM_Scen_Namn",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Positor",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Assertion",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Scen_Plats",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Positor",
    "ST"."ST_AVG_Reliability",
    "ST"."ST_AVG_Assertion",
    "ST"."ST_AVG_UTL_Utnyttjande",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Positor",
    "ST"."ST_MIN_Reliability",
    "ST"."ST_MIN_Assertion",
    "ST"."ST_MIN_UTL_Utnyttjande",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    dw."_Positor" p,
    TABLE(anchors."tST_Scen"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nST_Scen" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tST_Scen"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dST_Scen" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "ST_ID" int,
    "Metadata_ST" int,
    "ST_NAM_ST_ID" int,
    "Metadata_ST_NAM" int,
    "ST_NAM_ID" int,
    "ST_NAM_ChangedAt" datetime,
    "ST_NAM_PositedAt" datetime,
    "ST_NAM_Positor" tinyint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" string,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" int,
    "Metadata_ST_LOC" int,
    "ST_LOC_ID" int,
    "ST_LOC_PositedAt" datetime,
    "ST_LOC_Positor" tinyint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" string,
    "ST_LOC_Checksum" numeric(19,0),
    "ST_LOC_Scen_Plats" geography,
    "ST_AVG_ST_ID" int,
    "Metadata_ST_AVG" int,
    "ST_AVG_ID" int,
    "ST_AVG_ChangedAt" datetime,
    "ST_AVG_PositedAt" datetime,
    "ST_AVG_Positor" tinyint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" string,
    "ST_AVG_UTL_Utnyttjande" tinyint,
    "ST_AVG_Metadata_UTL" int,
    "ST_AVG_UTL_ID" tinyint,
    "ST_MIN_ST_ID" int,
    "Metadata_ST_MIN" int,
    "ST_MIN_ID" int,
    "ST_MIN_PositedAt" datetime,
    "ST_MIN_Positor" tinyint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" string,
    "ST_MIN_UTL_Utnyttjande" tinyint,
    "ST_MIN_Metadata_UTL" int,
    "ST_MIN_UTL_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "ST"."ST_NAM_ST_ID",
    "ST"."Metadata_ST_NAM",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Positor",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Assertion",
    "ST"."ST_NAM_Scen_Namn",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Positor",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Assertion",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Scen_Plats",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Positor",
    "ST"."ST_AVG_Reliability",
    "ST"."ST_AVG_Assertion",
    "ST"."ST_AVG_UTL_Utnyttjande",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Positor",
    "ST"."ST_MIN_Reliability",
    "ST"."ST_MIN_Assertion",
    "ST"."ST_MIN_UTL_Utnyttjande",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    dw."_Positor" p
JOIN
(
    SELECT DISTINCT
        "ST_NAM_Positor" AS positor,
        "ST_NAM_ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."ST_NAM_Scen_Namn"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_AVG_Positor" AS positor,
        "ST_AVG_ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Scen_Medel"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor",
    TABLE(anchors."tST_Scen"(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "ST"
WHERE
    "ST"."ST_ID" = timepoints."ST_ID"
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tAC_Skådespelare" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
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
    "NAM"."AC_NAM_Positor",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Assertion",
    "NAM"."AC_NAM_Skådespelare_Namn",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Kön" AS "AC_GEN_GEN_Kön",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Positor",
    "PLV"."AC_PLV_Reliability",
    "PLV"."AC_PLV_Assertion",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN
    TABLE(attributes."rAC_NAM_Skådespelare_Namn"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."AC_NAM_ID" = (
        SELECT
            sub."AC_NAM_ID"
        FROM
            TABLE(attributes."rAC_NAM_Skådespelare_Namn"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_NAM_AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_NAM_Assertion" = coalesce(assertion, sub."AC_NAM_Assertion")
        ORDER BY
            sub."AC_NAM_ChangedAt" DESC,
            sub."AC_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rAC_GEN_Skådespelare_Kön"(
        positor,
        positingTimepoint::datetime
    )) "GEN"
ON
    "GEN"."AC_GEN_ID" = (
        SELECT
            sub."AC_GEN_ID"
        FROM
            TABLE(attributes."rAC_GEN_Skådespelare_Kön"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_GEN_AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_GEN_Assertion" = coalesce(assertion, sub."AC_GEN_Assertion")
        ORDER BY
            sub."AC_GEN_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN
    TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(
        positor,
        changingTimepoint::datetime,
        positingTimepoint::datetime
    )) "PLV"
ON
    "PLV"."AC_PLV_ID" = (
        SELECT
            sub."AC_PLV_ID"
        FROM
            TABLE(attributes."rAC_PLV_Skådespelare_Yrkesnivå"(
                positor,
                changingTimepoint::datetime,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."AC_PLV_AC_ID" = "AC"."AC_ID"
        AND
            sub."AC_PLV_Assertion" = coalesce(assertion, sub."AC_PLV_Assertion")
        ORDER BY
            sub."AC_PLV_ChangedAt" DESC,
            sub."AC_PLV_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    knots."PLV_Yrkesnivå" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lAC_Skådespelare" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tAC_Skådespelare"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pAC_Skådespelare" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "AC"."AC_NAM_AC_ID",
    "AC"."Metadata_AC_NAM",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Positor",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Assertion",
    "AC"."AC_NAM_Skådespelare_Namn",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Positor",
    "AC"."AC_GEN_Reliability",
    "AC"."AC_GEN_Assertion",
    "AC"."AC_GEN_GEN_Checksum",
    "AC"."AC_GEN_GEN_Kön",
    "AC"."AC_GEN_Metadata_GEN",
    "AC"."AC_GEN_GEN_ID",
    "AC"."AC_PLV_AC_ID",
    "AC"."Metadata_AC_PLV",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Positor",
    "AC"."AC_PLV_Reliability",
    "AC"."AC_PLV_Assertion",
    "AC"."AC_PLV_PLV_Checksum",
    "AC"."AC_PLV_PLV_Yrkesnivå",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    dw."_Positor" p,
    TABLE(anchors."tAC_Skådespelare"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nAC_Skådespelare" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tAC_Skådespelare"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dAC_Skådespelare" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "AC_ID" smallint,
    "Metadata_AC" int,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" int,
    "AC_NAM_ID" int,
    "AC_NAM_ChangedAt" datetime,
    "AC_NAM_PositedAt" datetime,
    "AC_NAM_Positor" tinyint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" string,
    "AC_NAM_Skådespelare_Namn" varbinary(max),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" int,
    "AC_GEN_ID" int,
    "AC_GEN_PositedAt" datetime,
    "AC_GEN_Positor" tinyint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" string,
    "AC_GEN_GEN_Checksum" numeric(19,0),
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" int,
    "AC_GEN_GEN_ID" number(1,0),
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" int,
    "AC_PLV_ID" int,
    "AC_PLV_ChangedAt" datetime,
    "AC_PLV_PositedAt" datetime,
    "AC_PLV_Positor" tinyint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" string,
    "AC_PLV_PLV_Checksum" numeric(19,0),
    "AC_PLV_PLV_Yrkesnivå" string,
    "AC_PLV_Metadata_PLV" int,
    "AC_PLV_PLV_ID" tinyint
)
AS
$$
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "AC"."AC_NAM_AC_ID",
    "AC"."Metadata_AC_NAM",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Positor",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Assertion",
    "AC"."AC_NAM_Skådespelare_Namn",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Positor",
    "AC"."AC_GEN_Reliability",
    "AC"."AC_GEN_Assertion",
    "AC"."AC_GEN_GEN_Checksum",
    "AC"."AC_GEN_GEN_Kön",
    "AC"."AC_GEN_Metadata_GEN",
    "AC"."AC_GEN_GEN_ID",
    "AC"."AC_PLV_AC_ID",
    "AC"."Metadata_AC_PLV",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Positor",
    "AC"."AC_PLV_Reliability",
    "AC"."AC_PLV_Assertion",
    "AC"."AC_PLV_PLV_Checksum",
    "AC"."AC_PLV_PLV_Yrkesnivå",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    dw."_Positor" p
JOIN
(
    SELECT DISTINCT
        "AC_NAM_Positor" AS positor,
        "AC_NAM_AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Skådespelare_Namn"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_PLV_Positor" AS positor,
        "AC_PLV_AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor",
    TABLE(anchors."tAC_Skådespelare"(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "AC"
WHERE
    "AC"."AC_ID" = timepoints."AC_ID"
$$
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tPR_Föreställning" (
    positor tinyint,
    changingTimepoint timestamp_ntz(9),
    positingTimepoint datetime,
    assertion string
)
COPY GRANTS
RETURNS TABLE (
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
    "PR_LEN_Föreställning_Längd" time
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
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN
    TABLE(attributes."rPR_NAM_Föreställning_Namn"(
        positor,
        positingTimepoint::datetime
    )) "NAM"
ON
    "NAM"."PR_NAM_ID" = (
        SELECT
            sub."PR_NAM_ID"
        FROM
            TABLE(attributes."rPR_NAM_Föreställning_Namn"(
                positor,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."PR_NAM_PR_ID" = "PR"."PR_ID"
        AND
            sub."PR_NAM_Assertion" = coalesce(assertion, sub."PR_NAM_Assertion")
        ORDER BY
            sub."PR_NAM_PositedAt" DESC
        LIMIT 1
    )
LEFT JOIN
    TABLE(attributes."rPR_LEN_Föreställning_Längd"(
        positor,
        changingTimepoint::date,
        positingTimepoint::datetime
    )) "LEN"
ON
    "LEN"."PR_LEN_ID" = (
        SELECT
            sub."PR_LEN_ID"
        FROM
            TABLE(attributes."rPR_LEN_Föreställning_Längd"(
                positor,
                changingTimepoint::date,
                positingTimepoint::datetime
            )) sub
        WHERE
            sub."PR_LEN_PR_ID" = "PR"."PR_ID"
        AND
            sub."PR_LEN_Assertion" = coalesce(assertion, sub."PR_LEN_Assertion")
        ORDER BY
            sub."PR_LEN_ChangedAt" DESC,
            sub."PR_LEN_PositedAt" DESC
        LIMIT 1
    )
$$
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lPR_Föreställning" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tPR_Föreställning"(
        p."Positor",
        '9999-12-31'::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pPR_Föreställning" (
    changingTimepoint timestamp_ntz(9)
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    "Reliability" decimal(5,2),
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "PR"."PR_NAM_PR_ID",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Positor",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Assertion",
    "PR"."PR_NAM_Föreställning_Namn",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Positor",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Assertion",
    "PR"."PR_LEN_Föreställning_Längd"
FROM
    dw."_Positor" p,
    TABLE(anchors."tPR_Föreställning"(
        p."Positor",
        changingTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
$$
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nPR_Föreställning" COPY GRANTS AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    dw."_Positor" p,
    TABLE(anchors."tPR_Föreställning"(
        p."Positor",
        sysdate()::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dPR_Föreställning" (
    intervalStart timestamp_ntz(9),
    intervalEnd timestamp_ntz(9),
    selection string
)
COPY GRANTS
RETURNS TABLE (
    "Positor" tinyint,
    inspectedTimepoint timestamp_ntz(9),
    "PR_ID" number(10,0),
    "Metadata_PR" int,
    "PR_NAM_PR_ID" number(10,0),
    "Metadata_PR_NAM" int,
    "PR_NAM_ID" int,
    "PR_NAM_PositedAt" datetime,
    "PR_NAM_Positor" tinyint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" string,
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" number(10,0),
    "Metadata_PR_LEN" int,
    "PR_LEN_ID" int,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" datetime,
    "PR_LEN_Positor" tinyint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" string,
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "PR"."PR_NAM_PR_ID",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Positor",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Assertion",
    "PR"."PR_NAM_Föreställning_Namn",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Positor",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Assertion",
    "PR"."PR_LEN_Föreställning_Längd"
FROM
    dw."_Positor" p
JOIN
(
    SELECT DISTINCT
        "PR_LEN_Positor" AS positor,
        "PR_LEN_PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp_ntz(9) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."PR_LEN_Föreställning_Längd"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor",
    TABLE(anchors."tPR_Föreställning"(
        timepoints.positor,
        timepoints.inspectedTimepoint::timestamp_ntz(9),
        '9999-12-31'::datetime,
        '+'
    )) "PR"
WHERE
    "PR"."PR_ID" = timepoints."PR_ID"
$$
;
