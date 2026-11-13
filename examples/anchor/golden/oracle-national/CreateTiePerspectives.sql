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
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently (
    Metadata_AC_partner_AC_with_ONG_currently,
    AC_partner_AC_with_ONG_currently_ChangedAt,
    AC_ID_partner,
    AC_ID_with,
    currently_ONG_Pågående,
    currently_Metadata_ONG,
    ONG_ID_currently
)
AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    "ONG_currently".ONG_Pågående AS currently_ONG_Pågående,
    "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
            MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
        FROM
            ties.AC_partner_AC_with_ONG_currently t
    ) tie
LEFT JOIN
    knots.ONG_Pågående "ONG_currently"
ON
    "ONG_currently".ONG_ID = tie.ONG_ID_currently
WHERE
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_partner
AND
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = tie.latestAC_ID_with
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_partner_AC_with_ONG_currently (
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
            "ONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_partner) AS latestAC_ID_partner,
                    MAX(t.AC_partner_AC_with_ONG_currently_ChangedAt) OVER (PARTITION BY t.AC_ID_with) AS latestAC_ID_with
                FROM
                    ties.AC_partner_AC_with_ONG_currently t
                WHERE
                    t.AC_partner_AC_with_ONG_currently_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            knots.ONG_Pågående "ONG_currently"
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
CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently
AS
SELECT
    *
FROM
    ties.pAC_partner_AC_with_ONG_currently(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_partner_AC_with_ONG_currently (
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
            "ONG_currently".ONG_Pågående AS currently_ONG_Pågående,
            "ONG_currently".Metadata_ONG AS currently_Metadata_ONG,
            tie.ONG_ID_currently
        FROM
            ties.AC_partner_AC_with_ONG_currently tie
        LEFT JOIN
            knots.ONG_Pågående "ONG_currently"
        ON
            "ONG_currently".ONG_ID = tie.ONG_ID_currently
        WHERE
            tie.AC_partner_AC_with_ONG_currently_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_partner_AC_with_ONG_currently;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of (
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
    ties.AC_subset_PN_of tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_subset_PN_of (
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
            ties.AC_subset_PN_of tie
    ]';
END pAC_subset_PN_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_subset_PN_of
AS
SELECT
    *
FROM
    ties.pAC_subset_PN_of(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lEV_in_AC_rollsattes (
    Metadata_EV_in_AC_rollsattes,
    EV_ID_in,
    AC_ID_rollsattes
)
AS
SELECT
    tie.Metadata_EV_in_AC_rollsattes,
    tie.EV_ID_in,
    tie.AC_ID_rollsattes
FROM
    ties.EV_in_AC_rollsattes tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pEV_in_AC_rollsattes (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_EV_in_AC_rollsattes,
            tie.EV_ID_in,
            tie.AC_ID_rollsattes
        FROM
            ties.EV_in_AC_rollsattes tie
    ]';
END pEV_in_AC_rollsattes;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nEV_in_AC_rollsattes
AS
SELECT
    *
FROM
    ties.pEV_in_AC_rollsattes(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_deltar_PR_in_RAT_fick (
    Metadata_AC_deltar_PR_in_RAT_fick,
    AC_deltar_PR_in_RAT_fick_ChangedAt,
    AC_ID_deltar,
    PR_ID_in,
    fick_RAT_Checksum,
    fick_RAT_Betyg,
    fick_Metadata_RAT,
    RAT_ID_fick
)
AS
SELECT
    tie.Metadata_AC_deltar_PR_in_RAT_fick,
    tie.AC_deltar_PR_in_RAT_fick_ChangedAt,
    tie.AC_ID_deltar,
    tie.PR_ID_in,
    "RAT_fick".RAT_Checksum AS fick_RAT_Checksum,
    "RAT_fick".RAT_Betyg AS fick_RAT_Betyg,
    "RAT_fick".Metadata_RAT AS fick_Metadata_RAT,
    tie.RAT_ID_fick
FROM
    (
        SELECT
            t.*,
            MAX(t.AC_deltar_PR_in_RAT_fick_ChangedAt) OVER (
                PARTITION BY
                    t.AC_ID_deltar,
                    t.PR_ID_in
            ) AS latestTime
        FROM
            ties.AC_deltar_PR_in_RAT_fick t
    ) tie
LEFT JOIN
    knots.RAT_Betyg "RAT_fick"
ON
    "RAT_fick".RAT_ID = tie.RAT_ID_fick
WHERE
    tie.AC_deltar_PR_in_RAT_fick_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_deltar_PR_in_RAT_fick (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_deltar_PR_in_RAT_fick,
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt,
            tie.AC_ID_deltar,
            tie.PR_ID_in,
            "RAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "RAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "RAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            tie.RAT_ID_fick
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.AC_deltar_PR_in_RAT_fick_ChangedAt) OVER (
                        PARTITION BY
                            t.AC_ID_deltar,
                            t.PR_ID_in
                    ) AS latestTime
                FROM
                    ties.AC_deltar_PR_in_RAT_fick t
                WHERE
                    t.AC_deltar_PR_in_RAT_fick_ChangedAt <= changingTimepoint
            ) tie
        LEFT JOIN
            knots.RAT_Betyg "RAT_fick"
        ON
            "RAT_fick".RAT_ID = tie.RAT_ID_fick
        WHERE
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt = tie.latestTime
    ]';
END pAC_deltar_PR_in_RAT_fick;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_deltar_PR_in_RAT_fick
AS
SELECT
    *
FROM
    ties.pAC_deltar_PR_in_RAT_fick(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dAC_deltar_PR_in_RAT_fick (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_deltar_PR_in_RAT_fick,
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt,
            tie.AC_ID_deltar,
            tie.PR_ID_in,
            "RAT_fick".RAT_Checksum AS fick_RAT_Checksum,
            "RAT_fick".RAT_Betyg AS fick_RAT_Betyg,
            "RAT_fick".Metadata_RAT AS fick_Metadata_RAT,
            tie.RAT_ID_fick
        FROM
            ties.AC_deltar_PR_in_RAT_fick tie
        LEFT JOIN
            knots.RAT_Betyg "RAT_fick"
        ON
            "RAT_fick".RAT_ID = tie.RAT_ID_fick
        WHERE
            tie.AC_deltar_PR_in_RAT_fick_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dAC_deltar_PR_in_RAT_fick;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lST_at_PR_spelas (
    Metadata_ST_at_PR_spelas,
    ST_at_PR_spelas_ChangedAt,
    ST_ID_at,
    PR_ID_spelas
)
AS
SELECT
    tie.Metadata_ST_at_PR_spelas,
    tie.ST_at_PR_spelas_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_spelas
FROM
    (
        SELECT
            t.*,
            MAX(t.ST_at_PR_spelas_ChangedAt) OVER (
                PARTITION BY
                    t.ST_ID_at,
                    t.PR_ID_spelas
            ) AS latestTime
        FROM
            ties.ST_at_PR_spelas t
    ) tie
WHERE
    tie.ST_at_PR_spelas_ChangedAt = tie.latestTime
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pST_at_PR_spelas (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_ST_at_PR_spelas,
            tie.ST_at_PR_spelas_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_spelas
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.ST_at_PR_spelas_ChangedAt) OVER (
                        PARTITION BY
                            t.ST_ID_at,
                            t.PR_ID_spelas
                    ) AS latestTime
                FROM
                    ties.ST_at_PR_spelas t
                WHERE
                    t.ST_at_PR_spelas_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.ST_at_PR_spelas_ChangedAt = tie.latestTime
    ]';
END pST_at_PR_spelas;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nST_at_PR_spelas
AS
SELECT
    *
FROM
    ties.pST_at_PR_spelas(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dST_at_PR_spelas (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_ST_at_PR_spelas,
            tie.ST_at_PR_spelas_ChangedAt,
            tie.ST_ID_at,
            tie.PR_ID_spelas
        FROM
            ties.ST_at_PR_spelas tie
        WHERE
            tie.ST_at_PR_spelas_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dST_at_PR_spelas;
/
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lAC_förälder_AC_barn_PAT_har (
    Metadata_AC_förälder_AC_barn_PAT_har,
    AC_ID_förälder,
    AC_ID_barn,
    har_PAT_Föräldratyp,
    har_Metadata_PAT,
    PAT_ID_har
)
AS
SELECT
    tie.Metadata_AC_förälder_AC_barn_PAT_har,
    tie.AC_ID_förälder,
    tie.AC_ID_barn,
    "PAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
    "PAT_har".Metadata_PAT AS har_Metadata_PAT,
    tie.PAT_ID_har
FROM
    ties.AC_förälder_AC_barn_PAT_har tie
LEFT JOIN
    knots.PAT_Föräldratyp "PAT_har"
ON
    "PAT_har".PAT_ID = tie.PAT_ID_har
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pAC_förälder_AC_barn_PAT_har (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_AC_förälder_AC_barn_PAT_har,
            tie.AC_ID_förälder,
            tie.AC_ID_barn,
            "PAT_har".PAT_Föräldratyp AS har_PAT_Föräldratyp,
            "PAT_har".Metadata_PAT AS har_Metadata_PAT,
            tie.PAT_ID_har
        FROM
            ties.AC_förälder_AC_barn_PAT_har tie
        LEFT JOIN
            knots.PAT_Föräldratyp "PAT_har"
        ON
            "PAT_har".PAT_ID = tie.PAT_ID_har
    ]';
END pAC_förälder_AC_barn_PAT_har;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nAC_förälder_AC_barn_PAT_har
AS
SELECT
    *
FROM
    ties.pAC_förälder_AC_barn_PAT_har(CAST(current_timestamp AS timestamp(9)))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.lPR_innehåll_ST_plats_EV_of (
    Metadata_PR_innehåll_ST_plats_EV_of,
    PR_innehåll_ST_plats_EV_of_ChangedAt,
    PR_ID_innehåll,
    ST_ID_plats,
    EV_ID_of
)
AS
SELECT
    tie.Metadata_PR_innehåll_ST_plats_EV_of,
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt,
    tie.PR_ID_innehåll,
    tie.ST_ID_plats,
    tie.EV_ID_of
FROM
    (
        SELECT
            t.*,
            MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.PR_ID_innehåll) AS latestPR_ID_innehåll,
            MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.ST_ID_plats) AS latestST_ID_plats
        FROM
            ties.PR_innehåll_ST_plats_EV_of t
    ) tie
WHERE
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestPR_ID_innehåll
AND
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestST_ID_plats
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.pPR_innehåll_ST_plats_EV_of (
    changingTimepoint IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_PR_innehåll_ST_plats_EV_of,
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt,
            tie.PR_ID_innehåll,
            tie.ST_ID_plats,
            tie.EV_ID_of
        FROM
            (
                SELECT
                    t.*,
                    MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.PR_ID_innehåll) AS latestPR_ID_innehåll,
                    MAX(t.PR_innehåll_ST_plats_EV_of_ChangedAt) OVER (PARTITION BY t.ST_ID_plats) AS latestST_ID_plats
                FROM
                    ties.PR_innehåll_ST_plats_EV_of t
                WHERE
                    t.PR_innehåll_ST_plats_EV_of_ChangedAt <= changingTimepoint
            ) tie
        WHERE
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestPR_ID_innehåll
        AND
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt = tie.latestST_ID_plats
    ]';
END pPR_innehåll_ST_plats_EV_of;
/
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.nPR_innehåll_ST_plats_EV_of
AS
SELECT
    *
FROM
    ties.pPR_innehåll_ST_plats_EV_of(CAST(current_timestamp AS timestamp(9)))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties.dPR_innehåll_ST_plats_EV_of (
    intervalStart IN timestamp,
    intervalEnd IN timestamp
)
RETURN VARCHAR2 SQL_MACRO
IS
BEGIN
    RETURN q'[
        SELECT
            tie.Metadata_PR_innehåll_ST_plats_EV_of,
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt,
            tie.PR_ID_innehåll,
            tie.ST_ID_plats,
            tie.EV_ID_of
        FROM
            ties.PR_innehåll_ST_plats_EV_of tie
        WHERE
            tie.PR_innehåll_ST_plats_EV_of_ChangedAt BETWEEN intervalStart AND intervalEnd
    ]';
END dPR_innehåll_ST_plats_EV_of;
/
