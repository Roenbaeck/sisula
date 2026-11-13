-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the 
-- union of the two will produce all rows in a posit table.
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Event_Date_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_DAT`,
    `EV_DAT_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Who`,
    `EV_DAT_Confidence`,
    CASE
        WHEN `EV_DAT_Confidence` > 0.25 THEN '+'
        WHEN `EV_DAT_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_DAT_Stance`
FROM
    attributes.`EV_DAT_Event_Date_Meta`
WHERE
    `EV_DAT_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Event_Date` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Who`,
    a.`EV_DAT_Confidence`,
    CASE
        WHEN a.`EV_DAT_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_DAT_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_DAT_Stance`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Event_Date`
FROM
    attributes.`EV_DAT_Event_Date_Fact` p
JOIN
    attributes.`rEV_DAT_Event_Date_Meta`(positingTimepoint) a
ON
    a.`EV_DAT_ID` = p.`EV_DAT_ID`
AND
    a.`EV_DAT_Who` = coalesce(positor, a.`EV_DAT_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_DAT_ID`, a.`EV_DAT_Who`
        ORDER BY a.`EV_DAT_PositedAt` DESC
    ) = 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Event_Audience_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_AUD`,
    `EV_AUD_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Who`,
    `EV_AUD_Confidence`,
    CASE
        WHEN `EV_AUD_Confidence` > 0.25 THEN '+'
        WHEN `EV_AUD_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_AUD_Stance`
FROM
    attributes.`EV_AUD_Event_Audience_Meta`
WHERE
    `EV_AUD_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Event_Audience` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Who`,
    a.`EV_AUD_Confidence`,
    CASE
        WHEN a.`EV_AUD_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_AUD_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_AUD_Stance`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Event_Audience`
FROM
    attributes.`EV_AUD_Event_Audience_Fact` p
JOIN
    attributes.`rEV_AUD_Event_Audience_Meta`(positingTimepoint) a
ON
    a.`EV_AUD_ID` = p.`EV_AUD_ID`
AND
    a.`EV_AUD_Who` = coalesce(positor, a.`EV_AUD_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_AUD_ID`, a.`EV_AUD_Who`
        ORDER BY a.`EV_AUD_PositedAt` DESC
    ) = 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Event_Revenue_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_REV`,
    `EV_REV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Who`,
    `EV_REV_Confidence`,
    CASE
        WHEN `EV_REV_Confidence` > 0.25 THEN '+'
        WHEN `EV_REV_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_REV_Stance`
FROM
    attributes.`EV_REV_Event_Revenue_Meta`
WHERE
    `EV_REV_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Event_Revenue` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Who`,
    a.`EV_REV_Confidence`,
    CASE
        WHEN a.`EV_REV_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_REV_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_REV_Stance`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Event_Revenue`
FROM
    attributes.`EV_REV_Event_Revenue_Fact` p
JOIN
    attributes.`rEV_REV_Event_Revenue_Meta`(positingTimepoint) a
ON
    a.`EV_REV_ID` = p.`EV_REV_ID`
AND
    a.`EV_REV_Who` = coalesce(positor, a.`EV_REV_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_REV_ID`, a.`EV_REV_Who`
        ORDER BY a.`EV_REV_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Event_Status_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV_STA_ID`,
    `EV_STA_EV_ID`,
    `EV_STA_Event_Status`,
    `EV_STA_ChangedAt`
FROM
    attributes.`EV_STA_Event_Status_Fact`
WHERE
    `EV_STA_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_STA_Event_Status_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV_STA_ID`,
    `EV_STA_EV_ID`,
    `EV_STA_Event_Status`,
    `EV_STA_ChangedAt`
FROM
    attributes.`EV_STA_Event_Status_Fact`
WHERE
    `EV_STA_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Event_Status_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_STA`,
    `EV_STA_ID`,
    `EV_STA_PositedAt`,
    `EV_STA_Who`,
    `EV_STA_Confidence`,
    CASE
        WHEN `EV_STA_Confidence` > 0.25 THEN '+'
        WHEN `EV_STA_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_STA_Stance`
FROM
    attributes.`EV_STA_Event_Status_Meta`
WHERE
    `EV_STA_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Event_Status` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Who`,
    a.`EV_STA_Confidence`,
    CASE
        WHEN a.`EV_STA_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_STA_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_STA_Stance`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Event_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`rEV_STA_Event_Status_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Event_Status_Meta`(positingTimepoint) a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
