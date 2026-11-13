-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BigQuery BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION anchors.`tST_Scen` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_PositedAt`,
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Scen` `ST`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_NAM_Scen_Namn`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_NAM_ST_ID`
            ORDER BY
                r.`ST_NAM_ChangedAt` DESC,
                r.`ST_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_LOC_Scen_Plats`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_LOC_ST_ID`
            ORDER BY
                r.`ST_LOC_PositedAt` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_AVG_Scen_Medel`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_AVG_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_AVG_ST_ID`
            ORDER BY
                r.`ST_AVG_ChangedAt` DESC,
                r.`ST_AVG_PositedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_MIN_Scen_Minimum`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_MIN_ST_ID`
            ORDER BY
                r.`ST_MIN_PositedAt` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE VIEW anchors.`lST_Scen` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    anchors.`tST_Scen`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pST_Scen` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `ST`.`ST_NAM_ST_ID`,
    `ST`.`Metadata_ST_NAM`,
    `ST`.`ST_NAM_ID`,
    `ST`.`ST_NAM_ChangedAt`,
    `ST`.`ST_NAM_PositedAt`,
    `ST`.`ST_NAM_Reliability`,
    `ST`.`ST_NAM_Scen_Namn`,
    `ST`.`ST_LOC_ST_ID`,
    `ST`.`Metadata_ST_LOC`,
    `ST`.`ST_LOC_ID`,
    `ST`.`ST_LOC_PositedAt`,
    `ST`.`ST_LOC_Reliability`,
    `ST`.`ST_LOC_Checksum`,
    `ST`.`ST_LOC_Scen_Plats`,
    `ST`.`ST_AVG_ST_ID`,
    `ST`.`Metadata_ST_AVG`,
    `ST`.`ST_AVG_ID`,
    `ST`.`ST_AVG_ChangedAt`,
    `ST`.`ST_AVG_PositedAt`,
    `ST`.`ST_AVG_Reliability`,
    `ST`.`ST_AVG_UTL_Utnyttjande`,
    `ST`.`ST_AVG_Metadata_UTL`,
    `ST`.`ST_AVG_UTL_ID`,
    `ST`.`ST_MIN_ST_ID`,
    `ST`.`Metadata_ST_MIN`,
    `ST`.`ST_MIN_ID`,
    `ST`.`ST_MIN_PositedAt`,
    `ST`.`ST_MIN_Reliability`,
    `ST`.`ST_MIN_UTL_Utnyttjande`,
    `ST`.`ST_MIN_Metadata_UTL`,
    `ST`.`ST_MIN_UTL_ID`
FROM
    anchors.`tST_Scen`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
)
;
CREATE OR REPLACE VIEW anchors.`nST_Scen` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    anchors.`tST_Scen`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dST_Scen` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_PositedAt`,
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM (
    SELECT DISTINCT
        `ST_NAM_ST_ID` AS `ST_ID`,
        CAST(`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`ST_NAM_Scen_Namn`
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        `ST_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `ST_AVG_ST_ID` AS `ST_ID`,
        CAST(`ST_AVG_ChangedAt` AS datetime) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes.`ST_AVG_Scen_Medel`
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        `ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`ST_Scen` `ST`
ON
    `ST`.`ST_ID` = timepoints.`ST_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`ST_NAM_ChangedAt`) OVER (
            PARTITION BY x.`ST_NAM_ST_ID`
            ORDER BY x.`ST_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rST_NAM_Scen_Namn`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_NAM_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_NAM_ST_ID`, r.`ST_NAM_ChangedAt`
                ORDER BY r.`ST_NAM_PositedAt` DESC
            ) = 1
    ) x
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
AND
    `NAM`.`ST_NAM_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `NAM`.`until` IS NULL
OR
    `NAM`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rST_LOC_Scen_Plats`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_LOC_ST_ID`
            ORDER BY r.`ST_LOC_PositedAt` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`ST_AVG_ChangedAt`) OVER (
            PARTITION BY x.`ST_AVG_ST_ID`
            ORDER BY x.`ST_AVG_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rST_AVG_Scen_Medel`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_AVG_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_AVG_ST_ID`, r.`ST_AVG_ChangedAt`
                ORDER BY r.`ST_AVG_PositedAt` DESC
            ) = 1
    ) x
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
AND
    `AVG`.`ST_AVG_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `AVG`.`until` IS NULL
OR
    `AVG`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`UTL_Utnyttjande` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rST_MIN_Scen_Minimum`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_MIN_ST_ID`
            ORDER BY r.`ST_MIN_PositedAt` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION anchors.`tAC_Skådespelare` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_PositedAt`,
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Skådespelare` `AC`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_NAM_Skådespelare_Namn`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_NAM_AC_ID`
            ORDER BY
                r.`AC_NAM_ChangedAt` DESC,
                r.`AC_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_GEN_Skådespelare_Kön`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_GEN_AC_ID`
            ORDER BY
                r.`AC_GEN_PositedAt` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Kön` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_PLV_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_PLV_AC_ID`
            ORDER BY
                r.`AC_PLV_ChangedAt` DESC,
                r.`AC_PLV_PositedAt` DESC
        ) = 1
) `PLV`
ON
    `PLV`.`AC_PLV_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`PLV_Yrkesnivå` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
CREATE OR REPLACE VIEW anchors.`lAC_Skådespelare` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    anchors.`tAC_Skådespelare`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pAC_Skådespelare` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `AC`.`AC_NAM_AC_ID`,
    `AC`.`Metadata_AC_NAM`,
    `AC`.`AC_NAM_ID`,
    `AC`.`AC_NAM_ChangedAt`,
    `AC`.`AC_NAM_PositedAt`,
    `AC`.`AC_NAM_Reliability`,
    `AC`.`AC_NAM_Skådespelare_Namn`,
    `AC`.`AC_GEN_AC_ID`,
    `AC`.`Metadata_AC_GEN`,
    `AC`.`AC_GEN_ID`,
    `AC`.`AC_GEN_PositedAt`,
    `AC`.`AC_GEN_Reliability`,
    `AC`.`AC_GEN_GEN_Checksum`,
    `AC`.`AC_GEN_GEN_Kön`,
    `AC`.`AC_GEN_Metadata_GEN`,
    `AC`.`AC_GEN_GEN_ID`,
    `AC`.`AC_PLV_AC_ID`,
    `AC`.`Metadata_AC_PLV`,
    `AC`.`AC_PLV_ID`,
    `AC`.`AC_PLV_ChangedAt`,
    `AC`.`AC_PLV_PositedAt`,
    `AC`.`AC_PLV_Reliability`,
    `AC`.`AC_PLV_PLV_Checksum`,
    `AC`.`AC_PLV_PLV_Yrkesnivå`,
    `AC`.`AC_PLV_Metadata_PLV`,
    `AC`.`AC_PLV_PLV_ID`
