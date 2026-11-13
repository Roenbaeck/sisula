-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION nexuses.`tEV_Event` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Confidence`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Confidence`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Confidence`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Confidence`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Confidence`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Confidence`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Event` `EV`
LEFT JOIN
    knots.`ETY_EventType` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Event_Date`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Confidence` = 1
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
        attributes.`rEV_AUD_Event_Audience`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Confidence` = 1
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
        attributes.`rEV_REV_Event_Revenue`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_REV_Confidence` = 1
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
        attributes.`rEV_STA_Event_Status`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_STA_Confidence` = 1
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
        attributes.`rEV_UTL_Event_Utilization`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Confidence` = 1
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
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_LVL_Event_Level`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_LVL_Confidence` = 1
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
    knots.`PLV_ProfessionalLevel` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
CREATE OR REPLACE VIEW nexuses.`lEV_Event` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `EV`.*
FROM
    nexuses.`tEV_Event`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `EV`.`of_ETY_Checksum`,
    `EV`.`of_ETY_EventType`,
    `EV`.`of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `EV`.`EV_DAT_EV_ID`,
    `EV`.`Metadata_EV_DAT`,
    `EV`.`EV_DAT_ID`,
    `EV`.`EV_DAT_PositedAt`,
    `EV`.`EV_DAT_Confidence`,
    `EV`.`EV_DAT_Event_Date`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Confidence`,
    `EV`.`EV_AUD_Event_Audience`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Confidence`,
    `EV`.`EV_REV_Event_Revenue`,
    `EV`.`EV_STA_EV_ID`,
    `EV`.`Metadata_EV_STA`,
    `EV`.`EV_STA_ID`,
    `EV`.`EV_STA_ChangedAt`,
    `EV`.`EV_STA_PositedAt`,
    `EV`.`EV_STA_Confidence`,
    `EV`.`EV_STA_Event_Status`,
    `EV`.`EV_UTL_EV_ID`,
    `EV`.`Metadata_EV_UTL`,
    `EV`.`EV_UTL_ID`,
    `EV`.`EV_UTL_PositedAt`,
    `EV`.`EV_UTL_Confidence`,
    `EV`.`EV_UTL_UTL_Utilization`,
    `EV`.`EV_UTL_Metadata_UTL`,
    `EV`.`EV_UTL_UTL_ID`,
    `EV`.`EV_LVL_EV_ID`,
    `EV`.`Metadata_EV_LVL`,
    `EV`.`EV_LVL_ID`,
    `EV`.`EV_LVL_ChangedAt`,
    `EV`.`EV_LVL_PositedAt`,
    `EV`.`EV_LVL_Confidence`,
    `EV`.`EV_LVL_PLV_Checksum`,
    `EV`.`EV_LVL_PLV_ProfessionalLevel`,
    `EV`.`EV_LVL_Metadata_PLV`,
    `EV`.`EV_LVL_PLV_ID`
FROM
    nexuses.`tEV_Event`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
)
;
CREATE OR REPLACE VIEW nexuses.`nEV_Event` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `EV`.*
FROM
    nexuses.`tEV_Event`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Event` (
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
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Confidence`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Confidence`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Confidence`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Confidence`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Confidence`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Confidence`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM (
    SELECT DISTINCT
        `EV_STA_EV_ID` AS `EV_ID`,
        CAST(`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Event_Status`
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
        attributes.`EV_LVL_Event_Level`
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        `EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses.`EV_Event` `EV`
ON
    `EV`.`EV_ID` = timepoints.`EV_ID`
LEFT JOIN
    knots.`ETY_EventType` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Event_Date`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Confidence` = 1
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
        attributes.`rEV_AUD_Event_Audience`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Confidence` = 1
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
        attributes.`rEV_REV_Event_Revenue`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_REV_Confidence` = 1
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
            attributes.`rEV_STA_Event_Status`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_STA_Confidence` = 1
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
        attributes.`rEV_UTL_Event_Utilization`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_EV_ID`
            ORDER BY r.`EV_UTL_PositedAt` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
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
            attributes.`rEV_LVL_Event_Level`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_LVL_Confidence` = 1
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
    knots.`PLV_ProfessionalLevel` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
