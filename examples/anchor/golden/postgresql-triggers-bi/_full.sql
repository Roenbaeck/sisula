-- SCHEMAS ------------------------------------------------------------------------------------------------------------
--
-- The schemas that the model puts its tables, views and functions in, made before anything is made in them.
--
CREATE SCHEMA IF NOT EXISTS public;
-- KNOTS --------------------------------------------------------------------------------------------------------------
--
-- Knots are immutable lookup tables for values.
--
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."GRD_Grade" (
    "GRD_ID" smallint not null,
    "GRD_Grade" varchar(42) not null,
    "Metadata_GRD" integer not null,
    constraint "pkGRD_Grade" primary key (
        "GRD_ID"
    ),
    constraint "uqGRD_Grade" unique (
        "GRD_Grade"
    )
);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors store immutable entity identities.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."OB_Object_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."OB_Object" (
    "OB_ID" integer default nextval('public."OB_Object_ID_SEQ"') not null, 
    "Metadata_OB" integer not null,
    constraint "pkOB_Object" primary key (
        "OB_ID"
    )
);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses store immutable identities for event-like entities.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS public."EV_Event_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_Event" (
    "EV_ID" integer default nextval('public."EV_Event_ID_SEQ"') not null, 
    "SU_ID_for" integer not null, 
    constraint "EV_Event_fkSU_for" foreign key (
        "SU_ID_for"
    ) references public."SU_Subject"("SU_ID"), 
    "Metadata_EV" integer not null, 
    constraint "pkEV_Event" primary key (
        "EV_ID"
    )
);
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS public."EV_QTY_Event_Quantity_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_QTY_Event_Quantity_Posit" (
    "EV_QTY_ID" integer default nextval('public."EV_QTY_Event_Quantity_Posit_ID_SEQ"') not null, 
    "EV_QTY_EV_ID" integer not null,
    "EV_QTY_Event_Quantity" integer not null,
    constraint "fkEV_QTY_Event_Quantity_Posit" foreign key (
        "EV_QTY_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_QTY_Event_Quantity_Posit" primary key (
        "EV_QTY_ID"
    ),
    constraint "uqEV_QTY_Event_Quantity_Posit" unique (
        "EV_QTY_EV_ID",
        "EV_QTY_Event_Quantity"
    )
);
CREATE TABLE IF NOT EXISTS public."EV_QTY_Event_Quantity_Annex" (
    "EV_QTY_ID" integer not null,
    "EV_QTY_PositedAt" timestamp not null,
    "EV_QTY_Reliability" decimal(5,2) not null,
    "Metadata_EV_QTY" integer not null,
    constraint "fkEV_QTY_Event_Quantity_Annex" foreign key (
        "EV_QTY_ID"
    ) references public."EV_QTY_Event_Quantity_Posit"("EV_QTY_ID"),
    constraint "pkEV_QTY_Event_Quantity_Annex" primary key (
        "EV_QTY_ID",
        "EV_QTY_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."EV_PLC_Event_Place_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."EV_PLC_Event_Place_Posit" (
    "EV_PLC_ID" integer default nextval('public."EV_PLC_Event_Place_Posit_ID_SEQ"') not null, 
    "EV_PLC_EV_ID" integer not null,
    "EV_PLC_Event_Place" varchar(42) not null,
    "EV_PLC_ChangedAt" timestamp not null,
    constraint "fkEV_PLC_Event_Place_Posit" foreign key (
        "EV_PLC_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_PLC_Event_Place_Posit" primary key (
        "EV_PLC_ID"
    ),
    constraint "uqEV_PLC_Event_Place_Posit" unique (
        "EV_PLC_EV_ID",
        "EV_PLC_ChangedAt",
        "EV_PLC_Event_Place"
    )
);
CREATE TABLE IF NOT EXISTS public."EV_PLC_Event_Place_Annex" (
    "EV_PLC_ID" integer not null,
    "EV_PLC_PositedAt" timestamp not null,
    "EV_PLC_Reliability" decimal(5,2) not null,
    "Metadata_EV_PLC" integer not null,
    constraint "fkEV_PLC_Event_Place_Annex" foreign key (
        "EV_PLC_ID"
    ) references public."EV_PLC_Event_Place_Posit"("EV_PLC_ID"),
    constraint "pkEV_PLC_Event_Place_Annex" primary key (
        "EV_PLC_ID",
        "EV_PLC_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_NAM_Subject_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_NAM_Subject_Name_Posit" (
    "SU_NAM_ID" integer default nextval('public."SU_NAM_Subject_Name_Posit_ID_SEQ"') not null, 
    "SU_NAM_SU_ID" integer not null,
    "SU_NAM_Subject_Name" varchar(42) not null,
    constraint "fkSU_NAM_Subject_Name_Posit" foreign key (
        "SU_NAM_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_NAM_Subject_Name_Posit" primary key (
        "SU_NAM_ID"
    ),
    constraint "uqSU_NAM_Subject_Name_Posit" unique (
        "SU_NAM_SU_ID",
        "SU_NAM_Subject_Name"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_NAM_Subject_Name_Annex" (
    "SU_NAM_ID" integer not null,
    "SU_NAM_PositedAt" timestamp not null,
    "SU_NAM_Reliability" decimal(5,2) not null,
    "Metadata_SU_NAM" integer not null,
    constraint "fkSU_NAM_Subject_Name_Annex" foreign key (
        "SU_NAM_ID"
    ) references public."SU_NAM_Subject_Name_Posit"("SU_NAM_ID"),
    constraint "pkSU_NAM_Subject_Name_Annex" primary key (
        "SU_NAM_ID",
        "SU_NAM_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_COD_Subject_Code_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_COD_Subject_Code_Posit" (
    "SU_COD_ID" integer default nextval('public."SU_COD_Subject_Code_Posit_ID_SEQ"') not null, 
    "SU_COD_SU_ID" integer not null,
    "SU_COD_Subject_Code" varchar(42) not null,
    constraint "fkSU_COD_Subject_Code_Posit" foreign key (
        "SU_COD_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_COD_Subject_Code_Posit" primary key (
        "SU_COD_ID"
    ),
    constraint "uqSU_COD_Subject_Code_Posit" unique (
        "SU_COD_SU_ID",
        "SU_COD_Subject_Code"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_COD_Subject_Code_Annex" (
    "SU_COD_ID" integer not null,
    "SU_COD_PositedAt" timestamp not null,
    "SU_COD_Reliability" decimal(5,2) not null,
    "Metadata_SU_COD" integer not null,
    constraint "fkSU_COD_Subject_Code_Annex" foreign key (
        "SU_COD_ID"
    ) references public."SU_COD_Subject_Code_Posit"("SU_COD_ID"),
    constraint "pkSU_COD_Subject_Code_Annex" primary key (
        "SU_COD_ID",
        "SU_COD_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_GRD_Subject_Grade_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_GRD_Subject_Grade_Posit" (
    "SU_GRD_ID" integer default nextval('public."SU_GRD_Subject_Grade_Posit_ID_SEQ"') not null, 
    "SU_GRD_SU_ID" integer not null,
    "SU_GRD_GRD_ID" smallint not null,
    constraint "fk_A_SU_GRD_Subject_Grade_Posit" foreign key (
        "SU_GRD_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "fk_K_SU_GRD_Subject_Grade_Posit" foreign key (
        "SU_GRD_GRD_ID"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_GRD_Subject_Grade_Posit" primary key (
        "SU_GRD_ID"
    ),
    constraint "uqSU_GRD_Subject_Grade_Posit" unique (
        "SU_GRD_SU_ID",
        "SU_GRD_GRD_ID"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_GRD_Subject_Grade_Annex" (
    "SU_GRD_ID" integer not null,
    "SU_GRD_PositedAt" timestamp not null,
    "SU_GRD_Reliability" decimal(5,2) not null,
    "Metadata_SU_GRD" integer not null,
    constraint "fkSU_GRD_Subject_Grade_Annex" foreign key (
        "SU_GRD_ID"
    ) references public."SU_GRD_Subject_Grade_Posit"("SU_GRD_ID"),
    constraint "pkSU_GRD_Subject_Grade_Annex" primary key (
        "SU_GRD_ID",
        "SU_GRD_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_NOT_Subject_Note_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_NOT_Subject_Note_Posit" (
    "SU_NOT_ID" integer default nextval('public."SU_NOT_Subject_Note_Posit_ID_SEQ"') not null, 
    "SU_NOT_SU_ID" integer not null,
    "SU_NOT_Subject_Note" text not null,
    "SU_NOT_Checksum" bytea generated always as (decode(md5("SU_NOT_Subject_Note"::text), 'hex')) stored,
    constraint "fkSU_NOT_Subject_Note_Posit" foreign key (
        "SU_NOT_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_NOT_Subject_Note_Posit" primary key (
        "SU_NOT_ID"
    ),
    constraint "uqSU_NOT_Subject_Note_Posit" unique (
        "SU_NOT_SU_ID",
        "SU_NOT_Checksum" 
    )
);
CREATE TABLE IF NOT EXISTS public."SU_NOT_Subject_Note_Annex" (
    "SU_NOT_ID" integer not null,
    "SU_NOT_PositedAt" timestamp not null,
    "SU_NOT_Reliability" decimal(5,2) not null,
    "Metadata_SU_NOT" integer not null,
    constraint "fkSU_NOT_Subject_Note_Annex" foreign key (
        "SU_NOT_ID"
    ) references public."SU_NOT_Subject_Note_Posit"("SU_NOT_ID"),
    constraint "pkSU_NOT_Subject_Note_Annex" primary key (
        "SU_NOT_ID",
        "SU_NOT_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_TTL_Subject_Title_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_TTL_Subject_Title_Posit" (
    "SU_TTL_ID" integer default nextval('public."SU_TTL_Subject_Title_Posit_ID_SEQ"') not null, 
    "SU_TTL_SU_ID" integer not null,
    "SU_TTL_Subject_Title" varchar(42) not null,
    "SU_TTL_ChangedAt" timestamp not null,
    constraint "fkSU_TTL_Subject_Title_Posit" foreign key (
        "SU_TTL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TTL_Subject_Title_Posit" primary key (
        "SU_TTL_ID"
    ),
    constraint "uqSU_TTL_Subject_Title_Posit" unique (
        "SU_TTL_SU_ID",
        "SU_TTL_ChangedAt",
        "SU_TTL_Subject_Title"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_TTL_Subject_Title_Annex" (
    "SU_TTL_ID" integer not null,
    "SU_TTL_PositedAt" timestamp not null,
    "SU_TTL_Reliability" decimal(5,2) not null,
    "Metadata_SU_TTL" integer not null,
    constraint "fkSU_TTL_Subject_Title_Annex" foreign key (
        "SU_TTL_ID"
    ) references public."SU_TTL_Subject_Title_Posit"("SU_TTL_ID"),
    constraint "pkSU_TTL_Subject_Title_Annex" primary key (
        "SU_TTL_ID",
        "SU_TTL_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_STA_Subject_State_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_STA_Subject_State_Posit" (
    "SU_STA_ID" integer default nextval('public."SU_STA_Subject_State_Posit_ID_SEQ"') not null, 
    "SU_STA_SU_ID" integer not null,
    "SU_STA_Subject_State" varchar(42) not null,
    "SU_STA_ChangedAt" timestamp not null,
    constraint "fkSU_STA_Subject_State_Posit" foreign key (
        "SU_STA_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_STA_Subject_State_Posit" primary key (
        "SU_STA_ID"
    ),
    constraint "uqSU_STA_Subject_State_Posit" unique (
        "SU_STA_SU_ID",
        "SU_STA_ChangedAt",
        "SU_STA_Subject_State"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_STA_Subject_State_Annex" (
    "SU_STA_ID" integer not null,
    "SU_STA_PositedAt" timestamp not null,
    "SU_STA_Reliability" decimal(5,2) not null,
    "Metadata_SU_STA" integer not null,
    constraint "fkSU_STA_Subject_State_Annex" foreign key (
        "SU_STA_ID"
    ) references public."SU_STA_Subject_State_Posit"("SU_STA_ID"),
    constraint "pkSU_STA_Subject_State_Annex" primary key (
        "SU_STA_ID",
        "SU_STA_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_LBL_Subject_Label_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_LBL_Subject_Label_Posit" (
    "SU_LBL_ID" integer default nextval('public."SU_LBL_Subject_Label_Posit_ID_SEQ"') not null, 
    "SU_LBL_SU_ID" integer not null,
    "SU_LBL_Subject_Label" varchar(42) not null,
    "SU_LBL_ChangedAt" timestamp not null,
    constraint "fkSU_LBL_Subject_Label_Posit" foreign key (
        "SU_LBL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_LBL_Subject_Label_Posit" primary key (
        "SU_LBL_ID"
    ),
    constraint "uqSU_LBL_Subject_Label_Posit" unique (
        "SU_LBL_SU_ID",
        "SU_LBL_ChangedAt",
        "SU_LBL_Subject_Label"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_LBL_Subject_Label_Annex" (
    "SU_LBL_ID" integer not null,
    "SU_LBL_PositedAt" timestamp not null,
    "SU_LBL_Reliability" decimal(5,2) not null,
    "Metadata_SU_LBL" integer not null,
    constraint "fkSU_LBL_Subject_Label_Annex" foreign key (
        "SU_LBL_ID"
    ) references public."SU_LBL_Subject_Label_Posit"("SU_LBL_ID"),
    constraint "pkSU_LBL_Subject_Label_Annex" primary key (
        "SU_LBL_ID",
        "SU_LBL_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_TAG_Subject_Tag_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_TAG_Subject_Tag_Posit" (
    "SU_TAG_ID" integer default nextval('public."SU_TAG_Subject_Tag_Posit_ID_SEQ"') not null, 
    "SU_TAG_SU_ID" integer not null,
    "SU_TAG_Subject_Tag" varchar(42) not null,
    "SU_TAG_ChangedAt" timestamp not null,
    constraint "fkSU_TAG_Subject_Tag_Posit" foreign key (
        "SU_TAG_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TAG_Subject_Tag_Posit" primary key (
        "SU_TAG_ID"
    ),
    constraint "uqSU_TAG_Subject_Tag_Posit" unique (
        "SU_TAG_SU_ID",
        "SU_TAG_ChangedAt",
        "SU_TAG_Subject_Tag"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_TAG_Subject_Tag_Annex" (
    "SU_TAG_ID" integer not null,
    "SU_TAG_PositedAt" timestamp not null,
    "SU_TAG_Reliability" decimal(5,2) not null,
    "Metadata_SU_TAG" integer not null,
    constraint "fkSU_TAG_Subject_Tag_Annex" foreign key (
        "SU_TAG_ID"
    ) references public."SU_TAG_Subject_Tag_Posit"("SU_TAG_ID"),
    constraint "pkSU_TAG_Subject_Tag_Annex" primary key (
        "SU_TAG_ID",
        "SU_TAG_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_LVL_Subject_Level_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_LVL_Subject_Level_Posit" (
    "SU_LVL_ID" integer default nextval('public."SU_LVL_Subject_Level_Posit_ID_SEQ"') not null, 
    "SU_LVL_SU_ID" integer not null,
    "SU_LVL_GRD_ID" smallint not null,
    "SU_LVL_ChangedAt" timestamp not null,
    constraint "fk_A_SU_LVL_Subject_Level_Posit" foreign key (
        "SU_LVL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "fk_K_SU_LVL_Subject_Level_Posit" foreign key (
        "SU_LVL_GRD_ID"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_LVL_Subject_Level_Posit" primary key (
        "SU_LVL_ID"
    ),
    constraint "uqSU_LVL_Subject_Level_Posit" unique (
        "SU_LVL_SU_ID",
        "SU_LVL_ChangedAt",
        "SU_LVL_GRD_ID"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_LVL_Subject_Level_Annex" (
    "SU_LVL_ID" integer not null,
    "SU_LVL_PositedAt" timestamp not null,
    "SU_LVL_Reliability" decimal(5,2) not null,
    "Metadata_SU_LVL" integer not null,
    constraint "fkSU_LVL_Subject_Level_Annex" foreign key (
        "SU_LVL_ID"
    ) references public."SU_LVL_Subject_Level_Posit"("SU_LVL_ID"),
    constraint "pkSU_LVL_Subject_Level_Annex" primary key (
        "SU_LVL_ID",
        "SU_LVL_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_TXT_Subject_Text_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_TXT_Subject_Text_Posit" (
    "SU_TXT_ID" integer default nextval('public."SU_TXT_Subject_Text_Posit_ID_SEQ"') not null, 
    "SU_TXT_SU_ID" integer not null,
    "SU_TXT_Subject_Text" text not null,
    "SU_TXT_Checksum" bytea generated always as (decode(md5("SU_TXT_Subject_Text"::text), 'hex')) stored,
    "SU_TXT_ChangedAt" timestamp not null,
    constraint "fkSU_TXT_Subject_Text_Posit" foreign key (
        "SU_TXT_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TXT_Subject_Text_Posit" primary key (
        "SU_TXT_ID"
    ),
    constraint "uqSU_TXT_Subject_Text_Posit" unique (
        "SU_TXT_SU_ID",
        "SU_TXT_ChangedAt",
        "SU_TXT_Checksum" 
    )
);
CREATE TABLE IF NOT EXISTS public."SU_TXT_Subject_Text_Annex" (
    "SU_TXT_ID" integer not null,
    "SU_TXT_PositedAt" timestamp not null,
    "SU_TXT_Reliability" decimal(5,2) not null,
    "Metadata_SU_TXT" integer not null,
    constraint "fkSU_TXT_Subject_Text_Annex" foreign key (
        "SU_TXT_ID"
    ) references public."SU_TXT_Subject_Text_Posit"("SU_TXT_ID"),
    constraint "pkSU_TXT_Subject_Text_Annex" primary key (
        "SU_TXT_ID",
        "SU_TXT_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_ASR_Subject_Assessment_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_ASR_Subject_Assessment_Posit" (
    "SU_ASR_ID" integer default nextval('public."SU_ASR_Subject_Assessment_Posit_ID_SEQ"') not null, 
    "SU_ASR_SU_ID" integer not null,
    "SU_ASR_Subject_Assessment" varchar(42) not null,
    "SU_ASR_ChangedAt" timestamp not null,
    constraint "fkSU_ASR_Subject_Assessment_Posit" foreign key (
        "SU_ASR_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_ASR_Subject_Assessment_Posit" primary key (
        "SU_ASR_ID"
    ),
    constraint "uqSU_ASR_Subject_Assessment_Posit" unique (
        "SU_ASR_SU_ID",
        "SU_ASR_ChangedAt",
        "SU_ASR_Subject_Assessment"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_ASR_Subject_Assessment_Annex" (
    "SU_ASR_ID" integer not null,
    "SU_ASR_PositedAt" timestamp not null,
    "SU_ASR_Reliability" decimal(5,2) not null,
    "Metadata_SU_ASR" integer not null,
    constraint "fkSU_ASR_Subject_Assessment_Annex" foreign key (
        "SU_ASR_ID"
    ) references public."SU_ASR_Subject_Assessment_Posit"("SU_ASR_ID"),
    constraint "pkSU_ASR_Subject_Assessment_Annex" primary key (
        "SU_ASR_ID",
        "SU_ASR_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_ERS_Subject_Erasable_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_ERS_Subject_Erasable_Posit" (
    "SU_ERS_ID" integer default nextval('public."SU_ERS_Subject_Erasable_Posit_ID_SEQ"') not null, 
    "SU_ERS_SU_ID" integer not null,
    "SU_ERS_Subject_Erasable" varchar(42) not null,
    "SU_ERS_ChangedAt" timestamp not null,
    constraint "fkSU_ERS_Subject_Erasable_Posit" foreign key (
        "SU_ERS_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_ERS_Subject_Erasable_Posit" primary key (
        "SU_ERS_ID"
    ),
    constraint "uqSU_ERS_Subject_Erasable_Posit" unique (
        "SU_ERS_SU_ID",
        "SU_ERS_ChangedAt",
        "SU_ERS_Subject_Erasable"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_ERS_Subject_Erasable_Annex" (
    "SU_ERS_ID" integer not null,
    "SU_ERS_PositedAt" timestamp not null,
    "SU_ERS_Reliability" decimal(5,2) not null,
    "Metadata_SU_ERS" integer not null,
    constraint "fkSU_ERS_Subject_Erasable_Annex" foreign key (
        "SU_ERS_ID"
    ) references public."SU_ERS_Subject_Erasable_Posit"("SU_ERS_ID"),
    constraint "pkSU_ERS_Subject_Erasable_Annex" primary key (
        "SU_ERS_ID",
        "SU_ERS_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."OB_NAM_Object_Name_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."OB_NAM_Object_Name_Posit" (
    "OB_NAM_ID" integer default nextval('public."OB_NAM_Object_Name_Posit_ID_SEQ"') not null, 
    "OB_NAM_OB_ID" integer not null,
    "OB_NAM_Object_Name" varchar(42) not null,
    constraint "fkOB_NAM_Object_Name_Posit" foreign key (
        "OB_NAM_OB_ID"
    ) references public."OB_Object"("OB_ID"),
    constraint "pkOB_NAM_Object_Name_Posit" primary key (
        "OB_NAM_ID"
    ),
    constraint "uqOB_NAM_Object_Name_Posit" unique (
        "OB_NAM_OB_ID",
        "OB_NAM_Object_Name"
    )
);
CREATE TABLE IF NOT EXISTS public."OB_NAM_Object_Name_Annex" (
    "OB_NAM_ID" integer not null,
    "OB_NAM_PositedAt" timestamp not null,
    "OB_NAM_Reliability" decimal(5,2) not null,
    "Metadata_OB_NAM" integer not null,
    constraint "fkOB_NAM_Object_Name_Annex" foreign key (
        "OB_NAM_ID"
    ) references public."OB_NAM_Object_Name_Posit"("OB_NAM_ID"),
    constraint "pkOB_NAM_Object_Name_Annex" primary key (
        "OB_NAM_ID",
        "OB_NAM_PositedAt"
    )
);
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW public."EV_QTY_Event_Quantity" AS
SELECT
    a."Metadata_EV_QTY",
    p."EV_QTY_ID",
    p."EV_QTY_EV_ID",
    p."EV_QTY_Event_Quantity",
    a."EV_QTY_PositedAt",
    a."EV_QTY_Reliability"
FROM
    public."EV_QTY_Event_Quantity_Posit" p
JOIN
    public."EV_QTY_Event_Quantity_Annex" a
ON
    a."EV_QTY_ID" = p."EV_QTY_ID"
;
CREATE OR REPLACE VIEW public."EV_PLC_Event_Place" AS
SELECT
    a."Metadata_EV_PLC",
    p."EV_PLC_ID",
    p."EV_PLC_EV_ID",
    p."EV_PLC_Event_Place",
    p."EV_PLC_ChangedAt",
    a."EV_PLC_PositedAt",
    a."EV_PLC_Reliability"
FROM
    public."EV_PLC_Event_Place_Posit" p
JOIN
    public."EV_PLC_Event_Place_Annex" a
ON
    a."EV_PLC_ID" = p."EV_PLC_ID"
;
CREATE OR REPLACE VIEW public."SU_NAM_Subject_Name" AS
SELECT
    a."Metadata_SU_NAM",
    p."SU_NAM_ID",
    p."SU_NAM_SU_ID",
    p."SU_NAM_Subject_Name",
    a."SU_NAM_PositedAt",
    a."SU_NAM_Reliability"
FROM
    public."SU_NAM_Subject_Name_Posit" p
JOIN
    public."SU_NAM_Subject_Name_Annex" a
ON
    a."SU_NAM_ID" = p."SU_NAM_ID"
;
CREATE OR REPLACE VIEW public."SU_COD_Subject_Code" AS
SELECT
    a."Metadata_SU_COD",
    p."SU_COD_ID",
    p."SU_COD_SU_ID",
    p."SU_COD_Subject_Code",
    a."SU_COD_PositedAt",
    a."SU_COD_Reliability"
FROM
    public."SU_COD_Subject_Code_Posit" p
JOIN
    public."SU_COD_Subject_Code_Annex" a
ON
    a."SU_COD_ID" = p."SU_COD_ID"
;
CREATE OR REPLACE VIEW public."SU_GRD_Subject_Grade" AS
SELECT
    a."Metadata_SU_GRD",
    p."SU_GRD_ID",
    p."SU_GRD_SU_ID",
    p."SU_GRD_GRD_ID",
    a."SU_GRD_PositedAt",
    a."SU_GRD_Reliability"
FROM
    public."SU_GRD_Subject_Grade_Posit" p
JOIN
    public."SU_GRD_Subject_Grade_Annex" a
ON
    a."SU_GRD_ID" = p."SU_GRD_ID"
;
CREATE OR REPLACE VIEW public."SU_NOT_Subject_Note" AS
SELECT
    a."Metadata_SU_NOT",
    p."SU_NOT_ID",
    p."SU_NOT_SU_ID",
    p."SU_NOT_Checksum",
    p."SU_NOT_Subject_Note",
    a."SU_NOT_PositedAt",
    a."SU_NOT_Reliability"
FROM
    public."SU_NOT_Subject_Note_Posit" p
JOIN
    public."SU_NOT_Subject_Note_Annex" a
ON
    a."SU_NOT_ID" = p."SU_NOT_ID"
;
CREATE OR REPLACE VIEW public."SU_TTL_Subject_Title" AS
SELECT
    a."Metadata_SU_TTL",
    p."SU_TTL_ID",
    p."SU_TTL_SU_ID",
    p."SU_TTL_Subject_Title",
    p."SU_TTL_ChangedAt",
    a."SU_TTL_PositedAt",
    a."SU_TTL_Reliability"
FROM
    public."SU_TTL_Subject_Title_Posit" p
JOIN
    public."SU_TTL_Subject_Title_Annex" a
ON
    a."SU_TTL_ID" = p."SU_TTL_ID"
;
CREATE OR REPLACE VIEW public."SU_STA_Subject_State" AS
SELECT
    a."Metadata_SU_STA",
    p."SU_STA_ID",
    p."SU_STA_SU_ID",
    p."SU_STA_Subject_State",
    p."SU_STA_ChangedAt",
    a."SU_STA_PositedAt",
    a."SU_STA_Reliability"
FROM
    public."SU_STA_Subject_State_Posit" p
JOIN
    public."SU_STA_Subject_State_Annex" a
ON
    a."SU_STA_ID" = p."SU_STA_ID"
;
CREATE OR REPLACE VIEW public."SU_LBL_Subject_Label" AS
SELECT
    a."Metadata_SU_LBL",
    p."SU_LBL_ID",
    p."SU_LBL_SU_ID",
    p."SU_LBL_Subject_Label",
    p."SU_LBL_ChangedAt",
    a."SU_LBL_PositedAt",
    a."SU_LBL_Reliability"
FROM
    public."SU_LBL_Subject_Label_Posit" p
JOIN
    public."SU_LBL_Subject_Label_Annex" a
ON
    a."SU_LBL_ID" = p."SU_LBL_ID"
;
CREATE OR REPLACE VIEW public."SU_TAG_Subject_Tag" AS
SELECT
    a."Metadata_SU_TAG",
    p."SU_TAG_ID",
    p."SU_TAG_SU_ID",
    p."SU_TAG_Subject_Tag",
    p."SU_TAG_ChangedAt",
    a."SU_TAG_PositedAt",
    a."SU_TAG_Reliability"
FROM
    public."SU_TAG_Subject_Tag_Posit" p
JOIN
    public."SU_TAG_Subject_Tag_Annex" a
ON
    a."SU_TAG_ID" = p."SU_TAG_ID"
;
CREATE OR REPLACE VIEW public."SU_LVL_Subject_Level" AS
SELECT
    a."Metadata_SU_LVL",
    p."SU_LVL_ID",
    p."SU_LVL_SU_ID",
    p."SU_LVL_GRD_ID",
    p."SU_LVL_ChangedAt",
    a."SU_LVL_PositedAt",
    a."SU_LVL_Reliability"
FROM
    public."SU_LVL_Subject_Level_Posit" p
JOIN
    public."SU_LVL_Subject_Level_Annex" a
ON
    a."SU_LVL_ID" = p."SU_LVL_ID"
;
CREATE OR REPLACE VIEW public."SU_TXT_Subject_Text" AS
SELECT
    a."Metadata_SU_TXT",
    p."SU_TXT_ID",
    p."SU_TXT_SU_ID",
    p."SU_TXT_Checksum",
    p."SU_TXT_Subject_Text",
    p."SU_TXT_ChangedAt",
    a."SU_TXT_PositedAt",
    a."SU_TXT_Reliability"
FROM
    public."SU_TXT_Subject_Text_Posit" p
JOIN
    public."SU_TXT_Subject_Text_Annex" a
ON
    a."SU_TXT_ID" = p."SU_TXT_ID"
;
CREATE OR REPLACE VIEW public."SU_ASR_Subject_Assessment" AS
SELECT
    a."Metadata_SU_ASR",
    p."SU_ASR_ID",
    p."SU_ASR_SU_ID",
    p."SU_ASR_Subject_Assessment",
    p."SU_ASR_ChangedAt",
    a."SU_ASR_PositedAt",
    a."SU_ASR_Reliability"
FROM
    public."SU_ASR_Subject_Assessment_Posit" p
JOIN
    public."SU_ASR_Subject_Assessment_Annex" a
ON
    a."SU_ASR_ID" = p."SU_ASR_ID"
;
CREATE OR REPLACE VIEW public."SU_ERS_Subject_Erasable" AS
SELECT
    a."Metadata_SU_ERS",
    p."SU_ERS_ID",
    p."SU_ERS_SU_ID",
    p."SU_ERS_Subject_Erasable",
    p."SU_ERS_ChangedAt",
    a."SU_ERS_PositedAt",
    a."SU_ERS_Reliability"
FROM
    public."SU_ERS_Subject_Erasable_Posit" p
JOIN
    public."SU_ERS_Subject_Erasable_Annex" a
ON
    a."SU_ERS_ID" = p."SU_ERS_ID"
;
CREATE OR REPLACE VIEW public."OB_NAM_Object_Name" AS
SELECT
    a."Metadata_OB_NAM",
    p."OB_NAM_ID",
    p."OB_NAM_OB_ID",
    p."OB_NAM_Object_Name",
    a."OB_NAM_PositedAt",
    a."OB_NAM_Reliability"
FROM
    public."OB_NAM_Object_Name_Posit" p
JOIN
    public."OB_NAM_Object_Name_Annex" a
ON
    a."OB_NAM_ID" = p."OB_NAM_ID"
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION public."rEV_QTY_Event_Quantity_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_QTY",
    "EV_QTY_ID",
    "EV_QTY_PositedAt",
    "EV_QTY_Reliability"
FROM
    public."EV_QTY_Event_Quantity_Annex"
WHERE
    "EV_QTY_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_QTY_Event_Quantity" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_EV_ID" integer,
    "EV_QTY_Event_Quantity" integer
)
AS
$$
SELECT DISTINCT ON (p."EV_QTY_ID")
    a."Metadata_EV_QTY",
    p."EV_QTY_ID",
    a."EV_QTY_PositedAt",
    a."EV_QTY_Reliability",
    p."EV_QTY_EV_ID",
    p."EV_QTY_Event_Quantity"
FROM
    public."EV_QTY_Event_Quantity_Posit" p
JOIN
    public."rEV_QTY_Event_Quantity_Annex"(positingTimepoint) a
ON
    a."EV_QTY_ID" = p."EV_QTY_ID"
ORDER BY
    p."EV_QTY_ID",
    a."EV_QTY_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_PLC_ID" integer,
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_PLC_ID",
    "EV_PLC_EV_ID",
    "EV_PLC_Event_Place",
    "EV_PLC_ChangedAt"
FROM
    public."EV_PLC_Event_Place_Posit"
WHERE
    "EV_PLC_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fEV_PLC_Event_Place_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_PLC_ID" integer,
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_PLC_ID",
    "EV_PLC_EV_ID",
    "EV_PLC_Event_Place",
    "EV_PLC_ChangedAt"
FROM
    public."EV_PLC_Event_Place_Posit"
WHERE
    "EV_PLC_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_PLC",
    "EV_PLC_ID",
    "EV_PLC_PositedAt",
    "EV_PLC_Reliability"
FROM
    public."EV_PLC_Event_Place_Annex"
WHERE
    "EV_PLC_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rEV_PLC_Event_Place" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_PLC_ID")
    a."Metadata_EV_PLC",
    p."EV_PLC_ID",
    a."EV_PLC_PositedAt",
    a."EV_PLC_Reliability",
    p."EV_PLC_EV_ID",
    p."EV_PLC_Event_Place",
    p."EV_PLC_ChangedAt"
FROM
    public."rEV_PLC_Event_Place_Posit"(changingTimepoint) p
JOIN
    public."rEV_PLC_Event_Place_Annex"(positingTimepoint) a
ON
    a."EV_PLC_ID" = p."EV_PLC_ID"
ORDER BY
    p."EV_PLC_ID",
    a."EV_PLC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fEV_PLC_Event_Place" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_EV_ID" integer,
    "EV_PLC_Event_Place" varchar(42),
    "EV_PLC_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_PLC_ID")
    a."Metadata_EV_PLC",
    p."EV_PLC_ID",
    a."EV_PLC_PositedAt",
    a."EV_PLC_Reliability",
    p."EV_PLC_EV_ID",
    p."EV_PLC_Event_Place",
    p."EV_PLC_ChangedAt"
FROM
    public."fEV_PLC_Event_Place_Posit"(changingTimepoint) p
JOIN
    public."rEV_PLC_Event_Place_Annex"(positingTimepoint) a
ON
    a."EV_PLC_ID" = p."EV_PLC_ID"
ORDER BY
    p."EV_PLC_ID",
    a."EV_PLC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preEV_PLC_Event_Place" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."EV_PLC_Event_Place"
FROM
    public."rEV_PLC_Event_Place"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_PLC_EV_ID" = id
AND
    pre."EV_PLC_ChangedAt" < changingTimepoint
AND
    pre."EV_PLC_Reliability" = 1
ORDER BY
    pre."EV_PLC_ChangedAt" DESC,
    pre."EV_PLC_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folEV_PLC_Event_Place" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."EV_PLC_Event_Place"
FROM
    public."fEV_PLC_Event_Place"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_PLC_EV_ID" = id
AND
    fol."EV_PLC_ChangedAt" > changingTimepoint
AND
    fol."EV_PLC_Reliability" = 1
ORDER BY
    fol."EV_PLC_ChangedAt" ASC,
    fol."EV_PLC_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_NAM_Subject_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_NAM",
    "SU_NAM_ID",
    "SU_NAM_PositedAt",
    "SU_NAM_Reliability"
FROM
    public."SU_NAM_Subject_Name_Annex"
WHERE
    "SU_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_NAM_Subject_Name" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_SU_ID" integer,
    "SU_NAM_Subject_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."SU_NAM_ID")
    a."Metadata_SU_NAM",
    p."SU_NAM_ID",
    a."SU_NAM_PositedAt",
    a."SU_NAM_Reliability",
    p."SU_NAM_SU_ID",
    p."SU_NAM_Subject_Name"
FROM
    public."SU_NAM_Subject_Name_Posit" p
JOIN
    public."rSU_NAM_Subject_Name_Annex"(positingTimepoint) a
ON
    a."SU_NAM_ID" = p."SU_NAM_ID"
ORDER BY
    p."SU_NAM_ID",
    a."SU_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_COD_Subject_Code_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_COD",
    "SU_COD_ID",
    "SU_COD_PositedAt",
    "SU_COD_Reliability"
FROM
    public."SU_COD_Subject_Code_Annex"
WHERE
    "SU_COD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_COD_Subject_Code" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_SU_ID" integer,
    "SU_COD_Subject_Code" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."SU_COD_ID")
    a."Metadata_SU_COD",
    p."SU_COD_ID",
    a."SU_COD_PositedAt",
    a."SU_COD_Reliability",
    p."SU_COD_SU_ID",
    p."SU_COD_Subject_Code"
FROM
    public."SU_COD_Subject_Code_Posit" p
JOIN
    public."rSU_COD_Subject_Code_Annex"(positingTimepoint) a
ON
    a."SU_COD_ID" = p."SU_COD_ID"
ORDER BY
    p."SU_COD_ID",
    a."SU_COD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_GRD_Subject_Grade_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_GRD",
    "SU_GRD_ID",
    "SU_GRD_PositedAt",
    "SU_GRD_Reliability"
FROM
    public."SU_GRD_Subject_Grade_Annex"
WHERE
    "SU_GRD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_GRD_Subject_Grade" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_SU_ID" integer,
    "SU_GRD_GRD_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."SU_GRD_ID")
    a."Metadata_SU_GRD",
    p."SU_GRD_ID",
    a."SU_GRD_PositedAt",
    a."SU_GRD_Reliability",
    p."SU_GRD_SU_ID",
    p."SU_GRD_GRD_ID"
FROM
    public."SU_GRD_Subject_Grade_Posit" p
JOIN
    public."rSU_GRD_Subject_Grade_Annex"(positingTimepoint) a
ON
    a."SU_GRD_ID" = p."SU_GRD_ID"
ORDER BY
    p."SU_GRD_ID",
    a."SU_GRD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_NOT_Subject_Note_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_NOT",
    "SU_NOT_ID",
    "SU_NOT_PositedAt",
    "SU_NOT_Reliability"
FROM
    public."SU_NOT_Subject_Note_Annex"
WHERE
    "SU_NOT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_NOT_Subject_Note" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_SU_ID" integer,
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text
)
AS
$$
SELECT DISTINCT ON (p."SU_NOT_ID")
    a."Metadata_SU_NOT",
    p."SU_NOT_ID",
    a."SU_NOT_PositedAt",
    a."SU_NOT_Reliability",
    p."SU_NOT_SU_ID",
    p."SU_NOT_Checksum",
    p."SU_NOT_Subject_Note"
FROM
    public."SU_NOT_Subject_Note_Posit" p
JOIN
    public."rSU_NOT_Subject_Note_Annex"(positingTimepoint) a
ON
    a."SU_NOT_ID" = p."SU_NOT_ID"
ORDER BY
    p."SU_NOT_ID",
    a."SU_NOT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TTL_ID" integer,
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TTL_ID",
    "SU_TTL_SU_ID",
    "SU_TTL_Subject_Title",
    "SU_TTL_ChangedAt"
FROM
    public."SU_TTL_Subject_Title_Posit"
WHERE
    "SU_TTL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_TTL_Subject_Title_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TTL_ID" integer,
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TTL_ID",
    "SU_TTL_SU_ID",
    "SU_TTL_Subject_Title",
    "SU_TTL_ChangedAt"
FROM
    public."SU_TTL_Subject_Title_Posit"
WHERE
    "SU_TTL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_TTL",
    "SU_TTL_ID",
    "SU_TTL_PositedAt",
    "SU_TTL_Reliability"
FROM
    public."SU_TTL_Subject_Title_Annex"
WHERE
    "SU_TTL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TTL_Subject_Title" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TTL_ID")
    a."Metadata_SU_TTL",
    p."SU_TTL_ID",
    a."SU_TTL_PositedAt",
    a."SU_TTL_Reliability",
    p."SU_TTL_SU_ID",
    p."SU_TTL_Subject_Title",
    p."SU_TTL_ChangedAt"
FROM
    public."rSU_TTL_Subject_Title_Posit"(changingTimepoint) p
JOIN
    public."rSU_TTL_Subject_Title_Annex"(positingTimepoint) a
ON
    a."SU_TTL_ID" = p."SU_TTL_ID"
ORDER BY
    p."SU_TTL_ID",
    a."SU_TTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_TTL_Subject_Title" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_SU_ID" integer,
    "SU_TTL_Subject_Title" varchar(42),
    "SU_TTL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TTL_ID")
    a."Metadata_SU_TTL",
    p."SU_TTL_ID",
    a."SU_TTL_PositedAt",
    a."SU_TTL_Reliability",
    p."SU_TTL_SU_ID",
    p."SU_TTL_Subject_Title",
    p."SU_TTL_ChangedAt"
FROM
    public."fSU_TTL_Subject_Title_Posit"(changingTimepoint) p
JOIN
    public."rSU_TTL_Subject_Title_Annex"(positingTimepoint) a
ON
    a."SU_TTL_ID" = p."SU_TTL_ID"
ORDER BY
    p."SU_TTL_ID",
    a."SU_TTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_TTL_Subject_Title" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_TTL_Subject_Title"
FROM
    public."rSU_TTL_Subject_Title"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_TTL_SU_ID" = id
AND
    pre."SU_TTL_ChangedAt" < changingTimepoint
AND
    pre."SU_TTL_Reliability" = 1
ORDER BY
    pre."SU_TTL_ChangedAt" DESC,
    pre."SU_TTL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_TTL_Subject_Title" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_TTL_Subject_Title"
FROM
    public."fSU_TTL_Subject_Title"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_TTL_SU_ID" = id
AND
    fol."SU_TTL_ChangedAt" > changingTimepoint
AND
    fol."SU_TTL_Reliability" = 1
ORDER BY
    fol."SU_TTL_ChangedAt" ASC,
    fol."SU_TTL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_STA_ID" integer,
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_STA_ID",
    "SU_STA_SU_ID",
    "SU_STA_Subject_State",
    "SU_STA_ChangedAt"
FROM
    public."SU_STA_Subject_State_Posit"
WHERE
    "SU_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_STA_Subject_State_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_STA_ID" integer,
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_STA_ID",
    "SU_STA_SU_ID",
    "SU_STA_Subject_State",
    "SU_STA_ChangedAt"
FROM
    public."SU_STA_Subject_State_Posit"
WHERE
    "SU_STA_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_STA",
    "SU_STA_ID",
    "SU_STA_PositedAt",
    "SU_STA_Reliability"
FROM
    public."SU_STA_Subject_State_Annex"
WHERE
    "SU_STA_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_STA_Subject_State" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_STA_ID")
    a."Metadata_SU_STA",
    p."SU_STA_ID",
    a."SU_STA_PositedAt",
    a."SU_STA_Reliability",
    p."SU_STA_SU_ID",
    p."SU_STA_Subject_State",
    p."SU_STA_ChangedAt"
FROM
    public."rSU_STA_Subject_State_Posit"(changingTimepoint) p
JOIN
    public."rSU_STA_Subject_State_Annex"(positingTimepoint) a
ON
    a."SU_STA_ID" = p."SU_STA_ID"
ORDER BY
    p."SU_STA_ID",
    a."SU_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_STA_Subject_State" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_SU_ID" integer,
    "SU_STA_Subject_State" varchar(42),
    "SU_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_STA_ID")
    a."Metadata_SU_STA",
    p."SU_STA_ID",
    a."SU_STA_PositedAt",
    a."SU_STA_Reliability",
    p."SU_STA_SU_ID",
    p."SU_STA_Subject_State",
    p."SU_STA_ChangedAt"
FROM
    public."fSU_STA_Subject_State_Posit"(changingTimepoint) p
JOIN
    public."rSU_STA_Subject_State_Annex"(positingTimepoint) a
ON
    a."SU_STA_ID" = p."SU_STA_ID"
ORDER BY
    p."SU_STA_ID",
    a."SU_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_STA_Subject_State" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_STA_Subject_State"
FROM
    public."rSU_STA_Subject_State"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_STA_SU_ID" = id
AND
    pre."SU_STA_ChangedAt" < changingTimepoint
AND
    pre."SU_STA_Reliability" = 1
ORDER BY
    pre."SU_STA_ChangedAt" DESC,
    pre."SU_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_STA_Subject_State" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_STA_Subject_State"
FROM
    public."fSU_STA_Subject_State"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_STA_SU_ID" = id
AND
    fol."SU_STA_ChangedAt" > changingTimepoint
AND
    fol."SU_STA_Reliability" = 1
ORDER BY
    fol."SU_STA_ChangedAt" ASC,
    fol."SU_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LBL_ID" integer,
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LBL_ID",
    "SU_LBL_SU_ID",
    "SU_LBL_Subject_Label",
    "SU_LBL_ChangedAt"
FROM
    public."SU_LBL_Subject_Label_Posit"
WHERE
    "SU_LBL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_LBL_Subject_Label_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LBL_ID" integer,
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LBL_ID",
    "SU_LBL_SU_ID",
    "SU_LBL_Subject_Label",
    "SU_LBL_ChangedAt"
FROM
    public."SU_LBL_Subject_Label_Posit"
WHERE
    "SU_LBL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_LBL",
    "SU_LBL_ID",
    "SU_LBL_PositedAt",
    "SU_LBL_Reliability"
FROM
    public."SU_LBL_Subject_Label_Annex"
WHERE
    "SU_LBL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_LBL_Subject_Label" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LBL_ID")
    a."Metadata_SU_LBL",
    p."SU_LBL_ID",
    a."SU_LBL_PositedAt",
    a."SU_LBL_Reliability",
    p."SU_LBL_SU_ID",
    p."SU_LBL_Subject_Label",
    p."SU_LBL_ChangedAt"
FROM
    public."rSU_LBL_Subject_Label_Posit"(changingTimepoint) p
JOIN
    public."rSU_LBL_Subject_Label_Annex"(positingTimepoint) a
ON
    a."SU_LBL_ID" = p."SU_LBL_ID"
ORDER BY
    p."SU_LBL_ID",
    a."SU_LBL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_LBL_Subject_Label" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_SU_ID" integer,
    "SU_LBL_Subject_Label" varchar(42),
    "SU_LBL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LBL_ID")
    a."Metadata_SU_LBL",
    p."SU_LBL_ID",
    a."SU_LBL_PositedAt",
    a."SU_LBL_Reliability",
    p."SU_LBL_SU_ID",
    p."SU_LBL_Subject_Label",
    p."SU_LBL_ChangedAt"
FROM
    public."fSU_LBL_Subject_Label_Posit"(changingTimepoint) p
JOIN
    public."rSU_LBL_Subject_Label_Annex"(positingTimepoint) a
ON
    a."SU_LBL_ID" = p."SU_LBL_ID"
ORDER BY
    p."SU_LBL_ID",
    a."SU_LBL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_LBL_Subject_Label" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_LBL_Subject_Label"
FROM
    public."rSU_LBL_Subject_Label"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_LBL_SU_ID" = id
AND
    pre."SU_LBL_ChangedAt" < changingTimepoint
AND
    pre."SU_LBL_Reliability" = 1
ORDER BY
    pre."SU_LBL_ChangedAt" DESC,
    pre."SU_LBL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_LBL_Subject_Label" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_LBL_Subject_Label"
FROM
    public."fSU_LBL_Subject_Label"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_LBL_SU_ID" = id
AND
    fol."SU_LBL_ChangedAt" > changingTimepoint
AND
    fol."SU_LBL_Reliability" = 1
ORDER BY
    fol."SU_LBL_ChangedAt" ASC,
    fol."SU_LBL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TAG_ID" integer,
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TAG_ID",
    "SU_TAG_SU_ID",
    "SU_TAG_Subject_Tag",
    "SU_TAG_ChangedAt"
FROM
    public."SU_TAG_Subject_Tag_Posit"
WHERE
    "SU_TAG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_TAG_Subject_Tag_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TAG_ID" integer,
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TAG_ID",
    "SU_TAG_SU_ID",
    "SU_TAG_Subject_Tag",
    "SU_TAG_ChangedAt"
FROM
    public."SU_TAG_Subject_Tag_Posit"
WHERE
    "SU_TAG_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_TAG",
    "SU_TAG_ID",
    "SU_TAG_PositedAt",
    "SU_TAG_Reliability"
FROM
    public."SU_TAG_Subject_Tag_Annex"
WHERE
    "SU_TAG_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TAG_Subject_Tag" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TAG_ID")
    a."Metadata_SU_TAG",
    p."SU_TAG_ID",
    a."SU_TAG_PositedAt",
    a."SU_TAG_Reliability",
    p."SU_TAG_SU_ID",
    p."SU_TAG_Subject_Tag",
    p."SU_TAG_ChangedAt"
FROM
    public."rSU_TAG_Subject_Tag_Posit"(changingTimepoint) p
JOIN
    public."rSU_TAG_Subject_Tag_Annex"(positingTimepoint) a
ON
    a."SU_TAG_ID" = p."SU_TAG_ID"
ORDER BY
    p."SU_TAG_ID",
    a."SU_TAG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_TAG_Subject_Tag" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_SU_ID" integer,
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_TAG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TAG_ID")
    a."Metadata_SU_TAG",
    p."SU_TAG_ID",
    a."SU_TAG_PositedAt",
    a."SU_TAG_Reliability",
    p."SU_TAG_SU_ID",
    p."SU_TAG_Subject_Tag",
    p."SU_TAG_ChangedAt"
FROM
    public."fSU_TAG_Subject_Tag_Posit"(changingTimepoint) p
JOIN
    public."rSU_TAG_Subject_Tag_Annex"(positingTimepoint) a
ON
    a."SU_TAG_ID" = p."SU_TAG_ID"
ORDER BY
    p."SU_TAG_ID",
    a."SU_TAG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_TAG_Subject_Tag" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_TAG_Subject_Tag"
FROM
    public."rSU_TAG_Subject_Tag"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_TAG_SU_ID" = id
AND
    pre."SU_TAG_ChangedAt" < changingTimepoint
AND
    pre."SU_TAG_Reliability" = 1
ORDER BY
    pre."SU_TAG_ChangedAt" DESC,
    pre."SU_TAG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_TAG_Subject_Tag" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_TAG_Subject_Tag"
FROM
    public."fSU_TAG_Subject_Tag"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_TAG_SU_ID" = id
AND
    fol."SU_TAG_ChangedAt" > changingTimepoint
AND
    fol."SU_TAG_Reliability" = 1
ORDER BY
    fol."SU_TAG_ChangedAt" ASC,
    fol."SU_TAG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LVL_ID" integer,
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LVL_ID",
    "SU_LVL_SU_ID",
    "SU_LVL_GRD_ID",
    "SU_LVL_ChangedAt"
FROM
    public."SU_LVL_Subject_Level_Posit"
WHERE
    "SU_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_LVL_Subject_Level_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_LVL_ID" integer,
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_LVL_ID",
    "SU_LVL_SU_ID",
    "SU_LVL_GRD_ID",
    "SU_LVL_ChangedAt"
FROM
    public."SU_LVL_Subject_Level_Posit"
WHERE
    "SU_LVL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_LVL",
    "SU_LVL_ID",
    "SU_LVL_PositedAt",
    "SU_LVL_Reliability"
FROM
    public."SU_LVL_Subject_Level_Annex"
WHERE
    "SU_LVL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_LVL_Subject_Level" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LVL_ID")
    a."Metadata_SU_LVL",
    p."SU_LVL_ID",
    a."SU_LVL_PositedAt",
    a."SU_LVL_Reliability",
    p."SU_LVL_SU_ID",
    p."SU_LVL_GRD_ID",
    p."SU_LVL_ChangedAt"
FROM
    public."rSU_LVL_Subject_Level_Posit"(changingTimepoint) p
JOIN
    public."rSU_LVL_Subject_Level_Annex"(positingTimepoint) a
ON
    a."SU_LVL_ID" = p."SU_LVL_ID"
ORDER BY
    p."SU_LVL_ID",
    a."SU_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_LVL_Subject_Level" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_SU_ID" integer,
    "SU_LVL_GRD_ID" smallint, 
    "SU_LVL_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_LVL_ID")
    a."Metadata_SU_LVL",
    p."SU_LVL_ID",
    a."SU_LVL_PositedAt",
    a."SU_LVL_Reliability",
    p."SU_LVL_SU_ID",
    p."SU_LVL_GRD_ID",
    p."SU_LVL_ChangedAt"
FROM
    public."fSU_LVL_Subject_Level_Posit"(changingTimepoint) p
JOIN
    public."rSU_LVL_Subject_Level_Annex"(positingTimepoint) a
ON
    a."SU_LVL_ID" = p."SU_LVL_ID"
ORDER BY
    p."SU_LVL_ID",
    a."SU_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_LVL_Subject_Level" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    pre."SU_LVL_GRD_ID"
FROM
    public."rSU_LVL_Subject_Level"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_LVL_SU_ID" = id
AND
    pre."SU_LVL_ChangedAt" < changingTimepoint
AND
    pre."SU_LVL_Reliability" = 1
ORDER BY
    pre."SU_LVL_ChangedAt" DESC,
    pre."SU_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_LVL_Subject_Level" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    fol."SU_LVL_GRD_ID"
FROM
    public."fSU_LVL_Subject_Level"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_LVL_SU_ID" = id
AND
    fol."SU_LVL_ChangedAt" > changingTimepoint
AND
    fol."SU_LVL_Reliability" = 1
ORDER BY
    fol."SU_LVL_ChangedAt" ASC,
    fol."SU_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TXT_ID" integer,
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TXT_ID",
    "SU_TXT_SU_ID",
    "SU_TXT_Checksum",
    "SU_TXT_Subject_Text",
    "SU_TXT_ChangedAt"
FROM
    public."SU_TXT_Subject_Text_Posit"
WHERE
    "SU_TXT_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_TXT_Subject_Text_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_TXT_ID" integer,
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_TXT_ID",
    "SU_TXT_SU_ID",
    "SU_TXT_Checksum",
    "SU_TXT_Subject_Text",
    "SU_TXT_ChangedAt"
FROM
    public."SU_TXT_Subject_Text_Posit"
WHERE
    "SU_TXT_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_TXT",
    "SU_TXT_ID",
    "SU_TXT_PositedAt",
    "SU_TXT_Reliability"
FROM
    public."SU_TXT_Subject_Text_Annex"
WHERE
    "SU_TXT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_TXT_Subject_Text" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TXT_ID")
    a."Metadata_SU_TXT",
    p."SU_TXT_ID",
    a."SU_TXT_PositedAt",
    a."SU_TXT_Reliability",
    p."SU_TXT_SU_ID",
    p."SU_TXT_Checksum",
    p."SU_TXT_Subject_Text",
    p."SU_TXT_ChangedAt"
FROM
    public."rSU_TXT_Subject_Text_Posit"(changingTimepoint) p
JOIN
    public."rSU_TXT_Subject_Text_Annex"(positingTimepoint) a
ON
    a."SU_TXT_ID" = p."SU_TXT_ID"
ORDER BY
    p."SU_TXT_ID",
    a."SU_TXT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_TXT_Subject_Text" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_SU_ID" integer,
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_TXT_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_TXT_ID")
    a."Metadata_SU_TXT",
    p."SU_TXT_ID",
    a."SU_TXT_PositedAt",
    a."SU_TXT_Reliability",
    p."SU_TXT_SU_ID",
    p."SU_TXT_Checksum",
    p."SU_TXT_Subject_Text",
    p."SU_TXT_ChangedAt"
FROM
    public."fSU_TXT_Subject_Text_Posit"(changingTimepoint) p
JOIN
    public."rSU_TXT_Subject_Text_Annex"(positingTimepoint) a
ON
    a."SU_TXT_ID" = p."SU_TXT_ID"
ORDER BY
    p."SU_TXT_ID",
    a."SU_TXT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_TXT_Subject_Text" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS bytea
AS
$$
SELECT
    pre."SU_TXT_Checksum" 
FROM
    public."rSU_TXT_Subject_Text"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_TXT_SU_ID" = id
AND
    pre."SU_TXT_ChangedAt" < changingTimepoint
AND
    pre."SU_TXT_Reliability" = 1
ORDER BY
    pre."SU_TXT_ChangedAt" DESC,
    pre."SU_TXT_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_TXT_Subject_Text" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS bytea
AS
$$
SELECT
    fol."SU_TXT_Checksum" 
FROM
    public."fSU_TXT_Subject_Text"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_TXT_SU_ID" = id
AND
    fol."SU_TXT_ChangedAt" > changingTimepoint
AND
    fol."SU_TXT_Reliability" = 1
ORDER BY
    fol."SU_TXT_ChangedAt" ASC,
    fol."SU_TXT_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ASR_ID" integer,
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ASR_ID",
    "SU_ASR_SU_ID",
    "SU_ASR_Subject_Assessment",
    "SU_ASR_ChangedAt"
FROM
    public."SU_ASR_Subject_Assessment_Posit"
WHERE
    "SU_ASR_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_ASR_Subject_Assessment_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ASR_ID" integer,
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ASR_ID",
    "SU_ASR_SU_ID",
    "SU_ASR_Subject_Assessment",
    "SU_ASR_ChangedAt"
FROM
    public."SU_ASR_Subject_Assessment_Posit"
WHERE
    "SU_ASR_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_ASR",
    "SU_ASR_ID",
    "SU_ASR_PositedAt",
    "SU_ASR_Reliability"
FROM
    public."SU_ASR_Subject_Assessment_Annex"
WHERE
    "SU_ASR_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_ASR_Subject_Assessment" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ASR_ID")
    a."Metadata_SU_ASR",
    p."SU_ASR_ID",
    a."SU_ASR_PositedAt",
    a."SU_ASR_Reliability",
    p."SU_ASR_SU_ID",
    p."SU_ASR_Subject_Assessment",
    p."SU_ASR_ChangedAt"
FROM
    public."rSU_ASR_Subject_Assessment_Posit"(changingTimepoint) p
JOIN
    public."rSU_ASR_Subject_Assessment_Annex"(positingTimepoint) a
ON
    a."SU_ASR_ID" = p."SU_ASR_ID"
ORDER BY
    p."SU_ASR_ID",
    a."SU_ASR_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_ASR_Subject_Assessment" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_SU_ID" integer,
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ASR_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ASR_ID")
    a."Metadata_SU_ASR",
    p."SU_ASR_ID",
    a."SU_ASR_PositedAt",
    a."SU_ASR_Reliability",
    p."SU_ASR_SU_ID",
    p."SU_ASR_Subject_Assessment",
    p."SU_ASR_ChangedAt"
FROM
    public."fSU_ASR_Subject_Assessment_Posit"(changingTimepoint) p
JOIN
    public."rSU_ASR_Subject_Assessment_Annex"(positingTimepoint) a
ON
    a."SU_ASR_ID" = p."SU_ASR_ID"
ORDER BY
    p."SU_ASR_ID",
    a."SU_ASR_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_ASR_Subject_Assessment" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_ASR_Subject_Assessment"
FROM
    public."rSU_ASR_Subject_Assessment"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_ASR_SU_ID" = id
AND
    pre."SU_ASR_ChangedAt" < changingTimepoint
AND
    pre."SU_ASR_Reliability" = 1
ORDER BY
    pre."SU_ASR_ChangedAt" DESC,
    pre."SU_ASR_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_ASR_Subject_Assessment" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_ASR_Subject_Assessment"
FROM
    public."fSU_ASR_Subject_Assessment"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_ASR_SU_ID" = id
AND
    fol."SU_ASR_ChangedAt" > changingTimepoint
AND
    fol."SU_ASR_Reliability" = 1
ORDER BY
    fol."SU_ASR_ChangedAt" ASC,
    fol."SU_ASR_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ERS_ID" integer,
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ERS_ID",
    "SU_ERS_SU_ID",
    "SU_ERS_Subject_Erasable",
    "SU_ERS_ChangedAt"
FROM
    public."SU_ERS_Subject_Erasable_Posit"
WHERE
    "SU_ERS_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_ERS_Subject_Erasable_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ERS_ID" integer,
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_ERS_ID",
    "SU_ERS_SU_ID",
    "SU_ERS_Subject_Erasable",
    "SU_ERS_ChangedAt"
FROM
    public."SU_ERS_Subject_Erasable_Posit"
WHERE
    "SU_ERS_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_ERS",
    "SU_ERS_ID",
    "SU_ERS_PositedAt",
    "SU_ERS_Reliability"
FROM
    public."SU_ERS_Subject_Erasable_Annex"
WHERE
    "SU_ERS_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_ERS_Subject_Erasable" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ERS_ID")
    a."Metadata_SU_ERS",
    p."SU_ERS_ID",
    a."SU_ERS_PositedAt",
    a."SU_ERS_Reliability",
    p."SU_ERS_SU_ID",
    p."SU_ERS_Subject_Erasable",
    p."SU_ERS_ChangedAt"
FROM
    public."rSU_ERS_Subject_Erasable_Posit"(changingTimepoint) p
JOIN
    public."rSU_ERS_Subject_Erasable_Annex"(positingTimepoint) a
ON
    a."SU_ERS_ID" = p."SU_ERS_ID"
ORDER BY
    p."SU_ERS_ID",
    a."SU_ERS_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_ERS_Subject_Erasable" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_SU_ID" integer,
    "SU_ERS_Subject_Erasable" varchar(42),
    "SU_ERS_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."SU_ERS_ID")
    a."Metadata_SU_ERS",
    p."SU_ERS_ID",
    a."SU_ERS_PositedAt",
    a."SU_ERS_Reliability",
    p."SU_ERS_SU_ID",
    p."SU_ERS_Subject_Erasable",
    p."SU_ERS_ChangedAt"
FROM
    public."fSU_ERS_Subject_Erasable_Posit"(changingTimepoint) p
JOIN
    public."rSU_ERS_Subject_Erasable_Annex"(positingTimepoint) a
ON
    a."SU_ERS_ID" = p."SU_ERS_ID"
ORDER BY
    p."SU_ERS_ID",
    a."SU_ERS_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."preSU_ERS_Subject_Erasable" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."SU_ERS_Subject_Erasable"
FROM
    public."rSU_ERS_Subject_Erasable"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."SU_ERS_SU_ID" = id
AND
    pre."SU_ERS_ChangedAt" < changingTimepoint
AND
    pre."SU_ERS_Reliability" = 1
ORDER BY
    pre."SU_ERS_ChangedAt" DESC,
    pre."SU_ERS_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."folSU_ERS_Subject_Erasable" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."SU_ERS_Subject_Erasable"
FROM
    public."fSU_ERS_Subject_Erasable"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."SU_ERS_SU_ID" = id
AND
    fol."SU_ERS_ChangedAt" > changingTimepoint
AND
    fol."SU_ERS_Reliability" = 1
ORDER BY
    fol."SU_ERS_ChangedAt" ASC,
    fol."SU_ERS_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rOB_NAM_Object_Name_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_OB_NAM",
    "OB_NAM_ID",
    "OB_NAM_PositedAt",
    "OB_NAM_Reliability"
FROM
    public."OB_NAM_Object_Name_Annex"
WHERE
    "OB_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rOB_NAM_Object_Name" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Reliability" decimal(5,2),
    "OB_NAM_OB_ID" integer,
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."OB_NAM_ID")
    a."Metadata_OB_NAM",
    p."OB_NAM_ID",
    a."OB_NAM_PositedAt",
    a."OB_NAM_Reliability",
    p."OB_NAM_OB_ID",
    p."OB_NAM_Object_Name"
FROM
    public."OB_NAM_Object_Name_Posit" p
JOIN
    public."rOB_NAM_Object_Name_Annex"(positingTimepoint) a
ON
    a."OB_NAM_ID" = p."OB_NAM_ID"
ORDER BY
    p."OB_NAM_ID",
    a."OB_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tSU_Subject" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
SELECT
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_ID",
    "NAM"."SU_NAM_PositedAt",
    "NAM"."SU_NAM_Reliability",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_ID",
    "COD"."SU_COD_PositedAt",
    "COD"."SU_COD_Reliability",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "GRD"."SU_GRD_ID",
    "GRD"."SU_GRD_PositedAt",
    "GRD"."SU_GRD_Reliability",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_ID",
    "NOT"."SU_NOT_PositedAt",
    "NOT"."SU_NOT_Reliability",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ID",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_PositedAt",
    "TTL"."SU_TTL_Reliability",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ID",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_PositedAt",
    "STA"."SU_STA_Reliability",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ID",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_PositedAt",
    "LBL"."SU_LBL_Reliability",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ID",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_PositedAt",
    "TAG"."SU_TAG_Reliability",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ID",
    "LVL"."SU_LVL_ChangedAt",
    "LVL"."SU_LVL_PositedAt",
    "LVL"."SU_LVL_Reliability",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ID",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_PositedAt",
    "TXT"."SU_TXT_Reliability",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ID",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_PositedAt",
    "ASR"."SU_ASR_Reliability",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ID",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_PositedAt",
    "ERS"."SU_ERS_Reliability",
    "ERS"."SU_ERS_Subject_Erasable"
FROM
    public."SU_Subject" "SU"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_NAM_SU_ID")
        r.*
    FROM
        public."rSU_NAM_Subject_Name"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_NAM_Reliability" = 1
    ORDER BY
    r."SU_NAM_SU_ID",
    r."SU_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_COD_SU_ID")
        r.*
    FROM
        public."rSU_COD_Subject_Code"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_COD_Reliability" = 1
    ORDER BY
    r."SU_COD_SU_ID",
    r."SU_COD_PositedAt" DESC
) "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_GRD_SU_ID")
        r.*
    FROM
        public."rSU_GRD_Subject_Grade"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_GRD_Reliability" = 1
    ORDER BY
    r."SU_GRD_SU_ID",
    r."SU_GRD_PositedAt" DESC
) "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_NOT_SU_ID")
        r.*
    FROM
        public."rSU_NOT_Subject_Note"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_NOT_Reliability" = 1
    ORDER BY
    r."SU_NOT_SU_ID",
    r."SU_NOT_PositedAt" DESC
) "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_TTL_SU_ID")
        r.*
    FROM
        public."rSU_TTL_Subject_Title"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_TTL_Reliability" = 1
    ORDER BY
    r."SU_TTL_SU_ID",
    r."SU_TTL_ChangedAt" DESC,
    r."SU_TTL_PositedAt" DESC
) "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_STA_SU_ID")
        r.*
    FROM
        public."rSU_STA_Subject_State"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_STA_Reliability" = 1
    ORDER BY
    r."SU_STA_SU_ID",
    r."SU_STA_ChangedAt" DESC,
    r."SU_STA_PositedAt" DESC
) "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_LBL_SU_ID")
        r.*
    FROM
        public."rSU_LBL_Subject_Label"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_LBL_Reliability" = 1
    ORDER BY
    r."SU_LBL_SU_ID",
    r."SU_LBL_ChangedAt" DESC,
    r."SU_LBL_PositedAt" DESC
) "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_TAG_SU_ID")
        r.*
    FROM
        public."rSU_TAG_Subject_Tag"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_TAG_Reliability" = 1
    ORDER BY
    r."SU_TAG_SU_ID",
    r."SU_TAG_ChangedAt" DESC,
    r."SU_TAG_PositedAt" DESC
) "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_LVL_SU_ID")
        r.*
    FROM
        public."rSU_LVL_Subject_Level"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_LVL_Reliability" = 1
    ORDER BY
    r."SU_LVL_SU_ID",
    r."SU_LVL_ChangedAt" DESC,
    r."SU_LVL_PositedAt" DESC
) "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_TXT_SU_ID")
        r.*
    FROM
        public."rSU_TXT_Subject_Text"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_TXT_Reliability" = 1
    ORDER BY
    r."SU_TXT_SU_ID",
    r."SU_TXT_ChangedAt" DESC,
    r."SU_TXT_PositedAt" DESC
) "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_ASR_SU_ID")
        r.*
    FROM
        public."rSU_ASR_Subject_Assessment"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_ASR_Reliability" = 1
    ORDER BY
    r."SU_ASR_SU_ID",
    r."SU_ASR_ChangedAt" DESC,
    r."SU_ASR_PositedAt" DESC
) "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."SU_ERS_SU_ID")
        r.*
    FROM
        public."rSU_ERS_Subject_Erasable"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_ERS_Reliability" = 1
    ORDER BY
    r."SU_ERS_SU_ID",
    r."SU_ERS_ChangedAt" DESC,
    r."SU_ERS_PositedAt" DESC
) "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_Subject" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "SU".*
FROM
    public."tSU_Subject"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "SU"
;
CREATE OR REPLACE FUNCTION public."pSU_Subject" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "SU"."SU_NAM_SU_ID",
    "SU"."Metadata_SU_NAM",
    "SU"."SU_NAM_ID",
    "SU"."SU_NAM_PositedAt",
    "SU"."SU_NAM_Reliability",
    "SU"."SU_NAM_Subject_Name",
    "SU"."SU_COD_SU_ID",
    "SU"."Metadata_SU_COD",
    "SU"."SU_COD_ID",
    "SU"."SU_COD_PositedAt",
    "SU"."SU_COD_Reliability",
    "SU"."SU_COD_Subject_Code",
    "SU"."SU_GRD_SU_ID",
    "SU"."Metadata_SU_GRD",
    "SU"."SU_GRD_ID",
    "SU"."SU_GRD_PositedAt",
    "SU"."SU_GRD_Reliability",
    "SU"."SU_GRD_GRD_Grade",
    "SU"."SU_GRD_Metadata_GRD",
    "SU"."SU_GRD_GRD_ID",
    "SU"."SU_NOT_SU_ID",
    "SU"."Metadata_SU_NOT",
    "SU"."SU_NOT_ID",
    "SU"."SU_NOT_PositedAt",
    "SU"."SU_NOT_Reliability",
    "SU"."SU_NOT_Checksum",
    "SU"."SU_NOT_Subject_Note",
    "SU"."SU_TTL_SU_ID",
    "SU"."Metadata_SU_TTL",
    "SU"."SU_TTL_ID",
    "SU"."SU_TTL_ChangedAt",
    "SU"."SU_TTL_PositedAt",
    "SU"."SU_TTL_Reliability",
    "SU"."SU_TTL_Subject_Title",
    "SU"."SU_STA_SU_ID",
    "SU"."Metadata_SU_STA",
    "SU"."SU_STA_ID",
    "SU"."SU_STA_ChangedAt",
    "SU"."SU_STA_PositedAt",
    "SU"."SU_STA_Reliability",
    "SU"."SU_STA_Subject_State",
    "SU"."SU_LBL_SU_ID",
    "SU"."Metadata_SU_LBL",
    "SU"."SU_LBL_ID",
    "SU"."SU_LBL_ChangedAt",
    "SU"."SU_LBL_PositedAt",
    "SU"."SU_LBL_Reliability",
    "SU"."SU_LBL_Subject_Label",
    "SU"."SU_TAG_SU_ID",
    "SU"."Metadata_SU_TAG",
    "SU"."SU_TAG_ID",
    "SU"."SU_TAG_ChangedAt",
    "SU"."SU_TAG_PositedAt",
    "SU"."SU_TAG_Reliability",
    "SU"."SU_TAG_Subject_Tag",
    "SU"."SU_LVL_SU_ID",
    "SU"."Metadata_SU_LVL",
    "SU"."SU_LVL_ID",
    "SU"."SU_LVL_ChangedAt",
    "SU"."SU_LVL_PositedAt",
    "SU"."SU_LVL_Reliability",
    "SU"."SU_LVL_GRD_Grade",
    "SU"."SU_LVL_Metadata_GRD",
    "SU"."SU_LVL_GRD_ID",
    "SU"."SU_TXT_SU_ID",
    "SU"."Metadata_SU_TXT",
    "SU"."SU_TXT_ID",
    "SU"."SU_TXT_ChangedAt",
    "SU"."SU_TXT_PositedAt",
    "SU"."SU_TXT_Reliability",
    "SU"."SU_TXT_Checksum",
    "SU"."SU_TXT_Subject_Text",
    "SU"."SU_ASR_SU_ID",
    "SU"."Metadata_SU_ASR",
    "SU"."SU_ASR_ID",
    "SU"."SU_ASR_ChangedAt",
    "SU"."SU_ASR_PositedAt",
    "SU"."SU_ASR_Reliability",
    "SU"."SU_ASR_Subject_Assessment",
    "SU"."SU_ERS_SU_ID",
    "SU"."Metadata_SU_ERS",
    "SU"."SU_ERS_ID",
    "SU"."SU_ERS_ChangedAt",
    "SU"."SU_ERS_PositedAt",
    "SU"."SU_ERS_Reliability",
    "SU"."SU_ERS_Subject_Erasable"
FROM
    public."tSU_Subject"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "SU"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_Subject" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "SU".*
FROM
    public."tSU_Subject"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "SU"
;
CREATE OR REPLACE FUNCTION public."dSU_Subject" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "SU_ID" integer,
    "Metadata_SU" integer,
    "SU_NAM_SU_ID" integer,
    "Metadata_SU_NAM" integer,
    "SU_NAM_ID" integer,
    "SU_NAM_PositedAt" timestamp,
    "SU_NAM_Reliability" decimal(5,2),
    "SU_NAM_Subject_Name" varchar(42),
    "SU_COD_SU_ID" integer,
    "Metadata_SU_COD" integer,
    "SU_COD_ID" integer,
    "SU_COD_PositedAt" timestamp,
    "SU_COD_Reliability" decimal(5,2),
    "SU_COD_Subject_Code" varchar(42),
    "SU_GRD_SU_ID" integer,
    "Metadata_SU_GRD" integer,
    "SU_GRD_ID" integer,
    "SU_GRD_PositedAt" timestamp,
    "SU_GRD_Reliability" decimal(5,2),
    "SU_GRD_GRD_Grade" varchar(42),
    "SU_GRD_Metadata_GRD" integer,
    "SU_GRD_GRD_ID" smallint,
    "SU_NOT_SU_ID" integer,
    "Metadata_SU_NOT" integer,
    "SU_NOT_ID" integer,
    "SU_NOT_PositedAt" timestamp,
    "SU_NOT_Reliability" decimal(5,2),
    "SU_NOT_Checksum" bytea,
    "SU_NOT_Subject_Note" text,
    "SU_TTL_SU_ID" integer,
    "Metadata_SU_TTL" integer,
    "SU_TTL_ID" integer,
    "SU_TTL_ChangedAt" timestamp,
    "SU_TTL_PositedAt" timestamp,
    "SU_TTL_Reliability" decimal(5,2),
    "SU_TTL_Subject_Title" varchar(42),
    "SU_STA_SU_ID" integer,
    "Metadata_SU_STA" integer,
    "SU_STA_ID" integer,
    "SU_STA_ChangedAt" timestamp,
    "SU_STA_PositedAt" timestamp,
    "SU_STA_Reliability" decimal(5,2),
    "SU_STA_Subject_State" varchar(42),
    "SU_LBL_SU_ID" integer,
    "Metadata_SU_LBL" integer,
    "SU_LBL_ID" integer,
    "SU_LBL_ChangedAt" timestamp,
    "SU_LBL_PositedAt" timestamp,
    "SU_LBL_Reliability" decimal(5,2),
    "SU_LBL_Subject_Label" varchar(42),
    "SU_TAG_SU_ID" integer,
    "Metadata_SU_TAG" integer,
    "SU_TAG_ID" integer,
    "SU_TAG_ChangedAt" timestamp,
    "SU_TAG_PositedAt" timestamp,
    "SU_TAG_Reliability" decimal(5,2),
    "SU_TAG_Subject_Tag" varchar(42),
    "SU_LVL_SU_ID" integer,
    "Metadata_SU_LVL" integer,
    "SU_LVL_ID" integer,
    "SU_LVL_ChangedAt" timestamp,
    "SU_LVL_PositedAt" timestamp,
    "SU_LVL_Reliability" decimal(5,2),
    "SU_LVL_GRD_Grade" varchar(42),
    "SU_LVL_Metadata_GRD" integer,
    "SU_LVL_GRD_ID" smallint,
    "SU_TXT_SU_ID" integer,
    "Metadata_SU_TXT" integer,
    "SU_TXT_ID" integer,
    "SU_TXT_ChangedAt" timestamp,
    "SU_TXT_PositedAt" timestamp,
    "SU_TXT_Reliability" decimal(5,2),
    "SU_TXT_Checksum" bytea,
    "SU_TXT_Subject_Text" text,
    "SU_ASR_SU_ID" integer,
    "Metadata_SU_ASR" integer,
    "SU_ASR_ID" integer,
    "SU_ASR_ChangedAt" timestamp,
    "SU_ASR_PositedAt" timestamp,
    "SU_ASR_Reliability" decimal(5,2),
    "SU_ASR_Subject_Assessment" varchar(42),
    "SU_ERS_SU_ID" integer,
    "Metadata_SU_ERS" integer,
    "SU_ERS_ID" integer,
    "SU_ERS_ChangedAt" timestamp,
    "SU_ERS_PositedAt" timestamp,
    "SU_ERS_Reliability" decimal(5,2),
    "SU_ERS_Subject_Erasable" varchar(42)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "SU"."SU_ID",
    "SU"."Metadata_SU",
    "NAM"."SU_NAM_SU_ID",
    "NAM"."Metadata_SU_NAM",
    "NAM"."SU_NAM_ID",
    "NAM"."SU_NAM_PositedAt",
    "NAM"."SU_NAM_Reliability",
    "NAM"."SU_NAM_Subject_Name",
    "COD"."SU_COD_SU_ID",
    "COD"."Metadata_SU_COD",
    "COD"."SU_COD_ID",
    "COD"."SU_COD_PositedAt",
    "COD"."SU_COD_Reliability",
    "COD"."SU_COD_Subject_Code",
    "GRD"."SU_GRD_SU_ID",
    "GRD"."Metadata_SU_GRD",
    "GRD"."SU_GRD_ID",
    "GRD"."SU_GRD_PositedAt",
    "GRD"."SU_GRD_Reliability",
    "kGRD"."GRD_Grade" AS "SU_GRD_GRD_Grade",
    "kGRD"."Metadata_GRD" AS "SU_GRD_Metadata_GRD",
    "GRD"."SU_GRD_GRD_ID",
    "NOT"."SU_NOT_SU_ID",
    "NOT"."Metadata_SU_NOT",
    "NOT"."SU_NOT_ID",
    "NOT"."SU_NOT_PositedAt",
    "NOT"."SU_NOT_Reliability",
    "NOT"."SU_NOT_Checksum",
    "NOT"."SU_NOT_Subject_Note",
    "TTL"."SU_TTL_SU_ID",
    "TTL"."Metadata_SU_TTL",
    "TTL"."SU_TTL_ID",
    "TTL"."SU_TTL_ChangedAt",
    "TTL"."SU_TTL_PositedAt",
    "TTL"."SU_TTL_Reliability",
    "TTL"."SU_TTL_Subject_Title",
    "STA"."SU_STA_SU_ID",
    "STA"."Metadata_SU_STA",
    "STA"."SU_STA_ID",
    "STA"."SU_STA_ChangedAt",
    "STA"."SU_STA_PositedAt",
    "STA"."SU_STA_Reliability",
    "STA"."SU_STA_Subject_State",
    "LBL"."SU_LBL_SU_ID",
    "LBL"."Metadata_SU_LBL",
    "LBL"."SU_LBL_ID",
    "LBL"."SU_LBL_ChangedAt",
    "LBL"."SU_LBL_PositedAt",
    "LBL"."SU_LBL_Reliability",
    "LBL"."SU_LBL_Subject_Label",
    "TAG"."SU_TAG_SU_ID",
    "TAG"."Metadata_SU_TAG",
    "TAG"."SU_TAG_ID",
    "TAG"."SU_TAG_ChangedAt",
    "TAG"."SU_TAG_PositedAt",
    "TAG"."SU_TAG_Reliability",
    "TAG"."SU_TAG_Subject_Tag",
    "LVL"."SU_LVL_SU_ID",
    "LVL"."Metadata_SU_LVL",
    "LVL"."SU_LVL_ID",
    "LVL"."SU_LVL_ChangedAt",
    "LVL"."SU_LVL_PositedAt",
    "LVL"."SU_LVL_Reliability",
    "kLVL"."GRD_Grade" AS "SU_LVL_GRD_Grade",
    "kLVL"."Metadata_GRD" AS "SU_LVL_Metadata_GRD",
    "LVL"."SU_LVL_GRD_ID",
    "TXT"."SU_TXT_SU_ID",
    "TXT"."Metadata_SU_TXT",
    "TXT"."SU_TXT_ID",
    "TXT"."SU_TXT_ChangedAt",
    "TXT"."SU_TXT_PositedAt",
    "TXT"."SU_TXT_Reliability",
    "TXT"."SU_TXT_Checksum",
    "TXT"."SU_TXT_Subject_Text",
    "ASR"."SU_ASR_SU_ID",
    "ASR"."Metadata_SU_ASR",
    "ASR"."SU_ASR_ID",
    "ASR"."SU_ASR_ChangedAt",
    "ASR"."SU_ASR_PositedAt",
    "ASR"."SU_ASR_Reliability",
    "ASR"."SU_ASR_Subject_Assessment",
    "ERS"."SU_ERS_SU_ID",
    "ERS"."Metadata_SU_ERS",
    "ERS"."SU_ERS_ID",
    "ERS"."SU_ERS_ChangedAt",
    "ERS"."SU_ERS_PositedAt",
    "ERS"."SU_ERS_Reliability",
    "ERS"."SU_ERS_Subject_Erasable"
FROM (
    SELECT DISTINCT
        "SU_TTL_SU_ID" AS "SU_ID",
        "SU_TTL_ChangedAt"::timestamp AS inspectedTimepoint,
        'TTL' AS mnemonic
    FROM
        public."SU_TTL_Subject_Title"
    WHERE
        (selection IS NULL OR selection LIKE '%TTL%')
    AND
        "SU_TTL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_STA_SU_ID" AS "SU_ID",
        "SU_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        public."SU_STA_Subject_State"
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        "SU_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_LBL_SU_ID" AS "SU_ID",
        "SU_LBL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LBL' AS mnemonic
    FROM
        public."SU_LBL_Subject_Label"
    WHERE
        (selection IS NULL OR selection LIKE '%LBL%')
    AND
        "SU_LBL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_TAG_SU_ID" AS "SU_ID",
        "SU_TAG_ChangedAt"::timestamp AS inspectedTimepoint,
        'TAG' AS mnemonic
    FROM
        public."SU_TAG_Subject_Tag"
    WHERE
        (selection IS NULL OR selection LIKE '%TAG%')
    AND
        "SU_TAG_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_LVL_SU_ID" AS "SU_ID",
        "SU_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        public."SU_LVL_Subject_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "SU_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_TXT_SU_ID" AS "SU_ID",
        "SU_TXT_ChangedAt"::timestamp AS inspectedTimepoint,
        'TXT' AS mnemonic
    FROM
        public."SU_TXT_Subject_Text"
    WHERE
        (selection IS NULL OR selection LIKE '%TXT%')
    AND
        "SU_TXT_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_ASR_SU_ID" AS "SU_ID",
        "SU_ASR_ChangedAt"::timestamp AS inspectedTimepoint,
        'ASR' AS mnemonic
    FROM
        public."SU_ASR_Subject_Assessment"
    WHERE
        (selection IS NULL OR selection LIKE '%ASR%')
    AND
        "SU_ASR_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "SU_ERS_SU_ID" AS "SU_ID",
        "SU_ERS_ChangedAt"::timestamp AS inspectedTimepoint,
        'ERS' AS mnemonic
    FROM
        public."SU_ERS_Subject_Erasable"
    WHERE
        (selection IS NULL OR selection LIKE '%ERS%')
    AND
        "SU_ERS_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."SU_Subject" "SU"
ON
    "SU"."SU_ID" = timepoints."SU_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_NAM_SU_ID")
        r.*
    FROM
        public."rSU_NAM_Subject_Name"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_NAM_Reliability" = 1
    ORDER BY
    r."SU_NAM_SU_ID",
    r."SU_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."SU_NAM_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_COD_SU_ID")
        r.*
    FROM
        public."rSU_COD_Subject_Code"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_COD_Reliability" = 1
    ORDER BY
    r."SU_COD_SU_ID",
    r."SU_COD_PositedAt" DESC
) "COD"
ON
    "COD"."SU_COD_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_GRD_SU_ID")
        r.*
    FROM
        public."rSU_GRD_Subject_Grade"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_GRD_Reliability" = 1
    ORDER BY
    r."SU_GRD_SU_ID",
    r."SU_GRD_PositedAt" DESC
) "GRD"
ON
    "GRD"."SU_GRD_SU_ID" = "SU"."SU_ID"
LEFT JOIN
    public."GRD_Grade" "kGRD"
ON
    "kGRD"."GRD_ID" = "GRD"."SU_GRD_GRD_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."SU_NOT_SU_ID")
        r.*
    FROM
        public."rSU_NOT_Subject_Note"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."SU_NOT_Reliability" = 1
    ORDER BY
    r."SU_NOT_SU_ID",
    r."SU_NOT_PositedAt" DESC
) "NOT"
ON
    "NOT"."SU_NOT_SU_ID" = "SU"."SU_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_TTL_ChangedAt") OVER (
            PARTITION BY x."SU_TTL_SU_ID"
            ORDER BY x."SU_TTL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_TTL_SU_ID", r."SU_TTL_ChangedAt")
            r.*
        FROM
            public."rSU_TTL_Subject_Title"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_TTL_Reliability" = 1
        ORDER BY
    r."SU_TTL_SU_ID", r."SU_TTL_ChangedAt",
    r."SU_TTL_PositedAt" DESC
    ) x
) "TTL"
ON
    "TTL"."SU_TTL_SU_ID" = "SU"."SU_ID"
AND
    "TTL"."SU_TTL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TTL"."until" IS NULL
OR
    "TTL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_STA_ChangedAt") OVER (
            PARTITION BY x."SU_STA_SU_ID"
            ORDER BY x."SU_STA_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_STA_SU_ID", r."SU_STA_ChangedAt")
            r.*
        FROM
            public."rSU_STA_Subject_State"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_STA_Reliability" = 1
        ORDER BY
    r."SU_STA_SU_ID", r."SU_STA_ChangedAt",
    r."SU_STA_PositedAt" DESC
    ) x
) "STA"
ON
    "STA"."SU_STA_SU_ID" = "SU"."SU_ID"
AND
    "STA"."SU_STA_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_LBL_ChangedAt") OVER (
            PARTITION BY x."SU_LBL_SU_ID"
            ORDER BY x."SU_LBL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_LBL_SU_ID", r."SU_LBL_ChangedAt")
            r.*
        FROM
            public."rSU_LBL_Subject_Label"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_LBL_Reliability" = 1
        ORDER BY
    r."SU_LBL_SU_ID", r."SU_LBL_ChangedAt",
    r."SU_LBL_PositedAt" DESC
    ) x
) "LBL"
ON
    "LBL"."SU_LBL_SU_ID" = "SU"."SU_ID"
AND
    "LBL"."SU_LBL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "LBL"."until" IS NULL
OR
    "LBL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_TAG_ChangedAt") OVER (
            PARTITION BY x."SU_TAG_SU_ID"
            ORDER BY x."SU_TAG_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_TAG_SU_ID", r."SU_TAG_ChangedAt")
            r.*
        FROM
            public."rSU_TAG_Subject_Tag"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_TAG_Reliability" = 1
        ORDER BY
    r."SU_TAG_SU_ID", r."SU_TAG_ChangedAt",
    r."SU_TAG_PositedAt" DESC
    ) x
) "TAG"
ON
    "TAG"."SU_TAG_SU_ID" = "SU"."SU_ID"
AND
    "TAG"."SU_TAG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TAG"."until" IS NULL
OR
    "TAG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_LVL_ChangedAt") OVER (
            PARTITION BY x."SU_LVL_SU_ID"
            ORDER BY x."SU_LVL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_LVL_SU_ID", r."SU_LVL_ChangedAt")
            r.*
        FROM
            public."rSU_LVL_Subject_Level"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_LVL_Reliability" = 1
        ORDER BY
    r."SU_LVL_SU_ID", r."SU_LVL_ChangedAt",
    r."SU_LVL_PositedAt" DESC
    ) x
) "LVL"
ON
    "LVL"."SU_LVL_SU_ID" = "SU"."SU_ID"
AND
    "LVL"."SU_LVL_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    public."GRD_Grade" "kLVL"
ON
    "kLVL"."GRD_ID" = "LVL"."SU_LVL_GRD_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_TXT_ChangedAt") OVER (
            PARTITION BY x."SU_TXT_SU_ID"
            ORDER BY x."SU_TXT_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_TXT_SU_ID", r."SU_TXT_ChangedAt")
            r.*
        FROM
            public."rSU_TXT_Subject_Text"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_TXT_Reliability" = 1
        ORDER BY
    r."SU_TXT_SU_ID", r."SU_TXT_ChangedAt",
    r."SU_TXT_PositedAt" DESC
    ) x
) "TXT"
ON
    "TXT"."SU_TXT_SU_ID" = "SU"."SU_ID"
