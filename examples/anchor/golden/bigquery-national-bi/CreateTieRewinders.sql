-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_partner_AC_with_ONG_currently_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    `AC_partner_AC_with_ONG_currently_Reliability`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Annex`
WHERE
    `AC_partner_AC_with_ONG_currently_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_partner_AC_with_ONG_currently`,
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    ties.`rAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`
        ORDER BY a.`AC_partner_AC_with_ONG_currently_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_partner_AC_with_ONG_currently`,
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    ties.`fAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`
        ORDER BY a.`AC_partner_AC_with_ONG_currently_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_subset_PN_of`,
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_PositedAt`,
    `AC_subset_PN_of_Reliability`
FROM
    ties.`AC_subset_PN_of_Annex`
WHERE
    `AC_subset_PN_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Reliability`
FROM
    ties.`AC_subset_PN_of_Posit` p
JOIN
    ties.`rAC_subset_PN_of_Annex`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`
        ORDER BY a.`AC_subset_PN_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_subset_PN_of` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Reliability`
FROM
    ties.`AC_subset_PN_of_Posit` p
JOIN
    ties.`rAC_subset_PN_of_Annex`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`
        ORDER BY a.`AC_subset_PN_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_rollsattes_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_in_AC_rollsattes`,
    `EV_in_AC_rollsattes_ID`,
    `EV_in_AC_rollsattes_PositedAt`,
    `EV_in_AC_rollsattes_Reliability`
FROM
    ties.`EV_in_AC_rollsattes_Annex`
WHERE
    `EV_in_AC_rollsattes_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_rollsattes` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_rollsattes`,
    p.`EV_in_AC_rollsattes_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_rollsattes`,
    a.`EV_in_AC_rollsattes_PositedAt`,
    a.`EV_in_AC_rollsattes_Reliability`
FROM
    ties.`EV_in_AC_rollsattes_Posit` p
JOIN
    ties.`rEV_in_AC_rollsattes_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_rollsattes_ID` = p.`EV_in_AC_rollsattes_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_rollsattes_ID`
        ORDER BY a.`EV_in_AC_rollsattes_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fEV_in_AC_rollsattes` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_rollsattes`,
    p.`EV_in_AC_rollsattes_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_rollsattes`,
    a.`EV_in_AC_rollsattes_PositedAt`,
    a.`EV_in_AC_rollsattes_Reliability`
FROM
    ties.`EV_in_AC_rollsattes_Posit` p
JOIN
    ties.`rEV_in_AC_rollsattes_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_rollsattes_ID` = p.`EV_in_AC_rollsattes_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_rollsattes_ID`
        ORDER BY a.`EV_in_AC_rollsattes_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_deltar_PR_in_RAT_fick_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_deltar_PR_in_RAT_fick_ID`,
    `AC_ID_deltar`,
    `PR_ID_in`,
    `RAT_ID_fick`,
    `AC_deltar_PR_in_RAT_fick_ChangedAt`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Posit`
WHERE
    `AC_deltar_PR_in_RAT_fick_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_deltar_PR_in_RAT_fick_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_deltar_PR_in_RAT_fick_ID`,
    `AC_ID_deltar`,
    `PR_ID_in`,
    `RAT_ID_fick`,
    `AC_deltar_PR_in_RAT_fick_ChangedAt`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Posit`
WHERE
    `AC_deltar_PR_in_RAT_fick_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_deltar_PR_in_RAT_fick_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_deltar_PR_in_RAT_fick`,
    `AC_deltar_PR_in_RAT_fick_ID`,
    `AC_deltar_PR_in_RAT_fick_PositedAt`,
    `AC_deltar_PR_in_RAT_fick_Reliability`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Annex`
WHERE
    `AC_deltar_PR_in_RAT_fick_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_deltar_PR_in_RAT_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ID`,
    p.`AC_ID_deltar`,
    p.`PR_ID_in`,
    p.`RAT_ID_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    a.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    a.`AC_deltar_PR_in_RAT_fick_Reliability`
FROM
    ties.`rAC_deltar_PR_in_RAT_fick_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_deltar_PR_in_RAT_fick_Annex`(positingTimepoint) a
ON
    a.`AC_deltar_PR_in_RAT_fick_ID` = p.`AC_deltar_PR_in_RAT_fick_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_deltar_PR_in_RAT_fick_ID`
        ORDER BY a.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_deltar_PR_in_RAT_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ID`,
    p.`AC_ID_deltar`,
    p.`PR_ID_in`,
    p.`RAT_ID_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    a.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    a.`AC_deltar_PR_in_RAT_fick_Reliability`
FROM
    ties.`fAC_deltar_PR_in_RAT_fick_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_deltar_PR_in_RAT_fick_Annex`(positingTimepoint) a
ON
    a.`AC_deltar_PR_in_RAT_fick_ID` = p.`AC_deltar_PR_in_RAT_fick_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_deltar_PR_in_RAT_fick_ID`
        ORDER BY a.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_spelas_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_spelas_ID`,
    `ST_ID_at`,
    `PR_ID_spelas`,
    `ST_at_PR_spelas_ChangedAt`
FROM
    ties.`ST_at_PR_spelas_Posit`
WHERE
    `ST_at_PR_spelas_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_spelas_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_spelas_ID`,
    `ST_ID_at`,
    `PR_ID_spelas`,
    `ST_at_PR_spelas_ChangedAt`
