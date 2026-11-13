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
CREATE OR REPLACE FUNCTION rEV_QTY_Event_Quantity_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability,
            EV_QTY_Assertion
        FROM
            EV_QTY_Event_Quantity_Annex
        WHERE
            EV_QTY_PositedAt <= positingTimepoint
    ]';
END rEV_QTY_Event_Quantity_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_QTY_Event_Quantity (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_QTY,
            EV_QTY_ID,
            EV_QTY_PositedAt,
            EV_QTY_Positor,
            EV_QTY_Reliability,
            EV_QTY_Assertion,
            EV_QTY_EV_ID,
            EV_QTY_Event_Quantity
        FROM (
            SELECT
                a.Metadata_EV_QTY,
                p.EV_QTY_ID,
                a.EV_QTY_PositedAt,
                a.EV_QTY_Positor,
                a.EV_QTY_Reliability,
                a.EV_QTY_Assertion,
                p.EV_QTY_EV_ID,
                p.EV_QTY_Event_Quantity,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_QTY_ID,
                        a.EV_QTY_Positor
                    ORDER BY
                        a.EV_QTY_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_QTY_Event_Quantity_Posit p
            JOIN
                EV_QTY_Event_Quantity_Annex a
            ON
                a.EV_QTY_ID = p.EV_QTY_ID
            AND
                a.EV_QTY_Positor = COALESCE(positor, a.EV_QTY_Positor)
            WHERE
                a.EV_QTY_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_QTY_Event_Quantity;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_PLC_ID,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM
            EV_PLC_Event_Place_Posit
        WHERE
            EV_PLC_ChangedAt <= changingTimepoint
    ]';
END rEV_PLC_Event_Place_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fEV_PLC_Event_Place_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_PLC_ID,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM
            EV_PLC_Event_Place_Posit
        WHERE
            EV_PLC_ChangedAt > changingTimepoint
    ]';
END fEV_PLC_Event_Place_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability,
            EV_PLC_Assertion
        FROM
            EV_PLC_Event_Place_Annex
        WHERE
            EV_PLC_PositedAt <= positingTimepoint
    ]';
