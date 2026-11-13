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
-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw.`_Positor` (
    `Positor` int64 not null,
    PRIMARY KEY (
        `Positor`
    ) NOT ENFORCED
);
MERGE INTO dw.`_Positor` p
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
-- PAT_Föräldratyp table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.`PAT_Föräldratyp` (
    `PAT_ID` int64 not null,
    `PAT_Föräldratyp` string(42) not null,
    `Metadata_PAT` int64 not null,
    PRIMARY KEY (
        `PAT_ID`
    ) NOT ENFORCED
)
CLUSTER BY `PAT_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Kön table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`GEN_Kön` (
    `GEN_ID` int64 not null,
    `GEN_Kön` string(42) not null,
    `GEN_Checksum` int64,
    `Metadata_GEN` int64 not null,
    PRIMARY KEY (
        `GEN_ID`
    ) NOT ENFORCED
)
CLUSTER BY `GEN_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_Yrkesnivå table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`PLV_Yrkesnivå` (
    `PLV_ID` int64 not null,
    `PLV_Yrkesnivå` string not null,
    `PLV_Checksum` int64,
    `Metadata_PLV` int64 not null,
    PRIMARY KEY (
        `PLV_ID`
    ) NOT ENFORCED
)
CLUSTER BY `PLV_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utnyttjande table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.`UTL_Utnyttjande` (
    `UTL_ID` int64 not null,
    `UTL_Utnyttjande` int64 not null,
    `Metadata_UTL` int64 not null,
    PRIMARY KEY (
        `UTL_ID`
    ) NOT ENFORCED
)
CLUSTER BY `UTL_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Pågående table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots.`ONG_Pågående` (
    `ONG_ID` int64 not null,
    `ONG_Pågående` string(3) not null,
    `Metadata_ONG` int64 not null,
    PRIMARY KEY (
        `ONG_ID`
    ) NOT ENFORCED
)
CLUSTER BY `ONG_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Betyg table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`RAT_Betyg` (
    `RAT_ID` int64 not null,
    `RAT_Betyg` string(42) not null,
    `RAT_Checksum` int64,
    `Metadata_RAT` int64 not null,
    PRIMARY KEY (
        `RAT_ID`
    ) NOT ENFORCED
)
CLUSTER BY `RAT_ID`;
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_Händelsetyp table
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS knots.`ETY_Händelsetyp` (
    `ETY_ID` int64 not null,
    `ETY_Händelsetyp` string(42) not null,
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
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`ST_Scen` (
    `ST_ID` int64 not null,
    `Metadata_ST` int64 not null,
    PRIMARY KEY (
        `ST_ID`
    ) NOT ENFORCED
)
CLUSTER BY `ST_ID`;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`AC_Skådespelare` (
    `AC_ID` int64 not null,
    `Metadata_AC` int64 not null,
    PRIMARY KEY (
        `AC_ID`
    ) NOT ENFORCED
)
CLUSTER BY `AC_ID`;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`PR_Föreställning` (
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
-- EV_Händelse table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses.`EV_Händelse` (
    `EV_ID` numeric(12,0) not null,
    `ST_ID_hölls` int64 not null, 
    `PR_ID_spelades` int64 not null, 
    `ETY_ID_of` int64 not null,
    `Metadata_EV` int64 not null, 
    PRIMARY KEY (
        `EV_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_Händelse_fkST_hölls` FOREIGN KEY (`ST_ID_hölls`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Händelse_fkPR_spelades` FOREIGN KEY (`PR_ID_spelades`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_Händelse_fkETY_of` FOREIGN KEY (`ETY_ID_of`) REFERENCES
        knots.`ETY_Händelsetyp`(`ETY_ID`) NOT ENFORCED
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
-- EV_DAT_Händelse_Datum_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Händelse_Datum_Posit` (
    `EV_DAT_ID` int64 not null,
    `EV_DAT_EV_ID` numeric(12,0) not null,
    `EV_DAT_Händelse_Datum` datetime not null,
    PRIMARY KEY (
        `EV_DAT_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Händelse_Datum_Posit` FOREIGN KEY (`EV_DAT_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum_Annex table (of EV_DAT_Händelse_Datum_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Händelse_Datum_Annex` (
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
    CONSTRAINT `fkEV_DAT_Händelse_Datum_Annex` FOREIGN KEY (`EV_DAT_ID`) REFERENCES
        attributes.`EV_DAT_Händelse_Datum_Posit`(`EV_DAT_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_ID`, `EV_DAT_Positor`, `EV_DAT_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Händelse_Publik_Posit` (
    `EV_AUD_ID` int64 not null,
    `EV_AUD_EV_ID` numeric(12,0) not null,
    `EV_AUD_Händelse_Publik` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Händelse_Publik_Posit` FOREIGN KEY (`EV_AUD_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Annex table (of EV_AUD_Händelse_Publik_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Händelse_Publik_Annex` (
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
    CONSTRAINT `fkEV_AUD_Händelse_Publik_Annex` FOREIGN KEY (`EV_AUD_ID`) REFERENCES
        attributes.`EV_AUD_Händelse_Publik_Posit`(`EV_AUD_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_ID`, `EV_AUD_Positor`, `EV_AUD_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Händelse_Intäkt_Posit` (
    `EV_REV_ID` int64 not null,
    `EV_REV_EV_ID` numeric(12,0) not null,
    `EV_REV_Händelse_Intäkt` numeric(19,4) not null,
    PRIMARY KEY (
        `EV_REV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Händelse_Intäkt_Posit` FOREIGN KEY (`EV_REV_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Annex table (of EV_REV_Händelse_Intäkt_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Händelse_Intäkt_Annex` (
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
    CONSTRAINT `fkEV_REV_Händelse_Intäkt_Annex` FOREIGN KEY (`EV_REV_ID`) REFERENCES
        attributes.`EV_REV_Händelse_Intäkt_Posit`(`EV_REV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_ID`, `EV_REV_Positor`, `EV_REV_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Händelse_Status_Posit` (
    `EV_STA_ID` int64 not null,
    `EV_STA_EV_ID` numeric(12,0) not null,
    `EV_STA_Händelse_Status` string(20) not null,
    `EV_STA_ChangedAt` datetime not null,
    PRIMARY KEY (
        `EV_STA_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Händelse_Status_Posit` FOREIGN KEY (`EV_STA_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Annex table (of EV_STA_Händelse_Status_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Händelse_Status_Annex` (
    `EV_STA_ID` int64 not null,
    `EV_STA_PositedAt` datetime not null,
    `EV_STA_Positor` int64 not null,
    `EV_STA_Reliability` numeric(5,2) not null,
    `Metadata_EV_STA` int64 not null,
    PRIMARY KEY (
        `EV_STA_ID`,
        `EV_STA_Positor`,
        `EV_STA_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Händelse_Status_Annex` FOREIGN KEY (`EV_STA_ID`) REFERENCES
        attributes.`EV_STA_Händelse_Status_Posit`(`EV_STA_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_ID`, `EV_STA_Positor`, `EV_STA_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Händelse_Utnyttjande_Posit` (
    `EV_UTL_ID` int64 not null,
    `EV_UTL_EV_ID` numeric(12,0) not null,
    `EV_UTL_UTL_ID` int64 not null,
    PRIMARY KEY (
        `EV_UTL_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_UTL_Händelse_Utnyttjande_Posit` FOREIGN KEY (`EV_UTL_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_UTL_Händelse_Utnyttjande_Posit` FOREIGN KEY (`EV_UTL_UTL_ID`) REFERENCES
        knots.`UTL_Utnyttjande`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Annex table (of EV_UTL_Händelse_Utnyttjande_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Händelse_Utnyttjande_Annex` (
    `EV_UTL_ID` int64 not null,
    `EV_UTL_PositedAt` datetime not null,
    `EV_UTL_Positor` int64 not null,
    `EV_UTL_Reliability` numeric(5,2) not null,
    `Metadata_EV_UTL` int64 not null,
    PRIMARY KEY (
        `EV_UTL_ID`,
        `EV_UTL_Positor`,
        `EV_UTL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_UTL_Händelse_Utnyttjande_Annex` FOREIGN KEY (`EV_UTL_ID`) REFERENCES
        attributes.`EV_UTL_Händelse_Utnyttjande_Posit`(`EV_UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_ID`, `EV_UTL_Positor`, `EV_UTL_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Händelse_Level_Posit` (
    `EV_LVL_ID` int64 not null,
    `EV_LVL_EV_ID` numeric(12,0) not null,
    `EV_LVL_PLV_ID` int64 not null,
    `EV_LVL_ChangedAt` date not null,
    PRIMARY KEY (
        `EV_LVL_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_LVL_Händelse_Level_Posit` FOREIGN KEY (`EV_LVL_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_LVL_Händelse_Level_Posit` FOREIGN KEY (`EV_LVL_PLV_ID`) REFERENCES
        knots.`PLV_Yrkesnivå`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_EV_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Annex table (of EV_LVL_Händelse_Level_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Händelse_Level_Annex` (
    `EV_LVL_ID` int64 not null,
    `EV_LVL_PositedAt` datetime not null,
    `EV_LVL_Positor` int64 not null,
    `EV_LVL_Reliability` numeric(5,2) not null,
    `Metadata_EV_LVL` int64 not null,
    PRIMARY KEY (
        `EV_LVL_ID`,
        `EV_LVL_Positor`,
        `EV_LVL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_LVL_Händelse_Level_Annex` FOREIGN KEY (`EV_LVL_ID`) REFERENCES
        attributes.`EV_LVL_Händelse_Level_Posit`(`EV_LVL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_ID`, `EV_LVL_Positor`, `EV_LVL_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Scen_Namn_Posit` (
    `ST_NAM_ID` int64 not null,
    `ST_NAM_ST_ID` int64 not null,
    `ST_NAM_Scen_Namn` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Scen_Namn_Posit` FOREIGN KEY (`ST_NAM_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Annex table (of ST_NAM_Scen_Namn_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Scen_Namn_Annex` (
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
    CONSTRAINT `fkST_NAM_Scen_Namn_Annex` FOREIGN KEY (`ST_NAM_ID`) REFERENCES
        attributes.`ST_NAM_Scen_Namn_Posit`(`ST_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ID`, `ST_NAM_Positor`, `ST_NAM_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Scen_Plats_Posit` (
    `ST_LOC_ID` int64 not null,
    `ST_LOC_ST_ID` int64 not null,
    `ST_LOC_Scen_Plats` geography not null,
    `ST_LOC_Checksum` int64,
    PRIMARY KEY (
        `ST_LOC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Scen_Plats_Posit` FOREIGN KEY (`ST_LOC_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Annex table (of ST_LOC_Scen_Plats_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Scen_Plats_Annex` (
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
    CONSTRAINT `fkST_LOC_Scen_Plats_Annex` FOREIGN KEY (`ST_LOC_ID`) REFERENCES
        attributes.`ST_LOC_Scen_Plats_Posit`(`ST_LOC_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ID`, `ST_LOC_Positor`, `ST_LOC_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Scen_Medel_Posit` (
    `ST_AVG_ID` int64 not null,
    `ST_AVG_ST_ID` int64 not null,
    `ST_AVG_UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_AVG_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Scen_Medel_Posit` FOREIGN KEY (`ST_AVG_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Scen_Medel_Posit` FOREIGN KEY (`ST_AVG_UTL_ID`) REFERENCES
        knots.`UTL_Utnyttjande`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Annex table (of ST_AVG_Scen_Medel_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Scen_Medel_Annex` (
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
    CONSTRAINT `fkST_AVG_Scen_Medel_Annex` FOREIGN KEY (`ST_AVG_ID`) REFERENCES
        attributes.`ST_AVG_Scen_Medel_Posit`(`ST_AVG_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ID`, `ST_AVG_Positor`, `ST_AVG_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Scen_Minimum_Posit` (
    `ST_MIN_ID` int64 not null,
    `ST_MIN_ST_ID` int64 not null,
    `ST_MIN_UTL_ID` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Scen_Minimum_Posit` FOREIGN KEY (`ST_MIN_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Scen_Minimum_Posit` FOREIGN KEY (`ST_MIN_UTL_ID`) REFERENCES
        knots.`UTL_Utnyttjande`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ST_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Annex table (of ST_MIN_Scen_Minimum_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Scen_Minimum_Annex` (
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
    CONSTRAINT `fkST_MIN_Scen_Minimum_Annex` FOREIGN KEY (`ST_MIN_ID`) REFERENCES
        attributes.`ST_MIN_Scen_Minimum_Posit`(`ST_MIN_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ID`, `ST_MIN_Positor`, `ST_MIN_PositedAt`;
-- AC_NAM_Skådespelare_Namn is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Skådespelare_Namn_Posit` (
    `AC_NAM_ID` int64 not null,
    `AC_NAM_AC_ID` int64 not null,
    `AC_NAM_Skådespelare_Namn` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Skådespelare_Namn_Posit` FOREIGN KEY (`AC_NAM_AC_ID`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Annex table (of AC_NAM_Skådespelare_Namn_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Skådespelare_Namn_Annex` (
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
    CONSTRAINT `fkAC_NAM_Skådespelare_Namn_Annex` FOREIGN KEY (`AC_NAM_ID`) REFERENCES
        attributes.`AC_NAM_Skådespelare_Namn_Posit`(`AC_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_ID`, `AC_NAM_Positor`, `AC_NAM_PositedAt`;
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Skådespelare_Kön_Posit` (
    `AC_GEN_ID` int64 not null,
    `AC_GEN_AC_ID` int64 not null,
    `AC_GEN_GEN_ID` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Skådespelare_Kön_Posit` FOREIGN KEY (`AC_GEN_AC_ID`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Skådespelare_Kön_Posit` FOREIGN KEY (`AC_GEN_GEN_ID`) REFERENCES
        knots.`GEN_Kön`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Annex table (of AC_GEN_Skådespelare_Kön_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Skådespelare_Kön_Annex` (
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
    CONSTRAINT `fkAC_GEN_Skådespelare_Kön_Annex` FOREIGN KEY (`AC_GEN_ID`) REFERENCES
        attributes.`AC_GEN_Skådespelare_Kön_Posit`(`AC_GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_ID`, `AC_GEN_Positor`, `AC_GEN_PositedAt`;
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Skådespelare_Yrkesnivå_Posit` (
    `AC_PLV_ID` int64 not null,
    `AC_PLV_AC_ID` int64 not null,
    `AC_PLV_PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_PLV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Skådespelare_Yrkesnivå_Posit` FOREIGN KEY (`AC_PLV_AC_ID`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Skådespelare_Yrkesnivå_Posit` FOREIGN KEY (`AC_PLV_PLV_ID`) REFERENCES
        knots.`PLV_Yrkesnivå`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_AC_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Annex table (of AC_PLV_Skådespelare_Yrkesnivå_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Skådespelare_Yrkesnivå_Annex` (
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
    CONSTRAINT `fkAC_PLV_Skådespelare_Yrkesnivå_Annex` FOREIGN KEY (`AC_PLV_ID`) REFERENCES
        attributes.`AC_PLV_Skådespelare_Yrkesnivå_Posit`(`AC_PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_ID`, `AC_PLV_Positor`, `AC_PLV_PositedAt`;
-- Static attribute posit table ---------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Föreställning_Namn_Posit` (
    `PR_NAM_ID` int64 not null,
    `PR_NAM_PR_ID` int64 not null,
    `PR_NAM_Föreställning_Namn` string(42) not null,
    PRIMARY KEY (
        `PR_NAM_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Föreställning_Namn_Posit` FOREIGN KEY (`PR_NAM_PR_ID`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Annex table (of PR_NAM_Föreställning_Namn_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Föreställning_Namn_Annex` (
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
    CONSTRAINT `fkPR_NAM_Föreställning_Namn_Annex` FOREIGN KEY (`PR_NAM_ID`) REFERENCES
        attributes.`PR_NAM_Föreställning_Namn_Posit`(`PR_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_ID`, `PR_NAM_Positor`, `PR_NAM_PositedAt`;
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Föreställning_Längd_Posit` (
    `PR_LEN_ID` int64 not null,
    `PR_LEN_PR_ID` int64 not null,
    `PR_LEN_Föreställning_Längd` time not null,
    `PR_LEN_ChangedAt` date not null,
    PRIMARY KEY (
        `PR_LEN_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Föreställning_Längd_Posit` FOREIGN KEY (`PR_LEN_PR_ID`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_PR_ID`;
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Annex table (of PR_LEN_Föreställning_Längd_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Föreställning_Längd_Annex` (
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
    CONSTRAINT `fkPR_LEN_Föreställning_Längd_Annex` FOREIGN KEY (`PR_LEN_ID`) REFERENCES
        attributes.`PR_LEN_Föreställning_Längd_Posit`(`PR_LEN_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_ID`, `PR_LEN_Positor`, `PR_LEN_PositedAt`;
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes.`EV_DAT_Händelse_Datum` AS
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Händelse_Datum`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Positor`,
    a.`EV_DAT_Reliability`,
    CASE
        WHEN a.`EV_DAT_Reliability` > 0 THEN '+'
        WHEN a.`EV_DAT_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_DAT_Assertion`
FROM
    attributes.`EV_DAT_Händelse_Datum_Posit` p
JOIN
    attributes.`EV_DAT_Händelse_Datum_Annex` a
ON
    a.`EV_DAT_ID` = p.`EV_DAT_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_AUD_Händelse_Publik` AS
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Händelse_Publik`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Positor`,
    a.`EV_AUD_Reliability`,
    CASE
        WHEN a.`EV_AUD_Reliability` > 0 THEN '+'
        WHEN a.`EV_AUD_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_AUD_Assertion`
FROM
    attributes.`EV_AUD_Händelse_Publik_Posit` p
JOIN
    attributes.`EV_AUD_Händelse_Publik_Annex` a
ON
    a.`EV_AUD_ID` = p.`EV_AUD_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_REV_Händelse_Intäkt` AS
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Händelse_Intäkt`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Positor`,
    a.`EV_REV_Reliability`,
    CASE
        WHEN a.`EV_REV_Reliability` > 0 THEN '+'
        WHEN a.`EV_REV_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_REV_Assertion`
FROM
    attributes.`EV_REV_Händelse_Intäkt_Posit` p
JOIN
    attributes.`EV_REV_Händelse_Intäkt_Annex` a
ON
    a.`EV_REV_ID` = p.`EV_REV_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_STA_Händelse_Status` AS
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Händelse_Status`,
    p.`EV_STA_ChangedAt`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Positor`,
    a.`EV_STA_Reliability`,
    CASE
        WHEN a.`EV_STA_Reliability` > 0 THEN '+'
        WHEN a.`EV_STA_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_STA_Assertion`
FROM
    attributes.`EV_STA_Händelse_Status_Posit` p
JOIN
    attributes.`EV_STA_Händelse_Status_Annex` a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_UTL_Händelse_Utnyttjande` AS
SELECT
    a.`Metadata_EV_UTL`,
    p.`EV_UTL_ID`,
    p.`EV_UTL_EV_ID`,
    p.`EV_UTL_UTL_ID`,
    a.`EV_UTL_PositedAt`,
    a.`EV_UTL_Positor`,
    a.`EV_UTL_Reliability`,
    CASE
        WHEN a.`EV_UTL_Reliability` > 0 THEN '+'
        WHEN a.`EV_UTL_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_UTL_Assertion`
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande_Posit` p
JOIN
    attributes.`EV_UTL_Händelse_Utnyttjande_Annex` a
ON
    a.`EV_UTL_ID` = p.`EV_UTL_ID`
;
CREATE OR REPLACE VIEW attributes.`EV_LVL_Händelse_Level` AS
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Positor`,
    a.`EV_LVL_Reliability`,
    CASE
        WHEN a.`EV_LVL_Reliability` > 0 THEN '+'
        WHEN a.`EV_LVL_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_LVL_Assertion`
FROM
    attributes.`EV_LVL_Händelse_Level_Posit` p
JOIN
    attributes.`EV_LVL_Händelse_Level_Annex` a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_NAM_Scen_Namn` AS
SELECT
    a.`Metadata_ST_NAM`,
    p.`ST_NAM_ID`,
    p.`ST_NAM_ST_ID`,
    p.`ST_NAM_Scen_Namn`,
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
    attributes.`ST_NAM_Scen_Namn_Posit` p
JOIN
    attributes.`ST_NAM_Scen_Namn_Annex` a
ON
    a.`ST_NAM_ID` = p.`ST_NAM_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_LOC_Scen_Plats` AS
SELECT
    a.`Metadata_ST_LOC`,
    p.`ST_LOC_ID`,
    p.`ST_LOC_ST_ID`,
    p.`ST_LOC_Checksum`,
    p.`ST_LOC_Scen_Plats`,
    a.`ST_LOC_PositedAt`,
    a.`ST_LOC_Positor`,
    a.`ST_LOC_Reliability`,
    CASE
        WHEN a.`ST_LOC_Reliability` > 0 THEN '+'
        WHEN a.`ST_LOC_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_LOC_Assertion`
FROM
    attributes.`ST_LOC_Scen_Plats_Posit` p
JOIN
    attributes.`ST_LOC_Scen_Plats_Annex` a
ON
    a.`ST_LOC_ID` = p.`ST_LOC_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_AVG_Scen_Medel` AS
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
    attributes.`ST_AVG_Scen_Medel_Posit` p
JOIN
    attributes.`ST_AVG_Scen_Medel_Annex` a
ON
    a.`ST_AVG_ID` = p.`ST_AVG_ID`
;
CREATE OR REPLACE VIEW attributes.`ST_MIN_Scen_Minimum` AS
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
    attributes.`ST_MIN_Scen_Minimum_Posit` p
JOIN
    attributes.`ST_MIN_Scen_Minimum_Annex` a
ON
    a.`ST_MIN_ID` = p.`ST_MIN_ID`
;
CREATE OR REPLACE VIEW attributes.`AC_NAM_Skådespelare_Namn` AS
SELECT
    a.`Metadata_AC_NAM`,
    p.`AC_NAM_ID`,
    p.`AC_NAM_AC_ID`,
    p.`AC_NAM_Skådespelare_Namn`,
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
    attributes.`AC_NAM_Skådespelare_Namn_Posit` p
JOIN
    attributes.`AC_NAM_Skådespelare_Namn_Annex` a
ON
    a.`AC_NAM_ID` = p.`AC_NAM_ID`
;
CREATE OR REPLACE VIEW attributes.`AC_GEN_Skådespelare_Kön` AS
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
    attributes.`AC_GEN_Skådespelare_Kön_Posit` p
JOIN
    attributes.`AC_GEN_Skådespelare_Kön_Annex` a
ON
    a.`AC_GEN_ID` = p.`AC_GEN_ID`
;
CREATE OR REPLACE VIEW attributes.`AC_PLV_Skådespelare_Yrkesnivå` AS
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
    attributes.`AC_PLV_Skådespelare_Yrkesnivå_Posit` p
JOIN
    attributes.`AC_PLV_Skådespelare_Yrkesnivå_Annex` a
ON
    a.`AC_PLV_ID` = p.`AC_PLV_ID`
;
CREATE OR REPLACE VIEW attributes.`PR_NAM_Föreställning_Namn` AS
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Föreställning_Namn`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Positor`,
    a.`PR_NAM_Reliability`,
    CASE
        WHEN a.`PR_NAM_Reliability` > 0 THEN '+'
        WHEN a.`PR_NAM_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_NAM_Assertion`
FROM
    attributes.`PR_NAM_Föreställning_Namn_Posit` p
JOIN
    attributes.`PR_NAM_Föreställning_Namn_Annex` a
ON
    a.`PR_NAM_ID` = p.`PR_NAM_ID`
;
CREATE OR REPLACE VIEW attributes.`PR_LEN_Föreställning_Längd` AS
SELECT
    a.`Metadata_PR_LEN`,
    p.`PR_LEN_ID`,
    p.`PR_LEN_PR_ID`,
    p.`PR_LEN_Föreställning_Längd`,
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
    attributes.`PR_LEN_Föreställning_Längd_Posit` p
JOIN
    attributes.`PR_LEN_Föreställning_Längd_Annex` a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Händelse_Datum_Annex` (
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
    attributes.`EV_DAT_Händelse_Datum_Annex`
WHERE
    `EV_DAT_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Händelse_Datum` (
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
    p.`EV_DAT_Händelse_Datum`
FROM
    attributes.`EV_DAT_Händelse_Datum_Posit` p
JOIN
    attributes.`rEV_DAT_Händelse_Datum_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Händelse_Publik_Annex` (
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
    attributes.`EV_AUD_Händelse_Publik_Annex`
WHERE
    `EV_AUD_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Händelse_Publik` (
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
    p.`EV_AUD_Händelse_Publik`
FROM
    attributes.`EV_AUD_Händelse_Publik_Posit` p
JOIN
    attributes.`rEV_AUD_Händelse_Publik_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Händelse_Intäkt_Annex` (
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
    attributes.`EV_REV_Händelse_Intäkt_Annex`
WHERE
    `EV_REV_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Händelse_Intäkt` (
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
    p.`EV_REV_Händelse_Intäkt`
FROM
    attributes.`EV_REV_Händelse_Intäkt_Posit` p
JOIN
    attributes.`rEV_REV_Händelse_Intäkt_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Händelse_Status_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV_STA_ID`,
    `EV_STA_EV_ID`,
    `EV_STA_Händelse_Status`,
    `EV_STA_ChangedAt`
FROM
    attributes.`EV_STA_Händelse_Status_Posit`
WHERE
    `EV_STA_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_STA_Händelse_Status_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV_STA_ID`,
    `EV_STA_EV_ID`,
    `EV_STA_Händelse_Status`,
    `EV_STA_ChangedAt`
FROM
    attributes.`EV_STA_Händelse_Status_Posit`
WHERE
    `EV_STA_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Händelse_Status_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_STA`,
    `EV_STA_ID`,
    `EV_STA_PositedAt`,
    `EV_STA_Positor`,
    `EV_STA_Reliability`,
    CASE
        WHEN `EV_STA_Reliability` > 0 THEN '+'
        WHEN `EV_STA_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_STA_Assertion`
FROM
    attributes.`EV_STA_Händelse_Status_Annex`
WHERE
    `EV_STA_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Händelse_Status` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Positor`,
    a.`EV_STA_Reliability`,
    CASE
        WHEN a.`EV_STA_Reliability` > 0 THEN '+'
        WHEN a.`EV_STA_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_STA_Assertion`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Händelse_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`rEV_STA_Händelse_Status_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Händelse_Status_Annex`(positingTimepoint) a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
AND
    a.`EV_STA_Positor` = coalesce(positor, a.`EV_STA_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_STA_ID`, a.`EV_STA_Positor`
        ORDER BY a.`EV_STA_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_STA_Händelse_Status` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Positor`,
    a.`EV_STA_Reliability`,
    CASE
        WHEN a.`EV_STA_Reliability` > 0 THEN '+'
        WHEN a.`EV_STA_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_STA_Assertion`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Händelse_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`fEV_STA_Händelse_Status_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Händelse_Status_Annex`(positingTimepoint) a
ON
    a.`EV_STA_ID` = p.`EV_STA_ID`
AND
    a.`EV_STA_Positor` = coalesce(positor, a.`EV_STA_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_STA_ID`, a.`EV_STA_Positor`
        ORDER BY a.`EV_STA_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_STA_Händelse_Status` (
    id numeric(12,0),
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`EV_STA_Händelse_Status`
FROM
    attributes.`rEV_STA_Händelse_Status`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_STA_EV_ID` = id
AND
    pre.`EV_STA_ChangedAt` < changingTimepoint
AND
    pre.`EV_STA_Assertion` = coalesce(assertion, pre.`EV_STA_Assertion`)
ORDER BY
    pre.`EV_STA_ChangedAt` DESC,
    pre.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_STA_Händelse_Status` (
    id numeric(12,0),
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`EV_STA_Händelse_Status`
FROM
    attributes.`fEV_STA_Händelse_Status`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_STA_EV_ID` = id
AND
    fol.`EV_STA_ChangedAt` > changingTimepoint
AND
    fol.`EV_STA_Assertion` = coalesce(assertion, fol.`EV_STA_Assertion`)
ORDER BY
    fol.`EV_STA_ChangedAt` ASC,
    fol.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Händelse_Utnyttjande_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_UTL`,
    `EV_UTL_ID`,
    `EV_UTL_PositedAt`,
    `EV_UTL_Positor`,
    `EV_UTL_Reliability`,
    CASE
        WHEN `EV_UTL_Reliability` > 0 THEN '+'
        WHEN `EV_UTL_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_UTL_Assertion`
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande_Annex`
WHERE
    `EV_UTL_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Händelse_Utnyttjande` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_UTL`,
    p.`EV_UTL_ID`,
    a.`EV_UTL_PositedAt`,
    a.`EV_UTL_Positor`,
    a.`EV_UTL_Reliability`,
    CASE
        WHEN a.`EV_UTL_Reliability` > 0 THEN '+'
        WHEN a.`EV_UTL_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_UTL_Assertion`,
    p.`EV_UTL_EV_ID`,
    p.`EV_UTL_UTL_ID`
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande_Posit` p
JOIN
    attributes.`rEV_UTL_Händelse_Utnyttjande_Annex`(positingTimepoint) a
ON
    a.`EV_UTL_ID` = p.`EV_UTL_ID`
AND
    a.`EV_UTL_Positor` = coalesce(positor, a.`EV_UTL_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_UTL_ID`, a.`EV_UTL_Positor`
        ORDER BY a.`EV_UTL_PositedAt` DESC
    ) = 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Händelse_Level_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `EV_LVL_ID`,
    `EV_LVL_EV_ID`,
    `EV_LVL_PLV_ID`,
    `EV_LVL_ChangedAt`
FROM
    attributes.`EV_LVL_Händelse_Level_Posit`
WHERE
    `EV_LVL_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_LVL_Händelse_Level_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `EV_LVL_ID`,
    `EV_LVL_EV_ID`,
    `EV_LVL_PLV_ID`,
    `EV_LVL_ChangedAt`
FROM
    attributes.`EV_LVL_Händelse_Level_Posit`
WHERE
    `EV_LVL_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Händelse_Level_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_LVL`,
    `EV_LVL_ID`,
    `EV_LVL_PositedAt`,
    `EV_LVL_Positor`,
    `EV_LVL_Reliability`,
    CASE
        WHEN `EV_LVL_Reliability` > 0 THEN '+'
        WHEN `EV_LVL_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_LVL_Assertion`
FROM
    attributes.`EV_LVL_Händelse_Level_Annex`
WHERE
    `EV_LVL_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Händelse_Level` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Positor`,
    a.`EV_LVL_Reliability`,
    CASE
        WHEN a.`EV_LVL_Reliability` > 0 THEN '+'
        WHEN a.`EV_LVL_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_LVL_Assertion`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`rEV_LVL_Händelse_Level_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Händelse_Level_Annex`(positingTimepoint) a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
AND
    a.`EV_LVL_Positor` = coalesce(positor, a.`EV_LVL_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_LVL_ID`, a.`EV_LVL_Positor`
        ORDER BY a.`EV_LVL_PositedAt` DESC
    ) = 1
)
;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_LVL_Händelse_Level` (
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Positor`,
    a.`EV_LVL_Reliability`,
    CASE
        WHEN a.`EV_LVL_Reliability` > 0 THEN '+'
        WHEN a.`EV_LVL_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_LVL_Assertion`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`fEV_LVL_Händelse_Level_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Händelse_Level_Annex`(positingTimepoint) a
ON
    a.`EV_LVL_ID` = p.`EV_LVL_ID`
AND
    a.`EV_LVL_Positor` = coalesce(positor, a.`EV_LVL_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_LVL_ID`, a.`EV_LVL_Positor`
        ORDER BY a.`EV_LVL_PositedAt` DESC
    ) = 1
)
;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_LVL_Händelse_Level` (
    id numeric(12,0),
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`EV_LVL_PLV_ID`
FROM
    attributes.`rEV_LVL_Händelse_Level`(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_LVL_EV_ID` = id
AND
    pre.`EV_LVL_ChangedAt` < changingTimepoint
AND
    pre.`EV_LVL_Assertion` = coalesce(assertion, pre.`EV_LVL_Assertion`)
ORDER BY
    pre.`EV_LVL_ChangedAt` DESC,
    pre.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_LVL_Händelse_Level` (
    id numeric(12,0),
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`EV_LVL_PLV_ID`
FROM
    attributes.`fEV_LVL_Händelse_Level`(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_LVL_EV_ID` = id
AND
    fol.`EV_LVL_ChangedAt` > changingTimepoint
AND
    fol.`EV_LVL_Assertion` = coalesce(assertion, fol.`EV_LVL_Assertion`)
ORDER BY
    fol.`EV_LVL_ChangedAt` ASC,
    fol.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Scen_Namn_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Scen_Namn`,
    `ST_NAM_ChangedAt`
FROM
    attributes.`ST_NAM_Scen_Namn_Posit`
WHERE
    `ST_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_NAM_Scen_Namn_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_NAM_ID`,
    `ST_NAM_ST_ID`,
    `ST_NAM_Scen_Namn`,
    `ST_NAM_ChangedAt`
FROM
    attributes.`ST_NAM_Scen_Namn_Posit`
WHERE
    `ST_NAM_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Scen_Namn_Annex` (
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
    attributes.`ST_NAM_Scen_Namn_Annex`
WHERE
    `ST_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Scen_Namn` (
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
    p.`ST_NAM_Scen_Namn`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`rST_NAM_Scen_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Scen_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_NAM_Scen_Namn` (
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
    p.`ST_NAM_Scen_Namn`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`fST_NAM_Scen_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Scen_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_NAM_Scen_Namn` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`ST_NAM_Scen_Namn`
FROM
    attributes.`rST_NAM_Scen_Namn`(positor, changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_NAM_Scen_Namn` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`ST_NAM_Scen_Namn`
FROM
    attributes.`fST_NAM_Scen_Namn`(positor, changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Scen_Plats_Annex` (
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
    attributes.`ST_LOC_Scen_Plats_Annex`
WHERE
    `ST_LOC_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Scen_Plats` (
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
    p.`ST_LOC_Scen_Plats`
FROM
    attributes.`ST_LOC_Scen_Plats_Posit` p
JOIN
    attributes.`rST_LOC_Scen_Plats_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Scen_Medel_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    attributes.`ST_AVG_Scen_Medel_Posit`
WHERE
    `ST_AVG_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_AVG_Scen_Medel_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_AVG_ID`,
    `ST_AVG_ST_ID`,
    `ST_AVG_UTL_ID`,
    `ST_AVG_ChangedAt`
FROM
    attributes.`ST_AVG_Scen_Medel_Posit`
WHERE
    `ST_AVG_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Scen_Medel_Annex` (
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
    attributes.`ST_AVG_Scen_Medel_Annex`
WHERE
    `ST_AVG_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Scen_Medel` (
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
    attributes.`rST_AVG_Scen_Medel_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Scen_Medel_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_AVG_Scen_Medel` (
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
    attributes.`fST_AVG_Scen_Medel_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Scen_Medel_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_AVG_Scen_Medel` (
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
    attributes.`rST_AVG_Scen_Medel`(positor, changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_AVG_Scen_Medel` (
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
    attributes.`fST_AVG_Scen_Medel`(positor, changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Scen_Minimum_Annex` (
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
    attributes.`ST_MIN_Scen_Minimum_Annex`
WHERE
    `ST_MIN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Scen_Minimum` (
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
    attributes.`ST_MIN_Scen_Minimum_Posit` p
JOIN
    attributes.`rST_MIN_Scen_Minimum_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Skådespelare_Namn_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Skådespelare_Namn`,
    `AC_NAM_ChangedAt`
FROM
    attributes.`AC_NAM_Skådespelare_Namn_Posit`
WHERE
    `AC_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_NAM_Skådespelare_Namn_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_NAM_ID`,
    `AC_NAM_AC_ID`,
    `AC_NAM_Skådespelare_Namn`,
    `AC_NAM_ChangedAt`
FROM
    attributes.`AC_NAM_Skådespelare_Namn_Posit`
WHERE
    `AC_NAM_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Skådespelare_Namn_Annex` (
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
    attributes.`AC_NAM_Skådespelare_Namn_Annex`
WHERE
    `AC_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Skådespelare_Namn` (
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
    p.`AC_NAM_Skådespelare_Namn`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`rAC_NAM_Skådespelare_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Skådespelare_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_NAM_Skådespelare_Namn` (
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
    p.`AC_NAM_Skådespelare_Namn`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`fAC_NAM_Skådespelare_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Skådespelare_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_NAM_Skådespelare_Namn` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`AC_NAM_Skådespelare_Namn`
FROM
    attributes.`rAC_NAM_Skådespelare_Namn`(positor, changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_NAM_Skådespelare_Namn` (
    id int64,
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`AC_NAM_Skådespelare_Namn`
FROM
    attributes.`fAC_NAM_Skådespelare_Namn`(positor, changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Skådespelare_Kön_Annex` (
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
    attributes.`AC_GEN_Skådespelare_Kön_Annex`
WHERE
    `AC_GEN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Skådespelare_Kön` (
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
    attributes.`AC_GEN_Skådespelare_Kön_Posit` p
JOIN
    attributes.`rAC_GEN_Skådespelare_Kön_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    attributes.`AC_PLV_Skådespelare_Yrkesnivå_Posit`
WHERE
    `AC_PLV_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_PLV_Skådespelare_Yrkesnivå_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_PLV_ID`,
    `AC_PLV_AC_ID`,
    `AC_PLV_PLV_ID`,
    `AC_PLV_ChangedAt`
FROM
    attributes.`AC_PLV_Skådespelare_Yrkesnivå_Posit`
WHERE
    `AC_PLV_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Annex` (
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
    attributes.`AC_PLV_Skådespelare_Yrkesnivå_Annex`
WHERE
    `AC_PLV_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Skådespelare_Yrkesnivå` (
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
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_PLV_Skådespelare_Yrkesnivå` (
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
    attributes.`fAC_PLV_Skådespelare_Yrkesnivå_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_PLV_Skådespelare_Yrkesnivå` (
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
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(positor, changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_PLV_Skådespelare_Yrkesnivå` (
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
    attributes.`fAC_PLV_Skådespelare_Yrkesnivå`(positor, changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Föreställning_Namn_Annex` (
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
    attributes.`PR_NAM_Föreställning_Namn_Annex`
WHERE
    `PR_NAM_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Föreställning_Namn` (
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
    p.`PR_NAM_Föreställning_Namn`
FROM
    attributes.`PR_NAM_Föreställning_Namn_Posit` p
JOIN
    attributes.`rPR_NAM_Föreställning_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Föreställning_Längd_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Föreställning_Längd`,
    `PR_LEN_ChangedAt`
FROM
    attributes.`PR_LEN_Föreställning_Längd_Posit`
WHERE
    `PR_LEN_ChangedAt` <= changingTimepoint
)
;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`fPR_LEN_Föreställning_Längd_Posit` (
    changingTimepoint date
)
AS (
SELECT
    `PR_LEN_ID`,
    `PR_LEN_PR_ID`,
    `PR_LEN_Föreställning_Längd`,
    `PR_LEN_ChangedAt`
FROM
    attributes.`PR_LEN_Föreställning_Längd_Posit`
WHERE
    `PR_LEN_ChangedAt` > changingTimepoint
)
;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Föreställning_Längd_Annex` (
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
    attributes.`PR_LEN_Föreställning_Längd_Annex`
WHERE
    `PR_LEN_PositedAt` <= positingTimepoint
)
;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Föreställning_Längd` (
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
    p.`PR_LEN_Föreställning_Längd`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`rPR_LEN_Föreställning_Längd_Posit`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Föreställning_Längd_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fPR_LEN_Föreställning_Längd` (
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
    p.`PR_LEN_Föreställning_Längd`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`fPR_LEN_Föreställning_Längd_Posit`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Föreställning_Längd_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`prePR_LEN_Föreställning_Längd` (
    id int64,
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    pre.`PR_LEN_Föreställning_Längd`
FROM
    attributes.`rPR_LEN_Föreställning_Längd`(positor, changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folPR_LEN_Föreställning_Längd` (
    id int64,
    positor int64,
    changingTimepoint date,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    fol.`PR_LEN_Föreställning_Längd`
FROM
    attributes.`fPR_LEN_Föreställning_Längd`(positor, changingTimepoint, positingTimepoint) fol
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
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently_Posit` (
    `AC_partner_AC_with_ONG_currently_ID` int64 not null,
    `AC_ID_partner` int64 not null, 
    `AC_ID_with` int64 not null, 
    `ONG_ID_currently` int64 not null,
    `AC_partner_AC_with_ONG_currently_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkAC_partner` FOREIGN KEY (`AC_ID_partner`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_Posit_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        knots.`ONG_Pågående`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_partner_AC_with_ONG_currently_Annex table (of AC_partner_AC_with_ONG_currently_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently_Annex` (
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
        ties.`AC_partner_AC_with_ONG_currently_Posit`(`AC_partner_AC_with_ONG_currently_ID`) NOT ENFORCED
)
CLUSTER BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_Positor`, `AC_partner_AC_with_ONG_currently_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of_Posit` (
    `AC_subset_PN_of_ID` int64 not null,
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    PRIMARY KEY (
        `AC_subset_PN_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Posit_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_Posit_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        anchors.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_subset_PN_of_Annex table (of AC_subset_PN_of_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of_Annex` (
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
        ties.`AC_subset_PN_of_Posit`(`AC_subset_PN_of_ID`) NOT ENFORCED
)
CLUSTER BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_Positor`, `AC_subset_PN_of_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_rollsattes_Posit` (
    `EV_in_AC_rollsattes_ID` int64 not null,
    `EV_ID_in` numeric(12,0) not null, 
    `AC_ID_rollsattes` int64 not null, 
    PRIMARY KEY (
        `EV_in_AC_rollsattes_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_Posit_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_Posit_fkAC_rollsattes` FOREIGN KEY (`AC_ID_rollsattes`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes_Annex table (of EV_in_AC_rollsattes_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_rollsattes_Annex` (
    `EV_in_AC_rollsattes_ID` int64 not null,
    `EV_in_AC_rollsattes_PositedAt` datetime not null,
    `EV_in_AC_rollsattes_Positor` int64 not null,
    `EV_in_AC_rollsattes_Reliability` numeric(5,2) not null,
    `Metadata_EV_in_AC_rollsattes` int64 not null,
    PRIMARY KEY (
        `EV_in_AC_rollsattes_ID`,
        `EV_in_AC_rollsattes_Positor`,
        `EV_in_AC_rollsattes_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_in_AC_rollsattes_Annex` FOREIGN KEY (`EV_in_AC_rollsattes_ID`) REFERENCES
        ties.`EV_in_AC_rollsattes_Posit`(`EV_in_AC_rollsattes_ID`) NOT ENFORCED
)
CLUSTER BY `EV_in_AC_rollsattes_ID`, `EV_in_AC_rollsattes_Positor`, `EV_in_AC_rollsattes_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_deltar_PR_in_RAT_fick_Posit` (
    `AC_deltar_PR_in_RAT_fick_ID` int64 not null,
    `AC_ID_deltar` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_fick` int64 not null,
    `AC_deltar_PR_in_RAT_fick_ChangedAt` datetime not null,
    PRIMARY KEY (
        `AC_deltar_PR_in_RAT_fick_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_Posit_fkAC_deltar` FOREIGN KEY (`AC_ID_deltar`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_Posit_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_Posit_fkRAT_fick` FOREIGN KEY (`RAT_ID_fick`) REFERENCES
        knots.`RAT_Betyg`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_deltar`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick_Annex table (of AC_deltar_PR_in_RAT_fick_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_deltar_PR_in_RAT_fick_Annex` (
    `AC_deltar_PR_in_RAT_fick_ID` int64 not null,
    `AC_deltar_PR_in_RAT_fick_PositedAt` datetime not null,
    `AC_deltar_PR_in_RAT_fick_Positor` int64 not null,
    `AC_deltar_PR_in_RAT_fick_Reliability` numeric(5,2) not null,
    `Metadata_AC_deltar_PR_in_RAT_fick` int64 not null,
    PRIMARY KEY (
        `AC_deltar_PR_in_RAT_fick_ID`,
        `AC_deltar_PR_in_RAT_fick_Positor`,
        `AC_deltar_PR_in_RAT_fick_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_deltar_PR_in_RAT_fick_Annex` FOREIGN KEY (`AC_deltar_PR_in_RAT_fick_ID`) REFERENCES
        ties.`AC_deltar_PR_in_RAT_fick_Posit`(`AC_deltar_PR_in_RAT_fick_ID`) NOT ENFORCED
)
CLUSTER BY `AC_deltar_PR_in_RAT_fick_ID`, `AC_deltar_PR_in_RAT_fick_Positor`, `AC_deltar_PR_in_RAT_fick_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_spelas_Posit table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_spelas_Posit` (
    `ST_at_PR_spelas_ID` int64 not null,
    `ST_ID_at` int64 not null, 
    `PR_ID_spelas` int64 not null, 
    `ST_at_PR_spelas_ChangedAt` datetime not null,
    PRIMARY KEY (
        `ST_at_PR_spelas_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_Posit_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_Posit_fkPR_spelas` FOREIGN KEY (`PR_ID_spelas`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- ST_at_PR_spelas_Annex table (of ST_at_PR_spelas_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_spelas_Annex` (
    `ST_at_PR_spelas_ID` int64 not null,
    `ST_at_PR_spelas_PositedAt` datetime not null,
    `ST_at_PR_spelas_Positor` int64 not null,
    `ST_at_PR_spelas_Reliability` numeric(5,2) not null,
    `Metadata_ST_at_PR_spelas` int64 not null,
    PRIMARY KEY (
        `ST_at_PR_spelas_ID`,
        `ST_at_PR_spelas_Positor`,
        `ST_at_PR_spelas_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_at_PR_spelas_Annex` FOREIGN KEY (`ST_at_PR_spelas_ID`) REFERENCES
        ties.`ST_at_PR_spelas_Posit`(`ST_at_PR_spelas_ID`) NOT ENFORCED
)
CLUSTER BY `ST_at_PR_spelas_ID`, `ST_at_PR_spelas_Positor`, `ST_at_PR_spelas_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_förälder_AC_barn_PAT_har_Posit` (
    `AC_förälder_AC_barn_PAT_har_ID` int64 not null,
    `AC_ID_förälder` int64 not null, 
    `AC_ID_barn` int64 not null, 
    `PAT_ID_har` int64 not null,
    PRIMARY KEY (
        `AC_förälder_AC_barn_PAT_har_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_Posit_fkAC_förälder` FOREIGN KEY (`AC_ID_förälder`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_Posit_fkAC_barn` FOREIGN KEY (`AC_ID_barn`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_Posit_fkPAT_har` FOREIGN KEY (`PAT_ID_har`) REFERENCES
        knots.`PAT_Föräldratyp`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_förälder`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har_Annex table (of AC_förälder_AC_barn_PAT_har_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_förälder_AC_barn_PAT_har_Annex` (
    `AC_förälder_AC_barn_PAT_har_ID` int64 not null,
    `AC_förälder_AC_barn_PAT_har_PositedAt` datetime not null,
    `AC_förälder_AC_barn_PAT_har_Positor` int64 not null,
    `AC_förälder_AC_barn_PAT_har_Reliability` numeric(5,2) not null,
    `Metadata_AC_förälder_AC_barn_PAT_har` int64 not null,
    PRIMARY KEY (
        `AC_förälder_AC_barn_PAT_har_ID`,
        `AC_förälder_AC_barn_PAT_har_Positor`,
        `AC_förälder_AC_barn_PAT_har_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_förälder_AC_barn_PAT_har_Annex` FOREIGN KEY (`AC_förälder_AC_barn_PAT_har_ID`) REFERENCES
        ties.`AC_förälder_AC_barn_PAT_har_Posit`(`AC_förälder_AC_barn_PAT_har_ID`) NOT ENFORCED
)
CLUSTER BY `AC_förälder_AC_barn_PAT_har_ID`, `AC_förälder_AC_barn_PAT_har_Positor`, `AC_förälder_AC_barn_PAT_har_PositedAt`;
-- Tie posit table ----------------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of_Posit table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_innehåll_ST_plats_EV_of_Posit` (
    `PR_innehåll_ST_plats_EV_of_ID` int64 not null,
    `PR_ID_innehåll` int64 not null, 
    `ST_ID_plats` int64 not null, 
    `EV_ID_of` numeric(12,0) not null, 
    `PR_innehåll_ST_plats_EV_of_ChangedAt` datetime not null,
    PRIMARY KEY (
        `PR_innehåll_ST_plats_EV_of_ID`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_Posit_fkPR_innehåll` FOREIGN KEY (`PR_ID_innehåll`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_Posit_fkST_plats` FOREIGN KEY (`ST_ID_plats`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_Posit_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_innehåll`
;
-- Tie annex table ----------------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of_Annex table (of PR_innehåll_ST_plats_EV_of_Posit)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_innehåll_ST_plats_EV_of_Annex` (
    `PR_innehåll_ST_plats_EV_of_ID` int64 not null,
    `PR_innehåll_ST_plats_EV_of_PositedAt` datetime not null,
    `PR_innehåll_ST_plats_EV_of_Positor` int64 not null,
    `PR_innehåll_ST_plats_EV_of_Reliability` numeric(5,2) not null,
    `Metadata_PR_innehåll_ST_plats_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_innehåll_ST_plats_EV_of_ID`,
        `PR_innehåll_ST_plats_EV_of_Positor`,
        `PR_innehåll_ST_plats_EV_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_innehåll_ST_plats_EV_of_Annex` FOREIGN KEY (`PR_innehåll_ST_plats_EV_of_ID`) REFERENCES
        ties.`PR_innehåll_ST_plats_EV_of_Posit`(`PR_innehåll_ST_plats_EV_of_ID`) NOT ENFORCED
)
CLUSTER BY `PR_innehåll_ST_plats_EV_of_ID`, `PR_innehåll_ST_plats_EV_of_Positor`, `PR_innehåll_ST_plats_EV_of_PositedAt`;
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
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
    a.`AC_partner_AC_with_ONG_currently_Positor`,
    a.`AC_partner_AC_with_ONG_currently_Reliability`,
    CASE
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` > 0 THEN '+'
        WHEN a.`AC_partner_AC_with_ONG_currently_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_partner_AC_with_ONG_currently_Assertion`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Posit` p
JOIN
    ties.`AC_partner_AC_with_ONG_currently_Annex` a
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
    a.`AC_subset_PN_of_Positor`,
    a.`AC_subset_PN_of_Reliability`,
    CASE
        WHEN a.`AC_subset_PN_of_Reliability` > 0 THEN '+'
        WHEN a.`AC_subset_PN_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_subset_PN_of_Assertion`
FROM
    ties.`AC_subset_PN_of_Posit` p
JOIN
    ties.`AC_subset_PN_of_Annex` a
ON
    a.`AC_subset_PN_of_ID` = p.`AC_subset_PN_of_ID`
;
CREATE OR REPLACE VIEW ties.`EV_in_AC_rollsattes` AS
SELECT
    a.`Metadata_EV_in_AC_rollsattes`,
    p.`EV_in_AC_rollsattes_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_rollsattes`,
    a.`EV_in_AC_rollsattes_PositedAt`,
    a.`EV_in_AC_rollsattes_Positor`,
    a.`EV_in_AC_rollsattes_Reliability`,
    CASE
        WHEN a.`EV_in_AC_rollsattes_Reliability` > 0 THEN '+'
        WHEN a.`EV_in_AC_rollsattes_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_rollsattes_Assertion`
FROM
    ties.`EV_in_AC_rollsattes_Posit` p
JOIN
    ties.`EV_in_AC_rollsattes_Annex` a
ON
    a.`EV_in_AC_rollsattes_ID` = p.`EV_in_AC_rollsattes_ID`
;
CREATE OR REPLACE VIEW ties.`AC_deltar_PR_in_RAT_fick` AS
SELECT
    a.`Metadata_AC_deltar_PR_in_RAT_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ID`,
    p.`AC_ID_deltar`,
    p.`PR_ID_in`,
    p.`RAT_ID_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    a.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    a.`AC_deltar_PR_in_RAT_fick_Positor`,
    a.`AC_deltar_PR_in_RAT_fick_Reliability`,
    CASE
        WHEN a.`AC_deltar_PR_in_RAT_fick_Reliability` > 0 THEN '+'
        WHEN a.`AC_deltar_PR_in_RAT_fick_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Posit` p
JOIN
    ties.`AC_deltar_PR_in_RAT_fick_Annex` a
ON
    a.`AC_deltar_PR_in_RAT_fick_ID` = p.`AC_deltar_PR_in_RAT_fick_ID`
;
CREATE OR REPLACE VIEW ties.`ST_at_PR_spelas` AS
SELECT
    a.`Metadata_ST_at_PR_spelas`,
    p.`ST_at_PR_spelas_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_spelas`,
    p.`ST_at_PR_spelas_ChangedAt`,
    a.`ST_at_PR_spelas_PositedAt`,
    a.`ST_at_PR_spelas_Positor`,
    a.`ST_at_PR_spelas_Reliability`,
    CASE
        WHEN a.`ST_at_PR_spelas_Reliability` > 0 THEN '+'
        WHEN a.`ST_at_PR_spelas_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_spelas_Assertion`
FROM
    ties.`ST_at_PR_spelas_Posit` p
JOIN
    ties.`ST_at_PR_spelas_Annex` a
ON
    a.`ST_at_PR_spelas_ID` = p.`ST_at_PR_spelas_ID`
;
CREATE OR REPLACE VIEW ties.`AC_förälder_AC_barn_PAT_har` AS
SELECT
    a.`Metadata_AC_förälder_AC_barn_PAT_har`,
    p.`AC_förälder_AC_barn_PAT_har_ID`,
    p.`AC_ID_förälder`,
    p.`AC_ID_barn`,
    p.`PAT_ID_har`,
    a.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    a.`AC_förälder_AC_barn_PAT_har_Positor`,
    a.`AC_förälder_AC_barn_PAT_har_Reliability`,
    CASE
        WHEN a.`AC_förälder_AC_barn_PAT_har_Reliability` > 0 THEN '+'
        WHEN a.`AC_förälder_AC_barn_PAT_har_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_förälder_AC_barn_PAT_har_Assertion`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Posit` p
JOIN
    ties.`AC_förälder_AC_barn_PAT_har_Annex` a
ON
    a.`AC_förälder_AC_barn_PAT_har_ID` = p.`AC_förälder_AC_barn_PAT_har_ID`
;
CREATE OR REPLACE VIEW ties.`PR_innehåll_ST_plats_EV_of` AS
SELECT
    a.`Metadata_PR_innehåll_ST_plats_EV_of`,
    p.`PR_innehåll_ST_plats_EV_of_ID`,
    p.`PR_ID_innehåll`,
    p.`ST_ID_plats`,
    p.`EV_ID_of`,
    p.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    a.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    a.`PR_innehåll_ST_plats_EV_of_Positor`,
    a.`PR_innehåll_ST_plats_EV_of_Reliability`,
    CASE
        WHEN a.`PR_innehåll_ST_plats_EV_of_Reliability` > 0 THEN '+'
        WHEN a.`PR_innehåll_ST_plats_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Posit` p
JOIN
    ties.`PR_innehåll_ST_plats_EV_of_Annex` a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null.
--
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Posit` (
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
    ties.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_partner_AC_with_ONG_currently_Posit` (
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
    ties.`AC_partner_AC_with_ONG_currently_Posit`
WHERE
    `AC_partner_AC_with_ONG_currently_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently_Annex` (
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
    ties.`AC_partner_AC_with_ONG_currently_Annex`
WHERE
    `AC_partner_AC_with_ONG_currently_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_partner_AC_with_ONG_currently` (
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
    ties.`rAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_partner_AC_with_ONG_currently` (
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
    ties.`fAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of_Annex` (
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
    ties.`AC_subset_PN_of_Annex`
WHERE
    `AC_subset_PN_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of` (
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
    ties.`AC_subset_PN_of_Posit` p
JOIN
    ties.`rAC_subset_PN_of_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_subset_PN_of` (
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
    ties.`AC_subset_PN_of_Posit` p
JOIN
    ties.`rAC_subset_PN_of_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_rollsattes_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_in_AC_rollsattes`,
    `EV_in_AC_rollsattes_ID`,
    `EV_in_AC_rollsattes_PositedAt`,
    `EV_in_AC_rollsattes_Positor`,
    `EV_in_AC_rollsattes_Reliability`,
    CASE
        WHEN `EV_in_AC_rollsattes_Reliability` > 0 THEN '+'
        WHEN `EV_in_AC_rollsattes_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_rollsattes_Assertion`
FROM
    ties.`EV_in_AC_rollsattes_Annex`
WHERE
    `EV_in_AC_rollsattes_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_rollsattes` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_rollsattes`,
    p.`EV_in_AC_rollsattes_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_rollsattes`,
    a.`EV_in_AC_rollsattes_PositedAt`,
    a.`EV_in_AC_rollsattes_Positor`,
    a.`EV_in_AC_rollsattes_Reliability`,
    CASE
        WHEN a.`EV_in_AC_rollsattes_Reliability` > 0 THEN '+'
        WHEN a.`EV_in_AC_rollsattes_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_rollsattes_Assertion`
FROM
    ties.`EV_in_AC_rollsattes_Posit` p
JOIN
    ties.`rEV_in_AC_rollsattes_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_rollsattes_ID` = p.`EV_in_AC_rollsattes_ID`
AND
    a.`EV_in_AC_rollsattes_Positor` = coalesce(positor, a.`EV_in_AC_rollsattes_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_rollsattes_ID`, a.`EV_in_AC_rollsattes_Positor`
        ORDER BY a.`EV_in_AC_rollsattes_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fEV_in_AC_rollsattes` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_rollsattes`,
    p.`EV_in_AC_rollsattes_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_rollsattes`,
    a.`EV_in_AC_rollsattes_PositedAt`,
    a.`EV_in_AC_rollsattes_Positor`,
    a.`EV_in_AC_rollsattes_Reliability`,
    CASE
        WHEN a.`EV_in_AC_rollsattes_Reliability` > 0 THEN '+'
        WHEN a.`EV_in_AC_rollsattes_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `EV_in_AC_rollsattes_Assertion`
FROM
    ties.`EV_in_AC_rollsattes_Posit` p
JOIN
    ties.`rEV_in_AC_rollsattes_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_rollsattes_ID` = p.`EV_in_AC_rollsattes_ID`
AND
    a.`EV_in_AC_rollsattes_Positor` = coalesce(positor, a.`EV_in_AC_rollsattes_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_rollsattes_ID`, a.`EV_in_AC_rollsattes_Positor`
        ORDER BY a.`EV_in_AC_rollsattes_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_deltar_PR_in_RAT_fick_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_deltar_PR_in_RAT_fick_ID`,
    `AC_ID_deltar`,
    `PR_ID_in`,
    `RAT_ID_fick`,
    `AC_deltar_PR_in_RAT_fick_ChangedAt`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Posit`
WHERE
    `AC_deltar_PR_in_RAT_fick_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_deltar_PR_in_RAT_fick_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC_deltar_PR_in_RAT_fick_ID`,
    `AC_ID_deltar`,
    `PR_ID_in`,
    `RAT_ID_fick`,
    `AC_deltar_PR_in_RAT_fick_ChangedAt`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Posit`
WHERE
    `AC_deltar_PR_in_RAT_fick_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_deltar_PR_in_RAT_fick_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_deltar_PR_in_RAT_fick`,
    `AC_deltar_PR_in_RAT_fick_ID`,
    `AC_deltar_PR_in_RAT_fick_PositedAt`,
    `AC_deltar_PR_in_RAT_fick_Positor`,
    `AC_deltar_PR_in_RAT_fick_Reliability`,
    CASE
        WHEN `AC_deltar_PR_in_RAT_fick_Reliability` > 0 THEN '+'
        WHEN `AC_deltar_PR_in_RAT_fick_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Annex`
WHERE
    `AC_deltar_PR_in_RAT_fick_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_deltar_PR_in_RAT_fick` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_deltar_PR_in_RAT_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ID`,
    p.`AC_ID_deltar`,
    p.`PR_ID_in`,
    p.`RAT_ID_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    a.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    a.`AC_deltar_PR_in_RAT_fick_Positor`,
    a.`AC_deltar_PR_in_RAT_fick_Reliability`,
    CASE
        WHEN a.`AC_deltar_PR_in_RAT_fick_Reliability` > 0 THEN '+'
        WHEN a.`AC_deltar_PR_in_RAT_fick_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    ties.`rAC_deltar_PR_in_RAT_fick_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_deltar_PR_in_RAT_fick_Annex`(positingTimepoint) a
ON
    a.`AC_deltar_PR_in_RAT_fick_ID` = p.`AC_deltar_PR_in_RAT_fick_ID`
AND
    a.`AC_deltar_PR_in_RAT_fick_Positor` = coalesce(positor, a.`AC_deltar_PR_in_RAT_fick_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_deltar_PR_in_RAT_fick_ID`, a.`AC_deltar_PR_in_RAT_fick_Positor`
        ORDER BY a.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_deltar_PR_in_RAT_fick` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_deltar_PR_in_RAT_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ID`,
    p.`AC_ID_deltar`,
    p.`PR_ID_in`,
    p.`RAT_ID_fick`,
    p.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    a.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    a.`AC_deltar_PR_in_RAT_fick_Positor`,
    a.`AC_deltar_PR_in_RAT_fick_Reliability`,
    CASE
        WHEN a.`AC_deltar_PR_in_RAT_fick_Reliability` > 0 THEN '+'
        WHEN a.`AC_deltar_PR_in_RAT_fick_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    ties.`fAC_deltar_PR_in_RAT_fick_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_deltar_PR_in_RAT_fick_Annex`(positingTimepoint) a
ON
    a.`AC_deltar_PR_in_RAT_fick_ID` = p.`AC_deltar_PR_in_RAT_fick_ID`
AND
    a.`AC_deltar_PR_in_RAT_fick_Positor` = coalesce(positor, a.`AC_deltar_PR_in_RAT_fick_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_deltar_PR_in_RAT_fick_ID`, a.`AC_deltar_PR_in_RAT_fick_Positor`
        ORDER BY a.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_spelas_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_spelas_ID`,
    `ST_ID_at`,
    `PR_ID_spelas`,
    `ST_at_PR_spelas_ChangedAt`
FROM
    ties.`ST_at_PR_spelas_Posit`
WHERE
    `ST_at_PR_spelas_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_spelas_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST_at_PR_spelas_ID`,
    `ST_ID_at`,
    `PR_ID_spelas`,
    `ST_at_PR_spelas_ChangedAt`
FROM
    ties.`ST_at_PR_spelas_Posit`
WHERE
    `ST_at_PR_spelas_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_spelas_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_at_PR_spelas`,
    `ST_at_PR_spelas_ID`,
    `ST_at_PR_spelas_PositedAt`,
    `ST_at_PR_spelas_Positor`,
    `ST_at_PR_spelas_Reliability`,
    CASE
        WHEN `ST_at_PR_spelas_Reliability` > 0 THEN '+'
        WHEN `ST_at_PR_spelas_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_spelas_Assertion`
FROM
    ties.`ST_at_PR_spelas_Annex`
WHERE
    `ST_at_PR_spelas_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_spelas` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_spelas`,
    p.`ST_at_PR_spelas_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_spelas`,
    p.`ST_at_PR_spelas_ChangedAt`,
    a.`ST_at_PR_spelas_PositedAt`,
    a.`ST_at_PR_spelas_Positor`,
    a.`ST_at_PR_spelas_Reliability`,
    CASE
        WHEN a.`ST_at_PR_spelas_Reliability` > 0 THEN '+'
        WHEN a.`ST_at_PR_spelas_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_spelas_Assertion`
FROM
    ties.`rST_at_PR_spelas_Posit`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_spelas_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_spelas_ID` = p.`ST_at_PR_spelas_ID`
AND
    a.`ST_at_PR_spelas_Positor` = coalesce(positor, a.`ST_at_PR_spelas_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_spelas_ID`, a.`ST_at_PR_spelas_Positor`
        ORDER BY a.`ST_at_PR_spelas_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_spelas` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_ST_at_PR_spelas`,
    p.`ST_at_PR_spelas_ID`,
    p.`ST_ID_at`,
    p.`PR_ID_spelas`,
    p.`ST_at_PR_spelas_ChangedAt`,
    a.`ST_at_PR_spelas_PositedAt`,
    a.`ST_at_PR_spelas_Positor`,
    a.`ST_at_PR_spelas_Reliability`,
    CASE
        WHEN a.`ST_at_PR_spelas_Reliability` > 0 THEN '+'
        WHEN a.`ST_at_PR_spelas_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `ST_at_PR_spelas_Assertion`
FROM
    ties.`fST_at_PR_spelas_Posit`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_spelas_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_spelas_ID` = p.`ST_at_PR_spelas_ID`
AND
    a.`ST_at_PR_spelas_Positor` = coalesce(positor, a.`ST_at_PR_spelas_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_spelas_ID`, a.`ST_at_PR_spelas_Positor`
        ORDER BY a.`ST_at_PR_spelas_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_förälder_AC_barn_PAT_har_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_förälder_AC_barn_PAT_har`,
    `AC_förälder_AC_barn_PAT_har_ID`,
    `AC_förälder_AC_barn_PAT_har_PositedAt`,
    `AC_förälder_AC_barn_PAT_har_Positor`,
    `AC_förälder_AC_barn_PAT_har_Reliability`,
    CASE
        WHEN `AC_förälder_AC_barn_PAT_har_Reliability` > 0 THEN '+'
        WHEN `AC_förälder_AC_barn_PAT_har_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_förälder_AC_barn_PAT_har_Assertion`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Annex`
WHERE
    `AC_förälder_AC_barn_PAT_har_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_förälder_AC_barn_PAT_har` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_förälder_AC_barn_PAT_har`,
    p.`AC_förälder_AC_barn_PAT_har_ID`,
    p.`AC_ID_förälder`,
    p.`AC_ID_barn`,
    p.`PAT_ID_har`,
    a.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    a.`AC_förälder_AC_barn_PAT_har_Positor`,
    a.`AC_förälder_AC_barn_PAT_har_Reliability`,
    CASE
        WHEN a.`AC_förälder_AC_barn_PAT_har_Reliability` > 0 THEN '+'
        WHEN a.`AC_förälder_AC_barn_PAT_har_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_förälder_AC_barn_PAT_har_Assertion`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Posit` p
JOIN
    ties.`rAC_förälder_AC_barn_PAT_har_Annex`(positingTimepoint) a
ON
    a.`AC_förälder_AC_barn_PAT_har_ID` = p.`AC_förälder_AC_barn_PAT_har_ID`
AND
    a.`AC_förälder_AC_barn_PAT_har_Positor` = coalesce(positor, a.`AC_förälder_AC_barn_PAT_har_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_förälder_AC_barn_PAT_har_ID`, a.`AC_förälder_AC_barn_PAT_har_Positor`
        ORDER BY a.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_förälder_AC_barn_PAT_har` (
    positor int64,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_AC_förälder_AC_barn_PAT_har`,
    p.`AC_förälder_AC_barn_PAT_har_ID`,
    p.`AC_ID_förälder`,
    p.`AC_ID_barn`,
    p.`PAT_ID_har`,
    a.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    a.`AC_förälder_AC_barn_PAT_har_Positor`,
    a.`AC_förälder_AC_barn_PAT_har_Reliability`,
    CASE
        WHEN a.`AC_förälder_AC_barn_PAT_har_Reliability` > 0 THEN '+'
        WHEN a.`AC_förälder_AC_barn_PAT_har_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `AC_förälder_AC_barn_PAT_har_Assertion`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Posit` p
JOIN
    ties.`rAC_förälder_AC_barn_PAT_har_Annex`(positingTimepoint) a
ON
    a.`AC_förälder_AC_barn_PAT_har_ID` = p.`AC_förälder_AC_barn_PAT_har_ID`
AND
    a.`AC_förälder_AC_barn_PAT_har_Positor` = coalesce(positor, a.`AC_förälder_AC_barn_PAT_har_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_förälder_AC_barn_PAT_har_ID`, a.`AC_förälder_AC_barn_PAT_har_Positor`
        ORDER BY a.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_innehåll_ST_plats_EV_of_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_innehåll_ST_plats_EV_of_ID`,
    `PR_ID_innehåll`,
    `ST_ID_plats`,
    `EV_ID_of`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Posit`
WHERE
    `PR_innehåll_ST_plats_EV_of_ChangedAt` <= changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_innehåll_ST_plats_EV_of_Posit` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR_innehåll_ST_plats_EV_of_ID`,
    `PR_ID_innehåll`,
    `ST_ID_plats`,
    `EV_ID_of`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Posit`
WHERE
    `PR_innehåll_ST_plats_EV_of_ChangedAt` > changingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_innehåll_ST_plats_EV_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_innehåll_ST_plats_EV_of`,
    `PR_innehåll_ST_plats_EV_of_ID`,
    `PR_innehåll_ST_plats_EV_of_PositedAt`,
    `PR_innehåll_ST_plats_EV_of_Positor`,
    `PR_innehåll_ST_plats_EV_of_Reliability`,
    CASE
        WHEN `PR_innehåll_ST_plats_EV_of_Reliability` > 0 THEN '+'
        WHEN `PR_innehåll_ST_plats_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Annex`
WHERE
    `PR_innehåll_ST_plats_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_innehåll_ST_plats_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_innehåll_ST_plats_EV_of`,
    p.`PR_innehåll_ST_plats_EV_of_ID`,
    p.`PR_ID_innehåll`,
    p.`ST_ID_plats`,
    p.`EV_ID_of`,
    p.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    a.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    a.`PR_innehåll_ST_plats_EV_of_Positor`,
    a.`PR_innehåll_ST_plats_EV_of_Reliability`,
    CASE
        WHEN a.`PR_innehåll_ST_plats_EV_of_Reliability` > 0 THEN '+'
        WHEN a.`PR_innehåll_ST_plats_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    ties.`rPR_innehåll_ST_plats_EV_of_Posit`(changingTimepoint) p 
JOIN
    ties.`rPR_innehåll_ST_plats_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
AND
    a.`PR_innehåll_ST_plats_EV_of_Positor` = coalesce(positor, a.`PR_innehåll_ST_plats_EV_of_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_innehåll_ST_plats_EV_of_ID`, a.`PR_innehåll_ST_plats_EV_of_Positor`
        ORDER BY a.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_innehåll_ST_plats_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_innehåll_ST_plats_EV_of`,
    p.`PR_innehåll_ST_plats_EV_of_ID`,
    p.`PR_ID_innehåll`,
    p.`ST_ID_plats`,
    p.`EV_ID_of`,
    p.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    a.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    a.`PR_innehåll_ST_plats_EV_of_Positor`,
    a.`PR_innehåll_ST_plats_EV_of_Reliability`,
    CASE
        WHEN a.`PR_innehåll_ST_plats_EV_of_Reliability` > 0 THEN '+'
        WHEN a.`PR_innehåll_ST_plats_EV_of_Reliability` = 0 THEN '?'
        ELSE '-'
    END AS `PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    ties.`fPR_innehåll_ST_plats_EV_of_Posit`(changingTimepoint) p 
JOIN
    ties.`rPR_innehåll_ST_plats_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
AND
    a.`PR_innehåll_ST_plats_EV_of_Positor` = coalesce(positor, a.`PR_innehåll_ST_plats_EV_of_Positor`)
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_innehåll_ST_plats_EV_of_ID`, a.`PR_innehåll_ST_plats_EV_of_Positor`
        ORDER BY a.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC
    ) = 1
)
;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BigQuery CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`tST_Scen` (
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
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Positor`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Assertion`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Positor`,
    `AVG`.`ST_AVG_Reliability`,
    `AVG`.`ST_AVG_Assertion`,
    `AVG`.`ST_AVG_UTL_Utnyttjande`,
    `AVG`.`ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Positor`,
    `MIN`.`ST_MIN_Reliability`,
    `MIN`.`ST_MIN_Assertion`,
    `MIN`.`ST_MIN_UTL_Utnyttjande`,
    `MIN`.`ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Scen` `ST`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw.`_Positor` p
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
            attributes.`rST_NAM_Scen_Namn`(
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
            attributes.`rST_LOC_Scen_Plats`(
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
        k.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`
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
            attributes.`rST_AVG_Scen_Medel`(
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
        knots.`UTL_Utnyttjande` k
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
        k.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rST_MIN_Scen_Minimum`(
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
        knots.`UTL_Utnyttjande` k
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
CREATE OR REPLACE VIEW anchors.`lST_Scen` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    dw.`_Positor` p,
    anchors.`tST_Scen`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `ST`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pST_Scen` (
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
    `ST`.`ST_NAM_Scen_Namn`,
    `ST`.`ST_LOC_ST_ID`,
    `ST`.`Metadata_ST_LOC`,
    `ST`.`ST_LOC_ID`,
    `ST`.`ST_LOC_PositedAt`,
    `ST`.`ST_LOC_Positor`,
    `ST`.`ST_LOC_Reliability`,
    `ST`.`ST_LOC_Assertion`,
    `ST`.`ST_LOC_Checksum`,
    `ST`.`ST_LOC_Scen_Plats`,
    `ST`.`ST_AVG_ST_ID`,
    `ST`.`Metadata_ST_AVG`,
    `ST`.`ST_AVG_ID`,
    `ST`.`ST_AVG_ChangedAt`,
    `ST`.`ST_AVG_PositedAt`,
    `ST`.`ST_AVG_Positor`,
    `ST`.`ST_AVG_Reliability`,
    `ST`.`ST_AVG_Assertion`,
    `ST`.`ST_AVG_UTL_Utnyttjande`,
    `ST`.`ST_AVG_Metadata_UTL`,
    `ST`.`ST_AVG_UTL_ID`,
    `ST`.`ST_MIN_ST_ID`,
    `ST`.`Metadata_ST_MIN`,
    `ST`.`ST_MIN_ID`,
    `ST`.`ST_MIN_PositedAt`,
    `ST`.`ST_MIN_Positor`,
    `ST`.`ST_MIN_Reliability`,
    `ST`.`ST_MIN_Assertion`,
    `ST`.`ST_MIN_UTL_Utnyttjande`,
    `ST`.`ST_MIN_Metadata_UTL`,
    `ST`.`ST_MIN_UTL_ID`
FROM
    dw.`_Positor` p,
    anchors.`tST_Scen`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `ST`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nST_Scen` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    dw.`_Positor` p,
    anchors.`tST_Scen`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `ST`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dST_Scen` (
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
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Positor`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Assertion`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Positor`,
    `AVG`.`ST_AVG_Reliability`,
    `AVG`.`ST_AVG_Assertion`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Positor`,
    `MIN`.`ST_MIN_Reliability`,
    `MIN`.`ST_MIN_Assertion`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    dw.`_Positor` p
JOIN
(
    SELECT DISTINCT
        `ST_NAM_Positor` AS positor,
        `ST_NAM_ST_ID` AS `ST_ID`,
        CAST(`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`ST_NAM_Scen_Namn`
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
        attributes.`ST_AVG_Scen_Medel`
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        `ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.`Positor`
JOIN
    anchors.`ST_Scen` `ST`
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
            attributes.`rST_NAM_Scen_Namn`(
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
        attributes.`rST_LOC_Scen_Plats`(
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
            attributes.`rST_AVG_Scen_Medel`(
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
    knots.`UTL_Utnyttjande` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rST_MIN_Scen_Minimum`(
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
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`tAC_Skådespelare` (
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
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Positor`,
    `GEN`.`AC_GEN_Reliability`,
    `GEN`.`AC_GEN_Assertion`,
    `GEN`.`AC_GEN_GEN_Checksum`,
    `GEN`.`AC_GEN_GEN_Kön`,
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
    `PLV`.`AC_PLV_PLV_Yrkesnivå`,
    `PLV`.`AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Skådespelare` `AC`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw.`_Positor` p
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
            attributes.`rAC_NAM_Skådespelare_Namn`(
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
        k.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
        k.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
        k.`GEN_Kön` AS `AC_GEN_GEN_Kön`
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rAC_GEN_Skådespelare_Kön`(
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
        knots.`GEN_Kön` k
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
        k.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`
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
            attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(
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
        knots.`PLV_Yrkesnivå` k
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
CREATE OR REPLACE VIEW anchors.`lAC_Skådespelare` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    dw.`_Positor` p,
    anchors.`tAC_Skådespelare`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `AC`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pAC_Skådespelare` (
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
    `AC`.`AC_NAM_Skådespelare_Namn`,
    `AC`.`AC_GEN_AC_ID`,
    `AC`.`Metadata_AC_GEN`,
    `AC`.`AC_GEN_ID`,
    `AC`.`AC_GEN_PositedAt`,
    `AC`.`AC_GEN_Positor`,
    `AC`.`AC_GEN_Reliability`,
    `AC`.`AC_GEN_Assertion`,
    `AC`.`AC_GEN_GEN_Checksum`,
    `AC`.`AC_GEN_GEN_Kön`,
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
    `AC`.`AC_PLV_PLV_Yrkesnivå`,
    `AC`.`AC_PLV_Metadata_PLV`,
    `AC`.`AC_PLV_PLV_ID`
FROM
    dw.`_Positor` p,
    anchors.`tAC_Skådespelare`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `AC`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nAC_Skådespelare` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    dw.`_Positor` p,
    anchors.`tAC_Skådespelare`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `AC`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dAC_Skådespelare` (
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
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Positor`,
    `GEN`.`AC_GEN_Reliability`,
    `GEN`.`AC_GEN_Assertion`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
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
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    dw.`_Positor` p
JOIN
(
    SELECT DISTINCT
        `AC_NAM_Positor` AS positor,
        `AC_NAM_AC_ID` AS `AC_ID`,
        CAST(`AC_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`AC_NAM_Skådespelare_Namn`
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
        attributes.`AC_PLV_Skådespelare_Yrkesnivå`
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        `AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.`Positor`
JOIN
    anchors.`AC_Skådespelare` `AC`
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
            attributes.`rAC_NAM_Skådespelare_Namn`(
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
        attributes.`rAC_GEN_Skådespelare_Kön`(
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
    knots.`GEN_Kön` `kGEN`
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
            attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(
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
    knots.`PLV_Yrkesnivå` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`tPR_Föreställning` (
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
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Positor`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Assertion`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM
    anchors.`PR_Föreställning` `PR`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw.`_Positor` p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rPR_NAM_Föreställning_Namn`(
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
            attributes.`rPR_LEN_Föreställning_Längd`(
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
CREATE OR REPLACE VIEW anchors.`lPR_Föreställning` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    dw.`_Positor` p,
    anchors.`tPR_Föreställning`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `PR`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pPR_Föreställning` (
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
    `PR`.`PR_NAM_Föreställning_Namn`,
    `PR`.`PR_LEN_PR_ID`,
    `PR`.`Metadata_PR_LEN`,
    `PR`.`PR_LEN_ID`,
    `PR`.`PR_LEN_ChangedAt`,
    `PR`.`PR_LEN_PositedAt`,
    `PR`.`PR_LEN_Positor`,
    `PR`.`PR_LEN_Reliability`,
    `PR`.`PR_LEN_Assertion`,
    `PR`.`PR_LEN_Föreställning_Längd`
FROM
    dw.`_Positor` p,
    anchors.`tPR_Föreställning`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `PR`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nPR_Föreställning` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    dw.`_Positor` p,
    anchors.`tPR_Föreställning`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `PR`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dPR_Föreställning` (
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
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Positor`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Assertion`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM
    dw.`_Positor` p
JOIN
(
    SELECT DISTINCT
        `PR_LEN_Positor` AS positor,
        `PR_LEN_PR_ID` AS `PR_ID`,
        CAST(`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes.`PR_LEN_Föreställning_Längd`
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        `PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p.`Positor`
JOIN
    anchors.`PR_Föreställning` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rPR_NAM_Föreställning_Namn`(
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
            attributes.`rPR_LEN_Föreställning_Längd`(
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
CREATE OR REPLACE TABLE FUNCTION nexuses.`tEV_Händelse` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Positor`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Assertion`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Positor`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Assertion`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Positor`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Assertion`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Positor`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Assertion`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Positor`,
    `UTL`.`EV_UTL_Reliability`,
    `UTL`.`EV_UTL_Assertion`,
    `UTL`.`EV_UTL_UTL_Utnyttjande`,
    `UTL`.`EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Positor`,
    `LVL`.`EV_LVL_Reliability`,
    `LVL`.`EV_LVL_Assertion`,
    `LVL`.`EV_LVL_PLV_Checksum`,
    `LVL`.`EV_LVL_PLV_Yrkesnivå`,
    `LVL`.`EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Händelse` `EV`
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor, and BigQuery cannot do that when the positor is used before a window
-- or in an outer join (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw.`_Positor` p
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
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
            attributes.`rEV_DAT_Händelse_Datum`(
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
            attributes.`rEV_AUD_Händelse_Publik`(
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
            attributes.`rEV_REV_Händelse_Intäkt`(
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
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`EV_STA_Assertion` <> '?', r.`EV_STA_ChangedAt`, null)) OVER (
                PARTITION BY r.`EV_STA_Positor`, r.`EV_STA_EV_ID`
            ) AS `inEffect`
        FROM
            attributes.`rEV_STA_Händelse_Status`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_STA_Assertion` = coalesce(assertion, x.`EV_STA_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`EV_STA_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_STA_Positor`, x.`EV_STA_EV_ID`
            ORDER BY
                x.`EV_STA_ChangedAt` DESC,
                x.`EV_STA_PositedAt` DESC,
                x.`EV_STA_Reliability` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
AND
    `STA`.`EV_STA_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
        k.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes.`rEV_UTL_Händelse_Utnyttjande`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_UTL_Assertion` = coalesce(assertion, x.`EV_UTL_Assertion`)
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_UTL_Positor`, x.`EV_UTL_EV_ID`
            ORDER BY
                x.`EV_UTL_PositedAt` DESC,
                x.`EV_UTL_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        knots.`UTL_Utnyttjande` k
    ON
        k.`UTL_ID` = y.`EV_UTL_UTL_ID`
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
AND
    `UTL`.`EV_UTL_Positor` = p.`Positor`
LEFT JOIN (
    -- the knot joined in here, since BigQuery cannot call this function for each positor with it joined outside
    SELECT
        y.*,
        k.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
        k.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
        k.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window: BigQuery cannot evaluate a subquery that
    -- refers to the outer row and takes the first row of an ordering
    SELECT
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(IF(r.`EV_LVL_Assertion` <> '?', r.`EV_LVL_ChangedAt`, null)) OVER (
                PARTITION BY r.`EV_LVL_Positor`, r.`EV_LVL_EV_ID`
            ) AS `inEffect`
        FROM
            attributes.`rEV_LVL_Händelse_Level`(
                CAST(null AS int64),
                CAST(changingTimepoint AS date),
                CAST(positingTimepoint AS datetime)
            ) r
    ) x
    WHERE
        x.`EV_LVL_Assertion` = coalesce(assertion, x.`EV_LVL_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x.`EV_LVL_ChangedAt` = x.`inEffect`
    )
    QUALIFY
        row_number() OVER (
            PARTITION BY x.`EV_LVL_Positor`, x.`EV_LVL_EV_ID`
            ORDER BY
                x.`EV_LVL_ChangedAt` DESC,
                x.`EV_LVL_PositedAt` DESC,
                x.`EV_LVL_Reliability` DESC
        ) = 1
    ) y
    LEFT JOIN
        knots.`PLV_Yrkesnivå` k
    ON
        k.`PLV_ID` = y.`EV_LVL_PLV_ID`
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
AND
    `LVL`.`EV_LVL_Positor` = p.`Positor`
WHERE
    p.`Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`lEV_Händelse` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    dw.`_Positor` p,
    nexuses.`tEV_Händelse`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Händelse` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `EV`.`of_ETY_Checksum`,
    `EV`.`of_ETY_Händelsetyp`,
    `EV`.`of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `EV`.`EV_DAT_EV_ID`,
    `EV`.`Metadata_EV_DAT`,
    `EV`.`EV_DAT_ID`,
    `EV`.`EV_DAT_PositedAt`,
    `EV`.`EV_DAT_Positor`,
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Assertion`,
    `EV`.`EV_DAT_Händelse_Datum`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Positor`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Assertion`,
    `EV`.`EV_AUD_Händelse_Publik`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Positor`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Assertion`,
    `EV`.`EV_REV_Händelse_Intäkt`,
    `EV`.`EV_STA_EV_ID`,
    `EV`.`Metadata_EV_STA`,
    `EV`.`EV_STA_ID`,
    `EV`.`EV_STA_ChangedAt`,
    `EV`.`EV_STA_PositedAt`,
    `EV`.`EV_STA_Positor`,
    `EV`.`EV_STA_Reliability`,
    `EV`.`EV_STA_Assertion`,
    `EV`.`EV_STA_Händelse_Status`,
    `EV`.`EV_UTL_EV_ID`,
    `EV`.`Metadata_EV_UTL`,
    `EV`.`EV_UTL_ID`,
    `EV`.`EV_UTL_PositedAt`,
    `EV`.`EV_UTL_Positor`,
    `EV`.`EV_UTL_Reliability`,
    `EV`.`EV_UTL_Assertion`,
    `EV`.`EV_UTL_UTL_Utnyttjande`,
    `EV`.`EV_UTL_Metadata_UTL`,
    `EV`.`EV_UTL_UTL_ID`,
    `EV`.`EV_LVL_EV_ID`,
    `EV`.`Metadata_EV_LVL`,
    `EV`.`EV_LVL_ID`,
    `EV`.`EV_LVL_ChangedAt`,
    `EV`.`EV_LVL_PositedAt`,
    `EV`.`EV_LVL_Positor`,
    `EV`.`EV_LVL_Reliability`,
    `EV`.`EV_LVL_Assertion`,
    `EV`.`EV_LVL_PLV_Checksum`,
    `EV`.`EV_LVL_PLV_Yrkesnivå`,
    `EV`.`EV_LVL_Metadata_PLV`,
    `EV`.`EV_LVL_PLV_ID`
FROM
    dw.`_Positor` p,
    nexuses.`tEV_Händelse`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`nEV_Händelse` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    `EV`.*
FROM
    dw.`_Positor` p,
    nexuses.`tEV_Händelse`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) `EV`
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Händelse` (
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
    tp.inspectedTimepoint,
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `kETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `kETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `kETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_ID`,
    `DAT`.`EV_DAT_PositedAt`,
    `DAT`.`EV_DAT_Positor`,
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Assertion`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Positor`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Assertion`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Positor`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Assertion`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Positor`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Assertion`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Positor`,
    `UTL`.`EV_UTL_Reliability`,
    `UTL`.`EV_UTL_Assertion`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Positor`,
    `LVL`.`EV_LVL_Reliability`,
    `LVL`.`EV_LVL_Assertion`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `EV_STA_Positor` AS positor,
        `EV_STA_EV_ID` AS `EV_ID`,
        CAST(`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Händelse_Status`
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        `EV_STA_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        `EV_LVL_Positor` AS positor,
        `EV_LVL_EV_ID` AS `EV_ID`,
        CAST(`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Händelse_Level`
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        `EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN
    nexuses.`EV_Händelse` `EV`
ON
    `EV`.`EV_ID` = tp.`EV_ID`
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Händelse_Datum`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_DAT_Positor`, r.`EV_DAT_EV_ID`
            ORDER BY
                r.`EV_DAT_PositedAt` DESC,
                r.`EV_DAT_Reliability` DESC
        ) = 1
) `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
AND
    `DAT`.`EV_DAT_Positor` = tp.positor
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_AUD_Händelse_Publik`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_AUD_Positor`, r.`EV_AUD_EV_ID`
            ORDER BY
                r.`EV_AUD_PositedAt` DESC,
                r.`EV_AUD_Reliability` DESC
        ) = 1
) `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
AND
    `AUD`.`EV_AUD_Positor` = tp.positor
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_REV_Händelse_Intäkt`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_REV_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_REV_Positor`, r.`EV_REV_EV_ID`
            ORDER BY
                r.`EV_REV_PositedAt` DESC,
                r.`EV_REV_Reliability` DESC
        ) = 1
) `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
AND
    `REV`.`EV_REV_Positor` = tp.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`EV_STA_ChangedAt`) OVER (
            PARTITION BY y.`EV_STA_Positor`, y.`EV_STA_EV_ID`
            ORDER BY y.`EV_STA_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            attributes.`rEV_STA_Händelse_Status`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_STA_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_STA_Positor`, r.`EV_STA_EV_ID`, r.`EV_STA_ChangedAt`
                ORDER BY
                    IF(r.`EV_STA_Assertion` = '+', 0, 1),
                    r.`EV_STA_PositedAt` DESC,
                    r.`EV_STA_Reliability` DESC
            ) = 1
    ) y
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
AND
    `STA`.`EV_STA_Positor` = tp.positor
AND
    `STA`.`EV_STA_Assertion` = '+'
AND
    `STA`.`EV_STA_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    `STA`.`until` IS NULL
OR
    `STA`.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_UTL_Händelse_Utnyttjande`(
            CAST(null AS int64),
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Assertion` = '+'
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_Positor`, r.`EV_UTL_EV_ID`
            ORDER BY
                r.`EV_UTL_PositedAt` DESC,
                r.`EV_UTL_Reliability` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
AND
    `UTL`.`EV_UTL_Positor` = tp.positor
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    SELECT
        y.*,
        lead(y.`EV_LVL_ChangedAt`) OVER (
            PARTITION BY y.`EV_LVL_Positor`, y.`EV_LVL_EV_ID`
            ORDER BY y.`EV_LVL_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            attributes.`rEV_LVL_Händelse_Level`(
                CAST(null AS int64),
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_LVL_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY r.`EV_LVL_Positor`, r.`EV_LVL_EV_ID`, r.`EV_LVL_ChangedAt`
                ORDER BY
                    IF(r.`EV_LVL_Assertion` = '+', 0, 1),
                    r.`EV_LVL_PositedAt` DESC,
                    r.`EV_LVL_Reliability` DESC
            ) = 1
    ) y
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
AND
    `LVL`.`EV_LVL_Positor` = tp.positor
AND
    `LVL`.`EV_LVL_Assertion` = '+'
AND
    `LVL`.`EV_LVL_ChangedAt` <= CAST(tp.inspectedTimepoint AS date)
AND (
    `LVL`.`until` IS NULL
OR
    `LVL`.`until` > CAST(tp.inspectedTimepoint AS date)
)
LEFT JOIN
    knots.`PLV_Yrkesnivå` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_partner_AC_with_ONG_currently` (
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
    `kONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
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
            ties.`rAC_partner_AC_with_ONG_currently`(
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
    knots.`ONG_Pågående` `kONG_currently`
ON
    `kONG_currently`.`ONG_ID` = t.`ONG_ID_currently`
WHERE
    t.`AC_partner_AC_with_ONG_currently_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_partner_AC_with_ONG_currently`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Pågående`,
    t.`currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_partner_AC_with_ONG_currently`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_partner_AC_with_ONG_currently` (
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
    `kONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`,
    t.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    t.`AC_partner_AC_with_ONG_currently_PositedAt`,
    t.`AC_partner_AC_with_ONG_currently_Positor`,
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_partner_AC_with_ONG_currently_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_partner_AC_with_ONG_currently_Positor` AS positor,
        CAST(`AC_partner_AC_with_ONG_currently_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`AC_partner_AC_with_ONG_currently`
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
            ties.`rAC_partner_AC_with_ONG_currently`(
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
    knots.`ONG_Pågående` `kONG_currently`
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
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_subset_PN_of` (
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
            ties.`rAC_subset_PN_of`(
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
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_subset_PN_of` (
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
    dw.`_Positor` p,
    ties.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_subset_PN_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_subset_PN_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tEV_in_AC_rollsattes` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Positor`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_in_AC_rollsattes_Assertion`
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
            ties.`rEV_in_AC_rollsattes`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`EV_in_AC_rollsattes_Assertion` = coalesce(assertion, s.`EV_in_AC_rollsattes_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`EV_in_AC_rollsattes_Positor`,
                s.`EV_ID_in`,
                s.`AC_ID_rollsattes`
            ORDER BY
                s.`EV_in_AC_rollsattes_PositedAt` DESC,
                s.`EV_in_AC_rollsattes_Reliability` DESC,
                s.`EV_in_AC_rollsattes_ID` DESC
        ) = 1
) t
WHERE
    t.`EV_in_AC_rollsattes_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lEV_in_AC_rollsattes` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tEV_in_AC_rollsattes`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_rollsattes` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Positor`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_in_AC_rollsattes_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tEV_in_AC_rollsattes`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nEV_in_AC_rollsattes` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tEV_in_AC_rollsattes`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_deltar_PR_in_RAT_fick` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    `kRAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `kRAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `kRAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    t.`RAT_ID_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Positor`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_deltar_PR_in_RAT_fick_Assertion`
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
            max(IF(r.`AC_deltar_PR_in_RAT_fick_Assertion` <> '?', r.`AC_deltar_PR_in_RAT_fick_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`AC_deltar_PR_in_RAT_fick_Positor`,
                    r.`AC_ID_deltar`,
                    r.`PR_ID_in`
            ) AS `inEffect`
        FROM
            ties.`rAC_deltar_PR_in_RAT_fick`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_deltar_PR_in_RAT_fick_Assertion` = coalesce(assertion, s.`AC_deltar_PR_in_RAT_fick_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`AC_deltar_PR_in_RAT_fick_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_deltar_PR_in_RAT_fick_Positor`,
                s.`AC_ID_deltar`,
                s.`PR_ID_in`
            ORDER BY
                s.`AC_deltar_PR_in_RAT_fick_ChangedAt` DESC,
                s.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC,
                s.`AC_deltar_PR_in_RAT_fick_Reliability` DESC,
                s.`AC_deltar_PR_in_RAT_fick_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`RAT_Betyg` `kRAT_fick`
ON
    `kRAT_fick`.`RAT_ID` = t.`RAT_ID_fick`
WHERE
    t.`AC_deltar_PR_in_RAT_fick_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_deltar_PR_in_RAT_fick` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_deltar_PR_in_RAT_fick`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    t.`fick_RAT_Checksum`,
    t.`fick_RAT_Betyg`,
    t.`fick_Metadata_RAT`,
    t.`RAT_ID_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Positor`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tAC_deltar_PR_in_RAT_fick`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_deltar_PR_in_RAT_fick` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_deltar_PR_in_RAT_fick`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_deltar_PR_in_RAT_fick` (
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
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    `kRAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `kRAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `kRAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    t.`RAT_ID_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Positor`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_deltar_PR_in_RAT_fick_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `AC_deltar_PR_in_RAT_fick_Positor` AS positor,
        CAST(`AC_deltar_PR_in_RAT_fick_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`AC_deltar_PR_in_RAT_fick`
    WHERE
        `AC_deltar_PR_in_RAT_fick_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`AC_deltar_PR_in_RAT_fick_ChangedAt`) OVER (
            PARTITION BY
                y.`AC_deltar_PR_in_RAT_fick_Positor`,
                y.`AC_ID_deltar`,
                y.`PR_ID_in`
            ORDER BY y.`AC_deltar_PR_in_RAT_fick_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rAC_deltar_PR_in_RAT_fick`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`AC_deltar_PR_in_RAT_fick_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`AC_deltar_PR_in_RAT_fick_Positor`,
                    r.`AC_ID_deltar`,
                    r.`PR_ID_in`,
                    r.`AC_deltar_PR_in_RAT_fick_ChangedAt`
                ORDER BY
                    IF(r.`AC_deltar_PR_in_RAT_fick_Assertion` = '+', 0, 1),
                    r.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC,
                    r.`AC_deltar_PR_in_RAT_fick_Reliability` DESC,
                    r.`AC_deltar_PR_in_RAT_fick_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`AC_deltar_PR_in_RAT_fick_Positor` = tp.positor
AND
    t.`AC_deltar_PR_in_RAT_fick_Assertion` = '+'
AND
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
LEFT JOIN
    knots.`RAT_Betyg` `kRAT_fick`
ON
    `kRAT_fick`.`RAT_ID` = t.`RAT_ID_fick`
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tST_at_PR_spelas` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Positor`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_at_PR_spelas_Assertion`
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
            max(IF(r.`ST_at_PR_spelas_Assertion` <> '?', r.`ST_at_PR_spelas_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`ST_at_PR_spelas_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_spelas`
            ) AS `inEffect`
        FROM
            ties.`rST_at_PR_spelas`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`ST_at_PR_spelas_Assertion` = coalesce(assertion, s.`ST_at_PR_spelas_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`ST_at_PR_spelas_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`ST_at_PR_spelas_Positor`,
                s.`ST_ID_at`,
                s.`PR_ID_spelas`
            ORDER BY
                s.`ST_at_PR_spelas_ChangedAt` DESC,
                s.`ST_at_PR_spelas_PositedAt` DESC,
                s.`ST_at_PR_spelas_Reliability` DESC,
                s.`ST_at_PR_spelas_ID` DESC
        ) = 1
) t
WHERE
    t.`ST_at_PR_spelas_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lST_at_PR_spelas` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tST_at_PR_spelas`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_spelas` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Positor`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_at_PR_spelas_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tST_at_PR_spelas`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nST_at_PR_spelas` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tST_at_PR_spelas`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_spelas` (
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
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Positor`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_at_PR_spelas_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `ST_at_PR_spelas_Positor` AS positor,
        CAST(`ST_at_PR_spelas_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`ST_at_PR_spelas`
    WHERE
        `ST_at_PR_spelas_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`ST_at_PR_spelas_ChangedAt`) OVER (
            PARTITION BY
                y.`ST_at_PR_spelas_Positor`,
                y.`ST_ID_at`,
                y.`PR_ID_spelas`
            ORDER BY y.`ST_at_PR_spelas_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rST_at_PR_spelas`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`ST_at_PR_spelas_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`ST_at_PR_spelas_Positor`,
                    r.`ST_ID_at`,
                    r.`PR_ID_spelas`,
                    r.`ST_at_PR_spelas_ChangedAt`
                ORDER BY
                    IF(r.`ST_at_PR_spelas_Assertion` = '+', 0, 1),
                    r.`ST_at_PR_spelas_PositedAt` DESC,
                    r.`ST_at_PR_spelas_Reliability` DESC,
                    r.`ST_at_PR_spelas_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`ST_at_PR_spelas_Positor` = tp.positor
AND
    t.`ST_at_PR_spelas_Assertion` = '+'
AND
    t.`ST_at_PR_spelas_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
)
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_förälder_AC_barn_PAT_har` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    `kPAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `kPAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    t.`PAT_ID_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Positor`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_förälder_AC_barn_PAT_har_Assertion`
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
            ties.`rAC_förälder_AC_barn_PAT_har`(
                CAST(null AS int64),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`AC_förälder_AC_barn_PAT_har_Assertion` = coalesce(assertion, s.`AC_förälder_AC_barn_PAT_har_Assertion`)
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s.`AC_förälder_AC_barn_PAT_har_Positor`,
                s.`AC_ID_förälder`,
                s.`AC_ID_barn`,
                s.`PAT_ID_har`
            ORDER BY
                s.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC,
                s.`AC_förälder_AC_barn_PAT_har_Reliability` DESC,
                s.`AC_förälder_AC_barn_PAT_har_ID` DESC
        ) = 1
) t
LEFT JOIN
    knots.`PAT_Föräldratyp` `kPAT_har`
ON
    `kPAT_har`.`PAT_ID` = t.`PAT_ID_har`
WHERE
    t.`AC_förälder_AC_barn_PAT_har_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_förälder_AC_barn_PAT_har` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_förälder_AC_barn_PAT_har`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    t.`har_PAT_Föräldratyp`,
    t.`har_Metadata_PAT`,
    t.`PAT_ID_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Positor`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_förälder_AC_barn_PAT_har_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tAC_förälder_AC_barn_PAT_har`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_förälder_AC_barn_PAT_har` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tAC_förälder_AC_barn_PAT_har`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`tPR_innehåll_ST_plats_EV_of` (
    positor int64,
    changingTimepoint datetime,
    positingTimepoint datetime,
    assertion string
)
AS (
SELECT
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Positor`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_innehåll_ST_plats_EV_of_Assertion`
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
            max(IF(r.`PR_innehåll_ST_plats_EV_of_Assertion` <> '?', r.`PR_innehåll_ST_plats_EV_of_ChangedAt`, null)) OVER (
                PARTITION BY
                    r.`PR_innehåll_ST_plats_EV_of_Positor`,
                    r.`PR_ID_innehåll`,
                    r.`ST_ID_plats`,
                    r.`EV_ID_of`
            ) AS `inEffect`
        FROM
            ties.`rPR_innehåll_ST_plats_EV_of`(
                CAST(null AS int64),
                CAST(changingTimepoint AS datetime),
                CAST(positingTimepoint AS datetime)
            ) r
    ) s
    WHERE
        s.`PR_innehåll_ST_plats_EV_of_Assertion` = coalesce(assertion, s.`PR_innehåll_ST_plats_EV_of_Assertion`)
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s.`PR_innehåll_ST_plats_EV_of_ChangedAt` = s.`inEffect`
    )
    QUALIFY -- picked by a window: BigQuery cannot evaluate a subquery that refers to the outer row and takes the first
            -- row of an ordering
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s.`PR_innehåll_ST_plats_EV_of_Positor`, s.`PR_ID_innehåll`
            ORDER BY
                s.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
                s.`PR_innehåll_ST_plats_EV_of_ID` DESC
        ) = 1
    AND
        row_number() OVER (
            PARTITION BY s.`PR_innehåll_ST_plats_EV_of_Positor`, s.`ST_ID_plats`
            ORDER BY
                s.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
                s.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
                s.`PR_innehåll_ST_plats_EV_of_ID` DESC
        ) = 1
) t
WHERE
    t.`PR_innehåll_ST_plats_EV_of_Positor` = positor
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lPR_innehåll_ST_plats_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tPR_innehåll_ST_plats_EV_of`(
        p.`Positor`,
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Positor`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    dw.`_Positor` p,
    ties.`tPR_innehåll_ST_plats_EV_of`(
        p.`Positor`,
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nPR_innehåll_ST_plats_EV_of` AS
SELECT
    p.`Positor`,
    cast(null as numeric(5,2)) AS `Reliability`,
    t.*
FROM
    dw.`_Positor` p,
    ties.`tPR_innehåll_ST_plats_EV_of`(
        p.`Positor`,
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_innehåll_ST_plats_EV_of` (
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
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Positor`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_innehåll_ST_plats_EV_of_Assertion`
FROM
    dw.`_Positor` p
JOIN (
    SELECT DISTINCT
        `PR_innehåll_ST_plats_EV_of_Positor` AS positor,
        CAST(`PR_innehåll_ST_plats_EV_of_ChangedAt` AS datetime) AS inspectedTimepoint
    FROM
        ties.`PR_innehåll_ST_plats_EV_of`
    WHERE
        `PR_innehåll_ST_plats_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p.`Positor`
JOIN (
    SELECT
        y.*,
        lead(y.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (
            PARTITION BY
                y.`PR_innehåll_ST_plats_EV_of_Positor`,
                y.`PR_ID_innehåll`,
                y.`ST_ID_plats`,
                y.`EV_ID_of`
            ORDER BY y.`PR_innehåll_ST_plats_EV_of_ChangedAt`
        ) AS `until`
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT
            r.*
        FROM
            ties.`rPR_innehåll_ST_plats_EV_of`(
                CAST(null AS int64),
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`PR_innehåll_ST_plats_EV_of_Assertion` <> '?'
        QUALIFY
            row_number() OVER (
                PARTITION BY
                    r.`PR_innehåll_ST_plats_EV_of_Positor`,
                    r.`PR_ID_innehåll`,
                    r.`ST_ID_plats`,
                    r.`EV_ID_of`,
                    r.`PR_innehåll_ST_plats_EV_of_ChangedAt`
                ORDER BY
                    IF(r.`PR_innehåll_ST_plats_EV_of_Assertion` = '+', 0, 1),
                    r.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
                    r.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
                    r.`PR_innehåll_ST_plats_EV_of_ID` DESC
            ) = 1
    ) y
) t
ON
    t.`PR_innehåll_ST_plats_EV_of_Positor` = tp.positor
AND
    t.`PR_innehåll_ST_plats_EV_of_Assertion` = '+'
AND
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt` <= CAST(tp.inspectedTimepoint AS datetime)
AND (
    t.`until` IS NULL
OR
    t.`until` > CAST(tp.inspectedTimepoint AS datetime)
)
WHERE
    TRUE
QUALIFY -- a tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`PR_ID_innehåll`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t.`ST_ID_plats`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_Reliability` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
)
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
ALTER SCHEMA dw SET OPTIONS(description='Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.');
ALTER TABLE knots.`PAT_Föräldratyp` SET OPTIONS(description='Kind of parent-child relationship between two actors, such as biological or adoptive parent.');
ALTER TABLE knots.`PAT_Föräldratyp` ALTER COLUMN `PAT_Föräldratyp` SET OPTIONS(description='Kind of parent-child relationship between two actors, such as biological or adoptive parent.');
ALTER TABLE knots.`GEN_Kön` SET OPTIONS(description='Gender of an actor.');
ALTER TABLE knots.`GEN_Kön` ALTER COLUMN `GEN_Kön` SET OPTIONS(description='Gender of an actor.');
ALTER TABLE knots.`PLV_Yrkesnivå` SET OPTIONS(description='Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.');
ALTER TABLE knots.`PLV_Yrkesnivå` ALTER COLUMN `PLV_Yrkesnivå` SET OPTIONS(description='Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.');
ALTER TABLE knots.`UTL_Utnyttjande` SET OPTIONS(description='Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.');
ALTER TABLE knots.`UTL_Utnyttjande` ALTER COLUMN `UTL_Utnyttjande` SET OPTIONS(description='Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.');
ALTER TABLE knots.`ONG_Pågående` SET OPTIONS(description='Yes or No flag indicating whether a relationship is still ongoing or has ended.');
ALTER TABLE knots.`ONG_Pågående` ALTER COLUMN `ONG_Pågående` SET OPTIONS(description='Yes or No flag indicating whether a relationship is still ongoing or has ended.');
ALTER TABLE knots.`RAT_Betyg` SET OPTIONS(description='Rating of how well an actor performs a part in a program, such as good, mediocre or bad.');
ALTER TABLE knots.`RAT_Betyg` ALTER COLUMN `RAT_Betyg` SET OPTIONS(description='Rating of how well an actor performs a part in a program, such as good, mediocre or bad.');
ALTER TABLE attributes.`EV_DAT_Händelse_Datum_Posit` ALTER COLUMN `EV_DAT_Händelse_Datum` SET OPTIONS(description='Date and time when the event took place.');
ALTER TABLE attributes.`EV_AUD_Händelse_Publik_Posit` ALTER COLUMN `EV_AUD_Händelse_Publik` SET OPTIONS(description='Number of people in the audience at the event.');
ALTER TABLE attributes.`EV_REV_Händelse_Intäkt_Posit` ALTER COLUMN `EV_REV_Händelse_Intäkt` SET OPTIONS(description='Revenue from ticket sales for the event.');
ALTER TABLE attributes.`EV_STA_Händelse_Status_Posit` ALTER COLUMN `EV_STA_Händelse_Status` SET OPTIONS(description='Status of the event, which may change until it has taken place.');
ALTER TABLE attributes.`EV_LVL_Händelse_Level_Posit` ALTER COLUMN `EV_LVL_PLV_ID` SET OPTIONS(description='Professional level required for the event, over time.');
ALTER TABLE attributes.`ST_NAM_Scen_Namn_Posit` ALTER COLUMN `ST_NAM_Scen_Namn` SET OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.');
ALTER TABLE attributes.`ST_LOC_Scen_Plats_Posit` ALTER COLUMN `ST_LOC_Scen_Plats` SET OPTIONS(description='Geographic location of the stage as a geography point.');
ALTER TABLE attributes.`ST_AVG_Scen_Medel_Posit` ALTER COLUMN `ST_AVG_UTL_ID` SET OPTIONS(description='Average utilization of the stage capacity, recalculated over time.');
ALTER TABLE attributes.`ST_MIN_Scen_Minimum_Posit` ALTER COLUMN `ST_MIN_UTL_ID` SET OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.');
ALTER TABLE attributes.`AC_NAM_Skådespelare_Namn_Posit` ALTER COLUMN `AC_NAM_Skådespelare_Namn` SET OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.');
ALTER TABLE attributes.`AC_GEN_Skådespelare_Kön_Posit` ALTER COLUMN `AC_GEN_GEN_ID` SET OPTIONS(description='Gender of the actor.');
ALTER TABLE attributes.`AC_PLV_Skådespelare_Yrkesnivå_Posit` ALTER COLUMN `AC_PLV_PLV_ID` SET OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.');
ALTER TABLE attributes.`PR_NAM_Föreställning_Namn_Posit` ALTER COLUMN `PR_NAM_Föreställning_Namn` SET OPTIONS(description='Name or title of the program.');
ALTER TABLE attributes.`PR_LEN_Föreställning_Längd_Posit` ALTER COLUMN `PR_LEN_Föreställning_Längd` SET OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.');
ALTER TABLE anchors.`PN_Person` SET OPTIONS(description='A person. Persons who perform are also registered as actors.');
ALTER TABLE anchors.`ST_Scen` SET OPTIONS(description='A stage or venue where programs are played and events are held.');
ALTER TABLE anchors.`AC_Skådespelare` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE nexuses.`EV_Händelse` SET OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.');
ALTER TABLE nexuses.`EV_Händelse` ALTER COLUMN `ST_ID_hölls` SET OPTIONS(description='The stage at which the event was held.');
ALTER TABLE nexuses.`EV_Händelse` ALTER COLUMN `PR_ID_spelades` SET OPTIONS(description='The program that was played at the event.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Posit` SET OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Posit` ALTER COLUMN `AC_ID_partner` SET OPTIONS(description='One of the actors in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Posit` ALTER COLUMN `AC_ID_with` SET OPTIONS(description='The other actor in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently_Posit` ALTER COLUMN `ONG_ID_currently` SET OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).');
ALTER TABLE ties.`AC_subset_PN_of_Posit` ALTER COLUMN `AC_ID_subset` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE ties.`AC_subset_PN_of_Posit` ALTER COLUMN `PN_ID_of` SET OPTIONS(description='The person who is the actor.');
ALTER TABLE ties.`EV_in_AC_rollsattes_Posit` SET OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.');
ALTER TABLE ties.`EV_in_AC_rollsattes_Posit` ALTER COLUMN `EV_ID_in` SET OPTIONS(description='The event the actor was cast in.');
ALTER TABLE ties.`EV_in_AC_rollsattes_Posit` ALTER COLUMN `AC_ID_rollsattes` SET OPTIONS(description='An actor cast in the event.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick_Posit` SET OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick_Posit` ALTER COLUMN `AC_ID_deltar` SET OPTIONS(description='The actor having a part in the program.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick_Posit` ALTER COLUMN `PR_ID_in` SET OPTIONS(description='The program the actor has a part in.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick_Posit` ALTER COLUMN `RAT_ID_fick` SET OPTIONS(description='The rating the actor got for the part.');
ALTER TABLE ties.`ST_at_PR_spelas_Posit` SET OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.');
ALTER TABLE ties.`ST_at_PR_spelas_Posit` ALTER COLUMN `ST_ID_at` SET OPTIONS(description='The stage where the program is playing.');
ALTER TABLE ties.`ST_at_PR_spelas_Posit` ALTER COLUMN `PR_ID_spelas` SET OPTIONS(description='The program playing at the stage.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har_Posit` SET OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har_Posit` ALTER COLUMN `AC_ID_förälder` SET OPTIONS(description='The actor who is the parent.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har_Posit` ALTER COLUMN `AC_ID_barn` SET OPTIONS(description='The actor who is the child.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har_Posit` ALTER COLUMN `PAT_ID_har` SET OPTIONS(description='The type of parental relationship.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of_Posit` SET OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of_Posit` ALTER COLUMN `PR_ID_innehåll` SET OPTIONS(description='The program that made up the content of the event.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of_Posit` ALTER COLUMN `ST_ID_plats` SET OPTIONS(description='The stage where the event was located.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of_Posit` ALTER COLUMN `EV_ID_of` SET OPTIONS(description='The event.');
