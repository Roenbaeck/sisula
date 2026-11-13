-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
-- BigQuery has no sequences: the load gives an identity to every posit. Its keys are not enforced, and it has no unique
-- constraints: what a posit table holds once is kept so by the load (the integrity checks tell if it has not).
--
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently_Posit` (
    `AC_partner_AC_with_ONG_currently_ID` int64 not null,
    `AC_ID_partner` int64 not null, 
    `AC_ID_with` int64 not null, 
    `ONG_ID_currently` int64 not null,
    `AC_partner_AC_with_ONG_currently_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkAC_partner` FOREIGN KEY (`AC_ID_partner`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        knots.`ONG_Pågående`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Annex table (of AC_partner_AC_with_ONG_currently_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently_Annex` (
    `AC_partner_AC_with_ONG_currently_ID` int64 not null,
    `AC_partner_AC_with_ONG_currently_PositedAt` datetime not null,
    `AC_partner_AC_with_ONG_currently_Reliability` numeric(5,2) not null,
    `Metadata_AC_partner_AC_with_ONG_currently` int64 not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`,
        `AC_partner_AC_with_ONG_currently_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_partner_AC_with_ONG_currently_Annex` FOREIGN KEY (`AC_partner_AC_with_ONG_currently_ID`) REFERENCES
        ties.`AC_partner_AC_with_ONG_currently_Posit`(`AC_partner_AC_with_ONG_currently_ID`) NOT ENFORCED
)
CLUSTER BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of_Posit` (
    `AC_subset_PN_of_ID` int64 not null,
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    PRIMARY KEY (
        `AC_subset_PN_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Posit_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Posit_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        anchors.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Annex table (of AC_subset_PN_of_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of_Annex` (
    `AC_subset_PN_of_ID` int64 not null,
    `AC_subset_PN_of_PositedAt` datetime not null,
    `AC_subset_PN_of_Reliability` numeric(5,2) not null,
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_subset_PN_of_ID`,
        `AC_subset_PN_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_subset_PN_of_Annex` FOREIGN KEY (`AC_subset_PN_of_ID`) REFERENCES
        ties.`AC_subset_PN_of_Posit`(`AC_subset_PN_of_ID`) NOT ENFORCED
)
CLUSTER BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_rollsattes_Posit` (
    `EV_in_AC_rollsattes_ID` int64 not null,
    `EV_ID_in` numeric(12,0) not null, 
    `AC_ID_rollsattes` int64 not null, 
    PRIMARY KEY (
        `EV_in_AC_rollsattes_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_Posit_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_Posit_fkAC_rollsattes` FOREIGN KEY (`AC_ID_rollsattes`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes_Annex table (of EV_in_AC_rollsattes_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_rollsattes_Annex` (
    `EV_in_AC_rollsattes_ID` int64 not null,
    `EV_in_AC_rollsattes_PositedAt` datetime not null,
    `EV_in_AC_rollsattes_Reliability` numeric(5,2) not null,
    `Metadata_EV_in_AC_rollsattes` int64 not null,
    PRIMARY KEY (
        `EV_in_AC_rollsattes_ID`,
        `EV_in_AC_rollsattes_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_in_AC_rollsattes_Annex` FOREIGN KEY (`EV_in_AC_rollsattes_ID`) REFERENCES
        ties.`EV_in_AC_rollsattes_Posit`(`EV_in_AC_rollsattes_ID`) NOT ENFORCED
)
CLUSTER BY `EV_in_AC_rollsattes_ID`, `EV_in_AC_rollsattes_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_deltar_PR_in_RAT_fick_Posit` (
    `AC_deltar_PR_in_RAT_fick_ID` int64 not null,
    `AC_ID_deltar` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_fick` int64 not null,
    `AC_deltar_PR_in_RAT_fick_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_deltar_PR_in_RAT_fick_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_Posit_fkAC_deltar` FOREIGN KEY (`AC_ID_deltar`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_Posit_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_Posit_fkRAT_fick` FOREIGN KEY (`RAT_ID_fick`) REFERENCES
        knots.`RAT_Betyg`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_deltar`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick_Annex table (of AC_deltar_PR_in_RAT_fick_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_deltar_PR_in_RAT_fick_Annex` (
    `AC_deltar_PR_in_RAT_fick_ID` int64 not null,
    `AC_deltar_PR_in_RAT_fick_PositedAt` datetime not null,
    `AC_deltar_PR_in_RAT_fick_Reliability` numeric(5,2) not null,
    `Metadata_AC_deltar_PR_in_RAT_fick` int64 not null,
    PRIMARY KEY (
        `AC_deltar_PR_in_RAT_fick_ID`,
        `AC_deltar_PR_in_RAT_fick_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_deltar_PR_in_RAT_fick_Annex` FOREIGN KEY (`AC_deltar_PR_in_RAT_fick_ID`) REFERENCES
        ties.`AC_deltar_PR_in_RAT_fick_Posit`(`AC_deltar_PR_in_RAT_fick_ID`) NOT ENFORCED
)
CLUSTER BY `AC_deltar_PR_in_RAT_fick_ID`, `AC_deltar_PR_in_RAT_fick_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_spelas_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_spelas_Posit` (
    `ST_at_PR_spelas_ID` int64 not null,
    `ST_ID_at` int64 not null, 
    `PR_ID_spelas` int64 not null, 
    `ST_at_PR_spelas_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_at_PR_spelas_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_Posit_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_Posit_fkPR_spelas` FOREIGN KEY (`PR_ID_spelas`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_spelas_Annex table (of ST_at_PR_spelas_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_spelas_Annex` (
    `ST_at_PR_spelas_ID` int64 not null,
    `ST_at_PR_spelas_PositedAt` datetime not null,
    `ST_at_PR_spelas_Reliability` numeric(5,2) not null,
    `Metadata_ST_at_PR_spelas` int64 not null,
    PRIMARY KEY (
        `ST_at_PR_spelas_ID`,
        `ST_at_PR_spelas_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_at_PR_spelas_Annex` FOREIGN KEY (`ST_at_PR_spelas_ID`) REFERENCES
        ties.`ST_at_PR_spelas_Posit`(`ST_at_PR_spelas_ID`) NOT ENFORCED
)
CLUSTER BY `ST_at_PR_spelas_ID`, `ST_at_PR_spelas_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_förälder_AC_barn_PAT_har_Posit` (
    `AC_förälder_AC_barn_PAT_har_ID` int64 not null,
    `AC_ID_förälder` int64 not null, 
    `AC_ID_barn` int64 not null, 
    `PAT_ID_har` int64 not null,
    PRIMARY KEY (
        `AC_förälder_AC_barn_PAT_har_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_Posit_fkAC_förälder` FOREIGN KEY (`AC_ID_förälder`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_Posit_fkAC_barn` FOREIGN KEY (`AC_ID_barn`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_Posit_fkPAT_har` FOREIGN KEY (`PAT_ID_har`) REFERENCES
        knots.`PAT_Föräldratyp`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_förälder`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har_Annex table (of AC_förälder_AC_barn_PAT_har_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_förälder_AC_barn_PAT_har_Annex` (
    `AC_förälder_AC_barn_PAT_har_ID` int64 not null,
    `AC_förälder_AC_barn_PAT_har_PositedAt` datetime not null,
    `AC_förälder_AC_barn_PAT_har_Reliability` numeric(5,2) not null,
    `Metadata_AC_förälder_AC_barn_PAT_har` int64 not null,
    PRIMARY KEY (
        `AC_förälder_AC_barn_PAT_har_ID`,
        `AC_förälder_AC_barn_PAT_har_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_förälder_AC_barn_PAT_har_Annex` FOREIGN KEY (`AC_förälder_AC_barn_PAT_har_ID`) REFERENCES
        ties.`AC_förälder_AC_barn_PAT_har_Posit`(`AC_förälder_AC_barn_PAT_har_ID`) NOT ENFORCED
)
CLUSTER BY `AC_förälder_AC_barn_PAT_har_ID`, `AC_förälder_AC_barn_PAT_har_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_innehåll_ST_plats_EV_of_Posit` (
    `PR_innehåll_ST_plats_EV_of_ID` int64 not null,
    `PR_ID_innehåll` int64 not null, 
    `ST_ID_plats` int64 not null, 
    `EV_ID_of` numeric(12,0) not null, 
    `PR_innehåll_ST_plats_EV_of_ChangedAt` datetime not null,
    PRIMARY KEY (
        `PR_innehåll_ST_plats_EV_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_Posit_fkPR_innehåll` FOREIGN KEY (`PR_ID_innehåll`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_Posit_fkST_plats` FOREIGN KEY (`ST_ID_plats`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_Posit_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_innehåll`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of_Annex table (of PR_innehåll_ST_plats_EV_of_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_innehåll_ST_plats_EV_of_Annex` (
    `PR_innehåll_ST_plats_EV_of_ID` int64 not null,
    `PR_innehåll_ST_plats_EV_of_PositedAt` datetime not null,
    `PR_innehåll_ST_plats_EV_of_Reliability` numeric(5,2) not null,
    `Metadata_PR_innehåll_ST_plats_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_innehåll_ST_plats_EV_of_ID`,
        `PR_innehåll_ST_plats_EV_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_innehåll_ST_plats_EV_of_Annex` FOREIGN KEY (`PR_innehåll_ST_plats_EV_of_ID`) REFERENCES
        ties.`PR_innehåll_ST_plats_EV_of_Posit`(`PR_innehåll_ST_plats_EV_of_ID`) NOT ENFORCED
)
CLUSTER BY `PR_innehåll_ST_plats_EV_of_ID`, `PR_innehåll_ST_plats_EV_of_PositedAt`;
