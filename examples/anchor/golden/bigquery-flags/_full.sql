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
-- NATURAL KEYS -------------------------------------------------------------------------------------------------------
--
-- A natural key is a route in the model: the values that identify an anchor or a nexus, reached from it through its
-- attributes, its roles and ties (see naturalKeys() in Helpers.js for the rules a route follows). For each route of
-- each anchor and nexus there is
--
--   key_<anchor or nexus>_<route>          the key of every identity, from the latest values, with one column for
--                                          each value; a value with a checksum, such as a geography, is followed by
--                                          the checksum, FARM_FINGERPRINT of the value, which is what it is matched on
--   pkey_<anchor or nexus>_<route>(time)   the key of every identity at a changing time, for a route that passes
--                                          something historized, since its key can change
--   ic_key_<anchor or nexus>_<route>       the keys that more than one identity has, and the identities that have
--                                          more than one key; part of IntegrityViolations
--
-- BigQuery does not enforce that a key is unique, so a lookup through a key view can find more than one identity
-- when ic_key_ is not empty.
--
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`key_ST_Stage_1st` (
    `ST_ID`,
    `ST_LOC_Stage_Location`,
    `ST_LOC_Checksum`
)
AS
SELECT
    `ST`.`ST_ID`,
    `ST`.`ST_LOC_Stage_Location`,
    `ST`.`ST_LOC_Checksum`
FROM
    anchors.`lST_Stage` `ST`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_key_ST_Stage_1st` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_1st',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_Checksum` AS `ST_LOC_Checksum`
    )),
    COUNT(DISTINCT `ST_ID`)
FROM
    anchors.`key_ST_Stage_1st`
WHERE
    `ST_LOC_Checksum` IS NOT NULL
GROUP BY
    `ST_LOC_Checksum`
HAVING
    COUNT(DISTINCT `ST_ID`) > 1
UNION ALL
SELECT
    'key_ST_Stage_1st',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`
    )),
    COUNT(*)
FROM
    anchors.`key_ST_Stage_1st`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`key_ST_Stage_2nd` (
    `ST_ID`,
    `ST_NAM_Stage_Name`
)
AS
SELECT
    `ST`.`ST_ID`,
    `ST`.`ST_NAM_Stage_Name`
FROM
    anchors.`lST_Stage` `ST`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pkey_ST_Stage_2nd` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `ST`.`ST_NAM_Stage_Name`
FROM
    anchors.`pST_Stage`(changingTimepoint) `ST`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_key_ST_Stage_2nd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_2nd',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_Stage_Name` AS `ST_NAM_Stage_Name`
    )),
    COUNT(DISTINCT `ST_ID`)
FROM
    anchors.`key_ST_Stage_2nd`
WHERE
    `ST_NAM_Stage_Name` IS NOT NULL
GROUP BY
    `ST_NAM_Stage_Name`
HAVING
    COUNT(DISTINCT `ST_ID`) > 1
UNION ALL
SELECT
    'key_ST_Stage_2nd',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`
    )),
    COUNT(*)
FROM
    anchors.`key_ST_Stage_2nd`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`key_AC_Actor_1st` (
    `AC_ID`,
    `AC_NAM_Actor_Name`
)
AS
SELECT
    `AC`.`AC_ID`,
    `AC`.`AC_NAM_Actor_Name`
FROM
    anchors.`lAC_Actor` `AC`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pkey_AC_Actor_1st` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `AC`.`AC_NAM_Actor_Name`
FROM
    anchors.`pAC_Actor`(changingTimepoint) `AC`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_key_AC_Actor_1st` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_1st',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_Actor_Name` AS `AC_NAM_Actor_Name`
    )),
    COUNT(DISTINCT `AC_ID`)
FROM
    anchors.`key_AC_Actor_1st`
WHERE
    `AC_NAM_Actor_Name` IS NOT NULL
GROUP BY
    `AC_NAM_Actor_Name`
HAVING
    COUNT(DISTINCT `AC_ID`) > 1
UNION ALL
SELECT
    'key_AC_Actor_1st',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `AC_ID` AS `AC_ID`
    )),
    COUNT(*)
FROM
    anchors.`key_AC_Actor_1st`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`key_PR_Program_1st` (
    `PR_ID`,
    `PR_NAM_Program_Name`
)
AS
SELECT
    `PR`.`PR_ID`,
    `PR`.`PR_NAM_Program_Name`
FROM
    anchors.`lPR_Program` `PR`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_key_PR_Program_1st` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Program_1st',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_Program_Name` AS `PR_NAM_Program_Name`
    )),
    COUNT(DISTINCT `PR_ID`)
FROM
    anchors.`key_PR_Program_1st`
WHERE
    `PR_NAM_Program_Name` IS NOT NULL
GROUP BY
    `PR_NAM_Program_Name`
