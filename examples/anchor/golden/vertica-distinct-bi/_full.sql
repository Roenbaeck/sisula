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
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PAT_ParentalType" (
    "PAT_ID" tinyint not null,
    "PAT_ParentalType" varchar(42) not null,
    "Metadata_PAT" integer not null,
    constraint "pkPAT_ParentalType" primary key (
        "PAT_ID"
    ),
    constraint "uqPAT_ParentalType" unique (
        "PAT_ParentalType"
    )
) ORDER BY "PAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Gender" (
    "GEN_ID" tinyint not null,
    "GEN_Gender" varchar(42) not null,
    "GEN_Checksum" int default hash("GEN_Gender"),
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Gender" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Gender" unique (
        "GEN_Checksum" 
    )
) ORDER BY "GEN_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_ProfessionalLevel" (
    "PLV_ID" tinyint not null,
    "PLV_ProfessionalLevel" long varchar(32000000) not null,
    "PLV_Checksum" int default hash("PLV_ProfessionalLevel"),
    "Metadata_PLV" integer not null,
    constraint "pkPLV_ProfessionalLevel" primary key (
        "PLV_ID"
    ),
    constraint "uqPLV_ProfessionalLevel" unique (
        "PLV_Checksum" 
    )
) ORDER BY "PLV_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utilization" (
    "UTL_ID" tinyint not null,
    "UTL_Utilization" tinyint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utilization" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utilization" unique (
        "UTL_Utilization"
    )
) ORDER BY "UTL_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Ongoing" (
    "ONG_ID" tinyint not null,
    "ONG_Ongoing" varchar(3) not null,
    "Metadata_ONG" integer not null,
    constraint "pkONG_Ongoing" primary key (
        "ONG_ID"
    ),
    constraint "uqONG_Ongoing" unique (
        "ONG_Ongoing"
    )
) ORDER BY "ONG_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Rating_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Rating" (
    "RAT_ID" tinyint default nextval('knots."RAT_Rating_ID_SEQ"') not null, 
    "RAT_Rating" varchar(42) not null,
    "RAT_Checksum" int default hash("RAT_Rating"),
    "Metadata_RAT" integer not null,
    constraint "pkRAT_Rating" primary key (
        "RAT_ID"
    ),
    constraint "uqRAT_Rating" unique (
        "RAT_Checksum" 
    )
) ORDER BY "RAT_ID" UNSEGMENTED ALL NODES;
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_EventType" (
    "ETY_ID" tinyint not null,
    "ETY_EventType" varchar(42) not null,
    "ETY_Checksum" int default hash("ETY_EventType"),
    "Metadata_ETY" integer not null,
    constraint "pkETY_EventType" primary key (
        "ETY_ID"
    ),
    constraint "uqETY_EventType" unique (
        "ETY_Checksum" 
    )
) ORDER BY "ETY_ID" UNSEGMENTED ALL NODES;
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors store immutable entity identities.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Stage" (
    "ST_ID" integer not null,
    "Metadata_ST" integer not null,
    constraint "pkST_Stage" primary key (
        "ST_ID"
    )
) ORDER BY "ST_ID" SEGMENTED BY MODULARHASH("ST_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Actor_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Actor" (
    "AC_ID" smallint default nextval('anchors."AC_Actor_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Actor" primary key (
        "AC_ID"
    )
) ORDER BY "AC_ID" SEGMENTED BY MODULARHASH("AC_ID") ALL NODES;
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Program" (
    "PR_ID" bigint not null,
    "Metadata_PR" integer not null,
    constraint "pkPR_Program" primary key (
        "PR_ID"
    )
) ORDER BY "PR_ID" SEGMENTED BY MODULARHASH("PR_ID") ALL NODES;
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses store immutable identities for event-like entities.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses."EV_Event" (
    "EV_ID" numeric(12,0) not null,
    "ST_ID_wasHeldAt" integer not null, 
    "PR_ID_wasPlayed" bigint not null, 
    "ETY_ID_of" tinyint not null,
    constraint "EV_Event_fkST_wasHeldAt" foreign key (
        "ST_ID_wasHeldAt"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "EV_Event_fkPR_wasPlayed" foreign key (
        "PR_ID_wasPlayed"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "EV_Event_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_EventType"("ETY_ID"),
    "Metadata_EV" integer not null, 
    constraint "pkEV_Event" primary key (
        "EV_ID"
    )
) ORDER BY "EV_ID" SEGMENTED BY MODULARHASH("EV_ID") ALL NODES;
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS attributes."EV_DAT_Event_Date_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date_Posit" (
    "EV_DAT_ID" integer default nextval('attributes."EV_DAT_Event_Date_Posit_ID_SEQ"') not null, 
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Event_Date" timestamp not null,
    constraint "fkEV_DAT_Event_Date_Posit" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_DAT_Event_Date_Posit" primary key (
        "EV_DAT_ID"
    ),
    constraint "uqEV_DAT_Event_Date_Posit" unique (
        "EV_DAT_EV_ID",
        "EV_DAT_Event_Date"
    )
) ORDER BY "EV_DAT_EV_ID" SEGMENTED BY MODULARHASH("EV_DAT_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Event_Date_Annex" (
    "EV_DAT_ID" integer not null,
    "EV_DAT_PositedAt" timestamp not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Event_Date_Annex" foreign key (
        "EV_DAT_ID"
    ) references attributes."EV_DAT_Event_Date_Posit"("EV_DAT_ID"),
    constraint "pkEV_DAT_Event_Date_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_PositedAt"
    )
) ORDER BY "EV_DAT_ID", "EV_DAT_PositedAt" SEGMENTED BY MODULARHASH("EV_DAT_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Posit" (
    "EV_AUD_ID" integer default nextval('attributes."EV_AUD_Event_Audience_Posit_ID_SEQ"') not null, 
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_Event_Audience" integer not null,
    constraint "fkEV_AUD_Event_Audience_Posit" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_AUD_Event_Audience_Posit" primary key (
        "EV_AUD_ID"
    ),
    constraint "uqEV_AUD_Event_Audience_Posit" unique (
        "EV_AUD_EV_ID",
        "EV_AUD_Event_Audience"
    )
) ORDER BY "EV_AUD_EV_ID" SEGMENTED BY MODULARHASH("EV_AUD_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Event_Audience_Annex" (
    "EV_AUD_ID" integer not null,
    "EV_AUD_PositedAt" timestamp not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Event_Audience_Annex" foreign key (
        "EV_AUD_ID"
    ) references attributes."EV_AUD_Event_Audience_Posit"("EV_AUD_ID"),
    constraint "pkEV_AUD_Event_Audience_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_PositedAt"
    )
) ORDER BY "EV_AUD_ID", "EV_AUD_PositedAt" SEGMENTED BY MODULARHASH("EV_AUD_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Posit" (
    "EV_REV_ID" integer default nextval('attributes."EV_REV_Event_Revenue_Posit_ID_SEQ"') not null, 
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_Event_Revenue" decimal(19,4) not null,
    constraint "fkEV_REV_Event_Revenue_Posit" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_REV_Event_Revenue_Posit" primary key (
        "EV_REV_ID"
    ),
    constraint "uqEV_REV_Event_Revenue_Posit" unique (
        "EV_REV_EV_ID",
        "EV_REV_Event_Revenue"
    )
) ORDER BY "EV_REV_EV_ID" SEGMENTED BY MODULARHASH("EV_REV_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Event_Revenue_Annex" (
    "EV_REV_ID" integer not null,
    "EV_REV_PositedAt" timestamp not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Event_Revenue_Annex" foreign key (
        "EV_REV_ID"
    ) references attributes."EV_REV_Event_Revenue_Posit"("EV_REV_ID"),
    constraint "pkEV_REV_Event_Revenue_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_PositedAt"
    )
) ORDER BY "EV_REV_ID", "EV_REV_PositedAt" SEGMENTED BY MODULARHASH("EV_REV_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_STA_Event_Status_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status_Posit" (
    "EV_STA_ID" integer default nextval('attributes."EV_STA_Event_Status_Posit_ID_SEQ"') not null, 
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_Event_Status" varchar(20) not null,
    "EV_STA_ChangedAt" timestamp not null,
    constraint "fkEV_STA_Event_Status_Posit" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "pkEV_STA_Event_Status_Posit" primary key (
        "EV_STA_ID"
    ),
    constraint "uqEV_STA_Event_Status_Posit" unique (
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt",
        "EV_STA_Event_Status"
    )
) ORDER BY "EV_STA_EV_ID", "EV_STA_ChangedAt" SEGMENTED BY MODULARHASH("EV_STA_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Event_Status_Annex" (
    "EV_STA_ID" integer not null,
    "EV_STA_PositedAt" timestamp not null,
    "EV_STA_Reliability" decimal(5,2) not null,
    "Metadata_EV_STA" integer not null,
    constraint "fkEV_STA_Event_Status_Annex" foreign key (
        "EV_STA_ID"
    ) references attributes."EV_STA_Event_Status_Posit"("EV_STA_ID"),
    constraint "pkEV_STA_Event_Status_Annex" primary key (
        "EV_STA_ID",
        "EV_STA_PositedAt"
    )
) ORDER BY "EV_STA_ID", "EV_STA_PositedAt" SEGMENTED BY MODULARHASH("EV_STA_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Posit" (
    "EV_UTL_ID" integer default nextval('attributes."EV_UTL_Event_Utilization_Posit_ID_SEQ"') not null, 
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" tinyint not null,
    constraint "fk_A_EV_UTL_Event_Utilization_Posit" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "fk_K_EV_UTL_Event_Utilization_Posit" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkEV_UTL_Event_Utilization_Posit" primary key (
        "EV_UTL_ID"
    ),
    constraint "uqEV_UTL_Event_Utilization_Posit" unique (
        "EV_UTL_EV_ID",
        "EV_UTL_UTL_ID"
    )
) ORDER BY "EV_UTL_EV_ID" SEGMENTED BY MODULARHASH("EV_UTL_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Event_Utilization_Annex" (
    "EV_UTL_ID" integer not null,
    "EV_UTL_PositedAt" timestamp not null,
    "EV_UTL_Reliability" decimal(5,2) not null,
    "Metadata_EV_UTL" integer not null,
    constraint "fkEV_UTL_Event_Utilization_Annex" foreign key (
        "EV_UTL_ID"
    ) references attributes."EV_UTL_Event_Utilization_Posit"("EV_UTL_ID"),
    constraint "pkEV_UTL_Event_Utilization_Annex" primary key (
        "EV_UTL_ID",
        "EV_UTL_PositedAt"
    )
) ORDER BY "EV_UTL_ID", "EV_UTL_PositedAt" SEGMENTED BY MODULARHASH("EV_UTL_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."EV_LVL_Event_Level_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level_Posit" (
    "EV_LVL_ID" integer default nextval('attributes."EV_LVL_Event_Level_Posit_ID_SEQ"') not null, 
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    constraint "fk_A_EV_LVL_Event_Level_Posit" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Event"("EV_ID"),
    constraint "fk_K_EV_LVL_Event_Level_Posit" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkEV_LVL_Event_Level_Posit" primary key (
        "EV_LVL_ID"
    ),
    constraint "uqEV_LVL_Event_Level_Posit" unique (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt",
        "EV_LVL_PLV_ID"
    )
) ORDER BY "EV_LVL_EV_ID", "EV_LVL_ChangedAt" SEGMENTED BY MODULARHASH("EV_LVL_EV_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Event_Level_Annex" (
    "EV_LVL_ID" integer not null,
    "EV_LVL_PositedAt" timestamp not null,
    "EV_LVL_Reliability" decimal(5,2) not null,
    "Metadata_EV_LVL" integer not null,
    constraint "fkEV_LVL_Event_Level_Annex" foreign key (
        "EV_LVL_ID"
    ) references attributes."EV_LVL_Event_Level_Posit"("EV_LVL_ID"),
    constraint "pkEV_LVL_Event_Level_Annex" primary key (
        "EV_LVL_ID",
        "EV_LVL_PositedAt"
    )
) ORDER BY "EV_LVL_ID", "EV_LVL_PositedAt" SEGMENTED BY MODULARHASH("EV_LVL_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Posit" (
    "ST_NAM_ID" integer default nextval('attributes."ST_NAM_Stage_Name_Posit_ID_SEQ"') not null, 
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Stage_Name" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Stage_Name_Posit" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "pkST_NAM_Stage_Name_Posit" primary key (
        "ST_NAM_ID"
    ),
    constraint "uqST_NAM_Stage_Name_Posit" unique (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Stage_Name"
    )
) ORDER BY "ST_NAM_ST_ID", "ST_NAM_ChangedAt" SEGMENTED BY MODULARHASH("ST_NAM_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Stage_Name_Annex" (
    "ST_NAM_ID" integer not null,
    "ST_NAM_PositedAt" timestamp not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Stage_Name_Annex" foreign key (
        "ST_NAM_ID"
    ) references attributes."ST_NAM_Stage_Name_Posit"("ST_NAM_ID"),
    constraint "pkST_NAM_Stage_Name_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_PositedAt"
    )
) ORDER BY "ST_NAM_ID", "ST_NAM_PositedAt" SEGMENTED BY MODULARHASH("ST_NAM_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Posit" (
    "ST_LOC_ID" integer default nextval('attributes."ST_LOC_Stage_Location_Posit_ID_SEQ"') not null, 
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Stage_Location" geography not null,
    "ST_LOC_Checksum" int default hash("ST_LOC_Stage_Location"),
    constraint "fkST_LOC_Stage_Location_Posit" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "pkST_LOC_Stage_Location_Posit" primary key (
        "ST_LOC_ID"
    ),
    constraint "uqST_LOC_Stage_Location_Posit" unique (
        "ST_LOC_ST_ID",
        "ST_LOC_Checksum" 
    )
) ORDER BY "ST_LOC_ST_ID" SEGMENTED BY MODULARHASH("ST_LOC_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Stage_Location_Annex" (
    "ST_LOC_ID" integer not null,
    "ST_LOC_PositedAt" timestamp not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Stage_Location_Annex" foreign key (
        "ST_LOC_ID"
    ) references attributes."ST_LOC_Stage_Location_Posit"("ST_LOC_ID"),
    constraint "pkST_LOC_Stage_Location_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_PositedAt"
    )
) ORDER BY "ST_LOC_ID", "ST_LOC_PositedAt" SEGMENTED BY MODULARHASH("ST_LOC_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Posit" (
    "ST_AVG_ID" integer default nextval('attributes."ST_AVG_Stage_Average_Posit_ID_SEQ"') not null, 
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_AVG_Stage_Average_Posit" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkST_AVG_Stage_Average_Posit" primary key (
        "ST_AVG_ID"
    ),
    constraint "uqST_AVG_Stage_Average_Posit" unique (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID"
    )
) ORDER BY "ST_AVG_ST_ID", "ST_AVG_ChangedAt" SEGMENTED BY MODULARHASH("ST_AVG_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Stage_Average_Annex" (
    "ST_AVG_ID" integer not null,
    "ST_AVG_PositedAt" timestamp not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "Metadata_ST_AVG" integer not null,
    constraint "fkST_AVG_Stage_Average_Annex" foreign key (
        "ST_AVG_ID"
    ) references attributes."ST_AVG_Stage_Average_Posit"("ST_AVG_ID"),
    constraint "pkST_AVG_Stage_Average_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_PositedAt"
    )
) ORDER BY "ST_AVG_ID", "ST_AVG_PositedAt" SEGMENTED BY MODULARHASH("ST_AVG_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Posit" (
    "ST_MIN_ID" integer default nextval('attributes."ST_MIN_Stage_Minimum_Posit_ID_SEQ"') not null, 
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" tinyint not null,
    constraint "fk_A_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Stage"("ST_ID"),
    constraint "fk_K_ST_MIN_Stage_Minimum_Posit" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utilization"("UTL_ID"),
    constraint "pkST_MIN_Stage_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ),
    constraint "uqST_MIN_Stage_Minimum_Posit" unique (
        "ST_MIN_ST_ID",
        "ST_MIN_UTL_ID"
    )
) ORDER BY "ST_MIN_ST_ID" SEGMENTED BY MODULARHASH("ST_MIN_ST_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Stage_Minimum_Annex" (
    "ST_MIN_ID" integer not null,
    "ST_MIN_PositedAt" timestamp not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "Metadata_ST_MIN" integer not null,
    constraint "fkST_MIN_Stage_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references attributes."ST_MIN_Stage_Minimum_Posit"("ST_MIN_ID"),
    constraint "pkST_MIN_Stage_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_PositedAt"
    )
) ORDER BY "ST_MIN_ID", "ST_MIN_PositedAt" SEGMENTED BY MODULARHASH("ST_MIN_ID") ALL NODES;
-- AC_NAM_Actor_Name is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
CREATE SEQUENCE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Posit" (
    "AC_NAM_ID" integer default nextval('attributes."AC_NAM_Actor_Name_Posit_ID_SEQ"') not null, 
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Actor_Name" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Actor_Name_Posit" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "pkAC_NAM_Actor_Name_Posit" primary key (
        "AC_NAM_ID"
    ),
    constraint "uqAC_NAM_Actor_Name_Posit" unique (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Actor_Name"
    )
) ORDER BY "AC_NAM_AC_ID", "AC_NAM_ChangedAt" SEGMENTED BY MODULARHASH("AC_NAM_AC_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Actor_Name_Annex" (
    "AC_NAM_ID" integer not null,
    "AC_NAM_PositedAt" timestamp not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Actor_Name_Annex" foreign key (
        "AC_NAM_ID"
    ) references attributes."AC_NAM_Actor_Name_Posit"("AC_NAM_ID"),
    constraint "pkAC_NAM_Actor_Name_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_PositedAt"
    )
) ORDER BY "AC_NAM_ID", "AC_NAM_PositedAt" SEGMENTED BY MODULARHASH("AC_NAM_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Posit" (
    "AC_GEN_ID" integer default nextval('attributes."AC_GEN_Actor_Gender_Posit_ID_SEQ"') not null, 
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" tinyint not null,
    constraint "fk_A_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_GEN_Actor_Gender_Posit" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Gender"("GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Posit" primary key (
        "AC_GEN_ID"
    ),
    constraint "uqAC_GEN_Actor_Gender_Posit" unique (
        "AC_GEN_AC_ID",
        "AC_GEN_GEN_ID"
    )
) ORDER BY "AC_GEN_AC_ID" SEGMENTED BY MODULARHASH("AC_GEN_AC_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Actor_Gender_Annex" (
    "AC_GEN_ID" integer not null,
    "AC_GEN_PositedAt" timestamp not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "Metadata_AC_GEN" integer not null,
    constraint "fkAC_GEN_Actor_Gender_Annex" foreign key (
        "AC_GEN_ID"
    ) references attributes."AC_GEN_Actor_Gender_Posit"("AC_GEN_ID"),
    constraint "pkAC_GEN_Actor_Gender_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_PositedAt"
    )
) ORDER BY "AC_GEN_ID", "AC_GEN_PositedAt" SEGMENTED BY MODULARHASH("AC_GEN_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Posit" (
    "AC_PLV_ID" integer default nextval('attributes."AC_PLV_Actor_ProfessionalLevel_Posit_ID_SEQ"') not null, 
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Actor"("AC_ID"),
    constraint "fk_K_AC_PLV_Actor_ProfessionalLevel_Posit" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_ProfessionalLevel"("PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Posit" primary key (
        "AC_PLV_ID"
    ),
    constraint "uqAC_PLV_Actor_ProfessionalLevel_Posit" unique (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PLV_ID"
    )
) ORDER BY "AC_PLV_AC_ID", "AC_PLV_ChangedAt" SEGMENTED BY MODULARHASH("AC_PLV_AC_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Actor_ProfessionalLevel_Annex" (
    "AC_PLV_ID" integer not null,
    "AC_PLV_PositedAt" timestamp not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fkAC_PLV_Actor_ProfessionalLevel_Annex" foreign key (
        "AC_PLV_ID"
    ) references attributes."AC_PLV_Actor_ProfessionalLevel_Posit"("AC_PLV_ID"),
    constraint "pkAC_PLV_Actor_ProfessionalLevel_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_PositedAt"
    )
) ORDER BY "AC_PLV_ID", "AC_PLV_PositedAt" SEGMENTED BY MODULARHASH("AC_PLV_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."PR_NAM_Program_Name_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name_Posit" (
    "PR_NAM_ID" integer default nextval('attributes."PR_NAM_Program_Name_Posit_ID_SEQ"') not null, 
    "PR_NAM_PR_ID" bigint not null,
    "PR_NAM_Program_Name" varchar(42) not null,
    constraint "fkPR_NAM_Program_Name_Posit" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Program"("PR_ID"),
    constraint "pkPR_NAM_Program_Name_Posit" primary key (
        "PR_NAM_ID"
    ),
    constraint "uqPR_NAM_Program_Name_Posit" unique (
        "PR_NAM_PR_ID",
        "PR_NAM_Program_Name"
    )
) ORDER BY "PR_NAM_PR_ID" SEGMENTED BY MODULARHASH("PR_NAM_PR_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Program_Name_Annex" (
    "PR_NAM_ID" integer not null,
    "PR_NAM_PositedAt" timestamp not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Program_Name_Annex" foreign key (
        "PR_NAM_ID"
    ) references attributes."PR_NAM_Program_Name_Posit"("PR_NAM_ID"),
    constraint "pkPR_NAM_Program_Name_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_PositedAt"
    )
) ORDER BY "PR_NAM_ID", "PR_NAM_PositedAt" SEGMENTED BY MODULARHASH("PR_NAM_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS attributes."PR_LEN_Program_Length_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length_Posit" (
    "PR_LEN_ID" integer default nextval('attributes."PR_LEN_Program_Length_Posit_ID_SEQ"') not null, 
    "PR_LEN_PR_ID" bigint not null,
    "PR_LEN_Program_Length" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Program_Length_Posit" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Program"("PR_ID"),
    constraint "pkPR_LEN_Program_Length_Posit" primary key (
        "PR_LEN_ID"
    ),
    constraint "uqPR_LEN_Program_Length_Posit" unique (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Program_Length"
    )
) ORDER BY "PR_LEN_PR_ID", "PR_LEN_ChangedAt" SEGMENTED BY MODULARHASH("PR_LEN_PR_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Program_Length_Annex" (
    "PR_LEN_ID" integer not null,
    "PR_LEN_PositedAt" timestamp not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Program_Length_Annex" foreign key (
        "PR_LEN_ID"
    ) references attributes."PR_LEN_Program_Length_Posit"("PR_LEN_ID"),
    constraint "pkPR_LEN_Program_Length_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_PositedAt"
    )
) ORDER BY "PR_LEN_ID", "PR_LEN_PositedAt" SEGMENTED BY MODULARHASH("PR_LEN_ID") ALL NODES;
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
    a."EV_DAT_Reliability"
