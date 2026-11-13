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
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            ST_NAM_Stage_Name
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Stage_Name;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average (
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
            ST_AVG_Stage_Average
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Stage_Average;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            AC_NAM_Actor_Name
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Actor_Name;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel (
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
            AC_PLV_Actor_ProfessionalLevel
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel;
/
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            PR_LEN_Program_Length
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Program_Length;
/
