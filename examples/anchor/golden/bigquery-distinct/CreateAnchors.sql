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
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors.`ST_Stage` (
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
CREATE TABLE IF NOT EXISTS anchors.`AC_Actor` (
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
CREATE TABLE IF NOT EXISTS anchors.`PR_Program` (
    `PR_ID` int64 not null,
    `Metadata_PR` int64 not null,
    PRIMARY KEY (
        `PR_ID`
    ) NOT ENFORCED
)
CLUSTER BY `PR_ID`;
