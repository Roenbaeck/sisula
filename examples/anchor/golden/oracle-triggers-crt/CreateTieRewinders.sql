-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null. They are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): functions that return
-- the text of a query, in which the parameters stand for the values given, called in the FROM clause like a table.
-- The macros do not call each other, they do what the others do in their own query.
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_holder_OB_item_GRD_grade_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt
        FROM
            SU_holder_OB_item_GRD_grade_Posit
        WHERE
            SU_holder_OB_item_GRD_grade_ChangedAt <= changingTimepoint
    ]';
END rSU_holder_OB_item_GRD_grade_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_holder_OB_item_GRD_grade_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt
        FROM
            SU_holder_OB_item_GRD_grade_Posit
        WHERE
            SU_holder_OB_item_GRD_grade_ChangedAt > changingTimepoint
    ]';
END fSU_holder_OB_item_GRD_grade_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_holder_OB_item_GRD_grade_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_holder_OB_item_GRD_grade_Reliability,
            SU_holder_OB_item_GRD_grade_Assertion
        FROM
            SU_holder_OB_item_GRD_grade_Annex
        WHERE
            SU_holder_OB_item_GRD_grade_PositedAt <= positingTimepoint
    ]';
END rSU_holder_OB_item_GRD_grade_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_holder_OB_item_GRD_grade (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_holder_OB_item_GRD_grade_Reliability,
            SU_holder_OB_item_GRD_grade_Assertion
        FROM (
            SELECT
                a.Metadata_SU_holder_OB_item_GRD_grade,
                p.SU_holder_OB_item_GRD_grade_ID,
                p.SU_ID_holder,
                p.OB_ID_item,
                p.GRD_ID_grade,
                p.SU_holder_OB_item_GRD_grade_ChangedAt,
                a.SU_holder_OB_item_GRD_grade_PositedAt,
                a.SU_holder_OB_item_GRD_grade_Positor,
                a.SU_holder_OB_item_GRD_grade_Reliability,
                a.SU_holder_OB_item_GRD_grade_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_holder_OB_item_GRD_grade_ID,
                        a.SU_holder_OB_item_GRD_grade_Positor
                    ORDER BY
                        a.SU_holder_OB_item_GRD_grade_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_holder_OB_item_GRD_grade_Posit p
            JOIN
                SU_holder_OB_item_GRD_grade_Annex a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            AND
                a.SU_holder_OB_item_GRD_grade_Positor = COALESCE(positor, a.SU_holder_OB_item_GRD_grade_Positor)
            WHERE
                p.SU_holder_OB_item_GRD_grade_ChangedAt <= changingTimepoint
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_holder_OB_item_GRD_grade;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_holder_OB_item_GRD_grade (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_holder_OB_item_GRD_grade,
            SU_holder_OB_item_GRD_grade_ID,
            SU_ID_holder,
            OB_ID_item,
            GRD_ID_grade,
            SU_holder_OB_item_GRD_grade_ChangedAt,
            SU_holder_OB_item_GRD_grade_PositedAt,
            SU_holder_OB_item_GRD_grade_Positor,
            SU_holder_OB_item_GRD_grade_Reliability,
            SU_holder_OB_item_GRD_grade_Assertion
        FROM (
            SELECT
                a.Metadata_SU_holder_OB_item_GRD_grade,
                p.SU_holder_OB_item_GRD_grade_ID,
                p.SU_ID_holder,
                p.OB_ID_item,
                p.GRD_ID_grade,
                p.SU_holder_OB_item_GRD_grade_ChangedAt,
                a.SU_holder_OB_item_GRD_grade_PositedAt,
                a.SU_holder_OB_item_GRD_grade_Positor,
                a.SU_holder_OB_item_GRD_grade_Reliability,
                a.SU_holder_OB_item_GRD_grade_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_holder_OB_item_GRD_grade_ID,
                        a.SU_holder_OB_item_GRD_grade_Positor
                    ORDER BY
                        a.SU_holder_OB_item_GRD_grade_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_holder_OB_item_GRD_grade_Posit p
            JOIN
                SU_holder_OB_item_GRD_grade_Annex a
            ON
                a.SU_holder_OB_item_GRD_grade_ID = p.SU_holder_OB_item_GRD_grade_ID
            AND
                a.SU_holder_OB_item_GRD_grade_Positor = COALESCE(positor, a.SU_holder_OB_item_GRD_grade_Positor)
            WHERE
                p.SU_holder_OB_item_GRD_grade_ChangedAt > changingTimepoint
            AND
                a.SU_holder_OB_item_GRD_grade_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_holder_OB_item_GRD_grade;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_keeper_OB_thing_GRD_rank_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit
        WHERE
            SU_keeper_OB_thing_GRD_rank_ChangedAt <= changingTimepoint
    ]';
END rSU_keeper_OB_thing_GRD_rank_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_keeper_OB_thing_GRD_rank_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt
        FROM
            SU_keeper_OB_thing_GRD_rank_Posit
        WHERE
            SU_keeper_OB_thing_GRD_rank_ChangedAt > changingTimepoint
    ]';
END fSU_keeper_OB_thing_GRD_rank_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_keeper_OB_thing_GRD_rank_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_Reliability,
            SU_keeper_OB_thing_GRD_rank_Assertion
        FROM
            SU_keeper_OB_thing_GRD_rank_Annex
        WHERE
            SU_keeper_OB_thing_GRD_rank_PositedAt <= positingTimepoint
    ]';
END rSU_keeper_OB_thing_GRD_rank_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_keeper_OB_thing_GRD_rank (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_Reliability,
            SU_keeper_OB_thing_GRD_rank_Assertion
        FROM (
            SELECT
                a.Metadata_SU_keeper_OB_thing_GRD_rank,
                p.SU_keeper_OB_thing_GRD_rank_ID,
                p.SU_ID_keeper,
                p.OB_ID_thing,
                p.GRD_ID_rank,
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                a.SU_keeper_OB_thing_GRD_rank_PositedAt,
                a.SU_keeper_OB_thing_GRD_rank_Positor,
                a.SU_keeper_OB_thing_GRD_rank_Reliability,
                a.SU_keeper_OB_thing_GRD_rank_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_keeper_OB_thing_GRD_rank_ID,
                        a.SU_keeper_OB_thing_GRD_rank_Positor
                    ORDER BY
                        a.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_keeper_OB_thing_GRD_rank_Posit p
            JOIN
                SU_keeper_OB_thing_GRD_rank_Annex a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            AND
                a.SU_keeper_OB_thing_GRD_rank_Positor = COALESCE(positor, a.SU_keeper_OB_thing_GRD_rank_Positor)
            WHERE
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt <= changingTimepoint
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_keeper_OB_thing_GRD_rank;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_keeper_OB_thing_GRD_rank (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_keeper_OB_thing_GRD_rank,
            SU_keeper_OB_thing_GRD_rank_ID,
            SU_ID_keeper,
            OB_ID_thing,
            GRD_ID_rank,
            SU_keeper_OB_thing_GRD_rank_ChangedAt,
            SU_keeper_OB_thing_GRD_rank_PositedAt,
            SU_keeper_OB_thing_GRD_rank_Positor,
            SU_keeper_OB_thing_GRD_rank_Reliability,
            SU_keeper_OB_thing_GRD_rank_Assertion
        FROM (
            SELECT
                a.Metadata_SU_keeper_OB_thing_GRD_rank,
                p.SU_keeper_OB_thing_GRD_rank_ID,
                p.SU_ID_keeper,
                p.OB_ID_thing,
                p.GRD_ID_rank,
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt,
                a.SU_keeper_OB_thing_GRD_rank_PositedAt,
                a.SU_keeper_OB_thing_GRD_rank_Positor,
                a.SU_keeper_OB_thing_GRD_rank_Reliability,
                a.SU_keeper_OB_thing_GRD_rank_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_keeper_OB_thing_GRD_rank_ID,
                        a.SU_keeper_OB_thing_GRD_rank_Positor
                    ORDER BY
                        a.SU_keeper_OB_thing_GRD_rank_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_keeper_OB_thing_GRD_rank_Posit p
            JOIN
                SU_keeper_OB_thing_GRD_rank_Annex a
            ON
                a.SU_keeper_OB_thing_GRD_rank_ID = p.SU_keeper_OB_thing_GRD_rank_ID
            AND
                a.SU_keeper_OB_thing_GRD_rank_Positor = COALESCE(positor, a.SU_keeper_OB_thing_GRD_rank_Positor)
            WHERE
                p.SU_keeper_OB_thing_GRD_rank_ChangedAt > changingTimepoint
            AND
                a.SU_keeper_OB_thing_GRD_rank_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_keeper_OB_thing_GRD_rank;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_part_SU_owner_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Positor,
            OB_part_SU_owner_Reliability,
            OB_part_SU_owner_Assertion
        FROM
            OB_part_SU_owner_Annex
        WHERE
            OB_part_SU_owner_PositedAt <= positingTimepoint
    ]';
END rOB_part_SU_owner_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rOB_part_SU_owner (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_ID_part,
            SU_ID_owner,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Positor,
            OB_part_SU_owner_Reliability,
            OB_part_SU_owner_Assertion
        FROM (
            SELECT
                a.Metadata_OB_part_SU_owner,
                p.OB_part_SU_owner_ID,
                p.OB_ID_part,
                p.SU_ID_owner,
                a.OB_part_SU_owner_PositedAt,
                a.OB_part_SU_owner_Positor,
                a.OB_part_SU_owner_Reliability,
                a.OB_part_SU_owner_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.OB_part_SU_owner_ID,
                        a.OB_part_SU_owner_Positor
                    ORDER BY
                        a.OB_part_SU_owner_PositedAt DESC
                ) AS rowNumber
            FROM
                OB_part_SU_owner_Posit p
            JOIN
                OB_part_SU_owner_Annex a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            AND
                a.OB_part_SU_owner_Positor = COALESCE(positor, a.OB_part_SU_owner_Positor)
            WHERE
                a.OB_part_SU_owner_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rOB_part_SU_owner;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fOB_part_SU_owner (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_OB_part_SU_owner,
            OB_part_SU_owner_ID,
            OB_ID_part,
            SU_ID_owner,
            OB_part_SU_owner_PositedAt,
            OB_part_SU_owner_Positor,
            OB_part_SU_owner_Reliability,
            OB_part_SU_owner_Assertion
        FROM (
            SELECT
                a.Metadata_OB_part_SU_owner,
                p.OB_part_SU_owner_ID,
                p.OB_ID_part,
                p.SU_ID_owner,
                a.OB_part_SU_owner_PositedAt,
                a.OB_part_SU_owner_Positor,
                a.OB_part_SU_owner_Reliability,
                a.OB_part_SU_owner_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.OB_part_SU_owner_ID,
                        a.OB_part_SU_owner_Positor
                    ORDER BY
                        a.OB_part_SU_owner_PositedAt DESC
                ) AS rowNumber
            FROM
                OB_part_SU_owner_Posit p
            JOIN
                OB_part_SU_owner_Annex a
            ON
                a.OB_part_SU_owner_ID = p.OB_part_SU_owner_ID
            AND
                a.OB_part_SU_owner_Positor = COALESCE(positor, a.OB_part_SU_owner_Positor)
            WHERE
                a.OB_part_SU_owner_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fOB_part_SU_owner;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_partner_SU_with_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt
        FROM
            SU_partner_SU_with_Posit
        WHERE
            SU_partner_SU_with_ChangedAt <= changingTimepoint
    ]';
END rSU_partner_SU_with_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_partner_SU_with_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt
        FROM
            SU_partner_SU_with_Posit
        WHERE
            SU_partner_SU_with_ChangedAt > changingTimepoint
    ]';
END fSU_partner_SU_with_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_partner_SU_with_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Positor,
            SU_partner_SU_with_Reliability,
            SU_partner_SU_with_Assertion
        FROM
            SU_partner_SU_with_Annex
        WHERE
            SU_partner_SU_with_PositedAt <= positingTimepoint
    ]';
END rSU_partner_SU_with_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rSU_partner_SU_with (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Positor,
            SU_partner_SU_with_Reliability,
            SU_partner_SU_with_Assertion
        FROM (
            SELECT
                a.Metadata_SU_partner_SU_with,
                p.SU_partner_SU_with_ID,
                p.SU_ID_partner,
                p.SU_ID_with,
                p.SU_partner_SU_with_ChangedAt,
                a.SU_partner_SU_with_PositedAt,
                a.SU_partner_SU_with_Positor,
                a.SU_partner_SU_with_Reliability,
                a.SU_partner_SU_with_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_partner_SU_with_ID,
                        a.SU_partner_SU_with_Positor
                    ORDER BY
                        a.SU_partner_SU_with_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_partner_SU_with_Posit p
            JOIN
                SU_partner_SU_with_Annex a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            AND
                a.SU_partner_SU_with_Positor = COALESCE(positor, a.SU_partner_SU_with_Positor)
            WHERE
                p.SU_partner_SU_with_ChangedAt <= changingTimepoint
            AND
                a.SU_partner_SU_with_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rSU_partner_SU_with;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fSU_partner_SU_with (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_SU_partner_SU_with,
            SU_partner_SU_with_ID,
            SU_ID_partner,
            SU_ID_with,
            SU_partner_SU_with_ChangedAt,
            SU_partner_SU_with_PositedAt,
            SU_partner_SU_with_Positor,
            SU_partner_SU_with_Reliability,
            SU_partner_SU_with_Assertion
        FROM (
            SELECT
                a.Metadata_SU_partner_SU_with,
                p.SU_partner_SU_with_ID,
                p.SU_ID_partner,
                p.SU_ID_with,
                p.SU_partner_SU_with_ChangedAt,
                a.SU_partner_SU_with_PositedAt,
                a.SU_partner_SU_with_Positor,
                a.SU_partner_SU_with_Reliability,
                a.SU_partner_SU_with_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.SU_partner_SU_with_ID,
                        a.SU_partner_SU_with_Positor
                    ORDER BY
                        a.SU_partner_SU_with_PositedAt DESC
                ) AS rowNumber
            FROM
                SU_partner_SU_with_Posit p
            JOIN
                SU_partner_SU_with_Annex a
            ON
                a.SU_partner_SU_with_ID = p.SU_partner_SU_with_ID
            AND
                a.SU_partner_SU_with_Positor = COALESCE(positor, a.SU_partner_SU_with_Positor)
            WHERE
                p.SU_partner_SU_with_ChangedAt > changingTimepoint
            AND
                a.SU_partner_SU_with_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fSU_partner_SU_with;
/