HAVING
    COUNT(DISTINCT `PR_ID`) > 1
UNION ALL
SELECT
    'key_PR_Program_1st',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `PR_ID` AS `PR_ID`
    )),
    COUNT(*)
FROM
    anchors.`key_PR_Program_1st`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`key_EV_Event_1st` (
    `EV_ID`,
    `EV_DAT_Event_Date`,
    `wasHeldAt_ST_LOC_Stage_Location`,
    `wasHeldAt_ST_LOC_Checksum`,
    `wasPlayed_PR_NAM_Program_Name`
)
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`EV_DAT_Event_Date`,
    `s2`.`ST_LOC_Stage_Location`,
    `s2`.`ST_LOC_Checksum`,
    `s4`.`PR_NAM_Program_Name`
FROM
    nexuses.`lEV_Event` `EV`
LEFT JOIN
    anchors.`lST_Stage` `s2`
ON
    `s2`.`ST_ID` = `EV`.`ST_ID_wasHeldAt`
LEFT JOIN
    anchors.`lPR_Program` `s4`
ON
    `s4`.`PR_ID` = `EV`.`PR_ID_wasPlayed`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`ic_key_EV_Event_1st` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_1st',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_Event_Date` AS `EV_DAT_Event_Date`,
        `wasHeldAt_ST_LOC_Checksum` AS `wasHeldAt_ST_LOC_Checksum`,
        `wasPlayed_PR_NAM_Program_Name` AS `wasPlayed_PR_NAM_Program_Name`
    )),
    COUNT(DISTINCT `EV_ID`)
FROM
    nexuses.`key_EV_Event_1st`
WHERE
    `EV_DAT_Event_Date` IS NOT NULL
AND
    `wasHeldAt_ST_LOC_Checksum` IS NOT NULL
AND
    `wasPlayed_PR_NAM_Program_Name` IS NOT NULL
GROUP BY
    `EV_DAT_Event_Date`,
    `wasHeldAt_ST_LOC_Checksum`,
    `wasPlayed_PR_NAM_Program_Name`
HAVING
    COUNT(DISTINCT `EV_ID`) > 1
UNION ALL
SELECT
    'key_EV_Event_1st',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `EV_ID` AS `EV_ID`
    )),
    COUNT(*)
FROM
    nexuses.`key_EV_Event_1st`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1;
-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- BigQuery does not enforce primary or foreign keys, and it has no unique constraints. The primary and foreign keys are declared,
-- which tells the optimizer to trust them; a unique key is only a rule of the model. A violation is therefore not an error, but
-- wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--   restatement                                   in an attribute or a tie that may not store them, a value
--                                                 that is the same as the one before it in changing time
--
-- A view that returns nothing has nothing wrong. IntegrityViolations is all of them together; it reads every table.
-- It also has the checks of the natural keys, ic_key_<anchor or nexus>_<route>, which are made with the keys: a key
-- that more than one identity has (duplicate natural key), and an identity with more than one key (more than one
-- natural key).
--
--   Construct     the table
--   Violation     what is wrong
--   ViolationKey  the key of the rows, as an object of column and value
--   Occurrences   how many rows
--
-- The orphan checks join to the table that is referred to and look for the rows without a match. They use a
-- column of the referred table in the WHERE clause, so a foreign key cannot make the optimizer drop the join.
--
-- PAT_ParentalType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_PAT_ParentalType` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PAT_ParentalType',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PAT_ID` AS `PAT_ID`)),
    COUNT(*)
FROM
    knots.`PAT_ParentalType`
GROUP BY
    `PAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PAT_ParentalType',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`PAT_ParentalType` AS `PAT_ParentalType`)),
    COUNT(*)
FROM
    knots.`PAT_ParentalType`
GROUP BY
    `PAT_ParentalType`
HAVING
    COUNT(*) > 1;
-- GEN_Gender integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_GEN_Gender` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'GEN_Gender',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`GEN_ID` AS `GEN_ID`)),
    COUNT(*)
FROM
    knots.`GEN_Gender`
GROUP BY
    `GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Gender',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`GEN_Checksum` AS `GEN_Checksum`)),
    COUNT(*)
FROM
    knots.`GEN_Gender`
GROUP BY
    `GEN_Checksum`
HAVING
    COUNT(*) > 1;
-- PLV_ProfessionalLevel integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_PLV_ProfessionalLevel` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PLV_ProfessionalLevel',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PLV_ID` AS `PLV_ID`)),
    COUNT(*)
FROM
    knots.`PLV_ProfessionalLevel`
