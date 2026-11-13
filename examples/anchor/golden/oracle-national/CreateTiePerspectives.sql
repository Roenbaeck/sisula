-- TIE PERSPECTIVES ---------------------------------------------------------------------------------------------------
--
-- Oracle latest (l) and now (n) perspectives.
--
CREATE OR REPLACE VIEW ties.lAC_partner_AC_with_ONG_currently AS
SELECT
    tie.Metadata_AC_partner_AC_with_ONG_currently,
    tie.AC_partner_AC_with_ONG_currently_ChangedAt,
    tie.AC_ID_partner,
    tie.AC_ID_with,
    ONG_currently.ONG_Pågående AS currently_ONG_Pågående,
    ONG_currently.Metadata_ONG AS currently_Metadata_ONG,
    tie.ONG_ID_currently
FROM
    ties.AC_partner_AC_with_ONG_currently tie
LEFT JOIN
    knots.ONG_Pågående ONG_currently
ON
    ONG_currently.ONG_ID = tie.ONG_ID_currently
WHERE (
    tie.AC_partner_AC_with_ONG_currently_ChangedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_ChangedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently sub
        WHERE
            (
                sub.AC_ID_partner = tie.AC_ID_partner
            OR
                sub.AC_ID_with = tie.AC_ID_with
            OR
                sub.ONG_ID_currently = tie.ONG_ID_currently
            )
    )
    OR tie.AC_partner_AC_with_ONG_currently_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nAC_partner_AC_with_ONG_currently AS
SELECT
    *
FROM
    ties.lAC_partner_AC_with_ONG_currently
;
CREATE OR REPLACE VIEW ties.lAC_subset_PN_of AS
SELECT
    tie.Metadata_AC_subset_PN_of,
    tie.AC_ID_subset,
    tie.PN_ID_of
FROM
    ties.AC_subset_PN_of tie
;

CREATE OR REPLACE VIEW ties.nAC_subset_PN_of AS
SELECT
    *
FROM
    ties.lAC_subset_PN_of
;
CREATE OR REPLACE VIEW ties.lEV_in_AC_rollsattes AS
SELECT
    tie.Metadata_EV_in_AC_rollsattes,
    tie.EV_ID_in,
    tie.AC_ID_rollsattes
FROM
    ties.EV_in_AC_rollsattes tie
;

CREATE OR REPLACE VIEW ties.nEV_in_AC_rollsattes AS
SELECT
    *
FROM
    ties.lEV_in_AC_rollsattes
;
CREATE OR REPLACE VIEW ties.lAC_deltar_PR_in_RAT_fick AS
SELECT
    tie.Metadata_AC_deltar_PR_in_RAT_fick,
    tie.AC_deltar_PR_in_RAT_fick_ChangedAt,
    tie.AC_ID_deltar,
    tie.PR_ID_in,
    RAT_fick.RAT_Betyg AS fick_RAT_Betyg,
    RAT_fick.Metadata_RAT AS fick_Metadata_RAT,
    tie.RAT_ID_fick
FROM
    ties.AC_deltar_PR_in_RAT_fick tie
LEFT JOIN
    knots.RAT_Betyg RAT_fick
ON
    RAT_fick.RAT_ID = tie.RAT_ID_fick
WHERE (
    tie.AC_deltar_PR_in_RAT_fick_ChangedAt = (
        SELECT
            MAX(sub.AC_deltar_PR_in_RAT_fick_ChangedAt)
        FROM
            ties.AC_deltar_PR_in_RAT_fick sub
        WHERE
            sub.AC_ID_deltar = tie.AC_ID_deltar
        AND
            sub.PR_ID_in = tie.PR_ID_in
    )
    OR tie.AC_deltar_PR_in_RAT_fick_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nAC_deltar_PR_in_RAT_fick AS
SELECT
    *
FROM
    ties.lAC_deltar_PR_in_RAT_fick
;
CREATE OR REPLACE VIEW ties.lST_at_PR_spelas AS
SELECT
    tie.Metadata_ST_at_PR_spelas,
    tie.ST_at_PR_spelas_ChangedAt,
    tie.ST_ID_at,
    tie.PR_ID_spelas
FROM
    ties.ST_at_PR_spelas tie
WHERE (
    tie.ST_at_PR_spelas_ChangedAt = (
        SELECT
            MAX(sub.ST_at_PR_spelas_ChangedAt)
        FROM
            ties.ST_at_PR_spelas sub
        WHERE
            sub.ST_ID_at = tie.ST_ID_at
        AND
            sub.PR_ID_spelas = tie.PR_ID_spelas
    )
    OR tie.ST_at_PR_spelas_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nST_at_PR_spelas AS
SELECT
    *
FROM
    ties.lST_at_PR_spelas
;
CREATE OR REPLACE VIEW ties.lAC_förälder_AC_barn_PAT_har AS
SELECT
    tie.Metadata_AC_förälder_AC_barn_PAT_har,
    tie.AC_ID_förälder,
    tie.AC_ID_barn,
    PAT_har.PAT_Föräldratyp AS har_PAT_Föräldratyp,
    PAT_har.Metadata_PAT AS har_Metadata_PAT,
    tie.PAT_ID_har
FROM
    ties.AC_förälder_AC_barn_PAT_har tie
LEFT JOIN
    knots.PAT_Föräldratyp PAT_har
ON
    PAT_har.PAT_ID = tie.PAT_ID_har
;

CREATE OR REPLACE VIEW ties.nAC_förälder_AC_barn_PAT_har AS
SELECT
    *
FROM
    ties.lAC_förälder_AC_barn_PAT_har
;
CREATE OR REPLACE VIEW ties.lPR_innehåll_ST_plats_EV_of AS
SELECT
    tie.Metadata_PR_innehåll_ST_plats_EV_of,
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt,
    tie.PR_ID_innehåll,
    tie.ST_ID_plats,
    tie.EV_ID_of
FROM
    ties.PR_innehåll_ST_plats_EV_of tie
WHERE (
    tie.PR_innehåll_ST_plats_EV_of_ChangedAt = (
        SELECT
            MAX(sub.PR_innehåll_ST_plats_EV_of_ChangedAt)
        FROM
            ties.PR_innehåll_ST_plats_EV_of sub
        WHERE
            (
                sub.PR_ID_innehåll = tie.PR_ID_innehåll
            OR
                sub.ST_ID_plats = tie.ST_ID_plats
            OR
                sub.EV_ID_of = tie.EV_ID_of
            )
    )
    OR tie.PR_innehåll_ST_plats_EV_of_ChangedAt IS NULL
)
;

CREATE OR REPLACE VIEW ties.nPR_innehåll_ST_plats_EV_of AS
SELECT
    *
FROM
    ties.lPR_innehåll_ST_plats_EV_of
;