END rEV_PLC_Event_Place_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_PLC_Event_Place (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability,
            EV_PLC_Assertion,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_PLC,
                p.EV_PLC_ID,
                a.EV_PLC_PositedAt,
                a.EV_PLC_Positor,
                a.EV_PLC_Reliability,
                a.EV_PLC_Assertion,
                p.EV_PLC_EV_ID,
                p.EV_PLC_Event_Place,
                p.EV_PLC_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_PLC_ID,
                        a.EV_PLC_Positor
                    ORDER BY
                        a.EV_PLC_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_PLC_Event_Place_Posit p
            JOIN
                EV_PLC_Event_Place_Annex a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            AND
                a.EV_PLC_Positor = COALESCE(positor, a.EV_PLC_Positor)
            WHERE
                p.EV_PLC_ChangedAt <= changingTimepoint
            AND
                a.EV_PLC_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_PLC_Event_Place;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fEV_PLC_Event_Place (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_PLC,
            EV_PLC_ID,
            EV_PLC_PositedAt,
            EV_PLC_Positor,
            EV_PLC_Reliability,
            EV_PLC_Assertion,
            EV_PLC_EV_ID,
            EV_PLC_Event_Place,
            EV_PLC_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_PLC,
                p.EV_PLC_ID,
                a.EV_PLC_PositedAt,
                a.EV_PLC_Positor,
                a.EV_PLC_Reliability,
                a.EV_PLC_Assertion,
                p.EV_PLC_EV_ID,
                p.EV_PLC_Event_Place,
                p.EV_PLC_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_PLC_ID,
                        a.EV_PLC_Positor
                    ORDER BY
                        a.EV_PLC_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_PLC_Event_Place_Posit p
            JOIN
                EV_PLC_Event_Place_Annex a
            ON
                a.EV_PLC_ID = p.EV_PLC_ID
            AND
                a.EV_PLC_Positor = COALESCE(positor, a.EV_PLC_Positor)
            WHERE
                p.EV_PLC_ChangedAt > changingTimepoint
            AND
                a.EV_PLC_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_PLC_Event_Place;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NAM_Subject_Name_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_PositedAt,
            SU_NAM_Positor,
            SU_NAM_Reliability,
            SU_NAM_Assertion
        FROM
            SU_NAM_Subject_Name_Annex
        WHERE
            SU_NAM_PositedAt <= positingTimepoint
    ]';
END rSU_NAM_Subject_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NAM_Subject_Name (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NAM,
            SU_NAM_ID,
            SU_NAM_PositedAt,
            SU_NAM_Positor,
            SU_NAM_Reliability,
            SU_NAM_Assertion,
            SU_NAM_SU_ID,
            SU_NAM_Subject_Name
        FROM (
            SELECT
                a.Metadata_SU_NAM,
                p.SU_NAM_ID,
                a.SU_NAM_PositedAt,
                a.SU_NAM_Positor,
                a.SU_NAM_Reliability,
                a.SU_NAM_Assertion,
                p.SU_NAM_SU_ID,
                p.SU_NAM_Subject_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_NAM_ID,
                        a.SU_NAM_Positor
                    ORDER BY
                        a.SU_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_NAM_Subject_Name_Posit p
            JOIN
                SU_NAM_Subject_Name_Annex a
            ON
                a.SU_NAM_ID = p.SU_NAM_ID
            AND
                a.SU_NAM_Positor = COALESCE(positor, a.SU_NAM_Positor)
            WHERE
                a.SU_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_NAM_Subject_Name;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_COD_Subject_Code_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_PositedAt,
            SU_COD_Positor,
            SU_COD_Reliability,
            SU_COD_Assertion
        FROM
            SU_COD_Subject_Code_Annex
        WHERE
            SU_COD_PositedAt <= positingTimepoint
    ]';
END rSU_COD_Subject_Code_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_COD_Subject_Code (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_COD,
            SU_COD_ID,
            SU_COD_PositedAt,
            SU_COD_Positor,
            SU_COD_Reliability,
            SU_COD_Assertion,
            SU_COD_SU_ID,
            SU_COD_Subject_Code
        FROM (
            SELECT
                a.Metadata_SU_COD,
                p.SU_COD_ID,
                a.SU_COD_PositedAt,
                a.SU_COD_Positor,
                a.SU_COD_Reliability,
                a.SU_COD_Assertion,
                p.SU_COD_SU_ID,
                p.SU_COD_Subject_Code,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_COD_ID,
                        a.SU_COD_Positor
                    ORDER BY
                        a.SU_COD_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_COD_Subject_Code_Posit p
            JOIN
                SU_COD_Subject_Code_Annex a
            ON
                a.SU_COD_ID = p.SU_COD_ID
            AND
                a.SU_COD_Positor = COALESCE(positor, a.SU_COD_Positor)
            WHERE
                a.SU_COD_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_COD_Subject_Code;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_GRD_Subject_Grade_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Positor,
            SU_GRD_Reliability,
            SU_GRD_Assertion
        FROM
            SU_GRD_Subject_Grade_Annex
        WHERE
            SU_GRD_PositedAt <= positingTimepoint
    ]';
END rSU_GRD_Subject_Grade_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_GRD_Subject_Grade (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_GRD,
            SU_GRD_ID,
            SU_GRD_PositedAt,
            SU_GRD_Positor,
            SU_GRD_Reliability,
            SU_GRD_Assertion,
            SU_GRD_SU_ID,
            SU_GRD_GRD_ID
        FROM (
            SELECT
                a.Metadata_SU_GRD,
                p.SU_GRD_ID,
                a.SU_GRD_PositedAt,
                a.SU_GRD_Positor,
                a.SU_GRD_Reliability,
                a.SU_GRD_Assertion,
                p.SU_GRD_SU_ID,
                p.SU_GRD_GRD_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_GRD_ID,
                        a.SU_GRD_Positor
                    ORDER BY
                        a.SU_GRD_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_GRD_Subject_Grade_Posit p
            JOIN
                SU_GRD_Subject_Grade_Annex a
            ON
                a.SU_GRD_ID = p.SU_GRD_ID
            AND
                a.SU_GRD_Positor = COALESCE(positor, a.SU_GRD_Positor)
            WHERE
                a.SU_GRD_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_GRD_Subject_Grade;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NOT_Subject_Note_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_PositedAt,
            SU_NOT_Positor,
            SU_NOT_Reliability,
            SU_NOT_Assertion
        FROM
            SU_NOT_Subject_Note_Annex
        WHERE
            SU_NOT_PositedAt <= positingTimepoint
    ]';
END rSU_NOT_Subject_Note_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_NOT_Subject_Note (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_NOT,
            SU_NOT_ID,
            SU_NOT_PositedAt,
            SU_NOT_Positor,
            SU_NOT_Reliability,
            SU_NOT_Assertion,
            SU_NOT_SU_ID,
            SU_NOT_Subject_Note
        FROM (
            SELECT
                a.Metadata_SU_NOT,
                p.SU_NOT_ID,
                a.SU_NOT_PositedAt,
                a.SU_NOT_Positor,
                a.SU_NOT_Reliability,
                a.SU_NOT_Assertion,
                p.SU_NOT_SU_ID,
                p.SU_NOT_Subject_Note,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_NOT_ID,
                        a.SU_NOT_Positor
                    ORDER BY
                        a.SU_NOT_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_NOT_Subject_Note_Posit p
            JOIN
                SU_NOT_Subject_Note_Annex a
            ON
                a.SU_NOT_ID = p.SU_NOT_ID
            AND
                a.SU_NOT_Positor = COALESCE(positor, a.SU_NOT_Positor)
            WHERE
                a.SU_NOT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_NOT_Subject_Note;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TTL_ID,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM
            SU_TTL_Subject_Title_Posit
        WHERE
            SU_TTL_ChangedAt <= changingTimepoint
    ]';
END rSU_TTL_Subject_Title_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TTL_Subject_Title_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TTL_ID,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM
            SU_TTL_Subject_Title_Posit
        WHERE
            SU_TTL_ChangedAt > changingTimepoint
    ]';
END fSU_TTL_Subject_Title_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability,
            SU_TTL_Assertion
        FROM
            SU_TTL_Subject_Title_Annex
        WHERE
            SU_TTL_PositedAt <= positingTimepoint
    ]';
END rSU_TTL_Subject_Title_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TTL_Subject_Title (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability,
            SU_TTL_Assertion,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TTL,
                p.SU_TTL_ID,
                a.SU_TTL_PositedAt,
                a.SU_TTL_Positor,
                a.SU_TTL_Reliability,
                a.SU_TTL_Assertion,
                p.SU_TTL_SU_ID,
                p.SU_TTL_Subject_Title,
                p.SU_TTL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TTL_ID,
                        a.SU_TTL_Positor
                    ORDER BY
                        a.SU_TTL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TTL_Subject_Title_Posit p
            JOIN
                SU_TTL_Subject_Title_Annex a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            AND
                a.SU_TTL_Positor = COALESCE(positor, a.SU_TTL_Positor)
            WHERE
                p.SU_TTL_ChangedAt <= changingTimepoint
            AND
                a.SU_TTL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_TTL_Subject_Title;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TTL_Subject_Title (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TTL,
            SU_TTL_ID,
            SU_TTL_PositedAt,
            SU_TTL_Positor,
            SU_TTL_Reliability,
            SU_TTL_Assertion,
            SU_TTL_SU_ID,
            SU_TTL_Subject_Title,
            SU_TTL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TTL,
                p.SU_TTL_ID,
                a.SU_TTL_PositedAt,
                a.SU_TTL_Positor,
                a.SU_TTL_Reliability,
                a.SU_TTL_Assertion,
                p.SU_TTL_SU_ID,
                p.SU_TTL_Subject_Title,
                p.SU_TTL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TTL_ID,
                        a.SU_TTL_Positor
                    ORDER BY
                        a.SU_TTL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TTL_Subject_Title_Posit p
            JOIN
                SU_TTL_Subject_Title_Annex a
            ON
                a.SU_TTL_ID = p.SU_TTL_ID
            AND
                a.SU_TTL_Positor = COALESCE(positor, a.SU_TTL_Positor)
            WHERE
                p.SU_TTL_ChangedAt > changingTimepoint
            AND
                a.SU_TTL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_TTL_Subject_Title;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_STA_ID,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM
            SU_STA_Subject_State_Posit
        WHERE
            SU_STA_ChangedAt <= changingTimepoint
    ]';
END rSU_STA_Subject_State_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_STA_Subject_State_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_STA_ID,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM
            SU_STA_Subject_State_Posit
        WHERE
            SU_STA_ChangedAt > changingTimepoint
    ]';
END fSU_STA_Subject_State_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability,
            SU_STA_Assertion
        FROM
            SU_STA_Subject_State_Annex
        WHERE
            SU_STA_PositedAt <= positingTimepoint
    ]';
END rSU_STA_Subject_State_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_STA_Subject_State (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability,
            SU_STA_Assertion,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_STA,
                p.SU_STA_ID,
                a.SU_STA_PositedAt,
                a.SU_STA_Positor,
                a.SU_STA_Reliability,
                a.SU_STA_Assertion,
                p.SU_STA_SU_ID,
                p.SU_STA_Subject_State,
                p.SU_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_STA_ID,
                        a.SU_STA_Positor
                    ORDER BY
                        a.SU_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_STA_Subject_State_Posit p
            JOIN
                SU_STA_Subject_State_Annex a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            AND
                a.SU_STA_Positor = COALESCE(positor, a.SU_STA_Positor)
            WHERE
                p.SU_STA_ChangedAt <= changingTimepoint
            AND
                a.SU_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_STA_Subject_State;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_STA_Subject_State (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_STA,
            SU_STA_ID,
            SU_STA_PositedAt,
            SU_STA_Positor,
            SU_STA_Reliability,
            SU_STA_Assertion,
            SU_STA_SU_ID,
            SU_STA_Subject_State,
            SU_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_STA,
                p.SU_STA_ID,
                a.SU_STA_PositedAt,
                a.SU_STA_Positor,
                a.SU_STA_Reliability,
                a.SU_STA_Assertion,
                p.SU_STA_SU_ID,
                p.SU_STA_Subject_State,
                p.SU_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_STA_ID,
                        a.SU_STA_Positor
                    ORDER BY
                        a.SU_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_STA_Subject_State_Posit p
            JOIN
                SU_STA_Subject_State_Annex a
            ON
                a.SU_STA_ID = p.SU_STA_ID
            AND
                a.SU_STA_Positor = COALESCE(positor, a.SU_STA_Positor)
            WHERE
                p.SU_STA_ChangedAt > changingTimepoint
            AND
                a.SU_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_STA_Subject_State;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LBL_ID,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM
            SU_LBL_Subject_Label_Posit
        WHERE
            SU_LBL_ChangedAt <= changingTimepoint
    ]';
END rSU_LBL_Subject_Label_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LBL_Subject_Label_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LBL_ID,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM
            SU_LBL_Subject_Label_Posit
        WHERE
            SU_LBL_ChangedAt > changingTimepoint
    ]';
END fSU_LBL_Subject_Label_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability,
            SU_LBL_Assertion
        FROM
            SU_LBL_Subject_Label_Annex
        WHERE
            SU_LBL_PositedAt <= positingTimepoint
    ]';
END rSU_LBL_Subject_Label_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LBL_Subject_Label (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability,
            SU_LBL_Assertion,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LBL,
                p.SU_LBL_ID,
                a.SU_LBL_PositedAt,
                a.SU_LBL_Positor,
                a.SU_LBL_Reliability,
                a.SU_LBL_Assertion,
                p.SU_LBL_SU_ID,
                p.SU_LBL_Subject_Label,
                p.SU_LBL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LBL_ID,
                        a.SU_LBL_Positor
                    ORDER BY
                        a.SU_LBL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LBL_Subject_Label_Posit p
            JOIN
                SU_LBL_Subject_Label_Annex a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            AND
                a.SU_LBL_Positor = COALESCE(positor, a.SU_LBL_Positor)
            WHERE
                p.SU_LBL_ChangedAt <= changingTimepoint
            AND
                a.SU_LBL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_LBL_Subject_Label;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LBL_Subject_Label (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LBL,
            SU_LBL_ID,
            SU_LBL_PositedAt,
            SU_LBL_Positor,
            SU_LBL_Reliability,
            SU_LBL_Assertion,
            SU_LBL_SU_ID,
            SU_LBL_Subject_Label,
            SU_LBL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LBL,
                p.SU_LBL_ID,
                a.SU_LBL_PositedAt,
                a.SU_LBL_Positor,
                a.SU_LBL_Reliability,
                a.SU_LBL_Assertion,
                p.SU_LBL_SU_ID,
                p.SU_LBL_Subject_Label,
                p.SU_LBL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LBL_ID,
                        a.SU_LBL_Positor
                    ORDER BY
                        a.SU_LBL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LBL_Subject_Label_Posit p
            JOIN
                SU_LBL_Subject_Label_Annex a
            ON
                a.SU_LBL_ID = p.SU_LBL_ID
            AND
                a.SU_LBL_Positor = COALESCE(positor, a.SU_LBL_Positor)
            WHERE
                p.SU_LBL_ChangedAt > changingTimepoint
            AND
                a.SU_LBL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_LBL_Subject_Label;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TAG_ID,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM
            SU_TAG_Subject_Tag_Posit
        WHERE
            SU_TAG_ChangedAt <= changingTimepoint
    ]';
END rSU_TAG_Subject_Tag_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TAG_Subject_Tag_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TAG_ID,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM
            SU_TAG_Subject_Tag_Posit
        WHERE
            SU_TAG_ChangedAt > changingTimepoint
    ]';
END fSU_TAG_Subject_Tag_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability,
            SU_TAG_Assertion
        FROM
            SU_TAG_Subject_Tag_Annex
        WHERE
            SU_TAG_PositedAt <= positingTimepoint
    ]';
