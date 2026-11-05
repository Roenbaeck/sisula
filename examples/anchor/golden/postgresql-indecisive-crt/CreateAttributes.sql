-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_QTY_Event_Quantity_Annex table (of EV_QTY_Event_Quantity_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_QTY_Event_Quantity_Annex" (
    "EV_QTY_ID" integer not null,
    "EV_QTY_PositedAt" timestamp not null,
    "EV_QTY_Positor" smallint not null,
    "EV_QTY_Reliability" decimal(5,2) not null,
    "EV_QTY_Assertion" char(1) generated always as (
        case
            when "EV_QTY_Reliability" > 0 then '+'
            when "EV_QTY_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_QTY" integer not null,
    constraint "fkEV_QTY_Event_Quantity_Annex" foreign key (
        "EV_QTY_ID"
    ) references public."EV_QTY_Event_Quantity_Posit"("EV_QTY_ID"),
    constraint "pkEV_QTY_Event_Quantity_Annex" primary key (
        "EV_QTY_ID",
        "EV_QTY_Positor",
        "EV_QTY_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_PLC_Event_Place_Posit table (on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_PLC_Event_Place_Annex table (of EV_PLC_Event_Place_Posit on EV_Event)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."EV_PLC_Event_Place_Annex" (
    "EV_PLC_ID" integer not null,
    "EV_PLC_PositedAt" timestamp not null,
    "EV_PLC_Positor" smallint not null,
    "EV_PLC_Reliability" decimal(5,2) not null,
    "EV_PLC_Assertion" char(1) generated always as (
        case
            when "EV_PLC_Reliability" > 0 then '+'
            when "EV_PLC_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_EV_PLC" integer not null,
    constraint "fkEV_PLC_Event_Place_Annex" foreign key (
        "EV_PLC_ID"
    ) references public."EV_PLC_Event_Place_Posit"("EV_PLC_ID"),
    constraint "pkEV_PLC_Event_Place_Annex" primary key (
        "EV_PLC_ID",
        "EV_PLC_Positor",
        "EV_PLC_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- SU_NAM_Subject_Name_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_NAM_Subject_Name_Annex table (of SU_NAM_Subject_Name_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_NAM_Subject_Name_Annex" (
    "SU_NAM_ID" integer not null,
    "SU_NAM_PositedAt" timestamp not null,
    "SU_NAM_Positor" smallint not null,
    "SU_NAM_Reliability" decimal(5,2) not null,
    "SU_NAM_Assertion" char(1) generated always as (
        case
            when "SU_NAM_Reliability" > 0 then '+'
            when "SU_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_NAM" integer not null,
    constraint "fkSU_NAM_Subject_Name_Annex" foreign key (
        "SU_NAM_ID"
    ) references public."SU_NAM_Subject_Name_Posit"("SU_NAM_ID"),
    constraint "pkSU_NAM_Subject_Name_Annex" primary key (
        "SU_NAM_ID",
        "SU_NAM_Positor",
        "SU_NAM_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- SU_COD_Subject_Code_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_COD_Subject_Code_Annex table (of SU_COD_Subject_Code_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_COD_Subject_Code_Annex" (
    "SU_COD_ID" integer not null,
    "SU_COD_PositedAt" timestamp not null,
    "SU_COD_Positor" smallint not null,
    "SU_COD_Reliability" decimal(5,2) not null,
    "SU_COD_Assertion" char(1) generated always as (
        case
            when "SU_COD_Reliability" > 0 then '+'
            when "SU_COD_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_COD" integer not null,
    constraint "fkSU_COD_Subject_Code_Annex" foreign key (
        "SU_COD_ID"
    ) references public."SU_COD_Subject_Code_Posit"("SU_COD_ID"),
    constraint "pkSU_COD_Subject_Code_Annex" primary key (
        "SU_COD_ID",
        "SU_COD_Positor",
        "SU_COD_PositedAt"
    )
);
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_GRD_Subject_Grade_Annex table (of SU_GRD_Subject_Grade_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_GRD_Subject_Grade_Annex" (
    "SU_GRD_ID" integer not null,
    "SU_GRD_PositedAt" timestamp not null,
    "SU_GRD_Positor" smallint not null,
    "SU_GRD_Reliability" decimal(5,2) not null,
    "SU_GRD_Assertion" char(1) generated always as (
        case
            when "SU_GRD_Reliability" > 0 then '+'
            when "SU_GRD_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_GRD" integer not null,
    constraint "fkSU_GRD_Subject_Grade_Annex" foreign key (
        "SU_GRD_ID"
    ) references public."SU_GRD_Subject_Grade_Posit"("SU_GRD_ID"),
    constraint "pkSU_GRD_Subject_Grade_Annex" primary key (
        "SU_GRD_ID",
        "SU_GRD_Positor",
        "SU_GRD_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- SU_NOT_Subject_Note_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_NOT_Subject_Note_Annex table (of SU_NOT_Subject_Note_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_NOT_Subject_Note_Annex" (
    "SU_NOT_ID" integer not null,
    "SU_NOT_PositedAt" timestamp not null,
    "SU_NOT_Positor" smallint not null,
    "SU_NOT_Reliability" decimal(5,2) not null,
    "SU_NOT_Assertion" char(1) generated always as (
        case
            when "SU_NOT_Reliability" > 0 then '+'
            when "SU_NOT_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_NOT" integer not null,
    constraint "fkSU_NOT_Subject_Note_Annex" foreign key (
        "SU_NOT_ID"
    ) references public."SU_NOT_Subject_Note_Posit"("SU_NOT_ID"),
    constraint "pkSU_NOT_Subject_Note_Annex" primary key (
        "SU_NOT_ID",
        "SU_NOT_Positor",
        "SU_NOT_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TTL_Subject_Title_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TTL_Subject_Title_Annex table (of SU_TTL_Subject_Title_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TTL_Subject_Title_Annex" (
    "SU_TTL_ID" integer not null,
    "SU_TTL_PositedAt" timestamp not null,
    "SU_TTL_Positor" smallint not null,
    "SU_TTL_Reliability" decimal(5,2) not null,
    "SU_TTL_Assertion" char(1) generated always as (
        case
            when "SU_TTL_Reliability" > 0 then '+'
            when "SU_TTL_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_TTL" integer not null,
    constraint "fkSU_TTL_Subject_Title_Annex" foreign key (
        "SU_TTL_ID"
    ) references public."SU_TTL_Subject_Title_Posit"("SU_TTL_ID"),
    constraint "pkSU_TTL_Subject_Title_Annex" primary key (
        "SU_TTL_ID",
        "SU_TTL_Positor",
        "SU_TTL_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_STA_Subject_State_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_STA_Subject_State_Annex table (of SU_STA_Subject_State_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_STA_Subject_State_Annex" (
    "SU_STA_ID" integer not null,
    "SU_STA_PositedAt" timestamp not null,
    "SU_STA_Positor" smallint not null,
    "SU_STA_Reliability" decimal(5,2) not null,
    "SU_STA_Assertion" char(1) generated always as (
        case
            when "SU_STA_Reliability" > 0 then '+'
            when "SU_STA_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_STA" integer not null,
    constraint "fkSU_STA_Subject_State_Annex" foreign key (
        "SU_STA_ID"
    ) references public."SU_STA_Subject_State_Posit"("SU_STA_ID"),
    constraint "pkSU_STA_Subject_State_Annex" primary key (
        "SU_STA_ID",
        "SU_STA_Positor",
        "SU_STA_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_LBL_Subject_Label_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_LBL_Subject_Label_Annex table (of SU_LBL_Subject_Label_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_LBL_Subject_Label_Annex" (
    "SU_LBL_ID" integer not null,
    "SU_LBL_PositedAt" timestamp not null,
    "SU_LBL_Positor" smallint not null,
    "SU_LBL_Reliability" decimal(5,2) not null,
    "SU_LBL_Assertion" char(1) generated always as (
        case
            when "SU_LBL_Reliability" > 0 then '+'
            when "SU_LBL_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_LBL" integer not null,
    constraint "fkSU_LBL_Subject_Label_Annex" foreign key (
        "SU_LBL_ID"
    ) references public."SU_LBL_Subject_Label_Posit"("SU_LBL_ID"),
    constraint "pkSU_LBL_Subject_Label_Annex" primary key (
        "SU_LBL_ID",
        "SU_LBL_Positor",
        "SU_LBL_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TAG_Subject_Tag_Annex table (of SU_TAG_Subject_Tag_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TAG_Subject_Tag_Annex" (
    "SU_TAG_ID" integer not null,
    "SU_TAG_PositedAt" timestamp not null,
    "SU_TAG_Positor" smallint not null,
    "SU_TAG_Reliability" decimal(5,2) not null,
    "SU_TAG_Assertion" char(1) generated always as (
        case
            when "SU_TAG_Reliability" > 0 then '+'
            when "SU_TAG_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_TAG" integer not null,
    constraint "fkSU_TAG_Subject_Tag_Annex" foreign key (
        "SU_TAG_ID"
    ) references public."SU_TAG_Subject_Tag_Posit"("SU_TAG_ID"),
    constraint "pkSU_TAG_Subject_Tag_Annex" primary key (
        "SU_TAG_ID",
        "SU_TAG_Positor",
        "SU_TAG_PositedAt"
    )
);
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- SU_LVL_Subject_Level_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_LVL_Subject_Level_Annex table (of SU_LVL_Subject_Level_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_LVL_Subject_Level_Annex" (
    "SU_LVL_ID" integer not null,
    "SU_LVL_PositedAt" timestamp not null,
    "SU_LVL_Positor" smallint not null,
    "SU_LVL_Reliability" decimal(5,2) not null,
    "SU_LVL_Assertion" char(1) generated always as (
        case
            when "SU_LVL_Reliability" > 0 then '+'
            when "SU_LVL_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_LVL" integer not null,
    constraint "fkSU_LVL_Subject_Level_Annex" foreign key (
        "SU_LVL_ID"
    ) references public."SU_LVL_Subject_Level_Posit"("SU_LVL_ID"),
    constraint "pkSU_LVL_Subject_Level_Annex" primary key (
        "SU_LVL_ID",
        "SU_LVL_Positor",
        "SU_LVL_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_TXT_Subject_Text_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_TXT_Subject_Text_Annex table (of SU_TXT_Subject_Text_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_TXT_Subject_Text_Annex" (
    "SU_TXT_ID" integer not null,
    "SU_TXT_PositedAt" timestamp not null,
    "SU_TXT_Positor" smallint not null,
    "SU_TXT_Reliability" decimal(5,2) not null,
    "SU_TXT_Assertion" char(1) generated always as (
        case
            when "SU_TXT_Reliability" > 0 then '+'
            when "SU_TXT_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_TXT" integer not null,
    constraint "fkSU_TXT_Subject_Text_Annex" foreign key (
        "SU_TXT_ID"
    ) references public."SU_TXT_Subject_Text_Posit"("SU_TXT_ID"),
    constraint "pkSU_TXT_Subject_Text_Annex" primary key (
        "SU_TXT_ID",
        "SU_TXT_Positor",
        "SU_TXT_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_ASR_Subject_Assessment_Annex table (of SU_ASR_Subject_Assessment_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_ASR_Subject_Assessment_Annex" (
    "SU_ASR_ID" integer not null,
    "SU_ASR_PositedAt" timestamp not null,
    "SU_ASR_Positor" smallint not null,
    "SU_ASR_Reliability" decimal(5,2) not null,
    "SU_ASR_Assertion" char(1) generated always as (
        case
            when "SU_ASR_Reliability" > 0 then '+'
            when "SU_ASR_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_ASR" integer not null,
    constraint "fkSU_ASR_Subject_Assessment_Annex" foreign key (
        "SU_ASR_ID"
    ) references public."SU_ASR_Subject_Assessment_Posit"("SU_ASR_ID"),
    constraint "pkSU_ASR_Subject_Assessment_Annex" primary key (
        "SU_ASR_ID",
        "SU_ASR_Positor",
        "SU_ASR_PositedAt"
    )
);
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable_Posit table (on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- SU_ERS_Subject_Erasable_Annex table (of SU_ERS_Subject_Erasable_Posit on SU_Subject)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."SU_ERS_Subject_Erasable_Annex" (
    "SU_ERS_ID" integer not null,
    "SU_ERS_PositedAt" timestamp not null,
    "SU_ERS_Positor" smallint not null,
    "SU_ERS_Reliability" decimal(5,2) not null,
    "SU_ERS_Assertion" char(1) generated always as (
        case
            when "SU_ERS_Reliability" > 0 then '+'
            when "SU_ERS_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_SU_ERS" integer not null,
    constraint "fkSU_ERS_Subject_Erasable_Annex" foreign key (
        "SU_ERS_ID"
    ) references public."SU_ERS_Subject_Erasable_Posit"("SU_ERS_ID"),
    constraint "pkSU_ERS_Subject_Erasable_Annex" primary key (
        "SU_ERS_ID",
        "SU_ERS_Positor",
        "SU_ERS_PositedAt"
    )
);
-- Static attribute posit table -----------------------------------------------------------------------------------
-- OB_NAM_Object_Name_Posit table (on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
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
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- OB_NAM_Object_Name_Annex table (of OB_NAM_Object_Name_Posit on OB_Object)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public."OB_NAM_Object_Name_Annex" (
    "OB_NAM_ID" integer not null,
    "OB_NAM_PositedAt" timestamp not null,
    "OB_NAM_Positor" smallint not null,
    "OB_NAM_Reliability" decimal(5,2) not null,
    "OB_NAM_Assertion" char(1) generated always as (
        case
            when "OB_NAM_Reliability" > 0 then '+'
            when "OB_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ) stored,
    "Metadata_OB_NAM" integer not null,
    constraint "fkOB_NAM_Object_Name_Annex" foreign key (
        "OB_NAM_ID"
    ) references public."OB_NAM_Object_Name_Posit"("OB_NAM_ID"),
    constraint "pkOB_NAM_Object_Name_Annex" primary key (
        "OB_NAM_ID",
        "OB_NAM_Positor",
        "OB_NAM_PositedAt"
    )
);
