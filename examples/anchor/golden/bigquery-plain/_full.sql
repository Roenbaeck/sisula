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
    `EV_Dummy` bool,
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
        `ST_ID`,
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
        `ST_ID`,
        `UTL_ID`,
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
        `AC_ID`,
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
        `AC_ID`,
        `PLV_ID`,
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
        `PR_ID`,
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
    `ST_NAM_ChangedAt`,
    `ST_NAM_Stage_Name` OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.'),
    `ST_LOC_Checksum`,
    `ST_LOC_Stage_Location` OPTIONS(description='Geographic location of the stage as a geography point.'),
    `ST_AVG_ChangedAt`,
    `UTL_Utilization` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `UTL_ID` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `UTL_Utilization` OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.'),
    `UTL_ID` OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.')
)
OPTIONS(description='A stage or venue where programs are played and events are held.')
AS
SELECT
    `ST`.`ST_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
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
            PARTITION BY t.`ST_ID`
            ORDER BY t.`ST_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_ID` = `ST`.`ST_ID`
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
            PARTITION BY t.`ST_ID`
            ORDER BY t.`ST_AVG_ChangedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pST_Stage` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
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
            PARTITION BY r.`ST_ID`
            ORDER BY r.`ST_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`ST_LOC_Stage_Location` `LOC`
ON
    `LOC`.`ST_ID` = `ST`.`ST_ID`
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
            PARTITION BY r.`ST_ID`
            ORDER BY r.`ST_AVG_ChangedAt` DESC
        ) = 1
) `AVG`
ON
    `AVG`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`
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
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Stage_Name`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Stage_Location`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utilization` AS `UTL_Utilization`,
    `AVG`.`UTL_ID`,
    `kMIN`.`UTL_Utilization` AS `UTL_Utilization`,
    `MIN`.`UTL_ID`
FROM (
    SELECT DISTINCT
        h.`ST_ID` AS `ST_ID`,
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
        h.`ST_ID` AS `ST_ID`,
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
            PARTITION BY h.`ST_ID`
            ORDER BY h.`ST_NAM_ChangedAt`
        ) AS `until`
    FROM
        public.`ST_NAM_Stage_Name` h
) `NAM`
ON
    `NAM`.`ST_ID` = `ST`.`ST_ID`
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
    `LOC`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`ST_AVG_ChangedAt`) OVER (
            PARTITION BY h.`ST_ID`
            ORDER BY h.`ST_AVG_ChangedAt`
        ) AS `until`
    FROM
        public.`ST_AVG_Stage_Average` h
) `AVG`
ON
    `AVG`.`ST_ID` = `ST`.`ST_ID`
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
    `kAVG`.`UTL_ID` = `AVG`.`UTL_ID`
LEFT JOIN
    public.`ST_MIN_Stage_Minimum` `MIN`
