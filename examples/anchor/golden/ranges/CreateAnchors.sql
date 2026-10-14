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
    "Metadata_PN" bigint not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    ) RELY
) CLUSTER BY ("PN_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Stage" (
    "ST_ID" int not null,
    "Metadata_ST" bigint not null,
    constraint "pkST_Stage" primary key (
        "ST_ID"
    ) RELY
) CLUSTER BY ("ST_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Actor_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Actor" (
    "AC_ID" smallint default anchors."AC_Actor_ID_SEQ".nextval not null, 
    "Metadata_AC" bigint not null,
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    ) RELY
) CLUSTER BY ("AC_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Program" (
    "PR_ID" number(10,0) not null,
    "Metadata_PR" bigint not null,
    constraint "pkPR_Program" primary key (
        "PR_ID"
    ) RELY
) CLUSTER BY ("PR_ID");