GROUP BY
    `PLV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PLV_ProfessionalLevel',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`PLV_Checksum` AS `PLV_Checksum`)),
    COUNT(*)
FROM
    knots.`PLV_ProfessionalLevel`
GROUP BY
    `PLV_Checksum`
HAVING
    COUNT(*) > 1;
-- UTL_Utilization integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_UTL_Utilization` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'UTL_Utilization',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`UTL_ID` AS `UTL_ID`)),
    COUNT(*)
FROM
    knots.`UTL_Utilization`
GROUP BY
    `UTL_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'UTL_Utilization',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`UTL_Utilization` AS `UTL_Utilization`)),
    COUNT(*)
FROM
    knots.`UTL_Utilization`
GROUP BY
    `UTL_Utilization`
HAVING
    COUNT(*) > 1;
-- ONG_Ongoing integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_ONG_Ongoing` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ONG_Ongoing',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ONG_ID` AS `ONG_ID`)),
    COUNT(*)
FROM
    knots.`ONG_Ongoing`
GROUP BY
    `ONG_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ONG_Ongoing',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`ONG_Ongoing` AS `ONG_Ongoing`)),
    COUNT(*)
FROM
    knots.`ONG_Ongoing`
GROUP BY
    `ONG_Ongoing`
HAVING
    COUNT(*) > 1;
-- RAT_Rating integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_RAT_Rating` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'RAT_Rating',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`RAT_ID` AS `RAT_ID`)),
    COUNT(*)
FROM
    knots.`RAT_Rating`
GROUP BY
    `RAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Rating',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`RAT_Checksum` AS `RAT_Checksum`)),
    COUNT(*)
FROM
    knots.`RAT_Rating`
GROUP BY
    `RAT_Checksum`
HAVING
    COUNT(*) > 1;
-- ETY_EventType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW knots.`ic_ETY_EventType` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ETY_EventType',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ETY_ID` AS `ETY_ID`)),
    COUNT(*)
FROM
    knots.`ETY_EventType`
GROUP BY
    `ETY_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_EventType',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`ETY_Checksum` AS `ETY_Checksum`)),
    COUNT(*)
FROM
    knots.`ETY_EventType`
GROUP BY
    `ETY_Checksum`
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_PN_Person` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PN_Person',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PN_ID` AS `PN_ID`)),
    COUNT(*)
FROM
    anchors.`PN_Person`
GROUP BY
    `PN_ID`
HAVING
    COUNT(*) > 1;
-- ST_Stage integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_ST_Stage` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_Stage',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_ID` AS `ST_ID`)),
    COUNT(*)
FROM
    anchors.`ST_Stage`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- AC_Actor integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_AC_Actor` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_Actor',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_ID` AS `AC_ID`)),
    COUNT(*)
FROM
    anchors.`AC_Actor`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- PR_Program integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`ic_PR_Program` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_Program',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_ID` AS `PR_ID`)),
    COUNT(*)
FROM
    anchors.`PR_Program`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1;
-- EV_Event integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`ic_EV_Event` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_Event',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_ID` AS `EV_ID`)),
    COUNT(*)
FROM
    nexuses.`EV_Event`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_Event',
    'no row in ST_Stage for ST_ID_wasHeldAt',
    TO_JSON_STRING(STRUCT(c.`ST_ID_wasHeldAt` AS `ST_ID_wasHeldAt`)),
    COUNT(*)
FROM
    nexuses.`EV_Event` c
LEFT JOIN
    anchors.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_wasHeldAt`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_wasHeldAt`
UNION ALL
SELECT
    'EV_Event',
    'no row in PR_Program for PR_ID_wasPlayed',
    TO_JSON_STRING(STRUCT(c.`PR_ID_wasPlayed` AS `PR_ID_wasPlayed`)),
    COUNT(*)
FROM
    nexuses.`EV_Event` c
LEFT JOIN
    anchors.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_wasPlayed`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_wasPlayed`
UNION ALL
SELECT
    'EV_Event',
    'no row in ETY_EventType for ETY_ID_of',
    TO_JSON_STRING(STRUCT(c.`ETY_ID_of` AS `ETY_ID_of`)),
    COUNT(*)
FROM
    nexuses.`EV_Event` c
LEFT JOIN
    knots.`ETY_EventType` p
ON
    p.`ETY_ID` = c.`ETY_ID_of`
WHERE
    p.`ETY_ID` IS NULL
GROUP BY
    c.`ETY_ID_of`
