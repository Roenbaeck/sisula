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
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_rollsattes_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_Reliability,
            EV_in_AC_rollsattes_Assertion
        FROM
            ties.EV_in_AC_rollsattes_Annex
        WHERE
            EV_in_AC_rollsattes_PositedAt <= positingTimepoint
    ]';
END rEV_in_AC_rollsattes_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rEV_in_AC_rollsattes (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_ID_in,
            AC_ID_rollsattes,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_Reliability,
            EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                a.Metadata_EV_in_AC_rollsattes,
                p.EV_in_AC_rollsattes_ID,
                p.EV_ID_in,
                p.AC_ID_rollsattes,
                a.EV_in_AC_rollsattes_PositedAt,
                a.EV_in_AC_rollsattes_Positor,
                a.EV_in_AC_rollsattes_Reliability,
                a.EV_in_AC_rollsattes_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_rollsattes_ID,
                        a.EV_in_AC_rollsattes_Positor
                    ORDER BY
                        a.EV_in_AC_rollsattes_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_rollsattes_Posit p
            JOIN
                ties.EV_in_AC_rollsattes_Annex a
            ON
                a.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
            AND
                a.EV_in_AC_rollsattes_Positor = COALESCE(positor, a.EV_in_AC_rollsattes_Positor)
            WHERE
                a.EV_in_AC_rollsattes_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rEV_in_AC_rollsattes;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fEV_in_AC_rollsattes (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_EV_in_AC_rollsattes,
            EV_in_AC_rollsattes_ID,
            EV_ID_in,
            AC_ID_rollsattes,
            EV_in_AC_rollsattes_PositedAt,
            EV_in_AC_rollsattes_Positor,
            EV_in_AC_rollsattes_Reliability,
            EV_in_AC_rollsattes_Assertion
        FROM (
            SELECT
                a.Metadata_EV_in_AC_rollsattes,
                p.EV_in_AC_rollsattes_ID,
                p.EV_ID_in,
                p.AC_ID_rollsattes,
                a.EV_in_AC_rollsattes_PositedAt,
                a.EV_in_AC_rollsattes_Positor,
                a.EV_in_AC_rollsattes_Reliability,
                a.EV_in_AC_rollsattes_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.EV_in_AC_rollsattes_ID,
                        a.EV_in_AC_rollsattes_Positor
                    ORDER BY
                        a.EV_in_AC_rollsattes_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.EV_in_AC_rollsattes_Posit p
            JOIN
                ties.EV_in_AC_rollsattes_Annex a
            ON
                a.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
            AND
                a.EV_in_AC_rollsattes_Positor = COALESCE(positor, a.EV_in_AC_rollsattes_Positor)
            WHERE
                a.EV_in_AC_rollsattes_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fEV_in_AC_rollsattes;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_deltar_PR_in_RAT_fick_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit
        WHERE
            AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
    ]';
END rAC_deltar_PR_in_RAT_fick_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_deltar_PR_in_RAT_fick_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Posit
        WHERE
            AC_deltar_PR_in_RAT_fick_ChangedAt > changingTimepoint
    ]';
END fAC_deltar_PR_in_RAT_fick_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_deltar_PR_in_RAT_fick_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_Reliability,
            AC_deltar_PR_in_RAT_fick_Assertion
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Annex
        WHERE
            AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint
    ]';
