-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION nexuses.`tEV_Händelse` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Reliability`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Reliability`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Händelse` `EV`
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Händelse_Datum`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_DAT_EV_ID`
            ORDER BY
                r.`EV_DAT_PositedAt` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_AUD_Händelse_Publik`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_AUD_EV_ID`
            ORDER BY
                r.`EV_AUD_PositedAt` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_REV_Händelse_Intäkt`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_REV_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_EV_ID`
            ORDER BY
                r.`EV_REV_PositedAt` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_STA_Händelse_Status`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_STA_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_STA_EV_ID`
            ORDER BY
                r.`EV_STA_ChangedAt` DESC,
                r.`EV_STA_PositedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_UTL_Händelse_Utnyttjande`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_EV_ID`
            ORDER BY
                r.`EV_UTL_PositedAt` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_LVL_Händelse_Level`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_LVL_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_LVL_EV_ID`
            ORDER BY
                r.`EV_LVL_ChangedAt` DESC,
                r.`EV_LVL_PositedAt` DESC
        ) = 1
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`PLV_Yrkesnivå` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
CREATE OR REPLACE VIEW nexuses.`lEV_Händelse` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    nexuses.`tEV_Händelse`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Händelse` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `EV`.`of_ETY_Checksum`,
    `EV`.`of_ETY_Händelsetyp`,
    `EV`.`of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `EV`.`EV_DAT_EV_ID`,
    `EV`.`Metadata_EV_DAT`,
    `EV`.`EV_DAT_ID`,
    `EV`.`EV_DAT_PositedAt`,
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Händelse_Datum`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Händelse_Publik`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Händelse_Intäkt`,
    `EV`.`EV_STA_EV_ID`,
    `EV`.`Metadata_EV_STA`,
    `EV`.`EV_STA_ID`,
    `EV`.`EV_STA_ChangedAt`,
    `EV`.`EV_STA_PositedAt`,
    `EV`.`EV_STA_Reliability`,
    `EV`.`EV_STA_Händelse_Status`,
    `EV`.`EV_UTL_EV_ID`,
    `EV`.`Metadata_EV_UTL`,
    `EV`.`EV_UTL_ID`,
    `EV`.`EV_UTL_PositedAt`,
    `EV`.`EV_UTL_Reliability`,
    `EV`.`EV_UTL_UTL_Utnyttjande`,
    `EV`.`EV_UTL_Metadata_UTL`,
    `EV`.`EV_UTL_UTL_ID`,
    `EV`.`EV_LVL_EV_ID`,
    `EV`.`Metadata_EV_LVL`,
    `EV`.`EV_LVL_ID`,
    `EV`.`EV_LVL_ChangedAt`,
    `EV`.`EV_LVL_PositedAt`,
    `EV`.`EV_LVL_Reliability`,
    `EV`.`EV_LVL_PLV_Checksum`,
    `EV`.`EV_LVL_PLV_Yrkesnivå`,
    `EV`.`EV_LVL_Metadata_PLV`,
    `EV`.`EV_LVL_PLV_ID`
FROM
    nexuses.`tEV_Händelse`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
)
;
CREATE OR REPLACE VIEW nexuses.`nEV_Händelse` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    nexuses.`tEV_Händelse`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Händelse` (
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
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Reliability`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Reliability`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM (
    SELECT DISTINCT
        `EV_STA_EV_ID` AS `EV_ID`,
        CAST(`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Händelse_Status`
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        `EV_STA_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `EV_LVL_EV_ID` AS `EV_ID`,
        CAST(`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Händelse_Level`
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        `EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses.`EV_Händelse` `EV`
ON
    `EV`.`EV_ID` = timepoints.`EV_ID`
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Händelse_Datum`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_DAT_EV_ID`
            ORDER BY r.`EV_DAT_PositedAt` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_AUD_Händelse_Publik`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_AUD_EV_ID`
            ORDER BY r.`EV_AUD_PositedAt` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_REV_Händelse_Intäkt`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_REV_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_EV_ID`
            ORDER BY r.`EV_REV_PositedAt` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`EV_STA_ChangedAt`) OVER (
            PARTITION BY x.`EV_STA_EV_ID`
            ORDER BY x.`EV_STA_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rEV_STA_Händelse_Status`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_STA_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_STA_EV_ID`, r.`EV_STA_ChangedAt`
                ORDER BY r.`EV_STA_PositedAt` DESC
            ) = 1
    ) x
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
AND
    `STA`.`EV_STA_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `STA`.`until` IS NULL
OR
    `STA`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_UTL_Händelse_Utnyttjande`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_EV_ID`
            ORDER BY r.`EV_UTL_PositedAt` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`EV_LVL_ChangedAt`) OVER (
            PARTITION BY x.`EV_LVL_EV_ID`
            ORDER BY x.`EV_LVL_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rEV_LVL_Händelse_Level`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_LVL_Reliability` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_LVL_EV_ID`, r.`EV_LVL_ChangedAt`
                ORDER BY r.`EV_LVL_PositedAt` DESC
            ) = 1
    ) x
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
AND
    `LVL`.`EV_LVL_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS date)
AND (
    `LVL`.`until` IS NULL
OR
    `LVL`.`until` > CAST(timepoints.inspectedTimepoint AS date)
)
LEFT JOIN
    knots.`PLV_Yrkesnivå` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