AND
    "TXT"."SU_TXT_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "TXT"."until" IS NULL
OR
    "TXT"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_ASR_ChangedAt") OVER (
            PARTITION BY x."SU_ASR_SU_ID"
            ORDER BY x."SU_ASR_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_ASR_SU_ID", r."SU_ASR_ChangedAt")
            r.*
        FROM
            public."rSU_ASR_Subject_Assessment"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_ASR_Reliability" = 1
        ORDER BY
    r."SU_ASR_SU_ID", r."SU_ASR_ChangedAt",
    r."SU_ASR_PositedAt" DESC
    ) x
) "ASR"
ON
    "ASR"."SU_ASR_SU_ID" = "SU"."SU_ID"
AND
    "ASR"."SU_ASR_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "ASR"."until" IS NULL
OR
    "ASR"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT
        x.*,
        lead(x."SU_ERS_ChangedAt") OVER (
            PARTITION BY x."SU_ERS_SU_ID"
            ORDER BY x."SU_ERS_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."SU_ERS_SU_ID", r."SU_ERS_ChangedAt")
            r.*
        FROM
            public."rSU_ERS_Subject_Erasable"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."SU_ERS_Reliability" = 1
        ORDER BY
    r."SU_ERS_SU_ID", r."SU_ERS_ChangedAt",
    r."SU_ERS_PositedAt" DESC
    ) x
) "ERS"
ON
    "ERS"."SU_ERS_SU_ID" = "SU"."SU_ID"