END rAC_deltar_PR_in_RAT_fick_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_deltar_PR_in_RAT_fick (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_Reliability,
            AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                a.Metadata_AC_deltar_PR_in_RAT_fick,
                p.AC_deltar_PR_in_RAT_fick_ID,
                p.AC_ID_deltar,
                p.PR_ID_in,
                p.RAT_ID_fick,
                p.AC_deltar_PR_in_RAT_fick_ChangedAt,
                a.AC_deltar_PR_in_RAT_fick_PositedAt,
                a.AC_deltar_PR_in_RAT_fick_Positor,
                a.AC_deltar_PR_in_RAT_fick_Reliability,
                a.AC_deltar_PR_in_RAT_fick_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_deltar_PR_in_RAT_fick_ID,
                        a.AC_deltar_PR_in_RAT_fick_Positor
                    ORDER BY
                        a.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_deltar_PR_in_RAT_fick_Posit p
            JOIN
                ties.AC_deltar_PR_in_RAT_fick_Annex a
            ON
                a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
            AND
                a.AC_deltar_PR_in_RAT_fick_Positor = COALESCE(positor, a.AC_deltar_PR_in_RAT_fick_Positor)
            WHERE
                p.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
            AND
                a.AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_deltar_PR_in_RAT_fick;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_deltar_PR_in_RAT_fick (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_deltar_PR_in_RAT_fick,
            AC_deltar_PR_in_RAT_fick_ID,
            AC_ID_deltar,
            PR_ID_in,
            RAT_ID_fick,
            AC_deltar_PR_in_RAT_fick_ChangedAt,
            AC_deltar_PR_in_RAT_fick_PositedAt,
            AC_deltar_PR_in_RAT_fick_Positor,
            AC_deltar_PR_in_RAT_fick_Reliability,
            AC_deltar_PR_in_RAT_fick_Assertion
        FROM (
            SELECT
                a.Metadata_AC_deltar_PR_in_RAT_fick,
                p.AC_deltar_PR_in_RAT_fick_ID,
                p.AC_ID_deltar,
                p.PR_ID_in,
                p.RAT_ID_fick,
                p.AC_deltar_PR_in_RAT_fick_ChangedAt,
                a.AC_deltar_PR_in_RAT_fick_PositedAt,
                a.AC_deltar_PR_in_RAT_fick_Positor,
                a.AC_deltar_PR_in_RAT_fick_Reliability,
                a.AC_deltar_PR_in_RAT_fick_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_deltar_PR_in_RAT_fick_ID,
                        a.AC_deltar_PR_in_RAT_fick_Positor
                    ORDER BY
                        a.AC_deltar_PR_in_RAT_fick_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_deltar_PR_in_RAT_fick_Posit p
            JOIN
                ties.AC_deltar_PR_in_RAT_fick_Annex a
            ON
                a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
            AND
                a.AC_deltar_PR_in_RAT_fick_Positor = COALESCE(positor, a.AC_deltar_PR_in_RAT_fick_Positor)
            WHERE
                p.AC_deltar_PR_in_RAT_fick_ChangedAt > changingTimepoint
            AND
                a.AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_deltar_PR_in_RAT_fick;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_spelas_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt
        FROM
            ties.ST_at_PR_spelas_Posit
        WHERE
            ST_at_PR_spelas_ChangedAt <= changingTimepoint
    ]';
END rST_at_PR_spelas_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_spelas_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt
        FROM
            ties.ST_at_PR_spelas_Posit
        WHERE
            ST_at_PR_spelas_ChangedAt > changingTimepoint
    ]';
END fST_at_PR_spelas_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_spelas_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_Reliability,
            ST_at_PR_spelas_Assertion
        FROM
            ties.ST_at_PR_spelas_Annex
        WHERE
            ST_at_PR_spelas_PositedAt <= positingTimepoint
    ]';