;
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_DAT_Event_Date` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_DAT_Event_Date',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_DAT_Event_Date`
GROUP BY
    `EV_DAT_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date',
    'no row in EV_Event for EV_DAT_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_DAT_EV_ID` AS `EV_DAT_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_DAT_Event_Date` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_DAT_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_DAT_EV_ID`
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_AUD_Event_Audience` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_AUD_Event_Audience',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_AUD_Event_Audience`
GROUP BY
    `EV_AUD_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience',
    'no row in EV_Event for EV_AUD_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_AUD_EV_ID` AS `EV_AUD_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_AUD_Event_Audience` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_AUD_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_AUD_EV_ID`
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_REV_Event_Revenue` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_REV_Event_Revenue',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_REV_Event_Revenue`
GROUP BY
    `EV_REV_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue',
    'no row in EV_Event for EV_REV_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_REV_EV_ID` AS `EV_REV_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_REV_Event_Revenue` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_REV_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_REV_EV_ID`
;
-- EV_STA_Event_Status integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_STA_Event_Status` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_STA_Event_Status',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_STA_EV_ID` AS `EV_STA_EV_ID`,
        `EV_STA_ChangedAt` AS `EV_STA_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`EV_STA_Event_Status`
GROUP BY
    `EV_STA_EV_ID`,
    `EV_STA_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_STA_Event_Status',
    'no row in EV_Event for EV_STA_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_STA_EV_ID` AS `EV_STA_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_STA_Event_Status` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_STA_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_STA_EV_ID`
UNION ALL
SELECT
    'EV_STA_Event_Status',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `EV_STA_EV_ID` AS `EV_STA_EV_ID`,
        `EV_STA_ChangedAt` AS `EV_STA_ChangedAt`
    )),
    1
FROM (
    SELECT
        `EV_STA_EV_ID`,
        `EV_STA_ChangedAt`,
        `EV_STA_Event_Status` AS compared,
        LAG(`EV_STA_Event_Status`) OVER (
            PARTITION BY
                `EV_STA_EV_ID`
            ORDER BY
                `EV_STA_ChangedAt`
        ) AS previous
    FROM
        attributes.`EV_STA_Event_Status`
)
WHERE
    compared = previous
;
-- EV_UTL_Event_Utilization integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_UTL_Event_Utilization` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_UTL_Event_Utilization',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_UTL_EV_ID` AS `EV_UTL_EV_ID`
    )),
    COUNT(*)
FROM
    attributes.`EV_UTL_Event_Utilization`
GROUP BY
    `EV_UTL_EV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_UTL_Event_Utilization',
    'no row in EV_Event for EV_UTL_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_UTL_EV_ID` AS `EV_UTL_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_UTL_Event_Utilization` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_UTL_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_UTL_EV_ID`
UNION ALL
SELECT
    'EV_UTL_Event_Utilization',
    'no row in UTL_Utilization for EV_UTL_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`EV_UTL_UTL_ID` AS `EV_UTL_UTL_ID`)),
    COUNT(*)
FROM
    attributes.`EV_UTL_Event_Utilization` c
LEFT JOIN
    knots.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`EV_UTL_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`EV_UTL_UTL_ID`
;
-- EV_LVL_Event_Level integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_EV_LVL_Event_Level` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_LVL_Event_Level',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_LVL_EV_ID` AS `EV_LVL_EV_ID`,
        `EV_LVL_ChangedAt` AS `EV_LVL_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`EV_LVL_Event_Level`
GROUP BY
    `EV_LVL_EV_ID`,
    `EV_LVL_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_LVL_Event_Level',
    'no row in EV_Event for EV_LVL_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_LVL_EV_ID` AS `EV_LVL_EV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_LVL_Event_Level` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_LVL_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_LVL_EV_ID`
UNION ALL
SELECT
    'EV_LVL_Event_Level',
    'no row in PLV_ProfessionalLevel for EV_LVL_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_LVL_PLV_ID` AS `EV_LVL_PLV_ID`)),
    COUNT(*)
FROM
    attributes.`EV_LVL_Event_Level` c
LEFT JOIN
    knots.`PLV_ProfessionalLevel` p
ON
    p.`PLV_ID` = c.`EV_LVL_PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`EV_LVL_PLV_ID`
UNION ALL
SELECT
    'EV_LVL_Event_Level',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `EV_LVL_EV_ID` AS `EV_LVL_EV_ID`,
        `EV_LVL_ChangedAt` AS `EV_LVL_ChangedAt`
    )),
    1
FROM (
    SELECT
        `EV_LVL_EV_ID`,
        `EV_LVL_ChangedAt`,
        `EV_LVL_PLV_ID` AS compared,
        LAG(`EV_LVL_PLV_ID`) OVER (
            PARTITION BY
                `EV_LVL_EV_ID`
            ORDER BY
                `EV_LVL_ChangedAt`
        ) AS previous
    FROM
        attributes.`EV_LVL_Event_Level`
)
WHERE
    compared = previous
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_NAM_Stage_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_NAM_Stage_Name',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`ST_NAM_Stage_Name`
GROUP BY
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name',
    'no row in ST_Stage for ST_NAM_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_NAM_ST_ID` AS `ST_NAM_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_NAM_Stage_Name` c
