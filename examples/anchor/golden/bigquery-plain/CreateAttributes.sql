-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_DAT_Event_Date` (
    `EV_ID` int64 not null,
    `EV_DAT_Event_Date` datetime not null,
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date` FOREIGN KEY (`EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_AUD_Event_Audience` (
    `EV_ID` int64 not null,
    `EV_AUD_Event_Audience` int64 not null,
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience` FOREIGN KEY (`EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_REV_Event_Revenue` (
    `EV_ID` int64 not null,
    `EV_REV_Event_Revenue` numeric(19,4) not null,
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue` FOREIGN KEY (`EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_NAM_Stage_Name` (
    `ST_ID` int64 not null,
    `ST_NAM_Stage_Name` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_ID`,
        `ST_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name` FOREIGN KEY (`ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_ID`, `ST_NAM_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS public.`ST_LOC_Stage_Location` (
    `ST_ID` int64 not null,
    `ST_LOC_Stage_Location` geography not null,
    `ST_LOC_Checksum` int64,
    PRIMARY KEY (
        `ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location` FOREIGN KEY (`ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_AVG_Stage_Average` (
    `ST_ID` int64 not null,
    `UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_ID`,
        `ST_AVG_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Stage_Average` FOREIGN KEY (`ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Stage_Average` FOREIGN KEY (`UTL_ID`) REFERENCES
        public.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_ID`, `ST_AVG_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_MIN_Stage_Minimum` (
    `ST_ID` int64 not null,
    `UTL_ID` int64 not null,
    PRIMARY KEY (
        `ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Stage_Minimum` FOREIGN KEY (`ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Stage_Minimum` FOREIGN KEY (`UTL_ID`) REFERENCES
        public.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_NAM_Actor_Name` (
    `AC_ID` int64 not null,
    `AC_NAM_Actor_Name` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_ID`,
        `AC_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name` FOREIGN KEY (`AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_ID`, `AC_NAM_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_GEN_Actor_Gender` (
    `AC_ID` int64 not null,
    `GEN_ID` int64 not null,
    PRIMARY KEY (
        `AC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Actor_Gender` FOREIGN KEY (`AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Actor_Gender` FOREIGN KEY (`GEN_ID`) REFERENCES
        public.`GEN_Gender`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_PLV_Actor_ProfessionalLevel` (
    `AC_ID` int64 not null,
    `PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_ID`,
        `AC_PLV_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Actor_ProfessionalLevel` FOREIGN KEY (`AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Actor_ProfessionalLevel` FOREIGN KEY (`PLV_ID`) REFERENCES
        public.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_ID`, `AC_PLV_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_NAM_Program_Name` (
    `PR_ID` int64 not null,
    `PR_NAM_Program_Name` string(42) not null,
    PRIMARY KEY (
        `PR_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name` FOREIGN KEY (`PR_ID`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_LEN_Program_Length` (
    `PR_ID` int64 not null,
    `PR_LEN_Program_Length` time not null,
    `PR_LEN_ChangedAt` date not null,
    PRIMARY KEY (
        `PR_ID`,
        `PR_LEN_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length` FOREIGN KEY (`PR_ID`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_ID`, `PR_LEN_ChangedAt`;
