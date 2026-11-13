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
