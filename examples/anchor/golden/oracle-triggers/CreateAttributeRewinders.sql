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
-- rEV_PLC_Event_Place rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM
            EV_PLC_Event_Place
        WHERE
            EV_PLC_ChangedAt <= changingTimepoint
    ]';
END rEV_PLC_Event_Place;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TTL_Subject_Title rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM
            SU_TTL_Subject_Title
        WHERE
            SU_TTL_ChangedAt <= changingTimepoint
    ]';
END rSU_TTL_Subject_Title;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_STA_Subject_State rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM
            SU_STA_Subject_State
        WHERE
            SU_STA_ChangedAt <= changingTimepoint
    ]';
END rSU_STA_Subject_State;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LBL_Subject_Label rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM
            SU_LBL_Subject_Label
        WHERE
            SU_LBL_ChangedAt <= changingTimepoint
    ]';
END rSU_LBL_Subject_Label;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TAG_Subject_Tag rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM
            SU_TAG_Subject_Tag
        WHERE
            SU_TAG_ChangedAt <= changingTimepoint
    ]';
END rSU_TAG_Subject_Tag;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_LVL_Subject_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM
            SU_LVL_Subject_Level
        WHERE
            SU_LVL_ChangedAt <= changingTimepoint
    ]';
END rSU_LVL_Subject_Level;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_TXT_Subject_Text rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM
            SU_TXT_Subject_Text
        WHERE
            SU_TXT_ChangedAt <= changingTimepoint
    ]';
END rSU_TXT_Subject_Text;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ASR_Subject_Assessment rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM
            SU_ASR_Subject_Assessment
        WHERE
            SU_ASR_ChangedAt <= changingTimepoint
    ]';
END rSU_ASR_Subject_Assessment;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rSU_ERS_Subject_Erasable rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM
            SU_ERS_Subject_Erasable
        WHERE
            SU_ERS_ChangedAt <= changingTimepoint
    ]';
END rSU_ERS_Subject_Erasable;
/