AND
    "ERS"."SU_ERS_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "ERS"."until" IS NULL
OR
    "ERS"."until" > timepoints.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tOB_Object" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "OB_ID" integer,
    "Metadata_OB" integer,
    "OB_NAM_OB_ID" integer,
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Reliability" decimal(5,2),
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "NAM"."OB_NAM_OB_ID",
    "NAM"."Metadata_OB_NAM",
    "NAM"."OB_NAM_ID",
    "NAM"."OB_NAM_PositedAt",
    "NAM"."OB_NAM_Reliability",
    "NAM"."OB_NAM_Object_Name"
FROM
    public."OB_Object" "OB"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."OB_NAM_OB_ID")
        r.*
    FROM
        public."rOB_NAM_Object_Name"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."OB_NAM_Reliability" = 1
    ORDER BY
    r."OB_NAM_OB_ID",
    r."OB_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."OB_NAM_OB_ID" = "OB"."OB_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lOB_Object" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "OB".*
FROM
    public."tOB_Object"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "OB"
;
CREATE OR REPLACE FUNCTION public."pOB_Object" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "OB_ID" integer,
    "Metadata_OB" integer,
    "OB_NAM_OB_ID" integer,
    "Metadata_OB_NAM" integer,
    "OB_NAM_ID" integer,
    "OB_NAM_PositedAt" timestamp,
    "OB_NAM_Reliability" decimal(5,2),
    "OB_NAM_Object_Name" varchar(42)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "OB"."OB_ID",
    "OB"."Metadata_OB",
    "OB"."OB_NAM_OB_ID",
    "OB"."Metadata_OB_NAM",
    "OB"."OB_NAM_ID",
    "OB"."OB_NAM_PositedAt",
    "OB"."OB_NAM_Reliability",
    "OB"."OB_NAM_Object_Name"
FROM
    public."tOB_Object"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "OB"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nOB_Object" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "OB".*
FROM
    public."tOB_Object"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "OB"
;
-- NEXUS TEMPORAL PERSPECTIVES ----------------------------------------------------------------------------------------
--
-- BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tEV_Event" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_ID",
    "QTY"."EV_QTY_PositedAt",
    "QTY"."EV_QTY_Reliability",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ID",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_PositedAt",
    "PLC"."EV_PLC_Reliability",
    "PLC"."EV_PLC_Event_Place"
FROM
    public."EV_Event" "EV"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_QTY_EV_ID")
        r.*
    FROM
        public."rEV_QTY_Event_Quantity"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_QTY_Reliability" = 1
    ORDER BY
    r."EV_QTY_EV_ID",
    r."EV_QTY_PositedAt" DESC
) "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_PLC_EV_ID")
        r.*
    FROM
        public."rEV_PLC_Event_Place"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_PLC_Reliability" = 1
    ORDER BY
    r."EV_PLC_EV_ID",
    r."EV_PLC_ChangedAt" DESC,
    r."EV_PLC_PositedAt" DESC
) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lEV_Event" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    public."tEV_Event"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
CREATE OR REPLACE FUNCTION public."pEV_Event" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "EV"."EV_QTY_EV_ID",
    "EV"."Metadata_EV_QTY",
    "EV"."EV_QTY_ID",
    "EV"."EV_QTY_PositedAt",
    "EV"."EV_QTY_Reliability",
    "EV"."EV_QTY_Event_Quantity",
    "EV"."EV_PLC_EV_ID",
    "EV"."Metadata_EV_PLC",
    "EV"."EV_PLC_ID",
    "EV"."EV_PLC_ChangedAt",
    "EV"."EV_PLC_PositedAt",
    "EV"."EV_PLC_Reliability",
    "EV"."EV_PLC_Event_Place"
FROM
    public."tEV_Event"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nEV_Event" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    public."tEV_Event"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
CREATE OR REPLACE FUNCTION public."dEV_Event" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "EV_ID" integer,
    "Metadata_EV" integer,
    "SU_ID_for" integer,
    "EV_QTY_EV_ID" integer,
    "Metadata_EV_QTY" integer,
    "EV_QTY_ID" integer,
    "EV_QTY_PositedAt" timestamp,
    "EV_QTY_Reliability" decimal(5,2),
    "EV_QTY_Event_Quantity" integer,
    "EV_PLC_EV_ID" integer,
    "Metadata_EV_PLC" integer,
    "EV_PLC_ID" integer,
    "EV_PLC_ChangedAt" timestamp,
    "EV_PLC_PositedAt" timestamp,
    "EV_PLC_Reliability" decimal(5,2),
    "EV_PLC_Event_Place" varchar(42)
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."SU_ID_for",
    "QTY"."EV_QTY_EV_ID",
    "QTY"."Metadata_EV_QTY",
    "QTY"."EV_QTY_ID",
    "QTY"."EV_QTY_PositedAt",
    "QTY"."EV_QTY_Reliability",
    "QTY"."EV_QTY_Event_Quantity",
    "PLC"."EV_PLC_EV_ID",
    "PLC"."Metadata_EV_PLC",
    "PLC"."EV_PLC_ID",
    "PLC"."EV_PLC_ChangedAt",
    "PLC"."EV_PLC_PositedAt",
    "PLC"."EV_PLC_Reliability",
    "PLC"."EV_PLC_Event_Place"
FROM (
    SELECT DISTINCT
        "EV_PLC_EV_ID" AS "EV_ID",
        "EV_PLC_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLC' AS mnemonic
    FROM
        public."EV_PLC_Event_Place"
    WHERE
        (selection IS NULL OR selection LIKE '%PLC%')
    AND
        "EV_PLC_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    public."EV_Event" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_QTY_EV_ID")
        r.*
    FROM
        public."rEV_QTY_Event_Quantity"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_QTY_Reliability" = 1
    ORDER BY
    r."EV_QTY_EV_ID",
    r."EV_QTY_PositedAt" DESC
) "QTY"
ON
    "QTY"."EV_QTY_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."EV_PLC_ChangedAt") OVER (
            PARTITION BY x."EV_PLC_EV_ID"
            ORDER BY x."EV_PLC_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."EV_PLC_EV_ID", r."EV_PLC_ChangedAt")
            r.*
        FROM
            public."rEV_PLC_Event_Place"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."EV_PLC_Reliability" = 1
        ORDER BY
    r."EV_PLC_EV_ID", r."EV_PLC_ChangedAt",
    r."EV_PLC_PositedAt" DESC
    ) x
) "PLC"
ON
    "PLC"."EV_PLC_EV_ID" = "EV"."EV_ID"
AND
    "PLC"."EV_PLC_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLC"."until" IS NULL
OR
    "PLC"."until" > timepoints.inspectedTimepoint::timestamp
)
$$ LANGUAGE sql STABLE;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade_Posit" (
    "SU_holder_OB_item_GRD_grade_ID" integer default nextval('public."SU_holder_OB_item_GRD_grade_Posit_ID_SEQ"') not null, 
    "SU_ID_holder" integer not null, 
    "OB_ID_item" integer not null, 
    "GRD_ID_grade" smallint not null,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp not null,
    constraint "SU_holder_OB_item_GRD_grade_Posit_fkSU_holder" foreign key (
        "SU_ID_holder"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_Posit_fkOB_item" foreign key (
        "OB_ID_item"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_holder_OB_item_GRD_grade_Posit_fkGRD_grade" foreign key (
        "GRD_ID_grade"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_holder_OB_item_GRD_grade_Posit" primary key (
        "SU_holder_OB_item_GRD_grade_ID"
    ),
    constraint "uqSU_holder_OB_item_GRD_grade" unique (
        "SU_ID_holder",
        "OB_ID_item",
        "SU_holder_OB_item_GRD_grade_ChangedAt",
        "GRD_ID_grade"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_holder_OB_item_GRD_grade_Annex" (
    "SU_holder_OB_item_GRD_grade_ID" integer not null,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp not null,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2) not null,
    "Metadata_SU_holder_OB_item_GRD_grade" integer not null,
    constraint "fkSU_holder_OB_item_GRD_grade_Annex" foreign key (
        "SU_holder_OB_item_GRD_grade_ID"
    ) references public."SU_holder_OB_item_GRD_grade_Posit"("SU_holder_OB_item_GRD_grade_ID"),
    constraint "pkSU_holder_OB_item_GRD_grade_Annex" primary key (
        "SU_holder_OB_item_GRD_grade_ID",
        "SU_holder_OB_item_GRD_grade_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank_Posit" (
    "SU_keeper_OB_thing_GRD_rank_ID" integer default nextval('public."SU_keeper_OB_thing_GRD_rank_Posit_ID_SEQ"') not null, 
    "SU_ID_keeper" integer not null, 
    "OB_ID_thing" integer not null, 
    "GRD_ID_rank" smallint not null,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp not null,
    constraint "SU_keeper_OB_thing_GRD_rank_Posit_fkSU_keeper" foreign key (
        "SU_ID_keeper"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_Posit_fkOB_thing" foreign key (
        "OB_ID_thing"
    ) references public."OB_Object"("OB_ID"), 
    constraint "SU_keeper_OB_thing_GRD_rank_Posit_fkGRD_rank" foreign key (
        "GRD_ID_rank"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_keeper_OB_thing_GRD_rank_Posit" primary key (
        "SU_keeper_OB_thing_GRD_rank_ID"
    ),
    constraint "uqSU_keeper_OB_thing_GRD_rank" unique (
        "SU_ID_keeper",
        "OB_ID_thing",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt",
        "GRD_ID_rank"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_keeper_OB_thing_GRD_rank_Annex" (
    "SU_keeper_OB_thing_GRD_rank_ID" integer not null,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp not null,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2) not null,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer not null,
    constraint "fkSU_keeper_OB_thing_GRD_rank_Annex" foreign key (
        "SU_keeper_OB_thing_GRD_rank_ID"
    ) references public."SU_keeper_OB_thing_GRD_rank_Posit"("SU_keeper_OB_thing_GRD_rank_ID"),
    constraint "pkSU_keeper_OB_thing_GRD_rank_Annex" primary key (
        "SU_keeper_OB_thing_GRD_rank_ID",
        "SU_keeper_OB_thing_GRD_rank_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."OB_part_SU_owner_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."OB_part_SU_owner_Posit" (
    "OB_part_SU_owner_ID" integer default nextval('public."OB_part_SU_owner_Posit_ID_SEQ"') not null, 
    "OB_ID_part" integer not null, 
    "SU_ID_owner" integer not null, 
    constraint "OB_part_SU_owner_Posit_fkOB_part" foreign key (
        "OB_ID_part"
    ) references public."OB_Object"("OB_ID"), 
    constraint "OB_part_SU_owner_Posit_fkSU_owner" foreign key (
        "SU_ID_owner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "pkOB_part_SU_owner_Posit" primary key (
        "OB_part_SU_owner_ID"
    ),
    constraint "uqOB_part_SU_owner" unique (
        "OB_ID_part",
        "SU_ID_owner"
    )
);
CREATE TABLE IF NOT EXISTS public."OB_part_SU_owner_Annex" (
    "OB_part_SU_owner_ID" integer not null,
    "OB_part_SU_owner_PositedAt" timestamp not null,
    "OB_part_SU_owner_Reliability" decimal(5,2) not null,
    "Metadata_OB_part_SU_owner" integer not null,
    constraint "fkOB_part_SU_owner_Annex" foreign key (
        "OB_part_SU_owner_ID"
    ) references public."OB_part_SU_owner_Posit"("OB_part_SU_owner_ID"),
    constraint "pkOB_part_SU_owner_Annex" primary key (
        "OB_part_SU_owner_ID",
        "OB_part_SU_owner_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS public."SU_partner_SU_with_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS public."SU_partner_SU_with_Posit" (
    "SU_partner_SU_with_ID" integer default nextval('public."SU_partner_SU_with_Posit_ID_SEQ"') not null, 
    "SU_ID_partner" integer not null, 
    "SU_ID_with" integer not null, 
    "SU_partner_SU_with_ChangedAt" timestamp not null,
    constraint "SU_partner_SU_with_Posit_fkSU_partner" foreign key (
        "SU_ID_partner"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_Posit_fkSU_with" foreign key (
        "SU_ID_with"
    ) references public."SU_Subject"("SU_ID"), 
    constraint "SU_partner_SU_with_Posit_uqSU_partner" unique (
        "SU_ID_partner",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "SU_partner_SU_with_Posit_uqSU_with" unique (
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt"
    ),
    constraint "pkSU_partner_SU_with_Posit" primary key (
        "SU_partner_SU_with_ID"
    ),
    constraint "uqSU_partner_SU_with" unique (
        "SU_partner_SU_with_ChangedAt",
        "SU_ID_partner",
        "SU_ID_with"
    )
);
CREATE TABLE IF NOT EXISTS public."SU_partner_SU_with_Annex" (
    "SU_partner_SU_with_ID" integer not null,
    "SU_partner_SU_with_PositedAt" timestamp not null,
    "SU_partner_SU_with_Reliability" decimal(5,2) not null,
    "Metadata_SU_partner_SU_with" integer not null,
    constraint "fkSU_partner_SU_with_Annex" foreign key (
        "SU_partner_SU_with_ID"
    ) references public."SU_partner_SU_with_Posit"("SU_partner_SU_with_ID"),
    constraint "pkSU_partner_SU_with_Annex" primary key (
        "SU_partner_SU_with_ID",
        "SU_partner_SU_with_PositedAt"
    )
);
-- TIE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------------
--
-- The assembled view of a tie combines its posit and annex tables. It has the name that the tie table has
-- in uni-temporal modeling.
--
CREATE OR REPLACE VIEW public."SU_holder_OB_item_GRD_grade" AS
SELECT
    a."Metadata_SU_holder_OB_item_GRD_grade",
    p."SU_holder_OB_item_GRD_grade_ID",
    p."SU_ID_holder",
    p."OB_ID_item",
    p."GRD_ID_grade",
    p."SU_holder_OB_item_GRD_grade_ChangedAt",
    a."SU_holder_OB_item_GRD_grade_PositedAt",
    a."SU_holder_OB_item_GRD_grade_Reliability"
FROM
    public."SU_holder_OB_item_GRD_grade_Posit" p
JOIN
    public."SU_holder_OB_item_GRD_grade_Annex" a
ON
    a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
;
CREATE OR REPLACE VIEW public."SU_keeper_OB_thing_GRD_rank" AS
SELECT
    a."Metadata_SU_keeper_OB_thing_GRD_rank",
    p."SU_keeper_OB_thing_GRD_rank_ID",
    p."SU_ID_keeper",
    p."OB_ID_thing",
    p."GRD_ID_rank",
    p."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt",
    a."SU_keeper_OB_thing_GRD_rank_Reliability"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Posit" p
JOIN
    public."SU_keeper_OB_thing_GRD_rank_Annex" a
ON
    a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
;
CREATE OR REPLACE VIEW public."OB_part_SU_owner" AS
SELECT
    a."Metadata_OB_part_SU_owner",
    p."OB_part_SU_owner_ID",
    p."OB_ID_part",
    p."SU_ID_owner",
    a."OB_part_SU_owner_PositedAt",
    a."OB_part_SU_owner_Reliability"
FROM
    public."OB_part_SU_owner_Posit" p
JOIN
    public."OB_part_SU_owner_Annex" a
ON
    a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
;
CREATE OR REPLACE VIEW public."SU_partner_SU_with" AS
SELECT
    a."Metadata_SU_partner_SU_with",
    p."SU_partner_SU_with_ID",
    p."SU_ID_partner",
    p."SU_ID_with",
    p."SU_partner_SU_with_ChangedAt",
    a."SU_partner_SU_with_PositedAt",
    a."SU_partner_SU_with_Reliability"
FROM
    public."SU_partner_SU_with_Posit" p
JOIN
    public."SU_partner_SU_with_Annex" a
ON
    a."SU_partner_SU_with_ID" = p."SU_partner_SU_with_ID"
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION public."rSU_holder_OB_item_GRD_grade_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_holder_OB_item_GRD_grade_ID",
    "SU_ID_holder",
    "OB_ID_item",
    "GRD_ID_grade",
    "SU_holder_OB_item_GRD_grade_ChangedAt"
FROM
    public."SU_holder_OB_item_GRD_grade_Posit"
WHERE
    "SU_holder_OB_item_GRD_grade_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_holder_OB_item_GRD_grade_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_holder_OB_item_GRD_grade_ID",
    "SU_ID_holder",
    "OB_ID_item",
    "GRD_ID_grade",
    "SU_holder_OB_item_GRD_grade_ChangedAt"
FROM
    public."SU_holder_OB_item_GRD_grade_Posit"
WHERE
    "SU_holder_OB_item_GRD_grade_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_holder_OB_item_GRD_grade_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_holder_OB_item_GRD_grade",
    "SU_holder_OB_item_GRD_grade_ID",
    "SU_holder_OB_item_GRD_grade_PositedAt",
    "SU_holder_OB_item_GRD_grade_Reliability"
FROM
    public."SU_holder_OB_item_GRD_grade_Annex"
WHERE
    "SU_holder_OB_item_GRD_grade_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_holder_OB_item_GRD_grade_ID")
    a."Metadata_SU_holder_OB_item_GRD_grade",
    p."SU_holder_OB_item_GRD_grade_ID",
    p."SU_ID_holder",
    p."OB_ID_item",
    p."GRD_ID_grade",
    p."SU_holder_OB_item_GRD_grade_ChangedAt",
    a."SU_holder_OB_item_GRD_grade_PositedAt",
    a."SU_holder_OB_item_GRD_grade_Reliability"
FROM
    public."rSU_holder_OB_item_GRD_grade_Posit"(changingTimepoint) p 
JOIN
    public."rSU_holder_OB_item_GRD_grade_Annex"(positingTimepoint) a
ON
    a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
ORDER BY
    p."SU_holder_OB_item_GRD_grade_ID",
    a."SU_holder_OB_item_GRD_grade_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "SU_ID_holder" integer, 
    "OB_ID_item" integer, 
    "GRD_ID_grade" smallint,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_holder_OB_item_GRD_grade_ID")
    a."Metadata_SU_holder_OB_item_GRD_grade",
    p."SU_holder_OB_item_GRD_grade_ID",
    p."SU_ID_holder",
    p."OB_ID_item",
    p."GRD_ID_grade",
    p."SU_holder_OB_item_GRD_grade_ChangedAt",
    a."SU_holder_OB_item_GRD_grade_PositedAt",
    a."SU_holder_OB_item_GRD_grade_Reliability"
FROM
    public."fSU_holder_OB_item_GRD_grade_Posit"(changingTimepoint) p 
JOIN
    public."rSU_holder_OB_item_GRD_grade_Annex"(positingTimepoint) a
ON
    a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
ORDER BY
    p."SU_holder_OB_item_GRD_grade_ID",
    a."SU_holder_OB_item_GRD_grade_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_keeper_OB_thing_GRD_rank_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_keeper_OB_thing_GRD_rank_ID",
    "SU_ID_keeper",
    "OB_ID_thing",
    "GRD_ID_rank",
    "SU_keeper_OB_thing_GRD_rank_ChangedAt"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Posit"
WHERE
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_keeper_OB_thing_GRD_rank_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_keeper_OB_thing_GRD_rank_ID",
    "SU_ID_keeper",
    "OB_ID_thing",
    "GRD_ID_rank",
    "SU_keeper_OB_thing_GRD_rank_ChangedAt"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Posit"
WHERE
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_keeper_OB_thing_GRD_rank_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_keeper_OB_thing_GRD_rank",
    "SU_keeper_OB_thing_GRD_rank_ID",
    "SU_keeper_OB_thing_GRD_rank_PositedAt",
    "SU_keeper_OB_thing_GRD_rank_Reliability"
FROM
    public."SU_keeper_OB_thing_GRD_rank_Annex"
WHERE
    "SU_keeper_OB_thing_GRD_rank_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_keeper_OB_thing_GRD_rank_ID")
    a."Metadata_SU_keeper_OB_thing_GRD_rank",
    p."SU_keeper_OB_thing_GRD_rank_ID",
    p."SU_ID_keeper",
    p."OB_ID_thing",
    p."GRD_ID_rank",
    p."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt",
    a."SU_keeper_OB_thing_GRD_rank_Reliability"
FROM
    public."rSU_keeper_OB_thing_GRD_rank_Posit"(changingTimepoint) p 
JOIN
    public."rSU_keeper_OB_thing_GRD_rank_Annex"(positingTimepoint) a
ON
    a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
ORDER BY
    p."SU_keeper_OB_thing_GRD_rank_ID",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "SU_ID_keeper" integer, 
    "OB_ID_thing" integer, 
    "GRD_ID_rank" smallint,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_keeper_OB_thing_GRD_rank_ID")
    a."Metadata_SU_keeper_OB_thing_GRD_rank",
    p."SU_keeper_OB_thing_GRD_rank_ID",
    p."SU_ID_keeper",
    p."OB_ID_thing",
    p."GRD_ID_rank",
    p."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt",
    a."SU_keeper_OB_thing_GRD_rank_Reliability"
FROM
    public."fSU_keeper_OB_thing_GRD_rank_Posit"(changingTimepoint) p 
JOIN
    public."rSU_keeper_OB_thing_GRD_rank_Annex"(positingTimepoint) a
ON
    a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
ORDER BY
    p."SU_keeper_OB_thing_GRD_rank_ID",
    a."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rOB_part_SU_owner_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_ID" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_OB_part_SU_owner",
    "OB_part_SU_owner_ID",
    "OB_part_SU_owner_PositedAt",
    "OB_part_SU_owner_Reliability"
FROM
    public."OB_part_SU_owner_Annex"
WHERE
    "OB_part_SU_owner_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rOB_part_SU_owner" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_ID" integer,
    "OB_ID_part" integer, 
    "SU_ID_owner" integer, 
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."OB_part_SU_owner_ID")
    a."Metadata_OB_part_SU_owner",
    p."OB_part_SU_owner_ID",
    p."OB_ID_part",
    p."SU_ID_owner",
    a."OB_part_SU_owner_PositedAt",
    a."OB_part_SU_owner_Reliability"
FROM
    public."OB_part_SU_owner_Posit" p
JOIN
    public."rOB_part_SU_owner_Annex"(positingTimepoint) a
ON
    a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
ORDER BY
    p."OB_part_SU_owner_ID",
    a."OB_part_SU_owner_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fOB_part_SU_owner" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_ID" integer,
    "OB_ID_part" integer, 
    "SU_ID_owner" integer, 
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."OB_part_SU_owner_ID")
    a."Metadata_OB_part_SU_owner",
    p."OB_part_SU_owner_ID",
    p."OB_ID_part",
    p."SU_ID_owner",
    a."OB_part_SU_owner_PositedAt",
    a."OB_part_SU_owner_Reliability"
FROM
    public."OB_part_SU_owner_Posit" p
JOIN
    public."rOB_part_SU_owner_Annex"(positingTimepoint) a
ON
    a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
ORDER BY
    p."OB_part_SU_owner_ID",
    a."OB_part_SU_owner_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_partner_SU_with_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_partner_SU_with_ID",
    "SU_ID_partner",
    "SU_ID_with",
    "SU_partner_SU_with_ChangedAt"
FROM
    public."SU_partner_SU_with_Posit"
WHERE
    "SU_partner_SU_with_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_partner_SU_with_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp
)
AS
$$
SELECT
    "SU_partner_SU_with_ID",
    "SU_ID_partner",
    "SU_ID_with",
    "SU_partner_SU_with_ChangedAt"
FROM
    public."SU_partner_SU_with_Posit"
WHERE
    "SU_partner_SU_with_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_partner_SU_with_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ID" integer,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_SU_partner_SU_with",
    "SU_partner_SU_with_ID",
    "SU_partner_SU_with_PositedAt",
    "SU_partner_SU_with_Reliability"
FROM
    public."SU_partner_SU_with_Annex"
WHERE
    "SU_partner_SU_with_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."rSU_partner_SU_with" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_partner_SU_with_ID")
    a."Metadata_SU_partner_SU_with",
    p."SU_partner_SU_with_ID",
    p."SU_ID_partner",
    p."SU_ID_with",
    p."SU_partner_SU_with_ChangedAt",
    a."SU_partner_SU_with_PositedAt",
    a."SU_partner_SU_with_Reliability"
