-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time. They are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later):
-- functions that return the text of a query, in which the parameters stand for the values given, called in the FROM
-- clause like a table. The macros do not call each other, they do what the others do in their own query.
--
-- The assembled rewinder and forwarder pick, for each posit, the annex row that was last posited at or before the
-- positing time. A bi posit has no positor, so the annex rows of a posit compete with each other alone.
--
-- @changingTimepoint the point in changing time to rewind to
-- @positingTimepoint the point in positing time to rewind to
--
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_partner_AC_with_ONG_currently_Posit (
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
            AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_partner_AC_with_ONG_currently_Posit (
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
            AC_partner_AC_with_ONG_currently_Posit
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
    ]';
END fAC_partner_AC_with_ONG_currently_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_partner_AC_with_ONG_currently_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_partner_AC_with_ONG_currently_ID,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        FROM
            AC_partner_AC_with_ONG_currently_Annex
        WHERE
            AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        FROM (
            SELECT
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
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
CREATE OR REPLACE FUNCTION fAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            AC_partner_AC_with_ONG_currently_ChangedAt,
            AC_partner_AC_with_ONG_currently_PositedAt,
            AC_partner_AC_with_ONG_currently_Reliability
        FROM (
            SELECT
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_partner_AC_with_ONG_currently_Posit p
            JOIN
                AC_partner_AC_with_ONG_currently_Annex a
            ON
                a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
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
CREATE OR REPLACE FUNCTION rAC_subset_PN_of_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_subset_PN_of_ID,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        FROM
            AC_subset_PN_of_Annex
        WHERE
            AC_subset_PN_of_PositedAt <= positingTimepoint
    ]';
END rAC_subset_PN_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_subset_PN_of (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        FROM (
            SELECT
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_subset_PN_of_Posit p
            JOIN
                AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
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
CREATE OR REPLACE FUNCTION fAC_subset_PN_of (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_subset_PN_of_ID,
            AC_ID_subset,
            PN_ID_of,
            AC_subset_PN_of_PositedAt,
            AC_subset_PN_of_Reliability
        FROM (
            SELECT
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_subset_PN_of_Posit p
            JOIN
                AC_subset_PN_of_Annex a
            ON
                a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
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
CREATE OR REPLACE FUNCTION rEV_in_AC_wasCast_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_in_AC_wasCast_ID,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        FROM
            EV_in_AC_wasCast_Annex
        WHERE
            EV_in_AC_wasCast_PositedAt <= positingTimepoint
    ]';
END rEV_in_AC_wasCast_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rEV_in_AC_wasCast (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_in_AC_wasCast_ID,
            EV_ID_in,
            AC_ID_wasCast,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        FROM (
            SELECT
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_in_AC_wasCast_Posit p
            JOIN
                EV_in_AC_wasCast_Annex a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
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
CREATE OR REPLACE FUNCTION fEV_in_AC_wasCast (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            EV_in_AC_wasCast_ID,
            EV_ID_in,
            AC_ID_wasCast,
            EV_in_AC_wasCast_PositedAt,
            EV_in_AC_wasCast_Reliability
        FROM (
            SELECT
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                EV_in_AC_wasCast_Posit p
            JOIN
                EV_in_AC_wasCast_Annex a
            ON
                a.EV_in_AC_wasCast_ID = p.EV_in_AC_wasCast_ID
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
CREATE OR REPLACE FUNCTION rAC_part_PR_in_RAT_got_Posit (
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
            AC_part_PR_in_RAT_got_Posit
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fAC_part_PR_in_RAT_got_Posit (
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
            AC_part_PR_in_RAT_got_Posit
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
    ]';
END fAC_part_PR_in_RAT_got_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_part_PR_in_RAT_got_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_part_PR_in_RAT_got_ID,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        FROM
            AC_part_PR_in_RAT_got_Annex
        WHERE
            AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        FROM (
            SELECT
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_part_PR_in_RAT_got_Posit p
            JOIN
                AC_part_PR_in_RAT_got_Annex a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
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
CREATE OR REPLACE FUNCTION fAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
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
            AC_part_PR_in_RAT_got_ChangedAt,
            AC_part_PR_in_RAT_got_PositedAt,
            AC_part_PR_in_RAT_got_Reliability
        FROM (
            SELECT
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_part_PR_in_RAT_got_Posit p
            JOIN
                AC_part_PR_in_RAT_got_Annex a
            ON
                a.AC_part_PR_in_RAT_got_ID = p.AC_part_PR_in_RAT_got_ID
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
CREATE OR REPLACE FUNCTION rST_at_PR_isPlaying_Posit (
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
            ST_at_PR_isPlaying_Posit
        WHERE
            ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END rST_at_PR_isPlaying_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fST_at_PR_isPlaying_Posit (
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
            ST_at_PR_isPlaying_Posit
        WHERE
            ST_at_PR_isPlaying_ChangedAt > changingTimepoint
    ]';
END fST_at_PR_isPlaying_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_at_PR_isPlaying_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_isPlaying_ID,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        FROM
            ST_at_PR_isPlaying_Annex
        WHERE
            ST_at_PR_isPlaying_PositedAt <= positingTimepoint
    ]';
END rST_at_PR_isPlaying_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rST_at_PR_isPlaying (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        FROM (
            SELECT
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_at_PR_isPlaying_Posit p
            JOIN
                ST_at_PR_isPlaying_Annex a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
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
CREATE OR REPLACE FUNCTION fST_at_PR_isPlaying (
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_isPlaying_ID,
            ST_ID_at,
            PR_ID_isPlaying,
            ST_at_PR_isPlaying_ChangedAt,
            ST_at_PR_isPlaying_PositedAt,
            ST_at_PR_isPlaying_Reliability
        FROM (
            SELECT
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ST_at_PR_isPlaying_Posit p
            JOIN
                ST_at_PR_isPlaying_Annex a
            ON
                a.ST_at_PR_isPlaying_ID = p.ST_at_PR_isPlaying_ID
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
CREATE OR REPLACE FUNCTION rAC_parent_AC_child_PAT_having_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_parent_AC_child_PAT_having_ID,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        FROM
            AC_parent_AC_child_PAT_having_Annex
        WHERE
            AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
    ]';
END rAC_parent_AC_child_PAT_having_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rAC_parent_AC_child_PAT_having (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_parent_AC_child_PAT_having_ID,
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        FROM (
            SELECT
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_parent_AC_child_PAT_having_Posit p
            JOIN
                AC_parent_AC_child_PAT_having_Annex a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
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
CREATE OR REPLACE FUNCTION fAC_parent_AC_child_PAT_having (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_parent_AC_child_PAT_having_ID,
            AC_ID_parent,
            AC_ID_child,
            PAT_ID_having,
            AC_parent_AC_child_PAT_having_PositedAt,
            AC_parent_AC_child_PAT_having_Reliability
        FROM (
            SELECT
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                AC_parent_AC_child_PAT_having_Posit p
            JOIN
                AC_parent_AC_child_PAT_having_Annex a
            ON
                a.AC_parent_AC_child_PAT_having_ID = p.AC_parent_AC_child_PAT_having_ID
            WHERE
                a.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_parent_AC_child_PAT_having;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_content_ST_location_EV_of_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_content_ST_location_EV_of_ID,
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        FROM
            PR_content_ST_location_EV_of_Annex
        WHERE
            PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rPR_content_ST_location_EV_of (
    positingTimepoint IN timestamp
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
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        FROM (
            SELECT
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_content_ST_location_EV_of_Posit p
            JOIN
                PR_content_ST_location_EV_of_Annex a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            WHERE
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_content_ST_location_EV_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fPR_content_ST_location_EV_of (
    positingTimepoint IN timestamp
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
            PR_content_ST_location_EV_of_PositedAt,
            PR_content_ST_location_EV_of_Reliability
        FROM (
            SELECT
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Reliability,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                PR_content_ST_location_EV_of_Posit p
            JOIN
                PR_content_ST_location_EV_of_Annex a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
            WHERE
                a.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_content_ST_location_EV_of;
/
