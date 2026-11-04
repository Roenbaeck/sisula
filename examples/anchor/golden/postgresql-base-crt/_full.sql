-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS public;
-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."_Positor" (
    "Positor" smallint not null,
    constraint "pk_Positor" primary key (
        "Positor"
    )
);
INSERT INTO public."_Positor" (
    "Positor"
)
VALUES (
    0
)
ON CONFLICT DO NOTHING;
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are used to store finite sets of values, normally used to describe states
-- of entities (through knotted attributes) or relationships (through knotted ties).
-- Knots have their own surrogate identities and are therefore immutable.
-- Values can be added to the set over time though.
-- Knots should have values that are mutually exclusive and exhaustive.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PAT_ParentalType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PAT_ParentalType" (
    "PAT_ID" smallint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" integer not null,
    constraint "pkPAT_ParentalType" primary key (
        "PAT_ID" 
    ),
    constraint "uqPAT_ParentalType" unique (
        "PAT_ParentalType"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- GEN_Gender table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GEN_Gender" (
    "GEN_ID" smallint not null,
    "GEN_Gender" varchar(42) not null,
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID" 
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Gender"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PLV_ProfessionalLevel" (
    "PLV_ID" smallint not null,
    "PLV_ProfessionalLevel" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_ProfessionalLevel"::text), 'hex')) stored,
    "Metadata_PLV" integer not null,
    constraint "pkPLV_ProfessionalLevel" primary key (
        "PLV_ID" 
    ),
    constraint "uqPLV_ProfessionalLevel" unique (
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- UTL_Utilization table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."UTL_Utilization" (
    "UTL_ID" smallint not null,
    "UTL_Utilization" smallint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID" 
    ),
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ONG_Ongoing table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ONG_Ongoing" (
    "ONG_ID" smallint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" integer not null,
    constraint "pkONG_Ongoing" primary key (
        "ONG_ID" 
    ),
    constraint "uqONG_Ongoing" unique (
        "ONG_Ongoing"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- RAT_Rating table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."RAT_Rating" (
    "RAT_ID" smallint not null,
    "RAT_Rating" varchar(42) not null,
    "Metadata_RAT" integer not null,
    constraint "pkRAT_Rating" primary key (
        "RAT_ID" 
    ),
    constraint "uqRAT_Rating" unique (
        "RAT_Rating"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ETY_EventType" (
    "ETY_ID" smallint not null,
    "ETY_EventType" varchar(42) not null,
    "Metadata_ETY" integer not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID" 
    ),
    constraint "uqETY_EventType" unique (
        "ETY_EventType"
    )
);
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
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses are used to store identities for event-like entities.
-- Nexuses are immutable.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-- EV_Event table (with 3 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_Event_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_Event" (
    "EV_ID" integer default nextval('public."EV_Event_ID_SEQ"') not null, 
    "ST_ID_wasHeldAt" integer not null, 
    "PR_ID_wasPlayed" integer not null, 
    "ETY_ID_of" smallint not null,
    constraint "EV_Event_fkST_wasHeldAt" foreign key (
        "ST_ID_wasHeldAt"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "EV_Event_fkPR_wasPlayed" foreign key (
        "PR_ID_wasPlayed"
    ) references public."PR_Program"("PR_ID"), 
    constraint "EV_Event_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references public."ETY_EventType"("ETY_ID"),
    "Metadata_EV" integer not null, 
    constraint "pkEV_Event" primary key (
        "EV_ID"
    )
);
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_DAT_Event_Date_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date_Posit" (
    "EV_DAT_ID" integer default nextval('public."EV_DAT_Event_Date_Posit_ID_SEQ"') not null, 
    "EV_DAT_EV_ID" integer not null,
    "EV_DAT_Event_Date" timestamp not null,
    constraint "fkEV_DAT_Event_Date_Posit" foreign key (
        "EV_DAT_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date_Posit" primary key (
        "EV_DAT_ID"
    ),
    constraint "uqEV_DAT_Event_Date_Posit" unique (
        "EV_DAT_EV_ID",
        "EV_DAT_Event_Date"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Annex table (of EV_DAT_Event_Date_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_DAT_Event_Date_Annex" (
    "EV_DAT_ID" integer not null,
    "EV_DAT_PositedAt" timestamp not null,
    "EV_DAT_Positor" smallint not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "EV_DAT_Assertion" char(1) generated always as (
        case
            when "EV_DAT_Reliability" > 0 then '+'
            when "EV_DAT_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Event_Date_Annex" foreign key (
        "EV_DAT_ID"
    ) references public."EV_DAT_Event_Date_Posit"("EV_DAT_ID"),
    constraint "pkEV_DAT_Event_Date_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_Positor",
        "EV_DAT_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_AUD_Event_Audience_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience_Posit" (
    "EV_AUD_ID" integer default nextval('public."EV_AUD_Event_Audience_Posit_ID_SEQ"') not null, 
    "EV_AUD_EV_ID" integer not null,
    "EV_AUD_Event_Audience" integer not null,
    constraint "fkEV_AUD_Event_Audience_Posit" foreign key (
        "EV_AUD_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience_Posit" primary key (
        "EV_AUD_ID"
    ),
    constraint "uqEV_AUD_Event_Audience_Posit" unique (
        "EV_AUD_EV_ID",
        "EV_AUD_Event_Audience"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Annex table (of EV_AUD_Event_Audience_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_AUD_Event_Audience_Annex" (
    "EV_AUD_ID" integer not null,
    "EV_AUD_PositedAt" timestamp not null,
    "EV_AUD_Positor" smallint not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "EV_AUD_Assertion" char(1) generated always as (
        case
            when "EV_AUD_Reliability" > 0 then '+'
            when "EV_AUD_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Event_Audience_Annex" foreign key (
        "EV_AUD_ID"
    ) references public."EV_AUD_Event_Audience_Posit"("EV_AUD_ID"),
    constraint "pkEV_AUD_Event_Audience_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_Positor",
        "EV_AUD_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_REV_Event_Revenue_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue_Posit" (
    "EV_REV_ID" integer default nextval('public."EV_REV_Event_Revenue_Posit_ID_SEQ"') not null, 
    "EV_REV_EV_ID" integer not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    constraint "fkEV_REV_Event_Revenue_Posit" foreign key (
        "EV_REV_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue_Posit" primary key (
        "EV_REV_ID"
    ),
    constraint "uqEV_REV_Event_Revenue_Posit" unique (
        "EV_REV_EV_ID",
        "EV_REV_Event_Revenue"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Annex table (of EV_REV_Event_Revenue_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_REV_Event_Revenue_Annex" (
    "EV_REV_ID" integer not null,
    "EV_REV_PositedAt" timestamp not null,
    "EV_REV_Positor" smallint not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "EV_REV_Assertion" char(1) generated always as (
        case
            when "EV_REV_Reliability" > 0 then '+'
            when "EV_REV_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Event_Revenue_Annex" foreign key (
        "EV_REV_ID"
    ) references public."EV_REV_Event_Revenue_Posit"("EV_REV_ID"),
    constraint "pkEV_REV_Event_Revenue_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_Positor",
        "EV_REV_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_NAM_Stage_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name_Posit" (
    "ST_NAM_ID" integer default nextval('public."ST_NAM_Stage_Name_Posit_ID_SEQ"') not null, 
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Stage_Name_Posit" foreign key (
        "ST_NAM_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name_Posit" primary key (
        "ST_NAM_ID"
    ),
    constraint "uqST_NAM_Stage_Name_Posit" unique (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Stage_Name"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Annex table (of ST_NAM_Stage_Name_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_NAM_Stage_Name_Annex" (
    "ST_NAM_ID" integer not null,
    "ST_NAM_PositedAt" timestamp not null,
    "ST_NAM_Positor" smallint not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "ST_NAM_Assertion" char(1) generated always as (
        case
            when "ST_NAM_Reliability" > 0 then '+'
            when "ST_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Stage_Name_Annex" foreign key (
        "ST_NAM_ID"
    ) references public."ST_NAM_Stage_Name_Posit"("ST_NAM_ID"),
    constraint "pkST_NAM_Stage_Name_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_Positor",
        "ST_NAM_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_LOC_Stage_Location_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location_Posit" (
    "ST_LOC_ID" integer default nextval('public."ST_LOC_Stage_Location_Posit_ID_SEQ"') not null, 
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Stage_Location" geography not null,
    "ST_LOC_Checksum" bytea generated always as (decode(md5("ST_LOC_Stage_Location"::text), 'hex')) stored,
    constraint "fkST_LOC_Stage_Location_Posit" foreign key (
        "ST_LOC_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location_Posit" primary key (
        "ST_LOC_ID"
    ),
    constraint "uqST_LOC_Stage_Location_Posit" unique (
        "ST_LOC_ST_ID",
        "ST_LOC_Checksum" 
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Annex table (of ST_LOC_Stage_Location_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_LOC_Stage_Location_Annex" (
    "ST_LOC_ID" integer not null,
    "ST_LOC_PositedAt" timestamp not null,
    "ST_LOC_Positor" smallint not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "ST_LOC_Assertion" char(1) generated always as (
        case
            when "ST_LOC_Reliability" > 0 then '+'
            when "ST_LOC_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Stage_Location_Annex" foreign key (
        "ST_LOC_ID"
    ) references public."ST_LOC_Stage_Location_Posit"("ST_LOC_ID"),
    constraint "pkST_LOC_Stage_Location_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_Positor",
        "ST_LOC_PositedAt"
    )
);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_AVG_Stage_Average_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average_Posit" (
    "ST_AVG_ID" integer default nextval('public."ST_AVG_Stage_Average_Posit_ID_SEQ"') not null, 
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" smallint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_AVG_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_AVG_UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average_Posit" primary key (
        "ST_AVG_ID"
    ),
    constraint "uqST_AVG_Stage_Average_Posit" unique (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Annex table (of ST_AVG_Stage_Average_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_AVG_Stage_Average_Annex" (
    "ST_AVG_ID" integer not null,
    "ST_AVG_PositedAt" timestamp not null,
    "ST_AVG_Positor" smallint not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "ST_AVG_Assertion" char(1) generated always as (
        case
            when "ST_AVG_Reliability" > 0 then '+'
            when "ST_AVG_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_AVG" integer not null,
    constraint "fkST_AVG_Stage_Average_Annex" foreign key (
        "ST_AVG_ID"
    ) references public."ST_AVG_Stage_Average_Posit"("ST_AVG_ID"),
    constraint "pkST_AVG_Stage_Average_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_Positor",
        "ST_AVG_PositedAt"
    )
);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Posit table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Posit" (
    "ST_MIN_ID" integer default nextval('public."ST_MIN_Stage_Minimum_Posit_ID_SEQ"') not null, 
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" smallint not null,
    constraint "fk_A_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_MIN_ST_ID"
    ) references public."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_MIN_UTL_ID"
    ) references public."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ),
    constraint "uqST_MIN_Stage_Minimum_Posit" unique (
        "ST_MIN_ST_ID",
        "ST_MIN_UTL_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Annex table (of ST_MIN_Stage_Minimum_Posit on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."ST_MIN_Stage_Minimum_Annex" (
    "ST_MIN_ID" integer not null,
    "ST_MIN_PositedAt" timestamp not null,
    "ST_MIN_Positor" smallint not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "ST_MIN_Assertion" char(1) generated always as (
        case
            when "ST_MIN_Reliability" > 0 then '+'
            when "ST_MIN_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_MIN" integer not null,
    constraint "fkST_MIN_Stage_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references public."ST_MIN_Stage_Minimum_Posit"("ST_MIN_ID"),
    constraint "pkST_MIN_Stage_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_Positor",
        "ST_MIN_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_NAM_Actor_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name_Posit" (
    "AC_NAM_ID" integer default nextval('public."AC_NAM_Actor_Name_Posit_ID_SEQ"') not null, 
    "AC_NAM_AC_ID" integer not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Actor_Name_Posit" foreign key (
        "AC_NAM_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name_Posit" primary key (
        "AC_NAM_ID"
    ),
    constraint "uqAC_NAM_Actor_Name_Posit" unique (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Actor_Name"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Annex table (of AC_NAM_Actor_Name_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_NAM_Actor_Name_Annex" (
    "AC_NAM_ID" integer not null,
    "AC_NAM_PositedAt" timestamp not null,
    "AC_NAM_Positor" smallint not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "AC_NAM_Assertion" char(1) generated always as (
        case
            when "AC_NAM_Reliability" > 0 then '+'
            when "AC_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Actor_Name_Annex" foreign key (
        "AC_NAM_ID"
    ) references public."AC_NAM_Actor_Name_Posit"("AC_NAM_ID"),
    constraint "pkAC_NAM_Actor_Name_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_Positor",
        "AC_NAM_PositedAt"
    )
);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_GEN_Actor_Gender_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender_Posit" (
    "AC_GEN_ID" integer default nextval('public."AC_GEN_Actor_Gender_Posit_ID_SEQ"') not null, 
    "AC_GEN_AC_ID" integer not null,
    "AC_GEN_GEN_ID" smallint not null,
    constraint "fk_A_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_GEN_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_GEN_GEN_ID"
    ) references public."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Posit" primary key (
        "AC_GEN_ID"
    ),
    constraint "uqAC_GEN_Actor_Gender_Posit" unique (
        "AC_GEN_AC_ID",
        "AC_GEN_GEN_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Annex table (of AC_GEN_Actor_Gender_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_GEN_Actor_Gender_Annex" (
    "AC_GEN_ID" integer not null,
    "AC_GEN_PositedAt" timestamp not null,
    "AC_GEN_Positor" smallint not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "AC_GEN_Assertion" char(1) generated always as (
        case
            when "AC_GEN_Reliability" > 0 then '+'
            when "AC_GEN_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_GEN" integer not null,
    constraint "fkAC_GEN_Actor_Gender_Annex" foreign key (
        "AC_GEN_ID"
    ) references public."AC_GEN_Actor_Gender_Posit"("AC_GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_Positor",
        "AC_GEN_PositedAt"
    )
);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Posit table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Posit" (
    "AC_PLV_ID" integer default nextval('public."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ"') not null, 
    "AC_PLV_AC_ID" integer not null,
    "AC_PLV_PLV_ID" smallint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_PLV_AC_ID"
    ) references public."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_PLV_PLV_ID"
    ) references public."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Posit" primary key (
        "AC_PLV_ID"
    ),
    constraint "uqAC_PLV_Actor_ProfessionalLevel_Posit" unique (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PLV_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Annex table (of AC_PLV_Actor_ProfessionalLevel_Posit on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."AC_PLV_Actor_ProfessionalLevel_Annex" (
    "AC_PLV_ID" integer not null,
    "AC_PLV_PositedAt" timestamp not null,
    "AC_PLV_Positor" smallint not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "AC_PLV_Assertion" char(1) generated always as (
        case
            when "AC_PLV_Reliability" > 0 then '+'
            when "AC_PLV_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_PLV" integer not null,
    constraint "fkAC_PLV_Actor_ProfessionalLevel_Annex" foreign key (
        "AC_PLV_ID"
    ) references public."AC_PLV_Actor_ProfessionalLevel_Posit"("AC_PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_Positor",
        "AC_PLV_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_NAM_Program_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name_Posit" (
    "PR_NAM_ID" integer default nextval('public."PR_NAM_Program_Name_Posit_ID_SEQ"') not null, 
    "PR_NAM_PR_ID" integer not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    constraint "fkPR_NAM_Program_Name_Posit" foreign key (
        "PR_NAM_PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name_Posit" primary key (
        "PR_NAM_ID"
    ),
    constraint "uqPR_NAM_Program_Name_Posit" unique (
        "PR_NAM_PR_ID",
        "PR_NAM_Program_Name"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Annex table (of PR_NAM_Program_Name_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_NAM_Program_Name_Annex" (
    "PR_NAM_ID" integer not null,
    "PR_NAM_PositedAt" timestamp not null,
    "PR_NAM_Positor" smallint not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "PR_NAM_Assertion" char(1) generated always as (
        case
            when "PR_NAM_Reliability" > 0 then '+'
            when "PR_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Program_Name_Annex" foreign key (
        "PR_NAM_ID"
    ) references public."PR_NAM_Program_Name_Posit"("PR_NAM_ID"),
    constraint "pkPR_NAM_Program_Name_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_Positor",
        "PR_NAM_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Posit table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."PR_LEN_Program_Length_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length_Posit" (
    "PR_LEN_ID" integer default nextval('public."PR_LEN_Program_Length_Posit_ID_SEQ"') not null, 
    "PR_LEN_PR_ID" integer not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Program_Length_Posit" foreign key (
        "PR_LEN_PR_ID"
    ) references public."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length_Posit" primary key (
        "PR_LEN_ID"
    ),
    constraint "uqPR_LEN_Program_Length_Posit" unique (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Program_Length"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Annex table (of PR_LEN_Program_Length_Posit on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."PR_LEN_Program_Length_Annex" (
    "PR_LEN_ID" integer not null,
    "PR_LEN_PositedAt" timestamp not null,
    "PR_LEN_Positor" smallint not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "PR_LEN_Assertion" char(1) generated always as (
        case
            when "PR_LEN_Reliability" > 0 then '+'
            when "PR_LEN_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Program_Length_Annex" foreign key (
        "PR_LEN_ID"
    ) references public."PR_LEN_Program_Length_Posit"("PR_LEN_ID"),
    constraint "pkPR_LEN_Program_Length_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_Positor",
        "PR_LEN_PositedAt"
    )
);
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public."EV_DAT_Event_Date" AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Positor",
    a."EV_DAT_Reliability",
    a."EV_DAT_Assertion"
FROM
    public."EV_DAT_Event_Date_Posit" p
JOIN
    public."EV_DAT_Event_Date_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
;
CREATE OR REPLACE VIEW public."EV_AUD_Event_Audience" AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Positor",
    a."EV_AUD_Reliability",
    a."EV_AUD_Assertion"
FROM
    public."EV_AUD_Event_Audience_Posit" p
JOIN
    public."EV_AUD_Event_Audience_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
;
CREATE OR REPLACE VIEW public."EV_REV_Event_Revenue" AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue",
    a."EV_REV_PositedAt",
    a."EV_REV_Positor",
    a."EV_REV_Reliability",
    a."EV_REV_Assertion"
FROM
    public."EV_REV_Event_Revenue_Posit" p
JOIN
    public."EV_REV_Event_Revenue_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
;
CREATE OR REPLACE VIEW public."ST_NAM_Stage_Name" AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion"
FROM
    public."ST_NAM_Stage_Name_Posit" p
JOIN
    public."ST_NAM_Stage_Name_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
;
CREATE OR REPLACE VIEW public."ST_LOC_Stage_Location" AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Positor",
    a."ST_LOC_Reliability",
    a."ST_LOC_Assertion"
FROM
    public."ST_LOC_Stage_Location_Posit" p
JOIN
    public."ST_LOC_Stage_Location_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
;
CREATE OR REPLACE VIEW public."ST_AVG_Stage_Average" AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Positor",
    a."ST_AVG_Reliability",
    a."ST_AVG_Assertion"
FROM
    public."ST_AVG_Stage_Average_Posit" p
JOIN
    public."ST_AVG_Stage_Average_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
;
CREATE OR REPLACE VIEW public."ST_MIN_Stage_Minimum" AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Positor",
    a."ST_MIN_Reliability",
    a."ST_MIN_Assertion"
FROM
    public."ST_MIN_Stage_Minimum_Posit" p
JOIN
    public."ST_MIN_Stage_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
;
CREATE OR REPLACE VIEW public."AC_NAM_Actor_Name" AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion"
FROM
    public."AC_NAM_Actor_Name_Posit" p
JOIN
    public."AC_NAM_Actor_Name_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
;
CREATE OR REPLACE VIEW public."AC_GEN_Actor_Gender" AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Positor",
    a."AC_GEN_Reliability",
    a."AC_GEN_Assertion"
FROM
    public."AC_GEN_Actor_Gender_Posit" p
JOIN
    public."AC_GEN_Actor_Gender_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
;
CREATE OR REPLACE VIEW public."AC_PLV_Actor_ProfessionalLevel" AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Positor",
    a."AC_PLV_Reliability",
    a."AC_PLV_Assertion"
FROM
    public."AC_PLV_Actor_ProfessionalLevel_Posit" p
JOIN
    public."AC_PLV_Actor_ProfessionalLevel_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
;
CREATE OR REPLACE VIEW public."PR_NAM_Program_Name" AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Positor",
    a."PR_NAM_Reliability",
    a."PR_NAM_Assertion"
FROM
    public."PR_NAM_Program_Name_Posit" p
JOIN
    public."PR_NAM_Program_Name_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
;
CREATE OR REPLACE VIEW public."PR_LEN_Program_Length" AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion"
FROM
    public."PR_LEN_Program_Length_Posit" p
JOIN
    public."PR_LEN_Program_Length_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- These table valued functions rewind an attribute posit table to the given
-- point in changing time, or an attribute annex table to the given point
-- in positing time. It does not pick a temporal perspective and
-- instead shows all rows that have been in effect before that point
-- in time. The forwarder is the opposite of the rewinder, such that the 
-- union of the two will produce all rows in a posit table.
--
-- @positor the view of which positor to adopt, or null for the views of all of them
-- @changingTimepoint the point in changing time to rewind to (defaults to End of Time, no rewind)
-- @positingTimepoint the point in positing time to rewind to (defaults to End of Time, no rewind)
--
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_DAT_Event_Date_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Positor" smallint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_EV_DAT",
    "EV_DAT_ID",
    "EV_DAT_PositedAt",
    "EV_DAT_Positor",
    "EV_DAT_Reliability",
    "EV_DAT_Assertion"
FROM
    public."EV_DAT_Event_Date_Annex"
WHERE
    "EV_DAT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_DAT_Event_Date" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Positor" smallint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" char(1),
    "EV_DAT_EV_ID" integer,
    "EV_DAT_Event_Date" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_DAT_ID", a."EV_DAT_Positor")
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Positor",
    a."EV_DAT_Reliability",
    a."EV_DAT_Assertion",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date"
FROM
    public."EV_DAT_Event_Date_Posit" p
JOIN
    public."rEV_DAT_Event_Date_Annex"(positingTimepoint) a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
AND
    a."EV_DAT_Positor" = coalesce(positor, a."EV_DAT_Positor")
ORDER BY
    p."EV_DAT_ID", a."EV_DAT_Positor",
    a."EV_DAT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_AUD_Event_Audience_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Positor" smallint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_EV_AUD",
    "EV_AUD_ID",
    "EV_AUD_PositedAt",
    "EV_AUD_Positor",
    "EV_AUD_Reliability",
    "EV_AUD_Assertion"
FROM
    public."EV_AUD_Event_Audience_Annex"
WHERE
    "EV_AUD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_AUD_Event_Audience" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Positor" smallint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" char(1),
    "EV_AUD_EV_ID" integer,
    "EV_AUD_Event_Audience" integer
)
AS
$$
SELECT DISTINCT ON (p."EV_AUD_ID", a."EV_AUD_Positor")
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Positor",
    a."EV_AUD_Reliability",
    a."EV_AUD_Assertion",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience"
FROM
    public."EV_AUD_Event_Audience_Posit" p
JOIN
    public."rEV_AUD_Event_Audience_Annex"(positingTimepoint) a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
AND
    a."EV_AUD_Positor" = coalesce(positor, a."EV_AUD_Positor")
ORDER BY
    p."EV_AUD_ID", a."EV_AUD_Positor",
    a."EV_AUD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_REV_Event_Revenue_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Positor" smallint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_EV_REV",
    "EV_REV_ID",
    "EV_REV_PositedAt",
    "EV_REV_Positor",
    "EV_REV_Reliability",
    "EV_REV_Assertion"
FROM
    public."EV_REV_Event_Revenue_Annex"
WHERE
    "EV_REV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rEV_REV_Event_Revenue" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Positor" smallint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" char(1),
    "EV_REV_EV_ID" integer,
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT DISTINCT ON (p."EV_REV_ID", a."EV_REV_Positor")
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Positor",
    a."EV_REV_Reliability",
    a."EV_REV_Assertion",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue"
FROM
    public."EV_REV_Event_Revenue_Posit" p
JOIN
    public."rEV_REV_Event_Revenue_Annex"(positingTimepoint) a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
AND
    a."EV_REV_Positor" = coalesce(positor, a."EV_REV_Positor")
ORDER BY
    p."EV_REV_ID", a."EV_REV_Positor",
    a."EV_REV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_NAM_Stage_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_NAM_ID",
    "ST_NAM_ST_ID",
    "ST_NAM_Stage_Name",
    "ST_NAM_ChangedAt"
FROM
    public."ST_NAM_Stage_Name_Posit"
WHERE
    "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fST_NAM_Stage_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_NAM_ID",
    "ST_NAM_ST_ID",
    "ST_NAM_Stage_Name",
    "ST_NAM_ChangedAt"
FROM
    public."ST_NAM_Stage_Name_Posit"
WHERE
    "ST_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_NAM_Stage_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_ST_NAM",
    "ST_NAM_ID",
    "ST_NAM_PositedAt",
    "ST_NAM_Positor",
    "ST_NAM_Reliability",
    "ST_NAM_Assertion"
FROM
    public."ST_NAM_Stage_Name_Annex"
WHERE
    "ST_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_NAM_Stage_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID", a."ST_NAM_Positor")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    public."rST_NAM_Stage_Name_Posit"(changingTimepoint) p
JOIN
    public."rST_NAM_Stage_Name_Annex"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Positor" = coalesce(positor, a."ST_NAM_Positor")
ORDER BY
    p."ST_NAM_ID", a."ST_NAM_Positor",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fST_NAM_Stage_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID", a."ST_NAM_Positor")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Positor",
    a."ST_NAM_Reliability",
    a."ST_NAM_Assertion",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    public."fST_NAM_Stage_Name_Posit"(changingTimepoint) p
JOIN
    public."rST_NAM_Stage_Name_Annex"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Positor" = coalesce(positor, a."ST_NAM_Positor")
ORDER BY
    p."ST_NAM_ID", a."ST_NAM_Positor",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preST_NAM_Stage_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."ST_NAM_Stage_Name"
FROM
    public."rST_NAM_Stage_Name"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_NAM_ST_ID" = id
AND
    pre."ST_NAM_ChangedAt" < changingTimepoint
AND
    pre."ST_NAM_Assertion" = coalesce(assertion, pre."ST_NAM_Assertion")
ORDER BY
    pre."ST_NAM_ChangedAt" DESC,
    pre."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folST_NAM_Stage_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."ST_NAM_Stage_Name"
FROM
    public."fST_NAM_Stage_Name"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_NAM_ST_ID" = id
AND
    fol."ST_NAM_ChangedAt" > changingTimepoint
AND
    fol."ST_NAM_Assertion" = coalesce(assertion, fol."ST_NAM_Assertion")
ORDER BY
    fol."ST_NAM_ChangedAt" ASC,
    fol."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_LOC_Stage_Location_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_ST_LOC",
    "ST_LOC_ID",
    "ST_LOC_PositedAt",
    "ST_LOC_Positor",
    "ST_LOC_Reliability",
    "ST_LOC_Assertion"
FROM
    public."ST_LOC_Stage_Location_Annex"
WHERE
    "ST_LOC_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_LOC_Stage_Location" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1),
    "ST_LOC_ST_ID" integer,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography
)
AS
$$
SELECT DISTINCT ON (p."ST_LOC_ID", a."ST_LOC_Positor")
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Positor",
    a."ST_LOC_Reliability",
    a."ST_LOC_Assertion",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location"
FROM
    public."ST_LOC_Stage_Location_Posit" p
JOIN
    public."rST_LOC_Stage_Location_Annex"(positingTimepoint) a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
AND
    a."ST_LOC_Positor" = coalesce(positor, a."ST_LOC_Positor")
ORDER BY
    p."ST_LOC_ID", a."ST_LOC_Positor",
    a."ST_LOC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_AVG_Stage_Average_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" integer,
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_AVG_ID",
    "ST_AVG_ST_ID",
    "ST_AVG_UTL_ID",
    "ST_AVG_ChangedAt"
FROM
    public."ST_AVG_Stage_Average_Posit"
WHERE
    "ST_AVG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fST_AVG_Stage_Average_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" integer,
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_AVG_ID",
    "ST_AVG_ST_ID",
    "ST_AVG_UTL_ID",
    "ST_AVG_ChangedAt"
FROM
    public."ST_AVG_Stage_Average_Posit"
WHERE
    "ST_AVG_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_AVG_Stage_Average_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_ST_AVG",
    "ST_AVG_ID",
    "ST_AVG_PositedAt",
    "ST_AVG_Positor",
    "ST_AVG_Reliability",
    "ST_AVG_Assertion"
FROM
    public."ST_AVG_Stage_Average_Annex"
WHERE
    "ST_AVG_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_AVG_Stage_Average" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID", a."ST_AVG_Positor")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Positor",
    a."ST_AVG_Reliability",
    a."ST_AVG_Assertion",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    public."rST_AVG_Stage_Average_Posit"(changingTimepoint) p
JOIN
    public."rST_AVG_Stage_Average_Annex"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Positor" = coalesce(positor, a."ST_AVG_Positor")
ORDER BY
    p."ST_AVG_ID", a."ST_AVG_Positor",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fST_AVG_Stage_Average" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID", a."ST_AVG_Positor")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Positor",
    a."ST_AVG_Reliability",
    a."ST_AVG_Assertion",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    public."fST_AVG_Stage_Average_Posit"(changingTimepoint) p
JOIN
    public."rST_AVG_Stage_Average_Annex"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Positor" = coalesce(positor, a."ST_AVG_Positor")
ORDER BY
    p."ST_AVG_ID", a."ST_AVG_Positor",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preST_AVG_Stage_Average" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."ST_AVG_UTL_ID"
FROM
    public."rST_AVG_Stage_Average"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_AVG_ST_ID" = id
AND
    pre."ST_AVG_ChangedAt" < changingTimepoint
AND
    pre."ST_AVG_Assertion" = coalesce(assertion, pre."ST_AVG_Assertion")
ORDER BY
    pre."ST_AVG_ChangedAt" DESC,
    pre."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folST_AVG_Stage_Average" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."ST_AVG_UTL_ID"
FROM
    public."fST_AVG_Stage_Average"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_AVG_ST_ID" = id
AND
    fol."ST_AVG_ChangedAt" > changingTimepoint
AND
    fol."ST_AVG_Assertion" = coalesce(assertion, fol."ST_AVG_Assertion")
ORDER BY
    fol."ST_AVG_ChangedAt" ASC,
    fol."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_MIN_Stage_Minimum_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_ST_MIN",
    "ST_MIN_ID",
    "ST_MIN_PositedAt",
    "ST_MIN_Positor",
    "ST_MIN_Reliability",
    "ST_MIN_Assertion"
FROM
    public."ST_MIN_Stage_Minimum_Annex"
WHERE
    "ST_MIN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rST_MIN_Stage_Minimum" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1),
    "ST_MIN_ST_ID" integer,
    "ST_MIN_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."ST_MIN_ID", a."ST_MIN_Positor")
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Positor",
    a."ST_MIN_Reliability",
    a."ST_MIN_Assertion",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    public."ST_MIN_Stage_Minimum_Posit" p
JOIN
    public."rST_MIN_Stage_Minimum_Annex"(positingTimepoint) a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
AND
    a."ST_MIN_Positor" = coalesce(positor, a."ST_MIN_Positor")
ORDER BY
    p."ST_MIN_ID", a."ST_MIN_Positor",
    a."ST_MIN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_NAM_Actor_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" integer,
    "AC_NAM_AC_ID" integer,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_NAM_ID",
    "AC_NAM_AC_ID",
    "AC_NAM_Actor_Name",
    "AC_NAM_ChangedAt"
FROM
    public."AC_NAM_Actor_Name_Posit"
WHERE
    "AC_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fAC_NAM_Actor_Name_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" integer,
    "AC_NAM_AC_ID" integer,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_NAM_ID",
    "AC_NAM_AC_ID",
    "AC_NAM_Actor_Name",
    "AC_NAM_ChangedAt"
FROM
    public."AC_NAM_Actor_Name_Posit"
WHERE
    "AC_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_NAM_Actor_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_NAM",
    "AC_NAM_ID",
    "AC_NAM_PositedAt",
    "AC_NAM_Positor",
    "AC_NAM_Reliability",
    "AC_NAM_Assertion"
FROM
    public."AC_NAM_Actor_Name_Annex"
WHERE
    "AC_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_NAM_Actor_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_AC_ID" integer,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID", a."AC_NAM_Positor")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    public."rAC_NAM_Actor_Name_Posit"(changingTimepoint) p
JOIN
    public."rAC_NAM_Actor_Name_Annex"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Positor" = coalesce(positor, a."AC_NAM_Positor")
ORDER BY
    p."AC_NAM_ID", a."AC_NAM_Positor",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fAC_NAM_Actor_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_AC_ID" integer,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID", a."AC_NAM_Positor")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Positor",
    a."AC_NAM_Reliability",
    a."AC_NAM_Assertion",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    public."fAC_NAM_Actor_Name_Posit"(changingTimepoint) p
JOIN
    public."rAC_NAM_Actor_Name_Annex"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Positor" = coalesce(positor, a."AC_NAM_Positor")
ORDER BY
    p."AC_NAM_ID", a."AC_NAM_Positor",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preAC_NAM_Actor_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."AC_NAM_Actor_Name"
FROM
    public."rAC_NAM_Actor_Name"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_NAM_AC_ID" = id
AND
    pre."AC_NAM_ChangedAt" < changingTimepoint
AND
    pre."AC_NAM_Assertion" = coalesce(assertion, pre."AC_NAM_Assertion")
ORDER BY
    pre."AC_NAM_ChangedAt" DESC,
    pre."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folAC_NAM_Actor_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."AC_NAM_Actor_Name"
FROM
    public."fAC_NAM_Actor_Name"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_NAM_AC_ID" = id
AND
    fol."AC_NAM_ChangedAt" > changingTimepoint
AND
    fol."AC_NAM_Assertion" = coalesce(assertion, fol."AC_NAM_Assertion")
ORDER BY
    fol."AC_NAM_ChangedAt" ASC,
    fol."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_GEN_Actor_Gender_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_GEN",
    "AC_GEN_ID",
    "AC_GEN_PositedAt",
    "AC_GEN_Positor",
    "AC_GEN_Reliability",
    "AC_GEN_Assertion"
FROM
    public."AC_GEN_Actor_Gender_Annex"
WHERE
    "AC_GEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_GEN_Actor_Gender" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1),
    "AC_GEN_AC_ID" integer,
    "AC_GEN_GEN_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."AC_GEN_ID", a."AC_GEN_Positor")
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Positor",
    a."AC_GEN_Reliability",
    a."AC_GEN_Assertion",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    public."AC_GEN_Actor_Gender_Posit" p
JOIN
    public."rAC_GEN_Actor_Gender_Annex"(positingTimepoint) a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
AND
    a."AC_GEN_Positor" = coalesce(positor, a."AC_GEN_Positor")
ORDER BY
    p."AC_GEN_ID", a."AC_GEN_Positor",
    a."AC_GEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_PLV_Actor_ProfessionalLevel_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" integer,
    "AC_PLV_AC_ID" integer,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_PLV_ID",
    "AC_PLV_AC_ID",
    "AC_PLV_PLV_ID",
    "AC_PLV_ChangedAt"
FROM
    public."AC_PLV_Actor_ProfessionalLevel_Posit"
WHERE
    "AC_PLV_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fAC_PLV_Actor_ProfessionalLevel_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" integer,
    "AC_PLV_AC_ID" integer,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_PLV_ID",
    "AC_PLV_AC_ID",
    "AC_PLV_PLV_ID",
    "AC_PLV_ChangedAt"
FROM
    public."AC_PLV_Actor_ProfessionalLevel_Posit"
WHERE
    "AC_PLV_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_PLV_Actor_ProfessionalLevel_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_PLV",
    "AC_PLV_ID",
    "AC_PLV_PositedAt",
    "AC_PLV_Positor",
    "AC_PLV_Reliability",
    "AC_PLV_Assertion"
FROM
    public."AC_PLV_Actor_ProfessionalLevel_Annex"
WHERE
    "AC_PLV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rAC_PLV_Actor_ProfessionalLevel" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "AC_PLV_AC_ID" integer,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID", a."AC_PLV_Positor")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Positor",
    a."AC_PLV_Reliability",
    a."AC_PLV_Assertion",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    public."rAC_PLV_Actor_ProfessionalLevel_Posit"(changingTimepoint) p
JOIN
    public."rAC_PLV_Actor_ProfessionalLevel_Annex"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Positor" = coalesce(positor, a."AC_PLV_Positor")
ORDER BY
    p."AC_PLV_ID", a."AC_PLV_Positor",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fAC_PLV_Actor_ProfessionalLevel" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "AC_PLV_AC_ID" integer,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID", a."AC_PLV_Positor")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Positor",
    a."AC_PLV_Reliability",
    a."AC_PLV_Assertion",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    public."fAC_PLV_Actor_ProfessionalLevel_Posit"(changingTimepoint) p
JOIN
    public."rAC_PLV_Actor_ProfessionalLevel_Annex"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Positor" = coalesce(positor, a."AC_PLV_Positor")
ORDER BY
    p."AC_PLV_ID", a."AC_PLV_Positor",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."preAC_PLV_Actor_ProfessionalLevel" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."AC_PLV_PLV_ID"
FROM
    public."rAC_PLV_Actor_ProfessionalLevel"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_PLV_AC_ID" = id
AND
    pre."AC_PLV_ChangedAt" < changingTimepoint
AND
    pre."AC_PLV_Assertion" = coalesce(assertion, pre."AC_PLV_Assertion")
ORDER BY
    pre."AC_PLV_ChangedAt" DESC,
    pre."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folAC_PLV_Actor_ProfessionalLevel" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."AC_PLV_PLV_ID"
FROM
    public."fAC_PLV_Actor_ProfessionalLevel"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_PLV_AC_ID" = id
AND
    fol."AC_PLV_ChangedAt" > changingTimepoint
AND
    fol."AC_PLV_Assertion" = coalesce(assertion, fol."AC_PLV_Assertion")
ORDER BY
    fol."AC_PLV_ChangedAt" ASC,
    fol."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rPR_NAM_Program_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_PR_NAM",
    "PR_NAM_ID",
    "PR_NAM_PositedAt",
    "PR_NAM_Positor",
    "PR_NAM_Reliability",
    "PR_NAM_Assertion"
FROM
    public."PR_NAM_Program_Name_Annex"
WHERE
    "PR_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rPR_NAM_Program_Name" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1),
    "PR_NAM_PR_ID" integer,
    "PR_NAM_Program_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."PR_NAM_ID", a."PR_NAM_Positor")
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Positor",
    a."PR_NAM_Reliability",
    a."PR_NAM_Assertion",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name"
FROM
    public."PR_NAM_Program_Name_Posit" p
JOIN
    public."rPR_NAM_Program_Name_Annex"(positingTimepoint) a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
AND
    a."PR_NAM_Positor" = coalesce(positor, a."PR_NAM_Positor")
ORDER BY
    p."PR_NAM_ID", a."PR_NAM_Positor",
    a."PR_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rPR_LEN_Program_Length_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" integer,
    "PR_LEN_PR_ID" integer,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    "PR_LEN_ID",
    "PR_LEN_PR_ID",
    "PR_LEN_Program_Length",
    "PR_LEN_ChangedAt"
FROM
    public."PR_LEN_Program_Length_Posit"
WHERE
    "PR_LEN_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fPR_LEN_Program_Length_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" integer,
    "PR_LEN_PR_ID" integer,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    "PR_LEN_ID",
    "PR_LEN_PR_ID",
    "PR_LEN_Program_Length",
    "PR_LEN_ChangedAt"
FROM
    public."PR_LEN_Program_Length_Posit"
WHERE
    "PR_LEN_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rPR_LEN_Program_Length_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_PR_LEN",
    "PR_LEN_ID",
    "PR_LEN_PositedAt",
    "PR_LEN_Positor",
    "PR_LEN_Reliability",
    "PR_LEN_Assertion"
FROM
    public."PR_LEN_Program_Length_Annex"
WHERE
    "PR_LEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."rPR_LEN_Program_Length" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_PR_ID" integer,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID", a."PR_LEN_Positor")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    public."rPR_LEN_Program_Length_Posit"(changingTimepoint) p
JOIN
    public."rPR_LEN_Program_Length_Annex"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Positor" = coalesce(positor, a."PR_LEN_Positor")
ORDER BY
    p."PR_LEN_ID", a."PR_LEN_Positor",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."fPR_LEN_Program_Length" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_PR_ID" integer,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID", a."PR_LEN_Positor")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Positor",
    a."PR_LEN_Reliability",
    a."PR_LEN_Assertion",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    public."fPR_LEN_Program_Length_Posit"(changingTimepoint) p
JOIN
    public."rPR_LEN_Program_Length_Annex"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Positor" = coalesce(positor, a."PR_LEN_Positor")
ORDER BY
    p."PR_LEN_ID", a."PR_LEN_Positor",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."prePR_LEN_Program_Length" (
    id integer,
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS time
AS
$$
SELECT
    pre."PR_LEN_Program_Length"
FROM
    public."rPR_LEN_Program_Length"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."PR_LEN_PR_ID" = id
AND
    pre."PR_LEN_ChangedAt" < changingTimepoint
AND
    pre."PR_LEN_Assertion" = coalesce(assertion, pre."PR_LEN_Assertion")
ORDER BY
    pre."PR_LEN_ChangedAt" DESC,
    pre."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."folPR_LEN_Program_Length" (
    id integer,
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS time
AS
$$
SELECT
    fol."PR_LEN_Program_Length"
FROM
    public."fPR_LEN_Program_Length"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."PR_LEN_PR_ID" = id
AND
    fol."PR_LEN_ChangedAt" > changingTimepoint
AND
    fol."PR_LEN_Assertion" = coalesce(assertion, fol."PR_LEN_Assertion")
ORDER BY
    fol."PR_LEN_ChangedAt" ASC,
    fol."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- CRT anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tST_Stage" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Positor",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Assertion",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "AVG"."ST_AVG_UTL_Utilization",
    "AVG"."ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "MIN"."ST_MIN_UTL_Utilization",
    "MIN"."ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    public."ST_Stage" "ST"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_NAM_Positor", x."ST_NAM_ST_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_NAM_Assertion" <> '?' THEN r."ST_NAM_ChangedAt" END) OVER (
                PARTITION BY r."ST_NAM_Positor", r."ST_NAM_ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_NAM_Stage_Name"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_NAM_Assertion" = coalesce(assertion, x."ST_NAM_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."ST_NAM_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."ST_NAM_Positor", x."ST_NAM_ST_ID",
    x."ST_NAM_ChangedAt" DESC,
    x."ST_NAM_PositedAt" DESC,
    x."ST_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_LOC_Positor", x."ST_LOC_ST_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_LOC_Stage_Location"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_LOC_Assertion" = coalesce(assertion, x."ST_LOC_Assertion")
    ORDER BY
    x."ST_LOC_Positor", x."ST_LOC_ST_ID",
    x."ST_LOC_PositedAt" DESC,
    x."ST_LOC_Reliability" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
        k."UTL_Utilization" AS "ST_AVG_UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_AVG_Positor", x."ST_AVG_ST_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_AVG_Assertion" <> '?' THEN r."ST_AVG_ChangedAt" END) OVER (
                PARTITION BY r."ST_AVG_Positor", r."ST_AVG_ST_ID"
            ) AS "inEffect"
        FROM
            public."rST_AVG_Stage_Average"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_AVG_Assertion" = coalesce(assertion, x."ST_AVG_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."ST_AVG_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."ST_AVG_Positor", x."ST_AVG_ST_ID",
    x."ST_AVG_ChangedAt" DESC,
    x."ST_AVG_PositedAt" DESC,
    x."ST_AVG_Reliability" DESC
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."ST_AVG_UTL_ID"
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
        k."UTL_Utilization" AS "ST_MIN_UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_MIN_Positor", x."ST_MIN_ST_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rST_MIN_Stage_Minimum"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."ST_MIN_Assertion" = coalesce(assertion, x."ST_MIN_Assertion")
    ORDER BY
    x."ST_MIN_Positor", x."ST_MIN_ST_ID",
    x."ST_MIN_PositedAt" DESC,
    x."ST_MIN_Reliability" DESC
    ) y
    LEFT JOIN
        public."UTL_Utilization" k
    ON
        k."UTL_ID" = y."ST_MIN_UTL_ID"
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    public."_Positor" p,
    public."tST_Stage"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "ST"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_Stage" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "ST"."ST_NAM_ST_ID",
    "ST"."Metadata_ST_NAM",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Positor",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Assertion",
    "ST"."ST_NAM_Stage_Name",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Positor",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Assertion",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Positor",
    "ST"."ST_AVG_Reliability",
    "ST"."ST_AVG_Assertion",
    "ST"."ST_AVG_UTL_Utilization",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Positor",
    "ST"."ST_MIN_Reliability",
    "ST"."ST_MIN_Assertion",
    "ST"."ST_MIN_UTL_Utilization",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    public."_Positor" p,
    public."tST_Stage"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "ST"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_Stage" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    public."_Positor" p,
    public."tST_Stage"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "ST"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_Stage" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Positor" smallint,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Assertion" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Positor" smallint,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Assertion" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" geography,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Positor" smallint,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_Assertion" char(1),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Positor" smallint,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_Assertion" char(1),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Positor",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Assertion",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Positor",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Assertion",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Positor",
    "AVG"."ST_AVG_Reliability",
    "AVG"."ST_AVG_Assertion",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Positor",
    "MIN"."ST_MIN_Reliability",
    "MIN"."ST_MIN_Assertion",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    public."_Positor" p
JOIN
(
    SELECT DISTINCT
        "ST_NAM_Positor" AS positor,
        "ST_NAM_ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."ST_NAM_Stage_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_AVG_Positor" AS positor,
        "ST_AVG_ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        public."ST_AVG_Stage_Average"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor"
JOIN
    public."ST_Stage" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."ST_NAM_ChangedAt") OVER (
            PARTITION BY y."ST_NAM_Positor", y."ST_NAM_ST_ID"
            ORDER BY y."ST_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_NAM_Positor", r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt")
            r.*
        FROM
            public."rST_NAM_Stage_Name"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."ST_NAM_Assertion" <> '?'
        ORDER BY
    r."ST_NAM_Positor", r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt",
    CASE WHEN r."ST_NAM_Assertion" = '+' THEN 0 ELSE 1 END,
    r."ST_NAM_PositedAt" DESC,
    r."ST_NAM_Reliability" DESC
    ) y
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Positor" = timepoints.positor
AND
    "NAM"."ST_NAM_Assertion" = '+'
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_LOC_Positor", r."ST_LOC_ST_ID")
        r.*
    FROM
        public."rST_LOC_Stage_Location"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."ST_LOC_Assertion" = '+'
    ORDER BY
    r."ST_LOC_Positor", r."ST_LOC_ST_ID",
    r."ST_LOC_PositedAt" DESC,
    r."ST_LOC_Reliability" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Positor" = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."ST_AVG_ChangedAt") OVER (
            PARTITION BY y."ST_AVG_Positor", y."ST_AVG_ST_ID"
            ORDER BY y."ST_AVG_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_AVG_Positor", r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt")
            r.*
        FROM
            public."rST_AVG_Stage_Average"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."ST_AVG_Assertion" <> '?'
        ORDER BY
    r."ST_AVG_Positor", r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt",
    CASE WHEN r."ST_AVG_Assertion" = '+' THEN 0 ELSE 1 END,
    r."ST_AVG_PositedAt" DESC,
    r."ST_AVG_Reliability" DESC
    ) y
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Positor" = timepoints.positor
AND
    "AVG"."ST_AVG_Assertion" = '+'
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_MIN_Positor", r."ST_MIN_ST_ID")
        r.*
    FROM
        public."rST_MIN_Stage_Minimum"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."ST_MIN_Assertion" = '+'
    ORDER BY
    r."ST_MIN_Positor", r."ST_MIN_ST_ID",
    r."ST_MIN_PositedAt" DESC,
    r."ST_MIN_Reliability" DESC
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Positor" = timepoints.positor
LEFT JOIN
    public."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_Actor" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "AC_ID" integer,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" integer,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" integer,
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1),
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" integer,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Positor",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Assertion",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "GEN"."AC_GEN_GEN_Gender",
    "GEN"."AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Positor",
    "PLV"."AC_PLV_Reliability",
    "PLV"."AC_PLV_Assertion",
    "PLV"."AC_PLV_PLV_Checksum",
    "PLV"."AC_PLV_PLV_ProfessionalLevel",
    "PLV"."AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."AC_Actor" "AC"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_NAM_Positor", x."AC_NAM_AC_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_NAM_Assertion" <> '?' THEN r."AC_NAM_ChangedAt" END) OVER (
                PARTITION BY r."AC_NAM_Positor", r."AC_NAM_AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_NAM_Actor_Name"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."AC_NAM_Assertion" = coalesce(assertion, x."AC_NAM_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."AC_NAM_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."AC_NAM_Positor", x."AC_NAM_AC_ID",
    x."AC_NAM_ChangedAt" DESC,
    x."AC_NAM_PositedAt" DESC,
    x."AC_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
        k."GEN_Gender" AS "AC_GEN_GEN_Gender"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_GEN_Positor", x."AC_GEN_AC_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_GEN_Actor_Gender"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."AC_GEN_Assertion" = coalesce(assertion, x."AC_GEN_Assertion")
    ORDER BY
    x."AC_GEN_Positor", x."AC_GEN_AC_ID",
    x."AC_GEN_PositedAt" DESC,
    x."AC_GEN_Reliability" DESC
    ) y
    LEFT JOIN
        public."GEN_Gender" k
    ON
        k."GEN_ID" = y."AC_GEN_GEN_ID"
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Positor" = p."Positor"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
        k."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
        k."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_PLV_Positor", x."AC_PLV_AC_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_PLV_Assertion" <> '?' THEN r."AC_PLV_ChangedAt" END) OVER (
                PARTITION BY r."AC_PLV_Positor", r."AC_PLV_AC_ID"
            ) AS "inEffect"
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."AC_PLV_Assertion" = coalesce(assertion, x."AC_PLV_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."AC_PLV_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."AC_PLV_Positor", x."AC_PLV_AC_ID",
    x."AC_PLV_ChangedAt" DESC,
    x."AC_PLV_PositedAt" DESC,
    x."AC_PLV_Reliability" DESC
    ) y
    LEFT JOIN
        public."PLV_ProfessionalLevel" k
    ON
        k."PLV_ID" = y."AC_PLV_PLV_ID"
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    public."_Positor" p,
    public."tAC_Actor"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "AC"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_Actor" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "AC_ID" integer,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" integer,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" integer,
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1),
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" integer,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "AC"."AC_NAM_AC_ID",
    "AC"."Metadata_AC_NAM",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Positor",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Assertion",
    "AC"."AC_NAM_Actor_Name",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Positor",
    "AC"."AC_GEN_Reliability",
    "AC"."AC_GEN_Assertion",
    "AC"."AC_GEN_GEN_Gender",
    "AC"."AC_GEN_Metadata_GEN",
    "AC"."AC_GEN_GEN_ID",
    "AC"."AC_PLV_AC_ID",
    "AC"."Metadata_AC_PLV",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Positor",
    "AC"."AC_PLV_Reliability",
    "AC"."AC_PLV_Assertion",
    "AC"."AC_PLV_PLV_Checksum",
    "AC"."AC_PLV_PLV_ProfessionalLevel",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    public."_Positor" p,
    public."tAC_Actor"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "AC"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_Actor" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    public."_Positor" p,
    public."tAC_Actor"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "AC"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_Actor" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "AC_ID" integer,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" integer,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Positor" smallint,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Assertion" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" integer,
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Positor" smallint,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_Assertion" char(1),
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" integer,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Positor" smallint,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_Assertion" char(1),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Positor",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Assertion",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Positor",
    "GEN"."AC_GEN_Reliability",
    "GEN"."AC_GEN_Assertion",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Positor",
    "PLV"."AC_PLV_Reliability",
    "PLV"."AC_PLV_Assertion",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    public."_Positor" p
JOIN
(
    SELECT DISTINCT
        "AC_NAM_Positor" AS positor,
        "AC_NAM_AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        public."AC_NAM_Actor_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_PLV_Positor" AS positor,
        "AC_PLV_AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        public."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor"
JOIN
    public."AC_Actor" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."AC_NAM_ChangedAt") OVER (
            PARTITION BY y."AC_NAM_Positor", y."AC_NAM_AC_ID"
            ORDER BY y."AC_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_NAM_Positor", r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt")
            r.*
        FROM
            public."rAC_NAM_Actor_Name"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_NAM_Assertion" <> '?'
        ORDER BY
    r."AC_NAM_Positor", r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt",
    CASE WHEN r."AC_NAM_Assertion" = '+' THEN 0 ELSE 1 END,
    r."AC_NAM_PositedAt" DESC,
    r."AC_NAM_Reliability" DESC
    ) y
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Positor" = timepoints.positor
AND
    "NAM"."AC_NAM_Assertion" = '+'
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."AC_GEN_Positor", r."AC_GEN_AC_ID")
        r.*
    FROM
        public."rAC_GEN_Actor_Gender"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."AC_GEN_Assertion" = '+'
    ORDER BY
    r."AC_GEN_Positor", r."AC_GEN_AC_ID",
    r."AC_GEN_PositedAt" DESC,
    r."AC_GEN_Reliability" DESC
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Positor" = timepoints.positor
LEFT JOIN
    public."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."AC_PLV_ChangedAt") OVER (
            PARTITION BY y."AC_PLV_Positor", y."AC_PLV_AC_ID"
            ORDER BY y."AC_PLV_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_PLV_Positor", r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt")
            r.*
        FROM
            public."rAC_PLV_Actor_ProfessionalLevel"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_PLV_Assertion" <> '?'
        ORDER BY
    r."AC_PLV_Positor", r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt",
    CASE WHEN r."AC_PLV_Assertion" = '+' THEN 0 ELSE 1 END,
    r."AC_PLV_PositedAt" DESC,
    r."AC_PLV_Reliability" DESC
    ) y
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Positor" = timepoints.positor
AND
    "PLV"."AC_PLV_Assertion" = '+'
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tPR_Program" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "PR_ID" integer,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" integer,
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" integer,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."PR_Program" "PR"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."PR_NAM_Positor", x."PR_NAM_PR_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_NAM_Program_Name"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."PR_NAM_Assertion" = coalesce(assertion, x."PR_NAM_Assertion")
    ORDER BY
    x."PR_NAM_Positor", x."PR_NAM_PR_ID",
    x."PR_NAM_PositedAt" DESC,
    x."PR_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."PR_LEN_Positor", x."PR_LEN_PR_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_LEN_Assertion" <> '?' THEN r."PR_LEN_ChangedAt" END) OVER (
                PARTITION BY r."PR_LEN_Positor", r."PR_LEN_PR_ID"
            ) AS "inEffect"
        FROM
            public."rPR_LEN_Program_Length"(
                null::smallint,
                changingTimepoint::date,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."PR_LEN_Assertion" = coalesce(assertion, x."PR_LEN_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."PR_LEN_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."PR_LEN_Positor", x."PR_LEN_PR_ID",
    x."PR_LEN_ChangedAt" DESC,
    x."PR_LEN_PositedAt" DESC,
    x."PR_LEN_Reliability" DESC
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    public."_Positor" p,
    public."tPR_Program"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "PR"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_Program" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "PR_ID" integer,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" integer,
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" integer,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "PR"."PR_NAM_PR_ID",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Positor",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Assertion",
    "PR"."PR_NAM_Program_Name",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Positor",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Assertion",
    "PR"."PR_LEN_Program_Length"
FROM
    public."_Positor" p,
    public."tPR_Program"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "PR"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_Program" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    public."_Positor" p,
    public."tPR_Program"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "PR"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dPR_Program" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "PR_ID" integer,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" integer,
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Positor" smallint,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Assertion" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" integer,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Positor" smallint,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Assertion" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Positor",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Assertion",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Positor",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Assertion",
    "LEN"."PR_LEN_Program_Length"
FROM
    public."_Positor" p
JOIN
(
    SELECT DISTINCT
        "PR_LEN_Positor" AS positor,
        "PR_LEN_PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        public."PR_LEN_Program_Length"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Positor"
JOIN
    public."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."PR_NAM_Positor", r."PR_NAM_PR_ID")
        r.*
    FROM
        public."rPR_NAM_Program_Name"(
            null::smallint,
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."PR_NAM_Assertion" = '+'
    ORDER BY
    r."PR_NAM_Positor", r."PR_NAM_PR_ID",
    r."PR_NAM_PositedAt" DESC,
    r."PR_NAM_Reliability" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Positor" = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."PR_LEN_ChangedAt") OVER (
            PARTITION BY y."PR_LEN_Positor", y."PR_LEN_PR_ID"
            ORDER BY y."PR_LEN_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."PR_LEN_Positor", r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt")
            r.*
        FROM
            public."rPR_LEN_Program_Length"(
                null::smallint,
                '9999-12-31'::date,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."PR_LEN_Assertion" <> '?'
        ORDER BY
    r."PR_LEN_Positor", r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt",
    CASE WHEN r."PR_LEN_Assertion" = '+' THEN 0 ELSE 1 END,
    r."PR_LEN_PositedAt" DESC,
    r."PR_LEN_Reliability" DESC
    ) y
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Positor" = timepoints.positor
AND
    "LEN"."PR_LEN_Assertion" = '+'
AND
    "LEN"."PR_LEN_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LEN"."until" IS NULL
OR
    "LEN"."until" > timepoints.inspectedTimepoint::date
)
$$ LANGUAGE sql STABLE;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- CRT nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tEV_Event" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "EV_ID" integer,
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" integer,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" integer,
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Positor" smallint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" char(1),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" integer,
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Positor" smallint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" char(1),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" integer,
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Positor" smallint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" char(1),
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Positor",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Assertion",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Positor",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Assertion",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Positor",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Assertion",
    "REV"."EV_REV_Event_Revenue"
FROM
    public."EV_Event" "EV"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    public."_Positor" p
LEFT JOIN
    public."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_DAT_Positor", x."EV_DAT_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_DAT_Event_Date"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_DAT_Assertion" = coalesce(assertion, x."EV_DAT_Assertion")
    ORDER BY
    x."EV_DAT_Positor", x."EV_DAT_EV_ID",
    x."EV_DAT_PositedAt" DESC,
    x."EV_DAT_Reliability" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_AUD_Positor", x."EV_AUD_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_AUD_Event_Audience"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_AUD_Assertion" = coalesce(assertion, x."EV_AUD_Assertion")
    ORDER BY
    x."EV_AUD_Positor", x."EV_AUD_EV_ID",
    x."EV_AUD_PositedAt" DESC,
    x."EV_AUD_Reliability" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Positor" = p."Positor"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_REV_Positor", x."EV_REV_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_REV_Event_Revenue"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) x
    WHERE
        x."EV_REV_Assertion" = coalesce(assertion, x."EV_REV_Assertion")
    ORDER BY
    x."EV_REV_Positor", x."EV_REV_EV_ID",
    x."EV_REV_PositedAt" DESC,
    x."EV_REV_Reliability" DESC
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Positor" = p."Positor"
WHERE
    p."Positor" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV".*
FROM
    public."_Positor" p,
    public."tEV_Event"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "EV"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "EV_ID" integer,
    "Metadata_EV" integer,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" integer,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" integer,
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Positor" smallint,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Assertion" char(1),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" integer,
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Positor" smallint,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Assertion" char(1),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" integer,
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Positor" smallint,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Assertion" char(1),
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "EV"."of_ETY_EventType",
    "EV"."of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "EV"."EV_DAT_EV_ID",
    "EV"."Metadata_EV_DAT",
    "EV"."EV_DAT_ID",
    "EV"."EV_DAT_PositedAt",
    "EV"."EV_DAT_Positor",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Assertion",
    "EV"."EV_DAT_Event_Date",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Positor",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Assertion",
    "EV"."EV_AUD_Event_Audience",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Positor",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Assertion",
    "EV"."EV_REV_Event_Revenue"
FROM
    public."_Positor" p,
    public."tEV_Event"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "EV"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    "EV".*
FROM
    public."_Positor" p,
    public."tEV_Event"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) "EV"
;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE SEQUENCE IF NOT EXISTS public."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_partner_AC_with_ONG_currently_Posit" (
    "AC_partner_AC_with_ONG_currently_ID" integer default nextval('public."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ"') not null, 
    "AC_ID_partner" integer not null, 
    "AC_ID_with" integer not null, 
    "ONG_ID_currently" smallint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp not null,
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_with" foreign key (
        "AC_ID_with"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references public."ONG_Ongoing"("ONG_ID"),
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "AC_partner_AC_with_ONG_currently_Posit_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "pkAC_partner_AC_with_ONG_currently_Posit" primary key (
        "AC_partner_AC_with_ONG_currently_ID"
    ),
    constraint "uqAC_partner_AC_with_ONG_currently" unique (
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently"
    )
);
CREATE TABLE IF NOT EXISTS public."AC_partner_AC_with_ONG_currently_Annex" (
    "AC_partner_AC_with_ONG_currently_ID" integer not null,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp not null,
    "AC_partner_AC_with_ONG_currently_Positor" smallint not null,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2) not null,
    "AC_partner_AC_with_ONG_currently_Assertion" char(1) generated always as (
        case
            when "AC_partner_AC_with_ONG_currently_Reliability" > 0 then '+'
            when "AC_partner_AC_with_ONG_currently_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_partner_AC_with_ONG_currently" integer not null,
    constraint "fkAC_partner_AC_with_ONG_currently_Annex" foreign key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) references public."AC_partner_AC_with_ONG_currently_Posit"("AC_partner_AC_with_ONG_currently_ID"),
    constraint "pkAC_partner_AC_with_ONG_currently_Annex" primary key (
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_Positor",
        "AC_partner_AC_with_ONG_currently_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."AC_subset_PN_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_subset_PN_of_Posit" (
    "AC_subset_PN_of_ID" integer default nextval('public."AC_subset_PN_of_Posit_ID_SEQ"') not null, 
    "AC_ID_subset" integer not null, 
    "PN_ID_of" integer not null, 
    constraint "AC_subset_PN_of_Posit_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_subset_PN_of_Posit_fkPN_of" foreign key (
        "PN_ID_of"
    ) references public."PN_Person"("PN_ID"), 
    constraint "AC_subset_PN_of_Posit_uqAC_subset" unique (
        "AC_ID_subset"
    ),
    constraint "AC_subset_PN_of_Posit_uqPN_of" unique (
        "PN_ID_of"
    ),
    constraint "pkAC_subset_PN_of_Posit" primary key (
        "AC_subset_PN_of_ID"
    ),
    constraint "uqAC_subset_PN_of" unique (
        "AC_ID_subset",
        "PN_ID_of"
    )
);
CREATE TABLE IF NOT EXISTS public."AC_subset_PN_of_Annex" (
    "AC_subset_PN_of_ID" integer not null,
    "AC_subset_PN_of_PositedAt" timestamp not null,
    "AC_subset_PN_of_Positor" smallint not null,
    "AC_subset_PN_of_Reliability" decimal(5,2) not null,
    "AC_subset_PN_of_Assertion" char(1) generated always as (
        case
            when "AC_subset_PN_of_Reliability" > 0 then '+'
            when "AC_subset_PN_of_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_subset_PN_of" integer not null,
    constraint "fkAC_subset_PN_of_Annex" foreign key (
        "AC_subset_PN_of_ID"
    ) references public."AC_subset_PN_of_Posit"("AC_subset_PN_of_ID"),
    constraint "pkAC_subset_PN_of_Annex" primary key (
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_Positor",
        "AC_subset_PN_of_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."EV_in_AC_wasCast_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_in_AC_wasCast_Posit" (
    "EV_in_AC_wasCast_ID" integer default nextval('public."EV_in_AC_wasCast_Posit_ID_SEQ"') not null, 
    "EV_ID_in" integer not null, 
    "AC_ID_wasCast" integer not null, 
    constraint "EV_in_AC_wasCast_Posit_fkEV_in" foreign key (
        "EV_ID_in"
    ) references public."EV_Event"("EV_ID"), 
    constraint "EV_in_AC_wasCast_Posit_fkAC_wasCast" foreign key (
        "AC_ID_wasCast"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "pkEV_in_AC_wasCast_Posit" primary key (
        "EV_in_AC_wasCast_ID"
    ),
    constraint "uqEV_in_AC_wasCast" unique (
        "EV_ID_in",
        "AC_ID_wasCast"
    )
);
CREATE TABLE IF NOT EXISTS public."EV_in_AC_wasCast_Annex" (
    "EV_in_AC_wasCast_ID" integer not null,
    "EV_in_AC_wasCast_PositedAt" timestamp not null,
    "EV_in_AC_wasCast_Positor" smallint not null,
    "EV_in_AC_wasCast_Reliability" decimal(5,2) not null,
    "EV_in_AC_wasCast_Assertion" char(1) generated always as (
        case
            when "EV_in_AC_wasCast_Reliability" > 0 then '+'
            when "EV_in_AC_wasCast_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_in_AC_wasCast" integer not null,
    constraint "fkEV_in_AC_wasCast_Annex" foreign key (
        "EV_in_AC_wasCast_ID"
    ) references public."EV_in_AC_wasCast_Posit"("EV_in_AC_wasCast_ID"),
    constraint "pkEV_in_AC_wasCast_Annex" primary key (
        "EV_in_AC_wasCast_ID",
        "EV_in_AC_wasCast_Positor",
        "EV_in_AC_wasCast_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."AC_part_PR_in_RAT_got_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_part_PR_in_RAT_got_Posit" (
    "AC_part_PR_in_RAT_got_ID" integer default nextval('public."AC_part_PR_in_RAT_got_Posit_ID_SEQ"') not null, 
    "AC_ID_part" integer not null, 
    "PR_ID_in" integer not null, 
    "RAT_ID_got" smallint not null,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp not null,
    constraint "AC_part_PR_in_RAT_got_Posit_fkAC_part" foreign key (
        "AC_ID_part"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_part_PR_in_RAT_got_Posit_fkPR_in" foreign key (
        "PR_ID_in"
    ) references public."PR_Program"("PR_ID"), 
    constraint "AC_part_PR_in_RAT_got_Posit_fkRAT_got" foreign key (
        "RAT_ID_got"
    ) references public."RAT_Rating"("RAT_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Posit" primary key (
        "AC_part_PR_in_RAT_got_ID"
    ),
    constraint "uqAC_part_PR_in_RAT_got" unique (
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "RAT_ID_got"
    )
);
CREATE TABLE IF NOT EXISTS public."AC_part_PR_in_RAT_got_Annex" (
    "AC_part_PR_in_RAT_got_ID" integer not null,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp not null,
    "AC_part_PR_in_RAT_got_Positor" smallint not null,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2) not null,
    "AC_part_PR_in_RAT_got_Assertion" char(1) generated always as (
        case
            when "AC_part_PR_in_RAT_got_Reliability" > 0 then '+'
            when "AC_part_PR_in_RAT_got_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_part_PR_in_RAT_got" integer not null,
    constraint "fkAC_part_PR_in_RAT_got_Annex" foreign key (
        "AC_part_PR_in_RAT_got_ID"
    ) references public."AC_part_PR_in_RAT_got_Posit"("AC_part_PR_in_RAT_got_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Annex" primary key (
        "AC_part_PR_in_RAT_got_ID",
        "AC_part_PR_in_RAT_got_Positor",
        "AC_part_PR_in_RAT_got_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."ST_at_PR_isPlaying_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."ST_at_PR_isPlaying_Posit" (
    "ST_at_PR_isPlaying_ID" integer default nextval('public."ST_at_PR_isPlaying_Posit_ID_SEQ"') not null, 
    "ST_ID_at" integer not null, 
    "PR_ID_isPlaying" integer not null, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp not null,
    constraint "ST_at_PR_isPlaying_Posit_fkST_at" foreign key (
        "ST_ID_at"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "ST_at_PR_isPlaying_Posit_fkPR_isPlaying" foreign key (
        "PR_ID_isPlaying"
    ) references public."PR_Program"("PR_ID"), 
    constraint "pkST_at_PR_isPlaying_Posit" primary key (
        "ST_at_PR_isPlaying_ID"
    ),
    constraint "uqST_at_PR_isPlaying" unique (
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt"
    )
);
CREATE TABLE IF NOT EXISTS public."ST_at_PR_isPlaying_Annex" (
    "ST_at_PR_isPlaying_ID" integer not null,
    "ST_at_PR_isPlaying_PositedAt" timestamp not null,
    "ST_at_PR_isPlaying_Positor" smallint not null,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2) not null,
    "ST_at_PR_isPlaying_Assertion" char(1) generated always as (
        case
            when "ST_at_PR_isPlaying_Reliability" > 0 then '+'
            when "ST_at_PR_isPlaying_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_at_PR_isPlaying" integer not null,
    constraint "fkST_at_PR_isPlaying_Annex" foreign key (
        "ST_at_PR_isPlaying_ID"
    ) references public."ST_at_PR_isPlaying_Posit"("ST_at_PR_isPlaying_ID"),
    constraint "pkST_at_PR_isPlaying_Annex" primary key (
        "ST_at_PR_isPlaying_ID",
        "ST_at_PR_isPlaying_Positor",
        "ST_at_PR_isPlaying_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."AC_parent_AC_child_PAT_having_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."AC_parent_AC_child_PAT_having_Posit" (
    "AC_parent_AC_child_PAT_having_ID" integer default nextval('public."AC_parent_AC_child_PAT_having_Posit_ID_SEQ"') not null, 
    "AC_ID_parent" integer not null, 
    "AC_ID_child" integer not null, 
    "PAT_ID_having" smallint not null,
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_parent" foreign key (
        "AC_ID_parent"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_child" foreign key (
        "AC_ID_child"
    ) references public."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkPAT_having" foreign key (
        "PAT_ID_having"
    ) references public."PAT_ParentalType"("PAT_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Posit" primary key (
        "AC_parent_AC_child_PAT_having_ID"
    ),
    constraint "uqAC_parent_AC_child_PAT_having" unique (
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    )
);
CREATE TABLE IF NOT EXISTS public."AC_parent_AC_child_PAT_having_Annex" (
    "AC_parent_AC_child_PAT_having_ID" integer not null,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp not null,
    "AC_parent_AC_child_PAT_having_Positor" smallint not null,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2) not null,
    "AC_parent_AC_child_PAT_having_Assertion" char(1) generated always as (
        case
            when "AC_parent_AC_child_PAT_having_Reliability" > 0 then '+'
            when "AC_parent_AC_child_PAT_having_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_parent_AC_child_PAT_having" integer not null,
    constraint "fkAC_parent_AC_child_PAT_having_Annex" foreign key (
        "AC_parent_AC_child_PAT_having_ID"
    ) references public."AC_parent_AC_child_PAT_having_Posit"("AC_parent_AC_child_PAT_having_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Annex" primary key (
        "AC_parent_AC_child_PAT_having_ID",
        "AC_parent_AC_child_PAT_having_Positor",
        "AC_parent_AC_child_PAT_having_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."PR_content_ST_location_EV_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."PR_content_ST_location_EV_of_Posit" (
    "PR_content_ST_location_EV_of_ID" integer default nextval('public."PR_content_ST_location_EV_of_Posit_ID_SEQ"') not null, 
    "PR_ID_content" integer not null, 
    "ST_ID_location" integer not null, 
    "EV_ID_of" integer not null, 
    constraint "PR_content_ST_location_EV_of_Posit_fkPR_content" foreign key (
        "PR_ID_content"
    ) references public."PR_Program"("PR_ID"), 
    constraint "PR_content_ST_location_EV_of_Posit_fkST_location" foreign key (
        "ST_ID_location"
    ) references public."ST_Stage"("ST_ID"), 
    constraint "PR_content_ST_location_EV_of_Posit_fkEV_of" foreign key (
        "EV_ID_of"
    ) references public."EV_Event"("EV_ID"), 
    constraint "pkPR_content_ST_location_EV_of_Posit" primary key (
        "PR_content_ST_location_EV_of_ID"
    ),
    constraint "uqPR_content_ST_location_EV_of" unique (
        "EV_ID_of",
        "PR_ID_content",
        "ST_ID_location"
    )
);
CREATE TABLE IF NOT EXISTS public."PR_content_ST_location_EV_of_Annex" (
    "PR_content_ST_location_EV_of_ID" integer not null,
    "PR_content_ST_location_EV_of_PositedAt" timestamp not null,
    "PR_content_ST_location_EV_of_Positor" smallint not null,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2) not null,
    "PR_content_ST_location_EV_of_Assertion" char(1) generated always as (
        case
            when "PR_content_ST_location_EV_of_Reliability" > 0 then '+'
            when "PR_content_ST_location_EV_of_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_PR_content_ST_location_EV_of" integer not null,
    constraint "fkPR_content_ST_location_EV_of_Annex" foreign key (
        "PR_content_ST_location_EV_of_ID"
    ) references public."PR_content_ST_location_EV_of_Posit"("PR_content_ST_location_EV_of_ID"),
    constraint "pkPR_content_ST_location_EV_of_Annex" primary key (
        "PR_content_ST_location_EV_of_ID",
        "PR_content_ST_location_EV_of_Positor",
        "PR_content_ST_location_EV_of_PositedAt"
    )
);
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public."AC_partner_AC_with_ONG_currently" AS
SELECT
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_Reliability",
    a."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    public."AC_partner_AC_with_ONG_currently_Annex" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
;
CREATE OR REPLACE VIEW public."AC_subset_PN_of" AS
SELECT
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Posit" p
JOIN
    public."AC_subset_PN_of_Annex" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
;
CREATE OR REPLACE VIEW public."EV_in_AC_wasCast" AS
SELECT
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_Reliability",
    a."EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Posit" p
JOIN
    public."EV_in_AC_wasCast_Annex" a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
;
CREATE OR REPLACE VIEW public."AC_part_PR_in_RAT_got" AS
SELECT
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_Reliability",
    a."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."AC_part_PR_in_RAT_got_Posit" p
JOIN
    public."AC_part_PR_in_RAT_got_Annex" a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
;
CREATE OR REPLACE VIEW public."ST_at_PR_isPlaying" AS
SELECT
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."ST_at_PR_isPlaying_Posit" p
JOIN
    public."ST_at_PR_isPlaying_Annex" a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
;
CREATE OR REPLACE VIEW public."AC_parent_AC_child_PAT_having" AS
SELECT
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_Reliability",
    a."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    public."AC_parent_AC_child_PAT_having_Annex" a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
;
CREATE OR REPLACE VIEW public."PR_content_ST_location_EV_of" AS
SELECT
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_Reliability",
    a."PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Posit" p
JOIN
    public."PR_content_ST_location_EV_of_Annex" a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null.
--
CREATE OR REPLACE FUNCTION public."rAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
FROM
    public."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_ID_partner",
    "AC_ID_with",
    "ONG_ID_currently",
    "AC_partner_AC_with_ONG_currently_ChangedAt"
FROM
    public."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_partner_AC_with_ONG_currently_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_partner_AC_with_ONG_currently_PositedAt",
    "AC_partner_AC_with_ONG_currently_Positor",
    "AC_partner_AC_with_ONG_currently_Reliability",
    "AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."AC_partner_AC_with_ONG_currently_Annex"
WHERE
    "AC_partner_AC_with_ONG_currently_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_Reliability",
    a."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."rAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint) p 
JOIN
    public."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = coalesce(positor, a."AC_partner_AC_with_ONG_currently_Positor")
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" integer, 
    "AC_ID_with" integer, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_Reliability",
    a."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."fAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint) p 
JOIN
    public."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Positor" = coalesce(positor, a."AC_partner_AC_with_ONG_currently_Positor")
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Positor",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_subset_PN_of_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_subset_PN_of",
    "AC_subset_PN_of_ID",
    "AC_subset_PN_of_PositedAt",
    "AC_subset_PN_of_Positor",
    "AC_subset_PN_of_Reliability",
    "AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Annex"
WHERE
    "AC_subset_PN_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_subset_PN_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_ID_subset" integer, 
    "PN_ID_of" integer, 
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Posit" p
JOIN
    public."rAC_subset_PN_of_Annex"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = coalesce(positor, a."AC_subset_PN_of_Positor")
ORDER BY
    p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_subset_PN_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_ID_subset" integer, 
    "PN_ID_of" integer, 
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_Reliability",
    a."AC_subset_PN_of_Assertion"
FROM
    public."AC_subset_PN_of_Posit" p
JOIN
    public."rAC_subset_PN_of_Annex"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Positor" = coalesce(positor, a."AC_subset_PN_of_Positor")
ORDER BY
    p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Positor",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_in_AC_wasCast_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_ID" integer,
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_EV_in_AC_wasCast",
    "EV_in_AC_wasCast_ID",
    "EV_in_AC_wasCast_PositedAt",
    "EV_in_AC_wasCast_Positor",
    "EV_in_AC_wasCast_Reliability",
    "EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Annex"
WHERE
    "EV_in_AC_wasCast_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_in_AC_wasCast" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_ID" integer,
    "EV_ID_in" integer, 
    "AC_ID_wasCast" integer, 
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor")
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_Reliability",
    a."EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Posit" p
JOIN
    public."rEV_in_AC_wasCast_Annex"(positingTimepoint) a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
AND
    a."EV_in_AC_wasCast_Positor" = coalesce(positor, a."EV_in_AC_wasCast_Positor")
ORDER BY
    p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fEV_in_AC_wasCast" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_in_AC_wasCast_ID" integer,
    "EV_ID_in" integer, 
    "AC_ID_wasCast" integer, 
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor")
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_Reliability",
    a."EV_in_AC_wasCast_Assertion"
FROM
    public."EV_in_AC_wasCast_Posit" p
JOIN
    public."rEV_in_AC_wasCast_Annex"(positingTimepoint) a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
AND
    a."EV_in_AC_wasCast_Positor" = coalesce(positor, a."EV_in_AC_wasCast_Positor")
ORDER BY
    p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Positor",
    a."EV_in_AC_wasCast_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_part_PR_in_RAT_got_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_part_PR_in_RAT_got_ID",
    "AC_ID_part",
    "PR_ID_in",
    "RAT_ID_got",
    "AC_part_PR_in_RAT_got_ChangedAt"
FROM
    public."AC_part_PR_in_RAT_got_Posit"
WHERE
    "AC_part_PR_in_RAT_got_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_part_PR_in_RAT_got_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_part_PR_in_RAT_got_ID",
    "AC_ID_part",
    "PR_ID_in",
    "RAT_ID_got",
    "AC_part_PR_in_RAT_got_ChangedAt"
FROM
    public."AC_part_PR_in_RAT_got_Posit"
WHERE
    "AC_part_PR_in_RAT_got_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_part_PR_in_RAT_got_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_part_PR_in_RAT_got",
    "AC_part_PR_in_RAT_got_ID",
    "AC_part_PR_in_RAT_got_PositedAt",
    "AC_part_PR_in_RAT_got_Positor",
    "AC_part_PR_in_RAT_got_Reliability",
    "AC_part_PR_in_RAT_got_Assertion"
FROM
    public."AC_part_PR_in_RAT_got_Annex"
WHERE
    "AC_part_PR_in_RAT_got_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor")
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_Reliability",
    a."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."rAC_part_PR_in_RAT_got_Posit"(changingTimepoint) p 
JOIN
    public."rAC_part_PR_in_RAT_got_Annex"(positingTimepoint) a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
AND
    a."AC_part_PR_in_RAT_got_Positor" = coalesce(positor, a."AC_part_PR_in_RAT_got_Positor")
ORDER BY
    p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_part_PR_in_RAT_got_ID" integer,
    "AC_ID_part" integer, 
    "PR_ID_in" integer, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor")
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_Reliability",
    a."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."fAC_part_PR_in_RAT_got_Posit"(changingTimepoint) p 
JOIN
    public."rAC_part_PR_in_RAT_got_Annex"(positingTimepoint) a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
AND
    a."AC_part_PR_in_RAT_got_Positor" = coalesce(positor, a."AC_part_PR_in_RAT_got_Positor")
ORDER BY
    p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Positor",
    a."AC_part_PR_in_RAT_got_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rST_at_PR_isPlaying_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_at_PR_isPlaying_ID",
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt"
FROM
    public."ST_at_PR_isPlaying_Posit"
WHERE
    "ST_at_PR_isPlaying_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fST_at_PR_isPlaying_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_at_PR_isPlaying_ID",
    "ST_ID_at",
    "PR_ID_isPlaying",
    "ST_at_PR_isPlaying_ChangedAt"
FROM
    public."ST_at_PR_isPlaying_Posit"
WHERE
    "ST_at_PR_isPlaying_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rST_at_PR_isPlaying_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ID" integer,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_ST_at_PR_isPlaying",
    "ST_at_PR_isPlaying_ID",
    "ST_at_PR_isPlaying_PositedAt",
    "ST_at_PR_isPlaying_Positor",
    "ST_at_PR_isPlaying_Reliability",
    "ST_at_PR_isPlaying_Assertion"
FROM
    public."ST_at_PR_isPlaying_Annex"
WHERE
    "ST_at_PR_isPlaying_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor")
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."rST_at_PR_isPlaying_Posit"(changingTimepoint) p 
JOIN
    public."rST_at_PR_isPlaying_Annex"(positingTimepoint) a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
AND
    a."ST_at_PR_isPlaying_Positor" = coalesce(positor, a."ST_at_PR_isPlaying_Positor")
ORDER BY
    p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_at_PR_isPlaying_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" integer, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor")
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_Reliability",
    a."ST_at_PR_isPlaying_Assertion"
FROM
    public."fST_at_PR_isPlaying_Posit"(changingTimepoint) p 
JOIN
    public."rST_at_PR_isPlaying_Annex"(positingTimepoint) a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
AND
    a."ST_at_PR_isPlaying_Positor" = coalesce(positor, a."ST_at_PR_isPlaying_Positor")
ORDER BY
    p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Positor",
    a."ST_at_PR_isPlaying_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_parent_AC_child_PAT_having_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_ID" integer,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_AC_parent_AC_child_PAT_having",
    "AC_parent_AC_child_PAT_having_ID",
    "AC_parent_AC_child_PAT_having_PositedAt",
    "AC_parent_AC_child_PAT_having_Positor",
    "AC_parent_AC_child_PAT_having_Reliability",
    "AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Annex"
WHERE
    "AC_parent_AC_child_PAT_having_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rAC_parent_AC_child_PAT_having" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_ID" integer,
    "AC_ID_parent" integer, 
    "AC_ID_child" integer, 
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor")
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_Reliability",
    a."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    public."rAC_parent_AC_child_PAT_having_Annex"(positingTimepoint) a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
AND
    a."AC_parent_AC_child_PAT_having_Positor" = coalesce(positor, a."AC_parent_AC_child_PAT_having_Positor")
ORDER BY
    p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fAC_parent_AC_child_PAT_having" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_parent_AC_child_PAT_having_ID" integer,
    "AC_ID_parent" integer, 
    "AC_ID_child" integer, 
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor")
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_Reliability",
    a."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    public."rAC_parent_AC_child_PAT_having_Annex"(positingTimepoint) a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
AND
    a."AC_parent_AC_child_PAT_having_Positor" = coalesce(positor, a."AC_parent_AC_child_PAT_having_Positor")
ORDER BY
    p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Positor",
    a."AC_parent_AC_child_PAT_having_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rPR_content_ST_location_EV_of_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ID" integer,
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT
    "Metadata_PR_content_ST_location_EV_of",
    "PR_content_ST_location_EV_of_ID",
    "PR_content_ST_location_EV_of_PositedAt",
    "PR_content_ST_location_EV_of_Positor",
    "PR_content_ST_location_EV_of_Reliability",
    "PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Annex"
WHERE
    "PR_content_ST_location_EV_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rPR_content_ST_location_EV_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ID" integer,
    "PR_ID_content" integer, 
    "ST_ID_location" integer, 
    "EV_ID_of" integer, 
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor")
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_Reliability",
    a."PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Posit" p
JOIN
    public."rPR_content_ST_location_EV_of_Annex"(positingTimepoint) a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
AND
    a."PR_content_ST_location_EV_of_Positor" = coalesce(positor, a."PR_content_ST_location_EV_of_Positor")
ORDER BY
    p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fPR_content_ST_location_EV_of" (
    positor smallint,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_content_ST_location_EV_of_ID" integer,
    "PR_ID_content" integer, 
    "ST_ID_location" integer, 
    "EV_ID_of" integer, 
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT DISTINCT ON (p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor")
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_Reliability",
    a."PR_content_ST_location_EV_of_Assertion"
FROM
    public."PR_content_ST_location_EV_of_Posit" p
JOIN
    public."rPR_content_ST_location_EV_of_Annex"(positingTimepoint) a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
AND
    a."PR_content_ST_location_EV_of_Positor" = coalesce(positor, a."PR_content_ST_location_EV_of_Positor")
ORDER BY
    p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Positor",
    a."PR_content_ST_location_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_partner"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Positor", s."AC_ID_with"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Reliability" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_partner_AC_with_ONG_currently_Assertion" <> '?' THEN r."AC_partner_AC_with_ONG_currently_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently"
            ) AS "inEffect"
        FROM
            public."rAC_partner_AC_with_ONG_currently"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Assertion" = coalesce(assertion, s."AC_partner_AC_with_ONG_currently_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
    )
) t
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Positor" = positor
AND
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_partner_AC_with_ONG_currently" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion"
FROM
    public."_Positor" p,
    public."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_partner_AC_with_ONG_currently" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_partner_AC_with_ONG_currently"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_ID_partner" integer,
    "AC_ID_with" integer,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Positor" smallint,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_partner_AC_with_ONG_currently_Assertion" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
-- A tie without identifiers is one to one: of the posits shown at the time, the latest for each of its anchors is kept, by a
-- window over the rows that are joined and the filter after it.
SELECT
    q."Positor",
    q.inspectedTimepoint,
    q."Metadata_AC_partner_AC_with_ONG_currently",
    q."AC_ID_partner",
    q."AC_ID_with",
    q."currently_ONG_Ongoing",
    q."currently_Metadata_ONG",
    q."ONG_ID_currently",
    q."AC_partner_AC_with_ONG_currently_ChangedAt",
    q."AC_partner_AC_with_ONG_currently_PositedAt",
    q."AC_partner_AC_with_ONG_currently_Positor",
    q."AC_partner_AC_with_ONG_currently_Reliability",
    q."AC_partner_AC_with_ONG_currently_Assertion"
FROM (
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Positor",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_partner_AC_with_ONG_currently_Assertion",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."AC_ID_partner"
        ORDER BY
            t."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_Reliability" DESC,
            t."AC_partner_AC_with_ONG_currently_ID" DESC
    ) AS "latestAC_ID_partner",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."AC_ID_with"
        ORDER BY
            t."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_Reliability" DESC,
            t."AC_partner_AC_with_ONG_currently_ID" DESC
    ) AS "latestAC_ID_with"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_partner_AC_with_ONG_currently_Positor" AS positor,
        "AC_partner_AC_with_ONG_currently_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        public."AC_partner_AC_with_ONG_currently"
    WHERE
        "AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (
            PARTITION BY
                y."AC_partner_AC_with_ONG_currently_Positor",
                y."AC_ID_partner",
                y."AC_ID_with",
                y."ONG_ID_currently"
            ORDER BY y."AC_partner_AC_with_ONG_currently_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently",
                    r."AC_partner_AC_with_ONG_currently_ChangedAt")
            r.*
        FROM
            public."rAC_partner_AC_with_ONG_currently"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_partner_AC_with_ONG_currently_Assertion" <> '?'
        ORDER BY
    r."AC_partner_AC_with_ONG_currently_Positor",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently",
                    r."AC_partner_AC_with_ONG_currently_ChangedAt",
    CASE WHEN r."AC_partner_AC_with_ONG_currently_Assertion" = '+' THEN 0 ELSE 1 END,
    r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
    r."AC_partner_AC_with_ONG_currently_Reliability" DESC,
    r."AC_partner_AC_with_ONG_currently_ID" DESC
    ) y
) t
ON
    t."AC_partner_AC_with_ONG_currently_Positor" = tp.positor
AND
    t."AC_partner_AC_with_ONG_currently_Assertion" = '+'
AND
    t."AC_partner_AC_with_ONG_currently_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
) q
WHERE
    q."latestAC_ID_partner" = 1
AND
    q."latestAC_ID_with" = 1
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_subset_PN_of" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_ID_subset" integer,
    "PN_ID_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."AC_ID_subset"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Positor", s."PN_ID_of"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Reliability" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_subset_PN_of"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."AC_subset_PN_of_Assertion" = coalesce(assertion, s."AC_subset_PN_of_Assertion")
) t
WHERE
    t."AC_subset_PN_of_Positor" = positor
AND
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_subset_PN_of" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_subset_PN_of"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_subset_PN_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_AC_subset_PN_of" integer,
    "AC_ID_subset" integer,
    "PN_ID_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Positor" smallint,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_subset_PN_of_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Positor",
    t."AC_subset_PN_of_Reliability",
    t."AC_subset_PN_of_Assertion"
FROM
    public."_Positor" p,
    public."tAC_subset_PN_of"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_subset_PN_of" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_subset_PN_of"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tEV_in_AC_wasCast" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_ID_in" integer,
    "AC_ID_wasCast" integer,
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_EV_in_AC_wasCast",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_wasCast_Positor",
                s."EV_ID_in",
                s."AC_ID_wasCast"
            ORDER BY
                s."EV_in_AC_wasCast_PositedAt" DESC,
                s."EV_in_AC_wasCast_Reliability" DESC,
                s."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rEV_in_AC_wasCast"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."EV_in_AC_wasCast_Assertion" = coalesce(assertion, s."EV_in_AC_wasCast_Assertion")
) t
WHERE
    t."EV_in_AC_wasCast_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lEV_in_AC_wasCast" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tEV_in_AC_wasCast"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pEV_in_AC_wasCast" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_EV_in_AC_wasCast" integer,
    "EV_ID_in" integer,
    "AC_ID_wasCast" integer,
    "EV_in_AC_wasCast_PositedAt" timestamp,
    "EV_in_AC_wasCast_Positor" smallint,
    "EV_in_AC_wasCast_Reliability" decimal(5,2),
    "EV_in_AC_wasCast_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Positor",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_in_AC_wasCast_Assertion"
FROM
    public."_Positor" p,
    public."tEV_in_AC_wasCast"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nEV_in_AC_wasCast" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tEV_in_AC_wasCast"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_part_PR_in_RAT_got_Positor",
                s."AC_ID_part",
                s."PR_ID_in"
            ORDER BY
                s."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                s."AC_part_PR_in_RAT_got_PositedAt" DESC,
                s."AC_part_PR_in_RAT_got_Reliability" DESC,
                s."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_part_PR_in_RAT_got_Assertion" <> '?' THEN r."AC_part_PR_in_RAT_got_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            public."rAC_part_PR_in_RAT_got"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."AC_part_PR_in_RAT_got_Assertion" = coalesce(assertion, s."AC_part_PR_in_RAT_got_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."AC_part_PR_in_RAT_got_ChangedAt" = s."inEffect"
    )
) t
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."AC_part_PR_in_RAT_got_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_part_PR_in_RAT_got" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_part_PR_in_RAT_got"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."_Positor" p,
    public."tAC_part_PR_in_RAT_got"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_part_PR_in_RAT_got" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_part_PR_in_RAT_got"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "Metadata_AC_part_PR_in_RAT_got" integer,
    "AC_ID_part" integer,
    "PR_ID_in" integer,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" integer,
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp,
    "AC_part_PR_in_RAT_got_Positor" smallint,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2),
    "AC_part_PR_in_RAT_got_Assertion" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Positor",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_part_PR_in_RAT_got_Assertion"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "AC_part_PR_in_RAT_got_Positor" AS positor,
        "AC_part_PR_in_RAT_got_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        public."AC_part_PR_in_RAT_got"
    WHERE
        "AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."AC_part_PR_in_RAT_got_ChangedAt") OVER (
            PARTITION BY
                y."AC_part_PR_in_RAT_got_Positor",
                y."AC_ID_part",
                y."PR_ID_in"
            ORDER BY y."AC_part_PR_in_RAT_got_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in",
                    r."AC_part_PR_in_RAT_got_ChangedAt")
            r.*
        FROM
            public."rAC_part_PR_in_RAT_got"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_part_PR_in_RAT_got_Assertion" <> '?'
        ORDER BY
    r."AC_part_PR_in_RAT_got_Positor",
                    r."AC_ID_part",
                    r."PR_ID_in",
                    r."AC_part_PR_in_RAT_got_ChangedAt",
    CASE WHEN r."AC_part_PR_in_RAT_got_Assertion" = '+' THEN 0 ELSE 1 END,
    r."AC_part_PR_in_RAT_got_PositedAt" DESC,
    r."AC_part_PR_in_RAT_got_Reliability" DESC,
    r."AC_part_PR_in_RAT_got_ID" DESC
    ) y
) t
ON
    t."AC_part_PR_in_RAT_got_Positor" = tp.positor
AND
    t."AC_part_PR_in_RAT_got_Assertion" = '+'
AND
    t."AC_part_PR_in_RAT_got_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_isPlaying_Positor",
                s."ST_ID_at",
                s."PR_ID_isPlaying"
            ORDER BY
                s."ST_at_PR_isPlaying_ChangedAt" DESC,
                s."ST_at_PR_isPlaying_PositedAt" DESC,
                s."ST_at_PR_isPlaying_Reliability" DESC,
                s."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_isPlaying_Assertion" <> '?' THEN r."ST_at_PR_isPlaying_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying"
            ) AS "inEffect"
        FROM
            public."rST_at_PR_isPlaying"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."ST_at_PR_isPlaying_Assertion" = coalesce(assertion, s."ST_at_PR_isPlaying_Assertion")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."ST_at_PR_isPlaying_ChangedAt" = s."inEffect"
    )
) t
WHERE
    t."ST_at_PR_isPlaying_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lST_at_PR_isPlaying" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tST_at_PR_isPlaying"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pST_at_PR_isPlaying" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM
    public."_Positor" p,
    public."tST_at_PR_isPlaying"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nST_at_PR_isPlaying" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tST_at_PR_isPlaying"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dST_at_PR_isPlaying" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    inspectedTimepoint timestamp,
    "Metadata_ST_at_PR_isPlaying" integer,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" integer,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp,
    "ST_at_PR_isPlaying_Positor" smallint,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2),
    "ST_at_PR_isPlaying_Assertion" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Positor",
    tp.inspectedTimepoint,
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Positor",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_at_PR_isPlaying_Assertion"
FROM
    public."_Positor" p
JOIN (
    SELECT DISTINCT
        "ST_at_PR_isPlaying_Positor" AS positor,
        "ST_at_PR_isPlaying_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        public."ST_at_PR_isPlaying"
    WHERE
        "ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Positor"
JOIN (
    SELECT
        y.*,
        lead(y."ST_at_PR_isPlaying_ChangedAt") OVER (
            PARTITION BY
                y."ST_at_PR_isPlaying_Positor",
                y."ST_ID_at",
                y."PR_ID_isPlaying"
            ORDER BY y."ST_at_PR_isPlaying_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying",
                    r."ST_at_PR_isPlaying_ChangedAt")
            r.*
        FROM
            public."rST_at_PR_isPlaying"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."ST_at_PR_isPlaying_Assertion" <> '?'
        ORDER BY
    r."ST_at_PR_isPlaying_Positor",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying",
                    r."ST_at_PR_isPlaying_ChangedAt",
    CASE WHEN r."ST_at_PR_isPlaying_Assertion" = '+' THEN 0 ELSE 1 END,
    r."ST_at_PR_isPlaying_PositedAt" DESC,
    r."ST_at_PR_isPlaying_Reliability" DESC,
    r."ST_at_PR_isPlaying_ID" DESC
    ) y
) t
ON
    t."ST_at_PR_isPlaying_Positor" = tp.positor
AND
    t."ST_at_PR_isPlaying_Assertion" = '+'
AND
    t."ST_at_PR_isPlaying_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tAC_parent_AC_child_PAT_having" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_ID_parent" integer,
    "AC_ID_child" integer,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_parent_AC_child_PAT_having_Positor",
                s."AC_ID_parent",
                s."AC_ID_child",
                s."PAT_ID_having"
            ORDER BY
                s."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                s."AC_parent_AC_child_PAT_having_Reliability" DESC,
                s."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rAC_parent_AC_child_PAT_having"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."AC_parent_AC_child_PAT_having_Assertion" = coalesce(assertion, s."AC_parent_AC_child_PAT_having_Assertion")
) t
LEFT JOIN
    public."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."AC_parent_AC_child_PAT_having_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lAC_parent_AC_child_PAT_having" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_parent_AC_child_PAT_having"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_AC_parent_AC_child_PAT_having" integer,
    "AC_ID_parent" integer,
    "AC_ID_child" integer,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" integer,
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp,
    "AC_parent_AC_child_PAT_having_Positor" smallint,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2),
    "AC_parent_AC_child_PAT_having_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_ID_parent",
    t."AC_ID_child",
    t."having_PAT_ParentalType",
    t."having_Metadata_PAT",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Positor",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_parent_AC_child_PAT_having_Assertion"
FROM
    public."_Positor" p,
    public."tAC_parent_AC_child_PAT_having"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nAC_parent_AC_child_PAT_having" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tAC_parent_AC_child_PAT_having"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."tPR_content_ST_location_EV_of" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp,
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_ID_content" integer,
    "ST_ID_location" integer,
    "EV_ID_of" integer,
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."PR_content_ST_location_EV_of_Positor",
                s."EV_ID_of"
            ORDER BY
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Reliability" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            public."rPR_content_ST_location_EV_of"(
                null::smallint,
                positingTimepoint::timestamp
            ) r
    ) s
    WHERE
        s."PR_content_ST_location_EV_of_Assertion" = coalesce(assertion, s."PR_content_ST_location_EV_of_Assertion")
) t
WHERE
    t."PR_content_ST_location_EV_of_Positor" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."lPR_content_ST_location_EV_of" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tPR_content_ST_location_EV_of"(
        p."Positor",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Positor" smallint,
    "Reliability" decimal(5,2),
    "Metadata_PR_content_ST_location_EV_of" integer,
    "PR_ID_content" integer,
    "ST_ID_location" integer,
    "EV_ID_of" integer,
    "PR_content_ST_location_EV_of_PositedAt" timestamp,
    "PR_content_ST_location_EV_of_Positor" smallint,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2),
    "PR_content_ST_location_EV_of_Assertion" char(1)
)
AS
$$
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Positor",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_content_ST_location_EV_of_Assertion"
FROM
    public."_Positor" p,
    public."tPR_content_ST_location_EV_of"(
        p."Positor",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public."nPR_content_ST_location_EV_of" AS
SELECT
    p."Positor",
    cast(null as decimal(5,2)) AS "Reliability",
    t.*
FROM
    public."_Positor" p,
    public."tPR_content_ST_location_EV_of"(
        p."Positor",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp,
        '+'
    ) t
;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA public IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE public."PAT_ParentalType" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN public."PAT_ParentalType"."PAT_ParentalType" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE public."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON COLUMN public."GEN_Gender"."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON TABLE public."PLV_ProfessionalLevel" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN public."PLV_ProfessionalLevel"."PLV_ProfessionalLevel" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE public."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN public."UTL_Utilization"."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE public."ONG_Ongoing" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN public."ONG_Ongoing"."ONG_Ongoing" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE public."RAT_Rating" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN public."RAT_Rating"."RAT_Rating" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON TABLE public."ETY_EventType" IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public."ETY_EventType"."ETY_EventType" IS 'Type of event, such as premiere, regular performance, rehearsal or gala.';
COMMENT ON COLUMN public."EV_DAT_Event_Date_Posit"."EV_DAT_Event_Date" IS 'Date and time when the event took place.';
COMMENT ON COLUMN public."EV_AUD_Event_Audience_Posit"."EV_AUD_Event_Audience" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN public."EV_REV_Event_Revenue_Posit"."EV_REV_Event_Revenue" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN public."ST_NAM_Stage_Name_Posit"."ST_NAM_Stage_Name" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN public."ST_LOC_Stage_Location_Posit"."ST_LOC_Stage_Location" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN public."ST_AVG_Stage_Average_Posit"."ST_AVG_UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN public."ST_MIN_Stage_Minimum_Posit"."ST_MIN_UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN public."AC_NAM_Actor_Name_Posit"."AC_NAM_Actor_Name" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN public."AC_GEN_Actor_Gender_Posit"."AC_GEN_GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN public."AC_PLV_Actor_ProfessionalLevel_Posit"."AC_PLV_PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN public."PR_NAM_Program_Name_Posit"."PR_NAM_Program_Name" IS 'Name or title of the program.';
COMMENT ON COLUMN public."PR_LEN_Program_Length_Posit"."PR_LEN_Program_Length" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE public."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE public."ST_Stage" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE public."AC_Actor" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE public."PR_Program" IS 'A program, such as a play, show or concert, that can be played on stages.';
COMMENT ON TABLE public."EV_Event" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN public."EV_Event"."ST_ID_wasHeldAt" IS 'The stage at which the event was held.';
COMMENT ON COLUMN public."EV_Event"."PR_ID_wasPlayed" IS 'The program that was played at the event.';
COMMENT ON COLUMN public."EV_Event"."ETY_ID_of" IS 'The type of the event.';
COMMENT ON TABLE public."AC_partner_AC_with_ONG_currently_Posit" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN public."AC_partner_AC_with_ONG_currently_Posit"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON TABLE public."AC_subset_PN_of_Posit" IS 'Connects an actor to the person that the actor is. Every actor is a person, but not every person is an actor.';
COMMENT ON COLUMN public."AC_subset_PN_of_Posit"."AC_ID_subset" IS 'The actor.';
COMMENT ON COLUMN public."AC_subset_PN_of_Posit"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE public."EV_in_AC_wasCast_Posit" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN public."EV_in_AC_wasCast_Posit"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN public."EV_in_AC_wasCast_Posit"."AC_ID_wasCast" IS 'An actor cast in the event.';
COMMENT ON TABLE public."AC_part_PR_in_RAT_got_Posit" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got_Posit"."AC_ID_part" IS 'The actor having a part in the program.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got_Posit"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN public."AC_part_PR_in_RAT_got_Posit"."RAT_ID_got" IS 'The rating the actor got for the part.';
COMMENT ON TABLE public."ST_at_PR_isPlaying_Posit" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN public."ST_at_PR_isPlaying_Posit"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN public."ST_at_PR_isPlaying_Posit"."PR_ID_isPlaying" IS 'The program playing at the stage.';
COMMENT ON TABLE public."AC_parent_AC_child_PAT_having_Posit" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having_Posit"."AC_ID_parent" IS 'The actor who is the parent.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having_Posit"."AC_ID_child" IS 'The actor who is the child.';
COMMENT ON COLUMN public."AC_parent_AC_child_PAT_having_Posit"."PAT_ID_having" IS 'The type of parental relationship.';
COMMENT ON TABLE public."PR_content_ST_location_EV_of_Posit" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of_Posit"."PR_ID_content" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of_Posit"."ST_ID_location" IS 'The stage where the event was located.';
COMMENT ON COLUMN public."PR_content_ST_location_EV_of_Posit"."EV_ID_of" IS 'The event.';