FROM
    public."rSU_partner_SU_with_Posit"(changingTimepoint) p 
JOIN
    public."rSU_partner_SU_with_Annex"(positingTimepoint) a
ON
    a."SU_partner_SU_with_ID" = p."SU_partner_SU_with_ID"
ORDER BY
    p."SU_partner_SU_with_ID",
    a."SU_partner_SU_with_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."fSU_partner_SU_with" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ID" integer,
    "SU_ID_partner" integer, 
    "SU_ID_with" integer, 
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."SU_partner_SU_with_ID")
    a."Metadata_SU_partner_SU_with",
    p."SU_partner_SU_with_ID",
    p."SU_ID_partner",
    p."SU_ID_with",
    p."SU_partner_SU_with_ChangedAt",
    a."SU_partner_SU_with_PositedAt",
    a."SU_partner_SU_with_Reliability"
FROM
    public."fSU_partner_SU_with_Posit"(changingTimepoint) p 
JOIN
    public."rSU_partner_SU_with_Annex"(positingTimepoint) a
ON
    a."SU_partner_SU_with_ID" = p."SU_partner_SU_with_ID"
ORDER BY
    p."SU_partner_SU_with_ID",
    a."SU_partner_SU_with_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION public."tSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    t."SU_holder_OB_item_GRD_grade_ID",
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_ID_holder",
    t."OB_ID_item",
    "kGRD_grade"."GRD_Grade" AS "grade_GRD_Grade",
    "kGRD_grade"."Metadata_GRD" AS "grade_Metadata_GRD",
    t."GRD_ID_grade"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."SU_ID_holder",
                r."OB_ID_item"
            ORDER BY
                r."SU_holder_OB_item_GRD_grade_ChangedAt" DESC,
                r."SU_holder_OB_item_GRD_grade_PositedAt" DESC,
                r."SU_holder_OB_item_GRD_grade_ID" DESC
        ) AS "latest"
    FROM
        public."rSU_holder_OB_item_GRD_grade"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_holder_OB_item_GRD_grade_Reliability" = 1
) t
LEFT JOIN
    public."GRD_Grade" "kGRD_grade"
ON
    "kGRD_grade"."GRD_ID" = t."GRD_ID_grade"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_holder_OB_item_GRD_grade" AS
SELECT
    *
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pSU_holder_OB_item_GRD_grade" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    t."SU_holder_OB_item_GRD_grade_ID",
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_ID_holder",
    t."OB_ID_item",
    t."grade_GRD_Grade",
    t."grade_Metadata_GRD",
    t."GRD_ID_grade"
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_holder_OB_item_GRD_grade" AS
SELECT
    *
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dSU_holder_OB_item_GRD_grade" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "SU_holder_OB_item_GRD_grade_ID" integer,
    "Metadata_SU_holder_OB_item_GRD_grade" integer,
    "SU_holder_OB_item_GRD_grade_ChangedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_PositedAt" timestamp,
    "SU_holder_OB_item_GRD_grade_Reliability" decimal(5,2),
    "SU_ID_holder" integer,
    "OB_ID_item" integer,
    "grade_GRD_Grade" varchar(42),
    "grade_Metadata_GRD" integer,
    "GRD_ID_grade" smallint
)
AS
$$
SELECT
    t."SU_holder_OB_item_GRD_grade_ID",
    t."Metadata_SU_holder_OB_item_GRD_grade",
    t."SU_holder_OB_item_GRD_grade_ChangedAt",
    t."SU_holder_OB_item_GRD_grade_PositedAt",
    t."SU_holder_OB_item_GRD_grade_Reliability",
    t."SU_ID_holder",
    t."OB_ID_item",
    t."grade_GRD_Grade",
    t."grade_Metadata_GRD",
    t."GRD_ID_grade"
FROM
    public."tSU_holder_OB_item_GRD_grade"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."SU_holder_OB_item_GRD_grade_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    t."SU_keeper_OB_thing_GRD_rank_ID",
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    "kGRD_rank"."GRD_Grade" AS "rank_GRD_Grade",
    "kGRD_rank"."Metadata_GRD" AS "rank_Metadata_GRD",
    t."GRD_ID_rank"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."SU_ID_keeper",
                r."OB_ID_thing"
            ORDER BY
                r."SU_keeper_OB_thing_GRD_rank_ChangedAt" DESC,
                r."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC,
                r."SU_keeper_OB_thing_GRD_rank_ID" DESC
        ) AS "latest"
    FROM
        public."rSU_keeper_OB_thing_GRD_rank"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_keeper_OB_thing_GRD_rank_Reliability" = 1
) t
LEFT JOIN
    public."GRD_Grade" "kGRD_rank"
ON
    "kGRD_rank"."GRD_ID" = t."GRD_ID_rank"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_keeper_OB_thing_GRD_rank" AS
SELECT
    *
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pSU_keeper_OB_thing_GRD_rank" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    t."SU_keeper_OB_thing_GRD_rank_ID",
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    t."rank_GRD_Grade",
    t."rank_Metadata_GRD",
    t."GRD_ID_rank"
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_keeper_OB_thing_GRD_rank" AS
SELECT
    *
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dSU_keeper_OB_thing_GRD_rank" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "SU_keeper_OB_thing_GRD_rank_ID" integer,
    "Metadata_SU_keeper_OB_thing_GRD_rank" integer,
    "SU_keeper_OB_thing_GRD_rank_ChangedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_PositedAt" timestamp,
    "SU_keeper_OB_thing_GRD_rank_Reliability" decimal(5,2),
    "SU_ID_keeper" integer,
    "OB_ID_thing" integer,
    "rank_GRD_Grade" varchar(42),
    "rank_Metadata_GRD" integer,
    "GRD_ID_rank" smallint
)
AS
$$
SELECT
    t."SU_keeper_OB_thing_GRD_rank_ID",
    t."Metadata_SU_keeper_OB_thing_GRD_rank",
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt",
    t."SU_keeper_OB_thing_GRD_rank_PositedAt",
    t."SU_keeper_OB_thing_GRD_rank_Reliability",
    t."SU_ID_keeper",
    t."OB_ID_thing",
    t."rank_GRD_Grade",
    t."rank_Metadata_GRD",
    t."GRD_ID_rank"
FROM
    public."tSU_keeper_OB_thing_GRD_rank"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."SU_keeper_OB_thing_GRD_rank_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION public."tOB_part_SU_owner" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "OB_part_SU_owner_ID" integer,
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2),
    "OB_ID_part" integer,
    "SU_ID_owner" integer
)
AS
$$
SELECT
    t."OB_part_SU_owner_ID",
    t."Metadata_OB_part_SU_owner",
    t."OB_part_SU_owner_PositedAt",
    t."OB_part_SU_owner_Reliability",
    t."OB_ID_part",
    t."SU_ID_owner"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."OB_ID_part"
            ORDER BY
                r."OB_part_SU_owner_PositedAt" DESC,
                r."OB_part_SU_owner_ID" DESC
        ) AS "latest"
    FROM
        public."rOB_part_SU_owner"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."OB_part_SU_owner_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lOB_part_SU_owner" AS
SELECT
    *
FROM
    public."tOB_part_SU_owner"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pOB_part_SU_owner" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "OB_part_SU_owner_ID" integer,
    "Metadata_OB_part_SU_owner" integer,
    "OB_part_SU_owner_PositedAt" timestamp,
    "OB_part_SU_owner_Reliability" decimal(5,2),
    "OB_ID_part" integer,
    "SU_ID_owner" integer
)
AS
$$
SELECT
    t."OB_part_SU_owner_ID",
    t."Metadata_OB_part_SU_owner",
    t."OB_part_SU_owner_PositedAt",
    t."OB_part_SU_owner_Reliability",
    t."OB_ID_part",
    t."SU_ID_owner"
FROM
    public."tOB_part_SU_owner"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nOB_part_SU_owner" AS
SELECT
    *
FROM
    public."tOB_part_SU_owner"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."tSU_partner_SU_with" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    t."SU_partner_SU_with_ID",
    t."Metadata_SU_partner_SU_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Reliability",
    t."SU_ID_partner",
    t."SU_ID_with"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."SU_ID_partner"
            ORDER BY
                r."SU_partner_SU_with_ChangedAt" DESC,
                r."SU_partner_SU_with_PositedAt" DESC,
                r."SU_partner_SU_with_ID" DESC
        ) AS "latestSU_ID_partner",
        row_number() OVER (
            PARTITION BY r."SU_ID_with"
            ORDER BY
                r."SU_partner_SU_with_ChangedAt" DESC,
                r."SU_partner_SU_with_PositedAt" DESC,
                r."SU_partner_SU_with_ID" DESC
        ) AS "latestSU_ID_with"
    FROM
        public."rSU_partner_SU_with"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."SU_partner_SU_with_Reliability" = 1
) t
WHERE
    t."latestSU_ID_partner" = 1
AND
    t."latestSU_ID_with" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."lSU_partner_SU_with" AS
SELECT
    *
FROM
    public."tSU_partner_SU_with"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."pSU_partner_SU_with" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    t."SU_partner_SU_with_ID",
    t."Metadata_SU_partner_SU_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Reliability",
    t."SU_ID_partner",
    t."SU_ID_with"
FROM
    public."tSU_partner_SU_with"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW public."nSU_partner_SU_with" AS
SELECT
    *
FROM
    public."tSU_partner_SU_with"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION public."dSU_partner_SU_with" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "SU_partner_SU_with_ID" integer,
    "Metadata_SU_partner_SU_with" integer,
    "SU_partner_SU_with_ChangedAt" timestamp,
    "SU_partner_SU_with_PositedAt" timestamp,
    "SU_partner_SU_with_Reliability" decimal(5,2),
    "SU_ID_partner" integer,
    "SU_ID_with" integer
)
AS
$$
SELECT
    t."SU_partner_SU_with_ID",
    t."Metadata_SU_partner_SU_with",
    t."SU_partner_SU_with_ChangedAt",
    t."SU_partner_SU_with_PositedAt",
    t."SU_partner_SU_with_Reliability",
    t."SU_ID_partner",
    t."SU_ID_with"
FROM
    public."tSU_partner_SU_with"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."SU_partner_SU_with_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