FROM
    attributes."EV_DAT_Event_Date_Posit" p
JOIN
    attributes."EV_DAT_Event_Date_Annex" a
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
    a."EV_AUD_Reliability"
FROM
    attributes."EV_AUD_Event_Audience_Posit" p
JOIN
    attributes."EV_AUD_Event_Audience_Annex" a
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
    a."EV_REV_Reliability"
FROM
    attributes."EV_REV_Event_Revenue_Posit" p
JOIN
    attributes."EV_REV_Event_Revenue_Annex" a
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
    a."EV_STA_Reliability"
FROM
    attributes."EV_STA_Event_Status_Posit" p
JOIN
    attributes."EV_STA_Event_Status_Annex" a
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
    a."EV_UTL_Reliability"
FROM
    attributes."EV_UTL_Event_Utilization_Posit" p
JOIN
    attributes."EV_UTL_Event_Utilization_Annex" a
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
    a."EV_LVL_Reliability"
FROM
    attributes."EV_LVL_Event_Level_Posit" p
JOIN
    attributes."EV_LVL_Event_Level_Annex" a
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
    a."ST_NAM_Reliability"
FROM
    attributes."ST_NAM_Stage_Name_Posit" p
JOIN
    attributes."ST_NAM_Stage_Name_Annex" a
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
    a."ST_LOC_Reliability"