LEFT JOIN
    anchors.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_NAM_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_NAM_ST_ID`
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_LOC_Stage_Location` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_LOC_Stage_Location',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`
    )),
    COUNT(*)
FROM
    attributes.`ST_LOC_Stage_Location`
GROUP BY
    `ST_LOC_ST_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location',
    'no row in ST_Stage for ST_LOC_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_LOC_ST_ID` AS `ST_LOC_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_LOC_Stage_Location` c
LEFT JOIN
    anchors.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_LOC_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_LOC_ST_ID`
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_AVG_Stage_Average` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_AVG_Stage_Average',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`ST_AVG_Stage_Average`
GROUP BY
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'no row in ST_Stage for ST_AVG_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_ST_ID` AS `ST_AVG_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_AVG_Stage_Average` c
LEFT JOIN
    anchors.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_AVG_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_AVG_ST_ID`
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'no row in UTL_Utilization for ST_AVG_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_UTL_ID` AS `ST_AVG_UTL_ID`)),
    COUNT(*)
FROM
    attributes.`ST_AVG_Stage_Average` c
LEFT JOIN
    knots.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`ST_AVG_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_AVG_UTL_ID`
UNION ALL
SELECT
    'ST_AVG_Stage_Average',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`
    )),
    1
FROM (
    SELECT
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`,
        `ST_AVG_UTL_ID` AS compared,
        LAG(`ST_AVG_UTL_ID`) OVER (
            PARTITION BY
                `ST_AVG_ST_ID`
            ORDER BY
                `ST_AVG_ChangedAt`
        ) AS previous
    FROM
        attributes.`ST_AVG_Stage_Average`
)
WHERE
    compared = previous
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_ST_MIN_Stage_Minimum` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_MIN_Stage_Minimum',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`
    )),
    COUNT(*)
FROM
    attributes.`ST_MIN_Stage_Minimum`
GROUP BY
    `ST_MIN_ST_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum',
    'no row in ST_Stage for ST_MIN_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_ST_ID` AS `ST_MIN_ST_ID`)),
    COUNT(*)
FROM
    attributes.`ST_MIN_Stage_Minimum` c
LEFT JOIN
    anchors.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_MIN_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_MIN_ST_ID`
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum',
    'no row in UTL_Utilization for ST_MIN_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_UTL_ID` AS `ST_MIN_UTL_ID`)),
    COUNT(*)
FROM
    attributes.`ST_MIN_Stage_Minimum` c
LEFT JOIN
    knots.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`ST_MIN_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_MIN_UTL_ID`
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_AC_NAM_Actor_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_NAM_Actor_Name',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`AC_NAM_Actor_Name`
GROUP BY
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'no row in AC_Actor for AC_NAM_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_NAM_AC_ID` AS `AC_NAM_AC_ID`)),
    COUNT(*)
FROM
    attributes.`AC_NAM_Actor_Name` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_NAM_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_NAM_AC_ID`
UNION ALL
SELECT
    'AC_NAM_Actor_Name',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`
    )),
    1
FROM (
    SELECT
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`,
        `AC_NAM_Actor_Name` AS compared,
        LAG(`AC_NAM_Actor_Name`) OVER (
            PARTITION BY
                `AC_NAM_AC_ID`
            ORDER BY
                `AC_NAM_ChangedAt`
        ) AS previous
    FROM
        attributes.`AC_NAM_Actor_Name`
)
WHERE
    compared = previous
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_AC_GEN_Actor_Gender` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_GEN_Actor_Gender',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`
    )),
    COUNT(*)
FROM
    attributes.`AC_GEN_Actor_Gender`
GROUP BY
    `AC_GEN_AC_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender',
    'no row in AC_Actor for AC_GEN_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_AC_ID` AS `AC_GEN_AC_ID`)),
    COUNT(*)
FROM
    attributes.`AC_GEN_Actor_Gender` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_GEN_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_GEN_AC_ID`
UNION ALL
SELECT
    'AC_GEN_Actor_Gender',
    'no row in GEN_Gender for AC_GEN_GEN_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_GEN_ID` AS `AC_GEN_GEN_ID`)),
    COUNT(*)
FROM
    attributes.`AC_GEN_Actor_Gender` c
LEFT JOIN
    knots.`GEN_Gender` p
ON
    p.`GEN_ID` = c.`AC_GEN_GEN_ID`
WHERE
    p.`GEN_ID` IS NULL
GROUP BY
    c.`AC_GEN_GEN_ID`
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_AC_PLV_Actor_ProfessionalLevel` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel`
GROUP BY
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in AC_Actor for AC_PLV_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_AC_ID` AS `AC_PLV_AC_ID`)),
    COUNT(*)
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_PLV_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_PLV_AC_ID`
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in PLV_ProfessionalLevel for AC_PLV_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_PLV_ID` AS `AC_PLV_PLV_ID`)),
    COUNT(*)
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel` c
LEFT JOIN
    knots.`PLV_ProfessionalLevel` p
