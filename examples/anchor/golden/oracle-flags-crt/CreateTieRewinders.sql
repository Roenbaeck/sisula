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
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        FROM
            ties.AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt
        FROM
            ties.AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
    ]';
END fAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_Reliability,
            AC_partner_AC_with_ONG_currently_Assertion
        FROM
            ties.AC_partner_AC_with_ONG_currently_Annex
        WHERE
            AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_Reliability,
            AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Positor,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                a.AC_partner_AC_with_ONG_currently_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID,
                        a.AC_partner_AC_with_ONG_currently_Positor
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                a.AC_partner_AC_with_ONG_currently_Positor = COALESCE(positor, a.AC_partner_AC_with_ONG_currently_Positor)
            WHERE
                p.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_partner_AC_with_ONG_currently;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_partner_AC_with_ONG_currently,
            AC_partner_AC_with_ONG_currently_ID,
            AC_ID_partner,
            AC_ID_with,
            ONG_ID_currently,
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Positor,
            AC_partner_AC_with_ONG_currently_Reliability,
            AC_partner_AC_with_ONG_currently_Assertion
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Positor,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                a.AC_partner_AC_with_ONG_currently_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID,
                        a.AC_partner_AC_with_ONG_currently_Positor
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
            AND
                a.AC_partner_AC_with_ONG_currently_Positor = COALESCE(positor, a.AC_partner_AC_with_ONG_currently_Positor)
            WHERE
                p.AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
            AND
                a.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_partner_AC_with_ONG_currently;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_Reliability,
            AC_subset_PN_of_Assertion
        FROM
            ties.AC_subset_PN_of_Annex
        WHERE
            AC_subset_PN_of_PositedAt <= positingTimepoint
    ]';
END rAC_subset_PN_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_Reliability,
            AC_subset_PN_of_Assertion
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Positor,
                a.AC_subset_PN_of_Reliability,
                a.AC_subset_PN_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID,
                        a.AC_subset_PN_of_Positor
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Posit p
            JOIN
                ties.AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                a.AC_subset_PN_of_Positor = COALESCE(positor, a.AC_subset_PN_of_Positor)
            WHERE
                a.AC_subset_PN_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_subset_PN_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_subset_PN_of (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_subset_PN_of,
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Positor,
            AC_subset_PN_of_Reliability,
            AC_subset_PN_of_Assertion
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Positor,
                a.AC_subset_PN_of_Reliability,
                a.AC_subset_PN_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID,
                        a.AC_subset_PN_of_Positor
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Posit p
            JOIN
                ties.AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
            AND
                a.AC_subset_PN_of_Positor = COALESCE(positor, a.AC_subset_PN_of_Positor)
            WHERE
                a.AC_subset_PN_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_subset_PN_of;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Positor,
            EV_in_AC_wasCast_Reliability,
            EV_in_AC_wasCast_Assertion
        FROM
            ties.EV_in_AC_wasCast_Annex
        WHERE
            EV_in_AC_wasCast_PositedAt <= positingTimepoint
    ]';
END rEV_in_AC_wasCast_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_ID_in,
            AC_ID_wasCast,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Positor,
            EV_in_AC_wasCast_Reliability,
            EV_in_AC_wasCast_Assertion
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Positor,
                a.EV_in_AC_wasCast_Reliability,
                a.EV_in_AC_wasCast_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID,
                        a.EV_in_AC_wasCast_Positor
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_wasCast_Posit p
            JOIN
                ties.EV_in_AC_wasCast_Annex a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            AND
                a.EV_in_AC_wasCast_Positor = COALESCE(positor, a.EV_in_AC_wasCast_Positor)
            WHERE
                a.EV_in_AC_wasCast_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_in_AC_wasCast;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_wasCast (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_wasCast,
            EV_in_AC_wasCast_ID,
            EV_ID_in,
            AC_ID_wasCast,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Positor,
            EV_in_AC_wasCast_Reliability,
            EV_in_AC_wasCast_Assertion
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Positor,
                a.EV_in_AC_wasCast_Reliability,
                a.EV_in_AC_wasCast_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID,
                        a.EV_in_AC_wasCast_Positor
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_wasCast_Posit p
            JOIN
                ties.EV_in_AC_wasCast_Annex a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
            AND
                a.EV_in_AC_wasCast_Positor = COALESCE(positor, a.EV_in_AC_wasCast_Positor)
            WHERE
                a.EV_in_AC_wasCast_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_in_AC_wasCast;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt
        FROM
            ties.AC_part_PR_in_RAT_got_Posit
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt
        FROM
            ties.AC_part_PR_in_RAT_got_Posit
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
    ]';
