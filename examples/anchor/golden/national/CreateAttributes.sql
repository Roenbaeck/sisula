-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- Attributes are mutable properties on anchors or nexuses.
-- Attributes have four flavors: static, historized, knotted static, and knotted historized.
--
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_DAT_Händelse_Datum table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum" (
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Händelse_Datum" datetime not null,
    "Metadata_EV_DAT" int not null,
    constraint "fkEV_DAT_Händelse_Datum" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_DAT_Händelse_Datum" primary key (
        "EV_DAT_EV_ID"
    ) RELY
) CLUSTER BY ("EV_DAT_EV_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_AUD_Händelse_Publik table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik" (
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_EQ" tinyint not null,
    "EV_AUD_Händelse_Publik" int not null,
    "Metadata_EV_AUD" int not null,
    constraint "fkEV_AUD_Händelse_Publik" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_AUD_Händelse_Publik" primary key (
        "EV_AUD_EQ",
        "EV_AUD_EV_ID"
    ) RELY
) CLUSTER BY ("EV_AUD_EV_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- EV_REV_Händelse_Intäkt table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt" (
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_EQ" tinyint not null,
    "EV_REV_Händelse_Intäkt" number(19,4) not null,
    "Metadata_EV_REV" int not null,
    constraint "fkEV_REV_Händelse_Intäkt" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_REV_Händelse_Intäkt" primary key (
        "EV_REV_EQ",
        "EV_REV_EV_ID"
    ) RELY
) CLUSTER BY ("EV_REV_EV_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- EV_STA_Händelse_Status table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status" (
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_EQ" tinyint not null,
    "EV_STA_Händelse_Status" varchar(20) not null,
    "EV_STA_ChangedAt" datetime not null,
    "Metadata_EV_STA" int not null,
    constraint "fkEV_STA_Händelse_Status" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "pkEV_STA_Händelse_Status" primary key (
        "EV_STA_EQ",
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt"
    ) RELY
) CLUSTER BY ("EV_STA_EV_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- EV_UTL_Händelse_Utnyttjande table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande" (
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" tinyint not null,
    "Metadata_EV_UTL" int not null,
    constraint "fk_A_EV_UTL_Händelse_Utnyttjande" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "fk_K_EV_UTL_Händelse_Utnyttjande" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkEV_UTL_Händelse_Utnyttjande" primary key (
        "EV_UTL_EV_ID"
    ) RELY
) CLUSTER BY ("EV_UTL_EV_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- EV_LVL_Händelse_Level table (on EV_Händelse)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level" (
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" tinyint not null,
    "EV_LVL_ChangedAt" date not null,
    "Metadata_EV_LVL" int not null,
    constraint "fk_A_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID") RELY,
    constraint "fk_K_EV_LVL_Händelse_Level" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID") RELY,
    constraint "pkEV_LVL_Händelse_Level" primary key (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt"
    ) RELY
) CLUSTER BY ("EV_LVL_EV_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- ST_NAM_Scen_Namn table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn" (
    "ST_NAM_ST_ID" int not null,
    "ST_NAM_EQ" tinyint not null,
    "ST_NAM_Scen_Namn" varchar(42) not null,
    "ST_NAM_ChangedAt" datetime not null,
    "Metadata_ST_NAM" int not null,
    constraint "fkST_NAM_Scen_Namn" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "pkST_NAM_Scen_Namn" primary key (
        "ST_NAM_EQ",
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt"
    ) RELY
) CLUSTER BY ("ST_NAM_ST_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- ST_LOC_Scen_Plats table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats" (
    "ST_LOC_ST_ID" int not null,
    "ST_LOC_EQ" tinyint not null,
    "ST_LOC_Scen_Plats" geography not null,
    "ST_LOC_Checksum" numeric(19,0) default hash("ST_LOC_Scen_Plats"),
    "Metadata_ST_LOC" int not null,
    constraint "fkST_LOC_Scen_Plats" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "pkST_LOC_Scen_Plats" primary key (
        "ST_LOC_EQ",
        "ST_LOC_ST_ID"
    ) RELY
) CLUSTER BY ("ST_LOC_ST_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- ST_AVG_Scen_Medel table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel" (
    "ST_AVG_ST_ID" int not null,
    "ST_AVG_UTL_ID" tinyint not null,
    "ST_AVG_ChangedAt" datetime not null,
    "Metadata_ST_AVG" int not null,
    constraint "fk_A_ST_AVG_Scen_Medel" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "fk_K_ST_AVG_Scen_Medel" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkST_AVG_Scen_Medel" primary key (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt"
    ) RELY
) CLUSTER BY ("ST_AVG_ST_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- ST_MIN_Scen_Minimum table (on ST_Scen)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum" (
    "ST_MIN_ST_ID" int not null,
    "ST_MIN_UTL_ID" tinyint not null,
    "Metadata_ST_MIN" int not null,
    constraint "fk_A_ST_MIN_Scen_Minimum" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Scen"("ST_ID") RELY,
    constraint "fk_K_ST_MIN_Scen_Minimum" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID") RELY,
    constraint "pkST_MIN_Scen_Minimum" primary key (
        "ST_MIN_ST_ID"
    ) RELY
) CLUSTER BY ("ST_MIN_ST_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- AC_NAM_Skådespelare_Namn table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn" (
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Skådespelare_Namn" varbinary(max) not null,
    "AC_NAM_ChangedAt" datetime not null,
    "Metadata_AC_NAM" int not null,
    constraint "fkAC_NAM_Skådespelare_Namn" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "pkAC_NAM_Skådespelare_Namn" primary key (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt"
    ) RELY
) CLUSTER BY ("AC_NAM_AC_ID");
-- Knotted static attribute table -------------------------------------------------------------------------------------
-- AC_GEN_Skådespelare_Kön table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön" (
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" number(1,0) not null,
    "Metadata_AC_GEN" int not null,
    constraint "fk_A_AC_GEN_Skådespelare_Kön" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "fk_K_AC_GEN_Skådespelare_Kön" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Kön"("GEN_ID") RELY,
    constraint "pkAC_GEN_Skådespelare_Kön" primary key (
        "AC_GEN_AC_ID"
    ) RELY
) CLUSTER BY ("AC_GEN_AC_ID");
-- Knotted historized attribute table ---------------------------------------------------------------------------------
-- AC_PLV_Skådespelare_Yrkesnivå table (on AC_Skådespelare)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå" (
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" tinyint not null,
    "AC_PLV_ChangedAt" datetime not null,
    "Metadata_AC_PLV" int not null,
    constraint "fk_A_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID") RELY,
    constraint "fk_K_AC_PLV_Skådespelare_Yrkesnivå" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_Yrkesnivå_ID"("PLV_ID") RELY,
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå" primary key (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt"
    ) RELY
) CLUSTER BY ("AC_PLV_AC_ID");
-- Static attribute table ---------------------------------------------------------------------------------------------
-- PR_NAM_Föreställning_Namn table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn" (
    "PR_NAM_PR_ID" number(10,0) not null,
    "PR_NAM_Föreställning_Namn" varchar(42) not null,
    "Metadata_PR_NAM" int not null,
    constraint "fkPR_NAM_Föreställning_Namn" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID") RELY,
    constraint "pkPR_NAM_Föreställning_Namn" primary key (
        "PR_NAM_PR_ID"
    ) RELY
) CLUSTER BY ("PR_NAM_PR_ID");
-- Historized attribute table -----------------------------------------------------------------------------------------
-- PR_LEN_Föreställning_Längd table (on PR_Föreställning)
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd" (
    "PR_LEN_PR_ID" number(10,0) not null,
    "PR_LEN_EQ" tinyint not null,
    "PR_LEN_Föreställning_Längd" time not null,
    "PR_LEN_ChangedAt" date not null,
    "Metadata_PR_LEN" int not null,
    constraint "fkPR_LEN_Föreställning_Längd" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID") RELY,
    constraint "pkPR_LEN_Föreställning_Längd" primary key (
        "PR_LEN_EQ",
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt"
    ) RELY
) CLUSTER BY ("PR_LEN_PR_ID");
