-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS knots;
CREATE SCHEMA IF NOT EXISTS anchors;
CREATE SCHEMA IF NOT EXISTS nexuses;
CREATE SCHEMA IF NOT EXISTS attributes;
CREATE SCHEMA IF NOT EXISTS ties;
-- POSITOR METADATA ---------------------------------------------------------------------------------------------------
--
-- Sets up a table containing the list of available positors. Since at least one positor
-- must be available the table is set up with a default positor with identity 0.
--
-- Positor table ------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw."_Who" (
    "Who" smallint not null,
    constraint "pk_Who" primary key (
        "Who"
    )
);
INSERT INTO dw."_Who" (
    "Who"
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
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType" (
    "PAT_ID" smallint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" bigint not null,
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
CREATE TABLE IF NOT EXISTS knots."GEN_Gender" (
    "GEN_ID" smallint not null,
    "GEN_Gender" varchar(42) not null,
    "GEN_Checksum" bytea generated always as (decode(md5("GEN_Gender"::text), 'hex')) stored,
    "Metadata_GEN" bigint not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID" 
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- PLV_ProfessionalLevel table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel" (
    "PLV_ID" smallint not null,
    "PLV_ProfessionalLevel" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_ProfessionalLevel"::text), 'hex')) stored,
    "Metadata_PLV" bigint not null,
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
CREATE TABLE IF NOT EXISTS knots."UTL_Utilization" (
    "UTL_ID" smallint not null,
    "UTL_Utilization" smallint not null,
    "Metadata_UTL" bigint not null,
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
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing" (
    "ONG_ID" smallint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" bigint not null,
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
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Rating_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Rating" (
    "RAT_ID" smallint default nextval('knots."RAT_Rating_ID_SEQ"') not null, 
    "RAT_Rating" varchar(42) not null,
    "RAT_Checksum" bytea generated always as (decode(md5("RAT_Rating"::text), 'hex')) stored,
    "Metadata_RAT" bigint not null,
    constraint "pkRAT_Rating" primary key (
        "RAT_ID" 
    ),
    constraint "uqRAT_Rating" unique (
        "RAT_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-- ETY_EventType table
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType" (
    "ETY_ID" smallint not null,
    "ETY_EventType" varchar(42) not null,
    "ETY_Checksum" bytea generated always as (decode(md5("ETY_EventType"::text), 'hex')) stored,
    "Metadata_ETY" bigint not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID" 
    ),
    constraint "uqETY_EventType" unique (
        "ETY_Checksum" 
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
CREATE SEQUENCE IF NOT EXISTS anchors."PN_Person_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."PN_Person" (
    "PN_ID" bigint default nextval('anchors."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" bigint not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- ST_Stage table (with 4 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Stage" (
    "ST_ID" integer not null,
    "Metadata_ST" bigint not null,
    constraint "pkST_Stage" primary key (
        "ST_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- AC_Actor table (with 3 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Actor_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Actor" (
    "AC_ID" smallint default nextval('anchors."AC_Actor_ID_SEQ"') not null, 
    "Metadata_AC" bigint not null,
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-- PR_Program table (with 2 attributes)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Program" (
    "PR_ID" bigint not null,
    "Metadata_PR" bigint not null,
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
-- EV_Event table (with 6 attributes and 3 roles)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses."EV_Event" (
    "EV_ID" numeric(12,0) not null,
    "ST_ID_wasHeldAt" integer not null, 
    "PR_ID_wasPlayed" bigint not null, 
    "ETY_ID_of" smallint not null,
    constraint "EV_Event_fkST_wasHeldAt" foreign key (
        "ST_ID_wasHeldAt"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "EV_Event_fkPR_wasPlayed" foreign key (
        "PR_ID_wasPlayed"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "EV_Event_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_EventType"("ETY_ID"),
    "Metadata_EV" bigint not null, 
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
-- EV_DAT_Event_Date_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_DAT_Event_Date_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date_Fact" (
    "EV_DAT_ID" bigint default nextval('attributes."EV_DAT_Event_Date_Fact_ID_SEQ"') not null, 
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Event_Date" timestamp not null,
    constraint "fkEV_DAT_Event_Date_Fact" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date_Fact" primary key (
        "EV_DAT_ID"
    ),
    constraint "uqEV_DAT_Event_Date_Fact" unique (
        "EV_DAT_EV_ID",
        "EV_DAT_Event_Date"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Event_Date_Meta table (of EV_DAT_Event_Date_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date_Meta" (
    "EV_DAT_ID" bigint not null,
    "EV_DAT_PositedAt" timestamp(3) not null,
    "EV_DAT_Who" smallint not null,
    "EV_DAT_Confidence" decimal(7,3) not null,
    "EV_DAT_Stance" char(1) generated always as (
        case
            when "EV_DAT_Confidence" > 0.25 then '+'
            when "EV_DAT_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_DAT" bigint not null,
    constraint "fkEV_DAT_Event_Date_Meta" foreign key (
        "EV_DAT_ID"
    ) references attributes."EV_DAT_Event_Date_Fact"("EV_DAT_ID"),
    constraint "pkEV_DAT_Event_Date_Meta" primary key (
        "EV_DAT_ID",
        "EV_DAT_Who",
        "EV_DAT_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Fact" (
    "EV_AUD_ID" bigint default nextval('attributes."EV_AUD_Event_Audience_Fact_ID_SEQ"') not null, 
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_Event_Audience" integer not null,
    constraint "fkEV_AUD_Event_Audience_Fact" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience_Fact" primary key (
        "EV_AUD_ID"
    ),
    constraint "uqEV_AUD_Event_Audience_Fact" unique (
        "EV_AUD_EV_ID",
        "EV_AUD_Event_Audience"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Event_Audience_Meta table (of EV_AUD_Event_Audience_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Meta" (
    "EV_AUD_ID" bigint not null,
    "EV_AUD_PositedAt" timestamp(3) not null,
    "EV_AUD_Who" smallint not null,
    "EV_AUD_Confidence" decimal(7,3) not null,
    "EV_AUD_Stance" char(1) generated always as (
        case
            when "EV_AUD_Confidence" > 0.25 then '+'
            when "EV_AUD_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_AUD" bigint not null,
    constraint "fkEV_AUD_Event_Audience_Meta" foreign key (
        "EV_AUD_ID"
    ) references attributes."EV_AUD_Event_Audience_Fact"("EV_AUD_ID"),
    constraint "pkEV_AUD_Event_Audience_Meta" primary key (
        "EV_AUD_ID",
        "EV_AUD_Who",
        "EV_AUD_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Fact" (
    "EV_REV_ID" bigint default nextval('attributes."EV_REV_Event_Revenue_Fact_ID_SEQ"') not null, 
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    constraint "fkEV_REV_Event_Revenue_Fact" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue_Fact" primary key (
        "EV_REV_ID"
    ),
    constraint "uqEV_REV_Event_Revenue_Fact" unique (
        "EV_REV_EV_ID",
        "EV_REV_Event_Revenue"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Event_Revenue_Meta table (of EV_REV_Event_Revenue_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Meta" (
    "EV_REV_ID" bigint not null,
    "EV_REV_PositedAt" timestamp(3) not null,
    "EV_REV_Who" smallint not null,
    "EV_REV_Confidence" decimal(7,3) not null,
    "EV_REV_Stance" char(1) generated always as (
        case
            when "EV_REV_Confidence" > 0.25 then '+'
            when "EV_REV_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_REV" bigint not null,
    constraint "fkEV_REV_Event_Revenue_Meta" foreign key (
        "EV_REV_ID"
    ) references attributes."EV_REV_Event_Revenue_Fact"("EV_REV_ID"),
    constraint "pkEV_REV_Event_Revenue_Meta" primary key (
        "EV_REV_ID",
        "EV_REV_Who",
        "EV_REV_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Event_Status_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_STA_Event_Status_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status_Fact" (
    "EV_STA_ID" bigint default nextval('attributes."EV_STA_Event_Status_Fact_ID_SEQ"') not null, 
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_Event_Status" varchar(20) not null,
    "EV_STA_ChangedAt" timestamp not null,
    constraint "fkEV_STA_Event_Status_Fact" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_STA_Event_Status_Fact" primary key (
        "EV_STA_ID"
    ),
    constraint "uqEV_STA_Event_Status_Fact" unique (
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt",
        "EV_STA_Event_Status"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Event_Status_Meta table (of EV_STA_Event_Status_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status_Meta" (
    "EV_STA_ID" bigint not null,
    "EV_STA_PositedAt" timestamp(3) not null,
    "EV_STA_Who" smallint not null,
    "EV_STA_Confidence" decimal(7,3) not null,
    "EV_STA_Stance" char(1) generated always as (
        case
            when "EV_STA_Confidence" > 0.25 then '+'
            when "EV_STA_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_STA" bigint not null,
    constraint "fkEV_STA_Event_Status_Meta" foreign key (
        "EV_STA_ID"
    ) references attributes."EV_STA_Event_Status_Fact"("EV_STA_ID"),
    constraint "pkEV_STA_Event_Status_Meta" primary key (
        "EV_STA_ID",
        "EV_STA_Who",
        "EV_STA_PositedAt"
    )
);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Fact" (
    "EV_UTL_ID" bigint default nextval('attributes."EV_UTL_Event_Utilization_Fact_ID_SEQ"') not null, 
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" smallint not null,
    constraint "fk_A_EV_UTL_Event_Utilization_Fact" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "fk_K_EV_UTL_Event_Utilization_Fact" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkEV_UTL_Event_Utilization_Fact" primary key (
        "EV_UTL_ID"
    ),
    constraint "uqEV_UTL_Event_Utilization_Fact" unique (
        "EV_UTL_EV_ID",
        "EV_UTL_UTL_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Event_Utilization_Meta table (of EV_UTL_Event_Utilization_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Meta" (
    "EV_UTL_ID" bigint not null,
    "EV_UTL_PositedAt" timestamp(3) not null,
    "EV_UTL_Who" smallint not null,
    "EV_UTL_Confidence" decimal(7,3) not null,
    "EV_UTL_Stance" char(1) generated always as (
        case
            when "EV_UTL_Confidence" > 0.25 then '+'
            when "EV_UTL_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_UTL" bigint not null,
    constraint "fkEV_UTL_Event_Utilization_Meta" foreign key (
        "EV_UTL_ID"
    ) references attributes."EV_UTL_Event_Utilization_Fact"("EV_UTL_ID"),
    constraint "pkEV_UTL_Event_Utilization_Meta" primary key (
        "EV_UTL_ID",
        "EV_UTL_Who",
        "EV_UTL_PositedAt"
    )
);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Event_Level_Fact table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_LVL_Event_Level_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level_Fact" (
    "EV_LVL_ID" bigint default nextval('attributes."EV_LVL_Event_Level_Fact_ID_SEQ"') not null, 
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" smallint not null,
    "EV_LVL_ChangedAt" date not null,
    constraint "fk_A_EV_LVL_Event_Level_Fact" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "fk_K_EV_LVL_Event_Level_Fact" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkEV_LVL_Event_Level_Fact" primary key (
        "EV_LVL_ID"
    ),
    constraint "uqEV_LVL_Event_Level_Fact" unique (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt",
        "EV_LVL_PLV_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Event_Level_Meta table (of EV_LVL_Event_Level_Fact on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level_Meta" (
    "EV_LVL_ID" bigint not null,
    "EV_LVL_PositedAt" timestamp(3) not null,
    "EV_LVL_Who" smallint not null,
    "EV_LVL_Confidence" decimal(7,3) not null,
    "EV_LVL_Stance" char(1) generated always as (
        case
            when "EV_LVL_Confidence" > 0.25 then '+'
            when "EV_LVL_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_LVL" bigint not null,
    constraint "fkEV_LVL_Event_Level_Meta" foreign key (
        "EV_LVL_ID"
    ) references attributes."EV_LVL_Event_Level_Fact"("EV_LVL_ID"),
    constraint "pkEV_LVL_Event_Level_Meta" primary key (
        "EV_LVL_ID",
        "EV_LVL_Who",
        "EV_LVL_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Fact" (
    "ST_NAM_ID" bigint default nextval('attributes."ST_NAM_Stage_Name_Fact_ID_SEQ"') not null, 
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Stage_Name_Fact" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name_Fact" primary key (
        "ST_NAM_ID"
    ),
    constraint "uqST_NAM_Stage_Name_Fact" unique (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Stage_Name"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Stage_Name_Meta table (of ST_NAM_Stage_Name_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Meta" (
    "ST_NAM_ID" bigint not null,
    "ST_NAM_PositedAt" timestamp(3) not null,
    "ST_NAM_Who" smallint not null,
    "ST_NAM_Confidence" decimal(7,3) not null,
    "ST_NAM_Stance" char(1) generated always as (
        case
            when "ST_NAM_Confidence" > 0.25 then '+'
            when "ST_NAM_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_NAM" bigint not null,
    constraint "fkST_NAM_Stage_Name_Meta" foreign key (
        "ST_NAM_ID"
    ) references attributes."ST_NAM_Stage_Name_Fact"("ST_NAM_ID"),
    constraint "pkST_NAM_Stage_Name_Meta" primary key (
        "ST_NAM_ID",
        "ST_NAM_Who",
        "ST_NAM_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Fact" (
    "ST_LOC_ID" bigint default nextval('attributes."ST_LOC_Stage_Location_Fact_ID_SEQ"') not null, 
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Stage_Location" text not null,
    "ST_LOC_Checksum" bytea generated always as (decode(md5("ST_LOC_Stage_Location"::text), 'hex')) stored,
    constraint "fkST_LOC_Stage_Location_Fact" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location_Fact" primary key (
        "ST_LOC_ID"
    ),
    constraint "uqST_LOC_Stage_Location_Fact" unique (
        "ST_LOC_ST_ID",
        "ST_LOC_Checksum" 
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Stage_Location_Meta table (of ST_LOC_Stage_Location_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Meta" (
    "ST_LOC_ID" bigint not null,
    "ST_LOC_PositedAt" timestamp(3) not null,
    "ST_LOC_Who" smallint not null,
    "ST_LOC_Confidence" decimal(7,3) not null,
    "ST_LOC_Stance" char(1) generated always as (
        case
            when "ST_LOC_Confidence" > 0.25 then '+'
            when "ST_LOC_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_LOC" bigint not null,
    constraint "fkST_LOC_Stage_Location_Meta" foreign key (
        "ST_LOC_ID"
    ) references attributes."ST_LOC_Stage_Location_Fact"("ST_LOC_ID"),
    constraint "pkST_LOC_Stage_Location_Meta" primary key (
        "ST_LOC_ID",
        "ST_LOC_Who",
        "ST_LOC_PositedAt"
    )
);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Fact" (
    "ST_AVG_ID" bigint default nextval('attributes."ST_AVG_Stage_Average_Fact_ID_SEQ"') not null, 
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" smallint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Stage_Average_Fact" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average_Fact" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average_Fact" primary key (
        "ST_AVG_ID"
    ),
    constraint "uqST_AVG_Stage_Average_Fact" unique (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Stage_Average_Meta table (of ST_AVG_Stage_Average_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Meta" (
    "ST_AVG_ID" bigint not null,
    "ST_AVG_PositedAt" timestamp(3) not null,
    "ST_AVG_Who" smallint not null,
    "ST_AVG_Confidence" decimal(7,3) not null,
    "ST_AVG_Stance" char(1) generated always as (
        case
            when "ST_AVG_Confidence" > 0.25 then '+'
            when "ST_AVG_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_AVG" bigint not null,
    constraint "fkST_AVG_Stage_Average_Meta" foreign key (
        "ST_AVG_ID"
    ) references attributes."ST_AVG_Stage_Average_Fact"("ST_AVG_ID"),
    constraint "pkST_AVG_Stage_Average_Meta" primary key (
        "ST_AVG_ID",
        "ST_AVG_Who",
        "ST_AVG_PositedAt"
    )
);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Fact table (on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Fact" (
    "ST_MIN_ID" bigint default nextval('attributes."ST_MIN_Stage_Minimum_Fact_ID_SEQ"') not null, 
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" smallint not null,
    constraint "fk_A_ST_MIN_Stage_Minimum_Fact" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum_Fact" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum_Fact" primary key (
        "ST_MIN_ID"
    ),
    constraint "uqST_MIN_Stage_Minimum_Fact" unique (
        "ST_MIN_ST_ID",
        "ST_MIN_UTL_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Stage_Minimum_Meta table (of ST_MIN_Stage_Minimum_Fact on ST_Stage)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Meta" (
    "ST_MIN_ID" bigint not null,
    "ST_MIN_PositedAt" timestamp(3) not null,
    "ST_MIN_Who" smallint not null,
    "ST_MIN_Confidence" decimal(7,3) not null,
    "ST_MIN_Stance" char(1) generated always as (
        case
            when "ST_MIN_Confidence" > 0.25 then '+'
            when "ST_MIN_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_MIN" bigint not null,
    constraint "fkST_MIN_Stage_Minimum_Meta" foreign key (
        "ST_MIN_ID"
    ) references attributes."ST_MIN_Stage_Minimum_Fact"("ST_MIN_ID"),
    constraint "pkST_MIN_Stage_Minimum_Meta" primary key (
        "ST_MIN_ID",
        "ST_MIN_Who",
        "ST_MIN_PositedAt"
    )
);
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Fact" (
    "AC_NAM_ID" bigint default nextval('attributes."AC_NAM_Actor_Name_Fact_ID_SEQ"') not null, 
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Actor_Name_Fact" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name_Fact" primary key (
        "AC_NAM_ID"
    ),
    constraint "uqAC_NAM_Actor_Name_Fact" unique (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Actor_Name"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Actor_Name_Meta table (of AC_NAM_Actor_Name_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Meta" (
    "AC_NAM_ID" bigint not null,
    "AC_NAM_PositedAt" timestamp(3) not null,
    "AC_NAM_Who" smallint not null,
    "AC_NAM_Confidence" decimal(7,3) not null,
    "AC_NAM_Stance" char(1) generated always as (
        case
            when "AC_NAM_Confidence" > 0.25 then '+'
            when "AC_NAM_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_NAM" bigint not null,
    constraint "fkAC_NAM_Actor_Name_Meta" foreign key (
        "AC_NAM_ID"
    ) references attributes."AC_NAM_Actor_Name_Fact"("AC_NAM_ID"),
    constraint "pkAC_NAM_Actor_Name_Meta" primary key (
        "AC_NAM_ID",
        "AC_NAM_Who",
        "AC_NAM_PositedAt"
    )
);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Fact" (
    "AC_GEN_ID" bigint default nextval('attributes."AC_GEN_Actor_Gender_Fact_ID_SEQ"') not null, 
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" smallint not null,
    constraint "fk_A_AC_GEN_Actor_Gender_Fact" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender_Fact" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Fact" primary key (
        "AC_GEN_ID"
    ),
    constraint "uqAC_GEN_Actor_Gender_Fact" unique (
        "AC_GEN_AC_ID",
        "AC_GEN_GEN_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Actor_Gender_Meta table (of AC_GEN_Actor_Gender_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Meta" (
    "AC_GEN_ID" bigint not null,
    "AC_GEN_PositedAt" timestamp(3) not null,
    "AC_GEN_Who" smallint not null,
    "AC_GEN_Confidence" decimal(7,3) not null,
    "AC_GEN_Stance" char(1) generated always as (
        case
            when "AC_GEN_Confidence" > 0.25 then '+'
            when "AC_GEN_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_GEN" bigint not null,
    constraint "fkAC_GEN_Actor_Gender_Meta" foreign key (
        "AC_GEN_ID"
    ) references attributes."AC_GEN_Actor_Gender_Fact"("AC_GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Meta" primary key (
        "AC_GEN_ID",
        "AC_GEN_Who",
        "AC_GEN_PositedAt"
    )
);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Fact table (on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Fact" (
    "AC_PLV_ID" bigint default nextval('attributes."AC_PLV_Actor_ProfessionalLevel_Fact_ID_SEQ"') not null, 
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" smallint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel_Fact" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel_Fact" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Fact" primary key (
        "AC_PLV_ID"
    ),
    constraint "uqAC_PLV_Actor_ProfessionalLevel_Fact" unique (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PLV_ID"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Actor_ProfessionalLevel_Meta table (of AC_PLV_Actor_ProfessionalLevel_Fact on AC_Actor)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Meta" (
    "AC_PLV_ID" bigint not null,
    "AC_PLV_PositedAt" timestamp(3) not null,
    "AC_PLV_Who" smallint not null,
    "AC_PLV_Confidence" decimal(7,3) not null,
    "AC_PLV_Stance" char(1) generated always as (
        case
            when "AC_PLV_Confidence" > 0.25 then '+'
            when "AC_PLV_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_PLV" bigint not null,
    constraint "fkAC_PLV_Actor_ProfessionalLevel_Meta" foreign key (
        "AC_PLV_ID"
    ) references attributes."AC_PLV_Actor_ProfessionalLevel_Fact"("AC_PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Meta" primary key (
        "AC_PLV_ID",
        "AC_PLV_Who",
        "AC_PLV_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."PR_NAM_Program_Name_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name_Fact" (
    "PR_NAM_ID" bigint default nextval('attributes."PR_NAM_Program_Name_Fact_ID_SEQ"') not null, 
    "PR_NAM_PR_ID" bigint not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    constraint "fkPR_NAM_Program_Name_Fact" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name_Fact" primary key (
        "PR_NAM_ID"
    ),
    constraint "uqPR_NAM_Program_Name_Fact" unique (
        "PR_NAM_PR_ID",
        "PR_NAM_Program_Name"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Program_Name_Meta table (of PR_NAM_Program_Name_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name_Meta" (
    "PR_NAM_ID" bigint not null,
    "PR_NAM_PositedAt" timestamp(3) not null,
    "PR_NAM_Who" smallint not null,
    "PR_NAM_Confidence" decimal(7,3) not null,
    "PR_NAM_Stance" char(1) generated always as (
        case
            when "PR_NAM_Confidence" > 0.25 then '+'
            when "PR_NAM_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_PR_NAM" bigint not null,
    constraint "fkPR_NAM_Program_Name_Meta" foreign key (
        "PR_NAM_ID"
    ) references attributes."PR_NAM_Program_Name_Fact"("PR_NAM_ID"),
    constraint "pkPR_NAM_Program_Name_Meta" primary key (
        "PR_NAM_ID",
        "PR_NAM_Who",
        "PR_NAM_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Fact table (on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."PR_LEN_Program_Length_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length_Fact" (
    "PR_LEN_ID" bigint default nextval('attributes."PR_LEN_Program_Length_Fact_ID_SEQ"') not null, 
    "PR_LEN_PR_ID" bigint not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Program_Length_Fact" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length_Fact" primary key (
        "PR_LEN_ID"
    ),
    constraint "uqPR_LEN_Program_Length_Fact" unique (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Program_Length"
    )
);
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Program_Length_Meta table (of PR_LEN_Program_Length_Fact on PR_Program)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length_Meta" (
    "PR_LEN_ID" bigint not null,
    "PR_LEN_PositedAt" timestamp(3) not null,
    "PR_LEN_Who" smallint not null,
    "PR_LEN_Confidence" decimal(7,3) not null,
    "PR_LEN_Stance" char(1) generated always as (
        case
            when "PR_LEN_Confidence" > 0.25 then '+'
            when "PR_LEN_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_PR_LEN" bigint not null,
    constraint "fkPR_LEN_Program_Length_Meta" foreign key (
        "PR_LEN_ID"
    ) references attributes."PR_LEN_Program_Length_Fact"("PR_LEN_ID"),
    constraint "pkPR_LEN_Program_Length_Meta" primary key (
        "PR_LEN_ID",
        "PR_LEN_Who",
        "PR_LEN_PositedAt"
    )
);
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes."EV_DAT_Event_Date" AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Who",
    a."EV_DAT_Confidence",
    a."EV_DAT_Stance"
FROM
    attributes."EV_DAT_Event_Date_Fact" p
JOIN
    attributes."EV_DAT_Event_Date_Meta" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
;
CREATE OR REPLACE VIEW attributes."EV_AUD_Event_Audience" AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Who",
    a."EV_AUD_Confidence",
    a."EV_AUD_Stance"
FROM
    attributes."EV_AUD_Event_Audience_Fact" p
JOIN
    attributes."EV_AUD_Event_Audience_Meta" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
;
CREATE OR REPLACE VIEW attributes."EV_REV_Event_Revenue" AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue",
    a."EV_REV_PositedAt",
    a."EV_REV_Who",
    a."EV_REV_Confidence",
    a."EV_REV_Stance"
FROM
    attributes."EV_REV_Event_Revenue_Fact" p
JOIN
    attributes."EV_REV_Event_Revenue_Meta" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
;
CREATE OR REPLACE VIEW attributes."EV_STA_Event_Status" AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt",
    a."EV_STA_PositedAt",
    a."EV_STA_Who",
    a."EV_STA_Confidence",
    a."EV_STA_Stance"
FROM
    attributes."EV_STA_Event_Status_Fact" p
JOIN
    attributes."EV_STA_Event_Status_Meta" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
;
CREATE OR REPLACE VIEW attributes."EV_UTL_Event_Utilization" AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Who",
    a."EV_UTL_Confidence",
    a."EV_UTL_Stance"
FROM
    attributes."EV_UTL_Event_Utilization_Fact" p
JOIN
    attributes."EV_UTL_Event_Utilization_Meta" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
;
CREATE OR REPLACE VIEW attributes."EV_LVL_Event_Level" AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Who",
    a."EV_LVL_Confidence",
    a."EV_LVL_Stance"
FROM
    attributes."EV_LVL_Event_Level_Fact" p
JOIN
    attributes."EV_LVL_Event_Level_Meta" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
;
CREATE OR REPLACE VIEW attributes."ST_NAM_Stage_Name" AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Who",
    a."ST_NAM_Confidence",
    a."ST_NAM_Stance"
FROM
    attributes."ST_NAM_Stage_Name_Fact" p
JOIN
    attributes."ST_NAM_Stage_Name_Meta" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."ST_LOC_Stage_Location" AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Who",
    a."ST_LOC_Confidence",
    a."ST_LOC_Stance"
FROM
    attributes."ST_LOC_Stage_Location_Fact" p
JOIN
    attributes."ST_LOC_Stage_Location_Meta" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
;
CREATE OR REPLACE VIEW attributes."ST_AVG_Stage_Average" AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Who",
    a."ST_AVG_Confidence",
    a."ST_AVG_Stance"
FROM
    attributes."ST_AVG_Stage_Average_Fact" p
JOIN
    attributes."ST_AVG_Stage_Average_Meta" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
;
CREATE OR REPLACE VIEW attributes."ST_MIN_Stage_Minimum" AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Who",
    a."ST_MIN_Confidence",
    a."ST_MIN_Stance"
FROM
    attributes."ST_MIN_Stage_Minimum_Fact" p
JOIN
    attributes."ST_MIN_Stage_Minimum_Meta" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_NAM_Actor_Name" AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Who",
    a."AC_NAM_Confidence",
    a."AC_NAM_Stance"
FROM
    attributes."AC_NAM_Actor_Name_Fact" p
JOIN
    attributes."AC_NAM_Actor_Name_Meta" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."AC_GEN_Actor_Gender" AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Who",
    a."AC_GEN_Confidence",
    a."AC_GEN_Stance"
FROM
    attributes."AC_GEN_Actor_Gender_Fact" p
JOIN
    attributes."AC_GEN_Actor_Gender_Meta" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_PLV_Actor_ProfessionalLevel" AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Who",
    a."AC_PLV_Confidence",
    a."AC_PLV_Stance"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Fact" p
JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel_Meta" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
;
CREATE OR REPLACE VIEW attributes."PR_NAM_Program_Name" AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Who",
    a."PR_NAM_Confidence",
    a."PR_NAM_Stance"
FROM
    attributes."PR_NAM_Program_Name_Fact" p
JOIN
    attributes."PR_NAM_Program_Name_Meta" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."PR_LEN_Program_Length" AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Who",
    a."PR_LEN_Confidence",
    a."PR_LEN_Stance"
FROM
    attributes."PR_LEN_Program_Length_Fact" p
JOIN
    attributes."PR_LEN_Program_Length_Meta" a
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
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Event_Date_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_DAT",
    "EV_DAT_ID",
    "EV_DAT_PositedAt",
    "EV_DAT_Who",
    "EV_DAT_Confidence",
    "EV_DAT_Stance"
FROM
    attributes."EV_DAT_Event_Date_Meta"
WHERE
    "EV_DAT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Event_Date" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" char(1),
    "EV_DAT_EV_ID" numeric(12,0),
    "EV_DAT_Event_Date" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_DAT_ID", a."EV_DAT_Who")
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Who",
    a."EV_DAT_Confidence",
    a."EV_DAT_Stance",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date"
FROM
    attributes."EV_DAT_Event_Date_Fact" p
JOIN
    attributes."rEV_DAT_Event_Date_Meta"(positingTimepoint) a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
AND
    a."EV_DAT_Who" = coalesce(positor, a."EV_DAT_Who")
ORDER BY
    p."EV_DAT_ID", a."EV_DAT_Who",
    a."EV_DAT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Event_Audience_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_AUD",
    "EV_AUD_ID",
    "EV_AUD_PositedAt",
    "EV_AUD_Who",
    "EV_AUD_Confidence",
    "EV_AUD_Stance"
FROM
    attributes."EV_AUD_Event_Audience_Meta"
WHERE
    "EV_AUD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Event_Audience" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" char(1),
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_Event_Audience" integer
)
AS
$$
SELECT DISTINCT ON (p."EV_AUD_ID", a."EV_AUD_Who")
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Who",
    a."EV_AUD_Confidence",
    a."EV_AUD_Stance",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience"
FROM
    attributes."EV_AUD_Event_Audience_Fact" p
JOIN
    attributes."rEV_AUD_Event_Audience_Meta"(positingTimepoint) a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
AND
    a."EV_AUD_Who" = coalesce(positor, a."EV_AUD_Who")
ORDER BY
    p."EV_AUD_ID", a."EV_AUD_Who",
    a."EV_AUD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Event_Revenue_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_REV",
    "EV_REV_ID",
    "EV_REV_PositedAt",
    "EV_REV_Who",
    "EV_REV_Confidence",
    "EV_REV_Stance"
FROM
    attributes."EV_REV_Event_Revenue_Meta"
WHERE
    "EV_REV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Event_Revenue" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" char(1),
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_Event_Revenue" decimal(19,4)
)
AS
$$
SELECT DISTINCT ON (p."EV_REV_ID", a."EV_REV_Who")
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Who",
    a."EV_REV_Confidence",
    a."EV_REV_Stance",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue"
FROM
    attributes."EV_REV_Event_Revenue_Fact" p
JOIN
    attributes."rEV_REV_Event_Revenue_Meta"(positingTimepoint) a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
AND
    a."EV_REV_Who" = coalesce(positor, a."EV_REV_Who")
ORDER BY
    p."EV_REV_ID", a."EV_REV_Who",
    a."EV_REV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" bigint,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_STA_ID",
    "EV_STA_EV_ID",
    "EV_STA_Event_Status",
    "EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Event_Status_Fact"
WHERE
    "EV_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Event_Status_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" bigint,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_STA_ID",
    "EV_STA_EV_ID",
    "EV_STA_Event_Status",
    "EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Event_Status_Fact"
WHERE
    "EV_STA_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_STA",
    "EV_STA_ID",
    "EV_STA_PositedAt",
    "EV_STA_Who",
    "EV_STA_Confidence",
    "EV_STA_Stance"
FROM
    attributes."EV_STA_Event_Status_Meta"
WHERE
    "EV_STA_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Event_Status" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID", a."EV_STA_Who")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Who",
    a."EV_STA_Confidence",
    a."EV_STA_Stance",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."rEV_STA_Event_Status_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Event_Status_Meta"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
AND
    a."EV_STA_Who" = coalesce(positor, a."EV_STA_Who")
ORDER BY
    p."EV_STA_ID", a."EV_STA_Who",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Event_Status" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Event_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID", a."EV_STA_Who")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Who",
    a."EV_STA_Confidence",
    a."EV_STA_Stance",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."fEV_STA_Event_Status_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Event_Status_Meta"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
AND
    a."EV_STA_Who" = coalesce(positor, a."EV_STA_Who")
ORDER BY
    p."EV_STA_ID", a."EV_STA_Who",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preEV_STA_Event_Status" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(20)
AS
$$
SELECT
    pre."EV_STA_Event_Status"
FROM
    attributes."rEV_STA_Event_Status"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_STA_EV_ID" = id
AND
    pre."EV_STA_ChangedAt" < changingTimepoint
AND
    pre."EV_STA_Stance" = coalesce(assertion, pre."EV_STA_Stance")
ORDER BY
    pre."EV_STA_ChangedAt" DESC,
    pre."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folEV_STA_Event_Status" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(20)
AS
$$
SELECT
    fol."EV_STA_Event_Status"
FROM
    attributes."fEV_STA_Event_Status"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_STA_EV_ID" = id
AND
    fol."EV_STA_ChangedAt" > changingTimepoint
AND
    fol."EV_STA_Stance" = coalesce(assertion, fol."EV_STA_Stance")
ORDER BY
    fol."EV_STA_ChangedAt" ASC,
    fol."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Event_Utilization_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_UTL",
    "EV_UTL_ID",
    "EV_UTL_PositedAt",
    "EV_UTL_Who",
    "EV_UTL_Confidence",
    "EV_UTL_Stance"
FROM
    attributes."EV_UTL_Event_Utilization_Meta"
WHERE
    "EV_UTL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Event_Utilization" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" char(1),
    "EV_UTL_EV_ID" numeric(12,0),
    "EV_UTL_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."EV_UTL_ID", a."EV_UTL_Who")
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Who",
    a."EV_UTL_Confidence",
    a."EV_UTL_Stance",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Event_Utilization_Fact" p
JOIN
    attributes."rEV_UTL_Event_Utilization_Meta"(positingTimepoint) a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
AND
    a."EV_UTL_Who" = coalesce(positor, a."EV_UTL_Who")
ORDER BY
    p."EV_UTL_ID", a."EV_UTL_Who",
    a."EV_UTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" bigint,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT
    "EV_LVL_ID",
    "EV_LVL_EV_ID",
    "EV_LVL_PLV_ID",
    "EV_LVL_ChangedAt"
FROM
    attributes."EV_LVL_Event_Level_Fact"
WHERE
    "EV_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Event_Level_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" bigint,
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT
    "EV_LVL_ID",
    "EV_LVL_EV_ID",
    "EV_LVL_PLV_ID",
    "EV_LVL_ChangedAt"
FROM
    attributes."EV_LVL_Event_Level_Fact"
WHERE
    "EV_LVL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_LVL",
    "EV_LVL_ID",
    "EV_LVL_PositedAt",
    "EV_LVL_Who",
    "EV_LVL_Confidence",
    "EV_LVL_Stance"
FROM
    attributes."EV_LVL_Event_Level_Meta"
WHERE
    "EV_LVL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Event_Level" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID", a."EV_LVL_Who")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Who",
    a."EV_LVL_Confidence",
    a."EV_LVL_Stance",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."rEV_LVL_Event_Level_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Event_Level_Meta"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
AND
    a."EV_LVL_Who" = coalesce(positor, a."EV_LVL_Who")
ORDER BY
    p."EV_LVL_ID", a."EV_LVL_Who",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Event_Level" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID", a."EV_LVL_Who")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Who",
    a."EV_LVL_Confidence",
    a."EV_LVL_Stance",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."fEV_LVL_Event_Level_Fact"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Event_Level_Meta"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
AND
    a."EV_LVL_Who" = coalesce(positor, a."EV_LVL_Who")
ORDER BY
    p."EV_LVL_ID", a."EV_LVL_Who",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preEV_LVL_Event_Level" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."EV_LVL_PLV_ID"
FROM
    attributes."rEV_LVL_Event_Level"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_LVL_EV_ID" = id
AND
    pre."EV_LVL_ChangedAt" < changingTimepoint
AND
    pre."EV_LVL_Stance" = coalesce(assertion, pre."EV_LVL_Stance")
ORDER BY
    pre."EV_LVL_ChangedAt" DESC,
    pre."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folEV_LVL_Event_Level" (
    id numeric(12,0),
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."EV_LVL_PLV_ID"
FROM
    attributes."fEV_LVL_Event_Level"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_LVL_EV_ID" = id
AND
    fol."EV_LVL_ChangedAt" > changingTimepoint
AND
    fol."EV_LVL_Stance" = coalesce(assertion, fol."EV_LVL_Stance")
ORDER BY
    fol."EV_LVL_ChangedAt" ASC,
    fol."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" bigint,
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
    attributes."ST_NAM_Stage_Name_Fact"
WHERE
    "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Stage_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" bigint,
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
    attributes."ST_NAM_Stage_Name_Fact"
WHERE
    "ST_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_NAM",
    "ST_NAM_ID",
    "ST_NAM_PositedAt",
    "ST_NAM_Who",
    "ST_NAM_Confidence",
    "ST_NAM_Stance"
FROM
    attributes."ST_NAM_Stage_Name_Meta"
WHERE
    "ST_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Stage_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID", a."ST_NAM_Who")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Who",
    a."ST_NAM_Confidence",
    a."ST_NAM_Stance",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."rST_NAM_Stage_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Stage_Name_Meta"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Who" = coalesce(positor, a."ST_NAM_Who")
ORDER BY
    p."ST_NAM_ID", a."ST_NAM_Who",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Stage_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Stage_Name" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID", a."ST_NAM_Who")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Who",
    a."ST_NAM_Confidence",
    a."ST_NAM_Stance",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."fST_NAM_Stage_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Stage_Name_Meta"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
AND
    a."ST_NAM_Who" = coalesce(positor, a."ST_NAM_Who")
ORDER BY
    p."ST_NAM_ID", a."ST_NAM_Who",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preST_NAM_Stage_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."ST_NAM_Stage_Name"
FROM
    attributes."rST_NAM_Stage_Name"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_NAM_ST_ID" = id
AND
    pre."ST_NAM_ChangedAt" < changingTimepoint
AND
    pre."ST_NAM_Stance" = coalesce(assertion, pre."ST_NAM_Stance")
ORDER BY
    pre."ST_NAM_ChangedAt" DESC,
    pre."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folST_NAM_Stage_Name" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."ST_NAM_Stage_Name"
FROM
    attributes."fST_NAM_Stage_Name"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_NAM_ST_ID" = id
AND
    fol."ST_NAM_ChangedAt" > changingTimepoint
AND
    fol."ST_NAM_Stance" = coalesce(assertion, fol."ST_NAM_Stance")
ORDER BY
    fol."ST_NAM_ChangedAt" ASC,
    fol."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Stage_Location_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Who" smallint,
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_LOC",
    "ST_LOC_ID",
    "ST_LOC_PositedAt",
    "ST_LOC_Who",
    "ST_LOC_Confidence",
    "ST_LOC_Stance"
FROM
    attributes."ST_LOC_Stage_Location_Meta"
WHERE
    "ST_LOC_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Stage_Location" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Who" smallint,
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Stance" char(1),
    "ST_LOC_ST_ID" integer,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text
)
AS
$$
SELECT DISTINCT ON (p."ST_LOC_ID", a."ST_LOC_Who")
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Who",
    a."ST_LOC_Confidence",
    a."ST_LOC_Stance",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location"
FROM
    attributes."ST_LOC_Stage_Location_Fact" p
JOIN
    attributes."rST_LOC_Stage_Location_Meta"(positingTimepoint) a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
AND
    a."ST_LOC_Who" = coalesce(positor, a."ST_LOC_Who")
ORDER BY
    p."ST_LOC_ID", a."ST_LOC_Who",
    a."ST_LOC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" bigint,
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
    attributes."ST_AVG_Stage_Average_Fact"
WHERE
    "ST_AVG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Stage_Average_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_AVG_ID" bigint,
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
    attributes."ST_AVG_Stage_Average_Fact"
WHERE
    "ST_AVG_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_AVG",
    "ST_AVG_ID",
    "ST_AVG_PositedAt",
    "ST_AVG_Who",
    "ST_AVG_Confidence",
    "ST_AVG_Stance"
FROM
    attributes."ST_AVG_Stage_Average_Meta"
WHERE
    "ST_AVG_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Stage_Average" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID", a."ST_AVG_Who")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Who",
    a."ST_AVG_Confidence",
    a."ST_AVG_Stance",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."rST_AVG_Stage_Average_Fact"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Stage_Average_Meta"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Who" = coalesce(positor, a."ST_AVG_Who")
ORDER BY
    p."ST_AVG_ID", a."ST_AVG_Who",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Stage_Average" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID", a."ST_AVG_Who")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Who",
    a."ST_AVG_Confidence",
    a."ST_AVG_Stance",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."fST_AVG_Stage_Average_Fact"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Stage_Average_Meta"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
AND
    a."ST_AVG_Who" = coalesce(positor, a."ST_AVG_Who")
ORDER BY
    p."ST_AVG_ID", a."ST_AVG_Who",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preST_AVG_Stage_Average" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."ST_AVG_UTL_ID"
FROM
    attributes."rST_AVG_Stage_Average"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_AVG_ST_ID" = id
AND
    pre."ST_AVG_ChangedAt" < changingTimepoint
AND
    pre."ST_AVG_Stance" = coalesce(assertion, pre."ST_AVG_Stance")
ORDER BY
    pre."ST_AVG_ChangedAt" DESC,
    pre."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folST_AVG_Stage_Average" (
    id integer,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."ST_AVG_UTL_ID"
FROM
    attributes."fST_AVG_Stage_Average"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_AVG_ST_ID" = id
AND
    fol."ST_AVG_ChangedAt" > changingTimepoint
AND
    fol."ST_AVG_Stance" = coalesce(assertion, fol."ST_AVG_Stance")
ORDER BY
    fol."ST_AVG_ChangedAt" ASC,
    fol."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Stage_Minimum_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Who" smallint,
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_MIN",
    "ST_MIN_ID",
    "ST_MIN_PositedAt",
    "ST_MIN_Who",
    "ST_MIN_Confidence",
    "ST_MIN_Stance"
FROM
    attributes."ST_MIN_Stage_Minimum_Meta"
WHERE
    "ST_MIN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Stage_Minimum" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Who" smallint,
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_Stance" char(1),
    "ST_MIN_ST_ID" integer,
    "ST_MIN_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."ST_MIN_ID", a."ST_MIN_Who")
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Who",
    a."ST_MIN_Confidence",
    a."ST_MIN_Stance",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Stage_Minimum_Fact" p
JOIN
    attributes."rST_MIN_Stage_Minimum_Meta"(positingTimepoint) a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
AND
    a."ST_MIN_Who" = coalesce(positor, a."ST_MIN_Who")
ORDER BY
    p."ST_MIN_ID", a."ST_MIN_Who",
    a."ST_MIN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" bigint,
    "AC_NAM_AC_ID" smallint,
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
    attributes."AC_NAM_Actor_Name_Fact"
WHERE
    "AC_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Actor_Name_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" bigint,
    "AC_NAM_AC_ID" smallint,
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
    attributes."AC_NAM_Actor_Name_Fact"
WHERE
    "AC_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_NAM",
    "AC_NAM_ID",
    "AC_NAM_PositedAt",
    "AC_NAM_Who",
    "AC_NAM_Confidence",
    "AC_NAM_Stance"
FROM
    attributes."AC_NAM_Actor_Name_Meta"
WHERE
    "AC_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Actor_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID", a."AC_NAM_Who")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Who",
    a."AC_NAM_Confidence",
    a."AC_NAM_Stance",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."rAC_NAM_Actor_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Actor_Name_Meta"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Who" = coalesce(positor, a."AC_NAM_Who")
ORDER BY
    p."AC_NAM_ID", a."AC_NAM_Who",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Actor_Name" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Actor_Name" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID", a."AC_NAM_Who")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Who",
    a."AC_NAM_Confidence",
    a."AC_NAM_Stance",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."fAC_NAM_Actor_Name_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Actor_Name_Meta"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
AND
    a."AC_NAM_Who" = coalesce(positor, a."AC_NAM_Who")
ORDER BY
    p."AC_NAM_ID", a."AC_NAM_Who",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preAC_NAM_Actor_Name" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."AC_NAM_Actor_Name"
FROM
    attributes."rAC_NAM_Actor_Name"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_NAM_AC_ID" = id
AND
    pre."AC_NAM_ChangedAt" < changingTimepoint
AND
    pre."AC_NAM_Stance" = coalesce(assertion, pre."AC_NAM_Stance")
ORDER BY
    pre."AC_NAM_ChangedAt" DESC,
    pre."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folAC_NAM_Actor_Name" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."AC_NAM_Actor_Name"
FROM
    attributes."fAC_NAM_Actor_Name"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_NAM_AC_ID" = id
AND
    fol."AC_NAM_ChangedAt" > changingTimepoint
AND
    fol."AC_NAM_Stance" = coalesce(assertion, fol."AC_NAM_Stance")
ORDER BY
    fol."AC_NAM_ChangedAt" ASC,
    fol."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Actor_Gender_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Who" smallint,
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_GEN",
    "AC_GEN_ID",
    "AC_GEN_PositedAt",
    "AC_GEN_Who",
    "AC_GEN_Confidence",
    "AC_GEN_Stance"
FROM
    attributes."AC_GEN_Actor_Gender_Meta"
WHERE
    "AC_GEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Actor_Gender" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Who" smallint,
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_Stance" char(1),
    "AC_GEN_AC_ID" smallint,
    "AC_GEN_GEN_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."AC_GEN_ID", a."AC_GEN_Who")
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Who",
    a."AC_GEN_Confidence",
    a."AC_GEN_Stance",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Actor_Gender_Fact" p
JOIN
    attributes."rAC_GEN_Actor_Gender_Meta"(positingTimepoint) a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
AND
    a."AC_GEN_Who" = coalesce(positor, a."AC_GEN_Who")
ORDER BY
    p."AC_GEN_ID", a."AC_GEN_Who",
    a."AC_GEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" bigint,
    "AC_PLV_AC_ID" smallint,
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
    attributes."AC_PLV_Actor_ProfessionalLevel_Fact"
WHERE
    "AC_PLV_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Actor_ProfessionalLevel_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" bigint,
    "AC_PLV_AC_ID" smallint,
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
    attributes."AC_PLV_Actor_ProfessionalLevel_Fact"
WHERE
    "AC_PLV_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_PLV",
    "AC_PLV_ID",
    "AC_PLV_PositedAt",
    "AC_PLV_Who",
    "AC_PLV_Confidence",
    "AC_PLV_Stance"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Meta"
WHERE
    "AC_PLV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Actor_ProfessionalLevel" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID", a."AC_PLV_Who")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Who",
    a."AC_PLV_Confidence",
    a."AC_PLV_Stance",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."rAC_PLV_Actor_ProfessionalLevel_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel_Meta"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Who" = coalesce(positor, a."AC_PLV_Who")
ORDER BY
    p."AC_PLV_ID", a."AC_PLV_Who",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Actor_ProfessionalLevel" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID", a."AC_PLV_Who")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Who",
    a."AC_PLV_Confidence",
    a."AC_PLV_Stance",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."fAC_PLV_Actor_ProfessionalLevel_Fact"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Actor_ProfessionalLevel_Meta"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
AND
    a."AC_PLV_Who" = coalesce(positor, a."AC_PLV_Who")
ORDER BY
    p."AC_PLV_ID", a."AC_PLV_Who",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."preAC_PLV_Actor_ProfessionalLevel" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    pre."AC_PLV_PLV_ID"
FROM
    attributes."rAC_PLV_Actor_ProfessionalLevel"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_PLV_AC_ID" = id
AND
    pre."AC_PLV_ChangedAt" < changingTimepoint
AND
    pre."AC_PLV_Stance" = coalesce(assertion, pre."AC_PLV_Stance")
ORDER BY
    pre."AC_PLV_ChangedAt" DESC,
    pre."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folAC_PLV_Actor_ProfessionalLevel" (
    id smallint,
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS smallint
AS
$$
SELECT
    fol."AC_PLV_PLV_ID"
FROM
    attributes."fAC_PLV_Actor_ProfessionalLevel"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_PLV_AC_ID" = id
AND
    fol."AC_PLV_ChangedAt" > changingTimepoint
AND
    fol."AC_PLV_Stance" = coalesce(assertion, fol."AC_PLV_Stance")
ORDER BY
    fol."AC_PLV_ChangedAt" ASC,
    fol."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Program_Name_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Who" smallint,
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_PR_NAM",
    "PR_NAM_ID",
    "PR_NAM_PositedAt",
    "PR_NAM_Who",
    "PR_NAM_Confidence",
    "PR_NAM_Stance"
FROM
    attributes."PR_NAM_Program_Name_Meta"
WHERE
    "PR_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Program_Name" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Who" smallint,
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Stance" char(1),
    "PR_NAM_PR_ID" bigint,
    "PR_NAM_Program_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."PR_NAM_ID", a."PR_NAM_Who")
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Who",
    a."PR_NAM_Confidence",
    a."PR_NAM_Stance",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name"
FROM
    attributes."PR_NAM_Program_Name_Fact" p
JOIN
    attributes."rPR_NAM_Program_Name_Meta"(positingTimepoint) a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
AND
    a."PR_NAM_Who" = coalesce(positor, a."PR_NAM_Who")
ORDER BY
    p."PR_NAM_ID", a."PR_NAM_Who",
    a."PR_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute posit rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" bigint,
    "PR_LEN_PR_ID" bigint,
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
    attributes."PR_LEN_Program_Length_Fact"
WHERE
    "PR_LEN_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute posit forwarder ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Program_Length_Fact" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" bigint,
    "PR_LEN_PR_ID" bigint,
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
    attributes."PR_LEN_Program_Length_Fact"
WHERE
    "PR_LEN_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute annex rewinder -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_PR_LEN",
    "PR_LEN_ID",
    "PR_LEN_PositedAt",
    "PR_LEN_Who",
    "PR_LEN_Confidence",
    "PR_LEN_Stance"
FROM
    attributes."PR_LEN_Program_Length_Meta"
WHERE
    "PR_LEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
-- Attribute assembled rewinder ---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Program_Length" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID", a."PR_LEN_Who")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Who",
    a."PR_LEN_Confidence",
    a."PR_LEN_Stance",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."rPR_LEN_Program_Length_Fact"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Program_Length_Meta"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Who" = coalesce(positor, a."PR_LEN_Who")
ORDER BY
    p."PR_LEN_ID", a."PR_LEN_Who",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute assembled forwarder --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Program_Length" (
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Program_Length" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID", a."PR_LEN_Who")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Who",
    a."PR_LEN_Confidence",
    a."PR_LEN_Stance",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."fPR_LEN_Program_Length_Fact"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Program_Length_Meta"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
AND
    a."PR_LEN_Who" = coalesce(positor, a."PR_LEN_Who")
ORDER BY
    p."PR_LEN_ID", a."PR_LEN_Who",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- Attribute previous value -------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."prePR_LEN_Program_Length" (
    id bigint,
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS time
AS
$$
SELECT
    pre."PR_LEN_Program_Length"
FROM
    attributes."rPR_LEN_Program_Length"(positor, changingTimepoint, positingTimepoint) pre
WHERE
    pre."PR_LEN_PR_ID" = id
AND
    pre."PR_LEN_ChangedAt" < changingTimepoint
AND
    pre."PR_LEN_Stance" = coalesce(assertion, pre."PR_LEN_Stance")
ORDER BY
    pre."PR_LEN_ChangedAt" DESC,
    pre."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- Attribute following value ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."folPR_LEN_Program_Length" (
    id bigint,
    positor smallint,
    changingTimepoint date,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS time
AS
$$
SELECT
    fol."PR_LEN_Program_Length"
FROM
    attributes."fPR_LEN_Program_Length"(positor, changingTimepoint, positingTimepoint) fol
WHERE
    fol."PR_LEN_PR_ID" = id
AND
    fol."PR_LEN_ChangedAt" > changingTimepoint
AND
    fol."PR_LEN_Stance" = coalesce(assertion, fol."PR_LEN_Stance")
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
CREATE OR REPLACE FUNCTION anchors."tST_Stage" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" bigint,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Who" smallint,
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Stance" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" bigint,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Who" smallint,
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_Stance" char(1),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" bigint,
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
    "NAM"."ST_NAM_Who",
    "NAM"."ST_NAM_Confidence",
    "NAM"."ST_NAM_Stance",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Who",
    "LOC"."ST_LOC_Confidence",
    "LOC"."ST_LOC_Stance",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Who",
    "AVG"."ST_AVG_Confidence",
    "AVG"."ST_AVG_Stance",
    "AVG"."ST_AVG_UTL_Utilization",
    "AVG"."ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Who",
    "MIN"."ST_MIN_Confidence",
    "MIN"."ST_MIN_Stance",
    "MIN"."ST_MIN_UTL_Utilization",
    "MIN"."ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw."_Who" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_NAM_Who", x."ST_NAM_ST_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_NAM_Stance" <> '?' THEN r."ST_NAM_ChangedAt" END) OVER (
                PARTITION BY r."ST_NAM_Who", r."ST_NAM_ST_ID"
            ) AS "inEffect"
        FROM
            attributes."rST_NAM_Stage_Name"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."ST_NAM_Stance" = coalesce(assertion, x."ST_NAM_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."ST_NAM_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."ST_NAM_Who", x."ST_NAM_ST_ID",
    x."ST_NAM_ChangedAt" DESC,
    x."ST_NAM_PositedAt" DESC,
    x."ST_NAM_Confidence" DESC
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_LOC_Who", x."ST_LOC_ST_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rST_LOC_Stage_Location"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."ST_LOC_Stance" = coalesce(assertion, x."ST_LOC_Stance")
    ORDER BY
    x."ST_LOC_Who", x."ST_LOC_ST_ID",
    x."ST_LOC_PositedAt" DESC,
    x."ST_LOC_Confidence" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
        k."UTL_Utilization" AS "ST_AVG_UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_AVG_Who", x."ST_AVG_ST_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_AVG_Stance" <> '?' THEN r."ST_AVG_ChangedAt" END) OVER (
                PARTITION BY r."ST_AVG_Who", r."ST_AVG_ST_ID"
            ) AS "inEffect"
        FROM
            attributes."rST_AVG_Stage_Average"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."ST_AVG_Stance" = coalesce(assertion, x."ST_AVG_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."ST_AVG_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."ST_AVG_Who", x."ST_AVG_ST_ID",
    x."ST_AVG_ChangedAt" DESC,
    x."ST_AVG_PositedAt" DESC,
    x."ST_AVG_Confidence" DESC
    ) y
    LEFT JOIN
        knots."UTL_Utilization" k
    ON
        k."UTL_ID" = y."ST_AVG_UTL_ID"
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
        k."UTL_Utilization" AS "ST_MIN_UTL_Utilization"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."ST_MIN_Who", x."ST_MIN_ST_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rST_MIN_Stage_Minimum"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."ST_MIN_Stance" = coalesce(assertion, x."ST_MIN_Stance")
    ORDER BY
    x."ST_MIN_Who", x."ST_MIN_ST_ID",
    x."ST_MIN_PositedAt" DESC,
    x."ST_MIN_Confidence" DESC
    ) y
    LEFT JOIN
        knots."UTL_Utilization" k
    ON
        k."UTL_ID" = y."ST_MIN_UTL_ID"
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Who" = p."Who"
WHERE
    p."Who" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lST_Stage" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "ST".*
FROM
    dw."_Who" p,
    anchors."tST_Stage"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "ST"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pST_Stage" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "ST_ID" integer,
    "Metadata_ST" bigint,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Who" smallint,
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Stance" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" bigint,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Who" smallint,
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_Stance" char(1),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" bigint,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "ST"."ST_NAM_ST_ID",
    "ST"."Metadata_ST_NAM",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Who",
    "ST"."ST_NAM_Confidence",
    "ST"."ST_NAM_Stance",
    "ST"."ST_NAM_Stage_Name",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Who",
    "ST"."ST_LOC_Confidence",
    "ST"."ST_LOC_Stance",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Stage_Location",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Who",
    "ST"."ST_AVG_Confidence",
    "ST"."ST_AVG_Stance",
    "ST"."ST_AVG_UTL_Utilization",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Who",
    "ST"."ST_MIN_Confidence",
    "ST"."ST_MIN_Stance",
    "ST"."ST_MIN_UTL_Utilization",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    dw."_Who" p,
    anchors."tST_Stage"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "ST"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nST_Stage" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "ST".*
FROM
    dw."_Who" p,
    anchors."tST_Stage"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "ST"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dST_Stage" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "ST_ID" integer,
    "Metadata_ST" bigint,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" bigint,
    "ST_NAM_ID" bigint,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp(3),
    "ST_NAM_Who" smallint,
    "ST_NAM_Confidence" decimal(7,3),
    "ST_NAM_Stance" char(1),
    "ST_NAM_Stage_Name" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" bigint,
    "ST_LOC_ID" bigint,
    "ST_LOC_PositedAt" timestamp(3),
    "ST_LOC_Who" smallint,
    "ST_LOC_Confidence" decimal(7,3),
    "ST_LOC_Stance" char(1),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Stage_Location" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" bigint,
    "ST_AVG_ID" bigint,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp(3),
    "ST_AVG_Who" smallint,
    "ST_AVG_Confidence" decimal(7,3),
    "ST_AVG_Stance" char(1),
    "ST_AVG_UTL_Utilization" smallint,
    "ST_AVG_Metadata_UTL" bigint,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" bigint,
    "ST_MIN_ID" bigint,
    "ST_MIN_PositedAt" timestamp(3),
    "ST_MIN_Who" smallint,
    "ST_MIN_Confidence" decimal(7,3),
    "ST_MIN_Stance" char(1),
    "ST_MIN_UTL_Utilization" smallint,
    "ST_MIN_Metadata_UTL" bigint,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Who",
    timepoints.inspectedTimepoint,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Who",
    "NAM"."ST_NAM_Confidence",
    "NAM"."ST_NAM_Stance",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Who",
    "LOC"."ST_LOC_Confidence",
    "LOC"."ST_LOC_Stance",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Who",
    "AVG"."ST_AVG_Confidence",
    "AVG"."ST_AVG_Stance",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Who",
    "MIN"."ST_MIN_Confidence",
    "MIN"."ST_MIN_Stance",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    dw."_Who" p
JOIN
(
    SELECT DISTINCT
        "ST_NAM_Who" AS positor,
        "ST_NAM_ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."ST_NAM_Stage_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_AVG_Who" AS positor,
        "ST_AVG_ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Stage_Average"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Who"
JOIN
    anchors."ST_Stage" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."ST_NAM_ChangedAt") OVER (
            PARTITION BY y."ST_NAM_Who", y."ST_NAM_ST_ID"
            ORDER BY y."ST_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_NAM_Who", r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt")
            r.*
        FROM
            attributes."rST_NAM_Stage_Name"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."ST_NAM_Stance" <> '?'
        ORDER BY
    r."ST_NAM_Who", r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt",
    CASE WHEN r."ST_NAM_Stance" = '+' THEN 0 ELSE 1 END,
    r."ST_NAM_PositedAt" DESC,
    r."ST_NAM_Confidence" DESC
    ) y
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_Who" = timepoints.positor
AND
    "NAM"."ST_NAM_Stance" = '+'
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_LOC_Who", r."ST_LOC_ST_ID")
        r.*
    FROM
        attributes."rST_LOC_Stage_Location"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."ST_LOC_Stance" = '+'
    ORDER BY
    r."ST_LOC_Who", r."ST_LOC_ST_ID",
    r."ST_LOC_PositedAt" DESC,
    r."ST_LOC_Confidence" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
AND
    "LOC"."ST_LOC_Who" = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."ST_AVG_ChangedAt") OVER (
            PARTITION BY y."ST_AVG_Who", y."ST_AVG_ST_ID"
            ORDER BY y."ST_AVG_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_AVG_Who", r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt")
            r.*
        FROM
            attributes."rST_AVG_Stage_Average"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."ST_AVG_Stance" <> '?'
        ORDER BY
    r."ST_AVG_Who", r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt",
    CASE WHEN r."ST_AVG_Stance" = '+' THEN 0 ELSE 1 END,
    r."ST_AVG_PositedAt" DESC,
    r."ST_AVG_Confidence" DESC
    ) y
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_Who" = timepoints.positor
AND
    "AVG"."ST_AVG_Stance" = '+'
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_MIN_Who", r."ST_MIN_ST_ID")
        r.*
    FROM
        attributes."rST_MIN_Stage_Minimum"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."ST_MIN_Stance" = '+'
    ORDER BY
    r."ST_MIN_Who", r."ST_MIN_ST_ID",
    r."ST_MIN_PositedAt" DESC,
    r."ST_MIN_Confidence" DESC
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
AND
    "MIN"."ST_MIN_Who" = timepoints.positor
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tAC_Actor" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" bigint,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Who" smallint,
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_Stance" char(1),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" bigint,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" bigint,
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
    "NAM"."AC_NAM_Who",
    "NAM"."AC_NAM_Confidence",
    "NAM"."AC_NAM_Stance",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Who",
    "GEN"."AC_GEN_Confidence",
    "GEN"."AC_GEN_Stance",
    "GEN"."AC_GEN_GEN_Checksum",
    "GEN"."AC_GEN_GEN_Gender",
    "GEN"."AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Who",
    "PLV"."AC_PLV_Confidence",
    "PLV"."AC_PLV_Stance",
    "PLV"."AC_PLV_PLV_Checksum",
    "PLV"."AC_PLV_PLV_ProfessionalLevel",
    "PLV"."AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw."_Who" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_NAM_Who", x."AC_NAM_AC_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_NAM_Stance" <> '?' THEN r."AC_NAM_ChangedAt" END) OVER (
                PARTITION BY r."AC_NAM_Who", r."AC_NAM_AC_ID"
            ) AS "inEffect"
        FROM
            attributes."rAC_NAM_Actor_Name"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."AC_NAM_Stance" = coalesce(assertion, x."AC_NAM_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."AC_NAM_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."AC_NAM_Who", x."AC_NAM_AC_ID",
    x."AC_NAM_ChangedAt" DESC,
    x."AC_NAM_PositedAt" DESC,
    x."AC_NAM_Confidence" DESC
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
        k."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
        k."GEN_Gender" AS "AC_GEN_GEN_Gender"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_GEN_Who", x."AC_GEN_AC_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rAC_GEN_Actor_Gender"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."AC_GEN_Stance" = coalesce(assertion, x."AC_GEN_Stance")
    ORDER BY
    x."AC_GEN_Who", x."AC_GEN_AC_ID",
    x."AC_GEN_PositedAt" DESC,
    x."AC_GEN_Confidence" DESC
    ) y
    LEFT JOIN
        knots."GEN_Gender" k
    ON
        k."GEN_ID" = y."AC_GEN_GEN_ID"
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
        k."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
        k."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."AC_PLV_Who", x."AC_PLV_AC_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_PLV_Stance" <> '?' THEN r."AC_PLV_ChangedAt" END) OVER (
                PARTITION BY r."AC_PLV_Who", r."AC_PLV_AC_ID"
            ) AS "inEffect"
        FROM
            attributes."rAC_PLV_Actor_ProfessionalLevel"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."AC_PLV_Stance" = coalesce(assertion, x."AC_PLV_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."AC_PLV_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."AC_PLV_Who", x."AC_PLV_AC_ID",
    x."AC_PLV_ChangedAt" DESC,
    x."AC_PLV_PositedAt" DESC,
    x."AC_PLV_Confidence" DESC
    ) y
    LEFT JOIN
        knots."PLV_ProfessionalLevel" k
    ON
        k."PLV_ID" = y."AC_PLV_PLV_ID"
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Who" = p."Who"
WHERE
    p."Who" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lAC_Actor" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "AC".*
FROM
    dw."_Who" p,
    anchors."tAC_Actor"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "AC"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pAC_Actor" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "AC_ID" smallint,
    "Metadata_AC" bigint,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Who" smallint,
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_Stance" char(1),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" bigint,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" bigint,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "AC"."AC_NAM_AC_ID",
    "AC"."Metadata_AC_NAM",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Who",
    "AC"."AC_NAM_Confidence",
    "AC"."AC_NAM_Stance",
    "AC"."AC_NAM_Actor_Name",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Who",
    "AC"."AC_GEN_Confidence",
    "AC"."AC_GEN_Stance",
    "AC"."AC_GEN_GEN_Checksum",
    "AC"."AC_GEN_GEN_Gender",
    "AC"."AC_GEN_Metadata_GEN",
    "AC"."AC_GEN_GEN_ID",
    "AC"."AC_PLV_AC_ID",
    "AC"."Metadata_AC_PLV",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Who",
    "AC"."AC_PLV_Confidence",
    "AC"."AC_PLV_Stance",
    "AC"."AC_PLV_PLV_Checksum",
    "AC"."AC_PLV_PLV_ProfessionalLevel",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    dw."_Who" p,
    anchors."tAC_Actor"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "AC"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nAC_Actor" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "AC".*
FROM
    dw."_Who" p,
    anchors."tAC_Actor"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "AC"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dAC_Actor" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "AC_ID" smallint,
    "Metadata_AC" bigint,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" bigint,
    "AC_NAM_ID" bigint,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp(3),
    "AC_NAM_Who" smallint,
    "AC_NAM_Confidence" decimal(7,3),
    "AC_NAM_Stance" char(1),
    "AC_NAM_Actor_Name" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" bigint,
    "AC_GEN_ID" bigint,
    "AC_GEN_PositedAt" timestamp(3),
    "AC_GEN_Who" smallint,
    "AC_GEN_Confidence" decimal(7,3),
    "AC_GEN_Stance" char(1),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Gender" varchar(42),
    "AC_GEN_Metadata_GEN" bigint,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" bigint,
    "AC_PLV_ID" bigint,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp(3),
    "AC_PLV_Who" smallint,
    "AC_PLV_Confidence" decimal(7,3),
    "AC_PLV_Stance" char(1),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_ProfessionalLevel" text,
    "AC_PLV_Metadata_PLV" bigint,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Who",
    timepoints.inspectedTimepoint,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Who",
    "NAM"."AC_NAM_Confidence",
    "NAM"."AC_NAM_Stance",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Who",
    "GEN"."AC_GEN_Confidence",
    "GEN"."AC_GEN_Stance",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Who",
    "PLV"."AC_PLV_Confidence",
    "PLV"."AC_PLV_Stance",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    dw."_Who" p
JOIN
(
    SELECT DISTINCT
        "AC_NAM_Who" AS positor,
        "AC_NAM_AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Actor_Name"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_PLV_Who" AS positor,
        "AC_PLV_AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Actor_ProfessionalLevel"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Who"
JOIN
    anchors."AC_Actor" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."AC_NAM_ChangedAt") OVER (
            PARTITION BY y."AC_NAM_Who", y."AC_NAM_AC_ID"
            ORDER BY y."AC_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_NAM_Who", r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt")
            r.*
        FROM
            attributes."rAC_NAM_Actor_Name"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."AC_NAM_Stance" <> '?'
        ORDER BY
    r."AC_NAM_Who", r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt",
    CASE WHEN r."AC_NAM_Stance" = '+' THEN 0 ELSE 1 END,
    r."AC_NAM_PositedAt" DESC,
    r."AC_NAM_Confidence" DESC
    ) y
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_Who" = timepoints.positor
AND
    "NAM"."AC_NAM_Stance" = '+'
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."AC_GEN_Who", r."AC_GEN_AC_ID")
        r.*
    FROM
        attributes."rAC_GEN_Actor_Gender"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."AC_GEN_Stance" = '+'
    ORDER BY
    r."AC_GEN_Who", r."AC_GEN_AC_ID",
    r."AC_GEN_PositedAt" DESC,
    r."AC_GEN_Confidence" DESC
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
AND
    "GEN"."AC_GEN_Who" = timepoints.positor
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."AC_PLV_ChangedAt") OVER (
            PARTITION BY y."AC_PLV_Who", y."AC_PLV_AC_ID"
            ORDER BY y."AC_PLV_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_PLV_Who", r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt")
            r.*
        FROM
            attributes."rAC_PLV_Actor_ProfessionalLevel"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."AC_PLV_Stance" <> '?'
        ORDER BY
    r."AC_PLV_Who", r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt",
    CASE WHEN r."AC_PLV_Stance" = '+' THEN 0 ELSE 1 END,
    r."AC_PLV_PositedAt" DESC,
    r."AC_PLV_Confidence" DESC
    ) y
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_Who" = timepoints.positor
AND
    "PLV"."AC_PLV_Stance" = '+'
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."tPR_Program" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" bigint,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Who" smallint,
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Stance" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1),
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
    "NAM"."PR_NAM_Who",
    "NAM"."PR_NAM_Confidence",
    "NAM"."PR_NAM_Stance",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Who",
    "LEN"."PR_LEN_Confidence",
    "LEN"."PR_LEN_Stance",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw."_Who" p
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."PR_NAM_Who", x."PR_NAM_PR_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rPR_NAM_Program_Name"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."PR_NAM_Stance" = coalesce(assertion, x."PR_NAM_Stance")
    ORDER BY
    x."PR_NAM_Who", x."PR_NAM_PR_ID",
    x."PR_NAM_PositedAt" DESC,
    x."PR_NAM_Confidence" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each anchor and positor, picked by a window
    SELECT DISTINCT ON (x."PR_LEN_Who", x."PR_LEN_PR_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_LEN_Stance" <> '?' THEN r."PR_LEN_ChangedAt" END) OVER (
                PARTITION BY r."PR_LEN_Who", r."PR_LEN_PR_ID"
            ) AS "inEffect"
        FROM
            attributes."rPR_LEN_Program_Length"(
                null::smallint,
                changingTimepoint::date,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."PR_LEN_Stance" = coalesce(assertion, x."PR_LEN_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."PR_LEN_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."PR_LEN_Who", x."PR_LEN_PR_ID",
    x."PR_LEN_ChangedAt" DESC,
    x."PR_LEN_PositedAt" DESC,
    x."PR_LEN_Confidence" DESC
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Who" = p."Who"
WHERE
    p."Who" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."lPR_Program" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "PR".*
FROM
    dw."_Who" p,
    anchors."tPR_Program"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "PR"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."pPR_Program" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "PR_ID" bigint,
    "Metadata_PR" bigint,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Who" smallint,
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Stance" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "PR"."PR_NAM_PR_ID",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Who",
    "PR"."PR_NAM_Confidence",
    "PR"."PR_NAM_Stance",
    "PR"."PR_NAM_Program_Name",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Who",
    "PR"."PR_LEN_Confidence",
    "PR"."PR_LEN_Stance",
    "PR"."PR_LEN_Program_Length"
FROM
    dw."_Who" p,
    anchors."tPR_Program"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "PR"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW anchors."nPR_Program" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) as "Confidence",
    "PR".*
FROM
    dw."_Who" p,
    anchors."tPR_Program"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "PR"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dPR_Program" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "PR_ID" bigint,
    "Metadata_PR" bigint,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" bigint,
    "PR_NAM_ID" bigint,
    "PR_NAM_PositedAt" timestamp(3),
    "PR_NAM_Who" smallint,
    "PR_NAM_Confidence" decimal(7,3),
    "PR_NAM_Stance" char(1),
    "PR_NAM_Program_Name" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" bigint,
    "PR_LEN_ID" bigint,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp(3),
    "PR_LEN_Who" smallint,
    "PR_LEN_Confidence" decimal(7,3),
    "PR_LEN_Stance" char(1),
    "PR_LEN_Program_Length" time
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Who",
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Who",
    "NAM"."PR_NAM_Confidence",
    "NAM"."PR_NAM_Stance",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Who",
    "LEN"."PR_LEN_Confidence",
    "LEN"."PR_LEN_Stance",
    "LEN"."PR_LEN_Program_Length"
FROM
    dw."_Who" p
JOIN
(
    SELECT DISTINCT
        "PR_LEN_Who" AS positor,
        "PR_LEN_PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."PR_LEN_Program_Length"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
ON
    timepoints.positor = p."Who"
JOIN
    anchors."PR_Program" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."PR_NAM_Who", r."PR_NAM_PR_ID")
        r.*
    FROM
        attributes."rPR_NAM_Program_Name"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."PR_NAM_Stance" = '+'
    ORDER BY
    r."PR_NAM_Who", r."PR_NAM_PR_ID",
    r."PR_NAM_PositedAt" DESC,
    r."PR_NAM_Confidence" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
AND
    "NAM"."PR_NAM_Who" = timepoints.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."PR_LEN_ChangedAt") OVER (
            PARTITION BY y."PR_LEN_Who", y."PR_LEN_PR_ID"
            ORDER BY y."PR_LEN_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."PR_LEN_Who", r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt")
            r.*
        FROM
            attributes."rPR_LEN_Program_Length"(
                null::smallint,
                '9999-12-31'::date,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."PR_LEN_Stance" <> '?'
        ORDER BY
    r."PR_LEN_Who", r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt",
    CASE WHEN r."PR_LEN_Stance" = '+' THEN 0 ELSE 1 END,
    r."PR_LEN_PositedAt" DESC,
    r."PR_LEN_Confidence" DESC
    ) y
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
AND
    "LEN"."PR_LEN_Who" = timepoints.positor
AND
    "LEN"."PR_LEN_Stance" = '+'
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
CREATE OR REPLACE FUNCTION nexuses."tEV_Event" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" bigint,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" bigint,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" char(1),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" char(1),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" char(1),
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1),
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" char(1),
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" bigint,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_ProfessionalLevel" text,
    "EV_LVL_Metadata_PLV" bigint,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "kETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Who",
    "DAT"."EV_DAT_Confidence",
    "DAT"."EV_DAT_Stance",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Who",
    "AUD"."EV_AUD_Confidence",
    "AUD"."EV_AUD_Stance",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Who",
    "REV"."EV_REV_Confidence",
    "REV"."EV_REV_Stance",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Who",
    "STA"."EV_STA_Confidence",
    "STA"."EV_STA_Stance",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Who",
    "UTL"."EV_UTL_Confidence",
    "UTL"."EV_UTL_Stance",
    "UTL"."EV_UTL_UTL_Utilization",
    "UTL"."EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Who",
    "LVL"."EV_LVL_Confidence",
    "LVL"."EV_LVL_Stance",
    "LVL"."EV_LVL_PLV_Checksum",
    "LVL"."EV_LVL_PLV_ProfessionalLevel",
    "LVL"."EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Event" "EV"
-- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
-- perspectives call this one for each positor (so a positor has to be in the table of positors to be shown)
CROSS JOIN
    dw."_Who" p
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_DAT_Who", x."EV_DAT_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_DAT_Event_Date"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."EV_DAT_Stance" = coalesce(assertion, x."EV_DAT_Stance")
    ORDER BY
    x."EV_DAT_Who", x."EV_DAT_EV_ID",
    x."EV_DAT_PositedAt" DESC,
    x."EV_DAT_Confidence" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_AUD_Who", x."EV_AUD_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_AUD_Event_Audience"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."EV_AUD_Stance" = coalesce(assertion, x."EV_AUD_Stance")
    ORDER BY
    x."EV_AUD_Who", x."EV_AUD_EV_ID",
    x."EV_AUD_PositedAt" DESC,
    x."EV_AUD_Confidence" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_REV_Who", x."EV_REV_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_REV_Event_Revenue"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."EV_REV_Stance" = coalesce(assertion, x."EV_REV_Stance")
    ORDER BY
    x."EV_REV_Who", x."EV_REV_EV_ID",
    x."EV_REV_PositedAt" DESC,
    x."EV_REV_Confidence" DESC
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Who" = p."Who"
LEFT JOIN (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_STA_Who", x."EV_STA_EV_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_STA_Stance" <> '?' THEN r."EV_STA_ChangedAt" END) OVER (
                PARTITION BY r."EV_STA_Who", r."EV_STA_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_STA_Event_Status"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."EV_STA_Stance" = coalesce(assertion, x."EV_STA_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."EV_STA_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."EV_STA_Who", x."EV_STA_EV_ID",
    x."EV_STA_ChangedAt" DESC,
    x."EV_STA_PositedAt" DESC,
    x."EV_STA_Confidence" DESC
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
        k."UTL_Utilization" AS "EV_UTL_UTL_Utilization"
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_UTL_Who", x."EV_UTL_EV_ID")
        x.*
    FROM (
        SELECT
            r.*
        FROM
            attributes."rEV_UTL_Event_Utilization"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."EV_UTL_Stance" = coalesce(assertion, x."EV_UTL_Stance")
    ORDER BY
    x."EV_UTL_Who", x."EV_UTL_EV_ID",
    x."EV_UTL_PositedAt" DESC,
    x."EV_UTL_Confidence" DESC
    ) y
    LEFT JOIN
        knots."UTL_Utilization" k
    ON
        k."UTL_ID" = y."EV_UTL_UTL_ID"
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
AND
    "UTL"."EV_UTL_Who" = p."Who"
LEFT JOIN (
    -- the knot is joined in here, inside what is called for each positor
    SELECT
        y.*,
        k."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
        k."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
        k."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel"
    FROM (
    -- the posit in effect for each nexus and positor, picked by a window
    SELECT DISTINCT ON (x."EV_LVL_Who", x."EV_LVL_EV_ID")
        x.*
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."EV_LVL_Stance" <> '?' THEN r."EV_LVL_ChangedAt" END) OVER (
                PARTITION BY r."EV_LVL_Who", r."EV_LVL_EV_ID"
            ) AS "inEffect"
        FROM
            attributes."rEV_LVL_Event_Level"(
                null::smallint,
                changingTimepoint::date,
                positingTimepoint::timestamp(3)
            ) r
    ) x
    WHERE
        x."EV_LVL_Stance" = coalesce(assertion, x."EV_LVL_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        x."EV_LVL_ChangedAt" = x."inEffect"
    )
    ORDER BY
    x."EV_LVL_Who", x."EV_LVL_EV_ID",
    x."EV_LVL_ChangedAt" DESC,
    x."EV_LVL_PositedAt" DESC,
    x."EV_LVL_Confidence" DESC
    ) y
    LEFT JOIN
        knots."PLV_ProfessionalLevel" k
    ON
        k."PLV_ID" = y."EV_LVL_PLV_ID"
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_Who" = p."Who"
WHERE
    p."Who" = positor
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."lEV_Event" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    "EV".*
FROM
    dw."_Who" p,
    nexuses."tEV_Event"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "EV"
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "EV_ID" numeric(12,0),
    "Metadata_EV" bigint,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" bigint,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" char(1),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" char(1),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" char(1),
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1),
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" char(1),
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" bigint,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_ProfessionalLevel" text,
    "EV_LVL_Metadata_PLV" bigint,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "EV"."of_ETY_Checksum",
    "EV"."of_ETY_EventType",
    "EV"."of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "EV"."EV_DAT_EV_ID",
    "EV"."Metadata_EV_DAT",
    "EV"."EV_DAT_ID",
    "EV"."EV_DAT_PositedAt",
    "EV"."EV_DAT_Who",
    "EV"."EV_DAT_Confidence",
    "EV"."EV_DAT_Stance",
    "EV"."EV_DAT_Event_Date",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Who",
    "EV"."EV_AUD_Confidence",
    "EV"."EV_AUD_Stance",
    "EV"."EV_AUD_Event_Audience",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Who",
    "EV"."EV_REV_Confidence",
    "EV"."EV_REV_Stance",
    "EV"."EV_REV_Event_Revenue",
    "EV"."EV_STA_EV_ID",
    "EV"."Metadata_EV_STA",
    "EV"."EV_STA_ID",
    "EV"."EV_STA_ChangedAt",
    "EV"."EV_STA_PositedAt",
    "EV"."EV_STA_Who",
    "EV"."EV_STA_Confidence",
    "EV"."EV_STA_Stance",
    "EV"."EV_STA_Event_Status",
    "EV"."EV_UTL_EV_ID",
    "EV"."Metadata_EV_UTL",
    "EV"."EV_UTL_ID",
    "EV"."EV_UTL_PositedAt",
    "EV"."EV_UTL_Who",
    "EV"."EV_UTL_Confidence",
    "EV"."EV_UTL_Stance",
    "EV"."EV_UTL_UTL_Utilization",
    "EV"."EV_UTL_Metadata_UTL",
    "EV"."EV_UTL_UTL_ID",
    "EV"."EV_LVL_EV_ID",
    "EV"."Metadata_EV_LVL",
    "EV"."EV_LVL_ID",
    "EV"."EV_LVL_ChangedAt",
    "EV"."EV_LVL_PositedAt",
    "EV"."EV_LVL_Who",
    "EV"."EV_LVL_Confidence",
    "EV"."EV_LVL_Stance",
    "EV"."EV_LVL_PLV_Checksum",
    "EV"."EV_LVL_PLV_ProfessionalLevel",
    "EV"."EV_LVL_Metadata_PLV",
    "EV"."EV_LVL_PLV_ID"
FROM
    dw."_Who" p,
    nexuses."tEV_Event"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "EV"
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW nexuses."nEV_Event" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    "EV".*
FROM
    dw."_Who" p,
    nexuses."tEV_Event"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) "EV"
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dEV_Event" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "EV_ID" numeric(12,0),
    "Metadata_EV" bigint,
    "ST_ID_wasHeldAt" integer,
    "PR_ID_wasPlayed" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_EventType" varchar(42),
    "of_Metadata_ETY" bigint,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" bigint,
    "EV_DAT_ID" bigint,
    "EV_DAT_PositedAt" timestamp(3),
    "EV_DAT_Who" smallint,
    "EV_DAT_Confidence" decimal(7,3),
    "EV_DAT_Stance" char(1),
    "EV_DAT_Event_Date" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" bigint,
    "EV_AUD_ID" bigint,
    "EV_AUD_PositedAt" timestamp(3),
    "EV_AUD_Who" smallint,
    "EV_AUD_Confidence" decimal(7,3),
    "EV_AUD_Stance" char(1),
    "EV_AUD_Event_Audience" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" bigint,
    "EV_REV_ID" bigint,
    "EV_REV_PositedAt" timestamp(3),
    "EV_REV_Who" smallint,
    "EV_REV_Confidence" decimal(7,3),
    "EV_REV_Stance" char(1),
    "EV_REV_Event_Revenue" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" bigint,
    "EV_STA_ID" bigint,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp(3),
    "EV_STA_Who" smallint,
    "EV_STA_Confidence" decimal(7,3),
    "EV_STA_Stance" char(1),
    "EV_STA_Event_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" bigint,
    "EV_UTL_ID" bigint,
    "EV_UTL_PositedAt" timestamp(3),
    "EV_UTL_Who" smallint,
    "EV_UTL_Confidence" decimal(7,3),
    "EV_UTL_Stance" char(1),
    "EV_UTL_UTL_Utilization" smallint,
    "EV_UTL_Metadata_UTL" bigint,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" bigint,
    "EV_LVL_ID" bigint,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp(3),
    "EV_LVL_Who" smallint,
    "EV_LVL_Confidence" decimal(7,3),
    "EV_LVL_Stance" char(1),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_ProfessionalLevel" text,
    "EV_LVL_Metadata_PLV" bigint,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Who",
    tp.inspectedTimepoint,
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_wasHeldAt",
    "EV"."PR_ID_wasPlayed",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "kETY_of"."ETY_EventType" AS "of_ETY_EventType",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Who",
    "DAT"."EV_DAT_Confidence",
    "DAT"."EV_DAT_Stance",
    "DAT"."EV_DAT_Event_Date",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Who",
    "AUD"."EV_AUD_Confidence",
    "AUD"."EV_AUD_Stance",
    "AUD"."EV_AUD_Event_Audience",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Who",
    "REV"."EV_REV_Confidence",
    "REV"."EV_REV_Stance",
    "REV"."EV_REV_Event_Revenue",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Who",
    "STA"."EV_STA_Confidence",
    "STA"."EV_STA_Stance",
    "STA"."EV_STA_Event_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Who",
    "UTL"."EV_UTL_Confidence",
    "UTL"."EV_UTL_Stance",
    "kUTL"."UTL_Utilization" AS "EV_UTL_UTL_Utilization",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Who",
    "LVL"."EV_LVL_Confidence",
    "LVL"."EV_LVL_Stance",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_ProfessionalLevel" AS "EV_LVL_PLV_ProfessionalLevel",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    dw."_Who" p
JOIN (
    SELECT DISTINCT
        "EV_STA_Who" AS positor,
        "EV_STA_EV_ID" AS "EV_ID",
        "EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."EV_STA_Event_Status"
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        "EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "EV_LVL_Who" AS positor,
        "EV_LVL_EV_ID" AS "EV_ID",
        "EV_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Event_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Who"
JOIN
    nexuses."EV_Event" "EV"
ON
    "EV"."EV_ID" = tp."EV_ID"
LEFT JOIN
    knots."ETY_EventType" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_DAT_Who", r."EV_DAT_EV_ID")
        r.*
    FROM
        attributes."rEV_DAT_Event_Date"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."EV_DAT_Stance" = '+'
    ORDER BY
    r."EV_DAT_Who", r."EV_DAT_EV_ID",
    r."EV_DAT_PositedAt" DESC,
    r."EV_DAT_Confidence" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
AND
    "DAT"."EV_DAT_Who" = tp.positor
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_AUD_Who", r."EV_AUD_EV_ID")
        r.*
    FROM
        attributes."rEV_AUD_Event_Audience"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."EV_AUD_Stance" = '+'
    ORDER BY
    r."EV_AUD_Who", r."EV_AUD_EV_ID",
    r."EV_AUD_PositedAt" DESC,
    r."EV_AUD_Confidence" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
AND
    "AUD"."EV_AUD_Who" = tp.positor
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_REV_Who", r."EV_REV_EV_ID")
        r.*
    FROM
        attributes."rEV_REV_Event_Revenue"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."EV_REV_Stance" = '+'
    ORDER BY
    r."EV_REV_Who", r."EV_REV_EV_ID",
    r."EV_REV_PositedAt" DESC,
    r."EV_REV_Confidence" DESC
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
AND
    "REV"."EV_REV_Who" = tp.positor
LEFT JOIN (
    SELECT
        y.*,
        lead(y."EV_STA_ChangedAt") OVER (
            PARTITION BY y."EV_STA_Who", y."EV_STA_EV_ID"
            ORDER BY y."EV_STA_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."EV_STA_Who", r."EV_STA_EV_ID", r."EV_STA_ChangedAt")
            r.*
        FROM
            attributes."rEV_STA_Event_Status"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."EV_STA_Stance" <> '?'
        ORDER BY
    r."EV_STA_Who", r."EV_STA_EV_ID", r."EV_STA_ChangedAt",
    CASE WHEN r."EV_STA_Stance" = '+' THEN 0 ELSE 1 END,
    r."EV_STA_PositedAt" DESC,
    r."EV_STA_Confidence" DESC
    ) y
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_Who" = tp.positor
AND
    "STA"."EV_STA_Stance" = '+'
AND
    "STA"."EV_STA_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > tp.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_UTL_Who", r."EV_UTL_EV_ID")
        r.*
    FROM
        attributes."rEV_UTL_Event_Utilization"(
            null::smallint,
            '9999-12-31'::timestamp(3)
        ) r
    WHERE
        r."EV_UTL_Stance" = '+'
    ORDER BY
    r."EV_UTL_Who", r."EV_UTL_EV_ID",
    r."EV_UTL_PositedAt" DESC,
    r."EV_UTL_Confidence" DESC
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
AND
    "UTL"."EV_UTL_Who" = tp.positor
LEFT JOIN
    knots."UTL_Utilization" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        y.*,
        lead(y."EV_LVL_ChangedAt") OVER (
            PARTITION BY y."EV_LVL_Who", y."EV_LVL_EV_ID"
            ORDER BY y."EV_LVL_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."EV_LVL_Who", r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt")
            r.*
        FROM
            attributes."rEV_LVL_Event_Level"(
                null::smallint,
                '9999-12-31'::date,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."EV_LVL_Stance" <> '?'
        ORDER BY
    r."EV_LVL_Who", r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt",
    CASE WHEN r."EV_LVL_Stance" = '+' THEN 0 ELSE 1 END,
    r."EV_LVL_PositedAt" DESC,
    r."EV_LVL_Confidence" DESC
    ) y
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_Who" = tp.positor
AND
    "LVL"."EV_LVL_Stance" = '+'
AND
    "LVL"."EV_LVL_ChangedAt" <= tp.inspectedTimepoint::date
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > tp.inspectedTimepoint::date
)
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- CRT ties use posit and annex split with changing/positing time, positor, reliability, and assertion.
--
CREATE SEQUENCE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Fact" (
    "AC_partner_AC_with_ONG_currently_ID" bigint default nextval('ties."AC_partner_AC_with_ONG_currently_Fact_ID_SEQ"') not null, 
    "AC_ID_partner" smallint not null, 
    "AC_ID_with" smallint not null, 
    "ONG_ID_currently" smallint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp not null,
    constraint "AC_partner_AC_with_ONG_currently_Fact_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Fact_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Fact_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Ongoing"("ONG_ID"),
    constraint "AC_partner_AC_with_ONG_currently_Fact_uqAC_partner" unique (
        "AC_ID_partner",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "AC_partner_AC_with_ONG_currently_Fact_uqAC_with" unique (
        "AC_ID_with",
        "AC_partner_AC_with_ONG_currently_ChangedAt"
    ),
    constraint "pkAC_partner_AC_with_ONG_currently_Fact" primary key (
        "AC_partner_AC_with_ONG_currently_ID"
    ),
    constraint "uqAC_partner_AC_with_ONG_currently" unique (
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently"
    )
);
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Meta" (
    "AC_partner_AC_with_ONG_currently_ID" bigint not null,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp(3) not null,
    "AC_partner_AC_with_ONG_currently_Who" smallint not null,
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3) not null,
    "AC_partner_AC_with_ONG_currently_Stance" char(1) generated always as (
        case
            when "AC_partner_AC_with_ONG_currently_Confidence" > 0.25 then '+'
            when "AC_partner_AC_with_ONG_currently_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_partner_AC_with_ONG_currently" bigint not null,
    constraint "fkAC_partner_AC_with_ONG_currently_Meta" foreign key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) references ties."AC_partner_AC_with_ONG_currently_Fact"("AC_partner_AC_with_ONG_currently_ID"),
    constraint "pkAC_partner_AC_with_ONG_currently_Meta" primary key (
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_Who",
        "AC_partner_AC_with_ONG_currently_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."AC_subset_PN_of_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Fact" (
    "AC_subset_PN_of_ID" bigint default nextval('ties."AC_subset_PN_of_Fact_ID_SEQ"') not null, 
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    constraint "AC_subset_PN_of_Fact_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_subset_PN_of_Fact_fkPN_of" foreign key (
        "PN_ID_of"
    ) references anchors."PN_Person"("PN_ID"), 
    constraint "AC_subset_PN_of_Fact_uqAC_subset" unique (
        "AC_ID_subset"
    ),
    constraint "AC_subset_PN_of_Fact_uqPN_of" unique (
        "PN_ID_of"
    ),
    constraint "pkAC_subset_PN_of_Fact" primary key (
        "AC_subset_PN_of_ID"
    ),
    constraint "uqAC_subset_PN_of" unique (
        "AC_ID_subset",
        "PN_ID_of"
    )
);
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Meta" (
    "AC_subset_PN_of_ID" bigint not null,
    "AC_subset_PN_of_PositedAt" timestamp(3) not null,
    "AC_subset_PN_of_Who" smallint not null,
    "AC_subset_PN_of_Confidence" decimal(7,3) not null,
    "AC_subset_PN_of_Stance" char(1) generated always as (
        case
            when "AC_subset_PN_of_Confidence" > 0.25 then '+'
            when "AC_subset_PN_of_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_subset_PN_of" bigint not null,
    constraint "fkAC_subset_PN_of_Meta" foreign key (
        "AC_subset_PN_of_ID"
    ) references ties."AC_subset_PN_of_Fact"("AC_subset_PN_of_ID"),
    constraint "pkAC_subset_PN_of_Meta" primary key (
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_Who",
        "AC_subset_PN_of_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."EV_in_AC_wasCast_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_wasCast_Fact" (
    "EV_in_AC_wasCast_ID" bigint default nextval('ties."EV_in_AC_wasCast_Fact_ID_SEQ"') not null, 
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_wasCast" smallint not null, 
    constraint "EV_in_AC_wasCast_Fact_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Event"("EV_ID"), 
    constraint "EV_in_AC_wasCast_Fact_fkAC_wasCast" foreign key (
        "AC_ID_wasCast"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "pkEV_in_AC_wasCast_Fact" primary key (
        "EV_in_AC_wasCast_ID"
    ),
    constraint "uqEV_in_AC_wasCast" unique (
        "EV_ID_in",
        "AC_ID_wasCast"
    )
);
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_wasCast_Meta" (
    "EV_in_AC_wasCast_ID" bigint not null,
    "EV_in_AC_wasCast_PositedAt" timestamp(3) not null,
    "EV_in_AC_wasCast_Who" smallint not null,
    "EV_in_AC_wasCast_Confidence" decimal(7,3) not null,
    "EV_in_AC_wasCast_Stance" char(1) generated always as (
        case
            when "EV_in_AC_wasCast_Confidence" > 0.25 then '+'
            when "EV_in_AC_wasCast_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_in_AC_wasCast" bigint not null,
    constraint "fkEV_in_AC_wasCast_Meta" foreign key (
        "EV_in_AC_wasCast_ID"
    ) references ties."EV_in_AC_wasCast_Fact"("EV_in_AC_wasCast_ID"),
    constraint "pkEV_in_AC_wasCast_Meta" primary key (
        "EV_in_AC_wasCast_ID",
        "EV_in_AC_wasCast_Who",
        "EV_in_AC_wasCast_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Fact" (
    "AC_part_PR_in_RAT_got_ID" bigint default nextval('ties."AC_part_PR_in_RAT_got_Fact_ID_SEQ"') not null, 
    "AC_ID_part" smallint not null, 
    "PR_ID_in" bigint not null, 
    "RAT_ID_got" smallint not null,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp not null,
    constraint "AC_part_PR_in_RAT_got_Fact_fkAC_part" foreign key (
        "AC_ID_part"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_part_PR_in_RAT_got_Fact_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "AC_part_PR_in_RAT_got_Fact_fkRAT_got" foreign key (
        "RAT_ID_got"
    ) references knots."RAT_Rating"("RAT_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Fact" primary key (
        "AC_part_PR_in_RAT_got_ID"
    ),
    constraint "uqAC_part_PR_in_RAT_got" unique (
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "RAT_ID_got"
    )
);
CREATE TABLE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Meta" (
    "AC_part_PR_in_RAT_got_ID" bigint not null,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp(3) not null,
    "AC_part_PR_in_RAT_got_Who" smallint not null,
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3) not null,
    "AC_part_PR_in_RAT_got_Stance" char(1) generated always as (
        case
            when "AC_part_PR_in_RAT_got_Confidence" > 0.25 then '+'
            when "AC_part_PR_in_RAT_got_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_part_PR_in_RAT_got" bigint not null,
    constraint "fkAC_part_PR_in_RAT_got_Meta" foreign key (
        "AC_part_PR_in_RAT_got_ID"
    ) references ties."AC_part_PR_in_RAT_got_Fact"("AC_part_PR_in_RAT_got_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Meta" primary key (
        "AC_part_PR_in_RAT_got_ID",
        "AC_part_PR_in_RAT_got_Who",
        "AC_part_PR_in_RAT_got_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."ST_at_PR_isPlaying_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_isPlaying_Fact" (
    "ST_at_PR_isPlaying_ID" bigint default nextval('ties."ST_at_PR_isPlaying_Fact_ID_SEQ"') not null, 
    "ST_ID_at" integer not null, 
    "PR_ID_isPlaying" bigint not null, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp not null,
    constraint "ST_at_PR_isPlaying_Fact_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "ST_at_PR_isPlaying_Fact_fkPR_isPlaying" foreign key (
        "PR_ID_isPlaying"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "pkST_at_PR_isPlaying_Fact" primary key (
        "ST_at_PR_isPlaying_ID"
    ),
    constraint "uqST_at_PR_isPlaying" unique (
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt"
    )
);
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_isPlaying_Meta" (
    "ST_at_PR_isPlaying_ID" bigint not null,
    "ST_at_PR_isPlaying_PositedAt" timestamp(3) not null,
    "ST_at_PR_isPlaying_Who" smallint not null,
    "ST_at_PR_isPlaying_Confidence" decimal(7,3) not null,
    "ST_at_PR_isPlaying_Stance" char(1) generated always as (
        case
            when "ST_at_PR_isPlaying_Confidence" > 0.25 then '+'
            when "ST_at_PR_isPlaying_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_ST_at_PR_isPlaying" bigint not null,
    constraint "fkST_at_PR_isPlaying_Meta" foreign key (
        "ST_at_PR_isPlaying_ID"
    ) references ties."ST_at_PR_isPlaying_Fact"("ST_at_PR_isPlaying_ID"),
    constraint "pkST_at_PR_isPlaying_Meta" primary key (
        "ST_at_PR_isPlaying_ID",
        "ST_at_PR_isPlaying_Who",
        "ST_at_PR_isPlaying_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Fact" (
    "AC_parent_AC_child_PAT_having_ID" bigint default nextval('ties."AC_parent_AC_child_PAT_having_Fact_ID_SEQ"') not null, 
    "AC_ID_parent" smallint not null, 
    "AC_ID_child" smallint not null, 
    "PAT_ID_having" smallint not null,
    constraint "AC_parent_AC_child_PAT_having_Fact_fkAC_parent" foreign key (
        "AC_ID_parent"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Fact_fkAC_child" foreign key (
        "AC_ID_child"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Fact_fkPAT_having" foreign key (
        "PAT_ID_having"
    ) references knots."PAT_ParentalType"("PAT_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Fact" primary key (
        "AC_parent_AC_child_PAT_having_ID"
    ),
    constraint "uqAC_parent_AC_child_PAT_having" unique (
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    )
);
CREATE TABLE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Meta" (
    "AC_parent_AC_child_PAT_having_ID" bigint not null,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp(3) not null,
    "AC_parent_AC_child_PAT_having_Who" smallint not null,
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3) not null,
    "AC_parent_AC_child_PAT_having_Stance" char(1) generated always as (
        case
            when "AC_parent_AC_child_PAT_having_Confidence" > 0.25 then '+'
            when "AC_parent_AC_child_PAT_having_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_AC_parent_AC_child_PAT_having" bigint not null,
    constraint "fkAC_parent_AC_child_PAT_having_Meta" foreign key (
        "AC_parent_AC_child_PAT_having_ID"
    ) references ties."AC_parent_AC_child_PAT_having_Fact"("AC_parent_AC_child_PAT_having_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Meta" primary key (
        "AC_parent_AC_child_PAT_having_ID",
        "AC_parent_AC_child_PAT_having_Who",
        "AC_parent_AC_child_PAT_having_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Fact_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Fact" (
    "PR_content_ST_location_EV_of_ID" bigint default nextval('ties."PR_content_ST_location_EV_of_Fact_ID_SEQ"') not null, 
    "PR_ID_content" bigint not null, 
    "ST_ID_location" integer not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_content_ST_location_EV_of_ChangedAt" timestamp not null,
    constraint "PR_content_ST_location_EV_of_Fact_fkPR_content" foreign key (
        "PR_ID_content"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "PR_content_ST_location_EV_of_Fact_fkST_location" foreign key (
        "ST_ID_location"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "PR_content_ST_location_EV_of_Fact_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Event"("EV_ID"), 
    constraint "PR_content_ST_location_EV_of_Fact_uqPR_content" unique (
        "PR_ID_content",
        "PR_content_ST_location_EV_of_ChangedAt"
    ),
    constraint "PR_content_ST_location_EV_of_Fact_uqST_location" unique (
        "ST_ID_location",
        "PR_content_ST_location_EV_of_ChangedAt"
    ),
    constraint "pkPR_content_ST_location_EV_of_Fact" primary key (
        "PR_content_ST_location_EV_of_ID"
    ),
    constraint "uqPR_content_ST_location_EV_of" unique (
        "PR_content_ST_location_EV_of_ChangedAt",
        "PR_ID_content",
        "ST_ID_location",
        "EV_ID_of"
    )
);
CREATE TABLE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Meta" (
    "PR_content_ST_location_EV_of_ID" bigint not null,
    "PR_content_ST_location_EV_of_PositedAt" timestamp(3) not null,
    "PR_content_ST_location_EV_of_Who" smallint not null,
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3) not null,
    "PR_content_ST_location_EV_of_Stance" char(1) generated always as (
        case
            when "PR_content_ST_location_EV_of_Confidence" > 0.25 then '+'
            when "PR_content_ST_location_EV_of_Confidence" = 0.25 then '?'
            else '-'
        end
    ) stored,
    "Metadata_PR_content_ST_location_EV_of" bigint not null,
    constraint "fkPR_content_ST_location_EV_of_Meta" foreign key (
        "PR_content_ST_location_EV_of_ID"
    ) references ties."PR_content_ST_location_EV_of_Fact"("PR_content_ST_location_EV_of_ID"),
    constraint "pkPR_content_ST_location_EV_of_Meta" primary key (
        "PR_content_ST_location_EV_of_ID",
        "PR_content_ST_location_EV_of_Who",
        "PR_content_ST_location_EV_of_PositedAt"
    )
);
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW ties."AC_partner_AC_with_ONG_currently" AS
SELECT
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Who",
    a."AC_partner_AC_with_ONG_currently_Confidence",
    a."AC_partner_AC_with_ONG_currently_Stance"
FROM
    ties."AC_partner_AC_with_ONG_currently_Fact" p
JOIN
    ties."AC_partner_AC_with_ONG_currently_Meta" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
;
CREATE OR REPLACE VIEW ties."AC_subset_PN_of" AS
SELECT
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Who",
    a."AC_subset_PN_of_Confidence",
    a."AC_subset_PN_of_Stance"
FROM
    ties."AC_subset_PN_of_Fact" p
JOIN
    ties."AC_subset_PN_of_Meta" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
;
CREATE OR REPLACE VIEW ties."EV_in_AC_wasCast" AS
SELECT
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Who",
    a."EV_in_AC_wasCast_Confidence",
    a."EV_in_AC_wasCast_Stance"
FROM
    ties."EV_in_AC_wasCast_Fact" p
JOIN
    ties."EV_in_AC_wasCast_Meta" a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
;
CREATE OR REPLACE VIEW ties."AC_part_PR_in_RAT_got" AS
SELECT
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Who",
    a."AC_part_PR_in_RAT_got_Confidence",
    a."AC_part_PR_in_RAT_got_Stance"
FROM
    ties."AC_part_PR_in_RAT_got_Fact" p
JOIN
    ties."AC_part_PR_in_RAT_got_Meta" a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
;
CREATE OR REPLACE VIEW ties."ST_at_PR_isPlaying" AS
SELECT
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Who",
    a."ST_at_PR_isPlaying_Confidence",
    a."ST_at_PR_isPlaying_Stance"
FROM
    ties."ST_at_PR_isPlaying_Fact" p
JOIN
    ties."ST_at_PR_isPlaying_Meta" a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
;
CREATE OR REPLACE VIEW ties."AC_parent_AC_child_PAT_having" AS
SELECT
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Who",
    a."AC_parent_AC_child_PAT_having_Confidence",
    a."AC_parent_AC_child_PAT_having_Stance"
FROM
    ties."AC_parent_AC_child_PAT_having_Fact" p
JOIN
    ties."AC_parent_AC_child_PAT_having_Meta" a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
;
CREATE OR REPLACE VIEW ties."PR_content_ST_location_EV_of" AS
SELECT
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    p."PR_content_ST_location_EV_of_ChangedAt",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Who",
    a."PR_content_ST_location_EV_of_Confidence",
    a."PR_content_ST_location_EV_of_Stance"
FROM
    ties."PR_content_ST_location_EV_of_Fact" p
JOIN
    ties."PR_content_ST_location_EV_of_Meta" a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- CRT rewinders over changing and positing time with positor-aware annex selection: the view of the positor given,
-- or of all of them for null.
--
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
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
    ties."AC_partner_AC_with_ONG_currently_Fact"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
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
    ties."AC_partner_AC_with_ONG_currently_Fact"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp(3),
    "AC_partner_AC_with_ONG_currently_Who" smallint,
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_partner_AC_with_ONG_currently_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_partner_AC_with_ONG_currently_PositedAt",
    "AC_partner_AC_with_ONG_currently_Who",
    "AC_partner_AC_with_ONG_currently_Confidence",
    "AC_partner_AC_with_ONG_currently_Stance"
FROM
    ties."AC_partner_AC_with_ONG_currently_Meta"
WHERE
    "AC_partner_AC_with_ONG_currently_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp(3),
    "AC_partner_AC_with_ONG_currently_Who" smallint,
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_partner_AC_with_ONG_currently_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Who")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Who",
    a."AC_partner_AC_with_ONG_currently_Confidence",
    a."AC_partner_AC_with_ONG_currently_Stance"
FROM
    ties."rAC_partner_AC_with_ONG_currently_Fact"(changingTimepoint) p 
JOIN
    ties."rAC_partner_AC_with_ONG_currently_Meta"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Who" = coalesce(positor, a."AC_partner_AC_with_ONG_currently_Who")
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Who",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_partner_AC_with_ONG_currently_ID" bigint,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp(3),
    "AC_partner_AC_with_ONG_currently_Who" smallint,
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_partner_AC_with_ONG_currently_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Who")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Who",
    a."AC_partner_AC_with_ONG_currently_Confidence",
    a."AC_partner_AC_with_ONG_currently_Stance"
FROM
    ties."fAC_partner_AC_with_ONG_currently_Fact"(changingTimepoint) p 
JOIN
    ties."rAC_partner_AC_with_ONG_currently_Meta"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
AND
    a."AC_partner_AC_with_ONG_currently_Who" = coalesce(positor, a."AC_partner_AC_with_ONG_currently_Who")
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID", a."AC_partner_AC_with_ONG_currently_Who",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" bigint,
    "AC_subset_PN_of_ID" bigint,
    "AC_subset_PN_of_PositedAt" timestamp(3),
    "AC_subset_PN_of_Who" smallint,
    "AC_subset_PN_of_Confidence" decimal(7,3),
    "AC_subset_PN_of_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_subset_PN_of",
    "AC_subset_PN_of_ID",
    "AC_subset_PN_of_PositedAt",
    "AC_subset_PN_of_Who",
    "AC_subset_PN_of_Confidence",
    "AC_subset_PN_of_Stance"
FROM
    ties."AC_subset_PN_of_Meta"
WHERE
    "AC_subset_PN_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" bigint,
    "AC_subset_PN_of_ID" bigint,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" timestamp(3),
    "AC_subset_PN_of_Who" smallint,
    "AC_subset_PN_of_Confidence" decimal(7,3),
    "AC_subset_PN_of_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Who")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Who",
    a."AC_subset_PN_of_Confidence",
    a."AC_subset_PN_of_Stance"
FROM
    ties."AC_subset_PN_of_Fact" p
JOIN
    ties."rAC_subset_PN_of_Meta"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Who" = coalesce(positor, a."AC_subset_PN_of_Who")
ORDER BY
    p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Who",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_subset_PN_of" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" bigint,
    "AC_subset_PN_of_ID" bigint,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" timestamp(3),
    "AC_subset_PN_of_Who" smallint,
    "AC_subset_PN_of_Confidence" decimal(7,3),
    "AC_subset_PN_of_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Who")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Who",
    a."AC_subset_PN_of_Confidence",
    a."AC_subset_PN_of_Stance"
FROM
    ties."AC_subset_PN_of_Fact" p
JOIN
    ties."rAC_subset_PN_of_Meta"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
AND
    a."AC_subset_PN_of_Who" = coalesce(positor, a."AC_subset_PN_of_Who")
ORDER BY
    p."AC_subset_PN_of_ID", a."AC_subset_PN_of_Who",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_wasCast_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_in_AC_wasCast_ID" bigint,
    "EV_in_AC_wasCast_PositedAt" timestamp(3),
    "EV_in_AC_wasCast_Who" smallint,
    "EV_in_AC_wasCast_Confidence" decimal(7,3),
    "EV_in_AC_wasCast_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_EV_in_AC_wasCast",
    "EV_in_AC_wasCast_ID",
    "EV_in_AC_wasCast_PositedAt",
    "EV_in_AC_wasCast_Who",
    "EV_in_AC_wasCast_Confidence",
    "EV_in_AC_wasCast_Stance"
FROM
    ties."EV_in_AC_wasCast_Meta"
WHERE
    "EV_in_AC_wasCast_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_wasCast" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_in_AC_wasCast_ID" bigint,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_wasCast" smallint, 
    "EV_in_AC_wasCast_PositedAt" timestamp(3),
    "EV_in_AC_wasCast_Who" smallint,
    "EV_in_AC_wasCast_Confidence" decimal(7,3),
    "EV_in_AC_wasCast_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Who")
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Who",
    a."EV_in_AC_wasCast_Confidence",
    a."EV_in_AC_wasCast_Stance"
FROM
    ties."EV_in_AC_wasCast_Fact" p
JOIN
    ties."rEV_in_AC_wasCast_Meta"(positingTimepoint) a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
AND
    a."EV_in_AC_wasCast_Who" = coalesce(positor, a."EV_in_AC_wasCast_Who")
ORDER BY
    p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Who",
    a."EV_in_AC_wasCast_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fEV_in_AC_wasCast" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_in_AC_wasCast_ID" bigint,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_wasCast" smallint, 
    "EV_in_AC_wasCast_PositedAt" timestamp(3),
    "EV_in_AC_wasCast_Who" smallint,
    "EV_in_AC_wasCast_Confidence" decimal(7,3),
    "EV_in_AC_wasCast_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Who")
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Who",
    a."EV_in_AC_wasCast_Confidence",
    a."EV_in_AC_wasCast_Stance"
FROM
    ties."EV_in_AC_wasCast_Fact" p
JOIN
    ties."rEV_in_AC_wasCast_Meta"(positingTimepoint) a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
AND
    a."EV_in_AC_wasCast_Who" = coalesce(positor, a."EV_in_AC_wasCast_Who")
ORDER BY
    p."EV_in_AC_wasCast_ID", a."EV_in_AC_wasCast_Who",
    a."EV_in_AC_wasCast_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_part_PR_in_RAT_got_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" bigint,
    "AC_ID_part" smallint, 
    "PR_ID_in" bigint, 
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
    ties."AC_part_PR_in_RAT_got_Fact"
WHERE
    "AC_part_PR_in_RAT_got_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_part_PR_in_RAT_got_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_part_PR_in_RAT_got_ID" bigint,
    "AC_ID_part" smallint, 
    "PR_ID_in" bigint, 
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
    ties."AC_part_PR_in_RAT_got_Fact"
WHERE
    "AC_part_PR_in_RAT_got_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_part_PR_in_RAT_got_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ID" bigint,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp(3),
    "AC_part_PR_in_RAT_got_Who" smallint,
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_part_PR_in_RAT_got_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_part_PR_in_RAT_got",
    "AC_part_PR_in_RAT_got_ID",
    "AC_part_PR_in_RAT_got_PositedAt",
    "AC_part_PR_in_RAT_got_Who",
    "AC_part_PR_in_RAT_got_Confidence",
    "AC_part_PR_in_RAT_got_Stance"
FROM
    ties."AC_part_PR_in_RAT_got_Meta"
WHERE
    "AC_part_PR_in_RAT_got_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ID" bigint,
    "AC_ID_part" smallint, 
    "PR_ID_in" bigint, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp(3),
    "AC_part_PR_in_RAT_got_Who" smallint,
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_part_PR_in_RAT_got_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Who")
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Who",
    a."AC_part_PR_in_RAT_got_Confidence",
    a."AC_part_PR_in_RAT_got_Stance"
FROM
    ties."rAC_part_PR_in_RAT_got_Fact"(changingTimepoint) p 
JOIN
    ties."rAC_part_PR_in_RAT_got_Meta"(positingTimepoint) a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
AND
    a."AC_part_PR_in_RAT_got_Who" = coalesce(positor, a."AC_part_PR_in_RAT_got_Who")
ORDER BY
    p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Who",
    a."AC_part_PR_in_RAT_got_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_part_PR_in_RAT_got_ID" bigint,
    "AC_ID_part" smallint, 
    "PR_ID_in" bigint, 
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp(3),
    "AC_part_PR_in_RAT_got_Who" smallint,
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_part_PR_in_RAT_got_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Who")
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Who",
    a."AC_part_PR_in_RAT_got_Confidence",
    a."AC_part_PR_in_RAT_got_Stance"
FROM
    ties."fAC_part_PR_in_RAT_got_Fact"(changingTimepoint) p 
JOIN
    ties."rAC_part_PR_in_RAT_got_Meta"(positingTimepoint) a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
AND
    a."AC_part_PR_in_RAT_got_Who" = coalesce(positor, a."AC_part_PR_in_RAT_got_Who")
ORDER BY
    p."AC_part_PR_in_RAT_got_ID", a."AC_part_PR_in_RAT_got_Who",
    a."AC_part_PR_in_RAT_got_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_isPlaying_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" bigint,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" bigint, 
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
    ties."ST_at_PR_isPlaying_Fact"
WHERE
    "ST_at_PR_isPlaying_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_isPlaying_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_isPlaying_ID" bigint,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" bigint, 
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
    ties."ST_at_PR_isPlaying_Fact"
WHERE
    "ST_at_PR_isPlaying_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_isPlaying_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ID" bigint,
    "ST_at_PR_isPlaying_PositedAt" timestamp(3),
    "ST_at_PR_isPlaying_Who" smallint,
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_at_PR_isPlaying_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_ST_at_PR_isPlaying",
    "ST_at_PR_isPlaying_ID",
    "ST_at_PR_isPlaying_PositedAt",
    "ST_at_PR_isPlaying_Who",
    "ST_at_PR_isPlaying_Confidence",
    "ST_at_PR_isPlaying_Stance"
FROM
    ties."ST_at_PR_isPlaying_Meta"
WHERE
    "ST_at_PR_isPlaying_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ID" bigint,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" bigint, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp(3),
    "ST_at_PR_isPlaying_Who" smallint,
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_at_PR_isPlaying_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Who")
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Who",
    a."ST_at_PR_isPlaying_Confidence",
    a."ST_at_PR_isPlaying_Stance"
FROM
    ties."rST_at_PR_isPlaying_Fact"(changingTimepoint) p 
JOIN
    ties."rST_at_PR_isPlaying_Meta"(positingTimepoint) a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
AND
    a."ST_at_PR_isPlaying_Who" = coalesce(positor, a."ST_at_PR_isPlaying_Who")
ORDER BY
    p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Who",
    a."ST_at_PR_isPlaying_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_at_PR_isPlaying_ID" bigint,
    "ST_ID_at" integer, 
    "PR_ID_isPlaying" bigint, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp(3),
    "ST_at_PR_isPlaying_Who" smallint,
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_at_PR_isPlaying_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Who")
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Who",
    a."ST_at_PR_isPlaying_Confidence",
    a."ST_at_PR_isPlaying_Stance"
FROM
    ties."fST_at_PR_isPlaying_Fact"(changingTimepoint) p 
JOIN
    ties."rST_at_PR_isPlaying_Meta"(positingTimepoint) a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
AND
    a."ST_at_PR_isPlaying_Who" = coalesce(positor, a."ST_at_PR_isPlaying_Who")
ORDER BY
    p."ST_at_PR_isPlaying_ID", a."ST_at_PR_isPlaying_Who",
    a."ST_at_PR_isPlaying_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_parent_AC_child_PAT_having_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_parent_AC_child_PAT_having_ID" bigint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp(3),
    "AC_parent_AC_child_PAT_having_Who" smallint,
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3),
    "AC_parent_AC_child_PAT_having_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_AC_parent_AC_child_PAT_having",
    "AC_parent_AC_child_PAT_having_ID",
    "AC_parent_AC_child_PAT_having_PositedAt",
    "AC_parent_AC_child_PAT_having_Who",
    "AC_parent_AC_child_PAT_having_Confidence",
    "AC_parent_AC_child_PAT_having_Stance"
FROM
    ties."AC_parent_AC_child_PAT_having_Meta"
WHERE
    "AC_parent_AC_child_PAT_having_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_parent_AC_child_PAT_having" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_parent_AC_child_PAT_having_ID" bigint,
    "AC_ID_parent" smallint, 
    "AC_ID_child" smallint, 
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp(3),
    "AC_parent_AC_child_PAT_having_Who" smallint,
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3),
    "AC_parent_AC_child_PAT_having_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Who")
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Who",
    a."AC_parent_AC_child_PAT_having_Confidence",
    a."AC_parent_AC_child_PAT_having_Stance"
FROM
    ties."AC_parent_AC_child_PAT_having_Fact" p
JOIN
    ties."rAC_parent_AC_child_PAT_having_Meta"(positingTimepoint) a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
AND
    a."AC_parent_AC_child_PAT_having_Who" = coalesce(positor, a."AC_parent_AC_child_PAT_having_Who")
ORDER BY
    p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Who",
    a."AC_parent_AC_child_PAT_having_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_parent_AC_child_PAT_having" (
    positor smallint,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_parent_AC_child_PAT_having_ID" bigint,
    "AC_ID_parent" smallint, 
    "AC_ID_child" smallint, 
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp(3),
    "AC_parent_AC_child_PAT_having_Who" smallint,
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3),
    "AC_parent_AC_child_PAT_having_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Who")
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Who",
    a."AC_parent_AC_child_PAT_having_Confidence",
    a."AC_parent_AC_child_PAT_having_Stance"
FROM
    ties."AC_parent_AC_child_PAT_having_Fact" p
JOIN
    ties."rAC_parent_AC_child_PAT_having_Meta"(positingTimepoint) a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
AND
    a."AC_parent_AC_child_PAT_having_Who" = coalesce(positor, a."AC_parent_AC_child_PAT_having_Who")
ORDER BY
    p."AC_parent_AC_child_PAT_having_ID", a."AC_parent_AC_child_PAT_having_Who",
    a."AC_parent_AC_child_PAT_having_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rPR_content_ST_location_EV_of_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_content_ST_location_EV_of_ID" bigint,
    "PR_ID_content" bigint, 
    "ST_ID_location" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_content_ST_location_EV_of_ChangedAt" timestamp
)
AS
$$
SELECT
    "PR_content_ST_location_EV_of_ID",
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of",
    "PR_content_ST_location_EV_of_ChangedAt"
FROM
    ties."PR_content_ST_location_EV_of_Fact"
WHERE
    "PR_content_ST_location_EV_of_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fPR_content_ST_location_EV_of_Fact" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_content_ST_location_EV_of_ID" bigint,
    "PR_ID_content" bigint, 
    "ST_ID_location" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_content_ST_location_EV_of_ChangedAt" timestamp
)
AS
$$
SELECT
    "PR_content_ST_location_EV_of_ID",
    "PR_ID_content",
    "ST_ID_location",
    "EV_ID_of",
    "PR_content_ST_location_EV_of_ChangedAt"
FROM
    ties."PR_content_ST_location_EV_of_Fact"
WHERE
    "PR_content_ST_location_EV_of_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rPR_content_ST_location_EV_of_Meta" (
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ID" bigint,
    "PR_content_ST_location_EV_of_PositedAt" timestamp(3),
    "PR_content_ST_location_EV_of_Who" smallint,
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_content_ST_location_EV_of_Stance" char(1)
)
AS
$$
SELECT
    "Metadata_PR_content_ST_location_EV_of",
    "PR_content_ST_location_EV_of_ID",
    "PR_content_ST_location_EV_of_PositedAt",
    "PR_content_ST_location_EV_of_Who",
    "PR_content_ST_location_EV_of_Confidence",
    "PR_content_ST_location_EV_of_Stance"
FROM
    ties."PR_content_ST_location_EV_of_Meta"
WHERE
    "PR_content_ST_location_EV_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rPR_content_ST_location_EV_of" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ID" bigint,
    "PR_ID_content" bigint, 
    "ST_ID_location" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_content_ST_location_EV_of_PositedAt" timestamp(3),
    "PR_content_ST_location_EV_of_Who" smallint,
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_content_ST_location_EV_of_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Who")
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    p."PR_content_ST_location_EV_of_ChangedAt",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Who",
    a."PR_content_ST_location_EV_of_Confidence",
    a."PR_content_ST_location_EV_of_Stance"
FROM
    ties."rPR_content_ST_location_EV_of_Fact"(changingTimepoint) p 
JOIN
    ties."rPR_content_ST_location_EV_of_Meta"(positingTimepoint) a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
AND
    a."PR_content_ST_location_EV_of_Who" = coalesce(positor, a."PR_content_ST_location_EV_of_Who")
ORDER BY
    p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Who",
    a."PR_content_ST_location_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fPR_content_ST_location_EV_of" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3)
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_content_ST_location_EV_of_ID" bigint,
    "PR_ID_content" bigint, 
    "ST_ID_location" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_content_ST_location_EV_of_PositedAt" timestamp(3),
    "PR_content_ST_location_EV_of_Who" smallint,
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_content_ST_location_EV_of_Stance" char(1)
)
AS
$$
SELECT DISTINCT ON (p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Who")
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    p."PR_content_ST_location_EV_of_ChangedAt",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Who",
    a."PR_content_ST_location_EV_of_Confidence",
    a."PR_content_ST_location_EV_of_Stance"
FROM
    ties."fPR_content_ST_location_EV_of_Fact"(changingTimepoint) p 
JOIN
    ties."rPR_content_ST_location_EV_of_Meta"(positingTimepoint) a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
AND
    a."PR_content_ST_location_EV_of_Who" = coalesce(positor, a."PR_content_ST_location_EV_of_Who")
ORDER BY
    p."PR_content_ST_location_EV_of_ID", a."PR_content_ST_location_EV_of_Who",
    a."PR_content_ST_location_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- CRT tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_partner_AC_with_ONG_currently" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp(3),
    "AC_partner_AC_with_ONG_currently_Who" smallint,
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_partner_AC_with_ONG_currently_Stance" char(1)
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
    t."AC_partner_AC_with_ONG_currently_Who",
    t."AC_partner_AC_with_ONG_currently_Confidence",
    t."AC_partner_AC_with_ONG_currently_Stance"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Who", s."AC_ID_partner"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Confidence" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY s."AC_partner_AC_with_ONG_currently_Who", s."AC_ID_with"
            ORDER BY
                s."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                s."AC_partner_AC_with_ONG_currently_Confidence" DESC,
                s."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_partner_AC_with_ONG_currently_Stance" <> '?' THEN r."AC_partner_AC_with_ONG_currently_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_partner_AC_with_ONG_currently_Who",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently"
            ) AS "inEffect"
        FROM
            ties."rAC_partner_AC_with_ONG_currently"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) s
    WHERE
        s."AC_partner_AC_with_ONG_currently_Stance" = coalesce(assertion, s."AC_partner_AC_with_ONG_currently_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."AC_partner_AC_with_ONG_currently_ChangedAt" = s."inEffect"
    )
) t
LEFT JOIN
    knots."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."AC_partner_AC_with_ONG_currently_Who" = positor
AND
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_partner_AC_with_ONG_currently"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp(3),
    "AC_partner_AC_with_ONG_currently_Who" smallint,
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_partner_AC_with_ONG_currently_Stance" char(1)
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Ongoing",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Who",
    t."AC_partner_AC_with_ONG_currently_Confidence",
    t."AC_partner_AC_with_ONG_currently_Stance"
FROM
    dw."_Who" p,
    ties."tAC_partner_AC_with_ONG_currently"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_partner_AC_with_ONG_currently"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "Metadata_AC_partner_AC_with_ONG_currently" bigint,
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Ongoing" varchar(3),
    "currently_Metadata_ONG" bigint,
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp(3),
    "AC_partner_AC_with_ONG_currently_Who" smallint,
    "AC_partner_AC_with_ONG_currently_Confidence" decimal(7,3),
    "AC_partner_AC_with_ONG_currently_Stance" char(1)
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
    q."Who",
    q.inspectedTimepoint,
    q."Metadata_AC_partner_AC_with_ONG_currently",
    q."AC_ID_partner",
    q."AC_ID_with",
    q."currently_ONG_Ongoing",
    q."currently_Metadata_ONG",
    q."ONG_ID_currently",
    q."AC_partner_AC_with_ONG_currently_ChangedAt",
    q."AC_partner_AC_with_ONG_currently_PositedAt",
    q."AC_partner_AC_with_ONG_currently_Who",
    q."AC_partner_AC_with_ONG_currently_Confidence",
    q."AC_partner_AC_with_ONG_currently_Stance"
FROM (
SELECT
    p."Who",
    tp.inspectedTimepoint,
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Who",
    t."AC_partner_AC_with_ONG_currently_Confidence",
    t."AC_partner_AC_with_ONG_currently_Stance",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."AC_ID_partner"
        ORDER BY
            t."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_Confidence" DESC,
            t."AC_partner_AC_with_ONG_currently_ID" DESC
    ) AS "latestAC_ID_partner",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."AC_ID_with"
        ORDER BY
            t."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
            t."AC_partner_AC_with_ONG_currently_Confidence" DESC,
            t."AC_partner_AC_with_ONG_currently_ID" DESC
    ) AS "latestAC_ID_with"
FROM
    dw."_Who" p
JOIN (
    SELECT DISTINCT
        "AC_partner_AC_with_ONG_currently_Who" AS positor,
        "AC_partner_AC_with_ONG_currently_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        ties."AC_partner_AC_with_ONG_currently"
    WHERE
        "AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Who"
JOIN (
    SELECT
        y.*,
        lead(y."AC_partner_AC_with_ONG_currently_ChangedAt") OVER (
            PARTITION BY
                y."AC_partner_AC_with_ONG_currently_Who",
                y."AC_ID_partner",
                y."AC_ID_with",
                y."ONG_ID_currently"
            ORDER BY y."AC_partner_AC_with_ONG_currently_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_partner_AC_with_ONG_currently_Who",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently",
                    r."AC_partner_AC_with_ONG_currently_ChangedAt")
            r.*
        FROM
            ties."rAC_partner_AC_with_ONG_currently"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."AC_partner_AC_with_ONG_currently_Stance" <> '?'
        ORDER BY
    r."AC_partner_AC_with_ONG_currently_Who",
                    r."AC_ID_partner",
                    r."AC_ID_with",
                    r."ONG_ID_currently",
                    r."AC_partner_AC_with_ONG_currently_ChangedAt",
    CASE WHEN r."AC_partner_AC_with_ONG_currently_Stance" = '+' THEN 0 ELSE 1 END,
    r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
    r."AC_partner_AC_with_ONG_currently_Confidence" DESC,
    r."AC_partner_AC_with_ONG_currently_ID" DESC
    ) y
) t
ON
    t."AC_partner_AC_with_ONG_currently_Who" = tp.positor
AND
    t."AC_partner_AC_with_ONG_currently_Stance" = '+'
AND
    t."AC_partner_AC_with_ONG_currently_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."ONG_Ongoing" "kONG_currently"
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
CREATE OR REPLACE FUNCTION ties."tAC_subset_PN_of" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" bigint,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint,
    "AC_subset_PN_of_PositedAt" timestamp(3),
    "AC_subset_PN_of_Who" smallint,
    "AC_subset_PN_of_Confidence" decimal(7,3),
    "AC_subset_PN_of_Stance" char(1)
)
AS
$$
SELECT
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Who",
    t."AC_subset_PN_of_Confidence",
    t."AC_subset_PN_of_Stance"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Who", s."AC_ID_subset"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Confidence" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY s."AC_subset_PN_of_Who", s."PN_ID_of"
            ORDER BY
                s."AC_subset_PN_of_PositedAt" DESC,
                s."AC_subset_PN_of_Confidence" DESC,
                s."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM (
        SELECT
            r.*
        FROM
            ties."rAC_subset_PN_of"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) s
    WHERE
        s."AC_subset_PN_of_Stance" = coalesce(assertion, s."AC_subset_PN_of_Stance")
) t
WHERE
    t."AC_subset_PN_of_Who" = positor
AND
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_subset_PN_of"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "Metadata_AC_subset_PN_of" bigint,
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint,
    "AC_subset_PN_of_PositedAt" timestamp(3),
    "AC_subset_PN_of_Who" smallint,
    "AC_subset_PN_of_Confidence" decimal(7,3),
    "AC_subset_PN_of_Stance" char(1)
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t."Metadata_AC_subset_PN_of",
    t."AC_ID_subset",
    t."PN_ID_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Who",
    t."AC_subset_PN_of_Confidence",
    t."AC_subset_PN_of_Stance"
FROM
    dw."_Who" p,
    ties."tAC_subset_PN_of"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_subset_PN_of"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tEV_in_AC_wasCast" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint,
    "EV_in_AC_wasCast_PositedAt" timestamp(3),
    "EV_in_AC_wasCast_Who" smallint,
    "EV_in_AC_wasCast_Confidence" decimal(7,3),
    "EV_in_AC_wasCast_Stance" char(1)
)
AS
$$
SELECT
    t."Metadata_EV_in_AC_wasCast",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Who",
    t."EV_in_AC_wasCast_Confidence",
    t."EV_in_AC_wasCast_Stance"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."EV_in_AC_wasCast_Who",
                s."EV_ID_in",
                s."AC_ID_wasCast"
            ORDER BY
                s."EV_in_AC_wasCast_PositedAt" DESC,
                s."EV_in_AC_wasCast_Confidence" DESC,
                s."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            ties."rEV_in_AC_wasCast"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) s
    WHERE
        s."EV_in_AC_wasCast_Stance" = coalesce(assertion, s."EV_in_AC_wasCast_Stance")
) t
WHERE
    t."EV_in_AC_wasCast_Who" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lEV_in_AC_wasCast" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tEV_in_AC_wasCast"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_wasCast" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "Metadata_EV_in_AC_wasCast" bigint,
    "EV_ID_in" numeric(12,0),
    "AC_ID_wasCast" smallint,
    "EV_in_AC_wasCast_PositedAt" timestamp(3),
    "EV_in_AC_wasCast_Who" smallint,
    "EV_in_AC_wasCast_Confidence" decimal(7,3),
    "EV_in_AC_wasCast_Stance" char(1)
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_ID_in",
    t."AC_ID_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Who",
    t."EV_in_AC_wasCast_Confidence",
    t."EV_in_AC_wasCast_Stance"
FROM
    dw."_Who" p,
    ties."tEV_in_AC_wasCast"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nEV_in_AC_wasCast" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tEV_in_AC_wasCast"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tAC_part_PR_in_RAT_got" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp(3),
    "AC_part_PR_in_RAT_got_Who" smallint,
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_part_PR_in_RAT_got_Stance" char(1)
)
AS
$$
SELECT
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Who",
    t."AC_part_PR_in_RAT_got_Confidence",
    t."AC_part_PR_in_RAT_got_Stance"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_part_PR_in_RAT_got_Who",
                s."AC_ID_part",
                s."PR_ID_in"
            ORDER BY
                s."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                s."AC_part_PR_in_RAT_got_PositedAt" DESC,
                s."AC_part_PR_in_RAT_got_Confidence" DESC,
                s."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."AC_part_PR_in_RAT_got_Stance" <> '?' THEN r."AC_part_PR_in_RAT_got_ChangedAt" END) OVER (
                PARTITION BY
                    r."AC_part_PR_in_RAT_got_Who",
                    r."AC_ID_part",
                    r."PR_ID_in"
            ) AS "inEffect"
        FROM
            ties."rAC_part_PR_in_RAT_got"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) s
    WHERE
        s."AC_part_PR_in_RAT_got_Stance" = coalesce(assertion, s."AC_part_PR_in_RAT_got_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."AC_part_PR_in_RAT_got_ChangedAt" = s."inEffect"
    )
) t
LEFT JOIN
    knots."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."AC_part_PR_in_RAT_got_Who" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_part_PR_in_RAT_got" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_part_PR_in_RAT_got"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_part_PR_in_RAT_got" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp(3),
    "AC_part_PR_in_RAT_got_Who" smallint,
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_part_PR_in_RAT_got_Stance" char(1)
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    t."got_RAT_Checksum",
    t."got_RAT_Rating",
    t."got_Metadata_RAT",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Who",
    t."AC_part_PR_in_RAT_got_Confidence",
    t."AC_part_PR_in_RAT_got_Stance"
FROM
    dw."_Who" p,
    ties."tAC_part_PR_in_RAT_got"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_part_PR_in_RAT_got" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_part_PR_in_RAT_got"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dAC_part_PR_in_RAT_got" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "Metadata_AC_part_PR_in_RAT_got" bigint,
    "AC_ID_part" smallint,
    "PR_ID_in" bigint,
    "got_RAT_Checksum" bytea,
    "got_RAT_Rating" varchar(42),
    "got_Metadata_RAT" bigint,
    "RAT_ID_got" smallint,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp(3),
    "AC_part_PR_in_RAT_got_Who" smallint,
    "AC_part_PR_in_RAT_got_Confidence" decimal(7,3),
    "AC_part_PR_in_RAT_got_Stance" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Who",
    tp.inspectedTimepoint,
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Checksum" AS "got_RAT_Checksum",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Who",
    t."AC_part_PR_in_RAT_got_Confidence",
    t."AC_part_PR_in_RAT_got_Stance"
FROM
    dw."_Who" p
JOIN (
    SELECT DISTINCT
        "AC_part_PR_in_RAT_got_Who" AS positor,
        "AC_part_PR_in_RAT_got_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        ties."AC_part_PR_in_RAT_got"
    WHERE
        "AC_part_PR_in_RAT_got_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Who"
JOIN (
    SELECT
        y.*,
        lead(y."AC_part_PR_in_RAT_got_ChangedAt") OVER (
            PARTITION BY
                y."AC_part_PR_in_RAT_got_Who",
                y."AC_ID_part",
                y."PR_ID_in"
            ORDER BY y."AC_part_PR_in_RAT_got_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."AC_part_PR_in_RAT_got_Who",
                    r."AC_ID_part",
                    r."PR_ID_in",
                    r."AC_part_PR_in_RAT_got_ChangedAt")
            r.*
        FROM
            ties."rAC_part_PR_in_RAT_got"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."AC_part_PR_in_RAT_got_Stance" <> '?'
        ORDER BY
    r."AC_part_PR_in_RAT_got_Who",
                    r."AC_ID_part",
                    r."PR_ID_in",
                    r."AC_part_PR_in_RAT_got_ChangedAt",
    CASE WHEN r."AC_part_PR_in_RAT_got_Stance" = '+' THEN 0 ELSE 1 END,
    r."AC_part_PR_in_RAT_got_PositedAt" DESC,
    r."AC_part_PR_in_RAT_got_Confidence" DESC,
    r."AC_part_PR_in_RAT_got_ID" DESC
    ) y
) t
ON
    t."AC_part_PR_in_RAT_got_Who" = tp.positor
AND
    t."AC_part_PR_in_RAT_got_Stance" = '+'
AND
    t."AC_part_PR_in_RAT_got_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
$$ LANGUAGE sql STABLE;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tST_at_PR_isPlaying" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp(3),
    "ST_at_PR_isPlaying_Who" smallint,
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_at_PR_isPlaying_Stance" char(1)
)
AS
$$
SELECT
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Who",
    t."ST_at_PR_isPlaying_Confidence",
    t."ST_at_PR_isPlaying_Stance"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."ST_at_PR_isPlaying_Who",
                s."ST_ID_at",
                s."PR_ID_isPlaying"
            ORDER BY
                s."ST_at_PR_isPlaying_ChangedAt" DESC,
                s."ST_at_PR_isPlaying_PositedAt" DESC,
                s."ST_at_PR_isPlaying_Confidence" DESC,
                s."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."ST_at_PR_isPlaying_Stance" <> '?' THEN r."ST_at_PR_isPlaying_ChangedAt" END) OVER (
                PARTITION BY
                    r."ST_at_PR_isPlaying_Who",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying"
            ) AS "inEffect"
        FROM
            ties."rST_at_PR_isPlaying"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) s
    WHERE
        s."ST_at_PR_isPlaying_Stance" = coalesce(assertion, s."ST_at_PR_isPlaying_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."ST_at_PR_isPlaying_ChangedAt" = s."inEffect"
    )
) t
WHERE
    t."ST_at_PR_isPlaying_Who" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lST_at_PR_isPlaying" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tST_at_PR_isPlaying"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pST_at_PR_isPlaying" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp(3),
    "ST_at_PR_isPlaying_Who" smallint,
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_at_PR_isPlaying_Stance" char(1)
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Who",
    t."ST_at_PR_isPlaying_Confidence",
    t."ST_at_PR_isPlaying_Stance"
FROM
    dw."_Who" p,
    ties."tST_at_PR_isPlaying"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nST_at_PR_isPlaying" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tST_at_PR_isPlaying"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dST_at_PR_isPlaying" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "Metadata_ST_at_PR_isPlaying" bigint,
    "ST_ID_at" integer,
    "PR_ID_isPlaying" bigint,
    "ST_at_PR_isPlaying_ChangedAt" timestamp,
    "ST_at_PR_isPlaying_PositedAt" timestamp(3),
    "ST_at_PR_isPlaying_Who" smallint,
    "ST_at_PR_isPlaying_Confidence" decimal(7,3),
    "ST_at_PR_isPlaying_Stance" char(1)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now, for each
-- positor: the posit shown at each changing time is joined with the changing time until which it holds, when the next
-- changing time with an assertion that is not a retraction is. The time-traveling perspective is not called
-- for each change; the posits are worked out for all of them in one pass.
SELECT
    p."Who",
    tp.inspectedTimepoint,
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_ID_at",
    t."PR_ID_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Who",
    t."ST_at_PR_isPlaying_Confidence",
    t."ST_at_PR_isPlaying_Stance"
FROM
    dw."_Who" p
JOIN (
    SELECT DISTINCT
        "ST_at_PR_isPlaying_Who" AS positor,
        "ST_at_PR_isPlaying_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        ties."ST_at_PR_isPlaying"
    WHERE
        "ST_at_PR_isPlaying_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Who"
JOIN (
    SELECT
        y.*,
        lead(y."ST_at_PR_isPlaying_ChangedAt") OVER (
            PARTITION BY
                y."ST_at_PR_isPlaying_Who",
                y."ST_ID_at",
                y."PR_ID_isPlaying"
            ORDER BY y."ST_at_PR_isPlaying_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."ST_at_PR_isPlaying_Who",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying",
                    r."ST_at_PR_isPlaying_ChangedAt")
            r.*
        FROM
            ties."rST_at_PR_isPlaying"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."ST_at_PR_isPlaying_Stance" <> '?'
        ORDER BY
    r."ST_at_PR_isPlaying_Who",
                    r."ST_ID_at",
                    r."PR_ID_isPlaying",
                    r."ST_at_PR_isPlaying_ChangedAt",
    CASE WHEN r."ST_at_PR_isPlaying_Stance" = '+' THEN 0 ELSE 1 END,
    r."ST_at_PR_isPlaying_PositedAt" DESC,
    r."ST_at_PR_isPlaying_Confidence" DESC,
    r."ST_at_PR_isPlaying_ID" DESC
    ) y
) t
ON
    t."ST_at_PR_isPlaying_Who" = tp.positor
AND
    t."ST_at_PR_isPlaying_Stance" = '+'
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
CREATE OR REPLACE FUNCTION ties."tAC_parent_AC_child_PAT_having" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" bigint,
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp(3),
    "AC_parent_AC_child_PAT_having_Who" smallint,
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3),
    "AC_parent_AC_child_PAT_having_Stance" char(1)
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
    t."AC_parent_AC_child_PAT_having_Who",
    t."AC_parent_AC_child_PAT_having_Confidence",
    t."AC_parent_AC_child_PAT_having_Stance"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                s."AC_parent_AC_child_PAT_having_Who",
                s."AC_ID_parent",
                s."AC_ID_child",
                s."PAT_ID_having"
            ORDER BY
                s."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                s."AC_parent_AC_child_PAT_having_Confidence" DESC,
                s."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM (
        SELECT
            r.*
        FROM
            ties."rAC_parent_AC_child_PAT_having"(
                null::smallint,
                positingTimepoint::timestamp(3)
            ) r
    ) s
    WHERE
        s."AC_parent_AC_child_PAT_having_Stance" = coalesce(assertion, s."AC_parent_AC_child_PAT_having_Stance")
) t
LEFT JOIN
    knots."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."AC_parent_AC_child_PAT_having_Who" = positor
AND
    t."latest" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lAC_parent_AC_child_PAT_having" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_parent_AC_child_PAT_having"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pAC_parent_AC_child_PAT_having" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "Metadata_AC_parent_AC_child_PAT_having" bigint,
    "AC_ID_parent" smallint,
    "AC_ID_child" smallint,
    "having_PAT_ParentalType" varchar(42),
    "having_Metadata_PAT" bigint,
    "PAT_ID_having" smallint,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp(3),
    "AC_parent_AC_child_PAT_having_Who" smallint,
    "AC_parent_AC_child_PAT_having_Confidence" decimal(7,3),
    "AC_parent_AC_child_PAT_having_Stance" char(1)
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_ID_parent",
    t."AC_ID_child",
    t."having_PAT_ParentalType",
    t."having_Metadata_PAT",
    t."PAT_ID_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Who",
    t."AC_parent_AC_child_PAT_having_Confidence",
    t."AC_parent_AC_child_PAT_having_Stance"
FROM
    dw."_Who" p,
    ties."tAC_parent_AC_child_PAT_having"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nAC_parent_AC_child_PAT_having" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tAC_parent_AC_child_PAT_having"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Time traveling perspective -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."tPR_content_ST_location_EV_of" (
    positor smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp(3),
    assertion char(1)
)
RETURNS TABLE (
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0),
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_content_ST_location_EV_of_PositedAt" timestamp(3),
    "PR_content_ST_location_EV_of_Who" smallint,
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_content_ST_location_EV_of_Stance" char(1)
)
AS
$$
SELECT
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Who",
    t."PR_content_ST_location_EV_of_Confidence",
    t."PR_content_ST_location_EV_of_Stance"
FROM (
    -- the views of all positors are worked out, and the one asked for is picked last: the latest, point-in-time and now
    -- perspectives call this one for each positor
    SELECT
        s.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY s."PR_content_ST_location_EV_of_Who", s."PR_ID_content"
            ORDER BY
                s."PR_content_ST_location_EV_of_ChangedAt" DESC,
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Confidence" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latestPR_ID_content",
        row_number() OVER (
            PARTITION BY s."PR_content_ST_location_EV_of_Who", s."ST_ID_location"
            ORDER BY
                s."PR_content_ST_location_EV_of_ChangedAt" DESC,
                s."PR_content_ST_location_EV_of_PositedAt" DESC,
                s."PR_content_ST_location_EV_of_Confidence" DESC,
                s."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latestST_ID_location"
    FROM (
        SELECT
            r.*,
            -- the latest changing time with an assertion that is not a retraction, which supersedes those before it
            -- whatever its sign
            max(CASE WHEN r."PR_content_ST_location_EV_of_Stance" <> '?' THEN r."PR_content_ST_location_EV_of_ChangedAt" END) OVER (
                PARTITION BY
                    r."PR_content_ST_location_EV_of_Who",
                    r."PR_ID_content",
                    r."ST_ID_location",
                    r."EV_ID_of"
            ) AS "inEffect"
        FROM
            ties."rPR_content_ST_location_EV_of"(
                null::smallint,
                changingTimepoint::timestamp,
                positingTimepoint::timestamp(3)
            ) r
    ) s
    WHERE
        s."PR_content_ST_location_EV_of_Stance" = coalesce(assertion, s."PR_content_ST_location_EV_of_Stance")
    AND ( -- asked for positive or negative assertions, only those at that changing time
        coalesce(assertion, '?') = '?'
    OR
        s."PR_content_ST_location_EV_of_ChangedAt" = s."inEffect"
    )
) t
WHERE
    t."PR_content_ST_location_EV_of_Who" = positor
AND
    t."latestPR_ID_content" = 1
AND
    t."latestST_ID_location" = 1
$$ LANGUAGE sql STABLE;
-- Latest perspective -------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."lPR_content_ST_location_EV_of" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tPR_content_ST_location_EV_of"(
        p."Who",
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Point-in-time perspective ------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."pPR_content_ST_location_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Who" smallint,
    "Confidence" decimal(7,3),
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0),
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_content_ST_location_EV_of_PositedAt" timestamp(3),
    "PR_content_ST_location_EV_of_Who" smallint,
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_content_ST_location_EV_of_Stance" char(1)
)
AS
$$
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Who",
    t."PR_content_ST_location_EV_of_Confidence",
    t."PR_content_ST_location_EV_of_Stance"
FROM
    dw."_Who" p,
    ties."tPR_content_ST_location_EV_of"(
        p."Who",
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
$$ LANGUAGE sql STABLE;
-- Now perspective ----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ties."nPR_content_ST_location_EV_of" AS
SELECT
    p."Who",
    cast(null as decimal(7,3)) AS "Confidence",
    t.*
FROM
    dw."_Who" p,
    ties."tPR_content_ST_location_EV_of"(
        p."Who",
        current_timestamp::timestamp,
        '9999-12-31'::timestamp(3),
        '+'
    ) t
;
-- Difference perspective ---------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dPR_content_ST_location_EV_of" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "Who" smallint,
    inspectedTimepoint timestamp,
    "Metadata_PR_content_ST_location_EV_of" bigint,
    "PR_ID_content" bigint,
    "ST_ID_location" integer,
    "EV_ID_of" numeric(12,0),
    "PR_content_ST_location_EV_of_ChangedAt" timestamp,
    "PR_content_ST_location_EV_of_PositedAt" timestamp(3),
    "PR_content_ST_location_EV_of_Who" smallint,
    "PR_content_ST_location_EV_of_Confidence" decimal(7,3),
    "PR_content_ST_location_EV_of_Stance" char(1)
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
    q."Who",
    q.inspectedTimepoint,
    q."Metadata_PR_content_ST_location_EV_of",
    q."PR_ID_content",
    q."ST_ID_location",
    q."EV_ID_of",
    q."PR_content_ST_location_EV_of_ChangedAt",
    q."PR_content_ST_location_EV_of_PositedAt",
    q."PR_content_ST_location_EV_of_Who",
    q."PR_content_ST_location_EV_of_Confidence",
    q."PR_content_ST_location_EV_of_Stance"
FROM (
SELECT
    p."Who",
    tp.inspectedTimepoint,
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Who",
    t."PR_content_ST_location_EV_of_Confidence",
    t."PR_content_ST_location_EV_of_Stance",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."PR_ID_content"
        ORDER BY
            t."PR_content_ST_location_EV_of_ChangedAt" DESC,
            t."PR_content_ST_location_EV_of_PositedAt" DESC,
            t."PR_content_ST_location_EV_of_Confidence" DESC,
            t."PR_content_ST_location_EV_of_ID" DESC
    ) AS "latestPR_ID_content",
    row_number() OVER (
        PARTITION BY tp.positor, tp.inspectedTimepoint, t."ST_ID_location"
        ORDER BY
            t."PR_content_ST_location_EV_of_ChangedAt" DESC,
            t."PR_content_ST_location_EV_of_PositedAt" DESC,
            t."PR_content_ST_location_EV_of_Confidence" DESC,
            t."PR_content_ST_location_EV_of_ID" DESC
    ) AS "latestST_ID_location"
FROM
    dw."_Who" p
JOIN (
    SELECT DISTINCT
        "PR_content_ST_location_EV_of_Who" AS positor,
        "PR_content_ST_location_EV_of_ChangedAt"::timestamp AS inspectedTimepoint
    FROM
        ties."PR_content_ST_location_EV_of"
    WHERE
        "PR_content_ST_location_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
) tp
ON
    tp.positor = p."Who"
JOIN (
    SELECT
        y.*,
        lead(y."PR_content_ST_location_EV_of_ChangedAt") OVER (
            PARTITION BY
                y."PR_content_ST_location_EV_of_Who",
                y."PR_ID_content",
                y."ST_ID_location",
                y."EV_ID_of"
            ORDER BY y."PR_content_ST_location_EV_of_ChangedAt"
        ) AS "until"
    FROM (
        -- one posit for each changing time with an assertion that is not a retraction: the positive one that is shown
        -- if there is one, and otherwise a negative one, which means that nothing is shown from that time on
        SELECT DISTINCT ON (r."PR_content_ST_location_EV_of_Who",
                    r."PR_ID_content",
                    r."ST_ID_location",
                    r."EV_ID_of",
                    r."PR_content_ST_location_EV_of_ChangedAt")
            r.*
        FROM
            ties."rPR_content_ST_location_EV_of"(
                null::smallint,
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp(3)
            ) r
        WHERE
            r."PR_content_ST_location_EV_of_Stance" <> '?'
        ORDER BY
    r."PR_content_ST_location_EV_of_Who",
                    r."PR_ID_content",
                    r."ST_ID_location",
                    r."EV_ID_of",
                    r."PR_content_ST_location_EV_of_ChangedAt",
    CASE WHEN r."PR_content_ST_location_EV_of_Stance" = '+' THEN 0 ELSE 1 END,
    r."PR_content_ST_location_EV_of_PositedAt" DESC,
    r."PR_content_ST_location_EV_of_Confidence" DESC,
    r."PR_content_ST_location_EV_of_ID" DESC
    ) y
) t
ON
    t."PR_content_ST_location_EV_of_Who" = tp.positor
AND
    t."PR_content_ST_location_EV_of_Stance" = '+'
AND
    t."PR_content_ST_location_EV_of_ChangedAt" <= tp.inspectedTimepoint::timestamp
AND (
    t."until" IS NULL
OR
    t."until" > tp.inspectedTimepoint::timestamp
)
) q
WHERE
    q."latestPR_ID_content" = 1
AND
    q."latestST_ID_location" = 1
$$ LANGUAGE sql STABLE;
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA dw IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE knots."PAT_ParentalType" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN knots."PAT_ParentalType"."PAT_ParentalType" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON COLUMN knots."GEN_Gender"."GEN_Gender" IS 'Gender of an actor.';
COMMENT ON TABLE knots."PLV_ProfessionalLevel" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN knots."PLV_ProfessionalLevel"."PLV_ProfessionalLevel" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots."UTL_Utilization"."UTL_Utilization" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots."ONG_Ongoing" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN knots."ONG_Ongoing"."ONG_Ongoing" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots."RAT_Rating" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN knots."RAT_Rating"."RAT_Rating" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes."EV_DAT_Event_Date_Fact"."EV_DAT_Event_Date" IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes."EV_AUD_Event_Audience_Fact"."EV_AUD_Event_Audience" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes."EV_REV_Event_Revenue_Fact"."EV_REV_Event_Revenue" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes."EV_STA_Event_Status_Fact"."EV_STA_Event_Status" IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes."EV_LVL_Event_Level_Fact"."EV_LVL_PLV_ID" IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes."ST_NAM_Stage_Name_Fact"."ST_NAM_Stage_Name" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes."ST_LOC_Stage_Location_Fact"."ST_LOC_Stage_Location" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes."ST_AVG_Stage_Average_Fact"."ST_AVG_UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes."ST_MIN_Stage_Minimum_Fact"."ST_MIN_UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes."AC_NAM_Actor_Name_Fact"."AC_NAM_Actor_Name" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes."AC_GEN_Actor_Gender_Fact"."AC_GEN_GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN attributes."AC_PLV_Actor_ProfessionalLevel_Fact"."AC_PLV_PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes."PR_NAM_Program_Name_Fact"."PR_NAM_Program_Name" IS 'Name or title of the program.';
COMMENT ON COLUMN attributes."PR_LEN_Program_Length_Fact"."PR_LEN_Program_Length" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors."ST_Stage" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors."AC_Actor" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses."EV_Event" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses."EV_Event"."ST_ID_wasHeldAt" IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses."EV_Event"."PR_ID_wasPlayed" IS 'The program that was played at the event.';
COMMENT ON TABLE ties."AC_partner_AC_with_ONG_currently_Fact" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Fact"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Fact"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Fact"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties."AC_subset_PN_of_Fact"."AC_ID_subset" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties."AC_subset_PN_of_Fact"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE ties."EV_in_AC_wasCast_Fact" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties."EV_in_AC_wasCast_Fact"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties."EV_in_AC_wasCast_Fact"."AC_ID_wasCast" IS 'An actor cast in the event.';
COMMENT ON TABLE ties."AC_part_PR_in_RAT_got_Fact" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got_Fact"."AC_ID_part" IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got_Fact"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got_Fact"."RAT_ID_got" IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties."ST_at_PR_isPlaying_Fact" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties."ST_at_PR_isPlaying_Fact"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties."ST_at_PR_isPlaying_Fact"."PR_ID_isPlaying" IS 'The program playing at the stage.';
COMMENT ON TABLE ties."AC_parent_AC_child_PAT_having_Fact" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having_Fact"."AC_ID_parent" IS 'The actor who is the parent.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having_Fact"."AC_ID_child" IS 'The actor who is the child.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having_Fact"."PAT_ID_having" IS 'The type of parental relationship.';
COMMENT ON TABLE ties."PR_content_ST_location_EV_of_Fact" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of_Fact"."PR_ID_content" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of_Fact"."ST_ID_location" IS 'The stage where the event was located.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of_Fact"."EV_ID_of" IS 'The event.';
