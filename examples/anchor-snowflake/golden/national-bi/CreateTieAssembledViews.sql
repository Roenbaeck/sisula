-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling.
--
CREATE OR REPLACE VIEW ties."AC_partner_AC_with_ONG_currently" COPY GRANTS AS
SELECT
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Reliability"
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    ties."AC_partner_AC_with_ONG_currently_Annex" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
;
CREATE OR REPLACE VIEW ties."AC_subset_PN_of" COPY GRANTS AS
SELECT
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Reliability"
FROM
    ties."AC_subset_PN_of_Posit" p
JOIN
    ties."AC_subset_PN_of_Annex" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
;
CREATE OR REPLACE VIEW ties."EV_in_AC_rollsattes" COPY GRANTS AS
SELECT
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Reliability"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    ties."EV_in_AC_rollsattes_Annex" a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
;
CREATE OR REPLACE VIEW ties."AC_deltar_PR_in_RAT_fick" COPY GRANTS AS
SELECT
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Reliability"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" p
JOIN
    ties."AC_deltar_PR_in_RAT_fick_Annex" a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
;
CREATE OR REPLACE VIEW ties."ST_at_PR_spelas" COPY GRANTS AS
SELECT
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Reliability"
FROM
    ties."ST_at_PR_spelas_Posit" p
JOIN
    ties."ST_at_PR_spelas_Annex" a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
;
CREATE OR REPLACE VIEW ties."AC_förälder_AC_barn_PAT_har" COPY GRANTS AS
SELECT
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Reliability"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    ties."AC_förälder_AC_barn_PAT_har_Annex" a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
;
CREATE OR REPLACE VIEW ties."PR_innehåll_ST_plats_EV_of" COPY GRANTS AS
SELECT
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Reliability"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" p
JOIN
    ties."PR_innehåll_ST_plats_EV_of_Annex" a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
;
