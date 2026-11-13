-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- The point-in-time and difference perspectives are SQL table macros (SQL_MACRO, Oracle Database 19.7 or later): a function
-- that returns the text of a query, in which its parameters stand for the values given. They are called in the FROM clause
-- of a query, like a table: SELECT * FROM pAC_part_EV_in(TIMESTAMP '2020-01-01 00:00:00').
--
-- A historized tie shows, for each identifier (for each anchor, in a tie without identifiers), the rows that have the latest
-- changing time: that is worked out with an analytic MAX in an inline view, whose column holds the latest time.
--
-- A table alias is written inside double quotes where it can be a word that Oracle reserves.
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_partner_AC_with_ONG_currently (
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner,
    AC_ID_with,
    currently_ONG_Ongoing,
    currently_Metadata_ONG,
    ONG_ID_currently
)
AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    "ONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
    "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
        FROM
            AC_partner_AC_with_ONG_currently t
    ) tie
LEFT JOIN
    ONG_Ongoing "ONG_currently"
ON
    "ONG_currently".ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
AND
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_partner_AC_with_ONG_currently (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_partner_AC_with_ONG_currently,
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
                FROM
                    AC_partner_AC_with_ONG_currently t
                WHERE
                    t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            ONG_Ongoing "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
        AND
            tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
    ]';
END pAC_partner_AC_with_ONG_currently;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_partner_AC_with_ONG_currently (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_partner_AC_with_ONG_currently,
            tie.AC_partner_AC_with_ONG_currently_ChangedAt,
            tie.AC_ID_partner,
            tie.AC_ID_with,
            "ONG_currently".ONG_Ongoing AS currently_ONG_Ongoing,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            AC_partner_AC_with_ONG_currently tie
        LEFT JOIN
            ONG_Ongoing "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_subset_PN_of (
    Metadata_AC_subset_PN_of,
    AC_ID_subset,
    PN_ID_of
)
AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_subset_PN_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_subset_PN_of,
            tie.AC_ID_subset,
            tie.PN_ID_of
        FROM
            AC_subset_PN_of tie
    ]';
END pAC_subset_PN_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_subset_PN_of
AS
SELECT
    *
FROM
    pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lEV_in_AC_wasCast (
    Metadata_EV_in_AC_wasCast,
    EV_ID_in,
    AC_ID_wasCast
)
AS
SELECT
    tie.Metadata_EV_in_AC_wasCast,
    tie.EV_ID_in,
    tie.AC_ID_wasCast
FROM
    EV_in_AC_wasCast tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pEV_in_AC_wasCast (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_EV_in_AC_wasCast,
            tie.EV_ID_in,
            tie.AC_ID_wasCast
        FROM
            EV_in_AC_wasCast tie
    ]';
END pEV_in_AC_wasCast;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nEV_in_AC_wasCast
AS
SELECT
    *
FROM
    pEV_in_AC_wasCast(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_part_PR_in_RAT_got (
    Metadata_AC_part_PR_in_RAT_got,
    AC_part_PR_in_RAT_got_ChangedAt,
    AC_ID_part,
    PR_ID_in,
    got_RAT_Rating,
    got_Metadata_RAT,
    RAT_ID_got
)
AS
SELECT
    tie.Metadata_AC_part_PR_in_RAT_got,
    tie.AC_part_PR_in_RAT_got_ChangedAt,
    tie.AC_ID_part,
    tie.PR_ID_in,
    "RAT_got".RAT_Rating AS got_RAT_Rating,
    "RAT_got".Metadata_RAT AS got_Metadata_RAT,
    tie.RAT_ID_got
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_part_PR_in_RAT_got_ChangedAt) OVER (
                PARTITION BY
                    t.AC_ID_part,
                    t.PR_ID_in
            ) AS latestTime
        FROM
            AC_part_PR_in_RAT_got t
    ) tie
LEFT JOIN
    RAT_Rating "RAT_got"
ON
    "RAT_got".RAT_ID = tie.RAT_ID_got
WHERE
    tie.AC_part_PR_in_RAT_got_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_part_PR_in_RAT_got (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_part_PR_in_RAT_got,
            tie.AC_part_PR_in_RAT_got_ChangedAt,
            tie.AC_ID_part,
            tie.PR_ID_in,
            "RAT_got".RAT_Rating AS got_RAT_Rating,
            "RAT_got".Metadata_RAT AS got_Metadata_RAT,
            tie.RAT_ID_got
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_part_PR_in_RAT_got_ChangedAt) OVER (
                        PARTITION BY
                            t.AC_ID_part,
                            t.PR_ID_in
                    ) AS latestTime
                FROM
                    AC_part_PR_in_RAT_got t
                WHERE
                    t.AC_part_PR_in_RAT_got_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            RAT_Rating "RAT_got"
        ON
            "RAT_got".RAT_ID = tie.RAT_ID_got
        WHERE
            tie.AC_part_PR_in_RAT_got_ChangedAt = tie.latestTime
    ]';