ON
    p.`PLV_ID` = c.`AC_PLV_PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`AC_PLV_PLV_ID`
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_PR_NAM_Program_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_NAM_Program_Name',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`
    )),
    COUNT(*)
FROM
    attributes.`PR_NAM_Program_Name`
GROUP BY
    `PR_NAM_PR_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name',
    'no row in PR_Program for PR_NAM_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_NAM_PR_ID` AS `PR_NAM_PR_ID`)),
    COUNT(*)
FROM
    attributes.`PR_NAM_Program_Name` c
LEFT JOIN
    anchors.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_NAM_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_NAM_PR_ID`
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW attributes.`ic_PR_LEN_Program_Length` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_LEN_Program_Length',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`
    )),
    COUNT(*)
FROM
    attributes.`PR_LEN_Program_Length`
GROUP BY
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length',
    'no row in PR_Program for PR_LEN_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_LEN_PR_ID` AS `PR_LEN_PR_ID`)),
    COUNT(*)
FROM
    attributes.`PR_LEN_Program_Length` c
LEFT JOIN
    anchors.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_LEN_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_LEN_PR_ID`
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_partner_AC_with_ONG_currently` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_partner)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_partner`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'duplicate unique key (AC_with)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_with` AS `AC_ID_with`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_with`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_partner',
    TO_JSON_STRING(STRUCT(c.`AC_ID_partner` AS `AC_ID_partner`)),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_partner`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_partner`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_with',
    TO_JSON_STRING(STRUCT(c.`AC_ID_with` AS `AC_ID_with`)),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_with`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_with`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently',
    'no row in ONG_Ongoing for ONG_ID_currently',
    TO_JSON_STRING(STRUCT(c.`ONG_ID_currently` AS `ONG_ID_currently`)),
    COUNT(*)
FROM
    ties.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    knots.`ONG_Ongoing` p
ON
    p.`ONG_ID` = c.`ONG_ID_currently`
WHERE
    p.`ONG_ID` IS NULL
GROUP BY
    c.`ONG_ID_currently`
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_subset_PN_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_subset_PN_of',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    ties.`AC_subset_PN_of`
GROUP BY
    `AC_ID_subset`,
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (AC_subset)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`
    )),
    COUNT(*)
FROM
    ties.`AC_subset_PN_of`
GROUP BY
    `AC_ID_subset`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'duplicate unique key (PN_of)',
    TO_JSON_STRING(STRUCT(
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    ties.`AC_subset_PN_of`
GROUP BY
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in AC_Actor for AC_ID_subset',
    TO_JSON_STRING(STRUCT(c.`AC_ID_subset` AS `AC_ID_subset`)),
    COUNT(*)
FROM
    ties.`AC_subset_PN_of` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_subset`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_subset`
UNION ALL
SELECT
    'AC_subset_PN_of',
    'no row in PN_Person for PN_ID_of',
    TO_JSON_STRING(STRUCT(c.`PN_ID_of` AS `PN_ID_of`)),
    COUNT(*)
FROM
    ties.`AC_subset_PN_of` c
LEFT JOIN
    anchors.`PN_Person` p
ON
    p.`PN_ID` = c.`PN_ID_of`
WHERE
    p.`PN_ID` IS NULL
GROUP BY
    c.`PN_ID_of`
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_EV_in_AC_wasCast` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_in_AC_wasCast',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`
    )),
    COUNT(*)
FROM
    ties.`EV_in_AC_wasCast`
GROUP BY
    `EV_ID_in`,
    `AC_ID_wasCast`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast',
    'no row in EV_Event for EV_ID_in',
    TO_JSON_STRING(STRUCT(c.`EV_ID_in` AS `EV_ID_in`)),
    COUNT(*)
FROM
    ties.`EV_in_AC_wasCast` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID_in`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_in`
UNION ALL
SELECT
    'EV_in_AC_wasCast',
    'no row in AC_Actor for AC_ID_wasCast',
    TO_JSON_STRING(STRUCT(c.`AC_ID_wasCast` AS `AC_ID_wasCast`)),
    COUNT(*)
FROM
    ties.`EV_in_AC_wasCast` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_wasCast`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_wasCast`
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_part_PR_in_RAT_got` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_part_PR_in_RAT_got',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`AC_part_PR_in_RAT_got`
GROUP BY
    `AC_ID_part`,
    `PR_ID_in`,
    `AC_part_PR_in_RAT_got_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in AC_Actor for AC_ID_part',
    TO_JSON_STRING(STRUCT(c.`AC_ID_part` AS `AC_ID_part`)),
    COUNT(*)
