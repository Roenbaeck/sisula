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
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Who,
            EV_DAT_Confidence,
            EV_DAT_Stance
        FROM
            attributes.EV_DAT_Event_Date_Meta
        WHERE
            EV_DAT_PositedAt <= positingTimepoint
    ]';
END rEV_DAT_Event_Date_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_DAT_Event_Date (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_DAT,
            EV_DAT_ID,
            EV_DAT_PositedAt,
            EV_DAT_Who,
            EV_DAT_Confidence,
            EV_DAT_Stance,
            EV_DAT_EV_ID,
            EV_DAT_Event_Date
        FROM (
            SELECT
                a.Metadata_EV_DAT,
                p.EV_DAT_ID,
                a.EV_DAT_PositedAt,
                a.EV_DAT_Who,
                a.EV_DAT_Confidence,
                a.EV_DAT_Stance,
                p.EV_DAT_EV_ID,
                p.EV_DAT_Event_Date,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_DAT_ID,
                        a.EV_DAT_Who
                    ORDER BY
                        a.EV_DAT_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_DAT_Event_Date_Fact p
            JOIN
                attributes.EV_DAT_Event_Date_Meta a
            ON
                a.EV_DAT_ID = p.EV_DAT_ID
            AND
                a.EV_DAT_Who = COALESCE(positor, a.EV_DAT_Who)
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
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Who,
            EV_AUD_Confidence,
            EV_AUD_Stance
        FROM
            attributes.EV_AUD_Event_Audience_Meta
        WHERE
            EV_AUD_PositedAt <= positingTimepoint
    ]';
END rEV_AUD_Event_Audience_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_AUD_Event_Audience (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_AUD,
            EV_AUD_ID,
            EV_AUD_PositedAt,
            EV_AUD_Who,
            EV_AUD_Confidence,
            EV_AUD_Stance,
            EV_AUD_EV_ID,
            EV_AUD_Event_Audience
        FROM (
            SELECT
                a.Metadata_EV_AUD,
                p.EV_AUD_ID,
                a.EV_AUD_PositedAt,
                a.EV_AUD_Who,
                a.EV_AUD_Confidence,
                a.EV_AUD_Stance,
                p.EV_AUD_EV_ID,
                p.EV_AUD_Event_Audience,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_AUD_ID,
                        a.EV_AUD_Who
                    ORDER BY
                        a.EV_AUD_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_AUD_Event_Audience_Fact p
            JOIN
                attributes.EV_AUD_Event_Audience_Meta a
            ON
                a.EV_AUD_ID = p.EV_AUD_ID
            AND
                a.EV_AUD_Who = COALESCE(positor, a.EV_AUD_Who)
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
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Who,
            EV_REV_Confidence,
            EV_REV_Stance
        FROM
            attributes.EV_REV_Event_Revenue_Meta
        WHERE
            EV_REV_PositedAt <= positingTimepoint
    ]';
END rEV_REV_Event_Revenue_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_REV_Event_Revenue (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_REV,
            EV_REV_ID,
            EV_REV_PositedAt,
            EV_REV_Who,
            EV_REV_Confidence,
            EV_REV_Stance,
            EV_REV_EV_ID,
            EV_REV_Event_Revenue
        FROM (
            SELECT
                a.Metadata_EV_REV,
                p.EV_REV_ID,
                a.EV_REV_PositedAt,
                a.EV_REV_Who,
                a.EV_REV_Confidence,
                a.EV_REV_Stance,
                p.EV_REV_EV_ID,
                p.EV_REV_Event_Revenue,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_REV_ID,
                        a.EV_REV_Who
                    ORDER BY
                        a.EV_REV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_REV_Event_Revenue_Fact p
            JOIN
                attributes.EV_REV_Event_Revenue_Meta a
            ON
                a.EV_REV_ID = p.EV_REV_ID
            AND
                a.EV_REV_Who = COALESCE(positor, a.EV_REV_Who)
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
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_STA_ID,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Event_Status_Fact
        WHERE
            EV_STA_ChangedAt <= changingTimepoint
    ]';
END rEV_STA_Event_Status_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_STA_ID,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM
            attributes.EV_STA_Event_Status_Fact
        WHERE
            EV_STA_ChangedAt > changingTimepoint
    ]';
END fEV_STA_Event_Status_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Who,
            EV_STA_Confidence,
            EV_STA_Stance
        FROM
            attributes.EV_STA_Event_Status_Meta
        WHERE
            EV_STA_PositedAt <= positingTimepoint
    ]';
END rEV_STA_Event_Status_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_STA_Event_Status (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Who,
            EV_STA_Confidence,
            EV_STA_Stance,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_STA,
                p.EV_STA_ID,
                a.EV_STA_PositedAt,
                a.EV_STA_Who,
                a.EV_STA_Confidence,
                a.EV_STA_Stance,
                p.EV_STA_EV_ID,
                p.EV_STA_Event_Status,
                p.EV_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_STA_ID,
                        a.EV_STA_Who
                    ORDER BY
                        a.EV_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_STA_Event_Status_Fact p
            JOIN
                attributes.EV_STA_Event_Status_Meta a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            AND
                a.EV_STA_Who = COALESCE(positor, a.EV_STA_Who)
            WHERE
                p.EV_STA_ChangedAt <= changingTimepoint
            AND
                a.EV_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_STA_Event_Status;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_STA_Event_Status (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_STA,
            EV_STA_ID,
            EV_STA_PositedAt,
            EV_STA_Who,
            EV_STA_Confidence,
            EV_STA_Stance,
            EV_STA_EV_ID,
            EV_STA_Event_Status,
            EV_STA_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_STA,
                p.EV_STA_ID,
                a.EV_STA_PositedAt,
                a.EV_STA_Who,
                a.EV_STA_Confidence,
                a.EV_STA_Stance,
                p.EV_STA_EV_ID,
                p.EV_STA_Event_Status,
                p.EV_STA_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_STA_ID,
                        a.EV_STA_Who
                    ORDER BY
                        a.EV_STA_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_STA_Event_Status_Fact p
            JOIN
                attributes.EV_STA_Event_Status_Meta a
            ON
                a.EV_STA_ID = p.EV_STA_ID
            AND
                a.EV_STA_Who = COALESCE(positor, a.EV_STA_Who)
            WHERE
                p.EV_STA_ChangedAt > changingTimepoint
            AND
                a.EV_STA_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_STA_Event_Status;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Who,
            EV_UTL_Confidence,
            EV_UTL_Stance
        FROM
            attributes.EV_UTL_Event_Utilization_Meta
        WHERE
            EV_UTL_PositedAt <= positingTimepoint
    ]';
END rEV_UTL_Event_Utilization_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_UTL_Event_Utilization (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_UTL,
            EV_UTL_ID,
            EV_UTL_PositedAt,
            EV_UTL_Who,
            EV_UTL_Confidence,
            EV_UTL_Stance,
            EV_UTL_EV_ID,
            EV_UTL_UTL_ID
        FROM (
            SELECT
                a.Metadata_EV_UTL,
                p.EV_UTL_ID,
                a.EV_UTL_PositedAt,
                a.EV_UTL_Who,
                a.EV_UTL_Confidence,
                a.EV_UTL_Stance,
                p.EV_UTL_EV_ID,
                p.EV_UTL_UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_UTL_ID,
                        a.EV_UTL_Who
                    ORDER BY
                        a.EV_UTL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_UTL_Event_Utilization_Fact p
            JOIN
                attributes.EV_UTL_Event_Utilization_Meta a
            ON
                a.EV_UTL_ID = p.EV_UTL_ID
            AND
                a.EV_UTL_Who = COALESCE(positor, a.EV_UTL_Who)
            WHERE
                a.EV_UTL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_UTL_Event_Utilization;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_LVL_ID,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Event_Level_Fact
        WHERE
            EV_LVL_ChangedAt <= changingTimepoint
    ]';
END rEV_LVL_Event_Level_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_LVL_ID,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM
            attributes.EV_LVL_Event_Level_Fact
        WHERE
            EV_LVL_ChangedAt > changingTimepoint
    ]';
END fEV_LVL_Event_Level_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Who,
            EV_LVL_Confidence,
            EV_LVL_Stance
        FROM
            attributes.EV_LVL_Event_Level_Meta
        WHERE
            EV_LVL_PositedAt <= positingTimepoint
    ]';
END rEV_LVL_Event_Level_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rEV_LVL_Event_Level (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Who,
            EV_LVL_Confidence,
            EV_LVL_Stance,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_LVL,
                p.EV_LVL_ID,
                a.EV_LVL_PositedAt,
                a.EV_LVL_Who,
                a.EV_LVL_Confidence,
                a.EV_LVL_Stance,
                p.EV_LVL_EV_ID,
                p.EV_LVL_PLV_ID,
                p.EV_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_LVL_ID,
                        a.EV_LVL_Who
                    ORDER BY
                        a.EV_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_LVL_Event_Level_Fact p
            JOIN
                attributes.EV_LVL_Event_Level_Meta a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            AND
                a.EV_LVL_Who = COALESCE(positor, a.EV_LVL_Who)
            WHERE
                p.EV_LVL_ChangedAt <= changingTimepoint
            AND
                a.EV_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_LVL_Event_Level;
/
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fEV_LVL_Event_Level (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_LVL,
            EV_LVL_ID,
            EV_LVL_PositedAt,
            EV_LVL_Who,
            EV_LVL_Confidence,
            EV_LVL_Stance,
            EV_LVL_EV_ID,
            EV_LVL_PLV_ID,
            EV_LVL_ChangedAt
        FROM (
            SELECT
                a.Metadata_EV_LVL,
                p.EV_LVL_ID,
                a.EV_LVL_PositedAt,
                a.EV_LVL_Who,
                a.EV_LVL_Confidence,
                a.EV_LVL_Stance,
                p.EV_LVL_EV_ID,
                p.EV_LVL_PLV_ID,
                p.EV_LVL_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_LVL_ID,
                        a.EV_LVL_Who
                    ORDER BY
                        a.EV_LVL_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.EV_LVL_Event_Level_Fact p
            JOIN
                attributes.EV_LVL_Event_Level_Meta a
            ON
                a.EV_LVL_ID = p.EV_LVL_ID
            AND
                a.EV_LVL_Who = COALESCE(positor, a.EV_LVL_Who)
            WHERE
                p.EV_LVL_ChangedAt > changingTimepoint
            AND
                a.EV_LVL_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_LVL_Event_Level;
/
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Stage_Name_Fact
        WHERE
            ST_NAM_ChangedAt <= changingTimepoint
    ]';
END rST_NAM_Stage_Name_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_NAM_ID,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM
            attributes.ST_NAM_Stage_Name_Fact
        WHERE
            ST_NAM_ChangedAt > changingTimepoint
    ]';
END fST_NAM_Stage_Name_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Who,
            ST_NAM_Confidence,
            ST_NAM_Stance
        FROM
            attributes.ST_NAM_Stage_Name_Meta
        WHERE
            ST_NAM_PositedAt <= positingTimepoint
    ]';
END rST_NAM_Stage_Name_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_NAM_Stage_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Who,
            ST_NAM_Confidence,
            ST_NAM_Stance,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Who,
                a.ST_NAM_Confidence,
                a.ST_NAM_Stance,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Who
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_NAM_Stage_Name_Fact p
            JOIN
                attributes.ST_NAM_Stage_Name_Meta a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Who = COALESCE(positor, a.ST_NAM_Who)
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
CREATE OR REPLACE FUNCTION attributes.fST_NAM_Stage_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_NAM,
            ST_NAM_ID,
            ST_NAM_PositedAt,
            ST_NAM_Who,
            ST_NAM_Confidence,
            ST_NAM_Stance,
            ST_NAM_ST_ID,
            ST_NAM_Stage_Name,
            ST_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_NAM,
                p.ST_NAM_ID,
                a.ST_NAM_PositedAt,
                a.ST_NAM_Who,
                a.ST_NAM_Confidence,
                a.ST_NAM_Stance,
                p.ST_NAM_ST_ID,
                p.ST_NAM_Stage_Name,
                p.ST_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_NAM_ID,
                        a.ST_NAM_Who
                    ORDER BY
                        a.ST_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_NAM_Stage_Name_Fact p
            JOIN
                attributes.ST_NAM_Stage_Name_Meta a
            ON
                a.ST_NAM_ID = p.ST_NAM_ID
            AND
                a.ST_NAM_Who = COALESCE(positor, a.ST_NAM_Who)
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
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Who,
            ST_LOC_Confidence,
            ST_LOC_Stance
        FROM
            attributes.ST_LOC_Stage_Location_Meta
        WHERE
            ST_LOC_PositedAt <= positingTimepoint
    ]';
