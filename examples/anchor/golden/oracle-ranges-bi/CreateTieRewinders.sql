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
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Fact (
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
            ties.AC_partner_AC_with_ONG_currently_Fact
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently_Fact (
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
            ties.AC_partner_AC_with_ONG_currently_Fact
        WHERE
            AC_partner_AC_with_ONG_currently_ChangedAt > changingTimepoint
    ]';
END fAC_partner_AC_with_ONG_currently_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently_Meta (
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
            AC_partner_AC_with_ONG_currently_Confidence
        FROM
            ties.AC_partner_AC_with_ONG_currently_Meta
        WHERE
            AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint
    ]';
END rAC_partner_AC_with_ONG_currently_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_partner_AC_with_ONG_currently (
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
            AC_partner_AC_with_ONG_currently_Confidence
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Fact p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Meta a
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
CREATE OR REPLACE FUNCTION ties.fAC_partner_AC_with_ONG_currently (
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
            AC_partner_AC_with_ONG_currently_Confidence
        FROM (
            SELECT
                a.Metadata_AC_partner_AC_with_ONG_currently,
                p.AC_partner_AC_with_ONG_currently_ID,
                p.AC_ID_partner,
                p.AC_ID_with,
                p.ONG_ID_currently,
                p.AC_partner_AC_with_ONG_currently_ChangedAt,
                a.AC_partner_AC_with_ONG_currently_PositedAt,
                a.AC_partner_AC_with_ONG_currently_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_partner_AC_with_ONG_currently_ID
                    ORDER BY
                        a.AC_partner_AC_with_ONG_currently_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_partner_AC_with_ONG_currently_Fact p
            JOIN
                ties.AC_partner_AC_with_ONG_currently_Meta a
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
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of_Meta (
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
            AC_subset_PN_of_Confidence
        FROM
            ties.AC_subset_PN_of_Meta
        WHERE
            AC_subset_PN_of_PositedAt <= positingTimepoint
    ]';
END rAC_subset_PN_of_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_subset_PN_of (
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
            AC_subset_PN_of_Confidence
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Fact p
            JOIN
                ties.AC_subset_PN_of_Meta a
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
CREATE OR REPLACE FUNCTION ties.fAC_subset_PN_of (
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
            AC_subset_PN_of_Confidence
        FROM (
            SELECT
                a.Metadata_AC_subset_PN_of,
                p.AC_subset_PN_of_ID,
                p.AC_ID_subset,
                p.PN_ID_of,
                a.AC_subset_PN_of_PositedAt,
                a.AC_subset_PN_of_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_subset_PN_of_ID
                    ORDER BY
                        a.AC_subset_PN_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_subset_PN_of_Fact p
            JOIN
                ties.AC_subset_PN_of_Meta a
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
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast_Meta (
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
            EV_in_AC_wasCast_Confidence
        FROM
            ties.EV_in_AC_wasCast_Meta
        WHERE
            EV_in_AC_wasCast_PositedAt <= positingTimepoint
    ]';
END rEV_in_AC_wasCast_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_wasCast (
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
            EV_in_AC_wasCast_Confidence
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_wasCast_Fact p
            JOIN
                ties.EV_in_AC_wasCast_Meta a
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
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_wasCast (
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
            EV_in_AC_wasCast_Confidence
        FROM (
            SELECT
                a.Metadata_EV_in_AC_wasCast,
                p.EV_in_AC_wasCast_ID,
                p.EV_ID_in,
                p.AC_ID_wasCast,
                a.EV_in_AC_wasCast_PositedAt,
                a.EV_in_AC_wasCast_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_wasCast_ID
                    ORDER BY
                        a.EV_in_AC_wasCast_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_wasCast_Fact p
            JOIN
                ties.EV_in_AC_wasCast_Meta a
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
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Fact (
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
            ties.AC_part_PR_in_RAT_got_Fact
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got_Fact (
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
            ties.AC_part_PR_in_RAT_got_Fact
        WHERE
            AC_part_PR_in_RAT_got_ChangedAt > changingTimepoint
    ]';
END fAC_part_PR_in_RAT_got_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got_Meta (
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
            AC_part_PR_in_RAT_got_Confidence
        FROM
            ties.AC_part_PR_in_RAT_got_Meta
        WHERE
            AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint
    ]';
END rAC_part_PR_in_RAT_got_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_part_PR_in_RAT_got (
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
            AC_part_PR_in_RAT_got_Confidence
        FROM (
            SELECT
                a.Metadata_AC_part_PR_in_RAT_got,
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_part_PR_in_RAT_got_Fact p
            JOIN
                ties.AC_part_PR_in_RAT_got_Meta a
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
CREATE OR REPLACE FUNCTION ties.fAC_part_PR_in_RAT_got (
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
            AC_part_PR_in_RAT_got_Confidence
        FROM (
            SELECT
                a.Metadata_AC_part_PR_in_RAT_got,
                p.AC_part_PR_in_RAT_got_ID,
                p.AC_ID_part,
                p.PR_ID_in,
                p.RAT_ID_got,
                p.AC_part_PR_in_RAT_got_ChangedAt,
                a.AC_part_PR_in_RAT_got_PositedAt,
                a.AC_part_PR_in_RAT_got_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_part_PR_in_RAT_got_ID
                    ORDER BY
                        a.AC_part_PR_in_RAT_got_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_part_PR_in_RAT_got_Fact p
            JOIN
                ties.AC_part_PR_in_RAT_got_Meta a
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
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Fact (
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
            ties.ST_at_PR_isPlaying_Fact
        WHERE
            ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END rST_at_PR_isPlaying_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying_Fact (
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
            ties.ST_at_PR_isPlaying_Fact
        WHERE
            ST_at_PR_isPlaying_ChangedAt > changingTimepoint
    ]';
END fST_at_PR_isPlaying_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying_Meta (
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
            ST_at_PR_isPlaying_Confidence
        FROM
            ties.ST_at_PR_isPlaying_Meta
        WHERE
            ST_at_PR_isPlaying_PositedAt <= positingTimepoint
    ]';
END rST_at_PR_isPlaying_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_isPlaying (
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
            ST_at_PR_isPlaying_Confidence
        FROM (
            SELECT
                a.Metadata_ST_at_PR_isPlaying,
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_isPlaying_Fact p
            JOIN
                ties.ST_at_PR_isPlaying_Meta a
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
CREATE OR REPLACE FUNCTION ties.fST_at_PR_isPlaying (
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
            ST_at_PR_isPlaying_Confidence
        FROM (
            SELECT
                a.Metadata_ST_at_PR_isPlaying,
                p.ST_at_PR_isPlaying_ID,
                p.ST_ID_at,
                p.PR_ID_isPlaying,
                p.ST_at_PR_isPlaying_ChangedAt,
                a.ST_at_PR_isPlaying_PositedAt,
                a.ST_at_PR_isPlaying_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_isPlaying_ID
                    ORDER BY
                        a.ST_at_PR_isPlaying_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_isPlaying_Fact p
            JOIN
                ties.ST_at_PR_isPlaying_Meta a
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
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having_Meta (
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
            AC_parent_AC_child_PAT_having_Confidence
        FROM
            ties.AC_parent_AC_child_PAT_having_Meta
        WHERE
            AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint
    ]';
END rAC_parent_AC_child_PAT_having_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_parent_AC_child_PAT_having (
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
            AC_parent_AC_child_PAT_having_Confidence
        FROM (
            SELECT
                a.Metadata_AC_parent_AC_child_PAT_having,
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_parent_AC_child_PAT_having_Fact p
            JOIN
                ties.AC_parent_AC_child_PAT_having_Meta a
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
CREATE OR REPLACE FUNCTION ties.fAC_parent_AC_child_PAT_having (
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
            AC_parent_AC_child_PAT_having_Confidence
        FROM (
            SELECT
                a.Metadata_AC_parent_AC_child_PAT_having,
                p.AC_parent_AC_child_PAT_having_ID,
                p.AC_ID_parent,
                p.AC_ID_child,
                p.PAT_ID_having,
                a.AC_parent_AC_child_PAT_having_PositedAt,
                a.AC_parent_AC_child_PAT_having_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_parent_AC_child_PAT_having_ID
                    ORDER BY
                        a.AC_parent_AC_child_PAT_having_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_parent_AC_child_PAT_having_Fact p
            JOIN
                ties.AC_parent_AC_child_PAT_having_Meta a
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
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Fact (
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
            ties.PR_content_ST_location_EV_of_Fact
        WHERE
            PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Fact;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_content_ST_location_EV_of_Fact (
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
            ties.PR_content_ST_location_EV_of_Fact
        WHERE
            PR_content_ST_location_EV_of_ChangedAt > changingTimepoint
    ]';
END fPR_content_ST_location_EV_of_Fact;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of_Meta (
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
            PR_content_ST_location_EV_of_Confidence
        FROM
            ties.PR_content_ST_location_EV_of_Meta
        WHERE
            PR_content_ST_location_EV_of_PositedAt <= positingTimepoint
    ]';
END rPR_content_ST_location_EV_of_Meta;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_content_ST_location_EV_of (
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
            PR_content_ST_location_EV_of_Confidence
        FROM (
            SELECT
                a.Metadata_PR_content_ST_location_EV_of,
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                p.PR_content_ST_location_EV_of_ChangedAt,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_content_ST_location_EV_of_Fact p
            JOIN
                ties.PR_content_ST_location_EV_of_Meta a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
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
            PR_content_ST_location_EV_of_Confidence
        FROM (
            SELECT
                a.Metadata_PR_content_ST_location_EV_of,
                p.PR_content_ST_location_EV_of_ID,
                p.PR_ID_content,
                p.ST_ID_location,
                p.EV_ID_of,
                p.PR_content_ST_location_EV_of_ChangedAt,
                a.PR_content_ST_location_EV_of_PositedAt,
                a.PR_content_ST_location_EV_of_Confidence,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_content_ST_location_EV_of_ID
                    ORDER BY
                        a.PR_content_ST_location_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_content_ST_location_EV_of_Fact p
            JOIN
                ties.PR_content_ST_location_EV_of_Meta a
            ON
                a.PR_content_ST_location_EV_of_ID = p.PR_content_ST_location_EV_of_ID
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