FROM
    ties.`AC_part_PR_in_RAT_got` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_part`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_part`
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in PR_Program for PR_ID_in',
    TO_JSON_STRING(STRUCT(c.`PR_ID_in` AS `PR_ID_in`)),
    COUNT(*)
FROM
    ties.`AC_part_PR_in_RAT_got` c
LEFT JOIN
    anchors.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_in`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_in`
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'no row in RAT_Rating for RAT_ID_got',
    TO_JSON_STRING(STRUCT(c.`RAT_ID_got` AS `RAT_ID_got`)),
    COUNT(*)
FROM
    ties.`AC_part_PR_in_RAT_got` c
LEFT JOIN
    knots.`RAT_Rating` p
ON
    p.`RAT_ID` = c.`RAT_ID_got`
WHERE
    p.`RAT_ID` IS NULL
GROUP BY
    c.`RAT_ID_got`
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got',
    'restatement',
    TO_JSON_STRING(STRUCT(
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`
    )),
    1
FROM (
    SELECT
        `AC_ID_part`,
        `PR_ID_in`,
        `RAT_ID_got`,
        LAG(`RAT_ID_got`) OVER (
            PARTITION BY
                `AC_ID_part`,
                `PR_ID_in`
            ORDER BY
                `AC_part_PR_in_RAT_got_ChangedAt`
        ) AS `previous_RAT_ID_got`,
        `AC_part_PR_in_RAT_got_ChangedAt`
    FROM
        ties.`AC_part_PR_in_RAT_got`
)
WHERE
    `RAT_ID_got` = `previous_RAT_ID_got`
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_ST_at_PR_isPlaying` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_at_PR_isPlaying',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`ST_at_PR_isPlaying`
GROUP BY
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying',
    'no row in ST_Stage for ST_ID_at',
    TO_JSON_STRING(STRUCT(c.`ST_ID_at` AS `ST_ID_at`)),
    COUNT(*)
FROM
    ties.`ST_at_PR_isPlaying` c
LEFT JOIN
    anchors.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_at`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_at`
UNION ALL
SELECT
    'ST_at_PR_isPlaying',
    'no row in PR_Program for PR_ID_isPlaying',
    TO_JSON_STRING(STRUCT(c.`PR_ID_isPlaying` AS `PR_ID_isPlaying`)),
    COUNT(*)
FROM
    ties.`ST_at_PR_isPlaying` c
LEFT JOIN
    anchors.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_isPlaying`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_isPlaying`
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_AC_parent_AC_child_PAT_having` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_parent_AC_child_PAT_having',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`
    )),
    COUNT(*)
FROM
    ties.`AC_parent_AC_child_PAT_having`
GROUP BY
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_parent',
    TO_JSON_STRING(STRUCT(c.`AC_ID_parent` AS `AC_ID_parent`)),
    COUNT(*)
FROM
    ties.`AC_parent_AC_child_PAT_having` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_parent`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_parent`
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_child',
    TO_JSON_STRING(STRUCT(c.`AC_ID_child` AS `AC_ID_child`)),
    COUNT(*)
FROM
    ties.`AC_parent_AC_child_PAT_having` c
LEFT JOIN
    anchors.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_child`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_child`
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having',
    'no row in PAT_ParentalType for PAT_ID_having',
    TO_JSON_STRING(STRUCT(c.`PAT_ID_having` AS `PAT_ID_having`)),
    COUNT(*)
FROM
    ties.`AC_parent_AC_child_PAT_having` c
LEFT JOIN
    knots.`PAT_ParentalType` p
ON
    p.`PAT_ID` = c.`PAT_ID_having`
WHERE
    p.`PAT_ID` IS NULL
GROUP BY
    c.`PAT_ID_having`
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`ic_PR_content_ST_location_EV_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_content_ST_location_EV_of',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_ID_content` AS `PR_ID_content`,
        `ST_ID_location` AS `ST_ID_location`,
        `EV_ID_of` AS `EV_ID_of`,
        `PR_content_ST_location_EV_of_ChangedAt` AS `PR_content_ST_location_EV_of_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`PR_content_ST_location_EV_of`
GROUP BY
    `PR_ID_content`,
    `ST_ID_location`,
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'duplicate unique key (PR_content)',
    TO_JSON_STRING(STRUCT(
        `PR_ID_content` AS `PR_ID_content`,
        `PR_content_ST_location_EV_of_ChangedAt` AS `PR_content_ST_location_EV_of_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`PR_content_ST_location_EV_of`
