-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_STA_Händelse_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Händelse_Status` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_EV_STA`,
        `EV_STA_EV_ID`,
        `EV_STA_Händelse_Status`,
        `EV_STA_ChangedAt`
    FROM
        attributes.`EV_STA_Händelse_Status`
    WHERE
        `EV_STA_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Händelse_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Händelse_Level` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_EV_LVL`,
        `EV_LVL_EV_ID`,
        `EV_LVL_PLV_ID`,
        `EV_LVL_ChangedAt`
    FROM
        attributes.`EV_LVL_Händelse_Level`
    WHERE
        `EV_LVL_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Scen_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Scen_Namn` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_NAM`,
        `ST_NAM_ST_ID`,
        `ST_NAM_Scen_Namn`,
        `ST_NAM_ChangedAt`
    FROM
        attributes.`ST_NAM_Scen_Namn`
    WHERE
        `ST_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Scen_Medel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Scen_Medel` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_AVG`,
        `ST_AVG_ST_ID`,
        `ST_AVG_UTL_ID`,
        `ST_AVG_ChangedAt`
    FROM
        attributes.`ST_AVG_Scen_Medel`
    WHERE
        `ST_AVG_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Skådespelare_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Skådespelare_Namn` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_NAM`,
        `AC_NAM_AC_ID`,
        `AC_NAM_Skådespelare_Namn`,
        `AC_NAM_ChangedAt`
    FROM
        attributes.`AC_NAM_Skådespelare_Namn`
    WHERE
        `AC_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Skådespelare_Yrkesnivå rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Skådespelare_Yrkesnivå` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_PLV`,
        `AC_PLV_AC_ID`,
        `AC_PLV_PLV_ID`,
        `AC_PLV_ChangedAt`
    FROM
        attributes.`AC_PLV_Skådespelare_Yrkesnivå`
    WHERE
        `AC_PLV_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Föreställning_Längd rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Föreställning_Längd` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_PR_LEN`,
        `PR_LEN_PR_ID`,
        `PR_LEN_Föreställning_Längd`,
        `PR_LEN_ChangedAt`
    FROM
        attributes.`PR_LEN_Föreställning_Längd`
    WHERE
        `PR_LEN_ChangedAt` <= changingTimepoint
)
;
