-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PN_Person table (with 0 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PN_Person_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PN_Person" (
    "PN_ID" integer default nextval('public."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" integer not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_Stage_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_Stage" (
    "ST_ID" integer default nextval('public."ST_Stage_ID_SEQ"') not null, 
    "Metadata_ST" integer not null,
    constraint "pkST_Stage" primary key (
        "ST_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_Actor_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_Actor" (
    "AC_ID" integer default nextval('public."AC_Actor_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_Program_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_Program" (
    "PR_ID" integer default nextval('public."PR_Program_ID_SEQ"') not null, 
    "Metadata_PR" integer not null,
    constraint "pkPR_Program" primary key (
        "PR_ID"
    )
);