GROUP BY
    `PR_ID_content`,
    `PR_content_ST_location_EV_of_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'duplicate unique key (ST_location)',
    TO_JSON_STRING(STRUCT(
        `ST_ID_location` AS `ST_ID_location`,
        `PR_content_ST_location_EV_of_ChangedAt` AS `PR_content_ST_location_EV_of_ChangedAt`
    )),
    COUNT(*)
FROM
    ties.`PR_content_ST_location_EV_of`
GROUP BY
    `ST_ID_location`,
    `PR_content_ST_location_EV_of_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in PR_Program for PR_ID_content',
    TO_JSON_STRING(STRUCT(c.`PR_ID_content` AS `PR_ID_content`)),
    COUNT(*)
FROM
    ties.`PR_content_ST_location_EV_of` c
LEFT JOIN
    anchors.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_content`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_content`
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in ST_Stage for ST_ID_location',
    TO_JSON_STRING(STRUCT(c.`ST_ID_location` AS `ST_ID_location`)),
    COUNT(*)
FROM
    ties.`PR_content_ST_location_EV_of` c
LEFT JOIN
    anchors.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_location`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_location`
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in EV_Event for EV_ID_of',
    TO_JSON_STRING(STRUCT(c.`EV_ID_of` AS `EV_ID_of`)),
    COUNT(*)
FROM
    ties.`PR_content_ST_location_EV_of` c
LEFT JOIN
    nexuses.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID_of`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_of`
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW dw.IntegrityViolations (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    CAST(NULL AS VARCHAR),
    CAST(NULL AS VARCHAR),
    CAST(NULL AS OBJECT),
    CAST(NULL AS NUMBER)
WHERE
    FALSE
UNION ALL SELECT * FROM knots.`ic_PAT_ParentalType`
UNION ALL SELECT * FROM knots.`ic_GEN_Gender`
UNION ALL SELECT * FROM knots.`ic_PLV_ProfessionalLevel`
UNION ALL SELECT * FROM knots.`ic_UTL_Utilization`
UNION ALL SELECT * FROM knots.`ic_ONG_Ongoing`
UNION ALL SELECT * FROM knots.`ic_RAT_Rating`
UNION ALL SELECT * FROM knots.`ic_ETY_EventType`
UNION ALL SELECT * FROM anchors.`ic_PN_Person`
UNION ALL SELECT * FROM anchors.`ic_ST_Stage`
UNION ALL SELECT * FROM anchors.`ic_AC_Actor`
UNION ALL SELECT * FROM anchors.`ic_PR_Program`
UNION ALL SELECT * FROM nexuses.`ic_EV_Event`
UNION ALL SELECT * FROM attributes.`ic_EV_DAT_Event_Date`
UNION ALL SELECT * FROM attributes.`ic_EV_AUD_Event_Audience`
UNION ALL SELECT * FROM attributes.`ic_EV_REV_Event_Revenue`
UNION ALL SELECT * FROM attributes.`ic_EV_STA_Event_Status`
UNION ALL SELECT * FROM attributes.`ic_EV_UTL_Event_Utilization`
UNION ALL SELECT * FROM attributes.`ic_EV_LVL_Event_Level`
UNION ALL SELECT * FROM attributes.`ic_ST_NAM_Stage_Name`
UNION ALL SELECT * FROM attributes.`ic_ST_LOC_Stage_Location`
UNION ALL SELECT * FROM attributes.`ic_ST_AVG_Stage_Average`
UNION ALL SELECT * FROM attributes.`ic_ST_MIN_Stage_Minimum`
UNION ALL SELECT * FROM attributes.`ic_AC_NAM_Actor_Name`
UNION ALL SELECT * FROM attributes.`ic_AC_GEN_Actor_Gender`
UNION ALL SELECT * FROM attributes.`ic_AC_PLV_Actor_ProfessionalLevel`
UNION ALL SELECT * FROM attributes.`ic_PR_NAM_Program_Name`
UNION ALL SELECT * FROM attributes.`ic_PR_LEN_Program_Length`
UNION ALL SELECT * FROM ties.`ic_AC_partner_AC_with_ONG_currently`
UNION ALL SELECT * FROM ties.`ic_AC_subset_PN_of`
UNION ALL SELECT * FROM ties.`ic_EV_in_AC_wasCast`
UNION ALL SELECT * FROM ties.`ic_AC_part_PR_in_RAT_got`
UNION ALL SELECT * FROM ties.`ic_ST_at_PR_isPlaying`
UNION ALL SELECT * FROM ties.`ic_AC_parent_AC_child_PAT_having`
UNION ALL SELECT * FROM ties.`ic_PR_content_ST_location_EV_of`
UNION ALL SELECT * FROM anchors.`ic_key_ST_Stage_1st`
UNION ALL SELECT * FROM anchors.`ic_key_ST_Stage_2nd`
UNION ALL SELECT * FROM anchors.`ic_key_AC_Actor_1st`
UNION ALL SELECT * FROM anchors.`ic_key_PR_Program_1st`
UNION ALL SELECT * FROM nexuses.`ic_key_EV_Event_1st`
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