ON
    `MIN`.`ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    public.`UTL_Utilization` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`UTL_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lAC_Actor` (
    `AC_ID`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_Actor_Name` OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.'),
    `GEN_Gender` OPTIONS(description='Gender of the actor.'),
    `GEN_ID` OPTIONS(description='Gender of the actor.'),
    `AC_PLV_ChangedAt`,
    `PLV_Checksum`,
    `PLV_ProfessionalLevel` OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.'),
    `PLV_ID` OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.')
)
OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.')
AS
SELECT
    `AC`.`AC_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
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
            PARTITION BY t.`AC_ID`
            ORDER BY t.`AC_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
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
            PARTITION BY t.`AC_ID`
            ORDER BY t.`AC_PLV_ChangedAt` DESC
        ) = 1
) `PLV`
ON
    `PLV`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pAC_Actor` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
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
            PARTITION BY r.`AC_ID`
            ORDER BY r.`AC_NAM_ChangedAt` DESC
        ) = 1
) `NAM`
ON
    `NAM`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`AC_GEN_Actor_Gender` `GEN`
ON
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
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
            PARTITION BY r.`AC_ID`
            ORDER BY r.`AC_PLV_ChangedAt` DESC
        ) = 1
) `PLV`
ON
    `PLV`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`PLV_ProfessionalLevel` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`PLV_ID`
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
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Actor_Name`,
    `kGEN`.`GEN_Gender` AS `GEN_Gender`,
    `GEN`.`GEN_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `PLV_Checksum`,
    `kPLV`.`PLV_ProfessionalLevel` AS `PLV_ProfessionalLevel`,
    `PLV`.`PLV_ID`
FROM (
    SELECT DISTINCT
        h.`AC_ID` AS `AC_ID`,
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
        h.`AC_ID` AS `AC_ID`,
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
            PARTITION BY h.`AC_ID`
            ORDER BY h.`AC_NAM_ChangedAt`
        ) AS `until`
    FROM
        public.`AC_NAM_Actor_Name` h
) `NAM`
ON
    `NAM`.`AC_ID` = `AC`.`AC_ID`
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
    `GEN`.`AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    public.`GEN_Gender` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`GEN_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`AC_PLV_ChangedAt`) OVER (
            PARTITION BY h.`AC_ID`
            ORDER BY h.`AC_PLV_ChangedAt`
        ) AS `until`
    FROM
        public.`AC_PLV_Actor_ProfessionalLevel` h
) `PLV`
ON
    `PLV`.`AC_ID` = `AC`.`AC_ID`
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
    `kPLV`.`PLV_ID` = `PLV`.`PLV_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.`lPR_Program` (
    `PR_ID`,
    `PR_NAM_Program_Name` OPTIONS(description='Name or title of the program.'),
    `PR_LEN_ChangedAt`,
    `PR_LEN_Program_Length` OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.')
)
OPTIONS(description='A program, such as a play, show or concert, that can be played on stages.')
AS
SELECT
    `PR`.`PR_ID`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`PR_Program` `PR`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_ID` = `PR`.`PR_ID`
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
            PARTITION BY t.`PR_ID`
            ORDER BY t.`PR_LEN_ChangedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_ID` = `PR`.`PR_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pPR_Program` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM
    public.`PR_Program` `PR`
LEFT JOIN
    public.`PR_NAM_Program_Name` `NAM`
ON
    `NAM`.`PR_ID` = `PR`.`PR_ID`
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
            PARTITION BY r.`PR_ID`
            ORDER BY r.`PR_LEN_ChangedAt` DESC
        ) = 1
) `LEN`
ON
    `LEN`.`PR_ID` = `PR`.`PR_ID`
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
    `NAM`.`PR_NAM_Program_Name`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Program_Length`
