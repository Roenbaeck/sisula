-- TIE CRT PERSPECTIVES -----------------------------------------------------------------------------------------------
--
-- Oracle-compatible latest and now perspectives for CRT ties.
--
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently AS
SELECT
    r.AC_partner_AC_with_ONG_currently_ID,
    r.Metadata_AC_partner_AC_with_ONG_currently,
    r.AC_ID_partner,
    r.AC_ID_with,
    kONG_currently.ONG_Pågående AS currently_ONG_Pågående,
    r.ONG_ID_currently
    r.AC_partner_AC_with_ONG_currently_ChangedAt,
    r.AC_partner_AC_with_ONG_currently_PositedAt,
    r.AC_partner_AC_with_ONG_currently_Positor,
    r.AC_partner_AC_with_ONG_currently_Reliability,
    r.AC_partner_AC_with_ONG_currently_Assertion,
    r.
FROM
    ties.rAC_partner_AC_with_ONG_currently r
LEFT JOIN
    knots.ONG_Pågående kONG_currently
ON
    kONG_currently.ONG_ID = r.ONG_ID_currently
;

CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    ties.lAC_partner_AC_with_ONG_currently
;

CREATE OR REPLACE FUNCTION ties.tAC_partner_AC_with_ONG_currently (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (positor IS NULL OR t.AC_partner_AC_with_ONG_currently_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_partner_AC_with_ONG_currently_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (changingTimepoint IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_partner_AC_with_ONG_currently t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of AS
SELECT
    r.AC_subset_PN_of_ID,
    r.Metadata_AC_subset_PN_of,
    r.AC_ID_subset,
    r.PN_ID_of
    r.AC_subset_PN_of_PositedAt,
    r.AC_subset_PN_of_Positor,
    r.AC_subset_PN_of_Reliability,
    r.AC_subset_PN_of_Assertion,
    r.
FROM
    ties.rAC_subset_PN_of r
;

CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    *
FROM
    ties.lAC_subset_PN_of
;

CREATE OR REPLACE FUNCTION ties.tAC_subset_PN_of (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (positor IS NULL OR t.AC_subset_PN_of_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_subset_PN_of_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_subset_PN_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_subset_PN_of (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_subset_PN_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lEV_in_AC_rollsattes AS
SELECT
    r.EV_in_AC_rollsattes_ID,
    r.Metadata_EV_in_AC_rollsattes,
    r.EV_ID_in,
    r.AC_ID_rollsattes
    r.EV_in_AC_rollsattes_PositedAt,
    r.EV_in_AC_rollsattes_Positor,
    r.EV_in_AC_rollsattes_Reliability,
    r.EV_in_AC_rollsattes_Assertion,
    r.
FROM
    ties.rEV_in_AC_rollsattes r
;

CREATE OR REPLACE VIEW ties.nEV_in_AC_rollsattes AS
SELECT
    *
FROM
    ties.lEV_in_AC_rollsattes
;

CREATE OR REPLACE FUNCTION ties.tEV_in_AC_rollsattes (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_rollsattes t
        WHERE
            (positor IS NULL OR t.EV_in_AC_rollsattes_Positor = positor)
        AND
            (assertion IS NULL OR t.EV_in_AC_rollsattes_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.EV_in_AC_rollsattes_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pEV_in_AC_rollsattes (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_rollsattes t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dEV_in_AC_rollsattes (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_rollsattes t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_deltar_PR_in_RAT_fick AS
SELECT
    r.AC_deltar_PR_in_RAT_fick_ID,
    r.Metadata_AC_deltar_PR_in_RAT_fick,
    r.AC_ID_deltar,
    r.PR_ID_in,
    kRAT_fick.RAT_Betyg AS fick_RAT_Betyg,
    r.RAT_ID_fick
    r.AC_deltar_PR_in_RAT_fick_ChangedAt,
    r.AC_deltar_PR_in_RAT_fick_PositedAt,
    r.AC_deltar_PR_in_RAT_fick_Positor,
    r.AC_deltar_PR_in_RAT_fick_Reliability,
    r.AC_deltar_PR_in_RAT_fick_Assertion,
    r.
FROM
    ties.rAC_deltar_PR_in_RAT_fick r
LEFT JOIN
    knots.RAT_Betyg kRAT_fick
ON
    kRAT_fick.RAT_ID = r.RAT_ID_fick
;

CREATE OR REPLACE VIEW ties.nAC_deltar_PR_in_RAT_fick AS
SELECT
    *
FROM
    ties.lAC_deltar_PR_in_RAT_fick
;

CREATE OR REPLACE FUNCTION ties.tAC_deltar_PR_in_RAT_fick (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_deltar_PR_in_RAT_fick t
        WHERE
            (positor IS NULL OR t.AC_deltar_PR_in_RAT_fick_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_deltar_PR_in_RAT_fick_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_deltar_PR_in_RAT_fick_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_deltar_PR_in_RAT_fick (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_deltar_PR_in_RAT_fick t
        WHERE
            (changingTimepoint IS NULL OR t.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_deltar_PR_in_RAT_fick (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_deltar_PR_in_RAT_fick t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_deltar_PR_in_RAT_fick_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lST_at_PR_spelas AS
SELECT
    r.ST_at_PR_spelas_ID,
    r.Metadata_ST_at_PR_spelas,
    r.ST_ID_at,
    r.PR_ID_spelas
    r.ST_at_PR_spelas_ChangedAt,
    r.ST_at_PR_spelas_PositedAt,
    r.ST_at_PR_spelas_Positor,
    r.ST_at_PR_spelas_Reliability,
    r.ST_at_PR_spelas_Assertion,
    r.
FROM
    ties.rST_at_PR_spelas r
;

CREATE OR REPLACE VIEW ties.nST_at_PR_spelas AS
SELECT
    *
FROM
    ties.lST_at_PR_spelas
;

CREATE OR REPLACE FUNCTION ties.tST_at_PR_spelas (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_spelas t
        WHERE
            (positor IS NULL OR t.ST_at_PR_spelas_Positor = positor)
        AND
            (assertion IS NULL OR t.ST_at_PR_spelas_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.ST_at_PR_spelas_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.ST_at_PR_spelas_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pST_at_PR_spelas (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_spelas t
        WHERE
            (changingTimepoint IS NULL OR t.ST_at_PR_spelas_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dST_at_PR_spelas (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_spelas t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.ST_at_PR_spelas_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_förälder_AC_barn_PAT_har AS
SELECT
    r.AC_förälder_AC_barn_PAT_har_ID,
    r.Metadata_AC_förälder_AC_barn_PAT_har,
    r.AC_ID_förälder,
    r.AC_ID_barn,
    kPAT_har.PAT_Föräldratyp AS har_PAT_Föräldratyp,
    r.PAT_ID_har
    r.AC_förälder_AC_barn_PAT_har_PositedAt,
    r.AC_förälder_AC_barn_PAT_har_Positor,
    r.AC_förälder_AC_barn_PAT_har_Reliability,
    r.AC_förälder_AC_barn_PAT_har_Assertion,
    r.
FROM
    ties.rAC_förälder_AC_barn_PAT_har r
LEFT JOIN
    knots.PAT_Föräldratyp kPAT_har
ON
    kPAT_har.PAT_ID = r.PAT_ID_har
;

CREATE OR REPLACE VIEW ties.nAC_förälder_AC_barn_PAT_har AS
SELECT
    *
FROM
    ties.lAC_förälder_AC_barn_PAT_har
;

CREATE OR REPLACE FUNCTION ties.tAC_förälder_AC_barn_PAT_har (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_förälder_AC_barn_PAT_har t
        WHERE
            (positor IS NULL OR t.AC_förälder_AC_barn_PAT_har_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_förälder_AC_barn_PAT_har_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_förälder_AC_barn_PAT_har_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_förälder_AC_barn_PAT_har (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_förälder_AC_barn_PAT_har t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_förälder_AC_barn_PAT_har (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_förälder_AC_barn_PAT_har t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lPR_innehåll_ST_plats_EV_of AS
SELECT
    r.PR_innehåll_ST_plats_EV_of_ID,
    r.Metadata_PR_innehåll_ST_plats_EV_of,
    r.PR_ID_innehåll,
    r.ST_ID_plats,
    r.EV_ID_of
    r.PR_innehåll_ST_plats_EV_of_ChangedAt,
    r.PR_innehåll_ST_plats_EV_of_PositedAt,
    r.PR_innehåll_ST_plats_EV_of_Positor,
    r.PR_innehåll_ST_plats_EV_of_Reliability,
    r.PR_innehåll_ST_plats_EV_of_Assertion,
    r.
FROM
    ties.rPR_innehåll_ST_plats_EV_of r
;

CREATE OR REPLACE VIEW ties.nPR_innehåll_ST_plats_EV_of AS
SELECT
    *
FROM
    ties.lPR_innehåll_ST_plats_EV_of
;

CREATE OR REPLACE FUNCTION ties.tPR_innehåll_ST_plats_EV_of (
    positor number(3),
    changingTimepoint timestamp(9),
    positingTimepoint timestamp,
    assertion varchar2(4000)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_innehåll_ST_plats_EV_of t
        WHERE
            (positor IS NULL OR t.PR_innehåll_ST_plats_EV_of_Positor = positor)
        AND
            (assertion IS NULL OR t.PR_innehåll_ST_plats_EV_of_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.PR_innehåll_ST_plats_EV_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pPR_innehåll_ST_plats_EV_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_innehåll_ST_plats_EV_of t
        WHERE
            (changingTimepoint IS NULL OR t.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dPR_innehåll_ST_plats_EV_of (
    intervalStart timestamp(9),
    intervalEnd timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_innehåll_ST_plats_EV_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.PR_innehåll_ST_plats_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