END fAC_part_PR_in_RAT_got_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Positor,
            AC_part_PR_in_RAT_got_Reliability,
            AC_part_PR_in_RAT_got_Assertion
        FROM
            ties.AC_part_PR_in_RAT_got_Annex
        WHERE
            AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Positor,
            AC_part_PR_in_RAT_got_Reliability,
            AC_part_PR_in_RAT_got_Assertion
        FROM (
            SELECT
                a.Metadata_AC_part_PR_in_RAT_got,
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Positor,
                a.AC_part_PR_in_RAT_got_Reliability,
                a.AC_part_PR_in_RAT_got_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID,
                        a.AC_part_PR_in_RAT_got_Positor
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_part_PR_in_RAT_got_Posit p
            JOIN
                ties.AC_part_PR_in_RAT_got_Annex a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            AND
                a.AC_part_PR_in_RAT_got_Positor = COALESCE(positor, a.AC_part_PR_in_RAT_got_Positor)
            WHERE
                p.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
            AND
                a.AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_part_PR_in_RAT_got;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_part_PR_in_RAT_got,
            AC_part_PR_in_RAT_got_ID,
            AC_ID_part,
            PR_ID_in,
            RAT_ID_got,
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Positor,
            AC_part_PR_in_RAT_got_Reliability,
            AC_part_PR_in_RAT_got_Assertion
        FROM (
            SELECT
                a.Metadata_AC_part_PR_in_RAT_got,
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Positor,
                a.AC_part_PR_in_RAT_got_Reliability,
                a.AC_part_PR_in_RAT_got_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID,
                        a.AC_part_PR_in_RAT_got_Positor
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_part_PR_in_RAT_got_Posit p
            JOIN
                ties.AC_part_PR_in_RAT_got_Annex a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
            AND
                a.AC_part_PR_in_RAT_got_Positor = COALESCE(positor, a.AC_part_PR_in_RAT_got_Positor)
            WHERE
                p.AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
            AND
                a.AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_part_PR_in_RAT_got;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt
        FROM
            ties.ST_at_PR_isPlaying_Posit
        WHERE
            ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END rST_at_PR_isPlaying_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt
        FROM
            ties.ST_at_PR_isPlaying_Posit
        WHERE
            ST_at_PR_isPlaying_ChangedAt > changingTimepoint
    ]';
END fST_at_PR_isPlaying_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Positor,
            ST_at_PR_isPlaying_Reliability,
            ST_at_PR_isPlaying_Assertion
        FROM
            ties.ST_at_PR_isPlaying_Annex
        WHERE
            ST_at_PR_isPlaying_PositedAt <= positingTimepoint
    ]';