-- ATTRIBUTE TRIGGERS ------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled views make them behave like tables.
-- There is one 'instead of' trigger for: insert.
-- They will ensure that such operations are propagated to the underlying tables
-- in a consistent way. Default values are used for some columns if not provided
-- by the corresponding SQL statements.
--
-- The rules are the ones in Anchor's docs/ANCHOR.md, "Loading through the latest views". Bitemporal modeling is decisive:
-- one posit at a time is asserted for an entity (and a changing time). An assertion of another value therefore retracts, at
-- its own positing time, the posit that is in effect, which is a correction; a posit is in effect at a positing time when its
-- latest annex row up to then asserts it. The positing time is now (the clock, which moves between two statements) unless it is
-- given.
--
-- For idempotent attributes, only changes that represent a value different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates, although what they correct is retracted.
--
-- PostgreSQL runs a trigger of this kind for each row.
--
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_QTY_Event_Quantity tells whether two values of EV_QTY_Event_Quantity are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_EV_QTY_Event_Quantity"(
    l integer,
    r integer
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_QTY_Event_Quantity instead of INSERT trigger on EV_QTY_Event_Quantity
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_QTY_Event_Quantity"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."EV_QTY_PositedAt", _now);
    _reliability := coalesce(NEW."EV_QTY_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_QTY_ID"
    INTO
        _posit
    FROM
        public."EV_QTY_Event_Quantity_Posit" p
    WHERE
        p."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
    AND
        public."eq_EV_QTY_Event_Quantity"(p."EV_QTY_Event_Quantity", NEW."EV_QTY_Event_Quantity")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity_Annex" a
        WHERE
            a."EV_QTY_ID" = _posit
        AND
            a."EV_QTY_PositedAt" = _positing
        AND
            a."EV_QTY_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_QTY_Event_Quantity for: %', concat_ws(', ', NEW."EV_QTY_EV_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity_Posit" p
        JOIN
            public."EV_QTY_Event_Quantity_Annex" a
        ON
            a."EV_QTY_ID" = p."EV_QTY_ID"
        WHERE
            p."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
        AND
            NOT public."eq_EV_QTY_Event_Quantity"(p."EV_QTY_Event_Quantity", NEW."EV_QTY_Event_Quantity")
        AND
            a."EV_QTY_PositedAt" = _positing
        AND
            a."EV_QTY_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_QTY_Event_Quantity for: %', concat_ws(', ', NEW."EV_QTY_EV_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_QTY_Event_Quantity_Annex" a
        WHERE
            a."EV_QTY_ID" = _posit
        AND
            a."EV_QTY_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_QTY_Reliability" = 1
            FROM
                public."EV_QTY_Event_Quantity_Annex" a
            WHERE
                a."EV_QTY_ID" = _posit
            AND
                a."EV_QTY_PositedAt" <= _positing
            ORDER BY
                a."EV_QTY_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
            "Metadata_EV_QTY",
            "EV_QTY_ID",
            "EV_QTY_PositedAt",
            "EV_QTY_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."EV_QTY_ID"
        FROM
            public."EV_QTY_Event_Quantity_Posit" p
        WHERE
            p."EV_QTY_EV_ID" = NEW."EV_QTY_EV_ID"
        AND
            NOT public."eq_EV_QTY_Event_Quantity"(p."EV_QTY_Event_Quantity", NEW."EV_QTY_Event_Quantity")
        AND
            coalesce((
                SELECT
                    a."EV_QTY_Reliability" = 1
                FROM
                    public."EV_QTY_Event_Quantity_Annex" a
                WHERE
                    a."EV_QTY_ID" = p."EV_QTY_ID"
                AND
                    a."EV_QTY_PositedAt" <= _positing
                ORDER BY
                    a."EV_QTY_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
            "Metadata_EV_QTY",
            "EV_QTY_ID",
            "EV_QTY_PositedAt",
            "EV_QTY_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."EV_QTY_Event_Quantity_Posit" (
            "EV_QTY_EV_ID",
            "EV_QTY_Event_Quantity"
        )
        VALUES (
            NEW."EV_QTY_EV_ID",
            NEW."EV_QTY_Event_Quantity"
        )
        RETURNING "EV_QTY_ID" INTO _posit;
    END IF;
    INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
        "Metadata_EV_QTY",
        "EV_QTY_ID",
        "EV_QTY_PositedAt",
        "EV_QTY_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_QTY", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_QTY_Event_Quantity" ON public."EV_QTY_Event_Quantity";
CREATE TRIGGER "it_EV_QTY_Event_Quantity"
INSTEAD OF INSERT ON public."EV_QTY_Event_Quantity"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_QTY_Event_Quantity"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_PLC_Event_Place tells whether two values of EV_PLC_Event_Place are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_EV_PLC_Event_Place"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_PLC_Event_Place instead of INSERT trigger on EV_PLC_Event_Place
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_EV_PLC_Event_Place"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."EV_PLC_PositedAt", _now);
    _reliability := coalesce(NEW."EV_PLC_Reliability", 1);
    _changing := coalesce(NEW."EV_PLC_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_PLC_ID"
    INTO
        _posit
    FROM
        public."EV_PLC_Event_Place_Posit" p
    WHERE
        p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
    AND
        p."EV_PLC_ChangedAt" = _changing
    AND
        public."eq_EV_PLC_Event_Place"(p."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place_Annex" a
        WHERE
            a."EV_PLC_ID" = _posit
        AND
            a."EV_PLC_PositedAt" = _positing
        AND
            a."EV_PLC_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place_Posit" p
        JOIN
            public."EV_PLC_Event_Place_Annex" a
        ON
            a."EV_PLC_ID" = p."EV_PLC_ID"
        WHERE
            p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            p."EV_PLC_ChangedAt" = _changing
        AND
            NOT public."eq_EV_PLC_Event_Place"(p."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
        AND
            a."EV_PLC_PositedAt" = _positing
        AND
            a."EV_PLC_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."EV_PLC_Event_Place_Annex" a
        WHERE
            a."EV_PLC_ID" = _posit
        AND
            a."EV_PLC_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_PLC_Reliability" = 1
            FROM
                public."EV_PLC_Event_Place_Annex" a
            WHERE
                a."EV_PLC_ID" = _posit
            AND
                a."EV_PLC_PositedAt" <= _positing
            ORDER BY
                a."EV_PLC_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."EV_PLC_Event_Place_Annex" (
            "Metadata_EV_PLC",
            "EV_PLC_ID",
            "EV_PLC_PositedAt",
            "EV_PLC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."EV_PLC_ID"
        FROM
            public."EV_PLC_Event_Place_Posit" p
        WHERE
            p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
        AND
            p."EV_PLC_ChangedAt" = _changing
        AND
            NOT public."eq_EV_PLC_Event_Place"(p."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
        AND
            coalesce((
                SELECT
                    a."EV_PLC_Reliability" = 1
                FROM
                    public."EV_PLC_Event_Place_Annex" a
                WHERE
                    a."EV_PLC_ID" = p."EV_PLC_ID"
                AND
                    a."EV_PLC_PositedAt" <= _positing
                ORDER BY
                    a."EV_PLC_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."EV_PLC_Event_Place_Annex" (
            "Metadata_EV_PLC",
            "EV_PLC_ID",
            "EV_PLC_PositedAt",
            "EV_PLC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."EV_PLC_Event_Place"
            FROM
                public."EV_PLC_Event_Place_Posit" p
            WHERE
                p."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
            AND
                p."EV_PLC_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."EV_PLC_Reliability" = 1
                    FROM
                        public."EV_PLC_Event_Place_Annex" a
                    WHERE
                        a."EV_PLC_ID" = p."EV_PLC_ID"
                    AND
                        a."EV_PLC_PositedAt" <= _positing
                    ORDER BY
                        a."EV_PLC_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."EV_PLC_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_EV_PLC_Event_Place"(pre."EV_PLC_Event_Place", NEW."EV_PLC_Event_Place")
    ) THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", _changing, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."EV_PLC_ID"
    INTO
        _following
    FROM
        public."EV_PLC_Event_Place_Posit" f
    WHERE
        f."EV_PLC_EV_ID" = NEW."EV_PLC_EV_ID"
    AND
        f."EV_PLC_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."EV_PLC_Reliability" = 1
            FROM
                public."EV_PLC_Event_Place_Annex" a
            WHERE
                a."EV_PLC_ID" = f."EV_PLC_ID"
            AND
                a."EV_PLC_PositedAt" <= _positing
            ORDER BY
                a."EV_PLC_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."EV_PLC_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_EV_PLC_Event_Place"((
        SELECT x."EV_PLC_Event_Place" FROM public."EV_PLC_Event_Place_Posit" x WHERE x."EV_PLC_ID" = _following
    ), NEW."EV_PLC_Event_Place") THEN
        RAISE EXCEPTION 'Restatement in EV_PLC_Event_Place for: %', concat_ws(', ', NEW."EV_PLC_EV_ID", _changing, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."EV_PLC_Event_Place_Posit" (
            "EV_PLC_EV_ID",
            "EV_PLC_ChangedAt",
            "EV_PLC_Event_Place"
        )
        VALUES (
            NEW."EV_PLC_EV_ID",
            _changing,
            NEW."EV_PLC_Event_Place"
        )
        RETURNING "EV_PLC_ID" INTO _posit;
    END IF;
    INSERT INTO public."EV_PLC_Event_Place_Annex" (
        "Metadata_EV_PLC",
        "EV_PLC_ID",
        "EV_PLC_PositedAt",
        "EV_PLC_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_PLC", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_PLC_Event_Place" ON public."EV_PLC_Event_Place";
CREATE TRIGGER "it_EV_PLC_Event_Place"
INSTEAD OF INSERT ON public."EV_PLC_Event_Place"
FOR EACH ROW EXECUTE FUNCTION public."it_EV_PLC_Event_Place"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NAM_Subject_Name tells whether two values of SU_NAM_Subject_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_NAM_Subject_Name"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NAM_Subject_Name instead of INSERT trigger on SU_NAM_Subject_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NAM_Subject_Name"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."SU_NAM_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_NAM_ID"
    INTO
        _posit
    FROM
        public."SU_NAM_Subject_Name_Posit" p
    WHERE
        p."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
    AND
        public."eq_SU_NAM_Subject_Name"(p."SU_NAM_Subject_Name", NEW."SU_NAM_Subject_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name_Annex" a
        WHERE
            a."SU_NAM_ID" = _posit
        AND
            a."SU_NAM_PositedAt" = _positing
        AND
            a."SU_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NAM_Subject_Name for: %', concat_ws(', ', NEW."SU_NAM_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name_Posit" p
        JOIN
            public."SU_NAM_Subject_Name_Annex" a
        ON
            a."SU_NAM_ID" = p."SU_NAM_ID"
        WHERE
            p."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
        AND
            NOT public."eq_SU_NAM_Subject_Name"(p."SU_NAM_Subject_Name", NEW."SU_NAM_Subject_Name")
        AND
            a."SU_NAM_PositedAt" = _positing
        AND
            a."SU_NAM_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NAM_Subject_Name for: %', concat_ws(', ', NEW."SU_NAM_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NAM_Subject_Name_Annex" a
        WHERE
            a."SU_NAM_ID" = _posit
        AND
            a."SU_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_NAM_Reliability" = 1
            FROM
                public."SU_NAM_Subject_Name_Annex" a
            WHERE
                a."SU_NAM_ID" = _posit
            AND
                a."SU_NAM_PositedAt" <= _positing
            ORDER BY
                a."SU_NAM_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_NAM_Subject_Name_Annex" (
            "Metadata_SU_NAM",
            "SU_NAM_ID",
            "SU_NAM_PositedAt",
            "SU_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_NAM_ID"
        FROM
            public."SU_NAM_Subject_Name_Posit" p
        WHERE
            p."SU_NAM_SU_ID" = NEW."SU_NAM_SU_ID"
        AND
            NOT public."eq_SU_NAM_Subject_Name"(p."SU_NAM_Subject_Name", NEW."SU_NAM_Subject_Name")
        AND
            coalesce((
                SELECT
                    a."SU_NAM_Reliability" = 1
                FROM
                    public."SU_NAM_Subject_Name_Annex" a
                WHERE
                    a."SU_NAM_ID" = p."SU_NAM_ID"
                AND
                    a."SU_NAM_PositedAt" <= _positing
                ORDER BY
                    a."SU_NAM_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_NAM_Subject_Name_Annex" (
            "Metadata_SU_NAM",
            "SU_NAM_ID",
            "SU_NAM_PositedAt",
            "SU_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_NAM_Subject_Name_Posit" (
            "SU_NAM_SU_ID",
            "SU_NAM_Subject_Name"
        )
        VALUES (
            NEW."SU_NAM_SU_ID",
            NEW."SU_NAM_Subject_Name"
        )
        RETURNING "SU_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_NAM_Subject_Name_Annex" (
        "Metadata_SU_NAM",
        "SU_NAM_ID",
        "SU_NAM_PositedAt",
        "SU_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_NAM", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NAM_Subject_Name" ON public."SU_NAM_Subject_Name";
CREATE TRIGGER "it_SU_NAM_Subject_Name"
INSTEAD OF INSERT ON public."SU_NAM_Subject_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NAM_Subject_Name"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_COD_Subject_Code tells whether two values of SU_COD_Subject_Code are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_COD_Subject_Code"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_COD_Subject_Code instead of INSERT trigger on SU_COD_Subject_Code
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_COD_Subject_Code"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_COD_PositedAt", _now);
    _reliability := coalesce(NEW."SU_COD_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_COD_ID"
    INTO
        _posit
    FROM
        public."SU_COD_Subject_Code_Posit" p
    WHERE
        p."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
    AND
        public."eq_SU_COD_Subject_Code"(p."SU_COD_Subject_Code", NEW."SU_COD_Subject_Code")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code_Annex" a
        WHERE
            a."SU_COD_ID" = _posit
        AND
            a."SU_COD_PositedAt" = _positing
        AND
            a."SU_COD_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_COD_Subject_Code for: %', concat_ws(', ', NEW."SU_COD_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code_Posit" p
        JOIN
            public."SU_COD_Subject_Code_Annex" a
        ON
            a."SU_COD_ID" = p."SU_COD_ID"
        WHERE
            p."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
        AND
            NOT public."eq_SU_COD_Subject_Code"(p."SU_COD_Subject_Code", NEW."SU_COD_Subject_Code")
        AND
            a."SU_COD_PositedAt" = _positing
        AND
            a."SU_COD_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_COD_Subject_Code for: %', concat_ws(', ', NEW."SU_COD_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_COD_Subject_Code_Annex" a
        WHERE
            a."SU_COD_ID" = _posit
        AND
            a."SU_COD_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_COD_Reliability" = 1
            FROM
                public."SU_COD_Subject_Code_Annex" a
            WHERE
                a."SU_COD_ID" = _posit
            AND
                a."SU_COD_PositedAt" <= _positing
            ORDER BY
                a."SU_COD_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_COD_Subject_Code_Annex" (
            "Metadata_SU_COD",
            "SU_COD_ID",
            "SU_COD_PositedAt",
            "SU_COD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_COD_ID"
        FROM
            public."SU_COD_Subject_Code_Posit" p
        WHERE
            p."SU_COD_SU_ID" = NEW."SU_COD_SU_ID"
        AND
            NOT public."eq_SU_COD_Subject_Code"(p."SU_COD_Subject_Code", NEW."SU_COD_Subject_Code")
        AND
            coalesce((
                SELECT
                    a."SU_COD_Reliability" = 1
                FROM
                    public."SU_COD_Subject_Code_Annex" a
                WHERE
                    a."SU_COD_ID" = p."SU_COD_ID"
                AND
                    a."SU_COD_PositedAt" <= _positing
                ORDER BY
                    a."SU_COD_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_COD_Subject_Code_Annex" (
            "Metadata_SU_COD",
            "SU_COD_ID",
            "SU_COD_PositedAt",
            "SU_COD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_COD_Subject_Code_Posit" (
            "SU_COD_SU_ID",
            "SU_COD_Subject_Code"
        )
        VALUES (
            NEW."SU_COD_SU_ID",
            NEW."SU_COD_Subject_Code"
        )
        RETURNING "SU_COD_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_COD_Subject_Code_Annex" (
        "Metadata_SU_COD",
        "SU_COD_ID",
        "SU_COD_PositedAt",
        "SU_COD_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_COD", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_COD_Subject_Code" ON public."SU_COD_Subject_Code";
CREATE TRIGGER "it_SU_COD_Subject_Code"
INSTEAD OF INSERT ON public."SU_COD_Subject_Code"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_COD_Subject_Code"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_GRD_Subject_Grade tells whether two values of SU_GRD_Subject_Grade are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_GRD_Subject_Grade"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_GRD_Subject_Grade instead of INSERT trigger on SU_GRD_Subject_Grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_GRD_Subject_Grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_GRD_PositedAt", _now);
    _reliability := coalesce(NEW."SU_GRD_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_GRD_ID"
    INTO
        _posit
    FROM
        public."SU_GRD_Subject_Grade_Posit" p
    WHERE
        p."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
    AND
        public."eq_SU_GRD_Subject_Grade"(p."SU_GRD_GRD_ID", NEW."SU_GRD_GRD_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade_Annex" a
        WHERE
            a."SU_GRD_ID" = _posit
        AND
            a."SU_GRD_PositedAt" = _positing
        AND
            a."SU_GRD_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_GRD_Subject_Grade for: %', concat_ws(', ', NEW."SU_GRD_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade_Posit" p
        JOIN
            public."SU_GRD_Subject_Grade_Annex" a
        ON
            a."SU_GRD_ID" = p."SU_GRD_ID"
        WHERE
            p."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
        AND
            NOT public."eq_SU_GRD_Subject_Grade"(p."SU_GRD_GRD_ID", NEW."SU_GRD_GRD_ID")
        AND
            a."SU_GRD_PositedAt" = _positing
        AND
            a."SU_GRD_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_GRD_Subject_Grade for: %', concat_ws(', ', NEW."SU_GRD_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_GRD_Subject_Grade_Annex" a
        WHERE
            a."SU_GRD_ID" = _posit
        AND
            a."SU_GRD_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_GRD_Reliability" = 1
            FROM
                public."SU_GRD_Subject_Grade_Annex" a
            WHERE
                a."SU_GRD_ID" = _posit
            AND
                a."SU_GRD_PositedAt" <= _positing
            ORDER BY
                a."SU_GRD_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
            "Metadata_SU_GRD",
            "SU_GRD_ID",
            "SU_GRD_PositedAt",
            "SU_GRD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_GRD_ID"
        FROM
            public."SU_GRD_Subject_Grade_Posit" p
        WHERE
            p."SU_GRD_SU_ID" = NEW."SU_GRD_SU_ID"
        AND
            NOT public."eq_SU_GRD_Subject_Grade"(p."SU_GRD_GRD_ID", NEW."SU_GRD_GRD_ID")
        AND
            coalesce((
                SELECT
                    a."SU_GRD_Reliability" = 1
                FROM
                    public."SU_GRD_Subject_Grade_Annex" a
                WHERE
                    a."SU_GRD_ID" = p."SU_GRD_ID"
                AND
                    a."SU_GRD_PositedAt" <= _positing
                ORDER BY
                    a."SU_GRD_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
            "Metadata_SU_GRD",
            "SU_GRD_ID",
            "SU_GRD_PositedAt",
            "SU_GRD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_GRD_Subject_Grade_Posit" (
            "SU_GRD_SU_ID",
            "SU_GRD_GRD_ID"
        )
        VALUES (
            NEW."SU_GRD_SU_ID",
            NEW."SU_GRD_GRD_ID"
        )
        RETURNING "SU_GRD_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
        "Metadata_SU_GRD",
        "SU_GRD_ID",
        "SU_GRD_PositedAt",
        "SU_GRD_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_GRD", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_GRD_Subject_Grade" ON public."SU_GRD_Subject_Grade";
CREATE TRIGGER "it_SU_GRD_Subject_Grade"
INSTEAD OF INSERT ON public."SU_GRD_Subject_Grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_GRD_Subject_Grade"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_NOT_Subject_Note tells whether two values of SU_NOT_Subject_Note are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_NOT_Subject_Note"(
    l text,
    r text
)
RETURNS boolean
AS
$$
    SELECT md5(l::text) = md5(r::text)
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_NOT_Subject_Note instead of INSERT trigger on SU_NOT_Subject_Note
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_NOT_Subject_Note"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_NOT_PositedAt", _now);
    _reliability := coalesce(NEW."SU_NOT_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."SU_NOT_ID"
    INTO
        _posit
    FROM
        public."SU_NOT_Subject_Note_Posit" p
    WHERE
        p."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
    AND
        public."eq_SU_NOT_Subject_Note"(p."SU_NOT_Subject_Note", NEW."SU_NOT_Subject_Note")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note_Annex" a
        WHERE
            a."SU_NOT_ID" = _posit
        AND
            a."SU_NOT_PositedAt" = _positing
        AND
            a."SU_NOT_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NOT_Subject_Note for: %', concat_ws(', ', NEW."SU_NOT_SU_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note_Posit" p
        JOIN
            public."SU_NOT_Subject_Note_Annex" a
        ON
            a."SU_NOT_ID" = p."SU_NOT_ID"
        WHERE
            p."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
        AND
            NOT public."eq_SU_NOT_Subject_Note"(p."SU_NOT_Subject_Note", NEW."SU_NOT_Subject_Note")
        AND
            a."SU_NOT_PositedAt" = _positing
        AND
            a."SU_NOT_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_NOT_Subject_Note for: %', concat_ws(', ', NEW."SU_NOT_SU_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_NOT_Subject_Note_Annex" a
        WHERE
            a."SU_NOT_ID" = _posit
        AND
            a."SU_NOT_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_NOT_Reliability" = 1
            FROM
                public."SU_NOT_Subject_Note_Annex" a
            WHERE
                a."SU_NOT_ID" = _posit
            AND
                a."SU_NOT_PositedAt" <= _positing
            ORDER BY
                a."SU_NOT_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_NOT_Subject_Note_Annex" (
            "Metadata_SU_NOT",
            "SU_NOT_ID",
            "SU_NOT_PositedAt",
            "SU_NOT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_NOT_ID"
        FROM
            public."SU_NOT_Subject_Note_Posit" p
        WHERE
            p."SU_NOT_SU_ID" = NEW."SU_NOT_SU_ID"
        AND
            NOT public."eq_SU_NOT_Subject_Note"(p."SU_NOT_Subject_Note", NEW."SU_NOT_Subject_Note")
        AND
            coalesce((
                SELECT
                    a."SU_NOT_Reliability" = 1
                FROM
                    public."SU_NOT_Subject_Note_Annex" a
                WHERE
                    a."SU_NOT_ID" = p."SU_NOT_ID"
                AND
                    a."SU_NOT_PositedAt" <= _positing
                ORDER BY
                    a."SU_NOT_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_NOT_Subject_Note_Annex" (
            "Metadata_SU_NOT",
            "SU_NOT_ID",
            "SU_NOT_PositedAt",
            "SU_NOT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_NOT_Subject_Note_Posit" (
            "SU_NOT_SU_ID",
            "SU_NOT_Subject_Note"
        )
        VALUES (
            NEW."SU_NOT_SU_ID",
            NEW."SU_NOT_Subject_Note"
        )
        RETURNING "SU_NOT_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_NOT_Subject_Note_Annex" (
        "Metadata_SU_NOT",
        "SU_NOT_ID",
        "SU_NOT_PositedAt",
        "SU_NOT_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_NOT", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_NOT_Subject_Note" ON public."SU_NOT_Subject_Note";
CREATE TRIGGER "it_SU_NOT_Subject_Note"
INSTEAD OF INSERT ON public."SU_NOT_Subject_Note"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_NOT_Subject_Note"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TTL_Subject_Title tells whether two values of SU_TTL_Subject_Title are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_TTL_Subject_Title"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TTL_Subject_Title instead of INSERT trigger on SU_TTL_Subject_Title
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TTL_Subject_Title"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_TTL_PositedAt", _now);
    _reliability := coalesce(NEW."SU_TTL_Reliability", 1);
    _changing := coalesce(NEW."SU_TTL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_TTL_ID"
    INTO
        _posit
    FROM
        public."SU_TTL_Subject_Title_Posit" p
    WHERE
        p."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
    AND
        p."SU_TTL_ChangedAt" = _changing
    AND
        public."eq_SU_TTL_Subject_Title"(p."SU_TTL_Subject_Title", NEW."SU_TTL_Subject_Title")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title_Annex" a
        WHERE
            a."SU_TTL_ID" = _posit
        AND
            a."SU_TTL_PositedAt" = _positing
        AND
            a."SU_TTL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TTL_Subject_Title for: %', concat_ws(', ', NEW."SU_TTL_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title_Posit" p
        JOIN
            public."SU_TTL_Subject_Title_Annex" a
        ON
            a."SU_TTL_ID" = p."SU_TTL_ID"
        WHERE
            p."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            p."SU_TTL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TTL_Subject_Title"(p."SU_TTL_Subject_Title", NEW."SU_TTL_Subject_Title")
        AND
            a."SU_TTL_PositedAt" = _positing
        AND
            a."SU_TTL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TTL_Subject_Title for: %', concat_ws(', ', NEW."SU_TTL_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TTL_Subject_Title_Annex" a
        WHERE
            a."SU_TTL_ID" = _posit
        AND
            a."SU_TTL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_TTL_Reliability" = 1
            FROM
                public."SU_TTL_Subject_Title_Annex" a
            WHERE
                a."SU_TTL_ID" = _posit
            AND
                a."SU_TTL_PositedAt" <= _positing
            ORDER BY
                a."SU_TTL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_TTL_Subject_Title_Annex" (
            "Metadata_SU_TTL",
            "SU_TTL_ID",
            "SU_TTL_PositedAt",
            "SU_TTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_TTL_ID"
        FROM
            public."SU_TTL_Subject_Title_Posit" p
        WHERE
            p."SU_TTL_SU_ID" = NEW."SU_TTL_SU_ID"
        AND
            p."SU_TTL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TTL_Subject_Title"(p."SU_TTL_Subject_Title", NEW."SU_TTL_Subject_Title")
        AND
            coalesce((
                SELECT
                    a."SU_TTL_Reliability" = 1
                FROM
                    public."SU_TTL_Subject_Title_Annex" a
                WHERE
                    a."SU_TTL_ID" = p."SU_TTL_ID"
                AND
                    a."SU_TTL_PositedAt" <= _positing
                ORDER BY
                    a."SU_TTL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_TTL_Subject_Title_Annex" (
            "Metadata_SU_TTL",
            "SU_TTL_ID",
            "SU_TTL_PositedAt",
            "SU_TTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_TTL_Subject_Title_Posit" (
            "SU_TTL_SU_ID",
            "SU_TTL_ChangedAt",
            "SU_TTL_Subject_Title"
        )
        VALUES (
            NEW."SU_TTL_SU_ID",
            _changing,
            NEW."SU_TTL_Subject_Title"
        )
        RETURNING "SU_TTL_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_TTL_Subject_Title_Annex" (
        "Metadata_SU_TTL",
        "SU_TTL_ID",
        "SU_TTL_PositedAt",
        "SU_TTL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_TTL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TTL_Subject_Title" ON public."SU_TTL_Subject_Title";
CREATE TRIGGER "it_SU_TTL_Subject_Title"
INSTEAD OF INSERT ON public."SU_TTL_Subject_Title"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TTL_Subject_Title"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_STA_Subject_State tells whether two values of SU_STA_Subject_State are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_STA_Subject_State"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_STA_Subject_State instead of INSERT trigger on SU_STA_Subject_State
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_STA_Subject_State"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_STA_PositedAt", _now);
    _reliability := coalesce(NEW."SU_STA_Reliability", 1);
    _changing := coalesce(NEW."SU_STA_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_STA_ID"
    INTO
        _posit
    FROM
        public."SU_STA_Subject_State_Posit" p
    WHERE
        p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
    AND
        p."SU_STA_ChangedAt" = _changing
    AND
        public."eq_SU_STA_Subject_State"(p."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State_Annex" a
        WHERE
            a."SU_STA_ID" = _posit
        AND
            a."SU_STA_PositedAt" = _positing
        AND
            a."SU_STA_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State_Posit" p
        JOIN
            public."SU_STA_Subject_State_Annex" a
        ON
            a."SU_STA_ID" = p."SU_STA_ID"
        WHERE
            p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            p."SU_STA_ChangedAt" = _changing
        AND
            NOT public."eq_SU_STA_Subject_State"(p."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
        AND
            a."SU_STA_PositedAt" = _positing
        AND
            a."SU_STA_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_STA_Subject_State_Annex" a
        WHERE
            a."SU_STA_ID" = _posit
        AND
            a."SU_STA_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_STA_Reliability" = 1
            FROM
                public."SU_STA_Subject_State_Annex" a
            WHERE
                a."SU_STA_ID" = _posit
            AND
                a."SU_STA_PositedAt" <= _positing
            ORDER BY
                a."SU_STA_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_STA_Subject_State_Annex" (
            "Metadata_SU_STA",
            "SU_STA_ID",
            "SU_STA_PositedAt",
            "SU_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_STA_ID"
        FROM
            public."SU_STA_Subject_State_Posit" p
        WHERE
            p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
        AND
            p."SU_STA_ChangedAt" = _changing
        AND
            NOT public."eq_SU_STA_Subject_State"(p."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
        AND
            coalesce((
                SELECT
                    a."SU_STA_Reliability" = 1
                FROM
                    public."SU_STA_Subject_State_Annex" a
                WHERE
                    a."SU_STA_ID" = p."SU_STA_ID"
                AND
                    a."SU_STA_PositedAt" <= _positing
                ORDER BY
                    a."SU_STA_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_STA_Subject_State_Annex" (
            "Metadata_SU_STA",
            "SU_STA_ID",
            "SU_STA_PositedAt",
            "SU_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_STA_Subject_State"
            FROM
                public."SU_STA_Subject_State_Posit" p
            WHERE
                p."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
            AND
                p."SU_STA_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."SU_STA_Reliability" = 1
                    FROM
                        public."SU_STA_Subject_State_Annex" a
                    WHERE
                        a."SU_STA_ID" = p."SU_STA_ID"
                    AND
                        a."SU_STA_PositedAt" <= _positing
                    ORDER BY
                        a."SU_STA_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."SU_STA_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_SU_STA_Subject_State"(pre."SU_STA_Subject_State", NEW."SU_STA_Subject_State")
    ) THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", _changing, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."SU_STA_ID"
    INTO
        _following
    FROM
        public."SU_STA_Subject_State_Posit" f
    WHERE
        f."SU_STA_SU_ID" = NEW."SU_STA_SU_ID"
    AND
        f."SU_STA_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."SU_STA_Reliability" = 1
            FROM
                public."SU_STA_Subject_State_Annex" a
            WHERE
                a."SU_STA_ID" = f."SU_STA_ID"
            AND
                a."SU_STA_PositedAt" <= _positing
            ORDER BY
                a."SU_STA_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."SU_STA_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_SU_STA_Subject_State"((
        SELECT x."SU_STA_Subject_State" FROM public."SU_STA_Subject_State_Posit" x WHERE x."SU_STA_ID" = _following
    ), NEW."SU_STA_Subject_State") THEN
        RAISE EXCEPTION 'Restatement in SU_STA_Subject_State for: %', concat_ws(', ', NEW."SU_STA_SU_ID", _changing, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_STA_Subject_State_Posit" (
            "SU_STA_SU_ID",
            "SU_STA_ChangedAt",
            "SU_STA_Subject_State"
        )
        VALUES (
            NEW."SU_STA_SU_ID",
            _changing,
            NEW."SU_STA_Subject_State"
        )
        RETURNING "SU_STA_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_STA_Subject_State_Annex" (
        "Metadata_SU_STA",
        "SU_STA_ID",
        "SU_STA_PositedAt",
        "SU_STA_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_STA", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_STA_Subject_State" ON public."SU_STA_Subject_State";
CREATE TRIGGER "it_SU_STA_Subject_State"
INSTEAD OF INSERT ON public."SU_STA_Subject_State"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_STA_Subject_State"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LBL_Subject_Label tells whether two values of SU_LBL_Subject_Label are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_LBL_Subject_Label"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LBL_Subject_Label instead of INSERT trigger on SU_LBL_Subject_Label
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LBL_Subject_Label"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_LBL_PositedAt", _now);
    _reliability := coalesce(NEW."SU_LBL_Reliability", 1);
    _changing := coalesce(NEW."SU_LBL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_LBL_ID"
    INTO
        _posit
    FROM
        public."SU_LBL_Subject_Label_Posit" p
    WHERE
        p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
    AND
        p."SU_LBL_ChangedAt" = _changing
    AND
        public."eq_SU_LBL_Subject_Label"(p."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label_Annex" a
        WHERE
            a."SU_LBL_ID" = _posit
        AND
            a."SU_LBL_PositedAt" = _positing
        AND
            a."SU_LBL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LBL_Subject_Label for: %', concat_ws(', ', NEW."SU_LBL_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label_Posit" p
        JOIN
            public."SU_LBL_Subject_Label_Annex" a
        ON
            a."SU_LBL_ID" = p."SU_LBL_ID"
        WHERE
            p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            p."SU_LBL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LBL_Subject_Label"(p."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
        AND
            a."SU_LBL_PositedAt" = _positing
        AND
            a."SU_LBL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LBL_Subject_Label for: %', concat_ws(', ', NEW."SU_LBL_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LBL_Subject_Label_Annex" a
        WHERE
            a."SU_LBL_ID" = _posit
        AND
            a."SU_LBL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_LBL_Reliability" = 1
            FROM
                public."SU_LBL_Subject_Label_Annex" a
            WHERE
                a."SU_LBL_ID" = _posit
            AND
                a."SU_LBL_PositedAt" <= _positing
            ORDER BY
                a."SU_LBL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_LBL_Subject_Label_Annex" (
            "Metadata_SU_LBL",
            "SU_LBL_ID",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_LBL_ID"
        FROM
            public."SU_LBL_Subject_Label_Posit" p
        WHERE
            p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
        AND
            p."SU_LBL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LBL_Subject_Label"(p."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
        AND
            coalesce((
                SELECT
                    a."SU_LBL_Reliability" = 1
                FROM
                    public."SU_LBL_Subject_Label_Annex" a
                WHERE
                    a."SU_LBL_ID" = p."SU_LBL_ID"
                AND
                    a."SU_LBL_PositedAt" <= _positing
                ORDER BY
                    a."SU_LBL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_LBL_Subject_Label_Annex" (
            "Metadata_SU_LBL",
            "SU_LBL_ID",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_LBL_Subject_Label"
            FROM
                public."SU_LBL_Subject_Label_Posit" p
            WHERE
                p."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
            AND
                p."SU_LBL_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."SU_LBL_Reliability" = 1
                    FROM
                        public."SU_LBL_Subject_Label_Annex" a
                    WHERE
                        a."SU_LBL_ID" = p."SU_LBL_ID"
                    AND
                        a."SU_LBL_PositedAt" <= _positing
                    ORDER BY
                        a."SU_LBL_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."SU_LBL_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_SU_LBL_Subject_Label"(pre."SU_LBL_Subject_Label", NEW."SU_LBL_Subject_Label")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."SU_LBL_ID"
    INTO
        _following
    FROM
        public."SU_LBL_Subject_Label_Posit" f
    WHERE
        f."SU_LBL_SU_ID" = NEW."SU_LBL_SU_ID"
    AND
        f."SU_LBL_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."SU_LBL_Reliability" = 1
            FROM
                public."SU_LBL_Subject_Label_Annex" a
            WHERE
                a."SU_LBL_ID" = f."SU_LBL_ID"
            AND
                a."SU_LBL_PositedAt" <= _positing
            ORDER BY
                a."SU_LBL_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."SU_LBL_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_SU_LBL_Subject_Label"((
        SELECT x."SU_LBL_Subject_Label" FROM public."SU_LBL_Subject_Label_Posit" x WHERE x."SU_LBL_ID" = _following
    ), NEW."SU_LBL_Subject_Label") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO public."SU_LBL_Subject_Label_Annex" (
            "Metadata_SU_LBL",
            "SU_LBL_ID",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", 0),
            _following,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_LBL_Subject_Label_Posit" (
            "SU_LBL_SU_ID",
            "SU_LBL_ChangedAt",
            "SU_LBL_Subject_Label"
        )
        VALUES (
            NEW."SU_LBL_SU_ID",
            _changing,
            NEW."SU_LBL_Subject_Label"
        )
        RETURNING "SU_LBL_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_LBL_Subject_Label_Annex" (
        "Metadata_SU_LBL",
        "SU_LBL_ID",
        "SU_LBL_PositedAt",
        "SU_LBL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_LBL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LBL_Subject_Label" ON public."SU_LBL_Subject_Label";
CREATE TRIGGER "it_SU_LBL_Subject_Label"
INSTEAD OF INSERT ON public."SU_LBL_Subject_Label"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LBL_Subject_Label"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TAG_Subject_Tag tells whether two values of SU_TAG_Subject_Tag are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_TAG_Subject_Tag"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TAG_Subject_Tag instead of INSERT trigger on SU_TAG_Subject_Tag
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TAG_Subject_Tag"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_TAG_PositedAt", _now);
    _reliability := coalesce(NEW."SU_TAG_Reliability", 1);
    _changing := coalesce(NEW."SU_TAG_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_TAG_ID"
    INTO
        _posit
    FROM
        public."SU_TAG_Subject_Tag_Posit" p
    WHERE
        p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
    AND
        p."SU_TAG_ChangedAt" = _changing
    AND
        public."eq_SU_TAG_Subject_Tag"(p."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag_Annex" a
        WHERE
            a."SU_TAG_ID" = _posit
        AND
            a."SU_TAG_PositedAt" = _positing
        AND
            a."SU_TAG_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TAG_Subject_Tag for: %', concat_ws(', ', NEW."SU_TAG_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag_Posit" p
        JOIN
            public."SU_TAG_Subject_Tag_Annex" a
        ON
            a."SU_TAG_ID" = p."SU_TAG_ID"
        WHERE
            p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            p."SU_TAG_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TAG_Subject_Tag"(p."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
        AND
            a."SU_TAG_PositedAt" = _positing
        AND
            a."SU_TAG_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TAG_Subject_Tag for: %', concat_ws(', ', NEW."SU_TAG_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TAG_Subject_Tag_Annex" a
        WHERE
            a."SU_TAG_ID" = _posit
        AND
            a."SU_TAG_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_TAG_Reliability" = 1
            FROM
                public."SU_TAG_Subject_Tag_Annex" a
            WHERE
                a."SU_TAG_ID" = _posit
            AND
                a."SU_TAG_PositedAt" <= _positing
            ORDER BY
                a."SU_TAG_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
            "Metadata_SU_TAG",
            "SU_TAG_ID",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_TAG_ID"
        FROM
            public."SU_TAG_Subject_Tag_Posit" p
        WHERE
            p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
        AND
            p."SU_TAG_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TAG_Subject_Tag"(p."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
        AND
            coalesce((
                SELECT
                    a."SU_TAG_Reliability" = 1
                FROM
                    public."SU_TAG_Subject_Tag_Annex" a
                WHERE
                    a."SU_TAG_ID" = p."SU_TAG_ID"
                AND
                    a."SU_TAG_PositedAt" <= _positing
                ORDER BY
                    a."SU_TAG_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
            "Metadata_SU_TAG",
            "SU_TAG_ID",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same value as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_TAG_Subject_Tag"
            FROM
                public."SU_TAG_Subject_Tag_Posit" p
            WHERE
                p."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
            AND
                p."SU_TAG_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."SU_TAG_Reliability" = 1
                    FROM
                        public."SU_TAG_Subject_Tag_Annex" a
                    WHERE
                        a."SU_TAG_ID" = p."SU_TAG_ID"
                    AND
                        a."SU_TAG_PositedAt" <= _positing
                    ORDER BY
                        a."SU_TAG_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."SU_TAG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            public."eq_SU_TAG_Subject_Tag"(pre."SU_TAG_Subject_Tag", NEW."SU_TAG_Subject_Tag")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."SU_TAG_ID"
    INTO
        _following
    FROM
        public."SU_TAG_Subject_Tag_Posit" f
    WHERE
        f."SU_TAG_SU_ID" = NEW."SU_TAG_SU_ID"
    AND
        f."SU_TAG_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."SU_TAG_Reliability" = 1
            FROM
                public."SU_TAG_Subject_Tag_Annex" a
            WHERE
                a."SU_TAG_ID" = f."SU_TAG_ID"
            AND
                a."SU_TAG_PositedAt" <= _positing
            ORDER BY
                a."SU_TAG_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."SU_TAG_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND public."eq_SU_TAG_Subject_Tag"((
        SELECT x."SU_TAG_Subject_Tag" FROM public."SU_TAG_Subject_Tag_Posit" x WHERE x."SU_TAG_ID" = _following
    ), NEW."SU_TAG_Subject_Tag") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
            "Metadata_SU_TAG",
            "SU_TAG_ID",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", 0),
            _following,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_TAG_Subject_Tag_Posit" (
            "SU_TAG_SU_ID",
            "SU_TAG_ChangedAt",
            "SU_TAG_Subject_Tag"
        )
        VALUES (
            NEW."SU_TAG_SU_ID",
            _changing,
            NEW."SU_TAG_Subject_Tag"
        )
        RETURNING "SU_TAG_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
        "Metadata_SU_TAG",
        "SU_TAG_ID",
        "SU_TAG_PositedAt",
        "SU_TAG_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_TAG", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TAG_Subject_Tag" ON public."SU_TAG_Subject_Tag";
CREATE TRIGGER "it_SU_TAG_Subject_Tag"
INSTEAD OF INSERT ON public."SU_TAG_Subject_Tag"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TAG_Subject_Tag"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_LVL_Subject_Level tells whether two values of SU_LVL_Subject_Level are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_LVL_Subject_Level"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_LVL_Subject_Level instead of INSERT trigger on SU_LVL_Subject_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_LVL_Subject_Level"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_LVL_PositedAt", _now);
    _reliability := coalesce(NEW."SU_LVL_Reliability", 1);
    _changing := coalesce(NEW."SU_LVL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_LVL_ID"
    INTO
        _posit
    FROM
        public."SU_LVL_Subject_Level_Posit" p
    WHERE
        p."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
    AND
        p."SU_LVL_ChangedAt" = _changing
    AND
        public."eq_SU_LVL_Subject_Level"(p."SU_LVL_GRD_ID", NEW."SU_LVL_GRD_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level_Annex" a
        WHERE
            a."SU_LVL_ID" = _posit
        AND
            a."SU_LVL_PositedAt" = _positing
        AND
            a."SU_LVL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LVL_Subject_Level for: %', concat_ws(', ', NEW."SU_LVL_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level_Posit" p
        JOIN
            public."SU_LVL_Subject_Level_Annex" a
        ON
            a."SU_LVL_ID" = p."SU_LVL_ID"
        WHERE
            p."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            p."SU_LVL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LVL_Subject_Level"(p."SU_LVL_GRD_ID", NEW."SU_LVL_GRD_ID")
        AND
            a."SU_LVL_PositedAt" = _positing
        AND
            a."SU_LVL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_LVL_Subject_Level for: %', concat_ws(', ', NEW."SU_LVL_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_LVL_Subject_Level_Annex" a
        WHERE
            a."SU_LVL_ID" = _posit
        AND
            a."SU_LVL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_LVL_Reliability" = 1
            FROM
                public."SU_LVL_Subject_Level_Annex" a
            WHERE
                a."SU_LVL_ID" = _posit
            AND
                a."SU_LVL_PositedAt" <= _positing
            ORDER BY
                a."SU_LVL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_LVL_Subject_Level_Annex" (
            "Metadata_SU_LVL",
            "SU_LVL_ID",
            "SU_LVL_PositedAt",
            "SU_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_LVL_ID"
        FROM
            public."SU_LVL_Subject_Level_Posit" p
        WHERE
            p."SU_LVL_SU_ID" = NEW."SU_LVL_SU_ID"
        AND
            p."SU_LVL_ChangedAt" = _changing
        AND
            NOT public."eq_SU_LVL_Subject_Level"(p."SU_LVL_GRD_ID", NEW."SU_LVL_GRD_ID")
        AND
            coalesce((
                SELECT
                    a."SU_LVL_Reliability" = 1
                FROM
                    public."SU_LVL_Subject_Level_Annex" a
                WHERE
                    a."SU_LVL_ID" = p."SU_LVL_ID"
                AND
                    a."SU_LVL_PositedAt" <= _positing
                ORDER BY
                    a."SU_LVL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_LVL_Subject_Level_Annex" (
            "Metadata_SU_LVL",
            "SU_LVL_ID",
            "SU_LVL_PositedAt",
            "SU_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_LVL_Subject_Level_Posit" (
            "SU_LVL_SU_ID",
            "SU_LVL_ChangedAt",
            "SU_LVL_GRD_ID"
        )
        VALUES (
            NEW."SU_LVL_SU_ID",
            _changing,
            NEW."SU_LVL_GRD_ID"
        )
        RETURNING "SU_LVL_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_LVL_Subject_Level_Annex" (
        "Metadata_SU_LVL",
        "SU_LVL_ID",
        "SU_LVL_PositedAt",
        "SU_LVL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_LVL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_LVL_Subject_Level" ON public."SU_LVL_Subject_Level";
CREATE TRIGGER "it_SU_LVL_Subject_Level"
INSTEAD OF INSERT ON public."SU_LVL_Subject_Level"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_LVL_Subject_Level"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_TXT_Subject_Text tells whether two values of SU_TXT_Subject_Text are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_TXT_Subject_Text"(
    l text,
    r text
)
RETURNS boolean
AS
$$
    SELECT md5(l::text) = md5(r::text)
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_TXT_Subject_Text instead of INSERT trigger on SU_TXT_Subject_Text
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_TXT_Subject_Text"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_TXT_PositedAt", _now);
    _reliability := coalesce(NEW."SU_TXT_Reliability", 1);
    _changing := coalesce(NEW."SU_TXT_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_TXT_ID"
    INTO
        _posit
    FROM
        public."SU_TXT_Subject_Text_Posit" p
    WHERE
        p."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
    AND
        p."SU_TXT_ChangedAt" = _changing
    AND
        public."eq_SU_TXT_Subject_Text"(p."SU_TXT_Subject_Text", NEW."SU_TXT_Subject_Text")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text_Annex" a
        WHERE
            a."SU_TXT_ID" = _posit
        AND
            a."SU_TXT_PositedAt" = _positing
        AND
            a."SU_TXT_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TXT_Subject_Text for: %', concat_ws(', ', NEW."SU_TXT_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text_Posit" p
        JOIN
            public."SU_TXT_Subject_Text_Annex" a
        ON
            a."SU_TXT_ID" = p."SU_TXT_ID"
        WHERE
            p."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            p."SU_TXT_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TXT_Subject_Text"(p."SU_TXT_Subject_Text", NEW."SU_TXT_Subject_Text")
        AND
            a."SU_TXT_PositedAt" = _positing
        AND
            a."SU_TXT_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_TXT_Subject_Text for: %', concat_ws(', ', NEW."SU_TXT_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_TXT_Subject_Text_Annex" a
        WHERE
            a."SU_TXT_ID" = _posit
        AND
            a."SU_TXT_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_TXT_Reliability" = 1
            FROM
                public."SU_TXT_Subject_Text_Annex" a
            WHERE
                a."SU_TXT_ID" = _posit
            AND
                a."SU_TXT_PositedAt" <= _positing
            ORDER BY
                a."SU_TXT_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_TXT_Subject_Text_Annex" (
            "Metadata_SU_TXT",
            "SU_TXT_ID",
            "SU_TXT_PositedAt",
            "SU_TXT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_TXT_ID"
        FROM
            public."SU_TXT_Subject_Text_Posit" p
        WHERE
            p."SU_TXT_SU_ID" = NEW."SU_TXT_SU_ID"
        AND
            p."SU_TXT_ChangedAt" = _changing
        AND
            NOT public."eq_SU_TXT_Subject_Text"(p."SU_TXT_Subject_Text", NEW."SU_TXT_Subject_Text")
        AND
            coalesce((
                SELECT
                    a."SU_TXT_Reliability" = 1
                FROM
                    public."SU_TXT_Subject_Text_Annex" a
                WHERE
                    a."SU_TXT_ID" = p."SU_TXT_ID"
                AND
                    a."SU_TXT_PositedAt" <= _positing
                ORDER BY
                    a."SU_TXT_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_TXT_Subject_Text_Annex" (
            "Metadata_SU_TXT",
            "SU_TXT_ID",
            "SU_TXT_PositedAt",
            "SU_TXT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_TXT_Subject_Text_Posit" (
            "SU_TXT_SU_ID",
            "SU_TXT_ChangedAt",
            "SU_TXT_Subject_Text"
        )
        VALUES (
            NEW."SU_TXT_SU_ID",
            _changing,
            NEW."SU_TXT_Subject_Text"
        )
        RETURNING "SU_TXT_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_TXT_Subject_Text_Annex" (
        "Metadata_SU_TXT",
        "SU_TXT_ID",
        "SU_TXT_PositedAt",
        "SU_TXT_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_TXT", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_TXT_Subject_Text" ON public."SU_TXT_Subject_Text";
CREATE TRIGGER "it_SU_TXT_Subject_Text"
INSTEAD OF INSERT ON public."SU_TXT_Subject_Text"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_TXT_Subject_Text"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ASR_Subject_Assessment tells whether two values of SU_ASR_Subject_Assessment are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_ASR_Subject_Assessment"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ASR_Subject_Assessment instead of INSERT trigger on SU_ASR_Subject_Assessment
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ASR_Subject_Assessment"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_ASR_PositedAt", _now);
    _reliability := coalesce(NEW."SU_ASR_Reliability", 1);
    _changing := coalesce(NEW."SU_ASR_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_ASR_ID"
    INTO
        _posit
    FROM
        public."SU_ASR_Subject_Assessment_Posit" p
    WHERE
        p."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
    AND
        p."SU_ASR_ChangedAt" = _changing
    AND
        public."eq_SU_ASR_Subject_Assessment"(p."SU_ASR_Subject_Assessment", NEW."SU_ASR_Subject_Assessment")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment_Annex" a
        WHERE
            a."SU_ASR_ID" = _posit
        AND
            a."SU_ASR_PositedAt" = _positing
        AND
            a."SU_ASR_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ASR_Subject_Assessment for: %', concat_ws(', ', NEW."SU_ASR_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment_Posit" p
        JOIN
            public."SU_ASR_Subject_Assessment_Annex" a
        ON
            a."SU_ASR_ID" = p."SU_ASR_ID"
        WHERE
            p."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            p."SU_ASR_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ASR_Subject_Assessment"(p."SU_ASR_Subject_Assessment", NEW."SU_ASR_Subject_Assessment")
        AND
            a."SU_ASR_PositedAt" = _positing
        AND
            a."SU_ASR_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ASR_Subject_Assessment for: %', concat_ws(', ', NEW."SU_ASR_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ASR_Subject_Assessment_Annex" a
        WHERE
            a."SU_ASR_ID" = _posit
        AND
            a."SU_ASR_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_ASR_Reliability" = 1
            FROM
                public."SU_ASR_Subject_Assessment_Annex" a
            WHERE
                a."SU_ASR_ID" = _posit
            AND
                a."SU_ASR_PositedAt" <= _positing
            ORDER BY
                a."SU_ASR_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
            "Metadata_SU_ASR",
            "SU_ASR_ID",
            "SU_ASR_PositedAt",
            "SU_ASR_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    IF _posit IS NOT NULL AND coalesce((
        SELECT
            a."SU_ASR_Reliability" = 1
        FROM
            public."SU_ASR_Subject_Assessment_Annex" a
        WHERE
            a."SU_ASR_ID" = _posit
        AND
            a."SU_ASR_PositedAt" <= _positing
        ORDER BY
            a."SU_ASR_PositedAt" DESC
        LIMIT 1
    ), false) THEN
        RETURN NULL;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_ASR_ID"
        FROM
            public."SU_ASR_Subject_Assessment_Posit" p
        WHERE
            p."SU_ASR_SU_ID" = NEW."SU_ASR_SU_ID"
        AND
            p."SU_ASR_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ASR_Subject_Assessment"(p."SU_ASR_Subject_Assessment", NEW."SU_ASR_Subject_Assessment")
        AND
            coalesce((
                SELECT
                    a."SU_ASR_Reliability" = 1
                FROM
                    public."SU_ASR_Subject_Assessment_Annex" a
                WHERE
                    a."SU_ASR_ID" = p."SU_ASR_ID"
                AND
                    a."SU_ASR_PositedAt" <= _positing
                ORDER BY
                    a."SU_ASR_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
            "Metadata_SU_ASR",
            "SU_ASR_ID",
            "SU_ASR_PositedAt",
            "SU_ASR_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_ASR_Subject_Assessment_Posit" (
            "SU_ASR_SU_ID",
            "SU_ASR_ChangedAt",
            "SU_ASR_Subject_Assessment"
        )
        VALUES (
            NEW."SU_ASR_SU_ID",
            _changing,
            NEW."SU_ASR_Subject_Assessment"
        )
        RETURNING "SU_ASR_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
        "Metadata_SU_ASR",
        "SU_ASR_ID",
        "SU_ASR_PositedAt",
        "SU_ASR_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_ASR", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ASR_Subject_Assessment" ON public."SU_ASR_Subject_Assessment";
CREATE TRIGGER "it_SU_ASR_Subject_Assessment"
INSTEAD OF INSERT ON public."SU_ASR_Subject_Assessment"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ASR_Subject_Assessment"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_SU_ERS_Subject_Erasable tells whether two values of SU_ERS_Subject_Erasable are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_SU_ERS_Subject_Erasable"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_ERS_Subject_Erasable instead of INSERT trigger on SU_ERS_Subject_Erasable
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_ERS_Subject_Erasable"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_ERS_PositedAt", _now);
    _reliability := coalesce(NEW."SU_ERS_Reliability", 1);
    _changing := coalesce(NEW."SU_ERS_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_ERS_ID"
    INTO
        _posit
    FROM
        public."SU_ERS_Subject_Erasable_Posit" p
    WHERE
        p."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
    AND
        p."SU_ERS_ChangedAt" = _changing
    AND
        public."eq_SU_ERS_Subject_Erasable"(p."SU_ERS_Subject_Erasable", NEW."SU_ERS_Subject_Erasable")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable_Annex" a
        WHERE
            a."SU_ERS_ID" = _posit
        AND
            a."SU_ERS_PositedAt" = _positing
        AND
            a."SU_ERS_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ERS_Subject_Erasable for: %', concat_ws(', ', NEW."SU_ERS_SU_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable_Posit" p
        JOIN
            public."SU_ERS_Subject_Erasable_Annex" a
        ON
            a."SU_ERS_ID" = p."SU_ERS_ID"
        WHERE
            p."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            p."SU_ERS_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ERS_Subject_Erasable"(p."SU_ERS_Subject_Erasable", NEW."SU_ERS_Subject_Erasable")
        AND
            a."SU_ERS_PositedAt" = _positing
        AND
            a."SU_ERS_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_ERS_Subject_Erasable for: %', concat_ws(', ', NEW."SU_ERS_SU_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_ERS_Subject_Erasable_Annex" a
        WHERE
            a."SU_ERS_ID" = _posit
        AND
            a."SU_ERS_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."SU_ERS_Reliability" = 1
            FROM
                public."SU_ERS_Subject_Erasable_Annex" a
            WHERE
                a."SU_ERS_ID" = _posit
            AND
                a."SU_ERS_PositedAt" <= _positing
            ORDER BY
                a."SU_ERS_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
            "Metadata_SU_ERS",
            "SU_ERS_ID",
            "SU_ERS_PositedAt",
            "SU_ERS_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_ERS_ID"
        FROM
            public."SU_ERS_Subject_Erasable_Posit" p
        WHERE
            p."SU_ERS_SU_ID" = NEW."SU_ERS_SU_ID"
        AND
            p."SU_ERS_ChangedAt" = _changing
        AND
            NOT public."eq_SU_ERS_Subject_Erasable"(p."SU_ERS_Subject_Erasable", NEW."SU_ERS_Subject_Erasable")
        AND
            coalesce((
                SELECT
                    a."SU_ERS_Reliability" = 1
                FROM
                    public."SU_ERS_Subject_Erasable_Annex" a
                WHERE
                    a."SU_ERS_ID" = p."SU_ERS_ID"
                AND
                    a."SU_ERS_PositedAt" <= _positing
                ORDER BY
                    a."SU_ERS_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
            "Metadata_SU_ERS",
            "SU_ERS_ID",
            "SU_ERS_PositedAt",
            "SU_ERS_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_ERS_Subject_Erasable_Posit" (
            "SU_ERS_SU_ID",
            "SU_ERS_ChangedAt",
            "SU_ERS_Subject_Erasable"
        )
        VALUES (
            NEW."SU_ERS_SU_ID",
            _changing,
            NEW."SU_ERS_Subject_Erasable"
        )
        RETURNING "SU_ERS_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
        "Metadata_SU_ERS",
        "SU_ERS_ID",
        "SU_ERS_PositedAt",
        "SU_ERS_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_ERS", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_ERS_Subject_Erasable" ON public."SU_ERS_Subject_Erasable";
CREATE TRIGGER "it_SU_ERS_Subject_Erasable"
INSTEAD OF INSERT ON public."SU_ERS_Subject_Erasable"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_ERS_Subject_Erasable"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_OB_NAM_Object_Name tells whether two values of OB_NAM_Object_Name are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."eq_OB_NAM_Object_Name"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_NAM_Object_Name instead of INSERT trigger on OB_NAM_Object_Name
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_NAM_Object_Name"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."OB_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."OB_NAM_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."OB_NAM_ID"
    INTO
        _posit
    FROM
        public."OB_NAM_Object_Name_Posit" p
    WHERE
        p."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
    AND
        public."eq_OB_NAM_Object_Name"(p."OB_NAM_Object_Name", NEW."OB_NAM_Object_Name")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name_Annex" a
        WHERE
            a."OB_NAM_ID" = _posit
        AND
            a."OB_NAM_PositedAt" = _positing
        AND
            a."OB_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_NAM_Object_Name for: %', concat_ws(', ', NEW."OB_NAM_OB_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name_Posit" p
        JOIN
            public."OB_NAM_Object_Name_Annex" a
        ON
            a."OB_NAM_ID" = p."OB_NAM_ID"
        WHERE
            p."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
        AND
            NOT public."eq_OB_NAM_Object_Name"(p."OB_NAM_Object_Name", NEW."OB_NAM_Object_Name")
        AND
            a."OB_NAM_PositedAt" = _positing
        AND
            a."OB_NAM_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_NAM_Object_Name for: %', concat_ws(', ', NEW."OB_NAM_OB_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_NAM_Object_Name_Annex" a
        WHERE
            a."OB_NAM_ID" = _posit
        AND
            a."OB_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."OB_NAM_Reliability" = 1
            FROM
                public."OB_NAM_Object_Name_Annex" a
            WHERE
                a."OB_NAM_ID" = _posit
            AND
                a."OB_NAM_PositedAt" <= _positing
            ORDER BY
                a."OB_NAM_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."OB_NAM_Object_Name_Annex" (
            "Metadata_OB_NAM",
            "OB_NAM_ID",
            "OB_NAM_PositedAt",
            "OB_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already, at the positing time, is skipped unless the attribute is assertive
    -- an assertion corrects what is asserted at the positing time for the same entity (and changing time), when that has
    -- another value: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."OB_NAM_ID"
        FROM
            public."OB_NAM_Object_Name_Posit" p
        WHERE
            p."OB_NAM_OB_ID" = NEW."OB_NAM_OB_ID"
        AND
            NOT public."eq_OB_NAM_Object_Name"(p."OB_NAM_Object_Name", NEW."OB_NAM_Object_Name")
        AND
            coalesce((
                SELECT
                    a."OB_NAM_Reliability" = 1
                FROM
                    public."OB_NAM_Object_Name_Annex" a
                WHERE
                    a."OB_NAM_ID" = p."OB_NAM_ID"
                AND
                    a."OB_NAM_PositedAt" <= _positing
                ORDER BY
                    a."OB_NAM_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO public."OB_NAM_Object_Name_Annex" (
            "Metadata_OB_NAM",
            "OB_NAM_ID",
            "OB_NAM_PositedAt",
            "OB_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."OB_NAM_Object_Name_Posit" (
            "OB_NAM_OB_ID",
            "OB_NAM_Object_Name"
        )
        VALUES (
            NEW."OB_NAM_OB_ID",
            NEW."OB_NAM_Object_Name"
        )
        RETURNING "OB_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO public."OB_NAM_Object_Name_Annex" (
        "Metadata_OB_NAM",
        "OB_NAM_ID",
        "OB_NAM_PositedAt",
        "OB_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_OB_NAM", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_NAM_Object_Name" ON public."OB_NAM_Object_Name";
CREATE TRIGGER "it_OB_NAM_Object_Name"
INSTEAD OF INSERT ON public."OB_NAM_Object_Name"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_NAM_Object_Name"();
-- ANCHOR TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the assembled views of the attributes (whose triggers keep the
-- posit and annex tables) in a consistent way. Default values are used for some columns if not provided by the
-- corresponding SQL statements: the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the triggers of the attributes see to that).
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_Subject instead of INSERT trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
    _GRD smallint;
    _LVL smallint;
BEGIN
    _id := NEW."SU_ID";
    IF _id IS NULL THEN
        INSERT INTO public."SU_Subject" (
            "Metadata_SU"
        )
        VALUES (
            NEW."Metadata_SU"
        )
        RETURNING "SU_ID" INTO _id;
    END IF;
    IF NEW."SU_NAM_Subject_Name" IS NOT NULL THEN
        INSERT INTO public."SU_NAM_Subject_Name" (
            "Metadata_SU_NAM",
            "SU_NAM_SU_ID",
            "SU_NAM_Subject_Name",
            "SU_NAM_PositedAt",
            "SU_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NAM", NEW."Metadata_SU"),
            coalesce(NEW."SU_NAM_SU_ID", _id),
            NEW."SU_NAM_Subject_Name",
            coalesce(NEW."SU_NAM_PositedAt", _now),
            coalesce(NEW."SU_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_COD_Subject_Code" IS NOT NULL THEN
        INSERT INTO public."SU_COD_Subject_Code" (
            "Metadata_SU_COD",
            "SU_COD_SU_ID",
            "SU_COD_Subject_Code",
            "SU_COD_PositedAt",
            "SU_COD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_COD", NEW."Metadata_SU"),
            coalesce(NEW."SU_COD_SU_ID", _id),
            NEW."SU_COD_Subject_Code",
            coalesce(NEW."SU_COD_PositedAt", _now),
            coalesce(NEW."SU_COD_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _GRD := NEW."SU_GRD_GRD_ID";
    IF _GRD IS NULL AND NEW."SU_GRD_GRD_Grade" IS NOT NULL THEN
        SELECT
            k."GRD_ID"
        INTO
            _GRD
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."SU_GRD_GRD_Grade"
        LIMIT 1;
    END IF;
    IF _GRD IS NOT NULL THEN
        INSERT INTO public."SU_GRD_Subject_Grade" (
            "Metadata_SU_GRD",
            "SU_GRD_SU_ID",
            "SU_GRD_GRD_ID",
            "SU_GRD_PositedAt",
            "SU_GRD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_GRD", NEW."Metadata_SU"),
            coalesce(NEW."SU_GRD_SU_ID", _id),
            _GRD,
            coalesce(NEW."SU_GRD_PositedAt", _now),
            coalesce(NEW."SU_GRD_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_NOT_Subject_Note" IS NOT NULL THEN
        INSERT INTO public."SU_NOT_Subject_Note" (
            "Metadata_SU_NOT",
            "SU_NOT_SU_ID",
            "SU_NOT_Subject_Note",
            "SU_NOT_PositedAt",
            "SU_NOT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_NOT", NEW."Metadata_SU"),
            coalesce(NEW."SU_NOT_SU_ID", _id),
            NEW."SU_NOT_Subject_Note",
            coalesce(NEW."SU_NOT_PositedAt", _now),
            coalesce(NEW."SU_NOT_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_TTL_Subject_Title" IS NOT NULL THEN
        INSERT INTO public."SU_TTL_Subject_Title" (
            "Metadata_SU_TTL",
            "SU_TTL_SU_ID",
            "SU_TTL_Subject_Title",
            "SU_TTL_ChangedAt",
            "SU_TTL_PositedAt",
            "SU_TTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TTL", NEW."Metadata_SU"),
            coalesce(NEW."SU_TTL_SU_ID", _id),
            NEW."SU_TTL_Subject_Title",
            coalesce(NEW."SU_TTL_ChangedAt", _now),
            coalesce(NEW."SU_TTL_PositedAt", _now),
            coalesce(NEW."SU_TTL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_STA_Subject_State" IS NOT NULL THEN
        INSERT INTO public."SU_STA_Subject_State" (
            "Metadata_SU_STA",
            "SU_STA_SU_ID",
            "SU_STA_Subject_State",
            "SU_STA_ChangedAt",
            "SU_STA_PositedAt",
            "SU_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_STA", NEW."Metadata_SU"),
            coalesce(NEW."SU_STA_SU_ID", _id),
            NEW."SU_STA_Subject_State",
            coalesce(NEW."SU_STA_ChangedAt", _now),
            coalesce(NEW."SU_STA_PositedAt", _now),
            coalesce(NEW."SU_STA_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_LBL_Subject_Label" IS NOT NULL THEN
        INSERT INTO public."SU_LBL_Subject_Label" (
            "Metadata_SU_LBL",
            "SU_LBL_SU_ID",
            "SU_LBL_Subject_Label",
            "SU_LBL_ChangedAt",
            "SU_LBL_PositedAt",
            "SU_LBL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LBL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LBL_SU_ID", _id),
            NEW."SU_LBL_Subject_Label",
            coalesce(NEW."SU_LBL_ChangedAt", _now),
            coalesce(NEW."SU_LBL_PositedAt", _now),
            coalesce(NEW."SU_LBL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_TAG_Subject_Tag" IS NOT NULL THEN
        INSERT INTO public."SU_TAG_Subject_Tag" (
            "Metadata_SU_TAG",
            "SU_TAG_SU_ID",
            "SU_TAG_Subject_Tag",
            "SU_TAG_ChangedAt",
            "SU_TAG_PositedAt",
            "SU_TAG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TAG", NEW."Metadata_SU"),
            coalesce(NEW."SU_TAG_SU_ID", _id),
            NEW."SU_TAG_Subject_Tag",
            coalesce(NEW."SU_TAG_ChangedAt", _now),
            coalesce(NEW."SU_TAG_PositedAt", _now),
            coalesce(NEW."SU_TAG_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _LVL := NEW."SU_LVL_GRD_ID";
    IF _LVL IS NULL AND NEW."SU_LVL_GRD_Grade" IS NOT NULL THEN
        SELECT
            k."GRD_ID"
        INTO
            _LVL
        FROM
            public."GRD_Grade" k
        WHERE
            k."GRD_Grade" = NEW."SU_LVL_GRD_Grade"
        LIMIT 1;
    END IF;
    IF _LVL IS NOT NULL THEN
        INSERT INTO public."SU_LVL_Subject_Level" (
            "Metadata_SU_LVL",
            "SU_LVL_SU_ID",
            "SU_LVL_GRD_ID",
            "SU_LVL_ChangedAt",
            "SU_LVL_PositedAt",
            "SU_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_LVL", NEW."Metadata_SU"),
            coalesce(NEW."SU_LVL_SU_ID", _id),
            _LVL,
            coalesce(NEW."SU_LVL_ChangedAt", _now),
            coalesce(NEW."SU_LVL_PositedAt", _now),
            coalesce(NEW."SU_LVL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_TXT_Subject_Text" IS NOT NULL THEN
        INSERT INTO public."SU_TXT_Subject_Text" (
            "Metadata_SU_TXT",
            "SU_TXT_SU_ID",
            "SU_TXT_Subject_Text",
            "SU_TXT_ChangedAt",
            "SU_TXT_PositedAt",
            "SU_TXT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_TXT", NEW."Metadata_SU"),
            coalesce(NEW."SU_TXT_SU_ID", _id),
            NEW."SU_TXT_Subject_Text",
            coalesce(NEW."SU_TXT_ChangedAt", _now),
            coalesce(NEW."SU_TXT_PositedAt", _now),
            coalesce(NEW."SU_TXT_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL THEN
        INSERT INTO public."SU_ASR_Subject_Assessment" (
            "Metadata_SU_ASR",
            "SU_ASR_SU_ID",
            "SU_ASR_Subject_Assessment",
            "SU_ASR_ChangedAt",
            "SU_ASR_PositedAt",
            "SU_ASR_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ASR", NEW."Metadata_SU"),
            coalesce(NEW."SU_ASR_SU_ID", _id),
            NEW."SU_ASR_Subject_Assessment",
            coalesce(NEW."SU_ASR_ChangedAt", _now),
            coalesce(NEW."SU_ASR_PositedAt", _now),
            coalesce(NEW."SU_ASR_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL THEN
        INSERT INTO public."SU_ERS_Subject_Erasable" (
            "Metadata_SU_ERS",
            "SU_ERS_SU_ID",
            "SU_ERS_Subject_Erasable",
            "SU_ERS_ChangedAt",
            "SU_ERS_PositedAt",
            "SU_ERS_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_ERS", NEW."Metadata_SU"),
            coalesce(NEW."SU_ERS_SU_ID", _id),
            NEW."SU_ERS_Subject_Erasable",
            coalesce(NEW."SU_ERS_ChangedAt", _now),
            coalesce(NEW."SU_ERS_PositedAt", _now),
            coalesce(NEW."SU_ERS_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "it_lSU_Subject"
INSTEAD OF INSERT ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_Subject"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_Subject instead of UPDATE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _GRD smallint;
    _LVL smallint;
BEGIN
    IF NEW."SU_ID" IS DISTINCT FROM OLD."SU_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_ID" IS DISTINCT FROM OLD."SU_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column SU_NAM_ID is not updatable.';
    END IF;
    IF NEW."SU_NAM_SU_ID" IS DISTINCT FROM OLD."SU_NAM_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NAM_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_NAM_Subject_Name, and when it posits
    _reliability := CASE
        WHEN NEW."SU_NAM_Reliability" IS DISTINCT FROM OLD."SU_NAM_Reliability" THEN NEW."SU_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_NAM_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_NAM_PositedAt" IS DISTINCT FROM OLD."SU_NAM_PositedAt" THEN NEW."SU_NAM_PositedAt"
        ELSE _now
    END;
    IF NEW."SU_NAM_Subject_Name" IS DISTINCT FROM OLD."SU_NAM_Subject_Name"
    OR NEW."SU_NAM_PositedAt" IS DISTINCT FROM OLD."SU_NAM_PositedAt"
    OR NEW."SU_NAM_Reliability" IS DISTINCT FROM OLD."SU_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_NAM_Subject_Name" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_NAM_Subject_Name" IS NULL
            OR NEW."SU_NAM_PositedAt" IS DISTINCT FROM OLD."SU_NAM_PositedAt"
            OR OLD."SU_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_NAM_Subject_Name" <> NEW."SU_NAM_Subject_Name"
            THEN
                INSERT INTO public."SU_NAM_Subject_Name" (
                    "Metadata_SU_NAM",
                    "SU_NAM_SU_ID",
                    "SU_NAM_Subject_Name",
                    "SU_NAM_PositedAt",
                    "SU_NAM_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_NAM" IS NOT DISTINCT FROM OLD."Metadata_SU_NAM"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_NAM"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_NAM_SU_ID", NEW."SU_ID"),
                    NEW."SU_NAM_Subject_Name",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_NAM_Subject_Name" IS NULL AND OLD."SU_NAM_Subject_Name" IS NOT NULL THEN
            INSERT INTO public."SU_NAM_Subject_Name" (
                "Metadata_SU_NAM",
                "SU_NAM_SU_ID",
                "SU_NAM_Subject_Name",
                "SU_NAM_PositedAt",
                "SU_NAM_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_NAM" IS NOT DISTINCT FROM OLD."Metadata_SU_NAM"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_NAM"
                    END, NEW."Metadata_SU"),
                p."SU_NAM_SU_ID",
                p."SU_NAM_Subject_Name",
                _positing,
                0
            FROM
                public."SU_NAM_Subject_Name_Posit" p
            WHERE
                p."SU_NAM_ID" = OLD."SU_NAM_ID";
        END IF;
    END IF;
    IF NEW."SU_COD_ID" IS DISTINCT FROM OLD."SU_COD_ID" THEN
        RAISE EXCEPTION 'The identity column SU_COD_ID is not updatable.';
    END IF;
    IF NEW."SU_COD_SU_ID" IS DISTINCT FROM OLD."SU_COD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_COD_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_COD_Subject_Code, and when it posits
    _reliability := CASE
        WHEN NEW."SU_COD_Reliability" IS DISTINCT FROM OLD."SU_COD_Reliability" THEN NEW."SU_COD_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_COD_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_COD_PositedAt" IS DISTINCT FROM OLD."SU_COD_PositedAt" THEN NEW."SU_COD_PositedAt"
        ELSE _now
    END;
    IF NEW."SU_COD_Subject_Code" IS DISTINCT FROM OLD."SU_COD_Subject_Code"
    OR NEW."SU_COD_PositedAt" IS DISTINCT FROM OLD."SU_COD_PositedAt"
    OR NEW."SU_COD_Reliability" IS DISTINCT FROM OLD."SU_COD_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_COD_Subject_Code" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_COD_Subject_Code" IS NULL
            OR NEW."SU_COD_PositedAt" IS DISTINCT FROM OLD."SU_COD_PositedAt"
            OR OLD."SU_COD_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_COD_Subject_Code" <> NEW."SU_COD_Subject_Code"
            THEN
                INSERT INTO public."SU_COD_Subject_Code" (
                    "Metadata_SU_COD",
                    "SU_COD_SU_ID",
                    "SU_COD_Subject_Code",
                    "SU_COD_PositedAt",
                    "SU_COD_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_COD" IS NOT DISTINCT FROM OLD."Metadata_SU_COD"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_COD"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_COD_SU_ID", NEW."SU_ID"),
                    NEW."SU_COD_Subject_Code",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_COD_Subject_Code" IS NULL AND OLD."SU_COD_Subject_Code" IS NOT NULL THEN
            INSERT INTO public."SU_COD_Subject_Code" (
                "Metadata_SU_COD",
                "SU_COD_SU_ID",
                "SU_COD_Subject_Code",
                "SU_COD_PositedAt",
                "SU_COD_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_COD" IS NOT DISTINCT FROM OLD."Metadata_SU_COD"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_COD"
                    END, NEW."Metadata_SU"),
                p."SU_COD_SU_ID",
                p."SU_COD_Subject_Code",
                _positing,
                0
            FROM
                public."SU_COD_Subject_Code_Posit" p
            WHERE
                p."SU_COD_ID" = OLD."SU_COD_ID";
        END IF;
    END IF;
    IF NEW."SU_GRD_ID" IS DISTINCT FROM OLD."SU_GRD_ID" THEN
        RAISE EXCEPTION 'The identity column SU_GRD_ID is not updatable.';
    END IF;
    IF NEW."SU_GRD_SU_ID" IS DISTINCT FROM OLD."SU_GRD_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_GRD_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_GRD_Subject_Grade, and when it posits
    _reliability := CASE
        WHEN NEW."SU_GRD_Reliability" IS DISTINCT FROM OLD."SU_GRD_Reliability" THEN NEW."SU_GRD_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_GRD_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_GRD_PositedAt" IS DISTINCT FROM OLD."SU_GRD_PositedAt" THEN NEW."SU_GRD_PositedAt"
        ELSE _now
    END;
    _GRD := NEW."SU_GRD_GRD_ID";
    IF _GRD IS NOT DISTINCT FROM OLD."SU_GRD_GRD_ID" AND NEW."SU_GRD_GRD_Grade" IS DISTINCT FROM OLD."SU_GRD_GRD_Grade" THEN
        _GRD := NULL;
        IF NEW."SU_GRD_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _GRD
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."SU_GRD_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."SU_GRD_GRD_ID" IS DISTINCT FROM OLD."SU_GRD_GRD_ID"
    OR NEW."SU_GRD_GRD_Grade" IS DISTINCT FROM OLD."SU_GRD_GRD_Grade"
    OR NEW."SU_GRD_PositedAt" IS DISTINCT FROM OLD."SU_GRD_PositedAt"
    OR NEW."SU_GRD_Reliability" IS DISTINCT FROM OLD."SU_GRD_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _GRD IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_GRD_GRD_ID" IS NULL
            OR NEW."SU_GRD_PositedAt" IS DISTINCT FROM OLD."SU_GRD_PositedAt"
            OR OLD."SU_GRD_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_GRD_GRD_ID" <> _GRD
            THEN
                INSERT INTO public."SU_GRD_Subject_Grade" (
                    "Metadata_SU_GRD",
                    "SU_GRD_SU_ID",
                    "SU_GRD_GRD_ID",
                    "SU_GRD_PositedAt",
                    "SU_GRD_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_GRD" IS NOT DISTINCT FROM OLD."Metadata_SU_GRD"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_GRD"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_GRD_SU_ID", NEW."SU_ID"),
                    _GRD,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."SU_GRD_GRD_ID" IS NOT NULL AND (
            NEW."SU_GRD_GRD_ID" IS NULL OR (
                NEW."SU_GRD_GRD_ID" = OLD."SU_GRD_GRD_ID"
                AND NEW."SU_GRD_GRD_Grade" IS NULL AND OLD."SU_GRD_GRD_Grade" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."SU_GRD_Subject_Grade" (
                "Metadata_SU_GRD",
                "SU_GRD_SU_ID",
                "SU_GRD_GRD_ID",
                "SU_GRD_PositedAt",
                "SU_GRD_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_GRD" IS NOT DISTINCT FROM OLD."Metadata_SU_GRD"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_GRD"
                    END, NEW."Metadata_SU"),
                p."SU_GRD_SU_ID",
                p."SU_GRD_GRD_ID",
                _positing,
                0
            FROM
                public."SU_GRD_Subject_Grade_Posit" p
            WHERE
                p."SU_GRD_ID" = OLD."SU_GRD_ID";
        END IF;
    END IF;
    IF NEW."SU_NOT_ID" IS DISTINCT FROM OLD."SU_NOT_ID" THEN
        RAISE EXCEPTION 'The identity column SU_NOT_ID is not updatable.';
    END IF;
    IF NEW."SU_NOT_SU_ID" IS DISTINCT FROM OLD."SU_NOT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_NOT_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_NOT_Subject_Note, and when it posits
    _reliability := CASE
        WHEN NEW."SU_NOT_Reliability" IS DISTINCT FROM OLD."SU_NOT_Reliability" THEN NEW."SU_NOT_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_NOT_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_NOT_PositedAt" IS DISTINCT FROM OLD."SU_NOT_PositedAt" THEN NEW."SU_NOT_PositedAt"
        ELSE _now
    END;
    IF NEW."SU_NOT_Subject_Note" IS DISTINCT FROM OLD."SU_NOT_Subject_Note"
    OR NEW."SU_NOT_PositedAt" IS DISTINCT FROM OLD."SU_NOT_PositedAt"
    OR NEW."SU_NOT_Reliability" IS DISTINCT FROM OLD."SU_NOT_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_NOT_Subject_Note" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_NOT_Subject_Note" IS NULL
            OR NEW."SU_NOT_PositedAt" IS DISTINCT FROM OLD."SU_NOT_PositedAt"
            OR OLD."SU_NOT_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR md5(OLD."SU_NOT_Subject_Note"::text) <> md5(NEW."SU_NOT_Subject_Note"::text)
            THEN
                INSERT INTO public."SU_NOT_Subject_Note" (
                    "Metadata_SU_NOT",
                    "SU_NOT_SU_ID",
                    "SU_NOT_Subject_Note",
                    "SU_NOT_PositedAt",
                    "SU_NOT_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_NOT" IS NOT DISTINCT FROM OLD."Metadata_SU_NOT"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_NOT"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_NOT_SU_ID", NEW."SU_ID"),
                    NEW."SU_NOT_Subject_Note",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_NOT_Subject_Note" IS NULL AND OLD."SU_NOT_Subject_Note" IS NOT NULL THEN
            INSERT INTO public."SU_NOT_Subject_Note" (
                "Metadata_SU_NOT",
                "SU_NOT_SU_ID",
                "SU_NOT_Subject_Note",
                "SU_NOT_PositedAt",
                "SU_NOT_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_NOT" IS NOT DISTINCT FROM OLD."Metadata_SU_NOT"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_NOT"
                    END, NEW."Metadata_SU"),
                p."SU_NOT_SU_ID",
                p."SU_NOT_Subject_Note",
                _positing,
                0
            FROM
                public."SU_NOT_Subject_Note_Posit" p
            WHERE
                p."SU_NOT_ID" = OLD."SU_NOT_ID";
        END IF;
    END IF;
    IF NEW."SU_TTL_ID" IS DISTINCT FROM OLD."SU_TTL_ID" THEN
        RAISE EXCEPTION 'The identity column SU_TTL_ID is not updatable.';
    END IF;
    IF NEW."SU_TTL_SU_ID" IS DISTINCT FROM OLD."SU_TTL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TTL_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_TTL_Subject_Title, and when it posits
    _reliability := CASE
        WHEN NEW."SU_TTL_Reliability" IS DISTINCT FROM OLD."SU_TTL_Reliability" THEN NEW."SU_TTL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_TTL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_TTL_PositedAt" IS DISTINCT FROM OLD."SU_TTL_PositedAt" THEN NEW."SU_TTL_PositedAt"
        WHEN NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" AND NEW."SU_TTL_Subject_Title" IS NULL THEN NEW."SU_TTL_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_TTL_Subject_Title" IS DISTINCT FROM OLD."SU_TTL_Subject_Title"
    OR NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt"
    OR NEW."SU_TTL_PositedAt" IS DISTINCT FROM OLD."SU_TTL_PositedAt"
    OR NEW."SU_TTL_Reliability" IS DISTINCT FROM OLD."SU_TTL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_TTL_Subject_Title" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_TTL_Subject_Title" IS NULL
            OR NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt"
            OR NEW."SU_TTL_PositedAt" IS DISTINCT FROM OLD."SU_TTL_PositedAt"
            OR OLD."SU_TTL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_TTL_Subject_Title" <> NEW."SU_TTL_Subject_Title"
            THEN
                INSERT INTO public."SU_TTL_Subject_Title" (
                    "Metadata_SU_TTL",
                    "SU_TTL_SU_ID",
                    "SU_TTL_Subject_Title",
                    "SU_TTL_ChangedAt",
                    "SU_TTL_PositedAt",
                    "SU_TTL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_TTL" IS NOT DISTINCT FROM OLD."Metadata_SU_TTL"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_TTL"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_TTL_SU_ID", NEW."SU_ID"),
                    NEW."SU_TTL_Subject_Title",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_TTL_ChangedAt" IS DISTINCT FROM OLD."SU_TTL_ChangedAt" THEN NEW."SU_TTL_ChangedAt"
                        WHEN OLD."SU_TTL_Subject_Title" = NEW."SU_TTL_Subject_Title" THEN NEW."SU_TTL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_TTL_Subject_Title" IS NULL AND OLD."SU_TTL_Subject_Title" IS NOT NULL THEN
            INSERT INTO public."SU_TTL_Subject_Title" (
                "Metadata_SU_TTL",
                "SU_TTL_SU_ID",
                "SU_TTL_Subject_Title",
                "SU_TTL_ChangedAt",
                "SU_TTL_PositedAt",
                "SU_TTL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TTL" IS NOT DISTINCT FROM OLD."Metadata_SU_TTL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TTL"
                    END, NEW."Metadata_SU"),
                p."SU_TTL_SU_ID",
                p."SU_TTL_Subject_Title",
                p."SU_TTL_ChangedAt",
                _positing,
                0
            FROM
                public."SU_TTL_Subject_Title_Posit" p
            WHERE
                p."SU_TTL_ID" = OLD."SU_TTL_ID";
        END IF;
    END IF;
    IF NEW."SU_STA_ID" IS DISTINCT FROM OLD."SU_STA_ID" THEN
        RAISE EXCEPTION 'The identity column SU_STA_ID is not updatable.';
    END IF;
    IF NEW."SU_STA_SU_ID" IS DISTINCT FROM OLD."SU_STA_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_STA_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_STA_Subject_State, and when it posits
    _reliability := CASE
        WHEN NEW."SU_STA_Reliability" IS DISTINCT FROM OLD."SU_STA_Reliability" THEN NEW."SU_STA_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_STA_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_STA_PositedAt" IS DISTINCT FROM OLD."SU_STA_PositedAt" THEN NEW."SU_STA_PositedAt"
        WHEN NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" AND NEW."SU_STA_Subject_State" IS NULL THEN NEW."SU_STA_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_STA_Subject_State" IS DISTINCT FROM OLD."SU_STA_Subject_State"
    OR NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt"
    OR NEW."SU_STA_PositedAt" IS DISTINCT FROM OLD."SU_STA_PositedAt"
    OR NEW."SU_STA_Reliability" IS DISTINCT FROM OLD."SU_STA_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_STA_Subject_State" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_STA_Subject_State" IS NULL
            OR NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt"
            OR NEW."SU_STA_PositedAt" IS DISTINCT FROM OLD."SU_STA_PositedAt"
            OR OLD."SU_STA_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_STA_Subject_State" <> NEW."SU_STA_Subject_State"
            THEN
                INSERT INTO public."SU_STA_Subject_State" (
                    "Metadata_SU_STA",
                    "SU_STA_SU_ID",
                    "SU_STA_Subject_State",
                    "SU_STA_ChangedAt",
                    "SU_STA_PositedAt",
                    "SU_STA_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_STA" IS NOT DISTINCT FROM OLD."Metadata_SU_STA"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_STA"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_STA_SU_ID", NEW."SU_ID"),
                    NEW."SU_STA_Subject_State",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_STA_ChangedAt" IS DISTINCT FROM OLD."SU_STA_ChangedAt" THEN NEW."SU_STA_ChangedAt"
                        WHEN OLD."SU_STA_Subject_State" = NEW."SU_STA_Subject_State" THEN NEW."SU_STA_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_STA_Subject_State" IS NULL AND OLD."SU_STA_Subject_State" IS NOT NULL THEN
            INSERT INTO public."SU_STA_Subject_State" (
                "Metadata_SU_STA",
                "SU_STA_SU_ID",
                "SU_STA_Subject_State",
                "SU_STA_ChangedAt",
                "SU_STA_PositedAt",
                "SU_STA_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_STA" IS NOT DISTINCT FROM OLD."Metadata_SU_STA"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_STA"
                    END, NEW."Metadata_SU"),
                p."SU_STA_SU_ID",
                p."SU_STA_Subject_State",
                p."SU_STA_ChangedAt",
                _positing,
                0
            FROM
                public."SU_STA_Subject_State_Posit" p
            WHERE
                p."SU_STA_ID" = OLD."SU_STA_ID";
        END IF;
    END IF;
    IF NEW."SU_LBL_ID" IS DISTINCT FROM OLD."SU_LBL_ID" THEN
        RAISE EXCEPTION 'The identity column SU_LBL_ID is not updatable.';
    END IF;
    IF NEW."SU_LBL_SU_ID" IS DISTINCT FROM OLD."SU_LBL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LBL_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_LBL_Subject_Label, and when it posits
    _reliability := CASE
        WHEN NEW."SU_LBL_Reliability" IS DISTINCT FROM OLD."SU_LBL_Reliability" THEN NEW."SU_LBL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_LBL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_LBL_PositedAt" IS DISTINCT FROM OLD."SU_LBL_PositedAt" THEN NEW."SU_LBL_PositedAt"
        WHEN NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" AND NEW."SU_LBL_Subject_Label" IS NULL THEN NEW."SU_LBL_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_LBL_Subject_Label" IS DISTINCT FROM OLD."SU_LBL_Subject_Label"
    OR NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt"
    OR NEW."SU_LBL_PositedAt" IS DISTINCT FROM OLD."SU_LBL_PositedAt"
    OR NEW."SU_LBL_Reliability" IS DISTINCT FROM OLD."SU_LBL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_LBL_Subject_Label" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_LBL_Subject_Label" IS NULL
            OR NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt"
            OR NEW."SU_LBL_PositedAt" IS DISTINCT FROM OLD."SU_LBL_PositedAt"
            OR OLD."SU_LBL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_LBL_Subject_Label" <> NEW."SU_LBL_Subject_Label"
            THEN
                INSERT INTO public."SU_LBL_Subject_Label" (
                    "Metadata_SU_LBL",
                    "SU_LBL_SU_ID",
                    "SU_LBL_Subject_Label",
                    "SU_LBL_ChangedAt",
                    "SU_LBL_PositedAt",
                    "SU_LBL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_LBL" IS NOT DISTINCT FROM OLD."Metadata_SU_LBL"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_LBL"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_LBL_SU_ID", NEW."SU_ID"),
                    NEW."SU_LBL_Subject_Label",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_LBL_ChangedAt" IS DISTINCT FROM OLD."SU_LBL_ChangedAt" THEN NEW."SU_LBL_ChangedAt"
                        WHEN OLD."SU_LBL_Subject_Label" = NEW."SU_LBL_Subject_Label" THEN NEW."SU_LBL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_LBL_Subject_Label" IS NULL AND OLD."SU_LBL_Subject_Label" IS NOT NULL THEN
            INSERT INTO public."SU_LBL_Subject_Label" (
                "Metadata_SU_LBL",
                "SU_LBL_SU_ID",
                "SU_LBL_Subject_Label",
                "SU_LBL_ChangedAt",
                "SU_LBL_PositedAt",
                "SU_LBL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_LBL" IS NOT DISTINCT FROM OLD."Metadata_SU_LBL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_LBL"
                    END, NEW."Metadata_SU"),
                p."SU_LBL_SU_ID",
                p."SU_LBL_Subject_Label",
                p."SU_LBL_ChangedAt",
                _positing,
                0
            FROM
                public."SU_LBL_Subject_Label_Posit" p
            WHERE
                p."SU_LBL_ID" = OLD."SU_LBL_ID";
        END IF;
    END IF;
    IF NEW."SU_TAG_ID" IS DISTINCT FROM OLD."SU_TAG_ID" THEN
        RAISE EXCEPTION 'The identity column SU_TAG_ID is not updatable.';
    END IF;
    IF NEW."SU_TAG_SU_ID" IS DISTINCT FROM OLD."SU_TAG_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TAG_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_TAG_Subject_Tag, and when it posits
    _reliability := CASE
        WHEN NEW."SU_TAG_Reliability" IS DISTINCT FROM OLD."SU_TAG_Reliability" THEN NEW."SU_TAG_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_TAG_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_TAG_PositedAt" IS DISTINCT FROM OLD."SU_TAG_PositedAt" THEN NEW."SU_TAG_PositedAt"
        WHEN NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" AND NEW."SU_TAG_Subject_Tag" IS NULL THEN NEW."SU_TAG_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_TAG_Subject_Tag" IS DISTINCT FROM OLD."SU_TAG_Subject_Tag"
    OR NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt"
    OR NEW."SU_TAG_PositedAt" IS DISTINCT FROM OLD."SU_TAG_PositedAt"
    OR NEW."SU_TAG_Reliability" IS DISTINCT FROM OLD."SU_TAG_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_TAG_Subject_Tag" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_TAG_Subject_Tag" IS NULL
            OR NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt"
            OR NEW."SU_TAG_PositedAt" IS DISTINCT FROM OLD."SU_TAG_PositedAt"
            OR OLD."SU_TAG_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_TAG_Subject_Tag" <> NEW."SU_TAG_Subject_Tag"
            THEN
                INSERT INTO public."SU_TAG_Subject_Tag" (
                    "Metadata_SU_TAG",
                    "SU_TAG_SU_ID",
                    "SU_TAG_Subject_Tag",
                    "SU_TAG_ChangedAt",
                    "SU_TAG_PositedAt",
                    "SU_TAG_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_TAG" IS NOT DISTINCT FROM OLD."Metadata_SU_TAG"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_TAG"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_TAG_SU_ID", NEW."SU_ID"),
                    NEW."SU_TAG_Subject_Tag",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_TAG_ChangedAt" IS DISTINCT FROM OLD."SU_TAG_ChangedAt" THEN NEW."SU_TAG_ChangedAt"
                        WHEN OLD."SU_TAG_Subject_Tag" = NEW."SU_TAG_Subject_Tag" THEN NEW."SU_TAG_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_TAG_Subject_Tag" IS NULL AND OLD."SU_TAG_Subject_Tag" IS NOT NULL THEN
            INSERT INTO public."SU_TAG_Subject_Tag" (
                "Metadata_SU_TAG",
                "SU_TAG_SU_ID",
                "SU_TAG_Subject_Tag",
                "SU_TAG_ChangedAt",
                "SU_TAG_PositedAt",
                "SU_TAG_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TAG" IS NOT DISTINCT FROM OLD."Metadata_SU_TAG"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TAG"
                    END, NEW."Metadata_SU"),
                p."SU_TAG_SU_ID",
                p."SU_TAG_Subject_Tag",
                p."SU_TAG_ChangedAt",
                _positing,
                0
            FROM
                public."SU_TAG_Subject_Tag_Posit" p
            WHERE
                p."SU_TAG_ID" = OLD."SU_TAG_ID";
        END IF;
    END IF;
    IF NEW."SU_LVL_ID" IS DISTINCT FROM OLD."SU_LVL_ID" THEN
        RAISE EXCEPTION 'The identity column SU_LVL_ID is not updatable.';
    END IF;
    IF NEW."SU_LVL_SU_ID" IS DISTINCT FROM OLD."SU_LVL_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_LVL_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_LVL_Subject_Level, and when it posits
    _reliability := CASE
        WHEN NEW."SU_LVL_Reliability" IS DISTINCT FROM OLD."SU_LVL_Reliability" THEN NEW."SU_LVL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_LVL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_LVL_PositedAt" IS DISTINCT FROM OLD."SU_LVL_PositedAt" THEN NEW."SU_LVL_PositedAt"
        WHEN NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" AND NEW."SU_LVL_GRD_ID" IS NULL THEN NEW."SU_LVL_ChangedAt"
        ELSE _now
    END;
    _LVL := NEW."SU_LVL_GRD_ID";
    IF _LVL IS NOT DISTINCT FROM OLD."SU_LVL_GRD_ID" AND NEW."SU_LVL_GRD_Grade" IS DISTINCT FROM OLD."SU_LVL_GRD_Grade" THEN
        _LVL := NULL;
        IF NEW."SU_LVL_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _LVL
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."SU_LVL_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."SU_LVL_GRD_ID" IS DISTINCT FROM OLD."SU_LVL_GRD_ID"
    OR NEW."SU_LVL_GRD_Grade" IS DISTINCT FROM OLD."SU_LVL_GRD_Grade"
    OR NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt"
    OR NEW."SU_LVL_PositedAt" IS DISTINCT FROM OLD."SU_LVL_PositedAt"
    OR NEW."SU_LVL_Reliability" IS DISTINCT FROM OLD."SU_LVL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_LVL_GRD_ID" IS NULL
            OR NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt"
            OR NEW."SU_LVL_PositedAt" IS DISTINCT FROM OLD."SU_LVL_PositedAt"
            OR OLD."SU_LVL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_LVL_GRD_ID" <> _LVL
            THEN
                INSERT INTO public."SU_LVL_Subject_Level" (
                    "Metadata_SU_LVL",
                    "SU_LVL_SU_ID",
                    "SU_LVL_GRD_ID",
                    "SU_LVL_ChangedAt",
                    "SU_LVL_PositedAt",
                    "SU_LVL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_LVL" IS NOT DISTINCT FROM OLD."Metadata_SU_LVL"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_LVL"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_LVL_SU_ID", NEW."SU_ID"),
                    _LVL,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_LVL_ChangedAt" IS DISTINCT FROM OLD."SU_LVL_ChangedAt" THEN NEW."SU_LVL_ChangedAt"
                        WHEN OLD."SU_LVL_GRD_ID" = _LVL THEN NEW."SU_LVL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."SU_LVL_GRD_ID" IS NOT NULL AND (
            NEW."SU_LVL_GRD_ID" IS NULL OR (
                NEW."SU_LVL_GRD_ID" = OLD."SU_LVL_GRD_ID"
                AND NEW."SU_LVL_GRD_Grade" IS NULL AND OLD."SU_LVL_GRD_Grade" IS NOT NULL
            )
        ) THEN
            INSERT INTO public."SU_LVL_Subject_Level" (
                "Metadata_SU_LVL",
                "SU_LVL_SU_ID",
                "SU_LVL_GRD_ID",
                "SU_LVL_ChangedAt",
                "SU_LVL_PositedAt",
                "SU_LVL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_LVL" IS NOT DISTINCT FROM OLD."Metadata_SU_LVL"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_LVL"
                    END, NEW."Metadata_SU"),
                p."SU_LVL_SU_ID",
                p."SU_LVL_GRD_ID",
                p."SU_LVL_ChangedAt",
                _positing,
                0
            FROM
                public."SU_LVL_Subject_Level_Posit" p
            WHERE
                p."SU_LVL_ID" = OLD."SU_LVL_ID";
        END IF;
    END IF;
    IF NEW."SU_TXT_ID" IS DISTINCT FROM OLD."SU_TXT_ID" THEN
        RAISE EXCEPTION 'The identity column SU_TXT_ID is not updatable.';
    END IF;
    IF NEW."SU_TXT_SU_ID" IS DISTINCT FROM OLD."SU_TXT_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_TXT_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_TXT_Subject_Text, and when it posits
    _reliability := CASE
        WHEN NEW."SU_TXT_Reliability" IS DISTINCT FROM OLD."SU_TXT_Reliability" THEN NEW."SU_TXT_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_TXT_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_TXT_PositedAt" IS DISTINCT FROM OLD."SU_TXT_PositedAt" THEN NEW."SU_TXT_PositedAt"
        WHEN NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" AND NEW."SU_TXT_Subject_Text" IS NULL THEN NEW."SU_TXT_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_TXT_Subject_Text" IS DISTINCT FROM OLD."SU_TXT_Subject_Text"
    OR NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt"
    OR NEW."SU_TXT_PositedAt" IS DISTINCT FROM OLD."SU_TXT_PositedAt"
    OR NEW."SU_TXT_Reliability" IS DISTINCT FROM OLD."SU_TXT_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_TXT_Subject_Text" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_TXT_Subject_Text" IS NULL
            OR NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt"
            OR NEW."SU_TXT_PositedAt" IS DISTINCT FROM OLD."SU_TXT_PositedAt"
            OR OLD."SU_TXT_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR md5(OLD."SU_TXT_Subject_Text"::text) <> md5(NEW."SU_TXT_Subject_Text"::text)
            THEN
                INSERT INTO public."SU_TXT_Subject_Text" (
                    "Metadata_SU_TXT",
                    "SU_TXT_SU_ID",
                    "SU_TXT_Subject_Text",
                    "SU_TXT_ChangedAt",
                    "SU_TXT_PositedAt",
                    "SU_TXT_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_TXT" IS NOT DISTINCT FROM OLD."Metadata_SU_TXT"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_TXT"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_TXT_SU_ID", NEW."SU_ID"),
                    NEW."SU_TXT_Subject_Text",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_TXT_ChangedAt" IS DISTINCT FROM OLD."SU_TXT_ChangedAt" THEN NEW."SU_TXT_ChangedAt"
                        WHEN md5(OLD."SU_TXT_Subject_Text"::text) = md5(NEW."SU_TXT_Subject_Text"::text) THEN NEW."SU_TXT_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_TXT_Subject_Text" IS NULL AND OLD."SU_TXT_Subject_Text" IS NOT NULL THEN
            INSERT INTO public."SU_TXT_Subject_Text" (
                "Metadata_SU_TXT",
                "SU_TXT_SU_ID",
                "SU_TXT_Subject_Text",
                "SU_TXT_ChangedAt",
                "SU_TXT_PositedAt",
                "SU_TXT_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_TXT" IS NOT DISTINCT FROM OLD."Metadata_SU_TXT"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_TXT"
                    END, NEW."Metadata_SU"),
                p."SU_TXT_SU_ID",
                p."SU_TXT_Subject_Text",
                p."SU_TXT_ChangedAt",
                _positing,
                0
            FROM
                public."SU_TXT_Subject_Text_Posit" p
            WHERE
                p."SU_TXT_ID" = OLD."SU_TXT_ID";
        END IF;
    END IF;
    IF NEW."SU_ASR_ID" IS DISTINCT FROM OLD."SU_ASR_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ASR_ID is not updatable.';
    END IF;
    IF NEW."SU_ASR_SU_ID" IS DISTINCT FROM OLD."SU_ASR_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ASR_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_ASR_Subject_Assessment, and when it posits
    _reliability := CASE
        WHEN NEW."SU_ASR_Reliability" IS DISTINCT FROM OLD."SU_ASR_Reliability" THEN NEW."SU_ASR_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_ASR_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_ASR_PositedAt" IS DISTINCT FROM OLD."SU_ASR_PositedAt" THEN NEW."SU_ASR_PositedAt"
        WHEN NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" AND NEW."SU_ASR_Subject_Assessment" IS NULL THEN NEW."SU_ASR_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_ASR_Subject_Assessment" IS DISTINCT FROM OLD."SU_ASR_Subject_Assessment"
    OR NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt"
    OR NEW."SU_ASR_PositedAt" IS DISTINCT FROM OLD."SU_ASR_PositedAt"
    OR NEW."SU_ASR_Reliability" IS DISTINCT FROM OLD."SU_ASR_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_ASR_Subject_Assessment" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_ASR_Subject_Assessment" IS NULL
            OR NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt"
            OR NEW."SU_ASR_PositedAt" IS DISTINCT FROM OLD."SU_ASR_PositedAt"
            OR OLD."SU_ASR_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_ASR_Subject_Assessment" <> NEW."SU_ASR_Subject_Assessment"
            THEN
                INSERT INTO public."SU_ASR_Subject_Assessment" (
                    "Metadata_SU_ASR",
                    "SU_ASR_SU_ID",
                    "SU_ASR_Subject_Assessment",
                    "SU_ASR_ChangedAt",
                    "SU_ASR_PositedAt",
                    "SU_ASR_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_ASR" IS NOT DISTINCT FROM OLD."Metadata_SU_ASR"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_ASR"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_ASR_SU_ID", NEW."SU_ID"),
                    NEW."SU_ASR_Subject_Assessment",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_ASR_ChangedAt" IS DISTINCT FROM OLD."SU_ASR_ChangedAt" THEN NEW."SU_ASR_ChangedAt"
                        WHEN OLD."SU_ASR_Subject_Assessment" = NEW."SU_ASR_Subject_Assessment" THEN NEW."SU_ASR_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_ASR_Subject_Assessment" IS NULL AND OLD."SU_ASR_Subject_Assessment" IS NOT NULL THEN
            INSERT INTO public."SU_ASR_Subject_Assessment" (
                "Metadata_SU_ASR",
                "SU_ASR_SU_ID",
                "SU_ASR_Subject_Assessment",
                "SU_ASR_ChangedAt",
                "SU_ASR_PositedAt",
                "SU_ASR_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_ASR" IS NOT DISTINCT FROM OLD."Metadata_SU_ASR"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_ASR"
                    END, NEW."Metadata_SU"),
                p."SU_ASR_SU_ID",
                p."SU_ASR_Subject_Assessment",
                p."SU_ASR_ChangedAt",
                _positing,
                0
            FROM
                public."SU_ASR_Subject_Assessment_Posit" p
            WHERE
                p."SU_ASR_ID" = OLD."SU_ASR_ID";
        END IF;
    END IF;
    IF NEW."SU_ERS_ID" IS DISTINCT FROM OLD."SU_ERS_ID" THEN
        RAISE EXCEPTION 'The identity column SU_ERS_ID is not updatable.';
    END IF;
    IF NEW."SU_ERS_SU_ID" IS DISTINCT FROM OLD."SU_ERS_SU_ID" THEN
        RAISE EXCEPTION 'The foreign key column SU_ERS_SU_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of SU_ERS_Subject_Erasable, and when it posits
    _reliability := CASE
        WHEN NEW."SU_ERS_Reliability" IS DISTINCT FROM OLD."SU_ERS_Reliability" THEN NEW."SU_ERS_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."SU_ERS_Reliability"
    END;
    _positing := CASE
        WHEN NEW."SU_ERS_PositedAt" IS DISTINCT FROM OLD."SU_ERS_PositedAt" THEN NEW."SU_ERS_PositedAt"
        WHEN NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" AND NEW."SU_ERS_Subject_Erasable" IS NULL THEN NEW."SU_ERS_ChangedAt"
        ELSE _now
    END;
    IF NEW."SU_ERS_Subject_Erasable" IS DISTINCT FROM OLD."SU_ERS_Subject_Erasable"
    OR NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt"
    OR NEW."SU_ERS_PositedAt" IS DISTINCT FROM OLD."SU_ERS_PositedAt"
    OR NEW."SU_ERS_Reliability" IS DISTINCT FROM OLD."SU_ERS_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."SU_ERS_Subject_Erasable" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."SU_ERS_Subject_Erasable" IS NULL
            OR NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt"
            OR NEW."SU_ERS_PositedAt" IS DISTINCT FROM OLD."SU_ERS_PositedAt"
            OR OLD."SU_ERS_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."SU_ERS_Subject_Erasable" <> NEW."SU_ERS_Subject_Erasable"
            THEN
                INSERT INTO public."SU_ERS_Subject_Erasable" (
                    "Metadata_SU_ERS",
                    "SU_ERS_SU_ID",
                    "SU_ERS_Subject_Erasable",
                    "SU_ERS_ChangedAt",
                    "SU_ERS_PositedAt",
                    "SU_ERS_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                             AND NEW."Metadata_SU_ERS" IS NOT DISTINCT FROM OLD."Metadata_SU_ERS"
                            THEN NEW."Metadata_SU"
                            ELSE NEW."Metadata_SU_ERS"
                        END, NEW."Metadata_SU"),
                    coalesce(NEW."SU_ERS_SU_ID", NEW."SU_ID"),
                    NEW."SU_ERS_Subject_Erasable",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."SU_ERS_ChangedAt" IS DISTINCT FROM OLD."SU_ERS_ChangedAt" THEN NEW."SU_ERS_ChangedAt"
                        WHEN OLD."SU_ERS_Subject_Erasable" = NEW."SU_ERS_Subject_Erasable" THEN NEW."SU_ERS_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."SU_ERS_Subject_Erasable" IS NULL AND OLD."SU_ERS_Subject_Erasable" IS NOT NULL THEN
            INSERT INTO public."SU_ERS_Subject_Erasable" (
                "Metadata_SU_ERS",
                "SU_ERS_SU_ID",
                "SU_ERS_Subject_Erasable",
                "SU_ERS_ChangedAt",
                "SU_ERS_PositedAt",
                "SU_ERS_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_SU" IS DISTINCT FROM OLD."Metadata_SU"
                         AND NEW."Metadata_SU_ERS" IS NOT DISTINCT FROM OLD."Metadata_SU_ERS"
                        THEN NEW."Metadata_SU"
                        ELSE NEW."Metadata_SU_ERS"
                    END, NEW."Metadata_SU"),
                p."SU_ERS_SU_ID",
                p."SU_ERS_Subject_Erasable",
                p."SU_ERS_ChangedAt",
                _positing,
                0
            FROM
                public."SU_ERS_Subject_Erasable_Posit" p
            WHERE
                p."SU_ERS_ID" = OLD."SU_ERS_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "ut_lSU_Subject"
INSTEAD OF UPDATE ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_Subject"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_Subject instead of DELETE trigger on lSU_Subject
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_Subject"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of SU_NAM_Subject_Name is retracted
    INSERT INTO public."SU_NAM_Subject_Name_Annex" (
        "Metadata_SU_NAM",
        "SU_NAM_ID",
        "SU_NAM_PositedAt",
        "SU_NAM_Reliability"
    )
    SELECT
        OLD."Metadata_SU_NAM",
        OLD."SU_NAM_ID",
        _now,
        0
    WHERE
        OLD."SU_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_COD_Subject_Code is retracted
    INSERT INTO public."SU_COD_Subject_Code_Annex" (
        "Metadata_SU_COD",
        "SU_COD_ID",
        "SU_COD_PositedAt",
        "SU_COD_Reliability"
    )
    SELECT
        OLD."Metadata_SU_COD",
        OLD."SU_COD_ID",
        _now,
        0
    WHERE
        OLD."SU_COD_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_GRD_Subject_Grade is retracted
    INSERT INTO public."SU_GRD_Subject_Grade_Annex" (
        "Metadata_SU_GRD",
        "SU_GRD_ID",
        "SU_GRD_PositedAt",
        "SU_GRD_Reliability"
    )
    SELECT
        OLD."Metadata_SU_GRD",
        OLD."SU_GRD_ID",
        _now,
        0
    WHERE
        OLD."SU_GRD_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_NOT_Subject_Note is retracted
    INSERT INTO public."SU_NOT_Subject_Note_Annex" (
        "Metadata_SU_NOT",
        "SU_NOT_ID",
        "SU_NOT_PositedAt",
        "SU_NOT_Reliability"
    )
    SELECT
        OLD."Metadata_SU_NOT",
        OLD."SU_NOT_ID",
        _now,
        0
    WHERE
        OLD."SU_NOT_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_TTL_Subject_Title is retracted
    INSERT INTO public."SU_TTL_Subject_Title_Annex" (
        "Metadata_SU_TTL",
        "SU_TTL_ID",
        "SU_TTL_PositedAt",
        "SU_TTL_Reliability"
    )
    SELECT
        OLD."Metadata_SU_TTL",
        OLD."SU_TTL_ID",
        _now,
        0
    WHERE
        OLD."SU_TTL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_STA_Subject_State is retracted
    INSERT INTO public."SU_STA_Subject_State_Annex" (
        "Metadata_SU_STA",
        "SU_STA_ID",
        "SU_STA_PositedAt",
        "SU_STA_Reliability"
    )
    SELECT
        OLD."Metadata_SU_STA",
        OLD."SU_STA_ID",
        _now,
        0
    WHERE
        OLD."SU_STA_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_LBL_Subject_Label is retracted
    INSERT INTO public."SU_LBL_Subject_Label_Annex" (
        "Metadata_SU_LBL",
        "SU_LBL_ID",
        "SU_LBL_PositedAt",
        "SU_LBL_Reliability"
    )
    SELECT
        OLD."Metadata_SU_LBL",
        OLD."SU_LBL_ID",
        _now,
        0
    WHERE
        OLD."SU_LBL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_TAG_Subject_Tag is retracted
    INSERT INTO public."SU_TAG_Subject_Tag_Annex" (
        "Metadata_SU_TAG",
        "SU_TAG_ID",
        "SU_TAG_PositedAt",
        "SU_TAG_Reliability"
    )
    SELECT
        OLD."Metadata_SU_TAG",
        OLD."SU_TAG_ID",
        _now,
        0
    WHERE
        OLD."SU_TAG_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_LVL_Subject_Level is retracted
    INSERT INTO public."SU_LVL_Subject_Level_Annex" (
        "Metadata_SU_LVL",
        "SU_LVL_ID",
        "SU_LVL_PositedAt",
        "SU_LVL_Reliability"
    )
    SELECT
        OLD."Metadata_SU_LVL",
        OLD."SU_LVL_ID",
        _now,
        0
    WHERE
        OLD."SU_LVL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_TXT_Subject_Text is retracted
    INSERT INTO public."SU_TXT_Subject_Text_Annex" (
        "Metadata_SU_TXT",
        "SU_TXT_ID",
        "SU_TXT_PositedAt",
        "SU_TXT_Reliability"
    )
    SELECT
        OLD."Metadata_SU_TXT",
        OLD."SU_TXT_ID",
        _now,
        0
    WHERE
        OLD."SU_TXT_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_ASR_Subject_Assessment is retracted
    INSERT INTO public."SU_ASR_Subject_Assessment_Annex" (
        "Metadata_SU_ASR",
        "SU_ASR_ID",
        "SU_ASR_PositedAt",
        "SU_ASR_Reliability"
    )
    SELECT
        OLD."Metadata_SU_ASR",
        OLD."SU_ASR_ID",
        _now,
        0
    WHERE
        OLD."SU_ASR_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of SU_ERS_Subject_Erasable is retracted
    INSERT INTO public."SU_ERS_Subject_Erasable_Annex" (
        "Metadata_SU_ERS",
        "SU_ERS_ID",
        "SU_ERS_PositedAt",
        "SU_ERS_Reliability"
    )
    SELECT
        OLD."Metadata_SU_ERS",
        OLD."SU_ERS_ID",
        _now,
        0
    WHERE
        OLD."SU_ERS_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_Subject" ON public."lSU_Subject";
CREATE TRIGGER "dt_lSU_Subject"
INSTEAD OF DELETE ON public."lSU_Subject"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_Subject"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_Object instead of INSERT trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
BEGIN
    _id := NEW."OB_ID";
    IF _id IS NULL THEN
        INSERT INTO public."OB_Object" (
            "Metadata_OB"
        )
        VALUES (
            NEW."Metadata_OB"
        )
        RETURNING "OB_ID" INTO _id;
    END IF;
    IF NEW."OB_NAM_Object_Name" IS NOT NULL THEN
        INSERT INTO public."OB_NAM_Object_Name" (
            "Metadata_OB_NAM",
            "OB_NAM_OB_ID",
            "OB_NAM_Object_Name",
            "OB_NAM_PositedAt",
            "OB_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_NAM", NEW."Metadata_OB"),
            coalesce(NEW."OB_NAM_OB_ID", _id),
            NEW."OB_NAM_Object_Name",
            coalesce(NEW."OB_NAM_PositedAt", _now),
            coalesce(NEW."OB_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "it_lOB_Object"
INSTEAD OF INSERT ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."it_lOB_Object"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_Object instead of UPDATE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
BEGIN
    IF NEW."OB_ID" IS DISTINCT FROM OLD."OB_ID" THEN
        RAISE EXCEPTION 'The identity column OB_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_ID" IS DISTINCT FROM OLD."OB_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column OB_NAM_ID is not updatable.';
    END IF;
    IF NEW."OB_NAM_OB_ID" IS DISTINCT FROM OLD."OB_NAM_OB_ID" THEN
        RAISE EXCEPTION 'The foreign key column OB_NAM_OB_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of OB_NAM_Object_Name, and when it posits
    _reliability := CASE
        WHEN NEW."OB_NAM_Reliability" IS DISTINCT FROM OLD."OB_NAM_Reliability" THEN NEW."OB_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."OB_NAM_Reliability"
    END;
    _positing := CASE
        WHEN NEW."OB_NAM_PositedAt" IS DISTINCT FROM OLD."OB_NAM_PositedAt" THEN NEW."OB_NAM_PositedAt"
        ELSE _now
    END;
    IF NEW."OB_NAM_Object_Name" IS DISTINCT FROM OLD."OB_NAM_Object_Name"
    OR NEW."OB_NAM_PositedAt" IS DISTINCT FROM OLD."OB_NAM_PositedAt"
    OR NEW."OB_NAM_Reliability" IS DISTINCT FROM OLD."OB_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."OB_NAM_Object_Name" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."OB_NAM_Object_Name" IS NULL
            OR NEW."OB_NAM_PositedAt" IS DISTINCT FROM OLD."OB_NAM_PositedAt"
            OR OLD."OB_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."OB_NAM_Object_Name" <> NEW."OB_NAM_Object_Name"
            THEN
                INSERT INTO public."OB_NAM_Object_Name" (
                    "Metadata_OB_NAM",
                    "OB_NAM_OB_ID",
                    "OB_NAM_Object_Name",
                    "OB_NAM_PositedAt",
                    "OB_NAM_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_OB" IS DISTINCT FROM OLD."Metadata_OB"
                             AND NEW."Metadata_OB_NAM" IS NOT DISTINCT FROM OLD."Metadata_OB_NAM"
                            THEN NEW."Metadata_OB"
                            ELSE NEW."Metadata_OB_NAM"
                        END, NEW."Metadata_OB"),
                    coalesce(NEW."OB_NAM_OB_ID", NEW."OB_ID"),
                    NEW."OB_NAM_Object_Name",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."OB_NAM_Object_Name" IS NULL AND OLD."OB_NAM_Object_Name" IS NOT NULL THEN
            INSERT INTO public."OB_NAM_Object_Name" (
                "Metadata_OB_NAM",
                "OB_NAM_OB_ID",
                "OB_NAM_Object_Name",
                "OB_NAM_PositedAt",
                "OB_NAM_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_OB" IS DISTINCT FROM OLD."Metadata_OB"
                         AND NEW."Metadata_OB_NAM" IS NOT DISTINCT FROM OLD."Metadata_OB_NAM"
                        THEN NEW."Metadata_OB"
                        ELSE NEW."Metadata_OB_NAM"
                    END, NEW."Metadata_OB"),
                p."OB_NAM_OB_ID",
                p."OB_NAM_Object_Name",
                _positing,
                0
            FROM
                public."OB_NAM_Object_Name_Posit" p
            WHERE
                p."OB_NAM_ID" = OLD."OB_NAM_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "ut_lOB_Object"
INSTEAD OF UPDATE ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."ut_lOB_Object"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_Object instead of DELETE trigger on lOB_Object
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lOB_Object"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of OB_NAM_Object_Name is retracted
    INSERT INTO public."OB_NAM_Object_Name_Annex" (
        "Metadata_OB_NAM",
        "OB_NAM_ID",
        "OB_NAM_PositedAt",
        "OB_NAM_Reliability"
    )
    SELECT
        OLD."Metadata_OB_NAM",
        OLD."OB_NAM_ID",
        _now,
        0
    WHERE
        OLD."OB_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_Object" ON public."lOB_Object";
CREATE TRIGGER "dt_lOB_Object"
INSTEAD OF DELETE ON public."lOB_Object"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_Object"();
-- NEXUS TRIGGERS ---------------------------------------------------------------------------------------------------
--
-- The following triggers on the latest view make it behave like a table.
-- There are three different 'instead of' triggers: insert, update, and delete.
-- They will ensure that such operations are propagated to the assembled views of the attributes (whose triggers keep the
-- posit and annex tables) in a consistent way. Default values are used for some columns if not provided by the
-- corresponding SQL statements: the changing and positing times are now, the reliability is 1.
--
-- For idempotent attributes, only changes that represent a value different from
-- the previous or following value are stored. Others are silently ignored in
-- order to avoid unnecessary temporal duplicates (the triggers of the attributes see to that).
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_Event instead of INSERT trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
BEGIN
    _id := NEW."EV_ID";
    IF _id IS NULL THEN
        INSERT INTO public."EV_Event" (
            "SU_ID_for",
            "Metadata_EV"
        )
        VALUES (
            NEW."SU_ID_for",
            NEW."Metadata_EV"
        )
        RETURNING "EV_ID" INTO _id;
    END IF;
    IF NEW."EV_QTY_Event_Quantity" IS NOT NULL THEN
        INSERT INTO public."EV_QTY_Event_Quantity" (
            "Metadata_EV_QTY",
            "EV_QTY_EV_ID",
            "EV_QTY_Event_Quantity",
            "EV_QTY_PositedAt",
            "EV_QTY_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_QTY", NEW."Metadata_EV"),
            coalesce(NEW."EV_QTY_EV_ID", _id),
            NEW."EV_QTY_Event_Quantity",
            coalesce(NEW."EV_QTY_PositedAt", _now),
            coalesce(NEW."EV_QTY_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."EV_PLC_Event_Place" IS NOT NULL THEN
        INSERT INTO public."EV_PLC_Event_Place" (
            "Metadata_EV_PLC",
            "EV_PLC_EV_ID",
            "EV_PLC_Event_Place",
            "EV_PLC_ChangedAt",
            "EV_PLC_PositedAt",
            "EV_PLC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_PLC", NEW."Metadata_EV"),
            coalesce(NEW."EV_PLC_EV_ID", _id),
            NEW."EV_PLC_Event_Place",
            coalesce(NEW."EV_PLC_ChangedAt", _now),
            coalesce(NEW."EV_PLC_PositedAt", _now),
            coalesce(NEW."EV_PLC_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "it_lEV_Event"
INSTEAD OF INSERT ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."it_lEV_Event"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Event instead of UPDATE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
BEGIN
    IF NEW."EV_ID" IS DISTINCT FROM OLD."EV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_ID is not updatable.';
    END IF;
    IF NEW."SU_ID_for" IS DISTINCT FROM OLD."SU_ID_for" THEN
        RAISE EXCEPTION 'The role column SU_ID_for is not updatable.';
    END IF;
    IF NEW."EV_QTY_ID" IS DISTINCT FROM OLD."EV_QTY_ID" THEN
        RAISE EXCEPTION 'The identity column EV_QTY_ID is not updatable.';
    END IF;
    IF NEW."EV_QTY_EV_ID" IS DISTINCT FROM OLD."EV_QTY_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_QTY_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_QTY_Event_Quantity, and when it posits
    _reliability := CASE
        WHEN NEW."EV_QTY_Reliability" IS DISTINCT FROM OLD."EV_QTY_Reliability" THEN NEW."EV_QTY_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_QTY_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_QTY_PositedAt" IS DISTINCT FROM OLD."EV_QTY_PositedAt" THEN NEW."EV_QTY_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_QTY_Event_Quantity" IS DISTINCT FROM OLD."EV_QTY_Event_Quantity"
    OR NEW."EV_QTY_PositedAt" IS DISTINCT FROM OLD."EV_QTY_PositedAt"
    OR NEW."EV_QTY_Reliability" IS DISTINCT FROM OLD."EV_QTY_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_QTY_Event_Quantity" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_QTY_Event_Quantity" IS NULL
            OR NEW."EV_QTY_PositedAt" IS DISTINCT FROM OLD."EV_QTY_PositedAt"
            OR OLD."EV_QTY_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_QTY_Event_Quantity" <> NEW."EV_QTY_Event_Quantity"
            THEN
                INSERT INTO public."EV_QTY_Event_Quantity" (
                    "Metadata_EV_QTY",
                    "EV_QTY_EV_ID",
                    "EV_QTY_Event_Quantity",
                    "EV_QTY_PositedAt",
                    "EV_QTY_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_QTY" IS NOT DISTINCT FROM OLD."Metadata_EV_QTY"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_QTY"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_QTY_EV_ID", NEW."EV_ID"),
                    NEW."EV_QTY_Event_Quantity",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_QTY_Event_Quantity" IS NULL AND OLD."EV_QTY_Event_Quantity" IS NOT NULL THEN
            INSERT INTO public."EV_QTY_Event_Quantity" (
                "Metadata_EV_QTY",
                "EV_QTY_EV_ID",
                "EV_QTY_Event_Quantity",
                "EV_QTY_PositedAt",
                "EV_QTY_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_QTY" IS NOT DISTINCT FROM OLD."Metadata_EV_QTY"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_QTY"
                    END, NEW."Metadata_EV"),
                p."EV_QTY_EV_ID",
                p."EV_QTY_Event_Quantity",
                _positing,
                0
            FROM
                public."EV_QTY_Event_Quantity_Posit" p
            WHERE
                p."EV_QTY_ID" = OLD."EV_QTY_ID";
        END IF;
    END IF;
    IF NEW."EV_PLC_ID" IS DISTINCT FROM OLD."EV_PLC_ID" THEN
        RAISE EXCEPTION 'The identity column EV_PLC_ID is not updatable.';
    END IF;
    IF NEW."EV_PLC_EV_ID" IS DISTINCT FROM OLD."EV_PLC_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_PLC_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_PLC_Event_Place, and when it posits
    _reliability := CASE
        WHEN NEW."EV_PLC_Reliability" IS DISTINCT FROM OLD."EV_PLC_Reliability" THEN NEW."EV_PLC_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_PLC_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_PLC_PositedAt" IS DISTINCT FROM OLD."EV_PLC_PositedAt" THEN NEW."EV_PLC_PositedAt"
        WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" AND NEW."EV_PLC_Event_Place" IS NULL THEN NEW."EV_PLC_ChangedAt"
        ELSE _now
    END;
    IF NEW."EV_PLC_Event_Place" IS DISTINCT FROM OLD."EV_PLC_Event_Place"
    OR NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt"
    OR NEW."EV_PLC_PositedAt" IS DISTINCT FROM OLD."EV_PLC_PositedAt"
    OR NEW."EV_PLC_Reliability" IS DISTINCT FROM OLD."EV_PLC_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_PLC_Event_Place" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_PLC_Event_Place" IS NULL
            OR NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt"
            OR NEW."EV_PLC_PositedAt" IS DISTINCT FROM OLD."EV_PLC_PositedAt"
            OR OLD."EV_PLC_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_PLC_Event_Place" <> NEW."EV_PLC_Event_Place"
            THEN
                INSERT INTO public."EV_PLC_Event_Place" (
                    "Metadata_EV_PLC",
                    "EV_PLC_EV_ID",
                    "EV_PLC_Event_Place",
                    "EV_PLC_ChangedAt",
                    "EV_PLC_PositedAt",
                    "EV_PLC_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_PLC" IS NOT DISTINCT FROM OLD."Metadata_EV_PLC"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_PLC"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_PLC_EV_ID", NEW."EV_ID"),
                    NEW."EV_PLC_Event_Place",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."EV_PLC_ChangedAt" IS DISTINCT FROM OLD."EV_PLC_ChangedAt" THEN NEW."EV_PLC_ChangedAt"
                        WHEN OLD."EV_PLC_Event_Place" = NEW."EV_PLC_Event_Place" THEN NEW."EV_PLC_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_PLC_Event_Place" IS NULL AND OLD."EV_PLC_Event_Place" IS NOT NULL THEN
            INSERT INTO public."EV_PLC_Event_Place" (
                "Metadata_EV_PLC",
                "EV_PLC_EV_ID",
                "EV_PLC_Event_Place",
                "EV_PLC_ChangedAt",
                "EV_PLC_PositedAt",
                "EV_PLC_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_PLC" IS NOT DISTINCT FROM OLD."Metadata_EV_PLC"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_PLC"
                    END, NEW."Metadata_EV"),
                p."EV_PLC_EV_ID",
                p."EV_PLC_Event_Place",
                p."EV_PLC_ChangedAt",
                _positing,
                0
            FROM
                public."EV_PLC_Event_Place_Posit" p
            WHERE
                p."EV_PLC_ID" = OLD."EV_PLC_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "ut_lEV_Event"
INSTEAD OF UPDATE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."ut_lEV_Event"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Event instead of DELETE trigger on lEV_Event
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lEV_Event"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of EV_QTY_Event_Quantity is retracted
    INSERT INTO public."EV_QTY_Event_Quantity_Annex" (
        "Metadata_EV_QTY",
        "EV_QTY_ID",
        "EV_QTY_PositedAt",
        "EV_QTY_Reliability"
    )
    SELECT
        OLD."Metadata_EV_QTY",
        OLD."EV_QTY_ID",
        _now,
        0
    WHERE
        OLD."EV_QTY_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_PLC_Event_Place is retracted
    INSERT INTO public."EV_PLC_Event_Place_Annex" (
        "Metadata_EV_PLC",
        "EV_PLC_ID",
        "EV_PLC_PositedAt",
        "EV_PLC_Reliability"
    )
    SELECT
        OLD."Metadata_EV_PLC",
        OLD."EV_PLC_ID",
        _now,
        0
    WHERE
        OLD."EV_PLC_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Event" ON public."lEV_Event";
CREATE TRIGGER "dt_lEV_Event"
INSTEAD OF DELETE ON public."lEV_Event"
FOR EACH ROW EXECUTE FUNCTION public."dt_lEV_Event"();
-- TIE TRIGGERS -------------------------------------------------------------------------------------------------------
--
-- The following triggers on the assembled and latest views make them behave like tables.
-- The assembled view has an 'instead of' trigger for insert, which keeps the posit and annex tables. The latest view has
-- three: insert, update, and delete. They propagate such operations to the assembled view in a consistent way. Default
-- values are used for some columns if not provided by the corresponding SQL statements: the changing and positing times
-- are now, the reliability is 1.
--
-- The rules are the ones of the attributes (see the attribute triggers). A tie that has identifiers and other roles, which
-- are its values, is decisive about the values of the identifiers (at a changing time): an assertion of other values retracts,
-- at its own positing time, the posit that is in effect, which is a correction.
--
-- For idempotent ties, only changes that represent values different from the previous or following value are stored.
-- Others are silently ignored in order to avoid unnecessary temporal duplicates.
--
-- PostgreSQL runs a trigger of this kind for each row, so a statement is a row at a time. Whether a column is set in an UPDATE
-- is told from whether it has another value than the row had.
--
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_holder_OB_item_GRD_grade tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_SU_holder_OB_item_GRD_grade"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."SU_holder_OB_item_GRD_grade_Reliability" = 1
            FROM
                public."SU_holder_OB_item_GRD_grade_Annex" a
            WHERE
                a."SU_holder_OB_item_GRD_grade_ID" = _id
            AND
                a."SU_holder_OB_item_GRD_grade_PositedAt" <= _positing
            ORDER BY
                a."SU_holder_OB_item_GRD_grade_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_holder_OB_item_GRD_grade instead of INSERT trigger on SU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_holder_OB_item_GRD_grade_PositedAt", _now);
    _reliability := coalesce(NEW."SU_holder_OB_item_GRD_grade_Reliability", 1);
    _changing := coalesce(NEW."SU_holder_OB_item_GRD_grade_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_holder_OB_item_GRD_grade_ID"
    INTO
        _posit
    FROM
        public."SU_holder_OB_item_GRD_grade_Posit" p
    WHERE
        p."SU_ID_holder" = NEW."SU_ID_holder"
    AND
        p."OB_ID_item" = NEW."OB_ID_item"
    AND
        p."GRD_ID_grade" = NEW."GRD_ID_grade"
    AND
        p."SU_holder_OB_item_GRD_grade_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade_Annex" a
        WHERE
            a."SU_holder_OB_item_GRD_grade_ID" = _posit
        AND
            a."SU_holder_OB_item_GRD_grade_PositedAt" = _positing
        AND
            a."SU_holder_OB_item_GRD_grade_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_holder_OB_item_GRD_grade for: %', concat_ws(', ',
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."GRD_ID_grade",
            _changing,
            _positing);
    END IF;
    -- other values for identifiers that already have values at that time, asserted at the positing time, are a contradiction
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade_Posit" p
        JOIN
            public."SU_holder_OB_item_GRD_grade_Annex" a
        ON
            a."SU_holder_OB_item_GRD_grade_ID" = p."SU_holder_OB_item_GRD_grade_ID"
        WHERE
            p."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            p."OB_ID_item" = NEW."OB_ID_item"
        AND
            p."SU_holder_OB_item_GRD_grade_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_grade" = NEW."GRD_ID_grade"
            )
        AND
            a."SU_holder_OB_item_GRD_grade_PositedAt" = _positing
        AND
            a."SU_holder_OB_item_GRD_grade_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_holder_OB_item_GRD_grade for: %', concat_ws(', ',
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."GRD_ID_grade",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_holder_OB_item_GRD_grade_Annex" a
        WHERE
            a."SU_holder_OB_item_GRD_grade_ID" = _posit
        AND
            a."SU_holder_OB_item_GRD_grade_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT public."ie_SU_holder_OB_item_GRD_grade"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_holder_OB_item_GRD_grade_Annex" (
            "Metadata_SU_holder_OB_item_GRD_grade",
            "SU_holder_OB_item_GRD_grade_ID",
            "SU_holder_OB_item_GRD_grade_PositedAt",
            "SU_holder_OB_item_GRD_grade_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same identifiers (and changing time), when that has
    -- other values: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_holder_OB_item_GRD_grade_ID"
        FROM
            public."SU_holder_OB_item_GRD_grade_Posit" p
        WHERE
            p."SU_ID_holder" = NEW."SU_ID_holder"
        AND
            p."OB_ID_item" = NEW."OB_ID_item"
        AND
            p."SU_holder_OB_item_GRD_grade_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_grade" = NEW."GRD_ID_grade"
            )
        AND
            public."ie_SU_holder_OB_item_GRD_grade"(p."SU_holder_OB_item_GRD_grade_ID", _positing)
    LOOP
        INSERT INTO public."SU_holder_OB_item_GRD_grade_Annex" (
            "Metadata_SU_holder_OB_item_GRD_grade",
            "SU_holder_OB_item_GRD_grade_ID",
            "SU_holder_OB_item_GRD_grade_PositedAt",
            "SU_holder_OB_item_GRD_grade_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_holder_OB_item_GRD_grade_Posit" (
            "SU_ID_holder",
            "OB_ID_item",
            "GRD_ID_grade",
            "SU_holder_OB_item_GRD_grade_ChangedAt"
        )
        VALUES (
            NEW."SU_ID_holder",
            NEW."OB_ID_item",
            NEW."GRD_ID_grade",
            _changing
        )
        RETURNING "SU_holder_OB_item_GRD_grade_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_holder_OB_item_GRD_grade_Annex" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_holder_OB_item_GRD_grade_ID",
        "SU_holder_OB_item_GRD_grade_PositedAt",
        "SU_holder_OB_item_GRD_grade_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_holder_OB_item_GRD_grade", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_holder_OB_item_GRD_grade" ON public."SU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_SU_holder_OB_item_GRD_grade"
INSTEAD OF INSERT ON public."SU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_holder_OB_item_GRD_grade"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_holder_OB_item_GRD_grade instead of INSERT trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."SU_holder_OB_item_GRD_grade" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_ID_holder",
        "OB_ID_item",
        "GRD_ID_grade",
        "SU_holder_OB_item_GRD_grade_ChangedAt",
        "SU_holder_OB_item_GRD_grade_PositedAt",
        "SU_holder_OB_item_GRD_grade_Reliability"
    )
    VALUES (
        NEW."Metadata_SU_holder_OB_item_GRD_grade",
        NEW."SU_ID_holder",
        NEW."OB_ID_item",
        coalesce(NEW."GRD_ID_grade", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."grade_GRD_Grade"
            LIMIT 1
        )),
        coalesce(NEW."SU_holder_OB_item_GRD_grade_ChangedAt", _now),
        coalesce(NEW."SU_holder_OB_item_GRD_grade_PositedAt", _now),
        coalesce(NEW."SU_holder_OB_item_GRD_grade_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "it_lSU_holder_OB_item_GRD_grade"
INSTEAD OF INSERT ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_holder_OB_item_GRD_grade"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_holder_OB_item_GRD_grade instead of UPDATE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _GRD_grade smallint;
BEGIN
    IF NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder" THEN
        RAISE EXCEPTION 'The identity column SU_ID_holder is not updatable.';
    END IF;
    IF NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item" THEN
        RAISE EXCEPTION 'The identity column OB_ID_item is not updatable.';
    END IF;
    _GRD_grade := NEW."GRD_ID_grade";
    IF NEW."grade_GRD_Grade" IS DISTINCT FROM OLD."grade_GRD_Grade" AND NEW."GRD_ID_grade" IS NOT DISTINCT FROM OLD."GRD_ID_grade" THEN
        _GRD_grade := NULL;
        IF NEW."grade_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _GRD_grade
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."grade_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    _positing := CASE
        WHEN NEW."SU_holder_OB_item_GRD_grade_PositedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_PositedAt" THEN NEW."SU_holder_OB_item_GRD_grade_PositedAt"
        ELSE _now
    END;
    IF
        NEW."SU_ID_holder" IS DISTINCT FROM OLD."SU_ID_holder" OR
        NEW."OB_ID_item" IS DISTINCT FROM OLD."OB_ID_item" OR
        _GRD_grade IS DISTINCT FROM OLD."GRD_ID_grade" OR
        NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" OR
        NEW."SU_holder_OB_item_GRD_grade_PositedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_PositedAt" OR
        NEW."SU_holder_OB_item_GRD_grade_Reliability" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_Reliability"
    THEN
        IF
            NEW."SU_ID_holder" IS NOT NULL
        AND
            NEW."OB_ID_item" IS NOT NULL
        AND
            _GRD_grade IS NOT NULL
        THEN
            INSERT INTO public."SU_holder_OB_item_GRD_grade" (
                "Metadata_SU_holder_OB_item_GRD_grade",
                "SU_ID_holder",
                "OB_ID_item",
                "GRD_ID_grade",
                "SU_holder_OB_item_GRD_grade_ChangedAt",
                "SU_holder_OB_item_GRD_grade_PositedAt",
                "SU_holder_OB_item_GRD_grade_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_holder_OB_item_GRD_grade",
                NEW."SU_ID_holder",
                NEW."OB_ID_item",
                _GRD_grade,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt" IS DISTINCT FROM OLD."SU_holder_OB_item_GRD_grade_ChangedAt" THEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
                    WHEN
                        NEW."SU_ID_holder" = OLD."SU_ID_holder"
                    AND
                        NEW."OB_ID_item" = OLD."OB_ID_item"
                    AND
                        _GRD_grade = OLD."GRD_ID_grade"
                    THEN NEW."SU_holder_OB_item_GRD_grade_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."SU_holder_OB_item_GRD_grade_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."SU_holder_OB_item_GRD_grade" (
                "Metadata_SU_holder_OB_item_GRD_grade",
                "SU_ID_holder",
                "OB_ID_item",
                "GRD_ID_grade",
                "SU_holder_OB_item_GRD_grade_ChangedAt",
                "SU_holder_OB_item_GRD_grade_PositedAt",
                "SU_holder_OB_item_GRD_grade_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_holder_OB_item_GRD_grade",
                OLD."SU_ID_holder",
                OLD."OB_ID_item",
                OLD."GRD_ID_grade",
                OLD."SU_holder_OB_item_GRD_grade_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "ut_lSU_holder_OB_item_GRD_grade"
INSTEAD OF UPDATE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_holder_OB_item_GRD_grade"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_holder_OB_item_GRD_grade instead of DELETE trigger on lSU_holder_OB_item_GRD_grade
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."SU_holder_OB_item_GRD_grade_Annex" (
        "Metadata_SU_holder_OB_item_GRD_grade",
        "SU_holder_OB_item_GRD_grade_ID",
        "SU_holder_OB_item_GRD_grade_PositedAt",
        "SU_holder_OB_item_GRD_grade_Reliability"
    )
    SELECT
        OLD."Metadata_SU_holder_OB_item_GRD_grade",
        OLD."SU_holder_OB_item_GRD_grade_ID",
        _now,
        0
    WHERE
        OLD."SU_holder_OB_item_GRD_grade_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_holder_OB_item_GRD_grade" ON public."lSU_holder_OB_item_GRD_grade";
CREATE TRIGGER "dt_lSU_holder_OB_item_GRD_grade"
INSTEAD OF DELETE ON public."lSU_holder_OB_item_GRD_grade"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_holder_OB_item_GRD_grade"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_keeper_OB_thing_GRD_rank tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_SU_keeper_OB_thing_GRD_rank"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."SU_keeper_OB_thing_GRD_rank_Reliability" = 1
            FROM
                public."SU_keeper_OB_thing_GRD_rank_Annex" a
            WHERE
                a."SU_keeper_OB_thing_GRD_rank_ID" = _id
            AND
                a."SU_keeper_OB_thing_GRD_rank_PositedAt" <= _positing
            ORDER BY
                a."SU_keeper_OB_thing_GRD_rank_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_keeper_OB_thing_GRD_rank instead of INSERT trigger on SU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_PositedAt", _now);
    _reliability := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Reliability", 1);
    _changing := coalesce(NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_keeper_OB_thing_GRD_rank_ID"
    INTO
        _posit
    FROM
        public."SU_keeper_OB_thing_GRD_rank_Posit" p
    WHERE
        p."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        p."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        p."GRD_ID_rank" = NEW."GRD_ID_rank"
    AND
        p."SU_keeper_OB_thing_GRD_rank_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Annex" a
        WHERE
            a."SU_keeper_OB_thing_GRD_rank_ID" = _posit
        AND
            a."SU_keeper_OB_thing_GRD_rank_PositedAt" = _positing
        AND
            a."SU_keeper_OB_thing_GRD_rank_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_keeper_OB_thing_GRD_rank for: %', concat_ws(', ',
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."GRD_ID_rank",
            _changing,
            _positing);
    END IF;
    -- other values for identifiers that already have values at that time, asserted at the positing time, are a contradiction
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Posit" p
        JOIN
            public."SU_keeper_OB_thing_GRD_rank_Annex" a
        ON
            a."SU_keeper_OB_thing_GRD_rank_ID" = p."SU_keeper_OB_thing_GRD_rank_ID"
        WHERE
            p."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            p."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            p."SU_keeper_OB_thing_GRD_rank_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_rank" = NEW."GRD_ID_rank"
            )
        AND
            a."SU_keeper_OB_thing_GRD_rank_PositedAt" = _positing
        AND
            a."SU_keeper_OB_thing_GRD_rank_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_keeper_OB_thing_GRD_rank for: %', concat_ws(', ',
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."GRD_ID_rank",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Annex" a
        WHERE
            a."SU_keeper_OB_thing_GRD_rank_ID" = _posit
        AND
            a."SU_keeper_OB_thing_GRD_rank_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT public."ie_SU_keeper_OB_thing_GRD_rank"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ID",
            "SU_keeper_OB_thing_GRD_rank_PositedAt",
            "SU_keeper_OB_thing_GRD_rank_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion that is asserted already is skipped unless the tie is assertive
    IF _posit IS NOT NULL AND public."ie_SU_keeper_OB_thing_GRD_rank"(_posit, _positing) THEN
        RETURN NULL;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same identifiers (and changing time), when that has
    -- other values: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."SU_keeper_OB_thing_GRD_rank_ID"
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Posit" p
        WHERE
            p."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            p."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            p."SU_keeper_OB_thing_GRD_rank_ChangedAt" = _changing
        AND
            NOT (
                p."GRD_ID_rank" = NEW."GRD_ID_rank"
            )
        AND
            public."ie_SU_keeper_OB_thing_GRD_rank"(p."SU_keeper_OB_thing_GRD_rank_ID", _positing)
    LOOP
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ID",
            "SU_keeper_OB_thing_GRD_rank_PositedAt",
            "SU_keeper_OB_thing_GRD_rank_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the same values as the version before it, which is asserted at the positing time, is a restatement
    IF EXISTS (
        SELECT
            1
        FROM (
            SELECT
                p."SU_ID_keeper",
                p."OB_ID_thing",
                p."GRD_ID_rank"
            FROM
                public."SU_keeper_OB_thing_GRD_rank_Posit" p
            WHERE
                p."SU_ID_keeper" = NEW."SU_ID_keeper"
            AND
                p."OB_ID_thing" = NEW."OB_ID_thing"
            AND
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" < _changing
            AND
                public."ie_SU_keeper_OB_thing_GRD_rank"(p."SU_keeper_OB_thing_GRD_rank_ID", _positing)
            ORDER BY
                p."SU_keeper_OB_thing_GRD_rank_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            pre."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            pre."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            pre."GRD_ID_rank" = NEW."GRD_ID_rank"
    ) THEN
        -- (an idempotent tie does not store it)
        RETURN NULL;
    END IF;
    -- the same values as the version after it make that version a restatement
    SELECT
        f."SU_keeper_OB_thing_GRD_rank_ID"
    INTO
        _following
    FROM
        public."SU_keeper_OB_thing_GRD_rank_Posit" f
    WHERE
        f."SU_ID_keeper" = NEW."SU_ID_keeper"
    AND
        f."OB_ID_thing" = NEW."OB_ID_thing"
    AND
        f."SU_keeper_OB_thing_GRD_rank_ChangedAt" > _changing
    AND
        public."ie_SU_keeper_OB_thing_GRD_rank"(f."SU_keeper_OB_thing_GRD_rank_ID", _positing)
    ORDER BY
        f."SU_keeper_OB_thing_GRD_rank_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_keeper_OB_thing_GRD_rank_Posit" x
        WHERE
            x."SU_keeper_OB_thing_GRD_rank_ID" = _following
        AND
            x."SU_ID_keeper" = NEW."SU_ID_keeper"
        AND
            x."OB_ID_thing" = NEW."OB_ID_thing"
        AND
            x."GRD_ID_rank" = NEW."GRD_ID_rank"
    ) THEN
        -- (an idempotent tie retracts it)
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
            "Metadata_SU_keeper_OB_thing_GRD_rank",
            "SU_keeper_OB_thing_GRD_rank_ID",
            "SU_keeper_OB_thing_GRD_rank_PositedAt",
            "SU_keeper_OB_thing_GRD_rank_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
            _following,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Posit" (
            "SU_ID_keeper",
            "OB_ID_thing",
            "GRD_ID_rank",
            "SU_keeper_OB_thing_GRD_rank_ChangedAt"
        )
        VALUES (
            NEW."SU_ID_keeper",
            NEW."OB_ID_thing",
            NEW."GRD_ID_rank",
            _changing
        )
        RETURNING "SU_keeper_OB_thing_GRD_rank_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_keeper_OB_thing_GRD_rank_ID",
        "SU_keeper_OB_thing_GRD_rank_PositedAt",
        "SU_keeper_OB_thing_GRD_rank_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_keeper_OB_thing_GRD_rank", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_keeper_OB_thing_GRD_rank" ON public."SU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_SU_keeper_OB_thing_GRD_rank"
INSTEAD OF INSERT ON public."SU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_keeper_OB_thing_GRD_rank"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_keeper_OB_thing_GRD_rank instead of INSERT trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_ID_keeper",
        "OB_ID_thing",
        "GRD_ID_rank",
        "SU_keeper_OB_thing_GRD_rank_ChangedAt",
        "SU_keeper_OB_thing_GRD_rank_PositedAt",
        "SU_keeper_OB_thing_GRD_rank_Reliability"
    )
    VALUES (
        NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
        NEW."SU_ID_keeper",
        NEW."OB_ID_thing",
        coalesce(NEW."GRD_ID_rank", (
            SELECT
                k."GRD_ID"
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."rank_GRD_Grade"
            LIMIT 1
        )),
        coalesce(NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt", _now),
        coalesce(NEW."SU_keeper_OB_thing_GRD_rank_PositedAt", _now),
        coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "it_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF INSERT ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_keeper_OB_thing_GRD_rank"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_keeper_OB_thing_GRD_rank instead of UPDATE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _GRD_rank smallint;
BEGIN
    IF NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper" THEN
        RAISE EXCEPTION 'The identity column SU_ID_keeper is not updatable.';
    END IF;
    IF NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing" THEN
        RAISE EXCEPTION 'The identity column OB_ID_thing is not updatable.';
    END IF;
    _GRD_rank := NEW."GRD_ID_rank";
    IF NEW."rank_GRD_Grade" IS DISTINCT FROM OLD."rank_GRD_Grade" AND NEW."GRD_ID_rank" IS NOT DISTINCT FROM OLD."GRD_ID_rank" THEN
        _GRD_rank := NULL;
        IF NEW."rank_GRD_Grade" IS NOT NULL THEN
            SELECT
                k."GRD_ID"
            INTO
                _GRD_rank
            FROM
                public."GRD_Grade" k
            WHERE
                k."GRD_Grade" = NEW."rank_GRD_Grade"
            LIMIT 1;
        END IF;
    END IF;
    _positing := CASE
        WHEN NEW."SU_keeper_OB_thing_GRD_rank_PositedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_PositedAt" THEN NEW."SU_keeper_OB_thing_GRD_rank_PositedAt"
        ELSE _now
    END;
    IF
        NEW."SU_ID_keeper" IS DISTINCT FROM OLD."SU_ID_keeper" OR
        NEW."OB_ID_thing" IS DISTINCT FROM OLD."OB_ID_thing" OR
        _GRD_rank IS DISTINCT FROM OLD."GRD_ID_rank" OR
        NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" OR
        NEW."SU_keeper_OB_thing_GRD_rank_PositedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_PositedAt" OR
        NEW."SU_keeper_OB_thing_GRD_rank_Reliability" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_Reliability"
    THEN
        IF
            NEW."SU_ID_keeper" IS NOT NULL
        AND
            NEW."OB_ID_thing" IS NOT NULL
        AND
            _GRD_rank IS NOT NULL
        THEN
            INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
                "Metadata_SU_keeper_OB_thing_GRD_rank",
                "SU_ID_keeper",
                "OB_ID_thing",
                "GRD_ID_rank",
                "SU_keeper_OB_thing_GRD_rank_ChangedAt",
                "SU_keeper_OB_thing_GRD_rank_PositedAt",
                "SU_keeper_OB_thing_GRD_rank_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
                NEW."SU_ID_keeper",
                NEW."OB_ID_thing",
                _GRD_rank,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt" IS DISTINCT FROM OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt" THEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
                    WHEN
                        NEW."SU_ID_keeper" = OLD."SU_ID_keeper"
                    AND
                        NEW."OB_ID_thing" = OLD."OB_ID_thing"
                    AND
                        _GRD_rank = OLD."GRD_ID_rank"
                    THEN NEW."SU_keeper_OB_thing_GRD_rank_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."SU_keeper_OB_thing_GRD_rank_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."SU_keeper_OB_thing_GRD_rank" (
                "Metadata_SU_keeper_OB_thing_GRD_rank",
                "SU_ID_keeper",
                "OB_ID_thing",
                "GRD_ID_rank",
                "SU_keeper_OB_thing_GRD_rank_ChangedAt",
                "SU_keeper_OB_thing_GRD_rank_PositedAt",
                "SU_keeper_OB_thing_GRD_rank_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_keeper_OB_thing_GRD_rank",
                OLD."SU_ID_keeper",
                OLD."OB_ID_thing",
                OLD."GRD_ID_rank",
                OLD."SU_keeper_OB_thing_GRD_rank_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "ut_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF UPDATE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_keeper_OB_thing_GRD_rank"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_keeper_OB_thing_GRD_rank instead of DELETE trigger on lSU_keeper_OB_thing_GRD_rank
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."SU_keeper_OB_thing_GRD_rank_Annex" (
        "Metadata_SU_keeper_OB_thing_GRD_rank",
        "SU_keeper_OB_thing_GRD_rank_ID",
        "SU_keeper_OB_thing_GRD_rank_PositedAt",
        "SU_keeper_OB_thing_GRD_rank_Reliability"
    )
    SELECT
        OLD."Metadata_SU_keeper_OB_thing_GRD_rank",
        OLD."SU_keeper_OB_thing_GRD_rank_ID",
        _now,
        0
    WHERE
        OLD."SU_keeper_OB_thing_GRD_rank_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_keeper_OB_thing_GRD_rank" ON public."lSU_keeper_OB_thing_GRD_rank";
CREATE TRIGGER "dt_lSU_keeper_OB_thing_GRD_rank"
INSTEAD OF DELETE ON public."lSU_keeper_OB_thing_GRD_rank"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_keeper_OB_thing_GRD_rank"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_OB_part_SU_owner tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_OB_part_SU_owner"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."OB_part_SU_owner_Reliability" = 1
            FROM
                public."OB_part_SU_owner_Annex" a
            WHERE
                a."OB_part_SU_owner_ID" = _id
            AND
                a."OB_part_SU_owner_PositedAt" <= _positing
            ORDER BY
                a."OB_part_SU_owner_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_OB_part_SU_owner instead of INSERT trigger on OB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_OB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."OB_part_SU_owner_PositedAt", _now);
    _reliability := coalesce(NEW."OB_part_SU_owner_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."OB_part_SU_owner_ID"
    INTO
        _posit
    FROM
        public."OB_part_SU_owner_Posit" p
    WHERE
        p."OB_ID_part" = NEW."OB_ID_part"
    AND
        p."SU_ID_owner" = NEW."SU_ID_owner"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner_Annex" a
        WHERE
            a."OB_part_SU_owner_ID" = _posit
        AND
            a."OB_part_SU_owner_PositedAt" = _positing
        AND
            a."OB_part_SU_owner_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_part_SU_owner for: %', concat_ws(', ',
            NEW."OB_ID_part",
            NEW."SU_ID_owner",
            _positing);
    END IF;
    -- other values for identifiers that already have values at that time, asserted at the positing time, are a contradiction
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner_Posit" p
        JOIN
            public."OB_part_SU_owner_Annex" a
        ON
            a."OB_part_SU_owner_ID" = p."OB_part_SU_owner_ID"
        WHERE
            p."OB_ID_part" = NEW."OB_ID_part"
        AND
            NOT (
                p."SU_ID_owner" = NEW."SU_ID_owner"
            )
        AND
            a."OB_part_SU_owner_PositedAt" = _positing
        AND
            a."OB_part_SU_owner_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in OB_part_SU_owner for: %', concat_ws(', ',
            NEW."OB_ID_part",
            NEW."SU_ID_owner",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."OB_part_SU_owner_Annex" a
        WHERE
            a."OB_part_SU_owner_ID" = _posit
        AND
            a."OB_part_SU_owner_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT public."ie_OB_part_SU_owner"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."OB_part_SU_owner_Annex" (
            "Metadata_OB_part_SU_owner",
            "OB_part_SU_owner_ID",
            "OB_part_SU_owner_PositedAt",
            "OB_part_SU_owner_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_part_SU_owner", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- an assertion corrects what is asserted at the positing time for the same identifiers (and changing time), when that has
    -- other values: it is retracted at the positing time of the assertion, so that one posit at a time is asserted
    FOR _other IN
        SELECT
            p."OB_part_SU_owner_ID"
        FROM
            public."OB_part_SU_owner_Posit" p
        WHERE
            p."OB_ID_part" = NEW."OB_ID_part"
        AND
            NOT (
                p."SU_ID_owner" = NEW."SU_ID_owner"
            )
        AND
            public."ie_OB_part_SU_owner"(p."OB_part_SU_owner_ID", _positing)
    LOOP
        INSERT INTO public."OB_part_SU_owner_Annex" (
            "Metadata_OB_part_SU_owner",
            "OB_part_SU_owner_ID",
            "OB_part_SU_owner_PositedAt",
            "OB_part_SU_owner_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_OB_part_SU_owner", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."OB_part_SU_owner_Posit" (
            "OB_ID_part",
            "SU_ID_owner",
            "OB_part_SU_owner_ID"
        )
        VALUES (
            NEW."OB_ID_part",
            NEW."SU_ID_owner",
            DEFAULT
        )
        RETURNING "OB_part_SU_owner_ID" INTO _posit;
    END IF;
    INSERT INTO public."OB_part_SU_owner_Annex" (
        "Metadata_OB_part_SU_owner",
        "OB_part_SU_owner_ID",
        "OB_part_SU_owner_PositedAt",
        "OB_part_SU_owner_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_OB_part_SU_owner", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_OB_part_SU_owner" ON public."OB_part_SU_owner";
CREATE TRIGGER "it_OB_part_SU_owner"
INSTEAD OF INSERT ON public."OB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_OB_part_SU_owner"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lOB_part_SU_owner instead of INSERT trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."OB_part_SU_owner" (
        "Metadata_OB_part_SU_owner",
        "OB_ID_part",
        "SU_ID_owner",
        "OB_part_SU_owner_PositedAt",
        "OB_part_SU_owner_Reliability"
    )
    VALUES (
        NEW."Metadata_OB_part_SU_owner",
        NEW."OB_ID_part",
        NEW."SU_ID_owner",
        coalesce(NEW."OB_part_SU_owner_PositedAt", _now),
        coalesce(NEW."OB_part_SU_owner_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "it_lOB_part_SU_owner"
INSTEAD OF INSERT ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."it_lOB_part_SU_owner"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lOB_part_SU_owner instead of UPDATE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
BEGIN
    IF NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part" THEN
        RAISE EXCEPTION 'The identity column OB_ID_part is not updatable.';
    END IF;
    _positing := CASE
        WHEN NEW."OB_part_SU_owner_PositedAt" IS DISTINCT FROM OLD."OB_part_SU_owner_PositedAt" THEN NEW."OB_part_SU_owner_PositedAt"
        ELSE _now
    END;
    IF
        NEW."OB_ID_part" IS DISTINCT FROM OLD."OB_ID_part" OR
        NEW."SU_ID_owner" IS DISTINCT FROM OLD."SU_ID_owner" OR
        NEW."OB_part_SU_owner_PositedAt" IS DISTINCT FROM OLD."OB_part_SU_owner_PositedAt" OR
        NEW."OB_part_SU_owner_Reliability" IS DISTINCT FROM OLD."OB_part_SU_owner_Reliability"
    THEN
        IF
            NEW."OB_ID_part" IS NOT NULL
        AND
            NEW."SU_ID_owner" IS NOT NULL
        THEN
            INSERT INTO public."OB_part_SU_owner" (
                "Metadata_OB_part_SU_owner",
                "OB_ID_part",
                "SU_ID_owner",
                "OB_part_SU_owner_PositedAt",
                "OB_part_SU_owner_Reliability"
            )
            VALUES (
                NEW."Metadata_OB_part_SU_owner",
                NEW."OB_ID_part",
                NEW."SU_ID_owner",
                _positing,
                coalesce(NEW."OB_part_SU_owner_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."OB_part_SU_owner" (
                "Metadata_OB_part_SU_owner",
                "OB_ID_part",
                "SU_ID_owner",
                "OB_part_SU_owner_PositedAt",
                "OB_part_SU_owner_Reliability"
            )
            VALUES (
                NEW."Metadata_OB_part_SU_owner",
                OLD."OB_ID_part",
                OLD."SU_ID_owner",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "ut_lOB_part_SU_owner"
INSTEAD OF UPDATE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."ut_lOB_part_SU_owner"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lOB_part_SU_owner instead of DELETE trigger on lOB_part_SU_owner
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lOB_part_SU_owner"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."OB_part_SU_owner_Annex" (
        "Metadata_OB_part_SU_owner",
        "OB_part_SU_owner_ID",
        "OB_part_SU_owner_PositedAt",
        "OB_part_SU_owner_Reliability"
    )
    SELECT
        OLD."Metadata_OB_part_SU_owner",
        OLD."OB_part_SU_owner_ID",
        _now,
        0
    WHERE
        OLD."OB_part_SU_owner_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lOB_part_SU_owner" ON public."lOB_part_SU_owner";
CREATE TRIGGER "dt_lOB_part_SU_owner"
INSTEAD OF DELETE ON public."lOB_part_SU_owner"
FOR EACH ROW EXECUTE FUNCTION public."dt_lOB_part_SU_owner"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_SU_partner_SU_with tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ie_SU_partner_SU_with"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."SU_partner_SU_with_Reliability" = 1
            FROM
                public."SU_partner_SU_with_Annex" a
            WHERE
                a."SU_partner_SU_with_ID" = _id
            AND
                a."SU_partner_SU_with_PositedAt" <= _positing
            ORDER BY
                a."SU_partner_SU_with_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_SU_partner_SU_with instead of INSERT trigger on SU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_SU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing timestamp;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."SU_partner_SU_with_PositedAt", _now);
    _reliability := coalesce(NEW."SU_partner_SU_with_Reliability", 1);
    _changing := coalesce(NEW."SU_partner_SU_with_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."SU_partner_SU_with_ID"
    INTO
        _posit
    FROM
        public."SU_partner_SU_with_Posit" p
    WHERE
        p."SU_ID_partner" = NEW."SU_ID_partner"
    AND
        p."SU_ID_with" = NEW."SU_ID_with"
    AND
        p."SU_partner_SU_with_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_partner_SU_with_Annex" a
        WHERE
            a."SU_partner_SU_with_ID" = _posit
        AND
            a."SU_partner_SU_with_PositedAt" = _positing
        AND
            a."SU_partner_SU_with_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in SU_partner_SU_with for: %', concat_ws(', ',
            NEW."SU_ID_partner",
            NEW."SU_ID_with",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            public."SU_partner_SU_with_Annex" a
        WHERE
            a."SU_partner_SU_with_ID" = _posit
        AND
            a."SU_partner_SU_with_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT public."ie_SU_partner_SU_with"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO public."SU_partner_SU_with_Annex" (
            "Metadata_SU_partner_SU_with",
            "SU_partner_SU_with_ID",
            "SU_partner_SU_with_PositedAt",
            "SU_partner_SU_with_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_SU_partner_SU_with", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO public."SU_partner_SU_with_Posit" (
            "SU_ID_partner",
            "SU_ID_with",
            "SU_partner_SU_with_ChangedAt"
        )
        VALUES (
            NEW."SU_ID_partner",
            NEW."SU_ID_with",
            _changing
        )
        RETURNING "SU_partner_SU_with_ID" INTO _posit;
    END IF;
    INSERT INTO public."SU_partner_SU_with_Annex" (
        "Metadata_SU_partner_SU_with",
        "SU_partner_SU_with_ID",
        "SU_partner_SU_with_PositedAt",
        "SU_partner_SU_with_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_SU_partner_SU_with", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_SU_partner_SU_with" ON public."SU_partner_SU_with";
CREATE TRIGGER "it_SU_partner_SU_with"
INSTEAD OF INSERT ON public."SU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_SU_partner_SU_with"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lSU_partner_SU_with instead of INSERT trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."it_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO public."SU_partner_SU_with" (
        "Metadata_SU_partner_SU_with",
        "SU_ID_partner",
        "SU_ID_with",
        "SU_partner_SU_with_ChangedAt",
        "SU_partner_SU_with_PositedAt",
        "SU_partner_SU_with_Reliability"
    )
    VALUES (
        NEW."Metadata_SU_partner_SU_with",
        NEW."SU_ID_partner",
        NEW."SU_ID_with",
        coalesce(NEW."SU_partner_SU_with_ChangedAt", _now),
        coalesce(NEW."SU_partner_SU_with_PositedAt", _now),
        coalesce(NEW."SU_partner_SU_with_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "it_lSU_partner_SU_with"
INSTEAD OF INSERT ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."it_lSU_partner_SU_with"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lSU_partner_SU_with instead of UPDATE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."ut_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
BEGIN
    _positing := CASE
        WHEN NEW."SU_partner_SU_with_PositedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_PositedAt" THEN NEW."SU_partner_SU_with_PositedAt"
        ELSE _now
    END;
    IF
        NEW."SU_ID_partner" IS DISTINCT FROM OLD."SU_ID_partner" OR
        NEW."SU_ID_with" IS DISTINCT FROM OLD."SU_ID_with" OR
        NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" OR
        NEW."SU_partner_SU_with_PositedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_PositedAt" OR
        NEW."SU_partner_SU_with_Reliability" IS DISTINCT FROM OLD."SU_partner_SU_with_Reliability"
    THEN
        IF
            NEW."SU_ID_partner" IS NOT NULL
        AND
            NEW."SU_ID_with" IS NOT NULL
        THEN
            INSERT INTO public."SU_partner_SU_with" (
                "Metadata_SU_partner_SU_with",
                "SU_ID_partner",
                "SU_ID_with",
                "SU_partner_SU_with_ChangedAt",
                "SU_partner_SU_with_PositedAt",
                "SU_partner_SU_with_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_partner_SU_with",
                NEW."SU_ID_partner",
                NEW."SU_ID_with",
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."SU_partner_SU_with_ChangedAt" IS DISTINCT FROM OLD."SU_partner_SU_with_ChangedAt" THEN NEW."SU_partner_SU_with_ChangedAt"
                    WHEN
                        NEW."SU_ID_partner" = OLD."SU_ID_partner"
                    AND
                        NEW."SU_ID_with" = OLD."SU_ID_with"
                    THEN NEW."SU_partner_SU_with_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."SU_partner_SU_with_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO public."SU_partner_SU_with" (
                "Metadata_SU_partner_SU_with",
                "SU_ID_partner",
                "SU_ID_with",
                "SU_partner_SU_with_ChangedAt",
                "SU_partner_SU_with_PositedAt",
                "SU_partner_SU_with_Reliability"
            )
            VALUES (
                NEW."Metadata_SU_partner_SU_with",
                OLD."SU_ID_partner",
                OLD."SU_ID_with",
                OLD."SU_partner_SU_with_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "ut_lSU_partner_SU_with"
INSTEAD OF UPDATE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."ut_lSU_partner_SU_with"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lSU_partner_SU_with instead of DELETE trigger on lSU_partner_SU_with
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public."dt_lSU_partner_SU_with"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO public."SU_partner_SU_with_Annex" (
        "Metadata_SU_partner_SU_with",
        "SU_partner_SU_with_ID",
        "SU_partner_SU_with_PositedAt",
        "SU_partner_SU_with_Reliability"
    )
    SELECT
        OLD."Metadata_SU_partner_SU_with",
        OLD."SU_partner_SU_with_ID",
        _now,
        0
    WHERE
        OLD."SU_partner_SU_with_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lSU_partner_SU_with" ON public."lSU_partner_SU_with";
CREATE TRIGGER "dt_lSU_partner_SU_with"
INSTEAD OF DELETE ON public."lSU_partner_SU_with"
FOR EACH ROW EXECUTE FUNCTION public."dt_lSU_partner_SU_with"();
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA public IS 'A model for testing the triggers of the latest views: an attribute for each combination of the settings that the triggers read (restatable, idempotent, assertive, deletable, checksum, knotted, static or historized), ties with and without identifiers, and a nexus with an attribute. The scripts in sqlserver-tests/ run against its output.';
COMMENT ON TABLE public."GRD_Grade" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN public."GRD_Grade"."GRD_Grade" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON COLUMN public."EV_QTY_Event_Quantity_Posit"."EV_QTY_Event_Quantity" IS 'Static.';
COMMENT ON COLUMN public."EV_PLC_Event_Place_Posit"."EV_PLC_Event_Place" IS 'Historized and not restatable, as an attribute of an anchor may be.';
COMMENT ON COLUMN public."SU_NAM_Subject_Name_Posit"."SU_NAM_Subject_Name" IS 'Static.';
COMMENT ON COLUMN public."SU_COD_Subject_Code_Posit"."SU_COD_Subject_Code" IS 'Static and idempotent.';
COMMENT ON COLUMN public."SU_GRD_Subject_Grade_Posit"."SU_GRD_GRD_ID" IS 'Static and knotted.';
COMMENT ON COLUMN public."SU_NOT_Subject_Note_Posit"."SU_NOT_Subject_Note" IS 'Static, with a checksum.';
COMMENT ON COLUMN public."SU_TTL_Subject_Title_Posit"."SU_TTL_Subject_Title" IS 'Historized, restatable.';
COMMENT ON COLUMN public."SU_STA_Subject_State_Posit"."SU_STA_Subject_State" IS 'Historized, not restatable: a restatement is an error.';
COMMENT ON COLUMN public."SU_LBL_Subject_Label_Posit"."SU_LBL_Subject_Label" IS 'Historized, not restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN public."SU_TAG_Subject_Tag_Posit"."SU_TAG_Subject_Tag" IS 'Historized, restatable and idempotent: a restatement is skipped.';
COMMENT ON COLUMN public."SU_LVL_Subject_Level_Posit"."SU_LVL_GRD_ID" IS 'Historized and knotted.';
COMMENT ON COLUMN public."SU_TXT_Subject_Text_Posit"."SU_TXT_Subject_Text" IS 'Historized, with a checksum.';
COMMENT ON COLUMN public."SU_ASR_Subject_Assessment_Posit"."SU_ASR_Subject_Assessment" IS 'Historized, not assertive: a re-assertion is skipped (bitemporal and concurrent-reliance-temporal).';
COMMENT ON COLUMN public."SU_ERS_Subject_Erasable_Posit"."SU_ERS_Subject_Erasable" IS 'Historized and deletable (uni-temporal).';
COMMENT ON COLUMN public."OB_NAM_Object_Name_Posit"."OB_NAM_Object_Name" IS 'Static.';
COMMENT ON TABLE public."SU_Subject" IS 'The subject of the tests.';
COMMENT ON TABLE public."OB_Object" IS 'Something the subject has or keeps.';
COMMENT ON TABLE public."EV_Event" IS 'An event, with attributes of its own, a static one and a historized one.';
COMMENT ON COLUMN public."EV_Event"."SU_ID_for" IS 'The subject the event is for.';
COMMENT ON TABLE public."SU_holder_OB_item_GRD_grade_Posit" IS 'Historized, with identifiers and a knotted value role, restatable.';
COMMENT ON COLUMN public."SU_holder_OB_item_GRD_grade_Posit"."SU_ID_holder" IS 'The subject of the tests.';
COMMENT ON COLUMN public."SU_holder_OB_item_GRD_grade_Posit"."OB_ID_item" IS 'Something the subject has or keeps.';
COMMENT ON COLUMN public."SU_holder_OB_item_GRD_grade_Posit"."GRD_ID_grade" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE public."SU_keeper_OB_thing_GRD_rank_Posit" IS 'Historized, with identifiers and a knotted value role, idempotent and not assertive.';
COMMENT ON COLUMN public."SU_keeper_OB_thing_GRD_rank_Posit"."SU_ID_keeper" IS 'The subject of the tests.';
COMMENT ON COLUMN public."SU_keeper_OB_thing_GRD_rank_Posit"."OB_ID_thing" IS 'Something the subject has or keeps.';
COMMENT ON COLUMN public."SU_keeper_OB_thing_GRD_rank_Posit"."GRD_ID_rank" IS 'A grade, used by knotted attributes and by the value roles of ties.';
COMMENT ON TABLE public."OB_part_SU_owner_Posit" IS 'Static, with an identifier and a value role: each object has one owner.';
COMMENT ON COLUMN public."OB_part_SU_owner_Posit"."OB_ID_part" IS 'Something the subject has or keeps.';
COMMENT ON COLUMN public."OB_part_SU_owner_Posit"."SU_ID_owner" IS 'The subject of the tests.';
COMMENT ON TABLE public."SU_partner_SU_with_Posit" IS 'Historized, without identifiers.';
COMMENT ON COLUMN public."SU_partner_SU_with_Posit"."SU_ID_partner" IS 'The subject of the tests.';
COMMENT ON COLUMN public."SU_partner_SU_with_Posit"."SU_ID_with" IS 'The subject of the tests.';