END rST_LOC_Stage_Location_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_LOC_Stage_Location (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_LOC,
            ST_LOC_ID,
            ST_LOC_PositedAt,
            ST_LOC_Who,
            ST_LOC_Confidence,
            ST_LOC_Stance,
            ST_LOC_ST_ID,
            ST_LOC_Checksum,
            ST_LOC_Stage_Location
        FROM (
            SELECT
                a.Metadata_ST_LOC,
                p.ST_LOC_ID,
                a.ST_LOC_PositedAt,
                a.ST_LOC_Who,
                a.ST_LOC_Confidence,
                a.ST_LOC_Stance,
                p.ST_LOC_ST_ID,
                p.ST_LOC_Checksum,
                p.ST_LOC_Stage_Location,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_LOC_ID,
                        a.ST_LOC_Who
                    ORDER BY
                        a.ST_LOC_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_LOC_Stage_Location_Fact p
            JOIN
                attributes.ST_LOC_Stage_Location_Meta a
            ON
                a.ST_LOC_ID = p.ST_LOC_ID
            AND
                a.ST_LOC_Who = COALESCE(positor, a.ST_LOC_Who)
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
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Stage_Average_Fact
        WHERE
            ST_AVG_ChangedAt <= changingTimepoint
    ]';
END rST_AVG_Stage_Average_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_AVG_ID,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM
            attributes.ST_AVG_Stage_Average_Fact
        WHERE
            ST_AVG_ChangedAt > changingTimepoint
    ]';
