-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors are used to store the identities of entities.
-- Anchors are immutable.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-- SU_Subject table (with 12 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."SU_Subject_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_Subject" (
    "SU_ID" integer default nextval('public."SU_Subject_ID_SEQ"') not null, 
    "Metadata_SU" integer not null,
    constraint "pkSU_Subject" primary key (
        "SU_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- OB_Object table (with 1 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."OB_Object_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."OB_Object" (
    "OB_ID" integer default nextval('public."OB_Object_ID_SEQ"') not null, 
    "Metadata_OB" integer not null,
    constraint "pkOB_Object" primary key (
        "OB_ID"
    )
);