END rSU_TAG_Subject_Tag_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TAG_Subject_Tag (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability,
            SU_TAG_Assertion,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TAG,
                p.SU_TAG_ID,
                a.SU_TAG_PositedAt,
                a.SU_TAG_Positor,
                a.SU_TAG_Reliability,
                a.SU_TAG_Assertion,
                p.SU_TAG_SU_ID,
                p.SU_TAG_Subject_Tag,
                p.SU_TAG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TAG_ID,
                        a.SU_TAG_Positor
                    ORDER BY
                        a.SU_TAG_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TAG_Subject_Tag_Posit p
            JOIN
                SU_TAG_Subject_Tag_Annex a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            AND
                a.SU_TAG_Positor = COALESCE(positor, a.SU_TAG_Positor)
            WHERE
                p.SU_TAG_ChangedAt <= changingTimepoint
            AND
                a.SU_TAG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_TAG_Subject_Tag;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TAG_Subject_Tag (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TAG,
            SU_TAG_ID,
            SU_TAG_PositedAt,
            SU_TAG_Positor,
            SU_TAG_Reliability,
            SU_TAG_Assertion,
            SU_TAG_SU_ID,
            SU_TAG_Subject_Tag,
            SU_TAG_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TAG,
                p.SU_TAG_ID,
                a.SU_TAG_PositedAt,
                a.SU_TAG_Positor,
                a.SU_TAG_Reliability,
                a.SU_TAG_Assertion,
                p.SU_TAG_SU_ID,
                p.SU_TAG_Subject_Tag,
                p.SU_TAG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TAG_ID,
                        a.SU_TAG_Positor
                    ORDER BY
                        a.SU_TAG_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TAG_Subject_Tag_Posit p
            JOIN
                SU_TAG_Subject_Tag_Annex a
            ON
                a.SU_TAG_ID = p.SU_TAG_ID
            AND
                a.SU_TAG_Positor = COALESCE(positor, a.SU_TAG_Positor)
            WHERE
                p.SU_TAG_ChangedAt > changingTimepoint
            AND
                a.SU_TAG_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_TAG_Subject_Tag;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LVL_ID,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM
            SU_LVL_Subject_Level_Posit
        WHERE
            SU_LVL_ChangedAt <= changingTimepoint
    ]';
END rSU_LVL_Subject_Level_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LVL_Subject_Level_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_LVL_ID,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM
            SU_LVL_Subject_Level_Posit
        WHERE
            SU_LVL_ChangedAt > changingTimepoint
    ]';
