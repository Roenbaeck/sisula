-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS knots;
CREATE SCHEMA IF NOT EXISTS anchors;
CREATE SCHEMA IF NOT EXISTS nexuses;
CREATE SCHEMA IF NOT EXISTS attributes;
CREATE SCHEMA IF NOT EXISTS ties;
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- BigQuery has no sequences, and no unique constraints: an identity is given by the load, and a value is unique because the
-- load adds only values that are not there. Its primary and foreign keys are not enforced (they are for the optimizer).
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.`PAT_ParentalType` (
    `PAT_ID` int64 not null,
    `PAT_ParentalType` string(42) not null,
    `Metadata_PAT` int64 not null,
    PRIMARY KEY (
        `PAT_ID`
    ) NOT ENFORCED
)
CLUSTER BY `PAT_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`GEN_Gender` (
    `GEN_ID` int64 not null,
    `GEN_Gender` string(42) not null,
    `GEN_Checksum` int64,
    `Metadata_GEN` int64 not null,
    PRIMARY KEY (
        `GEN_ID`
    ) NOT ENFORCED
)
CLUSTER BY `GEN_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`PLV_ProfessionalLevel` (
    `PLV_ID` int64 not null,
    `PLV_ProfessionalLevel` string not null,
    `PLV_Checksum` int64,
    `Metadata_PLV` int64 not null,
    PRIMARY KEY (
        `PLV_ID`
    ) NOT ENFORCED
)
CLUSTER BY `PLV_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.`UTL_Utilization` (
    `UTL_ID` int64 not null,
    `UTL_Utilization` int64 not null,
    `Metadata_UTL` int64 not null,
    PRIMARY KEY (
        `UTL_ID`
    ) NOT ENFORCED
)
CLUSTER BY `UTL_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.`ONG_Ongoing` (
    `ONG_ID` int64 not null,
    `ONG_Ongoing` string(3) not null,
    `Metadata_ONG` int64 not null,
    PRIMARY KEY (
        `ONG_ID`
    ) NOT ENFORCED
)
CLUSTER BY `ONG_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`RAT_Rating` (
    `RAT_ID` int64 not null,
    `RAT_Rating` string(42) not null,
    `RAT_Checksum` int64,
    `Metadata_RAT` int64 not null,
    PRIMARY KEY (
        `RAT_ID`
    ) NOT ENFORCED
)
CLUSTER BY `RAT_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`ETY_EventType` (
    `ETY_ID` int64 not null,
    `ETY_EventType` string(42) not null,
    `ETY_Checksum` int64,
    `Metadata_ETY` int64 not null,
    PRIMARY KEY (
        `ETY_ID`
    ) NOT ENFORCED
)
CLUSTER BY `ETY_ID`;
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- BigQuery has no sequences: the load gives an identity to every new entity.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`PN_Person` (
    `PN_ID` int64 not null,
    `Metadata_PN` int64 not null,
    PRIMARY KEY (
        `PN_ID`
    ) NOT ENFORCED
)
CLUSTER BY `PN_ID`;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`ST_Stage` (
    `ST_ID` int64 not null,
    `Metadata_ST` int64 not null,
    PRIMARY KEY (
        `ST_ID`
    ) NOT ENFORCED
)
CLUSTER BY `ST_ID`;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`AC_Actor` (
    `AC_ID` int64 not null,
    `Metadata_AC` int64 not null,
    PRIMARY KEY (
        `AC_ID`
    ) NOT ENFORCED
)
CLUSTER BY `AC_ID`;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`PR_Program` (
    `PR_ID` int64 not null,
    `Metadata_PR` int64 not null,
    PRIMARY KEY (
        `PR_ID`
    ) NOT ENFORCED
)
CLUSTER BY `PR_ID`;
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- BigQuery has no sequences: the load gives an identity to every new event.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses.`EV_Event` (
    `EV_ID` numeric(12,0) not null,
    `ST_ID_wasHeldAt` int64 not null, 
    `PR_ID_wasPlayed` int64 not null, 
    `ETY_ID_of` int64 not null,
    `Metadata_EV` int64 not null, 
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkST_wasHeldAt` FOREIGN KEY (`ST_ID_wasHeldAt`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkPR_wasPlayed` FOREIGN KEY (`PR_ID_wasPlayed`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkETY_of` FOREIGN KEY (`ETY_ID_of`) REFERENCES
        knots.`ETY_EventType`(`ETY_ID`) NOT ENFORCED
)
CLUSTER BY `EV_ID`;
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Event_Date` (
    `EV_DAT_EV_ID` numeric(12,0) not null,
    `EV_DAT_Event_Date` datetime not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date` FOREIGN KEY (`EV_DAT_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Event_Audience` (
    `EV_AUD_EV_ID` numeric(12,0) not null,
    `EV_AUD_Event_Audience` int64 not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience` FOREIGN KEY (`EV_AUD_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Event_Revenue` (
    `EV_REV_EV_ID` numeric(12,0) not null,
    `EV_REV_Event_Revenue` numeric(19,4) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue` FOREIGN KEY (`EV_REV_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_EV_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Event_Status table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Event_Status` (
    `EV_STA_EV_ID` numeric(12,0) not null,
    `EV_STA_Event_Status` string(20) not null,
    `EV_STA_ChangedAt` datetime not null,
    `Metadata_EV_STA` int64 not null,
    PRIMARY KEY (
        `EV_STA_EV_ID`,
        `EV_STA_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Event_Status` FOREIGN KEY (`EV_STA_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_EV_ID`, `EV_STA_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Event_Utilization` (
    `EV_UTL_EV_ID` numeric(12,0) not null,
    `EV_UTL_UTL_ID` int64 not null,
    `Metadata_EV_UTL` int64 not null,
    PRIMARY KEY (
        `EV_UTL_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_UTL_Event_Utilization` FOREIGN KEY (`EV_UTL_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_UTL_Event_Utilization` FOREIGN KEY (`EV_UTL_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_EV_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Event_Level table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Event_Level` (
    `EV_LVL_EV_ID` numeric(12,0) not null,
    `EV_LVL_PLV_ID` int64 not null,
    `EV_LVL_ChangedAt` date not null,
    `Metadata_EV_LVL` int64 not null,
    PRIMARY KEY (
        `EV_LVL_EV_ID`,
        `EV_LVL_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_LVL_Event_Level` FOREIGN KEY (`EV_LVL_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_LVL_Event_Level` FOREIGN KEY (`EV_LVL_PLV_ID`) REFERENCES
        knots.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_EV_ID`, `EV_LVL_ChangedAt`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Stage_Name` (
    `ST_NAM_ST_ID` int64 not null,
    `ST_NAM_Stage_Name` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name` FOREIGN KEY (`ST_NAM_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ST_ID`, `ST_NAM_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Stage_Location` (
    `ST_LOC_ST_ID` int64 not null,
    `ST_LOC_Stage_Location` geography not null,
    `ST_LOC_Checksum` int64,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location` FOREIGN KEY (`ST_LOC_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ST_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Stage_Average` (
    `ST_AVG_ST_ID` int64 not null,
    `ST_AVG_UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Stage_Average` FOREIGN KEY (`ST_AVG_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Stage_Average` FOREIGN KEY (`ST_AVG_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ST_ID`, `ST_AVG_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Stage_Minimum` (
    `ST_MIN_ST_ID` int64 not null,
    `ST_MIN_UTL_ID` int64 not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Stage_Minimum` FOREIGN KEY (`ST_MIN_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Stage_Minimum` FOREIGN KEY (`ST_MIN_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ST_ID`;
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Actor_Name` (
    `AC_NAM_AC_ID` int64 not null,
    `AC_NAM_Actor_Name` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name` FOREIGN KEY (`AC_NAM_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_AC_ID`, `AC_NAM_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Actor_Gender` (
    `AC_GEN_AC_ID` int64 not null,
    `AC_GEN_GEN_ID` int64 not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_AC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Actor_Gender` FOREIGN KEY (`AC_GEN_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Actor_Gender` FOREIGN KEY (`AC_GEN_GEN_ID`) REFERENCES
        knots.`GEN_Gender`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_AC_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Actor_ProfessionalLevel` (
    `AC_PLV_AC_ID` int64 not null,
    `AC_PLV_PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Actor_ProfessionalLevel` FOREIGN KEY (`AC_PLV_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Actor_ProfessionalLevel` FOREIGN KEY (`AC_PLV_PLV_ID`) REFERENCES
        knots.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_AC_ID`, `AC_PLV_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Program_Name` (
    `PR_NAM_PR_ID` int64 not null,
    `PR_NAM_Program_Name` string(42) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_PR_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name` FOREIGN KEY (`PR_NAM_PR_ID`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_PR_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Program_Length` (
    `PR_LEN_PR_ID` int64 not null,
    `PR_LEN_Program_Length` time not null,
    `PR_LEN_ChangedAt` date not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length` FOREIGN KEY (`PR_LEN_PR_ID`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_PR_ID`, `PR_LEN_ChangedAt`;
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
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        knots.`ONG_Ongoing`(`ONG_ID`) NOT ENFORCED
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
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        anchors.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_wasCast` (
    `EV_ID_in` numeric(12,0) not null, 
    `AC_ID_wasCast` int64 not null, 
    `Metadata_EV_in_AC_wasCast` int64 not null,
    PRIMARY KEY (
        `EV_ID_in`,
        `AC_ID_wasCast`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_fkAC_wasCast` FOREIGN KEY (`AC_ID_wasCast`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_part_PR_in_RAT_got` (
    `AC_ID_part` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_got` int64 not null,
    `AC_part_PR_in_RAT_got_ChangedAt` datetime not null,
    `Metadata_AC_part_PR_in_RAT_got` int64 not null,
    PRIMARY KEY (
        `AC_ID_part`,
        `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkAC_part` FOREIGN KEY (`AC_ID_part`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkRAT_got` FOREIGN KEY (`RAT_ID_got`) REFERENCES
        knots.`RAT_Rating`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_part`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_isPlaying` (
    `ST_ID_at` int64 not null, 
    `PR_ID_isPlaying` int64 not null, 
    `ST_at_PR_isPlaying_ChangedAt` datetime not null,
    `Metadata_ST_at_PR_isPlaying` int64 not null,
    PRIMARY KEY (
        `ST_ID_at`,
        `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_fkPR_isPlaying` FOREIGN KEY (`PR_ID_isPlaying`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_parent_AC_child_PAT_having` (
    `AC_ID_parent` int64 not null, 
    `AC_ID_child` int64 not null, 
    `PAT_ID_having` int64 not null,
    `Metadata_AC_parent_AC_child_PAT_having` int64 not null,
    PRIMARY KEY (
        `AC_ID_parent`,
        `AC_ID_child`,
        `PAT_ID_having`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkAC_parent` FOREIGN KEY (`AC_ID_parent`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkAC_child` FOREIGN KEY (`AC_ID_child`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkPAT_having` FOREIGN KEY (`PAT_ID_having`) REFERENCES
        knots.`PAT_ParentalType`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_parent`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_content_ST_location_EV_of` (
    `PR_ID_content` int64 not null, 
    `ST_ID_location` int64 not null, 
    `EV_ID_of` numeric(12,0) not null, 
    `PR_content_ST_location_EV_of_ChangedAt` datetime not null,
    `Metadata_PR_content_ST_location_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_ID_content`,
        `ST_ID_location`,
        `EV_ID_of`,
        `PR_content_ST_location_EV_of_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkPR_content` FOREIGN KEY (`PR_ID_content`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkST_location` FOREIGN KEY (`ST_ID_location`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_content`
;
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute table to the given
-- point in changing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time.
--
-- @changingTimepoint the point in changing time to rewind to
--
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_STA_Event_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Event_Status` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_EV_STA`,
        `EV_STA_EV_ID`,
        `EV_STA_Event_Status`,
        `EV_STA_ChangedAt`
    FROM
        attributes.`EV_STA_Event_Status`
    WHERE
        `EV_STA_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Event_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Event_Level` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_EV_LVL`,
        `EV_LVL_EV_ID`,
        `EV_LVL_PLV_ID`,
        `EV_LVL_ChangedAt`
    FROM
        attributes.`EV_LVL_Event_Level`
    WHERE
        `EV_LVL_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Stage_Name` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_NAM`,
        `ST_NAM_ST_ID`,
        `ST_NAM_Stage_Name`,
        `ST_NAM_ChangedAt`
    FROM
        attributes.`ST_NAM_Stage_Name`
    WHERE
        `ST_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Stage_Average` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_AVG`,
        `ST_AVG_ST_ID`,
        `ST_AVG_UTL_ID`,
        `ST_AVG_ChangedAt`
    FROM
        attributes.`ST_AVG_Stage_Average`
    WHERE
        `ST_AVG_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Actor_Name` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_NAM`,
        `AC_NAM_AC_ID`,
        `AC_NAM_Actor_Name`,
        `AC_NAM_ChangedAt`
    FROM
        attributes.`AC_NAM_Actor_Name`
    WHERE
        `AC_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_PLV`,
        `AC_PLV_AC_ID`,
        `AC_PLV_PLV_ID`,
        `AC_PLV_ChangedAt`
    FROM
        attributes.`AC_PLV_Actor_ProfessionalLevel`
    WHERE
        `AC_PLV_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Program_Length` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_PR_LEN`,
        `PR_LEN_PR_ID`,
        `PR_LEN_Program_Length`,
        `PR_LEN_ChangedAt`
    FROM
        attributes.`PR_LEN_Program_Length`
    WHERE
        `PR_LEN_ChangedAt` <= changingTimepoint
)
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BigQuery anchor perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`lST_Stage` (
    `ST_ID`,
    `Metadata_ST`,
    `ST_NAM_ST_ID`,
    `Metadata_ST_NAM`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_Stage_Name` OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.'),
    `ST_LOC_ST_ID`,
    `Metadata_ST_LOC`,
    `ST_LOC_Checksum`,
    `ST_LOC_Stage_Location` OPTIONS(description='Geographic location of the stage as a geography point.'),
    `ST_AVG_ST_ID`,
    `Metadata_ST_AVG`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_UTL_Utilization` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `ST_AVG_Metadata_UTL`,
    `ST_AVG_UTL_ID` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `ST_MIN_ST_ID`,
    `Metadata_ST_MIN`,
    `ST_MIN_UTL_Utilization` OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.'),
    `ST_MIN_Metadata_UTL`,
    `ST_MIN_UTL_ID` OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.')
)
OPTIONS(description='A stage or venue where programs are played and events are held.')
AS
SELECT
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`ST_NAM_Stage_Name` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`ST_NAM_ST_ID`
            ORDER BY t.`ST_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    attributes.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`ST_AVG_Stage_Average` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`ST_AVG_ST_ID`
            ORDER BY t.`ST_AVG_ChangedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN
    attributes.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pST_Stage` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rST_NAM_Stage_Name`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`ST_NAM_ST_ID`
            ORDER BY r.`ST_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    attributes.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rST_AVG_Stage_Average`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`ST_AVG_ST_ID`
            ORDER BY r.`ST_AVG_ChangedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN
    attributes.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nST_Stage`
AS
SELECT
    *
FROM
    anchors.`pST_Stage`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dST_Stage` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM (
    SELECT DISTINCT
        h.`ST_NAM_ST_ID` AS `ST_ID`,
        CAST(h.`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`ST_NAM_Stage_Name` h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h.`ST_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        h.`ST_AVG_ST_ID` AS `ST_ID`,
        CAST(h.`ST_AVG_ChangedAt` AS datetime) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes.`ST_AVG_Stage_Average` h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h.`ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`ST_Stage` `ST`
ON
    `ST`.`ST_ID` = timepoints.`ST_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`ST_NAM_ChangedAt`) OVER (
            PARTITION BY h.`ST_NAM_ST_ID`
            ORDER BY h.`ST_NAM_ChangedAt`
        ) AS `until`
    FROM
        attributes.`ST_NAM_Stage_Name` h
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
AND
    `NAM`.`ST_NAM_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `NAM`.`until` IS NULL
OR
    `NAM`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    attributes.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`ST_AVG_ChangedAt`) OVER (
            PARTITION BY h.`ST_AVG_ST_ID`
            ORDER BY h.`ST_AVG_ChangedAt`
        ) AS `until`
    FROM
        attributes.`ST_AVG_Stage_Average` h
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
AND
    `AVG`.`ST_AVG_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `AVG`.`until` IS NULL
OR
    `AVG`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN
    attributes.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`lAC_Actor` (
    `AC_ID`,
    `Metadata_AC`,
    `AC_NAM_AC_ID`,
    `Metadata_AC_NAM`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_Actor_Name` OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.'),
    `AC_GEN_AC_ID`,
    `Metadata_AC_GEN`,
    `AC_GEN_GEN_Checksum`,
    `AC_GEN_GEN_Gender` OPTIONS(description='Gender of the actor.'),
    `AC_GEN_Metadata_GEN`,
    `AC_GEN_GEN_ID` OPTIONS(description='Gender of the actor.'),
    `AC_PLV_AC_ID`,
    `Metadata_AC_PLV`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PLV_Checksum`,
    `AC_PLV_PLV_ProfessionalLevel` OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.'),
    `AC_PLV_Metadata_PLV`,
    `AC_PLV_PLV_ID` OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.')
)
OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.')
AS
SELECT
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`AC_NAM_Actor_Name` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`AC_NAM_AC_ID`
            ORDER BY t.`AC_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    attributes.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`AC_PLV_Actor_ProfessionalLevel` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`AC_PLV_AC_ID`
            ORDER BY t.`AC_PLV_ChangedAt` DESC
        ) = 1
) `PLV`
ON
    `PLV`.`AC_PLV_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pAC_Actor` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rAC_NAM_Actor_Name`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`AC_NAM_AC_ID`
            ORDER BY r.`AC_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    attributes.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rAC_PLV_Actor_ProfessionalLevel`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`AC_PLV_AC_ID`
            ORDER BY r.`AC_PLV_ChangedAt` DESC
        ) = 1
) `PLV`
ON
    `PLV`.`AC_PLV_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nAC_Actor`
AS
SELECT
    *
FROM
    anchors.`pAC_Actor`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dAC_Actor` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM (
    SELECT DISTINCT
        h.`AC_NAM_AC_ID` AS `AC_ID`,
        CAST(h.`AC_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`AC_NAM_Actor_Name` h
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        h.`AC_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        h.`AC_PLV_AC_ID` AS `AC_ID`,
        CAST(h.`AC_PLV_ChangedAt` AS datetime) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes.`AC_PLV_Actor_ProfessionalLevel` h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h.`AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`AC_Actor` `AC`
ON
    `AC`.`AC_ID` = timepoints.`AC_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`AC_NAM_ChangedAt`) OVER (
            PARTITION BY h.`AC_NAM_AC_ID`
            ORDER BY h.`AC_NAM_ChangedAt`
        ) AS `until`
    FROM
        attributes.`AC_NAM_Actor_Name` h
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
AND
    `NAM`.`AC_NAM_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `NAM`.`until` IS NULL
OR
    `NAM`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    attributes.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`AC_PLV_ChangedAt`) OVER (
            PARTITION BY h.`AC_PLV_AC_ID`
            ORDER BY h.`AC_PLV_ChangedAt`
        ) AS `until`
    FROM
        attributes.`AC_PLV_Actor_ProfessionalLevel` h
) `PLV`
ON
    `PLV`.`AC_PLV_AC_ID` = `AC`.`AC_ID`
AND
    `PLV`.`AC_PLV_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `PLV`.`until` IS NULL
OR
    `PLV`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`lPR_Program` (
    `PR_ID`,
    `Metadata_PR`,
    `PR_NAM_PR_ID`,
    `Metadata_PR_NAM`,
    `PR_NAM_Program_Name` OPTIONS(description='Name or title of the program.'),
    `PR_LEN_PR_ID`,
    `Metadata_PR_LEN`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_Program_Length` OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.')
)
AS
SELECT
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    anchors.`PR_Program` `PR`
LEFT JOIN
    attributes.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`PR_LEN_Program_Length` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`PR_LEN_PR_ID`
            ORDER BY t.`PR_LEN_ChangedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pPR_Program` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    anchors.`PR_Program` `PR`
LEFT JOIN
    attributes.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rPR_LEN_Program_Length`(CAST(changingTimepoint AS date)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`PR_LEN_PR_ID`
            ORDER BY r.`PR_LEN_ChangedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nPR_Program`
AS
SELECT
    *
FROM
    anchors.`pPR_Program`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dPR_Program` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM (
    SELECT DISTINCT
        h.`PR_LEN_PR_ID` AS `PR_ID`,
        CAST(h.`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes.`PR_LEN_Program_Length` h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h.`PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`PR_Program` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN
    attributes.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`PR_LEN_ChangedAt`) OVER (
            PARTITION BY h.`PR_LEN_PR_ID`
            ORDER BY h.`PR_LEN_ChangedAt`
        ) AS `until`
    FROM
        attributes.`PR_LEN_Program_Length` h
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`
AND
    `LEN`.`PR_LEN_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS date)
AND (
    `LEN`.`until` IS NULL
OR
    `LEN`.`until` > CAST(timepoints.inspectedTimepoint AS date)
)
)
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BigQuery nexus perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`lEV_Event` (
    `EV_ID`,
    `Metadata_EV`,
    `ST_ID_wasHeldAt` OPTIONS(description='The stage at which the event was held.'),
    `PR_ID_wasPlayed` OPTIONS(description='The program that was played at the event.'),
    `of_ETY_Checksum`,
    `of_ETY_EventType`,
    `of_Metadata_ETY`,
    `ETY_ID_of`,
    `EV_DAT_EV_ID`,
    `Metadata_EV_DAT`,
    `EV_DAT_Event_Date` OPTIONS(description='Date and time when the event took place.'),
    `EV_AUD_EV_ID`,
    `Metadata_EV_AUD`,
    `EV_AUD_Event_Audience` OPTIONS(description='Number of people in the audience at the event.'),
    `EV_REV_EV_ID`,
    `Metadata_EV_REV`,
    `EV_REV_Event_Revenue` OPTIONS(description='Revenue from ticket sales for the event.'),
    `EV_STA_EV_ID`,
    `Metadata_EV_STA`,
    `EV_STA_ChangedAt`,
    `EV_STA_Event_Status` OPTIONS(description='Status of the event, which may change until it has taken place.'),
    `EV_UTL_EV_ID`,
    `Metadata_EV_UTL`,
    `EV_UTL_UTL_Utilization`,
    `EV_UTL_Metadata_UTL`,
    `EV_UTL_UTL_ID`,
    `EV_LVL_EV_ID`,
    `Metadata_EV_LVL`,
    `EV_LVL_ChangedAt`,
    `EV_LVL_PLV_Checksum`,
    `EV_LVL_PLV_ProfessionalLevel` OPTIONS(description='Professional level required for the event, over time.'),
    `EV_LVL_Metadata_PLV`,
    `EV_LVL_PLV_ID` OPTIONS(description='Professional level required for the event, over time.')
)
OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.')
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Event` `EV`
LEFT JOIN
    knots.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`EV_STA_Event_Status` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`EV_STA_EV_ID`
            ORDER BY t.`EV_STA_ChangedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_UTL_Event_Utilization` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`EV_LVL_Event_Level` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`EV_LVL_EV_ID`
            ORDER BY t.`EV_LVL_ChangedAt` DESC
        ) = 1
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`PLV_ProfessionalLevel` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Event` `EV`
LEFT JOIN
    knots.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rEV_STA_Event_Status`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`EV_STA_EV_ID`
            ORDER BY r.`EV_STA_ChangedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_UTL_Event_Utilization` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rEV_LVL_Event_Level`(CAST(changingTimepoint AS date)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`EV_LVL_EV_ID`
            ORDER BY r.`EV_LVL_ChangedAt` DESC
        ) = 1
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`PLV_ProfessionalLevel` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`nEV_Event` AS
SELECT
    *
FROM
    nexuses.`pEV_Event`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Event` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with the values in effect then: every value is joined with the time until which it
-- holds, when the next one does. BigQuery cannot call a table function for each row of another table, so each change is
-- joined with the version in effect then.
SELECT
    timepoints.inspectedTimepoint,
    timepoints.mnemonic,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM (
    SELECT DISTINCT
        h.`EV_STA_EV_ID` AS `EV_ID`,
        CAST(h.`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Event_Status` h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h.`EV_STA_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        h.`EV_LVL_EV_ID` AS `EV_ID`,
        CAST(h.`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Event_Level` h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h.`EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses.`EV_Event` `EV`
ON
    `EV`.`EV_ID` = timepoints.`EV_ID`
LEFT JOIN
    knots.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`EV_STA_ChangedAt`) OVER (
            PARTITION BY h.`EV_STA_EV_ID`
            ORDER BY h.`EV_STA_ChangedAt`
        ) AS `until`
    FROM
        attributes.`EV_STA_Event_Status` h
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
AND
    `STA`.`EV_STA_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS datetime)
AND (
    `STA`.`until` IS NULL
OR
    `STA`.`until` > CAST(timepoints.inspectedTimepoint AS datetime)
)
LEFT JOIN
    attributes.`EV_UTL_Event_Utilization` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`EV_LVL_ChangedAt`) OVER (
            PARTITION BY h.`EV_LVL_EV_ID`
            ORDER BY h.`EV_LVL_ChangedAt`
        ) AS `until`
    FROM
        attributes.`EV_LVL_Event_Level` h
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
AND
    `LVL`.`EV_LVL_ChangedAt` <= CAST(timepoints.inspectedTimepoint AS date)
AND (
    `LVL`.`until` IS NULL
OR
    `LVL`.`until` > CAST(timepoints.inspectedTimepoint AS date)
)
LEFT JOIN
    knots.`PLV_ProfessionalLevel` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` (
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_ID_partner` OPTIONS(description='One of the actors in the partnership.'),
    `AC_ID_with` OPTIONS(description='The other actor in the partnership.'),
    `currently_ONG_Ongoing` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).'),
    `currently_Metadata_ONG`,
    `ONG_ID_currently` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).')
)
OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.')
AS
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Ongoing` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_partner`)
AND
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_with`)
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Ongoing` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_partner`)
AND
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` = max(tie.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (PARTITION BY tie.`AC_ID_with`)
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    ties.`pAC_partner_AC_with_ONG_currently`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Ongoing` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` (
    `Metadata_AC_subset_PN_of`,
    `AC_ID_subset` OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.'),
    `PN_ID_of` OPTIONS(description='The person who is the actor.')
)
AS
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    ties.`AC_subset_PN_of` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    ties.`AC_subset_PN_of` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    ties.`pAC_subset_PN_of`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lEV_in_AC_wasCast` (
    `Metadata_EV_in_AC_wasCast`,
    `EV_ID_in` OPTIONS(description='The event the actor was cast in.'),
    `AC_ID_wasCast` OPTIONS(description='An actor cast in the event.')
)
OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.')
AS
SELECT
    tie.`Metadata_EV_in_AC_wasCast`,
    tie.`EV_ID_in`,
    tie.`AC_ID_wasCast`
FROM
    ties.`EV_in_AC_wasCast` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_EV_in_AC_wasCast`,
    tie.`EV_ID_in`,
    tie.`AC_ID_wasCast`
FROM
    ties.`EV_in_AC_wasCast` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nEV_in_AC_wasCast` AS
SELECT
    *
FROM
    ties.`pEV_in_AC_wasCast`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_part_PR_in_RAT_got` (
    `Metadata_AC_part_PR_in_RAT_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_ID_part` OPTIONS(description='The actor having a part in the program.'),
    `PR_ID_in` OPTIONS(description='The program the actor has a part in.'),
    `got_RAT_Checksum`,
    `got_RAT_Rating` OPTIONS(description='The rating the actor got for the part.'),
    `got_Metadata_RAT`,
    `RAT_ID_got` OPTIONS(description='The rating the actor got for the part.')
)
OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.')
AS
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Checksum` AS `got_RAT_Checksum`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    ties.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    knots.`RAT_Rating` `RAT_got`
ON
    `RAT_got`.`RAT_ID` = tie.`RAT_ID_got`
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_part_PR_in_RAT_got_ChangedAt` = max(tie.`AC_part_PR_in_RAT_got_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_part`,
            tie.`PR_ID_in`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Checksum` AS `got_RAT_Checksum`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    ties.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    knots.`RAT_Rating` `RAT_got`
ON
    `RAT_got`.`RAT_ID` = tie.`RAT_ID_got`
WHERE
    tie.`AC_part_PR_in_RAT_got_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_part_PR_in_RAT_got_ChangedAt` = max(tie.`AC_part_PR_in_RAT_got_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_part`,
            tie.`PR_ID_in`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    ties.`pAC_part_PR_in_RAT_got`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Checksum` AS `got_RAT_Checksum`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    ties.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    knots.`RAT_Rating` `RAT_got`
ON
    `RAT_got`.`RAT_ID` = tie.`RAT_ID_got`
WHERE
    tie.`AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lST_at_PR_isPlaying` (
    `Metadata_ST_at_PR_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`,
    `ST_ID_at` OPTIONS(description='The stage where the program is playing.'),
    `PR_ID_isPlaying` OPTIONS(description='The program playing at the stage.')
)
OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.')
AS
SELECT
    tie.`Metadata_ST_at_PR_isPlaying`,
    tie.`ST_at_PR_isPlaying_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_isPlaying`
FROM
    ties.`ST_at_PR_isPlaying` tie
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_isPlaying_ChangedAt` = max(tie.`ST_at_PR_isPlaying_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_isPlaying`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_isPlaying`,
    tie.`ST_at_PR_isPlaying_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_isPlaying`
FROM
    ties.`ST_at_PR_isPlaying` tie
WHERE
    tie.`ST_at_PR_isPlaying_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_isPlaying_ChangedAt` = max(tie.`ST_at_PR_isPlaying_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_isPlaying`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nST_at_PR_isPlaying` AS
SELECT
    *
FROM
    ties.`pST_at_PR_isPlaying`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_isPlaying` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_isPlaying`,
    tie.`ST_at_PR_isPlaying_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_isPlaying`
FROM
    ties.`ST_at_PR_isPlaying` tie
WHERE
    tie.`ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_parent_AC_child_PAT_having` (
    `Metadata_AC_parent_AC_child_PAT_having`,
    `AC_ID_parent` OPTIONS(description='The actor who is the parent.'),
    `AC_ID_child` OPTIONS(description='The actor who is the child.'),
    `having_PAT_ParentalType` OPTIONS(description='The type of parental relationship.'),
    `having_Metadata_PAT`,
    `PAT_ID_having` OPTIONS(description='The type of parental relationship.')
)
OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.')
AS
SELECT
    tie.`Metadata_AC_parent_AC_child_PAT_having`,
    tie.`AC_ID_parent`,
    tie.`AC_ID_child`,
    `PAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `PAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    tie.`PAT_ID_having`
FROM
    ties.`AC_parent_AC_child_PAT_having` tie
LEFT JOIN
    knots.`PAT_ParentalType` `PAT_having`
ON
    `PAT_having`.`PAT_ID` = tie.`PAT_ID_having`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_parent_AC_child_PAT_having`,
    tie.`AC_ID_parent`,
    tie.`AC_ID_child`,
    `PAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `PAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    tie.`PAT_ID_having`
FROM
    ties.`AC_parent_AC_child_PAT_having` tie
LEFT JOIN
    knots.`PAT_ParentalType` `PAT_having`
ON
    `PAT_having`.`PAT_ID` = tie.`PAT_ID_having`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    ties.`pAC_parent_AC_child_PAT_having`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lPR_content_ST_location_EV_of` (
    `Metadata_PR_content_ST_location_EV_of`,
    `PR_content_ST_location_EV_of_ChangedAt`,
    `PR_ID_content` OPTIONS(description='The program that made up the content of the event.'),
    `ST_ID_location` OPTIONS(description='The stage where the event was located.'),
    `EV_ID_of` OPTIONS(description='The event.')
)
OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.')
AS
SELECT
    tie.`Metadata_PR_content_ST_location_EV_of`,
    tie.`PR_content_ST_location_EV_of_ChangedAt`,
    tie.`PR_ID_content`,
    tie.`ST_ID_location`,
    tie.`EV_ID_of`
FROM
    ties.`PR_content_ST_location_EV_of` tie
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`PR_content_ST_location_EV_of_ChangedAt` = max(tie.`PR_content_ST_location_EV_of_ChangedAt`) OVER (PARTITION BY tie.`PR_ID_content`)
AND
    tie.`PR_content_ST_location_EV_of_ChangedAt` = max(tie.`PR_content_ST_location_EV_of_ChangedAt`) OVER (PARTITION BY tie.`ST_ID_location`)
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_PR_content_ST_location_EV_of`,
    tie.`PR_content_ST_location_EV_of_ChangedAt`,
    tie.`PR_ID_content`,
    tie.`ST_ID_location`,
    tie.`EV_ID_of`
FROM
    ties.`PR_content_ST_location_EV_of` tie
WHERE
    tie.`PR_content_ST_location_EV_of_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`PR_content_ST_location_EV_of_ChangedAt` = max(tie.`PR_content_ST_location_EV_of_ChangedAt`) OVER (PARTITION BY tie.`PR_ID_content`)
AND
    tie.`PR_content_ST_location_EV_of_ChangedAt` = max(tie.`PR_content_ST_location_EV_of_ChangedAt`) OVER (PARTITION BY tie.`ST_ID_location`)
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    ties.`pPR_content_ST_location_EV_of`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_content_ST_location_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_PR_content_ST_location_EV_of`,
    tie.`PR_content_ST_location_EV_of_ChangedAt`,
    tie.`PR_ID_content`,
    tie.`ST_ID_location`,
    tie.`EV_ID_of`
FROM
    ties.`PR_content_ST_location_EV_of` tie
WHERE
    tie.`PR_content_ST_location_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
ALTER SCHEMA dw SET OPTIONS(description='Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.');
ALTER TABLE knots.`PAT_ParentalType` SET OPTIONS(description='Kind of parent-child relationship between two actors, such as biological or adoptive parent.');
ALTER TABLE knots.`PAT_ParentalType` ALTER COLUMN `PAT_ParentalType` SET OPTIONS(description='Kind of parent-child relationship between two actors, such as biological or adoptive parent.');
ALTER TABLE knots.`GEN_Gender` SET OPTIONS(description='Gender of an actor.');
ALTER TABLE knots.`GEN_Gender` ALTER COLUMN `GEN_Gender` SET OPTIONS(description='Gender of an actor.');
ALTER TABLE knots.`PLV_ProfessionalLevel` SET OPTIONS(description='Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.');
ALTER TABLE knots.`PLV_ProfessionalLevel` ALTER COLUMN `PLV_ProfessionalLevel` SET OPTIONS(description='Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.');
ALTER TABLE knots.`UTL_Utilization` SET OPTIONS(description='Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.');
ALTER TABLE knots.`UTL_Utilization` ALTER COLUMN `UTL_Utilization` SET OPTIONS(description='Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.');
ALTER TABLE knots.`ONG_Ongoing` SET OPTIONS(description='Yes or No flag indicating whether a relationship is still ongoing or has ended.');
ALTER TABLE knots.`ONG_Ongoing` ALTER COLUMN `ONG_Ongoing` SET OPTIONS(description='Yes or No flag indicating whether a relationship is still ongoing or has ended.');
ALTER TABLE knots.`RAT_Rating` SET OPTIONS(description='Rating of how well an actor performs a part in a program, such as good, mediocre or bad.');
ALTER TABLE knots.`RAT_Rating` ALTER COLUMN `RAT_Rating` SET OPTIONS(description='Rating of how well an actor performs a part in a program, such as good, mediocre or bad.');
ALTER TABLE attributes.`EV_DAT_Event_Date` ALTER COLUMN `EV_DAT_Event_Date` SET OPTIONS(description='Date and time when the event took place.');
ALTER TABLE attributes.`EV_AUD_Event_Audience` ALTER COLUMN `EV_AUD_Event_Audience` SET OPTIONS(description='Number of people in the audience at the event.');
ALTER TABLE attributes.`EV_REV_Event_Revenue` ALTER COLUMN `EV_REV_Event_Revenue` SET OPTIONS(description='Revenue from ticket sales for the event.');
ALTER TABLE attributes.`EV_STA_Event_Status` ALTER COLUMN `EV_STA_Event_Status` SET OPTIONS(description='Status of the event, which may change until it has taken place.');
ALTER TABLE attributes.`EV_LVL_Event_Level` ALTER COLUMN `EV_LVL_PLV_ID` SET OPTIONS(description='Professional level required for the event, over time.');
ALTER TABLE attributes.`ST_NAM_Stage_Name` ALTER COLUMN `ST_NAM_Stage_Name` SET OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.');
ALTER TABLE attributes.`ST_LOC_Stage_Location` ALTER COLUMN `ST_LOC_Stage_Location` SET OPTIONS(description='Geographic location of the stage as a geography point.');
ALTER TABLE attributes.`ST_AVG_Stage_Average` ALTER COLUMN `ST_AVG_UTL_ID` SET OPTIONS(description='Average utilization of the stage capacity, recalculated over time.');
ALTER TABLE attributes.`ST_MIN_Stage_Minimum` ALTER COLUMN `ST_MIN_UTL_ID` SET OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.');
ALTER TABLE attributes.`AC_NAM_Actor_Name` ALTER COLUMN `AC_NAM_Actor_Name` SET OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.');
ALTER TABLE attributes.`AC_GEN_Actor_Gender` ALTER COLUMN `AC_GEN_GEN_ID` SET OPTIONS(description='Gender of the actor.');
ALTER TABLE attributes.`AC_PLV_Actor_ProfessionalLevel` ALTER COLUMN `AC_PLV_PLV_ID` SET OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.');
ALTER TABLE attributes.`PR_NAM_Program_Name` ALTER COLUMN `PR_NAM_Program_Name` SET OPTIONS(description='Name or title of the program.');
ALTER TABLE attributes.`PR_LEN_Program_Length` ALTER COLUMN `PR_LEN_Program_Length` SET OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.');
ALTER TABLE anchors.`PN_Person` SET OPTIONS(description='A person. Persons who perform are also registered as actors.');
ALTER TABLE anchors.`ST_Stage` SET OPTIONS(description='A stage or venue where programs are played and events are held.');
ALTER TABLE anchors.`AC_Actor` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE nexuses.`EV_Event` SET OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.');
ALTER TABLE nexuses.`EV_Event` ALTER COLUMN `ST_ID_wasHeldAt` SET OPTIONS(description='The stage at which the event was held.');
ALTER TABLE nexuses.`EV_Event` ALTER COLUMN `PR_ID_wasPlayed` SET OPTIONS(description='The program that was played at the event.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` SET OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `AC_ID_partner` SET OPTIONS(description='One of the actors in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `AC_ID_with` SET OPTIONS(description='The other actor in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `ONG_ID_currently` SET OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).');
ALTER TABLE ties.`AC_subset_PN_of` ALTER COLUMN `AC_ID_subset` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE ties.`AC_subset_PN_of` ALTER COLUMN `PN_ID_of` SET OPTIONS(description='The person who is the actor.');
ALTER TABLE ties.`EV_in_AC_wasCast` SET OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.');
ALTER TABLE ties.`EV_in_AC_wasCast` ALTER COLUMN `EV_ID_in` SET OPTIONS(description='The event the actor was cast in.');
ALTER TABLE ties.`EV_in_AC_wasCast` ALTER COLUMN `AC_ID_wasCast` SET OPTIONS(description='An actor cast in the event.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got` SET OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got` ALTER COLUMN `AC_ID_part` SET OPTIONS(description='The actor having a part in the program.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got` ALTER COLUMN `PR_ID_in` SET OPTIONS(description='The program the actor has a part in.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got` ALTER COLUMN `RAT_ID_got` SET OPTIONS(description='The rating the actor got for the part.');
ALTER TABLE ties.`ST_at_PR_isPlaying` SET OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.');
ALTER TABLE ties.`ST_at_PR_isPlaying` ALTER COLUMN `ST_ID_at` SET OPTIONS(description='The stage where the program is playing.');
ALTER TABLE ties.`ST_at_PR_isPlaying` ALTER COLUMN `PR_ID_isPlaying` SET OPTIONS(description='The program playing at the stage.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having` SET OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having` ALTER COLUMN `AC_ID_parent` SET OPTIONS(description='The actor who is the parent.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having` ALTER COLUMN `AC_ID_child` SET OPTIONS(description='The actor who is the child.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having` ALTER COLUMN `PAT_ID_having` SET OPTIONS(description='The type of parental relationship.');
ALTER TABLE ties.`PR_content_ST_location_EV_of` SET OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.');
ALTER TABLE ties.`PR_content_ST_location_EV_of` ALTER COLUMN `PR_ID_content` SET OPTIONS(description='The program that made up the content of the event.');
ALTER TABLE ties.`PR_content_ST_location_EV_of` ALTER COLUMN `ST_ID_location` SET OPTIONS(description='The stage where the event was located.');
ALTER TABLE ties.`PR_content_ST_location_EV_of` ALTER COLUMN `EV_ID_of` SET OPTIONS(description='The event.');
