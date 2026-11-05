-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_QTY_Event_Quantity" (
    "EV_QTY_EV_ID" integer not null,
    "EV_QTY_Event_Quantity" integer not null,
    "Metadata_EV_QTY" integer not null,
    constraint "fkEV_QTY_Event_Quantity" foreign key (
        "EV_QTY_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_QTY_Event_Quantity" primary key (
        "EV_QTY_EV_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_PLC_Event_Place table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_PLC_Event_Place" (
    "EV_PLC_EV_ID" integer not null,
    "EV_PLC_Event_Place" varchar(42) not null,
    "EV_PLC_ChangedAt" timestamp not null,
    "Metadata_EV_PLC" integer not null,
    constraint "fkEV_PLC_Event_Place" foreign key (
        "EV_PLC_EV_ID"
    ) references public."EV_Event"("EV_ID"),
    constraint "pkEV_PLC_Event_Place" primary key (
        "EV_PLC_EV_ID",
        "EV_PLC_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_NAM_Subject_Name" (
    "SU_NAM_SU_ID" integer not null,
    "SU_NAM_Subject_Name" varchar(42) not null,
    "Metadata_SU_NAM" integer not null,
    constraint "fkSU_NAM_Subject_Name" foreign key (
        "SU_NAM_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_NAM_Subject_Name" primary key (
        "SU_NAM_SU_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_COD_Subject_Code" (
    "SU_COD_SU_ID" integer not null,
    "SU_COD_Subject_Code" varchar(42) not null,
    "Metadata_SU_COD" integer not null,
    constraint "fkSU_COD_Subject_Code" foreign key (
        "SU_COD_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_COD_Subject_Code" primary key (
        "SU_COD_SU_ID"
    )
);
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_GRD_Subject_Grade" (
    "SU_GRD_SU_ID" integer not null,
    "SU_GRD_GRD_ID" smallint not null,
    "Metadata_SU_GRD" integer not null,
    constraint "fk_A_SU_GRD_Subject_Grade" foreign key (
        "SU_GRD_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "fk_K_SU_GRD_Subject_Grade" foreign key (
        "SU_GRD_GRD_ID"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_GRD_Subject_Grade" primary key (
        "SU_GRD_SU_ID"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_NOT_Subject_Note" (
    "SU_NOT_SU_ID" integer not null,
    "SU_NOT_Subject_Note" text not null,
    "SU_NOT_Checksum" bytea generated always as (decode(md5("SU_NOT_Subject_Note"::text), 'hex')) stored,
    "Metadata_SU_NOT" integer not null,
    constraint "fkSU_NOT_Subject_Note" foreign key (
        "SU_NOT_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_NOT_Subject_Note" primary key (
        "SU_NOT_SU_ID"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TTL_Subject_Title" (
    "SU_TTL_SU_ID" integer not null,
    "SU_TTL_Subject_Title" varchar(42) not null,
    "SU_TTL_ChangedAt" timestamp not null,
    "Metadata_SU_TTL" integer not null,
    constraint "fkSU_TTL_Subject_Title" foreign key (
        "SU_TTL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TTL_Subject_Title" primary key (
        "SU_TTL_SU_ID",
        "SU_TTL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_STA_Subject_State table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_STA_Subject_State" (
    "SU_STA_SU_ID" integer not null,
    "SU_STA_Subject_State" varchar(42) not null,
    "SU_STA_ChangedAt" timestamp not null,
    "Metadata_SU_STA" integer not null,
    constraint "fkSU_STA_Subject_State" foreign key (
        "SU_STA_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_STA_Subject_State" primary key (
        "SU_STA_SU_ID",
        "SU_STA_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_LBL_Subject_Label" (
    "SU_LBL_SU_ID" integer not null,
    "SU_LBL_Subject_Label" varchar(42) not null,
    "SU_LBL_ChangedAt" timestamp not null,
    "Metadata_SU_LBL" integer not null,
    constraint "fkSU_LBL_Subject_Label" foreign key (
        "SU_LBL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_LBL_Subject_Label" primary key (
        "SU_LBL_SU_ID",
        "SU_LBL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TAG_Subject_Tag" (
    "SU_TAG_SU_ID" integer not null,
    "SU_TAG_Subject_Tag" varchar(42) not null,
    "SU_TAG_ChangedAt" timestamp not null,
    "Metadata_SU_TAG" integer not null,
    constraint "fkSU_TAG_Subject_Tag" foreign key (
        "SU_TAG_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TAG_Subject_Tag" primary key (
        "SU_TAG_SU_ID",
        "SU_TAG_ChangedAt"
    )
);
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- SU_LVL_Subject_Level table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_LVL_Subject_Level" (
    "SU_LVL_SU_ID" integer not null,
    "SU_LVL_GRD_ID" smallint not null,
    "SU_LVL_ChangedAt" timestamp not null,
    "Metadata_SU_LVL" integer not null,
    constraint "fk_A_SU_LVL_Subject_Level" foreign key (
        "SU_LVL_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "fk_K_SU_LVL_Subject_Level" foreign key (
        "SU_LVL_GRD_ID"
    ) references public."GRD_Grade"("GRD_ID"),
    constraint "pkSU_LVL_Subject_Level" primary key (
        "SU_LVL_SU_ID",
        "SU_LVL_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TXT_Subject_Text" (
    "SU_TXT_SU_ID" integer not null,
    "SU_TXT_Subject_Text" text not null,
    "SU_TXT_Checksum" bytea generated always as (decode(md5("SU_TXT_Subject_Text"::text), 'hex')) stored,
    "SU_TXT_ChangedAt" timestamp not null,
    "Metadata_SU_TXT" integer not null,
    constraint "fkSU_TXT_Subject_Text" foreign key (
        "SU_TXT_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_TXT_Subject_Text" primary key (
        "SU_TXT_SU_ID",
        "SU_TXT_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_ASR_Subject_Assessment" (
    "SU_ASR_SU_ID" integer not null,
    "SU_ASR_Subject_Assessment" varchar(42) not null,
    "SU_ASR_ChangedAt" timestamp not null,
    "Metadata_SU_ASR" integer not null,
    constraint "fkSU_ASR_Subject_Assessment" foreign key (
        "SU_ASR_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_ASR_Subject_Assessment" primary key (
        "SU_ASR_SU_ID",
        "SU_ASR_ChangedAt"
    )
);
-- Historized attribute table -----------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_ERS_Subject_Erasable" (
    "SU_ERS_SU_ID" integer not null,
    "SU_ERS_Subject_Erasable" varchar(42) not null,
    "SU_ERS_ChangedAt" timestamp not null,
    "Metadata_SU_ERS" integer not null,
    constraint "fkSU_ERS_Subject_Erasable" foreign key (
        "SU_ERS_SU_ID"
    ) references public."SU_Subject"("SU_ID"),
    constraint "pkSU_ERS_Subject_Erasable" primary key (
        "SU_ERS_SU_ID",
        "SU_ERS_ChangedAt"
    )
);
-- Static attribute table ---------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name table (on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."OB_NAM_Object_Name" (
    "OB_NAM_OB_ID" integer not null,
    "OB_NAM_Object_Name" varchar(42) not null,
    "Metadata_OB_NAM" integer not null,
    constraint "fkOB_NAM_Object_Name" foreign key (
        "OB_NAM_OB_ID"
    ) references public."OB_Object"("OB_ID"),
    constraint "pkOB_NAM_Object_Name" primary key (
        "OB_NAM_OB_ID"
    )
);