END pAC_part_PR_in_RAT_got;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_part_PR_in_RAT_got
AS
SELECT
    *
FROM
    pAC_part_PR_in_RAT_got(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dAC_part_PR_in_RAT_got (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_part_PR_in_RAT_got,
            tie.AC_part_PR_in_RAT_got_ChangedAt,
            tie.AC_ID_part,
            tie.PR_ID_in,
            "RAT_got".RAT_Rating AS got_RAT_Rating,
            "RAT_got".Metadata_RAT AS got_Metadata_RAT,
            tie.RAT_ID_got
        FROM
            AC_part_PR_in_RAT_got tie
        LEFT JOIN
            RAT_Rating "RAT_got"
        ON
            "RAT_got".RAT_ID = tie.RAT_ID_got
        WHERE
            tie.AC_part_PR_in_RAT_got_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_part_PR_in_RAT_got;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lST_at_PR_isPlaying (
    Metadata_ST_at_PR_isPlaying,
    ST_at_PR_isPlaying_ChangedAt,
    ST_ID_at,
    PR_ID_isPlaying
)
AS
SELECT
    tie.Metadata_ST_at_PR_isPlaying,
    tie.ST_at_PR_isPlaying_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_isPlaying
FROM
    (
        SELECT
            t.*,
            MAX(t.ST_at_PR_isPlaying_ChangedAt) OVER (
                PARTITION BY
                    t.ST_ID_at,
                    t.PR_ID_isPlaying
            ) AS latestTime
        FROM
            ST_at_PR_isPlaying t
    ) tie
WHERE
    tie.ST_at_PR_isPlaying_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pST_at_PR_isPlaying (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_ST_at_PR_isPlaying,
            tie.ST_at_PR_isPlaying_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_isPlaying
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.ST_at_PR_isPlaying_ChangedAt) OVER (
                        PARTITION BY
                            t.ST_ID_at,
                            t.PR_ID_isPlaying
                    ) AS latestTime
                FROM
                    ST_at_PR_isPlaying t
                WHERE
                    t.ST_at_PR_isPlaying_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.ST_at_PR_isPlaying_ChangedAt = tie.latestTime
    ]';
END pST_at_PR_isPlaying;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nST_at_PR_isPlaying
AS
SELECT
    *
FROM
    pST_at_PR_isPlaying(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dST_at_PR_isPlaying (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_ST_at_PR_isPlaying,
            tie.ST_at_PR_isPlaying_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_isPlaying
        FROM
            ST_at_PR_isPlaying tie
        WHERE
            tie.ST_at_PR_isPlaying_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_isPlaying;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lAC_parent_AC_child_PAT_having (
    Metadata_AC_parent_AC_child_PAT_having,
    AC_ID_parent,
    AC_ID_child,
    having_PAT_ParentalType,
    having_Metadata_PAT,
    PAT_ID_having
)
AS
SELECT
    tie.Metadata_AC_parent_AC_child_PAT_having,
    tie.AC_ID_parent,
    tie.AC_ID_child,
    "PAT_having".PAT_ParentalType AS having_PAT_ParentalType,
    "PAT_having".Metadata_PAT AS having_Metadata_PAT,
    tie.PAT_ID_having
FROM
    AC_parent_AC_child_PAT_having tie
LEFT JOIN
    PAT_ParentalType "PAT_having"
ON
    "PAT_having".PAT_ID = tie.PAT_ID_having
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pAC_parent_AC_child_PAT_having (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_parent_AC_child_PAT_having,
            tie.AC_ID_parent,
            tie.AC_ID_child,
            "PAT_having".PAT_ParentalType AS having_PAT_ParentalType,
            "PAT_having".Metadata_PAT AS having_Metadata_PAT,
            tie.PAT_ID_having
        FROM
            AC_parent_AC_child_PAT_having tie
        LEFT JOIN
            PAT_ParentalType "PAT_having"
        ON
            "PAT_having".PAT_ID = tie.PAT_ID_having
    ]';
END pAC_parent_AC_child_PAT_having;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nAC_parent_AC_child_PAT_having
AS
SELECT
    *
FROM
    pAC_parent_AC_child_PAT_having(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lPR_content_ST_location_EV_of (
    Metadata_PR_content_ST_location_EV_of,
    PR_ID_content,
    ST_ID_location,
    EV_ID_of
)
AS
SELECT
    tie.Metadata_PR_content_ST_location_EV_of,
    tie.PR_ID_content,
    tie.ST_ID_location,
    tie.EV_ID_of
FROM
    PR_content_ST_location_EV_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pPR_content_ST_location_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_PR_content_ST_location_EV_of,
            tie.PR_ID_content,
            tie.ST_ID_location,
            tie.EV_ID_of
        FROM
            PR_content_ST_location_EV_of tie
    ]';
END pPR_content_ST_location_EV_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nPR_content_ST_location_EV_of
AS
SELECT
    *
FROM
    pPR_content_ST_location_EV_of(CAST(current_timestamp AS timestamp(9)))
;