FROM
    ties.`ST_at_PR_spelas_Posit`
WHERE
    `ST_at_PR_spelas_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_spelas_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_at_PR_spelas`,
    `ST_at_PR_spelas_ID`,
    `ST_at_PR_spelas_PositedAt`,
    `ST_at_PR_spelas_Reliability`
FROM
    ties.`ST_at_PR_spelas_Annex`
WHERE
    `ST_at_PR_spelas_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_spelas` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_spelas`,
    p.`ST_at_PR_spelas_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_spelas`,
    p.`ST_at_PR_spelas_ChangedAt`,
    a.`ST_at_PR_spelas_PositedAt`,
    a.`ST_at_PR_spelas_Reliability`
FROM
    ties.`rST_at_PR_spelas_Posit`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_spelas_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_spelas_ID` = p.`ST_at_PR_spelas_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_spelas_ID`
        ORDER BY a.`ST_at_PR_spelas_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_spelas` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_spelas`,
    p.`ST_at_PR_spelas_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_spelas`,
    p.`ST_at_PR_spelas_ChangedAt`,
    a.`ST_at_PR_spelas_PositedAt`,
    a.`ST_at_PR_spelas_Reliability`
FROM
    ties.`fST_at_PR_spelas_Posit`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_spelas_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_spelas_ID` = p.`ST_at_PR_spelas_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_spelas_ID`
        ORDER BY a.`ST_at_PR_spelas_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_förälder_AC_barn_PAT_har_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_förälder_AC_barn_PAT_har`,
    `AC_förälder_AC_barn_PAT_har_ID`,
    `AC_förälder_AC_barn_PAT_har_PositedAt`,
    `AC_förälder_AC_barn_PAT_har_Reliability`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Annex`
WHERE
    `AC_förälder_AC_barn_PAT_har_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_förälder_AC_barn_PAT_har` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_förälder_AC_barn_PAT_har`,
    p.`AC_förälder_AC_barn_PAT_har_ID`,
    p.`AC_ID_förälder`,
    p.`AC_ID_barn`,
    p.`PAT_ID_har`,
    a.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    a.`AC_förälder_AC_barn_PAT_har_Reliability`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Posit` p
JOIN
    ties.`rAC_förälder_AC_barn_PAT_har_Annex`(positingTimepoint) a
ON
    a.`AC_förälder_AC_barn_PAT_har_ID` = p.`AC_förälder_AC_barn_PAT_har_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_förälder_AC_barn_PAT_har_ID`
        ORDER BY a.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_förälder_AC_barn_PAT_har` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_förälder_AC_barn_PAT_har`,
    p.`AC_förälder_AC_barn_PAT_har_ID`,
    p.`AC_ID_förälder`,
    p.`AC_ID_barn`,
    p.`PAT_ID_har`,
    a.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    a.`AC_förälder_AC_barn_PAT_har_Reliability`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Posit` p
JOIN
    ties.`rAC_förälder_AC_barn_PAT_har_Annex`(positingTimepoint) a
ON
    a.`AC_förälder_AC_barn_PAT_har_ID` = p.`AC_förälder_AC_barn_PAT_har_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_förälder_AC_barn_PAT_har_ID`
        ORDER BY a.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_innehåll_ST_plats_EV_of_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_innehåll_ST_plats_EV_of_ID`,
    `PR_ID_innehåll`,
    `ST_ID_plats`,
    `EV_ID_of`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Posit`
WHERE
    `PR_innehåll_ST_plats_EV_of_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_innehåll_ST_plats_EV_of_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_innehåll_ST_plats_EV_of_ID`,
    `PR_ID_innehåll`,
    `ST_ID_plats`,
    `EV_ID_of`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Posit`
WHERE
    `PR_innehåll_ST_plats_EV_of_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_innehåll_ST_plats_EV_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_innehåll_ST_plats_EV_of`,
    `PR_innehåll_ST_plats_EV_of_ID`,
    `PR_innehåll_ST_plats_EV_of_PositedAt`,
    `PR_innehåll_ST_plats_EV_of_Reliability`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Annex`
WHERE
    `PR_innehåll_ST_plats_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_innehåll_ST_plats_EV_of`,
    p.`PR_innehåll_ST_plats_EV_of_ID`,
    p.`PR_ID_innehåll`,
    p.`ST_ID_plats`,
    p.`EV_ID_of`,
    p.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    a.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    a.`PR_innehåll_ST_plats_EV_of_Reliability`
FROM
    ties.`rPR_innehåll_ST_plats_EV_of_Posit`(changingTimepoint) p 
JOIN
    ties.`rPR_innehåll_ST_plats_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_innehåll_ST_plats_EV_of_ID`
        ORDER BY a.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_innehåll_ST_plats_EV_of`,
    p.`PR_innehåll_ST_plats_EV_of_ID`,
    p.`PR_ID_innehåll`,
    p.`ST_ID_plats`,
    p.`EV_ID_of`,
    p.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    a.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    a.`PR_innehåll_ST_plats_EV_of_Reliability`
FROM
    ties.`fPR_innehåll_ST_plats_EV_of_Posit`(changingTimepoint) p 
JOIN
    ties.`rPR_innehåll_ST_plats_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_innehåll_ST_plats_EV_of_ID`
        ORDER BY a.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC
    ) = 1
)
;
