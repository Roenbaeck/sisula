-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS public;
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
CREATE TABLE IF NOT EXISTS public.`PAT_ParentalType` (
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
CREATE TABLE IF NOT EXISTS public.`GEN_Gender` (
    `GEN_ID` int64 not null,
    `GEN_Gender` string(42) not null,
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
CREATE TABLE IF NOT EXISTS public.`PLV_ProfessionalLevel` (
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
CREATE TABLE IF NOT EXISTS public.`UTL_Utilization` (
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
CREATE TABLE IF NOT EXISTS public.`ONG_Ongoing` (
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
CREATE TABLE IF NOT EXISTS public.`RAT_Rating` (
    `RAT_ID` int64 not null,
    `RAT_Rating` string(42) not null,
    `Metadata_RAT` int64 not null,
    PRIMARY KEY (
        `RAT_ID`
    ) NOT ENFORCED
)
CLUSTER BY `RAT_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ETY_EventType` (
    `ETY_ID` int64 not null,
    `ETY_EventType` string(42) not null,
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
CREATE TABLE IF NOT EXISTS public.`PN_Person` (
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
CREATE TABLE IF NOT EXISTS public.`ST_Stage` (
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
CREATE TABLE IF NOT EXISTS public.`AC_Actor` (
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
CREATE TABLE IF NOT EXISTS public.`PR_Program` (
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
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_Event` (
    `EV_ID` int64 not null,
    `ST_ID_wasHeldAt` int64 not null, 
    `PR_ID_wasPlayed` int64 not null, 
    `ETY_ID_of` int64 not null,
    `Metadata_EV` int64 not null, 
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkST_wasHeldAt` FOREIGN KEY (`ST_ID_wasHeldAt`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkPR_wasPlayed` FOREIGN KEY (`PR_ID_wasPlayed`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Event_fkETY_of` FOREIGN KEY (`ETY_ID_of`) REFERENCES
        public.`ETY_EventType`(`ETY_ID`) NOT ENFORCED
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
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_DAT_Event_Date_Posit` (
    `EV_DAT_ID` int64 not null,
    `EV_DAT_EV_ID` int64 not null,
    `EV_DAT_Event_Date` datetime not null,
    PRIMARY KEY (
        `EV_DAT_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date_Posit` FOREIGN KEY (`EV_DAT_EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_DAT_Event_Date_Annex` (
    `EV_DAT_ID` int64 not null,
    `EV_DAT_PositedAt` datetime not null,
    `EV_DAT_Reliability` numeric(5,2) not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_ID`,
        `EV_DAT_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date_Annex` FOREIGN KEY (`EV_DAT_ID`) REFERENCES
        public.`EV_DAT_Event_Date_Posit`(`EV_DAT_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_ID`, `EV_DAT_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_AUD_Event_Audience_Posit` (
    `EV_AUD_ID` int64 not null,
    `EV_AUD_EV_ID` int64 not null,
    `EV_AUD_Event_Audience` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience_Posit` FOREIGN KEY (`EV_AUD_EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_AUD_Event_Audience_Annex` (
    `EV_AUD_ID` int64 not null,
    `EV_AUD_PositedAt` datetime not null,
    `EV_AUD_Reliability` numeric(5,2) not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`,
        `EV_AUD_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience_Annex` FOREIGN KEY (`EV_AUD_ID`) REFERENCES
        public.`EV_AUD_Event_Audience_Posit`(`EV_AUD_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_ID`, `EV_AUD_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_REV_Event_Revenue_Posit` (
    `EV_REV_ID` int64 not null,
    `EV_REV_EV_ID` int64 not null,
    `EV_REV_Event_Revenue` numeric(19,4) not null,
    PRIMARY KEY (
        `EV_REV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue_Posit` FOREIGN KEY (`EV_REV_EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_REV_Event_Revenue_Annex` (
    `EV_REV_ID` int64 not null,
    `EV_REV_PositedAt` datetime not null,
    `EV_REV_Reliability` numeric(5,2) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_ID`,
        `EV_REV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue_Annex` FOREIGN KEY (`EV_REV_ID`) REFERENCES
        public.`EV_REV_Event_Revenue_Posit`(`EV_REV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_ID`, `EV_REV_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_NAM_Stage_Name_Posit` (
    `ST_NAM_ID` int64 not null,
    `ST_NAM_ST_ID` int64 not null,
    `ST_NAM_Stage_Name` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name_Posit` FOREIGN KEY (`ST_NAM_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_NAM_Stage_Name_Annex` (
    `ST_NAM_ID` int64 not null,
    `ST_NAM_PositedAt` datetime not null,
    `ST_NAM_Reliability` numeric(5,2) not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ID`,
        `ST_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name_Annex` FOREIGN KEY (`ST_NAM_ID`) REFERENCES
        public.`ST_NAM_Stage_Name_Posit`(`ST_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ID`, `ST_NAM_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS public.`ST_LOC_Stage_Location_Posit` (
    `ST_LOC_ID` int64 not null,
    `ST_LOC_ST_ID` int64 not null,
    `ST_LOC_Stage_Location` geography not null,
    `ST_LOC_Checksum` int64,
    PRIMARY KEY (
        `ST_LOC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location_Posit` FOREIGN KEY (`ST_LOC_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_LOC_Stage_Location_Annex` (
    `ST_LOC_ID` int64 not null,
    `ST_LOC_PositedAt` datetime not null,
    `ST_LOC_Reliability` numeric(5,2) not null,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ID`,
        `ST_LOC_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location_Annex` FOREIGN KEY (`ST_LOC_ID`) REFERENCES
        public.`ST_LOC_Stage_Location_Posit`(`ST_LOC_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ID`, `ST_LOC_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_AVG_Stage_Average_Posit` (
    `ST_AVG_ID` int64 not null,
    `ST_AVG_ST_ID` int64 not null,
    `ST_AVG_UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_AVG_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Stage_Average_Posit` FOREIGN KEY (`ST_AVG_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Stage_Average_Posit` FOREIGN KEY (`ST_AVG_UTL_ID`) REFERENCES
        public.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_AVG_Stage_Average_Annex` (
    `ST_AVG_ID` int64 not null,
    `ST_AVG_PositedAt` datetime not null,
    `ST_AVG_Reliability` numeric(5,2) not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ID`,
        `ST_AVG_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_AVG_Stage_Average_Annex` FOREIGN KEY (`ST_AVG_ID`) REFERENCES
        public.`ST_AVG_Stage_Average_Posit`(`ST_AVG_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ID`, `ST_AVG_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_MIN_Stage_Minimum_Posit` (
    `ST_MIN_ID` int64 not null,
    `ST_MIN_ST_ID` int64 not null,
    `ST_MIN_UTL_ID` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Stage_Minimum_Posit` FOREIGN KEY (`ST_MIN_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Stage_Minimum_Posit` FOREIGN KEY (`ST_MIN_UTL_ID`) REFERENCES
        public.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_MIN_Stage_Minimum_Annex` (
    `ST_MIN_ID` int64 not null,
    `ST_MIN_PositedAt` datetime not null,
    `ST_MIN_Reliability` numeric(5,2) not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`,
        `ST_MIN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_MIN_Stage_Minimum_Annex` FOREIGN KEY (`ST_MIN_ID`) REFERENCES
        public.`ST_MIN_Stage_Minimum_Posit`(`ST_MIN_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ID`, `ST_MIN_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_NAM_Actor_Name_Posit` (
    `AC_NAM_ID` int64 not null,
    `AC_NAM_AC_ID` int64 not null,
    `AC_NAM_Actor_Name` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name_Posit` FOREIGN KEY (`AC_NAM_AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_NAM_Actor_Name_Annex` (
    `AC_NAM_ID` int64 not null,
    `AC_NAM_PositedAt` datetime not null,
    `AC_NAM_Reliability` numeric(5,2) not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_ID`,
        `AC_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name_Annex` FOREIGN KEY (`AC_NAM_ID`) REFERENCES
        public.`AC_NAM_Actor_Name_Posit`(`AC_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_ID`, `AC_NAM_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_GEN_Actor_Gender_Posit` (
    `AC_GEN_ID` int64 not null,
    `AC_GEN_AC_ID` int64 not null,
    `AC_GEN_GEN_ID` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Actor_Gender_Posit` FOREIGN KEY (`AC_GEN_AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Actor_Gender_Posit` FOREIGN KEY (`AC_GEN_GEN_ID`) REFERENCES
        public.`GEN_Gender`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_GEN_Actor_Gender_Annex` (
    `AC_GEN_ID` int64 not null,
    `AC_GEN_PositedAt` datetime not null,
    `AC_GEN_Reliability` numeric(5,2) not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`,
        `AC_GEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_GEN_Actor_Gender_Annex` FOREIGN KEY (`AC_GEN_ID`) REFERENCES
        public.`AC_GEN_Actor_Gender_Posit`(`AC_GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_ID`, `AC_GEN_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_PLV_Actor_ProfessionalLevel_Posit` (
    `AC_PLV_ID` int64 not null,
    `AC_PLV_AC_ID` int64 not null,
    `AC_PLV_PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_PLV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Actor_ProfessionalLevel_Posit` FOREIGN KEY (`AC_PLV_AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Actor_ProfessionalLevel_Posit` FOREIGN KEY (`AC_PLV_PLV_ID`) REFERENCES
        public.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_PLV_Actor_ProfessionalLevel_Annex` (
    `AC_PLV_ID` int64 not null,
    `AC_PLV_PositedAt` datetime not null,
    `AC_PLV_Reliability` numeric(5,2) not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_ID`,
        `AC_PLV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_PLV_Actor_ProfessionalLevel_Annex` FOREIGN KEY (`AC_PLV_ID`) REFERENCES
        public.`AC_PLV_Actor_ProfessionalLevel_Posit`(`AC_PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_ID`, `AC_PLV_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_NAM_Program_Name_Posit` (
    `PR_NAM_ID` int64 not null,
    `PR_NAM_PR_ID` int64 not null,
    `PR_NAM_Program_Name` string(42) not null,
    PRIMARY KEY (
        `PR_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name_Posit` FOREIGN KEY (`PR_NAM_PR_ID`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_NAM_Program_Name_Annex` (
    `PR_NAM_ID` int64 not null,
    `PR_NAM_PositedAt` datetime not null,
    `PR_NAM_Reliability` numeric(5,2) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_ID`,
        `PR_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name_Annex` FOREIGN KEY (`PR_NAM_ID`) REFERENCES
        public.`PR_NAM_Program_Name_Posit`(`PR_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_ID`, `PR_NAM_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_LEN_Program_Length_Posit` (
    `PR_LEN_ID` int64 not null,
    `PR_LEN_PR_ID` int64 not null,
    `PR_LEN_Program_Length` time not null,
    `PR_LEN_ChangedAt` date not null,
    PRIMARY KEY (
        `PR_LEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length_Posit` FOREIGN KEY (`PR_LEN_PR_ID`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_LEN_Program_Length_Annex` (
    `PR_LEN_ID` int64 not null,
    `PR_LEN_PositedAt` datetime not null,
    `PR_LEN_Reliability` numeric(5,2) not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_ID`,
        `PR_LEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length_Annex` FOREIGN KEY (`PR_LEN_ID`) REFERENCES
        public.`PR_LEN_Program_Length_Posit`(`PR_LEN_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_ID`, `PR_LEN_PositedAt`;
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public.`EV_DAT_Event_Date` AS
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Event_Date`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Reliability`
FROM
    public.`EV_DAT_Event_Date_Posit` p
JOIN
    public.`EV_DAT_Event_Date_Annex` a
ON
    a.`EV_DAT_ID` = p.`EV_DAT_ID`
;
CREATE OR REPLACE VIEW public.`EV_AUD_Event_Audience` AS
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Event_Audience`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Reliability`
FROM
    public.`EV_AUD_Event_Audience_Posit` p
JOIN
    public.`EV_AUD_Event_Audience_Annex` a
ON
    a.`EV_AUD_ID` = p.`EV_AUD_ID`
;
CREATE OR REPLACE VIEW public.`EV_REV_Event_Revenue` AS
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Event_Revenue`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Reliability`
FROM
    public.`EV_REV_Event_Revenue_Posit` p
JOIN
    public.`EV_REV_Event_Revenue_Annex` a
ON
    a.`EV_REV_ID` = p.`EV_REV_ID`
;
CREATE OR REPLACE VIEW public.`ST_NAM_Stage_Name` AS
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Reliability`
FROM
    public.`ST_NAM_Stage_Name_Posit` p
JOIN
    public.`ST_NAM_Stage_Name_Annex` a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
;
CREATE OR REPLACE VIEW public.`ST_LOC_Stage_Location` AS
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Stage_Location`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Reliability`
FROM
    public.`ST_LOC_Stage_Location_Posit` p
JOIN
    public.`ST_LOC_Stage_Location_Annex` a
ON
    a.`ST_LOC_ID` = p.`ST_LOC_ID`
;
CREATE OR REPLACE VIEW public.`ST_AVG_Stage_Average` AS
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Reliability`
FROM
    public.`ST_AVG_Stage_Average_Posit` p
JOIN
    public.`ST_AVG_Stage_Average_Annex` a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
;
CREATE OR REPLACE VIEW public.`ST_MIN_Stage_Minimum` AS
SELECT
    a.`Metadata_ST_MIN`,
    p.`ST_MIN_ID`,
    p.`ST_MIN_ST_ID`,
    p.`ST_MIN_UTL_ID`,
    a.`ST_MIN_PositedAt`,
    a.`ST_MIN_Reliability`
FROM
    public.`ST_MIN_Stage_Minimum_Posit` p
JOIN
    public.`ST_MIN_Stage_Minimum_Annex` a
ON
    a.`ST_MIN_ID` = p.`ST_MIN_ID`
;
CREATE OR REPLACE VIEW public.`AC_NAM_Actor_Name` AS
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Reliability`
FROM
    public.`AC_NAM_Actor_Name_Posit` p
JOIN
    public.`AC_NAM_Actor_Name_Annex` a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
;
CREATE OR REPLACE VIEW public.`AC_GEN_Actor_Gender` AS
SELECT
    a.`Metadata_AC_GEN`,
    p.`AC_GEN_ID`,
    p.`AC_GEN_AC_ID`,
    p.`AC_GEN_GEN_ID`,
    a.`AC_GEN_PositedAt`,
    a.`AC_GEN_Reliability`
FROM
    public.`AC_GEN_Actor_Gender_Posit` p
JOIN
    public.`AC_GEN_Actor_Gender_Annex` a
ON
    a.`AC_GEN_ID` = p.`AC_GEN_ID`
;
CREATE OR REPLACE VIEW public.`AC_PLV_Actor_ProfessionalLevel` AS
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Reliability`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit` p
JOIN
    public.`AC_PLV_Actor_ProfessionalLevel_Annex` a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
;
CREATE OR REPLACE VIEW public.`PR_NAM_Program_Name` AS
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Program_Name`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Reliability`
FROM
    public.`PR_NAM_Program_Name_Posit` p
JOIN
    public.`PR_NAM_Program_Name_Annex` a
ON
    a.`PR_NAM_ID` = p.`PR_NAM_ID`
;
CREATE OR REPLACE VIEW public.`PR_LEN_Program_Length` AS
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Reliability`
FROM
    public.`PR_LEN_Program_Length_Posit` p
JOIN
    public.`PR_LEN_Program_Length_Annex` a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION public.`rEV_DAT_Event_Date_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_DAT`,
    `EV_DAT_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Reliability`
FROM
    public.`EV_DAT_Event_Date_Annex`
WHERE
    `EV_DAT_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_DAT_Event_Date` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Reliability`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Event_Date`
FROM
    public.`EV_DAT_Event_Date_Posit` p
JOIN
    public.`rEV_DAT_Event_Date_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rEV_AUD_Event_Audience_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_AUD`,
    `EV_AUD_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Reliability`
FROM
    public.`EV_AUD_Event_Audience_Annex`
WHERE
    `EV_AUD_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_AUD_Event_Audience` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Reliability`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Event_Audience`
FROM
    public.`EV_AUD_Event_Audience_Posit` p
JOIN
    public.`rEV_AUD_Event_Audience_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rEV_REV_Event_Revenue_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_REV`,
    `EV_REV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Reliability`
FROM
    public.`EV_REV_Event_Revenue_Annex`
WHERE
    `EV_REV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_REV_Event_Revenue` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Reliability`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Event_Revenue`
FROM
    public.`EV_REV_Event_Revenue_Posit` p
JOIN
    public.`rEV_REV_Event_Revenue_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    public.`ST_NAM_Stage_Name_Posit`
WHERE
    `ST_NAM_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_NAM_Stage_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Stage_Name`,
    `ST_NAM_ChangedAt`
FROM
    public.`ST_NAM_Stage_Name_Posit`
WHERE
    `ST_NAM_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_NAM`,
    `ST_NAM_ID`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Reliability`
FROM
    public.`ST_NAM_Stage_Name_Annex`
WHERE
    `ST_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Reliability`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    public.`rST_NAM_Stage_Name_Posit`(changingTimepoint) p
JOIN
    public.`rST_NAM_Stage_Name_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fST_NAM_Stage_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Reliability`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    public.`fST_NAM_Stage_Name_Posit`(changingTimepoint) p
JOIN
    public.`rST_NAM_Stage_Name_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`preST_NAM_Stage_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_NAM_Stage_Name`
FROM
    public.`rST_NAM_Stage_Name`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_NAM_ST_ID` = id
AND
    pre.`ST_NAM_ChangedAt` < changingTimepoint
AND
    pre.`ST_NAM_Reliability` = 1
ORDER BY
    pre.`ST_NAM_ChangedAt` DESC,
    pre.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folST_NAM_Stage_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_NAM_Stage_Name`
FROM
    public.`fST_NAM_Stage_Name`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_NAM_ST_ID` = id
AND
    fol.`ST_NAM_ChangedAt` > changingTimepoint
AND
    fol.`ST_NAM_Reliability` = 1
ORDER BY
    fol.`ST_NAM_ChangedAt` ASC,
    fol.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_LOC_Stage_Location_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_LOC`,
    `ST_LOC_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Reliability`
FROM
    public.`ST_LOC_Stage_Location_Annex`
WHERE
    `ST_LOC_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_LOC_Stage_Location` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Reliability`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Stage_Location`
FROM
    public.`ST_LOC_Stage_Location_Posit` p
JOIN
    public.`rST_LOC_Stage_Location_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    public.`ST_AVG_Stage_Average_Posit`
WHERE
    `ST_AVG_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_AVG_Stage_Average_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    public.`ST_AVG_Stage_Average_Posit`
WHERE
    `ST_AVG_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_AVG`,
    `ST_AVG_ID`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Reliability`
FROM
    public.`ST_AVG_Stage_Average_Annex`
WHERE
    `ST_AVG_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Reliability`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    public.`rST_AVG_Stage_Average_Posit`(changingTimepoint) p
JOIN
    public.`rST_AVG_Stage_Average_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fST_AVG_Stage_Average` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Reliability`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    public.`fST_AVG_Stage_Average_Posit`(changingTimepoint) p
JOIN
    public.`rST_AVG_Stage_Average_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`preST_AVG_Stage_Average` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_AVG_UTL_ID`
FROM
    public.`rST_AVG_Stage_Average`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_AVG_ST_ID` = id
AND
    pre.`ST_AVG_ChangedAt` < changingTimepoint
AND
    pre.`ST_AVG_Reliability` = 1
ORDER BY
    pre.`ST_AVG_ChangedAt` DESC,
    pre.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folST_AVG_Stage_Average` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_AVG_UTL_ID`
FROM
    public.`fST_AVG_Stage_Average`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_AVG_ST_ID` = id
AND
    fol.`ST_AVG_ChangedAt` > changingTimepoint
AND
    fol.`ST_AVG_Reliability` = 1
ORDER BY
    fol.`ST_AVG_ChangedAt` ASC,
    fol.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_MIN_Stage_Minimum_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_MIN`,
    `ST_MIN_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Reliability`
FROM
    public.`ST_MIN_Stage_Minimum_Annex`
WHERE
    `ST_MIN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_MIN_Stage_Minimum` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_MIN`,
    p.`ST_MIN_ID`,
    a.`ST_MIN_PositedAt`,
    a.`ST_MIN_Reliability`,
    p.`ST_MIN_ST_ID`,
    p.`ST_MIN_UTL_ID`
FROM
    public.`ST_MIN_Stage_Minimum_Posit` p
JOIN
    public.`rST_MIN_Stage_Minimum_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    public.`AC_NAM_Actor_Name_Posit`
WHERE
    `AC_NAM_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_NAM_Actor_Name_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Actor_Name`,
    `AC_NAM_ChangedAt`
FROM
    public.`AC_NAM_Actor_Name_Posit`
WHERE
    `AC_NAM_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_NAM`,
    `AC_NAM_ID`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Reliability`
FROM
    public.`AC_NAM_Actor_Name_Annex`
WHERE
    `AC_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Reliability`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    public.`rAC_NAM_Actor_Name_Posit`(changingTimepoint) p
JOIN
    public.`rAC_NAM_Actor_Name_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fAC_NAM_Actor_Name` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Reliability`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    public.`fAC_NAM_Actor_Name_Posit`(changingTimepoint) p
JOIN
    public.`rAC_NAM_Actor_Name_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`preAC_NAM_Actor_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_NAM_Actor_Name`
FROM
    public.`rAC_NAM_Actor_Name`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_NAM_AC_ID` = id
AND
    pre.`AC_NAM_ChangedAt` < changingTimepoint
AND
    pre.`AC_NAM_Reliability` = 1
ORDER BY
    pre.`AC_NAM_ChangedAt` DESC,
    pre.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folAC_NAM_Actor_Name` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_NAM_Actor_Name`
FROM
    public.`fAC_NAM_Actor_Name`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_NAM_AC_ID` = id
AND
    fol.`AC_NAM_ChangedAt` > changingTimepoint
AND
    fol.`AC_NAM_Reliability` = 1
ORDER BY
    fol.`AC_NAM_ChangedAt` ASC,
    fol.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_GEN_Actor_Gender_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_GEN`,
    `AC_GEN_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Reliability`
FROM
    public.`AC_GEN_Actor_Gender_Annex`
WHERE
    `AC_GEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_GEN_Actor_Gender` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_GEN`,
    p.`AC_GEN_ID`,
    a.`AC_GEN_PositedAt`,
    a.`AC_GEN_Reliability`,
    p.`AC_GEN_AC_ID`,
    p.`AC_GEN_GEN_ID`
FROM
    public.`AC_GEN_Actor_Gender_Posit` p
JOIN
    public.`rAC_GEN_Actor_Gender_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
WHERE
    `AC_PLV_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_PLV_Actor_ProfessionalLevel_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
WHERE
    `AC_PLV_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_PLV`,
    `AC_PLV_ID`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Reliability`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Annex`
WHERE
    `AC_PLV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Reliability`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    public.`rAC_PLV_Actor_ProfessionalLevel_Posit`(changingTimepoint) p
JOIN
    public.`rAC_PLV_Actor_ProfessionalLevel_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Reliability`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    public.`fAC_PLV_Actor_ProfessionalLevel_Posit`(changingTimepoint) p
JOIN
    public.`rAC_PLV_Actor_ProfessionalLevel_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`preAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_PLV_PLV_ID`
FROM
    public.`rAC_PLV_Actor_ProfessionalLevel`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_PLV_AC_ID` = id
AND
    pre.`AC_PLV_ChangedAt` < changingTimepoint
AND
    pre.`AC_PLV_Reliability` = 1
ORDER BY
    pre.`AC_PLV_ChangedAt` DESC,
    pre.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_PLV_PLV_ID`
FROM
    public.`fAC_PLV_Actor_ProfessionalLevel`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_PLV_AC_ID` = id
AND
    fol.`AC_PLV_ChangedAt` > changingTimepoint
AND
    fol.`AC_PLV_Reliability` = 1
ORDER BY
    fol.`AC_PLV_ChangedAt` ASC,
    fol.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_NAM_Program_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_NAM`,
    `PR_NAM_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Reliability`
FROM
    public.`PR_NAM_Program_Name_Annex`
WHERE
    `PR_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_NAM_Program_Name` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Reliability`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Program_Name`
FROM
    public.`PR_NAM_Program_Name_Posit` p
JOIN
    public.`rPR_NAM_Program_Name_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    public.`PR_LEN_Program_Length_Posit`
WHERE
    `PR_LEN_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fPR_LEN_Program_Length_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Program_Length`,
    `PR_LEN_ChangedAt`
FROM
    public.`PR_LEN_Program_Length_Posit`
WHERE
    `PR_LEN_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_LEN`,
    `PR_LEN_ID`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Reliability`
FROM
    public.`PR_LEN_Program_Length_Annex`
WHERE
    `PR_LEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Reliability`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    public.`rPR_LEN_Program_Length_Posit`(changingTimepoint) p
JOIN
    public.`rPR_LEN_Program_Length_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fPR_LEN_Program_Length` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Reliability`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    public.`fPR_LEN_Program_Length_Posit`(changingTimepoint) p
JOIN
    public.`rPR_LEN_Program_Length_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`prePR_LEN_Program_Length` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`PR_LEN_Program_Length`
FROM
    public.`rPR_LEN_Program_Length`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`PR_LEN_PR_ID` = id
AND
    pre.`PR_LEN_ChangedAt` < changingTimepoint
AND
    pre.`PR_LEN_Reliability` = 1
ORDER BY
    pre.`PR_LEN_ChangedAt` DESC,
    pre.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`folPR_LEN_Program_Length` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`PR_LEN_Program_Length`
FROM
    public.`fPR_LEN_Program_Length`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`PR_LEN_PR_ID` = id
AND
    fol.`PR_LEN_ChangedAt` > changingTimepoint
AND
    fol.`PR_LEN_Reliability` = 1
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
CREATE OR REPLACE TABLE FUNCTION public.`tST_Stage` (
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
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    public.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rST_NAM_Stage_Name`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_NAM_Reliability` = 1
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
        public.`rST_LOC_Stage_Location`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Reliability` = 1
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
        public.`rST_AVG_Stage_Average`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_AVG_Reliability` = 1
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
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rST_MIN_Stage_Minimum`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Reliability` = 1
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
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE VIEW public.`lST_Stage` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    public.`tST_Stage`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION public.`pST_Stage` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `ST`.`ST_NAM_ST_ID`,
    `ST`.`Metadata_ST_NAM`,
    `ST`.`ST_NAM_ID`,
    `ST`.`ST_NAM_ChangedAt`,
    `ST`.`ST_NAM_PositedAt`,
    `ST`.`ST_NAM_Reliability`,
    `ST`.`ST_NAM_Stage_Name`,
    `ST`.`ST_LOC_ST_ID`,
    `ST`.`Metadata_ST_LOC`,
    `ST`.`ST_LOC_ID`,
    `ST`.`ST_LOC_PositedAt`,
    `ST`.`ST_LOC_Reliability`,
    `ST`.`ST_LOC_Checksum`,
    `ST`.`ST_LOC_Stage_Location`,
    `ST`.`ST_AVG_ST_ID`,
    `ST`.`Metadata_ST_AVG`,
    `ST`.`ST_AVG_ID`,
    `ST`.`ST_AVG_ChangedAt`,
    `ST`.`ST_AVG_PositedAt`,
    `ST`.`ST_AVG_Reliability`,
    `ST`.`ST_AVG_UTL_Utilization`,
    `ST`.`ST_AVG_Metadata_UTL`,
    `ST`.`ST_AVG_UTL_ID`,
    `ST`.`ST_MIN_ST_ID`,
    `ST`.`Metadata_ST_MIN`,
    `ST`.`ST_MIN_ID`,
    `ST`.`ST_MIN_PositedAt`,
    `ST`.`ST_MIN_Reliability`,
    `ST`.`ST_MIN_UTL_Utilization`,
    `ST`.`ST_MIN_Metadata_UTL`,
    `ST`.`ST_MIN_UTL_ID`
FROM
    public.`tST_Stage`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
)
;
CREATE OR REPLACE VIEW public.`nST_Stage` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    public.`tST_Stage`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION public.`dST_Stage` (
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
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM (
    SELECT DISTINCT
        `ST_NAM_ST_ID` AS `ST_ID`,
        CAST(`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public.`ST_NAM_Stage_Name`
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
        public.`ST_AVG_Stage_Average`
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        `ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`ST_Stage` `ST`
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
            public.`rST_NAM_Stage_Name`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_NAM_Reliability` = 1
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
        public.`rST_LOC_Stage_Location`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Reliability` = 1
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
            public.`rST_AVG_Stage_Average`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_AVG_Reliability` = 1
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
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        public.`rST_MIN_Stage_Minimum`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_MIN_ST_ID`
            ORDER BY r.`ST_MIN_PositedAt` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION public.`tAC_Actor` (
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
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    public.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rAC_NAM_Actor_Name`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_NAM_Reliability` = 1
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
        public.`rAC_GEN_Actor_Gender`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Reliability` = 1
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
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rAC_PLV_Actor_ProfessionalLevel`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`AC_PLV_Reliability` = 1
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
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
CREATE OR REPLACE VIEW public.`lAC_Actor` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    public.`tAC_Actor`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION public.`pAC_Actor` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `AC`.`AC_NAM_AC_ID`,
    `AC`.`Metadata_AC_NAM`,
    `AC`.`AC_NAM_ID`,
    `AC`.`AC_NAM_ChangedAt`,
    `AC`.`AC_NAM_PositedAt`,
    `AC`.`AC_NAM_Reliability`,
    `AC`.`AC_NAM_Actor_Name`,
    `AC`.`AC_GEN_AC_ID`,
    `AC`.`Metadata_AC_GEN`,
    `AC`.`AC_GEN_ID`,
    `AC`.`AC_GEN_PositedAt`,
    `AC`.`AC_GEN_Reliability`,
    `AC`.`AC_GEN_GEN_Gender`,
    `AC`.`AC_GEN_Metadata_GEN`,
    `AC`.`AC_GEN_GEN_ID`,
    `AC`.`AC_PLV_AC_ID`,
    `AC`.`Metadata_AC_PLV`,
    `AC`.`AC_PLV_ID`,
    `AC`.`AC_PLV_ChangedAt`,
    `AC`.`AC_PLV_PositedAt`,
    `AC`.`AC_PLV_Reliability`,
    `AC`.`AC_PLV_PLV_Checksum`,
    `AC`.`AC_PLV_PLV_ProfessionalLevel`,
    `AC`.`AC_PLV_Metadata_PLV`,
    `AC`.`AC_PLV_PLV_ID`
FROM
    public.`tAC_Actor`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
)
;
CREATE OR REPLACE VIEW public.`nAC_Actor` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    public.`tAC_Actor`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION public.`dAC_Actor` (
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
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
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
        public.`AC_NAM_Actor_Name`
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
        public.`AC_PLV_Actor_ProfessionalLevel`
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        `AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`AC_Actor` `AC`
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
            public.`rAC_NAM_Actor_Name`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_NAM_Reliability` = 1
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
        public.`rAC_GEN_Actor_Gender`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_GEN_AC_ID`
            ORDER BY r.`AC_GEN_PositedAt` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
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
            public.`rAC_PLV_Actor_ProfessionalLevel`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_PLV_Reliability` = 1
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
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION public.`tPR_Program` (
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
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`PR_Program` `PR`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rPR_NAM_Program_Name`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Reliability` = 1
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
        public.`rPR_LEN_Program_Length`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`PR_LEN_Reliability` = 1
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
CREATE OR REPLACE VIEW public.`lPR_Program` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    public.`tPR_Program`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION public.`pPR_Program` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `PR`.`PR_NAM_PR_ID`,
    `PR`.`Metadata_PR_NAM`,
    `PR`.`PR_NAM_ID`,
    `PR`.`PR_NAM_PositedAt`,
    `PR`.`PR_NAM_Reliability`,
    `PR`.`PR_NAM_Program_Name`,
    `PR`.`PR_LEN_PR_ID`,
    `PR`.`Metadata_PR_LEN`,
    `PR`.`PR_LEN_ID`,
    `PR`.`PR_LEN_ChangedAt`,
    `PR`.`PR_LEN_PositedAt`,
    `PR`.`PR_LEN_Reliability`,
    `PR`.`PR_LEN_Program_Length`
FROM
    public.`tPR_Program`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
)
;
CREATE OR REPLACE VIEW public.`nPR_Program` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    public.`tPR_Program`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION public.`dPR_Program` (
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
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Program_Length`
FROM (
    SELECT DISTINCT
        `PR_LEN_PR_ID` AS `PR_ID`,
        CAST(`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public.`PR_LEN_Program_Length`
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        `PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`PR_Program` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        public.`rPR_NAM_Program_Name`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Reliability` = 1
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
            public.`rPR_LEN_Program_Length`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_LEN_Reliability` = 1
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
CREATE OR REPLACE TABLE FUNCTION public.`tEV_Event` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `kETY_of`.`ETY_EventType` AS `of_ETY_EventType`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
LEFT JOIN
    public.`ETY_EventType` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        public.`rEV_DAT_Event_Date`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Reliability` = 1
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
        public.`rEV_AUD_Event_Audience`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Reliability` = 1
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
        public.`rEV_REV_Event_Revenue`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_REV_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_EV_ID`
            ORDER BY
                r.`EV_REV_PositedAt` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
)
;
CREATE OR REPLACE VIEW public.`lEV_Event` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    public.`tEV_Event`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION public.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `EV`.`of_ETY_EventType`,
    `EV`.`of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `EV`.`EV_DAT_EV_ID`,
    `EV`.`Metadata_EV_DAT`,
    `EV`.`EV_DAT_ID`,
    `EV`.`EV_DAT_PositedAt`,
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Event_Date`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Event_Audience`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Event_Revenue`
FROM
    public.`tEV_Event`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
)
;
CREATE OR REPLACE VIEW public.`nEV_Event` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    public.`tEV_Event`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
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
CREATE TABLE IF NOT EXISTS public.`AC_partner_AC_with_ONG_currently_Posit` (
    `AC_partner_AC_with_ONG_currently_ID` int64 not null,
    `AC_ID_partner` int64 not null, 
    `AC_ID_with` int64 not null, 
    `ONG_ID_currently` int64 not null,
    `AC_partner_AC_with_ONG_currently_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkAC_partner` FOREIGN KEY (`AC_ID_partner`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        public.`ONG_Ongoing`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Annex table (of AC_partner_AC_with_ONG_currently_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_partner_AC_with_ONG_currently_Annex` (
    `AC_partner_AC_with_ONG_currently_ID` int64 not null,
    `AC_partner_AC_with_ONG_currently_PositedAt` datetime not null,
    `AC_partner_AC_with_ONG_currently_Reliability` numeric(5,2) not null,
    `Metadata_AC_partner_AC_with_ONG_currently` int64 not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`,
        `AC_partner_AC_with_ONG_currently_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_partner_AC_with_ONG_currently_Annex` FOREIGN KEY (`AC_partner_AC_with_ONG_currently_ID`) REFERENCES
        public.`AC_partner_AC_with_ONG_currently_Posit`(`AC_partner_AC_with_ONG_currently_ID`) NOT ENFORCED
)
CLUSTER BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_subset_PN_of_Posit` (
    `AC_subset_PN_of_ID` int64 not null,
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    PRIMARY KEY (
        `AC_subset_PN_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Posit_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Posit_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        public.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Annex table (of AC_subset_PN_of_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_subset_PN_of_Annex` (
    `AC_subset_PN_of_ID` int64 not null,
    `AC_subset_PN_of_PositedAt` datetime not null,
    `AC_subset_PN_of_Reliability` numeric(5,2) not null,
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_subset_PN_of_ID`,
        `AC_subset_PN_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_subset_PN_of_Annex` FOREIGN KEY (`AC_subset_PN_of_ID`) REFERENCES
        public.`AC_subset_PN_of_Posit`(`AC_subset_PN_of_ID`) NOT ENFORCED
)
CLUSTER BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_in_AC_wasCast_Posit` (
    `EV_in_AC_wasCast_ID` int64 not null,
    `EV_ID_in` int64 not null, 
    `AC_ID_wasCast` int64 not null, 
    PRIMARY KEY (
        `EV_in_AC_wasCast_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_Posit_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_Posit_fkAC_wasCast` FOREIGN KEY (`AC_ID_wasCast`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast_Annex table (of EV_in_AC_wasCast_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_in_AC_wasCast_Annex` (
    `EV_in_AC_wasCast_ID` int64 not null,
    `EV_in_AC_wasCast_PositedAt` datetime not null,
    `EV_in_AC_wasCast_Reliability` numeric(5,2) not null,
    `Metadata_EV_in_AC_wasCast` int64 not null,
    PRIMARY KEY (
        `EV_in_AC_wasCast_ID`,
        `EV_in_AC_wasCast_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_in_AC_wasCast_Annex` FOREIGN KEY (`EV_in_AC_wasCast_ID`) REFERENCES
        public.`EV_in_AC_wasCast_Posit`(`EV_in_AC_wasCast_ID`) NOT ENFORCED
)
CLUSTER BY `EV_in_AC_wasCast_ID`, `EV_in_AC_wasCast_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_part_PR_in_RAT_got_Posit` (
    `AC_part_PR_in_RAT_got_ID` int64 not null,
    `AC_ID_part` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_got` int64 not null,
    `AC_part_PR_in_RAT_got_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_part_PR_in_RAT_got_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Posit_fkAC_part` FOREIGN KEY (`AC_ID_part`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Posit_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_Posit_fkRAT_got` FOREIGN KEY (`RAT_ID_got`) REFERENCES
        public.`RAT_Rating`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_part`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got_Annex table (of AC_part_PR_in_RAT_got_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_part_PR_in_RAT_got_Annex` (
    `AC_part_PR_in_RAT_got_ID` int64 not null,
    `AC_part_PR_in_RAT_got_PositedAt` datetime not null,
    `AC_part_PR_in_RAT_got_Reliability` numeric(5,2) not null,
    `Metadata_AC_part_PR_in_RAT_got` int64 not null,
    PRIMARY KEY (
        `AC_part_PR_in_RAT_got_ID`,
        `AC_part_PR_in_RAT_got_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_part_PR_in_RAT_got_Annex` FOREIGN KEY (`AC_part_PR_in_RAT_got_ID`) REFERENCES
        public.`AC_part_PR_in_RAT_got_Posit`(`AC_part_PR_in_RAT_got_ID`) NOT ENFORCED
)
CLUSTER BY `AC_part_PR_in_RAT_got_ID`, `AC_part_PR_in_RAT_got_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_at_PR_isPlaying_Posit` (
    `ST_at_PR_isPlaying_ID` int64 not null,
    `ST_ID_at` int64 not null, 
    `PR_ID_isPlaying` int64 not null, 
    `ST_at_PR_isPlaying_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_at_PR_isPlaying_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_Posit_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_Posit_fkPR_isPlaying` FOREIGN KEY (`PR_ID_isPlaying`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying_Annex table (of ST_at_PR_isPlaying_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_at_PR_isPlaying_Annex` (
    `ST_at_PR_isPlaying_ID` int64 not null,
    `ST_at_PR_isPlaying_PositedAt` datetime not null,
    `ST_at_PR_isPlaying_Reliability` numeric(5,2) not null,
    `Metadata_ST_at_PR_isPlaying` int64 not null,
    PRIMARY KEY (
        `ST_at_PR_isPlaying_ID`,
        `ST_at_PR_isPlaying_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_at_PR_isPlaying_Annex` FOREIGN KEY (`ST_at_PR_isPlaying_ID`) REFERENCES
        public.`ST_at_PR_isPlaying_Posit`(`ST_at_PR_isPlaying_ID`) NOT ENFORCED
)
CLUSTER BY `ST_at_PR_isPlaying_ID`, `ST_at_PR_isPlaying_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_parent_AC_child_PAT_having_Posit` (
    `AC_parent_AC_child_PAT_having_ID` int64 not null,
    `AC_ID_parent` int64 not null, 
    `AC_ID_child` int64 not null, 
    `PAT_ID_having` int64 not null,
    PRIMARY KEY (
        `AC_parent_AC_child_PAT_having_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Posit_fkAC_parent` FOREIGN KEY (`AC_ID_parent`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Posit_fkAC_child` FOREIGN KEY (`AC_ID_child`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_Posit_fkPAT_having` FOREIGN KEY (`PAT_ID_having`) REFERENCES
        public.`PAT_ParentalType`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_parent`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having_Annex table (of AC_parent_AC_child_PAT_having_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_parent_AC_child_PAT_having_Annex` (
    `AC_parent_AC_child_PAT_having_ID` int64 not null,
    `AC_parent_AC_child_PAT_having_PositedAt` datetime not null,
    `AC_parent_AC_child_PAT_having_Reliability` numeric(5,2) not null,
    `Metadata_AC_parent_AC_child_PAT_having` int64 not null,
    PRIMARY KEY (
        `AC_parent_AC_child_PAT_having_ID`,
        `AC_parent_AC_child_PAT_having_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_parent_AC_child_PAT_having_Annex` FOREIGN KEY (`AC_parent_AC_child_PAT_having_ID`) REFERENCES
        public.`AC_parent_AC_child_PAT_having_Posit`(`AC_parent_AC_child_PAT_having_ID`) NOT ENFORCED
)
CLUSTER BY `AC_parent_AC_child_PAT_having_ID`, `AC_parent_AC_child_PAT_having_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_content_ST_location_EV_of_Posit` (
    `PR_content_ST_location_EV_of_ID` int64 not null,
    `PR_ID_content` int64 not null, 
    `ST_ID_location` int64 not null, 
    `EV_ID_of` int64 not null, 
    PRIMARY KEY (
        `PR_content_ST_location_EV_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Posit_fkPR_content` FOREIGN KEY (`PR_ID_content`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Posit_fkST_location` FOREIGN KEY (`ST_ID_location`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_Posit_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_content`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of_Annex table (of PR_content_ST_location_EV_of_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_content_ST_location_EV_of_Annex` (
    `PR_content_ST_location_EV_of_ID` int64 not null,
    `PR_content_ST_location_EV_of_PositedAt` datetime not null,
    `PR_content_ST_location_EV_of_Reliability` numeric(5,2) not null,
    `Metadata_PR_content_ST_location_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_content_ST_location_EV_of_ID`,
        `PR_content_ST_location_EV_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_content_ST_location_EV_of_Annex` FOREIGN KEY (`PR_content_ST_location_EV_of_ID`) REFERENCES
        public.`PR_content_ST_location_EV_of_Posit`(`PR_content_ST_location_EV_of_ID`) NOT ENFORCED
)
CLUSTER BY `PR_content_ST_location_EV_of_ID`, `PR_content_ST_location_EV_of_PositedAt`;
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling.
--
CREATE OR REPLACE VIEW public.`AC_partner_AC_with_ONG_currently` AS
SELECT
    a.`Metadata_AC_partner_AC_with_ONG_currently`,
    p.`AC_partner_AC_with_ONG_currently_ID`,
    p.`AC_ID_partner`,
    p.`AC_ID_with`,
    p.`ONG_ID_currently`,
    p.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    a.`AC_partner_AC_with_ONG_currently_PositedAt`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit` p
JOIN
    public.`AC_partner_AC_with_ONG_currently_Annex` a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
;
CREATE OR REPLACE VIEW public.`AC_subset_PN_of` AS
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Reliability`
FROM
    public.`AC_subset_PN_of_Posit` p
JOIN
    public.`AC_subset_PN_of_Annex` a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
;
CREATE OR REPLACE VIEW public.`EV_in_AC_wasCast` AS
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Reliability`
FROM
    public.`EV_in_AC_wasCast_Posit` p
JOIN
    public.`EV_in_AC_wasCast_Annex` a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
;
CREATE OR REPLACE VIEW public.`AC_part_PR_in_RAT_got` AS
SELECT
    a.`Metadata_AC_part_PR_in_RAT_got`,
    p.`AC_part_PR_in_RAT_got_ID`,
    p.`AC_ID_part`,
    p.`PR_ID_in`,
    p.`RAT_ID_got`,
    p.`AC_part_PR_in_RAT_got_ChangedAt`,
    a.`AC_part_PR_in_RAT_got_PositedAt`,
    a.`AC_part_PR_in_RAT_got_Reliability`
FROM
    public.`AC_part_PR_in_RAT_got_Posit` p
JOIN
    public.`AC_part_PR_in_RAT_got_Annex` a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
;
CREATE OR REPLACE VIEW public.`ST_at_PR_isPlaying` AS
SELECT
    a.`Metadata_ST_at_PR_isPlaying`,
    p.`ST_at_PR_isPlaying_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_isPlaying`,
    p.`ST_at_PR_isPlaying_ChangedAt`,
    a.`ST_at_PR_isPlaying_PositedAt`,
    a.`ST_at_PR_isPlaying_Reliability`
FROM
    public.`ST_at_PR_isPlaying_Posit` p
JOIN
    public.`ST_at_PR_isPlaying_Annex` a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
;
CREATE OR REPLACE VIEW public.`AC_parent_AC_child_PAT_having` AS
SELECT
    a.`Metadata_AC_parent_AC_child_PAT_having`,
    p.`AC_parent_AC_child_PAT_having_ID`,
    p.`AC_ID_parent`,
    p.`AC_ID_child`,
    p.`PAT_ID_having`,
    a.`AC_parent_AC_child_PAT_having_PositedAt`,
    a.`AC_parent_AC_child_PAT_having_Reliability`
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` p
JOIN
    public.`AC_parent_AC_child_PAT_having_Annex` a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
;
CREATE OR REPLACE VIEW public.`PR_content_ST_location_EV_of` AS
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Reliability`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`PR_content_ST_location_EV_of_Annex` a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION public.`rAC_partner_AC_with_ONG_currently_Posit` (
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
    public.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_partner_AC_with_ONG_currently_Posit` (
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
    public.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_partner_AC_with_ONG_currently_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    `AC_partner_AC_with_ONG_currently_Reliability`
FROM
    public.`AC_partner_AC_with_ONG_currently_Annex`
WHERE
    `AC_partner_AC_with_ONG_currently_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_partner_AC_with_ONG_currently` (
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
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    public.`rAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fAC_partner_AC_with_ONG_currently` (
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
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    public.`fAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rAC_subset_PN_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_subset_PN_of`,
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_PositedAt`,
    `AC_subset_PN_of_Reliability`
FROM
    public.`AC_subset_PN_of_Annex`
WHERE
    `AC_subset_PN_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_subset_PN_of` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Reliability`
FROM
    public.`AC_subset_PN_of_Posit` p
JOIN
    public.`rAC_subset_PN_of_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fAC_subset_PN_of` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Reliability`
FROM
    public.`AC_subset_PN_of_Posit` p
JOIN
    public.`rAC_subset_PN_of_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rEV_in_AC_wasCast_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_in_AC_wasCast`,
    `EV_in_AC_wasCast_ID`,
    `EV_in_AC_wasCast_PositedAt`,
    `EV_in_AC_wasCast_Reliability`
FROM
    public.`EV_in_AC_wasCast_Annex`
WHERE
    `EV_in_AC_wasCast_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_in_AC_wasCast` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Reliability`
FROM
    public.`EV_in_AC_wasCast_Posit` p
JOIN
    public.`rEV_in_AC_wasCast_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fEV_in_AC_wasCast` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Reliability`
FROM
    public.`EV_in_AC_wasCast_Posit` p
JOIN
    public.`rEV_in_AC_wasCast_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rAC_part_PR_in_RAT_got_Posit` (
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
    public.`AC_part_PR_in_RAT_got_Posit`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_part_PR_in_RAT_got_Posit` (
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
    public.`AC_part_PR_in_RAT_got_Posit`
WHERE
    `AC_part_PR_in_RAT_got_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_part_PR_in_RAT_got_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_part_PR_in_RAT_got`,
    `AC_part_PR_in_RAT_got_ID`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    `AC_part_PR_in_RAT_got_Reliability`
FROM
    public.`AC_part_PR_in_RAT_got_Annex`
WHERE
    `AC_part_PR_in_RAT_got_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_part_PR_in_RAT_got` (
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
    a.`AC_part_PR_in_RAT_got_Reliability`
FROM
    public.`rAC_part_PR_in_RAT_got_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_part_PR_in_RAT_got_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fAC_part_PR_in_RAT_got` (
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
    a.`AC_part_PR_in_RAT_got_Reliability`
FROM
    public.`fAC_part_PR_in_RAT_got_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_part_PR_in_RAT_got_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rST_at_PR_isPlaying_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    public.`ST_at_PR_isPlaying_Posit`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_at_PR_isPlaying_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_isPlaying_ID`,
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
FROM
    public.`ST_at_PR_isPlaying_Posit`
WHERE
    `ST_at_PR_isPlaying_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_at_PR_isPlaying_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_at_PR_isPlaying`,
    `ST_at_PR_isPlaying_ID`,
    `ST_at_PR_isPlaying_PositedAt`,
    `ST_at_PR_isPlaying_Reliability`
FROM
    public.`ST_at_PR_isPlaying_Annex`
WHERE
    `ST_at_PR_isPlaying_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_at_PR_isPlaying` (
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
    a.`ST_at_PR_isPlaying_Reliability`
FROM
    public.`rST_at_PR_isPlaying_Posit`(changingTimepoint) p 
JOIN
    public.`rST_at_PR_isPlaying_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fST_at_PR_isPlaying` (
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
    a.`ST_at_PR_isPlaying_Reliability`
FROM
    public.`fST_at_PR_isPlaying_Posit`(changingTimepoint) p 
JOIN
    public.`rST_at_PR_isPlaying_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rAC_parent_AC_child_PAT_having_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_parent_AC_child_PAT_having`,
    `AC_parent_AC_child_PAT_having_ID`,
    `AC_parent_AC_child_PAT_having_PositedAt`,
    `AC_parent_AC_child_PAT_having_Reliability`
FROM
    public.`AC_parent_AC_child_PAT_having_Annex`
WHERE
    `AC_parent_AC_child_PAT_having_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_parent_AC_child_PAT_having` (
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
    a.`AC_parent_AC_child_PAT_having_Reliability`
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` p
JOIN
    public.`rAC_parent_AC_child_PAT_having_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fAC_parent_AC_child_PAT_having` (
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
    a.`AC_parent_AC_child_PAT_having_Reliability`
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` p
JOIN
    public.`rAC_parent_AC_child_PAT_having_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`rPR_content_ST_location_EV_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_content_ST_location_EV_of`,
    `PR_content_ST_location_EV_of_ID`,
    `PR_content_ST_location_EV_of_PositedAt`,
    `PR_content_ST_location_EV_of_Reliability`
FROM
    public.`PR_content_ST_location_EV_of_Annex`
WHERE
    `PR_content_ST_location_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_content_ST_location_EV_of` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Reliability`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`rPR_content_ST_location_EV_of_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`fPR_content_ST_location_EV_of` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_content_ST_location_EV_of`,
    p.`PR_content_ST_location_EV_of_ID`,
    p.`PR_ID_content`,
    p.`ST_ID_location`,
    p.`EV_ID_of`,
    a.`PR_content_ST_location_EV_of_PositedAt`,
    a.`PR_content_ST_location_EV_of_Reliability`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`rPR_content_ST_location_EV_of_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION public.`tAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    public.`rAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    public.`ONG_Ongoing` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Reliability` = 1
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
CREATE OR REPLACE VIEW public.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    public.`tAC_partner_AC_with_ONG_currently`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    public.`tAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW public.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    public.`tAC_partner_AC_with_ONG_currently`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_partner_AC_with_ONG_currently_ID`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    public.`tAC_partner_AC_with_ONG_currently`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION public.`tAC_subset_PN_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_subset_PN_of_ID`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    public.`rAC_subset_PN_of`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`AC_subset_PN_of_Reliability` = 1
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
CREATE OR REPLACE VIEW public.`lAC_subset_PN_of` AS
SELECT
    *
FROM
    public.`tAC_subset_PN_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_subset_PN_of_ID`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    public.`tAC_subset_PN_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW public.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    public.`tAC_subset_PN_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`tEV_in_AC_wasCast` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_wasCast_ID`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Reliability`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`
FROM
    public.`rEV_in_AC_wasCast`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`EV_in_AC_wasCast_Reliability` = 1
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
CREATE OR REPLACE VIEW public.`lEV_in_AC_wasCast` AS
SELECT
    *
FROM
    public.`tEV_in_AC_wasCast`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_wasCast_ID`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Reliability`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`
FROM
    public.`tEV_in_AC_wasCast`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW public.`nEV_in_AC_wasCast` AS
SELECT
    *
FROM
    public.`tEV_in_AC_wasCast`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`tAC_part_PR_in_RAT_got` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `kRAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    public.`rAC_part_PR_in_RAT_got`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    public.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
WHERE
    t.`AC_part_PR_in_RAT_got_Reliability` = 1
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
CREATE OR REPLACE VIEW public.`lAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    public.`tAC_part_PR_in_RAT_got`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    public.`tAC_part_PR_in_RAT_got`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW public.`nAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    public.`tAC_part_PR_in_RAT_got`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_part_PR_in_RAT_got_ID`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`
FROM
    public.`tAC_part_PR_in_RAT_got`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION public.`tST_at_PR_isPlaying` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    public.`rST_at_PR_isPlaying`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`ST_at_PR_isPlaying_Reliability` = 1
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
CREATE OR REPLACE VIEW public.`lST_at_PR_isPlaying` AS
SELECT
    *
FROM
    public.`tST_at_PR_isPlaying`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    public.`tST_at_PR_isPlaying`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW public.`nST_at_PR_isPlaying` AS
SELECT
    *
FROM
    public.`tST_at_PR_isPlaying`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`dST_at_PR_isPlaying` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`ST_at_PR_isPlaying_ID`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`
FROM
    public.`tST_at_PR_isPlaying`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION public.`tAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_parent_AC_child_PAT_having_ID`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Reliability`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    `kPAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `kPAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    t.`PAT_ID_having`
FROM
    public.`rAC_parent_AC_child_PAT_having`(
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    public.`PAT_ParentalType` `kPAT_having`
ON
    `kPAT_having`.`PAT_ID` = t.`PAT_ID_having`
WHERE
    t.`AC_parent_AC_child_PAT_having_Reliability` = 1
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
CREATE OR REPLACE VIEW public.`lAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    public.`tAC_parent_AC_child_PAT_having`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_parent_AC_child_PAT_having_ID`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Reliability`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    t.`having_PAT_ParentalType`,
    t.`having_Metadata_PAT`,
    t.`PAT_ID_having`
FROM
    public.`tAC_parent_AC_child_PAT_having`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW public.`nAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    public.`tAC_parent_AC_child_PAT_having`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`tPR_content_ST_location_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Reliability`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    public.`rPR_content_ST_location_EV_of`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`PR_content_ST_location_EV_of_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`EV_ID_of`
        ORDER BY
            t.`PR_content_ST_location_EV_of_PositedAt` DESC,
            t.`PR_content_ST_location_EV_of_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW public.`lPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    public.`tPR_content_ST_location_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION public.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`PR_content_ST_location_EV_of_ID`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Reliability`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`
FROM
    public.`tPR_content_ST_location_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW public.`nPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    public.`tPR_content_ST_location_EV_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
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
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_PN_Person_1st` (
    `PN_ID`,
    `subset_AC_NAM_Actor_Name`
)
AS
SELECT
    `PN`.`PN_ID`,
    `s2`.`AC_NAM_Actor_Name`
FROM
    public.`PN_Person` `PN`
LEFT JOIN
    public.`lAC_subset_PN_of` `s1`
ON
    `s1`.`PN_ID_of` = `PN`.`PN_ID`
LEFT JOIN
    public.`lAC_Actor` `s2`
ON
    `s2`.`AC_ID` = `s1`.`AC_ID_subset`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of PN_Person at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pkey_PN_Person_1st` (
    changingTimepoint datetime
)
AS (
SELECT
    `PN`.`PN_ID`,
    `s2`.`AC_NAM_Actor_Name`
FROM
    public.`PN_Person` `PN`
LEFT JOIN
    public.`pAC_subset_PN_of`(changingTimepoint) `s1`
ON
    `s1`.`PN_ID_of` = `PN`.`PN_ID`
LEFT JOIN
    public.`pAC_Actor`(changingTimepoint) `s2`
ON
    `s2`.`AC_ID` = `s1`.`AC_ID_subset`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PN_Person
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_PN_Person_1st` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PN_Person_1st',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `subset_AC_NAM_Actor_Name` AS `subset_AC_NAM_Actor_Name`
    )),
    COUNT(DISTINCT `PN_ID`)
FROM
    public.`key_PN_Person_1st`
WHERE
    `subset_AC_NAM_Actor_Name` IS NOT NULL
GROUP BY
    `subset_AC_NAM_Actor_Name`
HAVING
    COUNT(DISTINCT `PN_ID`) > 1
UNION ALL
SELECT
    'key_PN_Person_1st',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `PN_ID` AS `PN_ID`
    )),
    COUNT(*)
FROM
    public.`key_PN_Person_1st`
GROUP BY
    `PN_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_ST_Stage_1st` (
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
    public.`lST_Stage` `ST`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_ST_Stage_1st` (
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
    public.`key_ST_Stage_1st`
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
    public.`key_ST_Stage_1st`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_ST_Stage_2nd` (
    `ST_ID`,
    `ST_NAM_Stage_Name`
)
AS
SELECT
    `ST`.`ST_ID`,
    `ST`.`ST_NAM_Stage_Name`
FROM
    public.`lST_Stage` `ST`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pkey_ST_Stage_2nd` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `ST`.`ST_NAM_Stage_Name`
FROM
    public.`pST_Stage`(changingTimepoint) `ST`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_ST_Stage_2nd` (
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
    public.`key_ST_Stage_2nd`
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
    public.`key_ST_Stage_2nd`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_ST_Stage_3rd` (
    `ST_ID`,
    `ST_MIN_UTL_Utilization`,
    `ST_NAM_Stage_Name`
)
AS
SELECT
    `ST`.`ST_ID`,
    `ST`.`ST_MIN_UTL_Utilization`,
    `ST`.`ST_NAM_Stage_Name`
FROM
    public.`lST_Stage` `ST`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pkey_ST_Stage_3rd` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `ST`.`ST_MIN_UTL_Utilization`,
    `ST`.`ST_NAM_Stage_Name`
FROM
    public.`pST_Stage`(changingTimepoint) `ST`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_ST_Stage_3rd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_3rd',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
        `ST_NAM_Stage_Name` AS `ST_NAM_Stage_Name`
    )),
    COUNT(DISTINCT `ST_ID`)
FROM
    public.`key_ST_Stage_3rd`
WHERE
    `ST_MIN_UTL_Utilization` IS NOT NULL
AND
    `ST_NAM_Stage_Name` IS NOT NULL
GROUP BY
    `ST_MIN_UTL_Utilization`,
    `ST_NAM_Stage_Name`
HAVING
    COUNT(DISTINCT `ST_ID`) > 1
UNION ALL
SELECT
    'key_ST_Stage_3rd',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`
    )),
    COUNT(*)
FROM
    public.`key_ST_Stage_3rd`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-- Note: ST_Stage can be wasHeldAt in more than one EV_Event, so an identity can have more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_ST_Stage_4th` (
    `ST_ID`,
    `wasHeldAt_EV_DAT_Event_Date`
)
AS
SELECT
    `ST`.`ST_ID`,
    `s1`.`EV_DAT_Event_Date`
FROM
    public.`lST_Stage` `ST`
LEFT JOIN
    public.`lEV_Event` `s1`
ON
    `s1`.`ST_ID_wasHeldAt` = `ST`.`ST_ID`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 4th key of ST_Stage
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_ST_Stage_4th` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_ST_Stage_4th',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `wasHeldAt_EV_DAT_Event_Date` AS `wasHeldAt_EV_DAT_Event_Date`
    )),
    COUNT(DISTINCT `ST_ID`)
FROM
    public.`key_ST_Stage_4th`
WHERE
    `wasHeldAt_EV_DAT_Event_Date` IS NOT NULL
GROUP BY
    `wasHeldAt_EV_DAT_Event_Date`
HAVING
    COUNT(DISTINCT `ST_ID`) > 1
UNION ALL
SELECT
    'key_ST_Stage_4th',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `ST_ID` AS `ST_ID`
    )),
    COUNT(*)
FROM
    public.`key_ST_Stage_4th`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- The 5th key of ST_Stage is not generated: more than one element is stop 1
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_AC_Actor_1st` (
    `AC_ID`,
    `AC_NAM_Actor_Name`
)
AS
SELECT
    `AC`.`AC_ID`,
    `AC`.`AC_NAM_Actor_Name`
FROM
    public.`lAC_Actor` `AC`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pkey_AC_Actor_1st` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `AC`.`AC_NAM_Actor_Name`
FROM
    public.`pAC_Actor`(changingTimepoint) `AC`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_AC_Actor_1st` (
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
    public.`key_AC_Actor_1st`
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
    public.`key_AC_Actor_1st`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_AC_Actor_2nd` (
    `AC_ID`,
    `with_AC_NAM_Actor_Name`
)
AS
SELECT
    `AC`.`AC_ID`,
    `s2`.`AC_NAM_Actor_Name`
FROM
    public.`lAC_Actor` `AC`
LEFT JOIN
    public.`lAC_partner_AC_with_ONG_currently` `s1`
ON
    `s1`.`AC_ID_partner` = `AC`.`AC_ID`
LEFT JOIN
    public.`lAC_Actor` `s2`
ON
    `s2`.`AC_ID` = `s1`.`AC_ID_with`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pkey_AC_Actor_2nd` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `s2`.`AC_NAM_Actor_Name`
FROM
    public.`pAC_Actor`(changingTimepoint) `AC`
LEFT JOIN
    public.`pAC_partner_AC_with_ONG_currently`(changingTimepoint) `s1`
ON
    `s1`.`AC_ID_partner` = `AC`.`AC_ID`
LEFT JOIN
    public.`pAC_Actor`(changingTimepoint) `s2`
ON
    `s2`.`AC_ID` = `s1`.`AC_ID_with`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_AC_Actor_2nd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_2nd',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `with_AC_NAM_Actor_Name` AS `with_AC_NAM_Actor_Name`
    )),
    COUNT(DISTINCT `AC_ID`)
FROM
    public.`key_AC_Actor_2nd`
WHERE
    `with_AC_NAM_Actor_Name` IS NOT NULL
GROUP BY
    `with_AC_NAM_Actor_Name`
HAVING
    COUNT(DISTINCT `AC_ID`) > 1
UNION ALL
SELECT
    'key_AC_Actor_2nd',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `AC_ID` AS `AC_ID`
    )),
    COUNT(*)
FROM
    public.`key_AC_Actor_2nd`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-- Note: AC_parent_AC_child_PAT_having has identifiers other than parent, so it can lead to more than one child and an identity to more than one key
-- Note: AC_part_PR_in_RAT_got has identifiers other than part, so it can lead to more than one in and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_AC_Actor_3rd` (
    `AC_ID`,
    `child_in_PR_NAM_Program_Name`
)
AS
SELECT
    `AC`.`AC_ID`,
    `s4`.`PR_NAM_Program_Name`
FROM
    public.`lAC_Actor` `AC`
LEFT JOIN
    public.`lAC_parent_AC_child_PAT_having` `s1`
ON
    `s1`.`AC_ID_parent` = `AC`.`AC_ID`
LEFT JOIN
    public.`lAC_part_PR_in_RAT_got` `s3`
ON
    `s3`.`AC_ID_part` = `s1`.`AC_ID_child`
LEFT JOIN
    public.`lPR_Program` `s4`
ON
    `s4`.`PR_ID` = `s3`.`PR_ID_in`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pkey_AC_Actor_3rd` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `s4`.`PR_NAM_Program_Name`
FROM
    public.`pAC_Actor`(changingTimepoint) `AC`
LEFT JOIN
    public.`pAC_parent_AC_child_PAT_having`(changingTimepoint) `s1`
ON
    `s1`.`AC_ID_parent` = `AC`.`AC_ID`
LEFT JOIN
    public.`pAC_part_PR_in_RAT_got`(changingTimepoint) `s3`
ON
    `s3`.`AC_ID_part` = `s1`.`AC_ID_child`
LEFT JOIN
    public.`pPR_Program`(changingTimepoint) `s4`
ON
    `s4`.`PR_ID` = `s3`.`PR_ID_in`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of AC_Actor
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_AC_Actor_3rd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_AC_Actor_3rd',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `child_in_PR_NAM_Program_Name` AS `child_in_PR_NAM_Program_Name`
    )),
    COUNT(DISTINCT `AC_ID`)
FROM
    public.`key_AC_Actor_3rd`
WHERE
    `child_in_PR_NAM_Program_Name` IS NOT NULL
GROUP BY
    `child_in_PR_NAM_Program_Name`
HAVING
    COUNT(DISTINCT `AC_ID`) > 1
UNION ALL
SELECT
    'key_AC_Actor_3rd',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `AC_ID` AS `AC_ID`
    )),
    COUNT(*)
FROM
    public.`key_AC_Actor_3rd`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- The 4th key of AC_Actor is not generated: stop 1: ST_NAM_Stage_Name is not an attribute of AC_Actor
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_PR_Program_1st` (
    `PR_ID`,
    `PR_NAM_Program_Name`
)
AS
SELECT
    `PR`.`PR_ID`,
    `PR`.`PR_NAM_Program_Name`
FROM
    public.`lPR_Program` `PR`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_PR_Program_1st` (
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
    public.`key_PR_Program_1st`
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
    public.`key_PR_Program_1st`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-- Note: AC_part_PR_in_RAT_got has identifiers other than in, so it can lead to more than one got and an identity to more than one key
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_PR_Program_2nd` (
    `PR_ID`,
    `got_RAT_Rating`
)
AS
SELECT
    `PR`.`PR_ID`,
    `s1`.`got_RAT_Rating`
FROM
    public.`lPR_Program` `PR`
LEFT JOIN
    public.`lAC_part_PR_in_RAT_got` `s1`
ON
    `s1`.`PR_ID_in` = `PR`.`PR_ID`
;
-- Point-in-time key --------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program at a changing time
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pkey_PR_Program_2nd` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `s1`.`got_RAT_Rating`
FROM
    public.`pPR_Program`(changingTimepoint) `PR`
LEFT JOIN
    public.`pAC_part_PR_in_RAT_got`(changingTimepoint) `s1`
ON
    `s1`.`PR_ID_in` = `PR`.`PR_ID`
)
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of PR_Program
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_PR_Program_2nd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_PR_Program_2nd',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `got_RAT_Rating` AS `got_RAT_Rating`
    )),
    COUNT(DISTINCT `PR_ID`)
FROM
    public.`key_PR_Program_2nd`
WHERE
    `got_RAT_Rating` IS NOT NULL
GROUP BY
    `got_RAT_Rating`
HAVING
    COUNT(DISTINCT `PR_ID`) > 1
UNION ALL
SELECT
    'key_PR_Program_2nd',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `PR_ID` AS `PR_ID`
    )),
    COUNT(*)
FROM
    public.`key_PR_Program_2nd`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1;
-- The 3rd key of PR_Program is not generated: branch 1 does not end in a value, an attribute or a knot
-- Key view -----------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_EV_Event_1st` (
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
    public.`lEV_Event` `EV`
LEFT JOIN
    public.`lST_Stage` `s2`
ON
    `s2`.`ST_ID` = `EV`.`ST_ID_wasHeldAt`
LEFT JOIN
    public.`lPR_Program` `s4`
ON
    `s4`.`PR_ID` = `EV`.`PR_ID_wasPlayed`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 1st key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_EV_Event_1st` (
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
    public.`key_EV_Event_1st`
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
    public.`key_EV_Event_1st`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_EV_Event_2nd` (
    `EV_ID`,
    `of_ETY_EventType`,
    `EV_DAT_Event_Date`
)
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`of_ETY_EventType`,
    `EV`.`EV_DAT_Event_Date`
FROM
    public.`lEV_Event` `EV`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 2nd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_EV_Event_2nd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_2nd',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `of_ETY_EventType` AS `of_ETY_EventType`,
        `EV_DAT_Event_Date` AS `EV_DAT_Event_Date`
    )),
    COUNT(DISTINCT `EV_ID`)
FROM
    public.`key_EV_Event_2nd`
WHERE
    `of_ETY_EventType` IS NOT NULL
AND
    `EV_DAT_Event_Date` IS NOT NULL
GROUP BY
    `of_ETY_EventType`,
    `EV_DAT_Event_Date`
HAVING
    COUNT(DISTINCT `EV_ID`) > 1
UNION ALL
SELECT
    'key_EV_Event_2nd',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `EV_ID` AS `EV_ID`
    )),
    COUNT(*)
FROM
    public.`key_EV_Event_2nd`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1;
-- Key view -----------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`key_EV_Event_3rd` (
    `EV_ID`,
    `content_PR_NAM_Program_Name`
)
AS
SELECT
    `EV`.`EV_ID`,
    `s2`.`PR_NAM_Program_Name`
FROM
    public.`lEV_Event` `EV`
LEFT JOIN
    public.`lPR_content_ST_location_EV_of` `s1`
ON
    `s1`.`EV_ID_of` = `EV`.`EV_ID`
LEFT JOIN
    public.`lPR_Program` `s2`
ON
    `s2`.`PR_ID` = `s1`.`PR_ID_content`
;
-- Key integrity ------------------------------------------------------------------------------------------------------
-- 3rd key of EV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_key_EV_Event_3rd` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'key_EV_Event_3rd',
    'duplicate natural key',
    TO_JSON_STRING(STRUCT(
        `content_PR_NAM_Program_Name` AS `content_PR_NAM_Program_Name`
    )),
    COUNT(DISTINCT `EV_ID`)
FROM
    public.`key_EV_Event_3rd`
WHERE
    `content_PR_NAM_Program_Name` IS NOT NULL
GROUP BY
    `content_PR_NAM_Program_Name`
HAVING
    COUNT(DISTINCT `EV_ID`) > 1
UNION ALL
SELECT
    'key_EV_Event_3rd',
    'more than one natural key',
    TO_JSON_STRING(STRUCT(
        `EV_ID` AS `EV_ID`
    )),
    COUNT(*)
FROM
    public.`key_EV_Event_3rd`
GROUP BY
    `EV_ID`
HAVING
    COUNT(*) > 1;
-- The 4th key of EV_Event is not generated: stop 1: a tie takes two stops in a row in one branch, the role it is entered by and the role it is left by
-- The 5th key of EV_Event is not generated: stop 1 is on the knot ETY_EventType, which a route reaches through a knotted attribute or a knot role instead
-- INTEGRITY CHECKS ---------------------------------------------------------------------------------------------------
--
-- BigQuery does not enforce primary or foreign keys, and it has no unique constraints. The primary and foreign keys are declared,
-- which tells the optimizer to trust them; a unique key is only a rule of the model. A violation is therefore not an error, but
-- wrong results. Every table has a view,
-- ic_<table>, that returns the rows that break what the table declares:
--
--   duplicate primary key, duplicate unique key   the same key more than once
--   no row in <table> for <column>                a reference to a row that does not exist
--
-- In a bitemporal model an attribute and a tie are a posit table and an annex table, each with a view
-- (ic_<posit table>, ic_<annex table>), and a third view, ic_<attribute or tie>, for what the two say together:
--
--   temporal duplicate                            the unique key of the assembled view in SQL Server: two annex rows with the
--                                                 same entity (the identifiers of a tie, or all its roles), changing time,
--                                                 positing time and reliability
--   more than one posit asserted at a time        for the same entity (the identifiers of a tie) and changing time, more than
--                                                 one posit asserted at a positing time: a correction retracts what it corrects
--                                                 at its own positing time
--   restatement                                   in an attribute or a tie that may not store them, a value that is asserted at
--                                                 the changing time after the one that has it already
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
CREATE OR REPLACE VIEW public.`ic_PAT_ParentalType` (
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
    public.`PAT_ParentalType`
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
    public.`PAT_ParentalType`
GROUP BY
    `PAT_ParentalType`
HAVING
    COUNT(*) > 1;
-- GEN_Gender integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_GEN_Gender` (
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
    public.`GEN_Gender`
GROUP BY
    `GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'GEN_Gender',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`GEN_Gender` AS `GEN_Gender`)),
    COUNT(*)
FROM
    public.`GEN_Gender`
GROUP BY
    `GEN_Gender`
HAVING
    COUNT(*) > 1;
-- PLV_ProfessionalLevel integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PLV_ProfessionalLevel` (
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
    public.`PLV_ProfessionalLevel`
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
    public.`PLV_ProfessionalLevel`
GROUP BY
    `PLV_Checksum`
HAVING
    COUNT(*) > 1;
-- UTL_Utilization integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_UTL_Utilization` (
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
    public.`UTL_Utilization`
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
    public.`UTL_Utilization`
GROUP BY
    `UTL_Utilization`
HAVING
    COUNT(*) > 1;
-- ONG_Ongoing integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ONG_Ongoing` (
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
    public.`ONG_Ongoing`
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
    public.`ONG_Ongoing`
GROUP BY
    `ONG_Ongoing`
HAVING
    COUNT(*) > 1;
-- RAT_Rating integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_RAT_Rating` (
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
    public.`RAT_Rating`
GROUP BY
    `RAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'RAT_Rating',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`RAT_Rating` AS `RAT_Rating`)),
    COUNT(*)
FROM
    public.`RAT_Rating`
GROUP BY
    `RAT_Rating`
HAVING
    COUNT(*) > 1;
-- ETY_EventType integrity --------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ETY_EventType` (
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
    public.`ETY_EventType`
GROUP BY
    `ETY_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ETY_EventType',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(`ETY_EventType` AS `ETY_EventType`)),
    COUNT(*)
FROM
    public.`ETY_EventType`
GROUP BY
    `ETY_EventType`
HAVING
    COUNT(*) > 1;
-- PN_Person integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PN_Person` (
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
    public.`PN_Person`
GROUP BY
    `PN_ID`
HAVING
    COUNT(*) > 1;
-- ST_Stage integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_Stage` (
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
    public.`ST_Stage`
GROUP BY
    `ST_ID`
HAVING
    COUNT(*) > 1;
-- AC_Actor integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_Actor` (
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
    public.`AC_Actor`
GROUP BY
    `AC_ID`
HAVING
    COUNT(*) > 1;
-- PR_Program integrity ------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_Program` (
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
    public.`PR_Program`
GROUP BY
    `PR_ID`
HAVING
    COUNT(*) > 1;
-- EV_Event integrity -------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_Event` (
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
    public.`EV_Event`
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
    public.`EV_Event` c
LEFT JOIN
    public.`ST_Stage` p
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
    public.`EV_Event` c
LEFT JOIN
    public.`PR_Program` p
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
    public.`EV_Event` c
LEFT JOIN
    public.`ETY_EventType` p
ON
    p.`ETY_ID` = c.`ETY_ID_of`
WHERE
    p.`ETY_ID` IS NULL
GROUP BY
    c.`ETY_ID_of`
;
-- EV_DAT_Event_Date_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_DAT_ID` AS `EV_DAT_ID`)),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Posit`
GROUP BY
    `EV_DAT_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`,
        `EV_DAT_Event_Date` AS `EV_DAT_Event_Date`
    )),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Posit`
GROUP BY
    `EV_DAT_EV_ID`,
    `EV_DAT_Event_Date`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Posit',
    'no row in EV_Event for EV_DAT_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_DAT_EV_ID` AS `EV_DAT_EV_ID`)),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_DAT_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_DAT_EV_ID`
;
-- EV_DAT_Event_Date_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_DAT_Event_Date_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_ID` AS `EV_DAT_ID`,
        `EV_DAT_PositedAt` AS `EV_DAT_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Annex`
GROUP BY
    `EV_DAT_ID`,
    `EV_DAT_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_DAT_Event_Date_Annex',
    'no row in EV_DAT_Event_Date_Posit for EV_DAT_ID',
    TO_JSON_STRING(STRUCT(c.`EV_DAT_ID` AS `EV_DAT_ID`)),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date_Annex` c
LEFT JOIN
    public.`EV_DAT_Event_Date_Posit` p
ON
    p.`EV_DAT_ID` = c.`EV_DAT_ID`
WHERE
    p.`EV_DAT_ID` IS NULL
GROUP BY
    c.`EV_DAT_ID`
;
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_DAT_Event_Date',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`,
        `EV_DAT_PositedAt` AS `EV_DAT_PositedAt`,
        `EV_DAT_Reliability` AS `EV_DAT_Reliability`
    )),
    COUNT(*)
FROM
    public.`EV_DAT_Event_Date`
GROUP BY
    `EV_DAT_EV_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_DAT_Event_Date',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `EV_DAT_EV_ID` AS `EV_DAT_EV_ID`,
        `EV_DAT_PositedAt` AS `EV_DAT_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_DAT_EV_ID`,
        `EV_DAT_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_DAT_EV_ID`
            ORDER BY
                `EV_DAT_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `EV_DAT_EV_ID`,
            `EV_DAT_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_DAT_ID` ORDER BY `EV_DAT_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `EV_DAT_ID`,
                `EV_DAT_EV_ID`,
                `EV_DAT_PositedAt`,
                IF(`EV_DAT_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`EV_DAT_Event_Date`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_DAT_EV_ID`,
    `EV_DAT_PositedAt`,
    asserted
;
-- EV_AUD_Event_Audience_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_AUD_ID` AS `EV_AUD_ID`)),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Posit`
GROUP BY
    `EV_AUD_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`,
        `EV_AUD_Event_Audience` AS `EV_AUD_Event_Audience`
    )),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Posit`
GROUP BY
    `EV_AUD_EV_ID`,
    `EV_AUD_Event_Audience`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Posit',
    'no row in EV_Event for EV_AUD_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_AUD_EV_ID` AS `EV_AUD_EV_ID`)),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_AUD_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_AUD_EV_ID`
;
-- EV_AUD_Event_Audience_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_AUD_Event_Audience_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_ID` AS `EV_AUD_ID`,
        `EV_AUD_PositedAt` AS `EV_AUD_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Annex`
GROUP BY
    `EV_AUD_ID`,
    `EV_AUD_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_AUD_Event_Audience_Annex',
    'no row in EV_AUD_Event_Audience_Posit for EV_AUD_ID',
    TO_JSON_STRING(STRUCT(c.`EV_AUD_ID` AS `EV_AUD_ID`)),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience_Annex` c
LEFT JOIN
    public.`EV_AUD_Event_Audience_Posit` p
ON
    p.`EV_AUD_ID` = c.`EV_AUD_ID`
WHERE
    p.`EV_AUD_ID` IS NULL
GROUP BY
    c.`EV_AUD_ID`
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_AUD_Event_Audience',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`,
        `EV_AUD_PositedAt` AS `EV_AUD_PositedAt`,
        `EV_AUD_Reliability` AS `EV_AUD_Reliability`
    )),
    COUNT(*)
FROM
    public.`EV_AUD_Event_Audience`
GROUP BY
    `EV_AUD_EV_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_AUD_Event_Audience',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `EV_AUD_EV_ID` AS `EV_AUD_EV_ID`,
        `EV_AUD_PositedAt` AS `EV_AUD_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_AUD_EV_ID`,
        `EV_AUD_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_AUD_EV_ID`
            ORDER BY
                `EV_AUD_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `EV_AUD_EV_ID`,
            `EV_AUD_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_AUD_ID` ORDER BY `EV_AUD_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `EV_AUD_ID`,
                `EV_AUD_EV_ID`,
                `EV_AUD_PositedAt`,
                IF(`EV_AUD_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`EV_AUD_Event_Audience`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_AUD_EV_ID`,
    `EV_AUD_PositedAt`,
    asserted
;
-- EV_REV_Event_Revenue_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_REV_ID` AS `EV_REV_ID`)),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Posit`
GROUP BY
    `EV_REV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`,
        `EV_REV_Event_Revenue` AS `EV_REV_Event_Revenue`
    )),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Posit`
GROUP BY
    `EV_REV_EV_ID`,
    `EV_REV_Event_Revenue`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Posit',
    'no row in EV_Event for EV_REV_EV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_REV_EV_ID` AS `EV_REV_EV_ID`)),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_REV_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_REV_EV_ID`
;
-- EV_REV_Event_Revenue_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_REV_Event_Revenue_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_REV_ID` AS `EV_REV_ID`,
        `EV_REV_PositedAt` AS `EV_REV_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Annex`
GROUP BY
    `EV_REV_ID`,
    `EV_REV_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_REV_Event_Revenue_Annex',
    'no row in EV_REV_Event_Revenue_Posit for EV_REV_ID',
    TO_JSON_STRING(STRUCT(c.`EV_REV_ID` AS `EV_REV_ID`)),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue_Annex` c
LEFT JOIN
    public.`EV_REV_Event_Revenue_Posit` p
ON
    p.`EV_REV_ID` = c.`EV_REV_ID`
WHERE
    p.`EV_REV_ID` IS NULL
GROUP BY
    c.`EV_REV_ID`
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_REV_Event_Revenue',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`,
        `EV_REV_PositedAt` AS `EV_REV_PositedAt`,
        `EV_REV_Reliability` AS `EV_REV_Reliability`
    )),
    COUNT(*)
FROM
    public.`EV_REV_Event_Revenue`
GROUP BY
    `EV_REV_EV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'EV_REV_Event_Revenue',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `EV_REV_EV_ID` AS `EV_REV_EV_ID`,
        `EV_REV_PositedAt` AS `EV_REV_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_REV_EV_ID`,
        `EV_REV_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_REV_EV_ID`
            ORDER BY
                `EV_REV_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `EV_REV_EV_ID`,
            `EV_REV_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_REV_ID` ORDER BY `EV_REV_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `EV_REV_ID`,
                `EV_REV_EV_ID`,
                `EV_REV_PositedAt`,
                IF(`EV_REV_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`EV_REV_Event_Revenue`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_REV_EV_ID`,
    `EV_REV_PositedAt`,
    asserted
;
-- ST_NAM_Stage_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_NAM_ID` AS `ST_NAM_ID`)),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Posit`
GROUP BY
    `ST_NAM_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`,
        `ST_NAM_Stage_Name` AS `ST_NAM_Stage_Name`
    )),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Posit`
GROUP BY
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_Stage_Name`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Posit',
    'no row in ST_Stage for ST_NAM_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_NAM_ST_ID` AS `ST_NAM_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_NAM_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_NAM_ST_ID`
;
-- ST_NAM_Stage_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_NAM_Stage_Name_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ID` AS `ST_NAM_ID`,
        `ST_NAM_PositedAt` AS `ST_NAM_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Annex`
GROUP BY
    `ST_NAM_ID`,
    `ST_NAM_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_NAM_Stage_Name_Annex',
    'no row in ST_NAM_Stage_Name_Posit for ST_NAM_ID',
    TO_JSON_STRING(STRUCT(c.`ST_NAM_ID` AS `ST_NAM_ID`)),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name_Annex` c
LEFT JOIN
    public.`ST_NAM_Stage_Name_Posit` p
ON
    p.`ST_NAM_ID` = c.`ST_NAM_ID`
WHERE
    p.`ST_NAM_ID` IS NULL
GROUP BY
    c.`ST_NAM_ID`
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_NAM_Stage_Name',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`,
        `ST_NAM_PositedAt` AS `ST_NAM_PositedAt`,
        `ST_NAM_Reliability` AS `ST_NAM_Reliability`
    )),
    COUNT(*)
FROM
    public.`ST_NAM_Stage_Name`
GROUP BY
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_NAM_Stage_Name',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `ST_NAM_ST_ID` AS `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt` AS `ST_NAM_ChangedAt`,
        `ST_NAM_PositedAt` AS `ST_NAM_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt`,
        `ST_NAM_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_NAM_ST_ID`,
                `ST_NAM_ChangedAt`
            ORDER BY
                `ST_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `ST_NAM_ST_ID`,
            `ST_NAM_ChangedAt`,
            `ST_NAM_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_NAM_ID` ORDER BY `ST_NAM_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `ST_NAM_ID`,
                `ST_NAM_ST_ID`,
                `ST_NAM_ChangedAt`,
                `ST_NAM_PositedAt`,
                IF(`ST_NAM_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`ST_NAM_Stage_Name`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_NAM_ST_ID`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_PositedAt`,
    asserted
;
-- ST_LOC_Stage_Location_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_LOC_ID` AS `ST_LOC_ID`)),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Posit`
GROUP BY
    `ST_LOC_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`,
        `ST_LOC_Checksum` AS `ST_LOC_Checksum`
    )),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Posit`
GROUP BY
    `ST_LOC_ST_ID`,
    `ST_LOC_Checksum`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Posit',
    'no row in ST_Stage for ST_LOC_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_LOC_ST_ID` AS `ST_LOC_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_LOC_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_LOC_ST_ID`
;
-- ST_LOC_Stage_Location_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_LOC_Stage_Location_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ID` AS `ST_LOC_ID`,
        `ST_LOC_PositedAt` AS `ST_LOC_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Annex`
GROUP BY
    `ST_LOC_ID`,
    `ST_LOC_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_LOC_Stage_Location_Annex',
    'no row in ST_LOC_Stage_Location_Posit for ST_LOC_ID',
    TO_JSON_STRING(STRUCT(c.`ST_LOC_ID` AS `ST_LOC_ID`)),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location_Annex` c
LEFT JOIN
    public.`ST_LOC_Stage_Location_Posit` p
ON
    p.`ST_LOC_ID` = c.`ST_LOC_ID`
WHERE
    p.`ST_LOC_ID` IS NULL
GROUP BY
    c.`ST_LOC_ID`
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_LOC_Stage_Location',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`,
        `ST_LOC_PositedAt` AS `ST_LOC_PositedAt`,
        `ST_LOC_Reliability` AS `ST_LOC_Reliability`
    )),
    COUNT(*)
FROM
    public.`ST_LOC_Stage_Location`
GROUP BY
    `ST_LOC_ST_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_LOC_Stage_Location',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `ST_LOC_ST_ID` AS `ST_LOC_ST_ID`,
        `ST_LOC_PositedAt` AS `ST_LOC_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_LOC_ST_ID`,
        `ST_LOC_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_LOC_ST_ID`
            ORDER BY
                `ST_LOC_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `ST_LOC_ST_ID`,
            `ST_LOC_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_LOC_ID` ORDER BY `ST_LOC_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `ST_LOC_ID`,
                `ST_LOC_ST_ID`,
                `ST_LOC_PositedAt`,
                IF(`ST_LOC_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`ST_LOC_Stage_Location`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_LOC_ST_ID`,
    `ST_LOC_PositedAt`,
    asserted
;
-- ST_AVG_Stage_Average_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_AVG_ID` AS `ST_AVG_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit`
GROUP BY
    `ST_AVG_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`,
        `ST_AVG_UTL_ID` AS `ST_AVG_UTL_ID`
    )),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit`
GROUP BY
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_UTL_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in ST_Stage for ST_AVG_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_ST_ID` AS `ST_AVG_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_AVG_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_AVG_ST_ID`
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Posit',
    'no row in UTL_Utilization for ST_AVG_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_UTL_ID` AS `ST_AVG_UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Posit` c
LEFT JOIN
    public.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`ST_AVG_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_AVG_UTL_ID`
;
-- ST_AVG_Stage_Average_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_AVG_Stage_Average_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ID` AS `ST_AVG_ID`,
        `ST_AVG_PositedAt` AS `ST_AVG_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Annex`
GROUP BY
    `ST_AVG_ID`,
    `ST_AVG_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_AVG_Stage_Average_Annex',
    'no row in ST_AVG_Stage_Average_Posit for ST_AVG_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_ID` AS `ST_AVG_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average_Annex` c
LEFT JOIN
    public.`ST_AVG_Stage_Average_Posit` p
ON
    p.`ST_AVG_ID` = c.`ST_AVG_ID`
WHERE
    p.`ST_AVG_ID` IS NULL
GROUP BY
    c.`ST_AVG_ID`
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_AVG_Stage_Average',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`,
        `ST_AVG_PositedAt` AS `ST_AVG_PositedAt`,
        `ST_AVG_Reliability` AS `ST_AVG_Reliability`
    )),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average`
GROUP BY
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_AVG_Stage_Average',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `ST_AVG_ST_ID` AS `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt` AS `ST_AVG_ChangedAt`,
        `ST_AVG_PositedAt` AS `ST_AVG_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`,
        `ST_AVG_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_AVG_ST_ID`,
                `ST_AVG_ChangedAt`
            ORDER BY
                `ST_AVG_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `ST_AVG_ST_ID`,
            `ST_AVG_ChangedAt`,
            `ST_AVG_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_AVG_ID` ORDER BY `ST_AVG_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `ST_AVG_ID`,
                `ST_AVG_ST_ID`,
                `ST_AVG_ChangedAt`,
                `ST_AVG_PositedAt`,
                IF(`ST_AVG_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`ST_AVG_Stage_Average`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_AVG_ST_ID`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_PositedAt`,
    asserted
UNION ALL
-- restatement in what is in effect: the latest annex row of each posit, when it asserts the posit
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
            PARTITION BY `ST_AVG_ST_ID`
            ORDER BY `ST_AVG_ChangedAt`, `ST_AVG_ID`
        ) AS previous,
        LAG(`ST_AVG_ChangedAt`) OVER (
            PARTITION BY `ST_AVG_ST_ID`
            ORDER BY `ST_AVG_ChangedAt`, `ST_AVG_ID`
        ) AS previous_changing
    FROM (
        SELECT
            `ST_AVG_ID`,
            `ST_AVG_ST_ID`,
            `ST_AVG_ChangedAt`,
            `ST_AVG_UTL_ID`,
            `ST_AVG_Reliability`
        FROM
            public.`ST_AVG_Stage_Average`
        WHERE
            TRUE
        QUALIFY
            ROW_NUMBER() OVER (
                PARTITION BY `ST_AVG_ID`
                ORDER BY `ST_AVG_PositedAt` DESC
            ) = 1
    )
    WHERE
        `ST_AVG_Reliability` = 1
)
WHERE
    compared = previous
AND
    previous_changing < `ST_AVG_ChangedAt`
;
-- ST_MIN_Stage_Minimum_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_MIN_ID` AS `ST_MIN_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit`
GROUP BY
    `ST_MIN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`,
        `ST_MIN_UTL_ID` AS `ST_MIN_UTL_ID`
    )),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit`
GROUP BY
    `ST_MIN_ST_ID`,
    `ST_MIN_UTL_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in ST_Stage for ST_MIN_ST_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_ST_ID` AS `ST_MIN_ST_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_MIN_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_MIN_ST_ID`
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Posit',
    'no row in UTL_Utilization for ST_MIN_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_UTL_ID` AS `ST_MIN_UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Posit` c
LEFT JOIN
    public.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`ST_MIN_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_MIN_UTL_ID`
;
-- ST_MIN_Stage_Minimum_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ID` AS `ST_MIN_ID`,
        `ST_MIN_PositedAt` AS `ST_MIN_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Annex`
GROUP BY
    `ST_MIN_ID`,
    `ST_MIN_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_MIN_Stage_Minimum_Annex',
    'no row in ST_MIN_Stage_Minimum_Posit for ST_MIN_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_ID` AS `ST_MIN_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum_Annex` c
LEFT JOIN
    public.`ST_MIN_Stage_Minimum_Posit` p
ON
    p.`ST_MIN_ID` = c.`ST_MIN_ID`
WHERE
    p.`ST_MIN_ID` IS NULL
GROUP BY
    c.`ST_MIN_ID`
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_MIN_Stage_Minimum',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`,
        `ST_MIN_PositedAt` AS `ST_MIN_PositedAt`,
        `ST_MIN_Reliability` AS `ST_MIN_Reliability`
    )),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum`
GROUP BY
    `ST_MIN_ST_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'ST_MIN_Stage_Minimum',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `ST_MIN_ST_ID` AS `ST_MIN_ST_ID`,
        `ST_MIN_PositedAt` AS `ST_MIN_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_MIN_ST_ID`,
        `ST_MIN_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_MIN_ST_ID`
            ORDER BY
                `ST_MIN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `ST_MIN_ST_ID`,
            `ST_MIN_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_MIN_ID` ORDER BY `ST_MIN_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `ST_MIN_ID`,
                `ST_MIN_ST_ID`,
                `ST_MIN_PositedAt`,
                IF(`ST_MIN_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`ST_MIN_Stage_Minimum`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_MIN_ST_ID`,
    `ST_MIN_PositedAt`,
    asserted
;
-- AC_NAM_Actor_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_NAM_ID` AS `AC_NAM_ID`)),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Posit`
GROUP BY
    `AC_NAM_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`,
        `AC_NAM_Actor_Name` AS `AC_NAM_Actor_Name`
    )),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Posit`
GROUP BY
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_Actor_Name`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Posit',
    'no row in AC_Actor for AC_NAM_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_NAM_AC_ID` AS `AC_NAM_AC_ID`)),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_NAM_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_NAM_AC_ID`
;
-- AC_NAM_Actor_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_NAM_Actor_Name_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_ID` AS `AC_NAM_ID`,
        `AC_NAM_PositedAt` AS `AC_NAM_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Annex`
GROUP BY
    `AC_NAM_ID`,
    `AC_NAM_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_NAM_Actor_Name_Annex',
    'no row in AC_NAM_Actor_Name_Posit for AC_NAM_ID',
    TO_JSON_STRING(STRUCT(c.`AC_NAM_ID` AS `AC_NAM_ID`)),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name_Annex` c
LEFT JOIN
    public.`AC_NAM_Actor_Name_Posit` p
ON
    p.`AC_NAM_ID` = c.`AC_NAM_ID`
WHERE
    p.`AC_NAM_ID` IS NULL
GROUP BY
    c.`AC_NAM_ID`
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_NAM_Actor_Name',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`,
        `AC_NAM_PositedAt` AS `AC_NAM_PositedAt`,
        `AC_NAM_Reliability` AS `AC_NAM_Reliability`
    )),
    COUNT(*)
FROM
    public.`AC_NAM_Actor_Name`
GROUP BY
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_NAM_Actor_Name',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `AC_NAM_AC_ID` AS `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt` AS `AC_NAM_ChangedAt`,
        `AC_NAM_PositedAt` AS `AC_NAM_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`,
        `AC_NAM_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_NAM_AC_ID`,
                `AC_NAM_ChangedAt`
            ORDER BY
                `AC_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `AC_NAM_AC_ID`,
            `AC_NAM_ChangedAt`,
            `AC_NAM_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_NAM_ID` ORDER BY `AC_NAM_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `AC_NAM_ID`,
                `AC_NAM_AC_ID`,
                `AC_NAM_ChangedAt`,
                `AC_NAM_PositedAt`,
                IF(`AC_NAM_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`AC_NAM_Actor_Name`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_NAM_AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_PositedAt`,
    asserted
UNION ALL
-- restatement in what is in effect: the latest annex row of each posit, when it asserts the posit
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
            PARTITION BY `AC_NAM_AC_ID`
            ORDER BY `AC_NAM_ChangedAt`, `AC_NAM_ID`
        ) AS previous,
        LAG(`AC_NAM_ChangedAt`) OVER (
            PARTITION BY `AC_NAM_AC_ID`
            ORDER BY `AC_NAM_ChangedAt`, `AC_NAM_ID`
        ) AS previous_changing
    FROM (
        SELECT
            `AC_NAM_ID`,
            `AC_NAM_AC_ID`,
            `AC_NAM_ChangedAt`,
            `AC_NAM_Actor_Name`,
            `AC_NAM_Reliability`
        FROM
            public.`AC_NAM_Actor_Name`
        WHERE
            TRUE
        QUALIFY
            ROW_NUMBER() OVER (
                PARTITION BY `AC_NAM_ID`
                ORDER BY `AC_NAM_PositedAt` DESC
            ) = 1
    )
    WHERE
        `AC_NAM_Reliability` = 1
)
WHERE
    compared = previous
AND
    previous_changing < `AC_NAM_ChangedAt`
;
-- AC_GEN_Actor_Gender_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_GEN_ID` AS `AC_GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit`
GROUP BY
    `AC_GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`,
        `AC_GEN_GEN_ID` AS `AC_GEN_GEN_ID`
    )),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit`
GROUP BY
    `AC_GEN_AC_ID`,
    `AC_GEN_GEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in AC_Actor for AC_GEN_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_AC_ID` AS `AC_GEN_AC_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_GEN_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_GEN_AC_ID`
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Posit',
    'no row in GEN_Gender for AC_GEN_GEN_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_GEN_ID` AS `AC_GEN_GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Posit` c
LEFT JOIN
    public.`GEN_Gender` p
ON
    p.`GEN_ID` = c.`AC_GEN_GEN_ID`
WHERE
    p.`GEN_ID` IS NULL
GROUP BY
    c.`AC_GEN_GEN_ID`
;
-- AC_GEN_Actor_Gender_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_ID` AS `AC_GEN_ID`,
        `AC_GEN_PositedAt` AS `AC_GEN_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Annex`
GROUP BY
    `AC_GEN_ID`,
    `AC_GEN_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_GEN_Actor_Gender_Annex',
    'no row in AC_GEN_Actor_Gender_Posit for AC_GEN_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_ID` AS `AC_GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender_Annex` c
LEFT JOIN
    public.`AC_GEN_Actor_Gender_Posit` p
ON
    p.`AC_GEN_ID` = c.`AC_GEN_ID`
WHERE
    p.`AC_GEN_ID` IS NULL
GROUP BY
    c.`AC_GEN_ID`
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_GEN_Actor_Gender',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`,
        `AC_GEN_PositedAt` AS `AC_GEN_PositedAt`,
        `AC_GEN_Reliability` AS `AC_GEN_Reliability`
    )),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender`
GROUP BY
    `AC_GEN_AC_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_GEN_Actor_Gender',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `AC_GEN_AC_ID` AS `AC_GEN_AC_ID`,
        `AC_GEN_PositedAt` AS `AC_GEN_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_GEN_AC_ID`,
        `AC_GEN_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_GEN_AC_ID`
            ORDER BY
                `AC_GEN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `AC_GEN_AC_ID`,
            `AC_GEN_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_GEN_ID` ORDER BY `AC_GEN_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `AC_GEN_ID`,
                `AC_GEN_AC_ID`,
                `AC_GEN_PositedAt`,
                IF(`AC_GEN_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`AC_GEN_Actor_Gender`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_GEN_AC_ID`,
    `AC_GEN_PositedAt`,
    asserted
;
-- AC_PLV_Actor_ProfessionalLevel_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_PLV_ID` AS `AC_PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
GROUP BY
    `AC_PLV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`,
        `AC_PLV_PLV_ID` AS `AC_PLV_PLV_ID`
    )),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit`
GROUP BY
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PLV_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in AC_Actor for AC_PLV_AC_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_AC_ID` AS `AC_PLV_AC_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_PLV_AC_ID`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_PLV_AC_ID`
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Posit',
    'no row in PLV_ProfessionalLevel for AC_PLV_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_PLV_ID` AS `AC_PLV_PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Posit` c
LEFT JOIN
    public.`PLV_ProfessionalLevel` p
ON
    p.`PLV_ID` = c.`AC_PLV_PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`AC_PLV_PLV_ID`
;
-- AC_PLV_Actor_ProfessionalLevel_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_ID` AS `AC_PLV_ID`,
        `AC_PLV_PositedAt` AS `AC_PLV_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Annex`
GROUP BY
    `AC_PLV_ID`,
    `AC_PLV_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_PLV_Actor_ProfessionalLevel_Annex',
    'no row in AC_PLV_Actor_ProfessionalLevel_Posit for AC_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_ID` AS `AC_PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Annex` c
LEFT JOIN
    public.`AC_PLV_Actor_ProfessionalLevel_Posit` p
ON
    p.`AC_PLV_ID` = c.`AC_PLV_ID`
WHERE
    p.`AC_PLV_ID` IS NULL
GROUP BY
    c.`AC_PLV_ID`
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`,
        `AC_PLV_PositedAt` AS `AC_PLV_PositedAt`,
        `AC_PLV_Reliability` AS `AC_PLV_Reliability`
    )),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel`
GROUP BY
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'AC_PLV_Actor_ProfessionalLevel',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `AC_PLV_AC_ID` AS `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt` AS `AC_PLV_ChangedAt`,
        `AC_PLV_PositedAt` AS `AC_PLV_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt`,
        `AC_PLV_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_PLV_AC_ID`,
                `AC_PLV_ChangedAt`
            ORDER BY
                `AC_PLV_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `AC_PLV_AC_ID`,
            `AC_PLV_ChangedAt`,
            `AC_PLV_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_PLV_ID` ORDER BY `AC_PLV_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `AC_PLV_ID`,
                `AC_PLV_AC_ID`,
                `AC_PLV_ChangedAt`,
                `AC_PLV_PositedAt`,
                IF(`AC_PLV_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`AC_PLV_Actor_ProfessionalLevel`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_PLV_AC_ID`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PositedAt`,
    asserted
;
-- PR_NAM_Program_Name_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_NAM_ID` AS `PR_NAM_ID`)),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Posit`
GROUP BY
    `PR_NAM_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`,
        `PR_NAM_Program_Name` AS `PR_NAM_Program_Name`
    )),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Posit`
GROUP BY
    `PR_NAM_PR_ID`,
    `PR_NAM_Program_Name`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Posit',
    'no row in PR_Program for PR_NAM_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_NAM_PR_ID` AS `PR_NAM_PR_ID`)),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_NAM_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_NAM_PR_ID`
;
-- PR_NAM_Program_Name_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_NAM_Program_Name_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_ID` AS `PR_NAM_ID`,
        `PR_NAM_PositedAt` AS `PR_NAM_PositedAt`
    )),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Annex`
GROUP BY
    `PR_NAM_ID`,
    `PR_NAM_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_NAM_Program_Name_Annex',
    'no row in PR_NAM_Program_Name_Posit for PR_NAM_ID',
    TO_JSON_STRING(STRUCT(c.`PR_NAM_ID` AS `PR_NAM_ID`)),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name_Annex` c
LEFT JOIN
    public.`PR_NAM_Program_Name_Posit` p
ON
    p.`PR_NAM_ID` = c.`PR_NAM_ID`
WHERE
    p.`PR_NAM_ID` IS NULL
GROUP BY
    c.`PR_NAM_ID`
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_NAM_Program_Name',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`,
        `PR_NAM_PositedAt` AS `PR_NAM_PositedAt`,
        `PR_NAM_Reliability` AS `PR_NAM_Reliability`
    )),
    COUNT(*)
FROM
    public.`PR_NAM_Program_Name`
GROUP BY
    `PR_NAM_PR_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'PR_NAM_Program_Name',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `PR_NAM_PR_ID` AS `PR_NAM_PR_ID`,
        `PR_NAM_PositedAt` AS `PR_NAM_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `PR_NAM_PR_ID`,
        `PR_NAM_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `PR_NAM_PR_ID`
            ORDER BY
                `PR_NAM_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `PR_NAM_PR_ID`,
            `PR_NAM_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `PR_NAM_ID` ORDER BY `PR_NAM_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `PR_NAM_ID`,
                `PR_NAM_PR_ID`,
                `PR_NAM_PositedAt`,
                IF(`PR_NAM_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`PR_NAM_Program_Name`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `PR_NAM_PR_ID`,
    `PR_NAM_PositedAt`,
    asserted
;
-- PR_LEN_Program_Length_Posit integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_LEN_ID` AS `PR_LEN_ID`)),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Posit`
GROUP BY
    `PR_LEN_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`,
        `PR_LEN_Program_Length` AS `PR_LEN_Program_Length`
    )),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Posit`
GROUP BY
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_Program_Length`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Posit',
    'no row in PR_Program for PR_LEN_PR_ID',
    TO_JSON_STRING(STRUCT(c.`PR_LEN_PR_ID` AS `PR_LEN_PR_ID`)),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_LEN_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_LEN_PR_ID`
;
-- PR_LEN_Program_Length_Annex integrity ----------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_LEN_Program_Length_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_ID` AS `PR_LEN_ID`,
        `PR_LEN_PositedAt` AS `PR_LEN_PositedAt`
    )),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Annex`
GROUP BY
    `PR_LEN_ID`,
    `PR_LEN_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_LEN_Program_Length_Annex',
    'no row in PR_LEN_Program_Length_Posit for PR_LEN_ID',
    TO_JSON_STRING(STRUCT(c.`PR_LEN_ID` AS `PR_LEN_ID`)),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length_Annex` c
LEFT JOIN
    public.`PR_LEN_Program_Length_Posit` p
ON
    p.`PR_LEN_ID` = c.`PR_LEN_ID`
WHERE
    p.`PR_LEN_ID` IS NULL
GROUP BY
    c.`PR_LEN_ID`
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_LEN_Program_Length',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`,
        `PR_LEN_PositedAt` AS `PR_LEN_PositedAt`,
        `PR_LEN_Reliability` AS `PR_LEN_Reliability`
    )),
    COUNT(*)
FROM
    public.`PR_LEN_Program_Length`
GROUP BY
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same entity and changing time: a posit is asserted from its annex row until the next
-- annex row of its own, so what is asserted at a positing time is the running sum of the changes up to it
SELECT
    'PR_LEN_Program_Length',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `PR_LEN_PR_ID` AS `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt` AS `PR_LEN_ChangedAt`,
        `PR_LEN_PositedAt` AS `PR_LEN_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt`,
        `PR_LEN_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `PR_LEN_PR_ID`,
                `PR_LEN_ChangedAt`
            ORDER BY
                `PR_LEN_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `PR_LEN_PR_ID`,
            `PR_LEN_ChangedAt`,
            `PR_LEN_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `PR_LEN_ID` ORDER BY `PR_LEN_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `PR_LEN_ID`,
                `PR_LEN_PR_ID`,
                `PR_LEN_ChangedAt`,
                `PR_LEN_PositedAt`,
                IF(`PR_LEN_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`PR_LEN_Program_Length`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `PR_LEN_PR_ID`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_PositedAt`,
    asserted
;
-- AC_partner_AC_with_ONG_currently_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_partner_AC_with_ONG_currently_ID` AS `AC_partner_AC_with_ONG_currently_ID`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_partner_AC_with_ONG_currently_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_partner)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_ID_partner`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'duplicate unique key (AC_with)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_with` AS `AC_ID_with`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit`
GROUP BY
    `AC_ID_with`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_partner',
    TO_JSON_STRING(STRUCT(c.`AC_ID_partner` AS `AC_ID_partner`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_partner`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_partner`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in AC_Actor for AC_ID_with',
    TO_JSON_STRING(STRUCT(c.`AC_ID_with` AS `AC_ID_with`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_with`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_with`
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Posit',
    'no row in ONG_Ongoing for ONG_ID_currently',
    TO_JSON_STRING(STRUCT(c.`ONG_ID_currently` AS `ONG_ID_currently`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Posit` c
LEFT JOIN
    public.`ONG_Ongoing` p
ON
    p.`ONG_ID` = c.`ONG_ID_currently`
WHERE
    p.`ONG_ID` IS NULL
GROUP BY
    c.`ONG_ID_currently`
;
-- AC_partner_AC_with_ONG_currently_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_partner_AC_with_ONG_currently_ID` AS `AC_partner_AC_with_ONG_currently_ID`,
        `AC_partner_AC_with_ONG_currently_PositedAt` AS `AC_partner_AC_with_ONG_currently_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Annex`
GROUP BY
    `AC_partner_AC_with_ONG_currently_ID`,
    `AC_partner_AC_with_ONG_currently_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_partner_AC_with_ONG_currently_Annex',
    'no row in AC_partner_AC_with_ONG_currently_Posit for AC_partner_AC_with_ONG_currently_ID',
    TO_JSON_STRING(STRUCT(c.`AC_partner_AC_with_ONG_currently_ID` AS `AC_partner_AC_with_ONG_currently_ID`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently_Annex` c
LEFT JOIN
    public.`AC_partner_AC_with_ONG_currently_Posit` p
ON
    p.`AC_partner_AC_with_ONG_currently_ID` = c.`AC_partner_AC_with_ONG_currently_ID`
WHERE
    p.`AC_partner_AC_with_ONG_currently_ID` IS NULL
GROUP BY
    c.`AC_partner_AC_with_ONG_currently_ID`
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_partner_AC_with_ONG_currently',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`,
        `AC_partner_AC_with_ONG_currently_PositedAt` AS `AC_partner_AC_with_ONG_currently_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently`
GROUP BY
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_partner_AC_with_ONG_currently_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_partner_AC_with_ONG_currently',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `AC_ID_partner` AS `AC_ID_partner`,
        `AC_ID_with` AS `AC_ID_with`,
        `ONG_ID_currently` AS `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt` AS `AC_partner_AC_with_ONG_currently_ChangedAt`,
        `AC_partner_AC_with_ONG_currently_PositedAt` AS `AC_partner_AC_with_ONG_currently_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_ID_partner`,
        `AC_ID_with`,
        `ONG_ID_currently`,
        `AC_partner_AC_with_ONG_currently_ChangedAt`,
        `AC_partner_AC_with_ONG_currently_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_ID_partner`,
                `AC_ID_with`,
                `ONG_ID_currently`,
                `AC_partner_AC_with_ONG_currently_ChangedAt`
            ORDER BY
                `AC_partner_AC_with_ONG_currently_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `AC_ID_partner`,
            `AC_ID_with`,
            `ONG_ID_currently`,
            `AC_partner_AC_with_ONG_currently_ChangedAt`,
            `AC_partner_AC_with_ONG_currently_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_partner_AC_with_ONG_currently_ID` ORDER BY `AC_partner_AC_with_ONG_currently_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `AC_partner_AC_with_ONG_currently_ID`,
                `AC_ID_partner`,
                `AC_ID_with`,
                `ONG_ID_currently`,
                `AC_partner_AC_with_ONG_currently_ChangedAt`,
                `AC_partner_AC_with_ONG_currently_PositedAt`,
                IF(`AC_partner_AC_with_ONG_currently_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`AC_partner_AC_with_ONG_currently`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_ID_partner`,
    `AC_ID_with`,
    `ONG_ID_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_partner_AC_with_ONG_currently_PositedAt`,
    asserted
;
-- AC_subset_PN_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_subset_PN_of_ID` AS `AC_subset_PN_of_ID`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `AC_subset_PN_of_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `AC_ID_subset`,
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (AC_subset)',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `AC_ID_subset`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'duplicate unique key (PN_of)',
    TO_JSON_STRING(STRUCT(
        `PN_ID_of` AS `PN_ID_of`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit`
GROUP BY
    `PN_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in AC_Actor for AC_ID_subset',
    TO_JSON_STRING(STRUCT(c.`AC_ID_subset` AS `AC_ID_subset`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_subset`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_subset`
UNION ALL
SELECT
    'AC_subset_PN_of_Posit',
    'no row in PN_Person for PN_ID_of',
    TO_JSON_STRING(STRUCT(c.`PN_ID_of` AS `PN_ID_of`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Posit` c
LEFT JOIN
    public.`PN_Person` p
ON
    p.`PN_ID` = c.`PN_ID_of`
WHERE
    p.`PN_ID` IS NULL
GROUP BY
    c.`PN_ID_of`
;
-- AC_subset_PN_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_subset_PN_of_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_subset_PN_of_ID` AS `AC_subset_PN_of_ID`,
        `AC_subset_PN_of_PositedAt` AS `AC_subset_PN_of_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Annex`
GROUP BY
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_subset_PN_of_Annex',
    'no row in AC_subset_PN_of_Posit for AC_subset_PN_of_ID',
    TO_JSON_STRING(STRUCT(c.`AC_subset_PN_of_ID` AS `AC_subset_PN_of_ID`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of_Annex` c
LEFT JOIN
    public.`AC_subset_PN_of_Posit` p
ON
    p.`AC_subset_PN_of_ID` = c.`AC_subset_PN_of_ID`
WHERE
    p.`AC_subset_PN_of_ID` IS NULL
GROUP BY
    c.`AC_subset_PN_of_ID`
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_subset_PN_of',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`,
        `AC_subset_PN_of_PositedAt` AS `AC_subset_PN_of_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_subset_PN_of`
GROUP BY
    `AC_ID_subset`,
    `PN_ID_of`,
    `AC_subset_PN_of_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_subset_PN_of',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `AC_ID_subset` AS `AC_ID_subset`,
        `PN_ID_of` AS `PN_ID_of`,
        `AC_subset_PN_of_PositedAt` AS `AC_subset_PN_of_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_ID_subset`,
        `PN_ID_of`,
        `AC_subset_PN_of_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_ID_subset`,
                `PN_ID_of`
            ORDER BY
                `AC_subset_PN_of_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `AC_ID_subset`,
            `PN_ID_of`,
            `AC_subset_PN_of_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_subset_PN_of_ID` ORDER BY `AC_subset_PN_of_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `AC_subset_PN_of_ID`,
                `AC_ID_subset`,
                `PN_ID_of`,
                `AC_subset_PN_of_PositedAt`,
                IF(`AC_subset_PN_of_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`AC_subset_PN_of`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_ID_subset`,
    `PN_ID_of`,
    `AC_subset_PN_of_PositedAt`,
    asserted
;
-- EV_in_AC_wasCast_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`EV_in_AC_wasCast_ID` AS `EV_in_AC_wasCast_ID`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit`
GROUP BY
    `EV_in_AC_wasCast_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`
    )),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit`
GROUP BY
    `EV_ID_in`,
    `AC_ID_wasCast`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in EV_Event for EV_ID_in',
    TO_JSON_STRING(STRUCT(c.`EV_ID_in` AS `EV_ID_in`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID_in`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_in`
UNION ALL
SELECT
    'EV_in_AC_wasCast_Posit',
    'no row in AC_Actor for AC_ID_wasCast',
    TO_JSON_STRING(STRUCT(c.`AC_ID_wasCast` AS `AC_ID_wasCast`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_wasCast`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_wasCast`
;
-- EV_in_AC_wasCast_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'EV_in_AC_wasCast_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `EV_in_AC_wasCast_ID` AS `EV_in_AC_wasCast_ID`,
        `EV_in_AC_wasCast_PositedAt` AS `EV_in_AC_wasCast_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Annex`
GROUP BY
    `EV_in_AC_wasCast_ID`,
    `EV_in_AC_wasCast_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'EV_in_AC_wasCast_Annex',
    'no row in EV_in_AC_wasCast_Posit for EV_in_AC_wasCast_ID',
    TO_JSON_STRING(STRUCT(c.`EV_in_AC_wasCast_ID` AS `EV_in_AC_wasCast_ID`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast_Annex` c
LEFT JOIN
    public.`EV_in_AC_wasCast_Posit` p
ON
    p.`EV_in_AC_wasCast_ID` = c.`EV_in_AC_wasCast_ID`
WHERE
    p.`EV_in_AC_wasCast_ID` IS NULL
GROUP BY
    c.`EV_in_AC_wasCast_ID`
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'EV_in_AC_wasCast',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`,
        `EV_in_AC_wasCast_PositedAt` AS `EV_in_AC_wasCast_PositedAt`
    )),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast`
GROUP BY
    `EV_ID_in`,
    `AC_ID_wasCast`,
    `EV_in_AC_wasCast_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'EV_in_AC_wasCast',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `EV_ID_in` AS `EV_ID_in`,
        `AC_ID_wasCast` AS `AC_ID_wasCast`,
        `EV_in_AC_wasCast_PositedAt` AS `EV_in_AC_wasCast_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_ID_in`,
        `AC_ID_wasCast`,
        `EV_in_AC_wasCast_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_ID_in`,
                `AC_ID_wasCast`
            ORDER BY
                `EV_in_AC_wasCast_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `EV_ID_in`,
            `AC_ID_wasCast`,
            `EV_in_AC_wasCast_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `EV_in_AC_wasCast_ID` ORDER BY `EV_in_AC_wasCast_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `EV_in_AC_wasCast_ID`,
                `EV_ID_in`,
                `AC_ID_wasCast`,
                `EV_in_AC_wasCast_PositedAt`,
                IF(`EV_in_AC_wasCast_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`EV_in_AC_wasCast`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_ID_in`,
    `AC_ID_wasCast`,
    `EV_in_AC_wasCast_PositedAt`,
    asserted
;
-- AC_part_PR_in_RAT_got_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_part_PR_in_RAT_got_ID` AS `AC_part_PR_in_RAT_got_ID`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit`
GROUP BY
    `AC_part_PR_in_RAT_got_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `RAT_ID_got` AS `RAT_ID_got`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit`
GROUP BY
    `AC_ID_part`,
    `PR_ID_in`,
    `RAT_ID_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in AC_Actor for AC_ID_part',
    TO_JSON_STRING(STRUCT(c.`AC_ID_part` AS `AC_ID_part`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_part`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_part`
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in PR_Program for PR_ID_in',
    TO_JSON_STRING(STRUCT(c.`PR_ID_in` AS `PR_ID_in`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_in`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_in`
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Posit',
    'no row in RAT_Rating for RAT_ID_got',
    TO_JSON_STRING(STRUCT(c.`RAT_ID_got` AS `RAT_ID_got`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Posit` c
LEFT JOIN
    public.`RAT_Rating` p
ON
    p.`RAT_ID` = c.`RAT_ID_got`
WHERE
    p.`RAT_ID` IS NULL
GROUP BY
    c.`RAT_ID_got`
;
-- AC_part_PR_in_RAT_got_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_part_PR_in_RAT_got_ID` AS `AC_part_PR_in_RAT_got_ID`,
        `AC_part_PR_in_RAT_got_PositedAt` AS `AC_part_PR_in_RAT_got_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Annex`
GROUP BY
    `AC_part_PR_in_RAT_got_ID`,
    `AC_part_PR_in_RAT_got_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_part_PR_in_RAT_got_Annex',
    'no row in AC_part_PR_in_RAT_got_Posit for AC_part_PR_in_RAT_got_ID',
    TO_JSON_STRING(STRUCT(c.`AC_part_PR_in_RAT_got_ID` AS `AC_part_PR_in_RAT_got_ID`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got_Annex` c
LEFT JOIN
    public.`AC_part_PR_in_RAT_got_Posit` p
ON
    p.`AC_part_PR_in_RAT_got_ID` = c.`AC_part_PR_in_RAT_got_ID`
WHERE
    p.`AC_part_PR_in_RAT_got_ID` IS NULL
GROUP BY
    c.`AC_part_PR_in_RAT_got_ID`
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_part_PR_in_RAT_got',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`,
        `AC_part_PR_in_RAT_got_PositedAt` AS `AC_part_PR_in_RAT_got_PositedAt`,
        `AC_part_PR_in_RAT_got_Reliability` AS `AC_part_PR_in_RAT_got_Reliability`
    )),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got`
GROUP BY
    `AC_ID_part`,
    `PR_ID_in`,
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    `AC_part_PR_in_RAT_got_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_part_PR_in_RAT_got',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `AC_ID_part` AS `AC_ID_part`,
        `PR_ID_in` AS `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt` AS `AC_part_PR_in_RAT_got_ChangedAt`,
        `AC_part_PR_in_RAT_got_PositedAt` AS `AC_part_PR_in_RAT_got_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_ID_part`,
        `PR_ID_in`,
        `AC_part_PR_in_RAT_got_ChangedAt`,
        `AC_part_PR_in_RAT_got_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_ID_part`,
                `PR_ID_in`,
                `AC_part_PR_in_RAT_got_ChangedAt`
            ORDER BY
                `AC_part_PR_in_RAT_got_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `AC_ID_part`,
            `PR_ID_in`,
            `AC_part_PR_in_RAT_got_ChangedAt`,
            `AC_part_PR_in_RAT_got_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_part_PR_in_RAT_got_ID` ORDER BY `AC_part_PR_in_RAT_got_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `AC_part_PR_in_RAT_got_ID`,
                `AC_ID_part`,
                `PR_ID_in`,
                `AC_part_PR_in_RAT_got_ChangedAt`,
                `AC_part_PR_in_RAT_got_PositedAt`,
                IF(`AC_part_PR_in_RAT_got_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`AC_part_PR_in_RAT_got`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_ID_part`,
    `PR_ID_in`,
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_part_PR_in_RAT_got_PositedAt`,
    asserted
;
-- ST_at_PR_isPlaying_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`ST_at_PR_isPlaying_ID` AS `ST_at_PR_isPlaying_ID`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit`
GROUP BY
    `ST_at_PR_isPlaying_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`
    )),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit`
GROUP BY
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in ST_Stage for ST_ID_at',
    TO_JSON_STRING(STRUCT(c.`ST_ID_at` AS `ST_ID_at`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_at`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_at`
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Posit',
    'no row in PR_Program for PR_ID_isPlaying',
    TO_JSON_STRING(STRUCT(c.`PR_ID_isPlaying` AS `PR_ID_isPlaying`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_isPlaying`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_isPlaying`
;
-- ST_at_PR_isPlaying_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'ST_at_PR_isPlaying_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `ST_at_PR_isPlaying_ID` AS `ST_at_PR_isPlaying_ID`,
        `ST_at_PR_isPlaying_PositedAt` AS `ST_at_PR_isPlaying_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Annex`
GROUP BY
    `ST_at_PR_isPlaying_ID`,
    `ST_at_PR_isPlaying_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'ST_at_PR_isPlaying_Annex',
    'no row in ST_at_PR_isPlaying_Posit for ST_at_PR_isPlaying_ID',
    TO_JSON_STRING(STRUCT(c.`ST_at_PR_isPlaying_ID` AS `ST_at_PR_isPlaying_ID`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying_Annex` c
LEFT JOIN
    public.`ST_at_PR_isPlaying_Posit` p
ON
    p.`ST_at_PR_isPlaying_ID` = c.`ST_at_PR_isPlaying_ID`
WHERE
    p.`ST_at_PR_isPlaying_ID` IS NULL
GROUP BY
    c.`ST_at_PR_isPlaying_ID`
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'ST_at_PR_isPlaying',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`,
        `ST_at_PR_isPlaying_PositedAt` AS `ST_at_PR_isPlaying_PositedAt`
    )),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying`
GROUP BY
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`,
    `ST_at_PR_isPlaying_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'ST_at_PR_isPlaying',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `ST_ID_at` AS `ST_ID_at`,
        `PR_ID_isPlaying` AS `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt` AS `ST_at_PR_isPlaying_ChangedAt`,
        `ST_at_PR_isPlaying_PositedAt` AS `ST_at_PR_isPlaying_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `ST_ID_at`,
        `PR_ID_isPlaying`,
        `ST_at_PR_isPlaying_ChangedAt`,
        `ST_at_PR_isPlaying_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `ST_ID_at`,
                `PR_ID_isPlaying`,
                `ST_at_PR_isPlaying_ChangedAt`
            ORDER BY
                `ST_at_PR_isPlaying_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `ST_ID_at`,
            `PR_ID_isPlaying`,
            `ST_at_PR_isPlaying_ChangedAt`,
            `ST_at_PR_isPlaying_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `ST_at_PR_isPlaying_ID` ORDER BY `ST_at_PR_isPlaying_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `ST_at_PR_isPlaying_ID`,
                `ST_ID_at`,
                `PR_ID_isPlaying`,
                `ST_at_PR_isPlaying_ChangedAt`,
                `ST_at_PR_isPlaying_PositedAt`,
                IF(`ST_at_PR_isPlaying_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`ST_at_PR_isPlaying`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `ST_ID_at`,
    `PR_ID_isPlaying`,
    `ST_at_PR_isPlaying_ChangedAt`,
    `ST_at_PR_isPlaying_PositedAt`,
    asserted
;
-- AC_parent_AC_child_PAT_having_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`AC_parent_AC_child_PAT_having_ID` AS `AC_parent_AC_child_PAT_having_ID`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit`
GROUP BY
    `AC_parent_AC_child_PAT_having_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`
    )),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit`
GROUP BY
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_parent',
    TO_JSON_STRING(STRUCT(c.`AC_ID_parent` AS `AC_ID_parent`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_parent`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_parent`
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in AC_Actor for AC_ID_child',
    TO_JSON_STRING(STRUCT(c.`AC_ID_child` AS `AC_ID_child`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_child`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_child`
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Posit',
    'no row in PAT_ParentalType for PAT_ID_having',
    TO_JSON_STRING(STRUCT(c.`PAT_ID_having` AS `PAT_ID_having`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` c
LEFT JOIN
    public.`PAT_ParentalType` p
ON
    p.`PAT_ID` = c.`PAT_ID_having`
WHERE
    p.`PAT_ID` IS NULL
GROUP BY
    c.`PAT_ID_having`
;
-- AC_parent_AC_child_PAT_having_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `AC_parent_AC_child_PAT_having_ID` AS `AC_parent_AC_child_PAT_having_ID`,
        `AC_parent_AC_child_PAT_having_PositedAt` AS `AC_parent_AC_child_PAT_having_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Annex`
GROUP BY
    `AC_parent_AC_child_PAT_having_ID`,
    `AC_parent_AC_child_PAT_having_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'AC_parent_AC_child_PAT_having_Annex',
    'no row in AC_parent_AC_child_PAT_having_Posit for AC_parent_AC_child_PAT_having_ID',
    TO_JSON_STRING(STRUCT(c.`AC_parent_AC_child_PAT_having_ID` AS `AC_parent_AC_child_PAT_having_ID`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having_Annex` c
LEFT JOIN
    public.`AC_parent_AC_child_PAT_having_Posit` p
ON
    p.`AC_parent_AC_child_PAT_having_ID` = c.`AC_parent_AC_child_PAT_having_ID`
WHERE
    p.`AC_parent_AC_child_PAT_having_ID` IS NULL
GROUP BY
    c.`AC_parent_AC_child_PAT_having_ID`
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'AC_parent_AC_child_PAT_having',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`,
        `AC_parent_AC_child_PAT_having_PositedAt` AS `AC_parent_AC_child_PAT_having_PositedAt`
    )),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having`
GROUP BY
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`,
    `AC_parent_AC_child_PAT_having_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'AC_parent_AC_child_PAT_having',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `AC_ID_parent` AS `AC_ID_parent`,
        `AC_ID_child` AS `AC_ID_child`,
        `PAT_ID_having` AS `PAT_ID_having`,
        `AC_parent_AC_child_PAT_having_PositedAt` AS `AC_parent_AC_child_PAT_having_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `AC_ID_parent`,
        `AC_ID_child`,
        `PAT_ID_having`,
        `AC_parent_AC_child_PAT_having_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `AC_ID_parent`,
                `AC_ID_child`,
                `PAT_ID_having`
            ORDER BY
                `AC_parent_AC_child_PAT_having_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `AC_ID_parent`,
            `AC_ID_child`,
            `PAT_ID_having`,
            `AC_parent_AC_child_PAT_having_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `AC_parent_AC_child_PAT_having_ID` ORDER BY `AC_parent_AC_child_PAT_having_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `AC_parent_AC_child_PAT_having_ID`,
                `AC_ID_parent`,
                `AC_ID_child`,
                `PAT_ID_having`,
                `AC_parent_AC_child_PAT_having_PositedAt`,
                IF(`AC_parent_AC_child_PAT_having_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`AC_parent_AC_child_PAT_having`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `AC_ID_parent`,
    `AC_ID_child`,
    `PAT_ID_having`,
    `AC_parent_AC_child_PAT_having_PositedAt`,
    asserted
;
-- PR_content_ST_location_EV_of_Posit integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of_Posit` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(`PR_content_ST_location_EV_of_ID` AS `PR_content_ST_location_EV_of_ID`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit`
GROUP BY
    `PR_content_ST_location_EV_of_ID`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'duplicate unique key',
    TO_JSON_STRING(STRUCT(
        `PR_ID_content` AS `PR_ID_content`,
        `ST_ID_location` AS `ST_ID_location`,
        `EV_ID_of` AS `EV_ID_of`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit`
GROUP BY
    `PR_ID_content`,
    `ST_ID_location`,
    `EV_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in PR_Program for PR_ID_content',
    TO_JSON_STRING(STRUCT(c.`PR_ID_content` AS `PR_ID_content`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_content`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_content`
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in ST_Stage for ST_ID_location',
    TO_JSON_STRING(STRUCT(c.`ST_ID_location` AS `ST_ID_location`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_ID_location`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_ID_location`
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Posit',
    'no row in EV_Event for EV_ID_of',
    TO_JSON_STRING(STRUCT(c.`EV_ID_of` AS `EV_ID_of`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Posit` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_ID_of`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_ID_of`
;
-- PR_content_ST_location_EV_of_Annex integrity ----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of_Annex` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'duplicate primary key',
    TO_JSON_STRING(STRUCT(
        `PR_content_ST_location_EV_of_ID` AS `PR_content_ST_location_EV_of_ID`,
        `PR_content_ST_location_EV_of_PositedAt` AS `PR_content_ST_location_EV_of_PositedAt`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Annex`
GROUP BY
    `PR_content_ST_location_EV_of_ID`,
    `PR_content_ST_location_EV_of_PositedAt`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of_Annex',
    'no row in PR_content_ST_location_EV_of_Posit for PR_content_ST_location_EV_of_ID',
    TO_JSON_STRING(STRUCT(c.`PR_content_ST_location_EV_of_ID` AS `PR_content_ST_location_EV_of_ID`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of_Annex` c
LEFT JOIN
    public.`PR_content_ST_location_EV_of_Posit` p
ON
    p.`PR_content_ST_location_EV_of_ID` = c.`PR_content_ST_location_EV_of_ID`
WHERE
    p.`PR_content_ST_location_EV_of_ID` IS NULL
GROUP BY
    c.`PR_content_ST_location_EV_of_ID`
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
-- What the posit and the annex say together, which no key can hold in BigQuery.
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of` (
    Construct,
    Violation,
    ViolationKey,
    Occurrences
)
AS
-- entity integrity, the unique key that the assembled view has in SQL Server
SELECT
    'PR_content_ST_location_EV_of',
    'temporal duplicate',
    TO_JSON_STRING(STRUCT(
        `EV_ID_of` AS `EV_ID_of`,
        `PR_content_ST_location_EV_of_PositedAt` AS `PR_content_ST_location_EV_of_PositedAt`,
        `PR_content_ST_location_EV_of_Reliability` AS `PR_content_ST_location_EV_of_Reliability`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of`
GROUP BY
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_PositedAt`,
    `PR_content_ST_location_EV_of_Reliability`
HAVING
    COUNT(*) > 1
UNION ALL
-- what is asserted at one time for the same identifiers (all the roles, if there are none) and changing time: a posit is
-- asserted from its annex row until the next annex row of its own, so what is asserted at a positing time is the running
-- sum of the changes up to it
SELECT
    'PR_content_ST_location_EV_of',
    'more than one posit asserted at a time',
    TO_JSON_STRING(STRUCT(
        `EV_ID_of` AS `EV_ID_of`,
        `PR_content_ST_location_EV_of_PositedAt` AS `PR_content_ST_location_EV_of_PositedAt`
    )),
    asserted
FROM (
    SELECT
        `EV_ID_of`,
        `PR_content_ST_location_EV_of_PositedAt`,
        SUM(asserted_change) OVER (
            PARTITION BY
                `EV_ID_of`
            ORDER BY
                `PR_content_ST_location_EV_of_PositedAt`
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS asserted
    FROM (
        SELECT
            `EV_ID_of`,
            `PR_content_ST_location_EV_of_PositedAt`,
            is_asserted - COALESCE(LAG(is_asserted) OVER (
                PARTITION BY `PR_content_ST_location_EV_of_ID` ORDER BY `PR_content_ST_location_EV_of_PositedAt`
            ), 0) AS asserted_change
        FROM (
            SELECT
                `PR_content_ST_location_EV_of_ID`,
                `EV_ID_of`,
                `PR_content_ST_location_EV_of_PositedAt`,
                IF(`PR_content_ST_location_EV_of_Reliability` = 1, 1, 0) AS is_asserted
            FROM
                public.`PR_content_ST_location_EV_of`
        )
    )
)
WHERE
    asserted > 1
GROUP BY
    `EV_ID_of`,
    `PR_content_ST_location_EV_of_PositedAt`,
    asserted
;
-- IntegrityViolations ------------------------------------------------------------------------------------------------
-- Every integrity check of the model, in one view.
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.IntegrityViolations (
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
UNION ALL SELECT * FROM public.`ic_PAT_ParentalType`
UNION ALL SELECT * FROM public.`ic_GEN_Gender`
UNION ALL SELECT * FROM public.`ic_PLV_ProfessionalLevel`
UNION ALL SELECT * FROM public.`ic_UTL_Utilization`
UNION ALL SELECT * FROM public.`ic_ONG_Ongoing`
UNION ALL SELECT * FROM public.`ic_RAT_Rating`
UNION ALL SELECT * FROM public.`ic_ETY_EventType`
UNION ALL SELECT * FROM public.`ic_PN_Person`
UNION ALL SELECT * FROM public.`ic_ST_Stage`
UNION ALL SELECT * FROM public.`ic_AC_Actor`
UNION ALL SELECT * FROM public.`ic_PR_Program`
UNION ALL SELECT * FROM public.`ic_EV_Event`
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date_Posit`
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date_Annex`
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience_Posit`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience_Annex`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue_Posit`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue_Annex`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name_Posit`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name_Annex`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location_Posit`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location_Annex`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average_Posit`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average_Annex`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum_Posit`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum_Annex`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name_Posit`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name_Annex`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender_Posit`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender_Annex`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel_Posit`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel_Annex`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name_Posit`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name_Annex`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length_Posit`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length_Annex`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently_Posit`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently_Annex`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of_Posit`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of_Annex`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast_Posit`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast_Annex`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got_Posit`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got_Annex`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying_Posit`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying_Annex`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having_Posit`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having_Annex`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having`
UNION ALL SELECT * FROM public.`ic_PR_content_ST_location_EV_of_Posit`
UNION ALL SELECT * FROM public.`ic_PR_content_ST_location_EV_of_Annex`
UNION ALL SELECT * FROM public.`ic_PR_content_ST_location_EV_of`
UNION ALL SELECT * FROM public.`ic_key_PN_Person_1st`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_1st`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_2nd`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_3rd`
UNION ALL SELECT * FROM public.`ic_key_ST_Stage_4th`
UNION ALL SELECT * FROM public.`ic_key_AC_Actor_1st`
UNION ALL SELECT * FROM public.`ic_key_AC_Actor_2nd`
UNION ALL SELECT * FROM public.`ic_key_AC_Actor_3rd`
UNION ALL SELECT * FROM public.`ic_key_PR_Program_1st`
UNION ALL SELECT * FROM public.`ic_key_PR_Program_2nd`
UNION ALL SELECT * FROM public.`ic_key_EV_Event_1st`
UNION ALL SELECT * FROM public.`ic_key_EV_Event_2nd`
UNION ALL SELECT * FROM public.`ic_key_EV_Event_3rd`
;-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
ALTER SCHEMA public SET OPTIONS(description='Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.');
ALTER TABLE public.`PAT_ParentalType` SET OPTIONS(description='Kind of parent-child relationship between two actors, such as biological or adoptive parent.');
ALTER TABLE public.`PAT_ParentalType` ALTER COLUMN `PAT_ParentalType` SET OPTIONS(description='Kind of parent-child relationship between two actors, such as biological or adoptive parent.');
ALTER TABLE public.`GEN_Gender` SET OPTIONS(description='Gender of an actor.');
ALTER TABLE public.`GEN_Gender` ALTER COLUMN `GEN_Gender` SET OPTIONS(description='Gender of an actor.');
ALTER TABLE public.`PLV_ProfessionalLevel` SET OPTIONS(description='Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.');
ALTER TABLE public.`PLV_ProfessionalLevel` ALTER COLUMN `PLV_ProfessionalLevel` SET OPTIONS(description='Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.');
ALTER TABLE public.`UTL_Utilization` SET OPTIONS(description='Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.');
ALTER TABLE public.`UTL_Utilization` ALTER COLUMN `UTL_Utilization` SET OPTIONS(description='Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.');
ALTER TABLE public.`ONG_Ongoing` SET OPTIONS(description='Yes or No flag indicating whether a relationship is still ongoing or has ended.');
ALTER TABLE public.`ONG_Ongoing` ALTER COLUMN `ONG_Ongoing` SET OPTIONS(description='Yes or No flag indicating whether a relationship is still ongoing or has ended.');
ALTER TABLE public.`RAT_Rating` SET OPTIONS(description='Rating of how well an actor performs a part in a program, such as good, mediocre or bad.');
ALTER TABLE public.`RAT_Rating` ALTER COLUMN `RAT_Rating` SET OPTIONS(description='Rating of how well an actor performs a part in a program, such as good, mediocre or bad.');
ALTER TABLE public.`ETY_EventType` SET OPTIONS(description='Type of event, such as premiere, regular performance, rehearsal or gala.');
ALTER TABLE public.`ETY_EventType` ALTER COLUMN `ETY_EventType` SET OPTIONS(description='Type of event, such as premiere, regular performance, rehearsal or gala.');
ALTER TABLE public.`EV_DAT_Event_Date_Posit` ALTER COLUMN `EV_DAT_Event_Date` SET OPTIONS(description='Date and time when the event took place.');
ALTER TABLE public.`EV_AUD_Event_Audience_Posit` ALTER COLUMN `EV_AUD_Event_Audience` SET OPTIONS(description='Number of people in the audience at the event.');
ALTER TABLE public.`EV_REV_Event_Revenue_Posit` ALTER COLUMN `EV_REV_Event_Revenue` SET OPTIONS(description='Revenue from ticket sales for the event.');
ALTER TABLE public.`ST_NAM_Stage_Name_Posit` ALTER COLUMN `ST_NAM_Stage_Name` SET OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.');
ALTER TABLE public.`ST_LOC_Stage_Location_Posit` ALTER COLUMN `ST_LOC_Stage_Location` SET OPTIONS(description='Geographic location of the stage as a geography point.');
ALTER TABLE public.`ST_AVG_Stage_Average_Posit` ALTER COLUMN `ST_AVG_UTL_ID` SET OPTIONS(description='Average utilization of the stage capacity, recalculated over time.');
ALTER TABLE public.`ST_MIN_Stage_Minimum_Posit` ALTER COLUMN `ST_MIN_UTL_ID` SET OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.');
ALTER TABLE public.`AC_NAM_Actor_Name_Posit` ALTER COLUMN `AC_NAM_Actor_Name` SET OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.');
ALTER TABLE public.`AC_GEN_Actor_Gender_Posit` ALTER COLUMN `AC_GEN_GEN_ID` SET OPTIONS(description='Gender of the actor.');
ALTER TABLE public.`AC_PLV_Actor_ProfessionalLevel_Posit` ALTER COLUMN `AC_PLV_PLV_ID` SET OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.');
ALTER TABLE public.`PR_NAM_Program_Name_Posit` ALTER COLUMN `PR_NAM_Program_Name` SET OPTIONS(description='Name or title of the program.');
ALTER TABLE public.`PR_LEN_Program_Length_Posit` ALTER COLUMN `PR_LEN_Program_Length` SET OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.');
ALTER TABLE public.`PN_Person` SET OPTIONS(description='A person. Persons who perform are also registered as actors.');
ALTER TABLE public.`ST_Stage` SET OPTIONS(description='A stage or venue where programs are played and events are held.');
ALTER TABLE public.`AC_Actor` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE public.`PR_Program` SET OPTIONS(description='A program, such as a play, show or concert, that can be played on stages.');
ALTER TABLE public.`EV_Event` SET OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.');
ALTER TABLE public.`EV_Event` ALTER COLUMN `ST_ID_wasHeldAt` SET OPTIONS(description='The stage at which the event was held.');
ALTER TABLE public.`EV_Event` ALTER COLUMN `PR_ID_wasPlayed` SET OPTIONS(description='The program that was played at the event.');
ALTER TABLE public.`EV_Event` ALTER COLUMN `ETY_ID_of` SET OPTIONS(description='The type of the event.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently_Posit` SET OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently_Posit` ALTER COLUMN `AC_ID_partner` SET OPTIONS(description='One of the actors in the partnership.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently_Posit` ALTER COLUMN `AC_ID_with` SET OPTIONS(description='The other actor in the partnership.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently_Posit` ALTER COLUMN `ONG_ID_currently` SET OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).');
ALTER TABLE public.`AC_subset_PN_of_Posit` SET OPTIONS(description='Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.');
ALTER TABLE public.`AC_subset_PN_of_Posit` ALTER COLUMN `AC_ID_subset` SET OPTIONS(description='The actor.');
ALTER TABLE public.`AC_subset_PN_of_Posit` ALTER COLUMN `PN_ID_of` SET OPTIONS(description='The person who is the actor.');
ALTER TABLE public.`EV_in_AC_wasCast_Posit` SET OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.');
ALTER TABLE public.`EV_in_AC_wasCast_Posit` ALTER COLUMN `EV_ID_in` SET OPTIONS(description='The event the actor was cast in.');
ALTER TABLE public.`EV_in_AC_wasCast_Posit` ALTER COLUMN `AC_ID_wasCast` SET OPTIONS(description='An actor cast in the event.');
ALTER TABLE public.`AC_part_PR_in_RAT_got_Posit` SET OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.');
ALTER TABLE public.`AC_part_PR_in_RAT_got_Posit` ALTER COLUMN `AC_ID_part` SET OPTIONS(description='The actor having a part in the program.');
ALTER TABLE public.`AC_part_PR_in_RAT_got_Posit` ALTER COLUMN `PR_ID_in` SET OPTIONS(description='The program the actor has a part in.');
ALTER TABLE public.`AC_part_PR_in_RAT_got_Posit` ALTER COLUMN `RAT_ID_got` SET OPTIONS(description='The rating the actor got for the part.');
ALTER TABLE public.`ST_at_PR_isPlaying_Posit` SET OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.');
ALTER TABLE public.`ST_at_PR_isPlaying_Posit` ALTER COLUMN `ST_ID_at` SET OPTIONS(description='The stage where the program is playing.');
ALTER TABLE public.`ST_at_PR_isPlaying_Posit` ALTER COLUMN `PR_ID_isPlaying` SET OPTIONS(description='The program playing at the stage.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having_Posit` SET OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having_Posit` ALTER COLUMN `AC_ID_parent` SET OPTIONS(description='The actor who is the parent.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having_Posit` ALTER COLUMN `AC_ID_child` SET OPTIONS(description='The actor who is the child.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having_Posit` ALTER COLUMN `PAT_ID_having` SET OPTIONS(description='The type of parental relationship.');
ALTER TABLE public.`PR_content_ST_location_EV_of_Posit` SET OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.');
ALTER TABLE public.`PR_content_ST_location_EV_of_Posit` ALTER COLUMN `PR_ID_content` SET OPTIONS(description='The program that made up the content of the event.');
ALTER TABLE public.`PR_content_ST_location_EV_of_Posit` ALTER COLUMN `ST_ID_location` SET OPTIONS(description='The stage where the event was located.');
ALTER TABLE public.`PR_content_ST_location_EV_of_Posit` ALTER COLUMN `EV_ID_of` SET OPTIONS(description='The event.');
