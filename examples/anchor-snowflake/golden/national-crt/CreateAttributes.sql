-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Posit" (
    "EV_DAT_ID" int default attributes."EV_DAT_Händelse_Datum_Posit_ID_SEQ".nextval not null, 
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Händelse_Datum" datetime not null,
    constraint "fkEV_DAT_Händelse_Datum_Posit" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_DAT_Händelse_Datum_Posit" primary key (
        "EV_DAT_ID"
    ) RELY,
    constraint "uqEV_DAT_Händelse_Datum_Posit" unique (
        "EV_DAT_EV_ID",
        "EV_DAT_Händelse_Datum"
    ) RELY
) CLUSTER BY ("EV_DAT_EV_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum_Annex table (of EV_DAT_Händelse_Datum_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Annex" (
    "EV_DAT_ID" int not null,
    "EV_DAT_PositedAt" datetime not null,
    "EV_DAT_Positor" tinyint not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "EV_DAT_Assertion" string default (
        case
            when "EV_DAT_Reliability" > 0 then '+'
            when "EV_DAT_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_EV_DAT" int not null,
    constraint "fkEV_DAT_Händelse_Datum_Annex" foreign key (
        "EV_DAT_ID"
    ) references attributes."EV_DAT_Händelse_Datum_Posit"("EV_DAT_ID") RELY,
    constraint "pkEV_DAT_Händelse_Datum_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_Positor",
        "EV_DAT_PositedAt"
    ) RELY
) CLUSTER BY ("EV_DAT_ID", "EV_DAT_Positor", "EV_DAT_PositedAt");
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Posit" (
    "EV_AUD_ID" int default attributes."EV_AUD_Händelse_Publik_Posit_ID_SEQ".nextval not null, 
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_Händelse_Publik" int not null,
    constraint "fkEV_AUD_Händelse_Publik_Posit" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_AUD_Händelse_Publik_Posit" primary key (
        "EV_AUD_ID"
    ) RELY,
    constraint "uqEV_AUD_Händelse_Publik_Posit" unique (
        "EV_AUD_EV_ID",
        "EV_AUD_Händelse_Publik"
    ) RELY
) CLUSTER BY ("EV_AUD_EV_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik_Annex table (of EV_AUD_Händelse_Publik_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Annex" (
    "EV_AUD_ID" int not null,
    "EV_AUD_PositedAt" datetime not null,
    "EV_AUD_Positor" tinyint not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "EV_AUD_Assertion" string default (
        case
            when "EV_AUD_Reliability" > 0 then '+'
            when "EV_AUD_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_EV_AUD" int not null,
    constraint "fkEV_AUD_Händelse_Publik_Annex" foreign key (
        "EV_AUD_ID"
    ) references attributes."EV_AUD_Händelse_Publik_Posit"("EV_AUD_ID") RELY,
    constraint "pkEV_AUD_Händelse_Publik_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_Positor",
        "EV_AUD_PositedAt"
    ) RELY
) CLUSTER BY ("EV_AUD_ID", "EV_AUD_Positor", "EV_AUD_PositedAt");
-- Static attribute posit table -----------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Posit" (
    "EV_REV_ID" int default attributes."EV_REV_Händelse_Intäkt_Posit_ID_SEQ".nextval not null, 
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_Händelse_Intäkt" number(19,4) not null,
    constraint "fkEV_REV_Händelse_Intäkt_Posit" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_REV_Händelse_Intäkt_Posit" primary key (
        "EV_REV_ID"
    ) RELY,
    constraint "uqEV_REV_Händelse_Intäkt_Posit" unique (
        "EV_REV_EV_ID",
        "EV_REV_Händelse_Intäkt"
    ) RELY
) CLUSTER BY ("EV_REV_EV_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt_Annex table (of EV_REV_Händelse_Intäkt_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Annex" (
    "EV_REV_ID" int not null,
    "EV_REV_PositedAt" datetime not null,
    "EV_REV_Positor" tinyint not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "EV_REV_Assertion" string default (
        case
            when "EV_REV_Reliability" > 0 then '+'
            when "EV_REV_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_EV_REV" int not null,
    constraint "fkEV_REV_Händelse_Intäkt_Annex" foreign key (
        "EV_REV_ID"
    ) references attributes."EV_REV_Händelse_Intäkt_Posit"("EV_REV_ID") RELY,
    constraint "pkEV_REV_Händelse_Intäkt_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_Positor",
        "EV_REV_PositedAt"
    ) RELY
) CLUSTER BY ("EV_REV_ID", "EV_REV_Positor", "EV_REV_PositedAt");
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Posit" (
    "EV_STA_ID" int default attributes."EV_STA_Händelse_Status_Posit_ID_SEQ".nextval not null, 
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_Händelse_Status" varchar(20) not null,
    "EV_STA_ChangedAt" datetime not null,
    constraint "fkEV_STA_Händelse_Status_Posit" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_STA_Händelse_Status_Posit" primary key (
        "EV_STA_ID"
    ) RELY,
    constraint "uqEV_STA_Händelse_Status_Posit" unique (
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt",
        "EV_STA_Händelse_Status"
    ) RELY
) CLUSTER BY ("EV_STA_EV_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status_Annex table (of EV_STA_Händelse_Status_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Annex" (
    "EV_STA_ID" int not null,
    "EV_STA_PositedAt" datetime not null,
    "EV_STA_Positor" tinyint not null,
    "EV_STA_Reliability" decimal(5,2) not null,
    "EV_STA_Assertion" string default (
        case
            when "EV_STA_Reliability" > 0 then '+'
            when "EV_STA_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_EV_STA" int not null,
    constraint "fkEV_STA_Händelse_Status_Annex" foreign key (
        "EV_STA_ID"
    ) references attributes."EV_STA_Händelse_Status_Posit"("EV_STA_ID") RELY,
    constraint "pkEV_STA_Händelse_Status_Annex" primary key (
        "EV_STA_ID",
        "EV_STA_Positor",
        "EV_STA_PositedAt"
    ) RELY
) CLUSTER BY ("EV_STA_ID", "EV_STA_Positor", "EV_STA_PositedAt");
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Posit" (
    "EV_UTL_ID" int default attributes."EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ".nextval not null, 
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" tinyint not null,
    constraint "fk_A_EV_UTL_Händelse_Utnyttjande_Posit" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "fk_K_EV_UTL_Händelse_Utnyttjande_Posit" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkEV_UTL_Händelse_Utnyttjande_Posit" primary key (
        "EV_UTL_ID"
    ) RELY,
    constraint "uqEV_UTL_Händelse_Utnyttjande_Posit" unique (
        "EV_UTL_EV_ID",
        "EV_UTL_UTL_ID"
    ) RELY
) CLUSTER BY ("EV_UTL_EV_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande_Annex table (of EV_UTL_Händelse_Utnyttjande_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
    "EV_UTL_ID" int not null,
    "EV_UTL_PositedAt" datetime not null,
    "EV_UTL_Positor" tinyint not null,
    "EV_UTL_Reliability" decimal(5,2) not null,
    "EV_UTL_Assertion" string default (
        case
            when "EV_UTL_Reliability" > 0 then '+'
            when "EV_UTL_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_EV_UTL" int not null,
    constraint "fkEV_UTL_Händelse_Utnyttjande_Annex" foreign key (
        "EV_UTL_ID"
    ) references attributes."EV_UTL_Händelse_Utnyttjande_Posit"("EV_UTL_ID") RELY,
    constraint "pkEV_UTL_Händelse_Utnyttjande_Annex" primary key (
        "EV_UTL_ID",
        "EV_UTL_Positor",
        "EV_UTL_PositedAt"
    ) RELY
) CLUSTER BY ("EV_UTL_ID", "EV_UTL_Positor", "EV_UTL_PositedAt");
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Posit table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Posit" (
    "EV_LVL_ID" int default attributes."EV_LVL_Händelse_Level_Posit_ID_SEQ".nextval not null, 
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    constraint "fk_A_EV_LVL_Händelse_Level_Posit" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "fk_K_EV_LVL_Händelse_Level_Posit" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID") RELY,
    constraint "pkEV_LVL_Händelse_Level_Posit" primary key (
        "EV_LVL_ID"
    ) RELY,
    constraint "uqEV_LVL_Händelse_Level_Posit" unique (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt",
        "EV_LVL_PLV_ID"
    ) RELY
) CLUSTER BY ("EV_LVL_EV_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level_Annex table (of EV_LVL_Händelse_Level_Posit on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Annex" (
    "EV_LVL_ID" int not null,
    "EV_LVL_PositedAt" datetime not null,
    "EV_LVL_Positor" tinyint not null,
    "EV_LVL_Reliability" decimal(5,2) not null,
    "EV_LVL_Assertion" string default (
        case
            when "EV_LVL_Reliability" > 0 then '+'
            when "EV_LVL_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_EV_LVL" int not null,
    constraint "fkEV_LVL_Händelse_Level_Annex" foreign key (
        "EV_LVL_ID"
    ) references attributes."EV_LVL_Händelse_Level_Posit"("EV_LVL_ID") RELY,
    constraint "pkEV_LVL_Händelse_Level_Annex" primary key (
        "EV_LVL_ID",
        "EV_LVL_Positor",
        "EV_LVL_PositedAt"
    ) RELY
) CLUSTER BY ("EV_LVL_ID", "EV_LVL_Positor", "EV_LVL_PositedAt");
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Posit" (
    "ST_NAM_ID" int default attributes."ST_NAM_Scen_Namn_Posit_ID_SEQ".nextval not null, 
    "ST_NAM_ST_ID" int not null,
    "ST_NAM_Scen_Namn" varchar(42) not null,
    "ST_NAM_ChangedAt" datetime not null,
    constraint "fkST_NAM_Scen_Namn_Posit" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "pkST_NAM_Scen_Namn_Posit" primary key (
        "ST_NAM_ID"
    ) RELY,
    constraint "uqST_NAM_Scen_Namn_Posit" unique (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Scen_Namn"
    ) RELY
) CLUSTER BY ("ST_NAM_ST_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn_Annex table (of ST_NAM_Scen_Namn_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Annex" (
    "ST_NAM_ID" int not null,
    "ST_NAM_PositedAt" datetime not null,
    "ST_NAM_Positor" tinyint not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "ST_NAM_Assertion" string default (
        case
            when "ST_NAM_Reliability" > 0 then '+'
            when "ST_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_ST_NAM" int not null,
    constraint "fkST_NAM_Scen_Namn_Annex" foreign key (
        "ST_NAM_ID"
    ) references attributes."ST_NAM_Scen_Namn_Posit"("ST_NAM_ID") RELY,
    constraint "pkST_NAM_Scen_Namn_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_Positor",
        "ST_NAM_PositedAt"
    ) RELY
) CLUSTER BY ("ST_NAM_ID", "ST_NAM_Positor", "ST_NAM_PositedAt");
-- Static attribute posit table -----------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Posit" (
    "ST_LOC_ID" int default attributes."ST_LOC_Scen_Plats_Posit_ID_SEQ".nextval not null, 
    "ST_LOC_ST_ID" int not null,
    "ST_LOC_Scen_Plats" geography not null,
    "ST_LOC_Checksum" numeric(19,0) default hash("ST_LOC_Scen_Plats"),
    constraint "fkST_LOC_Scen_Plats_Posit" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "pkST_LOC_Scen_Plats_Posit" primary key (
        "ST_LOC_ID"
    ) RELY,
    constraint "uqST_LOC_Scen_Plats_Posit" unique (
        "ST_LOC_ST_ID",
        "ST_LOC_Checksum" 
    ) RELY
) CLUSTER BY ("ST_LOC_ST_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats_Annex table (of ST_LOC_Scen_Plats_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Annex" (
    "ST_LOC_ID" int not null,
    "ST_LOC_PositedAt" datetime not null,
    "ST_LOC_Positor" tinyint not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "ST_LOC_Assertion" string default (
        case
            when "ST_LOC_Reliability" > 0 then '+'
            when "ST_LOC_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_ST_LOC" int not null,
    constraint "fkST_LOC_Scen_Plats_Annex" foreign key (
        "ST_LOC_ID"
    ) references attributes."ST_LOC_Scen_Plats_Posit"("ST_LOC_ID") RELY,
    constraint "pkST_LOC_Scen_Plats_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_Positor",
        "ST_LOC_PositedAt"
    ) RELY
) CLUSTER BY ("ST_LOC_ID", "ST_LOC_Positor", "ST_LOC_PositedAt");
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Posit" (
    "ST_AVG_ID" int default attributes."ST_AVG_Scen_Medel_Posit_ID_SEQ".nextval not null, 
    "ST_AVG_ST_ID" int not null,
    "ST_AVG_UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" datetime not null,
    constraint "fk_A_ST_AVG_Scen_Medel_Posit" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "fk_K_ST_AVG_Scen_Medel_Posit" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkST_AVG_Scen_Medel_Posit" primary key (
        "ST_AVG_ID"
    ) RELY,
    constraint "uqST_AVG_Scen_Medel_Posit" unique (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID"
    ) RELY
) CLUSTER BY ("ST_AVG_ST_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel_Annex table (of ST_AVG_Scen_Medel_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Annex" (
    "ST_AVG_ID" int not null,
    "ST_AVG_PositedAt" datetime not null,
    "ST_AVG_Positor" tinyint not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "ST_AVG_Assertion" string default (
        case
            when "ST_AVG_Reliability" > 0 then '+'
            when "ST_AVG_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_ST_AVG" int not null,
    constraint "fkST_AVG_Scen_Medel_Annex" foreign key (
        "ST_AVG_ID"
    ) references attributes."ST_AVG_Scen_Medel_Posit"("ST_AVG_ID") RELY,
    constraint "pkST_AVG_Scen_Medel_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_Positor",
        "ST_AVG_PositedAt"
    ) RELY
) CLUSTER BY ("ST_AVG_ID", "ST_AVG_Positor", "ST_AVG_PositedAt");
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Posit table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Posit" (
    "ST_MIN_ID" int default attributes."ST_MIN_Scen_Minimum_Posit_ID_SEQ".nextval not null, 
    "ST_MIN_ST_ID" int not null,
    "ST_MIN_UTL_ID" tinyint not null,
    constraint "fk_A_ST_MIN_Scen_Minimum_Posit" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "fk_K_ST_MIN_Scen_Minimum_Posit" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkST_MIN_Scen_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ) RELY,
    constraint "uqST_MIN_Scen_Minimum_Posit" unique (
        "ST_MIN_ST_ID",
        "ST_MIN_UTL_ID"
    ) RELY
) CLUSTER BY ("ST_MIN_ST_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum_Annex table (of ST_MIN_Scen_Minimum_Posit on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Annex" (
    "ST_MIN_ID" int not null,
    "ST_MIN_PositedAt" datetime not null,
    "ST_MIN_Positor" tinyint not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "ST_MIN_Assertion" string default (
        case
            when "ST_MIN_Reliability" > 0 then '+'
            when "ST_MIN_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_ST_MIN" int not null,
    constraint "fkST_MIN_Scen_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references attributes."ST_MIN_Scen_Minimum_Posit"("ST_MIN_ID") RELY,
    constraint "pkST_MIN_Scen_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_Positor",
        "ST_MIN_PositedAt"
    ) RELY
) CLUSTER BY ("ST_MIN_ID", "ST_MIN_Positor", "ST_MIN_PositedAt");
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Posit" (
    "AC_NAM_ID" int default attributes."AC_NAM_Skådespelare_Namn_Posit_ID_SEQ".nextval not null, 
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Skådespelare_Namn" varbinary(max) not null,
    "AC_NAM_ChangedAt" datetime not null,
    constraint "fkAC_NAM_Skådespelare_Namn_Posit" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "pkAC_NAM_Skådespelare_Namn_Posit" primary key (
        "AC_NAM_ID"
    ) RELY,
    constraint "uqAC_NAM_Skådespelare_Namn_Posit" unique (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Skådespelare_Namn"
    ) RELY
) CLUSTER BY ("AC_NAM_AC_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn_Annex table (of AC_NAM_Skådespelare_Namn_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Annex" (
    "AC_NAM_ID" int not null,
    "AC_NAM_PositedAt" datetime not null,
    "AC_NAM_Positor" tinyint not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "AC_NAM_Assertion" string default (
        case
            when "AC_NAM_Reliability" > 0 then '+'
            when "AC_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_AC_NAM" int not null,
    constraint "fkAC_NAM_Skådespelare_Namn_Annex" foreign key (
        "AC_NAM_ID"
    ) references attributes."AC_NAM_Skådespelare_Namn_Posit"("AC_NAM_ID") RELY,
    constraint "pkAC_NAM_Skådespelare_Namn_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_Positor",
        "AC_NAM_PositedAt"
    ) RELY
) CLUSTER BY ("AC_NAM_ID", "AC_NAM_Positor", "AC_NAM_PositedAt");
-- Knotted static attribute posit table -------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Posit" (
    "AC_GEN_ID" int default attributes."AC_GEN_Skådespelare_Kön_Posit_ID_SEQ".nextval not null, 
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" number(1,0) not null,
    constraint "fk_A_AC_GEN_Skådespelare_Kön_Posit" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "fk_K_AC_GEN_Skådespelare_Kön_Posit" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Kön"("GEN_ID") RELY,
    constraint "pkAC_GEN_Skådespelare_Kön_Posit" primary key (
        "AC_GEN_ID"
    ) RELY,
    constraint "uqAC_GEN_Skådespelare_Kön_Posit" unique (
        "AC_GEN_AC_ID",
        "AC_GEN_GEN_ID"
    ) RELY
) CLUSTER BY ("AC_GEN_AC_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön_Annex table (of AC_GEN_Skådespelare_Kön_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Annex" (
    "AC_GEN_ID" int not null,
    "AC_GEN_PositedAt" datetime not null,
    "AC_GEN_Positor" tinyint not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "AC_GEN_Assertion" string default (
        case
            when "AC_GEN_Reliability" > 0 then '+'
            when "AC_GEN_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_AC_GEN" int not null,
    constraint "fkAC_GEN_Skådespelare_Kön_Annex" foreign key (
        "AC_GEN_ID"
    ) references attributes."AC_GEN_Skådespelare_Kön_Posit"("AC_GEN_ID") RELY,
    constraint "pkAC_GEN_Skådespelare_Kön_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_Positor",
        "AC_GEN_PositedAt"
    ) RELY
) CLUSTER BY ("AC_GEN_ID", "AC_GEN_Positor", "AC_GEN_PositedAt");
-- Knotted historized attribute posit table ---------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Posit table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" (
    "AC_PLV_ID" int default attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ".nextval not null, 
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" datetime not null,
    constraint "fk_A_AC_PLV_Skådespelare_Yrkesnivå_Posit" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "fk_K_AC_PLV_Skådespelare_Yrkesnivå_Posit" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID") RELY,
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå_Posit" primary key (
        "AC_PLV_ID"
    ) RELY,
    constraint "uqAC_PLV_Skådespelare_Yrkesnivå_Posit" unique (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PLV_ID"
    ) RELY
) CLUSTER BY ("AC_PLV_AC_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå_Annex table (of AC_PLV_Skådespelare_Yrkesnivå_Posit on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
    "AC_PLV_ID" int not null,
    "AC_PLV_PositedAt" datetime not null,
    "AC_PLV_Positor" tinyint not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "AC_PLV_Assertion" string default (
        case
            when "AC_PLV_Reliability" > 0 then '+'
            when "AC_PLV_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_AC_PLV" int not null,
    constraint "fkAC_PLV_Skådespelare_Yrkesnivå_Annex" foreign key (
        "AC_PLV_ID"
    ) references attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"("AC_PLV_ID") RELY,
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_Positor",
        "AC_PLV_PositedAt"
    ) RELY
) CLUSTER BY ("AC_PLV_ID", "AC_PLV_Positor", "AC_PLV_PositedAt");
-- Static attribute posit table -----------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Posit" (
    "PR_NAM_ID" int default attributes."PR_NAM_Föreställning_Namn_Posit_ID_SEQ".nextval not null, 
    "PR_NAM_PR_ID" number(10,0) not null,
    "PR_NAM_Föreställning_Namn" varchar(42) not null,
    constraint "fkPR_NAM_Föreställning_Namn_Posit" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID") RELY,
    constraint "pkPR_NAM_Föreställning_Namn_Posit" primary key (
        "PR_NAM_ID"
    ) RELY,
    constraint "uqPR_NAM_Föreställning_Namn_Posit" unique (
        "PR_NAM_PR_ID",
        "PR_NAM_Föreställning_Namn"
    ) RELY
) CLUSTER BY ("PR_NAM_PR_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn_Annex table (of PR_NAM_Föreställning_Namn_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Annex" (
    "PR_NAM_ID" int not null,
    "PR_NAM_PositedAt" datetime not null,
    "PR_NAM_Positor" tinyint not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "PR_NAM_Assertion" string default (
        case
            when "PR_NAM_Reliability" > 0 then '+'
            when "PR_NAM_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_PR_NAM" int not null,
    constraint "fkPR_NAM_Föreställning_Namn_Annex" foreign key (
        "PR_NAM_ID"
    ) references attributes."PR_NAM_Föreställning_Namn_Posit"("PR_NAM_ID") RELY,
    constraint "pkPR_NAM_Föreställning_Namn_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_Positor",
        "PR_NAM_PositedAt"
    ) RELY
) CLUSTER BY ("PR_NAM_ID", "PR_NAM_Positor", "PR_NAM_PositedAt");
-- Historized attribute posit table -----------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Posit table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Posit" (
    "PR_LEN_ID" int default attributes."PR_LEN_Föreställning_Längd_Posit_ID_SEQ".nextval not null, 
    "PR_LEN_PR_ID" number(10,0) not null,
    "PR_LEN_Föreställning_Längd" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Föreställning_Längd_Posit" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID") RELY,
    constraint "pkPR_LEN_Föreställning_Längd_Posit" primary key (
        "PR_LEN_ID"
    ) RELY,
    constraint "uqPR_LEN_Föreställning_Längd_Posit" unique (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Föreställning_Längd"
    ) RELY
) CLUSTER BY ("PR_LEN_PR_ID");
-- Attribute annex table ----------------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd_Annex table (of PR_LEN_Föreställning_Längd_Posit on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Annex" (
    "PR_LEN_ID" int not null,
    "PR_LEN_PositedAt" datetime not null,
    "PR_LEN_Positor" tinyint not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "PR_LEN_Assertion" string default (
        case
            when "PR_LEN_Reliability" > 0 then '+'
            when "PR_LEN_Reliability" = 0 then '?'
            else '-'
        end
    ),
    "Metadata_PR_LEN" int not null,
    constraint "fkPR_LEN_Föreställning_Längd_Annex" foreign key (
        "PR_LEN_ID"
    ) references attributes."PR_LEN_Föreställning_Längd_Posit"("PR_LEN_ID") RELY,
    constraint "pkPR_LEN_Föreställning_Längd_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_Positor",
        "PR_LEN_PositedAt"
    ) RELY
) CLUSTER BY ("PR_LEN_ID", "PR_LEN_Positor", "PR_LEN_PositedAt");