END fST_AVG_Stage_Average_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Who,
            ST_AVG_Confidence,
            ST_AVG_Stance
        FROM
            attributes.ST_AVG_Stage_Average_Meta
        WHERE
            ST_AVG_PositedAt <= positingTimepoint
    ]';
END rST_AVG_Stage_Average_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_AVG_Stage_Average (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Who,
            ST_AVG_Confidence,
            ST_AVG_Stance,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Who,
                a.ST_AVG_Confidence,
                a.ST_AVG_Stance,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Who
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_AVG_Stage_Average_Fact p
            JOIN
                attributes.ST_AVG_Stage_Average_Meta a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Who = COALESCE(positor, a.ST_AVG_Who)
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
CREATE OR REPLACE FUNCTION attributes.fST_AVG_Stage_Average (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_AVG,
            ST_AVG_ID,
            ST_AVG_PositedAt,
            ST_AVG_Who,
            ST_AVG_Confidence,
            ST_AVG_Stance,
            ST_AVG_ST_ID,
            ST_AVG_UTL_ID,
            ST_AVG_ChangedAt
        FROM (
            SELECT
                a.Metadata_ST_AVG,
                p.ST_AVG_ID,
                a.ST_AVG_PositedAt,
                a.ST_AVG_Who,
                a.ST_AVG_Confidence,
                a.ST_AVG_Stance,
                p.ST_AVG_ST_ID,
                p.ST_AVG_UTL_ID,
                p.ST_AVG_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_AVG_ID,
                        a.ST_AVG_Who
                    ORDER BY
                        a.ST_AVG_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_AVG_Stage_Average_Fact p
            JOIN
                attributes.ST_AVG_Stage_Average_Meta a
            ON
                a.ST_AVG_ID = p.ST_AVG_ID
            AND
                a.ST_AVG_Who = COALESCE(positor, a.ST_AVG_Who)
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
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Who,
            ST_MIN_Confidence,
            ST_MIN_Stance
        FROM
            attributes.ST_MIN_Stage_Minimum_Meta
        WHERE
            ST_MIN_PositedAt <= positingTimepoint
    ]';
END rST_MIN_Stage_Minimum_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rST_MIN_Stage_Minimum (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_MIN,
            ST_MIN_ID,
            ST_MIN_PositedAt,
            ST_MIN_Who,
            ST_MIN_Confidence,
            ST_MIN_Stance,
            ST_MIN_ST_ID,
            ST_MIN_UTL_ID
        FROM (
            SELECT
                a.Metadata_ST_MIN,
                p.ST_MIN_ID,
                a.ST_MIN_PositedAt,
                a.ST_MIN_Who,
                a.ST_MIN_Confidence,
                a.ST_MIN_Stance,
                p.ST_MIN_ST_ID,
                p.ST_MIN_UTL_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_MIN_ID,
                        a.ST_MIN_Who
                    ORDER BY
                        a.ST_MIN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.ST_MIN_Stage_Minimum_Fact p
            JOIN
                attributes.ST_MIN_Stage_Minimum_Meta a
            ON
                a.ST_MIN_ID = p.ST_MIN_ID
            AND
                a.ST_MIN_Who = COALESCE(positor, a.ST_MIN_Who)
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
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Actor_Name_Fact
        WHERE
            AC_NAM_ChangedAt <= changingTimepoint
    ]';
END rAC_NAM_Actor_Name_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_NAM_ID,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM
            attributes.AC_NAM_Actor_Name_Fact
        WHERE
            AC_NAM_ChangedAt > changingTimepoint
    ]';
END fAC_NAM_Actor_Name_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Who,
            AC_NAM_Confidence,
            AC_NAM_Stance
        FROM
            attributes.AC_NAM_Actor_Name_Meta
        WHERE
            AC_NAM_PositedAt <= positingTimepoint
    ]';
END rAC_NAM_Actor_Name_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_NAM_Actor_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Who,
            AC_NAM_Confidence,
            AC_NAM_Stance,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Who,
                a.AC_NAM_Confidence,
                a.AC_NAM_Stance,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Who
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_NAM_Actor_Name_Fact p
            JOIN
                attributes.AC_NAM_Actor_Name_Meta a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Who = COALESCE(positor, a.AC_NAM_Who)
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
CREATE OR REPLACE FUNCTION attributes.fAC_NAM_Actor_Name (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_NAM,
            AC_NAM_ID,
            AC_NAM_PositedAt,
            AC_NAM_Who,
            AC_NAM_Confidence,
            AC_NAM_Stance,
            AC_NAM_AC_ID,
            AC_NAM_Actor_Name,
            AC_NAM_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_NAM,
                p.AC_NAM_ID,
                a.AC_NAM_PositedAt,
                a.AC_NAM_Who,
                a.AC_NAM_Confidence,
                a.AC_NAM_Stance,
                p.AC_NAM_AC_ID,
                p.AC_NAM_Actor_Name,
                p.AC_NAM_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_NAM_ID,
                        a.AC_NAM_Who
                    ORDER BY
                        a.AC_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_NAM_Actor_Name_Fact p
            JOIN
                attributes.AC_NAM_Actor_Name_Meta a
            ON
                a.AC_NAM_ID = p.AC_NAM_ID
            AND
                a.AC_NAM_Who = COALESCE(positor, a.AC_NAM_Who)
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
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Who,
            AC_GEN_Confidence,
            AC_GEN_Stance
        FROM
            attributes.AC_GEN_Actor_Gender_Meta
        WHERE
            AC_GEN_PositedAt <= positingTimepoint
    ]';
END rAC_GEN_Actor_Gender_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_GEN_Actor_Gender (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_GEN,
            AC_GEN_ID,
            AC_GEN_PositedAt,
            AC_GEN_Who,
            AC_GEN_Confidence,
            AC_GEN_Stance,
            AC_GEN_AC_ID,
            AC_GEN_GEN_ID
        FROM (
            SELECT
                a.Metadata_AC_GEN,
                p.AC_GEN_ID,
                a.AC_GEN_PositedAt,
                a.AC_GEN_Who,
                a.AC_GEN_Confidence,
                a.AC_GEN_Stance,
                p.AC_GEN_AC_ID,
                p.AC_GEN_GEN_ID,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_GEN_ID,
                        a.AC_GEN_Who
                    ORDER BY
                        a.AC_GEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_GEN_Actor_Gender_Fact p
            JOIN
                attributes.AC_GEN_Actor_Gender_Meta a
            ON
                a.AC_GEN_ID = p.AC_GEN_ID
            AND
                a.AC_GEN_Who = COALESCE(positor, a.AC_GEN_Who)
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
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact
        WHERE
            AC_PLV_ChangedAt <= changingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel_Fact (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_PLV_ID,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Fact
        WHERE
            AC_PLV_ChangedAt > changingTimepoint
    ]';
END fAC_PLV_Actor_ProfessionalLevel_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Who,
            AC_PLV_Confidence,
            AC_PLV_Stance
        FROM
            attributes.AC_PLV_Actor_ProfessionalLevel_Meta
        WHERE
            AC_PLV_PositedAt <= positingTimepoint
    ]';
END rAC_PLV_Actor_ProfessionalLevel_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rAC_PLV_Actor_ProfessionalLevel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Who,
            AC_PLV_Confidence,
            AC_PLV_Stance,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Who,
                a.AC_PLV_Confidence,
                a.AC_PLV_Stance,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Who
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
            JOIN
                attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Who = COALESCE(positor, a.AC_PLV_Who)
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
CREATE OR REPLACE FUNCTION attributes.fAC_PLV_Actor_ProfessionalLevel (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_PLV,
            AC_PLV_ID,
            AC_PLV_PositedAt,
            AC_PLV_Who,
            AC_PLV_Confidence,
            AC_PLV_Stance,
            AC_PLV_AC_ID,
            AC_PLV_PLV_ID,
            AC_PLV_ChangedAt
        FROM (
            SELECT
                a.Metadata_AC_PLV,
                p.AC_PLV_ID,
                a.AC_PLV_PositedAt,
                a.AC_PLV_Who,
                a.AC_PLV_Confidence,
                a.AC_PLV_Stance,
                p.AC_PLV_AC_ID,
                p.AC_PLV_PLV_ID,
                p.AC_PLV_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_PLV_ID,
                        a.AC_PLV_Who
                    ORDER BY
                        a.AC_PLV_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.AC_PLV_Actor_ProfessionalLevel_Fact p
            JOIN
                attributes.AC_PLV_Actor_ProfessionalLevel_Meta a
            ON
                a.AC_PLV_ID = p.AC_PLV_ID
            AND
                a.AC_PLV_Who = COALESCE(positor, a.AC_PLV_Who)
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
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Who,
            PR_NAM_Confidence,
            PR_NAM_Stance
        FROM
            attributes.PR_NAM_Program_Name_Meta
        WHERE
            PR_NAM_PositedAt <= positingTimepoint
    ]';
END rPR_NAM_Program_Name_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_NAM_Program_Name (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_NAM,
            PR_NAM_ID,
            PR_NAM_PositedAt,
            PR_NAM_Who,
            PR_NAM_Confidence,
            PR_NAM_Stance,
            PR_NAM_PR_ID,
            PR_NAM_Program_Name
        FROM (
            SELECT
                a.Metadata_PR_NAM,
                p.PR_NAM_ID,
                a.PR_NAM_PositedAt,
                a.PR_NAM_Who,
                a.PR_NAM_Confidence,
                a.PR_NAM_Stance,
                p.PR_NAM_PR_ID,
                p.PR_NAM_Program_Name,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_NAM_ID,
                        a.PR_NAM_Who
                    ORDER BY
                        a.PR_NAM_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_NAM_Program_Name_Fact p
            JOIN
                attributes.PR_NAM_Program_Name_Meta a
            ON
                a.PR_NAM_ID = p.PR_NAM_ID
            AND
                a.PR_NAM_Who = COALESCE(positor, a.PR_NAM_Who)
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
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Program_Length_Fact
        WHERE
            PR_LEN_ChangedAt <= changingTimepoint
    ]';
END rPR_LEN_Program_Length_Fact;
/
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length_Fact (
    changingTimepoint IN date
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_LEN_ID,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM
            attributes.PR_LEN_Program_Length_Fact
        WHERE
            PR_LEN_ChangedAt > changingTimepoint
    ]';
END fPR_LEN_Program_Length_Fact;
/
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length_Meta (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Who,
            PR_LEN_Confidence,
            PR_LEN_Stance
        FROM
            attributes.PR_LEN_Program_Length_Meta
        WHERE
            PR_LEN_PositedAt <= positingTimepoint
    ]';
END rPR_LEN_Program_Length_Meta;
/
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes.rPR_LEN_Program_Length (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Who,
            PR_LEN_Confidence,
            PR_LEN_Stance,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Who,
                a.PR_LEN_Confidence,
                a.PR_LEN_Stance,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Who
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_LEN_Program_Length_Fact p
            JOIN
                attributes.PR_LEN_Program_Length_Meta a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Who = COALESCE(positor, a.PR_LEN_Who)
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
CREATE OR REPLACE FUNCTION attributes.fPR_LEN_Program_Length (
    positor IN number,
    changingTimepoint IN date,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_LEN,
            PR_LEN_ID,
            PR_LEN_PositedAt,
            PR_LEN_Who,
            PR_LEN_Confidence,
            PR_LEN_Stance,
            PR_LEN_PR_ID,
            PR_LEN_Program_Length,
            PR_LEN_ChangedAt
        FROM (
            SELECT
                a.Metadata_PR_LEN,
                p.PR_LEN_ID,
                a.PR_LEN_PositedAt,
                a.PR_LEN_Who,
                a.PR_LEN_Confidence,
                a.PR_LEN_Stance,
                p.PR_LEN_PR_ID,
                p.PR_LEN_Program_Length,
                p.PR_LEN_ChangedAt,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_LEN_ID,
                        a.PR_LEN_Who
                    ORDER BY
                        a.PR_LEN_PositedAt DESC
                ) AS rowNumber
            FROM
                attributes.PR_LEN_Program_Length_Fact p
            JOIN
                attributes.PR_LEN_Program_Length_Meta a
            ON
                a.PR_LEN_ID = p.PR_LEN_ID
            AND
                a.PR_LEN_Who = COALESCE(positor, a.PR_LEN_Who)
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
