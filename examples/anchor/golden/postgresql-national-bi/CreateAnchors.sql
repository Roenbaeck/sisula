-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors store immutable entity identities.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."PN_Person_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."PN_Person" (
    "PN_ID" bigint default nextval('anchors."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" integer not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" integer not null,
    "Metadata_ST" integer not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default nextval('anchors."AC_Skådespelare_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" bigint not null,
    "Metadata_PR" integer not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    )
);