END fSU_LVL_Subject_Level_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability,
            SU_LVL_Assertion
        FROM
            SU_LVL_Subject_Level_Annex
        WHERE
            SU_LVL_PositedAt <= positingTimepoint
    ]';
END rSU_LVL_Subject_Level_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_LVL_Subject_Level (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability,
            SU_LVL_Assertion,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LVL,
                p.SU_LVL_ID,
                a.SU_LVL_PositedAt,
                a.SU_LVL_Positor,
                a.SU_LVL_Reliability,
                a.SU_LVL_Assertion,
                p.SU_LVL_SU_ID,
                p.SU_LVL_GRD_ID,
                p.SU_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LVL_ID,
                        a.SU_LVL_Positor
                    ORDER BY
                        a.SU_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LVL_Subject_Level_Posit p
            JOIN
                SU_LVL_Subject_Level_Annex a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            AND
                a.SU_LVL_Positor = COALESCE(positor, a.SU_LVL_Positor)
            WHERE
                p.SU_LVL_ChangedAt <= changingTimepoint
            AND
                a.SU_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_LVL_Subject_Level;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_LVL_Subject_Level (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_LVL,
            SU_LVL_ID,
            SU_LVL_PositedAt,
            SU_LVL_Positor,
            SU_LVL_Reliability,
            SU_LVL_Assertion,
            SU_LVL_SU_ID,
            SU_LVL_GRD_ID,
            SU_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_LVL,
                p.SU_LVL_ID,
                a.SU_LVL_PositedAt,
                a.SU_LVL_Positor,
                a.SU_LVL_Reliability,
                a.SU_LVL_Assertion,
                p.SU_LVL_SU_ID,
                p.SU_LVL_GRD_ID,
                p.SU_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_LVL_ID,
                        a.SU_LVL_Positor
                    ORDER BY
                        a.SU_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_LVL_Subject_Level_Posit p
            JOIN
                SU_LVL_Subject_Level_Annex a
            ON
                a.SU_LVL_ID = p.SU_LVL_ID
            AND
                a.SU_LVL_Positor = COALESCE(positor, a.SU_LVL_Positor)
            WHERE
                p.SU_LVL_ChangedAt > changingTimepoint
            AND
                a.SU_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_LVL_Subject_Level;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TXT_ID,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM
            SU_TXT_Subject_Text_Posit
        WHERE
            SU_TXT_ChangedAt <= changingTimepoint
    ]';
END rSU_TXT_Subject_Text_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TXT_Subject_Text_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_TXT_ID,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM
            SU_TXT_Subject_Text_Posit
        WHERE
            SU_TXT_ChangedAt > changingTimepoint
    ]';