FROM
    attributes."ST_LOC_Stage_Location_Posit" p
JOIN
    attributes."ST_LOC_Stage_Location_Annex" a
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
    a."ST_AVG_Reliability"
FROM
    attributes."ST_AVG_Stage_Average_Posit" p
JOIN
    attributes."ST_AVG_Stage_Average_Annex" a
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
    a."ST_MIN_Reliability"
FROM
    attributes."ST_MIN_Stage_Minimum_Posit" p
JOIN
    attributes."ST_MIN_Stage_Minimum_Annex" a
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
    a."AC_NAM_Reliability"
FROM
    attributes."AC_NAM_Actor_Name_Posit" p
JOIN
    attributes."AC_NAM_Actor_Name_Annex" a
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
    a."AC_GEN_Reliability"
FROM
    attributes."AC_GEN_Actor_Gender_Posit" p
JOIN
    attributes."AC_GEN_Actor_Gender_Annex" a
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
    a."AC_PLV_Reliability"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit" p
JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel_Annex" a
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
    a."PR_NAM_Reliability"
FROM
    attributes."PR_NAM_Program_Name_Posit" p
JOIN
    attributes."PR_NAM_Program_Name_Annex" a
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
    a."PR_LEN_Reliability"
FROM
    attributes."PR_LEN_Program_Length_Posit" p
JOIN
    attributes."PR_LEN_Program_Length_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