FROM
    anchors.`tAC_Skådespelare`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
)
;
CREATE OR REPLACE VIEW anchors.`nAC_Skådespelare` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    anchors.`tAC_Skådespelare`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dAC_Skådespelare` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_PositedAt`,
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM (
    SELECT DISTINCT
        `AC_NAM_AC_ID` AS `AC_ID`,
        CAST(`AC_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`AC_NAM_Skådespelare_Namn`
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        `AC_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `AC_PLV_AC_ID` AS `AC_ID`,
        CAST(`AC_PLV_ChangedAt` AS datetime) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes.`AC_PLV_Skådespelare_Yrkesnivå`
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        `AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`AC_Skådespelare` `AC`
ON
    `AC`.`AC_ID` = timepoints.`AC_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`AC_NAM_ChangedAt`) OVER (
            PARTITION BY x.`AC_NAM_AC_ID`
            ORDER BY x.`AC_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rAC_NAM_Skådespelare_Namn`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_NAM_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_NAM_AC_ID`, r.`AC_NAM_ChangedAt`
                ORDER BY r.`AC_NAM_PositedAt` DESC
            ) = 1
    ) x
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
AND
    `NAM`.`AC_NAM_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `NAM`.`until` IS NULL
OR
    `NAM`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rAC_GEN_Skådespelare_Kön`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_GEN_AC_ID`
            ORDER BY r.`AC_GEN_PositedAt` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Kön` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`AC_PLV_ChangedAt`) OVER (
            PARTITION BY x.`AC_PLV_AC_ID`
            ORDER BY x.`AC_PLV_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_PLV_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_PLV_AC_ID`, r.`AC_PLV_ChangedAt`
                ORDER BY r.`AC_PLV_PositedAt` DESC
            ) = 1
    ) x
) `PLV`
ON
    `PLV`.`AC_PLV_AC_ID` = `AC`.`AC_ID`
AND
    `PLV`.`AC_PLV_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `PLV`.`until` IS NULL
OR
    `PLV`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`PLV_Yrkesnivå` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION anchors.`tPR_Föreställning` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM
    anchors.`PR_Föreställning` `PR`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rPR_NAM_Föreställning_Namn`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_NAM_PR_ID`
            ORDER BY
                r.`PR_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rPR_LEN_Föreställning_Längd`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_LEN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_LEN_PR_ID`
            ORDER BY
                r.`PR_LEN_ChangedAt` DESC,
                r.`PR_LEN_PositedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`
)
;
CREATE OR REPLACE VIEW anchors.`lPR_Föreställning` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    anchors.`tPR_Föreställning`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pPR_Föreställning` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `PR`.`PR_NAM_PR_ID`,
    `PR`.`Metadata_PR_NAM`,
    `PR`.`PR_NAM_ID`,
    `PR`.`PR_NAM_PositedAt`,
    `PR`.`PR_NAM_Reliability`,
    `PR`.`PR_NAM_Föreställning_Namn`,
    `PR`.`PR_LEN_PR_ID`,
    `PR`.`Metadata_PR_LEN`,
    `PR`.`PR_LEN_ID`,
    `PR`.`PR_LEN_ChangedAt`,
    `PR`.`PR_LEN_PositedAt`,
    `PR`.`PR_LEN_Reliability`,
    `PR`.`PR_LEN_Föreställning_Längd`
FROM
    anchors.`tPR_Föreställning`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
)
;
CREATE OR REPLACE VIEW anchors.`nPR_Föreställning` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    anchors.`tPR_Föreställning`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dPR_Föreställning` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM (
    SELECT DISTINCT
        `PR_LEN_PR_ID` AS `PR_ID`,
        CAST(`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes.`PR_LEN_Föreställning_Längd`
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        `PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`PR_Föreställning` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rPR_NAM_Föreställning_Namn`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_NAM_PR_ID`
            ORDER BY r.`PR_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`PR_LEN_ChangedAt`) OVER (
            PARTITION BY x.`PR_LEN_PR_ID`
            ORDER BY x.`PR_LEN_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rPR_LEN_Föreställning_Längd`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_LEN_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`PR_LEN_PR_ID`, r.`PR_LEN_ChangedAt`
                ORDER BY r.`PR_LEN_PositedAt` DESC
            ) = 1
    ) x
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`
AND
    `LEN`.`PR_LEN_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS date)
AND (
    `LEN`.`until` IS NULL
OR
    `LEN`.`until` > CAST(timepoints.inspectedTimepoint AS date)
)
)
;