END fSU_TXT_Subject_Text_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability,
            SU_TXT_Assertion
        FROM
            SU_TXT_Subject_Text_Annex
        WHERE
            SU_TXT_PositedAt <= positingTimepoint
    ]';
END rSU_TXT_Subject_Text_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_TXT_Subject_Text (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability,
            SU_TXT_Assertion,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TXT,
                p.SU_TXT_ID,
                a.SU_TXT_PositedAt,
                a.SU_TXT_Positor,
                a.SU_TXT_Reliability,
                a.SU_TXT_Assertion,
                p.SU_TXT_SU_ID,
                p.SU_TXT_Subject_Text,
                p.SU_TXT_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TXT_ID,
                        a.SU_TXT_Positor
                    ORDER BY
                        a.SU_TXT_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TXT_Subject_Text_Posit p
            JOIN
                SU_TXT_Subject_Text_Annex a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            AND
                a.SU_TXT_Positor = COALESCE(positor, a.SU_TXT_Positor)
            WHERE
                p.SU_TXT_ChangedAt <= changingTimepoint
            AND
                a.SU_TXT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_TXT_Subject_Text;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_TXT_Subject_Text (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_TXT,
            SU_TXT_ID,
            SU_TXT_PositedAt,
            SU_TXT_Positor,
            SU_TXT_Reliability,
            SU_TXT_Assertion,
            SU_TXT_SU_ID,
            SU_TXT_Subject_Text,
            SU_TXT_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_TXT,
                p.SU_TXT_ID,
                a.SU_TXT_PositedAt,
                a.SU_TXT_Positor,
                a.SU_TXT_Reliability,
                a.SU_TXT_Assertion,
                p.SU_TXT_SU_ID,
                p.SU_TXT_Subject_Text,
                p.SU_TXT_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_TXT_ID,
                        a.SU_TXT_Positor
                    ORDER BY
                        a.SU_TXT_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_TXT_Subject_Text_Posit p
            JOIN
                SU_TXT_Subject_Text_Annex a
            ON
                a.SU_TXT_ID = p.SU_TXT_ID
            AND
                a.SU_TXT_Positor = COALESCE(positor, a.SU_TXT_Positor)
            WHERE
                p.SU_TXT_ChangedAt > changingTimepoint
            AND
                a.SU_TXT_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_TXT_Subject_Text;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ASR_ID,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM
            SU_ASR_Subject_Assessment_Posit
        WHERE
            SU_ASR_ChangedAt <= changingTimepoint
    ]';
END rSU_ASR_Subject_Assessment_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ASR_Subject_Assessment_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ASR_ID,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM
            SU_ASR_Subject_Assessment_Posit
        WHERE
            SU_ASR_ChangedAt > changingTimepoint
    ]';