;
-- ATTRIBUTE REWINDERS ------------------------------------------------------------------------------------------------
--
-- A rewinder shows the posits of an attribute with the latest row of their annex: what is known now about each posit, which
-- is asserted or retracted. Vertica has no function that returns a table, so it is a view and shows what is known now
-- (the rewinders of the other databases can be asked about an earlier time); the perspectives that Vertica has are over it.
--
CREATE OR REPLACE VIEW attributes."rEV_DAT_Event_Date" AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Reliability",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Event_Date"
FROM
    attributes."EV_DAT_Event_Date_Posit" p
JOIN
    attributes."EV_DAT_Event_Date_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_DAT_ID"
    ORDER BY a."EV_DAT_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_AUD_Event_Audience" AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Reliability",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Event_Audience"
FROM
    attributes."EV_AUD_Event_Audience_Posit" p
JOIN
    attributes."EV_AUD_Event_Audience_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_AUD_ID"
    ORDER BY a."EV_AUD_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_REV_Event_Revenue" AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Reliability",
    p."EV_REV_EV_ID",
    p."EV_REV_Event_Revenue"
FROM
    attributes."EV_REV_Event_Revenue_Posit" p
JOIN
    attributes."EV_REV_Event_Revenue_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_REV_ID"
    ORDER BY a."EV_REV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_STA_Event_Status" AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability",
    p."EV_STA_EV_ID",
    p."EV_STA_Event_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Event_Status_Posit" p
JOIN
    attributes."EV_STA_Event_Status_Annex" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_STA_ID"
    ORDER BY a."EV_STA_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_UTL_Event_Utilization" AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Reliability",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Event_Utilization_Posit" p
JOIN
    attributes."EV_UTL_Event_Utilization_Annex" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_UTL_ID"
    ORDER BY a."EV_UTL_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rEV_LVL_Event_Level" AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."EV_LVL_Event_Level_Posit" p
JOIN
    attributes."EV_LVL_Event_Level_Annex" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_LVL_ID"
    ORDER BY a."EV_LVL_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_NAM_Stage_Name" AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Stage_Name",
    p."ST_NAM_ChangedAt"
FROM
    attributes."ST_NAM_Stage_Name_Posit" p
JOIN
    attributes."ST_NAM_Stage_Name_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_NAM_ID"
    ORDER BY a."ST_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_LOC_Stage_Location" AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Reliability",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Stage_Location"
FROM
    attributes."ST_LOC_Stage_Location_Posit" p
JOIN
    attributes."ST_LOC_Stage_Location_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_LOC_ID"
    ORDER BY a."ST_LOC_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_AVG_Stage_Average" AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."ST_AVG_Stage_Average_Posit" p
JOIN
    attributes."ST_AVG_Stage_Average_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_AVG_ID"
    ORDER BY a."ST_AVG_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rST_MIN_Stage_Minimum" AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Reliability",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Stage_Minimum_Posit" p
JOIN
    attributes."ST_MIN_Stage_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_MIN_ID"
    ORDER BY a."ST_MIN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_NAM_Actor_Name" AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Actor_Name",
    p."AC_NAM_ChangedAt"
FROM
    attributes."AC_NAM_Actor_Name_Posit" p
JOIN
    attributes."AC_NAM_Actor_Name_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_NAM_ID"
    ORDER BY a."AC_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_GEN_Actor_Gender" AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Reliability",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Actor_Gender_Posit" p
JOIN
    attributes."AC_GEN_Actor_Gender_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_GEN_ID"
    ORDER BY a."AC_GEN_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rAC_PLV_Actor_ProfessionalLevel" AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."AC_PLV_Actor_ProfessionalLevel_Posit" p
JOIN
    attributes."AC_PLV_Actor_ProfessionalLevel_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_PLV_ID"
    ORDER BY a."AC_PLV_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rPR_NAM_Program_Name" AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Reliability",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Program_Name"
FROM
    attributes."PR_NAM_Program_Name_Posit" p
JOIN
    attributes."PR_NAM_Program_Name_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_NAM_ID"
    ORDER BY a."PR_NAM_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW attributes."rPR_LEN_Program_Length" AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Program_Length",
    p."PR_LEN_ChangedAt"
FROM
    attributes."PR_LEN_Program_Length_Posit" p
JOIN
    attributes."PR_LEN_Program_Length_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_LEN_ID"
    ORDER BY a."PR_LEN_PositedAt" DESC
)
;
-- ANCHOR TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI anchor perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that
-- take a time (time traveling, point-in-time and difference) are not made; the latest and the now perspectives take none,
-- and are views over the rewinders of the attributes (views that show the latest annex row of every posit).
--
CREATE OR REPLACE VIEW anchors."lST_Stage" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_NAM_Stage_Name" r
    WHERE
        r."ST_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_NAM_ST_ID"
        ORDER BY
            r."ST_NAM_ChangedAt" DESC,
            r."ST_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_LOC_Stage_Location" r
    WHERE
        r."ST_LOC_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_LOC_ST_ID"
        ORDER BY
            r."ST_LOC_PositedAt" DESC
    )
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_AVG_Stage_Average" r
    WHERE
        r."ST_AVG_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_AVG_ST_ID"
        ORDER BY
            r."ST_AVG_ChangedAt" DESC,
            r."ST_AVG_PositedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_MIN_Stage_Minimum" r
    WHERE
        r."ST_MIN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_MIN_ST_ID"
        ORDER BY
            r."ST_MIN_PositedAt" DESC
    )
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
;
CREATE OR REPLACE VIEW anchors."nST_Stage" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Stage_Name",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Stage_Location",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utilization" AS "ST_AVG_UTL_Utilization",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utilization" AS "ST_MIN_UTL_Utilization",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Stage" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_NAM_Stage_Name" r
    WHERE
        r."ST_NAM_Reliability" = 1
    AND
        r."ST_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."ST_NAM_ST_ID"
        ORDER BY
            r."ST_NAM_ChangedAt" DESC,
            r."ST_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_LOC_Stage_Location" r
    WHERE
        r."ST_LOC_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_LOC_ST_ID"
        ORDER BY
            r."ST_LOC_PositedAt" DESC
    )
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_AVG_Stage_Average" r
    WHERE
        r."ST_AVG_Reliability" = 1
    AND
        r."ST_AVG_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."ST_AVG_ST_ID"
        ORDER BY
            r."ST_AVG_ChangedAt" DESC,
            r."ST_AVG_PositedAt" DESC
    )
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rST_MIN_Stage_Minimum" r
    WHERE
        r."ST_MIN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."ST_MIN_ST_ID"
        ORDER BY
            r."ST_MIN_PositedAt" DESC
    )
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utilization" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
;
CREATE OR REPLACE VIEW anchors."lAC_Actor" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_NAM_Actor_Name" r
    WHERE
        r."AC_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_NAM_AC_ID"
        ORDER BY
            r."AC_NAM_ChangedAt" DESC,
            r."AC_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_GEN_Actor_Gender" r
    WHERE
        r."AC_GEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_GEN_AC_ID"
        ORDER BY
            r."AC_GEN_PositedAt" DESC
    )
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_PLV_Actor_ProfessionalLevel" r
    WHERE
        r."AC_PLV_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_PLV_AC_ID"
        ORDER BY
            r."AC_PLV_ChangedAt" DESC,
            r."AC_PLV_PositedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW anchors."nAC_Actor" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Actor_Name",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Gender" AS "AC_GEN_GEN_Gender",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_ProfessionalLevel" AS "AC_PLV_PLV_ProfessionalLevel",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Actor" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_NAM_Actor_Name" r
    WHERE
        r."AC_NAM_Reliability" = 1
    AND
        r."AC_NAM_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."AC_NAM_AC_ID"
        ORDER BY
            r."AC_NAM_ChangedAt" DESC,
            r."AC_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_GEN_Actor_Gender" r
    WHERE
        r."AC_GEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."AC_GEN_AC_ID"
        ORDER BY
            r."AC_GEN_PositedAt" DESC
    )
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Gender" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rAC_PLV_Actor_ProfessionalLevel" r
    WHERE
        r."AC_PLV_Reliability" = 1
    AND
        r."AC_PLV_ChangedAt" <= current_timestamp::timestamp
    LIMIT 1 OVER (
        PARTITION BY r."AC_PLV_AC_ID"
        ORDER BY
            r."AC_PLV_ChangedAt" DESC,
            r."AC_PLV_PositedAt" DESC
    )
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_ProfessionalLevel" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
;
CREATE OR REPLACE VIEW anchors."lPR_Program" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_NAM_Program_Name" r
    WHERE
        r."PR_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_NAM_PR_ID"
        ORDER BY
            r."PR_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_LEN_Program_Length" r
    WHERE
        r."PR_LEN_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_LEN_PR_ID"
        ORDER BY
            r."PR_LEN_ChangedAt" DESC,
            r."PR_LEN_PositedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