FROM (
    SELECT DISTINCT
        h.`PR_ID` AS `PR_ID`,
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
    `NAM`.`PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`PR_LEN_ChangedAt`) OVER (
            PARTITION BY h.`PR_ID`
            ORDER BY h.`PR_LEN_ChangedAt`
        ) AS `until`
    FROM
        public.`PR_LEN_Program_Length` h
) `LEN`
ON
    `LEN`.`PR_ID` = `PR`.`PR_ID`
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
    `ST_ID_wasHeldAt` OPTIONS(description='The stage at which the event was held.'),
    `PR_ID_wasPlayed` OPTIONS(description='The program that was played at the event.'),
    `ETY_EventType` OPTIONS(description='The type of the event.'),
    `ETY_ID_of` OPTIONS(description='The type of the event.'),
    `EV_DAT_Event_Date` OPTIONS(description='Date and time when the event took place.'),
    `EV_AUD_Event_Audience` OPTIONS(description='Number of people in the audience at the event.'),
    `EV_REV_Event_Revenue` OPTIONS(description='Revenue from ticket sales for the event.')
)
OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.')
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_EventType` AS `ETY_EventType`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_Event_Audience`,
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
    `DAT`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_ID` = `EV`.`EV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION public.`pEV_Event` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`ST_ID_wasHeldAt`,
    `EV`.`PR_ID_wasPlayed`,
    `ETY_of`.`ETY_EventType` AS `ETY_EventType`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_Event_Date`,
    `AUD`.`EV_AUD_Event_Audience`,
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
    `DAT`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_AUD_Event_Audience` `AUD`
ON
    `AUD`.`EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    public.`EV_REV_Event_Revenue` `REV`
ON
    `REV`.`EV_ID` = `EV`.`EV_ID`
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
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_ID_partner` OPTIONS(description='One of the actors in the partnership.'),
    `AC_ID_with` OPTIONS(description='The other actor in the partnership.'),
    `ONG_Ongoing` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).'),
    `ONG_ID_currently` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).')
)
OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.')
AS
SELECT
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `ONG_Ongoing`,
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
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `ONG_Ongoing`,
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
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Ongoing` AS `ONG_Ongoing`,
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
    `AC_ID_subset` OPTIONS(description='The actor.'),
    `PN_ID_of` OPTIONS(description='The person who is the actor.')
)
OPTIONS(description='Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.')
AS
SELECT
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
    `EV_ID_in` OPTIONS(description='The event the actor was cast in.'),
    `AC_ID_wasCast` OPTIONS(description='An actor cast in the event.')
)
OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.')
AS
SELECT
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
    `AC_part_PR_in_RAT_got_ChangedAt`,
    `AC_ID_part` OPTIONS(description='The actor having a part in the program.'),
    `PR_ID_in` OPTIONS(description='The program the actor has a part in.'),
    `RAT_Rating` OPTIONS(description='The rating the actor got for the part.'),
    `RAT_ID_got` OPTIONS(description='The rating the actor got for the part.')
)
OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.')
AS
SELECT
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `RAT_Rating`,
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
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `RAT_Rating`,
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
    tie.`AC_part_PR_in_RAT_got_ChangedAt`,
    tie.`AC_ID_part`,
    tie.`PR_ID_in`,
    `RAT_got`.`RAT_Rating` AS `RAT_Rating`,
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
    `ST_at_PR_isPlaying_ChangedAt`,
    `ST_ID_at` OPTIONS(description='The stage where the program is playing.'),
    `PR_ID_isPlaying` OPTIONS(description='The program playing at the stage.')
)
OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.')
AS
SELECT
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
    `AC_ID_parent` OPTIONS(description='The actor who is the parent.'),
    `AC_ID_child` OPTIONS(description='The actor who is the child.'),
    `PAT_ParentalType` OPTIONS(description='The type of parental relationship.'),
    `PAT_ID_having` OPTIONS(description='The type of parental relationship.')
)
OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.')
AS
SELECT
    tie.`AC_ID_parent`,
    tie.`AC_ID_child`,
    `PAT_having`.`PAT_ParentalType` AS `PAT_ParentalType`,
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
    tie.`AC_ID_parent`,
    tie.`AC_ID_child`,
    `PAT_having`.`PAT_ParentalType` AS `PAT_ParentalType`,
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
    `PR_ID_content` OPTIONS(description='The program that made up the content of the event.'),
    `ST_ID_location` OPTIONS(description='The stage where the event was located.'),
    `EV_ID_of` OPTIONS(description='The event.')
)
OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.')
AS
SELECT
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
ALTER TABLE public.`ST_AVG_Stage_Average` ALTER COLUMN `UTL_ID` SET OPTIONS(description='Average utilization of the stage capacity, recalculated over time.');
ALTER TABLE public.`ST_MIN_Stage_Minimum` ALTER COLUMN `UTL_ID` SET OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.');
ALTER TABLE public.`AC_NAM_Actor_Name` ALTER COLUMN `AC_NAM_Actor_Name` SET OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.');
ALTER TABLE public.`AC_GEN_Actor_Gender` ALTER COLUMN `GEN_ID` SET OPTIONS(description='Gender of the actor.');
ALTER TABLE public.`AC_PLV_Actor_ProfessionalLevel` ALTER COLUMN `PLV_ID` SET OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.');
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
