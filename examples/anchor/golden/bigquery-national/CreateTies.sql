-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- Ties are used to represent relationships between entities.
-- They come in four flavors: static, historized, knotted static, and knotted historized.
-- Ties have cardinality, constraining how members may participate in the relationship.
-- Every entity that is a member in a tie has a specified role in the relationship.
-- Ties must have at least two anchor roles and zero or more knot roles.
--
-- BigQuery has no unique constraints: a tie without identifiers is one to one because the load keeps it so.
--
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently` (
    `AC_ID_partner` int64 not null, 
    `AC_ID_with` int64 not null, 
    `ONG_ID_currently` int64 not null,
    `AC_partner_AC_with_ONG_currently_ChangedAt` datetime not null,
    `Metadata_AC_partner_AC_with_ONG_currently` int64 not null,
    PRIMARY KEY (
        `AC_ID_partner`,
        `AC_ID_with`,
        `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkAC_partner` FOREIGN KEY (`AC_ID_partner`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        knots.`ONG_Pågående`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of` (
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_ID_subset`,
        `PN_ID_of`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        anchors.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_rollsattes` (
    `EV_ID_in` numeric(12,0) not null, 
    `AC_ID_rollsattes` int64 not null, 
    `Metadata_EV_in_AC_rollsattes` int64 not null,
    PRIMARY KEY (
        `EV_ID_in`,
        `AC_ID_rollsattes`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_fkAC_rollsattes` FOREIGN KEY (`AC_ID_rollsattes`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_deltar_PR_in_RAT_fick` (
    `AC_ID_deltar` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_fick` int64 not null,
    `AC_deltar_PR_in_RAT_fick_ChangedAt` datetime not null,
    `Metadata_AC_deltar_PR_in_RAT_fick` int64 not null,
    PRIMARY KEY (
        `AC_ID_deltar`,
        `PR_ID_in`,
        `AC_deltar_PR_in_RAT_fick_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_fkAC_deltar` FOREIGN KEY (`AC_ID_deltar`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_fkRAT_fick` FOREIGN KEY (`RAT_ID_fick`) REFERENCES
        knots.`RAT_Betyg`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_deltar`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_spelas table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_spelas` (
    `ST_ID_at` int64 not null, 
    `PR_ID_spelas` int64 not null, 
    `ST_at_PR_spelas_ChangedAt` datetime not null,
    `Metadata_ST_at_PR_spelas` int64 not null,
    PRIMARY KEY (
        `ST_ID_at`,
        `PR_ID_spelas`,
        `ST_at_PR_spelas_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_fkPR_spelas` FOREIGN KEY (`PR_ID_spelas`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_förälder_AC_barn_PAT_har` (
    `AC_ID_förälder` int64 not null, 
    `AC_ID_barn` int64 not null, 
    `PAT_ID_har` int64 not null,
    `Metadata_AC_förälder_AC_barn_PAT_har` int64 not null,
    PRIMARY KEY (
        `AC_ID_förälder`,
        `AC_ID_barn`,
        `PAT_ID_har`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_fkAC_förälder` FOREIGN KEY (`AC_ID_förälder`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_fkAC_barn` FOREIGN KEY (`AC_ID_barn`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_fkPAT_har` FOREIGN KEY (`PAT_ID_har`) REFERENCES
        knots.`PAT_Föräldratyp`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_förälder`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_innehåll_ST_plats_EV_of` (
    `PR_ID_innehåll` int64 not null, 
    `ST_ID_plats` int64 not null, 
    `EV_ID_of` numeric(12,0) not null, 
    `PR_innehåll_ST_plats_EV_of_ChangedAt` datetime not null,
    `Metadata_PR_innehåll_ST_plats_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_ID_innehåll`,
        `ST_ID_plats`,
        `EV_ID_of`,
        `PR_innehåll_ST_plats_EV_of_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_fkPR_innehåll` FOREIGN KEY (`PR_ID_innehåll`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_fkST_plats` FOREIGN KEY (`ST_ID_plats`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_innehåll`
;
