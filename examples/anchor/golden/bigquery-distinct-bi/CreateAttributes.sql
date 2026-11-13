-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
-- BigQuery has no sequences: the load gives an identity to every posit. Its keys are not enforced, and it has no unique
-- constraints: what a posit table holds once is kept so by the load (the integrity checks tell if it has not).
--
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Event_Date_Posit` (
    `EV_DAT_ID` int64 not null,
    `EV_DAT_EV_ID` numeric(12,0) not null,
    `EV_DAT_Event_Date` datetime not null,
    PRIMARY KEY (
        `EV_DAT_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date_Posit` FOREIGN KEY (`EV_DAT_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Event_Date_Annex` (
    `EV_DAT_ID` int64 not null,
    `EV_DAT_PositedAt` datetime not null,
    `EV_DAT_Reliability` numeric(5,2) not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_ID`,
        `EV_DAT_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date_Annex` FOREIGN KEY (`EV_DAT_ID`) REFERENCES
        attributes.`EV_DAT_Event_Date_Posit`(`EV_DAT_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_ID`, `EV_DAT_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Event_Audience_Posit` (
    `EV_AUD_ID` int64 not null,
    `EV_AUD_EV_ID` numeric(12,0) not null,
    `EV_AUD_Event_Audience` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience_Posit` FOREIGN KEY (`EV_AUD_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Event_Audience_Annex` (
    `EV_AUD_ID` int64 not null,
    `EV_AUD_PositedAt` datetime not null,
    `EV_AUD_Reliability` numeric(5,2) not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`,
        `EV_AUD_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience_Annex` FOREIGN KEY (`EV_AUD_ID`) REFERENCES
        attributes.`EV_AUD_Event_Audience_Posit`(`EV_AUD_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_ID`, `EV_AUD_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Event_Revenue_Posit` (
    `EV_REV_ID` int64 not null,
    `EV_REV_EV_ID` numeric(12,0) not null,
    `EV_REV_Event_Revenue` numeric(19,4) not null,
    PRIMARY KEY (
        `EV_REV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue_Posit` FOREIGN KEY (`EV_REV_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Event_Revenue_Annex` (
    `EV_REV_ID` int64 not null,
    `EV_REV_PositedAt` datetime not null,
    `EV_REV_Reliability` numeric(5,2) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_ID`,
        `EV_REV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue_Annex` FOREIGN KEY (`EV_REV_ID`) REFERENCES
        attributes.`EV_REV_Event_Revenue_Posit`(`EV_REV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_ID`, `EV_REV_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Event_Status_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Event_Status_Posit` (
    `EV_STA_ID` int64 not null,
    `EV_STA_EV_ID` numeric(12,0) not null,
    `EV_STA_Event_Status` string(20) not null,
    `EV_STA_ChangedAt` datetime not null,
    PRIMARY KEY (
        `EV_STA_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Event_Status_Posit` FOREIGN KEY (`EV_STA_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Event_Status_Annex table (of EV_STA_Event_Status_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Event_Status_Annex` (
    `EV_STA_ID` int64 not null,
    `EV_STA_PositedAt` datetime not null,
    `EV_STA_Reliability` numeric(5,2) not null,
    `Metadata_EV_STA` int64 not null,
    PRIMARY KEY (
        `EV_STA_ID`,
        `EV_STA_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Event_Status_Annex` FOREIGN KEY (`EV_STA_ID`) REFERENCES
        attributes.`EV_STA_Event_Status_Posit`(`EV_STA_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_ID`, `EV_STA_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Event_Utilization_Posit` (
    `EV_UTL_ID` int64 not null,
    `EV_UTL_EV_ID` numeric(12,0) not null,
    `EV_UTL_UTL_ID` int64 not null,
    PRIMARY KEY (
        `EV_UTL_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_UTL_Event_Utilization_Posit` FOREIGN KEY (`EV_UTL_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_UTL_Event_Utilization_Posit` FOREIGN KEY (`EV_UTL_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Annex table (of EV_UTL_Event_Utilization_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Event_Utilization_Annex` (
    `EV_UTL_ID` int64 not null,
    `EV_UTL_PositedAt` datetime not null,
    `EV_UTL_Reliability` numeric(5,2) not null,
    `Metadata_EV_UTL` int64 not null,
    PRIMARY KEY (
        `EV_UTL_ID`,
        `EV_UTL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_UTL_Event_Utilization_Annex` FOREIGN KEY (`EV_UTL_ID`) REFERENCES
        attributes.`EV_UTL_Event_Utilization_Posit`(`EV_UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_ID`, `EV_UTL_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Event_Level_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Event_Level_Posit` (
    `EV_LVL_ID` int64 not null,
    `EV_LVL_EV_ID` numeric(12,0) not null,
    `EV_LVL_PLV_ID` int64 not null,
    `EV_LVL_ChangedAt` date not null,
    PRIMARY KEY (
        `EV_LVL_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_LVL_Event_Level_Posit` FOREIGN KEY (`EV_LVL_EV_ID`) REFERENCES
        nexuses.`EV_Event`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_LVL_Event_Level_Posit` FOREIGN KEY (`EV_LVL_PLV_ID`) REFERENCES
        knots.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level_Annex table (of EV_LVL_Event_Level_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Event_Level_Annex` (
    `EV_LVL_ID` int64 not null,
    `EV_LVL_PositedAt` datetime not null,
    `EV_LVL_Reliability` numeric(5,2) not null,
    `Metadata_EV_LVL` int64 not null,
    PRIMARY KEY (
        `EV_LVL_ID`,
        `EV_LVL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_LVL_Event_Level_Annex` FOREIGN KEY (`EV_LVL_ID`) REFERENCES
        attributes.`EV_LVL_Event_Level_Posit`(`EV_LVL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_ID`, `EV_LVL_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Stage_Name_Posit` (
    `ST_NAM_ID` int64 not null,
    `ST_NAM_ST_ID` int64 not null,
    `ST_NAM_Stage_Name` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name_Posit` FOREIGN KEY (`ST_NAM_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Stage_Name_Annex` (
    `ST_NAM_ID` int64 not null,
    `ST_NAM_PositedAt` datetime not null,
    `ST_NAM_Reliability` numeric(5,2) not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ID`,
        `ST_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name_Annex` FOREIGN KEY (`ST_NAM_ID`) REFERENCES
        attributes.`ST_NAM_Stage_Name_Posit`(`ST_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ID`, `ST_NAM_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Stage_Location_Posit` (
    `ST_LOC_ID` int64 not null,
    `ST_LOC_ST_ID` int64 not null,
    `ST_LOC_Stage_Location` geography not null,
    `ST_LOC_Checksum` int64,
    PRIMARY KEY (
        `ST_LOC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location_Posit` FOREIGN KEY (`ST_LOC_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Stage_Location_Annex` (
    `ST_LOC_ID` int64 not null,
    `ST_LOC_PositedAt` datetime not null,
    `ST_LOC_Reliability` numeric(5,2) not null,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ID`,
        `ST_LOC_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location_Annex` FOREIGN KEY (`ST_LOC_ID`) REFERENCES
        attributes.`ST_LOC_Stage_Location_Posit`(`ST_LOC_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ID`, `ST_LOC_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Stage_Average_Posit` (
    `ST_AVG_ID` int64 not null,
    `ST_AVG_ST_ID` int64 not null,
    `ST_AVG_UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_AVG_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Stage_Average_Posit` FOREIGN KEY (`ST_AVG_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Stage_Average_Posit` FOREIGN KEY (`ST_AVG_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Stage_Average_Annex` (
    `ST_AVG_ID` int64 not null,
    `ST_AVG_PositedAt` datetime not null,
    `ST_AVG_Reliability` numeric(5,2) not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ID`,
        `ST_AVG_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_AVG_Stage_Average_Annex` FOREIGN KEY (`ST_AVG_ID`) REFERENCES
        attributes.`ST_AVG_Stage_Average_Posit`(`ST_AVG_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ID`, `ST_AVG_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Stage_Minimum_Posit` (
    `ST_MIN_ID` int64 not null,
    `ST_MIN_ST_ID` int64 not null,
    `ST_MIN_UTL_ID` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Stage_Minimum_Posit` FOREIGN KEY (`ST_MIN_ST_ID`) REFERENCES
        anchors.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Stage_Minimum_Posit` FOREIGN KEY (`ST_MIN_UTL_ID`) REFERENCES
        knots.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Stage_Minimum_Annex` (
    `ST_MIN_ID` int64 not null,
    `ST_MIN_PositedAt` datetime not null,
    `ST_MIN_Reliability` numeric(5,2) not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`,
        `ST_MIN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_MIN_Stage_Minimum_Annex` FOREIGN KEY (`ST_MIN_ID`) REFERENCES
        attributes.`ST_MIN_Stage_Minimum_Posit`(`ST_MIN_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ID`, `ST_MIN_PositedAt`;
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Actor_Name_Posit` (
    `AC_NAM_ID` int64 not null,
    `AC_NAM_AC_ID` int64 not null,
    `AC_NAM_Actor_Name` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name_Posit` FOREIGN KEY (`AC_NAM_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Actor_Name_Annex` (
    `AC_NAM_ID` int64 not null,
    `AC_NAM_PositedAt` datetime not null,
    `AC_NAM_Reliability` numeric(5,2) not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_ID`,
        `AC_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name_Annex` FOREIGN KEY (`AC_NAM_ID`) REFERENCES
        attributes.`AC_NAM_Actor_Name_Posit`(`AC_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_ID`, `AC_NAM_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Actor_Gender_Posit` (
    `AC_GEN_ID` int64 not null,
    `AC_GEN_AC_ID` int64 not null,
    `AC_GEN_GEN_ID` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Actor_Gender_Posit` FOREIGN KEY (`AC_GEN_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Actor_Gender_Posit` FOREIGN KEY (`AC_GEN_GEN_ID`) REFERENCES
        knots.`GEN_Gender`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Actor_Gender_Annex` (
    `AC_GEN_ID` int64 not null,
    `AC_GEN_PositedAt` datetime not null,
    `AC_GEN_Reliability` numeric(5,2) not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`,
        `AC_GEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_GEN_Actor_Gender_Annex` FOREIGN KEY (`AC_GEN_ID`) REFERENCES
        attributes.`AC_GEN_Actor_Gender_Posit`(`AC_GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_ID`, `AC_GEN_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Actor_ProfessionalLevel_Posit` (
    `AC_PLV_ID` int64 not null,
    `AC_PLV_AC_ID` int64 not null,
    `AC_PLV_PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_PLV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Actor_ProfessionalLevel_Posit` FOREIGN KEY (`AC_PLV_AC_ID`) REFERENCES
        anchors.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Actor_ProfessionalLevel_Posit` FOREIGN KEY (`AC_PLV_PLV_ID`) REFERENCES
        knots.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Actor_ProfessionalLevel_Annex` (
    `AC_PLV_ID` int64 not null,
    `AC_PLV_PositedAt` datetime not null,
    `AC_PLV_Reliability` numeric(5,2) not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_ID`,
        `AC_PLV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_PLV_Actor_ProfessionalLevel_Annex` FOREIGN KEY (`AC_PLV_ID`) REFERENCES
        attributes.`AC_PLV_Actor_ProfessionalLevel_Posit`(`AC_PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_ID`, `AC_PLV_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Program_Name_Posit` (
    `PR_NAM_ID` int64 not null,
    `PR_NAM_PR_ID` int64 not null,
    `PR_NAM_Program_Name` string(42) not null,
    PRIMARY KEY (
        `PR_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name_Posit` FOREIGN KEY (`PR_NAM_PR_ID`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Program_Name_Annex` (
    `PR_NAM_ID` int64 not null,
    `PR_NAM_PositedAt` datetime not null,
    `PR_NAM_Reliability` numeric(5,2) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_ID`,
        `PR_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name_Annex` FOREIGN KEY (`PR_NAM_ID`) REFERENCES
        attributes.`PR_NAM_Program_Name_Posit`(`PR_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_ID`, `PR_NAM_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Program_Length_Posit` (
    `PR_LEN_ID` int64 not null,
    `PR_LEN_PR_ID` int64 not null,
    `PR_LEN_Program_Length` time not null,
    `PR_LEN_ChangedAt` date not null,
    PRIMARY KEY (
        `PR_LEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length_Posit` FOREIGN KEY (`PR_LEN_PR_ID`) REFERENCES
        anchors.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Program_Length_Annex` (
    `PR_LEN_ID` int64 not null,
    `PR_LEN_PositedAt` datetime not null,
    `PR_LEN_Reliability` numeric(5,2) not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_ID`,
        `PR_LEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length_Annex` FOREIGN KEY (`PR_LEN_ID`) REFERENCES
        attributes.`PR_LEN_Program_Length_Posit`(`PR_LEN_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_ID`, `PR_LEN_PositedAt`;
