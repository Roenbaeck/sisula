-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."PN_Person_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS anchors."PN_Person" (
    "PN_ID" bigint default nextval('anchors."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" integer not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
) ORDER BY "PN_ID" SEGMENTED BY MODULARHASH("PN_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Scen table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" integer not null,
    "Metadata_ST" integer not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Skådespelare table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default nextval('anchors."AC_Skådespelare_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    )
) ORDER BY "AC_ID" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Föreställning table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" bigint not null,
    "Metadata_PR" integer not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    )
) ORDER BY "PR_ID" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
