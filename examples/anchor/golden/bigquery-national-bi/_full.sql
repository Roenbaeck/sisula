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
-- BI attributes use posit and annex split with changing/positing time and reliability.
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
    `EV_DAT_Reliability` numeric(5,2) not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_ID`,
        `EV_DAT_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Händelse_Datum_Annex` FOREIGN KEY (`EV_DAT_ID`) REFERENCES
        attributes.`EV_DAT_Händelse_Datum_Posit`(`EV_DAT_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_ID`, `EV_DAT_PositedAt`;
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
    `EV_AUD_Reliability` numeric(5,2) not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_ID`,
        `EV_AUD_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Händelse_Publik_Annex` FOREIGN KEY (`EV_AUD_ID`) REFERENCES
        attributes.`EV_AUD_Händelse_Publik_Posit`(`EV_AUD_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_ID`, `EV_AUD_PositedAt`;
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
    `EV_REV_Reliability` numeric(5,2) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_ID`,
        `EV_REV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Händelse_Intäkt_Annex` FOREIGN KEY (`EV_REV_ID`) REFERENCES
        attributes.`EV_REV_Händelse_Intäkt_Posit`(`EV_REV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_ID`, `EV_REV_PositedAt`;
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
    `EV_STA_Reliability` numeric(5,2) not null,
    `Metadata_EV_STA` int64 not null,
    PRIMARY KEY (
        `EV_STA_ID`,
        `EV_STA_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Händelse_Status_Annex` FOREIGN KEY (`EV_STA_ID`) REFERENCES
        attributes.`EV_STA_Händelse_Status_Posit`(`EV_STA_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_ID`, `EV_STA_PositedAt`;
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
    `EV_UTL_Reliability` numeric(5,2) not null,
    `Metadata_EV_UTL` int64 not null,
    PRIMARY KEY (
        `EV_UTL_ID`,
        `EV_UTL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_UTL_Händelse_Utnyttjande_Annex` FOREIGN KEY (`EV_UTL_ID`) REFERENCES
        attributes.`EV_UTL_Händelse_Utnyttjande_Posit`(`EV_UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_ID`, `EV_UTL_PositedAt`;
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
    `EV_LVL_Reliability` numeric(5,2) not null,
    `Metadata_EV_LVL` int64 not null,
    PRIMARY KEY (
        `EV_LVL_ID`,
        `EV_LVL_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_LVL_Händelse_Level_Annex` FOREIGN KEY (`EV_LVL_ID`) REFERENCES
        attributes.`EV_LVL_Händelse_Level_Posit`(`EV_LVL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_ID`, `EV_LVL_PositedAt`;
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
    `ST_NAM_Reliability` numeric(5,2) not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ID`,
        `ST_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Scen_Namn_Annex` FOREIGN KEY (`ST_NAM_ID`) REFERENCES
        attributes.`ST_NAM_Scen_Namn_Posit`(`ST_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ID`, `ST_NAM_PositedAt`;
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
    `ST_LOC_Reliability` numeric(5,2) not null,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ID`,
        `ST_LOC_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Scen_Plats_Annex` FOREIGN KEY (`ST_LOC_ID`) REFERENCES
        attributes.`ST_LOC_Scen_Plats_Posit`(`ST_LOC_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ID`, `ST_LOC_PositedAt`;
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
    `ST_AVG_Reliability` numeric(5,2) not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ID`,
        `ST_AVG_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_AVG_Scen_Medel_Annex` FOREIGN KEY (`ST_AVG_ID`) REFERENCES
        attributes.`ST_AVG_Scen_Medel_Posit`(`ST_AVG_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ID`, `ST_AVG_PositedAt`;
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
    `ST_MIN_Reliability` numeric(5,2) not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ID`,
        `ST_MIN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_MIN_Scen_Minimum_Annex` FOREIGN KEY (`ST_MIN_ID`) REFERENCES
        attributes.`ST_MIN_Scen_Minimum_Posit`(`ST_MIN_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ID`, `ST_MIN_PositedAt`;
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
    `AC_NAM_Reliability` numeric(5,2) not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_ID`,
        `AC_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Skådespelare_Namn_Annex` FOREIGN KEY (`AC_NAM_ID`) REFERENCES
        attributes.`AC_NAM_Skådespelare_Namn_Posit`(`AC_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_ID`, `AC_NAM_PositedAt`;
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
    `AC_GEN_Reliability` numeric(5,2) not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_ID`,
        `AC_GEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_GEN_Skådespelare_Kön_Annex` FOREIGN KEY (`AC_GEN_ID`) REFERENCES
        attributes.`AC_GEN_Skådespelare_Kön_Posit`(`AC_GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_ID`, `AC_GEN_PositedAt`;
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
    `AC_PLV_Reliability` numeric(5,2) not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_ID`,
        `AC_PLV_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_PLV_Skådespelare_Yrkesnivå_Annex` FOREIGN KEY (`AC_PLV_ID`) REFERENCES
        attributes.`AC_PLV_Skådespelare_Yrkesnivå_Posit`(`AC_PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_ID`, `AC_PLV_PositedAt`;
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
    `PR_NAM_Reliability` numeric(5,2) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_ID`,
        `PR_NAM_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Föreställning_Namn_Annex` FOREIGN KEY (`PR_NAM_ID`) REFERENCES
        attributes.`PR_NAM_Föreställning_Namn_Posit`(`PR_NAM_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_ID`, `PR_NAM_PositedAt`;
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
    `PR_LEN_Reliability` numeric(5,2) not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_ID`,
        `PR_LEN_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Föreställning_Längd_Annex` FOREIGN KEY (`PR_LEN_ID`) REFERENCES
        attributes.`PR_LEN_Föreställning_Längd_Posit`(`PR_LEN_ID`) NOT ENFORCED
)
CLUSTER BY `PR_LEN_ID`, `PR_LEN_PositedAt`;
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
    a.`EV_DAT_Reliability`
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
    a.`EV_AUD_Reliability`
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
    a.`EV_REV_Reliability`
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
    a.`EV_STA_Reliability`
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
    a.`EV_UTL_Reliability`
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
    a.`EV_LVL_Reliability`
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
    a.`ST_NAM_Reliability`
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
    a.`ST_LOC_Reliability`
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
    a.`ST_AVG_Reliability`
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
    a.`ST_MIN_Reliability`
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
    a.`AC_NAM_Reliability`
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
    a.`AC_GEN_Reliability`
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
    a.`AC_PLV_Reliability`
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
    a.`PR_NAM_Reliability`
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
    a.`PR_LEN_Reliability`
FROM
    attributes.`PR_LEN_Föreställning_Längd_Posit` p
JOIN
    attributes.`PR_LEN_Föreställning_Längd_Annex` a
ON
    a.`PR_LEN_ID` = p.`PR_LEN_ID`
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Händelse_Datum_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_DAT`,
    `EV_DAT_ID`,
    `EV_DAT_PositedAt`,
    `EV_DAT_Reliability`
FROM
    attributes.`EV_DAT_Händelse_Datum_Annex`
WHERE
    `EV_DAT_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_DAT_Händelse_Datum` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_DAT`,
    p.`EV_DAT_ID`,
    a.`EV_DAT_PositedAt`,
    a.`EV_DAT_Reliability`,
    p.`EV_DAT_EV_ID`,
    p.`EV_DAT_Händelse_Datum`
FROM
    attributes.`EV_DAT_Händelse_Datum_Posit` p
JOIN
    attributes.`rEV_DAT_Händelse_Datum_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Händelse_Publik_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_AUD`,
    `EV_AUD_ID`,
    `EV_AUD_PositedAt`,
    `EV_AUD_Reliability`
FROM
    attributes.`EV_AUD_Händelse_Publik_Annex`
WHERE
    `EV_AUD_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_AUD_Händelse_Publik` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_AUD`,
    p.`EV_AUD_ID`,
    a.`EV_AUD_PositedAt`,
    a.`EV_AUD_Reliability`,
    p.`EV_AUD_EV_ID`,
    p.`EV_AUD_Händelse_Publik`
FROM
    attributes.`EV_AUD_Händelse_Publik_Posit` p
JOIN
    attributes.`rEV_AUD_Händelse_Publik_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Händelse_Intäkt_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_REV`,
    `EV_REV_ID`,
    `EV_REV_PositedAt`,
    `EV_REV_Reliability`
FROM
    attributes.`EV_REV_Händelse_Intäkt_Annex`
WHERE
    `EV_REV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_REV_Händelse_Intäkt` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_REV`,
    p.`EV_REV_ID`,
    a.`EV_REV_PositedAt`,
    a.`EV_REV_Reliability`,
    p.`EV_REV_EV_ID`,
    p.`EV_REV_Händelse_Intäkt`
FROM
    attributes.`EV_REV_Händelse_Intäkt_Posit` p
JOIN
    attributes.`rEV_REV_Händelse_Intäkt_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Händelse_Status_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_STA`,
    `EV_STA_ID`,
    `EV_STA_PositedAt`,
    `EV_STA_Reliability`
FROM
    attributes.`EV_STA_Händelse_Status_Annex`
WHERE
    `EV_STA_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Händelse_Status` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Reliability`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Händelse_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`rEV_STA_Händelse_Status_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Händelse_Status_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_STA_Händelse_Status` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_STA`,
    p.`EV_STA_ID`,
    a.`EV_STA_PositedAt`,
    a.`EV_STA_Reliability`,
    p.`EV_STA_EV_ID`,
    p.`EV_STA_Händelse_Status`,
    p.`EV_STA_ChangedAt`
FROM
    attributes.`fEV_STA_Händelse_Status_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_STA_Händelse_Status_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_STA_Händelse_Status` (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`EV_STA_Händelse_Status`
FROM
    attributes.`rEV_STA_Händelse_Status`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_STA_EV_ID` = id
AND
    pre.`EV_STA_ChangedAt` < changingTimepoint
AND
    pre.`EV_STA_Reliability` = 1
ORDER BY
    pre.`EV_STA_ChangedAt` DESC,
    pre.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_STA_Händelse_Status` (
    id numeric(12,0),
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`EV_STA_Händelse_Status`
FROM
    attributes.`fEV_STA_Händelse_Status`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_STA_EV_ID` = id
AND
    fol.`EV_STA_ChangedAt` > changingTimepoint
AND
    fol.`EV_STA_Reliability` = 1
ORDER BY
    fol.`EV_STA_ChangedAt` ASC,
    fol.`EV_STA_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Händelse_Utnyttjande_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_UTL`,
    `EV_UTL_ID`,
    `EV_UTL_PositedAt`,
    `EV_UTL_Reliability`
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande_Annex`
WHERE
    `EV_UTL_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_UTL_Händelse_Utnyttjande` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_UTL`,
    p.`EV_UTL_ID`,
    a.`EV_UTL_PositedAt`,
    a.`EV_UTL_Reliability`,
    p.`EV_UTL_EV_ID`,
    p.`EV_UTL_UTL_ID`
FROM
    attributes.`EV_UTL_Händelse_Utnyttjande_Posit` p
JOIN
    attributes.`rEV_UTL_Händelse_Utnyttjande_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Händelse_Level_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_LVL`,
    `EV_LVL_ID`,
    `EV_LVL_PositedAt`,
    `EV_LVL_Reliability`
FROM
    attributes.`EV_LVL_Händelse_Level_Annex`
WHERE
    `EV_LVL_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Händelse_Level` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Reliability`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`rEV_LVL_Händelse_Level_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Händelse_Level_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fEV_LVL_Händelse_Level` (
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_LVL`,
    p.`EV_LVL_ID`,
    a.`EV_LVL_PositedAt`,
    a.`EV_LVL_Reliability`,
    p.`EV_LVL_EV_ID`,
    p.`EV_LVL_PLV_ID`,
    p.`EV_LVL_ChangedAt`
FROM
    attributes.`fEV_LVL_Händelse_Level_Posit`(changingTimepoint) p
JOIN
    attributes.`rEV_LVL_Händelse_Level_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preEV_LVL_Händelse_Level` (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`EV_LVL_PLV_ID`
FROM
    attributes.`rEV_LVL_Händelse_Level`(changingTimepoint, positingTimepoint) pre
WHERE
    pre.`EV_LVL_EV_ID` = id
AND
    pre.`EV_LVL_ChangedAt` < changingTimepoint
AND
    pre.`EV_LVL_Reliability` = 1
ORDER BY
    pre.`EV_LVL_ChangedAt` DESC,
    pre.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`folEV_LVL_Händelse_Level` (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`EV_LVL_PLV_ID`
FROM
    attributes.`fEV_LVL_Händelse_Level`(changingTimepoint, positingTimepoint) fol
WHERE
    fol.`EV_LVL_EV_ID` = id
AND
    fol.`EV_LVL_ChangedAt` > changingTimepoint
AND
    fol.`EV_LVL_Reliability` = 1
ORDER BY
    fol.`EV_LVL_ChangedAt` ASC,
    fol.`EV_LVL_PositedAt` DESC
LIMIT 1
)
;
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Scen_Namn_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_NAM`,
    `ST_NAM_ID`,
    `ST_NAM_PositedAt`,
    `ST_NAM_Reliability`
FROM
    attributes.`ST_NAM_Scen_Namn_Annex`
WHERE
    `ST_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Scen_Namn` (
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
    p.`ST_NAM_Scen_Namn`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`rST_NAM_Scen_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Scen_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_NAM_Scen_Namn` (
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
    p.`ST_NAM_Scen_Namn`,
    p.`ST_NAM_ChangedAt`
FROM
    attributes.`fST_NAM_Scen_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_NAM_Scen_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_NAM_Scen_Namn` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_NAM_Scen_Namn`
FROM
    attributes.`rST_NAM_Scen_Namn`(changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_NAM_Scen_Namn` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_NAM_Scen_Namn`
FROM
    attributes.`fST_NAM_Scen_Namn`(changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Scen_Plats_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_LOC`,
    `ST_LOC_ID`,
    `ST_LOC_PositedAt`,
    `ST_LOC_Reliability`
FROM
    attributes.`ST_LOC_Scen_Plats_Annex`
WHERE
    `ST_LOC_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_LOC_Scen_Plats` (
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
    p.`ST_LOC_Scen_Plats`
FROM
    attributes.`ST_LOC_Scen_Plats_Posit` p
JOIN
    attributes.`rST_LOC_Scen_Plats_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Scen_Medel_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_AVG`,
    `ST_AVG_ID`,
    `ST_AVG_PositedAt`,
    `ST_AVG_Reliability`
FROM
    attributes.`ST_AVG_Scen_Medel_Annex`
WHERE
    `ST_AVG_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Scen_Medel` (
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
    attributes.`rST_AVG_Scen_Medel_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Scen_Medel_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fST_AVG_Scen_Medel` (
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
    attributes.`fST_AVG_Scen_Medel_Posit`(changingTimepoint) p
JOIN
    attributes.`rST_AVG_Scen_Medel_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preST_AVG_Scen_Medel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`ST_AVG_UTL_ID`
FROM
    attributes.`rST_AVG_Scen_Medel`(changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folST_AVG_Scen_Medel` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`ST_AVG_UTL_ID`
FROM
    attributes.`fST_AVG_Scen_Medel`(changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Scen_Minimum_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_ST_MIN`,
    `ST_MIN_ID`,
    `ST_MIN_PositedAt`,
    `ST_MIN_Reliability`
FROM
    attributes.`ST_MIN_Scen_Minimum_Annex`
WHERE
    `ST_MIN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_MIN_Scen_Minimum` (
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
    attributes.`ST_MIN_Scen_Minimum_Posit` p
JOIN
    attributes.`rST_MIN_Scen_Minimum_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Skådespelare_Namn_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_NAM`,
    `AC_NAM_ID`,
    `AC_NAM_PositedAt`,
    `AC_NAM_Reliability`
FROM
    attributes.`AC_NAM_Skådespelare_Namn_Annex`
WHERE
    `AC_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Skådespelare_Namn` (
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
    p.`AC_NAM_Skådespelare_Namn`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`rAC_NAM_Skådespelare_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Skådespelare_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_NAM_Skådespelare_Namn` (
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
    p.`AC_NAM_Skådespelare_Namn`,
    p.`AC_NAM_ChangedAt`
FROM
    attributes.`fAC_NAM_Skådespelare_Namn_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_NAM_Skådespelare_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_NAM_Skådespelare_Namn` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_NAM_Skådespelare_Namn`
FROM
    attributes.`rAC_NAM_Skådespelare_Namn`(changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_NAM_Skådespelare_Namn` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_NAM_Skådespelare_Namn`
FROM
    attributes.`fAC_NAM_Skådespelare_Namn`(changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Skådespelare_Kön_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_GEN`,
    `AC_GEN_ID`,
    `AC_GEN_PositedAt`,
    `AC_GEN_Reliability`
FROM
    attributes.`AC_GEN_Skådespelare_Kön_Annex`
WHERE
    `AC_GEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_GEN_Skådespelare_Kön` (
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
    attributes.`AC_GEN_Skådespelare_Kön_Posit` p
JOIN
    attributes.`rAC_GEN_Skådespelare_Kön_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_PLV`,
    `AC_PLV_ID`,
    `AC_PLV_PositedAt`,
    `AC_PLV_Reliability`
FROM
    attributes.`AC_PLV_Skådespelare_Yrkesnivå_Annex`
WHERE
    `AC_PLV_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Skådespelare_Yrkesnivå` (
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
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fAC_PLV_Skådespelare_Yrkesnivå` (
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
    attributes.`fAC_PLV_Skådespelare_Yrkesnivå_Posit`(changingTimepoint) p
JOIN
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`preAC_PLV_Skådespelare_Yrkesnivå` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`AC_PLV_PLV_ID`
FROM
    attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folAC_PLV_Skådespelare_Yrkesnivå` (
    id int64,
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`AC_PLV_PLV_ID`
FROM
    attributes.`fAC_PLV_Skådespelare_Yrkesnivå`(changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Föreställning_Namn_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_NAM`,
    `PR_NAM_ID`,
    `PR_NAM_PositedAt`,
    `PR_NAM_Reliability`
FROM
    attributes.`PR_NAM_Föreställning_Namn_Annex`
WHERE
    `PR_NAM_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_NAM_Föreställning_Namn` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_PR_NAM`,
    p.`PR_NAM_ID`,
    a.`PR_NAM_PositedAt`,
    a.`PR_NAM_Reliability`,
    p.`PR_NAM_PR_ID`,
    p.`PR_NAM_Föreställning_Namn`
FROM
    attributes.`PR_NAM_Föreställning_Namn_Posit` p
JOIN
    attributes.`rPR_NAM_Föreställning_Namn_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Föreställning_Längd_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_PR_LEN`,
    `PR_LEN_ID`,
    `PR_LEN_PositedAt`,
    `PR_LEN_Reliability`
FROM
    attributes.`PR_LEN_Föreställning_Längd_Annex`
WHERE
    `PR_LEN_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Föreställning_Längd` (
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
    p.`PR_LEN_Föreställning_Längd`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`rPR_LEN_Föreställning_Längd_Posit`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Föreställning_Längd_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`fPR_LEN_Föreställning_Längd` (
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
    p.`PR_LEN_Föreställning_Längd`,
    p.`PR_LEN_ChangedAt`
FROM
    attributes.`fPR_LEN_Föreställning_Längd_Posit`(changingTimepoint) p
JOIN
    attributes.`rPR_LEN_Föreställning_Längd_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION attributes.`prePR_LEN_Föreställning_Längd` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    pre.`PR_LEN_Föreställning_Längd`
FROM
    attributes.`rPR_LEN_Föreställning_Längd`(changingTimepoint, positingTimepoint) pre
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
CREATE OR REPLACE TABLE FUNCTION attributes.`folPR_LEN_Föreställning_Längd` (
    id int64,
    changingTimepoint date,
    positingTimepoint datetime
)
AS (
SELECT
    fol.`PR_LEN_Föreställning_Längd`
FROM
    attributes.`fPR_LEN_Föreställning_Längd`(changingTimepoint, positingTimepoint) fol
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
CREATE OR REPLACE TABLE FUNCTION anchors.`tST_Scen` (
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
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Scen` `ST`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_NAM_Scen_Namn`(
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
        attributes.`rST_LOC_Scen_Plats`(
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
        attributes.`rST_AVG_Scen_Medel`(
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
    knots.`UTL_Utnyttjande` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rST_MIN_Scen_Minimum`(
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
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE VIEW anchors.`lST_Scen` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    anchors.`tST_Scen`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pST_Scen` (
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
    `ST`.`ST_NAM_Scen_Namn`,
    `ST`.`ST_LOC_ST_ID`,
    `ST`.`Metadata_ST_LOC`,
    `ST`.`ST_LOC_ID`,
    `ST`.`ST_LOC_PositedAt`,
    `ST`.`ST_LOC_Reliability`,
    `ST`.`ST_LOC_Checksum`,
    `ST`.`ST_LOC_Scen_Plats`,
    `ST`.`ST_AVG_ST_ID`,
    `ST`.`Metadata_ST_AVG`,
    `ST`.`ST_AVG_ID`,
    `ST`.`ST_AVG_ChangedAt`,
    `ST`.`ST_AVG_PositedAt`,
    `ST`.`ST_AVG_Reliability`,
    `ST`.`ST_AVG_UTL_Utnyttjande`,
    `ST`.`ST_AVG_Metadata_UTL`,
    `ST`.`ST_AVG_UTL_ID`,
    `ST`.`ST_MIN_ST_ID`,
    `ST`.`Metadata_ST_MIN`,
    `ST`.`ST_MIN_ID`,
    `ST`.`ST_MIN_PositedAt`,
    `ST`.`ST_MIN_Reliability`,
    `ST`.`ST_MIN_UTL_Utnyttjande`,
    `ST`.`ST_MIN_Metadata_UTL`,
    `ST`.`ST_MIN_UTL_ID`
FROM
    anchors.`tST_Scen`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
)
;
CREATE OR REPLACE VIEW anchors.`nST_Scen` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `ST`.*
FROM
    anchors.`tST_Scen`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `ST`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dST_Scen` (
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
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_ID`,
    `LOC`.`ST_LOC_PositedAt`,
    `LOC`.`ST_LOC_Reliability`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ID`,
    `AVG`.`ST_AVG_ChangedAt`,
    `AVG`.`ST_AVG_PositedAt`,
    `AVG`.`ST_AVG_Reliability`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `MIN`.`ST_MIN_ID`,
    `MIN`.`ST_MIN_PositedAt`,
    `MIN`.`ST_MIN_Reliability`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM (
    SELECT DISTINCT
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
JOIN
    anchors.`ST_Scen` `ST`
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
            attributes.`rST_NAM_Scen_Namn`(
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
        attributes.`rST_LOC_Scen_Plats`(
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
            attributes.`rST_AVG_Scen_Medel`(
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
    knots.`UTL_Utnyttjande` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rST_MIN_Scen_Minimum`(
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
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION anchors.`tAC_Skådespelare` (
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
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Skådespelare` `AC`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_NAM_Skådespelare_Namn`(
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
        attributes.`rAC_GEN_Skådespelare_Kön`(
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
    knots.`GEN_Kön` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(
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
    knots.`PLV_Yrkesnivå` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
CREATE OR REPLACE VIEW anchors.`lAC_Skådespelare` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    anchors.`tAC_Skådespelare`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pAC_Skådespelare` (
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
    `AC`.`AC_NAM_Skådespelare_Namn`,
    `AC`.`AC_GEN_AC_ID`,
    `AC`.`Metadata_AC_GEN`,
    `AC`.`AC_GEN_ID`,
    `AC`.`AC_GEN_PositedAt`,
    `AC`.`AC_GEN_Reliability`,
    `AC`.`AC_GEN_GEN_Checksum`,
    `AC`.`AC_GEN_GEN_Kön`,
    `AC`.`AC_GEN_Metadata_GEN`,
    `AC`.`AC_GEN_GEN_ID`,
    `AC`.`AC_PLV_AC_ID`,
    `AC`.`Metadata_AC_PLV`,
    `AC`.`AC_PLV_ID`,
    `AC`.`AC_PLV_ChangedAt`,
    `AC`.`AC_PLV_PositedAt`,
    `AC`.`AC_PLV_Reliability`,
    `AC`.`AC_PLV_PLV_Checksum`,
    `AC`.`AC_PLV_PLV_Yrkesnivå`,
    `AC`.`AC_PLV_Metadata_PLV`,
    `AC`.`AC_PLV_PLV_ID`
FROM
    anchors.`tAC_Skådespelare`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
)
;
CREATE OR REPLACE VIEW anchors.`nAC_Skådespelare` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `AC`.*
FROM
    anchors.`tAC_Skådespelare`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `AC`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dAC_Skådespelare` (
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
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `GEN`.`AC_GEN_ID`,
    `GEN`.`AC_GEN_PositedAt`,
    `GEN`.`AC_GEN_Reliability`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ID`,
    `PLV`.`AC_PLV_ChangedAt`,
    `PLV`.`AC_PLV_PositedAt`,
    `PLV`.`AC_PLV_Reliability`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM (
    SELECT DISTINCT
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
JOIN
    anchors.`AC_Skådespelare` `AC`
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
            attributes.`rAC_NAM_Skådespelare_Namn`(
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
        attributes.`rAC_GEN_Skådespelare_Kön`(
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
    knots.`GEN_Kön` `kGEN`
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
            attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(
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
    knots.`PLV_Yrkesnivå` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
CREATE OR REPLACE TABLE FUNCTION anchors.`tPR_Föreställning` (
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
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM
    anchors.`PR_Föreställning` `PR`
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rPR_NAM_Föreställning_Namn`(
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
        attributes.`rPR_LEN_Föreställning_Längd`(
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
CREATE OR REPLACE VIEW anchors.`lPR_Föreställning` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    anchors.`tPR_Föreställning`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`pPR_Föreställning` (
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
    `PR`.`PR_NAM_Föreställning_Namn`,
    `PR`.`PR_LEN_PR_ID`,
    `PR`.`Metadata_PR_LEN`,
    `PR`.`PR_LEN_ID`,
    `PR`.`PR_LEN_ChangedAt`,
    `PR`.`PR_LEN_PositedAt`,
    `PR`.`PR_LEN_Reliability`,
    `PR`.`PR_LEN_Föreställning_Längd`
FROM
    anchors.`tPR_Föreställning`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
)
;
CREATE OR REPLACE VIEW anchors.`nPR_Föreställning` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `PR`.*
FROM
    anchors.`tPR_Föreställning`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `PR`
;
CREATE OR REPLACE TABLE FUNCTION anchors.`dPR_Föreställning` (
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
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ID`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_PositedAt`,
    `LEN`.`PR_LEN_Reliability`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM (
    SELECT DISTINCT
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
JOIN
    anchors.`PR_Föreställning` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rPR_NAM_Föreställning_Namn`(
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
            attributes.`rPR_LEN_Föreställning_Längd`(
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
CREATE OR REPLACE TABLE FUNCTION nexuses.`tEV_Händelse` (
    changingTimepoint datetime,
    positingTimepoint datetime
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
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Reliability`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Reliability`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Händelse` `EV`
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Händelse_Datum`(
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
        attributes.`rEV_AUD_Händelse_Publik`(
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
        attributes.`rEV_REV_Händelse_Intäkt`(
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
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_STA_Händelse_Status`(
            CAST(changingTimepoint AS datetime),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_STA_Reliability` = 1
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
        attributes.`rEV_UTL_Händelse_Utnyttjande`(
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Reliability` = 1
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
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window: BigQuery cannot evaluate a subquery that refers to
    -- the outer row and takes the first row of an ordering
    SELECT
        r.*
    FROM
        attributes.`rEV_LVL_Händelse_Level`(
            CAST(changingTimepoint AS date),
            CAST(positingTimepoint AS datetime)
        ) r
    WHERE
        r.`EV_LVL_Reliability` = 1
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
    knots.`PLV_Yrkesnivå` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`
)
;
CREATE OR REPLACE VIEW nexuses.`lEV_Händelse` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    nexuses.`tEV_Händelse`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Händelse` (
    changingTimepoint datetime
)
AS (
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
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
    `EV`.`EV_DAT_Reliability`,
    `EV`.`EV_DAT_Händelse_Datum`,
    `EV`.`EV_AUD_EV_ID`,
    `EV`.`Metadata_EV_AUD`,
    `EV`.`EV_AUD_ID`,
    `EV`.`EV_AUD_PositedAt`,
    `EV`.`EV_AUD_Reliability`,
    `EV`.`EV_AUD_Händelse_Publik`,
    `EV`.`EV_REV_EV_ID`,
    `EV`.`Metadata_EV_REV`,
    `EV`.`EV_REV_ID`,
    `EV`.`EV_REV_PositedAt`,
    `EV`.`EV_REV_Reliability`,
    `EV`.`EV_REV_Händelse_Intäkt`,
    `EV`.`EV_STA_EV_ID`,
    `EV`.`Metadata_EV_STA`,
    `EV`.`EV_STA_ID`,
    `EV`.`EV_STA_ChangedAt`,
    `EV`.`EV_STA_PositedAt`,
    `EV`.`EV_STA_Reliability`,
    `EV`.`EV_STA_Händelse_Status`,
    `EV`.`EV_UTL_EV_ID`,
    `EV`.`Metadata_EV_UTL`,
    `EV`.`EV_UTL_ID`,
    `EV`.`EV_UTL_PositedAt`,
    `EV`.`EV_UTL_Reliability`,
    `EV`.`EV_UTL_UTL_Utnyttjande`,
    `EV`.`EV_UTL_Metadata_UTL`,
    `EV`.`EV_UTL_UTL_ID`,
    `EV`.`EV_LVL_EV_ID`,
    `EV`.`Metadata_EV_LVL`,
    `EV`.`EV_LVL_ID`,
    `EV`.`EV_LVL_ChangedAt`,
    `EV`.`EV_LVL_PositedAt`,
    `EV`.`EV_LVL_Reliability`,
    `EV`.`EV_LVL_PLV_Checksum`,
    `EV`.`EV_LVL_PLV_Yrkesnivå`,
    `EV`.`EV_LVL_Metadata_PLV`,
    `EV`.`EV_LVL_PLV_ID`
FROM
    nexuses.`tEV_Händelse`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
)
;
CREATE OR REPLACE VIEW nexuses.`nEV_Händelse` AS
SELECT
    cast(null as numeric(5,2)) as `Reliability`,
    `EV`.*
FROM
    nexuses.`tEV_Händelse`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    ) `EV`
;
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Händelse` (
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
    `DAT`.`EV_DAT_Reliability`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_ID`,
    `AUD`.`EV_AUD_PositedAt`,
    `AUD`.`EV_AUD_Reliability`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_ID`,
    `REV`.`EV_REV_PositedAt`,
    `REV`.`EV_REV_Reliability`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ID`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_PositedAt`,
    `STA`.`EV_STA_Reliability`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `UTL`.`EV_UTL_ID`,
    `UTL`.`EV_UTL_PositedAt`,
    `UTL`.`EV_UTL_Reliability`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ID`,
    `LVL`.`EV_LVL_ChangedAt`,
    `LVL`.`EV_LVL_PositedAt`,
    `LVL`.`EV_LVL_Reliability`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM (
    SELECT DISTINCT
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
        `EV_LVL_EV_ID` AS `EV_ID`,
        CAST(`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Händelse_Level`
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        `EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses.`EV_Händelse` `EV`
ON
    `EV`.`EV_ID` = timepoints.`EV_ID`
LEFT JOIN
    knots.`ETY_Händelsetyp` `kETY_of`
ON
    `kETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN (
    SELECT
        r.*
    FROM
        attributes.`rEV_DAT_Händelse_Datum`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_DAT_Reliability` = 1
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
        attributes.`rEV_AUD_Händelse_Publik`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_AUD_Reliability` = 1
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
        attributes.`rEV_REV_Händelse_Intäkt`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_REV_Reliability` = 1
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
            attributes.`rEV_STA_Händelse_Status`(
                CAST('9999-12-31' AS datetime),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_STA_Reliability` = 1
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
        attributes.`rEV_UTL_Händelse_Utnyttjande`(
            CAST('9999-12-31' AS datetime)
        ) r
    WHERE
        r.`EV_UTL_Reliability` = 1
    QUALIFY
        row_number() OVER (
            PARTITION BY r.`EV_UTL_EV_ID`
            ORDER BY r.`EV_UTL_PositedAt` DESC
        ) = 1
) `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
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
            attributes.`rEV_LVL_Händelse_Level`(
                CAST('9999-12-31' AS date),
                CAST('9999-12-31' AS datetime)
            ) r
        WHERE
            r.`EV_LVL_Reliability` = 1
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
    knots.`PLV_Yrkesnivå` `kLVL`
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
    `AC_partner_AC_with_ONG_currently_Reliability` numeric(5,2) not null,
    `Metadata_AC_partner_AC_with_ONG_currently` int64 not null,
    PRIMARY KEY (
        `AC_partner_AC_with_ONG_currently_ID`,
        `AC_partner_AC_with_ONG_currently_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_partner_AC_with_ONG_currently_Annex` FOREIGN KEY (`AC_partner_AC_with_ONG_currently_ID`) REFERENCES
        ties.`AC_partner_AC_with_ONG_currently_Posit`(`AC_partner_AC_with_ONG_currently_ID`) NOT ENFORCED
)
CLUSTER BY `AC_partner_AC_with_ONG_currently_ID`, `AC_partner_AC_with_ONG_currently_PositedAt`;
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
    `AC_subset_PN_of_Reliability` numeric(5,2) not null,
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_subset_PN_of_ID`,
        `AC_subset_PN_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_subset_PN_of_Annex` FOREIGN KEY (`AC_subset_PN_of_ID`) REFERENCES
        ties.`AC_subset_PN_of_Posit`(`AC_subset_PN_of_ID`) NOT ENFORCED
)
CLUSTER BY `AC_subset_PN_of_ID`, `AC_subset_PN_of_PositedAt`;
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
    `EV_in_AC_rollsattes_Reliability` numeric(5,2) not null,
    `Metadata_EV_in_AC_rollsattes` int64 not null,
    PRIMARY KEY (
        `EV_in_AC_rollsattes_ID`,
        `EV_in_AC_rollsattes_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_in_AC_rollsattes_Annex` FOREIGN KEY (`EV_in_AC_rollsattes_ID`) REFERENCES
        ties.`EV_in_AC_rollsattes_Posit`(`EV_in_AC_rollsattes_ID`) NOT ENFORCED
)
CLUSTER BY `EV_in_AC_rollsattes_ID`, `EV_in_AC_rollsattes_PositedAt`;
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
    `AC_deltar_PR_in_RAT_fick_Reliability` numeric(5,2) not null,
    `Metadata_AC_deltar_PR_in_RAT_fick` int64 not null,
    PRIMARY KEY (
        `AC_deltar_PR_in_RAT_fick_ID`,
        `AC_deltar_PR_in_RAT_fick_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_deltar_PR_in_RAT_fick_Annex` FOREIGN KEY (`AC_deltar_PR_in_RAT_fick_ID`) REFERENCES
        ties.`AC_deltar_PR_in_RAT_fick_Posit`(`AC_deltar_PR_in_RAT_fick_ID`) NOT ENFORCED
)
CLUSTER BY `AC_deltar_PR_in_RAT_fick_ID`, `AC_deltar_PR_in_RAT_fick_PositedAt`;
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
    `ST_at_PR_spelas_Reliability` numeric(5,2) not null,
    `Metadata_ST_at_PR_spelas` int64 not null,
    PRIMARY KEY (
        `ST_at_PR_spelas_ID`,
        `ST_at_PR_spelas_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_at_PR_spelas_Annex` FOREIGN KEY (`ST_at_PR_spelas_ID`) REFERENCES
        ties.`ST_at_PR_spelas_Posit`(`ST_at_PR_spelas_ID`) NOT ENFORCED
)
CLUSTER BY `ST_at_PR_spelas_ID`, `ST_at_PR_spelas_PositedAt`;
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
    `AC_förälder_AC_barn_PAT_har_Reliability` numeric(5,2) not null,
    `Metadata_AC_förälder_AC_barn_PAT_har` int64 not null,
    PRIMARY KEY (
        `AC_förälder_AC_barn_PAT_har_ID`,
        `AC_förälder_AC_barn_PAT_har_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_förälder_AC_barn_PAT_har_Annex` FOREIGN KEY (`AC_förälder_AC_barn_PAT_har_ID`) REFERENCES
        ties.`AC_förälder_AC_barn_PAT_har_Posit`(`AC_förälder_AC_barn_PAT_har_ID`) NOT ENFORCED
)
CLUSTER BY `AC_förälder_AC_barn_PAT_har_ID`, `AC_förälder_AC_barn_PAT_har_PositedAt`;
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
    `PR_innehåll_ST_plats_EV_of_Reliability` numeric(5,2) not null,
    `Metadata_PR_innehåll_ST_plats_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_innehåll_ST_plats_EV_of_ID`,
        `PR_innehåll_ST_plats_EV_of_PositedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_innehåll_ST_plats_EV_of_Annex` FOREIGN KEY (`PR_innehåll_ST_plats_EV_of_ID`) REFERENCES
        ties.`PR_innehåll_ST_plats_EV_of_Posit`(`PR_innehåll_ST_plats_EV_of_ID`) NOT ENFORCED
)
CLUSTER BY `PR_innehåll_ST_plats_EV_of_ID`, `PR_innehåll_ST_plats_EV_of_PositedAt`;
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
    a.`AC_partner_AC_with_ONG_currently_Reliability`
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
    a.`AC_subset_PN_of_Reliability`
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
    a.`EV_in_AC_rollsattes_Reliability`
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
    a.`AC_deltar_PR_in_RAT_fick_Reliability`
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
    a.`ST_at_PR_spelas_Reliability`
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
    a.`AC_förälder_AC_barn_PAT_har_Reliability`
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
    a.`PR_innehåll_ST_plats_EV_of_Reliability`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Posit` p
JOIN
    ties.`PR_innehåll_ST_plats_EV_of_Annex` a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
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
    `AC_partner_AC_with_ONG_currently_Reliability`
FROM
    ties.`AC_partner_AC_with_ONG_currently_Annex`
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
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    ties.`rAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
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
    a.`AC_partner_AC_with_ONG_currently_Reliability`
FROM
    ties.`fAC_partner_AC_with_ONG_currently_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_partner_AC_with_ONG_currently_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_subset_PN_of_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_AC_subset_PN_of`,
    `AC_subset_PN_of_ID`,
    `AC_subset_PN_of_PositedAt`,
    `AC_subset_PN_of_Reliability`
FROM
    ties.`AC_subset_PN_of_Annex`
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
    a.`AC_subset_PN_of_Reliability`
FROM
    ties.`AC_subset_PN_of_Posit` p
JOIN
    ties.`rAC_subset_PN_of_Annex`(positingTimepoint) a
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
    a.`AC_subset_PN_of_Reliability`
FROM
    ties.`AC_subset_PN_of_Posit` p
JOIN
    ties.`rAC_subset_PN_of_Annex`(positingTimepoint) a
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
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_rollsattes_Annex` (
    positingTimepoint datetime
)
AS (
SELECT
    `Metadata_EV_in_AC_rollsattes`,
    `EV_in_AC_rollsattes_ID`,
    `EV_in_AC_rollsattes_PositedAt`,
    `EV_in_AC_rollsattes_Reliability`
FROM
    ties.`EV_in_AC_rollsattes_Annex`
WHERE
    `EV_in_AC_rollsattes_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rEV_in_AC_rollsattes` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_rollsattes`,
    p.`EV_in_AC_rollsattes_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_rollsattes`,
    a.`EV_in_AC_rollsattes_PositedAt`,
    a.`EV_in_AC_rollsattes_Reliability`
FROM
    ties.`EV_in_AC_rollsattes_Posit` p
JOIN
    ties.`rEV_in_AC_rollsattes_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_rollsattes_ID` = p.`EV_in_AC_rollsattes_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_rollsattes_ID`
        ORDER BY a.`EV_in_AC_rollsattes_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fEV_in_AC_rollsattes` (
    positingTimepoint datetime
)
AS (
SELECT
    a.`Metadata_EV_in_AC_rollsattes`,
    p.`EV_in_AC_rollsattes_ID`,
    p.`EV_ID_in`,
    p.`AC_ID_rollsattes`,
    a.`EV_in_AC_rollsattes_PositedAt`,
    a.`EV_in_AC_rollsattes_Reliability`
FROM
    ties.`EV_in_AC_rollsattes_Posit` p
JOIN
    ties.`rEV_in_AC_rollsattes_Annex`(positingTimepoint) a
ON
    a.`EV_in_AC_rollsattes_ID` = p.`EV_in_AC_rollsattes_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`EV_in_AC_rollsattes_ID`
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
    `AC_deltar_PR_in_RAT_fick_Reliability`
FROM
    ties.`AC_deltar_PR_in_RAT_fick_Annex`
WHERE
    `AC_deltar_PR_in_RAT_fick_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_deltar_PR_in_RAT_fick` (
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
    a.`AC_deltar_PR_in_RAT_fick_Reliability`
FROM
    ties.`rAC_deltar_PR_in_RAT_fick_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_deltar_PR_in_RAT_fick_Annex`(positingTimepoint) a
ON
    a.`AC_deltar_PR_in_RAT_fick_ID` = p.`AC_deltar_PR_in_RAT_fick_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_deltar_PR_in_RAT_fick_ID`
        ORDER BY a.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_deltar_PR_in_RAT_fick` (
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
    a.`AC_deltar_PR_in_RAT_fick_Reliability`
FROM
    ties.`fAC_deltar_PR_in_RAT_fick_Posit`(changingTimepoint) p 
JOIN
    ties.`rAC_deltar_PR_in_RAT_fick_Annex`(positingTimepoint) a
ON
    a.`AC_deltar_PR_in_RAT_fick_ID` = p.`AC_deltar_PR_in_RAT_fick_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_deltar_PR_in_RAT_fick_ID`
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
    `ST_at_PR_spelas_Reliability`
FROM
    ties.`ST_at_PR_spelas_Annex`
WHERE
    `ST_at_PR_spelas_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rST_at_PR_spelas` (
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
    a.`ST_at_PR_spelas_Reliability`
FROM
    ties.`rST_at_PR_spelas_Posit`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_spelas_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_spelas_ID` = p.`ST_at_PR_spelas_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_spelas_ID`
        ORDER BY a.`ST_at_PR_spelas_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fST_at_PR_spelas` (
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
    a.`ST_at_PR_spelas_Reliability`
FROM
    ties.`fST_at_PR_spelas_Posit`(changingTimepoint) p 
JOIN
    ties.`rST_at_PR_spelas_Annex`(positingTimepoint) a
ON
    a.`ST_at_PR_spelas_ID` = p.`ST_at_PR_spelas_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`ST_at_PR_spelas_ID`
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
    `AC_förälder_AC_barn_PAT_har_Reliability`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Annex`
WHERE
    `AC_förälder_AC_barn_PAT_har_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rAC_förälder_AC_barn_PAT_har` (
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
    a.`AC_förälder_AC_barn_PAT_har_Reliability`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Posit` p
JOIN
    ties.`rAC_förälder_AC_barn_PAT_har_Annex`(positingTimepoint) a
ON
    a.`AC_förälder_AC_barn_PAT_har_ID` = p.`AC_förälder_AC_barn_PAT_har_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_förälder_AC_barn_PAT_har_ID`
        ORDER BY a.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fAC_förälder_AC_barn_PAT_har` (
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
    a.`AC_förälder_AC_barn_PAT_har_Reliability`
FROM
    ties.`AC_förälder_AC_barn_PAT_har_Posit` p
JOIN
    ties.`rAC_förälder_AC_barn_PAT_har_Annex`(positingTimepoint) a
ON
    a.`AC_förälder_AC_barn_PAT_har_ID` = p.`AC_förälder_AC_barn_PAT_har_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`AC_förälder_AC_barn_PAT_har_ID`
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
    `PR_innehåll_ST_plats_EV_of_Reliability`
FROM
    ties.`PR_innehåll_ST_plats_EV_of_Annex`
WHERE
    `PR_innehåll_ST_plats_EV_of_PositedAt` <= positingTimepoint
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`rPR_innehåll_ST_plats_EV_of` (
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
    a.`PR_innehåll_ST_plats_EV_of_Reliability`
FROM
    ties.`rPR_innehåll_ST_plats_EV_of_Posit`(changingTimepoint) p 
JOIN
    ties.`rPR_innehåll_ST_plats_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_innehåll_ST_plats_EV_of_ID`
        ORDER BY a.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC
    ) = 1
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`fPR_innehåll_ST_plats_EV_of` (
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
    a.`PR_innehåll_ST_plats_EV_of_Reliability`
FROM
    ties.`fPR_innehåll_ST_plats_EV_of_Posit`(changingTimepoint) p 
JOIN
    ties.`rPR_innehåll_ST_plats_EV_of_Annex`(positingTimepoint) a
ON
    a.`PR_innehåll_ST_plats_EV_of_ID` = p.`PR_innehåll_ST_plats_EV_of_ID`
WHERE
    TRUE
QUALIFY
    row_number() OVER (
        PARTITION BY p.`PR_innehåll_ST_plats_EV_of_ID`
        ORDER BY a.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC
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
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    `kONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `kONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    t.`ONG_ID_currently`
FROM
    ties.`rAC_partner_AC_with_ONG_currently`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`ONG_Pågående` `kONG_currently`
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
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Pågående`,
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
    t.`AC_partner_AC_with_ONG_currently_Reliability`,
    t.`AC_ID_partner`,
    t.`AC_ID_with`,
    t.`currently_ONG_Pågående`,
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
    t.`AC_subset_PN_of_Reliability`,
    t.`AC_ID_subset`,
    t.`PN_ID_of`
FROM
    ties.`rAC_subset_PN_of`(
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
    t.`AC_subset_PN_of_Reliability`,
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
CREATE OR REPLACE TABLE FUNCTION ties.`tEV_in_AC_rollsattes` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_rollsattes_ID`,
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`
FROM
    ties.`rEV_in_AC_rollsattes`(
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`EV_in_AC_rollsattes_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`EV_ID_in`,
            t.`AC_ID_rollsattes`
        ORDER BY
            t.`EV_in_AC_rollsattes_PositedAt` DESC,
            t.`EV_in_AC_rollsattes_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lEV_in_AC_rollsattes` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_rollsattes`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_rollsattes` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`EV_in_AC_rollsattes_ID`,
    t.`Metadata_EV_in_AC_rollsattes`,
    t.`EV_in_AC_rollsattes_PositedAt`,
    t.`EV_in_AC_rollsattes_Reliability`,
    t.`EV_ID_in`,
    t.`AC_ID_rollsattes`
FROM
    ties.`tEV_in_AC_rollsattes`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nEV_in_AC_rollsattes` AS
SELECT
    *
FROM
    ties.`tEV_in_AC_rollsattes`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_deltar_PR_in_RAT_fick_ID`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    `kRAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `kRAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    t.`RAT_ID_fick`
FROM
    ties.`rAC_deltar_PR_in_RAT_fick`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`RAT_Betyg` `kRAT_fick`
ON
    `kRAT_fick`.`RAT_ID` = t.`RAT_ID_fick`
WHERE
    t.`AC_deltar_PR_in_RAT_fick_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_deltar`,
            t.`PR_ID_in`
        ORDER BY
            t.`AC_deltar_PR_in_RAT_fick_ChangedAt` DESC,
            t.`AC_deltar_PR_in_RAT_fick_PositedAt` DESC,
            t.`AC_deltar_PR_in_RAT_fick_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_deltar_PR_in_RAT_fick` AS
SELECT
    *
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_deltar_PR_in_RAT_fick_ID`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    t.`fick_RAT_Betyg`,
    t.`fick_Metadata_RAT`,
    t.`RAT_ID_fick`
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_deltar_PR_in_RAT_fick` AS
SELECT
    *
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_deltar_PR_in_RAT_fick` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`AC_deltar_PR_in_RAT_fick_ID`,
    t.`Metadata_AC_deltar_PR_in_RAT_fick`,
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    t.`AC_deltar_PR_in_RAT_fick_PositedAt`,
    t.`AC_deltar_PR_in_RAT_fick_Reliability`,
    t.`AC_ID_deltar`,
    t.`PR_ID_in`,
    t.`fick_RAT_Betyg`,
    t.`fick_Metadata_RAT`,
    t.`RAT_ID_fick`
FROM
    ties.`tAC_deltar_PR_in_RAT_fick`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`AC_deltar_PR_in_RAT_fick_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tST_at_PR_spelas` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_spelas_ID`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`
FROM
    ties.`rST_at_PR_spelas`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`ST_at_PR_spelas_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`ST_ID_at`,
            t.`PR_ID_spelas`
        ORDER BY
            t.`ST_at_PR_spelas_ChangedAt` DESC,
            t.`ST_at_PR_spelas_PositedAt` DESC,
            t.`ST_at_PR_spelas_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lST_at_PR_spelas` AS
SELECT
    *
FROM
    ties.`tST_at_PR_spelas`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_spelas` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`ST_at_PR_spelas_ID`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`
FROM
    ties.`tST_at_PR_spelas`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nST_at_PR_spelas` AS
SELECT
    *
FROM
    ties.`tST_at_PR_spelas`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_spelas` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`ST_at_PR_spelas_ID`,
    t.`Metadata_ST_at_PR_spelas`,
    t.`ST_at_PR_spelas_ChangedAt`,
    t.`ST_at_PR_spelas_PositedAt`,
    t.`ST_at_PR_spelas_Reliability`,
    t.`ST_ID_at`,
    t.`PR_ID_spelas`
FROM
    ties.`tST_at_PR_spelas`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`ST_at_PR_spelas_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
CREATE OR REPLACE TABLE FUNCTION ties.`tAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`AC_förälder_AC_barn_PAT_har_ID`,
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    `kPAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `kPAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    t.`PAT_ID_har`
FROM
    ties.`rAC_förälder_AC_barn_PAT_har`(
        CAST(positingTimepoint AS datetime)
    ) t
LEFT JOIN
    knots.`PAT_Föräldratyp` `kPAT_har`
ON
    `kPAT_har`.`PAT_ID` = t.`PAT_ID_har`
WHERE
    t.`AC_förälder_AC_barn_PAT_har_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- the latest posit for the identifiers
    row_number() OVER (
        PARTITION BY
            t.`AC_ID_förälder`,
            t.`AC_ID_barn`,
            t.`PAT_ID_har`
        ORDER BY
            t.`AC_förälder_AC_barn_PAT_har_PositedAt` DESC,
            t.`AC_förälder_AC_barn_PAT_har_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lAC_förälder_AC_barn_PAT_har` AS
SELECT
    *
FROM
    ties.`tAC_förälder_AC_barn_PAT_har`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`AC_förälder_AC_barn_PAT_har_ID`,
    t.`Metadata_AC_förälder_AC_barn_PAT_har`,
    t.`AC_förälder_AC_barn_PAT_har_PositedAt`,
    t.`AC_förälder_AC_barn_PAT_har_Reliability`,
    t.`AC_ID_förälder`,
    t.`AC_ID_barn`,
    t.`har_PAT_Föräldratyp`,
    t.`har_Metadata_PAT`,
    t.`PAT_ID_har`
FROM
    ties.`tAC_förälder_AC_barn_PAT_har`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nAC_förälder_AC_barn_PAT_har` AS
SELECT
    *
FROM
    ties.`tAC_förälder_AC_barn_PAT_har`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`tPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime,
    positingTimepoint datetime
)
AS (
SELECT
    t.`PR_innehåll_ST_plats_EV_of_ID`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`
FROM
    ties.`rPR_innehåll_ST_plats_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST(positingTimepoint AS datetime)
    ) t
WHERE
    t.`PR_innehåll_ST_plats_EV_of_Reliability` = 1
QUALIFY -- picked by a window: a database may not evaluate a subquery that refers to the outer row and takes the first row
        -- of an ordering
    -- a tie without identifiers is one to one: the latest posit for each of its anchors
    row_number() OVER (
        PARTITION BY t.`PR_ID_innehåll`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
AND
    row_number() OVER (
        PARTITION BY t.`ST_ID_plats`
        ORDER BY
            t.`PR_innehåll_ST_plats_EV_of_ChangedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_PositedAt` DESC,
            t.`PR_innehåll_ST_plats_EV_of_ID` DESC
    ) = 1
)
;
CREATE OR REPLACE VIEW ties.`lPR_innehåll_ST_plats_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    t.`PR_innehåll_ST_plats_EV_of_ID`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST(changingTimepoint AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
)
;
CREATE OR REPLACE VIEW ties.`nPR_innehåll_ST_plats_EV_of` AS
SELECT
    *
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST(current_datetime() AS datetime),
        CAST('9999-12-31' AS datetime)
    )
;
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_innehåll_ST_plats_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    t.`PR_innehåll_ST_plats_EV_of_ID`,
    t.`Metadata_PR_innehåll_ST_plats_EV_of`,
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    t.`PR_innehåll_ST_plats_EV_of_PositedAt`,
    t.`PR_innehåll_ST_plats_EV_of_Reliability`,
    t.`PR_ID_innehåll`,
    t.`ST_ID_plats`,
    t.`EV_ID_of`
FROM
    ties.`tPR_innehåll_ST_plats_EV_of`(
        CAST('9999-12-31' AS datetime),
        CAST('9999-12-31' AS datetime)
    ) t
WHERE
    t.`PR_innehåll_ST_plats_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
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
