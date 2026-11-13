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
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_DAT_Event_Date` (
    `EV_DAT_EV_ID` int64 not null,
    `EV_DAT_Event_Date` datetime not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Event_Date` FOREIGN KEY (`EV_DAT_EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_AUD_Event_Audience` (
    `EV_AUD_EV_ID` int64 not null,
    `EV_AUD_Event_Audience` int64 not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Event_Audience` FOREIGN KEY (`EV_AUD_EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_REV_Event_Revenue` (
    `EV_REV_EV_ID` int64 not null,
    `EV_REV_Event_Revenue` numeric(19,4) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Event_Revenue` FOREIGN KEY (`EV_REV_EV_ID`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_EV_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_NAM_Stage_Name` (
    `ST_NAM_ST_ID` int64 not null,
    `ST_NAM_Stage_Name` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Stage_Name` FOREIGN KEY (`ST_NAM_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ST_ID`, `ST_NAM_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS public.`ST_LOC_Stage_Location` (
    `ST_LOC_ST_ID` int64 not null,
    `ST_LOC_Stage_Location` geography not null,
    `ST_LOC_Checksum` int64,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Stage_Location` FOREIGN KEY (`ST_LOC_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ST_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Stage_Average table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_AVG_Stage_Average` (
    `ST_AVG_ST_ID` int64 not null,
    `ST_AVG_UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Stage_Average` FOREIGN KEY (`ST_AVG_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Stage_Average` FOREIGN KEY (`ST_AVG_UTL_ID`) REFERENCES
        public.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ST_ID`, `ST_AVG_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_MIN_Stage_Minimum` (
    `ST_MIN_ST_ID` int64 not null,
    `ST_MIN_UTL_ID` int64 not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Stage_Minimum` FOREIGN KEY (`ST_MIN_ST_ID`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Stage_Minimum` FOREIGN KEY (`ST_MIN_UTL_ID`) REFERENCES
        public.`UTL_Utilization`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ST_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_NAM_Actor_Name` (
    `AC_NAM_AC_ID` int64 not null,
    `AC_NAM_Actor_Name` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Actor_Name` FOREIGN KEY (`AC_NAM_AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_AC_ID`, `AC_NAM_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_GEN_Actor_Gender` (
    `AC_GEN_AC_ID` int64 not null,
    `AC_GEN_GEN_ID` int64 not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_AC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Actor_Gender` FOREIGN KEY (`AC_GEN_AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Actor_Gender` FOREIGN KEY (`AC_GEN_GEN_ID`) REFERENCES
        public.`GEN_Gender`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_AC_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_PLV_Actor_ProfessionalLevel` (
    `AC_PLV_AC_ID` int64 not null,
    `AC_PLV_PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Actor_ProfessionalLevel` FOREIGN KEY (`AC_PLV_AC_ID`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Actor_ProfessionalLevel` FOREIGN KEY (`AC_PLV_PLV_ID`) REFERENCES
        public.`PLV_ProfessionalLevel`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_AC_ID`, `AC_PLV_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_NAM_Program_Name` (
    `PR_NAM_PR_ID` int64 not null,
    `PR_NAM_Program_Name` string(42) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_PR_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Program_Name` FOREIGN KEY (`PR_NAM_PR_ID`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_PR_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Program_Length table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_LEN_Program_Length` (
    `PR_LEN_PR_ID` int64 not null,
    `PR_LEN_Program_Length` time not null,
    `PR_LEN_ChangedAt` date not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Program_Length` FOREIGN KEY (`PR_LEN_PR_ID`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
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
CREATE TABLE IF NOT EXISTS public.`AC_partner_AC_with_ONG_currently` (
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
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        public.`ONG_Ongoing`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_subset_PN_of` (
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_ID_subset`,
        `PN_ID_of`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        public.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_wasCast table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`EV_in_AC_wasCast` (
    `EV_ID_in` int64 not null, 
    `AC_ID_wasCast` int64 not null, 
    `Metadata_EV_in_AC_wasCast` int64 not null,
    PRIMARY KEY (
        `EV_ID_in`,
        `AC_ID_wasCast`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_wasCast_fkAC_wasCast` FOREIGN KEY (`AC_ID_wasCast`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_part_PR_in_RAT_got table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_part_PR_in_RAT_got` (
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
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_part_PR_in_RAT_got_fkRAT_got` FOREIGN KEY (`RAT_ID_got`) REFERENCES
        public.`RAT_Rating`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_part`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_isPlaying table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`ST_at_PR_isPlaying` (
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
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_isPlaying_fkPR_isPlaying` FOREIGN KEY (`PR_ID_isPlaying`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_parent_AC_child_PAT_having table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`AC_parent_AC_child_PAT_having` (
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
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkAC_child` FOREIGN KEY (`AC_ID_child`) REFERENCES
        public.`AC_Actor`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_parent_AC_child_PAT_having_fkPAT_having` FOREIGN KEY (`PAT_ID_having`) REFERENCES
        public.`PAT_ParentalType`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_parent`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- PR_content_ST_location_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.`PR_content_ST_location_EV_of` (
    `PR_ID_content` int64 not null, 
    `ST_ID_location` int64 not null, 
    `EV_ID_of` int64 not null, 
    `Metadata_PR_content_ST_location_EV_of` int64 not null,
    PRIMARY KEY (
        `EV_ID_of`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkPR_content` FOREIGN KEY (`PR_ID_content`) REFERENCES
        public.`PR_Program`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkST_location` FOREIGN KEY (`ST_ID_location`) REFERENCES
        public.`ST_Stage`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_content_ST_location_EV_of_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        public.`EV_Event`(`EV_ID`) NOT ENFORCED
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
-- rST_NAM_Stage_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_NAM_Stage_Name` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_NAM`,
        `ST_NAM_ST_ID`,
        `ST_NAM_Stage_Name`,
        `ST_NAM_ChangedAt`
    FROM
        public.`ST_NAM_Stage_Name`
    WHERE
        `ST_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Stage_Average rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rST_AVG_Stage_Average` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_AVG`,
        `ST_AVG_ST_ID`,
        `ST_AVG_UTL_ID`,
        `ST_AVG_ChangedAt`
    FROM
        public.`ST_AVG_Stage_Average`
    WHERE
        `ST_AVG_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Actor_Name rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_NAM_Actor_Name` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_NAM`,
        `AC_NAM_AC_ID`,
        `AC_NAM_Actor_Name`,
        `AC_NAM_ChangedAt`
    FROM
        public.`AC_NAM_Actor_Name`
    WHERE
        `AC_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Actor_ProfessionalLevel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rAC_PLV_Actor_ProfessionalLevel` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_PLV`,
        `AC_PLV_AC_ID`,
        `AC_PLV_PLV_ID`,
        `AC_PLV_ChangedAt`
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel`
    WHERE
        `AC_PLV_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Program_Length rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`rPR_LEN_Program_Length` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_PR_LEN`,
        `PR_LEN_PR_ID`,
        `PR_LEN_Program_Length`,
        `PR_LEN_ChangedAt`
    FROM
        public.`PR_LEN_Program_Length`
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
CREATE OR REPLACE VIEW public.`lST_Stage` (
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
    public.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`ST_NAM_Stage_Name` t
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
    public.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`ST_AVG_Stage_Average` t
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
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pST_Stage` (
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
    public.`ST_Stage` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rST_NAM_Stage_Name`(CAST(changingTimepoint AS datetime)) r
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
    public.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rST_AVG_Stage_Average`(CAST(changingTimepoint AS datetime)) r
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
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nST_Stage`
AS
SELECT
    *
FROM
    public.`pST_Stage`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dST_Stage` (
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
        public.`ST_NAM_Stage_Name` h
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
        public.`ST_AVG_Stage_Average` h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h.`ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`ST_Stage` `ST`
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
        public.`ST_NAM_Stage_Name` h
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
    public.`ST_LOC_Stage_Location` `LOC`
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
        public.`ST_AVG_Stage_Average` h
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
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_Actor` (
    `AC_ID`,
    `Metadata_AC`,
    `AC_NAM_AC_ID`,
    `Metadata_AC_NAM`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_Actor_Name` OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.'),
    `AC_GEN_AC_ID`,
    `Metadata_AC_GEN`,
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
    public.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`AC_NAM_Actor_Name` t
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
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel` t
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
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_Actor` (
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
    public.`AC_Actor` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rAC_NAM_Actor_Name`(CAST(changingTimepoint AS datetime)) r
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
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rAC_PLV_Actor_ProfessionalLevel`(CAST(changingTimepoint AS datetime)) r
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
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_Actor`
AS
SELECT
    *
FROM
    public.`pAC_Actor`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_Actor` (
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
        public.`AC_NAM_Actor_Name` h
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
        public.`AC_PLV_Actor_ProfessionalLevel` h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h.`AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`AC_Actor` `AC`
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
        public.`AC_NAM_Actor_Name` h
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
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
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
        public.`AC_PLV_Actor_ProfessionalLevel` h
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_Program` (
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
OPTIONS(description='A program, such as a play, show or concert, that can be played on stages.')
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
    public.`PR_Program` `PR`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        public.`PR_LEN_Program_Length` t
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
CREATE OR REPLACE TABLE FUNCTION public.`pPR_Program` (
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
    public.`PR_Program` `PR`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        public.`rPR_LEN_Program_Length`(CAST(changingTimepoint AS date)) r
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
CREATE OR REPLACE VIEW public.`nPR_Program`
AS
SELECT
    *
FROM
    public.`pPR_Program`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dPR_Program` (
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
        public.`PR_LEN_Program_Length` h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h.`PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public.`PR_Program` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
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
        public.`PR_LEN_Program_Length` h
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
CREATE OR REPLACE VIEW public.`lEV_Event` (
    `EV_ID`,
    `Metadata_EV`,
    `ST_ID_wasHeldAt` OPTIONS(description='The stage at which the event was held.'),
    `PR_ID_wasPlayed` OPTIONS(description='The program that was played at the event.'),
    `of_ETY_EventType` OPTIONS(description='The type of the event.'),
    `of_Metadata_ETY`,
    `ETY_ID_of` OPTIONS(description='The type of the event.'),
    `EV_DAT_EV_ID`,
    `Metadata_EV_DAT`,
    `EV_DAT_Event_Date` OPTIONS(description='Date and time when the event took place.'),
    `EV_AUD_EV_ID`,
    `Metadata_EV_AUD`,
    `EV_AUD_Event_Audience` OPTIONS(description='Number of people in the audience at the event.'),
    `EV_REV_EV_ID`,
    `Metadata_EV_REV`,
    `EV_REV_Event_Revenue` OPTIONS(description='Revenue from ticket sales for the event.')
)
OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.')
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
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
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
LEFT JOIN
    public.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    public.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
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
    `REV`.`EV_REV_Event_Revenue`
FROM
    public.`EV_Event` `EV`
LEFT JOIN
    public.`ETY_EventType` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    public.`EV_DAT_Event_Date` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_Event` AS
SELECT
    *
FROM
    public.`pEV_Event`(CAST(current_datetime() AS datetime))
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_partner_AC_with_ONG_currently` (
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
    public.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    public.`ONG_Ongoing` `ONG_currently`
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
CREATE OR REPLACE TABLE FUNCTION public.`pAC_partner_AC_with_ONG_currently` (
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
    public.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    public.`ONG_Ongoing` `ONG_currently`
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
CREATE OR REPLACE VIEW public.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    public.`pAC_partner_AC_with_ONG_currently`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_partner_AC_with_ONG_currently` (
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
    public.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    public.`ONG_Ongoing` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_subset_PN_of` (
    `Metadata_AC_subset_PN_of`,
    `AC_ID_subset` OPTIONS(description='The actor.'),
    `PN_ID_of` OPTIONS(description='The person who is the actor.')
)
OPTIONS(description='Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.')
AS
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    public.`AC_subset_PN_of` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    public.`AC_subset_PN_of` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    public.`pAC_subset_PN_of`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lEV_in_AC_wasCast` (
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
    public.`EV_in_AC_wasCast` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_in_AC_wasCast` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_EV_in_AC_wasCast`,
    tie.`EV_ID_in`,
    tie.`AC_ID_wasCast`
FROM
    public.`EV_in_AC_wasCast` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nEV_in_AC_wasCast` AS
SELECT
    *
FROM
    public.`pEV_in_AC_wasCast`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_part_PR_in_RAT_got` (
    `Metadata_AC_part_PR_in_RAT_got`,
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_ID_part` OPTIONS(description='The actor having a part in the program.'),
    `PR_ID_in` OPTIONS(description='The program the actor has a part in.'),
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
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    public.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    public.`RAT_Rating` `RAT_got`
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
CREATE OR REPLACE TABLE FUNCTION public.`pAC_part_PR_in_RAT_got` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    public.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    public.`RAT_Rating` `RAT_got`
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
CREATE OR REPLACE VIEW public.`nAC_part_PR_in_RAT_got` AS
SELECT
    *
FROM
    public.`pAC_part_PR_in_RAT_got`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dAC_part_PR_in_RAT_got` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_part_PR_in_RAT_got`,
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `got_RAT_Rating`,
    `RAT_got`.`Metadata_RAT` AS `got_Metadata_RAT`,
    tie.`RAT_ID_got`
FROM
    public.`AC_part_PR_in_RAT_got` tie
LEFT JOIN
    public.`RAT_Rating` `RAT_got`
ON
    `RAT_got`.`RAT_ID` = tie.`RAT_ID_got`
WHERE
    tie.`AC_part_PR_in_RAT_got_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lST_at_PR_isPlaying` (
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
    public.`ST_at_PR_isPlaying` tie
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
CREATE OR REPLACE TABLE FUNCTION public.`pST_at_PR_isPlaying` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_isPlaying`,
    tie.`ST_at_PR_isPlaying_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_isPlaying`
FROM
    public.`ST_at_PR_isPlaying` tie
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
CREATE OR REPLACE VIEW public.`nST_at_PR_isPlaying` AS
SELECT
    *
FROM
    public.`pST_at_PR_isPlaying`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`dST_at_PR_isPlaying` (
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
    public.`ST_at_PR_isPlaying` tie
WHERE
    tie.`ST_at_PR_isPlaying_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_parent_AC_child_PAT_having` (
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
    public.`AC_parent_AC_child_PAT_having` tie
LEFT JOIN
    public.`PAT_ParentalType` `PAT_having`
ON
    `PAT_having`.`PAT_ID` = tie.`PAT_ID_having`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_parent_AC_child_PAT_having` (
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
    public.`AC_parent_AC_child_PAT_having` tie
LEFT JOIN
    public.`PAT_ParentalType` `PAT_having`
ON
    `PAT_having`.`PAT_ID` = tie.`PAT_ID_having`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nAC_parent_AC_child_PAT_having` AS
SELECT
    *
FROM
    public.`pAC_parent_AC_child_PAT_having`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_content_ST_location_EV_of` (
    `Metadata_PR_content_ST_location_EV_of`,
    `PR_ID_content` OPTIONS(description='The program that made up the content of the event.'),
    `ST_ID_location` OPTIONS(description='The stage where the event was located.'),
    `EV_ID_of` OPTIONS(description='The event.')
)
OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.')
AS
SELECT
    tie.`Metadata_PR_content_ST_location_EV_of`,
    tie.`PR_ID_content`,
    tie.`ST_ID_location`,
    tie.`EV_ID_of`
FROM
    public.`PR_content_ST_location_EV_of` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pPR_content_ST_location_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_PR_content_ST_location_EV_of`,
    tie.`PR_ID_content`,
    tie.`ST_ID_location`,
    tie.`EV_ID_of`
FROM
    public.`PR_content_ST_location_EV_of` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`nPR_content_ST_location_EV_of` AS
SELECT
    *
FROM
    public.`pPR_content_ST_location_EV_of`(CAST(current_datetime() AS datetime))
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
-- EV_DAT_Event_Date integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_DAT_Event_Date` (
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
    public.`EV_DAT_Event_Date`
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
    public.`EV_DAT_Event_Date` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_DAT_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_DAT_EV_ID`
;
-- EV_AUD_Event_Audience integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_AUD_Event_Audience` (
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
    public.`EV_AUD_Event_Audience`
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
    public.`EV_AUD_Event_Audience` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_AUD_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_AUD_EV_ID`
;
-- EV_REV_Event_Revenue integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_REV_Event_Revenue` (
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
    public.`EV_REV_Event_Revenue`
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
    public.`EV_REV_Event_Revenue` c
LEFT JOIN
    public.`EV_Event` p
ON
    p.`EV_ID` = c.`EV_REV_EV_ID`
WHERE
    p.`EV_ID` IS NULL
GROUP BY
    c.`EV_REV_EV_ID`
;
-- ST_NAM_Stage_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_NAM_Stage_Name` (
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
    public.`ST_NAM_Stage_Name`
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
    public.`ST_NAM_Stage_Name` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_NAM_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_NAM_ST_ID`
;
-- ST_LOC_Stage_Location integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_LOC_Stage_Location` (
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
    public.`ST_LOC_Stage_Location`
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
    public.`ST_LOC_Stage_Location` c
LEFT JOIN
    public.`ST_Stage` p
ON
    p.`ST_ID` = c.`ST_LOC_ST_ID`
WHERE
    p.`ST_ID` IS NULL
GROUP BY
    c.`ST_LOC_ST_ID`
;
-- ST_AVG_Stage_Average integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_AVG_Stage_Average` (
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
    public.`ST_AVG_Stage_Average`
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
    public.`ST_AVG_Stage_Average` c
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
    'ST_AVG_Stage_Average',
    'no row in UTL_Utilization for ST_AVG_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_AVG_UTL_ID` AS `ST_AVG_UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_AVG_Stage_Average` c
LEFT JOIN
    public.`UTL_Utilization` p
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
        public.`ST_AVG_Stage_Average`
)
WHERE
    compared = previous
;
-- ST_MIN_Stage_Minimum integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_MIN_Stage_Minimum` (
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
    public.`ST_MIN_Stage_Minimum`
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
    public.`ST_MIN_Stage_Minimum` c
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
    'ST_MIN_Stage_Minimum',
    'no row in UTL_Utilization for ST_MIN_UTL_ID',
    TO_JSON_STRING(STRUCT(c.`ST_MIN_UTL_ID` AS `ST_MIN_UTL_ID`)),
    COUNT(*)
FROM
    public.`ST_MIN_Stage_Minimum` c
LEFT JOIN
    public.`UTL_Utilization` p
ON
    p.`UTL_ID` = c.`ST_MIN_UTL_ID`
WHERE
    p.`UTL_ID` IS NULL
GROUP BY
    c.`ST_MIN_UTL_ID`
;
-- AC_NAM_Actor_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_NAM_Actor_Name` (
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
    public.`AC_NAM_Actor_Name`
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
    public.`AC_NAM_Actor_Name` c
LEFT JOIN
    public.`AC_Actor` p
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
        public.`AC_NAM_Actor_Name`
)
WHERE
    compared = previous
;
-- AC_GEN_Actor_Gender integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_GEN_Actor_Gender` (
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
    public.`AC_GEN_Actor_Gender`
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
    public.`AC_GEN_Actor_Gender` c
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
    'AC_GEN_Actor_Gender',
    'no row in GEN_Gender for AC_GEN_GEN_ID',
    TO_JSON_STRING(STRUCT(c.`AC_GEN_GEN_ID` AS `AC_GEN_GEN_ID`)),
    COUNT(*)
FROM
    public.`AC_GEN_Actor_Gender` c
LEFT JOIN
    public.`GEN_Gender` p
ON
    p.`GEN_ID` = c.`AC_GEN_GEN_ID`
WHERE
    p.`GEN_ID` IS NULL
GROUP BY
    c.`AC_GEN_GEN_ID`
;
-- AC_PLV_Actor_ProfessionalLevel integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_PLV_Actor_ProfessionalLevel` (
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
    public.`AC_PLV_Actor_ProfessionalLevel`
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
    public.`AC_PLV_Actor_ProfessionalLevel` c
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
    'AC_PLV_Actor_ProfessionalLevel',
    'no row in PLV_ProfessionalLevel for AC_PLV_PLV_ID',
    TO_JSON_STRING(STRUCT(c.`AC_PLV_PLV_ID` AS `AC_PLV_PLV_ID`)),
    COUNT(*)
FROM
    public.`AC_PLV_Actor_ProfessionalLevel` c
LEFT JOIN
    public.`PLV_ProfessionalLevel` p
ON
    p.`PLV_ID` = c.`AC_PLV_PLV_ID`
WHERE
    p.`PLV_ID` IS NULL
GROUP BY
    c.`AC_PLV_PLV_ID`
;
-- PR_NAM_Program_Name integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_NAM_Program_Name` (
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
    public.`PR_NAM_Program_Name`
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
    public.`PR_NAM_Program_Name` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_NAM_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_NAM_PR_ID`
;
-- PR_LEN_Program_Length integrity ---------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_LEN_Program_Length` (
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
    public.`PR_LEN_Program_Length`
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
    public.`PR_LEN_Program_Length` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_LEN_PR_ID`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_LEN_PR_ID`
;
-- AC_partner_AC_with_ONG_currently integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_partner_AC_with_ONG_currently` (
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
    public.`AC_partner_AC_with_ONG_currently`
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
    public.`AC_partner_AC_with_ONG_currently`
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
    public.`AC_partner_AC_with_ONG_currently`
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
    public.`AC_partner_AC_with_ONG_currently` c
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
    'AC_partner_AC_with_ONG_currently',
    'no row in AC_Actor for AC_ID_with',
    TO_JSON_STRING(STRUCT(c.`AC_ID_with` AS `AC_ID_with`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently` c
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
    'AC_partner_AC_with_ONG_currently',
    'no row in ONG_Ongoing for ONG_ID_currently',
    TO_JSON_STRING(STRUCT(c.`ONG_ID_currently` AS `ONG_ID_currently`)),
    COUNT(*)
FROM
    public.`AC_partner_AC_with_ONG_currently` c
LEFT JOIN
    public.`ONG_Ongoing` p
ON
    p.`ONG_ID` = c.`ONG_ID_currently`
WHERE
    p.`ONG_ID` IS NULL
GROUP BY
    c.`ONG_ID_currently`
;
-- AC_subset_PN_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_subset_PN_of` (
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
    public.`AC_subset_PN_of`
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
    public.`AC_subset_PN_of`
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
    public.`AC_subset_PN_of`
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
    public.`AC_subset_PN_of` c
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
    'AC_subset_PN_of',
    'no row in PN_Person for PN_ID_of',
    TO_JSON_STRING(STRUCT(c.`PN_ID_of` AS `PN_ID_of`)),
    COUNT(*)
FROM
    public.`AC_subset_PN_of` c
LEFT JOIN
    public.`PN_Person` p
ON
    p.`PN_ID` = c.`PN_ID_of`
WHERE
    p.`PN_ID` IS NULL
GROUP BY
    c.`PN_ID_of`
;
-- EV_in_AC_wasCast integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_EV_in_AC_wasCast` (
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
    public.`EV_in_AC_wasCast`
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
    public.`EV_in_AC_wasCast` c
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
    'EV_in_AC_wasCast',
    'no row in AC_Actor for AC_ID_wasCast',
    TO_JSON_STRING(STRUCT(c.`AC_ID_wasCast` AS `AC_ID_wasCast`)),
    COUNT(*)
FROM
    public.`EV_in_AC_wasCast` c
LEFT JOIN
    public.`AC_Actor` p
ON
    p.`AC_ID` = c.`AC_ID_wasCast`
WHERE
    p.`AC_ID` IS NULL
GROUP BY
    c.`AC_ID_wasCast`
;
-- AC_part_PR_in_RAT_got integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_part_PR_in_RAT_got` (
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
    public.`AC_part_PR_in_RAT_got`
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
    public.`AC_part_PR_in_RAT_got` c
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
    'AC_part_PR_in_RAT_got',
    'no row in PR_Program for PR_ID_in',
    TO_JSON_STRING(STRUCT(c.`PR_ID_in` AS `PR_ID_in`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got` c
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
    'AC_part_PR_in_RAT_got',
    'no row in RAT_Rating for RAT_ID_got',
    TO_JSON_STRING(STRUCT(c.`RAT_ID_got` AS `RAT_ID_got`)),
    COUNT(*)
FROM
    public.`AC_part_PR_in_RAT_got` c
LEFT JOIN
    public.`RAT_Rating` p
ON
    p.`RAT_ID` = c.`RAT_ID_got`
WHERE
    p.`RAT_ID` IS NULL
GROUP BY
    c.`RAT_ID_got`
;
-- ST_at_PR_isPlaying integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_ST_at_PR_isPlaying` (
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
    public.`ST_at_PR_isPlaying`
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
    public.`ST_at_PR_isPlaying` c
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
    'ST_at_PR_isPlaying',
    'no row in PR_Program for PR_ID_isPlaying',
    TO_JSON_STRING(STRUCT(c.`PR_ID_isPlaying` AS `PR_ID_isPlaying`)),
    COUNT(*)
FROM
    public.`ST_at_PR_isPlaying` c
LEFT JOIN
    public.`PR_Program` p
ON
    p.`PR_ID` = c.`PR_ID_isPlaying`
WHERE
    p.`PR_ID` IS NULL
GROUP BY
    c.`PR_ID_isPlaying`
;
-- AC_parent_AC_child_PAT_having integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_AC_parent_AC_child_PAT_having` (
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
    public.`AC_parent_AC_child_PAT_having`
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
    public.`AC_parent_AC_child_PAT_having` c
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
    'AC_parent_AC_child_PAT_having',
    'no row in AC_Actor for AC_ID_child',
    TO_JSON_STRING(STRUCT(c.`AC_ID_child` AS `AC_ID_child`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having` c
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
    'AC_parent_AC_child_PAT_having',
    'no row in PAT_ParentalType for PAT_ID_having',
    TO_JSON_STRING(STRUCT(c.`PAT_ID_having` AS `PAT_ID_having`)),
    COUNT(*)
FROM
    public.`AC_parent_AC_child_PAT_having` c
LEFT JOIN
    public.`PAT_ParentalType` p
ON
    p.`PAT_ID` = c.`PAT_ID_having`
WHERE
    p.`PAT_ID` IS NULL
GROUP BY
    c.`PAT_ID_having`
;
-- PR_content_ST_location_EV_of integrity ---------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`ic_PR_content_ST_location_EV_of` (
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
        `EV_ID_of` AS `EV_ID_of`
    )),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of`
GROUP BY
    `EV_ID_of`
HAVING
    COUNT(*) > 1
UNION ALL
SELECT
    'PR_content_ST_location_EV_of',
    'no row in PR_Program for PR_ID_content',
    TO_JSON_STRING(STRUCT(c.`PR_ID_content` AS `PR_ID_content`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of` c
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
    'PR_content_ST_location_EV_of',
    'no row in ST_Stage for ST_ID_location',
    TO_JSON_STRING(STRUCT(c.`ST_ID_location` AS `ST_ID_location`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of` c
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
    'PR_content_ST_location_EV_of',
    'no row in EV_Event for EV_ID_of',
    TO_JSON_STRING(STRUCT(c.`EV_ID_of` AS `EV_ID_of`)),
    COUNT(*)
FROM
    public.`PR_content_ST_location_EV_of` c
LEFT JOIN
    public.`EV_Event` p
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
UNION ALL SELECT * FROM public.`ic_EV_DAT_Event_Date`
UNION ALL SELECT * FROM public.`ic_EV_AUD_Event_Audience`
UNION ALL SELECT * FROM public.`ic_EV_REV_Event_Revenue`
UNION ALL SELECT * FROM public.`ic_ST_NAM_Stage_Name`
UNION ALL SELECT * FROM public.`ic_ST_LOC_Stage_Location`
UNION ALL SELECT * FROM public.`ic_ST_AVG_Stage_Average`
UNION ALL SELECT * FROM public.`ic_ST_MIN_Stage_Minimum`
UNION ALL SELECT * FROM public.`ic_AC_NAM_Actor_Name`
UNION ALL SELECT * FROM public.`ic_AC_GEN_Actor_Gender`
UNION ALL SELECT * FROM public.`ic_AC_PLV_Actor_ProfessionalLevel`
UNION ALL SELECT * FROM public.`ic_PR_NAM_Program_Name`
UNION ALL SELECT * FROM public.`ic_PR_LEN_Program_Length`
UNION ALL SELECT * FROM public.`ic_AC_partner_AC_with_ONG_currently`
UNION ALL SELECT * FROM public.`ic_AC_subset_PN_of`
UNION ALL SELECT * FROM public.`ic_EV_in_AC_wasCast`
UNION ALL SELECT * FROM public.`ic_AC_part_PR_in_RAT_got`
UNION ALL SELECT * FROM public.`ic_ST_at_PR_isPlaying`
UNION ALL SELECT * FROM public.`ic_AC_parent_AC_child_PAT_having`
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
ALTER TABLE public.`EV_DAT_Event_Date` ALTER COLUMN `EV_DAT_Event_Date` SET OPTIONS(description='Date and time when the event took place.');
ALTER TABLE public.`EV_AUD_Event_Audience` ALTER COLUMN `EV_AUD_Event_Audience` SET OPTIONS(description='Number of people in the audience at the event.');
ALTER TABLE public.`EV_REV_Event_Revenue` ALTER COLUMN `EV_REV_Event_Revenue` SET OPTIONS(description='Revenue from ticket sales for the event.');
ALTER TABLE public.`ST_NAM_Stage_Name` ALTER COLUMN `ST_NAM_Stage_Name` SET OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.');
ALTER TABLE public.`ST_LOC_Stage_Location` ALTER COLUMN `ST_LOC_Stage_Location` SET OPTIONS(description='Geographic location of the stage as a geography point.');
ALTER TABLE public.`ST_AVG_Stage_Average` ALTER COLUMN `ST_AVG_UTL_ID` SET OPTIONS(description='Average utilization of the stage capacity, recalculated over time.');
ALTER TABLE public.`ST_MIN_Stage_Minimum` ALTER COLUMN `ST_MIN_UTL_ID` SET OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.');
ALTER TABLE public.`AC_NAM_Actor_Name` ALTER COLUMN `AC_NAM_Actor_Name` SET OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.');
ALTER TABLE public.`AC_GEN_Actor_Gender` ALTER COLUMN `AC_GEN_GEN_ID` SET OPTIONS(description='Gender of the actor.');
ALTER TABLE public.`AC_PLV_Actor_ProfessionalLevel` ALTER COLUMN `AC_PLV_PLV_ID` SET OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.');
ALTER TABLE public.`PR_NAM_Program_Name` ALTER COLUMN `PR_NAM_Program_Name` SET OPTIONS(description='Name or title of the program.');
ALTER TABLE public.`PR_LEN_Program_Length` ALTER COLUMN `PR_LEN_Program_Length` SET OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.');
ALTER TABLE public.`PN_Person` SET OPTIONS(description='A person. Persons who perform are also registered as actors.');
ALTER TABLE public.`ST_Stage` SET OPTIONS(description='A stage or venue where programs are played and events are held.');
ALTER TABLE public.`AC_Actor` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE public.`PR_Program` SET OPTIONS(description='A program, such as a play, show or concert, that can be played on stages.');
ALTER TABLE public.`EV_Event` SET OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.');
ALTER TABLE public.`EV_Event` ALTER COLUMN `ST_ID_wasHeldAt` SET OPTIONS(description='The stage at which the event was held.');
ALTER TABLE public.`EV_Event` ALTER COLUMN `PR_ID_wasPlayed` SET OPTIONS(description='The program that was played at the event.');
ALTER TABLE public.`EV_Event` ALTER COLUMN `ETY_ID_of` SET OPTIONS(description='The type of the event.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently` SET OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `AC_ID_partner` SET OPTIONS(description='One of the actors in the partnership.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `AC_ID_with` SET OPTIONS(description='The other actor in the partnership.');
ALTER TABLE public.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `ONG_ID_currently` SET OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).');
ALTER TABLE public.`AC_subset_PN_of` SET OPTIONS(description='Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.');
ALTER TABLE public.`AC_subset_PN_of` ALTER COLUMN `AC_ID_subset` SET OPTIONS(description='The actor.');
ALTER TABLE public.`AC_subset_PN_of` ALTER COLUMN `PN_ID_of` SET OPTIONS(description='The person who is the actor.');
ALTER TABLE public.`EV_in_AC_wasCast` SET OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.');
ALTER TABLE public.`EV_in_AC_wasCast` ALTER COLUMN `EV_ID_in` SET OPTIONS(description='The event the actor was cast in.');
ALTER TABLE public.`EV_in_AC_wasCast` ALTER COLUMN `AC_ID_wasCast` SET OPTIONS(description='An actor cast in the event.');
ALTER TABLE public.`AC_part_PR_in_RAT_got` SET OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.');
ALTER TABLE public.`AC_part_PR_in_RAT_got` ALTER COLUMN `AC_ID_part` SET OPTIONS(description='The actor having a part in the program.');
ALTER TABLE public.`AC_part_PR_in_RAT_got` ALTER COLUMN `PR_ID_in` SET OPTIONS(description='The program the actor has a part in.');
ALTER TABLE public.`AC_part_PR_in_RAT_got` ALTER COLUMN `RAT_ID_got` SET OPTIONS(description='The rating the actor got for the part.');
ALTER TABLE public.`ST_at_PR_isPlaying` SET OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.');
ALTER TABLE public.`ST_at_PR_isPlaying` ALTER COLUMN `ST_ID_at` SET OPTIONS(description='The stage where the program is playing.');
ALTER TABLE public.`ST_at_PR_isPlaying` ALTER COLUMN `PR_ID_isPlaying` SET OPTIONS(description='The program playing at the stage.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having` SET OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having` ALTER COLUMN `AC_ID_parent` SET OPTIONS(description='The actor who is the parent.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having` ALTER COLUMN `AC_ID_child` SET OPTIONS(description='The actor who is the child.');
ALTER TABLE public.`AC_parent_AC_child_PAT_having` ALTER COLUMN `PAT_ID_having` SET OPTIONS(description='The type of parental relationship.');
ALTER TABLE public.`PR_content_ST_location_EV_of` SET OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.');
ALTER TABLE public.`PR_content_ST_location_EV_of` ALTER COLUMN `PR_ID_content` SET OPTIONS(description='The program that made up the content of the event.');
ALTER TABLE public.`PR_content_ST_location_EV_of` ALTER COLUMN `ST_ID_location` SET OPTIONS(description='The stage where the event was located.');
ALTER TABLE public.`PR_content_ST_location_EV_of` ALTER COLUMN `EV_ID_of` SET OPTIONS(description='The event.');