END rST_at_PR_spelas_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rST_at_PR_spelas (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_Reliability,
            ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                a.Metadata_ST_at_PR_spelas,
                p.ST_at_PR_spelas_ID,
                p.ST_ID_at,
                p.PR_ID_spelas,
                p.ST_at_PR_spelas_ChangedAt,
                a.ST_at_PR_spelas_PositedAt,
                a.ST_at_PR_spelas_Positor,
                a.ST_at_PR_spelas_Reliability,
                a.ST_at_PR_spelas_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_spelas_ID,
                        a.ST_at_PR_spelas_Positor
                    ORDER BY
                        a.ST_at_PR_spelas_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_spelas_Posit p
            JOIN
                ties.ST_at_PR_spelas_Annex a
            ON
                a.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
            AND
                a.ST_at_PR_spelas_Positor = COALESCE(positor, a.ST_at_PR_spelas_Positor)
            WHERE
                p.ST_at_PR_spelas_ChangedAt <= changingTimepoint
            AND
                a.ST_at_PR_spelas_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rST_at_PR_spelas;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fST_at_PR_spelas (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_ST_at_PR_spelas,
            ST_at_PR_spelas_ID,
            ST_ID_at,
            PR_ID_spelas,
            ST_at_PR_spelas_ChangedAt,
            ST_at_PR_spelas_PositedAt,
            ST_at_PR_spelas_Positor,
            ST_at_PR_spelas_Reliability,
            ST_at_PR_spelas_Assertion
        FROM (
            SELECT
                a.Metadata_ST_at_PR_spelas,
                p.ST_at_PR_spelas_ID,
                p.ST_ID_at,
                p.PR_ID_spelas,
                p.ST_at_PR_spelas_ChangedAt,
                a.ST_at_PR_spelas_PositedAt,
                a.ST_at_PR_spelas_Positor,
                a.ST_at_PR_spelas_Reliability,
                a.ST_at_PR_spelas_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.ST_at_PR_spelas_ID,
                        a.ST_at_PR_spelas_Positor
                    ORDER BY
                        a.ST_at_PR_spelas_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.ST_at_PR_spelas_Posit p
            JOIN
                ties.ST_at_PR_spelas_Annex a
            ON
                a.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
            AND
                a.ST_at_PR_spelas_Positor = COALESCE(positor, a.ST_at_PR_spelas_Positor)
            WHERE
                p.ST_at_PR_spelas_ChangedAt > changingTimepoint
            AND
                a.ST_at_PR_spelas_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fST_at_PR_spelas;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_förälder_AC_barn_PAT_har_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_Reliability,
            AC_förälder_AC_barn_PAT_har_Assertion
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Annex
        WHERE
            AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint
    ]';
END rAC_förälder_AC_barn_PAT_har_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rAC_förälder_AC_barn_PAT_har (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_ID_förälder,
            AC_ID_barn,
            PAT_ID_har,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_Reliability,
            AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                a.Metadata_AC_förälder_AC_barn_PAT_har,
                p.AC_förälder_AC_barn_PAT_har_ID,
                p.AC_ID_förälder,
                p.AC_ID_barn,
                p.PAT_ID_har,
                a.AC_förälder_AC_barn_PAT_har_PositedAt,
                a.AC_förälder_AC_barn_PAT_har_Positor,
                a.AC_förälder_AC_barn_PAT_har_Reliability,
                a.AC_förälder_AC_barn_PAT_har_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_förälder_AC_barn_PAT_har_ID,
                        a.AC_förälder_AC_barn_PAT_har_Positor
                    ORDER BY
                        a.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_förälder_AC_barn_PAT_har_Posit p
            JOIN
                ties.AC_förälder_AC_barn_PAT_har_Annex a
            ON
                a.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
            AND
                a.AC_förälder_AC_barn_PAT_har_Positor = COALESCE(positor, a.AC_förälder_AC_barn_PAT_har_Positor)
            WHERE
                a.AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rAC_förälder_AC_barn_PAT_har;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fAC_förälder_AC_barn_PAT_har (
    positor IN number,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_AC_förälder_AC_barn_PAT_har,
            AC_förälder_AC_barn_PAT_har_ID,
            AC_ID_förälder,
            AC_ID_barn,
            PAT_ID_har,
            AC_förälder_AC_barn_PAT_har_PositedAt,
            AC_förälder_AC_barn_PAT_har_Positor,
            AC_förälder_AC_barn_PAT_har_Reliability,
            AC_förälder_AC_barn_PAT_har_Assertion
        FROM (
            SELECT
                a.Metadata_AC_förälder_AC_barn_PAT_har,
                p.AC_förälder_AC_barn_PAT_har_ID,
                p.AC_ID_förälder,
                p.AC_ID_barn,
                p.PAT_ID_har,
                a.AC_förälder_AC_barn_PAT_har_PositedAt,
                a.AC_förälder_AC_barn_PAT_har_Positor,
                a.AC_förälder_AC_barn_PAT_har_Reliability,
                a.AC_förälder_AC_barn_PAT_har_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.AC_förälder_AC_barn_PAT_har_ID,
                        a.AC_förälder_AC_barn_PAT_har_Positor
                    ORDER BY
                        a.AC_förälder_AC_barn_PAT_har_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.AC_förälder_AC_barn_PAT_har_Posit p
            JOIN
                ties.AC_förälder_AC_barn_PAT_har_Annex a
            ON
                a.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
            AND
                a.AC_förälder_AC_barn_PAT_har_Positor = COALESCE(positor, a.AC_förälder_AC_barn_PAT_har_Positor)
            WHERE
                a.AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fAC_förälder_AC_barn_PAT_har;
/
-- Tie posit rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_innehåll_ST_plats_EV_of_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Posit
        WHERE
            PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
    ]';
END rPR_innehåll_ST_plats_EV_of_Posit;
/
-- Tie posit forwarder ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_innehåll_ST_plats_EV_of_Posit (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Posit
        WHERE
            PR_innehåll_ST_plats_EV_of_ChangedAt > changingTimepoint
    ]';
END fPR_innehåll_ST_plats_EV_of_Posit;
/
-- Tie annex rewinder -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_innehåll_ST_plats_EV_of_Annex (
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_Reliability,
            PR_innehåll_ST_plats_EV_of_Assertion
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Annex
        WHERE
            PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint
    ]';
END rPR_innehåll_ST_plats_EV_of_Annex;
/
-- Tie assembled rewinder ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.rPR_innehåll_ST_plats_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_Reliability,
            PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                a.Metadata_PR_innehåll_ST_plats_EV_of,
                p.PR_innehåll_ST_plats_EV_of_ID,
                p.PR_ID_innehåll,
                p.ST_ID_plats,
                p.EV_ID_of,
                p.PR_innehåll_ST_plats_EV_of_ChangedAt,
                a.PR_innehåll_ST_plats_EV_of_PositedAt,
                a.PR_innehåll_ST_plats_EV_of_Positor,
                a.PR_innehåll_ST_plats_EV_of_Reliability,
                a.PR_innehåll_ST_plats_EV_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_innehåll_ST_plats_EV_of_ID,
                        a.PR_innehåll_ST_plats_EV_of_Positor
                    ORDER BY
                        a.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_innehåll_ST_plats_EV_of_Posit p
            JOIN
                ties.PR_innehåll_ST_plats_EV_of_Annex a
            ON
                a.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
            AND
                a.PR_innehåll_ST_plats_EV_of_Positor = COALESCE(positor, a.PR_innehåll_ST_plats_EV_of_Positor)
            WHERE
                p.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
            AND
                a.PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END rPR_innehåll_ST_plats_EV_of;
/
-- Tie assembled forwarder --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.fPR_innehåll_ST_plats_EV_of (
    positor IN number,
    changingTimepoint IN timestamp,
    positingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            Metadata_PR_innehåll_ST_plats_EV_of,
            PR_innehåll_ST_plats_EV_of_ID,
            PR_ID_innehåll,
            ST_ID_plats,
            EV_ID_of,
            PR_innehåll_ST_plats_EV_of_ChangedAt,
            PR_innehåll_ST_plats_EV_of_PositedAt,
            PR_innehåll_ST_plats_EV_of_Positor,
            PR_innehåll_ST_plats_EV_of_Reliability,
            PR_innehåll_ST_plats_EV_of_Assertion
        FROM (
            SELECT
                a.Metadata_PR_innehåll_ST_plats_EV_of,
                p.PR_innehåll_ST_plats_EV_of_ID,
                p.PR_ID_innehåll,
                p.ST_ID_plats,
                p.EV_ID_of,
                p.PR_innehåll_ST_plats_EV_of_ChangedAt,
                a.PR_innehåll_ST_plats_EV_of_PositedAt,
                a.PR_innehåll_ST_plats_EV_of_Positor,
                a.PR_innehåll_ST_plats_EV_of_Reliability,
                a.PR_innehåll_ST_plats_EV_of_Assertion,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        p.PR_innehåll_ST_plats_EV_of_ID,
                        a.PR_innehåll_ST_plats_EV_of_Positor
                    ORDER BY
                        a.PR_innehåll_ST_plats_EV_of_PositedAt DESC
                ) AS rowNumber
            FROM
                ties.PR_innehåll_ST_plats_EV_of_Posit p
            JOIN
                ties.PR_innehåll_ST_plats_EV_of_Annex a
            ON
                a.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
            AND
                a.PR_innehåll_ST_plats_EV_of_Positor = COALESCE(positor, a.PR_innehåll_ST_plats_EV_of_Positor)
            WHERE
                p.PR_innehåll_ST_plats_EV_of_ChangedAt > changingTimepoint
            AND
                a.PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint
        )
        WHERE
            rowNumber = 1
    ]';
END fPR_innehåll_ST_plats_EV_of;
/
