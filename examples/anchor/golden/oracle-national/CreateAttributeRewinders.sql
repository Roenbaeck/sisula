-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These SQL table macros rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- A SQL table macro (SQL_MACRO, Oracle Database 19.7 or later) is a function that returns the text of a query, in which
-- its parameters stand for the values given. It is called in the FROM clause of a query, like a table:
-- SELECT * FROM rAC_NAM_Actor_Name(TIMESTAMP '2020-01-01 00:00:00').
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_STA_Händelse_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Händelse_Status (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_EV_ID,
            EV_STA_Händelse_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Händelse_Status
        WHERE
            EV_STA_ChangedAt <= changingTimepoint
    ]';
END rEV_STA_Händelse_Status;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Händelse_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Händelse_Level (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Händelse_Level
        WHERE
            EV_LVL_ChangedAt <= changingTimepoint
    ]';
END rEV_LVL_Händelse_Level;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Scen_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Scen_Namn (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Scen_Namn,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Scen_Namn
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Scen_Namn;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Scen_Medel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Scen_Medel (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Scen_Medel
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Scen_Medel;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Skådespelare_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Skådespelare_Namn (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Skådespelare_Namn,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Skådespelare_Namn
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Skådespelare_Namn;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Skådespelare_Yrkesnivå rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Skådespelare_Yrkesnivå (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Skådespelare_Yrkesnivå
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Skådespelare_Yrkesnivå;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Föreställning_Längd rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Föreställning_Längd (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Föreställning_Längd,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Föreställning_Längd
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Föreställning_Längd;
/
