-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."PN_Person_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."PN_Person" (
    "PN_ID" bigint default anchors."PN_Person_ID_SEQ".nextval not null, 
    "Metadata_PN" int not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    ) RELY
) CLUSTER BY ("PN_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" int not null,
    "Metadata_ST" int not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    ) RELY
) CLUSTER BY ("ST_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default anchors."AC_Skådespelare_ID_SEQ".nextval not null, 
    "Metadata_AC" int not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    ) RELY
) CLUSTER BY ("AC_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" number(10,0) not null,
    "Metadata_PR" int not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    ) RELY
) CLUSTER BY ("PR_ID");
