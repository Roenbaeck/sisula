-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These SQL table macros rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the
-- union of the two will produce all rows in a posit table.
--
-- A SQL table macro (SQL_MACRO, Oracle Database 19.7 or later) is a function that returns the text of a query, in which
-- its parameters stand for the values given. It is called in the FROM clause of a query, like a table:
-- SELECT * FROM rAC_NAM_Actor_Name(CAST(NULL AS number), TIMESTAMP '2020-01-01 00:00:00', TIMESTAMP '2020-01-01 00:00:00').
--
-- The assembled rewinder and forwarder pick, for each posit and positor, the annex row that was last posited
-- at or before the positing time (the macros do not call each other, they do what the others do in their own query).
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_DAT_Event_Date_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Positor,
            EV_DAT_Reliability,
            EV_DAT_Assertion
        FROM
            EV_DAT_Event_Date_Annex
        WHERE
            EV_DAT_PositedAt <= positingTimepoint
    ]';
END rEV_DAT_Event_Date_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_DAT_Event_Date (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Positor,
            EV_DAT_Reliability,
            EV_DAT_Assertion,
            EV_ID,
            EV_DAT_Event_Date
        FROM (
            SELECT
                p.EV_DAT_ID,
                a.EV_DAT_PositedAt,
                a.EV_DAT_Positor,
                a.EV_DAT_Reliability,
                a.EV_DAT_Assertion,
                p.EV_ID,
                p.EV_DAT_Event_Date,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_DAT_ID,
                        a.EV_DAT_Positor
                    ORDER BY
                        a.EV_DAT_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_DAT_Event_Date_Posit p
            JOIN
                EV_DAT_Event_Date_Annex a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            AND
                a.EV_DAT_Positor = COALESCE(positor, a.EV_DAT_Positor)
            WHERE
                a.EV_DAT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_DAT_Event_Date;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_AUD_Event_Audience_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Positor,
            EV_AUD_Reliability,
            EV_AUD_Assertion
        FROM
            EV_AUD_Event_Audience_Annex
        WHERE
            EV_AUD_PositedAt <= positingTimepoint
    ]';
END rEV_AUD_Event_Audience_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_AUD_Event_Audience (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Positor,
            EV_AUD_Reliability,
            EV_AUD_Assertion,
            EV_ID,
            EV_AUD_Event_Audience
        FROM (
            SELECT
                p.EV_AUD_ID,
                a.EV_AUD_PositedAt,
                a.EV_AUD_Positor,
                a.EV_AUD_Reliability,
                a.EV_AUD_Assertion,
                p.EV_ID,
                p.EV_AUD_Event_Audience,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_AUD_ID,
                        a.EV_AUD_Positor
                    ORDER BY
                        a.EV_AUD_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_AUD_Event_Audience_Posit p
            JOIN
                EV_AUD_Event_Audience_Annex a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            AND
                a.EV_AUD_Positor = COALESCE(positor, a.EV_AUD_Positor)
            WHERE
                a.EV_AUD_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_AUD_Event_Audience;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_REV_Event_Revenue_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Positor,
            EV_REV_Reliability,
            EV_REV_Assertion
        FROM
            EV_REV_Event_Revenue_Annex
        WHERE
            EV_REV_PositedAt <= positingTimepoint
    ]';
END rEV_REV_Event_Revenue_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_REV_Event_Revenue (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Positor,
            EV_REV_Reliability,
            EV_REV_Assertion,
            EV_ID,
            EV_REV_Event_Revenue
        FROM (
            SELECT
                p.EV_REV_ID,
                a.EV_REV_PositedAt,
                a.EV_REV_Positor,
                a.EV_REV_Reliability,
                a.EV_REV_Assertion,
                p.EV_ID,
                p.EV_REV_Event_Revenue,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_REV_ID,
                        a.EV_REV_Positor
                    ORDER BY
                        a.EV_REV_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_REV_Event_Revenue_Posit p
            JOIN
                EV_REV_Event_Revenue_Annex a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            AND
                a.EV_REV_Positor = COALESCE(positor, a.EV_REV_Positor)
            WHERE
                a.EV_REV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_REV_Event_Revenue;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            ST_NAM_Stage_Name_Posit
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Stage_Name_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_NAM_Stage_Name_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            ST_NAM_Stage_Name_Posit
        WHERE
            ST_NAM_ChangedAt > changingTimepoint
    ]';
END fST_NAM_Stage_Name_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability,
            ST_NAM_Assertion
        FROM
            ST_NAM_Stage_Name_Annex
        WHERE
            ST_NAM_PositedAt <= positingTimepoint
    ]';
END rST_NAM_Stage_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_NAM_Stage_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability,
            ST_NAM_Assertion,
            ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Positor,
                a.ST_NAM_Reliability,
                a.ST_NAM_Assertion,
                p.ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Positor
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_NAM_Stage_Name_Posit p
            JOIN
                ST_NAM_Stage_Name_Annex a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Positor = COALESCE(positor, a.ST_NAM_Positor)
            WHERE
                p.ST_NAM_ChangedAt <= changingTimepoint
            AND
                a.ST_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_NAM_Stage_Name;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_NAM_Stage_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Positor,
            ST_NAM_Reliability,
            ST_NAM_Assertion,
            ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Positor,
                a.ST_NAM_Reliability,
                a.ST_NAM_Assertion,
                p.ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Positor
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_NAM_Stage_Name_Posit p
            JOIN
                ST_NAM_Stage_Name_Annex a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Positor = COALESCE(positor, a.ST_NAM_Positor)
            WHERE
                p.ST_NAM_ChangedAt > changingTimepoint
            AND
                a.ST_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_NAM_Stage_Name;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_LOC_Stage_Location_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Positor,
            ST_LOC_Reliability,
            ST_LOC_Assertion
        FROM
            ST_LOC_Stage_Location_Annex
        WHERE
            ST_LOC_PositedAt <= positingTimepoint
    ]';
END rST_LOC_Stage_Location_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_LOC_Stage_Location (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Positor,
            ST_LOC_Reliability,
            ST_LOC_Assertion,
            ST_ID,
            ST_LOC_Checksum,
            ST_LOC_Stage_Location
        FROM (
            SELECT
                p.ST_LOC_ID,
                a.ST_LOC_PositedAt,
                a.ST_LOC_Positor,
                a.ST_LOC_Reliability,
                a.ST_LOC_Assertion,
                p.ST_ID,
                p.ST_LOC_Checksum,
                p.ST_LOC_Stage_Location,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_LOC_ID,
                        a.ST_LOC_Positor
                    ORDER BY
                        a.ST_LOC_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_LOC_Stage_Location_Posit p
            JOIN
                ST_LOC_Stage_Location_Annex a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            AND
                a.ST_LOC_Positor = COALESCE(positor, a.ST_LOC_Positor)
            WHERE
                a.ST_LOC_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_LOC_Stage_Location;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_ID,
            UTL_ID,
            ST_AVG_ChangedAt
        FROM
            ST_AVG_Stage_Average_Posit
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Stage_Average_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_AVG_Stage_Average_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_ID,
            UTL_ID,
            ST_AVG_ChangedAt
        FROM
            ST_AVG_Stage_Average_Posit
        WHERE
            ST_AVG_ChangedAt > changingTimepoint
    ]';
END fST_AVG_Stage_Average_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability,
            ST_AVG_Assertion
        FROM
            ST_AVG_Stage_Average_Annex
        WHERE
            ST_AVG_PositedAt <= positingTimepoint
    ]';
END rST_AVG_Stage_Average_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_AVG_Stage_Average (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability,
            ST_AVG_Assertion,
            ST_ID,
            UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Positor,
                a.ST_AVG_Reliability,
                a.ST_AVG_Assertion,
                p.ST_ID,
                p.UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Positor
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_AVG_Stage_Average_Posit p
            JOIN
                ST_AVG_Stage_Average_Annex a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Positor = COALESCE(positor, a.ST_AVG_Positor)
            WHERE
                p.ST_AVG_ChangedAt <= changingTimepoint
            AND
                a.ST_AVG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_AVG_Stage_Average;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_AVG_Stage_Average (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Positor,
            ST_AVG_Reliability,
            ST_AVG_Assertion,
            ST_ID,
            UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Positor,
                a.ST_AVG_Reliability,
                a.ST_AVG_Assertion,
                p.ST_ID,
                p.UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Positor
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_AVG_Stage_Average_Posit p
            JOIN
                ST_AVG_Stage_Average_Annex a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Positor = COALESCE(positor, a.ST_AVG_Positor)
            WHERE
                p.ST_AVG_ChangedAt > changingTimepoint
            AND
                a.ST_AVG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_AVG_Stage_Average;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_MIN_Stage_Minimum_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Positor,
            ST_MIN_Reliability,
            ST_MIN_Assertion
        FROM
            ST_MIN_Stage_Minimum_Annex
        WHERE
            ST_MIN_PositedAt <= positingTimepoint
    ]';
END rST_MIN_Stage_Minimum_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_MIN_Stage_Minimum (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Positor,
            ST_MIN_Reliability,
            ST_MIN_Assertion,
            ST_ID,
            UTL_ID
        FROM (
            SELECT
                p.ST_MIN_ID,
                a.ST_MIN_PositedAt,
                a.ST_MIN_Positor,
                a.ST_MIN_Reliability,
                a.ST_MIN_Assertion,
                p.ST_ID,
                p.UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_MIN_ID,
                        a.ST_MIN_Positor
                    ORDER BY
                        a.ST_MIN_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_MIN_Stage_Minimum_Posit p
            JOIN
                ST_MIN_Stage_Minimum_Annex a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            AND
                a.ST_MIN_Positor = COALESCE(positor, a.ST_MIN_Positor)
            WHERE
                a.ST_MIN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_MIN_Stage_Minimum;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            AC_NAM_Actor_Name_Posit
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Actor_Name_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_NAM_Actor_Name_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            AC_NAM_Actor_Name_Posit
        WHERE
            AC_NAM_ChangedAt > changingTimepoint
    ]';
END fAC_NAM_Actor_Name_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability,
            AC_NAM_Assertion
        FROM
            AC_NAM_Actor_Name_Annex
        WHERE
            AC_NAM_PositedAt <= positingTimepoint
    ]';
END rAC_NAM_Actor_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_NAM_Actor_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability,
            AC_NAM_Assertion,
            AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Positor,
                a.AC_NAM_Reliability,
                a.AC_NAM_Assertion,
                p.AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Positor
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_NAM_Actor_Name_Posit p
            JOIN
                AC_NAM_Actor_Name_Annex a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Positor = COALESCE(positor, a.AC_NAM_Positor)
            WHERE
                p.AC_NAM_ChangedAt <= changingTimepoint
            AND
                a.AC_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_NAM_Actor_Name;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_NAM_Actor_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Positor,
            AC_NAM_Reliability,
            AC_NAM_Assertion,
            AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Positor,
                a.AC_NAM_Reliability,
                a.AC_NAM_Assertion,
                p.AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Positor
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_NAM_Actor_Name_Posit p
            JOIN
                AC_NAM_Actor_Name_Annex a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Positor = COALESCE(positor, a.AC_NAM_Positor)
            WHERE
                p.AC_NAM_ChangedAt > changingTimepoint
            AND
                a.AC_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_NAM_Actor_Name;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_GEN_Actor_Gender_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Positor,
            AC_GEN_Reliability,
            AC_GEN_Assertion
        FROM
            AC_GEN_Actor_Gender_Annex
        WHERE
            AC_GEN_PositedAt <= positingTimepoint
    ]';
END rAC_GEN_Actor_Gender_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_GEN_Actor_Gender (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Positor,
            AC_GEN_Reliability,
            AC_GEN_Assertion,
            AC_ID,
            GEN_ID
        FROM (
            SELECT
                p.AC_GEN_ID,
                a.AC_GEN_PositedAt,
                a.AC_GEN_Positor,
                a.AC_GEN_Reliability,
                a.AC_GEN_Assertion,
                p.AC_ID,
                p.GEN_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_GEN_ID,
                        a.AC_GEN_Positor
                    ORDER BY
                        a.AC_GEN_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_GEN_Actor_Gender_Posit p
            JOIN
                AC_GEN_Actor_Gender_Annex a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            AND
                a.AC_GEN_Positor = COALESCE(positor, a.AC_GEN_Positor)
            WHERE
                a.AC_GEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_GEN_Actor_Gender;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_ID,
            PLV_ID,
            AC_PLV_ChangedAt
        FROM
            AC_PLV_Actor_ProfessionalLevel_Posit
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_PLV_Actor_ProfessionalLevel_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_ID,
            PLV_ID,
            AC_PLV_ChangedAt
        FROM
            AC_PLV_Actor_ProfessionalLevel_Posit
        WHERE
            AC_PLV_ChangedAt > changingTimepoint
    ]';
END fAC_PLV_Actor_ProfessionalLevel_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability,
            AC_PLV_Assertion
        FROM
            AC_PLV_Actor_ProfessionalLevel_Annex
        WHERE
            AC_PLV_PositedAt <= positingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_PLV_Actor_ProfessionalLevel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability,
            AC_PLV_Assertion,
            AC_ID,
            PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Positor,
                a.AC_PLV_Reliability,
                a.AC_PLV_Assertion,
                p.AC_ID,
                p.PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Positor
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_PLV_Actor_ProfessionalLevel_Posit p
            JOIN
                AC_PLV_Actor_ProfessionalLevel_Annex a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Positor = COALESCE(positor, a.AC_PLV_Positor)
            WHERE
                p.AC_PLV_ChangedAt <= changingTimepoint
            AND
                a.AC_PLV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_PLV_Actor_ProfessionalLevel;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_PLV_Actor_ProfessionalLevel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Positor,
            AC_PLV_Reliability,
            AC_PLV_Assertion,
            AC_ID,
            PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Positor,
                a.AC_PLV_Reliability,
                a.AC_PLV_Assertion,
                p.AC_ID,
                p.PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Positor
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_PLV_Actor_ProfessionalLevel_Posit p
            JOIN
                AC_PLV_Actor_ProfessionalLevel_Annex a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Positor = COALESCE(positor, a.AC_PLV_Positor)
            WHERE
                p.AC_PLV_ChangedAt > changingTimepoint
            AND
                a.AC_PLV_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_PLV_Actor_ProfessionalLevel;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_NAM_Program_Name_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Positor,
            PR_NAM_Reliability,
            PR_NAM_Assertion
        FROM
            PR_NAM_Program_Name_Annex
        WHERE
            PR_NAM_PositedAt <= positingTimepoint
    ]';
END rPR_NAM_Program_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_NAM_Program_Name (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Positor,
            PR_NAM_Reliability,
            PR_NAM_Assertion,
            PR_ID,
            PR_NAM_Program_Name
        FROM (
            SELECT
                p.PR_NAM_ID,
                a.PR_NAM_PositedAt,
                a.PR_NAM_Positor,
                a.PR_NAM_Reliability,
                a.PR_NAM_Assertion,
                p.PR_ID,
                p.PR_NAM_Program_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_NAM_ID,
                        a.PR_NAM_Positor
                    ORDER BY
                        a.PR_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_NAM_Program_Name_Posit p
            JOIN
                PR_NAM_Program_Name_Annex a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            AND
                a.PR_NAM_Positor = COALESCE(positor, a.PR_NAM_Positor)
            WHERE
                a.PR_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_NAM_Program_Name;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length_Posit (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            PR_LEN_Program_Length_Posit
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Program_Length_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fPR_LEN_Program_Length_Posit (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            PR_LEN_Program_Length_Posit
        WHERE
            PR_LEN_ChangedAt > changingTimepoint
    ]';
END fPR_LEN_Program_Length_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability,
            PR_LEN_Assertion
        FROM
            PR_LEN_Program_Length_Annex
        WHERE
            PR_LEN_PositedAt <= positingTimepoint
    ]';
END rPR_LEN_Program_Length_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_LEN_Program_Length (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability,
            PR_LEN_Assertion,
            PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Positor,
                a.PR_LEN_Reliability,
                a.PR_LEN_Assertion,
                p.PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Positor
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_LEN_Program_Length_Posit p
            JOIN
                PR_LEN_Program_Length_Annex a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Positor = COALESCE(positor, a.PR_LEN_Positor)
            WHERE
                p.PR_LEN_ChangedAt <= changingTimepoint
            AND
                a.PR_LEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_LEN_Program_Length;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fPR_LEN_Program_Length (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Positor,
            PR_LEN_Reliability,
            PR_LEN_Assertion,
            PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Positor,
                a.PR_LEN_Reliability,
                a.PR_LEN_Assertion,
                p.PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Positor
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_LEN_Program_Length_Posit p
            JOIN
                PR_LEN_Program_Length_Annex a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Positor = COALESCE(positor, a.PR_LEN_Positor)
            WHERE
                p.PR_LEN_ChangedAt > changingTimepoint
            AND
                a.PR_LEN_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_LEN_Program_Length;
/
