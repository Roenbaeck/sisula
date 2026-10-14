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
    "PN_ID" int default public."PN_Person_ID_SEQ".nextval not null, 
    constraint "pkPN_Person" primary key (
        "PN_ID"
    ) RELY
) CLUSTER BY ("PN_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_Stage_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_Stage" (
    "ST_ID" int default public."ST_Stage_ID_SEQ".nextval not null, 
    constraint "pkST_Stage" primary key (
        "ST_ID"
    ) RELY
) CLUSTER BY ("ST_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_Actor_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_Actor" (
    "AC_ID" int default public."AC_Actor_ID_SEQ".nextval not null, 
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    ) RELY
) CLUSTER BY ("AC_ID");
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_Program_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_Program" (
    "PR_ID" int default public."PR_Program_ID_SEQ".nextval not null, 
    constraint "pkPR_Program" primary key (
        "PR_ID"
    ) RELY
) CLUSTER BY ("PR_ID");
