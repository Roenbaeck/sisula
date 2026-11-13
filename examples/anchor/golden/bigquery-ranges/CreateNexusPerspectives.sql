-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery nexus perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`lEV_Event` (
    `EV_ID`,
    `Metadata_EV`,
    `ST_ID_wasHeldAt` OPTIONS(description='The stage at which the event was held.'),
    `PR_ID_wasPlayed` OPTIONS(description='The program that was played at the event.'),
    `of_ETY_Checksum`,
    `of_ETY_EventType`,
    `of_Metadata_ETY`,
    `ETY_ID_of`,
    `EV_DAT_EV_ID`,
    `Metadata_EV_DAT`,
    `EV_DAT_Event_Date` OPTIONS(description='Date and time when the event took place.'),
    `EV_AUD_EV_ID`,
    `Metadata_EV_AUD`,
    `EV_AUD_Event_Audience` OPTIONS(description='Number of people in the audience at the event.'),
    `EV_REV_EV_ID`,
    `Metadata_EV_REV`,
    `EV_REV_Event_Revenue` OPTIONS(description='Revenue from ticket sales for the event.'),
    `EV_STA_EV_ID`,
    `Metadata_EV_STA`,
    `EV_STA_ChangedAt`,
    `EV_STA_Event_Status` OPTIONS(description='Status of the event, which may change until it has taken place.'),
    `EV_UTL_EV_ID`,
    `Metadata_EV_UTL`,
    `EV_UTL_UTL_Utilization`,
    `EV_UTL_Metadata_UTL`,
    `EV_UTL_UTL_ID`,
    `EV_LVL_EV_ID`,
    `Metadata_EV_LVL`,
    `EV_LVL_ChangedAt`,
    `EV_LVL_PLV_Checksum`,
    `EV_LVL_PLV_ProfessionalLevel` OPTIONS(description='Professional level required for the event, over time.'),
    `EV_LVL_Metadata_PLV`,
    `EV_LVL_PLV_ID` OPTIONS(description='Professional level required for the event, over time.')
)
OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.')
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Event` `EV`
LEFT JOIN
    knots.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`EV_STA_Event_Status` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`EV_STA_EV_ID`
            ORDER BY t.`EV_STA_ChangedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_UTL_Event_Utilization` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`EV_LVL_Event_Level` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`EV_LVL_EV_ID`
            ORDER BY t.`EV_LVL_ChangedAt` DESC
        ) = 1
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`PLV_ProfessionalLevel` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Event` `EV`
LEFT JOIN
    knots.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rEV_STA_Event_Status`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`EV_STA_EV_ID`
            ORDER BY r.`EV_STA_ChangedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_UTL_Event_Utilization` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rEV_LVL_Event_Level`(CAST(changingTimepoint AS date)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`EV_LVL_EV_ID`
            ORDER BY r.`EV_LVL_ChangedAt` DESC
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
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`nEV_Event` AS
SELECT
    *
FROM
    nexuses.`pEV_Event`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Event` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM (
    SELECT DISTINCT
        h.`EV_STA_EV_ID` AS `EV_ID`,
        CAST(h.`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Event_Status` h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h.`EV_STA_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        h.`EV_LVL_EV_ID` AS `EV_ID`,
        CAST(h.`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Event_Level` h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h.`EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses.`EV_Event` `EV`
ON
    `EV`.`EV_ID` = timepoints.`EV_ID`
LEFT JOIN
    knots.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`EV_STA_ChangedAt`) OVER (
            PARTITION BY h.`EV_STA_EV_ID`
            ORDER BY h.`EV_STA_ChangedAt`
        ) AS `until`
    FROM
        attributes.`EV_STA_Event_Status` h
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
LEFT JOIN
    attributes.`EV_UTL_Event_Utilization` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`EV_LVL_ChangedAt`) OVER (
            PARTITION BY h.`EV_LVL_EV_ID`
            ORDER BY h.`EV_LVL_ChangedAt`
        ) AS `until`
    FROM
        attributes.`EV_LVL_Event_Level` h
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
