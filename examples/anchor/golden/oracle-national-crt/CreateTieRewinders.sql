-- TIE CRT ASSEMBLED VIEWS --------------------------------------------------------------------------------------------
--
-- Oracle-compatible CRT assembly views for ties.
--
CREATE OR REPLACE VIEW ties.rAC_partner_AC_with_ONG_currently AS
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
    a.
FROM
    ties.AC_partner_AC_with_ONG_currently_Posit p
JOIN
    ties.AC_partner_AC_with_ONG_currently_Annex a
ON
    a.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
WHERE
    a.AC_partner_AC_with_ONG_currently_Positor = 0
AND
    a.AC_partner_AC_with_ONG_currently_PositedAt = (
        SELECT
            MAX(sub.AC_partner_AC_with_ONG_currently_PositedAt)
        FROM
            ties.AC_partner_AC_with_ONG_currently_Annex sub
        WHERE
            sub.AC_partner_AC_with_ONG_currently_ID = p.AC_partner_AC_with_ONG_currently_ID
        AND
            sub.AC_partner_AC_with_ONG_currently_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_subset_PN_of AS
SELECT
    a.Metadata_AC_subset_PN_of,
    p.AC_subset_PN_of_ID,
    p.AC_ID_subset,
    p.PN_ID_of,
    a.AC_subset_PN_of_PositedAt,
    a.AC_subset_PN_of_Positor,
    a.AC_subset_PN_of_Reliability,
    a.AC_subset_PN_of_Assertion,
    a.
FROM
    ties.AC_subset_PN_of_Posit p
JOIN
    ties.AC_subset_PN_of_Annex a
ON
    a.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
WHERE
    a.AC_subset_PN_of_Positor = 0
AND
    a.AC_subset_PN_of_PositedAt = (
        SELECT
            MAX(sub.AC_subset_PN_of_PositedAt)
        FROM
            ties.AC_subset_PN_of_Annex sub
        WHERE
            sub.AC_subset_PN_of_ID = p.AC_subset_PN_of_ID
        AND
            sub.AC_subset_PN_of_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rEV_in_AC_rollsattes AS
SELECT
    a.Metadata_EV_in_AC_rollsattes,
    p.EV_in_AC_rollsattes_ID,
    p.EV_ID_in,
    p.AC_ID_rollsattes,
    a.EV_in_AC_rollsattes_PositedAt,
    a.EV_in_AC_rollsattes_Positor,
    a.EV_in_AC_rollsattes_Reliability,
    a.EV_in_AC_rollsattes_Assertion,
    a.
FROM
    ties.EV_in_AC_rollsattes_Posit p
JOIN
    ties.EV_in_AC_rollsattes_Annex a
ON
    a.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
WHERE
    a.EV_in_AC_rollsattes_Positor = 0
AND
    a.EV_in_AC_rollsattes_PositedAt = (
        SELECT
            MAX(sub.EV_in_AC_rollsattes_PositedAt)
        FROM
            ties.EV_in_AC_rollsattes_Annex sub
        WHERE
            sub.EV_in_AC_rollsattes_ID = p.EV_in_AC_rollsattes_ID
        AND
            sub.EV_in_AC_rollsattes_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_deltar_PR_in_RAT_fick AS
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
    a.
FROM
    ties.AC_deltar_PR_in_RAT_fick_Posit p
JOIN
    ties.AC_deltar_PR_in_RAT_fick_Annex a
ON
    a.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
WHERE
    a.AC_deltar_PR_in_RAT_fick_Positor = 0
AND
    a.AC_deltar_PR_in_RAT_fick_PositedAt = (
        SELECT
            MAX(sub.AC_deltar_PR_in_RAT_fick_PositedAt)
        FROM
            ties.AC_deltar_PR_in_RAT_fick_Annex sub
        WHERE
            sub.AC_deltar_PR_in_RAT_fick_ID = p.AC_deltar_PR_in_RAT_fick_ID
        AND
            sub.AC_deltar_PR_in_RAT_fick_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rST_at_PR_spelas AS
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
    a.
FROM
    ties.ST_at_PR_spelas_Posit p
JOIN
    ties.ST_at_PR_spelas_Annex a
ON
    a.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
WHERE
    a.ST_at_PR_spelas_Positor = 0
AND
    a.ST_at_PR_spelas_PositedAt = (
        SELECT
            MAX(sub.ST_at_PR_spelas_PositedAt)
        FROM
            ties.ST_at_PR_spelas_Annex sub
        WHERE
            sub.ST_at_PR_spelas_ID = p.ST_at_PR_spelas_ID
        AND
            sub.ST_at_PR_spelas_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rAC_förälder_AC_barn_PAT_har AS
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
    a.
FROM
    ties.AC_förälder_AC_barn_PAT_har_Posit p
JOIN
    ties.AC_förälder_AC_barn_PAT_har_Annex a
ON
    a.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
WHERE
    a.AC_förälder_AC_barn_PAT_har_Positor = 0
AND
    a.AC_förälder_AC_barn_PAT_har_PositedAt = (
        SELECT
            MAX(sub.AC_förälder_AC_barn_PAT_har_PositedAt)
        FROM
            ties.AC_förälder_AC_barn_PAT_har_Annex sub
        WHERE
            sub.AC_förälder_AC_barn_PAT_har_ID = p.AC_förälder_AC_barn_PAT_har_ID
        AND
            sub.AC_förälder_AC_barn_PAT_har_Positor = 0
    )
;
CREATE OR REPLACE VIEW ties.rPR_innehåll_ST_plats_EV_of AS
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
    a.
FROM
    ties.PR_innehåll_ST_plats_EV_of_Posit p
JOIN
    ties.PR_innehåll_ST_plats_EV_of_Annex a
ON
    a.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
WHERE
    a.PR_innehåll_ST_plats_EV_of_Positor = 0
AND
    a.PR_innehåll_ST_plats_EV_of_PositedAt = (
        SELECT
            MAX(sub.PR_innehåll_ST_plats_EV_of_PositedAt)
        FROM
            ties.PR_innehåll_ST_plats_EV_of_Annex sub
        WHERE
            sub.PR_innehåll_ST_plats_EV_of_ID = p.PR_innehåll_ST_plats_EV_of_ID
        AND
            sub.PR_innehåll_ST_plats_EV_of_Positor = 0
    )
;
