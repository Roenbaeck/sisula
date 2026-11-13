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
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_DAT_Händelse_Datum` (
    `EV_DAT_EV_ID` numeric(12,0) not null,
    `EV_DAT_Händelse_Datum` datetime not null,
    `Metadata_EV_DAT` int64 not null,
    PRIMARY KEY (
        `EV_DAT_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_DAT_Händelse_Datum` FOREIGN KEY (`EV_DAT_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_DAT_EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_AUD_Händelse_Publik` (
    `EV_AUD_EV_ID` numeric(12,0) not null,
    `EV_AUD_Händelse_Publik` int64 not null,
    `Metadata_EV_AUD` int64 not null,
    PRIMARY KEY (
        `EV_AUD_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_AUD_Händelse_Publik` FOREIGN KEY (`EV_AUD_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_AUD_EV_ID`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_REV_Händelse_Intäkt` (
    `EV_REV_EV_ID` numeric(12,0) not null,
    `EV_REV_Händelse_Intäkt` numeric(19,4) not null,
    `Metadata_EV_REV` int64 not null,
    PRIMARY KEY (
        `EV_REV_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_REV_Händelse_Intäkt` FOREIGN KEY (`EV_REV_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_REV_EV_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_STA_Händelse_Status` (
    `EV_STA_EV_ID` numeric(12,0) not null,
    `EV_STA_Händelse_Status` string(20) not null,
    `EV_STA_ChangedAt` datetime not null,
    `Metadata_EV_STA` int64 not null,
    PRIMARY KEY (
        `EV_STA_EV_ID`,
        `EV_STA_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkEV_STA_Händelse_Status` FOREIGN KEY (`EV_STA_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_STA_EV_ID`, `EV_STA_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_UTL_Händelse_Utnyttjande` (
    `EV_UTL_EV_ID` numeric(12,0) not null,
    `EV_UTL_UTL_ID` int64 not null,
    `Metadata_EV_UTL` int64 not null,
    PRIMARY KEY (
        `EV_UTL_EV_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_UTL_Händelse_Utnyttjande` FOREIGN KEY (`EV_UTL_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_UTL_Händelse_Utnyttjande` FOREIGN KEY (`EV_UTL_UTL_ID`) REFERENCES
        knots.`UTL_Utnyttjande`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `EV_UTL_EV_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`EV_LVL_Händelse_Level` (
    `EV_LVL_EV_ID` numeric(12,0) not null,
    `EV_LVL_PLV_ID` int64 not null,
    `EV_LVL_ChangedAt` date not null,
    `Metadata_EV_LVL` int64 not null,
    PRIMARY KEY (
        `EV_LVL_EV_ID`,
        `EV_LVL_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_EV_LVL_Händelse_Level` FOREIGN KEY (`EV_LVL_EV_ID`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_EV_LVL_Händelse_Level` FOREIGN KEY (`EV_LVL_PLV_ID`) REFERENCES
        knots.`PLV_Yrkesnivå`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `EV_LVL_EV_ID`, `EV_LVL_ChangedAt`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_NAM_Scen_Namn` (
    `ST_NAM_ST_ID` int64 not null,
    `ST_NAM_Scen_Namn` string(42) not null,
    `ST_NAM_ChangedAt` datetime not null,
    `Metadata_ST_NAM` int64 not null,
    PRIMARY KEY (
        `ST_NAM_ST_ID`,
        `ST_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_NAM_Scen_Namn` FOREIGN KEY (`ST_NAM_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_NAM_ST_ID`, `ST_NAM_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
-- the checksum is FARM_FINGERPRINT of the value, which the load fills in: a column cannot be computed from another
CREATE TABLE IF NOT EXISTS attributes.`ST_LOC_Scen_Plats` (
    `ST_LOC_ST_ID` int64 not null,
    `ST_LOC_Scen_Plats` geography not null,
    `ST_LOC_Checksum` int64,
    `Metadata_ST_LOC` int64 not null,
    PRIMARY KEY (
        `ST_LOC_ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkST_LOC_Scen_Plats` FOREIGN KEY (`ST_LOC_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
)
CLUSTER BY `ST_LOC_ST_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_AVG_Scen_Medel` (
    `ST_AVG_ST_ID` int64 not null,
    `ST_AVG_UTL_ID` int64 not null,
    `ST_AVG_ChangedAt` datetime not null,
    `Metadata_ST_AVG` int64 not null,
    PRIMARY KEY (
        `ST_AVG_ST_ID`,
        `ST_AVG_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_AVG_Scen_Medel` FOREIGN KEY (`ST_AVG_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_AVG_Scen_Medel` FOREIGN KEY (`ST_AVG_UTL_ID`) REFERENCES
        knots.`UTL_Utnyttjande`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_AVG_ST_ID`, `ST_AVG_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`ST_MIN_Scen_Minimum` (
    `ST_MIN_ST_ID` int64 not null,
    `ST_MIN_UTL_ID` int64 not null,
    `Metadata_ST_MIN` int64 not null,
    PRIMARY KEY (
        `ST_MIN_ST_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_ST_MIN_Scen_Minimum` FOREIGN KEY (`ST_MIN_ST_ID`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_ST_MIN_Scen_Minimum` FOREIGN KEY (`ST_MIN_UTL_ID`) REFERENCES
        knots.`UTL_Utnyttjande`(`UTL_ID`) NOT ENFORCED
)
CLUSTER BY `ST_MIN_ST_ID`;
-- AC_NAM_Skådespelare_Namn is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_NAM_Skådespelare_Namn` (
    `AC_NAM_AC_ID` int64 not null,
    `AC_NAM_Skådespelare_Namn` string(42) not null,
    `AC_NAM_ChangedAt` datetime not null,
    `Metadata_AC_NAM` int64 not null,
    PRIMARY KEY (
        `AC_NAM_AC_ID`,
        `AC_NAM_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkAC_NAM_Skådespelare_Namn` FOREIGN KEY (`AC_NAM_AC_ID`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY `AC_NAM_AC_ID`, `AC_NAM_ChangedAt`;
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_GEN_Skådespelare_Kön` (
    `AC_GEN_AC_ID` int64 not null,
    `AC_GEN_GEN_ID` int64 not null,
    `Metadata_AC_GEN` int64 not null,
    PRIMARY KEY (
        `AC_GEN_AC_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_GEN_Skådespelare_Kön` FOREIGN KEY (`AC_GEN_AC_ID`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_GEN_Skådespelare_Kön` FOREIGN KEY (`AC_GEN_GEN_ID`) REFERENCES
        knots.`GEN_Kön`(`GEN_ID`) NOT ENFORCED
)
CLUSTER BY `AC_GEN_AC_ID`;
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`AC_PLV_Skådespelare_Yrkesnivå` (
    `AC_PLV_AC_ID` int64 not null,
    `AC_PLV_PLV_ID` int64 not null,
    `AC_PLV_ChangedAt` datetime not null,
    `Metadata_AC_PLV` int64 not null,
    PRIMARY KEY (
        `AC_PLV_AC_ID`,
        `AC_PLV_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fk_A_AC_PLV_Skådespelare_Yrkesnivå` FOREIGN KEY (`AC_PLV_AC_ID`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED,
    CONSTRAINT `fk_K_AC_PLV_Skådespelare_Yrkesnivå` FOREIGN KEY (`AC_PLV_PLV_ID`) REFERENCES
        knots.`PLV_Yrkesnivå`(`PLV_ID`) NOT ENFORCED
)
CLUSTER BY `AC_PLV_AC_ID`, `AC_PLV_ChangedAt`;
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_NAM_Föreställning_Namn` (
    `PR_NAM_PR_ID` int64 not null,
    `PR_NAM_Föreställning_Namn` string(42) not null,
    `Metadata_PR_NAM` int64 not null,
    PRIMARY KEY (
        `PR_NAM_PR_ID`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_NAM_Föreställning_Namn` FOREIGN KEY (`PR_NAM_PR_ID`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY `PR_NAM_PR_ID`;
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes.`PR_LEN_Föreställning_Längd` (
    `PR_LEN_PR_ID` int64 not null,
    `PR_LEN_Föreställning_Längd` time not null,
    `PR_LEN_ChangedAt` date not null,
    `Metadata_PR_LEN` int64 not null,
    PRIMARY KEY (
        `PR_LEN_PR_ID`,
        `PR_LEN_ChangedAt`
    ) NOT ENFORCED,
    CONSTRAINT `fkPR_LEN_Föreställning_Längd` FOREIGN KEY (`PR_LEN_PR_ID`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
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
CREATE TABLE IF NOT EXISTS ties.`AC_partner_AC_with_ONG_currently` (
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
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkAC_with` FOREIGN KEY (`AC_ID_with`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_partner_AC_with_ONG_currently_fkONG_currently` FOREIGN KEY (`ONG_ID_currently`) REFERENCES
        knots.`ONG_Pågående`(`ONG_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_partner`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- AC_subset_PN_of table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_subset_PN_of` (
    `AC_ID_subset` int64 not null, 
    `PN_ID_of` int64 not null, 
    `Metadata_AC_subset_PN_of` int64 not null,
    PRIMARY KEY (
        `AC_ID_subset`,
        `PN_ID_of`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkAC_subset` FOREIGN KEY (`AC_ID_subset`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_subset_PN_of_fkPN_of` FOREIGN KEY (`PN_ID_of`) REFERENCES
        anchors.`PN_Person`(`PN_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_subset`
;
-- Static tie table ---------------------------------------------------------------------------------------------------
-- EV_in_AC_rollsattes table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`EV_in_AC_rollsattes` (
    `EV_ID_in` numeric(12,0) not null, 
    `AC_ID_rollsattes` int64 not null, 
    `Metadata_EV_in_AC_rollsattes` int64 not null,
    PRIMARY KEY (
        `EV_ID_in`,
        `AC_ID_rollsattes`
    ) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_fkEV_in` FOREIGN KEY (`EV_ID_in`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
    ,CONSTRAINT `EV_in_AC_rollsattes_fkAC_rollsattes` FOREIGN KEY (`AC_ID_rollsattes`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
)
CLUSTER BY
    `EV_ID_in`
;
-- Knotted historized tie table ---------------------------------------------------------------------------------------
-- AC_deltar_PR_in_RAT_fick table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_deltar_PR_in_RAT_fick` (
    `AC_ID_deltar` int64 not null, 
    `PR_ID_in` int64 not null, 
    `RAT_ID_fick` int64 not null,
    `AC_deltar_PR_in_RAT_fick_ChangedAt` datetime not null,
    `Metadata_AC_deltar_PR_in_RAT_fick` int64 not null,
    PRIMARY KEY (
        `AC_ID_deltar`,
        `PR_ID_in`,
        `AC_deltar_PR_in_RAT_fick_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_fkAC_deltar` FOREIGN KEY (`AC_ID_deltar`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_fkPR_in` FOREIGN KEY (`PR_ID_in`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_deltar_PR_in_RAT_fick_fkRAT_fick` FOREIGN KEY (`RAT_ID_fick`) REFERENCES
        knots.`RAT_Betyg`(`RAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_deltar`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- ST_at_PR_spelas table (having 2 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`ST_at_PR_spelas` (
    `ST_ID_at` int64 not null, 
    `PR_ID_spelas` int64 not null, 
    `ST_at_PR_spelas_ChangedAt` datetime not null,
    `Metadata_ST_at_PR_spelas` int64 not null,
    PRIMARY KEY (
        `ST_ID_at`,
        `PR_ID_spelas`,
        `ST_at_PR_spelas_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_fkST_at` FOREIGN KEY (`ST_ID_at`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `ST_at_PR_spelas_fkPR_spelas` FOREIGN KEY (`PR_ID_spelas`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
)
CLUSTER BY
    `ST_ID_at`
;
-- Knotted static tie table -------------------------------------------------------------------------------------------
-- AC_förälder_AC_barn_PAT_har table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`AC_förälder_AC_barn_PAT_har` (
    `AC_ID_förälder` int64 not null, 
    `AC_ID_barn` int64 not null, 
    `PAT_ID_har` int64 not null,
    `Metadata_AC_förälder_AC_barn_PAT_har` int64 not null,
    PRIMARY KEY (
        `AC_ID_förälder`,
        `AC_ID_barn`,
        `PAT_ID_har`
    ) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_fkAC_förälder` FOREIGN KEY (`AC_ID_förälder`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_fkAC_barn` FOREIGN KEY (`AC_ID_barn`) REFERENCES
        anchors.`AC_Skådespelare`(`AC_ID`) NOT ENFORCED
    ,CONSTRAINT `AC_förälder_AC_barn_PAT_har_fkPAT_har` FOREIGN KEY (`PAT_ID_har`) REFERENCES
        knots.`PAT_Föräldratyp`(`PAT_ID`) NOT ENFORCED
)
CLUSTER BY
    `AC_ID_förälder`
;
-- Historized tie table -----------------------------------------------------------------------------------------------
-- PR_innehåll_ST_plats_EV_of table (having 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ties.`PR_innehåll_ST_plats_EV_of` (
    `PR_ID_innehåll` int64 not null, 
    `ST_ID_plats` int64 not null, 
    `EV_ID_of` numeric(12,0) not null, 
    `PR_innehåll_ST_plats_EV_of_ChangedAt` datetime not null,
    `Metadata_PR_innehåll_ST_plats_EV_of` int64 not null,
    PRIMARY KEY (
        `PR_ID_innehåll`,
        `ST_ID_plats`,
        `EV_ID_of`,
        `PR_innehåll_ST_plats_EV_of_ChangedAt`
    ) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_fkPR_innehåll` FOREIGN KEY (`PR_ID_innehåll`) REFERENCES
        anchors.`PR_Föreställning`(`PR_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_fkST_plats` FOREIGN KEY (`ST_ID_plats`) REFERENCES
        anchors.`ST_Scen`(`ST_ID`) NOT ENFORCED
    ,CONSTRAINT `PR_innehåll_ST_plats_EV_of_fkEV_of` FOREIGN KEY (`EV_ID_of`) REFERENCES
        nexuses.`EV_Händelse`(`EV_ID`) NOT ENFORCED
)
CLUSTER BY
    `PR_ID_innehåll`
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
-- rEV_STA_Händelse_Status rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_STA_Händelse_Status` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_EV_STA`,
        `EV_STA_EV_ID`,
        `EV_STA_Händelse_Status`,
        `EV_STA_ChangedAt`
    FROM
        attributes.`EV_STA_Händelse_Status`
    WHERE
        `EV_STA_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rEV_LVL_Händelse_Level rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rEV_LVL_Händelse_Level` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_EV_LVL`,
        `EV_LVL_EV_ID`,
        `EV_LVL_PLV_ID`,
        `EV_LVL_ChangedAt`
    FROM
        attributes.`EV_LVL_Händelse_Level`
    WHERE
        `EV_LVL_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_NAM_Scen_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_NAM_Scen_Namn` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_NAM`,
        `ST_NAM_ST_ID`,
        `ST_NAM_Scen_Namn`,
        `ST_NAM_ChangedAt`
    FROM
        attributes.`ST_NAM_Scen_Namn`
    WHERE
        `ST_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rST_AVG_Scen_Medel rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rST_AVG_Scen_Medel` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_ST_AVG`,
        `ST_AVG_ST_ID`,
        `ST_AVG_UTL_ID`,
        `ST_AVG_ChangedAt`
    FROM
        attributes.`ST_AVG_Scen_Medel`
    WHERE
        `ST_AVG_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_NAM_Skådespelare_Namn rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_NAM_Skådespelare_Namn` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_NAM`,
        `AC_NAM_AC_ID`,
        `AC_NAM_Skådespelare_Namn`,
        `AC_NAM_ChangedAt`
    FROM
        attributes.`AC_NAM_Skådespelare_Namn`
    WHERE
        `AC_NAM_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rAC_PLV_Skådespelare_Yrkesnivå rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rAC_PLV_Skådespelare_Yrkesnivå` (
    changingTimepoint datetime
)
AS (
    SELECT
        `Metadata_AC_PLV`,
        `AC_PLV_AC_ID`,
        `AC_PLV_PLV_ID`,
        `AC_PLV_ChangedAt`
    FROM
        attributes.`AC_PLV_Skådespelare_Yrkesnivå`
    WHERE
        `AC_PLV_ChangedAt` <= changingTimepoint
)
;
-- Attribute rewinder -------------------------------------------------------------------------------------------------
-- rPR_LEN_Föreställning_Längd rewinding over changing time function
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION attributes.`rPR_LEN_Föreställning_Längd` (
    changingTimepoint date
)
AS (
    SELECT
        `Metadata_PR_LEN`,
        `PR_LEN_PR_ID`,
        `PR_LEN_Föreställning_Längd`,
        `PR_LEN_ChangedAt`
    FROM
        attributes.`PR_LEN_Föreställning_Längd`
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
CREATE OR REPLACE VIEW anchors.`lST_Scen` (
    `ST_ID`,
    `Metadata_ST`,
    `ST_NAM_ST_ID`,
    `Metadata_ST_NAM`,
    `ST_NAM_ChangedAt`,
    `ST_NAM_Scen_Namn` OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.'),
    `ST_LOC_ST_ID`,
    `Metadata_ST_LOC`,
    `ST_LOC_Checksum`,
    `ST_LOC_Scen_Plats` OPTIONS(description='Geographic location of the stage as a geography point.'),
    `ST_AVG_ST_ID`,
    `Metadata_ST_AVG`,
    `ST_AVG_ChangedAt`,
    `ST_AVG_UTL_Utnyttjande` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `ST_AVG_Metadata_UTL`,
    `ST_AVG_UTL_ID` OPTIONS(description='Average utilization of the stage capacity, recalculated over time.'),
    `ST_MIN_ST_ID`,
    `Metadata_ST_MIN`,
    `ST_MIN_UTL_Utnyttjande` OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.'),
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
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Scen` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`ST_NAM_Scen_Namn` t
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
    attributes.`ST_LOC_Scen_Plats` `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`ST_AVG_Scen_Medel` t
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
    knots.`UTL_Utnyttjande` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN
    attributes.`ST_MIN_Scen_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pST_Scen` (
    changingTimepoint datetime
)
AS (
SELECT
    `ST`.`ST_ID`,
    `ST`.`Metadata_ST`,
    `NAM`.`ST_NAM_ST_ID`,
    `NAM`.`Metadata_ST_NAM`,
    `NAM`.`ST_NAM_ChangedAt`,
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM
    anchors.`ST_Scen` `ST`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rST_NAM_Scen_Namn`(CAST(changingTimepoint AS datetime)) r
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
    attributes.`ST_LOC_Scen_Plats` `LOC`
ON
    `LOC`.`ST_LOC_ST_ID` = `ST`.`ST_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rST_AVG_Scen_Medel`(CAST(changingTimepoint AS datetime)) r
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
    knots.`UTL_Utnyttjande` `kAVG`
ON
    `kAVG`.`UTL_ID` = `AVG`.`ST_AVG_UTL_ID`
LEFT JOIN
    attributes.`ST_MIN_Scen_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nST_Scen`
AS
SELECT
    *
FROM
    anchors.`pST_Scen`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dST_Scen` (
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
    `NAM`.`ST_NAM_Scen_Namn`,
    `LOC`.`ST_LOC_ST_ID`,
    `LOC`.`Metadata_ST_LOC`,
    `LOC`.`ST_LOC_Checksum`,
    `LOC`.`ST_LOC_Scen_Plats`,
    `AVG`.`ST_AVG_ST_ID`,
    `AVG`.`Metadata_ST_AVG`,
    `AVG`.`ST_AVG_ChangedAt`,
    `kAVG`.`UTL_Utnyttjande` AS `ST_AVG_UTL_Utnyttjande`,
    `kAVG`.`Metadata_UTL` AS `ST_AVG_Metadata_UTL`,
    `AVG`.`ST_AVG_UTL_ID`,
    `MIN`.`ST_MIN_ST_ID`,
    `MIN`.`Metadata_ST_MIN`,
    `kMIN`.`UTL_Utnyttjande` AS `ST_MIN_UTL_Utnyttjande`,
    `kMIN`.`Metadata_UTL` AS `ST_MIN_Metadata_UTL`,
    `MIN`.`ST_MIN_UTL_ID`
FROM (
    SELECT DISTINCT
        h.`ST_NAM_ST_ID` AS `ST_ID`,
        CAST(h.`ST_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`ST_NAM_Scen_Namn` h
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
        attributes.`ST_AVG_Scen_Medel` h
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        h.`ST_AVG_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`ST_Scen` `ST`
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
        attributes.`ST_NAM_Scen_Namn` h
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
    attributes.`ST_LOC_Scen_Plats` `LOC`
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
        attributes.`ST_AVG_Scen_Medel` h
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
LEFT JOIN
    attributes.`ST_MIN_Scen_Minimum` `MIN`
ON
    `MIN`.`ST_MIN_ST_ID` = `ST`.`ST_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kMIN`
ON
    `kMIN`.`UTL_ID` = `MIN`.`ST_MIN_UTL_ID`
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`lAC_Skådespelare` (
    `AC_ID`,
    `Metadata_AC`,
    `AC_NAM_AC_ID`,
    `Metadata_AC_NAM`,
    `AC_NAM_ChangedAt`,
    `AC_NAM_Skådespelare_Namn` OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.'),
    `AC_GEN_AC_ID`,
    `Metadata_AC_GEN`,
    `AC_GEN_GEN_Checksum`,
    `AC_GEN_GEN_Kön` OPTIONS(description='Gender of the actor.'),
    `AC_GEN_Metadata_GEN`,
    `AC_GEN_GEN_ID` OPTIONS(description='Gender of the actor.'),
    `AC_PLV_AC_ID`,
    `Metadata_AC_PLV`,
    `AC_PLV_ChangedAt`,
    `AC_PLV_PLV_Checksum`,
    `AC_PLV_PLV_Yrkesnivå` OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.'),
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
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Skådespelare` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`AC_NAM_Skådespelare_Namn` t
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
    attributes.`AC_GEN_Skådespelare_Kön` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Kön` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`AC_PLV_Skådespelare_Yrkesnivå` t
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
    knots.`PLV_Yrkesnivå` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`pAC_Skådespelare` (
    changingTimepoint datetime
)
AS (
SELECT
    `AC`.`AC_ID`,
    `AC`.`Metadata_AC`,
    `NAM`.`AC_NAM_AC_ID`,
    `NAM`.`Metadata_AC_NAM`,
    `NAM`.`AC_NAM_ChangedAt`,
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM
    anchors.`AC_Skådespelare` `AC`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rAC_NAM_Skådespelare_Namn`(CAST(changingTimepoint AS datetime)) r
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
    attributes.`AC_GEN_Skådespelare_Kön` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Kön` `kGEN`
ON
    `kGEN`.`GEN_ID` = `GEN`.`AC_GEN_GEN_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rAC_PLV_Skådespelare_Yrkesnivå`(CAST(changingTimepoint AS datetime)) r
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
    knots.`PLV_Yrkesnivå` `kPLV`
ON
    `kPLV`.`PLV_ID` = `PLV`.`AC_PLV_PLV_ID`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`nAC_Skådespelare`
AS
SELECT
    *
FROM
    anchors.`pAC_Skådespelare`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dAC_Skådespelare` (
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
    `NAM`.`AC_NAM_Skådespelare_Namn`,
    `GEN`.`AC_GEN_AC_ID`,
    `GEN`.`Metadata_AC_GEN`,
    `kGEN`.`GEN_Checksum` AS `AC_GEN_GEN_Checksum`,
    `kGEN`.`GEN_Kön` AS `AC_GEN_GEN_Kön`,
    `kGEN`.`Metadata_GEN` AS `AC_GEN_Metadata_GEN`,
    `GEN`.`AC_GEN_GEN_ID`,
    `PLV`.`AC_PLV_AC_ID`,
    `PLV`.`Metadata_AC_PLV`,
    `PLV`.`AC_PLV_ChangedAt`,
    `kPLV`.`PLV_Checksum` AS `AC_PLV_PLV_Checksum`,
    `kPLV`.`PLV_Yrkesnivå` AS `AC_PLV_PLV_Yrkesnivå`,
    `kPLV`.`Metadata_PLV` AS `AC_PLV_Metadata_PLV`,
    `PLV`.`AC_PLV_PLV_ID`
FROM (
    SELECT DISTINCT
        h.`AC_NAM_AC_ID` AS `AC_ID`,
        CAST(h.`AC_NAM_ChangedAt` AS datetime) AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes.`AC_NAM_Skådespelare_Namn` h
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
        attributes.`AC_PLV_Skådespelare_Yrkesnivå` h
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        h.`AC_PLV_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`AC_Skådespelare` `AC`
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
        attributes.`AC_NAM_Skådespelare_Namn` h
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
    attributes.`AC_GEN_Skådespelare_Kön` `GEN`
ON
    `GEN`.`AC_GEN_AC_ID` = `AC`.`AC_ID`
LEFT JOIN
    knots.`GEN_Kön` `kGEN`
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
        attributes.`AC_PLV_Skådespelare_Yrkesnivå` h
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
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors.`lPR_Föreställning` (
    `PR_ID`,
    `Metadata_PR`,
    `PR_NAM_PR_ID`,
    `Metadata_PR_NAM`,
    `PR_NAM_Föreställning_Namn` OPTIONS(description='Name or title of the program.'),
    `PR_LEN_PR_ID`,
    `Metadata_PR_LEN`,
    `PR_LEN_ChangedAt`,
    `PR_LEN_Föreställning_Längd` OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.')
)
AS
SELECT
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM
    anchors.`PR_Föreställning` `PR`
LEFT JOIN
    attributes.`PR_NAM_Föreställning_Namn` `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`PR_LEN_Föreställning_Längd` t
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
CREATE OR REPLACE TABLE FUNCTION anchors.`pPR_Föreställning` (
    changingTimepoint datetime
)
AS (
SELECT
    `PR`.`PR_ID`,
    `PR`.`Metadata_PR`,
    `NAM`.`PR_NAM_PR_ID`,
    `NAM`.`Metadata_PR_NAM`,
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM
    anchors.`PR_Föreställning` `PR`
LEFT JOIN
    attributes.`PR_NAM_Föreställning_Namn` `NAM`
ON
    `NAM`.`PR_NAM_PR_ID` = `PR`.`PR_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rPR_LEN_Föreställning_Längd`(CAST(changingTimepoint AS date)) r
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
CREATE OR REPLACE VIEW anchors.`nPR_Föreställning`
AS
SELECT
    *
FROM
    anchors.`pPR_Föreställning`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION anchors.`dPR_Föreställning` (
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
    `NAM`.`PR_NAM_Föreställning_Namn`,
    `LEN`.`PR_LEN_PR_ID`,
    `LEN`.`Metadata_PR_LEN`,
    `LEN`.`PR_LEN_ChangedAt`,
    `LEN`.`PR_LEN_Föreställning_Längd`
FROM (
    SELECT DISTINCT
        h.`PR_LEN_PR_ID` AS `PR_ID`,
        CAST(h.`PR_LEN_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes.`PR_LEN_Föreställning_Längd` h
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        h.`PR_LEN_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors.`PR_Föreställning` `PR`
ON
    `PR`.`PR_ID` = timepoints.`PR_ID`
LEFT JOIN
    attributes.`PR_NAM_Föreställning_Namn` `NAM`
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
        attributes.`PR_LEN_Föreställning_Längd` h
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
CREATE OR REPLACE VIEW nexuses.`lEV_Händelse` (
    `EV_ID`,
    `Metadata_EV`,
    `ST_ID_hölls` OPTIONS(description='The stage at which the event was held.'),
    `PR_ID_spelades` OPTIONS(description='The program that was played at the event.'),
    `of_ETY_Checksum`,
    `of_ETY_Händelsetyp`,
    `of_Metadata_ETY`,
    `ETY_ID_of`,
    `EV_DAT_EV_ID`,
    `Metadata_EV_DAT`,
    `EV_DAT_Händelse_Datum` OPTIONS(description='Date and time when the event took place.'),
    `EV_AUD_EV_ID`,
    `Metadata_EV_AUD`,
    `EV_AUD_Händelse_Publik` OPTIONS(description='Number of people in the audience at the event.'),
    `EV_REV_EV_ID`,
    `Metadata_EV_REV`,
    `EV_REV_Händelse_Intäkt` OPTIONS(description='Revenue from ticket sales for the event.'),
    `EV_STA_EV_ID`,
    `Metadata_EV_STA`,
    `EV_STA_ChangedAt`,
    `EV_STA_Händelse_Status` OPTIONS(description='Status of the event, which may change until it has taken place.'),
    `EV_UTL_EV_ID`,
    `Metadata_EV_UTL`,
    `EV_UTL_UTL_Utnyttjande`,
    `EV_UTL_Metadata_UTL`,
    `EV_UTL_UTL_ID`,
    `EV_LVL_EV_ID`,
    `Metadata_EV_LVL`,
    `EV_LVL_ChangedAt`,
    `EV_LVL_PLV_Checksum`,
    `EV_LVL_PLV_Yrkesnivå` OPTIONS(description='Professional level required for the event, over time.'),
    `EV_LVL_Metadata_PLV`,
    `EV_LVL_PLV_ID` OPTIONS(description='Professional level required for the event, over time.')
)
OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.')
AS
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Händelse` `EV`
LEFT JOIN
    knots.`ETY_Händelsetyp` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Händelse_Datum` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Händelse_Publik` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Händelse_Intäkt` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`EV_STA_Händelse_Status` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`EV_STA_EV_ID`
            ORDER BY t.`EV_STA_ChangedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_UTL_Händelse_Utnyttjande` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        t.*
    FROM
        attributes.`EV_LVL_Händelse_Level` t
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY t.`EV_LVL_EV_ID`
            ORDER BY t.`EV_LVL_ChangedAt` DESC
        ) = 1
) `LVL`
ON
    `LVL`.`EV_LVL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`PLV_Yrkesnivå` `kLVL`
ON
    `kLVL`.`PLV_ID` = `LVL`.`EV_LVL_PLV_ID`;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`pEV_Händelse` (
    changingTimepoint datetime
)
AS (
SELECT
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM
    nexuses.`EV_Händelse` `EV`
LEFT JOIN
    knots.`ETY_Händelsetyp` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Händelse_Datum` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Händelse_Publik` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Händelse_Intäkt` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rEV_STA_Händelse_Status`(CAST(changingTimepoint AS datetime)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`EV_STA_EV_ID`
            ORDER BY r.`EV_STA_ChangedAt` DESC
        ) = 1
) `STA`
ON
    `STA`.`EV_STA_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_UTL_Händelse_Utnyttjande` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    -- the latest row of each owner
    SELECT
        r.*
    FROM
        attributes.`rEV_LVL_Händelse_Level`(CAST(changingTimepoint AS date)) r
    WHERE
        TRUE
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY r.`EV_LVL_EV_ID`
            ORDER BY r.`EV_LVL_ChangedAt` DESC
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
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses.`nEV_Händelse` AS
SELECT
    *
FROM
    nexuses.`pEV_Händelse`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION nexuses.`dEV_Händelse` (
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
    `EV`.`EV_ID`,
    `EV`.`Metadata_EV`,
    `EV`.`ST_ID_hölls`,
    `EV`.`PR_ID_spelades`,
    `ETY_of`.`ETY_Checksum` AS `of_ETY_Checksum`,
    `ETY_of`.`ETY_Händelsetyp` AS `of_ETY_Händelsetyp`,
    `ETY_of`.`Metadata_ETY` AS `of_Metadata_ETY`,
    `EV`.`ETY_ID_of`,
    `DAT`.`EV_DAT_EV_ID`,
    `DAT`.`Metadata_EV_DAT`,
    `DAT`.`EV_DAT_Händelse_Datum`,
    `AUD`.`EV_AUD_EV_ID`,
    `AUD`.`Metadata_EV_AUD`,
    `AUD`.`EV_AUD_Händelse_Publik`,
    `REV`.`EV_REV_EV_ID`,
    `REV`.`Metadata_EV_REV`,
    `REV`.`EV_REV_Händelse_Intäkt`,
    `STA`.`EV_STA_EV_ID`,
    `STA`.`Metadata_EV_STA`,
    `STA`.`EV_STA_ChangedAt`,
    `STA`.`EV_STA_Händelse_Status`,
    `UTL`.`EV_UTL_EV_ID`,
    `UTL`.`Metadata_EV_UTL`,
    `kUTL`.`UTL_Utnyttjande` AS `EV_UTL_UTL_Utnyttjande`,
    `kUTL`.`Metadata_UTL` AS `EV_UTL_Metadata_UTL`,
    `UTL`.`EV_UTL_UTL_ID`,
    `LVL`.`EV_LVL_EV_ID`,
    `LVL`.`Metadata_EV_LVL`,
    `LVL`.`EV_LVL_ChangedAt`,
    `kLVL`.`PLV_Checksum` AS `EV_LVL_PLV_Checksum`,
    `kLVL`.`PLV_Yrkesnivå` AS `EV_LVL_PLV_Yrkesnivå`,
    `kLVL`.`Metadata_PLV` AS `EV_LVL_Metadata_PLV`,
    `LVL`.`EV_LVL_PLV_ID`
FROM (
    SELECT DISTINCT
        h.`EV_STA_EV_ID` AS `EV_ID`,
        CAST(h.`EV_STA_ChangedAt` AS datetime) AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes.`EV_STA_Händelse_Status` h
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        h.`EV_STA_ChangedAt` BETWEEN intervalStart AND intervalEnd
    UNION DISTINCT
    SELECT DISTINCT
        h.`EV_LVL_EV_ID` AS `EV_ID`,
        CAST(h.`EV_LVL_ChangedAt` AS datetime) AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes.`EV_LVL_Händelse_Level` h
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        h.`EV_LVL_ChangedAt` BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses.`EV_Händelse` `EV`
ON
    `EV`.`EV_ID` = timepoints.`EV_ID`
LEFT JOIN
    knots.`ETY_Händelsetyp` `ETY_of`
ON
    `ETY_of`.`ETY_ID` = `EV`.`ETY_ID_of`
LEFT JOIN
    attributes.`EV_DAT_Händelse_Datum` `DAT`
ON
    `DAT`.`EV_DAT_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_AUD_Händelse_Publik` `AUD`
ON
    `AUD`.`EV_AUD_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    attributes.`EV_REV_Händelse_Intäkt` `REV`
ON
    `REV`.`EV_REV_EV_ID` = `EV`.`EV_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`EV_STA_ChangedAt`) OVER (
            PARTITION BY h.`EV_STA_EV_ID`
            ORDER BY h.`EV_STA_ChangedAt`
        ) AS `until`
    FROM
        attributes.`EV_STA_Händelse_Status` h
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
LEFT JOIN
    attributes.`EV_UTL_Händelse_Utnyttjande` `UTL`
ON
    `UTL`.`EV_UTL_EV_ID` = `EV`.`EV_ID`
LEFT JOIN
    knots.`UTL_Utnyttjande` `kUTL`
ON
    `kUTL`.`UTL_ID` = `UTL`.`EV_UTL_UTL_ID`
LEFT JOIN (
    SELECT
        h.*,
        lead(h.`EV_LVL_ChangedAt`) OVER (
            PARTITION BY h.`EV_LVL_EV_ID`
            ORDER BY h.`EV_LVL_ChangedAt`
        ) AS `until`
    FROM
        attributes.`EV_LVL_Händelse_Level` h
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
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BigQuery tie perspectives: latest (l), point-in-time (p), now (n) and difference (d).
--
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_partner_AC_with_ONG_currently` (
    `Metadata_AC_partner_AC_with_ONG_currently`,
    `AC_partner_AC_with_ONG_currently_ChangedAt`,
    `AC_ID_partner` OPTIONS(description='One of the actors in the partnership.'),
    `AC_ID_with` OPTIONS(description='The other actor in the partnership.'),
    `currently_ONG_Pågående` OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).'),
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
    `ONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Pågående` `ONG_currently`
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
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_partner_AC_with_ONG_currently` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Pågående` `ONG_currently`
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
CREATE OR REPLACE VIEW ties.`nAC_partner_AC_with_ONG_currently` AS
SELECT
    *
FROM
    ties.`pAC_partner_AC_with_ONG_currently`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_partner_AC_with_ONG_currently` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_partner_AC_with_ONG_currently`,
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt`,
    tie.`AC_ID_partner`,
    tie.`AC_ID_with`,
    `ONG_currently`.`ONG_Pågående` AS `currently_ONG_Pågående`,
    `ONG_currently`.`Metadata_ONG` AS `currently_Metadata_ONG`,
    tie.`ONG_ID_currently`
FROM
    ties.`AC_partner_AC_with_ONG_currently` tie
LEFT JOIN
    knots.`ONG_Pågående` `ONG_currently`
ON
    `ONG_currently`.`ONG_ID` = tie.`ONG_ID_currently`
WHERE
    tie.`AC_partner_AC_with_ONG_currently_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_subset_PN_of` (
    `Metadata_AC_subset_PN_of`,
    `AC_ID_subset` OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.'),
    `PN_ID_of` OPTIONS(description='The person who is the actor.')
)
AS
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    ties.`AC_subset_PN_of` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_subset_PN_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_subset_PN_of`,
    tie.`AC_ID_subset`,
    tie.`PN_ID_of`
FROM
    ties.`AC_subset_PN_of` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_subset_PN_of` AS
SELECT
    *
FROM
    ties.`pAC_subset_PN_of`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lEV_in_AC_rollsattes` (
    `Metadata_EV_in_AC_rollsattes`,
    `EV_ID_in` OPTIONS(description='The event the actor was cast in.'),
    `AC_ID_rollsattes` OPTIONS(description='An actor cast in the event.')
)
OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.')
AS
SELECT
    tie.`Metadata_EV_in_AC_rollsattes`,
    tie.`EV_ID_in`,
    tie.`AC_ID_rollsattes`
FROM
    ties.`EV_in_AC_rollsattes` tie
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pEV_in_AC_rollsattes` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_EV_in_AC_rollsattes`,
    tie.`EV_ID_in`,
    tie.`AC_ID_rollsattes`
FROM
    ties.`EV_in_AC_rollsattes` tie
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nEV_in_AC_rollsattes` AS
SELECT
    *
FROM
    ties.`pEV_in_AC_rollsattes`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_deltar_PR_in_RAT_fick` (
    `Metadata_AC_deltar_PR_in_RAT_fick`,
    `AC_deltar_PR_in_RAT_fick_ChangedAt`,
    `AC_ID_deltar` OPTIONS(description='The actor having a part in the program.'),
    `PR_ID_in` OPTIONS(description='The program the actor has a part in.'),
    `fick_RAT_Checksum`,
    `fick_RAT_Betyg` OPTIONS(description='The rating the actor got for the part.'),
    `fick_Metadata_RAT`,
    `RAT_ID_fick` OPTIONS(description='The rating the actor got for the part.')
)
OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.')
AS
SELECT
    tie.`Metadata_AC_deltar_PR_in_RAT_fick`,
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    tie.`AC_ID_deltar`,
    tie.`PR_ID_in`,
    `RAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `RAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `RAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    tie.`RAT_ID_fick`
FROM
    ties.`AC_deltar_PR_in_RAT_fick` tie
LEFT JOIN
    knots.`RAT_Betyg` `RAT_fick`
ON
    `RAT_fick`.`RAT_ID` = tie.`RAT_ID_fick`
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` = max(tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_deltar`,
            tie.`PR_ID_in`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_deltar_PR_in_RAT_fick` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_deltar_PR_in_RAT_fick`,
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    tie.`AC_ID_deltar`,
    tie.`PR_ID_in`,
    `RAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `RAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `RAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    tie.`RAT_ID_fick`
FROM
    ties.`AC_deltar_PR_in_RAT_fick` tie
LEFT JOIN
    knots.`RAT_Betyg` `RAT_fick`
ON
    `RAT_fick`.`RAT_ID` = tie.`RAT_ID_fick`
WHERE
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` = max(tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`) OVER (
        PARTITION BY
            tie.`AC_ID_deltar`,
            tie.`PR_ID_in`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_deltar_PR_in_RAT_fick` AS
SELECT
    *
FROM
    ties.`pAC_deltar_PR_in_RAT_fick`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dAC_deltar_PR_in_RAT_fick` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_AC_deltar_PR_in_RAT_fick`,
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt`,
    tie.`AC_ID_deltar`,
    tie.`PR_ID_in`,
    `RAT_fick`.`RAT_Checksum` AS `fick_RAT_Checksum`,
    `RAT_fick`.`RAT_Betyg` AS `fick_RAT_Betyg`,
    `RAT_fick`.`Metadata_RAT` AS `fick_Metadata_RAT`,
    tie.`RAT_ID_fick`
FROM
    ties.`AC_deltar_PR_in_RAT_fick` tie
LEFT JOIN
    knots.`RAT_Betyg` `RAT_fick`
ON
    `RAT_fick`.`RAT_ID` = tie.`RAT_ID_fick`
WHERE
    tie.`AC_deltar_PR_in_RAT_fick_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lST_at_PR_spelas` (
    `Metadata_ST_at_PR_spelas`,
    `ST_at_PR_spelas_ChangedAt`,
    `ST_ID_at` OPTIONS(description='The stage where the program is playing.'),
    `PR_ID_spelas` OPTIONS(description='The program playing at the stage.')
)
OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.')
AS
SELECT
    tie.`Metadata_ST_at_PR_spelas`,
    tie.`ST_at_PR_spelas_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_spelas`
FROM
    ties.`ST_at_PR_spelas` tie
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_spelas_ChangedAt` = max(tie.`ST_at_PR_spelas_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_spelas`
    )
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pST_at_PR_spelas` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_spelas`,
    tie.`ST_at_PR_spelas_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_spelas`
FROM
    ties.`ST_at_PR_spelas` tie
WHERE
    tie.`ST_at_PR_spelas_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- the latest value for the identifiers
    tie.`ST_at_PR_spelas_ChangedAt` = max(tie.`ST_at_PR_spelas_ChangedAt`) OVER (
        PARTITION BY
            tie.`ST_ID_at`,
            tie.`PR_ID_spelas`
    )
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nST_at_PR_spelas` AS
SELECT
    *
FROM
    ties.`pST_at_PR_spelas`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dST_at_PR_spelas` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_ST_at_PR_spelas`,
    tie.`ST_at_PR_spelas_ChangedAt`,
    tie.`ST_ID_at`,
    tie.`PR_ID_spelas`
FROM
    ties.`ST_at_PR_spelas` tie
WHERE
    tie.`ST_at_PR_spelas_ChangedAt` BETWEEN intervalStart AND intervalEnd
)
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lAC_förälder_AC_barn_PAT_har` (
    `Metadata_AC_förälder_AC_barn_PAT_har`,
    `AC_ID_förälder` OPTIONS(description='The actor who is the parent.'),
    `AC_ID_barn` OPTIONS(description='The actor who is the child.'),
    `har_PAT_Föräldratyp` OPTIONS(description='The type of parental relationship.'),
    `har_Metadata_PAT`,
    `PAT_ID_har` OPTIONS(description='The type of parental relationship.')
)
OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.')
AS
SELECT
    tie.`Metadata_AC_förälder_AC_barn_PAT_har`,
    tie.`AC_ID_förälder`,
    tie.`AC_ID_barn`,
    `PAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `PAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    tie.`PAT_ID_har`
FROM
    ties.`AC_förälder_AC_barn_PAT_har` tie
LEFT JOIN
    knots.`PAT_Föräldratyp` `PAT_har`
ON
    `PAT_har`.`PAT_ID` = tie.`PAT_ID_har`
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pAC_förälder_AC_barn_PAT_har` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_AC_förälder_AC_barn_PAT_har`,
    tie.`AC_ID_förälder`,
    tie.`AC_ID_barn`,
    `PAT_har`.`PAT_Föräldratyp` AS `har_PAT_Föräldratyp`,
    `PAT_har`.`Metadata_PAT` AS `har_Metadata_PAT`,
    tie.`PAT_ID_har`
FROM
    ties.`AC_förälder_AC_barn_PAT_har` tie
LEFT JOIN
    knots.`PAT_Föräldratyp` `PAT_har`
ON
    `PAT_har`.`PAT_ID` = tie.`PAT_ID_har`
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nAC_förälder_AC_barn_PAT_har` AS
SELECT
    *
FROM
    ties.`pAC_förälder_AC_barn_PAT_har`(CAST(current_datetime() AS datetime))
;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`lPR_innehåll_ST_plats_EV_of` (
    `Metadata_PR_innehåll_ST_plats_EV_of`,
    `PR_innehåll_ST_plats_EV_of_ChangedAt`,
    `PR_ID_innehåll` OPTIONS(description='The program that made up the content of the event.'),
    `ST_ID_plats` OPTIONS(description='The stage where the event was located.'),
    `EV_ID_of` OPTIONS(description='The event.')
)
OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.')
AS
SELECT
    tie.`Metadata_PR_innehåll_ST_plats_EV_of`,
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    tie.`PR_ID_innehåll`,
    tie.`ST_ID_plats`,
    tie.`EV_ID_of`
FROM
    ties.`PR_innehåll_ST_plats_EV_of` tie
WHERE
    TRUE
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`PR_ID_innehåll`)
AND
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`ST_ID_plats`)
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`pPR_innehåll_ST_plats_EV_of` (
    changingTimepoint datetime
)
AS (
SELECT
    tie.`Metadata_PR_innehåll_ST_plats_EV_of`,
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    tie.`PR_ID_innehåll`,
    tie.`ST_ID_plats`,
    tie.`EV_ID_of`
FROM
    ties.`PR_innehåll_ST_plats_EV_of` tie
WHERE
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` <= changingTimepoint
QUALIFY -- picked by a window rather than by a subquery that refers to the outer row: for a tie without identifiers that
        -- subquery compares with OR, and then a database may keep rows that it should not
    -- a tie without identifiers is one to one: the latest value for each of its anchors
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`PR_ID_innehåll`)
AND
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` = max(tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`) OVER (PARTITION BY tie.`ST_ID_plats`)
)
;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties.`nPR_innehåll_ST_plats_EV_of` AS
SELECT
    *
FROM
    ties.`pPR_innehåll_ST_plats_EV_of`(CAST(current_datetime() AS datetime))
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE FUNCTION ties.`dPR_innehåll_ST_plats_EV_of` (
    intervalStart datetime,
    intervalEnd datetime
)
AS (
SELECT
    tie.`Metadata_PR_innehåll_ST_plats_EV_of`,
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt`,
    tie.`PR_ID_innehåll`,
    tie.`ST_ID_plats`,
    tie.`EV_ID_of`
FROM
    ties.`PR_innehåll_ST_plats_EV_of` tie
WHERE
    tie.`PR_innehåll_ST_plats_EV_of_ChangedAt` BETWEEN intervalStart AND intervalEnd
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
ALTER TABLE attributes.`EV_DAT_Händelse_Datum` ALTER COLUMN `EV_DAT_Händelse_Datum` SET OPTIONS(description='Date and time when the event took place.');
ALTER TABLE attributes.`EV_AUD_Händelse_Publik` ALTER COLUMN `EV_AUD_Händelse_Publik` SET OPTIONS(description='Number of people in the audience at the event.');
ALTER TABLE attributes.`EV_REV_Händelse_Intäkt` ALTER COLUMN `EV_REV_Händelse_Intäkt` SET OPTIONS(description='Revenue from ticket sales for the event.');
ALTER TABLE attributes.`EV_STA_Händelse_Status` ALTER COLUMN `EV_STA_Händelse_Status` SET OPTIONS(description='Status of the event, which may change until it has taken place.');
ALTER TABLE attributes.`EV_LVL_Händelse_Level` ALTER COLUMN `EV_LVL_PLV_ID` SET OPTIONS(description='Professional level required for the event, over time.');
ALTER TABLE attributes.`ST_NAM_Scen_Namn` ALTER COLUMN `ST_NAM_Scen_Namn` SET OPTIONS(description='Name of the stage. Historized, since a stage may be renamed over time.');
ALTER TABLE attributes.`ST_LOC_Scen_Plats` ALTER COLUMN `ST_LOC_Scen_Plats` SET OPTIONS(description='Geographic location of the stage as a geography point.');
ALTER TABLE attributes.`ST_AVG_Scen_Medel` ALTER COLUMN `ST_AVG_UTL_ID` SET OPTIONS(description='Average utilization of the stage capacity, recalculated over time.');
ALTER TABLE attributes.`ST_MIN_Scen_Minimum` ALTER COLUMN `ST_MIN_UTL_ID` SET OPTIONS(description='Minimum utilization of the stage capacity required for a performance to take place.');
ALTER TABLE attributes.`AC_NAM_Skådespelare_Namn` ALTER COLUMN `AC_NAM_Skådespelare_Namn` SET OPTIONS(description='Name of the actor, such as a stage name. Historized, since it may change over time.');
ALTER TABLE attributes.`AC_GEN_Skådespelare_Kön` ALTER COLUMN `AC_GEN_GEN_ID` SET OPTIONS(description='Gender of the actor.');
ALTER TABLE attributes.`AC_PLV_Skådespelare_Yrkesnivå` ALTER COLUMN `AC_PLV_PLV_ID` SET OPTIONS(description='Professional level of the actor, which may change as the actor gains experience.');
ALTER TABLE attributes.`PR_NAM_Föreställning_Namn` ALTER COLUMN `PR_NAM_Föreställning_Namn` SET OPTIONS(description='Name or title of the program.');
ALTER TABLE attributes.`PR_LEN_Föreställning_Längd` ALTER COLUMN `PR_LEN_Föreställning_Längd` SET OPTIONS(description='Running time of the program. Historized, since the program may be shortened or extended over time.');
ALTER TABLE anchors.`PN_Person` SET OPTIONS(description='A person. Persons who perform are also registered as actors.');
ALTER TABLE anchors.`ST_Scen` SET OPTIONS(description='A stage or venue where programs are played and events are held.');
ALTER TABLE anchors.`AC_Skådespelare` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE nexuses.`EV_Händelse` SET OPTIONS(description='An event, a single performance of a program held at a stage at a specific date and time.');
ALTER TABLE nexuses.`EV_Händelse` ALTER COLUMN `ST_ID_hölls` SET OPTIONS(description='The stage at which the event was held.');
ALTER TABLE nexuses.`EV_Händelse` ALTER COLUMN `PR_ID_spelades` SET OPTIONS(description='The program that was played at the event.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` SET OPTIONS(description='Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `AC_ID_partner` SET OPTIONS(description='One of the actors in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `AC_ID_with` SET OPTIONS(description='The other actor in the partnership.');
ALTER TABLE ties.`AC_partner_AC_with_ONG_currently` ALTER COLUMN `ONG_ID_currently` SET OPTIONS(description='Whether the partnership is still ongoing (Yes) or has ended (No).');
ALTER TABLE ties.`AC_subset_PN_of` ALTER COLUMN `AC_ID_subset` SET OPTIONS(description='An actor, a person who performs parts in programs and is cast in events.');
ALTER TABLE ties.`AC_subset_PN_of` ALTER COLUMN `PN_ID_of` SET OPTIONS(description='The person who is the actor.');
ALTER TABLE ties.`EV_in_AC_rollsattes` SET OPTIONS(description='The actors that were cast in an event, meaning those who performed at that performance.');
ALTER TABLE ties.`EV_in_AC_rollsattes` ALTER COLUMN `EV_ID_in` SET OPTIONS(description='The event the actor was cast in.');
ALTER TABLE ties.`EV_in_AC_rollsattes` ALTER COLUMN `AC_ID_rollsattes` SET OPTIONS(description='An actor cast in the event.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick` SET OPTIONS(description='Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick` ALTER COLUMN `AC_ID_deltar` SET OPTIONS(description='The actor having a part in the program.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick` ALTER COLUMN `PR_ID_in` SET OPTIONS(description='The program the actor has a part in.');
ALTER TABLE ties.`AC_deltar_PR_in_RAT_fick` ALTER COLUMN `RAT_ID_fick` SET OPTIONS(description='The rating the actor got for the part.');
ALTER TABLE ties.`ST_at_PR_spelas` SET OPTIONS(description='Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.');
ALTER TABLE ties.`ST_at_PR_spelas` ALTER COLUMN `ST_ID_at` SET OPTIONS(description='The stage where the program is playing.');
ALTER TABLE ties.`ST_at_PR_spelas` ALTER COLUMN `PR_ID_spelas` SET OPTIONS(description='The program playing at the stage.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har` SET OPTIONS(description='Parent-child relationships between actors, along with the type of parental relationship.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har` ALTER COLUMN `AC_ID_förälder` SET OPTIONS(description='The actor who is the parent.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har` ALTER COLUMN `AC_ID_barn` SET OPTIONS(description='The actor who is the child.');
ALTER TABLE ties.`AC_förälder_AC_barn_PAT_har` ALTER COLUMN `PAT_ID_har` SET OPTIONS(description='The type of parental relationship.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of` SET OPTIONS(description='The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of` ALTER COLUMN `PR_ID_innehåll` SET OPTIONS(description='The program that made up the content of the event.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of` ALTER COLUMN `ST_ID_plats` SET OPTIONS(description='The stage where the event was located.');
ALTER TABLE ties.`PR_innehåll_ST_plats_EV_of` ALTER COLUMN `EV_ID_of` SET OPTIONS(description='The event.');