END fSU_ASR_Subject_Assessment_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability,
            SU_ASR_Assertion
        FROM
            SU_ASR_Subject_Assessment_Annex
        WHERE
            SU_ASR_PositedAt <= positingTimepoint
    ]';
END rSU_ASR_Subject_Assessment_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ASR_Subject_Assessment (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability,
            SU_ASR_Assertion,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ASR,
                p.SU_ASR_ID,
                a.SU_ASR_PositedAt,
                a.SU_ASR_Positor,
                a.SU_ASR_Reliability,
                a.SU_ASR_Assertion,
                p.SU_ASR_SU_ID,
                p.SU_ASR_Subject_Assessment,
                p.SU_ASR_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ASR_ID,
                        a.SU_ASR_Positor
                    ORDER BY
                        a.SU_ASR_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ASR_Subject_Assessment_Posit p
            JOIN
                SU_ASR_Subject_Assessment_Annex a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            AND
                a.SU_ASR_Positor = COALESCE(positor, a.SU_ASR_Positor)
            WHERE
                p.SU_ASR_ChangedAt <= changingTimepoint
            AND
                a.SU_ASR_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_ASR_Subject_Assessment;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ASR_Subject_Assessment (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ASR,
            SU_ASR_ID,
            SU_ASR_PositedAt,
            SU_ASR_Positor,
            SU_ASR_Reliability,
            SU_ASR_Assertion,
            SU_ASR_SU_ID,
            SU_ASR_Subject_Assessment,
            SU_ASR_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ASR,
                p.SU_ASR_ID,
                a.SU_ASR_PositedAt,
                a.SU_ASR_Positor,
                a.SU_ASR_Reliability,
                a.SU_ASR_Assertion,
                p.SU_ASR_SU_ID,
                p.SU_ASR_Subject_Assessment,
                p.SU_ASR_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ASR_ID,
                        a.SU_ASR_Positor
                    ORDER BY
                        a.SU_ASR_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ASR_Subject_Assessment_Posit p
            JOIN
                SU_ASR_Subject_Assessment_Annex a
            ON
                a.SU_ASR_ID = p.SU_ASR_ID
            AND
                a.SU_ASR_Positor = COALESCE(positor, a.SU_ASR_Positor)
            WHERE
                p.SU_ASR_ChangedAt > changingTimepoint
            AND
                a.SU_ASR_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_ASR_Subject_Assessment;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ERS_ID,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM
            SU_ERS_Subject_Erasable_Posit
        WHERE
            SU_ERS_ChangedAt <= changingTimepoint
    ]';
END rSU_ERS_Subject_Erasable_Posit;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ERS_Subject_Erasable_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_ERS_ID,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM
            SU_ERS_Subject_Erasable_Posit
        WHERE
            SU_ERS_ChangedAt > changingTimepoint
    ]';