END rST_at_PR_isPlaying_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Positor,
            ST_at_PR_isPlaying_Reliability,
            ST_at_PR_isPlaying_Assertion
        FROM (
            SELECT
                a.Metadata_ST_at_PR_isPlaying,
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Positor,
                a.ST_at_PR_isPlaying_Reliability,
                a.ST_at_PR_isPlaying_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID,
                        a.ST_at_PR_isPlaying_Positor
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_isPlaying_Posit p
            JOIN
                ties.ST_at_PR_isPlaying_Annex a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            AND
                a.ST_at_PR_isPlaying_Positor = COALESCE(positor, a.ST_at_PR_isPlaying_Positor)
            WHERE
                p.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
            AND
                a.ST_at_PR_isPlaying_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_at_PR_isPlaying;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_isPlaying,
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Positor,
            ST_at_PR_isPlaying_Reliability,
            ST_at_PR_isPlaying_Assertion
        FROM (
            SELECT
                a.Metadata_ST_at_PR_isPlaying,
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Positor,
                a.ST_at_PR_isPlaying_Reliability,
                a.ST_at_PR_isPlaying_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID,
                        a.ST_at_PR_isPlaying_Positor
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_isPlaying_Posit p
            JOIN
                ties.ST_at_PR_isPlaying_Annex a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
            AND
                a.ST_at_PR_isPlaying_Positor = COALESCE(positor, a.ST_at_PR_isPlaying_Positor)
            WHERE
                p.ST_at_PR_isPlaying_ChangedAt > changingTimepoint
            AND
                a.ST_at_PR_isPlaying_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_at_PR_isPlaying;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Positor,
            AC_parent_AC_child_PAT_having_Reliability,
            AC_parent_AC_child_PAT_having_Assertion
        FROM
            ties.AC_parent_AC_child_PAT_having_Annex
        WHERE
            AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
    ]';
END rAC_parent_AC_child_PAT_having_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Positor,
            AC_parent_AC_child_PAT_having_Reliability,
            AC_parent_AC_child_PAT_having_Assertion
        FROM (
            SELECT
                a.Metadata_AC_parent_AC_child_PAT_having,
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Positor,
                a.AC_parent_AC_child_PAT_having_Reliability,
                a.AC_parent_AC_child_PAT_having_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID,
                        a.AC_parent_AC_child_PAT_having_Positor
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_parent_AC_child_PAT_having_Posit p
            JOIN
                ties.AC_parent_AC_child_PAT_having_Annex a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            AND
                a.AC_parent_AC_child_PAT_having_Positor = COALESCE(positor, a.AC_parent_AC_child_PAT_having_Positor)
            WHERE
                a.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_parent_AC_child_PAT_having;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_parent_AC_child_PAT_having (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_parent_AC_child_PAT_having,
            AC_parent_AC_child_PAT_having_ID,
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Positor,
            AC_parent_AC_child_PAT_having_Reliability,
            AC_parent_AC_child_PAT_having_Assertion
        FROM (
            SELECT
                a.Metadata_AC_parent_AC_child_PAT_having,
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Positor,
                a.AC_parent_AC_child_PAT_having_Reliability,
                a.AC_parent_AC_child_PAT_having_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID,
                        a.AC_parent_AC_child_PAT_having_Positor
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_parent_AC_child_PAT_having_Posit p
            JOIN
                ties.AC_parent_AC_child_PAT_having_Annex a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            AND
                a.AC_parent_AC_child_PAT_having_Positor = COALESCE(positor, a.AC_parent_AC_child_PAT_having_Positor)
            WHERE
                a.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_parent_AC_child_PAT_having;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt
        FROM
            ties.PR_content_ST_location_EV_of_Posit
        WHERE
            PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt
        FROM
            ties.PR_content_ST_location_EV_of_Posit
        WHERE
            PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
    ]';
END fPR_content_ST_location_EV_of_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Positor,
            PR_content_ST_location_EV_of_Reliability,
            PR_content_ST_location_EV_of_Assertion
        FROM
            ties.PR_content_ST_location_EV_of_Annex
        WHERE
            PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Positor,
            PR_content_ST_location_EV_of_Reliability,
            PR_content_ST_location_EV_of_Assertion
        FROM (
            SELECT
                a.Metadata_PR_content_ST_location_EV_of,
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                p.PR_content_ST_location_EV_of_ChangedAt,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Positor,
                a.PR_content_ST_location_EV_of_Reliability,
                a.PR_content_ST_location_EV_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID,
                        a.PR_content_ST_location_EV_of_Positor
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_content_ST_location_EV_of_Posit p
            JOIN
                ties.PR_content_ST_location_EV_of_Annex a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            AND
                a.PR_content_ST_location_EV_of_Positor = COALESCE(positor, a.PR_content_ST_location_EV_of_Positor)
            WHERE
                p.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
            AND
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_content_ST_location_EV_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_content_ST_location_EV_of,
            PR_content_ST_location_EV_of_ID,
            PR_ID_content,
            ST_ID_location,
            EV_ID_of,
            PR_content_ST_location_EV_of_ChangedAt,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Positor,
            PR_content_ST_location_EV_of_Reliability,
            PR_content_ST_location_EV_of_Assertion
        FROM (
            SELECT
                a.Metadata_PR_content_ST_location_EV_of,
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                p.PR_content_ST_location_EV_of_ChangedAt,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Positor,
                a.PR_content_ST_location_EV_of_Reliability,
                a.PR_content_ST_location_EV_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID,
                        a.PR_content_ST_location_EV_of_Positor
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_content_ST_location_EV_of_Posit p
            JOIN
                ties.PR_content_ST_location_EV_of_Annex a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            AND
                a.PR_content_ST_location_EV_of_Positor = COALESCE(positor, a.PR_content_ST_location_EV_of_Positor)
            WHERE
                p.PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
            AND
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_content_ST_location_EV_of;
/
