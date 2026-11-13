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