END fSU_ERS_Subject_Erasable_Posit;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability,
            SU_ERS_Assertion
        FROM
            SU_ERS_Subject_Erasable_Annex
        WHERE
            SU_ERS_PositedAt <= positingTimepoint
    ]';
END rSU_ERS_Subject_Erasable_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_ERS_Subject_Erasable (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability,
            SU_ERS_Assertion,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ERS,
                p.SU_ERS_ID,
                a.SU_ERS_PositedAt,
                a.SU_ERS_Positor,
                a.SU_ERS_Reliability,
                a.SU_ERS_Assertion,
                p.SU_ERS_SU_ID,
                p.SU_ERS_Subject_Erasable,
                p.SU_ERS_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ERS_ID,
                        a.SU_ERS_Positor
                    ORDER BY
                        a.SU_ERS_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ERS_Subject_Erasable_Posit p
            JOIN
                SU_ERS_Subject_Erasable_Annex a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            AND
                a.SU_ERS_Positor = COALESCE(positor, a.SU_ERS_Positor)
            WHERE
                p.SU_ERS_ChangedAt <= changingTimepoint
            AND
                a.SU_ERS_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_ERS_Subject_Erasable;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_ERS_Subject_Erasable (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_ERS,
            SU_ERS_ID,
            SU_ERS_PositedAt,
            SU_ERS_Positor,
            SU_ERS_Reliability,
            SU_ERS_Assertion,
            SU_ERS_SU_ID,
            SU_ERS_Subject_Erasable,
            SU_ERS_ChangedAt
        FROM (
            SELECT
                a.Metadata_SU_ERS,
                p.SU_ERS_ID,
                a.SU_ERS_PositedAt,
                a.SU_ERS_Positor,
                a.SU_ERS_Reliability,
                a.SU_ERS_Assertion,
                p.SU_ERS_SU_ID,
                p.SU_ERS_Subject_Erasable,
                p.SU_ERS_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_ERS_ID,
                        a.SU_ERS_Positor
                    ORDER BY
                        a.SU_ERS_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_ERS_Subject_Erasable_Posit p
            JOIN
                SU_ERS_Subject_Erasable_Annex a
            ON
                a.SU_ERS_ID = p.SU_ERS_ID
            AND
                a.SU_ERS_Positor = COALESCE(positor, a.SU_ERS_Positor)
            WHERE
                p.SU_ERS_ChangedAt > changingTimepoint
            AND
                a.SU_ERS_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_ERS_Subject_Erasable;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_NAM_Object_Name_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_PositedAt,
            OB_NAM_Positor,
            OB_NAM_Reliability,
            OB_NAM_Assertion
        FROM
            OB_NAM_Object_Name_Annex
        WHERE
            OB_NAM_PositedAt <= positingTimepoint
    ]';
END rOB_NAM_Object_Name_Annex;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_NAM_Object_Name (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_NAM,
            OB_NAM_ID,
            OB_NAM_PositedAt,
            OB_NAM_Positor,
            OB_NAM_Reliability,
            OB_NAM_Assertion,
            OB_NAM_OB_ID,
            OB_NAM_Object_Name
        FROM (
            SELECT
                a.Metadata_OB_NAM,
                p.OB_NAM_ID,
                a.OB_NAM_PositedAt,
                a.OB_NAM_Positor,
                a.OB_NAM_Reliability,
                a.OB_NAM_Assertion,
                p.OB_NAM_OB_ID,
                p.OB_NAM_Object_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.OB_NAM_ID,
                        a.OB_NAM_Positor
                    ORDER BY
                        a.OB_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                OB_NAM_Object_Name_Posit p
            JOIN
                OB_NAM_Object_Name_Annex a
            ON
                a.OB_NAM_ID = p.OB_NAM_ID
            AND
                a.OB_NAM_Positor = COALESCE(positor, a.OB_NAM_Positor)
            WHERE
                a.OB_NAM_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rOB_NAM_Object_Name;
/
