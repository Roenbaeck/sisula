-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS public;
-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`_Positor` (
    `Positor` int64 not null,
    PRIMARY KEY (
        `Positor`
    ) NOT ENFORCED
);
MERGE INTO public.`_Positor` p
USING ( SELECT 0 AS _defaultPositor ) d
ON (
    d._defaultPositor = p.`Positor`
)
WHEN NOT MATCHED THEN
INSERT (
    `Positor`
)
VALUES (
    d._defaultPositor
);
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
-- CRT attributes use posit and annex split with changing/positing time, positor, reliability and assertion (the assertion, +, ? or -, is not stored: it is computed from the reliability where an annex is read).
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
    `EV_DAT_Positor` int64 not null,
    `EV_DAT_Reliability` numeric(5,2) not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_ID`,
        `EV_DAT_Positor`,
        `EV_DAT_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date_Annex` FOREIGN KEY (`EV_DAT_ID`) REFERENCES
        public.`EV_DAT_Event_Date_Posit`(`EV_DAT_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_ID`, `EV_DAT_Positor`, `EV_DAT_PositedAt`;
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
    `EV_AUD_Positor` int64 not null,
    `EV_AUD_Reliability` numeric(5,2) not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`,
        `EV_AUD_Positor`,
        `EV_AUD_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience_Annex` FOREIGN KEY (`EV_AUD_ID`) REFERENCES
        public.`EV_AUD_Event_Audience_Posit`(`EV_AUD_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_ID`, `EV_AUD_Positor`, `EV_AUD_PositedAt`;
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
    `EV_REV_Positor` int64 not null,
    `EV_REV_Reliability` numeric(5,2) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_ID`,
        `EV_REV_Positor`,
        `EV_REV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue_Annex` FOREIGN KEY (`EV_REV_ID`) REFERENCES
        public.`EV_REV_Event_Revenue_Posit`(`EV_REV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_ID`, `EV_REV_Positor`, `EV_REV_PositedAt`;
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
    `ST_NAM_Positor` int64 not null,
    `ST_NAM_Reliability` numeric(5,2) not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ID`,
        `ST_NAM_Positor`,
        `ST_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name_Annex` FOREIGN KEY (`ST_NAM_ID`) REFERENCES
        public.`ST_NAM_Stage_Name_Posit`(`ST_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ID`, `ST_NAM_Positor`, `ST_NAM_PositedAt`;
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
    `ST_LOC_Positor` int64 not null,
    `ST_LOC_Reliability` numeric(5,2) not null,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ID`,
        `ST_LOC_Positor`,
        `ST_LOC_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location_Annex` FOREIGN KEY (`ST_LOC_ID`) REFERENCES
        public.`ST_LOC_Stage_Location_Posit`(`ST_LOC_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ID`, `ST_LOC_Positor`, `ST_LOC_PositedAt`;
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
    `ST_AVG_Positor` int64 not null,
    `ST_AVG_Reliability` numeric(5,2) not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ID`,
        `ST_AVG_Positor`,
        `ST_AVG_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_AVG_Stage_Average_Annex` FOREIGN KEY (`ST_AVG_ID`) REFERENCES
        public.`ST_AVG_Stage_Average_Posit`(`ST_AVG_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ID`, `ST_AVG_Positor`, `ST_AVG_PositedAt`;
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
    `ST_MIN_Positor` int64 not null,
    `ST_MIN_Reliability` numeric(5,2) not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`,
        `ST_MIN_Positor`,
        `ST_MIN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_MIN_Stage_Minimum_Annex` FOREIGN KEY (`ST_MIN_ID`) REFERENCES
        public.`ST_MIN_Stage_Minimum_Posit`(`ST_MIN_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ID`, `ST_MIN_Positor`, `ST_MIN_PositedAt`;
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
    `AC_NAM_Positor` int64 not null,
    `AC_NAM_Reliability` numeric(5,2) not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_ID`,
        `AC_NAM_Positor`,
        `AC_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name_Annex` FOREIGN KEY (`AC_NAM_ID`) REFERENCES
        public.`AC_NAM_Actor_Name_Posit`(`AC_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_ID`, `AC_NAM_Positor`, `AC_NAM_PositedAt`;
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
    `AC_GEN_Positor` int64 not null,
    `AC_GEN_Reliability` numeric(5,2) not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`,
        `AC_GEN_Positor`,
        `AC_GEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_GEN_Actor_Gender_Annex` FOREIGN KEY (`AC_GEN_ID`) REFERENCES
        public.`AC_GEN_Actor_Gender_Posit`(`AC_GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_ID`, `AC_GEN_Positor`, `AC_GEN_PositedAt`;
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
    `AC_PLV_Positor` int64 not null,
    `AC_PLV_Reliability` numeric(5,2) not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_ID`,
        `AC_PLV_Positor`,
        `AC_PLV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_PLV_Actor_ProfessionalLevel_Annex` FOREIGN KEY (`AC_PLV_ID`) REFERENCES
        public.`AC_PLV_Actor_ProfessionalLevel_Posit`(`AC_PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_ID`, `AC_PLV_Positor`, `AC_PLV_PositedAt`;
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
    `PR_NAM_Positor` int64 not null,
    `PR_NAM_Reliability` numeric(5,2) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_ID`,
        `PR_NAM_Positor`,
        `PR_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name_Annex` FOREIGN KEY (`PR_NAM_ID`) REFERENCES
        public.`PR_NAM_Program_Name_Posit`(`PR_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_ID`, `PR_NAM_Positor`, `PR_NAM_PositedAt`;
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
    `PR_LEN_Positor` int64 not null,
    `PR_LEN_Reliability` numeric(5,2) not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_ID`,
        `PR_LEN_Positor`,
        `PR_LEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length_Annex` FOREIGN KEY (`PR_LEN_ID`) REFERENCES
        public.`PR_LEN_Program_Length_Posit`(`PR_LEN_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_ID`, `PR_LEN_Positor`, `PR_LEN_PositedAt`;
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
    a.`EV_DAT_Positor`,
    a.`EV_DAT_Reliability`,
    CASE
        WHEN a.`EV_DAT_Reliability` > 0 THEN '+'
        WHEN a.`EV_DAT_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_DAT_Assertion`
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
    a.`EV_AUD_Positor`,
    a.`EV_AUD_Reliability`,
    CASE
        WHEN a.`EV_AUD_Reliability` > 0 THEN '+'
        WHEN a.`EV_AUD_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_AUD_Assertion`
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
    a.`EV_REV_Positor`,
    a.`EV_REV_Reliability`,
    CASE
        WHEN a.`EV_REV_Reliability` > 0 THEN '+'
        WHEN a.`EV_REV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_REV_Assertion`
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
    a.`ST_NAM_Positor`,
    a.`ST_NAM_Reliability`,
    CASE
        WHEN a.`ST_NAM_Reliability` > 0 THEN '+'
        WHEN a.`ST_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_NAM_Assertion`
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
    a.`ST_LOC_Positor`,
    a.`ST_LOC_Reliability`,
    CASE
        WHEN a.`ST_LOC_Reliability` > 0 THEN '+'
        WHEN a.`ST_LOC_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_LOC_Assertion`
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
    a.`ST_AVG_Positor`,
    a.`ST_AVG_Reliability`,
    CASE
        WHEN a.`ST_AVG_Reliability` > 0 THEN '+'
        WHEN a.`ST_AVG_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_AVG_Assertion`
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
    a.`ST_MIN_Positor`,
    a.`ST_MIN_Reliability`,
    CASE
        WHEN a.`ST_MIN_Reliability` > 0 THEN '+'
        WHEN a.`ST_MIN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_MIN_Assertion`
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
    a.`AC_NAM_Positor`,
    a.`AC_NAM_Reliability`,
    CASE
        WHEN a.`AC_NAM_Reliability` > 0 THEN '+'
        WHEN a.`AC_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_NAM_Assertion`
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
    a.`AC_GEN_Positor`,
    a.`AC_GEN_Reliability`,
    CASE
        WHEN a.`AC_GEN_Reliability` > 0 THEN '+'
        WHEN a.`AC_GEN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_GEN_Assertion`
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
    a.`AC_PLV_Positor`,
    a.`AC_PLV_Reliability`,
    CASE
        WHEN a.`AC_PLV_Reliability` > 0 THEN '+'
        WHEN a.`AC_PLV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_PLV_Assertion`
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
    a.`PR_NAM_Positor`,
    a.`PR_NAM_Reliability`,
    CASE
        WHEN a.`PR_NAM_Reliability` > 0 THEN '+'
        WHEN a.`PR_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_NAM_Assertion`
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
    a.`PR_LEN_Positor`,
    a.`PR_LEN_Reliability`,
    CASE
        WHEN a.`PR_LEN_Reliability` > 0 THEN '+'
        WHEN a.`PR_LEN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_LEN_Assertion`
FROM
    public.`PR_LEN_Program_Length_Posit` p
JOIN
    public.`PR_LEN_Program_Length_Annex` a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the 
-- union of the two will produce all rows in a posit table.
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rEV_DAT_Event_Date_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_DAT`,
    `EV_DAT_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Positor`,
    `EV_DAT_Reliability`,
    CASE
        WHEN `EV_DAT_Reliability` > 0 THEN '+'
        WHEN `EV_DAT_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_DAT_Assertion`
FROM
    public.`EV_DAT_Event_Date_Annex`
WHERE
    `EV_DAT_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rEV_DAT_Event_Date` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Positor`,
    a.`EV_DAT_Reliability`,
    CASE
        WHEN a.`EV_DAT_Reliability` > 0 THEN '+'
        WHEN a.`EV_DAT_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_DAT_Assertion`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Event_Date`
FROM
    public.`EV_DAT_Event_Date_Posit` p
JOIN
    public.`rEV_DAT_Event_Date_Annex`(positingTimepoint) a
ON
    a.`EV_DAT_ID` = p.`EV_DAT_ID`
AND
    a.`EV_DAT_Positor` = coalesce(positor, a.`EV_DAT_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_DAT_ID`, a.`EV_DAT_Positor`
        ORDER BY a.`EV_DAT_PositedAt` DESC
    ) = 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rEV_AUD_Event_Audience_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_AUD`,
    `EV_AUD_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Positor`,
    `EV_AUD_Reliability`,
    CASE
        WHEN `EV_AUD_Reliability` > 0 THEN '+'
        WHEN `EV_AUD_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_AUD_Assertion`
FROM
    public.`EV_AUD_Event_Audience_Annex`
WHERE
    `EV_AUD_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rEV_AUD_Event_Audience` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Positor`,
    a.`EV_AUD_Reliability`,
    CASE
        WHEN a.`EV_AUD_Reliability` > 0 THEN '+'
        WHEN a.`EV_AUD_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_AUD_Assertion`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Event_Audience`
FROM
    public.`EV_AUD_Event_Audience_Posit` p
JOIN
    public.`rEV_AUD_Event_Audience_Annex`(positingTimepoint) a
ON
    a.`EV_AUD_ID` = p.`EV_AUD_ID`
AND
    a.`EV_AUD_Positor` = coalesce(positor, a.`EV_AUD_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_AUD_ID`, a.`EV_AUD_Positor`
        ORDER BY a.`EV_AUD_PositedAt` DESC
    ) = 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rEV_REV_Event_Revenue_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_REV`,
    `EV_REV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Positor`,
    `EV_REV_Reliability`,
    CASE
        WHEN `EV_REV_Reliability` > 0 THEN '+'
        WHEN `EV_REV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_REV_Assertion`
FROM
    public.`EV_REV_Event_Revenue_Annex`
WHERE
    `EV_REV_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rEV_REV_Event_Revenue` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Positor`,
    a.`EV_REV_Reliability`,
    CASE
        WHEN a.`EV_REV_Reliability` > 0 THEN '+'
        WHEN a.`EV_REV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_REV_Assertion`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Event_Revenue`
FROM
    public.`EV_REV_Event_Revenue_Posit` p
JOIN
    public.`rEV_REV_Event_Revenue_Annex`(positingTimepoint) a
ON
    a.`EV_REV_ID` = p.`EV_REV_ID`
AND
    a.`EV_REV_Positor` = coalesce(positor, a.`EV_REV_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_REV_ID`, a.`EV_REV_Positor`
        ORDER BY a.`EV_REV_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_NAM`,
    `ST_NAM_ID`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Positor`,
    `ST_NAM_Reliability`,
    CASE
        WHEN `ST_NAM_Reliability` > 0 THEN '+'
        WHEN `ST_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_NAM_Assertion`
FROM
    public.`ST_NAM_Stage_Name_Annex`
WHERE
    `ST_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Positor`,
    a.`ST_NAM_Reliability`,
    CASE
        WHEN a.`ST_NAM_Reliability` > 0 THEN '+'
        WHEN a.`ST_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_NAM_Assertion`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    public.`rST_NAM_Stage_Name_Posit`(changingTimepoint) p
JOIN
    public.`rST_NAM_Stage_Name_Annex`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
AND
    a.`ST_NAM_Positor` = coalesce(positor, a.`ST_NAM_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`, a.`ST_NAM_Positor`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`fST_NAM_Stage_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    a.`ST_NAM_PositedAt`,
    a.`ST_NAM_Positor`,
    a.`ST_NAM_Reliability`,
    CASE
        WHEN a.`ST_NAM_Reliability` > 0 THEN '+'
        WHEN a.`ST_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_NAM_Assertion`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Stage_Name`,
    p.`ST_NAM_ChangedAt`
FROM
    public.`fST_NAM_Stage_Name_Posit`(changingTimepoint) p
JOIN
    public.`rST_NAM_Stage_Name_Annex`(positingTimepoint) a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
AND
    a.`ST_NAM_Positor` = coalesce(positor, a.`ST_NAM_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_NAM_ID`, a.`ST_NAM_Positor`
        ORDER BY a.`ST_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`preST_NAM_Stage_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`ST_NAM_Stage_Name`
FROM
    public.`rST_NAM_Stage_Name`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_NAM_ST_ID` = id
AND
    pre.`ST_NAM_ChangedAt` < changingTimepoint
AND
    pre.`ST_NAM_Assertion` = coalesce(assertion, pre.`ST_NAM_Assertion`)
ORDER BY
    pre.`ST_NAM_ChangedAt` DESC,
    pre.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`folST_NAM_Stage_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`ST_NAM_Stage_Name`
FROM
    public.`fST_NAM_Stage_Name`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_NAM_ST_ID` = id
AND
    fol.`ST_NAM_ChangedAt` > changingTimepoint
AND
    fol.`ST_NAM_Assertion` = coalesce(assertion, fol.`ST_NAM_Assertion`)
ORDER BY
    fol.`ST_NAM_ChangedAt` ASC,
    fol.`ST_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_LOC_Stage_Location_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_LOC`,
    `ST_LOC_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Positor`,
    `ST_LOC_Reliability`,
    CASE
        WHEN `ST_LOC_Reliability` > 0 THEN '+'
        WHEN `ST_LOC_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_LOC_Assertion`
FROM
    public.`ST_LOC_Stage_Location_Annex`
WHERE
    `ST_LOC_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_LOC_Stage_Location` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Positor`,
    a.`ST_LOC_Reliability`,
    CASE
        WHEN a.`ST_LOC_Reliability` > 0 THEN '+'
        WHEN a.`ST_LOC_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_LOC_Assertion`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Stage_Location`
FROM
    public.`ST_LOC_Stage_Location_Posit` p
JOIN
    public.`rST_LOC_Stage_Location_Annex`(positingTimepoint) a
ON
    a.`ST_LOC_ID` = p.`ST_LOC_ID`
AND
    a.`ST_LOC_Positor` = coalesce(positor, a.`ST_LOC_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_LOC_ID`, a.`ST_LOC_Positor`
        ORDER BY a.`ST_LOC_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_AVG`,
    `ST_AVG_ID`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Positor`,
    `ST_AVG_Reliability`,
    CASE
        WHEN `ST_AVG_Reliability` > 0 THEN '+'
        WHEN `ST_AVG_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_AVG_Assertion`
FROM
    public.`ST_AVG_Stage_Average_Annex`
WHERE
    `ST_AVG_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Positor`,
    a.`ST_AVG_Reliability`,
    CASE
        WHEN a.`ST_AVG_Reliability` > 0 THEN '+'
        WHEN a.`ST_AVG_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_AVG_Assertion`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    public.`rST_AVG_Stage_Average_Posit`(changingTimepoint) p
JOIN
    public.`rST_AVG_Stage_Average_Annex`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
AND
    a.`ST_AVG_Positor` = coalesce(positor, a.`ST_AVG_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`, a.`ST_AVG_Positor`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`fST_AVG_Stage_Average` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_AVG`,
    p.`ST_AVG_ID`,
    a.`ST_AVG_PositedAt`,
    a.`ST_AVG_Positor`,
    a.`ST_AVG_Reliability`,
    CASE
        WHEN a.`ST_AVG_Reliability` > 0 THEN '+'
        WHEN a.`ST_AVG_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_AVG_Assertion`,
    p.`ST_AVG_ST_ID`,
    p.`ST_AVG_UTL_ID`,
    p.`ST_AVG_ChangedAt`
FROM
    public.`fST_AVG_Stage_Average_Posit`(changingTimepoint) p
JOIN
    public.`rST_AVG_Stage_Average_Annex`(positingTimepoint) a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
AND
    a.`ST_AVG_Positor` = coalesce(positor, a.`ST_AVG_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_AVG_ID`, a.`ST_AVG_Positor`
        ORDER BY a.`ST_AVG_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`preST_AVG_Stage_Average` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`ST_AVG_UTL_ID`
FROM
    public.`rST_AVG_Stage_Average`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`ST_AVG_ST_ID` = id
AND
    pre.`ST_AVG_ChangedAt` < changingTimepoint
AND
    pre.`ST_AVG_Assertion` = coalesce(assertion, pre.`ST_AVG_Assertion`)
ORDER BY
    pre.`ST_AVG_ChangedAt` DESC,
    pre.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`folST_AVG_Stage_Average` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`ST_AVG_UTL_ID`
FROM
    public.`fST_AVG_Stage_Average`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`ST_AVG_ST_ID` = id
AND
    fol.`ST_AVG_ChangedAt` > changingTimepoint
AND
    fol.`ST_AVG_Assertion` = coalesce(assertion, fol.`ST_AVG_Assertion`)
ORDER BY
    fol.`ST_AVG_ChangedAt` ASC,
    fol.`ST_AVG_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_MIN_Stage_Minimum_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_MIN`,
    `ST_MIN_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Positor`,
    `ST_MIN_Reliability`,
    CASE
        WHEN `ST_MIN_Reliability` > 0 THEN '+'
        WHEN `ST_MIN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_MIN_Assertion`
FROM
    public.`ST_MIN_Stage_Minimum_Annex`
WHERE
    `ST_MIN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_MIN_Stage_Minimum` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_MIN`,
    p.`ST_MIN_ID`,
    a.`ST_MIN_PositedAt`,
    a.`ST_MIN_Positor`,
    a.`ST_MIN_Reliability`,
    CASE
        WHEN a.`ST_MIN_Reliability` > 0 THEN '+'
        WHEN a.`ST_MIN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_MIN_Assertion`,
    p.`ST_MIN_ST_ID`,
    p.`ST_MIN_UTL_ID`
FROM
    public.`ST_MIN_Stage_Minimum_Posit` p
JOIN
    public.`rST_MIN_Stage_Minimum_Annex`(positingTimepoint) a
ON
    a.`ST_MIN_ID` = p.`ST_MIN_ID`
AND
    a.`ST_MIN_Positor` = coalesce(positor, a.`ST_MIN_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_MIN_ID`, a.`ST_MIN_Positor`
        ORDER BY a.`ST_MIN_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_NAM`,
    `AC_NAM_ID`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Positor`,
    `AC_NAM_Reliability`,
    CASE
        WHEN `AC_NAM_Reliability` > 0 THEN '+'
        WHEN `AC_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_NAM_Assertion`
FROM
    public.`AC_NAM_Actor_Name_Annex`
WHERE
    `AC_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Positor`,
    a.`AC_NAM_Reliability`,
    CASE
        WHEN a.`AC_NAM_Reliability` > 0 THEN '+'
        WHEN a.`AC_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_NAM_Assertion`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    public.`rAC_NAM_Actor_Name_Posit`(changingTimepoint) p
JOIN
    public.`rAC_NAM_Actor_Name_Annex`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
AND
    a.`AC_NAM_Positor` = coalesce(positor, a.`AC_NAM_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`, a.`AC_NAM_Positor`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`fAC_NAM_Actor_Name` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    a.`AC_NAM_PositedAt`,
    a.`AC_NAM_Positor`,
    a.`AC_NAM_Reliability`,
    CASE
        WHEN a.`AC_NAM_Reliability` > 0 THEN '+'
        WHEN a.`AC_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_NAM_Assertion`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Actor_Name`,
    p.`AC_NAM_ChangedAt`
FROM
    public.`fAC_NAM_Actor_Name_Posit`(changingTimepoint) p
JOIN
    public.`rAC_NAM_Actor_Name_Annex`(positingTimepoint) a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
AND
    a.`AC_NAM_Positor` = coalesce(positor, a.`AC_NAM_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_NAM_ID`, a.`AC_NAM_Positor`
        ORDER BY a.`AC_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`preAC_NAM_Actor_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`AC_NAM_Actor_Name`
FROM
    public.`rAC_NAM_Actor_Name`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_NAM_AC_ID` = id
AND
    pre.`AC_NAM_ChangedAt` < changingTimepoint
AND
    pre.`AC_NAM_Assertion` = coalesce(assertion, pre.`AC_NAM_Assertion`)
ORDER BY
    pre.`AC_NAM_ChangedAt` DESC,
    pre.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`folAC_NAM_Actor_Name` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`AC_NAM_Actor_Name`
FROM
    public.`fAC_NAM_Actor_Name`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_NAM_AC_ID` = id
AND
    fol.`AC_NAM_ChangedAt` > changingTimepoint
AND
    fol.`AC_NAM_Assertion` = coalesce(assertion, fol.`AC_NAM_Assertion`)
ORDER BY
    fol.`AC_NAM_ChangedAt` ASC,
    fol.`AC_NAM_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_GEN_Actor_Gender_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_GEN`,
    `AC_GEN_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Positor`,
    `AC_GEN_Reliability`,
    CASE
        WHEN `AC_GEN_Reliability` > 0 THEN '+'
        WHEN `AC_GEN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_GEN_Assertion`
FROM
    public.`AC_GEN_Actor_Gender_Annex`
WHERE
    `AC_GEN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_GEN_Actor_Gender` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_GEN`,
    p.`AC_GEN_ID`,
    a.`AC_GEN_PositedAt`,
    a.`AC_GEN_Positor`,
    a.`AC_GEN_Reliability`,
    CASE
        WHEN a.`AC_GEN_Reliability` > 0 THEN '+'
        WHEN a.`AC_GEN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_GEN_Assertion`,
    p.`AC_GEN_AC_ID`,
    p.`AC_GEN_GEN_ID`
FROM
    public.`AC_GEN_Actor_Gender_Posit` p
JOIN
    public.`rAC_GEN_Actor_Gender_Annex`(positingTimepoint) a
ON
    a.`AC_GEN_ID` = p.`AC_GEN_ID`
AND
    a.`AC_GEN_Positor` = coalesce(positor, a.`AC_GEN_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_GEN_ID`, a.`AC_GEN_Positor`
        ORDER BY a.`AC_GEN_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_PLV`,
    `AC_PLV_ID`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Positor`,
    `AC_PLV_Reliability`,
    CASE
        WHEN `AC_PLV_Reliability` > 0 THEN '+'
        WHEN `AC_PLV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_PLV_Assertion`
FROM
    public.`AC_PLV_Actor_ProfessionalLevel_Annex`
WHERE
    `AC_PLV_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Positor`,
    a.`AC_PLV_Reliability`,
    CASE
        WHEN a.`AC_PLV_Reliability` > 0 THEN '+'
        WHEN a.`AC_PLV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_PLV_Assertion`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    public.`rAC_PLV_Actor_ProfessionalLevel_Posit`(changingTimepoint) p
JOIN
    public.`rAC_PLV_Actor_ProfessionalLevel_Annex`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
AND
    a.`AC_PLV_Positor` = coalesce(positor, a.`AC_PLV_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`, a.`AC_PLV_Positor`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`fAC_PLV_Actor_ProfessionalLevel` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_PLV`,
    p.`AC_PLV_ID`,
    a.`AC_PLV_PositedAt`,
    a.`AC_PLV_Positor`,
    a.`AC_PLV_Reliability`,
    CASE
        WHEN a.`AC_PLV_Reliability` > 0 THEN '+'
        WHEN a.`AC_PLV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_PLV_Assertion`,
    p.`AC_PLV_AC_ID`,
    p.`AC_PLV_PLV_ID`,
    p.`AC_PLV_ChangedAt`
FROM
    public.`fAC_PLV_Actor_ProfessionalLevel_Posit`(changingTimepoint) p
JOIN
    public.`rAC_PLV_Actor_ProfessionalLevel_Annex`(positingTimepoint) a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
AND
    a.`AC_PLV_Positor` = coalesce(positor, a.`AC_PLV_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_PLV_ID`, a.`AC_PLV_Positor`
        ORDER BY a.`AC_PLV_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`preAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`AC_PLV_PLV_ID`
FROM
    public.`rAC_PLV_Actor_ProfessionalLevel`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`AC_PLV_AC_ID` = id
AND
    pre.`AC_PLV_ChangedAt` < changingTimepoint
AND
    pre.`AC_PLV_Assertion` = coalesce(assertion, pre.`AC_PLV_Assertion`)
ORDER BY
    pre.`AC_PLV_ChangedAt` DESC,
    pre.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`folAC_PLV_Actor_ProfessionalLevel` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`AC_PLV_PLV_ID`
FROM
    public.`fAC_PLV_Actor_ProfessionalLevel`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`AC_PLV_AC_ID` = id
AND
    fol.`AC_PLV_ChangedAt` > changingTimepoint
AND
    fol.`AC_PLV_Assertion` = coalesce(assertion, fol.`AC_PLV_Assertion`)
ORDER BY
    fol.`AC_PLV_ChangedAt` ASC,
    fol.`AC_PLV_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rPR_NAM_Program_Name_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_NAM`,
    `PR_NAM_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Positor`,
    `PR_NAM_Reliability`,
    CASE
        WHEN `PR_NAM_Reliability` > 0 THEN '+'
        WHEN `PR_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_NAM_Assertion`
FROM
    public.`PR_NAM_Program_Name_Annex`
WHERE
    `PR_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rPR_NAM_Program_Name` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Positor`,
    a.`PR_NAM_Reliability`,
    CASE
        WHEN a.`PR_NAM_Reliability` > 0 THEN '+'
        WHEN a.`PR_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_NAM_Assertion`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Program_Name`
FROM
    public.`PR_NAM_Program_Name_Posit` p
JOIN
    public.`rPR_NAM_Program_Name_Annex`(positingTimepoint) a
ON
    a.`PR_NAM_ID` = p.`PR_NAM_ID`
AND
    a.`PR_NAM_Positor` = coalesce(positor, a.`PR_NAM_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_NAM_ID`, a.`PR_NAM_Positor`
        ORDER BY a.`PR_NAM_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_LEN`,
    `PR_LEN_ID`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Positor`,
    `PR_LEN_Reliability`,
    CASE
        WHEN `PR_LEN_Reliability` > 0 THEN '+'
        WHEN `PR_LEN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_LEN_Assertion`
FROM
    public.`PR_LEN_Program_Length_Annex`
WHERE
    `PR_LEN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Positor`,
    a.`PR_LEN_Reliability`,
    CASE
        WHEN a.`PR_LEN_Reliability` > 0 THEN '+'
        WHEN a.`PR_LEN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_LEN_Assertion`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    public.`rPR_LEN_Program_Length_Posit`(changingTimepoint) p
JOIN
    public.`rPR_LEN_Program_Length_Annex`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
AND
    a.`PR_LEN_Positor` = coalesce(positor, a.`PR_LEN_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`, a.`PR_LEN_Positor`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`fPR_LEN_Program_Length` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    a.`PR_LEN_PositedAt`,
    a.`PR_LEN_Positor`,
    a.`PR_LEN_Reliability`,
    CASE
        WHEN a.`PR_LEN_Reliability` > 0 THEN '+'
        WHEN a.`PR_LEN_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_LEN_Assertion`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Program_Length`,
    p.`PR_LEN_ChangedAt`
FROM
    public.`fPR_LEN_Program_Length_Posit`(changingTimepoint) p
JOIN
    public.`rPR_LEN_Program_Length_Annex`(positingTimepoint) a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
AND
    a.`PR_LEN_Positor` = coalesce(positor, a.`PR_LEN_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_LEN_ID`, a.`PR_LEN_Positor`
        ORDER BY a.`PR_LEN_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`prePR_LEN_Program_Length` (
    id int64,
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`PR_LEN_Program_Length`
FROM
    public.`rPR_LEN_Program_Length`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`PR_LEN_PR_ID` = id
AND
    pre.`PR_LEN_ChangedAt` < changingTimepoint
AND
    pre.`PR_LEN_Assertion` = coalesce(assertion, pre.`PR_LEN_Assertion`)
ORDER BY
    pre.`PR_LEN_ChangedAt` DESC,
    pre.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`folPR_LEN_Program_Length` (
    id int64,
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`PR_LEN_Program_Length`
FROM
    public.`fPR_LEN_Program_Length`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`PR_LEN_PR_ID` = id
AND
    fol.`PR_LEN_ChangedAt` > changingTimepoint
AND
    fol.`PR_LEN_Assertion` = coalesce(assertion, fol.`PR_LEN_Assertion`)
ORDER BY
    fol.`PR_LEN_ChangedAt` ASC,
    fol.`PR_LEN_PositedAt` DESC
LIMIT 1
)
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability and assertion (the assertion, +, ? or -, is not stored: it is computed from the reliability where an annex is read).
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
    `AC_partner_AC_with_ONG_currently_Positor` int64 not null,
    `AC_partner_AC_with_ONG_currently_Reliability` numeric(5,2) not null,
    `Metadata_AC_partner_AC_with_ONG_currently` int64 not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`,
        `AC_partner_AC_with_ONG_currently_Positor`,
        `AC_partner_AC_with_ONG_currently_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_partner_AC_with_ONG_currently_Annex` FOREIGN KEY (`AC_partner_AC_with_ONG_currently_ID`) REFERENCES
        public.`AC_partner_AC_with_ONG_currently_Posit`(`AC_partner_AC_with_ONG_currently_ID`) NOT ENFORCED
)
CLUSTER BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_Positor`, `AC_partner_AC_with_ONG_currently_PositedAt`;
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
    `AC_subset_PN_of_Positor` int64 not null,
    `AC_subset_PN_of_Reliability` numeric(5,2) not null,
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_subset_PN_of_ID`,
        `AC_subset_PN_of_Positor`,
        `AC_subset_PN_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_subset_PN_of_Annex` FOREIGN KEY (`AC_subset_PN_of_ID`) REFERENCES
        public.`AC_subset_PN_of_Posit`(`AC_subset_PN_of_ID`) NOT ENFORCED
)
CLUSTER BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_Positor`, `AC_subset_PN_of_PositedAt`;
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
    `EV_in_AC_wasCast_Positor` int64 not null,
    `EV_in_AC_wasCast_Reliability` numeric(5,2) not null,
    `Metadata_EV_in_AC_wasCast` int64 not null,
    PRIMARY KEY (
        `EV_in_AC_wasCast_ID`,
        `EV_in_AC_wasCast_Positor`,
        `EV_in_AC_wasCast_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_in_AC_wasCast_Annex` FOREIGN KEY (`EV_in_AC_wasCast_ID`) REFERENCES
        public.`EV_in_AC_wasCast_Posit`(`EV_in_AC_wasCast_ID`) NOT ENFORCED
)
CLUSTER BY `EV_in_AC_wasCast_ID`, `EV_in_AC_wasCast_Positor`, `EV_in_AC_wasCast_PositedAt`;
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
    `AC_part_PR_in_RAT_got_Positor` int64 not null,
    `AC_part_PR_in_RAT_got_Reliability` numeric(5,2) not null,
    `Metadata_AC_part_PR_in_RAT_got` int64 not null,
    PRIMARY KEY (
        `AC_part_PR_in_RAT_got_ID`,
        `AC_part_PR_in_RAT_got_Positor`,
        `AC_part_PR_in_RAT_got_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_part_PR_in_RAT_got_Annex` FOREIGN KEY (`AC_part_PR_in_RAT_got_ID`) REFERENCES
        public.`AC_part_PR_in_RAT_got_Posit`(`AC_part_PR_in_RAT_got_ID`) NOT ENFORCED
)
CLUSTER BY `AC_part_PR_in_RAT_got_ID`, `AC_part_PR_in_RAT_got_Positor`, `AC_part_PR_in_RAT_got_PositedAt`;
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
    `ST_at_PR_isPlaying_Positor` int64 not null,
    `ST_at_PR_isPlaying_Reliability` numeric(5,2) not null,
    `Metadata_ST_at_PR_isPlaying` int64 not null,
    PRIMARY KEY (
        `ST_at_PR_isPlaying_ID`,
        `ST_at_PR_isPlaying_Positor`,
        `ST_at_PR_isPlaying_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_at_PR_isPlaying_Annex` FOREIGN KEY (`ST_at_PR_isPlaying_ID`) REFERENCES
        public.`ST_at_PR_isPlaying_Posit`(`ST_at_PR_isPlaying_ID`) NOT ENFORCED
)
CLUSTER BY `ST_at_PR_isPlaying_ID`, `ST_at_PR_isPlaying_Positor`, `ST_at_PR_isPlaying_PositedAt`;
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
    `AC_parent_AC_child_PAT_having_Positor` int64 not null,
    `AC_parent_AC_child_PAT_having_Reliability` numeric(5,2) not null,
    `Metadata_AC_parent_AC_child_PAT_having` int64 not null,
    PRIMARY KEY (
        `AC_parent_AC_child_PAT_having_ID`,
        `AC_parent_AC_child_PAT_having_Positor`,
        `AC_parent_AC_child_PAT_having_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_parent_AC_child_PAT_having_Annex` FOREIGN KEY (`AC_parent_AC_child_PAT_having_ID`) REFERENCES
        public.`AC_parent_AC_child_PAT_having_Posit`(`AC_parent_AC_child_PAT_having_ID`) NOT ENFORCED
)
CLUSTER BY `AC_parent_AC_child_PAT_having_ID`, `AC_parent_AC_child_PAT_having_Positor`, `AC_parent_AC_child_PAT_having_PositedAt`;
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
    `PR_content_ST_location_EV_of_Positor` int64 not null,
    `PR_content_ST_location_EV_of_Reliability` numeric(5,2) not null,
    `Metadata_PR_content_ST_location_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_content_ST_location_EV_of_ID`,
        `PR_content_ST_location_EV_of_Positor`,
        `PR_content_ST_location_EV_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_content_ST_location_EV_of_Annex` FOREIGN KEY (`PR_content_ST_location_EV_of_ID`) REFERENCES
        public.`PR_content_ST_location_EV_of_Posit`(`PR_content_ST_location_EV_of_ID`) NOT ENFORCED
)
CLUSTER BY `PR_content_ST_location_EV_of_ID`, `PR_content_ST_location_EV_of_Positor`, `PR_content_ST_location_EV_of_PositedAt`;
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
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
    a.`AC_partner_AC_with_ONG_currently_Positor`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`,
    CASE
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` > 0 THEN '+'
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Assertion`
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
    a.`AC_subset_PN_of_Positor`,
    a.`AC_subset_PN_of_Reliability`,
    CASE
        WHEN a.`AC_subset_PN_of_Reliability` > 0 THEN '+'
        WHEN a.`AC_subset_PN_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Assertion`
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
    a.`EV_in_AC_wasCast_Positor`,
    a.`EV_in_AC_wasCast_Reliability`,
    CASE
        WHEN a.`EV_in_AC_wasCast_Reliability` > 0 THEN '+'
        WHEN a.`EV_in_AC_wasCast_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_wasCast_Assertion`
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
    a.`AC_part_PR_in_RAT_got_Positor`,
    a.`AC_part_PR_in_RAT_got_Reliability`,
    CASE
        WHEN a.`AC_part_PR_in_RAT_got_Reliability` > 0 THEN '+'
        WHEN a.`AC_part_PR_in_RAT_got_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_part_PR_in_RAT_got_Assertion`
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
    a.`ST_at_PR_isPlaying_Positor`,
    a.`ST_at_PR_isPlaying_Reliability`,
    CASE
        WHEN a.`ST_at_PR_isPlaying_Reliability` > 0 THEN '+'
        WHEN a.`ST_at_PR_isPlaying_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_isPlaying_Assertion`
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
    a.`AC_parent_AC_child_PAT_having_Positor`,
    a.`AC_parent_AC_child_PAT_having_Reliability`,
    CASE
        WHEN a.`AC_parent_AC_child_PAT_having_Reliability` > 0 THEN '+'
        WHEN a.`AC_parent_AC_child_PAT_having_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_parent_AC_child_PAT_having_Assertion`
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
    a.`PR_content_ST_location_EV_of_Positor`,
    a.`PR_content_ST_location_EV_of_Reliability`,
    CASE
        WHEN a.`PR_content_ST_location_EV_of_Reliability` > 0 THEN '+'
        WHEN a.`PR_content_ST_location_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_content_ST_location_EV_of_Assertion`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`PR_content_ST_location_EV_of_Annex` a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null.
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
    `AC_partner_AC_with_ONG_currently_Positor`,
    `AC_partner_AC_with_ONG_currently_Reliability`,
    CASE
        WHEN `AC_partner_AC_with_ONG_currently_Reliability` > 0 THEN '+'
        WHEN `AC_partner_AC_with_ONG_currently_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Assertion`
FROM
    public.`AC_partner_AC_with_ONG_currently_Annex`
WHERE
    `AC_partner_AC_with_ONG_currently_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_partner_AC_with_ONG_currently` (
    positor int64,
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
    a.`AC_partner_AC_with_ONG_currently_Positor`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`,
    CASE
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` > 0 THEN '+'
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Assertion`
FROM
    public.`rAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
AND
    a.`AC_partner_AC_with_ONG_currently_Positor` = coalesce(positor, a.`AC_partner_AC_with_ONG_currently_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`, a.`AC_partner_AC_with_ONG_currently_Positor`
        ORDER BY a.`AC_partner_AC_with_ONG_currently_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_partner_AC_with_ONG_currently` (
    positor int64,
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
    a.`AC_partner_AC_with_ONG_currently_Positor`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`,
    CASE
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` > 0 THEN '+'
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Assertion`
FROM
    public.`fAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
ON
    a.`AC_partner_AC_with_ONG_currently_ID` = p.`AC_partner_AC_with_ONG_currently_ID`
AND
    a.`AC_partner_AC_with_ONG_currently_Positor` = coalesce(positor, a.`AC_partner_AC_with_ONG_currently_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_partner_AC_with_ONG_currently_ID`, a.`AC_partner_AC_with_ONG_currently_Positor`
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
    `AC_subset_PN_of_Positor`,
    `AC_subset_PN_of_Reliability`,
    CASE
        WHEN `AC_subset_PN_of_Reliability` > 0 THEN '+'
        WHEN `AC_subset_PN_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Assertion`
FROM
    public.`AC_subset_PN_of_Annex`
WHERE
    `AC_subset_PN_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_subset_PN_of` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Positor`,
    a.`AC_subset_PN_of_Reliability`,
    CASE
        WHEN a.`AC_subset_PN_of_Reliability` > 0 THEN '+'
        WHEN a.`AC_subset_PN_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Assertion`
FROM
    public.`AC_subset_PN_of_Posit` p
JOIN
    public.`rAC_subset_PN_of_Annex`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
AND
    a.`AC_subset_PN_of_Positor` = coalesce(positor, a.`AC_subset_PN_of_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`, a.`AC_subset_PN_of_Positor`
        ORDER BY a.`AC_subset_PN_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_subset_PN_of` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_subset_PN_of`,
    p.`AC_subset_PN_of_ID`,
    p.`AC_ID_subset`,
    p.`PN_ID_of`,
    a.`AC_subset_PN_of_PositedAt`,
    a.`AC_subset_PN_of_Positor`,
    a.`AC_subset_PN_of_Reliability`,
    CASE
        WHEN a.`AC_subset_PN_of_Reliability` > 0 THEN '+'
        WHEN a.`AC_subset_PN_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Assertion`
FROM
    public.`AC_subset_PN_of_Posit` p
JOIN
    public.`rAC_subset_PN_of_Annex`(positingTimepoint) a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
AND
    a.`AC_subset_PN_of_Positor` = coalesce(positor, a.`AC_subset_PN_of_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_subset_PN_of_ID`, a.`AC_subset_PN_of_Positor`
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
    `EV_in_AC_wasCast_Positor`,
    `EV_in_AC_wasCast_Reliability`,
    CASE
        WHEN `EV_in_AC_wasCast_Reliability` > 0 THEN '+'
        WHEN `EV_in_AC_wasCast_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_wasCast_Assertion`
FROM
    public.`EV_in_AC_wasCast_Annex`
WHERE
    `EV_in_AC_wasCast_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rEV_in_AC_wasCast` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Positor`,
    a.`EV_in_AC_wasCast_Reliability`,
    CASE
        WHEN a.`EV_in_AC_wasCast_Reliability` > 0 THEN '+'
        WHEN a.`EV_in_AC_wasCast_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_wasCast_Assertion`
FROM
    public.`EV_in_AC_wasCast_Posit` p
JOIN
    public.`rEV_in_AC_wasCast_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
AND
    a.`EV_in_AC_wasCast_Positor` = coalesce(positor, a.`EV_in_AC_wasCast_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`, a.`EV_in_AC_wasCast_Positor`
        ORDER BY a.`EV_in_AC_wasCast_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fEV_in_AC_wasCast` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_wasCast`,
    p.`EV_in_AC_wasCast_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_wasCast`,
    a.`EV_in_AC_wasCast_PositedAt`,
    a.`EV_in_AC_wasCast_Positor`,
    a.`EV_in_AC_wasCast_Reliability`,
    CASE
        WHEN a.`EV_in_AC_wasCast_Reliability` > 0 THEN '+'
        WHEN a.`EV_in_AC_wasCast_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_wasCast_Assertion`
FROM
    public.`EV_in_AC_wasCast_Posit` p
JOIN
    public.`rEV_in_AC_wasCast_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_wasCast_ID` = p.`EV_in_AC_wasCast_ID`
AND
    a.`EV_in_AC_wasCast_Positor` = coalesce(positor, a.`EV_in_AC_wasCast_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_wasCast_ID`, a.`EV_in_AC_wasCast_Positor`
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
    `AC_part_PR_in_RAT_got_Positor`,
    `AC_part_PR_in_RAT_got_Reliability`,
    CASE
        WHEN `AC_part_PR_in_RAT_got_Reliability` > 0 THEN '+'
        WHEN `AC_part_PR_in_RAT_got_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_part_PR_in_RAT_got_Assertion`
FROM
    public.`AC_part_PR_in_RAT_got_Annex`
WHERE
    `AC_part_PR_in_RAT_got_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_part_PR_in_RAT_got` (
    positor int64,
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
    a.`AC_part_PR_in_RAT_got_Positor`,
    a.`AC_part_PR_in_RAT_got_Reliability`,
    CASE
        WHEN a.`AC_part_PR_in_RAT_got_Reliability` > 0 THEN '+'
        WHEN a.`AC_part_PR_in_RAT_got_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_part_PR_in_RAT_got_Assertion`
FROM
    public.`rAC_part_PR_in_RAT_got_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_part_PR_in_RAT_got_Annex`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
AND
    a.`AC_part_PR_in_RAT_got_Positor` = coalesce(positor, a.`AC_part_PR_in_RAT_got_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`, a.`AC_part_PR_in_RAT_got_Positor`
        ORDER BY a.`AC_part_PR_in_RAT_got_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_part_PR_in_RAT_got` (
    positor int64,
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
    a.`AC_part_PR_in_RAT_got_Positor`,
    a.`AC_part_PR_in_RAT_got_Reliability`,
    CASE
        WHEN a.`AC_part_PR_in_RAT_got_Reliability` > 0 THEN '+'
        WHEN a.`AC_part_PR_in_RAT_got_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_part_PR_in_RAT_got_Assertion`
FROM
    public.`fAC_part_PR_in_RAT_got_Posit`(changingTimepoint) p 
JOIN
    public.`rAC_part_PR_in_RAT_got_Annex`(positingTimepoint) a
ON
    a.`AC_part_PR_in_RAT_got_ID` = p.`AC_part_PR_in_RAT_got_ID`
AND
    a.`AC_part_PR_in_RAT_got_Positor` = coalesce(positor, a.`AC_part_PR_in_RAT_got_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_part_PR_in_RAT_got_ID`, a.`AC_part_PR_in_RAT_got_Positor`
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
    `ST_at_PR_isPlaying_Positor`,
    `ST_at_PR_isPlaying_Reliability`,
    CASE
        WHEN `ST_at_PR_isPlaying_Reliability` > 0 THEN '+'
        WHEN `ST_at_PR_isPlaying_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_isPlaying_Assertion`
FROM
    public.`ST_at_PR_isPlaying_Annex`
WHERE
    `ST_at_PR_isPlaying_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rST_at_PR_isPlaying` (
    positor int64,
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
    a.`ST_at_PR_isPlaying_Positor`,
    a.`ST_at_PR_isPlaying_Reliability`,
    CASE
        WHEN a.`ST_at_PR_isPlaying_Reliability` > 0 THEN '+'
        WHEN a.`ST_at_PR_isPlaying_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_isPlaying_Assertion`
FROM
    public.`rST_at_PR_isPlaying_Posit`(changingTimepoint) p 
JOIN
    public.`rST_at_PR_isPlaying_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
AND
    a.`ST_at_PR_isPlaying_Positor` = coalesce(positor, a.`ST_at_PR_isPlaying_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`, a.`ST_at_PR_isPlaying_Positor`
        ORDER BY a.`ST_at_PR_isPlaying_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fST_at_PR_isPlaying` (
    positor int64,
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
    a.`ST_at_PR_isPlaying_Positor`,
    a.`ST_at_PR_isPlaying_Reliability`,
    CASE
        WHEN a.`ST_at_PR_isPlaying_Reliability` > 0 THEN '+'
        WHEN a.`ST_at_PR_isPlaying_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_isPlaying_Assertion`
FROM
    public.`fST_at_PR_isPlaying_Posit`(changingTimepoint) p 
JOIN
    public.`rST_at_PR_isPlaying_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_isPlaying_ID` = p.`ST_at_PR_isPlaying_ID`
AND
    a.`ST_at_PR_isPlaying_Positor` = coalesce(positor, a.`ST_at_PR_isPlaying_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_isPlaying_ID`, a.`ST_at_PR_isPlaying_Positor`
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
    `AC_parent_AC_child_PAT_having_Positor`,
    `AC_parent_AC_child_PAT_having_Reliability`,
    CASE
        WHEN `AC_parent_AC_child_PAT_having_Reliability` > 0 THEN '+'
        WHEN `AC_parent_AC_child_PAT_having_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_parent_AC_child_PAT_having_Assertion`
FROM
    public.`AC_parent_AC_child_PAT_having_Annex`
WHERE
    `AC_parent_AC_child_PAT_having_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rAC_parent_AC_child_PAT_having` (
    positor int64,
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
    a.`AC_parent_AC_child_PAT_having_Positor`,
    a.`AC_parent_AC_child_PAT_having_Reliability`,
    CASE
        WHEN a.`AC_parent_AC_child_PAT_having_Reliability` > 0 THEN '+'
        WHEN a.`AC_parent_AC_child_PAT_having_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_parent_AC_child_PAT_having_Assertion`
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` p
JOIN
    public.`rAC_parent_AC_child_PAT_having_Annex`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
AND
    a.`AC_parent_AC_child_PAT_having_Positor` = coalesce(positor, a.`AC_parent_AC_child_PAT_having_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`, a.`AC_parent_AC_child_PAT_having_Positor`
        ORDER BY a.`AC_parent_AC_child_PAT_having_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fAC_parent_AC_child_PAT_having` (
    positor int64,
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
    a.`AC_parent_AC_child_PAT_having_Positor`,
    a.`AC_parent_AC_child_PAT_having_Reliability`,
    CASE
        WHEN a.`AC_parent_AC_child_PAT_having_Reliability` > 0 THEN '+'
        WHEN a.`AC_parent_AC_child_PAT_having_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_parent_AC_child_PAT_having_Assertion`
FROM
    public.`AC_parent_AC_child_PAT_having_Posit` p
JOIN
    public.`rAC_parent_AC_child_PAT_having_Annex`(positingTimepoint) a
ON
    a.`AC_parent_AC_child_PAT_having_ID` = p.`AC_parent_AC_child_PAT_having_ID`
AND
    a.`AC_parent_AC_child_PAT_having_Positor` = coalesce(positor, a.`AC_parent_AC_child_PAT_having_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_parent_AC_child_PAT_having_ID`, a.`AC_parent_AC_child_PAT_having_Positor`
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
    `PR_content_ST_location_EV_of_Positor`,
    `PR_content_ST_location_EV_of_Reliability`,
    CASE
        WHEN `PR_content_ST_location_EV_of_Reliability` > 0 THEN '+'
        WHEN `PR_content_ST_location_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_content_ST_location_EV_of_Assertion`
FROM
    public.`PR_content_ST_location_EV_of_Annex`
WHERE
    `PR_content_ST_location_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION public.`rPR_content_ST_location_EV_of` (
    positor int64,
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
    a.`PR_content_ST_location_EV_of_Positor`,
    a.`PR_content_ST_location_EV_of_Reliability`,
    CASE
        WHEN a.`PR_content_ST_location_EV_of_Reliability` > 0 THEN '+'
        WHEN a.`PR_content_ST_location_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_content_ST_location_EV_of_Assertion`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`rPR_content_ST_location_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
AND
    a.`PR_content_ST_location_EV_of_Positor` = coalesce(positor, a.`PR_content_ST_location_EV_of_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`, a.`PR_content_ST_location_EV_of_Positor`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION public.`fPR_content_ST_location_EV_of` (
    positor int64,
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
    a.`PR_content_ST_location_EV_of_Positor`,
    a.`PR_content_ST_location_EV_of_Reliability`,
    CASE
        WHEN a.`PR_content_ST_location_EV_of_Reliability` > 0 THEN '+'
        WHEN a.`PR_content_ST_location_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_content_ST_location_EV_of_Assertion`
FROM
    public.`PR_content_ST_location_EV_of_Posit` p
JOIN
    public.`rPR_content_ST_location_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_content_ST_location_EV_of_ID` = p.`PR_content_ST_location_EV_of_ID`
AND
    a.`PR_content_ST_location_EV_of_Positor` = coalesce(positor, a.`PR_content_ST_location_EV_of_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_content_ST_location_EV_of_ID`, a.`PR_content_ST_location_EV_of_Positor`
        ORDER BY a.`PR_content_ST_location_EV_of_PositedAt` DESC
    ) = 1
)
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BigQuery CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tST_Stage` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
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
    `NAM`.`ST_NAM_Positor`,
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Assertion`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Positor`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Assertion`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Positor`,
    `AVG`.`ST_AVG_Reliability`,
    `AVG`.`ST_AVG_Assertion`,
    `AVG`.`ST_AVG_UTL_Utilization`,
    `AVG`.`ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Positor`,
    `MIN`.`ST_MIN_Reliability`,
    `MIN`.`ST_MIN_Assertion`,
    `MIN`.`ST_MIN_UTL_Utilization`,
    `MIN`.`ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    public.`ST_Stage` `ST`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public.`_Positor` p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`ST_NAM_Assertion` <> '?', r.`ST_NAM_ChangedAt`, null)) OVER (
                PARTITION BY r.`ST_NAM_Positor`, r.`ST_NAM_ST_ID`
            ) AS `inEffect`
        FROM
            public.`rST_NAM_Stage_Name`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`ST_NAM_Assertion` = coalesce(assertion, x.`ST_NAM_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`ST_NAM_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`ST_NAM_Positor`, x.`ST_NAM_ST_ID`
            ORDER BY
                x.`ST_NAM_ChangedAt` DESC,
                x.`ST_NAM_PositedAt` DESC,
                x.`ST_NAM_Reliability` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
AND
    `NAM`.`ST_NAM_Positor` = p.`Positor`
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rST_LOC_Stage_Location`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`ST_LOC_Assertion` = coalesce(assertion, x.`ST_LOC_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`ST_LOC_Positor`, x.`ST_LOC_ST_ID`
            ORDER BY
                x.`ST_LOC_PositedAt` DESC,
                x.`ST_LOC_Reliability` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
AND
    `LOC`.`ST_LOC_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
        k.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`ST_AVG_Assertion` <> '?', r.`ST_AVG_ChangedAt`, null)) OVER (
                PARTITION BY r.`ST_AVG_Positor`, r.`ST_AVG_ST_ID`
            ) AS `inEffect`
        FROM
            public.`rST_AVG_Stage_Average`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`ST_AVG_Assertion` = coalesce(assertion, x.`ST_AVG_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`ST_AVG_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`ST_AVG_Positor`, x.`ST_AVG_ST_ID`
            ORDER BY
                x.`ST_AVG_ChangedAt` DESC,
                x.`ST_AVG_PositedAt` DESC,
                x.`ST_AVG_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        public.`UTL_Utilization` k
    ON
        k.`UTL_ID` = y.`ST_AVG_UTL_ID`
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
AND
    `AVG`.`ST_AVG_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
        k.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rST_MIN_Stage_Minimum`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`ST_MIN_Assertion` = coalesce(assertion, x.`ST_MIN_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`ST_MIN_Positor`, x.`ST_MIN_ST_ID`
            ORDER BY
                x.`ST_MIN_PositedAt` DESC,
                x.`ST_MIN_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        public.`UTL_Utilization` k
    ON
        k.`UTL_ID` = y.`ST_MIN_UTL_ID`
) `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
AND
    `MIN`.`ST_MIN_Positor` = p.`Positor`
WHERE
    p.`Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lST_Stage` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    public.`_Positor` p,
    public.`tST_Stage`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `ST`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pST_Stage` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `ST`.`ST_NAM_ST_ID`,
    `ST`.`Metadata_ST_NAM`,
    `ST`.`ST_NAM_ID`,
    `ST`.`ST_NAM_ChangedAt`,
    `ST`.`ST_NAM_PositedAt`,
    `ST`.`ST_NAM_Positor`,
    `ST`.`ST_NAM_Reliability`,
    `ST`.`ST_NAM_Assertion`,
    `ST`.`ST_NAM_Stage_Name`,
    `ST`.`ST_LOC_ST_ID`,
    `ST`.`Metadata_ST_LOC`,
    `ST`.`ST_LOC_ID`,
    `ST`.`ST_LOC_PositedAt`,
    `ST`.`ST_LOC_Positor`,
    `ST`.`ST_LOC_Reliability`,
    `ST`.`ST_LOC_Assertion`,
    `ST`.`ST_LOC_Checksum`,
    `ST`.`ST_LOC_Stage_Location`,
    `ST`.`ST_AVG_ST_ID`,
    `ST`.`Metadata_ST_AVG`,
    `ST`.`ST_AVG_ID`,
    `ST`.`ST_AVG_ChangedAt`,
    `ST`.`ST_AVG_PositedAt`,
    `ST`.`ST_AVG_Positor`,
    `ST`.`ST_AVG_Reliability`,
    `ST`.`ST_AVG_Assertion`,
    `ST`.`ST_AVG_UTL_Utilization`,
    `ST`.`ST_AVG_Metadata_UTL`,
    `ST`.`ST_AVG_UTL_ID`,
    `ST`.`ST_MIN_ST_ID`,
    `ST`.`Metadata_ST_MIN`,
    `ST`.`ST_MIN_ID`,
    `ST`.`ST_MIN_PositedAt`,
    `ST`.`ST_MIN_Positor`,
    `ST`.`ST_MIN_Reliability`,
    `ST`.`ST_MIN_Assertion`,
    `ST`.`ST_MIN_UTL_Utilization`,
    `ST`.`ST_MIN_Metadata_UTL`,
    `ST`.`ST_MIN_UTL_ID`
FROM
    public.`_Positor` p,
    public.`tST_Stage`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `ST`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nST_Stage` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    public.`_Positor` p,
    public.`tST_Stage`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `ST`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dST_Stage` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with an outer join on its argument for each row of another
-- table.
SELECT
    p.`Positor`,
    timepoints.inspectedTimepoint,
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_PositedAt`,
    `NAM`.`ST_NAM_Positor`,
    `NAM`.`ST_NAM_Reliability`,
    `NAM`.`ST_NAM_Assertion`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Positor`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Assertion`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Positor`,
    `AVG`.`ST_AVG_Reliability`,
    `AVG`.`ST_AVG_Assertion`,
    `kAVG`.`UTL_Utilization` AS `ST_AVG_UTL_Utilization`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Positor`,
    `MIN`.`ST_MIN_Reliability`,
    `MIN`.`ST_MIN_Assertion`,
    `kMIN`.`UTL_Utilization` AS `ST_MIN_UTL_Utilization`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    public.`_Positor` p
JOIN
(
    SELECT DISTINCT
        `ST_NAM_Positor` AS positor,
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
        `ST_AVG_Positor` AS positor,
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
ON
    timepoints.positor = p.`Positor`
JOIN
    public.`ST_Stage` `ST`
ON
    `ST`.`ST_ID` = timepoints.`ST_ID`
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`ST_NAM_ChangedAt`) OVER (
            PARTITION BY y.`ST_NAM_Positor`, y.`ST_NAM_ST_ID`
            ORDER BY y.`ST_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rST_NAM_Stage_Name`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_NAM_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_NAM_Positor`, r.`ST_NAM_ST_ID`, r.`ST_NAM_ChangedAt`
                ORDER BY
                    IF(r.`ST_NAM_Assertion` = '+', 0, 1),
                    r.`ST_NAM_PositedAt` DESC,
                    r.`ST_NAM_Reliability` DESC
            ) = 1
    ) y
) `NAM`
ON
    `NAM`.`ST_NAM_ST_ID` = `ST`.`ST_ID`
AND
    `NAM`.`ST_NAM_Positor` = timepoints.positor
AND
    `NAM`.`ST_NAM_Assertion` = '+'
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
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_LOC_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_LOC_Positor`, r.`ST_LOC_ST_ID`
            ORDER BY
                r.`ST_LOC_PositedAt` DESC,
                r.`ST_LOC_Reliability` DESC
        ) = 1
) `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
AND
    `LOC`.`ST_LOC_Positor` = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`ST_AVG_ChangedAt`) OVER (
            PARTITION BY y.`ST_AVG_Positor`, y.`ST_AVG_ST_ID`
            ORDER BY y.`ST_AVG_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rST_AVG_Stage_Average`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_AVG_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`ST_AVG_Positor`, r.`ST_AVG_ST_ID`, r.`ST_AVG_ChangedAt`
                ORDER BY
                    IF(r.`ST_AVG_Assertion` = '+', 0, 1),
                    r.`ST_AVG_PositedAt` DESC,
                    r.`ST_AVG_Reliability` DESC
            ) = 1
    ) y
) `AVG`
ON
    `AVG`.`ST_AVG_ST_ID` = `ST`.`ST_ID`
AND
    `AVG`.`ST_AVG_Positor` = timepoints.positor
AND
    `AVG`.`ST_AVG_Assertion` = '+'
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
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`ST_MIN_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`ST_MIN_Positor`, r.`ST_MIN_ST_ID`
            ORDER BY
                r.`ST_MIN_PositedAt` DESC,
                r.`ST_MIN_Reliability` DESC
        ) = 1
) `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
AND
    `MIN`.`ST_MIN_Positor` = timepoints.positor
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tAC_Actor` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
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
    `NAM`.`AC_NAM_Positor`,
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Assertion`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Positor`,
    `GEN`.`AC_GEN_Reliability`,
    `GEN`.`AC_GEN_Assertion`,
    `GEN`.`AC_GEN_GEN_Gender`,
    `GEN`.`AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Positor`,
    `PLV`.`AC_PLV_Reliability`,
    `PLV`.`AC_PLV_Assertion`,
    `PLV`.`AC_PLV_PLV_Checksum`,
    `PLV`.`AC_PLV_PLV_ProfessionalLevel`,
    `PLV`.`AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    public.`AC_Actor` `AC`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public.`_Positor` p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`AC_NAM_Assertion` <> '?', r.`AC_NAM_ChangedAt`, null)) OVER (
                PARTITION BY r.`AC_NAM_Positor`, r.`AC_NAM_AC_ID`
            ) AS `inEffect`
        FROM
            public.`rAC_NAM_Actor_Name`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`AC_NAM_Assertion` = coalesce(assertion, x.`AC_NAM_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`AC_NAM_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`AC_NAM_Positor`, x.`AC_NAM_AC_ID`
            ORDER BY
                x.`AC_NAM_ChangedAt` DESC,
                x.`AC_NAM_PositedAt` DESC,
                x.`AC_NAM_Reliability` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
AND
    `NAM`.`AC_NAM_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
        k.`GEN_Gender` AS `AC_GEN_GEN_Gender`
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rAC_GEN_Actor_Gender`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`AC_GEN_Assertion` = coalesce(assertion, x.`AC_GEN_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`AC_GEN_Positor`, x.`AC_GEN_AC_ID`
            ORDER BY
                x.`AC_GEN_PositedAt` DESC,
                x.`AC_GEN_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        public.`GEN_Gender` k
    ON
        k.`GEN_ID` = y.`AC_GEN_GEN_ID`
) `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
AND
    `GEN`.`AC_GEN_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
        k.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
        k.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`AC_PLV_Assertion` <> '?', r.`AC_PLV_ChangedAt`, null)) OVER (
                PARTITION BY r.`AC_PLV_Positor`, r.`AC_PLV_AC_ID`
            ) AS `inEffect`
        FROM
            public.`rAC_PLV_Actor_ProfessionalLevel`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`AC_PLV_Assertion` = coalesce(assertion, x.`AC_PLV_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`AC_PLV_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`AC_PLV_Positor`, x.`AC_PLV_AC_ID`
            ORDER BY
                x.`AC_PLV_ChangedAt` DESC,
                x.`AC_PLV_PositedAt` DESC,
                x.`AC_PLV_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        public.`PLV_ProfessionalLevel` k
    ON
        k.`PLV_ID` = y.`AC_PLV_PLV_ID`
) `PLV`
ON
    `PLV`.`AC_PLV_AC_ID` = `AC`.`AC_ID`
AND
    `PLV`.`AC_PLV_Positor` = p.`Positor`
WHERE
    p.`Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_Actor` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    public.`_Positor` p,
    public.`tAC_Actor`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `AC`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_Actor` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `AC`.`AC_NAM_AC_ID`,
    `AC`.`Metadata_AC_NAM`,
    `AC`.`AC_NAM_ID`,
    `AC`.`AC_NAM_ChangedAt`,
    `AC`.`AC_NAM_PositedAt`,
    `AC`.`AC_NAM_Positor`,
    `AC`.`AC_NAM_Reliability`,
    `AC`.`AC_NAM_Assertion`,
    `AC`.`AC_NAM_Actor_Name`,
    `AC`.`AC_GEN_AC_ID`,
    `AC`.`Metadata_AC_GEN`,
    `AC`.`AC_GEN_ID`,
    `AC`.`AC_GEN_PositedAt`,
    `AC`.`AC_GEN_Positor`,
    `AC`.`AC_GEN_Reliability`,
    `AC`.`AC_GEN_Assertion`,
    `AC`.`AC_GEN_GEN_Gender`,
    `AC`.`AC_GEN_Metadata_GEN`,
    `AC`.`AC_GEN_GEN_ID`,
    `AC`.`AC_PLV_AC_ID`,
    `AC`.`Metadata_AC_PLV`,
    `AC`.`AC_PLV_ID`,
    `AC`.`AC_PLV_ChangedAt`,
    `AC`.`AC_PLV_PositedAt`,
    `AC`.`AC_PLV_Positor`,
    `AC`.`AC_PLV_Reliability`,
    `AC`.`AC_PLV_Assertion`,
    `AC`.`AC_PLV_PLV_Checksum`,
    `AC`.`AC_PLV_PLV_ProfessionalLevel`,
    `AC`.`AC_PLV_Metadata_PLV`,
    `AC`.`AC_PLV_PLV_ID`
FROM
    public.`_Positor` p,
    public.`tAC_Actor`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `AC`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_Actor` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    public.`_Positor` p,
    public.`tAC_Actor`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `AC`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_Actor` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with an outer join on its argument for each row of another
-- table.
SELECT
    p.`Positor`,
    timepoints.inspectedTimepoint,
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_PositedAt`,
    `NAM`.`AC_NAM_Positor`,
    `NAM`.`AC_NAM_Reliability`,
    `NAM`.`AC_NAM_Assertion`,
    `NAM`.`AC_NAM_Actor_Name`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Positor`,
    `GEN`.`AC_GEN_Reliability`,
    `GEN`.`AC_GEN_Assertion`,
    `kGEN`.`GEN_Gender` AS `AC_GEN_GEN_Gender`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Positor`,
    `PLV`.`AC_PLV_Reliability`,
    `PLV`.`AC_PLV_Assertion`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `AC_PLV_PLV_ProfessionalLevel`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    public.`_Positor` p
JOIN
(
    SELECT DISTINCT
        `AC_NAM_Positor` AS positor,
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
        `AC_PLV_Positor` AS positor,
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
ON
    timepoints.positor = p.`Positor`
JOIN
    public.`AC_Actor` `AC`
ON
    `AC`.`AC_ID` = timepoints.`AC_ID`
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`AC_NAM_ChangedAt`) OVER (
            PARTITION BY y.`AC_NAM_Positor`, y.`AC_NAM_AC_ID`
            ORDER BY y.`AC_NAM_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rAC_NAM_Actor_Name`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_NAM_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_NAM_Positor`, r.`AC_NAM_AC_ID`, r.`AC_NAM_ChangedAt`
                ORDER BY
                    IF(r.`AC_NAM_Assertion` = '+', 0, 1),
                    r.`AC_NAM_PositedAt` DESC,
                    r.`AC_NAM_Reliability` DESC
            ) = 1
    ) y
) `NAM`
ON
    `NAM`.`AC_NAM_AC_ID` = `AC`.`AC_ID`
AND
    `NAM`.`AC_NAM_Positor` = timepoints.positor
AND
    `NAM`.`AC_NAM_Assertion` = '+'
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
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`AC_GEN_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`AC_GEN_Positor`, r.`AC_GEN_AC_ID`
            ORDER BY
                r.`AC_GEN_PositedAt` DESC,
                r.`AC_GEN_Reliability` DESC
        ) = 1
) `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
AND
    `GEN`.`AC_GEN_Positor` = timepoints.positor
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`AC_PLV_ChangedAt`) OVER (
            PARTITION BY y.`AC_PLV_Positor`, y.`AC_PLV_AC_ID`
            ORDER BY y.`AC_PLV_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rAC_PLV_Actor_ProfessionalLevel`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_PLV_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`AC_PLV_Positor`, r.`AC_PLV_AC_ID`, r.`AC_PLV_ChangedAt`
                ORDER BY
                    IF(r.`AC_PLV_Assertion` = '+', 0, 1),
                    r.`AC_PLV_PositedAt` DESC,
                    r.`AC_PLV_Reliability` DESC
            ) = 1
    ) y
) `PLV`
ON
    `PLV`.`AC_PLV_AC_ID` = `AC`.`AC_ID`
AND
    `PLV`.`AC_PLV_Positor` = timepoints.positor
AND
    `PLV`.`AC_PLV_Assertion` = '+'
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
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tPR_Program` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Positor`,
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Assertion`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Positor`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Assertion`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`PR_Program` `PR`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public.`_Positor` p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rPR_NAM_Program_Name`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`PR_NAM_Assertion` = coalesce(assertion, x.`PR_NAM_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`PR_NAM_Positor`, x.`PR_NAM_PR_ID`
            ORDER BY
                x.`PR_NAM_PositedAt` DESC,
                x.`PR_NAM_Reliability` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
AND
    `NAM`.`PR_NAM_Positor` = p.`Positor`
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`PR_LEN_Assertion` <> '?', r.`PR_LEN_ChangedAt`, null)) OVER (
                PARTITION BY r.`PR_LEN_Positor`, r.`PR_LEN_PR_ID`
            ) AS `inEffect`
        FROM
            public.`rPR_LEN_Program_Length`(
                CAST(null AS int64),
                CAST(changingTimepoint AS date),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`PR_LEN_Assertion` = coalesce(assertion, x.`PR_LEN_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`PR_LEN_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`PR_LEN_Positor`, x.`PR_LEN_PR_ID`
            ORDER BY
                x.`PR_LEN_ChangedAt` DESC,
                x.`PR_LEN_PositedAt` DESC,
                x.`PR_LEN_Reliability` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`
AND
    `LEN`.`PR_LEN_Positor` = p.`Positor`
WHERE
    p.`Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_Program` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    public.`_Positor` p,
    public.`tPR_Program`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `PR`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pPR_Program` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `PR`.`PR_NAM_PR_ID`,
    `PR`.`Metadata_PR_NAM`,
    `PR`.`PR_NAM_ID`,
    `PR`.`PR_NAM_PositedAt`,
    `PR`.`PR_NAM_Positor`,
    `PR`.`PR_NAM_Reliability`,
    `PR`.`PR_NAM_Assertion`,
    `PR`.`PR_NAM_Program_Name`,
    `PR`.`PR_LEN_PR_ID`,
    `PR`.`Metadata_PR_LEN`,
    `PR`.`PR_LEN_ID`,
    `PR`.`PR_LEN_ChangedAt`,
    `PR`.`PR_LEN_PositedAt`,
    `PR`.`PR_LEN_Positor`,
    `PR`.`PR_LEN_Reliability`,
    `PR`.`PR_LEN_Assertion`,
    `PR`.`PR_LEN_Program_Length`
FROM
    public.`_Positor` p,
    public.`tPR_Program`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `PR`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nPR_Program` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    public.`_Positor` p,
    public.`tPR_Program`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `PR`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dPR_Program` (
    intervalStart datetime,
    intervalEnd datetime,
    selection string
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with an outer join on its argument for each row of another
-- table.
SELECT
    p.`Positor`,
    timepoints.inspectedTimepoint,
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_ID`,
    `NAM`.`PR_NAM_PositedAt`,
    `NAM`.`PR_NAM_Positor`,
    `NAM`.`PR_NAM_Reliability`,
    `NAM`.`PR_NAM_Assertion`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Positor`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Assertion`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`_Positor` p
JOIN
(
    SELECT DISTINCT
        `PR_LEN_Positor` AS positor,
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
ON
    timepoints.positor = p.`Positor`
JOIN
    public.`PR_Program` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        public.`rPR_NAM_Program_Name`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`PR_NAM_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`PR_NAM_Positor`, r.`PR_NAM_PR_ID`
            ORDER BY
                r.`PR_NAM_PositedAt` DESC,
                r.`PR_NAM_Reliability` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
AND
    `NAM`.`PR_NAM_Positor` = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`PR_LEN_ChangedAt`) OVER (
            PARTITION BY y.`PR_LEN_Positor`, y.`PR_LEN_PR_ID`
            ORDER BY y.`PR_LEN_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rPR_LEN_Program_Length`(
                CAST(null AS int64),
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_LEN_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`PR_LEN_Positor`, r.`PR_LEN_PR_ID`, r.`PR_LEN_ChangedAt`
                ORDER BY
                    IF(r.`PR_LEN_Assertion` = '+', 0, 1),
                    r.`PR_LEN_PositedAt` DESC,
                    r.`PR_LEN_Reliability` DESC
            ) = 1
    ) y
) `LEN`
ON
    `LEN`.`PR_LEN_PR_ID` = `PR`.`PR_ID`
AND
    `LEN`.`PR_LEN_Positor` = timepoints.positor
AND
    `LEN`.`PR_LEN_Assertion` = '+'
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
-- BigQuery CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tEV_Event` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
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
    `DAT`.`EV_DAT_Positor`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Assertion`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Positor`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Assertion`,
    `AUD`.`EV_AUD_Event_Audience`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Positor`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Assertion`,
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public.`_Positor` p
LEFT JOIN
    public.`ETY_EventType` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rEV_DAT_Event_Date`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_DAT_Assertion` = coalesce(assertion, x.`EV_DAT_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_DAT_Positor`, x.`EV_DAT_EV_ID`
            ORDER BY
                x.`EV_DAT_PositedAt` DESC,
                x.`EV_DAT_Reliability` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
AND
    `DAT`.`EV_DAT_Positor` = p.`Positor`
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rEV_AUD_Event_Audience`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_AUD_Assertion` = coalesce(assertion, x.`EV_AUD_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_AUD_Positor`, x.`EV_AUD_EV_ID`
            ORDER BY
                x.`EV_AUD_PositedAt` DESC,
                x.`EV_AUD_Reliability` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
AND
    `AUD`.`EV_AUD_Positor` = p.`Positor`
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rEV_REV_Event_Revenue`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_REV_Assertion` = coalesce(assertion, x.`EV_REV_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_REV_Positor`, x.`EV_REV_EV_ID`
            ORDER BY
                x.`EV_REV_PositedAt` DESC,
                x.`EV_REV_Reliability` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
AND
    `REV`.`EV_REV_Positor` = p.`Positor`
WHERE
    p.`Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lEV_Event` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    public.`_Positor` p,
    public.`tEV_Event`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
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
    `EV`.`EV_DAT_Positor`,
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Assertion`,
    `EV`.`EV_DAT_Event_Date`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Positor`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Assertion`,
    `EV`.`EV_AUD_Event_Audience`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Positor`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Assertion`,
    `EV`.`EV_REV_Event_Revenue`
FROM
    public.`_Positor` p,
    public.`tEV_Event`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_Event` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    public.`_Positor` p,
    public.`tEV_Event`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tAC_partner_AC_with_ONG_currently` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`AC_partner_AC_with_ONG_currently_Assertion` <> '?', r.`AC_partner_AC_with_ONG_currently_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_partner_AC_with_ONG_currently_Positor`,
                    r.`AC_ID_partner`,
                    r.`AC_ID_with`,
                    r.`ONG_ID_currently`
            ) AS `inEffect`
        FROM
            public.`rAC_partner_AC_with_ONG_currently`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_partner_AC_with_ONG_currently_Assertion` = coalesce(assertion, s.`AC_partner_AC_with_ONG_currently_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`AC_partner_AC_with_ONG_currently_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`AC_partner_AC_with_ONG_currently_Positor`, s.`AC_ID_partner`
            ORDER BY
                s.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
                s.`AC_partner_AC_with_ONG_currently_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`AC_partner_AC_with_ONG_currently_Positor`, s.`AC_ID_with`
            ORDER BY
                s.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                s.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
                s.`AC_partner_AC_with_ONG_currently_ID` DESC
        ) = 1
) t
LEFT JOIN
    public.`ONG_Ongoing` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Ongoing`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Ongoing` AS `currently_ONG_Ongoing`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    public.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_partner_AC_with_ONG_currently_Positor` AS positor,
        CAST(`AC_partner_AC_with_ONG_currently_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        public.`AC_partner_AC_with_ONG_currently`
    WHERE
        `AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_partner_AC_with_ONG_currently_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_partner_AC_with_ONG_currently_Positor`,
                y.`AC_ID_partner`,
                y.`AC_ID_with`,
                y.`ONG_ID_currently`
            ORDER BY y.`AC_partner_AC_with_ONG_currently_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rAC_partner_AC_with_ONG_currently`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_partner_AC_with_ONG_currently_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_partner_AC_with_ONG_currently_Positor`,
                    r.`AC_ID_partner`,
                    r.`AC_ID_with`,
                    r.`ONG_ID_currently`,
                    r.`AC_partner_AC_with_ONG_currently_ChangedAt`
                ORDER BY
                    IF(r.`AC_partner_AC_with_ONG_currently_Assertion` = '+', 0, 1),
                    r.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
                    r.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
                    r.`AC_partner_AC_with_ONG_currently_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_partner_AC_with_ONG_currently_Positor` = tp.positor
AND
    t.`AC_partner_AC_with_ONG_currently_Assertion` = '+'
AND
    t.`AC_partner_AC_with_ONG_currently_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    public.`ONG_Ongoing` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    TRUE
QUALIFY -- a tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`AC_ID_partner`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`AC_ID_with`
        ORDER BY
            t.`AC_partner_AC_with_ONG_currently_ChangedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_PositedAt` DESC,
            t.`AC_partner_AC_with_ONG_currently_Reliability` DESC,
            t.`AC_partner_AC_with_ONG_currently_ID` DESC
    ) = 1
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tAC_subset_PN_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Positor`,
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_subset_PN_of_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rAC_subset_PN_of`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_subset_PN_of_Assertion` = coalesce(assertion, s.`AC_subset_PN_of_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`AC_subset_PN_of_Positor`, s.`AC_ID_subset`
            ORDER BY
                s.`AC_subset_PN_of_PositedAt` DESC,
                s.`AC_subset_PN_of_Reliability` DESC,
                s.`AC_subset_PN_of_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`AC_subset_PN_of_Positor`, s.`PN_ID_of`
            ORDER BY
                s.`AC_subset_PN_of_PositedAt` DESC,
                s.`AC_subset_PN_of_Reliability` DESC,
                s.`AC_subset_PN_of_ID` DESC
        ) = 1
) t
WHERE
    t.`AC_subset_PN_of_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_subset_PN_of`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`,
    t.`AC_subset_PN_of_PositedAt`,
    t.`AC_subset_PN_of_Positor`,
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_subset_PN_of_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tEV_in_AC_wasCast` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Positor`,
    t.`EV_in_AC_wasCast_Reliability`,
    t.`EV_in_AC_wasCast_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rEV_in_AC_wasCast`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`EV_in_AC_wasCast_Assertion` = coalesce(assertion, s.`EV_in_AC_wasCast_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`EV_in_AC_wasCast_Positor`,
                s.`EV_ID_in`,
                s.`AC_ID_wasCast`
            ORDER BY
                s.`EV_in_AC_wasCast_PositedAt` DESC,
                s.`EV_in_AC_wasCast_Reliability` DESC,
                s.`EV_in_AC_wasCast_ID` DESC
        ) = 1
) t
WHERE
    t.`EV_in_AC_wasCast_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lEV_in_AC_wasCast` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tEV_in_AC_wasCast`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_EV_in_AC_wasCast`,
    t.`EV_ID_in`,
    t.`AC_ID_wasCast`,
    t.`EV_in_AC_wasCast_PositedAt`,
    t.`EV_in_AC_wasCast_Positor`,
    t.`EV_in_AC_wasCast_Reliability`,
    t.`EV_in_AC_wasCast_Assertion`
FROM
    public.`_Positor` p,
    public.`tEV_in_AC_wasCast`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_in_AC_wasCast` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tEV_in_AC_wasCast`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tAC_part_PR_in_RAT_got` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `kRAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Positor`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_part_PR_in_RAT_got_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`AC_part_PR_in_RAT_got_Assertion` <> '?', r.`AC_part_PR_in_RAT_got_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_part_PR_in_RAT_got_Positor`,
                    r.`AC_ID_part`,
                    r.`PR_ID_in`
            ) AS `inEffect`
        FROM
            public.`rAC_part_PR_in_RAT_got`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_part_PR_in_RAT_got_Assertion` = coalesce(assertion, s.`AC_part_PR_in_RAT_got_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`AC_part_PR_in_RAT_got_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_part_PR_in_RAT_got_Positor`,
                s.`AC_ID_part`,
                s.`PR_ID_in`
            ORDER BY
                s.`AC_part_PR_in_RAT_got_ChangedAt` DESC,
                s.`AC_part_PR_in_RAT_got_PositedAt` DESC,
                s.`AC_part_PR_in_RAT_got_Reliability` DESC,
                s.`AC_part_PR_in_RAT_got_ID` DESC
        ) = 1
) t
LEFT JOIN
    public.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
WHERE
    t.`AC_part_PR_in_RAT_got_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_part_PR_in_RAT_got` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_part_PR_in_RAT_got`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    t.`got_RAT_Rating`,
    t.`got_Metadata_RAT`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Positor`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_part_PR_in_RAT_got_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_part_PR_in_RAT_got`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_part_PR_in_RAT_got` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_part_PR_in_RAT_got`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    t.`Metadata_AC_part_PR_in_RAT_got`,
    t.`AC_ID_part`,
    t.`PR_ID_in`,
    `kRAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `kRAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    t.`RAT_ID_got`,
    t.`AC_part_PR_in_RAT_got_ChangedAt`,
    t.`AC_part_PR_in_RAT_got_PositedAt`,
    t.`AC_part_PR_in_RAT_got_Positor`,
    t.`AC_part_PR_in_RAT_got_Reliability`,
    t.`AC_part_PR_in_RAT_got_Assertion`
FROM
    public.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_part_PR_in_RAT_got_Positor` AS positor,
        CAST(`AC_part_PR_in_RAT_got_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        public.`AC_part_PR_in_RAT_got`
    WHERE
        `AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_part_PR_in_RAT_got_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_part_PR_in_RAT_got_Positor`,
                y.`AC_ID_part`,
                y.`PR_ID_in`
            ORDER BY y.`AC_part_PR_in_RAT_got_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rAC_part_PR_in_RAT_got`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_part_PR_in_RAT_got_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_part_PR_in_RAT_got_Positor`,
                    r.`AC_ID_part`,
                    r.`PR_ID_in`,
                    r.`AC_part_PR_in_RAT_got_ChangedAt`
                ORDER BY
                    IF(r.`AC_part_PR_in_RAT_got_Assertion` = '+', 0, 1),
                    r.`AC_part_PR_in_RAT_got_PositedAt` DESC,
                    r.`AC_part_PR_in_RAT_got_Reliability` DESC,
                    r.`AC_part_PR_in_RAT_got_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_part_PR_in_RAT_got_Positor` = tp.positor
AND
    t.`AC_part_PR_in_RAT_got_Assertion` = '+'
AND
    t.`AC_part_PR_in_RAT_got_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    public.`RAT_Rating` `kRAT_got`
ON
    `kRAT_got`.`RAT_ID` = t.`RAT_ID_got`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tST_at_PR_isPlaying` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Positor`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_at_PR_isPlaying_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`ST_at_PR_isPlaying_Assertion` <> '?', r.`ST_at_PR_isPlaying_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`ST_at_PR_isPlaying_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_isPlaying`
            ) AS `inEffect`
        FROM
            public.`rST_at_PR_isPlaying`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`ST_at_PR_isPlaying_Assertion` = coalesce(assertion, s.`ST_at_PR_isPlaying_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`ST_at_PR_isPlaying_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`ST_at_PR_isPlaying_Positor`,
                s.`ST_ID_at`,
                s.`PR_ID_isPlaying`
            ORDER BY
                s.`ST_at_PR_isPlaying_ChangedAt` DESC,
                s.`ST_at_PR_isPlaying_PositedAt` DESC,
                s.`ST_at_PR_isPlaying_Reliability` DESC,
                s.`ST_at_PR_isPlaying_ID` DESC
        ) = 1
) t
WHERE
    t.`ST_at_PR_isPlaying_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lST_at_PR_isPlaying` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tST_at_PR_isPlaying`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Positor`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_at_PR_isPlaying_Assertion`
FROM
    public.`_Positor` p,
    public.`tST_at_PR_isPlaying`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nST_at_PR_isPlaying` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tST_at_PR_isPlaying`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dST_at_PR_isPlaying` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. BigQuery cannot call the time-traveling perspective
-- for each change, since it cannot evaluate a function with a window over its argument for each row of another table.
SELECT
    p.`Positor`,
    tp.inspectedTimepoint,
    t.`Metadata_ST_at_PR_isPlaying`,
    t.`ST_ID_at`,
    t.`PR_ID_isPlaying`,
    t.`ST_at_PR_isPlaying_ChangedAt`,
    t.`ST_at_PR_isPlaying_PositedAt`,
    t.`ST_at_PR_isPlaying_Positor`,
    t.`ST_at_PR_isPlaying_Reliability`,
    t.`ST_at_PR_isPlaying_Assertion`
FROM
    public.`_Positor` p
JOIN (
    SELECT DISTINCT
        `ST_at_PR_isPlaying_Positor` AS positor,
        CAST(`ST_at_PR_isPlaying_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        public.`ST_at_PR_isPlaying`
    WHERE
        `ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`ST_at_PR_isPlaying_ChangedAt`) OVER (
            PARTITION BY
                y.`ST_at_PR_isPlaying_Positor`,
                y.`ST_ID_at`,
                y.`PR_ID_isPlaying`
            ORDER BY y.`ST_at_PR_isPlaying_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            public.`rST_at_PR_isPlaying`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_at_PR_isPlaying_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`ST_at_PR_isPlaying_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_isPlaying`,
                    r.`ST_at_PR_isPlaying_ChangedAt`
                ORDER BY
                    IF(r.`ST_at_PR_isPlaying_Assertion` = '+', 0, 1),
                    r.`ST_at_PR_isPlaying_PositedAt` DESC,
                    r.`ST_at_PR_isPlaying_Reliability` DESC,
                    r.`ST_at_PR_isPlaying_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`ST_at_PR_isPlaying_Positor` = tp.positor
AND
    t.`ST_at_PR_isPlaying_Assertion` = '+'
AND
    t.`ST_at_PR_isPlaying_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tAC_parent_AC_child_PAT_having` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    `kPAT_having`.`PAT_ParentalType` AS `having_PAT_ParentalType`,
    `kPAT_having`.`Metadata_PAT` AS `having_Metadata_PAT`,
    t.`PAT_ID_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Positor`,
    t.`AC_parent_AC_child_PAT_having_Reliability`,
    t.`AC_parent_AC_child_PAT_having_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rAC_parent_AC_child_PAT_having`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_parent_AC_child_PAT_having_Assertion` = coalesce(assertion, s.`AC_parent_AC_child_PAT_having_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_parent_AC_child_PAT_having_Positor`,
                s.`AC_ID_parent`,
                s.`AC_ID_child`,
                s.`PAT_ID_having`
            ORDER BY
                s.`AC_parent_AC_child_PAT_having_PositedAt` DESC,
                s.`AC_parent_AC_child_PAT_having_Reliability` DESC,
                s.`AC_parent_AC_child_PAT_having_ID` DESC
        ) = 1
) t
LEFT JOIN
    public.`PAT_ParentalType` `kPAT_having`
ON
    `kPAT_having`.`PAT_ID` = t.`PAT_ID_having`
WHERE
    t.`AC_parent_AC_child_PAT_having_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_parent_AC_child_PAT_having` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_parent_AC_child_PAT_having`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_parent_AC_child_PAT_having` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_parent_AC_child_PAT_having`,
    t.`AC_ID_parent`,
    t.`AC_ID_child`,
    t.`having_PAT_ParentalType`,
    t.`having_Metadata_PAT`,
    t.`PAT_ID_having`,
    t.`AC_parent_AC_child_PAT_having_PositedAt`,
    t.`AC_parent_AC_child_PAT_having_Positor`,
    t.`AC_parent_AC_child_PAT_having_Reliability`,
    t.`AC_parent_AC_child_PAT_having_Assertion`
FROM
    public.`_Positor` p,
    public.`tAC_parent_AC_child_PAT_having`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_parent_AC_child_PAT_having` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tAC_parent_AC_child_PAT_having`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`tPR_content_ST_location_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Positor`,
    t.`PR_content_ST_location_EV_of_Reliability`,
    t.`PR_content_ST_location_EV_of_Assertion`
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a
    -- window
    SELECT
        s.*
    FROM (
        SELECT
            r.*
        FROM
            public.`rPR_content_ST_location_EV_of`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`PR_content_ST_location_EV_of_Assertion` = coalesce(assertion, s.`PR_content_ST_location_EV_of_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`PR_content_ST_location_EV_of_Positor`,
                s.`EV_ID_of`
            ORDER BY
                s.`PR_content_ST_location_EV_of_PositedAt` DESC,
                s.`PR_content_ST_location_EV_of_Reliability` DESC,
                s.`PR_content_ST_location_EV_of_ID` DESC
        ) = 1
) t
WHERE
    t.`PR_content_ST_location_EV_of_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_content_ST_location_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tPR_content_ST_location_EV_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_PR_content_ST_location_EV_of`,
    t.`PR_ID_content`,
    t.`ST_ID_location`,
    t.`EV_ID_of`,
    t.`PR_content_ST_location_EV_of_PositedAt`,
    t.`PR_content_ST_location_EV_of_Positor`,
    t.`PR_content_ST_location_EV_of_Reliability`,
    t.`PR_content_ST_location_EV_of_Assertion`
FROM
    public.`_Positor` p,
    public.`tPR_content_ST_location_EV_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nPR_content_ST_location_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    public.`_Positor` p,
    public.`tPR_content_ST_location_EV_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
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
