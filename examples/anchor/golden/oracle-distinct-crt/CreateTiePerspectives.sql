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
    kONG_currently.ONG_Ongoing AS currently_ONG_Ongoing,
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
    knots.ONG_Ongoing kONG_currently
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
CREATE OR REPLACE VIEW ties.lEV_in_AC_wasCast AS
SELECT
    r.EV_in_AC_wasCast_ID,
    r.Metadata_EV_in_AC_wasCast,
    r.EV_ID_in,
    r.AC_ID_wasCast
    r.EV_in_AC_wasCast_PositedAt,
    r.EV_in_AC_wasCast_Positor,
    r.EV_in_AC_wasCast_Reliability,
    r.EV_in_AC_wasCast_Assertion,
    r.
FROM
    ties.rEV_in_AC_wasCast r
;

CREATE OR REPLACE VIEW ties.nEV_in_AC_wasCast AS
SELECT
    *
FROM
    ties.lEV_in_AC_wasCast
;

CREATE OR REPLACE FUNCTION ties.tEV_in_AC_wasCast (
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
            ties.lEV_in_AC_wasCast t
        WHERE
            (positor IS NULL OR t.EV_in_AC_wasCast_Positor = positor)
        AND
            (assertion IS NULL OR t.EV_in_AC_wasCast_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.EV_in_AC_wasCast_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pEV_in_AC_wasCast (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lEV_in_AC_wasCast t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dEV_in_AC_wasCast (
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
            ties.lEV_in_AC_wasCast t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_part_PR_in_RAT_got AS
SELECT
    r.AC_part_PR_in_RAT_got_ID,
    r.Metadata_AC_part_PR_in_RAT_got,
    r.AC_ID_part,
    r.PR_ID_in,
    kRAT_got.RAT_Rating AS got_RAT_Rating,
    r.RAT_ID_got
    r.AC_part_PR_in_RAT_got_ChangedAt,
    r.AC_part_PR_in_RAT_got_PositedAt,
    r.AC_part_PR_in_RAT_got_Positor,
    r.AC_part_PR_in_RAT_got_Reliability,
    r.AC_part_PR_in_RAT_got_Assertion,
    r.
FROM
    ties.rAC_part_PR_in_RAT_got r
LEFT JOIN
    knots.RAT_Rating kRAT_got
ON
    kRAT_got.RAT_ID = r.RAT_ID_got
;

CREATE OR REPLACE VIEW ties.nAC_part_PR_in_RAT_got AS
SELECT
    *
FROM
    ties.lAC_part_PR_in_RAT_got
;

CREATE OR REPLACE FUNCTION ties.tAC_part_PR_in_RAT_got (
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
            ties.lAC_part_PR_in_RAT_got t
        WHERE
            (positor IS NULL OR t.AC_part_PR_in_RAT_got_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_part_PR_in_RAT_got_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_part_PR_in_RAT_got (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_part_PR_in_RAT_got t
        WHERE
            (changingTimepoint IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_part_PR_in_RAT_got (
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
            ties.lAC_part_PR_in_RAT_got t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lST_at_PR_isPlaying AS
SELECT
    r.ST_at_PR_isPlaying_ID,
    r.Metadata_ST_at_PR_isPlaying,
    r.ST_ID_at,
    r.PR_ID_isPlaying
    r.ST_at_PR_isPlaying_ChangedAt,
    r.ST_at_PR_isPlaying_PositedAt,
    r.ST_at_PR_isPlaying_Positor,
    r.ST_at_PR_isPlaying_Reliability,
    r.ST_at_PR_isPlaying_Assertion,
    r.
FROM
    ties.rST_at_PR_isPlaying r
;

CREATE OR REPLACE VIEW ties.nST_at_PR_isPlaying AS
SELECT
    *
FROM
    ties.lST_at_PR_isPlaying
;

CREATE OR REPLACE FUNCTION ties.tST_at_PR_isPlaying (
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
            ties.lST_at_PR_isPlaying t
        WHERE
            (positor IS NULL OR t.ST_at_PR_isPlaying_Positor = positor)
        AND
            (assertion IS NULL OR t.ST_at_PR_isPlaying_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.ST_at_PR_isPlaying_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pST_at_PR_isPlaying (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lST_at_PR_isPlaying t
        WHERE
            (changingTimepoint IS NULL OR t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dST_at_PR_isPlaying (
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
            ties.lST_at_PR_isPlaying t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lAC_parent_AC_child_PAT_having AS
SELECT
    r.AC_parent_AC_child_PAT_having_ID,
    r.Metadata_AC_parent_AC_child_PAT_having,
    r.AC_ID_parent,
    r.AC_ID_child,
    kPAT_having.PAT_ParentalType AS having_PAT_ParentalType,
    r.PAT_ID_having
    r.AC_parent_AC_child_PAT_having_PositedAt,
    r.AC_parent_AC_child_PAT_having_Positor,
    r.AC_parent_AC_child_PAT_having_Reliability,
    r.AC_parent_AC_child_PAT_having_Assertion,
    r.
FROM
    ties.rAC_parent_AC_child_PAT_having r
LEFT JOIN
    knots.PAT_ParentalType kPAT_having
ON
    kPAT_having.PAT_ID = r.PAT_ID_having
;

CREATE OR REPLACE VIEW ties.nAC_parent_AC_child_PAT_having AS
SELECT
    *
FROM
    ties.lAC_parent_AC_child_PAT_having
;

CREATE OR REPLACE FUNCTION ties.tAC_parent_AC_child_PAT_having (
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
            ties.lAC_parent_AC_child_PAT_having t
        WHERE
            (positor IS NULL OR t.AC_parent_AC_child_PAT_having_Positor = positor)
        AND
            (assertion IS NULL OR t.AC_parent_AC_child_PAT_having_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR 1 = 1)
        AND
            (positingTimepoint IS NULL OR t.AC_parent_AC_child_PAT_having_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pAC_parent_AC_child_PAT_having (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lAC_parent_AC_child_PAT_having t
        WHERE
            (changingTimepoint IS NULL OR 1 = 1)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dAC_parent_AC_child_PAT_having (
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
            ties.lAC_parent_AC_child_PAT_having t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR 1 = 1)
    ]';
END;
/
CREATE OR REPLACE VIEW ties.lPR_content_ST_location_EV_of AS
SELECT
    r.PR_content_ST_location_EV_of_ID,
    r.Metadata_PR_content_ST_location_EV_of,
    r.PR_ID_content,
    r.ST_ID_location,
    r.EV_ID_of
    r.PR_content_ST_location_EV_of_ChangedAt,
    r.PR_content_ST_location_EV_of_PositedAt,
    r.PR_content_ST_location_EV_of_Positor,
    r.PR_content_ST_location_EV_of_Reliability,
    r.PR_content_ST_location_EV_of_Assertion,
    r.
FROM
    ties.rPR_content_ST_location_EV_of r
;

CREATE OR REPLACE VIEW ties.nPR_content_ST_location_EV_of AS
SELECT
    *
FROM
    ties.lPR_content_ST_location_EV_of
;

CREATE OR REPLACE FUNCTION ties.tPR_content_ST_location_EV_of (
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
            ties.lPR_content_ST_location_EV_of t
        WHERE
            (positor IS NULL OR t.PR_content_ST_location_EV_of_Positor = positor)
        AND
            (assertion IS NULL OR t.PR_content_ST_location_EV_of_Assertion = assertion)
        AND
            (changingTimepoint IS NULL OR t.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
        AND
            (positingTimepoint IS NULL OR t.PR_content_ST_location_EV_of_PositedAt <= positingTimepoint)
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.pPR_content_ST_location_EV_of (
    changingTimepoint timestamp(9)
)
RETURN varchar2 SQL_MACRO(TABLE)
IS
BEGIN
    RETURN q'[
        SELECT
            t.*
        FROM
            ties.lPR_content_ST_location_EV_of t
        WHERE
            (changingTimepoint IS NULL OR t.PR_content_ST_location_EV_of_ChangedAt <= changingTimepoint
    ]';
END;
/

CREATE OR REPLACE FUNCTION ties.dPR_content_ST_location_EV_of (
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
            ties.lPR_content_ST_location_EV_of t
        WHERE
            (intervalStart IS NULL OR intervalEnd IS NULL OR t.PR_content_ST_location_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END;
/