CREATE OR REPLACE VIEW anchors."nPR_Program" AS
SELECT
    cast(null as decimal(5,2)) AS "Reliability",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Program_Name",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Program_Length"
FROM
    anchors."PR_Program" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_NAM_Program_Name" r
    WHERE
        r."PR_NAM_Reliability" = 1
    LIMIT 1 OVER (
        PARTITION BY r."PR_NAM_PR_ID"
        ORDER BY
            r."PR_NAM_PositedAt" DESC
    )
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor
    SELECT
        r.*
    FROM
        attributes."rPR_LEN_Program_Length" r
    WHERE
        r."PR_LEN_Reliability" = 1
    AND
        r."PR_LEN_ChangedAt" <= current_timestamp::date
    LIMIT 1 OVER (
        PARTITION BY r."PR_LEN_PR_ID"
        ORDER BY
            r."PR_LEN_ChangedAt" DESC,
            r."PR_LEN_PositedAt" DESC
    )
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI nexus perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that
-- take a time (time traveling, point-in-time and difference) are not made; the latest and the now perspectives take none,
-- and are views over the rewinders of the attributes (views that show the latest annex row of every posit).
--
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit" (
    "AC_partner_AC_with_ONG_currently_ID" integer default nextval('ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ"') not null, 
    "AC_ID_partner" smallint not null, 
    "AC_ID_with" smallint not null, 
    "ONG_ID_currently" tinyint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp not null,
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Ongoing"("ONG_ID"),
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
) ORDER BY "AC_partner_AC_with_ONG_currently_ID" SEGMENTED BY MODULARHASH("AC_partner_AC_with_ONG_currently_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Annex" (
    "AC_partner_AC_with_ONG_currently_ID" integer not null,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp not null,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2) not null,
    "Metadata_AC_partner_AC_with_ONG_currently" integer not null,
    constraint "fkAC_partner_AC_with_ONG_currently_Annex" foreign key (
        "AC_partner_AC_with_ONG_currently_ID"
    ) references ties."AC_partner_AC_with_ONG_currently_Posit"("AC_partner_AC_with_ONG_currently_ID"),
    constraint "pkAC_partner_AC_with_ONG_currently_Annex" primary key (
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_PositedAt"
    )
) ORDER BY "AC_partner_AC_with_ONG_currently_ID", "AC_partner_AC_with_ONG_currently_PositedAt" SEGMENTED BY MODULARHASH("AC_partner_AC_with_ONG_currently_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS ties."AC_subset_PN_of_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Posit" (
    "AC_subset_PN_of_ID" integer default nextval('ties."AC_subset_PN_of_Posit_ID_SEQ"') not null, 
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    constraint "AC_subset_PN_of_Posit_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_subset_PN_of_Posit_fkPN_of" foreign key (
        "PN_ID_of"
    ) references anchors."PN_Person"("PN_ID"), 
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
) ORDER BY "AC_subset_PN_of_ID" SEGMENTED BY MODULARHASH("AC_subset_PN_of_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Annex" (
    "AC_subset_PN_of_ID" integer not null,
    "AC_subset_PN_of_PositedAt" timestamp not null,
    "AC_subset_PN_of_Reliability" decimal(5,2) not null,
    "Metadata_AC_subset_PN_of" integer not null,
    constraint "fkAC_subset_PN_of_Annex" foreign key (
        "AC_subset_PN_of_ID"
    ) references ties."AC_subset_PN_of_Posit"("AC_subset_PN_of_ID"),
    constraint "pkAC_subset_PN_of_Annex" primary key (
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_PositedAt"
    )
) ORDER BY "AC_subset_PN_of_ID", "AC_subset_PN_of_PositedAt" SEGMENTED BY MODULARHASH("AC_subset_PN_of_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS ties."EV_in_AC_wasCast_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_wasCast_Posit" (
    "EV_in_AC_wasCast_ID" integer default nextval('ties."EV_in_AC_wasCast_Posit_ID_SEQ"') not null, 
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_wasCast" smallint not null, 
    constraint "EV_in_AC_wasCast_Posit_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Event"("EV_ID"), 
    constraint "EV_in_AC_wasCast_Posit_fkAC_wasCast" foreign key (
        "AC_ID_wasCast"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "pkEV_in_AC_wasCast_Posit" primary key (
        "EV_in_AC_wasCast_ID"
    ),
    constraint "uqEV_in_AC_wasCast" unique (
        "EV_ID_in",
        "AC_ID_wasCast"
    )
) ORDER BY "EV_in_AC_wasCast_ID" SEGMENTED BY MODULARHASH("EV_in_AC_wasCast_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_wasCast_Annex" (
    "EV_in_AC_wasCast_ID" integer not null,
    "EV_in_AC_wasCast_PositedAt" timestamp not null,
    "EV_in_AC_wasCast_Reliability" decimal(5,2) not null,
    "Metadata_EV_in_AC_wasCast" integer not null,
    constraint "fkEV_in_AC_wasCast_Annex" foreign key (
        "EV_in_AC_wasCast_ID"
    ) references ties."EV_in_AC_wasCast_Posit"("EV_in_AC_wasCast_ID"),
    constraint "pkEV_in_AC_wasCast_Annex" primary key (
        "EV_in_AC_wasCast_ID",
        "EV_in_AC_wasCast_PositedAt"
    )
) ORDER BY "EV_in_AC_wasCast_ID", "EV_in_AC_wasCast_PositedAt" SEGMENTED BY MODULARHASH("EV_in_AC_wasCast_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Posit" (
    "AC_part_PR_in_RAT_got_ID" integer default nextval('ties."AC_part_PR_in_RAT_got_Posit_ID_SEQ"') not null, 
    "AC_ID_part" smallint not null, 
    "PR_ID_in" bigint not null, 
    "RAT_ID_got" tinyint not null,
    "AC_part_PR_in_RAT_got_ChangedAt" timestamp not null,
    constraint "AC_part_PR_in_RAT_got_Posit_fkAC_part" foreign key (
        "AC_ID_part"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_part_PR_in_RAT_got_Posit_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "AC_part_PR_in_RAT_got_Posit_fkRAT_got" foreign key (
        "RAT_ID_got"
    ) references knots."RAT_Rating"("RAT_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Posit" primary key (
        "AC_part_PR_in_RAT_got_ID"
    ),
    constraint "uqAC_part_PR_in_RAT_got" unique (
        "AC_ID_part",
        "PR_ID_in",
        "AC_part_PR_in_RAT_got_ChangedAt",
        "RAT_ID_got"
    )
) ORDER BY "AC_part_PR_in_RAT_got_ID" SEGMENTED BY MODULARHASH("AC_part_PR_in_RAT_got_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS ties."AC_part_PR_in_RAT_got_Annex" (
    "AC_part_PR_in_RAT_got_ID" integer not null,
    "AC_part_PR_in_RAT_got_PositedAt" timestamp not null,
    "AC_part_PR_in_RAT_got_Reliability" decimal(5,2) not null,
    "Metadata_AC_part_PR_in_RAT_got" integer not null,
    constraint "fkAC_part_PR_in_RAT_got_Annex" foreign key (
        "AC_part_PR_in_RAT_got_ID"
    ) references ties."AC_part_PR_in_RAT_got_Posit"("AC_part_PR_in_RAT_got_ID"),
    constraint "pkAC_part_PR_in_RAT_got_Annex" primary key (
        "AC_part_PR_in_RAT_got_ID",
        "AC_part_PR_in_RAT_got_PositedAt"
    )
) ORDER BY "AC_part_PR_in_RAT_got_ID", "AC_part_PR_in_RAT_got_PositedAt" SEGMENTED BY MODULARHASH("AC_part_PR_in_RAT_got_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS ties."ST_at_PR_isPlaying_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_isPlaying_Posit" (
    "ST_at_PR_isPlaying_ID" integer default nextval('ties."ST_at_PR_isPlaying_Posit_ID_SEQ"') not null, 
    "ST_ID_at" integer not null, 
    "PR_ID_isPlaying" bigint not null, 
    "ST_at_PR_isPlaying_ChangedAt" timestamp not null,
    constraint "ST_at_PR_isPlaying_Posit_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "ST_at_PR_isPlaying_Posit_fkPR_isPlaying" foreign key (
        "PR_ID_isPlaying"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "pkST_at_PR_isPlaying_Posit" primary key (
        "ST_at_PR_isPlaying_ID"
    ),
    constraint "uqST_at_PR_isPlaying" unique (
        "ST_ID_at",
        "PR_ID_isPlaying",
        "ST_at_PR_isPlaying_ChangedAt"
    )
) ORDER BY "ST_at_PR_isPlaying_ID" SEGMENTED BY MODULARHASH("ST_at_PR_isPlaying_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_isPlaying_Annex" (
    "ST_at_PR_isPlaying_ID" integer not null,
    "ST_at_PR_isPlaying_PositedAt" timestamp not null,
    "ST_at_PR_isPlaying_Reliability" decimal(5,2) not null,
    "Metadata_ST_at_PR_isPlaying" integer not null,
    constraint "fkST_at_PR_isPlaying_Annex" foreign key (
        "ST_at_PR_isPlaying_ID"
    ) references ties."ST_at_PR_isPlaying_Posit"("ST_at_PR_isPlaying_ID"),
    constraint "pkST_at_PR_isPlaying_Annex" primary key (
        "ST_at_PR_isPlaying_ID",
        "ST_at_PR_isPlaying_PositedAt"
    )
) ORDER BY "ST_at_PR_isPlaying_ID", "ST_at_PR_isPlaying_PositedAt" SEGMENTED BY MODULARHASH("ST_at_PR_isPlaying_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Posit" (
    "AC_parent_AC_child_PAT_having_ID" integer default nextval('ties."AC_parent_AC_child_PAT_having_Posit_ID_SEQ"') not null, 
    "AC_ID_parent" smallint not null, 
    "AC_ID_child" smallint not null, 
    "PAT_ID_having" tinyint not null,
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_parent" foreign key (
        "AC_ID_parent"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkAC_child" foreign key (
        "AC_ID_child"
    ) references anchors."AC_Actor"("AC_ID"), 
    constraint "AC_parent_AC_child_PAT_having_Posit_fkPAT_having" foreign key (
        "PAT_ID_having"
    ) references knots."PAT_ParentalType"("PAT_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Posit" primary key (
        "AC_parent_AC_child_PAT_having_ID"
    ),
    constraint "uqAC_parent_AC_child_PAT_having" unique (
        "AC_ID_parent",
        "AC_ID_child",
        "PAT_ID_having"
    )
) ORDER BY "AC_parent_AC_child_PAT_having_ID" SEGMENTED BY MODULARHASH("AC_parent_AC_child_PAT_having_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS ties."AC_parent_AC_child_PAT_having_Annex" (
    "AC_parent_AC_child_PAT_having_ID" integer not null,
    "AC_parent_AC_child_PAT_having_PositedAt" timestamp not null,
    "AC_parent_AC_child_PAT_having_Reliability" decimal(5,2) not null,
    "Metadata_AC_parent_AC_child_PAT_having" integer not null,
    constraint "fkAC_parent_AC_child_PAT_having_Annex" foreign key (
        "AC_parent_AC_child_PAT_having_ID"
    ) references ties."AC_parent_AC_child_PAT_having_Posit"("AC_parent_AC_child_PAT_having_ID"),
    constraint "pkAC_parent_AC_child_PAT_having_Annex" primary key (
        "AC_parent_AC_child_PAT_having_ID",
        "AC_parent_AC_child_PAT_having_PositedAt"
    )
) ORDER BY "AC_parent_AC_child_PAT_having_ID", "AC_parent_AC_child_PAT_having_PositedAt" SEGMENTED BY MODULARHASH("AC_parent_AC_child_PAT_having_ID") ALL NODES;
CREATE SEQUENCE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Posit_ID_SEQ" START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Posit" (
    "PR_content_ST_location_EV_of_ID" integer default nextval('ties."PR_content_ST_location_EV_of_Posit_ID_SEQ"') not null, 
    "PR_ID_content" bigint not null, 
    "ST_ID_location" integer not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_content_ST_location_EV_of_ChangedAt" timestamp not null,
    constraint "PR_content_ST_location_EV_of_Posit_fkPR_content" foreign key (
        "PR_ID_content"
    ) references anchors."PR_Program"("PR_ID"), 
    constraint "PR_content_ST_location_EV_of_Posit_fkST_location" foreign key (
        "ST_ID_location"
    ) references anchors."ST_Stage"("ST_ID"), 
    constraint "PR_content_ST_location_EV_of_Posit_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Event"("EV_ID"), 
    constraint "PR_content_ST_location_EV_of_Posit_uqPR_content" unique (
        "PR_ID_content",
        "PR_content_ST_location_EV_of_ChangedAt"
    ),
    constraint "PR_content_ST_location_EV_of_Posit_uqST_location" unique (
        "ST_ID_location",
        "PR_content_ST_location_EV_of_ChangedAt"
    ),
    constraint "pkPR_content_ST_location_EV_of_Posit" primary key (
        "PR_content_ST_location_EV_of_ID"
    ),
    constraint "uqPR_content_ST_location_EV_of" unique (
        "PR_content_ST_location_EV_of_ChangedAt",
        "PR_ID_content",
        "ST_ID_location",
        "EV_ID_of"
    )
) ORDER BY "PR_content_ST_location_EV_of_ID" SEGMENTED BY MODULARHASH("PR_content_ST_location_EV_of_ID") ALL NODES;
CREATE TABLE IF NOT EXISTS ties."PR_content_ST_location_EV_of_Annex" (
    "PR_content_ST_location_EV_of_ID" integer not null,
    "PR_content_ST_location_EV_of_PositedAt" timestamp not null,
    "PR_content_ST_location_EV_of_Reliability" decimal(5,2) not null,
    "Metadata_PR_content_ST_location_EV_of" integer not null,
    constraint "fkPR_content_ST_location_EV_of_Annex" foreign key (
        "PR_content_ST_location_EV_of_ID"
    ) references ties."PR_content_ST_location_EV_of_Posit"("PR_content_ST_location_EV_of_ID"),
    constraint "pkPR_content_ST_location_EV_of_Annex" primary key (
        "PR_content_ST_location_EV_of_ID",
        "PR_content_ST_location_EV_of_PositedAt"
    )
) ORDER BY "PR_content_ST_location_EV_of_ID", "PR_content_ST_location_EV_of_PositedAt" SEGMENTED BY MODULARHASH("PR_content_ST_location_EV_of_ID") ALL NODES;
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling.
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
    a."AC_partner_AC_with_ONG_currently_Reliability"
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    ties."AC_partner_AC_with_ONG_currently_Annex" a
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
    a."AC_subset_PN_of_Reliability"
FROM
    ties."AC_subset_PN_of_Posit" p
JOIN
    ties."AC_subset_PN_of_Annex" a
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
    a."EV_in_AC_wasCast_Reliability"
FROM
    ties."EV_in_AC_wasCast_Posit" p
JOIN
    ties."EV_in_AC_wasCast_Annex" a
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
    a."AC_part_PR_in_RAT_got_Reliability"
FROM
    ties."AC_part_PR_in_RAT_got_Posit" p
JOIN
    ties."AC_part_PR_in_RAT_got_Annex" a
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
    a."ST_at_PR_isPlaying_Reliability"
FROM
    ties."ST_at_PR_isPlaying_Posit" p
JOIN
    ties."ST_at_PR_isPlaying_Annex" a
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
    a."AC_parent_AC_child_PAT_having_Reliability"
FROM
    ties."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    ties."AC_parent_AC_child_PAT_having_Annex" a
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
    a."PR_content_ST_location_EV_of_Reliability"
FROM
    ties."PR_content_ST_location_EV_of_Posit" p
JOIN
    ties."PR_content_ST_location_EV_of_Annex" a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
;
-- TIE REWINDERS ------------------------------------------------------------------------------------------------------
--
-- A rewinder shows the posits of a tie with the latest row of their annex: what is known now about each posit, which is
-- asserted or retracted. Vertica has no function that returns a table, so it is a view and shows what is known now
-- (the rewinders of the other databases can be asked about an earlier time); the perspectives that Vertica has are over it.
--
CREATE OR REPLACE VIEW ties."rAC_partner_AC_with_ONG_currently" AS
SELECT
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Reliability"
FROM
    ties."AC_partner_AC_with_ONG_currently_Posit" p
JOIN
    ties."AC_partner_AC_with_ONG_currently_Annex" a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_partner_AC_with_ONG_currently_ID"
    ORDER BY a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW ties."rAC_subset_PN_of" AS
SELECT
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Reliability"
FROM
    ties."AC_subset_PN_of_Posit" p
JOIN
    ties."AC_subset_PN_of_Annex" a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_subset_PN_of_ID"
    ORDER BY a."AC_subset_PN_of_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW ties."rEV_in_AC_wasCast" AS
SELECT
    a."Metadata_EV_in_AC_wasCast",
    p."EV_in_AC_wasCast_ID",
    p."EV_ID_in",
    p."AC_ID_wasCast",
    a."EV_in_AC_wasCast_PositedAt",
    a."EV_in_AC_wasCast_Reliability"
FROM
    ties."EV_in_AC_wasCast_Posit" p
JOIN
    ties."EV_in_AC_wasCast_Annex" a
ON
    a."EV_in_AC_wasCast_ID" = p."EV_in_AC_wasCast_ID"
LIMIT 1 OVER (
    PARTITION BY p."EV_in_AC_wasCast_ID"
    ORDER BY a."EV_in_AC_wasCast_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW ties."rAC_part_PR_in_RAT_got" AS
SELECT
    a."Metadata_AC_part_PR_in_RAT_got",
    p."AC_part_PR_in_RAT_got_ID",
    p."AC_ID_part",
    p."PR_ID_in",
    p."RAT_ID_got",
    p."AC_part_PR_in_RAT_got_ChangedAt",
    a."AC_part_PR_in_RAT_got_PositedAt",
    a."AC_part_PR_in_RAT_got_Reliability"
FROM
    ties."AC_part_PR_in_RAT_got_Posit" p
JOIN
    ties."AC_part_PR_in_RAT_got_Annex" a
ON
    a."AC_part_PR_in_RAT_got_ID" = p."AC_part_PR_in_RAT_got_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_part_PR_in_RAT_got_ID"
    ORDER BY a."AC_part_PR_in_RAT_got_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW ties."rST_at_PR_isPlaying" AS
SELECT
    a."Metadata_ST_at_PR_isPlaying",
    p."ST_at_PR_isPlaying_ID",
    p."ST_ID_at",
    p."PR_ID_isPlaying",
    p."ST_at_PR_isPlaying_ChangedAt",
    a."ST_at_PR_isPlaying_PositedAt",
    a."ST_at_PR_isPlaying_Reliability"
FROM
    ties."ST_at_PR_isPlaying_Posit" p
JOIN
    ties."ST_at_PR_isPlaying_Annex" a
ON
    a."ST_at_PR_isPlaying_ID" = p."ST_at_PR_isPlaying_ID"
LIMIT 1 OVER (
    PARTITION BY p."ST_at_PR_isPlaying_ID"
    ORDER BY a."ST_at_PR_isPlaying_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW ties."rAC_parent_AC_child_PAT_having" AS
SELECT
    a."Metadata_AC_parent_AC_child_PAT_having",
    p."AC_parent_AC_child_PAT_having_ID",
    p."AC_ID_parent",
    p."AC_ID_child",
    p."PAT_ID_having",
    a."AC_parent_AC_child_PAT_having_PositedAt",
    a."AC_parent_AC_child_PAT_having_Reliability"
FROM
    ties."AC_parent_AC_child_PAT_having_Posit" p
JOIN
    ties."AC_parent_AC_child_PAT_having_Annex" a
ON
    a."AC_parent_AC_child_PAT_having_ID" = p."AC_parent_AC_child_PAT_having_ID"
LIMIT 1 OVER (
    PARTITION BY p."AC_parent_AC_child_PAT_having_ID"
    ORDER BY a."AC_parent_AC_child_PAT_having_PositedAt" DESC
)
;
CREATE OR REPLACE VIEW ties."rPR_content_ST_location_EV_of" AS
SELECT
    a."Metadata_PR_content_ST_location_EV_of",
    p."PR_content_ST_location_EV_of_ID",
    p."PR_ID_content",
    p."ST_ID_location",
    p."EV_ID_of",
    p."PR_content_ST_location_EV_of_ChangedAt",
    a."PR_content_ST_location_EV_of_PositedAt",
    a."PR_content_ST_location_EV_of_Reliability"
FROM
    ties."PR_content_ST_location_EV_of_Posit" p
JOIN
    ties."PR_content_ST_location_EV_of_Annex" a
ON
    a."PR_content_ST_location_EV_of_ID" = p."PR_content_ST_location_EV_of_ID"
LIMIT 1 OVER (
    PARTITION BY p."PR_content_ST_location_EV_of_ID"
    ORDER BY a."PR_content_ST_location_EV_of_PositedAt" DESC
)
;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: latest (l) and now (n). Vertica has no function that returns a table, so the perspectives that take
-- a time (time traveling, point-in-time and difference) are not made; the latest and the now perspectives take none, and are
-- views over the rewinder of the tie (a view that shows the latest annex row of every posit).
--
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" AS
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM
        ties."rAC_partner_AC_with_ONG_currently" r
    WHERE
        r."AC_partner_AC_with_ONG_currently_Reliability" = 1
) t
LEFT JOIN
    knots."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Ongoing" AS "currently_ONG_Ongoing",
    "kONG_currently"."Metadata_ONG" AS "currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_partner"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_partner",
        row_number() OVER (
            PARTITION BY r."AC_ID_with"
            ORDER BY
                r."AC_partner_AC_with_ONG_currently_ChangedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_PositedAt" DESC,
                r."AC_partner_AC_with_ONG_currently_ID" DESC
        ) AS "latestAC_ID_with"
    FROM
        ties."rAC_partner_AC_with_ONG_currently" r
    WHERE
        r."AC_partner_AC_with_ONG_currently_Reliability" = 1
    AND
        r."AC_partner_AC_with_ONG_currently_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    knots."ONG_Ongoing" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
;
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" AS
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Reliability",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_subset"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY r."PN_ID_of"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM
        ties."rAC_subset_PN_of" r
    WHERE
        r."AC_subset_PN_of_Reliability" = 1
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Reliability",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."AC_ID_subset"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestAC_ID_subset",
        row_number() OVER (
            PARTITION BY r."PN_ID_of"
            ORDER BY
                r."AC_subset_PN_of_PositedAt" DESC,
                r."AC_subset_PN_of_ID" DESC
        ) AS "latestPN_ID_of"
    FROM
        ties."rAC_subset_PN_of" r
    WHERE
        r."AC_subset_PN_of_Reliability" = 1
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
;
CREATE OR REPLACE VIEW ties."lEV_in_AC_wasCast" AS
SELECT
    t."EV_in_AC_wasCast_ID",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."EV_ID_in",
                r."AC_ID_wasCast"
            ORDER BY
                r."EV_in_AC_wasCast_PositedAt" DESC,
                r."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM
        ties."rEV_in_AC_wasCast" r
    WHERE
        r."EV_in_AC_wasCast_Reliability" = 1
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nEV_in_AC_wasCast" AS
SELECT
    t."EV_in_AC_wasCast_ID",
    t."Metadata_EV_in_AC_wasCast",
    t."EV_in_AC_wasCast_PositedAt",
    t."EV_in_AC_wasCast_Reliability",
    t."EV_ID_in",
    t."AC_ID_wasCast"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."EV_ID_in",
                r."AC_ID_wasCast"
            ORDER BY
                r."EV_in_AC_wasCast_PositedAt" DESC,
                r."EV_in_AC_wasCast_ID" DESC
        ) AS "latest"
    FROM
        ties."rEV_in_AC_wasCast" r
    WHERE
        r."EV_in_AC_wasCast_Reliability" = 1
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lAC_part_PR_in_RAT_got" AS
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_part",
                r."PR_ID_in"
            ORDER BY
                r."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                r."AC_part_PR_in_RAT_got_PositedAt" DESC,
                r."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_part_PR_in_RAT_got" r
    WHERE
        r."AC_part_PR_in_RAT_got_Reliability" = 1
) t
LEFT JOIN
    knots."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nAC_part_PR_in_RAT_got" AS
SELECT
    t."AC_part_PR_in_RAT_got_ID",
    t."Metadata_AC_part_PR_in_RAT_got",
    t."AC_part_PR_in_RAT_got_ChangedAt",
    t."AC_part_PR_in_RAT_got_PositedAt",
    t."AC_part_PR_in_RAT_got_Reliability",
    t."AC_ID_part",
    t."PR_ID_in",
    "kRAT_got"."RAT_Rating" AS "got_RAT_Rating",
    "kRAT_got"."Metadata_RAT" AS "got_Metadata_RAT",
    t."RAT_ID_got"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_part",
                r."PR_ID_in"
            ORDER BY
                r."AC_part_PR_in_RAT_got_ChangedAt" DESC,
                r."AC_part_PR_in_RAT_got_PositedAt" DESC,
                r."AC_part_PR_in_RAT_got_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_part_PR_in_RAT_got" r
    WHERE
        r."AC_part_PR_in_RAT_got_Reliability" = 1
    AND
        r."AC_part_PR_in_RAT_got_ChangedAt" <= current_timestamp::timestamp
) t
LEFT JOIN
    knots."RAT_Rating" "kRAT_got"
ON
    "kRAT_got"."RAT_ID" = t."RAT_ID_got"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lST_at_PR_isPlaying" AS
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_isPlaying"
            ORDER BY
                r."ST_at_PR_isPlaying_ChangedAt" DESC,
                r."ST_at_PR_isPlaying_PositedAt" DESC,
                r."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM
        ties."rST_at_PR_isPlaying" r
    WHERE
        r."ST_at_PR_isPlaying_Reliability" = 1
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nST_at_PR_isPlaying" AS
SELECT
    t."ST_at_PR_isPlaying_ID",
    t."Metadata_ST_at_PR_isPlaying",
    t."ST_at_PR_isPlaying_ChangedAt",
    t."ST_at_PR_isPlaying_PositedAt",
    t."ST_at_PR_isPlaying_Reliability",
    t."ST_ID_at",
    t."PR_ID_isPlaying"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_isPlaying"
            ORDER BY
                r."ST_at_PR_isPlaying_ChangedAt" DESC,
                r."ST_at_PR_isPlaying_PositedAt" DESC,
                r."ST_at_PR_isPlaying_ID" DESC
        ) AS "latest"
    FROM
        ties."rST_at_PR_isPlaying" r
    WHERE
        r."ST_at_PR_isPlaying_Reliability" = 1
    AND
        r."ST_at_PR_isPlaying_ChangedAt" <= current_timestamp::timestamp
) t
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lAC_parent_AC_child_PAT_having" AS
SELECT
    t."AC_parent_AC_child_PAT_having_ID",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_parent",
                r."AC_ID_child",
                r."PAT_ID_having"
            ORDER BY
                r."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                r."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_parent_AC_child_PAT_having" r
    WHERE
        r."AC_parent_AC_child_PAT_having_Reliability" = 1
) t
LEFT JOIN
    knots."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."nAC_parent_AC_child_PAT_having" AS
SELECT
    t."AC_parent_AC_child_PAT_having_ID",
    t."Metadata_AC_parent_AC_child_PAT_having",
    t."AC_parent_AC_child_PAT_having_PositedAt",
    t."AC_parent_AC_child_PAT_having_Reliability",
    t."AC_ID_parent",
    t."AC_ID_child",
    "kPAT_having"."PAT_ParentalType" AS "having_PAT_ParentalType",
    "kPAT_having"."Metadata_PAT" AS "having_Metadata_PAT",
    t."PAT_ID_having"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_parent",
                r."AC_ID_child",
                r."PAT_ID_having"
            ORDER BY
                r."AC_parent_AC_child_PAT_having_PositedAt" DESC,
                r."AC_parent_AC_child_PAT_having_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_parent_AC_child_PAT_having" r
    WHERE
        r."AC_parent_AC_child_PAT_having_Reliability" = 1
) t
LEFT JOIN
    knots."PAT_ParentalType" "kPAT_having"
ON
    "kPAT_having"."PAT_ID" = t."PAT_ID_having"
WHERE
    t."latest" = 1
;
CREATE OR REPLACE VIEW ties."lPR_content_ST_location_EV_of" AS
SELECT
    t."PR_content_ST_location_EV_of_ID",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_content"
            ORDER BY
                r."PR_content_ST_location_EV_of_ChangedAt" DESC,
                r."PR_content_ST_location_EV_of_PositedAt" DESC,
                r."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latestPR_ID_content",
        row_number() OVER (
            PARTITION BY r."ST_ID_location"
            ORDER BY
                r."PR_content_ST_location_EV_of_ChangedAt" DESC,
                r."PR_content_ST_location_EV_of_PositedAt" DESC,
                r."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latestST_ID_location"
    FROM
        ties."rPR_content_ST_location_EV_of" r
    WHERE
        r."PR_content_ST_location_EV_of_Reliability" = 1
) t
WHERE
    t."latestPR_ID_content" = 1
AND
    t."latestST_ID_location" = 1
;
CREATE OR REPLACE VIEW ties."nPR_content_ST_location_EV_of" AS
SELECT
    t."PR_content_ST_location_EV_of_ID",
    t."Metadata_PR_content_ST_location_EV_of",
    t."PR_content_ST_location_EV_of_ChangedAt",
    t."PR_content_ST_location_EV_of_PositedAt",
    t."PR_content_ST_location_EV_of_Reliability",
    t."PR_ID_content",
    t."ST_ID_location",
    t."EV_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_content"
            ORDER BY
                r."PR_content_ST_location_EV_of_ChangedAt" DESC,
                r."PR_content_ST_location_EV_of_PositedAt" DESC,
                r."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latestPR_ID_content",
        row_number() OVER (
            PARTITION BY r."ST_ID_location"
            ORDER BY
                r."PR_content_ST_location_EV_of_ChangedAt" DESC,
                r."PR_content_ST_location_EV_of_PositedAt" DESC,
                r."PR_content_ST_location_EV_of_ID" DESC
        ) AS "latestST_ID_location"
    FROM
        ties."rPR_content_ST_location_EV_of" r
    WHERE
        r."PR_content_ST_location_EV_of_Reliability" = 1
    AND
        r."PR_content_ST_location_EV_of_ChangedAt" <= current_timestamp::timestamp
) t
WHERE
    t."latestPR_ID_content" = 1
AND
    t."latestST_ID_location" = 1
;
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
COMMENT ON COLUMN attributes."EV_DAT_Event_Date_Posit"."EV_DAT_Event_Date" IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes."EV_AUD_Event_Audience_Posit"."EV_AUD_Event_Audience" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes."EV_REV_Event_Revenue_Posit"."EV_REV_Event_Revenue" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes."EV_STA_Event_Status_Posit"."EV_STA_Event_Status" IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes."EV_LVL_Event_Level_Posit"."EV_LVL_PLV_ID" IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes."ST_NAM_Stage_Name_Posit"."ST_NAM_Stage_Name" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes."ST_LOC_Stage_Location_Posit"."ST_LOC_Stage_Location" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes."ST_AVG_Stage_Average_Posit"."ST_AVG_UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes."ST_MIN_Stage_Minimum_Posit"."ST_MIN_UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes."AC_NAM_Actor_Name_Posit"."AC_NAM_Actor_Name" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes."AC_GEN_Actor_Gender_Posit"."AC_GEN_GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN attributes."AC_PLV_Actor_ProfessionalLevel_Posit"."AC_PLV_PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes."PR_NAM_Program_Name_Posit"."PR_NAM_Program_Name" IS 'Name or title of the program.';
COMMENT ON COLUMN attributes."PR_LEN_Program_Length_Posit"."PR_LEN_Program_Length" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors."ST_Stage" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors."AC_Actor" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses."EV_Event" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses."EV_Event"."ST_ID_wasHeldAt" IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses."EV_Event"."PR_ID_wasPlayed" IS 'The program that was played at the event.';
COMMENT ON TABLE ties."AC_partner_AC_with_ONG_currently_Posit" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Posit"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties."AC_subset_PN_of_Posit"."AC_ID_subset" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties."AC_subset_PN_of_Posit"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE ties."EV_in_AC_wasCast_Posit" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties."EV_in_AC_wasCast_Posit"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties."EV_in_AC_wasCast_Posit"."AC_ID_wasCast" IS 'An actor cast in the event.';
COMMENT ON TABLE ties."AC_part_PR_in_RAT_got_Posit" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got_Posit"."AC_ID_part" IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got_Posit"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties."AC_part_PR_in_RAT_got_Posit"."RAT_ID_got" IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties."ST_at_PR_isPlaying_Posit" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties."ST_at_PR_isPlaying_Posit"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties."ST_at_PR_isPlaying_Posit"."PR_ID_isPlaying" IS 'The program playing at the stage.';
COMMENT ON TABLE ties."AC_parent_AC_child_PAT_having_Posit" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having_Posit"."AC_ID_parent" IS 'The actor who is the parent.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having_Posit"."AC_ID_child" IS 'The actor who is the child.';
COMMENT ON COLUMN ties."AC_parent_AC_child_PAT_having_Posit"."PAT_ID_having" IS 'The type of parental relationship.';
COMMENT ON TABLE ties."PR_content_ST_location_EV_of_Posit" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of_Posit"."PR_ID_content" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of_Posit"."ST_ID_location" IS 'The stage where the event was located.';
COMMENT ON COLUMN ties."PR_content_ST_location_EV_of_Posit"."EV_ID_of" IS 'The event.';