AND
    a.`EV_STA_Who` = coalesce(positor, a.`EV_STA_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_STA_ID`, a.`EV_STA_Who`
        ORDER BY a.`EV_STA_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_STA_Event_Status` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Who`,
    a.`EV_STA_Confidence`,
    CASE
        WHEN a.`EV_STA_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_STA_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_STA_Stance`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Event_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`fEV_STA_Event_Status_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Event_Status_Meta`(positingTimepoint) a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
AND
    a.`EV_STA_Who` = coalesce(positor, a.`EV_STA_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_STA_ID`, a.`EV_STA_Who`
        ORDER BY a.`EV_STA_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_STA_Event_Status` (
    id numeric(12,0),
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`EV_STA_Event_Status`
FROM
    attributes.`rEV_STA_Event_Status`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_STA_EV_ID` = id
AND
    pre.`EV_STA_ChangedAt` < changingTimepoint
AND
    pre.`EV_STA_Stance` = coalesce(assertion, pre.`EV_STA_Stance`)
ORDER BY
    pre.`EV_STA_ChangedAt` DESC,
    pre.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_STA_Event_Status` (
    id numeric(12,0),
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`EV_STA_Event_Status`
FROM
    attributes.`fEV_STA_Event_Status`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_STA_EV_ID` = id
AND
    fol.`EV_STA_ChangedAt` > changingTimepoint
AND
    fol.`EV_STA_Stance` = coalesce(assertion, fol.`EV_STA_Stance`)
ORDER BY
    fol.`EV_STA_ChangedAt` ASC,
    fol.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Event_Utilization_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_UTL`,
    `EV_UTL_ID`,
    `EV_UTL_PositedAt`,
    `EV_UTL_Who`,
    `EV_UTL_Confidence`,
    CASE
        WHEN `EV_UTL_Confidence` > 0.25 THEN '+'
        WHEN `EV_UTL_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_UTL_Stance`
FROM
    attributes.`EV_UTL_Event_Utilization_Meta`
WHERE
    `EV_UTL_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Event_Utilization` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_UTL`,
    p.`EV_UTL_ID`,
    a.`EV_UTL_PositedAt`,
    a.`EV_UTL_Who`,
    a.`EV_UTL_Confidence`,
    CASE
        WHEN a.`EV_UTL_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_UTL_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_UTL_Stance`,
    p.`EV_UTL_EV_ID`,
    p.`EV_UTL_UTL_ID`
FROM
    attributes.`EV_UTL_Event_Utilization_Fact` p
JOIN
    attributes.`rEV_UTL_Event_Utilization_Meta`(positingTimepoint) a
ON
    a.`EV_UTL_ID` = p.`EV_UTL_ID`
AND
    a.`EV_UTL_Who` = coalesce(positor, a.`EV_UTL_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_UTL_ID`, a.`EV_UTL_Who`
        ORDER BY a.`EV_UTL_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Event_Level_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `EV_LVL_ID`,
    `EV_LVL_EV_ID`,
    `EV_LVL_PLV_ID`,
    `EV_LVL_ChangedAt`
FROM
    attributes.`EV_LVL_Event_Level_Fact`
WHERE
    `EV_LVL_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_LVL_Event_Level_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `EV_LVL_ID`,
    `EV_LVL_EV_ID`,
    `EV_LVL_PLV_ID`,
    `EV_LVL_ChangedAt`
FROM
    attributes.`EV_LVL_Event_Level_Fact`
WHERE
    `EV_LVL_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Event_Level_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_LVL`,
    `EV_LVL_ID`,
    `EV_LVL_PositedAt`,
    `EV_LVL_Who`,
    `EV_LVL_Confidence`,
    CASE
        WHEN `EV_LVL_Confidence` > 0.25 THEN '+'
        WHEN `EV_LVL_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_LVL_Stance`
FROM
    attributes.`EV_LVL_Event_Level_Meta`
WHERE
    `EV_LVL_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Event_Level` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Who`,
    a.`EV_LVL_Confidence`,
    CASE
        WHEN a.`EV_LVL_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_LVL_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_LVL_Stance`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`rEV_LVL_Event_Level_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Event_Level_Meta`(positingTimepoint) a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
AND
    a.`EV_LVL_Who` = coalesce(positor, a.`EV_LVL_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_LVL_ID`, a.`EV_LVL_Who`
        ORDER BY a.`EV_LVL_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_LVL_Event_Level` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Who`,
    a.`EV_LVL_Confidence`,
    CASE
        WHEN a.`EV_LVL_Confidence` > 0.25 THEN '+'
        WHEN a.`EV_LVL_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `EV_LVL_Stance`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`fEV_LVL_Event_Level_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Event_Level_Meta`(positingTimepoint) a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
AND
    a.`EV_LVL_Who` = coalesce(positor, a.`EV_LVL_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_LVL_ID`, a.`EV_LVL_Who`
        ORDER BY a.`EV_LVL_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_LVL_Event_Level` (
    id numeric(12,0),
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`EV_LVL_PLV_ID`
FROM
    attributes.`rEV_LVL_Event_Level`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_LVL_EV_ID` = id
AND
    pre.`EV_LVL_ChangedAt` < changingTimepoint
AND
    pre.`EV_LVL_Stance` = coalesce(assertion, pre.`EV_LVL_Stance`)
ORDER BY
    pre.`EV_LVL_ChangedAt` DESC,
    pre.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_LVL_Event_Level` (
    id numeric(12,0),
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`EV_LVL_PLV_ID`
FROM
    attributes.`fEV_LVL_Event_Level`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_LVL_EV_ID` = id
AND
    fol.`EV_LVL_ChangedAt` > changingTimepoint
AND
    fol.`EV_LVL_Stance` = coalesce(assertion, fol.`EV_LVL_Stance`)
ORDER BY
    fol.`EV_LVL_ChangedAt` ASC,
    fol.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Stage_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    attributes.`ST_NAM_Stage_Name_Fact`
WHERE
    `ST_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_NAM_Stage_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    attributes.`ST_NAM_Stage_Name_Fact`
WHERE
    `ST_NAM_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Stage_Name_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_NAM`,
    `ST_NAM_ID`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Who`,
    `ST_NAM_Confidence`,
    CASE
        WHEN `ST_NAM_Confidence` > 0.25 THEN '+'
        WHEN `ST_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_NAM_Stance`
FROM
    attributes.`ST_NAM_Stage_Name_Meta`
WHERE
    `ST_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Stage_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Who`,
    a.`ST_NAM_Confidence`,
    CASE
        WHEN a.`ST_NAM_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_NAM_Stance`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`rST_NAM_Stage_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Stage_Name_Meta`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
AND
    a.`ST_NAM_Who` = coalesce(positor, a.`ST_NAM_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`, a.`ST_NAM_Who`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_NAM_Stage_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Who`,
    a.`ST_NAM_Confidence`,
    CASE
        WHEN a.`ST_NAM_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_NAM_Stance`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`fST_NAM_Stage_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Stage_Name_Meta`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
AND
    a.`ST_NAM_Who` = coalesce(positor, a.`ST_NAM_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`, a.`ST_NAM_Who`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_NAM_Stage_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`ST_NAM_Stage_Name`
FROM
    attributes.`rST_NAM_Stage_Name`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_NAM_ST_ID` = id
AND
    pre.`ST_NAM_ChangedAt` < changingTimepoint
AND
    pre.`ST_NAM_Stance` = coalesce(assertion, pre.`ST_NAM_Stance`)
ORDER BY
    pre.`ST_NAM_ChangedAt` DESC,
    pre.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_NAM_Stage_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`ST_NAM_Stage_Name`
FROM
    attributes.`fST_NAM_Stage_Name`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_NAM_ST_ID` = id
AND
    fol.`ST_NAM_ChangedAt` > changingTimepoint
AND
    fol.`ST_NAM_Stance` = coalesce(assertion, fol.`ST_NAM_Stance`)
ORDER BY
    fol.`ST_NAM_ChangedAt` ASC,
    fol.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Stage_Location_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_LOC`,
    `ST_LOC_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Who`,
    `ST_LOC_Confidence`,
    CASE
        WHEN `ST_LOC_Confidence` > 0.25 THEN '+'
        WHEN `ST_LOC_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_LOC_Stance`
FROM
    attributes.`ST_LOC_Stage_Location_Meta`
WHERE
    `ST_LOC_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Stage_Location` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Who`,
    a.`ST_LOC_Confidence`,
    CASE
        WHEN a.`ST_LOC_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_LOC_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_LOC_Stance`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Stage_Location`
FROM
    attributes.`ST_LOC_Stage_Location_Fact` p
JOIN
    attributes.`rST_LOC_Stage_Location_Meta`(positingTimepoint) a
ON
    a.`ST_LOC_ID` = p.`ST_LOC_ID`
AND
    a.`ST_LOC_Who` = coalesce(positor, a.`ST_LOC_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_LOC_ID`, a.`ST_LOC_Who`
        ORDER BY a.`ST_LOC_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Stage_Average_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    attributes.`ST_AVG_Stage_Average_Fact`
WHERE
    `ST_AVG_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_AVG_Stage_Average_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    attributes.`ST_AVG_Stage_Average_Fact`
WHERE
    `ST_AVG_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Stage_Average_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_AVG`,
    `ST_AVG_ID`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Who`,
    `ST_AVG_Confidence`,
    CASE
        WHEN `ST_AVG_Confidence` > 0.25 THEN '+'
        WHEN `ST_AVG_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_AVG_Stance`
FROM
    attributes.`ST_AVG_Stage_Average_Meta`
WHERE
    `ST_AVG_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Stage_Average` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Who`,
    a.`ST_AVG_Confidence`,
    CASE
        WHEN a.`ST_AVG_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_AVG_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_AVG_Stance`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    attributes.`rST_AVG_Stage_Average_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Stage_Average_Meta`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
AND
    a.`ST_AVG_Who` = coalesce(positor, a.`ST_AVG_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`, a.`ST_AVG_Who`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_AVG_Stage_Average` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Who`,
    a.`ST_AVG_Confidence`,
    CASE
        WHEN a.`ST_AVG_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_AVG_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_AVG_Stance`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    attributes.`fST_AVG_Stage_Average_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Stage_Average_Meta`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
AND
    a.`ST_AVG_Who` = coalesce(positor, a.`ST_AVG_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`, a.`ST_AVG_Who`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_AVG_Stage_Average` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`ST_AVG_UTL_ID`
FROM
    attributes.`rST_AVG_Stage_Average`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_AVG_ST_ID` = id
AND
    pre.`ST_AVG_ChangedAt` < changingTimepoint
AND
    pre.`ST_AVG_Stance` = coalesce(assertion, pre.`ST_AVG_Stance`)
ORDER BY
    pre.`ST_AVG_ChangedAt` DESC,
    pre.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_AVG_Stage_Average` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`ST_AVG_UTL_ID`
FROM
    attributes.`fST_AVG_Stage_Average`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_AVG_ST_ID` = id
AND
    fol.`ST_AVG_ChangedAt` > changingTimepoint
AND
    fol.`ST_AVG_Stance` = coalesce(assertion, fol.`ST_AVG_Stance`)
ORDER BY
    fol.`ST_AVG_ChangedAt` ASC,
    fol.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Stage_Minimum_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_MIN`,
    `ST_MIN_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Who`,
    `ST_MIN_Confidence`,
    CASE
        WHEN `ST_MIN_Confidence` > 0.25 THEN '+'
        WHEN `ST_MIN_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_MIN_Stance`
FROM
    attributes.`ST_MIN_Stage_Minimum_Meta`
WHERE
    `ST_MIN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Stage_Minimum` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_MIN`,
    p.`ST_MIN_ID`,
    a.`ST_MIN_PositedAt`,
    a.`ST_MIN_Who`,
    a.`ST_MIN_Confidence`,
    CASE
        WHEN a.`ST_MIN_Confidence` > 0.25 THEN '+'
        WHEN a.`ST_MIN_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `ST_MIN_Stance`,
    p.`ST_MIN_ST_ID`,
    p.`ST_MIN_UTL_ID`
FROM
    attributes.`ST_MIN_Stage_Minimum_Fact` p
JOIN
    attributes.`rST_MIN_Stage_Minimum_Meta`(positingTimepoint) a
ON
    a.`ST_MIN_ID` = p.`ST_MIN_ID`
AND
    a.`ST_MIN_Who` = coalesce(positor, a.`ST_MIN_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_MIN_ID`, a.`ST_MIN_Who`
        ORDER BY a.`ST_MIN_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Actor_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    attributes.`AC_NAM_Actor_Name_Fact`
WHERE
    `AC_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_NAM_Actor_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    attributes.`AC_NAM_Actor_Name_Fact`
WHERE
    `AC_NAM_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Actor_Name_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_NAM`,
    `AC_NAM_ID`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Who`,
    `AC_NAM_Confidence`,
    CASE
        WHEN `AC_NAM_Confidence` > 0.25 THEN '+'
        WHEN `AC_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_NAM_Stance`
FROM
    attributes.`AC_NAM_Actor_Name_Meta`
WHERE
    `AC_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Actor_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Who`,
    a.`AC_NAM_Confidence`,
    CASE
        WHEN a.`AC_NAM_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_NAM_Stance`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`rAC_NAM_Actor_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Actor_Name_Meta`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
AND
    a.`AC_NAM_Who` = coalesce(positor, a.`AC_NAM_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`, a.`AC_NAM_Who`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_NAM_Actor_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Who`,
    a.`AC_NAM_Confidence`,
    CASE
        WHEN a.`AC_NAM_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_NAM_Stance`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`fAC_NAM_Actor_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Actor_Name_Meta`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
AND
    a.`AC_NAM_Who` = coalesce(positor, a.`AC_NAM_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`, a.`AC_NAM_Who`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_NAM_Actor_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`AC_NAM_Actor_Name`
FROM
    attributes.`rAC_NAM_Actor_Name`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_NAM_AC_ID` = id
AND
    pre.`AC_NAM_ChangedAt` < changingTimepoint
AND
    pre.`AC_NAM_Stance` = coalesce(assertion, pre.`AC_NAM_Stance`)
ORDER BY
    pre.`AC_NAM_ChangedAt` DESC,
    pre.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_NAM_Actor_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`AC_NAM_Actor_Name`
FROM
    attributes.`fAC_NAM_Actor_Name`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_NAM_AC_ID` = id
AND
    fol.`AC_NAM_ChangedAt` > changingTimepoint
AND
    fol.`AC_NAM_Stance` = coalesce(assertion, fol.`AC_NAM_Stance`)
ORDER BY
    fol.`AC_NAM_ChangedAt` ASC,
    fol.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Actor_Gender_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_GEN`,
    `AC_GEN_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Who`,
    `AC_GEN_Confidence`,
    CASE
        WHEN `AC_GEN_Confidence` > 0.25 THEN '+'
        WHEN `AC_GEN_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_GEN_Stance`
FROM
    attributes.`AC_GEN_Actor_Gender_Meta`
WHERE
    `AC_GEN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Actor_Gender` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_GEN`,
    p.`AC_GEN_ID`,
    a.`AC_GEN_PositedAt`,
    a.`AC_GEN_Who`,
    a.`AC_GEN_Confidence`,
    CASE
        WHEN a.`AC_GEN_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_GEN_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_GEN_Stance`,
    p.`AC_GEN_AC_ID`,
    p.`AC_GEN_GEN_ID`
FROM
    attributes.`AC_GEN_Actor_Gender_Fact` p
JOIN
    attributes.`rAC_GEN_Actor_Gender_Meta`(positingTimepoint) a
ON
    a.`AC_GEN_ID` = p.`AC_GEN_ID`
AND
    a.`AC_GEN_Who` = coalesce(positor, a.`AC_GEN_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_GEN_ID`, a.`AC_GEN_Who`
        ORDER BY a.`AC_GEN_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Actor_ProfessionalLevel_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel_Fact`
WHERE
    `AC_PLV_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_PLV_Actor_ProfessionalLevel_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel_Fact`
WHERE
    `AC_PLV_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Actor_ProfessionalLevel_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_PLV`,
    `AC_PLV_ID`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Who`,
    `AC_PLV_Confidence`,
    CASE
        WHEN `AC_PLV_Confidence` > 0.25 THEN '+'
        WHEN `AC_PLV_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_PLV_Stance`
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel_Meta`
WHERE
    `AC_PLV_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Actor_ProfessionalLevel` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Who`,
    a.`AC_PLV_Confidence`,
    CASE
        WHEN a.`AC_PLV_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_PLV_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_PLV_Stance`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    attributes.`rAC_PLV_Actor_ProfessionalLevel_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Actor_ProfessionalLevel_Meta`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
AND
    a.`AC_PLV_Who` = coalesce(positor, a.`AC_PLV_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`, a.`AC_PLV_Who`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_PLV_Actor_ProfessionalLevel` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Who`,
    a.`AC_PLV_Confidence`,
    CASE
        WHEN a.`AC_PLV_Confidence` > 0.25 THEN '+'
        WHEN a.`AC_PLV_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `AC_PLV_Stance`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    attributes.`fAC_PLV_Actor_ProfessionalLevel_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Actor_ProfessionalLevel_Meta`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
AND
    a.`AC_PLV_Who` = coalesce(positor, a.`AC_PLV_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`, a.`AC_PLV_Who`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`AC_PLV_PLV_ID`
FROM
    attributes.`rAC_PLV_Actor_ProfessionalLevel`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_PLV_AC_ID` = id
AND
    pre.`AC_PLV_ChangedAt` < changingTimepoint
AND
    pre.`AC_PLV_Stance` = coalesce(assertion, pre.`AC_PLV_Stance`)
ORDER BY
    pre.`AC_PLV_ChangedAt` DESC,
    pre.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`AC_PLV_PLV_ID`
FROM
    attributes.`fAC_PLV_Actor_ProfessionalLevel`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_PLV_AC_ID` = id
AND
    fol.`AC_PLV_ChangedAt` > changingTimepoint
AND
    fol.`AC_PLV_Stance` = coalesce(assertion, fol.`AC_PLV_Stance`)
ORDER BY
    fol.`AC_PLV_ChangedAt` ASC,
    fol.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Program_Name_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_NAM`,
    `PR_NAM_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Who`,
    `PR_NAM_Confidence`,
    CASE
        WHEN `PR_NAM_Confidence` > 0.25 THEN '+'
        WHEN `PR_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_NAM_Stance`
FROM
    attributes.`PR_NAM_Program_Name_Meta`
WHERE
    `PR_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Program_Name` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Who`,
    a.`PR_NAM_Confidence`,
    CASE
        WHEN a.`PR_NAM_Confidence` > 0.25 THEN '+'
        WHEN a.`PR_NAM_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_NAM_Stance`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Program_Name`
FROM
    attributes.`PR_NAM_Program_Name_Fact` p
JOIN
    attributes.`rPR_NAM_Program_Name_Meta`(positingTimepoint) a
ON
    a.`PR_NAM_ID` = p.`PR_NAM_ID`
AND
    a.`PR_NAM_Who` = coalesce(positor, a.`PR_NAM_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_NAM_ID`, a.`PR_NAM_Who`
        ORDER BY a.`PR_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Program_Length_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    attributes.`PR_LEN_Program_Length_Fact`
WHERE
    `PR_LEN_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fPR_LEN_Program_Length_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    attributes.`PR_LEN_Program_Length_Fact`
WHERE
    `PR_LEN_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Program_Length_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_LEN`,
    `PR_LEN_ID`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Who`,
    `PR_LEN_Confidence`,
    CASE
        WHEN `PR_LEN_Confidence` > 0.25 THEN '+'
        WHEN `PR_LEN_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_LEN_Stance`
FROM
    attributes.`PR_LEN_Program_Length_Meta`
WHERE
    `PR_LEN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Program_Length` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Who`,
    a.`PR_LEN_Confidence`,
    CASE
        WHEN a.`PR_LEN_Confidence` > 0.25 THEN '+'
        WHEN a.`PR_LEN_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_LEN_Stance`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`rPR_LEN_Program_Length_Fact`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Program_Length_Meta`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
AND
    a.`PR_LEN_Who` = coalesce(positor, a.`PR_LEN_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`, a.`PR_LEN_Who`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fPR_LEN_Program_Length` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Who`,
    a.`PR_LEN_Confidence`,
    CASE
        WHEN a.`PR_LEN_Confidence` > 0.25 THEN '+'
        WHEN a.`PR_LEN_Confidence` = 0.25 THEN '?'
        ELSE '-'
    END AS `PR_LEN_Stance`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`fPR_LEN_Program_Length_Fact`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Program_Length_Meta`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
AND
    a.`PR_LEN_Who` = coalesce(positor, a.`PR_LEN_Who`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`, a.`PR_LEN_Who`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`prePR_LEN_Program_Length` (
    id int64,
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`PR_LEN_Program_Length`
FROM
    attributes.`rPR_LEN_Program_Length`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`PR_LEN_PR_ID` = id
AND
    pre.`PR_LEN_ChangedAt` < changingTimepoint
AND
    pre.`PR_LEN_Stance` = coalesce(assertion, pre.`PR_LEN_Stance`)
ORDER BY
    pre.`PR_LEN_ChangedAt` DESC,
    pre.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folPR_LEN_Program_Length` (
    id int64,
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`PR_LEN_Program_Length`
FROM
    attributes.`fPR_LEN_Program_Length`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`PR_LEN_PR_ID` = id
AND
    fol.`PR_LEN_ChangedAt` > changingTimepoint
AND
    fol.`PR_LEN_Stance` = coalesce(assertion, fol.`PR_LEN_Stance`)
ORDER BY
    fol.`PR_LEN_ChangedAt` ASC,
    fol.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
