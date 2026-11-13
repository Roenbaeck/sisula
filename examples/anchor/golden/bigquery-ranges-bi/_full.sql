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
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
-- BigQuery has no sequences: the load gives an identity to every posit. Its keys are not enforced, and it has no unique
-- constraints: what a posit table holds once is kept so by the load (the integrity checks tell if it has not).
--
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Event_Date_Fact` (
    `EV_DAT_ID` int64 not null,
    `EV_DAT_EV_ID` numeric(12,0) not null,
    `EV_DAT_Event_Date` datetime not null,
    PRIMARY KEY (
        `EV_DAT_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date_Fact` FOREIGN KEY (`EV_DAT_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Meta table (of EV_DAT_Event_Date_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Event_Date_Meta` (
    `EV_DAT_ID` int64 not null,
    `EV_DAT_PositedAt` datetime not null,
    `EV_DAT_Confidence` numeric(7,3) not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_ID`,
        `EV_DAT_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date_Meta` FOREIGN KEY (`EV_DAT_ID`) REFERENCES
        attributes.`EV_DAT_Event_Date_Fact`(`EV_DAT_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_ID`, `EV_DAT_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Event_Audience_Fact` (
    `EV_AUD_ID` int64 not null,
    `EV_AUD_EV_ID` numeric(12,0) not null,
    `EV_AUD_Event_Audience` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience_Fact` FOREIGN KEY (`EV_AUD_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Meta table (of EV_AUD_Event_Audience_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Event_Audience_Meta` (
    `EV_AUD_ID` int64 not null,
    `EV_AUD_PositedAt` datetime not null,
    `EV_AUD_Confidence` numeric(7,3) not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`,
        `EV_AUD_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience_Meta` FOREIGN KEY (`EV_AUD_ID`) REFERENCES
        attributes.`EV_AUD_Event_Audience_Fact`(`EV_AUD_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_ID`, `EV_AUD_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Event_Revenue_Fact` (
    `EV_REV_ID` int64 not null,
    `EV_REV_EV_ID` numeric(12,0) not null,
    `EV_REV_Event_Revenue` numeric(19,4) not null,
    PRIMARY KEY (
        `EV_REV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue_Fact` FOREIGN KEY (`EV_REV_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Meta table (of EV_REV_Event_Revenue_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Event_Revenue_Meta` (
    `EV_REV_ID` int64 not null,
    `EV_REV_PositedAt` datetime not null,
    `EV_REV_Confidence` numeric(7,3) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_ID`,
        `EV_REV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue_Meta` FOREIGN KEY (`EV_REV_ID`) REFERENCES
        attributes.`EV_REV_Event_Revenue_Fact`(`EV_REV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_ID`, `EV_REV_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Event_Status_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Event_Status_Fact` (
    `EV_STA_ID` int64 not null,
    `EV_STA_EV_ID` numeric(12,0) not null,
    `EV_STA_Event_Status` string(20) not null,
    `EV_STA_ChangedAt` datetime not null,
    PRIMARY KEY (
        `EV_STA_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Event_Status_Fact` FOREIGN KEY (`EV_STA_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Event_Status_Meta table (of EV_STA_Event_Status_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Event_Status_Meta` (
    `EV_STA_ID` int64 not null,
    `EV_STA_PositedAt` datetime not null,
    `EV_STA_Confidence` numeric(7,3) not null,
    `Metadata_EV_STA` int64 not null,
    PRIMARY KEY (
        `EV_STA_ID`,
        `EV_STA_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Event_Status_Meta` FOREIGN KEY (`EV_STA_ID`) REFERENCES
        attributes.`EV_STA_Event_Status_Fact`(`EV_STA_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_ID`, `EV_STA_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Event_Utilization_Fact` (
    `EV_UTL_ID` int64 not null,
    `EV_UTL_EV_ID` numeric(12,0) not null,
    `EV_UTL_UTL_ID` int64 not null,
    PRIMARY KEY (
        `EV_UTL_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_UTL_Event_Utilization_Fact` FOREIGN KEY (`EV_UTL_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_UTL_Event_Utilization_Fact` FOREIGN KEY (`EV_UTL_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Meta table (of EV_UTL_Event_Utilization_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Event_Utilization_Meta` (
    `EV_UTL_ID` int64 not null,
    `EV_UTL_PositedAt` datetime not null,
    `EV_UTL_Confidence` numeric(7,3) not null,
    `Metadata_EV_UTL` int64 not null,
    PRIMARY KEY (
        `EV_UTL_ID`,
        `EV_UTL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_UTL_Event_Utilization_Meta` FOREIGN KEY (`EV_UTL_ID`) REFERENCES
        attributes.`EV_UTL_Event_Utilization_Fact`(`EV_UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_ID`, `EV_UTL_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Event_Level_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Event_Level_Fact` (
    `EV_LVL_ID` int64 not null,
    `EV_LVL_EV_ID` numeric(12,0) not null,
    `EV_LVL_PLV_ID` int64 not null,
    `EV_LVL_ChangedAt` date not null,
    PRIMARY KEY (
        `EV_LVL_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_LVL_Event_Level_Fact` FOREIGN KEY (`EV_LVL_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_LVL_Event_Level_Fact` FOREIGN KEY (`EV_LVL_PLV_ID`) REFERENCES
        knots.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level_Meta table (of EV_LVL_Event_Level_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Event_Level_Meta` (
    `EV_LVL_ID` int64 not null,
    `EV_LVL_PositedAt` datetime not null,
    `EV_LVL_Confidence` numeric(7,3) not null,
    `Metadata_EV_LVL` int64 not null,
    PRIMARY KEY (
        `EV_LVL_ID`,
        `EV_LVL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_LVL_Event_Level_Meta` FOREIGN KEY (`EV_LVL_ID`) REFERENCES
        attributes.`EV_LVL_Event_Level_Fact`(`EV_LVL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_ID`, `EV_LVL_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Stage_Name_Fact` (
    `ST_NAM_ID` int64 not null,
    `ST_NAM_ST_ID` int64 not null,
    `ST_NAM_Stage_Name` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name_Fact` FOREIGN KEY (`ST_NAM_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Meta table (of ST_NAM_Stage_Name_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Stage_Name_Meta` (
    `ST_NAM_ID` int64 not null,
    `ST_NAM_PositedAt` datetime not null,
    `ST_NAM_Confidence` numeric(7,3) not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ID`,
        `ST_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name_Meta` FOREIGN KEY (`ST_NAM_ID`) REFERENCES
        attributes.`ST_NAM_Stage_Name_Fact`(`ST_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ID`, `ST_NAM_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Stage_Location_Fact` (
    `ST_LOC_ID` int64 not null,
    `ST_LOC_ST_ID` int64 not null,
    `ST_LOC_Stage_Location` geography not null,
    `ST_LOC_Checksum` int64,
    PRIMARY KEY (
        `ST_LOC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location_Fact` FOREIGN KEY (`ST_LOC_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Meta table (of ST_LOC_Stage_Location_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Stage_Location_Meta` (
    `ST_LOC_ID` int64 not null,
    `ST_LOC_PositedAt` datetime not null,
    `ST_LOC_Confidence` numeric(7,3) not null,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ID`,
        `ST_LOC_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location_Meta` FOREIGN KEY (`ST_LOC_ID`) REFERENCES
        attributes.`ST_LOC_Stage_Location_Fact`(`ST_LOC_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ID`, `ST_LOC_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Stage_Average_Fact` (
    `ST_AVG_ID` int64 not null,
    `ST_AVG_ST_ID` int64 not null,
    `ST_AVG_UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_AVG_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Stage_Average_Fact` FOREIGN KEY (`ST_AVG_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Stage_Average_Fact` FOREIGN KEY (`ST_AVG_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Meta table (of ST_AVG_Stage_Average_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Stage_Average_Meta` (
    `ST_AVG_ID` int64 not null,
    `ST_AVG_PositedAt` datetime not null,
    `ST_AVG_Confidence` numeric(7,3) not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ID`,
        `ST_AVG_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_AVG_Stage_Average_Meta` FOREIGN KEY (`ST_AVG_ID`) REFERENCES
        attributes.`ST_AVG_Stage_Average_Fact`(`ST_AVG_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ID`, `ST_AVG_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Stage_Minimum_Fact` (
    `ST_MIN_ID` int64 not null,
    `ST_MIN_ST_ID` int64 not null,
    `ST_MIN_UTL_ID` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Stage_Minimum_Fact` FOREIGN KEY (`ST_MIN_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Stage_Minimum_Fact` FOREIGN KEY (`ST_MIN_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Meta table (of ST_MIN_Stage_Minimum_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Stage_Minimum_Meta` (
    `ST_MIN_ID` int64 not null,
    `ST_MIN_PositedAt` datetime not null,
    `ST_MIN_Confidence` numeric(7,3) not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`,
        `ST_MIN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_MIN_Stage_Minimum_Meta` FOREIGN KEY (`ST_MIN_ID`) REFERENCES
        attributes.`ST_MIN_Stage_Minimum_Fact`(`ST_MIN_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ID`, `ST_MIN_PositedAt`;
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Actor_Name_Fact` (
    `AC_NAM_ID` int64 not null,
    `AC_NAM_AC_ID` int64 not null,
    `AC_NAM_Actor_Name` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name_Fact` FOREIGN KEY (`AC_NAM_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Meta table (of AC_NAM_Actor_Name_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Actor_Name_Meta` (
    `AC_NAM_ID` int64 not null,
    `AC_NAM_PositedAt` datetime not null,
    `AC_NAM_Confidence` numeric(7,3) not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_ID`,
        `AC_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name_Meta` FOREIGN KEY (`AC_NAM_ID`) REFERENCES
        attributes.`AC_NAM_Actor_Name_Fact`(`AC_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_ID`, `AC_NAM_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Actor_Gender_Fact` (
    `AC_GEN_ID` int64 not null,
    `AC_GEN_AC_ID` int64 not null,
    `AC_GEN_GEN_ID` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Actor_Gender_Fact` FOREIGN KEY (`AC_GEN_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Actor_Gender_Fact` FOREIGN KEY (`AC_GEN_GEN_ID`) REFERENCES
        knots.`GEN_Gender`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Meta table (of AC_GEN_Actor_Gender_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Actor_Gender_Meta` (
    `AC_GEN_ID` int64 not null,
    `AC_GEN_PositedAt` datetime not null,
    `AC_GEN_Confidence` numeric(7,3) not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`,
        `AC_GEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_GEN_Actor_Gender_Meta` FOREIGN KEY (`AC_GEN_ID`) REFERENCES
        attributes.`AC_GEN_Actor_Gender_Fact`(`AC_GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_ID`, `AC_GEN_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Actor_ProfessionalLevel_Fact` (
    `AC_PLV_ID` int64 not null,
    `AC_PLV_AC_ID` int64 not null,
    `AC_PLV_PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_PLV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Actor_ProfessionalLevel_Fact` FOREIGN KEY (`AC_PLV_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Actor_ProfessionalLevel_Fact` FOREIGN KEY (`AC_PLV_PLV_ID`) REFERENCES
        knots.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Meta table (of AC_PLV_Actor_ProfessionalLevel_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Actor_ProfessionalLevel_Meta` (
    `AC_PLV_ID` int64 not null,
    `AC_PLV_PositedAt` datetime not null,
    `AC_PLV_Confidence` numeric(7,3) not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_ID`,
        `AC_PLV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_PLV_Actor_ProfessionalLevel_Meta` FOREIGN KEY (`AC_PLV_ID`) REFERENCES
        attributes.`AC_PLV_Actor_ProfessionalLevel_Fact`(`AC_PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_ID`, `AC_PLV_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Program_Name_Fact` (
    `PR_NAM_ID` int64 not null,
    `PR_NAM_PR_ID` int64 not null,
    `PR_NAM_Program_Name` string(42) not null,
    PRIMARY KEY (
        `PR_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name_Fact` FOREIGN KEY (`PR_NAM_PR_ID`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Meta table (of PR_NAM_Program_Name_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Program_Name_Meta` (
    `PR_NAM_ID` int64 not null,
    `PR_NAM_PositedAt` datetime not null,
    `PR_NAM_Confidence` numeric(7,3) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_ID`,
        `PR_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name_Meta` FOREIGN KEY (`PR_NAM_ID`) REFERENCES
        attributes.`PR_NAM_Program_Name_Fact`(`PR_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_ID`, `PR_NAM_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Program_Length_Fact` (
    `PR_LEN_ID` int64 not null,
    `PR_LEN_PR_ID` int64 not null,
    `PR_LEN_Program_Length` time not null,
    `PR_LEN_ChangedAt` date not null,
    PRIMARY KEY (
        `PR_LEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length_Fact` FOREIGN KEY (`PR_LEN_PR_ID`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Meta table (of PR_LEN_Program_Length_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Program_Length_Meta` (
    `PR_LEN_ID` int64 not null,
    `PR_LEN_PositedAt` datetime not null,
    `PR_LEN_Confidence` numeric(7,3) not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_ID`,
        `PR_LEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length_Meta` FOREIGN KEY (`PR_LEN_ID`) REFERENCES
        attributes.`PR_LEN_Program_Length_Fact`(`PR_LEN_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_ID`, `PR_LEN_PositedAt`;
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes.`EV_DAT_Event_Date` AS
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Event_Date`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Confidence`
FROM
    attributes.`EV_DAT_Event_Date_Fact` p
JOIN
    attributes.`EV_DAT_Event_Date_Meta` a
ON
    a.`EV_DAT_ID` = p.`EV_DAT_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_AUD_Event_Audience` AS
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Event_Audience`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Confidence`
FROM
    attributes.`EV_AUD_Event_Audience_Fact` p
JOIN
    attributes.`EV_AUD_Event_Audience_Meta` a
ON
    a.`EV_AUD_ID` = p.`EV_AUD_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_REV_Event_Revenue` AS
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Event_Revenue`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Confidence`
FROM
    attributes.`EV_REV_Event_Revenue_Fact` p
JOIN
    attributes.`EV_REV_Event_Revenue_Meta` a
ON
    a.`EV_REV_ID` = p.`EV_REV_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_STA_Event_Status` AS
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Event_Status`,
    p.`EV_STA_ChangedAt`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Confidence`
FROM
    attributes.`EV_STA_Event_Status_Fact` p
JOIN
    attributes.`EV_STA_Event_Status_Meta` a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_UTL_Event_Utilization` AS
SELECT
    a.`Metadata_EV_UTL`,
    p.`EV_UTL_ID`,
    p.`EV_UTL_EV_ID`,
    p.`EV_UTL_UTL_ID`,
    a.`EV_UTL_PositedAt`,
    a.`EV_UTL_Confidence`
FROM
    attributes.`EV_UTL_Event_Utilization_Fact` p
JOIN
    attributes.`EV_UTL_Event_Utilization_Meta` a
ON
    a.`EV_UTL_ID` = p.`EV_UTL_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_LVL_Event_Level` AS
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Confidence`
FROM
    attributes.`EV_LVL_Event_Level_Fact` p
JOIN
    attributes.`EV_LVL_Event_Level_Meta` a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_NAM_Stage_Name` AS
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Confidence`
FROM
    attributes.`ST_NAM_Stage_Name_Fact` p
JOIN
    attributes.`ST_NAM_Stage_Name_Meta` a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_LOC_Stage_Location` AS
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Stage_Location`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Confidence`
FROM
    attributes.`ST_LOC_Stage_Location_Fact` p
JOIN
    attributes.`ST_LOC_Stage_Location_Meta` a
ON
    a.`ST_LOC_ID` = p.`ST_LOC_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_AVG_Stage_Average` AS
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Confidence`
FROM
    attributes.`ST_AVG_Stage_Average_Fact` p
JOIN
    attributes.`ST_AVG_Stage_Average_Meta` a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_MIN_Stage_Minimum` AS
SELECT
    a.`Metadata_ST_MIN`,
    p.`ST_MIN_ID`,
    p.`ST_MIN_ST_ID`,
    p.`ST_MIN_UTL_ID`,
    a.`ST_MIN_PositedAt`,
    a.`ST_MIN_Confidence`
FROM
    attributes.`ST_MIN_Stage_Minimum_Fact` p
JOIN
    attributes.`ST_MIN_Stage_Minimum_Meta` a
ON
    a.`ST_MIN_ID` = p.`ST_MIN_ID`
;
CREATE OR REPLACE VIEW attributes.`AC_NAM_Actor_Name` AS
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Confidence`
FROM
    attributes.`AC_NAM_Actor_Name_Fact` p
JOIN
    attributes.`AC_NAM_Actor_Name_Meta` a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
;
CREATE OR REPLACE VIEW attributes.`AC_GEN_Actor_Gender` AS
SELECT
    a.`Metadata_AC_GEN`,
    p.`AC_GEN_ID`,
    p.`AC_GEN_AC_ID`,
    p.`AC_GEN_GEN_ID`,
    a.`AC_GEN_PositedAt`,
    a.`AC_GEN_Confidence`
FROM
    attributes.`AC_GEN_Actor_Gender_Fact` p
JOIN
    attributes.`AC_GEN_Actor_Gender_Meta` a
ON
    a.`AC_GEN_ID` = p.`AC_GEN_ID`
;
CREATE OR REPLACE VIEW attributes.`AC_PLV_Actor_ProfessionalLevel` AS
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Confidence`
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel_Fact` p
JOIN
    attributes.`AC_PLV_Actor_ProfessionalLevel_Meta` a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
;
CREATE OR REPLACE VIEW attributes.`PR_NAM_Program_Name` AS
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Program_Name`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Confidence`
FROM
    attributes.`PR_NAM_Program_Name_Fact` p
JOIN
    attributes.`PR_NAM_Program_Name_Meta` a
ON
    a.`PR_NAM_ID` = p.`PR_NAM_ID`
;
CREATE OR REPLACE VIEW attributes.`PR_LEN_Program_Length` AS
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Confidence`
FROM
    attributes.`PR_LEN_Program_Length_Fact` p
JOIN
    attributes.`PR_LEN_Program_Length_Meta` a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Event_Date_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_DAT`,
    `EV_DAT_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Confidence`
FROM
    attributes.`EV_DAT_Event_Date_Meta`
WHERE
    `EV_DAT_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Event_Date` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Confidence`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Event_Date`
FROM
    attributes.`EV_DAT_Event_Date_Fact` p
JOIN
    attributes.`rEV_DAT_Event_Date_Meta`(positingTimepoint) a
ON
    a.`EV_DAT_ID` = p.`EV_DAT_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_DAT_ID`
        ORDER BY a.`EV_DAT_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Event_Audience_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_AUD`,
    `EV_AUD_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Confidence`
FROM
    attributes.`EV_AUD_Event_Audience_Meta`
WHERE
    `EV_AUD_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Event_Audience` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Confidence`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Event_Audience`
FROM
    attributes.`EV_AUD_Event_Audience_Fact` p
JOIN
    attributes.`rEV_AUD_Event_Audience_Meta`(positingTimepoint) a
ON
    a.`EV_AUD_ID` = p.`EV_AUD_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_AUD_ID`
        ORDER BY a.`EV_AUD_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Event_Revenue_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_REV`,
    `EV_REV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Confidence`
FROM
    attributes.`EV_REV_Event_Revenue_Meta`
WHERE
    `EV_REV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Event_Revenue` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Confidence`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Event_Revenue`
FROM
    attributes.`EV_REV_Event_Revenue_Fact` p
JOIN
    attributes.`rEV_REV_Event_Revenue_Meta`(positingTimepoint) a
ON
    a.`EV_REV_ID` = p.`EV_REV_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_REV_ID`
        ORDER BY a.`EV_REV_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Event_Status_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV_STA_ID`,
    `EV_STA_EV_ID`,
    `EV_STA_Event_Status`,
    `EV_STA_ChangedAt`
FROM
    attributes.`EV_STA_Event_Status_Fact`
WHERE
    `EV_STA_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_STA_Event_Status_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV_STA_ID`,
    `EV_STA_EV_ID`,
    `EV_STA_Event_Status`,
    `EV_STA_ChangedAt`
FROM
    attributes.`EV_STA_Event_Status_Fact`
WHERE
    `EV_STA_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Event_Status_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_STA`,
    `EV_STA_ID`,
    `EV_STA_PositedAt`,
    `EV_STA_Confidence`
FROM
    attributes.`EV_STA_Event_Status_Meta`
WHERE
    `EV_STA_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Event_Status` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Confidence`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Event_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`rEV_STA_Event_Status_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Event_Status_Meta`(positingTimepoint) a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_STA_ID`
        ORDER BY a.`EV_STA_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_STA_Event_Status` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Confidence`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Event_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`fEV_STA_Event_Status_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Event_Status_Meta`(positingTimepoint) a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_STA_ID`
        ORDER BY a.`EV_STA_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_STA_Event_Status` (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`EV_STA_Event_Status`
FROM
    attributes.`rEV_STA_Event_Status`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_STA_EV_ID` = id
AND
    pre.`EV_STA_ChangedAt` < changingTimepoint
AND
    pre.`EV_STA_Confidence` = 1
ORDER BY
    pre.`EV_STA_ChangedAt` DESC,
    pre.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_STA_Event_Status` (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`EV_STA_Event_Status`
FROM
    attributes.`fEV_STA_Event_Status`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_STA_EV_ID` = id
AND
    fol.`EV_STA_ChangedAt` > changingTimepoint
AND
    fol.`EV_STA_Confidence` = 1
ORDER BY
    fol.`EV_STA_ChangedAt` ASC,
    fol.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Event_Utilization_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_UTL`,
    `EV_UTL_ID`,
    `EV_UTL_PositedAt`,
    `EV_UTL_Confidence`
FROM
    attributes.`EV_UTL_Event_Utilization_Meta`
WHERE
    `EV_UTL_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Event_Utilization` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_UTL`,
    p.`EV_UTL_ID`,
    a.`EV_UTL_PositedAt`,
    a.`EV_UTL_Confidence`,
    p.`EV_UTL_EV_ID`,
    p.`EV_UTL_UTL_ID`
FROM
    attributes.`EV_UTL_Event_Utilization_Fact` p
JOIN
    attributes.`rEV_UTL_Event_Utilization_Meta`(positingTimepoint) a
ON
    a.`EV_UTL_ID` = p.`EV_UTL_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_UTL_ID`
        ORDER BY a.`EV_UTL_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Event_Level_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `EV_LVL_ID`,
    `EV_LVL_EV_ID`,
    `EV_LVL_PLV_ID`,
    `EV_LVL_ChangedAt`
FROM
    attributes.`EV_LVL_Event_Level_Fact`
WHERE
    `EV_LVL_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_LVL_Event_Level_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `EV_LVL_ID`,
    `EV_LVL_EV_ID`,
    `EV_LVL_PLV_ID`,
    `EV_LVL_ChangedAt`
FROM
    attributes.`EV_LVL_Event_Level_Fact`
WHERE
    `EV_LVL_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Event_Level_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_LVL`,
    `EV_LVL_ID`,
    `EV_LVL_PositedAt`,
    `EV_LVL_Confidence`
FROM
    attributes.`EV_LVL_Event_Level_Meta`
WHERE
    `EV_LVL_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Event_Level` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Confidence`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`rEV_LVL_Event_Level_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Event_Level_Meta`(positingTimepoint) a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_LVL_ID`
        ORDER BY a.`EV_LVL_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_LVL_Event_Level` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Confidence`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`fEV_LVL_Event_Level_Fact`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Event_Level_Meta`(positingTimepoint) a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_LVL_ID`
        ORDER BY a.`EV_LVL_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_LVL_Event_Level` (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`EV_LVL_PLV_ID`
FROM
    attributes.`rEV_LVL_Event_Level`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_LVL_EV_ID` = id
AND
    pre.`EV_LVL_ChangedAt` < changingTimepoint
AND
    pre.`EV_LVL_Confidence` = 1
ORDER BY
    pre.`EV_LVL_ChangedAt` DESC,
    pre.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_LVL_Event_Level` (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`EV_LVL_PLV_ID`
FROM
    attributes.`fEV_LVL_Event_Level`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_LVL_EV_ID` = id
AND
    fol.`EV_LVL_ChangedAt` > changingTimepoint
AND
    fol.`EV_LVL_Confidence` = 1
ORDER BY
    fol.`EV_LVL_ChangedAt` ASC,
    fol.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Stage_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    attributes.`ST_NAM_Stage_Name_Fact`
WHERE
    `ST_NAM_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_NAM_Stage_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    attributes.`ST_NAM_Stage_Name_Fact`
WHERE
    `ST_NAM_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Stage_Name_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_NAM`,
    `ST_NAM_ID`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Confidence`
FROM
    attributes.`ST_NAM_Stage_Name_Meta`
WHERE
    `ST_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Stage_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Confidence`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`rST_NAM_Stage_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Stage_Name_Meta`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_NAM_Stage_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Confidence`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`fST_NAM_Stage_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Stage_Name_Meta`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_NAM_Stage_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_NAM_Stage_Name`
FROM
    attributes.`rST_NAM_Stage_Name`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_NAM_ST_ID` = id
AND
    pre.`ST_NAM_ChangedAt` < changingTimepoint
AND
    pre.`ST_NAM_Confidence` = 1
ORDER BY
    pre.`ST_NAM_ChangedAt` DESC,
    pre.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_NAM_Stage_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_NAM_Stage_Name`
FROM
    attributes.`fST_NAM_Stage_Name`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_NAM_ST_ID` = id
AND
    fol.`ST_NAM_ChangedAt` > changingTimepoint
AND
    fol.`ST_NAM_Confidence` = 1
ORDER BY
    fol.`ST_NAM_ChangedAt` ASC,
    fol.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Stage_Location_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_LOC`,
    `ST_LOC_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Confidence`
FROM
    attributes.`ST_LOC_Stage_Location_Meta`
WHERE
    `ST_LOC_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Stage_Location` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Confidence`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Stage_Location`
FROM
    attributes.`ST_LOC_Stage_Location_Fact` p
JOIN
    attributes.`rST_LOC_Stage_Location_Meta`(positingTimepoint) a
ON
    a.`ST_LOC_ID` = p.`ST_LOC_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_LOC_ID`
        ORDER BY a.`ST_LOC_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Stage_Average_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    attributes.`ST_AVG_Stage_Average_Fact`
WHERE
    `ST_AVG_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_AVG_Stage_Average_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    attributes.`ST_AVG_Stage_Average_Fact`
WHERE
    `ST_AVG_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Stage_Average_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_AVG`,
    `ST_AVG_ID`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Confidence`
FROM
    attributes.`ST_AVG_Stage_Average_Meta`
WHERE
    `ST_AVG_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Stage_Average` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Confidence`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    attributes.`rST_AVG_Stage_Average_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Stage_Average_Meta`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_AVG_Stage_Average` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Confidence`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    attributes.`fST_AVG_Stage_Average_Fact`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Stage_Average_Meta`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_AVG_Stage_Average` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_AVG_UTL_ID`
FROM
    attributes.`rST_AVG_Stage_Average`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_AVG_ST_ID` = id
AND
    pre.`ST_AVG_ChangedAt` < changingTimepoint
AND
    pre.`ST_AVG_Confidence` = 1
ORDER BY
    pre.`ST_AVG_ChangedAt` DESC,
    pre.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_AVG_Stage_Average` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_AVG_UTL_ID`
FROM
    attributes.`fST_AVG_Stage_Average`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_AVG_ST_ID` = id
AND
    fol.`ST_AVG_ChangedAt` > changingTimepoint
AND
    fol.`ST_AVG_Confidence` = 1
ORDER BY
    fol.`ST_AVG_ChangedAt` ASC,
    fol.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Stage_Minimum_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_MIN`,
    `ST_MIN_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Confidence`
FROM
    attributes.`ST_MIN_Stage_Minimum_Meta`
WHERE
    `ST_MIN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Stage_Minimum` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_MIN`,
    p.`ST_MIN_ID`,
    a.`ST_MIN_PositedAt`,
    a.`ST_MIN_Confidence`,
    p.`ST_MIN_ST_ID`,
    p.`ST_MIN_UTL_ID`
FROM
    attributes.`ST_MIN_Stage_Minimum_Fact` p
JOIN
    attributes.`rST_MIN_Stage_Minimum_Meta`(positingTimepoint) a
ON
    a.`ST_MIN_ID` = p.`ST_MIN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_MIN_ID`
        ORDER BY a.`ST_MIN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Actor_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    attributes.`AC_NAM_Actor_Name_Fact`
WHERE
    `AC_NAM_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_NAM_Actor_Name_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    attributes.`AC_NAM_Actor_Name_Fact`
WHERE
    `AC_NAM_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Actor_Name_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_NAM`,
    `AC_NAM_ID`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Confidence`
FROM
    attributes.`AC_NAM_Actor_Name_Meta`
WHERE
    `AC_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Actor_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Confidence`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`rAC_NAM_Actor_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Actor_Name_Meta`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_NAM_Actor_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Confidence`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`fAC_NAM_Actor_Name_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Actor_Name_Meta`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_NAM_Actor_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_NAM_Actor_Name`
FROM
    attributes.`rAC_NAM_Actor_Name`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_NAM_AC_ID` = id
AND
    pre.`AC_NAM_ChangedAt` < changingTimepoint
AND
    pre.`AC_NAM_Confidence` = 1
ORDER BY
    pre.`AC_NAM_ChangedAt` DESC,
    pre.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_NAM_Actor_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_NAM_Actor_Name`
FROM
    attributes.`fAC_NAM_Actor_Name`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_NAM_AC_ID` = id
AND
    fol.`AC_NAM_ChangedAt` > changingTimepoint
AND
    fol.`AC_NAM_Confidence` = 1
ORDER BY
    fol.`AC_NAM_ChangedAt` ASC,
    fol.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Actor_Gender_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_GEN`,
    `AC_GEN_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Confidence`
FROM
    attributes.`AC_GEN_Actor_Gender_Meta`
WHERE
    `AC_GEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Actor_Gender` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_GEN`,
    p.`AC_GEN_ID`,
    a.`AC_GEN_PositedAt`,
    a.`AC_GEN_Confidence`,
    p.`AC_GEN_AC_ID`,
    p.`AC_GEN_GEN_ID`
FROM
    attributes.`AC_GEN_Actor_Gender_Fact` p
JOIN
    attributes.`rAC_GEN_Actor_Gender_Meta`(positingTimepoint) a
ON
    a.`AC_GEN_ID` = p.`AC_GEN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_GEN_ID`
        ORDER BY a.`AC_GEN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Actor_ProfessionalLevel_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel_Fact`
WHERE
    `AC_PLV_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_PLV_Actor_ProfessionalLevel_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel_Fact`
WHERE
    `AC_PLV_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Actor_ProfessionalLevel_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_PLV`,
    `AC_PLV_ID`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Confidence`
FROM
    attributes.`AC_PLV_Actor_ProfessionalLevel_Meta`
WHERE
    `AC_PLV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Confidence`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    attributes.`rAC_PLV_Actor_ProfessionalLevel_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Actor_ProfessionalLevel_Meta`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Confidence`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    attributes.`fAC_PLV_Actor_ProfessionalLevel_Fact`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Actor_ProfessionalLevel_Meta`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_PLV_PLV_ID`
FROM
    attributes.`rAC_PLV_Actor_ProfessionalLevel`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_PLV_AC_ID` = id
AND
    pre.`AC_PLV_ChangedAt` < changingTimepoint
AND
    pre.`AC_PLV_Confidence` = 1
ORDER BY
    pre.`AC_PLV_ChangedAt` DESC,
    pre.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_PLV_PLV_ID`
FROM
    attributes.`fAC_PLV_Actor_ProfessionalLevel`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_PLV_AC_ID` = id
AND
    fol.`AC_PLV_ChangedAt` > changingTimepoint
AND
    fol.`AC_PLV_Confidence` = 1
ORDER BY
    fol.`AC_PLV_ChangedAt` ASC,
    fol.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Program_Name_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_NAM`,
    `PR_NAM_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Confidence`
FROM
    attributes.`PR_NAM_Program_Name_Meta`
WHERE
    `PR_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Program_Name` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Confidence`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Program_Name`
FROM
    attributes.`PR_NAM_Program_Name_Fact` p
JOIN
    attributes.`rPR_NAM_Program_Name_Meta`(positingTimepoint) a
ON
    a.`PR_NAM_ID` = p.`PR_NAM_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_NAM_ID`
        ORDER BY a.`PR_NAM_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Program_Length_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    attributes.`PR_LEN_Program_Length_Fact`
WHERE
    `PR_LEN_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fPR_LEN_Program_Length_Fact` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    attributes.`PR_LEN_Program_Length_Fact`
WHERE
    `PR_LEN_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Program_Length_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_LEN`,
    `PR_LEN_ID`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Confidence`
FROM
    attributes.`PR_LEN_Program_Length_Meta`
WHERE
    `PR_LEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Program_Length` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Confidence`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`rPR_LEN_Program_Length_Fact`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Program_Length_Meta`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`fPR_LEN_Program_Length` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Confidence`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`fPR_LEN_Program_Length_Fact`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Program_Length_Meta`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`prePR_LEN_Program_Length` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`PR_LEN_Program_Length`
FROM
    attributes.`rPR_LEN_Program_Length`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`PR_LEN_PR_ID` = id
AND
    pre.`PR_LEN_ChangedAt` < changingTimepoint
AND
    pre.`PR_LEN_Confidence` = 1
ORDER BY
    pre.`PR_LEN_ChangedAt` DESC,
    pre.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folPR_LEN_Program_Length` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`PR_LEN_Program_Length`
FROM
    attributes.`fPR_LEN_Program_Length`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`PR_LEN_PR_ID` = id
AND
    fol.`PR_LEN_ChangedAt` > changingTimepoint
AND
    fol.`PR_LEN_Confidence` = 1
ORDER BY
    fol.`PR_LEN_ChangedAt` ASC,
    fol.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BigQuery BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION anchors.`tST_Stage` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_PositedAt`,
    `NAM`.`ST_NAM_Confidence`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Confidence`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Confidence`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Confidence`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_NAM_Stage_Name`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_NAM_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_NAM_ST_ID`
            ORDER BY
                r.`ST_NAM_ChangedAt` DESC,
                r.`ST_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_LOC_Stage_Location`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_LOC_ST_ID`
            ORDER BY
                r.`ST_LOC_PositedAt` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_AVG_Stage_Average`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_AVG_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_AVG_ST_ID`
            ORDER BY
                r.`ST_AVG_ChangedAt` DESC,
                r.`ST_AVG_PositedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_MIN_Stage_Minimum`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_MIN_ST_ID`
            ORDER BY
                r.`ST_MIN_PositedAt` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE VIEW anchors.`lST_Stage` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `ST`.*
FROM
    anchors.`tST_Stage`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pST_Stage` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `ST`.`ST_NAM_ST_ID`,
    `ST`.`Metadata_ST_NAM`,
    `ST`.`ST_NAM_ID`,
    `ST`.`ST_NAM_ChangedAt`,
    `ST`.`ST_NAM_PositedAt`,
    `ST`.`ST_NAM_Confidence`,
    `ST`.`ST_NAM_Stage_Name`,
    `ST`.`ST_LOC_ST_ID`,
    `ST`.`Metadata_ST_LOC`,
    `ST`.`ST_LOC_ID`,
    `ST`.`ST_LOC_PositedAt`,
    `ST`.`ST_LOC_Confidence`,
    `ST`.`ST_LOC_Checksum`,
    `ST`.`ST_LOC_Stage_Location`,
    `ST`.`ST_AVG_ST_ID`,
    `ST`.`Metadata_ST_AVG`,
    `ST`.`ST_AVG_ID`,
    `ST`.`ST_AVG_ChangedAt`,
    `ST`.`ST_AVG_PositedAt`,
    `ST`.`ST_AVG_Confidence`,
    `ST`.`ST_AVG_UTL_Utilization`,
    `ST`.`ST_AVG_Metadata_UTL`,
    `ST`.`ST_AVG_UTL_ID`,
    `ST`.`ST_MIN_ST_ID`,
    `ST`.`Metadata_ST_MIN`,
    `ST`.`ST_MIN_ID`,
    `ST`.`ST_MIN_PositedAt`,
    `ST`.`ST_MIN_Confidence`,
    `ST`.`ST_MIN_UTL_Utilization`,
    `ST`.`ST_MIN_Metadata_UTL`,
    `ST`.`ST_MIN_UTL_ID`
FROM
    anchors.`tST_Stage`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
)
;
CREATE OR REPLACE VIEW anchors.`nST_Stage` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `ST`.*
FROM
    anchors.`tST_Stage`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dST_Stage` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_PositedAt`,
    `NAM`.`ST_NAM_Confidence`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Confidence`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Confidence`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Confidence`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM (
    SELECT DISTINCT
        `ST_NAM_ST_ID` AS `ST_ID`,
        CAST(`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`ST_NAM_Stage_Name`
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        `ST_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `ST_AVG_ST_ID` AS `ST_ID`,
        CAST(`ST_AVG_ChangedAt` AS datetime) AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes.`ST_AVG_Stage_Average`
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        `ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`ST_Stage` `ST`
ON
    `ST`.`ST_ID` = timepoints.`ST_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`ST_NAM_ChangedAt`) OVER (
            PARTITION BY x.`ST_NAM_ST_ID`
            ORDER BY x.`ST_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rST_NAM_Stage_Name`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_NAM_Confidence` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_NAM_ST_ID`, r.`ST_NAM_ChangedAt`
                ORDER BY r.`ST_NAM_PositedAt` DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rST_LOC_Stage_Location`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_LOC_ST_ID`
            ORDER BY r.`ST_LOC_PositedAt` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`ST_AVG_ChangedAt`) OVER (
            PARTITION BY x.`ST_AVG_ST_ID`
            ORDER BY x.`ST_AVG_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rST_AVG_Stage_Average`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_AVG_Confidence` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_AVG_ST_ID`, r.`ST_AVG_ChangedAt`
                ORDER BY r.`ST_AVG_PositedAt` DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rST_MIN_Stage_Minimum`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_MIN_ST_ID`
            ORDER BY r.`ST_MIN_PositedAt` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION anchors.`tAC_Actor` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_PositedAt`,
    `NAM`.`AC_NAM_Confidence`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Confidence`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Confidence`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_NAM_Actor_Name`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_NAM_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_NAM_AC_ID`
            ORDER BY
                r.`AC_NAM_ChangedAt` DESC,
                r.`AC_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_GEN_Actor_Gender`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_GEN_AC_ID`
            ORDER BY
                r.`AC_GEN_PositedAt` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_PLV_Actor_ProfessionalLevel`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_PLV_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_PLV_AC_ID`
            ORDER BY
                r.`AC_PLV_ChangedAt` DESC,
                r.`AC_PLV_PositedAt` DESC
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
CREATE OR REPLACE VIEW anchors.`lAC_Actor` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `AC`.*
FROM
    anchors.`tAC_Actor`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pAC_Actor` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `AC`.`AC_NAM_AC_ID`,
    `AC`.`Metadata_AC_NAM`,
    `AC`.`AC_NAM_ID`,
    `AC`.`AC_NAM_ChangedAt`,
    `AC`.`AC_NAM_PositedAt`,
    `AC`.`AC_NAM_Confidence`,
    `AC`.`AC_NAM_Actor_Name`,
    `AC`.`AC_GEN_AC_ID`,
    `AC`.`Metadata_AC_GEN`,
    `AC`.`AC_GEN_ID`,
    `AC`.`AC_GEN_PositedAt`,
    `AC`.`AC_GEN_Confidence`,
    `AC`.`AC_GEN_GEN_Checksum`,
    `AC`.`AC_GEN_GEN_Gender`,
    `AC`.`AC_GEN_Metadata_GEN`,
    `AC`.`AC_GEN_GEN_ID`,
    `AC`.`AC_PLV_AC_ID`,
    `AC`.`Metadata_AC_PLV`,
    `AC`.`AC_PLV_ID`,
    `AC`.`AC_PLV_ChangedAt`,
    `AC`.`AC_PLV_PositedAt`,
    `AC`.`AC_PLV_Confidence`,
    `AC`.`AC_PLV_PLV_Checksum`,
    `AC`.`AC_PLV_PLV_ProfessionalLevel`,
    `AC`.`AC_PLV_Metadata_PLV`,
    `AC`.`AC_PLV_PLV_ID`
FROM
    anchors.`tAC_Actor`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
)
;
CREATE OR REPLACE VIEW anchors.`nAC_Actor` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `AC`.*
FROM
    anchors.`tAC_Actor`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dAC_Actor` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_PositedAt`,
    `NAM`.`AC_NAM_Confidence`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Confidence`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Confidence`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM (
    SELECT DISTINCT
        `AC_NAM_AC_ID` AS `AC_ID`,
        CAST(`AC_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`AC_NAM_Actor_Name`
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        `AC_NAM_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `AC_PLV_AC_ID` AS `AC_ID`,
        CAST(`AC_PLV_ChangedAt` AS datetime) AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes.`AC_PLV_Actor_ProfessionalLevel`
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        `AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`AC_Actor` `AC`
ON
    `AC`.`AC_ID` = timepoints.`AC_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`AC_NAM_ChangedAt`) OVER (
            PARTITION BY x.`AC_NAM_AC_ID`
            ORDER BY x.`AC_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rAC_NAM_Actor_Name`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_NAM_Confidence` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_NAM_AC_ID`, r.`AC_NAM_ChangedAt`
                ORDER BY r.`AC_NAM_PositedAt` DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rAC_GEN_Actor_Gender`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_GEN_AC_ID`
            ORDER BY r.`AC_GEN_PositedAt` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`AC_PLV_ChangedAt`) OVER (
            PARTITION BY x.`AC_PLV_AC_ID`
            ORDER BY x.`AC_PLV_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rAC_PLV_Actor_ProfessionalLevel`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_PLV_Confidence` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_PLV_AC_ID`, r.`AC_PLV_ChangedAt`
                ORDER BY r.`AC_PLV_PositedAt` DESC
            ) = 1
    ) x
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
CREATE OR REPLACE TABLE FUNCTION anchors.`tPR_Program` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Confidence`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Confidence`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    anchors.`PR_Program` `PR`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rPR_NAM_Program_Name`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_NAM_PR_ID`
            ORDER BY
                r.`PR_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rPR_LEN_Program_Length`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_LEN_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_LEN_PR_ID`
            ORDER BY
                r.`PR_LEN_ChangedAt` DESC,
                r.`PR_LEN_PositedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`
)
;
CREATE OR REPLACE VIEW anchors.`lPR_Program` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `PR`.*
FROM
    anchors.`tPR_Program`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pPR_Program` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `PR`.`PR_NAM_PR_ID`,
    `PR`.`Metadata_PR_NAM`,
    `PR`.`PR_NAM_ID`,
    `PR`.`PR_NAM_PositedAt`,
    `PR`.`PR_NAM_Confidence`,
    `PR`.`PR_NAM_Program_Name`,
    `PR`.`PR_LEN_PR_ID`,
    `PR`.`Metadata_PR_LEN`,
    `PR`.`PR_LEN_ID`,
    `PR`.`PR_LEN_ChangedAt`,
    `PR`.`PR_LEN_PositedAt`,
    `PR`.`PR_LEN_Confidence`,
    `PR`.`PR_LEN_Program_Length`
FROM
    anchors.`tPR_Program`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
)
;
CREATE OR REPLACE VIEW anchors.`nPR_Program` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `PR`.*
FROM
    anchors.`tPR_Program`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dPR_Program` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Confidence`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Confidence`,
    `LEN`.`PR_LEN_Program_Length`
FROM (
    SELECT DISTINCT
        `PR_LEN_PR_ID` AS `PR_ID`,
        CAST(`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes.`PR_LEN_Program_Length`
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        `PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`PR_Program` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rPR_NAM_Program_Name`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_NAM_PR_ID`
            ORDER BY r.`PR_NAM_PositedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`PR_LEN_ChangedAt`) OVER (
            PARTITION BY x.`PR_LEN_PR_ID`
            ORDER BY x.`PR_LEN_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rPR_LEN_Program_Length`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_LEN_Confidence` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`PR_LEN_PR_ID`, r.`PR_LEN_ChangedAt`
                ORDER BY r.`PR_LEN_PositedAt` DESC
            ) = 1
    ) x
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
-- BigQuery BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION nexuses.`tEV_Event` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Confidence`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Confidence`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Confidence`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Confidence`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Confidence`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Confidence`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Event` `EV`
LEFT JOIN
    knots.`ETY_EventType` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Event_Date`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_DAT_EV_ID`
            ORDER BY
                r.`EV_DAT_PositedAt` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_AUD_Event_Audience`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_AUD_EV_ID`
            ORDER BY
                r.`EV_AUD_PositedAt` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_REV_Event_Revenue`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_REV_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_EV_ID`
            ORDER BY
                r.`EV_REV_PositedAt` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_STA_Event_Status`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_STA_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_STA_EV_ID`
            ORDER BY
                r.`EV_STA_ChangedAt` DESC,
                r.`EV_STA_PositedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_UTL_Event_Utilization`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_EV_ID`
            ORDER BY
                r.`EV_UTL_PositedAt` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_LVL_Event_Level`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_LVL_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_LVL_EV_ID`
            ORDER BY
                r.`EV_LVL_ChangedAt` DESC,
                r.`EV_LVL_PositedAt` DESC
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
CREATE OR REPLACE VIEW nexuses.`lEV_Event` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `EV`.*
FROM
    nexuses.`tEV_Event`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `EV`.`of_ETY_Checksum`,
    `EV`.`of_ETY_EventType`,
    `EV`.`of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `EV`.`EV_DAT_EV_ID`,
    `EV`.`Metadata_EV_DAT`,
    `EV`.`EV_DAT_ID`,
    `EV`.`EV_DAT_PositedAt`,
    `EV`.`EV_DAT_Confidence`,
    `EV`.`EV_DAT_Event_Date`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Confidence`,
    `EV`.`EV_AUD_Event_Audience`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Confidence`,
    `EV`.`EV_REV_Event_Revenue`,
    `EV`.`EV_STA_EV_ID`,
    `EV`.`Metadata_EV_STA`,
    `EV`.`EV_STA_ID`,
    `EV`.`EV_STA_ChangedAt`,
    `EV`.`EV_STA_PositedAt`,
    `EV`.`EV_STA_Confidence`,
    `EV`.`EV_STA_Event_Status`,
    `EV`.`EV_UTL_EV_ID`,
    `EV`.`Metadata_EV_UTL`,
    `EV`.`EV_UTL_ID`,
    `EV`.`EV_UTL_PositedAt`,
    `EV`.`EV_UTL_Confidence`,
    `EV`.`EV_UTL_UTL_Utilization`,
    `EV`.`EV_UTL_Metadata_UTL`,
    `EV`.`EV_UTL_UTL_ID`,
    `EV`.`EV_LVL_EV_ID`,
    `EV`.`Metadata_EV_LVL`,
    `EV`.`EV_LVL_ID`,
    `EV`.`EV_LVL_ChangedAt`,
    `EV`.`EV_LVL_PositedAt`,
    `EV`.`EV_LVL_Confidence`,
    `EV`.`EV_LVL_PLV_Checksum`,
    `EV`.`EV_LVL_PLV_ProfessionalLevel`,
    `EV`.`EV_LVL_Metadata_PLV`,
    `EV`.`EV_LVL_PLV_ID`
FROM
    nexuses.`tEV_Event`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
)
;
CREATE OR REPLACE VIEW nexuses.`nEV_Event` AS
SELECT
    cast(null as numeric(7,3)) as `Confidence`,
    `EV`.*
FROM
    nexuses.`tEV_Event`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Event` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. BigQuery cannot call
-- the time-traveling perspective for each change, since it cannot evaluate a function with an outer join on its
-- argument for each row of another table.
SELECT
    timepoints.inspectedTimepoint,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Confidence`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Confidence`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Confidence`,
    `REV`.`EV_REV_Event_Revenue`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Confidence`,
    `STA`.`EV_STA_Event_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Confidence`,
    `kUTL`.`UTL_Utilization` AS `EV_UTL_UTL_Utilization`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Confidence`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_ProfessionalLevel` AS `EV_LVL_PLV_ProfessionalLevel`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM (
    SELECT DISTINCT
        `EV_STA_EV_ID` AS `EV_ID`,
        CAST(`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Event_Status`
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        `EV_STA_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `EV_LVL_EV_ID` AS `EV_ID`,
        CAST(`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Event_Level`
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        `EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses.`EV_Event` `EV`
ON
    `EV`.`EV_ID` = timepoints.`EV_ID`
LEFT JOIN
    knots.`ETY_EventType` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Event_Date`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_DAT_EV_ID`
            ORDER BY r.`EV_DAT_PositedAt` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_AUD_Event_Audience`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_AUD_EV_ID`
            ORDER BY r.`EV_AUD_PositedAt` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_REV_Event_Revenue`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_REV_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_EV_ID`
            ORDER BY r.`EV_REV_PositedAt` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`EV_STA_ChangedAt`) OVER (
            PARTITION BY x.`EV_STA_EV_ID`
            ORDER BY x.`EV_STA_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rEV_STA_Event_Status`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_STA_Confidence` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_STA_EV_ID`, r.`EV_STA_ChangedAt`
                ORDER BY r.`EV_STA_PositedAt` DESC
            ) = 1
    ) x
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
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_UTL_Event_Utilization`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Confidence` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_EV_ID`
            ORDER BY r.`EV_UTL_PositedAt` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utilization` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    SELECT
        x.*,
        lead(x.`EV_LVL_ChangedAt`) OVER (
            PARTITION BY x.`EV_LVL_EV_ID`
            ORDER BY x.`EV_LVL_ChangedAt`
        ) AS `until`
    FROM (
        -- the latest asserted posit at each changing time
        SELECT
            r.*
        FROM
            attributes.`rEV_LVL_Event_Level`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_LVL_Confidence` = 1
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_LVL_EV_ID`, r.`EV_LVL_ChangedAt`
                ORDER BY r.`EV_LVL_PositedAt` DESC
            ) = 1
    ) x
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
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
-- BigQuery has no sequences: the load gives an identity to every posit. Its keys are not enforced, and it has no unique
-- constraints: what a posit table holds once is kept so by the load (the integrity checks tell if it has not).
--
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Fact table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently_Fact` (
    `AC_partner_AC_with_ONG_currently_ID` int64 not null,
    `AC_ID_partner` int64 not null, 
    `AC_ID_with` int64 not null, 
    `ONG_ID_currently` int64 not null,
    `AC_partner_AC_with_ONG_currently_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Fact_fkAC_partner` FOREIGN KEY (`AC_ID_partner`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Fact_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Fact_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        knots.`ONG_Ongoing`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Meta table (of AC_partner_AC_with_ONG_currently_Fact)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently_Meta` (
    `AC_partner_AC_with_ONG_currently_ID` int64 not null,
    `AC_partner_AC_with_ONG_currently_PositedAt` datetime not null,
    `AC_partner_AC_with_ONG_currently_Confidence` numeric(7,3) not null,
    `Metadata_AC_partner_AC_with_ONG_currently` int64 not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`,
        `AC_partner_AC_with_ONG_currently_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_partner_AC_with_ONG_currently_Meta` FOREIGN KEY (`AC_partner_AC_with_ONG_currently_ID`) REFERENCES
        ties.`AC_partner_AC_with_ONG_currently_Fact`(`AC_partner_AC_with_ONG_currently_ID`) NOT ENFORCED
)
CLUSTER BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Fact table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of_Fact` (
    `AC_subset_PN_of_ID` int64 not null,
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    PRIMARY KEY (
        `AC_subset_PN_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Fact_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Fact_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        anchors.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Meta table (of AC_subset_PN_of_Fact)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of_Meta` (
    `AC_subset_PN_of_ID` int64 not null,
    `AC_subset_PN_of_PositedAt` datetime not null,
    `AC_subset_PN_of_Confidence` numeric(7,3) not null,
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_subset_PN_of_ID`,
        `AC_subset_PN_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_subset_PN_of_Meta` FOREIGN KEY (`AC_subset_PN_of_ID`) REFERENCES
        ties.`AC_subset_PN_of_Fact`(`AC_subset_PN_of_ID`) NOT ENFORCED
)
CLUSTER BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Fact table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_wasCast_Fact` (
    `EV_in_AC_wasCast_ID` int64 not null,
    `EV_ID_in` numeric(12,0) not null, 
    `AC_ID_wasCast` int64 not null, 
    PRIMARY KEY (
        `EV_in_AC_wasCast_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_Fact_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_Fact_fkAC_wasCast` FOREIGN KEY (`AC_ID_wasCast`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Meta table (of EV_in_AC_wasCast_Fact)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_wasCast_Meta` (
    `EV_in_AC_wasCast_ID` int64 not null,
    `EV_in_AC_wasCast_PositedAt` datetime not null,
    `EV_in_AC_wasCast_Confidence` numeric(7,3) not null,
    `Metadata_EV_in_AC_wasCast` int64 not null,
    PRIMARY KEY (
        `EV_in_AC_wasCast_ID`,
        `EV_in_AC_wasCast_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_in_AC_wasCast_Meta` FOREIGN KEY (`EV_in_AC_wasCast_ID`) REFERENCES
        ties.`EV_in_AC_wasCast_Fact`(`EV_in_AC_wasCast_ID`) NOT ENFORCED
)
CLUSTER BY `EV_in_AC_wasCast_ID`, `EV_in_AC_wasCast_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Fact table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_part_PR_in_RAT_got_Fact` (
    `AC_part_PR_in_RAT_got_ID` int64 not null,
    `AC_ID_part` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_got` int64 not null,
    `AC_part_PR_in_RAT_got_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_part_PR_in_RAT_got_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Fact_fkAC_part` FOREIGN KEY (`AC_ID_part`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Fact_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Fact_fkRAT_got` FOREIGN KEY (`RAT_ID_got`) REFERENCES
        knots.`RAT_Rating`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_part`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Meta table (of AC_part_PR_in_RAT_got_Fact)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_part_PR_in_RAT_got_Meta` (
    `AC_part_PR_in_RAT_got_ID` int64 not null,
    `AC_part_PR_in_RAT_got_PositedAt` datetime not null,
    `AC_part_PR_in_RAT_got_Confidence` numeric(7,3) not null,
    `Metadata_AC_part_PR_in_RAT_got` int64 not null,
    PRIMARY KEY (
        `AC_part_PR_in_RAT_got_ID`,
        `AC_part_PR_in_RAT_got_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_part_PR_in_RAT_got_Meta` FOREIGN KEY (`AC_part_PR_in_RAT_got_ID`) REFERENCES
        ties.`AC_part_PR_in_RAT_got_Fact`(`AC_part_PR_in_RAT_got_ID`) NOT ENFORCED
)
CLUSTER BY `AC_part_PR_in_RAT_got_ID`, `AC_part_PR_in_RAT_got_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Fact table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_isPlaying_Fact` (
    `ST_at_PR_isPlaying_ID` int64 not null,
    `ST_ID_at` int64 not null, 
    `PR_ID_isPlaying` int64 not null, 
    `ST_at_PR_isPlaying_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_at_PR_isPlaying_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_Fact_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_Fact_fkPR_isPlaying` FOREIGN KEY (`PR_ID_isPlaying`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Meta table (of ST_at_PR_isPlaying_Fact)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_isPlaying_Meta` (
    `ST_at_PR_isPlaying_ID` int64 not null,
    `ST_at_PR_isPlaying_PositedAt` datetime not null,
    `ST_at_PR_isPlaying_Confidence` numeric(7,3) not null,
    `Metadata_ST_at_PR_isPlaying` int64 not null,
    PRIMARY KEY (
        `ST_at_PR_isPlaying_ID`,
        `ST_at_PR_isPlaying_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_at_PR_isPlaying_Meta` FOREIGN KEY (`ST_at_PR_isPlaying_ID`) REFERENCES
        ties.`ST_at_PR_isPlaying_Fact`(`ST_at_PR_isPlaying_ID`) NOT ENFORCED
)
CLUSTER BY `ST_at_PR_isPlaying_ID`, `ST_at_PR_isPlaying_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Fact table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_parent_AC_child_PAT_having_Fact` (
    `AC_parent_AC_child_PAT_having_ID` int64 not null,
    `AC_ID_parent` int64 not null, 
    `AC_ID_child` int64 not null, 
    `PAT_ID_having` int64 not null,
    PRIMARY KEY (
        `AC_parent_AC_child_PAT_having_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Fact_fkAC_parent` FOREIGN KEY (`AC_ID_parent`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Fact_fkAC_child` FOREIGN KEY (`AC_ID_child`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Fact_fkPAT_having` FOREIGN KEY (`PAT_ID_having`) REFERENCES
        knots.`PAT_ParentalType`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_parent`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Meta table (of AC_parent_AC_child_PAT_having_Fact)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_parent_AC_child_PAT_having_Meta` (
    `AC_parent_AC_child_PAT_having_ID` int64 not null,
    `AC_parent_AC_child_PAT_having_PositedAt` datetime not null,
    `AC_parent_AC_child_PAT_having_Confidence` numeric(7,3) not null,
    `Metadata_AC_parent_AC_child_PAT_having` int64 not null,
    PRIMARY KEY (
        `AC_parent_AC_child_PAT_having_ID`,
        `AC_parent_AC_child_PAT_having_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_parent_AC_child_PAT_having_Meta` FOREIGN KEY (`AC_parent_AC_child_PAT_having_ID`) REFERENCES
        ties.`AC_parent_AC_child_PAT_having_Fact`(`AC_parent_AC_child_PAT_having_ID`) NOT ENFORCED
)
CLUSTER BY `AC_parent_AC_child_PAT_having_ID`, `AC_parent_AC_child_PAT_having_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Fact table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_content_ST_location_EV_of_Fact` (
    `PR_content_ST_location_EV_of_ID` int64 not null,
    `PR_ID_content` int64 not null, 
    `ST_ID_location` int64 not null, 
    `EV_ID_of` numeric(12,0) not null, 
    `PR_content_ST_location_EV_of_ChangedAt` datetime not null,
    PRIMARY KEY (
        `PR_content_ST_location_EV_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Fact_fkPR_content` FOREIGN KEY (`PR_ID_content`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Fact_fkST_location` FOREIGN KEY (`ST_ID_location`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Fact_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_content`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Meta table (of PR_content_ST_location_EV_of_Fact)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_content_ST_location_EV_of_Meta` (
    `PR_content_ST_location_EV_of_ID` int64 not null,
    `PR_content_ST_location_EV_of_PositedAt` datetime not null,
    `PR_content_ST_location_EV_of_Confidence` numeric(7,3) not null,
    `Metadata_PR_content_ST_location_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_content_ST_location_EV_of_ID`,
        `PR_content_ST_location_EV_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_content_ST_location_EV_of_Meta` FOREIGN KEY (`PR_content_ST_location_EV_of_ID`) REFERENCES
        ties.`PR_content_ST_location_EV_of_Fact`(`PR_content_ST_location_EV_of_ID`) NOT ENFORCED
)
CLUSTER BY `PR_content_ST_location_EV_of_ID`, `PR_content_ST_location_EV_of_PositedAt`;
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling.
--
CREATE OR REPLACE VIEW ties.`AC_partner_AC_with_ONG_currently` AS
SELECT
    a.`Metadata_AC_partner_AC_with_ONG_currently`,
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Confidence`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Fact` p
JOIN
    ties.`AC_partner_AC_with_ONG_currently_Meta` a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
;
CREATE OR REPLACE VIEW ties.`AC_subset_PN_of` AS
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Confidence`
FROM
    ties.`AC_subset_PN_of_Fact` p
JOIN
    ties.`AC_subset_PN_of_Meta` a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
;
CREATE OR REPLACE VIEW ties.`EV_in_AC_wasCast` AS
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Confidence`
FROM
    ties.`EV_in_AC_wasCast_Fact` p
JOIN
    ties.`EV_in_AC_wasCast_Meta` a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
;
CREATE OR REPLACE VIEW ties.`AC_part_PR_in_RAT_got` AS
SELECT
    a.`Metadata_AC_part_PR_in_RAT_got`,
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Confidence`
FROM
    ties.`AC_part_PR_in_RAT_got_Fact` p
JOIN
    ties.`AC_part_PR_in_RAT_got_Meta` a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
;
CREATE OR REPLACE VIEW ties.`ST_at_PR_isPlaying` AS
SELECT
    a.`Metadata_ST_at_PR_isPlaying`,
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Confidence`
FROM
    ties.`ST_at_PR_isPlaying_Fact` p
JOIN
    ties.`ST_at_PR_isPlaying_Meta` a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
;
CREATE OR REPLACE VIEW ties.`AC_parent_AC_child_PAT_having` AS
SELECT
    a.`Metadata_AC_parent_AC_child_PAT_having`,
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Confidence`
FROM
    ties.`AC_parent_AC_child_PAT_having_Fact` p
JOIN
    ties.`AC_parent_AC_child_PAT_having_Meta` a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
;
CREATE OR REPLACE VIEW ties.`PR_content_ST_location_EV_of` AS
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    p.`PR_content_ST_location_EV_of_ChangedAt`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Confidence`
FROM
    ties.`PR_content_ST_location_EV_of_Fact` p
JOIN
    ties.`PR_content_ST_location_EV_of_Meta` a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Fact` (
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
    ties.`AC_partner_AC_with_ONG_currently_Fact`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_partner_AC_with_ONG_currently_Fact` (
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
    ties.`AC_partner_AC_with_ONG_currently_Fact`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    `AC_partner_AC_with_ONG_currently_Confidence`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Meta`
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
    a.`AC_partner_AC_with_ONG_currently_Confidence`
FROM
    ties.`rAC_partner_AC_with_ONG_currently_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Meta`(positingTimepoint) a
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
    a.`AC_partner_AC_with_ONG_currently_Confidence`
FROM
    ties.`fAC_partner_AC_with_ONG_currently_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Meta`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_subset_PN_of`,
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_PositedAt`,
    `AC_subset_PN_of_Confidence`
FROM
    ties.`AC_subset_PN_of_Meta`
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
    a.`AC_subset_PN_of_Confidence`
FROM
    ties.`AC_subset_PN_of_Fact` p
JOIN
    ties.`rAC_subset_PN_of_Meta`(positingTimepoint) a
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
    a.`AC_subset_PN_of_Confidence`
FROM
    ties.`AC_subset_PN_of_Fact` p
JOIN
    ties.`rAC_subset_PN_of_Meta`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_wasCast_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_in_AC_wasCast`,
    `EV_in_AC_wasCast_ID`,
    `EV_in_AC_wasCast_PositedAt`,
    `EV_in_AC_wasCast_Confidence`
FROM
    ties.`EV_in_AC_wasCast_Meta`
WHERE
    `EV_in_AC_wasCast_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_wasCast` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Confidence`
FROM
    ties.`EV_in_AC_wasCast_Fact` p
JOIN
    ties.`rEV_in_AC_wasCast_Meta`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`
        ORDER BY a.`EV_in_AC_wasCast_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fEV_in_AC_wasCast` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Confidence`
FROM
    ties.`EV_in_AC_wasCast_Fact` p
JOIN
    ties.`rEV_in_AC_wasCast_Meta`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`
        ORDER BY a.`EV_in_AC_wasCast_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_part_PR_in_RAT_got_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_part_PR_in_RAT_got_ID`,
    `AC_ID_part`,
    `PR_ID_in`,
    `RAT_ID_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`
FROM
    ties.`AC_part_PR_in_RAT_got_Fact`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_part_PR_in_RAT_got_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_part_PR_in_RAT_got_ID`,
    `AC_ID_part`,
    `PR_ID_in`,
    `RAT_ID_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`
FROM
    ties.`AC_part_PR_in_RAT_got_Fact`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_part_PR_in_RAT_got_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_part_PR_in_RAT_got`,
    `AC_part_PR_in_RAT_got_ID`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    `AC_part_PR_in_RAT_got_Confidence`
FROM
    ties.`AC_part_PR_in_RAT_got_Meta`
WHERE
    `AC_part_PR_in_RAT_got_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_part_PR_in_RAT_got` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_part_PR_in_RAT_got`,
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Confidence`
FROM
    ties.`rAC_part_PR_in_RAT_got_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_part_PR_in_RAT_got_Meta`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`
        ORDER BY a.`AC_part_PR_in_RAT_got_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_part_PR_in_RAT_got` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_part_PR_in_RAT_got`,
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Confidence`
FROM
    ties.`fAC_part_PR_in_RAT_got_Fact`(changingTimepoint) p 
JOIN
    ties.`rAC_part_PR_in_RAT_got_Meta`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`
        ORDER BY a.`AC_part_PR_in_RAT_got_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_isPlaying_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    ties.`ST_at_PR_isPlaying_Fact`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_isPlaying_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    ties.`ST_at_PR_isPlaying_Fact`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_isPlaying_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_at_PR_isPlaying`,
    `ST_at_PR_isPlaying_ID`,
    `ST_at_PR_isPlaying_PositedAt`,
    `ST_at_PR_isPlaying_Confidence`
FROM
    ties.`ST_at_PR_isPlaying_Meta`
WHERE
    `ST_at_PR_isPlaying_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_isPlaying` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_isPlaying`,
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Confidence`
FROM
    ties.`rST_at_PR_isPlaying_Fact`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_isPlaying_Meta`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`
        ORDER BY a.`ST_at_PR_isPlaying_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_isPlaying` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_isPlaying`,
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Confidence`
FROM
    ties.`fST_at_PR_isPlaying_Fact`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_isPlaying_Meta`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`
        ORDER BY a.`ST_at_PR_isPlaying_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_parent_AC_child_PAT_having_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_parent_AC_child_PAT_having`,
    `AC_parent_AC_child_PAT_having_ID`,
    `AC_parent_AC_child_PAT_having_PositedAt`,
    `AC_parent_AC_child_PAT_having_Confidence`
FROM
    ties.`AC_parent_AC_child_PAT_having_Meta`
WHERE
    `AC_parent_AC_child_PAT_having_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_parent_AC_child_PAT_having` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_parent_AC_child_PAT_having`,
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Confidence`
FROM
    ties.`AC_parent_AC_child_PAT_having_Fact` p
JOIN
    ties.`rAC_parent_AC_child_PAT_having_Meta`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`
        ORDER BY a.`AC_parent_AC_child_PAT_having_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_parent_AC_child_PAT_having` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_parent_AC_child_PAT_having`,
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Confidence`
FROM
    ties.`AC_parent_AC_child_PAT_having_Fact` p
JOIN
    ties.`rAC_parent_AC_child_PAT_having_Meta`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`
        ORDER BY a.`AC_parent_AC_child_PAT_having_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_content_ST_location_EV_of_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_content_ST_location_EV_of_ID`,
    `PR_ID_content`,
    `ST_ID_location`,
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_ChangedAt`
FROM
    ties.`PR_content_ST_location_EV_of_Fact`
WHERE
    `PR_content_ST_location_EV_of_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_content_ST_location_EV_of_Fact` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_content_ST_location_EV_of_ID`,
    `PR_ID_content`,
    `ST_ID_location`,
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_ChangedAt`
FROM
    ties.`PR_content_ST_location_EV_of_Fact`
WHERE
    `PR_content_ST_location_EV_of_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_content_ST_location_EV_of_Meta` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_content_ST_location_EV_of`,
    `PR_content_ST_location_EV_of_ID`,
    `PR_content_ST_location_EV_of_PositedAt`,
    `PR_content_ST_location_EV_of_Confidence`
FROM
    ties.`PR_content_ST_location_EV_of_Meta`
WHERE
    `PR_content_ST_location_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_content_ST_location_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    p.`PR_content_ST_location_EV_of_ChangedAt`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Confidence`
FROM
    ties.`rPR_content_ST_location_EV_of_Fact`(changingTimepoint) p 
JOIN
    ties.`rPR_content_ST_location_EV_of_Meta`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_content_ST_location_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    p.`PR_content_ST_location_EV_of_ChangedAt`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Confidence`
FROM
    ties.`fPR_content_ST_location_EV_of_Fact`(changingTimepoint) p 
JOIN
    ties.`rPR_content_ST_location_EV_of_Meta`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`rAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`ONG_Ongoing` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`AC_ID_partner`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`AC_ID_with`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Confidence`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`tAC_partner_AC_with_ONG_currently`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_subset_PN_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_subset_PN_of_ID`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Confidence`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    ties.`rAC_subset_PN_of`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`AC_subset_PN_of_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`AC_ID_subset`
        ORDER BY
            t.`AC_subset_PN_of_PositedAt` DESC,
            t.`AC_subset_PN_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`PN_ID_of`
        ORDER BY
            t.`AC_subset_PN_of_PositedAt` DESC,
            t.`AC_subset_PN_of_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` AS
SELECT
    *
FROM
    ties.`tAC_subset_PN_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_subset_PN_of_ID`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Confidence`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    ties.`tAC_subset_PN_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    ties.`tAC_subset_PN_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tEV_in_AC_wasCast` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_wasCast_ID`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Confidence`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`
FROM
    ties.`rEV_in_AC_wasCast`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`EV_in_AC_wasCast_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`EV_ID_in`,
            t.`AC_ID_wasCast`
        ORDER BY
            t.`EV_in_AC_wasCast_PositedAt` DESC,
            t.`EV_in_AC_wasCast_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lEV_in_AC_wasCast` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_wasCast`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_wasCast_ID`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Confidence`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`
FROM
    ties.`tEV_in_AC_wasCast`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nEV_in_AC_wasCast` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_wasCast`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_part_PR_in_RAT_got` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `kRAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    ties.`rAC_part_PR_in_RAT_got`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
WHERE
    t.`AC_part_PR_in_RAT_got_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_part`,
            t.`PR_ID_in`
        ORDER BY
            t.`AC_part_PR_in_RAT_got_ChangedAt` DESC,
            t.`AC_part_PR_in_RAT_got_PositedAt` DESC,
            t.`AC_part_PR_in_RAT_got_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Confidence`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    ties.`tAC_part_PR_in_RAT_got`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tST_at_PR_isPlaying` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    ties.`rST_at_PR_isPlaying`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`ST_at_PR_isPlaying_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`ST_ID_at`,
            t.`PR_ID_isPlaying`
        ORDER BY
            t.`ST_at_PR_isPlaying_ChangedAt` DESC,
            t.`ST_at_PR_isPlaying_PositedAt` DESC,
            t.`ST_at_PR_isPlaying_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lST_at_PR_isPlaying` AS
SELECT
    *
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nST_at_PR_isPlaying` AS
SELECT
    *
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_isPlaying` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Confidence`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    ties.`tST_at_PR_isPlaying`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_parent_AC_child_PAT_having_ID`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Confidence`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    `kPAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `kPAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    t.`PAT_ID_having`
FROM
    ties.`rAC_parent_AC_child_PAT_having`(
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`PAT_ParentalType` `kPAT_having`
ON
    `kPAT_having`.`PAT_ID` = t.`PAT_ID_having`
WHERE
    t.`AC_parent_AC_child_PAT_having_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_parent`,
            t.`AC_ID_child`,
            t.`PAT_ID_having`
        ORDER BY
            t.`AC_parent_AC_child_PAT_having_PositedAt` DESC,
            t.`AC_parent_AC_child_PAT_having_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    ties.`tAC_parent_AC_child_PAT_having`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_parent_AC_child_PAT_having_ID`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Confidence`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    t.`having_PAT_ParentalType`,
    t.`having_Metadata_PAT`,
    t.`PAT_ID_having`
FROM
    ties.`tAC_parent_AC_child_PAT_having`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    ties.`tAC_parent_AC_child_PAT_having`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tPR_content_ST_location_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    ties.`rPR_content_ST_location_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`PR_content_ST_location_EV_of_Confidence` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`PR_ID_content`
        ORDER BY
            t.`PR_content_ST_location_EV_of_ChangedAt` DESC,
            t.`PR_content_ST_location_EV_of_PositedAt` DESC,
            t.`PR_content_ST_location_EV_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`ST_ID_location`
        ORDER BY
            t.`PR_content_ST_location_EV_of_ChangedAt` DESC,
            t.`PR_content_ST_location_EV_of_PositedAt` DESC,
            t.`PR_content_ST_location_EV_of_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_content_ST_location_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_ChangedAt`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Confidence`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    ties.`tPR_content_ST_location_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`PR_content_ST_location_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
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
ALTER TABLE attributes.`EV_DAT_Event_Date_Fact` ALTER COLUMN `EV_DAT_Event_Date` SET OPTIONS(description='Date and time when the event took place.');
ALTER TABLE attributes.`EV_AUD_Event_Audience_Fact` ALTER COLUMN `EV_AUD_Event_Audience` SET OPTIONS(description='Number of people in the audience at the event.');
ALTER TABLE attributes.`EV_REV_Event_Revenue_Fact` ALTER COLUMN `EV_REV_Event_Revenue` SET OPTIONS(description='Revenue from ticket sales for the event.');
ALTER TABLE attributes.`EV_STA_Event_Status_Fact` ALTER COLUMN `EV_STA_Event_Status` SET OPTIONS(description='Status of the event, which may change until it has taken place.');
ALTER TABLE attributes.`EV_LVL_Event_Level_Fact` ALTER COLUMN `EV_LVL_PLV_ID` SET OPTIONS(description='Professional level required for the event, over time.');
ALTER TABLE attributes.`ST_NAM_Stage_Name_Fact` ALTER COLUMN `ST_NAM_Stage_Name` SET OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.');
ALTER TABLE attributes.`ST_LOC_Stage_Location_Fact` ALTER COLUMN `ST_LOC_Stage_Location` SET OPTIONS(description='Geographic location of the stage as a geography point.');
ALTER TABLE attributes.`ST_AVG_Stage_Average_Fact` ALTER COLUMN `ST_AVG_UTL_ID` SET OPTIONS(description='Average utilization of the stage capacity, recalculated over time.');
ALTER TABLE attributes.`ST_MIN_Stage_Minimum_Fact` ALTER COLUMN `ST_MIN_UTL_ID` SET OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.');
ALTER TABLE attributes.`AC_NAM_Actor_Name_Fact` ALTER COLUMN `AC_NAM_Actor_Name` SET OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.');
ALTER TABLE attributes.`AC_GEN_Actor_Gender_Fact` ALTER COLUMN `AC_GEN_GEN_ID` SET OPTIONS(description='Gender of the actor.');
ALTER TABLE attributes.`AC_PLV_Actor_ProfessionalLevel_Fact` ALTER COLUMN `AC_PLV_PLV_ID` SET OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.');
ALTER TABLE attributes.`PR_NAM_Program_Name_Fact` ALTER COLUMN `PR_NAM_Program_Name` SET OPTIONS(description='Name or title of the program.');
ALTER TABLE attributes.`PR_LEN_Program_Length_Fact` ALTER COLUMN `PR_LEN_Program_Length` SET OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.');
ALTER TABLE anchors.`PN_Person` SET OPTIONS(description='A person. Persons who perform are also registered as actors.');
ALTER TABLE anchors.`ST_Stage` SET OPTIONS(description='A stage or venue where programs are played and events are held.');
ALTER TABLE anchors.`AC_Actor` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE nexuses.`EV_Event` SET OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.');
ALTER TABLE nexuses.`EV_Event` ALTER COLUMN `ST_ID_wasHeldAt` SET OPTIONS(description='The stage at which the event was held.');
ALTER TABLE nexuses.`EV_Event` ALTER COLUMN `PR_ID_wasPlayed` SET OPTIONS(description='The program that was played at the event.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Fact` SET OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Fact` ALTER COLUMN `AC_ID_partner` SET OPTIONS(description='One of the actors in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Fact` ALTER COLUMN `AC_ID_with` SET OPTIONS(description='The other actor in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Fact` ALTER COLUMN `ONG_ID_currently` SET OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).');
ALTER TABLE ties.`AC_subset_PN_of_Fact` ALTER COLUMN `AC_ID_subset` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE ties.`AC_subset_PN_of_Fact` ALTER COLUMN `PN_ID_of` SET OPTIONS(description='The person who is the actor.');
ALTER TABLE ties.`EV_in_AC_wasCast_Fact` SET OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.');
ALTER TABLE ties.`EV_in_AC_wasCast_Fact` ALTER COLUMN `EV_ID_in` SET OPTIONS(description='The event the actor was cast in.');
ALTER TABLE ties.`EV_in_AC_wasCast_Fact` ALTER COLUMN `AC_ID_wasCast` SET OPTIONS(description='An actor cast in the event.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got_Fact` SET OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got_Fact` ALTER COLUMN `AC_ID_part` SET OPTIONS(description='The actor having a part in the program.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got_Fact` ALTER COLUMN `PR_ID_in` SET OPTIONS(description='The program the actor has a part in.');
ALTER TABLE ties.`AC_part_PR_in_RAT_got_Fact` ALTER COLUMN `RAT_ID_got` SET OPTIONS(description='The rating the actor got for the part.');
ALTER TABLE ties.`ST_at_PR_isPlaying_Fact` SET OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.');
ALTER TABLE ties.`ST_at_PR_isPlaying_Fact` ALTER COLUMN `ST_ID_at` SET OPTIONS(description='The stage where the program is playing.');
ALTER TABLE ties.`ST_at_PR_isPlaying_Fact` ALTER COLUMN `PR_ID_isPlaying` SET OPTIONS(description='The program playing at the stage.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having_Fact` SET OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having_Fact` ALTER COLUMN `AC_ID_parent` SET OPTIONS(description='The actor who is the parent.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having_Fact` ALTER COLUMN `AC_ID_child` SET OPTIONS(description='The actor who is the child.');
ALTER TABLE ties.`AC_parent_AC_child_PAT_having_Fact` ALTER COLUMN `PAT_ID_having` SET OPTIONS(description='The type of parental relationship.');
ALTER TABLE ties.`PR_content_ST_location_EV_of_Fact` SET OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.');
ALTER TABLE ties.`PR_content_ST_location_EV_of_Fact` ALTER COLUMN `PR_ID_content` SET OPTIONS(description='The program that made up the content of the event.');
ALTER TABLE ties.`PR_content_ST_location_EV_of_Fact` ALTER COLUMN `ST_ID_location` SET OPTIONS(description='The stage where the event was located.');
ALTER TABLE ties.`PR_content_ST_location_EV_of_Fact` ALTER COLUMN `EV_ID_of` SET OPTIONS(description='The event.');
