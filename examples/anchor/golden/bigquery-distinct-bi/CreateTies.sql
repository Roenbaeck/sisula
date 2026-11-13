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
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        knots.`ONG_Ongoing`(`ONG_ID`) NOT ENFORCED
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
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
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
-- EV_in_AC_wasCast_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_wasCast_Posit` (
    `EV_in_AC_wasCast_ID` int64 not null,
    `EV_ID_in` numeric(12,0) not null, 
    `AC_ID_wasCast` int64 not null, 
    PRIMARY KEY (
        `EV_in_AC_wasCast_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_Posit_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_Posit_fkAC_wasCast` FOREIGN KEY (`AC_ID_wasCast`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Annex table (of EV_in_AC_wasCast_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_wasCast_Annex` (
    `EV_in_AC_wasCast_ID` int64 not null,
    `EV_in_AC_wasCast_PositedAt` datetime not null,
    `EV_in_AC_wasCast_Reliability` numeric(5,2) not null,
    `Metadata_EV_in_AC_wasCast` int64 not null,
    PRIMARY KEY (
        `EV_in_AC_wasCast_ID`,
        `EV_in_AC_wasCast_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_in_AC_wasCast_Annex` FOREIGN KEY (`EV_in_AC_wasCast_ID`) REFERENCES
        ties.`EV_in_AC_wasCast_Posit`(`EV_in_AC_wasCast_ID`) NOT ENFORCED
)
CLUSTER BY `EV_in_AC_wasCast_ID`, `EV_in_AC_wasCast_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_part_PR_in_RAT_got_Posit` (
    `AC_part_PR_in_RAT_got_ID` int64 not null,
    `AC_ID_part` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_got` int64 not null,
    `AC_part_PR_in_RAT_got_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_part_PR_in_RAT_got_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Posit_fkAC_part` FOREIGN KEY (`AC_ID_part`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Posit_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Posit_fkRAT_got` FOREIGN KEY (`RAT_ID_got`) REFERENCES
        knots.`RAT_Rating`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_part`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Annex table (of AC_part_PR_in_RAT_got_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_part_PR_in_RAT_got_Annex` (
    `AC_part_PR_in_RAT_got_ID` int64 not null,
    `AC_part_PR_in_RAT_got_PositedAt` datetime not null,
    `AC_part_PR_in_RAT_got_Reliability` numeric(5,2) not null,
    `Metadata_AC_part_PR_in_RAT_got` int64 not null,
    PRIMARY KEY (
        `AC_part_PR_in_RAT_got_ID`,
        `AC_part_PR_in_RAT_got_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_part_PR_in_RAT_got_Annex` FOREIGN KEY (`AC_part_PR_in_RAT_got_ID`) REFERENCES
        ties.`AC_part_PR_in_RAT_got_Posit`(`AC_part_PR_in_RAT_got_ID`) NOT ENFORCED
)
CLUSTER BY `AC_part_PR_in_RAT_got_ID`, `AC_part_PR_in_RAT_got_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_isPlaying_Posit` (
    `ST_at_PR_isPlaying_ID` int64 not null,
    `ST_ID_at` int64 not null, 
    `PR_ID_isPlaying` int64 not null, 
    `ST_at_PR_isPlaying_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_at_PR_isPlaying_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_Posit_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_Posit_fkPR_isPlaying` FOREIGN KEY (`PR_ID_isPlaying`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Annex table (of ST_at_PR_isPlaying_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_isPlaying_Annex` (
    `ST_at_PR_isPlaying_ID` int64 not null,
    `ST_at_PR_isPlaying_PositedAt` datetime not null,
    `ST_at_PR_isPlaying_Reliability` numeric(5,2) not null,
    `Metadata_ST_at_PR_isPlaying` int64 not null,
    PRIMARY KEY (
        `ST_at_PR_isPlaying_ID`,
        `ST_at_PR_isPlaying_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_at_PR_isPlaying_Annex` FOREIGN KEY (`ST_at_PR_isPlaying_ID`) REFERENCES
        ties.`ST_at_PR_isPlaying_Posit`(`ST_at_PR_isPlaying_ID`) NOT ENFORCED
)
CLUSTER BY `ST_at_PR_isPlaying_ID`, `ST_at_PR_isPlaying_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_parent_AC_child_PAT_having_Posit` (
    `AC_parent_AC_child_PAT_having_ID` int64 not null,
    `AC_ID_parent` int64 not null, 
    `AC_ID_child` int64 not null, 
    `PAT_ID_having` int64 not null,
    PRIMARY KEY (
        `AC_parent_AC_child_PAT_having_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Posit_fkAC_parent` FOREIGN KEY (`AC_ID_parent`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Posit_fkAC_child` FOREIGN KEY (`AC_ID_child`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Posit_fkPAT_having` FOREIGN KEY (`PAT_ID_having`) REFERENCES
        knots.`PAT_ParentalType`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_parent`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Annex table (of AC_parent_AC_child_PAT_having_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_parent_AC_child_PAT_having_Annex` (
    `AC_parent_AC_child_PAT_having_ID` int64 not null,
    `AC_parent_AC_child_PAT_having_PositedAt` datetime not null,
    `AC_parent_AC_child_PAT_having_Reliability` numeric(5,2) not null,
    `Metadata_AC_parent_AC_child_PAT_having` int64 not null,
    PRIMARY KEY (
        `AC_parent_AC_child_PAT_having_ID`,
        `AC_parent_AC_child_PAT_having_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_parent_AC_child_PAT_having_Annex` FOREIGN KEY (`AC_parent_AC_child_PAT_having_ID`) REFERENCES
        ties.`AC_parent_AC_child_PAT_having_Posit`(`AC_parent_AC_child_PAT_having_ID`) NOT ENFORCED
)
CLUSTER BY `AC_parent_AC_child_PAT_having_ID`, `AC_parent_AC_child_PAT_having_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_content_ST_location_EV_of_Posit` (
    `PR_content_ST_location_EV_of_ID` int64 not null,
    `PR_ID_content` int64 not null, 
    `ST_ID_location` int64 not null, 
    `EV_ID_of` numeric(12,0) not null, 
    `PR_content_ST_location_EV_of_ChangedAt` datetime not null,
    PRIMARY KEY (
        `PR_content_ST_location_EV_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Posit_fkPR_content` FOREIGN KEY (`PR_ID_content`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Posit_fkST_location` FOREIGN KEY (`ST_ID_location`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Posit_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_content`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Annex table (of PR_content_ST_location_EV_of_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_content_ST_location_EV_of_Annex` (
    `PR_content_ST_location_EV_of_ID` int64 not null,
    `PR_content_ST_location_EV_of_PositedAt` datetime not null,
    `PR_content_ST_location_EV_of_Reliability` numeric(5,2) not null,
    `Metadata_PR_content_ST_location_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_content_ST_location_EV_of_ID`,
        `PR_content_ST_location_EV_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_content_ST_location_EV_of_Annex` FOREIGN KEY (`PR_content_ST_location_EV_of_ID`) REFERENCES
        ties.`PR_content_ST_location_EV_of_Posit`(`PR_content_ST_location_EV_of_ID`) NOT ENFORCED
)
CLUSTER BY `PR_content_ST_location_EV_of_ID`, `PR_content_ST_location_EV_of_PositedAt`;
