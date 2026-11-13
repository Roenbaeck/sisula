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
