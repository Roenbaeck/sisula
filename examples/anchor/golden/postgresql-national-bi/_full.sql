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
CREATE TABLE IF NOT EXISTS knots."PAT_Föräldratyp" (
    "PAT_ID" smallint not null,
    "PAT_Föräldratyp" varchar(42) not null,
    "Metadata_PAT" integer not null,
    constraint "pkPAT_Föräldratyp" primary key (
        "PAT_ID"
    ),
    constraint "uqPAT_Föräldratyp" unique (
        "PAT_Föräldratyp"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."GEN_Kön" (
    "GEN_ID" smallint not null,
    "GEN_Kön" varchar(42) not null,
    "GEN_Checksum" bytea generated always as (decode(md5("GEN_Kön"::text), 'hex')) stored,
    "Metadata_GEN" integer not null,
    constraint "pkGEN_Kön" primary key (
        "GEN_ID"
    ),
    constraint "uqGEN_Kön" unique (
        "GEN_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."PLV_Yrkesnivå" (
    "PLV_ID" smallint not null,
    "PLV_Yrkesnivå" text not null,
    "PLV_Checksum" bytea generated always as (decode(md5("PLV_Yrkesnivå"::text), 'hex')) stored,
    "Metadata_PLV" integer not null,
    constraint "pkPLV_Yrkesnivå" primary key (
        "PLV_ID"
    ),
    constraint "uqPLV_Yrkesnivå" unique (
        "PLV_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."UTL_Utnyttjande" (
    "UTL_ID" smallint not null,
    "UTL_Utnyttjande" smallint not null,
    "Metadata_UTL" integer not null,
    constraint "pkUTL_Utnyttjande" primary key (
        "UTL_ID"
    ),
    constraint "uqUTL_Utnyttjande" unique (
        "UTL_Utnyttjande"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ONG_Pågående" (
    "ONG_ID" smallint not null,
    "ONG_Pågående" varchar(3) not null,
    "Metadata_ONG" integer not null,
    constraint "pkONG_Pågående" primary key (
        "ONG_ID"
    ),
    constraint "uqONG_Pågående" unique (
        "ONG_Pågående"
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS knots."RAT_Betyg_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS knots."RAT_Betyg" (
    "RAT_ID" smallint default nextval('knots."RAT_Betyg_ID_SEQ"') not null, 
    "RAT_Betyg" varchar(42) not null,
    "RAT_Checksum" bytea generated always as (decode(md5("RAT_Betyg"::text), 'hex')) stored,
    "Metadata_RAT" integer not null,
    constraint "pkRAT_Betyg" primary key (
        "RAT_ID"
    ),
    constraint "uqRAT_Betyg" unique (
        "RAT_Checksum" 
    )
);
-- Knot table ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knots."ETY_Händelsetyp" (
    "ETY_ID" smallint not null,
    "ETY_Händelsetyp" varchar(42) not null,
    "ETY_Checksum" bytea generated always as (decode(md5("ETY_Händelsetyp"::text), 'hex')) stored,
    "Metadata_ETY" integer not null,
    constraint "pkETY_Händelsetyp" primary key (
        "ETY_ID"
    ),
    constraint "uqETY_Händelsetyp" unique (
        "ETY_Checksum" 
    )
);
-- ANCHORS ------------------------------------------------------------------------------------------------------------
--
-- Anchors store immutable entity identities.
--
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."PN_Person_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."PN_Person" (
    "PN_ID" bigint default nextval('anchors."PN_Person_ID_SEQ"') not null, 
    "Metadata_PN" integer not null,
    constraint "pkPN_Person" primary key (
        "PN_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."ST_Scen" (
    "ST_ID" integer not null,
    "Metadata_ST" integer not null,
    constraint "pkST_Scen" primary key (
        "ST_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS anchors."AC_Skådespelare_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS anchors."AC_Skådespelare" (
    "AC_ID" smallint default nextval('anchors."AC_Skådespelare_ID_SEQ"') not null, 
    "Metadata_AC" integer not null,
    constraint "pkAC_Skådespelare" primary key (
        "AC_ID"
    )
);
-- Anchor table -------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anchors."PR_Föreställning" (
    "PR_ID" bigint not null,
    "Metadata_PR" integer not null,
    constraint "pkPR_Föreställning" primary key (
        "PR_ID"
    )
);
-- NEXUSES ------------------------------------------------------------------------------------------------------------
--
-- Nexuses store immutable identities for event-like entities.
--
-- Nexus table --------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nexuses."EV_Händelse" (
    "EV_ID" numeric(12,0) not null,
    "ST_ID_hölls" integer not null, 
    "PR_ID_spelades" bigint not null, 
    "ETY_ID_of" smallint not null,
    constraint "EV_Händelse_fkST_hölls" foreign key (
        "ST_ID_hölls"
    ) references anchors."ST_Scen"("ST_ID"), 
    constraint "EV_Händelse_fkPR_spelades" foreign key (
        "PR_ID_spelades"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "EV_Händelse_fkETY_of" foreign key (
        "ETY_ID_of"
    ) references knots."ETY_Händelsetyp"("ETY_ID"),
    "Metadata_EV" integer not null, 
    constraint "pkEV_Händelse" primary key (
        "EV_ID"
    )
);
-- ATTRIBUTES ---------------------------------------------------------------------------------------------------------
--
-- BI attributes use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Posit" (
    "EV_DAT_ID" integer default nextval('attributes."EV_DAT_Händelse_Datum_Posit_ID_SEQ"') not null, 
    "EV_DAT_EV_ID" numeric(12,0) not null,
    "EV_DAT_Händelse_Datum" timestamp not null,
    constraint "fkEV_DAT_Händelse_Datum_Posit" foreign key (
        "EV_DAT_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_DAT_Händelse_Datum_Posit" primary key (
        "EV_DAT_ID"
    ),
    constraint "uqEV_DAT_Händelse_Datum_Posit" unique (
        "EV_DAT_EV_ID",
        "EV_DAT_Händelse_Datum"
    )
);
CREATE TABLE IF NOT EXISTS attributes."EV_DAT_Händelse_Datum_Annex" (
    "EV_DAT_ID" integer not null,
    "EV_DAT_PositedAt" timestamp not null,
    "EV_DAT_Reliability" decimal(5,2) not null,
    "Metadata_EV_DAT" integer not null,
    constraint "fkEV_DAT_Händelse_Datum_Annex" foreign key (
        "EV_DAT_ID"
    ) references attributes."EV_DAT_Händelse_Datum_Posit"("EV_DAT_ID"),
    constraint "pkEV_DAT_Händelse_Datum_Annex" primary key (
        "EV_DAT_ID",
        "EV_DAT_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Posit" (
    "EV_AUD_ID" integer default nextval('attributes."EV_AUD_Händelse_Publik_Posit_ID_SEQ"') not null, 
    "EV_AUD_EV_ID" numeric(12,0) not null,
    "EV_AUD_Händelse_Publik" integer not null,
    constraint "fkEV_AUD_Händelse_Publik_Posit" foreign key (
        "EV_AUD_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_AUD_Händelse_Publik_Posit" primary key (
        "EV_AUD_ID"
    ),
    constraint "uqEV_AUD_Händelse_Publik_Posit" unique (
        "EV_AUD_EV_ID",
        "EV_AUD_Händelse_Publik"
    )
);
CREATE TABLE IF NOT EXISTS attributes."EV_AUD_Händelse_Publik_Annex" (
    "EV_AUD_ID" integer not null,
    "EV_AUD_PositedAt" timestamp not null,
    "EV_AUD_Reliability" decimal(5,2) not null,
    "Metadata_EV_AUD" integer not null,
    constraint "fkEV_AUD_Händelse_Publik_Annex" foreign key (
        "EV_AUD_ID"
    ) references attributes."EV_AUD_Händelse_Publik_Posit"("EV_AUD_ID"),
    constraint "pkEV_AUD_Händelse_Publik_Annex" primary key (
        "EV_AUD_ID",
        "EV_AUD_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Posit" (
    "EV_REV_ID" integer default nextval('attributes."EV_REV_Händelse_Intäkt_Posit_ID_SEQ"') not null, 
    "EV_REV_EV_ID" numeric(12,0) not null,
    "EV_REV_Händelse_Intäkt" decimal(19,4) not null,
    constraint "fkEV_REV_Händelse_Intäkt_Posit" foreign key (
        "EV_REV_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_REV_Händelse_Intäkt_Posit" primary key (
        "EV_REV_ID"
    ),
    constraint "uqEV_REV_Händelse_Intäkt_Posit" unique (
        "EV_REV_EV_ID",
        "EV_REV_Händelse_Intäkt"
    )
);
CREATE TABLE IF NOT EXISTS attributes."EV_REV_Händelse_Intäkt_Annex" (
    "EV_REV_ID" integer not null,
    "EV_REV_PositedAt" timestamp not null,
    "EV_REV_Reliability" decimal(5,2) not null,
    "Metadata_EV_REV" integer not null,
    constraint "fkEV_REV_Händelse_Intäkt_Annex" foreign key (
        "EV_REV_ID"
    ) references attributes."EV_REV_Händelse_Intäkt_Posit"("EV_REV_ID"),
    constraint "pkEV_REV_Händelse_Intäkt_Annex" primary key (
        "EV_REV_ID",
        "EV_REV_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Posit" (
    "EV_STA_ID" integer default nextval('attributes."EV_STA_Händelse_Status_Posit_ID_SEQ"') not null, 
    "EV_STA_EV_ID" numeric(12,0) not null,
    "EV_STA_Händelse_Status" varchar(20) not null,
    "EV_STA_ChangedAt" timestamp not null,
    constraint "fkEV_STA_Händelse_Status_Posit" foreign key (
        "EV_STA_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "pkEV_STA_Händelse_Status_Posit" primary key (
        "EV_STA_ID"
    ),
    constraint "uqEV_STA_Händelse_Status_Posit" unique (
        "EV_STA_EV_ID",
        "EV_STA_ChangedAt",
        "EV_STA_Händelse_Status"
    )
);
CREATE TABLE IF NOT EXISTS attributes."EV_STA_Händelse_Status_Annex" (
    "EV_STA_ID" integer not null,
    "EV_STA_PositedAt" timestamp not null,
    "EV_STA_Reliability" decimal(5,2) not null,
    "Metadata_EV_STA" integer not null,
    constraint "fkEV_STA_Händelse_Status_Annex" foreign key (
        "EV_STA_ID"
    ) references attributes."EV_STA_Händelse_Status_Posit"("EV_STA_ID"),
    constraint "pkEV_STA_Händelse_Status_Annex" primary key (
        "EV_STA_ID",
        "EV_STA_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Posit" (
    "EV_UTL_ID" integer default nextval('attributes."EV_UTL_Händelse_Utnyttjande_Posit_ID_SEQ"') not null, 
    "EV_UTL_EV_ID" numeric(12,0) not null,
    "EV_UTL_UTL_ID" smallint not null,
    constraint "fk_A_EV_UTL_Händelse_Utnyttjande_Posit" foreign key (
        "EV_UTL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "fk_K_EV_UTL_Händelse_Utnyttjande_Posit" foreign key (
        "EV_UTL_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkEV_UTL_Händelse_Utnyttjande_Posit" primary key (
        "EV_UTL_ID"
    ),
    constraint "uqEV_UTL_Händelse_Utnyttjande_Posit" unique (
        "EV_UTL_EV_ID",
        "EV_UTL_UTL_ID"
    )
);
CREATE TABLE IF NOT EXISTS attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
    "EV_UTL_ID" integer not null,
    "EV_UTL_PositedAt" timestamp not null,
    "EV_UTL_Reliability" decimal(5,2) not null,
    "Metadata_EV_UTL" integer not null,
    constraint "fkEV_UTL_Händelse_Utnyttjande_Annex" foreign key (
        "EV_UTL_ID"
    ) references attributes."EV_UTL_Händelse_Utnyttjande_Posit"("EV_UTL_ID"),
    constraint "pkEV_UTL_Händelse_Utnyttjande_Annex" primary key (
        "EV_UTL_ID",
        "EV_UTL_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Posit" (
    "EV_LVL_ID" integer default nextval('attributes."EV_LVL_Händelse_Level_Posit_ID_SEQ"') not null, 
    "EV_LVL_EV_ID" numeric(12,0) not null,
    "EV_LVL_PLV_ID" smallint not null,
    "EV_LVL_ChangedAt" date not null,
    constraint "fk_A_EV_LVL_Händelse_Level_Posit" foreign key (
        "EV_LVL_EV_ID"
    ) references nexuses."EV_Händelse"("EV_ID"),
    constraint "fk_K_EV_LVL_Händelse_Level_Posit" foreign key (
        "EV_LVL_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID"),
    constraint "pkEV_LVL_Händelse_Level_Posit" primary key (
        "EV_LVL_ID"
    ),
    constraint "uqEV_LVL_Händelse_Level_Posit" unique (
        "EV_LVL_EV_ID",
        "EV_LVL_ChangedAt",
        "EV_LVL_PLV_ID"
    )
);
CREATE TABLE IF NOT EXISTS attributes."EV_LVL_Händelse_Level_Annex" (
    "EV_LVL_ID" integer not null,
    "EV_LVL_PositedAt" timestamp not null,
    "EV_LVL_Reliability" decimal(5,2) not null,
    "Metadata_EV_LVL" integer not null,
    constraint "fkEV_LVL_Händelse_Level_Annex" foreign key (
        "EV_LVL_ID"
    ) references attributes."EV_LVL_Händelse_Level_Posit"("EV_LVL_ID"),
    constraint "pkEV_LVL_Händelse_Level_Annex" primary key (
        "EV_LVL_ID",
        "EV_LVL_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Posit" (
    "ST_NAM_ID" integer default nextval('attributes."ST_NAM_Scen_Namn_Posit_ID_SEQ"') not null, 
    "ST_NAM_ST_ID" integer not null,
    "ST_NAM_Scen_Namn" varchar(42) not null,
    "ST_NAM_ChangedAt" timestamp not null,
    constraint "fkST_NAM_Scen_Namn_Posit" foreign key (
        "ST_NAM_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_NAM_Scen_Namn_Posit" primary key (
        "ST_NAM_ID"
    ),
    constraint "uqST_NAM_Scen_Namn_Posit" unique (
        "ST_NAM_ST_ID",
        "ST_NAM_ChangedAt",
        "ST_NAM_Scen_Namn"
    )
);
CREATE TABLE IF NOT EXISTS attributes."ST_NAM_Scen_Namn_Annex" (
    "ST_NAM_ID" integer not null,
    "ST_NAM_PositedAt" timestamp not null,
    "ST_NAM_Reliability" decimal(5,2) not null,
    "Metadata_ST_NAM" integer not null,
    constraint "fkST_NAM_Scen_Namn_Annex" foreign key (
        "ST_NAM_ID"
    ) references attributes."ST_NAM_Scen_Namn_Posit"("ST_NAM_ID"),
    constraint "pkST_NAM_Scen_Namn_Annex" primary key (
        "ST_NAM_ID",
        "ST_NAM_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Posit" (
    "ST_LOC_ID" integer default nextval('attributes."ST_LOC_Scen_Plats_Posit_ID_SEQ"') not null, 
    "ST_LOC_ST_ID" integer not null,
    "ST_LOC_Scen_Plats" text not null,
    "ST_LOC_Checksum" bytea generated always as (decode(md5("ST_LOC_Scen_Plats"::text), 'hex')) stored,
    constraint "fkST_LOC_Scen_Plats_Posit" foreign key (
        "ST_LOC_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "pkST_LOC_Scen_Plats_Posit" primary key (
        "ST_LOC_ID"
    ),
    constraint "uqST_LOC_Scen_Plats_Posit" unique (
        "ST_LOC_ST_ID",
        "ST_LOC_Checksum" 
    )
);
CREATE TABLE IF NOT EXISTS attributes."ST_LOC_Scen_Plats_Annex" (
    "ST_LOC_ID" integer not null,
    "ST_LOC_PositedAt" timestamp not null,
    "ST_LOC_Reliability" decimal(5,2) not null,
    "Metadata_ST_LOC" integer not null,
    constraint "fkST_LOC_Scen_Plats_Annex" foreign key (
        "ST_LOC_ID"
    ) references attributes."ST_LOC_Scen_Plats_Posit"("ST_LOC_ID"),
    constraint "pkST_LOC_Scen_Plats_Annex" primary key (
        "ST_LOC_ID",
        "ST_LOC_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Posit" (
    "ST_AVG_ID" integer default nextval('attributes."ST_AVG_Scen_Medel_Posit_ID_SEQ"') not null, 
    "ST_AVG_ST_ID" integer not null,
    "ST_AVG_UTL_ID" smallint not null,
    "ST_AVG_ChangedAt" timestamp not null,
    constraint "fk_A_ST_AVG_Scen_Medel_Posit" foreign key (
        "ST_AVG_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "fk_K_ST_AVG_Scen_Medel_Posit" foreign key (
        "ST_AVG_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkST_AVG_Scen_Medel_Posit" primary key (
        "ST_AVG_ID"
    ),
    constraint "uqST_AVG_Scen_Medel_Posit" unique (
        "ST_AVG_ST_ID",
        "ST_AVG_ChangedAt",
        "ST_AVG_UTL_ID"
    )
);
CREATE TABLE IF NOT EXISTS attributes."ST_AVG_Scen_Medel_Annex" (
    "ST_AVG_ID" integer not null,
    "ST_AVG_PositedAt" timestamp not null,
    "ST_AVG_Reliability" decimal(5,2) not null,
    "Metadata_ST_AVG" integer not null,
    constraint "fkST_AVG_Scen_Medel_Annex" foreign key (
        "ST_AVG_ID"
    ) references attributes."ST_AVG_Scen_Medel_Posit"("ST_AVG_ID"),
    constraint "pkST_AVG_Scen_Medel_Annex" primary key (
        "ST_AVG_ID",
        "ST_AVG_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Posit" (
    "ST_MIN_ID" integer default nextval('attributes."ST_MIN_Scen_Minimum_Posit_ID_SEQ"') not null, 
    "ST_MIN_ST_ID" integer not null,
    "ST_MIN_UTL_ID" smallint not null,
    constraint "fk_A_ST_MIN_Scen_Minimum_Posit" foreign key (
        "ST_MIN_ST_ID"
    ) references anchors."ST_Scen"("ST_ID"),
    constraint "fk_K_ST_MIN_Scen_Minimum_Posit" foreign key (
        "ST_MIN_UTL_ID"
    ) references knots."UTL_Utnyttjande"("UTL_ID"),
    constraint "pkST_MIN_Scen_Minimum_Posit" primary key (
        "ST_MIN_ID"
    ),
    constraint "uqST_MIN_Scen_Minimum_Posit" unique (
        "ST_MIN_ST_ID",
        "ST_MIN_UTL_ID"
    )
);
CREATE TABLE IF NOT EXISTS attributes."ST_MIN_Scen_Minimum_Annex" (
    "ST_MIN_ID" integer not null,
    "ST_MIN_PositedAt" timestamp not null,
    "ST_MIN_Reliability" decimal(5,2) not null,
    "Metadata_ST_MIN" integer not null,
    constraint "fkST_MIN_Scen_Minimum_Annex" foreign key (
        "ST_MIN_ID"
    ) references attributes."ST_MIN_Scen_Minimum_Posit"("ST_MIN_ID"),
    constraint "pkST_MIN_Scen_Minimum_Annex" primary key (
        "ST_MIN_ID",
        "ST_MIN_PositedAt"
    )
);
-- AC_NAM_Skådespelare_Namn is in the encryption group PII, which is not used: this database does not encrypt
-- in this temporalization, so the values are stored as they are
CREATE SEQUENCE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Posit" (
    "AC_NAM_ID" integer default nextval('attributes."AC_NAM_Skådespelare_Namn_Posit_ID_SEQ"') not null, 
    "AC_NAM_AC_ID" smallint not null,
    "AC_NAM_Skådespelare_Namn" varchar(42) not null,
    "AC_NAM_ChangedAt" timestamp not null,
    constraint "fkAC_NAM_Skådespelare_Namn_Posit" foreign key (
        "AC_NAM_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "pkAC_NAM_Skådespelare_Namn_Posit" primary key (
        "AC_NAM_ID"
    ),
    constraint "uqAC_NAM_Skådespelare_Namn_Posit" unique (
        "AC_NAM_AC_ID",
        "AC_NAM_ChangedAt",
        "AC_NAM_Skådespelare_Namn"
    )
);
CREATE TABLE IF NOT EXISTS attributes."AC_NAM_Skådespelare_Namn_Annex" (
    "AC_NAM_ID" integer not null,
    "AC_NAM_PositedAt" timestamp not null,
    "AC_NAM_Reliability" decimal(5,2) not null,
    "Metadata_AC_NAM" integer not null,
    constraint "fkAC_NAM_Skådespelare_Namn_Annex" foreign key (
        "AC_NAM_ID"
    ) references attributes."AC_NAM_Skådespelare_Namn_Posit"("AC_NAM_ID"),
    constraint "pkAC_NAM_Skådespelare_Namn_Annex" primary key (
        "AC_NAM_ID",
        "AC_NAM_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Posit" (
    "AC_GEN_ID" integer default nextval('attributes."AC_GEN_Skådespelare_Kön_Posit_ID_SEQ"') not null, 
    "AC_GEN_AC_ID" smallint not null,
    "AC_GEN_GEN_ID" smallint not null,
    constraint "fk_A_AC_GEN_Skådespelare_Kön_Posit" foreign key (
        "AC_GEN_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "fk_K_AC_GEN_Skådespelare_Kön_Posit" foreign key (
        "AC_GEN_GEN_ID"
    ) references knots."GEN_Kön"("GEN_ID"),
    constraint "pkAC_GEN_Skådespelare_Kön_Posit" primary key (
        "AC_GEN_ID"
    ),
    constraint "uqAC_GEN_Skådespelare_Kön_Posit" unique (
        "AC_GEN_AC_ID",
        "AC_GEN_GEN_ID"
    )
);
CREATE TABLE IF NOT EXISTS attributes."AC_GEN_Skådespelare_Kön_Annex" (
    "AC_GEN_ID" integer not null,
    "AC_GEN_PositedAt" timestamp not null,
    "AC_GEN_Reliability" decimal(5,2) not null,
    "Metadata_AC_GEN" integer not null,
    constraint "fkAC_GEN_Skådespelare_Kön_Annex" foreign key (
        "AC_GEN_ID"
    ) references attributes."AC_GEN_Skådespelare_Kön_Posit"("AC_GEN_ID"),
    constraint "pkAC_GEN_Skådespelare_Kön_Annex" primary key (
        "AC_GEN_ID",
        "AC_GEN_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" (
    "AC_PLV_ID" integer default nextval('attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit_ID_SEQ"') not null, 
    "AC_PLV_AC_ID" smallint not null,
    "AC_PLV_PLV_ID" smallint not null,
    "AC_PLV_ChangedAt" timestamp not null,
    constraint "fk_A_AC_PLV_Skådespelare_Yrkesnivå_Posit" foreign key (
        "AC_PLV_AC_ID"
    ) references anchors."AC_Skådespelare"("AC_ID"),
    constraint "fk_K_AC_PLV_Skådespelare_Yrkesnivå_Posit" foreign key (
        "AC_PLV_PLV_ID"
    ) references knots."PLV_Yrkesnivå"("PLV_ID"),
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå_Posit" primary key (
        "AC_PLV_ID"
    ),
    constraint "uqAC_PLV_Skådespelare_Yrkesnivå_Posit" unique (
        "AC_PLV_AC_ID",
        "AC_PLV_ChangedAt",
        "AC_PLV_PLV_ID"
    )
);
CREATE TABLE IF NOT EXISTS attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
    "AC_PLV_ID" integer not null,
    "AC_PLV_PositedAt" timestamp not null,
    "AC_PLV_Reliability" decimal(5,2) not null,
    "Metadata_AC_PLV" integer not null,
    constraint "fkAC_PLV_Skådespelare_Yrkesnivå_Annex" foreign key (
        "AC_PLV_ID"
    ) references attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"("AC_PLV_ID"),
    constraint "pkAC_PLV_Skådespelare_Yrkesnivå_Annex" primary key (
        "AC_PLV_ID",
        "AC_PLV_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Posit" (
    "PR_NAM_ID" integer default nextval('attributes."PR_NAM_Föreställning_Namn_Posit_ID_SEQ"') not null, 
    "PR_NAM_PR_ID" bigint not null,
    "PR_NAM_Föreställning_Namn" varchar(42) not null,
    constraint "fkPR_NAM_Föreställning_Namn_Posit" foreign key (
        "PR_NAM_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID"),
    constraint "pkPR_NAM_Föreställning_Namn_Posit" primary key (
        "PR_NAM_ID"
    ),
    constraint "uqPR_NAM_Föreställning_Namn_Posit" unique (
        "PR_NAM_PR_ID",
        "PR_NAM_Föreställning_Namn"
    )
);
CREATE TABLE IF NOT EXISTS attributes."PR_NAM_Föreställning_Namn_Annex" (
    "PR_NAM_ID" integer not null,
    "PR_NAM_PositedAt" timestamp not null,
    "PR_NAM_Reliability" decimal(5,2) not null,
    "Metadata_PR_NAM" integer not null,
    constraint "fkPR_NAM_Föreställning_Namn_Annex" foreign key (
        "PR_NAM_ID"
    ) references attributes."PR_NAM_Föreställning_Namn_Posit"("PR_NAM_ID"),
    constraint "pkPR_NAM_Föreställning_Namn_Annex" primary key (
        "PR_NAM_ID",
        "PR_NAM_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Posit" (
    "PR_LEN_ID" integer default nextval('attributes."PR_LEN_Föreställning_Längd_Posit_ID_SEQ"') not null, 
    "PR_LEN_PR_ID" bigint not null,
    "PR_LEN_Föreställning_Längd" time not null,
    "PR_LEN_ChangedAt" date not null,
    constraint "fkPR_LEN_Föreställning_Längd_Posit" foreign key (
        "PR_LEN_PR_ID"
    ) references anchors."PR_Föreställning"("PR_ID"),
    constraint "pkPR_LEN_Föreställning_Längd_Posit" primary key (
        "PR_LEN_ID"
    ),
    constraint "uqPR_LEN_Föreställning_Längd_Posit" unique (
        "PR_LEN_PR_ID",
        "PR_LEN_ChangedAt",
        "PR_LEN_Föreställning_Längd"
    )
);
CREATE TABLE IF NOT EXISTS attributes."PR_LEN_Föreställning_Längd_Annex" (
    "PR_LEN_ID" integer not null,
    "PR_LEN_PositedAt" timestamp not null,
    "PR_LEN_Reliability" decimal(5,2) not null,
    "Metadata_PR_LEN" integer not null,
    constraint "fkPR_LEN_Föreställning_Längd_Annex" foreign key (
        "PR_LEN_ID"
    ) references attributes."PR_LEN_Föreställning_Längd_Posit"("PR_LEN_ID"),
    constraint "pkPR_LEN_Föreställning_Längd_Annex" primary key (
        "PR_LEN_ID",
        "PR_LEN_PositedAt"
    )
);
-- ATTRIBUTE ASSEMBLED VIEWS ------------------------------------------------------------------------------------------
--
-- The assembled view of an attribute combines its posit and annex tables. It has the name that the
-- attribute table has in uni-temporal modeling, and the difference perspectives read it.
--
CREATE OR REPLACE VIEW attributes."EV_DAT_Händelse_Datum" AS
SELECT
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Händelse_Datum",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Reliability"
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" p
JOIN
    attributes."EV_DAT_Händelse_Datum_Annex" a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
;
CREATE OR REPLACE VIEW attributes."EV_AUD_Händelse_Publik" AS
SELECT
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Händelse_Publik",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Reliability"
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" p
JOIN
    attributes."EV_AUD_Händelse_Publik_Annex" a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
;
CREATE OR REPLACE VIEW attributes."EV_REV_Händelse_Intäkt" AS
SELECT
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    p."EV_REV_EV_ID",
    p."EV_REV_Händelse_Intäkt",
    a."EV_REV_PositedAt",
    a."EV_REV_Reliability"
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" p
JOIN
    attributes."EV_REV_Händelse_Intäkt_Annex" a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
;
CREATE OR REPLACE VIEW attributes."EV_STA_Händelse_Status" AS
SELECT
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability"
FROM
    attributes."EV_STA_Händelse_Status_Posit" p
JOIN
    attributes."EV_STA_Händelse_Status_Annex" a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
;
CREATE OR REPLACE VIEW attributes."EV_UTL_Händelse_Utnyttjande" AS
SELECT
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Reliability"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
JOIN
    attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
;
CREATE OR REPLACE VIEW attributes."EV_LVL_Händelse_Level" AS
SELECT
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability"
FROM
    attributes."EV_LVL_Händelse_Level_Posit" p
JOIN
    attributes."EV_LVL_Händelse_Level_Annex" a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
;
CREATE OR REPLACE VIEW attributes."ST_NAM_Scen_Namn" AS
SELECT
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability"
FROM
    attributes."ST_NAM_Scen_Namn_Posit" p
JOIN
    attributes."ST_NAM_Scen_Namn_Annex" a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."ST_LOC_Scen_Plats" AS
SELECT
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Scen_Plats",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Reliability"
FROM
    attributes."ST_LOC_Scen_Plats_Posit" p
JOIN
    attributes."ST_LOC_Scen_Plats_Annex" a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
;
CREATE OR REPLACE VIEW attributes."ST_AVG_Scen_Medel" AS
SELECT
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability"
FROM
    attributes."ST_AVG_Scen_Medel_Posit" p
JOIN
    attributes."ST_AVG_Scen_Medel_Annex" a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
;
CREATE OR REPLACE VIEW attributes."ST_MIN_Scen_Minimum" AS
SELECT
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Reliability"
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" p
JOIN
    attributes."ST_MIN_Scen_Minimum_Annex" a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_NAM_Skådespelare_Namn" AS
SELECT
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability"
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit" p
JOIN
    attributes."AC_NAM_Skådespelare_Namn_Annex" a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."AC_GEN_Skådespelare_Kön" AS
SELECT
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Reliability"
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
JOIN
    attributes."AC_GEN_Skådespelare_Kön_Annex" a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
;
CREATE OR REPLACE VIEW attributes."AC_PLV_Skådespelare_Yrkesnivå" AS
SELECT
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability"
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
JOIN
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
;
CREATE OR REPLACE VIEW attributes."PR_NAM_Föreställning_Namn" AS
SELECT
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Föreställning_Namn",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Reliability"
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" p
JOIN
    attributes."PR_NAM_Föreställning_Namn_Annex" a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
;
CREATE OR REPLACE VIEW attributes."PR_LEN_Föreställning_Längd" AS
SELECT
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability"
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit" p
JOIN
    attributes."PR_LEN_Föreställning_Längd_Annex" a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
;
-- ATTRIBUTE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Händelse_Datum_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_DAT",
    "EV_DAT_ID",
    "EV_DAT_PositedAt",
    "EV_DAT_Reliability"
FROM
    attributes."EV_DAT_Händelse_Datum_Annex"
WHERE
    "EV_DAT_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_DAT_Händelse_Datum" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_EV_ID" numeric(12,0),
    "EV_DAT_Händelse_Datum" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_DAT_ID")
    a."Metadata_EV_DAT",
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt",
    a."EV_DAT_Reliability",
    p."EV_DAT_EV_ID",
    p."EV_DAT_Händelse_Datum"
FROM
    attributes."EV_DAT_Händelse_Datum_Posit" p
JOIN
    attributes."rEV_DAT_Händelse_Datum_Annex"(positingTimepoint) a
ON
    a."EV_DAT_ID" = p."EV_DAT_ID"
ORDER BY
    p."EV_DAT_ID",
    a."EV_DAT_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Händelse_Publik_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_AUD",
    "EV_AUD_ID",
    "EV_AUD_PositedAt",
    "EV_AUD_Reliability"
FROM
    attributes."EV_AUD_Händelse_Publik_Annex"
WHERE
    "EV_AUD_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_AUD_Händelse_Publik" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_EV_ID" numeric(12,0),
    "EV_AUD_Händelse_Publik" integer
)
AS
$$
SELECT DISTINCT ON (p."EV_AUD_ID")
    a."Metadata_EV_AUD",
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt",
    a."EV_AUD_Reliability",
    p."EV_AUD_EV_ID",
    p."EV_AUD_Händelse_Publik"
FROM
    attributes."EV_AUD_Händelse_Publik_Posit" p
JOIN
    attributes."rEV_AUD_Händelse_Publik_Annex"(positingTimepoint) a
ON
    a."EV_AUD_ID" = p."EV_AUD_ID"
ORDER BY
    p."EV_AUD_ID",
    a."EV_AUD_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Händelse_Intäkt_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_REV",
    "EV_REV_ID",
    "EV_REV_PositedAt",
    "EV_REV_Reliability"
FROM
    attributes."EV_REV_Händelse_Intäkt_Annex"
WHERE
    "EV_REV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_REV_Händelse_Intäkt" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_EV_ID" numeric(12,0),
    "EV_REV_Händelse_Intäkt" decimal(19,4)
)
AS
$$
SELECT DISTINCT ON (p."EV_REV_ID")
    a."Metadata_EV_REV",
    p."EV_REV_ID",
    a."EV_REV_PositedAt",
    a."EV_REV_Reliability",
    p."EV_REV_EV_ID",
    p."EV_REV_Händelse_Intäkt"
FROM
    attributes."EV_REV_Händelse_Intäkt_Posit" p
JOIN
    attributes."rEV_REV_Händelse_Intäkt_Annex"(positingTimepoint) a
ON
    a."EV_REV_ID" = p."EV_REV_ID"
ORDER BY
    p."EV_REV_ID",
    a."EV_REV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Händelse_Status_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" integer,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_STA_ID",
    "EV_STA_EV_ID",
    "EV_STA_Händelse_Status",
    "EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Händelse_Status_Posit"
WHERE
    "EV_STA_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Händelse_Status_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_STA_ID" integer,
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT
    "EV_STA_ID",
    "EV_STA_EV_ID",
    "EV_STA_Händelse_Status",
    "EV_STA_ChangedAt"
FROM
    attributes."EV_STA_Händelse_Status_Posit"
WHERE
    "EV_STA_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Händelse_Status_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_STA",
    "EV_STA_ID",
    "EV_STA_PositedAt",
    "EV_STA_Reliability"
FROM
    attributes."EV_STA_Händelse_Status_Annex"
WHERE
    "EV_STA_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_STA_Händelse_Status" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."rEV_STA_Händelse_Status_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Händelse_Status_Annex"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
ORDER BY
    p."EV_STA_ID",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_STA_Händelse_Status" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_EV_ID" numeric(12,0),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_STA_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."EV_STA_ID")
    a."Metadata_EV_STA",
    p."EV_STA_ID",
    a."EV_STA_PositedAt",
    a."EV_STA_Reliability",
    p."EV_STA_EV_ID",
    p."EV_STA_Händelse_Status",
    p."EV_STA_ChangedAt"
FROM
    attributes."fEV_STA_Händelse_Status_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_STA_Händelse_Status_Annex"(positingTimepoint) a
ON
    a."EV_STA_ID" = p."EV_STA_ID"
ORDER BY
    p."EV_STA_ID",
    a."EV_STA_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preEV_STA_Händelse_Status" (
    id numeric(12,0),
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(20)
AS
$$
SELECT
    pre."EV_STA_Händelse_Status"
FROM
    attributes."rEV_STA_Händelse_Status"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_STA_EV_ID" = id
AND
    pre."EV_STA_ChangedAt" < changingTimepoint
AND
    pre."EV_STA_Reliability" = 1
ORDER BY
    pre."EV_STA_ChangedAt" DESC,
    pre."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folEV_STA_Händelse_Status" (
    id numeric(12,0),
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(20)
AS
$$
SELECT
    fol."EV_STA_Händelse_Status"
FROM
    attributes."fEV_STA_Händelse_Status"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_STA_EV_ID" = id
AND
    fol."EV_STA_ChangedAt" > changingTimepoint
AND
    fol."EV_STA_Reliability" = 1
ORDER BY
    fol."EV_STA_ChangedAt" ASC,
    fol."EV_STA_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Händelse_Utnyttjande_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_UTL",
    "EV_UTL_ID",
    "EV_UTL_PositedAt",
    "EV_UTL_Reliability"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Annex"
WHERE
    "EV_UTL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_UTL_Händelse_Utnyttjande" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_EV_ID" numeric(12,0),
    "EV_UTL_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."EV_UTL_ID")
    a."Metadata_EV_UTL",
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt",
    a."EV_UTL_Reliability",
    p."EV_UTL_EV_ID",
    p."EV_UTL_UTL_ID"
FROM
    attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
JOIN
    attributes."rEV_UTL_Händelse_Utnyttjande_Annex"(positingTimepoint) a
ON
    a."EV_UTL_ID" = p."EV_UTL_ID"
ORDER BY
    p."EV_UTL_ID",
    a."EV_UTL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" integer,
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
    attributes."EV_LVL_Händelse_Level_Posit"
WHERE
    "EV_LVL_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Händelse_Level_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "EV_LVL_ID" integer,
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
    attributes."EV_LVL_Händelse_Level_Posit"
WHERE
    "EV_LVL_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_LVL",
    "EV_LVL_ID",
    "EV_LVL_PositedAt",
    "EV_LVL_Reliability"
FROM
    attributes."EV_LVL_Händelse_Level_Annex"
WHERE
    "EV_LVL_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rEV_LVL_Händelse_Level" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."rEV_LVL_Händelse_Level_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Händelse_Level_Annex"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
ORDER BY
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fEV_LVL_Händelse_Level" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_EV_ID" numeric(12,0),
    "EV_LVL_PLV_ID" smallint, 
    "EV_LVL_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."EV_LVL_ID")
    a."Metadata_EV_LVL",
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt",
    a."EV_LVL_Reliability",
    p."EV_LVL_EV_ID",
    p."EV_LVL_PLV_ID",
    p."EV_LVL_ChangedAt"
FROM
    attributes."fEV_LVL_Händelse_Level_Posit"(changingTimepoint) p
JOIN
    attributes."rEV_LVL_Händelse_Level_Annex"(positingTimepoint) a
ON
    a."EV_LVL_ID" = p."EV_LVL_ID"
ORDER BY
    p."EV_LVL_ID",
    a."EV_LVL_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preEV_LVL_Händelse_Level" (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    pre."EV_LVL_PLV_ID"
FROM
    attributes."rEV_LVL_Händelse_Level"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."EV_LVL_EV_ID" = id
AND
    pre."EV_LVL_ChangedAt" < changingTimepoint
AND
    pre."EV_LVL_Reliability" = 1
ORDER BY
    pre."EV_LVL_ChangedAt" DESC,
    pre."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folEV_LVL_Händelse_Level" (
    id numeric(12,0),
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    fol."EV_LVL_PLV_ID"
FROM
    attributes."fEV_LVL_Händelse_Level"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."EV_LVL_EV_ID" = id
AND
    fol."EV_LVL_ChangedAt" > changingTimepoint
AND
    fol."EV_LVL_Reliability" = 1
ORDER BY
    fol."EV_LVL_ChangedAt" ASC,
    fol."EV_LVL_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_NAM_ID",
    "ST_NAM_ST_ID",
    "ST_NAM_Scen_Namn",
    "ST_NAM_ChangedAt"
FROM
    attributes."ST_NAM_Scen_Namn_Posit"
WHERE
    "ST_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Scen_Namn_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_NAM_ID" integer,
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_NAM_ID",
    "ST_NAM_ST_ID",
    "ST_NAM_Scen_Namn",
    "ST_NAM_ChangedAt"
FROM
    attributes."ST_NAM_Scen_Namn_Posit"
WHERE
    "ST_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_NAM",
    "ST_NAM_ID",
    "ST_NAM_PositedAt",
    "ST_NAM_Reliability"
FROM
    attributes."ST_NAM_Scen_Namn_Annex"
WHERE
    "ST_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_NAM_Scen_Namn" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt"
FROM
    attributes."rST_NAM_Scen_Namn_Posit"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Scen_Namn_Annex"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
ORDER BY
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_NAM_Scen_Namn" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_ST_ID" integer,
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_NAM_ID")
    a."Metadata_ST_NAM",
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt",
    a."ST_NAM_Reliability",
    p."ST_NAM_ST_ID",
    p."ST_NAM_Scen_Namn",
    p."ST_NAM_ChangedAt"
FROM
    attributes."fST_NAM_Scen_Namn_Posit"(changingTimepoint) p
JOIN
    attributes."rST_NAM_Scen_Namn_Annex"(positingTimepoint) a
ON
    a."ST_NAM_ID" = p."ST_NAM_ID"
ORDER BY
    p."ST_NAM_ID",
    a."ST_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preST_NAM_Scen_Namn" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."ST_NAM_Scen_Namn"
FROM
    attributes."rST_NAM_Scen_Namn"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_NAM_ST_ID" = id
AND
    pre."ST_NAM_ChangedAt" < changingTimepoint
AND
    pre."ST_NAM_Reliability" = 1
ORDER BY
    pre."ST_NAM_ChangedAt" DESC,
    pre."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folST_NAM_Scen_Namn" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."ST_NAM_Scen_Namn"
FROM
    attributes."fST_NAM_Scen_Namn"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_NAM_ST_ID" = id
AND
    fol."ST_NAM_ChangedAt" > changingTimepoint
AND
    fol."ST_NAM_Reliability" = 1
ORDER BY
    fol."ST_NAM_ChangedAt" ASC,
    fol."ST_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Scen_Plats_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_LOC",
    "ST_LOC_ID",
    "ST_LOC_PositedAt",
    "ST_LOC_Reliability"
FROM
    attributes."ST_LOC_Scen_Plats_Annex"
WHERE
    "ST_LOC_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_LOC_Scen_Plats" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_ST_ID" integer,
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text
)
AS
$$
SELECT DISTINCT ON (p."ST_LOC_ID")
    a."Metadata_ST_LOC",
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt",
    a."ST_LOC_Reliability",
    p."ST_LOC_ST_ID",
    p."ST_LOC_Checksum",
    p."ST_LOC_Scen_Plats"
FROM
    attributes."ST_LOC_Scen_Plats_Posit" p
JOIN
    attributes."rST_LOC_Scen_Plats_Annex"(positingTimepoint) a
ON
    a."ST_LOC_ID" = p."ST_LOC_ID"
ORDER BY
    p."ST_LOC_ID",
    a."ST_LOC_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel_Posit" (
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
    attributes."ST_AVG_Scen_Medel_Posit"
WHERE
    "ST_AVG_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Scen_Medel_Posit" (
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
    attributes."ST_AVG_Scen_Medel_Posit"
WHERE
    "ST_AVG_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_AVG",
    "ST_AVG_ID",
    "ST_AVG_PositedAt",
    "ST_AVG_Reliability"
FROM
    attributes."ST_AVG_Scen_Medel_Annex"
WHERE
    "ST_AVG_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_AVG_Scen_Medel" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."rST_AVG_Scen_Medel_Posit"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Scen_Medel_Annex"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
ORDER BY
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fST_AVG_Scen_Medel" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_ST_ID" integer,
    "ST_AVG_UTL_ID" smallint, 
    "ST_AVG_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."ST_AVG_ID")
    a."Metadata_ST_AVG",
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt",
    a."ST_AVG_Reliability",
    p."ST_AVG_ST_ID",
    p."ST_AVG_UTL_ID",
    p."ST_AVG_ChangedAt"
FROM
    attributes."fST_AVG_Scen_Medel_Posit"(changingTimepoint) p
JOIN
    attributes."rST_AVG_Scen_Medel_Annex"(positingTimepoint) a
ON
    a."ST_AVG_ID" = p."ST_AVG_ID"
ORDER BY
    p."ST_AVG_ID",
    a."ST_AVG_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preST_AVG_Scen_Medel" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    pre."ST_AVG_UTL_ID"
FROM
    attributes."rST_AVG_Scen_Medel"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."ST_AVG_ST_ID" = id
AND
    pre."ST_AVG_ChangedAt" < changingTimepoint
AND
    pre."ST_AVG_Reliability" = 1
ORDER BY
    pre."ST_AVG_ChangedAt" DESC,
    pre."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folST_AVG_Scen_Medel" (
    id integer,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    fol."ST_AVG_UTL_ID"
FROM
    attributes."fST_AVG_Scen_Medel"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."ST_AVG_ST_ID" = id
AND
    fol."ST_AVG_ChangedAt" > changingTimepoint
AND
    fol."ST_AVG_Reliability" = 1
ORDER BY
    fol."ST_AVG_ChangedAt" ASC,
    fol."ST_AVG_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Scen_Minimum_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_MIN",
    "ST_MIN_ID",
    "ST_MIN_PositedAt",
    "ST_MIN_Reliability"
FROM
    attributes."ST_MIN_Scen_Minimum_Annex"
WHERE
    "ST_MIN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rST_MIN_Scen_Minimum" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_ST_ID" integer,
    "ST_MIN_UTL_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."ST_MIN_ID")
    a."Metadata_ST_MIN",
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt",
    a."ST_MIN_Reliability",
    p."ST_MIN_ST_ID",
    p."ST_MIN_UTL_ID"
FROM
    attributes."ST_MIN_Scen_Minimum_Posit" p
JOIN
    attributes."rST_MIN_Scen_Minimum_Annex"(positingTimepoint) a
ON
    a."ST_MIN_ID" = p."ST_MIN_ID"
ORDER BY
    p."ST_MIN_ID",
    a."ST_MIN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" integer,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_NAM_ID",
    "AC_NAM_AC_ID",
    "AC_NAM_Skådespelare_Namn",
    "AC_NAM_ChangedAt"
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit"
WHERE
    "AC_NAM_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Skådespelare_Namn_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_NAM_ID" integer,
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_NAM_ID",
    "AC_NAM_AC_ID",
    "AC_NAM_Skådespelare_Namn",
    "AC_NAM_ChangedAt"
FROM
    attributes."AC_NAM_Skådespelare_Namn_Posit"
WHERE
    "AC_NAM_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_NAM",
    "AC_NAM_ID",
    "AC_NAM_PositedAt",
    "AC_NAM_Reliability"
FROM
    attributes."AC_NAM_Skådespelare_Namn_Annex"
WHERE
    "AC_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_NAM_Skådespelare_Namn" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt"
FROM
    attributes."rAC_NAM_Skådespelare_Namn_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Skådespelare_Namn_Annex"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
ORDER BY
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_NAM_Skådespelare_Namn" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_AC_ID" smallint,
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_NAM_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_NAM_ID")
    a."Metadata_AC_NAM",
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt",
    a."AC_NAM_Reliability",
    p."AC_NAM_AC_ID",
    p."AC_NAM_Skådespelare_Namn",
    p."AC_NAM_ChangedAt"
FROM
    attributes."fAC_NAM_Skådespelare_Namn_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_NAM_Skådespelare_Namn_Annex"(positingTimepoint) a
ON
    a."AC_NAM_ID" = p."AC_NAM_ID"
ORDER BY
    p."AC_NAM_ID",
    a."AC_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preAC_NAM_Skådespelare_Namn" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    pre."AC_NAM_Skådespelare_Namn"
FROM
    attributes."rAC_NAM_Skådespelare_Namn"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_NAM_AC_ID" = id
AND
    pre."AC_NAM_ChangedAt" < changingTimepoint
AND
    pre."AC_NAM_Reliability" = 1
ORDER BY
    pre."AC_NAM_ChangedAt" DESC,
    pre."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folAC_NAM_Skådespelare_Namn" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS varchar(42)
AS
$$
SELECT
    fol."AC_NAM_Skådespelare_Namn"
FROM
    attributes."fAC_NAM_Skådespelare_Namn"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_NAM_AC_ID" = id
AND
    fol."AC_NAM_ChangedAt" > changingTimepoint
AND
    fol."AC_NAM_Reliability" = 1
ORDER BY
    fol."AC_NAM_ChangedAt" ASC,
    fol."AC_NAM_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Skådespelare_Kön_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_GEN",
    "AC_GEN_ID",
    "AC_GEN_PositedAt",
    "AC_GEN_Reliability"
FROM
    attributes."AC_GEN_Skådespelare_Kön_Annex"
WHERE
    "AC_GEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_GEN_Skådespelare_Kön" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_AC_ID" smallint,
    "AC_GEN_GEN_ID" smallint 
)
AS
$$
SELECT DISTINCT ON (p."AC_GEN_ID")
    a."Metadata_AC_GEN",
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt",
    a."AC_GEN_Reliability",
    p."AC_GEN_AC_ID",
    p."AC_GEN_GEN_ID"
FROM
    attributes."AC_GEN_Skådespelare_Kön_Posit" p
JOIN
    attributes."rAC_GEN_Skådespelare_Kön_Annex"(positingTimepoint) a
ON
    a."AC_GEN_ID" = p."AC_GEN_ID"
ORDER BY
    p."AC_GEN_ID",
    a."AC_GEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" integer,
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
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"
WHERE
    "AC_PLV_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Skådespelare_Yrkesnivå_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_PLV_ID" integer,
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
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"
WHERE
    "AC_PLV_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_PLV",
    "AC_PLV_ID",
    "AC_PLV_PositedAt",
    "AC_PLV_Reliability"
FROM
    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex"
WHERE
    "AC_PLV_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rAC_PLV_Skådespelare_Yrkesnivå" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."rAC_PLV_Skådespelare_Yrkesnivå_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Skådespelare_Yrkesnivå_Annex"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
ORDER BY
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fAC_PLV_Skådespelare_Yrkesnivå" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_AC_ID" smallint,
    "AC_PLV_PLV_ID" smallint, 
    "AC_PLV_ChangedAt" timestamp
)
AS
$$
SELECT DISTINCT ON (p."AC_PLV_ID")
    a."Metadata_AC_PLV",
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt",
    a."AC_PLV_Reliability",
    p."AC_PLV_AC_ID",
    p."AC_PLV_PLV_ID",
    p."AC_PLV_ChangedAt"
FROM
    attributes."fAC_PLV_Skådespelare_Yrkesnivå_Posit"(changingTimepoint) p
JOIN
    attributes."rAC_PLV_Skådespelare_Yrkesnivå_Annex"(positingTimepoint) a
ON
    a."AC_PLV_ID" = p."AC_PLV_ID"
ORDER BY
    p."AC_PLV_ID",
    a."AC_PLV_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."preAC_PLV_Skådespelare_Yrkesnivå" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    pre."AC_PLV_PLV_ID"
FROM
    attributes."rAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."AC_PLV_AC_ID" = id
AND
    pre."AC_PLV_ChangedAt" < changingTimepoint
AND
    pre."AC_PLV_Reliability" = 1
ORDER BY
    pre."AC_PLV_ChangedAt" DESC,
    pre."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folAC_PLV_Skådespelare_Yrkesnivå" (
    id smallint,
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS smallint
AS
$$
SELECT
    fol."AC_PLV_PLV_ID"
FROM
    attributes."fAC_PLV_Skådespelare_Yrkesnivå"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."AC_PLV_AC_ID" = id
AND
    fol."AC_PLV_ChangedAt" > changingTimepoint
AND
    fol."AC_PLV_Reliability" = 1
ORDER BY
    fol."AC_PLV_ChangedAt" ASC,
    fol."AC_PLV_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Föreställning_Namn_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_PR_NAM",
    "PR_NAM_ID",
    "PR_NAM_PositedAt",
    "PR_NAM_Reliability"
FROM
    attributes."PR_NAM_Föreställning_Namn_Annex"
WHERE
    "PR_NAM_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_NAM_Föreställning_Namn" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_PR_ID" bigint,
    "PR_NAM_Föreställning_Namn" varchar(42)
)
AS
$$
SELECT DISTINCT ON (p."PR_NAM_ID")
    a."Metadata_PR_NAM",
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt",
    a."PR_NAM_Reliability",
    p."PR_NAM_PR_ID",
    p."PR_NAM_Föreställning_Namn"
FROM
    attributes."PR_NAM_Föreställning_Namn_Posit" p
JOIN
    attributes."rPR_NAM_Föreställning_Namn_Annex"(positingTimepoint) a
ON
    a."PR_NAM_ID" = p."PR_NAM_ID"
ORDER BY
    p."PR_NAM_ID",
    a."PR_NAM_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" integer,
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Föreställning_Längd" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    "PR_LEN_ID",
    "PR_LEN_PR_ID",
    "PR_LEN_Föreställning_Längd",
    "PR_LEN_ChangedAt"
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit"
WHERE
    "PR_LEN_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Föreställning_Längd_Posit" (
    changingTimepoint date
)
RETURNS TABLE (
    "PR_LEN_ID" integer,
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Föreställning_Längd" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT
    "PR_LEN_ID",
    "PR_LEN_PR_ID",
    "PR_LEN_Föreställning_Längd",
    "PR_LEN_ChangedAt"
FROM
    attributes."PR_LEN_Föreställning_Längd_Posit"
WHERE
    "PR_LEN_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_PR_LEN",
    "PR_LEN_ID",
    "PR_LEN_PositedAt",
    "PR_LEN_Reliability"
FROM
    attributes."PR_LEN_Föreställning_Längd_Annex"
WHERE
    "PR_LEN_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."rPR_LEN_Föreställning_Längd" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Föreställning_Längd" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt"
FROM
    attributes."rPR_LEN_Föreställning_Längd_Posit"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Föreställning_Längd_Annex"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
ORDER BY
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."fPR_LEN_Föreställning_Längd" (
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_PR_ID" bigint,
    "PR_LEN_Föreställning_Längd" time,
    "PR_LEN_ChangedAt" date
)
AS
$$
SELECT DISTINCT ON (p."PR_LEN_ID")
    a."Metadata_PR_LEN",
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt",
    a."PR_LEN_Reliability",
    p."PR_LEN_PR_ID",
    p."PR_LEN_Föreställning_Längd",
    p."PR_LEN_ChangedAt"
FROM
    attributes."fPR_LEN_Föreställning_Längd_Posit"(changingTimepoint) p
JOIN
    attributes."rPR_LEN_Föreställning_Längd_Annex"(positingTimepoint) a
ON
    a."PR_LEN_ID" = p."PR_LEN_ID"
ORDER BY
    p."PR_LEN_ID",
    a."PR_LEN_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."prePR_LEN_Föreställning_Längd" (
    id bigint,
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS time
AS
$$
SELECT
    pre."PR_LEN_Föreställning_Längd"
FROM
    attributes."rPR_LEN_Föreställning_Längd"(changingTimepoint, positingTimepoint) pre
WHERE
    pre."PR_LEN_PR_ID" = id
AND
    pre."PR_LEN_ChangedAt" < changingTimepoint
AND
    pre."PR_LEN_Reliability" = 1
ORDER BY
    pre."PR_LEN_ChangedAt" DESC,
    pre."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION attributes."folPR_LEN_Föreställning_Längd" (
    id bigint,
    changingTimepoint date,
    positingTimepoint timestamp
)
RETURNS time
AS
$$
SELECT
    fol."PR_LEN_Föreställning_Längd"
FROM
    attributes."fPR_LEN_Föreställning_Längd"(changingTimepoint, positingTimepoint) fol
WHERE
    fol."PR_LEN_PR_ID" = id
AND
    fol."PR_LEN_ChangedAt" > changingTimepoint
AND
    fol."PR_LEN_Reliability" = 1
ORDER BY
    fol."PR_LEN_ChangedAt" ASC,
    fol."PR_LEN_PositedAt" DESC
LIMIT 1
$$ LANGUAGE sql STABLE;
-- ANCHOR TEMPORAL PERSPECTIVES ---------------------------------------------------------------------------------------
--
-- BI anchor perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION anchors."tST_Scen" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_UTL_Utnyttjande" smallint,
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
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Scen_Plats",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utnyttjande" AS "ST_AVG_UTL_Utnyttjande",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utnyttjande" AS "ST_MIN_UTL_Utnyttjande",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM
    anchors."ST_Scen" "ST"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_NAM_ST_ID")
        r.*
    FROM
        attributes."rST_NAM_Scen_Namn"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."ST_NAM_Reliability" = 1
    ORDER BY
    r."ST_NAM_ST_ID",
    r."ST_NAM_ChangedAt" DESC,
    r."ST_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_LOC_ST_ID")
        r.*
    FROM
        attributes."rST_LOC_Scen_Plats"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."ST_LOC_Reliability" = 1
    ORDER BY
    r."ST_LOC_ST_ID",
    r."ST_LOC_PositedAt" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_AVG_ST_ID")
        r.*
    FROM
        attributes."rST_AVG_Scen_Medel"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."ST_AVG_Reliability" = 1
    ORDER BY
    r."ST_AVG_ST_ID",
    r."ST_AVG_ChangedAt" DESC,
    r."ST_AVG_PositedAt" DESC
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."ST_MIN_ST_ID")
        r.*
    FROM
        attributes."rST_MIN_Scen_Minimum"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."ST_MIN_Reliability" = 1
    ORDER BY
    r."ST_MIN_ST_ID",
    r."ST_MIN_PositedAt" DESC
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."lST_Scen" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    anchors."tST_Scen"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "ST"
;
CREATE OR REPLACE FUNCTION anchors."pST_Scen" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "ST"."ST_NAM_ST_ID",
    "ST"."Metadata_ST_NAM",
    "ST"."ST_NAM_ID",
    "ST"."ST_NAM_ChangedAt",
    "ST"."ST_NAM_PositedAt",
    "ST"."ST_NAM_Reliability",
    "ST"."ST_NAM_Scen_Namn",
    "ST"."ST_LOC_ST_ID",
    "ST"."Metadata_ST_LOC",
    "ST"."ST_LOC_ID",
    "ST"."ST_LOC_PositedAt",
    "ST"."ST_LOC_Reliability",
    "ST"."ST_LOC_Checksum",
    "ST"."ST_LOC_Scen_Plats",
    "ST"."ST_AVG_ST_ID",
    "ST"."Metadata_ST_AVG",
    "ST"."ST_AVG_ID",
    "ST"."ST_AVG_ChangedAt",
    "ST"."ST_AVG_PositedAt",
    "ST"."ST_AVG_Reliability",
    "ST"."ST_AVG_UTL_Utnyttjande",
    "ST"."ST_AVG_Metadata_UTL",
    "ST"."ST_AVG_UTL_ID",
    "ST"."ST_MIN_ST_ID",
    "ST"."Metadata_ST_MIN",
    "ST"."ST_MIN_ID",
    "ST"."ST_MIN_PositedAt",
    "ST"."ST_MIN_Reliability",
    "ST"."ST_MIN_UTL_Utnyttjande",
    "ST"."ST_MIN_Metadata_UTL",
    "ST"."ST_MIN_UTL_ID"
FROM
    anchors."tST_Scen"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "ST"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."nST_Scen" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "ST".*
FROM
    anchors."tST_Scen"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "ST"
;
CREATE OR REPLACE FUNCTION anchors."dST_Scen" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "ST_ID" integer,
    "Metadata_ST" integer,
    "ST_NAM_ST_ID" integer,
    "Metadata_ST_NAM" integer,
    "ST_NAM_ID" integer,
    "ST_NAM_ChangedAt" timestamp,
    "ST_NAM_PositedAt" timestamp,
    "ST_NAM_Reliability" decimal(5,2),
    "ST_NAM_Scen_Namn" varchar(42),
    "ST_LOC_ST_ID" integer,
    "Metadata_ST_LOC" integer,
    "ST_LOC_ID" integer,
    "ST_LOC_PositedAt" timestamp,
    "ST_LOC_Reliability" decimal(5,2),
    "ST_LOC_Checksum" bytea,
    "ST_LOC_Scen_Plats" text,
    "ST_AVG_ST_ID" integer,
    "Metadata_ST_AVG" integer,
    "ST_AVG_ID" integer,
    "ST_AVG_ChangedAt" timestamp,
    "ST_AVG_PositedAt" timestamp,
    "ST_AVG_Reliability" decimal(5,2),
    "ST_AVG_UTL_Utnyttjande" smallint,
    "ST_AVG_Metadata_UTL" integer,
    "ST_AVG_UTL_ID" smallint,
    "ST_MIN_ST_ID" integer,
    "Metadata_ST_MIN" integer,
    "ST_MIN_ID" integer,
    "ST_MIN_PositedAt" timestamp,
    "ST_MIN_Reliability" decimal(5,2),
    "ST_MIN_UTL_Utnyttjande" smallint,
    "ST_MIN_Metadata_UTL" integer,
    "ST_MIN_UTL_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "ST"."ST_ID",
    "ST"."Metadata_ST",
    "NAM"."ST_NAM_ST_ID",
    "NAM"."Metadata_ST_NAM",
    "NAM"."ST_NAM_ID",
    "NAM"."ST_NAM_ChangedAt",
    "NAM"."ST_NAM_PositedAt",
    "NAM"."ST_NAM_Reliability",
    "NAM"."ST_NAM_Scen_Namn",
    "LOC"."ST_LOC_ST_ID",
    "LOC"."Metadata_ST_LOC",
    "LOC"."ST_LOC_ID",
    "LOC"."ST_LOC_PositedAt",
    "LOC"."ST_LOC_Reliability",
    "LOC"."ST_LOC_Checksum",
    "LOC"."ST_LOC_Scen_Plats",
    "AVG"."ST_AVG_ST_ID",
    "AVG"."Metadata_ST_AVG",
    "AVG"."ST_AVG_ID",
    "AVG"."ST_AVG_ChangedAt",
    "AVG"."ST_AVG_PositedAt",
    "AVG"."ST_AVG_Reliability",
    "kAVG"."UTL_Utnyttjande" AS "ST_AVG_UTL_Utnyttjande",
    "kAVG"."Metadata_UTL" AS "ST_AVG_Metadata_UTL",
    "AVG"."ST_AVG_UTL_ID",
    "MIN"."ST_MIN_ST_ID",
    "MIN"."Metadata_ST_MIN",
    "MIN"."ST_MIN_ID",
    "MIN"."ST_MIN_PositedAt",
    "MIN"."ST_MIN_Reliability",
    "kMIN"."UTL_Utnyttjande" AS "ST_MIN_UTL_Utnyttjande",
    "kMIN"."Metadata_UTL" AS "ST_MIN_Metadata_UTL",
    "MIN"."ST_MIN_UTL_ID"
FROM (
    SELECT DISTINCT
        "ST_NAM_ST_ID" AS "ST_ID",
        "ST_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."ST_NAM_Scen_Namn"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "ST_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "ST_AVG_ST_ID" AS "ST_ID",
        "ST_AVG_ChangedAt"::timestamp AS inspectedTimepoint,
        'AVG' AS mnemonic
    FROM
        attributes."ST_AVG_Scen_Medel"
    WHERE
        (selection IS NULL OR selection LIKE '%AVG%')
    AND
        "ST_AVG_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."ST_Scen" "ST"
ON
    "ST"."ST_ID" = timepoints."ST_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."ST_NAM_ChangedAt") OVER (
            PARTITION BY x."ST_NAM_ST_ID"
            ORDER BY x."ST_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt")
            r.*
        FROM
            attributes."rST_NAM_Scen_Namn"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."ST_NAM_Reliability" = 1
        ORDER BY
    r."ST_NAM_ST_ID", r."ST_NAM_ChangedAt",
    r."ST_NAM_PositedAt" DESC
    ) x
) "NAM"
ON
    "NAM"."ST_NAM_ST_ID" = "ST"."ST_ID"
AND
    "NAM"."ST_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_LOC_ST_ID")
        r.*
    FROM
        attributes."rST_LOC_Scen_Plats"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."ST_LOC_Reliability" = 1
    ORDER BY
    r."ST_LOC_ST_ID",
    r."ST_LOC_PositedAt" DESC
) "LOC"
ON
    "LOC"."ST_LOC_ST_ID" = "ST"."ST_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."ST_AVG_ChangedAt") OVER (
            PARTITION BY x."ST_AVG_ST_ID"
            ORDER BY x."ST_AVG_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt")
            r.*
        FROM
            attributes."rST_AVG_Scen_Medel"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."ST_AVG_Reliability" = 1
        ORDER BY
    r."ST_AVG_ST_ID", r."ST_AVG_ChangedAt",
    r."ST_AVG_PositedAt" DESC
    ) x
) "AVG"
ON
    "AVG"."ST_AVG_ST_ID" = "ST"."ST_ID"
AND
    "AVG"."ST_AVG_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "AVG"."until" IS NULL
OR
    "AVG"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."UTL_Utnyttjande" "kAVG"
ON
    "kAVG"."UTL_ID" = "AVG"."ST_AVG_UTL_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."ST_MIN_ST_ID")
        r.*
    FROM
        attributes."rST_MIN_Scen_Minimum"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."ST_MIN_Reliability" = 1
    ORDER BY
    r."ST_MIN_ST_ID",
    r."ST_MIN_PositedAt" DESC
) "MIN"
ON
    "MIN"."ST_MIN_ST_ID" = "ST"."ST_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kMIN"
ON
    "kMIN"."UTL_ID" = "MIN"."ST_MIN_UTL_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION anchors."tAC_Skådespelare" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_Yrkesnivå" text,
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
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Skådespelare_Namn",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Kön" AS "AC_GEN_GEN_Kön",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM
    anchors."AC_Skådespelare" "AC"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."AC_NAM_AC_ID")
        r.*
    FROM
        attributes."rAC_NAM_Skådespelare_Namn"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_NAM_Reliability" = 1
    ORDER BY
    r."AC_NAM_AC_ID",
    r."AC_NAM_ChangedAt" DESC,
    r."AC_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."AC_GEN_AC_ID")
        r.*
    FROM
        attributes."rAC_GEN_Skådespelare_Kön"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_GEN_Reliability" = 1
    ORDER BY
    r."AC_GEN_AC_ID",
    r."AC_GEN_PositedAt" DESC
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."AC_PLV_AC_ID")
        r.*
    FROM
        attributes."rAC_PLV_Skådespelare_Yrkesnivå"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_PLV_Reliability" = 1
    ORDER BY
    r."AC_PLV_AC_ID",
    r."AC_PLV_ChangedAt" DESC,
    r."AC_PLV_PositedAt" DESC
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."PLV_Yrkesnivå" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."lAC_Skådespelare" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    anchors."tAC_Skådespelare"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "AC"
;
CREATE OR REPLACE FUNCTION anchors."pAC_Skådespelare" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "AC"."AC_NAM_AC_ID",
    "AC"."Metadata_AC_NAM",
    "AC"."AC_NAM_ID",
    "AC"."AC_NAM_ChangedAt",
    "AC"."AC_NAM_PositedAt",
    "AC"."AC_NAM_Reliability",
    "AC"."AC_NAM_Skådespelare_Namn",
    "AC"."AC_GEN_AC_ID",
    "AC"."Metadata_AC_GEN",
    "AC"."AC_GEN_ID",
    "AC"."AC_GEN_PositedAt",
    "AC"."AC_GEN_Reliability",
    "AC"."AC_GEN_GEN_Checksum",
    "AC"."AC_GEN_GEN_Kön",
    "AC"."AC_GEN_Metadata_GEN",
    "AC"."AC_GEN_GEN_ID",
    "AC"."AC_PLV_AC_ID",
    "AC"."Metadata_AC_PLV",
    "AC"."AC_PLV_ID",
    "AC"."AC_PLV_ChangedAt",
    "AC"."AC_PLV_PositedAt",
    "AC"."AC_PLV_Reliability",
    "AC"."AC_PLV_PLV_Checksum",
    "AC"."AC_PLV_PLV_Yrkesnivå",
    "AC"."AC_PLV_Metadata_PLV",
    "AC"."AC_PLV_PLV_ID"
FROM
    anchors."tAC_Skådespelare"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "AC"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."nAC_Skådespelare" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "AC".*
FROM
    anchors."tAC_Skådespelare"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "AC"
;
CREATE OR REPLACE FUNCTION anchors."dAC_Skådespelare" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "AC_ID" smallint,
    "Metadata_AC" integer,
    "AC_NAM_AC_ID" smallint,
    "Metadata_AC_NAM" integer,
    "AC_NAM_ID" integer,
    "AC_NAM_ChangedAt" timestamp,
    "AC_NAM_PositedAt" timestamp,
    "AC_NAM_Reliability" decimal(5,2),
    "AC_NAM_Skådespelare_Namn" varchar(42),
    "AC_GEN_AC_ID" smallint,
    "Metadata_AC_GEN" integer,
    "AC_GEN_ID" integer,
    "AC_GEN_PositedAt" timestamp,
    "AC_GEN_Reliability" decimal(5,2),
    "AC_GEN_GEN_Checksum" bytea,
    "AC_GEN_GEN_Kön" varchar(42),
    "AC_GEN_Metadata_GEN" integer,
    "AC_GEN_GEN_ID" smallint,
    "AC_PLV_AC_ID" smallint,
    "Metadata_AC_PLV" integer,
    "AC_PLV_ID" integer,
    "AC_PLV_ChangedAt" timestamp,
    "AC_PLV_PositedAt" timestamp,
    "AC_PLV_Reliability" decimal(5,2),
    "AC_PLV_PLV_Checksum" bytea,
    "AC_PLV_PLV_Yrkesnivå" text,
    "AC_PLV_Metadata_PLV" integer,
    "AC_PLV_PLV_ID" smallint
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "AC"."AC_ID",
    "AC"."Metadata_AC",
    "NAM"."AC_NAM_AC_ID",
    "NAM"."Metadata_AC_NAM",
    "NAM"."AC_NAM_ID",
    "NAM"."AC_NAM_ChangedAt",
    "NAM"."AC_NAM_PositedAt",
    "NAM"."AC_NAM_Reliability",
    "NAM"."AC_NAM_Skådespelare_Namn",
    "GEN"."AC_GEN_AC_ID",
    "GEN"."Metadata_AC_GEN",
    "GEN"."AC_GEN_ID",
    "GEN"."AC_GEN_PositedAt",
    "GEN"."AC_GEN_Reliability",
    "kGEN"."GEN_Checksum" AS "AC_GEN_GEN_Checksum",
    "kGEN"."GEN_Kön" AS "AC_GEN_GEN_Kön",
    "kGEN"."Metadata_GEN" AS "AC_GEN_Metadata_GEN",
    "GEN"."AC_GEN_GEN_ID",
    "PLV"."AC_PLV_AC_ID",
    "PLV"."Metadata_AC_PLV",
    "PLV"."AC_PLV_ID",
    "PLV"."AC_PLV_ChangedAt",
    "PLV"."AC_PLV_PositedAt",
    "PLV"."AC_PLV_Reliability",
    "kPLV"."PLV_Checksum" AS "AC_PLV_PLV_Checksum",
    "kPLV"."PLV_Yrkesnivå" AS "AC_PLV_PLV_Yrkesnivå",
    "kPLV"."Metadata_PLV" AS "AC_PLV_Metadata_PLV",
    "PLV"."AC_PLV_PLV_ID"
FROM (
    SELECT DISTINCT
        "AC_NAM_AC_ID" AS "AC_ID",
        "AC_NAM_ChangedAt"::timestamp AS inspectedTimepoint,
        'NAM' AS mnemonic
    FROM
        attributes."AC_NAM_Skådespelare_Namn"
    WHERE
        (selection IS NULL OR selection LIKE '%NAM%')
    AND
        "AC_NAM_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "AC_PLV_AC_ID" AS "AC_ID",
        "AC_PLV_ChangedAt"::timestamp AS inspectedTimepoint,
        'PLV' AS mnemonic
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå"
    WHERE
        (selection IS NULL OR selection LIKE '%PLV%')
    AND
        "AC_PLV_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."AC_Skådespelare" "AC"
ON
    "AC"."AC_ID" = timepoints."AC_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."AC_NAM_ChangedAt") OVER (
            PARTITION BY x."AC_NAM_AC_ID"
            ORDER BY x."AC_NAM_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt")
            r.*
        FROM
            attributes."rAC_NAM_Skådespelare_Namn"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_NAM_Reliability" = 1
        ORDER BY
    r."AC_NAM_AC_ID", r."AC_NAM_ChangedAt",
    r."AC_NAM_PositedAt" DESC
    ) x
) "NAM"
ON
    "NAM"."AC_NAM_AC_ID" = "AC"."AC_ID"
AND
    "NAM"."AC_NAM_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "NAM"."until" IS NULL
OR
    "NAM"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."AC_GEN_AC_ID")
        r.*
    FROM
        attributes."rAC_GEN_Skådespelare_Kön"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."AC_GEN_Reliability" = 1
    ORDER BY
    r."AC_GEN_AC_ID",
    r."AC_GEN_PositedAt" DESC
) "GEN"
ON
    "GEN"."AC_GEN_AC_ID" = "AC"."AC_ID"
LEFT JOIN
    knots."GEN_Kön" "kGEN"
ON
    "kGEN"."GEN_ID" = "GEN"."AC_GEN_GEN_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."AC_PLV_ChangedAt") OVER (
            PARTITION BY x."AC_PLV_AC_ID"
            ORDER BY x."AC_PLV_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt")
            r.*
        FROM
            attributes."rAC_PLV_Skådespelare_Yrkesnivå"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."AC_PLV_Reliability" = 1
        ORDER BY
    r."AC_PLV_AC_ID", r."AC_PLV_ChangedAt",
    r."AC_PLV_PositedAt" DESC
    ) x
) "PLV"
ON
    "PLV"."AC_PLV_AC_ID" = "AC"."AC_ID"
AND
    "PLV"."AC_PLV_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "PLV"."until" IS NULL
OR
    "PLV"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN
    knots."PLV_Yrkesnivå" "kPLV"
ON
    "kPLV"."PLV_ID" = "PLV"."AC_PLV_PLV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION anchors."tPR_Föreställning" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Föreställning_Längd" time
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
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM
    anchors."PR_Föreställning" "PR"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."PR_NAM_PR_ID")
        r.*
    FROM
        attributes."rPR_NAM_Föreställning_Namn"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."PR_NAM_Reliability" = 1
    ORDER BY
    r."PR_NAM_PR_ID",
    r."PR_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    -- the latest asserted posit for each anchor, picked by a window
    SELECT DISTINCT ON (r."PR_LEN_PR_ID")
        r.*
    FROM
        attributes."rPR_LEN_Föreställning_Längd"(
            changingTimepoint::date,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."PR_LEN_Reliability" = 1
    ORDER BY
    r."PR_LEN_PR_ID",
    r."PR_LEN_ChangedAt" DESC,
    r."PR_LEN_PositedAt" DESC
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."lPR_Föreställning" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    anchors."tPR_Föreställning"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "PR"
;
CREATE OR REPLACE FUNCTION anchors."pPR_Föreställning" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "PR"."PR_NAM_PR_ID",
    "PR"."Metadata_PR_NAM",
    "PR"."PR_NAM_ID",
    "PR"."PR_NAM_PositedAt",
    "PR"."PR_NAM_Reliability",
    "PR"."PR_NAM_Föreställning_Namn",
    "PR"."PR_LEN_PR_ID",
    "PR"."Metadata_PR_LEN",
    "PR"."PR_LEN_ID",
    "PR"."PR_LEN_ChangedAt",
    "PR"."PR_LEN_PositedAt",
    "PR"."PR_LEN_Reliability",
    "PR"."PR_LEN_Föreställning_Längd"
FROM
    anchors."tPR_Föreställning"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "PR"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW anchors."nPR_Föreställning" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "PR".*
FROM
    anchors."tPR_Föreställning"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "PR"
;
CREATE OR REPLACE FUNCTION anchors."dPR_Föreställning" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "PR_ID" bigint,
    "Metadata_PR" integer,
    "PR_NAM_PR_ID" bigint,
    "Metadata_PR_NAM" integer,
    "PR_NAM_ID" integer,
    "PR_NAM_PositedAt" timestamp,
    "PR_NAM_Reliability" decimal(5,2),
    "PR_NAM_Föreställning_Namn" varchar(42),
    "PR_LEN_PR_ID" bigint,
    "Metadata_PR_LEN" integer,
    "PR_LEN_ID" integer,
    "PR_LEN_ChangedAt" date,
    "PR_LEN_PositedAt" timestamp,
    "PR_LEN_Reliability" decimal(5,2),
    "PR_LEN_Föreställning_Längd" time
)
AS
$$
-- each change in the interval, with what the time-traveling perspective shows then as it is known now: every latest
-- asserted posit is joined with the changing time until which it holds, when the next one does. The time-traveling
-- perspective is not called for each change; the posits are worked out for all of them in one pass.
SELECT
    timepoints.inspectedTimepoint,
    "PR"."PR_ID",
    "PR"."Metadata_PR",
    "NAM"."PR_NAM_PR_ID",
    "NAM"."Metadata_PR_NAM",
    "NAM"."PR_NAM_ID",
    "NAM"."PR_NAM_PositedAt",
    "NAM"."PR_NAM_Reliability",
    "NAM"."PR_NAM_Föreställning_Namn",
    "LEN"."PR_LEN_PR_ID",
    "LEN"."Metadata_PR_LEN",
    "LEN"."PR_LEN_ID",
    "LEN"."PR_LEN_ChangedAt",
    "LEN"."PR_LEN_PositedAt",
    "LEN"."PR_LEN_Reliability",
    "LEN"."PR_LEN_Föreställning_Längd"
FROM (
    SELECT DISTINCT
        "PR_LEN_PR_ID" AS "PR_ID",
        "PR_LEN_ChangedAt"::timestamp AS inspectedTimepoint,
        'LEN' AS mnemonic
    FROM
        attributes."PR_LEN_Föreställning_Längd"
    WHERE
        (selection IS NULL OR selection LIKE '%LEN%')
    AND
        "PR_LEN_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    anchors."PR_Föreställning" "PR"
ON
    "PR"."PR_ID" = timepoints."PR_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."PR_NAM_PR_ID")
        r.*
    FROM
        attributes."rPR_NAM_Föreställning_Namn"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."PR_NAM_Reliability" = 1
    ORDER BY
    r."PR_NAM_PR_ID",
    r."PR_NAM_PositedAt" DESC
) "NAM"
ON
    "NAM"."PR_NAM_PR_ID" = "PR"."PR_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."PR_LEN_ChangedAt") OVER (
            PARTITION BY x."PR_LEN_PR_ID"
            ORDER BY x."PR_LEN_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt")
            r.*
        FROM
            attributes."rPR_LEN_Föreställning_Längd"(
                '9999-12-31'::date,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."PR_LEN_Reliability" = 1
        ORDER BY
    r."PR_LEN_PR_ID", r."PR_LEN_ChangedAt",
    r."PR_LEN_PositedAt" DESC
    ) x
) "LEN"
ON
    "LEN"."PR_LEN_PR_ID" = "PR"."PR_ID"
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
-- BI nexus perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION nexuses."tEV_Händelse" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "kETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Reliability",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Reliability",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM
    nexuses."EV_Händelse" "EV"
LEFT JOIN
    knots."ETY_Händelsetyp" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_DAT_EV_ID")
        r.*
    FROM
        attributes."rEV_DAT_Händelse_Datum"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_DAT_Reliability" = 1
    ORDER BY
    r."EV_DAT_EV_ID",
    r."EV_DAT_PositedAt" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_AUD_EV_ID")
        r.*
    FROM
        attributes."rEV_AUD_Händelse_Publik"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_AUD_Reliability" = 1
    ORDER BY
    r."EV_AUD_EV_ID",
    r."EV_AUD_PositedAt" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_REV_EV_ID")
        r.*
    FROM
        attributes."rEV_REV_Händelse_Intäkt"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_REV_Reliability" = 1
    ORDER BY
    r."EV_REV_EV_ID",
    r."EV_REV_PositedAt" DESC
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_STA_EV_ID")
        r.*
    FROM
        attributes."rEV_STA_Händelse_Status"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_STA_Reliability" = 1
    ORDER BY
    r."EV_STA_EV_ID",
    r."EV_STA_ChangedAt" DESC,
    r."EV_STA_PositedAt" DESC
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_UTL_EV_ID")
        r.*
    FROM
        attributes."rEV_UTL_Händelse_Utnyttjande"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_UTL_Reliability" = 1
    ORDER BY
    r."EV_UTL_EV_ID",
    r."EV_UTL_PositedAt" DESC
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    -- the latest asserted posit for each nexus, picked by a window
    SELECT DISTINCT ON (r."EV_LVL_EV_ID")
        r.*
    FROM
        attributes."rEV_LVL_Händelse_Level"(
            changingTimepoint::date,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_LVL_Reliability" = 1
    ORDER BY
    r."EV_LVL_EV_ID",
    r."EV_LVL_ChangedAt" DESC,
    r."EV_LVL_PositedAt" DESC
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."PLV_Yrkesnivå" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW nexuses."lEV_Händelse" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    nexuses."tEV_Händelse"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
CREATE OR REPLACE FUNCTION nexuses."pEV_Händelse" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "Reliability" decimal(5,2),
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
)
AS
$$
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV"."EV_ID",
    "EV"."Metadata_EV",
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "EV"."of_ETY_Checksum",
    "EV"."of_ETY_Händelsetyp",
    "EV"."of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "EV"."EV_DAT_EV_ID",
    "EV"."Metadata_EV_DAT",
    "EV"."EV_DAT_ID",
    "EV"."EV_DAT_PositedAt",
    "EV"."EV_DAT_Reliability",
    "EV"."EV_DAT_Händelse_Datum",
    "EV"."EV_AUD_EV_ID",
    "EV"."Metadata_EV_AUD",
    "EV"."EV_AUD_ID",
    "EV"."EV_AUD_PositedAt",
    "EV"."EV_AUD_Reliability",
    "EV"."EV_AUD_Händelse_Publik",
    "EV"."EV_REV_EV_ID",
    "EV"."Metadata_EV_REV",
    "EV"."EV_REV_ID",
    "EV"."EV_REV_PositedAt",
    "EV"."EV_REV_Reliability",
    "EV"."EV_REV_Händelse_Intäkt",
    "EV"."EV_STA_EV_ID",
    "EV"."Metadata_EV_STA",
    "EV"."EV_STA_ID",
    "EV"."EV_STA_ChangedAt",
    "EV"."EV_STA_PositedAt",
    "EV"."EV_STA_Reliability",
    "EV"."EV_STA_Händelse_Status",
    "EV"."EV_UTL_EV_ID",
    "EV"."Metadata_EV_UTL",
    "EV"."EV_UTL_ID",
    "EV"."EV_UTL_PositedAt",
    "EV"."EV_UTL_Reliability",
    "EV"."EV_UTL_UTL_Utnyttjande",
    "EV"."EV_UTL_Metadata_UTL",
    "EV"."EV_UTL_UTL_ID",
    "EV"."EV_LVL_EV_ID",
    "EV"."Metadata_EV_LVL",
    "EV"."EV_LVL_ID",
    "EV"."EV_LVL_ChangedAt",
    "EV"."EV_LVL_PositedAt",
    "EV"."EV_LVL_Reliability",
    "EV"."EV_LVL_PLV_Checksum",
    "EV"."EV_LVL_PLV_Yrkesnivå",
    "EV"."EV_LVL_Metadata_PLV",
    "EV"."EV_LVL_PLV_ID"
FROM
    nexuses."tEV_Händelse"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW nexuses."nEV_Händelse" AS
SELECT
    cast(null as decimal(5,2)) as "Reliability",
    "EV".*
FROM
    nexuses."tEV_Händelse"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    ) "EV"
;
CREATE OR REPLACE FUNCTION nexuses."dEV_Händelse" (
    intervalStart timestamp,
    intervalEnd timestamp,
    selection text
)
RETURNS TABLE (
    inspectedTimepoint timestamp,
    "EV_ID" numeric(12,0),
    "Metadata_EV" integer,
    "ST_ID_hölls" integer,
    "PR_ID_spelades" bigint,
    "of_ETY_Checksum" bytea,
    "of_ETY_Händelsetyp" varchar(42),
    "of_Metadata_ETY" integer,
    "ETY_ID_of" smallint,
    "EV_DAT_EV_ID" numeric(12,0),
    "Metadata_EV_DAT" integer,
    "EV_DAT_ID" integer,
    "EV_DAT_PositedAt" timestamp,
    "EV_DAT_Reliability" decimal(5,2),
    "EV_DAT_Händelse_Datum" timestamp,
    "EV_AUD_EV_ID" numeric(12,0),
    "Metadata_EV_AUD" integer,
    "EV_AUD_ID" integer,
    "EV_AUD_PositedAt" timestamp,
    "EV_AUD_Reliability" decimal(5,2),
    "EV_AUD_Händelse_Publik" integer,
    "EV_REV_EV_ID" numeric(12,0),
    "Metadata_EV_REV" integer,
    "EV_REV_ID" integer,
    "EV_REV_PositedAt" timestamp,
    "EV_REV_Reliability" decimal(5,2),
    "EV_REV_Händelse_Intäkt" decimal(19,4),
    "EV_STA_EV_ID" numeric(12,0),
    "Metadata_EV_STA" integer,
    "EV_STA_ID" integer,
    "EV_STA_ChangedAt" timestamp,
    "EV_STA_PositedAt" timestamp,
    "EV_STA_Reliability" decimal(5,2),
    "EV_STA_Händelse_Status" varchar(20),
    "EV_UTL_EV_ID" numeric(12,0),
    "Metadata_EV_UTL" integer,
    "EV_UTL_ID" integer,
    "EV_UTL_PositedAt" timestamp,
    "EV_UTL_Reliability" decimal(5,2),
    "EV_UTL_UTL_Utnyttjande" smallint,
    "EV_UTL_Metadata_UTL" integer,
    "EV_UTL_UTL_ID" smallint,
    "EV_LVL_EV_ID" numeric(12,0),
    "Metadata_EV_LVL" integer,
    "EV_LVL_ID" integer,
    "EV_LVL_ChangedAt" date,
    "EV_LVL_PositedAt" timestamp,
    "EV_LVL_Reliability" decimal(5,2),
    "EV_LVL_PLV_Checksum" bytea,
    "EV_LVL_PLV_Yrkesnivå" text,
    "EV_LVL_Metadata_PLV" integer,
    "EV_LVL_PLV_ID" smallint
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
    "EV"."ST_ID_hölls",
    "EV"."PR_ID_spelades",
    "kETY_of"."ETY_Checksum" AS "of_ETY_Checksum",
    "kETY_of"."ETY_Händelsetyp" AS "of_ETY_Händelsetyp",
    "kETY_of"."Metadata_ETY" AS "of_Metadata_ETY",
    "EV"."ETY_ID_of",
    "DAT"."EV_DAT_EV_ID",
    "DAT"."Metadata_EV_DAT",
    "DAT"."EV_DAT_ID",
    "DAT"."EV_DAT_PositedAt",
    "DAT"."EV_DAT_Reliability",
    "DAT"."EV_DAT_Händelse_Datum",
    "AUD"."EV_AUD_EV_ID",
    "AUD"."Metadata_EV_AUD",
    "AUD"."EV_AUD_ID",
    "AUD"."EV_AUD_PositedAt",
    "AUD"."EV_AUD_Reliability",
    "AUD"."EV_AUD_Händelse_Publik",
    "REV"."EV_REV_EV_ID",
    "REV"."Metadata_EV_REV",
    "REV"."EV_REV_ID",
    "REV"."EV_REV_PositedAt",
    "REV"."EV_REV_Reliability",
    "REV"."EV_REV_Händelse_Intäkt",
    "STA"."EV_STA_EV_ID",
    "STA"."Metadata_EV_STA",
    "STA"."EV_STA_ID",
    "STA"."EV_STA_ChangedAt",
    "STA"."EV_STA_PositedAt",
    "STA"."EV_STA_Reliability",
    "STA"."EV_STA_Händelse_Status",
    "UTL"."EV_UTL_EV_ID",
    "UTL"."Metadata_EV_UTL",
    "UTL"."EV_UTL_ID",
    "UTL"."EV_UTL_PositedAt",
    "UTL"."EV_UTL_Reliability",
    "kUTL"."UTL_Utnyttjande" AS "EV_UTL_UTL_Utnyttjande",
    "kUTL"."Metadata_UTL" AS "EV_UTL_Metadata_UTL",
    "UTL"."EV_UTL_UTL_ID",
    "LVL"."EV_LVL_EV_ID",
    "LVL"."Metadata_EV_LVL",
    "LVL"."EV_LVL_ID",
    "LVL"."EV_LVL_ChangedAt",
    "LVL"."EV_LVL_PositedAt",
    "LVL"."EV_LVL_Reliability",
    "kLVL"."PLV_Checksum" AS "EV_LVL_PLV_Checksum",
    "kLVL"."PLV_Yrkesnivå" AS "EV_LVL_PLV_Yrkesnivå",
    "kLVL"."Metadata_PLV" AS "EV_LVL_Metadata_PLV",
    "LVL"."EV_LVL_PLV_ID"
FROM (
    SELECT DISTINCT
        "EV_STA_EV_ID" AS "EV_ID",
        "EV_STA_ChangedAt"::timestamp AS inspectedTimepoint,
        'STA' AS mnemonic
    FROM
        attributes."EV_STA_Händelse_Status"
    WHERE
        (selection IS NULL OR selection LIKE '%STA%')
    AND
        "EV_STA_ChangedAt" BETWEEN intervalStart AND intervalEnd
    UNION
    SELECT DISTINCT
        "EV_LVL_EV_ID" AS "EV_ID",
        "EV_LVL_ChangedAt"::timestamp AS inspectedTimepoint,
        'LVL' AS mnemonic
    FROM
        attributes."EV_LVL_Händelse_Level"
    WHERE
        (selection IS NULL OR selection LIKE '%LVL%')
    AND
        "EV_LVL_ChangedAt" BETWEEN intervalStart AND intervalEnd
) timepoints
JOIN
    nexuses."EV_Händelse" "EV"
ON
    "EV"."EV_ID" = timepoints."EV_ID"
LEFT JOIN
    knots."ETY_Händelsetyp" "kETY_of"
ON
    "kETY_of"."ETY_ID" = "EV"."ETY_ID_of"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_DAT_EV_ID")
        r.*
    FROM
        attributes."rEV_DAT_Händelse_Datum"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_DAT_Reliability" = 1
    ORDER BY
    r."EV_DAT_EV_ID",
    r."EV_DAT_PositedAt" DESC
) "DAT"
ON
    "DAT"."EV_DAT_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_AUD_EV_ID")
        r.*
    FROM
        attributes."rEV_AUD_Händelse_Publik"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_AUD_Reliability" = 1
    ORDER BY
    r."EV_AUD_EV_ID",
    r."EV_AUD_PositedAt" DESC
) "AUD"
ON
    "AUD"."EV_AUD_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_REV_EV_ID")
        r.*
    FROM
        attributes."rEV_REV_Händelse_Intäkt"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_REV_Reliability" = 1
    ORDER BY
    r."EV_REV_EV_ID",
    r."EV_REV_PositedAt" DESC
) "REV"
ON
    "REV"."EV_REV_EV_ID" = "EV"."EV_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."EV_STA_ChangedAt") OVER (
            PARTITION BY x."EV_STA_EV_ID"
            ORDER BY x."EV_STA_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."EV_STA_EV_ID", r."EV_STA_ChangedAt")
            r.*
        FROM
            attributes."rEV_STA_Händelse_Status"(
                '9999-12-31'::timestamp,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."EV_STA_Reliability" = 1
        ORDER BY
    r."EV_STA_EV_ID", r."EV_STA_ChangedAt",
    r."EV_STA_PositedAt" DESC
    ) x
) "STA"
ON
    "STA"."EV_STA_EV_ID" = "EV"."EV_ID"
AND
    "STA"."EV_STA_ChangedAt" <= timepoints.inspectedTimepoint::timestamp
AND (
    "STA"."until" IS NULL
OR
    "STA"."until" > timepoints.inspectedTimepoint::timestamp
)
LEFT JOIN (
    SELECT DISTINCT ON (r."EV_UTL_EV_ID")
        r.*
    FROM
        attributes."rEV_UTL_Händelse_Utnyttjande"(
            '9999-12-31'::timestamp
        ) r
    WHERE
        r."EV_UTL_Reliability" = 1
    ORDER BY
    r."EV_UTL_EV_ID",
    r."EV_UTL_PositedAt" DESC
) "UTL"
ON
    "UTL"."EV_UTL_EV_ID" = "EV"."EV_ID"
LEFT JOIN
    knots."UTL_Utnyttjande" "kUTL"
ON
    "kUTL"."UTL_ID" = "UTL"."EV_UTL_UTL_ID"
LEFT JOIN (
    SELECT
        x.*,
        lead(x."EV_LVL_ChangedAt") OVER (
            PARTITION BY x."EV_LVL_EV_ID"
            ORDER BY x."EV_LVL_ChangedAt"
        ) AS "until"
    FROM (
        -- the latest asserted posit at each changing time
        SELECT DISTINCT ON (r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt")
            r.*
        FROM
            attributes."rEV_LVL_Händelse_Level"(
                '9999-12-31'::date,
                '9999-12-31'::timestamp
            ) r
        WHERE
            r."EV_LVL_Reliability" = 1
        ORDER BY
    r."EV_LVL_EV_ID", r."EV_LVL_ChangedAt",
    r."EV_LVL_PositedAt" DESC
    ) x
) "LVL"
ON
    "LVL"."EV_LVL_EV_ID" = "EV"."EV_ID"
AND
    "LVL"."EV_LVL_ChangedAt" <= timepoints.inspectedTimepoint::date
AND (
    "LVL"."until" IS NULL
OR
    "LVL"."until" > timepoints.inspectedTimepoint::date
)
LEFT JOIN
    knots."PLV_Yrkesnivå" "kLVL"
ON
    "kLVL"."PLV_ID" = "LVL"."EV_LVL_PLV_ID"
$$ LANGUAGE sql STABLE;
-- TIES ---------------------------------------------------------------------------------------------------------------
--
-- BI ties use posit and annex split with changing/positing time and reliability.
--
CREATE SEQUENCE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_partner_AC_with_ONG_currently_Posit" (
    "AC_partner_AC_with_ONG_currently_ID" integer default nextval('ties."AC_partner_AC_with_ONG_currently_Posit_ID_SEQ"') not null, 
    "AC_ID_partner" smallint not null, 
    "AC_ID_with" smallint not null, 
    "ONG_ID_currently" smallint not null,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp not null,
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_partner" foreign key (
        "AC_ID_partner"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkAC_with" foreign key (
        "AC_ID_with"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_partner_AC_with_ONG_currently_Posit_fkONG_currently" foreign key (
        "ONG_ID_currently"
    ) references knots."ONG_Pågående"("ONG_ID"),
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
);
CREATE SEQUENCE IF NOT EXISTS ties."AC_subset_PN_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_subset_PN_of_Posit" (
    "AC_subset_PN_of_ID" integer default nextval('ties."AC_subset_PN_of_Posit_ID_SEQ"') not null, 
    "AC_ID_subset" smallint not null, 
    "PN_ID_of" bigint not null, 
    constraint "AC_subset_PN_of_Posit_fkAC_subset" foreign key (
        "AC_ID_subset"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
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
);
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
);
CREATE SEQUENCE IF NOT EXISTS ties."EV_in_AC_rollsattes_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes_Posit" (
    "EV_in_AC_rollsattes_ID" integer default nextval('ties."EV_in_AC_rollsattes_Posit_ID_SEQ"') not null, 
    "EV_ID_in" numeric(12,0) not null, 
    "AC_ID_rollsattes" smallint not null, 
    constraint "EV_in_AC_rollsattes_Posit_fkEV_in" foreign key (
        "EV_ID_in"
    ) references nexuses."EV_Händelse"("EV_ID"), 
    constraint "EV_in_AC_rollsattes_Posit_fkAC_rollsattes" foreign key (
        "AC_ID_rollsattes"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "pkEV_in_AC_rollsattes_Posit" primary key (
        "EV_in_AC_rollsattes_ID"
    ),
    constraint "uqEV_in_AC_rollsattes" unique (
        "EV_ID_in",
        "AC_ID_rollsattes"
    )
);
CREATE TABLE IF NOT EXISTS ties."EV_in_AC_rollsattes_Annex" (
    "EV_in_AC_rollsattes_ID" integer not null,
    "EV_in_AC_rollsattes_PositedAt" timestamp not null,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2) not null,
    "Metadata_EV_in_AC_rollsattes" integer not null,
    constraint "fkEV_in_AC_rollsattes_Annex" foreign key (
        "EV_in_AC_rollsattes_ID"
    ) references ties."EV_in_AC_rollsattes_Posit"("EV_in_AC_rollsattes_ID"),
    constraint "pkEV_in_AC_rollsattes_Annex" primary key (
        "EV_in_AC_rollsattes_ID",
        "EV_in_AC_rollsattes_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Posit" (
    "AC_deltar_PR_in_RAT_fick_ID" integer default nextval('ties."AC_deltar_PR_in_RAT_fick_Posit_ID_SEQ"') not null, 
    "AC_ID_deltar" smallint not null, 
    "PR_ID_in" bigint not null, 
    "RAT_ID_fick" smallint not null,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp not null,
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkAC_deltar" foreign key (
        "AC_ID_deltar"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkPR_in" foreign key (
        "PR_ID_in"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "AC_deltar_PR_in_RAT_fick_Posit_fkRAT_fick" foreign key (
        "RAT_ID_fick"
    ) references knots."RAT_Betyg"("RAT_ID"),
    constraint "pkAC_deltar_PR_in_RAT_fick_Posit" primary key (
        "AC_deltar_PR_in_RAT_fick_ID"
    ),
    constraint "uqAC_deltar_PR_in_RAT_fick" unique (
        "AC_ID_deltar",
        "PR_ID_in",
        "AC_deltar_PR_in_RAT_fick_ChangedAt",
        "RAT_ID_fick"
    )
);
CREATE TABLE IF NOT EXISTS ties."AC_deltar_PR_in_RAT_fick_Annex" (
    "AC_deltar_PR_in_RAT_fick_ID" integer not null,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp not null,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2) not null,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer not null,
    constraint "fkAC_deltar_PR_in_RAT_fick_Annex" foreign key (
        "AC_deltar_PR_in_RAT_fick_ID"
    ) references ties."AC_deltar_PR_in_RAT_fick_Posit"("AC_deltar_PR_in_RAT_fick_ID"),
    constraint "pkAC_deltar_PR_in_RAT_fick_Annex" primary key (
        "AC_deltar_PR_in_RAT_fick_ID",
        "AC_deltar_PR_in_RAT_fick_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."ST_at_PR_spelas_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas_Posit" (
    "ST_at_PR_spelas_ID" integer default nextval('ties."ST_at_PR_spelas_Posit_ID_SEQ"') not null, 
    "ST_ID_at" integer not null, 
    "PR_ID_spelas" bigint not null, 
    "ST_at_PR_spelas_ChangedAt" timestamp not null,
    constraint "ST_at_PR_spelas_Posit_fkST_at" foreign key (
        "ST_ID_at"
    ) references anchors."ST_Scen"("ST_ID"), 
    constraint "ST_at_PR_spelas_Posit_fkPR_spelas" foreign key (
        "PR_ID_spelas"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "pkST_at_PR_spelas_Posit" primary key (
        "ST_at_PR_spelas_ID"
    ),
    constraint "uqST_at_PR_spelas" unique (
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt"
    )
);
CREATE TABLE IF NOT EXISTS ties."ST_at_PR_spelas_Annex" (
    "ST_at_PR_spelas_ID" integer not null,
    "ST_at_PR_spelas_PositedAt" timestamp not null,
    "ST_at_PR_spelas_Reliability" decimal(5,2) not null,
    "Metadata_ST_at_PR_spelas" integer not null,
    constraint "fkST_at_PR_spelas_Annex" foreign key (
        "ST_at_PR_spelas_ID"
    ) references ties."ST_at_PR_spelas_Posit"("ST_at_PR_spelas_ID"),
    constraint "pkST_at_PR_spelas_Annex" primary key (
        "ST_at_PR_spelas_ID",
        "ST_at_PR_spelas_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Posit" (
    "AC_förälder_AC_barn_PAT_har_ID" integer default nextval('ties."AC_förälder_AC_barn_PAT_har_Posit_ID_SEQ"') not null, 
    "AC_ID_förälder" smallint not null, 
    "AC_ID_barn" smallint not null, 
    "PAT_ID_har" smallint not null,
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkAC_förälder" foreign key (
        "AC_ID_förälder"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkAC_barn" foreign key (
        "AC_ID_barn"
    ) references anchors."AC_Skådespelare"("AC_ID"), 
    constraint "AC_förälder_AC_barn_PAT_har_Posit_fkPAT_har" foreign key (
        "PAT_ID_har"
    ) references knots."PAT_Föräldratyp"("PAT_ID"),
    constraint "pkAC_förälder_AC_barn_PAT_har_Posit" primary key (
        "AC_förälder_AC_barn_PAT_har_ID"
    ),
    constraint "uqAC_förälder_AC_barn_PAT_har" unique (
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har"
    )
);
CREATE TABLE IF NOT EXISTS ties."AC_förälder_AC_barn_PAT_har_Annex" (
    "AC_förälder_AC_barn_PAT_har_ID" integer not null,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp not null,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2) not null,
    "Metadata_AC_förälder_AC_barn_PAT_har" integer not null,
    constraint "fkAC_förälder_AC_barn_PAT_har_Annex" foreign key (
        "AC_förälder_AC_barn_PAT_har_ID"
    ) references ties."AC_förälder_AC_barn_PAT_har_Posit"("AC_förälder_AC_barn_PAT_har_ID"),
    constraint "pkAC_förälder_AC_barn_PAT_har_Annex" primary key (
        "AC_förälder_AC_barn_PAT_har_ID",
        "AC_förälder_AC_barn_PAT_har_PositedAt"
    )
);
CREATE SEQUENCE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ" START 1 INCREMENT 1;
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Posit" (
    "PR_innehåll_ST_plats_EV_of_ID" integer default nextval('ties."PR_innehåll_ST_plats_EV_of_Posit_ID_SEQ"') not null, 
    "PR_ID_innehåll" bigint not null, 
    "ST_ID_plats" integer not null, 
    "EV_ID_of" numeric(12,0) not null, 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp not null,
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkPR_innehåll" foreign key (
        "PR_ID_innehåll"
    ) references anchors."PR_Föreställning"("PR_ID"), 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkST_plats" foreign key (
        "ST_ID_plats"
    ) references anchors."ST_Scen"("ST_ID"), 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_fkEV_of" foreign key (
        "EV_ID_of"
    ) references nexuses."EV_Händelse"("EV_ID"), 
    constraint "PR_innehåll_ST_plats_EV_of_Posit_uqPR_innehåll" unique (
        "PR_ID_innehåll",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    constraint "PR_innehåll_ST_plats_EV_of_Posit_uqST_plats" unique (
        "ST_ID_plats",
        "PR_innehåll_ST_plats_EV_of_ChangedAt"
    ),
    constraint "pkPR_innehåll_ST_plats_EV_of_Posit" primary key (
        "PR_innehåll_ST_plats_EV_of_ID"
    ),
    constraint "uqPR_innehåll_ST_plats_EV_of" unique (
        "PR_innehåll_ST_plats_EV_of_ChangedAt",
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of"
    )
);
CREATE TABLE IF NOT EXISTS ties."PR_innehåll_ST_plats_EV_of_Annex" (
    "PR_innehåll_ST_plats_EV_of_ID" integer not null,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp not null,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2) not null,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer not null,
    constraint "fkPR_innehåll_ST_plats_EV_of_Annex" foreign key (
        "PR_innehåll_ST_plats_EV_of_ID"
    ) references ties."PR_innehåll_ST_plats_EV_of_Posit"("PR_innehåll_ST_plats_EV_of_ID"),
    constraint "pkPR_innehåll_ST_plats_EV_of_Annex" primary key (
        "PR_innehåll_ST_plats_EV_of_ID",
        "PR_innehåll_ST_plats_EV_of_PositedAt"
    )
);
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
CREATE OR REPLACE VIEW ties."EV_in_AC_rollsattes" AS
SELECT
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Reliability"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    ties."EV_in_AC_rollsattes_Annex" a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
;
CREATE OR REPLACE VIEW ties."AC_deltar_PR_in_RAT_fick" AS
SELECT
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Reliability"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit" p
JOIN
    ties."AC_deltar_PR_in_RAT_fick_Annex" a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
;
CREATE OR REPLACE VIEW ties."ST_at_PR_spelas" AS
SELECT
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Reliability"
FROM
    ties."ST_at_PR_spelas_Posit" p
JOIN
    ties."ST_at_PR_spelas_Annex" a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
;
CREATE OR REPLACE VIEW ties."AC_förälder_AC_barn_PAT_har" AS
SELECT
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Reliability"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    ties."AC_förälder_AC_barn_PAT_har_Annex" a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
;
CREATE OR REPLACE VIEW ties."PR_innehåll_ST_plats_EV_of" AS
SELECT
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Reliability"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit" p
JOIN
    ties."PR_innehåll_ST_plats_EV_of_Annex" a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
;
-- TIE REWINDERS AND FORWARDERS ---------------------------------------------------------------------------------------
--
-- BI rewinders over changing and positing time.
--
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
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
    ties."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
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
    ties."AC_partner_AC_with_ONG_currently_Posit"
WHERE
    "AC_partner_AC_with_ONG_currently_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_partner_AC_with_ONG_currently",
    "AC_partner_AC_with_ONG_currently_ID",
    "AC_partner_AC_with_ONG_currently_PositedAt",
    "AC_partner_AC_with_ONG_currently_Reliability"
FROM
    ties."AC_partner_AC_with_ONG_currently_Annex"
WHERE
    "AC_partner_AC_with_ONG_currently_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Reliability"
FROM
    ties."rAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint) p 
JOIN
    ties."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "AC_ID_partner" smallint, 
    "AC_ID_with" smallint, 
    "ONG_ID_currently" smallint,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_partner_AC_with_ONG_currently_ID")
    a."Metadata_AC_partner_AC_with_ONG_currently",
    p."AC_partner_AC_with_ONG_currently_ID",
    p."AC_ID_partner",
    p."AC_ID_with",
    p."ONG_ID_currently",
    p."AC_partner_AC_with_ONG_currently_ChangedAt",
    a."AC_partner_AC_with_ONG_currently_PositedAt",
    a."AC_partner_AC_with_ONG_currently_Reliability"
FROM
    ties."fAC_partner_AC_with_ONG_currently_Posit"(changingTimepoint) p 
JOIN
    ties."rAC_partner_AC_with_ONG_currently_Annex"(positingTimepoint) a
ON
    a."AC_partner_AC_with_ONG_currently_ID" = p."AC_partner_AC_with_ONG_currently_ID"
ORDER BY
    p."AC_partner_AC_with_ONG_currently_ID",
    a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_subset_PN_of",
    "AC_subset_PN_of_ID",
    "AC_subset_PN_of_PositedAt",
    "AC_subset_PN_of_Reliability"
FROM
    ties."AC_subset_PN_of_Annex"
WHERE
    "AC_subset_PN_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_subset_PN_of" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Reliability"
FROM
    ties."AC_subset_PN_of_Posit" p
JOIN
    ties."rAC_subset_PN_of_Annex"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
ORDER BY
    p."AC_subset_PN_of_ID",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_subset_PN_of" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_ID" integer,
    "AC_ID_subset" smallint, 
    "PN_ID_of" bigint, 
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_subset_PN_of_ID")
    a."Metadata_AC_subset_PN_of",
    p."AC_subset_PN_of_ID",
    p."AC_ID_subset",
    p."PN_ID_of",
    a."AC_subset_PN_of_PositedAt",
    a."AC_subset_PN_of_Reliability"
FROM
    ties."AC_subset_PN_of_Posit" p
JOIN
    ties."rAC_subset_PN_of_Annex"(positingTimepoint) a
ON
    a."AC_subset_PN_of_ID" = p."AC_subset_PN_of_ID"
ORDER BY
    p."AC_subset_PN_of_ID",
    a."AC_subset_PN_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_rollsattes_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_in_AC_rollsattes_ID" integer,
    "EV_in_AC_rollsattes_PositedAt" timestamp,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_EV_in_AC_rollsattes",
    "EV_in_AC_rollsattes_ID",
    "EV_in_AC_rollsattes_PositedAt",
    "EV_in_AC_rollsattes_Reliability"
FROM
    ties."EV_in_AC_rollsattes_Annex"
WHERE
    "EV_in_AC_rollsattes_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rEV_in_AC_rollsattes" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_in_AC_rollsattes_ID" integer,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_rollsattes" smallint, 
    "EV_in_AC_rollsattes_PositedAt" timestamp,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_rollsattes_ID")
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Reliability"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    ties."rEV_in_AC_rollsattes_Annex"(positingTimepoint) a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
ORDER BY
    p."EV_in_AC_rollsattes_ID",
    a."EV_in_AC_rollsattes_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fEV_in_AC_rollsattes" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_in_AC_rollsattes_ID" integer,
    "EV_ID_in" numeric(12,0), 
    "AC_ID_rollsattes" smallint, 
    "EV_in_AC_rollsattes_PositedAt" timestamp,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."EV_in_AC_rollsattes_ID")
    a."Metadata_EV_in_AC_rollsattes",
    p."EV_in_AC_rollsattes_ID",
    p."EV_ID_in",
    p."AC_ID_rollsattes",
    a."EV_in_AC_rollsattes_PositedAt",
    a."EV_in_AC_rollsattes_Reliability"
FROM
    ties."EV_in_AC_rollsattes_Posit" p
JOIN
    ties."rEV_in_AC_rollsattes_Annex"(positingTimepoint) a
ON
    a."EV_in_AC_rollsattes_ID" = p."EV_in_AC_rollsattes_ID"
ORDER BY
    p."EV_in_AC_rollsattes_ID",
    a."EV_in_AC_rollsattes_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" bigint, 
    "RAT_ID_fick" smallint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_ID_deltar",
    "PR_ID_in",
    "RAT_ID_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
WHERE
    "AC_deltar_PR_in_RAT_fick_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_deltar_PR_in_RAT_fick_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" bigint, 
    "RAT_ID_fick" smallint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp
)
AS
$$
SELECT
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_ID_deltar",
    "PR_ID_in",
    "RAT_ID_fick",
    "AC_deltar_PR_in_RAT_fick_ChangedAt"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Posit"
WHERE
    "AC_deltar_PR_in_RAT_fick_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_deltar_PR_in_RAT_fick",
    "AC_deltar_PR_in_RAT_fick_ID",
    "AC_deltar_PR_in_RAT_fick_PositedAt",
    "AC_deltar_PR_in_RAT_fick_Reliability"
FROM
    ties."AC_deltar_PR_in_RAT_fick_Annex"
WHERE
    "AC_deltar_PR_in_RAT_fick_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" bigint, 
    "RAT_ID_fick" smallint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_deltar_PR_in_RAT_fick_ID")
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Reliability"
FROM
    ties."rAC_deltar_PR_in_RAT_fick_Posit"(changingTimepoint) p 
JOIN
    ties."rAC_deltar_PR_in_RAT_fick_Annex"(positingTimepoint) a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
ORDER BY
    p."AC_deltar_PR_in_RAT_fick_ID",
    a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "AC_ID_deltar" smallint, 
    "PR_ID_in" bigint, 
    "RAT_ID_fick" smallint,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_deltar_PR_in_RAT_fick_ID")
    a."Metadata_AC_deltar_PR_in_RAT_fick",
    p."AC_deltar_PR_in_RAT_fick_ID",
    p."AC_ID_deltar",
    p."PR_ID_in",
    p."RAT_ID_fick",
    p."AC_deltar_PR_in_RAT_fick_ChangedAt",
    a."AC_deltar_PR_in_RAT_fick_PositedAt",
    a."AC_deltar_PR_in_RAT_fick_Reliability"
FROM
    ties."fAC_deltar_PR_in_RAT_fick_Posit"(changingTimepoint) p 
JOIN
    ties."rAC_deltar_PR_in_RAT_fick_Annex"(positingTimepoint) a
ON
    a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
ORDER BY
    p."AC_deltar_PR_in_RAT_fick_ID",
    a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_spelas" bigint, 
    "ST_at_PR_spelas_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_at_PR_spelas_ID",
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
FROM
    ties."ST_at_PR_spelas_Posit"
WHERE
    "ST_at_PR_spelas_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_spelas_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_spelas" bigint, 
    "ST_at_PR_spelas_ChangedAt" timestamp
)
AS
$$
SELECT
    "ST_at_PR_spelas_ID",
    "ST_ID_at",
    "PR_ID_spelas",
    "ST_at_PR_spelas_ChangedAt"
FROM
    ties."ST_at_PR_spelas_Posit"
WHERE
    "ST_at_PR_spelas_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ID" integer,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_ST_at_PR_spelas",
    "ST_at_PR_spelas_ID",
    "ST_at_PR_spelas_PositedAt",
    "ST_at_PR_spelas_Reliability"
FROM
    ties."ST_at_PR_spelas_Annex"
WHERE
    "ST_at_PR_spelas_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rST_at_PR_spelas" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_spelas" bigint, 
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_spelas_ID")
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Reliability"
FROM
    ties."rST_at_PR_spelas_Posit"(changingTimepoint) p 
JOIN
    ties."rST_at_PR_spelas_Annex"(positingTimepoint) a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
ORDER BY
    p."ST_at_PR_spelas_ID",
    a."ST_at_PR_spelas_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fST_at_PR_spelas" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ID" integer,
    "ST_ID_at" integer, 
    "PR_ID_spelas" bigint, 
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."ST_at_PR_spelas_ID")
    a."Metadata_ST_at_PR_spelas",
    p."ST_at_PR_spelas_ID",
    p."ST_ID_at",
    p."PR_ID_spelas",
    p."ST_at_PR_spelas_ChangedAt",
    a."ST_at_PR_spelas_PositedAt",
    a."ST_at_PR_spelas_Reliability"
FROM
    ties."fST_at_PR_spelas_Posit"(changingTimepoint) p 
JOIN
    ties."rST_at_PR_spelas_Annex"(positingTimepoint) a
ON
    a."ST_at_PR_spelas_ID" = p."ST_at_PR_spelas_ID"
ORDER BY
    p."ST_at_PR_spelas_ID",
    a."ST_at_PR_spelas_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_förälder_AC_barn_PAT_har_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_förälder_AC_barn_PAT_har_ID" integer,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_AC_förälder_AC_barn_PAT_har",
    "AC_förälder_AC_barn_PAT_har_ID",
    "AC_förälder_AC_barn_PAT_har_PositedAt",
    "AC_förälder_AC_barn_PAT_har_Reliability"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Annex"
WHERE
    "AC_förälder_AC_barn_PAT_har_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rAC_förälder_AC_barn_PAT_har" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_förälder_AC_barn_PAT_har_ID" integer,
    "AC_ID_förälder" smallint, 
    "AC_ID_barn" smallint, 
    "PAT_ID_har" smallint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_förälder_AC_barn_PAT_har_ID")
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Reliability"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    ties."rAC_förälder_AC_barn_PAT_har_Annex"(positingTimepoint) a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
ORDER BY
    p."AC_förälder_AC_barn_PAT_har_ID",
    a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fAC_förälder_AC_barn_PAT_har" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_förälder_AC_barn_PAT_har_ID" integer,
    "AC_ID_förälder" smallint, 
    "AC_ID_barn" smallint, 
    "PAT_ID_har" smallint,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."AC_förälder_AC_barn_PAT_har_ID")
    a."Metadata_AC_förälder_AC_barn_PAT_har",
    p."AC_förälder_AC_barn_PAT_har_ID",
    p."AC_ID_förälder",
    p."AC_ID_barn",
    p."PAT_ID_har",
    a."AC_förälder_AC_barn_PAT_har_PositedAt",
    a."AC_förälder_AC_barn_PAT_har_Reliability"
FROM
    ties."AC_förälder_AC_barn_PAT_har_Posit" p
JOIN
    ties."rAC_förälder_AC_barn_PAT_har_Annex"(positingTimepoint) a
ON
    a."AC_förälder_AC_barn_PAT_har_ID" = p."AC_förälder_AC_barn_PAT_har_ID"
ORDER BY
    p."AC_förälder_AC_barn_PAT_har_ID",
    a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "PR_ID_innehåll" bigint, 
    "ST_ID_plats" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp
)
AS
$$
SELECT
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
WHERE
    "PR_innehåll_ST_plats_EV_of_ChangedAt" <= changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fPR_innehåll_ST_plats_EV_of_Posit" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "PR_ID_innehåll" bigint, 
    "ST_ID_plats" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp
)
AS
$$
SELECT
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_ID_innehåll",
    "ST_ID_plats",
    "EV_ID_of",
    "PR_innehåll_ST_plats_EV_of_ChangedAt"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Posit"
WHERE
    "PR_innehåll_ST_plats_EV_of_ChangedAt" > changingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of_Annex" (
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2)
)
AS
$$
SELECT
    "Metadata_PR_innehåll_ST_plats_EV_of",
    "PR_innehåll_ST_plats_EV_of_ID",
    "PR_innehåll_ST_plats_EV_of_PositedAt",
    "PR_innehåll_ST_plats_EV_of_Reliability"
FROM
    ties."PR_innehåll_ST_plats_EV_of_Annex"
WHERE
    "PR_innehåll_ST_plats_EV_of_PositedAt" <= positingTimepoint
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."rPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "PR_ID_innehåll" bigint, 
    "ST_ID_plats" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."PR_innehåll_ST_plats_EV_of_ID")
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Reliability"
FROM
    ties."rPR_innehåll_ST_plats_EV_of_Posit"(changingTimepoint) p 
JOIN
    ties."rPR_innehåll_ST_plats_EV_of_Annex"(positingTimepoint) a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
ORDER BY
    p."PR_innehåll_ST_plats_EV_of_ID",
    a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."fPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "PR_ID_innehåll" bigint, 
    "ST_ID_plats" integer, 
    "EV_ID_of" numeric(12,0), 
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2)
)
AS
$$
SELECT DISTINCT ON (p."PR_innehåll_ST_plats_EV_of_ID")
    a."Metadata_PR_innehåll_ST_plats_EV_of",
    p."PR_innehåll_ST_plats_EV_of_ID",
    p."PR_ID_innehåll",
    p."ST_ID_plats",
    p."EV_ID_of",
    p."PR_innehåll_ST_plats_EV_of_ChangedAt",
    a."PR_innehåll_ST_plats_EV_of_PositedAt",
    a."PR_innehåll_ST_plats_EV_of_Reliability"
FROM
    ties."fPR_innehåll_ST_plats_EV_of_Posit"(changingTimepoint) p 
JOIN
    ties."rPR_innehåll_ST_plats_EV_of_Annex"(positingTimepoint) a
ON
    a."PR_innehåll_ST_plats_EV_of_ID" = p."PR_innehåll_ST_plats_EV_of_ID"
ORDER BY
    p."PR_innehåll_ST_plats_EV_of_ID",
    a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
$$ LANGUAGE sql STABLE;
-- TIE TEMPORAL PERSPECTIVES ------------------------------------------------------------------------------------------
--
-- BI tie perspectives: time traveling (t), latest (l), point-in-time (p),
-- now (n), and difference (d).
--
CREATE OR REPLACE FUNCTION ties."tAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    "kONG_currently"."ONG_Pågående" AS "currently_ONG_Pågående",
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
        ties."rAC_partner_AC_with_ONG_currently"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_partner_AC_with_ONG_currently_Reliability" = 1
) t
LEFT JOIN
    knots."ONG_Pågående" "kONG_currently"
ON
    "kONG_currently"."ONG_ID" = t."ONG_ID_currently"
WHERE
    t."latestAC_ID_partner" = 1
AND
    t."latestAC_ID_with" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_partner_AC_with_ONG_currently" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_partner_AC_with_ONG_currently" AS
SELECT
    *
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dAC_partner_AC_with_ONG_currently" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "AC_partner_AC_with_ONG_currently_ID" integer,
    "Metadata_AC_partner_AC_with_ONG_currently" integer,
    "AC_partner_AC_with_ONG_currently_ChangedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_PositedAt" timestamp,
    "AC_partner_AC_with_ONG_currently_Reliability" decimal(5,2),
    "AC_ID_partner" smallint,
    "AC_ID_with" smallint,
    "currently_ONG_Pågående" varchar(3),
    "currently_Metadata_ONG" integer,
    "ONG_ID_currently" smallint
)
AS
$$
SELECT
    t."AC_partner_AC_with_ONG_currently_ID",
    t."Metadata_AC_partner_AC_with_ONG_currently",
    t."AC_partner_AC_with_ONG_currently_ChangedAt",
    t."AC_partner_AC_with_ONG_currently_PositedAt",
    t."AC_partner_AC_with_ONG_currently_Reliability",
    t."AC_ID_partner",
    t."AC_ID_with",
    t."currently_ONG_Pågående",
    t."currently_Metadata_ONG",
    t."ONG_ID_currently"
FROM
    ties."tAC_partner_AC_with_ONG_currently"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."AC_partner_AC_with_ONG_currently_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."tAC_subset_PN_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_subset_PN_of_ID" integer,
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
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
        ties."rAC_subset_PN_of"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_subset_PN_of_Reliability" = 1
) t
WHERE
    t."latestAC_ID_subset" = 1
AND
    t."latestPN_ID_of" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_subset_PN_of" AS
SELECT
    *
FROM
    ties."tAC_subset_PN_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_subset_PN_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_subset_PN_of_ID" integer,
    "Metadata_AC_subset_PN_of" integer,
    "AC_subset_PN_of_PositedAt" timestamp,
    "AC_subset_PN_of_Reliability" decimal(5,2),
    "AC_ID_subset" smallint,
    "PN_ID_of" bigint
)
AS
$$
SELECT
    t."AC_subset_PN_of_ID",
    t."Metadata_AC_subset_PN_of",
    t."AC_subset_PN_of_PositedAt",
    t."AC_subset_PN_of_Reliability",
    t."AC_ID_subset",
    t."PN_ID_of"
FROM
    ties."tAC_subset_PN_of"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_subset_PN_of" AS
SELECT
    *
FROM
    ties."tAC_subset_PN_of"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."tEV_in_AC_rollsattes" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "EV_in_AC_rollsattes_ID" integer,
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_in_AC_rollsattes_PositedAt" timestamp,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    t."EV_in_AC_rollsattes_ID",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."EV_ID_in",
                r."AC_ID_rollsattes"
            ORDER BY
                r."EV_in_AC_rollsattes_PositedAt" DESC,
                r."EV_in_AC_rollsattes_ID" DESC
        ) AS "latest"
    FROM
        ties."rEV_in_AC_rollsattes"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."EV_in_AC_rollsattes_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lEV_in_AC_rollsattes" AS
SELECT
    *
FROM
    ties."tEV_in_AC_rollsattes"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pEV_in_AC_rollsattes" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "EV_in_AC_rollsattes_ID" integer,
    "Metadata_EV_in_AC_rollsattes" integer,
    "EV_in_AC_rollsattes_PositedAt" timestamp,
    "EV_in_AC_rollsattes_Reliability" decimal(5,2),
    "EV_ID_in" numeric(12,0),
    "AC_ID_rollsattes" smallint
)
AS
$$
SELECT
    t."EV_in_AC_rollsattes_ID",
    t."Metadata_EV_in_AC_rollsattes",
    t."EV_in_AC_rollsattes_PositedAt",
    t."EV_in_AC_rollsattes_Reliability",
    t."EV_ID_in",
    t."AC_ID_rollsattes"
FROM
    ties."tEV_in_AC_rollsattes"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nEV_in_AC_rollsattes" AS
SELECT
    *
FROM
    ties."tEV_in_AC_rollsattes"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."tAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    t."AC_deltar_PR_in_RAT_fick_ID",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_ID_deltar",
    t."PR_ID_in",
    "kRAT_fick"."RAT_Betyg" AS "fick_RAT_Betyg",
    "kRAT_fick"."Metadata_RAT" AS "fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_deltar",
                r."PR_ID_in"
            ORDER BY
                r."AC_deltar_PR_in_RAT_fick_ChangedAt" DESC,
                r."AC_deltar_PR_in_RAT_fick_PositedAt" DESC,
                r."AC_deltar_PR_in_RAT_fick_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_deltar_PR_in_RAT_fick"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_deltar_PR_in_RAT_fick_Reliability" = 1
) t
LEFT JOIN
    knots."RAT_Betyg" "kRAT_fick"
ON
    "kRAT_fick"."RAT_ID" = t."RAT_ID_fick"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_deltar_PR_in_RAT_fick" AS
SELECT
    *
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_deltar_PR_in_RAT_fick" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    t."AC_deltar_PR_in_RAT_fick_ID",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_deltar_PR_in_RAT_fick" AS
SELECT
    *
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dAC_deltar_PR_in_RAT_fick" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "AC_deltar_PR_in_RAT_fick_ID" integer,
    "Metadata_AC_deltar_PR_in_RAT_fick" integer,
    "AC_deltar_PR_in_RAT_fick_ChangedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_PositedAt" timestamp,
    "AC_deltar_PR_in_RAT_fick_Reliability" decimal(5,2),
    "AC_ID_deltar" smallint,
    "PR_ID_in" bigint,
    "fick_RAT_Betyg" varchar(42),
    "fick_Metadata_RAT" integer,
    "RAT_ID_fick" smallint
)
AS
$$
SELECT
    t."AC_deltar_PR_in_RAT_fick_ID",
    t."Metadata_AC_deltar_PR_in_RAT_fick",
    t."AC_deltar_PR_in_RAT_fick_ChangedAt",
    t."AC_deltar_PR_in_RAT_fick_PositedAt",
    t."AC_deltar_PR_in_RAT_fick_Reliability",
    t."AC_ID_deltar",
    t."PR_ID_in",
    t."fick_RAT_Betyg",
    t."fick_Metadata_RAT",
    t."RAT_ID_fick"
FROM
    ties."tAC_deltar_PR_in_RAT_fick"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."AC_deltar_PR_in_RAT_fick_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."tST_at_PR_spelas" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    t."ST_at_PR_spelas_ID",
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Reliability",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."ST_ID_at",
                r."PR_ID_spelas"
            ORDER BY
                r."ST_at_PR_spelas_ChangedAt" DESC,
                r."ST_at_PR_spelas_PositedAt" DESC,
                r."ST_at_PR_spelas_ID" DESC
        ) AS "latest"
    FROM
        ties."rST_at_PR_spelas"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."ST_at_PR_spelas_Reliability" = 1
) t
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lST_at_PR_spelas" AS
SELECT
    *
FROM
    ties."tST_at_PR_spelas"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pST_at_PR_spelas" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    t."ST_at_PR_spelas_ID",
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Reliability",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
    ties."tST_at_PR_spelas"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nST_at_PR_spelas" AS
SELECT
    *
FROM
    ties."tST_at_PR_spelas"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dST_at_PR_spelas" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "ST_at_PR_spelas_ID" integer,
    "Metadata_ST_at_PR_spelas" integer,
    "ST_at_PR_spelas_ChangedAt" timestamp,
    "ST_at_PR_spelas_PositedAt" timestamp,
    "ST_at_PR_spelas_Reliability" decimal(5,2),
    "ST_ID_at" integer,
    "PR_ID_spelas" bigint
)
AS
$$
SELECT
    t."ST_at_PR_spelas_ID",
    t."Metadata_ST_at_PR_spelas",
    t."ST_at_PR_spelas_ChangedAt",
    t."ST_at_PR_spelas_PositedAt",
    t."ST_at_PR_spelas_Reliability",
    t."ST_ID_at",
    t."PR_ID_spelas"
FROM
    ties."tST_at_PR_spelas"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."ST_at_PR_spelas_ChangedAt" BETWEEN intervalStart AND intervalEnd
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE FUNCTION ties."tAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "AC_förälder_AC_barn_PAT_har_ID" integer,
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    t."AC_förälder_AC_barn_PAT_har_ID",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    "kPAT_har"."PAT_Föräldratyp" AS "har_PAT_Föräldratyp",
    "kPAT_har"."Metadata_PAT" AS "har_Metadata_PAT",
    t."PAT_ID_har"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- the latest posit for the identifiers
        row_number() OVER (
            PARTITION BY
                r."AC_ID_förälder",
                r."AC_ID_barn",
                r."PAT_ID_har"
            ORDER BY
                r."AC_förälder_AC_barn_PAT_har_PositedAt" DESC,
                r."AC_förälder_AC_barn_PAT_har_ID" DESC
        ) AS "latest"
    FROM
        ties."rAC_förälder_AC_barn_PAT_har"(
            positingTimepoint::timestamp
        ) r
    WHERE
        r."AC_förälder_AC_barn_PAT_har_Reliability" = 1
) t
LEFT JOIN
    knots."PAT_Föräldratyp" "kPAT_har"
ON
    "kPAT_har"."PAT_ID" = t."PAT_ID_har"
WHERE
    t."latest" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lAC_förälder_AC_barn_PAT_har" AS
SELECT
    *
FROM
    ties."tAC_förälder_AC_barn_PAT_har"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pAC_förälder_AC_barn_PAT_har" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "AC_förälder_AC_barn_PAT_har_ID" integer,
    "Metadata_AC_förälder_AC_barn_PAT_har" integer,
    "AC_förälder_AC_barn_PAT_har_PositedAt" timestamp,
    "AC_förälder_AC_barn_PAT_har_Reliability" decimal(5,2),
    "AC_ID_förälder" smallint,
    "AC_ID_barn" smallint,
    "har_PAT_Föräldratyp" varchar(42),
    "har_Metadata_PAT" integer,
    "PAT_ID_har" smallint
)
AS
$$
SELECT
    t."AC_förälder_AC_barn_PAT_har_ID",
    t."Metadata_AC_förälder_AC_barn_PAT_har",
    t."AC_förälder_AC_barn_PAT_har_PositedAt",
    t."AC_förälder_AC_barn_PAT_har_Reliability",
    t."AC_ID_förälder",
    t."AC_ID_barn",
    t."har_PAT_Föräldratyp",
    t."har_Metadata_PAT",
    t."PAT_ID_har"
FROM
    ties."tAC_förälder_AC_barn_PAT_har"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nAC_förälder_AC_barn_PAT_har" AS
SELECT
    *
FROM
    ties."tAC_förälder_AC_barn_PAT_har"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."tPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp,
    positingTimepoint timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_innehåll_ST_plats_EV_of_ID",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM (
    -- the latest asserted posit, picked by a window and kept by the filter outside it
    SELECT
        r.*,
        -- a tie without identifiers is one to one: the latest posit for each of its anchors
        row_number() OVER (
            PARTITION BY r."PR_ID_innehåll"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestPR_ID_innehåll",
        row_number() OVER (
            PARTITION BY r."ST_ID_plats"
            ORDER BY
                r."PR_innehåll_ST_plats_EV_of_ChangedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_PositedAt" DESC,
                r."PR_innehåll_ST_plats_EV_of_ID" DESC
        ) AS "latestST_ID_plats"
    FROM
        ties."rPR_innehåll_ST_plats_EV_of"(
            changingTimepoint::timestamp,
            positingTimepoint::timestamp
        ) r
    WHERE
        r."PR_innehåll_ST_plats_EV_of_Reliability" = 1
) t
WHERE
    t."latestPR_ID_innehåll" = 1
AND
    t."latestST_ID_plats" = 1
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."lPR_innehåll_ST_plats_EV_of" AS
SELECT
    *
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."pPR_innehåll_ST_plats_EV_of" (
    changingTimepoint timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_innehåll_ST_plats_EV_of_ID",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        changingTimepoint::timestamp,
        '9999-12-31'::timestamp
    ) t
$$ LANGUAGE sql STABLE;
CREATE OR REPLACE VIEW ties."nPR_innehåll_ST_plats_EV_of" AS
SELECT
    *
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        current_timestamp::timestamp,
        '9999-12-31'::timestamp
    )
;
CREATE OR REPLACE FUNCTION ties."dPR_innehåll_ST_plats_EV_of" (
    intervalStart timestamp,
    intervalEnd timestamp
)
RETURNS TABLE (
    "PR_innehåll_ST_plats_EV_of_ID" integer,
    "Metadata_PR_innehåll_ST_plats_EV_of" integer,
    "PR_innehåll_ST_plats_EV_of_ChangedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_PositedAt" timestamp,
    "PR_innehåll_ST_plats_EV_of_Reliability" decimal(5,2),
    "PR_ID_innehåll" bigint,
    "ST_ID_plats" integer,
    "EV_ID_of" numeric(12,0)
)
AS
$$
SELECT
    t."PR_innehåll_ST_plats_EV_of_ID",
    t."Metadata_PR_innehåll_ST_plats_EV_of",
    t."PR_innehåll_ST_plats_EV_of_ChangedAt",
    t."PR_innehåll_ST_plats_EV_of_PositedAt",
    t."PR_innehåll_ST_plats_EV_of_Reliability",
    t."PR_ID_innehåll",
    t."ST_ID_plats",
    t."EV_ID_of"
FROM
    ties."tPR_innehåll_ST_plats_EV_of"(
        '9999-12-31'::timestamp,
        '9999-12-31'::timestamp
    ) t
WHERE
    t."PR_innehåll_ST_plats_EV_of_ChangedAt" BETWEEN intervalStart AND intervalEnd
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
-- eq_EV_DAT_Händelse_Datum tells whether two values of EV_DAT_Händelse_Datum are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_DAT_Händelse_Datum"(
    l timestamp,
    r timestamp
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_DAT_Händelse_Datum instead of INSERT trigger on EV_DAT_Händelse_Datum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_DAT_Händelse_Datum"()
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
    _positing := coalesce(NEW."EV_DAT_PositedAt", _now);
    _reliability := coalesce(NEW."EV_DAT_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_DAT_ID"
    INTO
        _posit
    FROM
        attributes."EV_DAT_Händelse_Datum_Posit" p
    WHERE
        p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
    AND
        attributes."eq_EV_DAT_Händelse_Datum"(p."EV_DAT_Händelse_Datum", NEW."EV_DAT_Händelse_Datum")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum_Annex" a
        WHERE
            a."EV_DAT_ID" = _posit
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Händelse_Datum for: %', concat_ws(', ', NEW."EV_DAT_EV_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum_Posit" p
        JOIN
            attributes."EV_DAT_Händelse_Datum_Annex" a
        ON
            a."EV_DAT_ID" = p."EV_DAT_ID"
        WHERE
            p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            NOT attributes."eq_EV_DAT_Händelse_Datum"(p."EV_DAT_Händelse_Datum", NEW."EV_DAT_Händelse_Datum")
        AND
            a."EV_DAT_PositedAt" = _positing
        AND
            a."EV_DAT_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_DAT_Händelse_Datum for: %', concat_ws(', ', NEW."EV_DAT_EV_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_DAT_Händelse_Datum_Annex" a
        WHERE
            a."EV_DAT_ID" = _posit
        AND
            a."EV_DAT_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_DAT_Reliability" = 1
            FROM
                attributes."EV_DAT_Händelse_Datum_Annex" a
            WHERE
                a."EV_DAT_ID" = _posit
            AND
                a."EV_DAT_PositedAt" <= _positing
            ORDER BY
                a."EV_DAT_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_DAT_Händelse_Datum_Annex" (
            "Metadata_EV_DAT",
            "EV_DAT_ID",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", 0),
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
            p."EV_DAT_ID"
        FROM
            attributes."EV_DAT_Händelse_Datum_Posit" p
        WHERE
            p."EV_DAT_EV_ID" = NEW."EV_DAT_EV_ID"
        AND
            NOT attributes."eq_EV_DAT_Händelse_Datum"(p."EV_DAT_Händelse_Datum", NEW."EV_DAT_Händelse_Datum")
        AND
            coalesce((
                SELECT
                    a."EV_DAT_Reliability" = 1
                FROM
                    attributes."EV_DAT_Händelse_Datum_Annex" a
                WHERE
                    a."EV_DAT_ID" = p."EV_DAT_ID"
                AND
                    a."EV_DAT_PositedAt" <= _positing
                ORDER BY
                    a."EV_DAT_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."EV_DAT_Händelse_Datum_Annex" (
            "Metadata_EV_DAT",
            "EV_DAT_ID",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_DAT_Händelse_Datum_Posit" (
            "EV_DAT_EV_ID",
            "EV_DAT_Händelse_Datum"
        )
        VALUES (
            NEW."EV_DAT_EV_ID",
            NEW."EV_DAT_Händelse_Datum"
        )
        RETURNING "EV_DAT_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_DAT_Händelse_Datum_Annex" (
        "Metadata_EV_DAT",
        "EV_DAT_ID",
        "EV_DAT_PositedAt",
        "EV_DAT_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_DAT", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_DAT_Händelse_Datum" ON attributes."EV_DAT_Händelse_Datum";
CREATE TRIGGER "it_EV_DAT_Händelse_Datum"
INSTEAD OF INSERT ON attributes."EV_DAT_Händelse_Datum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_DAT_Händelse_Datum"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_AUD_Händelse_Publik tells whether two values of EV_AUD_Händelse_Publik are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_AUD_Händelse_Publik"(
    l integer,
    r integer
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_AUD_Händelse_Publik instead of INSERT trigger on EV_AUD_Händelse_Publik
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_AUD_Händelse_Publik"()
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
    _positing := coalesce(NEW."EV_AUD_PositedAt", _now);
    _reliability := coalesce(NEW."EV_AUD_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_AUD_ID"
    INTO
        _posit
    FROM
        attributes."EV_AUD_Händelse_Publik_Posit" p
    WHERE
        p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
    AND
        attributes."eq_EV_AUD_Händelse_Publik"(p."EV_AUD_Händelse_Publik", NEW."EV_AUD_Händelse_Publik")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik_Annex" a
        WHERE
            a."EV_AUD_ID" = _posit
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Händelse_Publik for: %', concat_ws(', ', NEW."EV_AUD_EV_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik_Posit" p
        JOIN
            attributes."EV_AUD_Händelse_Publik_Annex" a
        ON
            a."EV_AUD_ID" = p."EV_AUD_ID"
        WHERE
            p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            NOT attributes."eq_EV_AUD_Händelse_Publik"(p."EV_AUD_Händelse_Publik", NEW."EV_AUD_Händelse_Publik")
        AND
            a."EV_AUD_PositedAt" = _positing
        AND
            a."EV_AUD_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_AUD_Händelse_Publik for: %', concat_ws(', ', NEW."EV_AUD_EV_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_AUD_Händelse_Publik_Annex" a
        WHERE
            a."EV_AUD_ID" = _posit
        AND
            a."EV_AUD_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_AUD_Reliability" = 1
            FROM
                attributes."EV_AUD_Händelse_Publik_Annex" a
            WHERE
                a."EV_AUD_ID" = _posit
            AND
                a."EV_AUD_PositedAt" <= _positing
            ORDER BY
                a."EV_AUD_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_AUD_Händelse_Publik_Annex" (
            "Metadata_EV_AUD",
            "EV_AUD_ID",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", 0),
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
            p."EV_AUD_ID"
        FROM
            attributes."EV_AUD_Händelse_Publik_Posit" p
        WHERE
            p."EV_AUD_EV_ID" = NEW."EV_AUD_EV_ID"
        AND
            NOT attributes."eq_EV_AUD_Händelse_Publik"(p."EV_AUD_Händelse_Publik", NEW."EV_AUD_Händelse_Publik")
        AND
            coalesce((
                SELECT
                    a."EV_AUD_Reliability" = 1
                FROM
                    attributes."EV_AUD_Händelse_Publik_Annex" a
                WHERE
                    a."EV_AUD_ID" = p."EV_AUD_ID"
                AND
                    a."EV_AUD_PositedAt" <= _positing
                ORDER BY
                    a."EV_AUD_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."EV_AUD_Händelse_Publik_Annex" (
            "Metadata_EV_AUD",
            "EV_AUD_ID",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_AUD_Händelse_Publik_Posit" (
            "EV_AUD_EV_ID",
            "EV_AUD_Händelse_Publik"
        )
        VALUES (
            NEW."EV_AUD_EV_ID",
            NEW."EV_AUD_Händelse_Publik"
        )
        RETURNING "EV_AUD_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_AUD_Händelse_Publik_Annex" (
        "Metadata_EV_AUD",
        "EV_AUD_ID",
        "EV_AUD_PositedAt",
        "EV_AUD_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_AUD", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_AUD_Händelse_Publik" ON attributes."EV_AUD_Händelse_Publik";
CREATE TRIGGER "it_EV_AUD_Händelse_Publik"
INSTEAD OF INSERT ON attributes."EV_AUD_Händelse_Publik"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_AUD_Händelse_Publik"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_REV_Händelse_Intäkt tells whether two values of EV_REV_Händelse_Intäkt are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_REV_Händelse_Intäkt"(
    l decimal(19,4),
    r decimal(19,4)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_REV_Händelse_Intäkt instead of INSERT trigger on EV_REV_Händelse_Intäkt
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_REV_Händelse_Intäkt"()
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
    _positing := coalesce(NEW."EV_REV_PositedAt", _now);
    _reliability := coalesce(NEW."EV_REV_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_REV_ID"
    INTO
        _posit
    FROM
        attributes."EV_REV_Händelse_Intäkt_Posit" p
    WHERE
        p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
    AND
        attributes."eq_EV_REV_Händelse_Intäkt"(p."EV_REV_Händelse_Intäkt", NEW."EV_REV_Händelse_Intäkt")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt_Annex" a
        WHERE
            a."EV_REV_ID" = _posit
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Händelse_Intäkt for: %', concat_ws(', ', NEW."EV_REV_EV_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt_Posit" p
        JOIN
            attributes."EV_REV_Händelse_Intäkt_Annex" a
        ON
            a."EV_REV_ID" = p."EV_REV_ID"
        WHERE
            p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            NOT attributes."eq_EV_REV_Händelse_Intäkt"(p."EV_REV_Händelse_Intäkt", NEW."EV_REV_Händelse_Intäkt")
        AND
            a."EV_REV_PositedAt" = _positing
        AND
            a."EV_REV_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_REV_Händelse_Intäkt for: %', concat_ws(', ', NEW."EV_REV_EV_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_REV_Händelse_Intäkt_Annex" a
        WHERE
            a."EV_REV_ID" = _posit
        AND
            a."EV_REV_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_REV_Reliability" = 1
            FROM
                attributes."EV_REV_Händelse_Intäkt_Annex" a
            WHERE
                a."EV_REV_ID" = _posit
            AND
                a."EV_REV_PositedAt" <= _positing
            ORDER BY
                a."EV_REV_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_REV_Händelse_Intäkt_Annex" (
            "Metadata_EV_REV",
            "EV_REV_ID",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", 0),
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
            p."EV_REV_ID"
        FROM
            attributes."EV_REV_Händelse_Intäkt_Posit" p
        WHERE
            p."EV_REV_EV_ID" = NEW."EV_REV_EV_ID"
        AND
            NOT attributes."eq_EV_REV_Händelse_Intäkt"(p."EV_REV_Händelse_Intäkt", NEW."EV_REV_Händelse_Intäkt")
        AND
            coalesce((
                SELECT
                    a."EV_REV_Reliability" = 1
                FROM
                    attributes."EV_REV_Händelse_Intäkt_Annex" a
                WHERE
                    a."EV_REV_ID" = p."EV_REV_ID"
                AND
                    a."EV_REV_PositedAt" <= _positing
                ORDER BY
                    a."EV_REV_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."EV_REV_Händelse_Intäkt_Annex" (
            "Metadata_EV_REV",
            "EV_REV_ID",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_REV_Händelse_Intäkt_Posit" (
            "EV_REV_EV_ID",
            "EV_REV_Händelse_Intäkt"
        )
        VALUES (
            NEW."EV_REV_EV_ID",
            NEW."EV_REV_Händelse_Intäkt"
        )
        RETURNING "EV_REV_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_REV_Händelse_Intäkt_Annex" (
        "Metadata_EV_REV",
        "EV_REV_ID",
        "EV_REV_PositedAt",
        "EV_REV_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_REV", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_REV_Händelse_Intäkt" ON attributes."EV_REV_Händelse_Intäkt";
CREATE TRIGGER "it_EV_REV_Händelse_Intäkt"
INSTEAD OF INSERT ON attributes."EV_REV_Händelse_Intäkt"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_REV_Händelse_Intäkt"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_STA_Händelse_Status tells whether two values of EV_STA_Händelse_Status are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_STA_Händelse_Status"(
    l varchar(20),
    r varchar(20)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_STA_Händelse_Status instead of INSERT trigger on EV_STA_Händelse_Status
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_STA_Händelse_Status"()
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
    _positing := coalesce(NEW."EV_STA_PositedAt", _now);
    _reliability := coalesce(NEW."EV_STA_Reliability", 1);
    _changing := coalesce(NEW."EV_STA_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_STA_ID"
    INTO
        _posit
    FROM
        attributes."EV_STA_Händelse_Status_Posit" p
    WHERE
        p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
    AND
        p."EV_STA_ChangedAt" = _changing
    AND
        attributes."eq_EV_STA_Händelse_Status"(p."EV_STA_Händelse_Status", NEW."EV_STA_Händelse_Status")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status_Annex" a
        WHERE
            a."EV_STA_ID" = _posit
        AND
            a."EV_STA_PositedAt" = _positing
        AND
            a."EV_STA_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Händelse_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status_Posit" p
        JOIN
            attributes."EV_STA_Händelse_Status_Annex" a
        ON
            a."EV_STA_ID" = p."EV_STA_ID"
        WHERE
            p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            p."EV_STA_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_STA_Händelse_Status"(p."EV_STA_Händelse_Status", NEW."EV_STA_Händelse_Status")
        AND
            a."EV_STA_PositedAt" = _positing
        AND
            a."EV_STA_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_STA_Händelse_Status for: %', concat_ws(', ', NEW."EV_STA_EV_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_STA_Händelse_Status_Annex" a
        WHERE
            a."EV_STA_ID" = _posit
        AND
            a."EV_STA_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_STA_Reliability" = 1
            FROM
                attributes."EV_STA_Händelse_Status_Annex" a
            WHERE
                a."EV_STA_ID" = _posit
            AND
                a."EV_STA_PositedAt" <= _positing
            ORDER BY
                a."EV_STA_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_STA_Händelse_Status_Annex" (
            "Metadata_EV_STA",
            "EV_STA_ID",
            "EV_STA_PositedAt",
            "EV_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", 0),
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
            p."EV_STA_ID"
        FROM
            attributes."EV_STA_Händelse_Status_Posit" p
        WHERE
            p."EV_STA_EV_ID" = NEW."EV_STA_EV_ID"
        AND
            p."EV_STA_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_STA_Händelse_Status"(p."EV_STA_Händelse_Status", NEW."EV_STA_Händelse_Status")
        AND
            coalesce((
                SELECT
                    a."EV_STA_Reliability" = 1
                FROM
                    attributes."EV_STA_Händelse_Status_Annex" a
                WHERE
                    a."EV_STA_ID" = p."EV_STA_ID"
                AND
                    a."EV_STA_PositedAt" <= _positing
                ORDER BY
                    a."EV_STA_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."EV_STA_Händelse_Status_Annex" (
            "Metadata_EV_STA",
            "EV_STA_ID",
            "EV_STA_PositedAt",
            "EV_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_STA_Händelse_Status_Posit" (
            "EV_STA_EV_ID",
            "EV_STA_ChangedAt",
            "EV_STA_Händelse_Status"
        )
        VALUES (
            NEW."EV_STA_EV_ID",
            _changing,
            NEW."EV_STA_Händelse_Status"
        )
        RETURNING "EV_STA_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_STA_Händelse_Status_Annex" (
        "Metadata_EV_STA",
        "EV_STA_ID",
        "EV_STA_PositedAt",
        "EV_STA_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_STA", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_STA_Händelse_Status" ON attributes."EV_STA_Händelse_Status";
CREATE TRIGGER "it_EV_STA_Händelse_Status"
INSTEAD OF INSERT ON attributes."EV_STA_Händelse_Status"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_STA_Händelse_Status"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_UTL_Händelse_Utnyttjande tells whether two values of EV_UTL_Händelse_Utnyttjande are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_UTL_Händelse_Utnyttjande"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_UTL_Händelse_Utnyttjande instead of INSERT trigger on EV_UTL_Händelse_Utnyttjande
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_UTL_Händelse_Utnyttjande"()
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
    _positing := coalesce(NEW."EV_UTL_PositedAt", _now);
    _reliability := coalesce(NEW."EV_UTL_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_UTL_ID"
    INTO
        _posit
    FROM
        attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
    WHERE
        p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
    AND
        attributes."eq_EV_UTL_Händelse_Utnyttjande"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
        WHERE
            a."EV_UTL_ID" = _posit
        AND
            a."EV_UTL_PositedAt" = _positing
        AND
            a."EV_UTL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Händelse_Utnyttjande for: %', concat_ws(', ', NEW."EV_UTL_EV_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
        JOIN
            attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
        ON
            a."EV_UTL_ID" = p."EV_UTL_ID"
        WHERE
            p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
        AND
            NOT attributes."eq_EV_UTL_Händelse_Utnyttjande"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
        AND
            a."EV_UTL_PositedAt" = _positing
        AND
            a."EV_UTL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_UTL_Händelse_Utnyttjande for: %', concat_ws(', ', NEW."EV_UTL_EV_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
        WHERE
            a."EV_UTL_ID" = _posit
        AND
            a."EV_UTL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_UTL_Reliability" = 1
            FROM
                attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
            WHERE
                a."EV_UTL_ID" = _posit
            AND
                a."EV_UTL_PositedAt" <= _positing
            ORDER BY
                a."EV_UTL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
            "Metadata_EV_UTL",
            "EV_UTL_ID",
            "EV_UTL_PositedAt",
            "EV_UTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", 0),
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
            p."EV_UTL_ID"
        FROM
            attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
        WHERE
            p."EV_UTL_EV_ID" = NEW."EV_UTL_EV_ID"
        AND
            NOT attributes."eq_EV_UTL_Händelse_Utnyttjande"(p."EV_UTL_UTL_ID", NEW."EV_UTL_UTL_ID")
        AND
            coalesce((
                SELECT
                    a."EV_UTL_Reliability" = 1
                FROM
                    attributes."EV_UTL_Händelse_Utnyttjande_Annex" a
                WHERE
                    a."EV_UTL_ID" = p."EV_UTL_ID"
                AND
                    a."EV_UTL_PositedAt" <= _positing
                ORDER BY
                    a."EV_UTL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
            "Metadata_EV_UTL",
            "EV_UTL_ID",
            "EV_UTL_PositedAt",
            "EV_UTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Posit" (
            "EV_UTL_EV_ID",
            "EV_UTL_UTL_ID"
        )
        VALUES (
            NEW."EV_UTL_EV_ID",
            NEW."EV_UTL_UTL_ID"
        )
        RETURNING "EV_UTL_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
        "Metadata_EV_UTL",
        "EV_UTL_ID",
        "EV_UTL_PositedAt",
        "EV_UTL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_UTL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_UTL_Händelse_Utnyttjande" ON attributes."EV_UTL_Händelse_Utnyttjande";
CREATE TRIGGER "it_EV_UTL_Händelse_Utnyttjande"
INSTEAD OF INSERT ON attributes."EV_UTL_Händelse_Utnyttjande"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_UTL_Händelse_Utnyttjande"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_EV_LVL_Händelse_Level tells whether two values of EV_LVL_Händelse_Level are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_EV_LVL_Händelse_Level"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_LVL_Händelse_Level instead of INSERT trigger on EV_LVL_Händelse_Level
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_EV_LVL_Händelse_Level"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing date;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."EV_LVL_PositedAt", _now);
    _reliability := coalesce(NEW."EV_LVL_Reliability", 1);
    _changing := coalesce(NEW."EV_LVL_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."EV_LVL_ID"
    INTO
        _posit
    FROM
        attributes."EV_LVL_Händelse_Level_Posit" p
    WHERE
        p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
    AND
        p."EV_LVL_ChangedAt" = _changing
    AND
        attributes."eq_EV_LVL_Händelse_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level_Annex" a
        WHERE
            a."EV_LVL_ID" = _posit
        AND
            a."EV_LVL_PositedAt" = _positing
        AND
            a."EV_LVL_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Händelse_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level_Posit" p
        JOIN
            attributes."EV_LVL_Händelse_Level_Annex" a
        ON
            a."EV_LVL_ID" = p."EV_LVL_ID"
        WHERE
            p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            p."EV_LVL_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_LVL_Händelse_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
        AND
            a."EV_LVL_PositedAt" = _positing
        AND
            a."EV_LVL_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_LVL_Händelse_Level for: %', concat_ws(', ', NEW."EV_LVL_EV_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."EV_LVL_Händelse_Level_Annex" a
        WHERE
            a."EV_LVL_ID" = _posit
        AND
            a."EV_LVL_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."EV_LVL_Reliability" = 1
            FROM
                attributes."EV_LVL_Händelse_Level_Annex" a
            WHERE
                a."EV_LVL_ID" = _posit
            AND
                a."EV_LVL_PositedAt" <= _positing
            ORDER BY
                a."EV_LVL_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."EV_LVL_Händelse_Level_Annex" (
            "Metadata_EV_LVL",
            "EV_LVL_ID",
            "EV_LVL_PositedAt",
            "EV_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", 0),
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
            p."EV_LVL_ID"
        FROM
            attributes."EV_LVL_Händelse_Level_Posit" p
        WHERE
            p."EV_LVL_EV_ID" = NEW."EV_LVL_EV_ID"
        AND
            p."EV_LVL_ChangedAt" = _changing
        AND
            NOT attributes."eq_EV_LVL_Händelse_Level"(p."EV_LVL_PLV_ID", NEW."EV_LVL_PLV_ID")
        AND
            coalesce((
                SELECT
                    a."EV_LVL_Reliability" = 1
                FROM
                    attributes."EV_LVL_Händelse_Level_Annex" a
                WHERE
                    a."EV_LVL_ID" = p."EV_LVL_ID"
                AND
                    a."EV_LVL_PositedAt" <= _positing
                ORDER BY
                    a."EV_LVL_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."EV_LVL_Händelse_Level_Annex" (
            "Metadata_EV_LVL",
            "EV_LVL_ID",
            "EV_LVL_PositedAt",
            "EV_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."EV_LVL_Händelse_Level_Posit" (
            "EV_LVL_EV_ID",
            "EV_LVL_ChangedAt",
            "EV_LVL_PLV_ID"
        )
        VALUES (
            NEW."EV_LVL_EV_ID",
            _changing,
            NEW."EV_LVL_PLV_ID"
        )
        RETURNING "EV_LVL_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."EV_LVL_Händelse_Level_Annex" (
        "Metadata_EV_LVL",
        "EV_LVL_ID",
        "EV_LVL_PositedAt",
        "EV_LVL_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_LVL", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_LVL_Händelse_Level" ON attributes."EV_LVL_Händelse_Level";
CREATE TRIGGER "it_EV_LVL_Händelse_Level"
INSTEAD OF INSERT ON attributes."EV_LVL_Händelse_Level"
FOR EACH ROW EXECUTE FUNCTION attributes."it_EV_LVL_Händelse_Level"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_NAM_Scen_Namn tells whether two values of ST_NAM_Scen_Namn are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_NAM_Scen_Namn"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_NAM_Scen_Namn instead of INSERT trigger on ST_NAM_Scen_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_NAM_Scen_Namn"()
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
    _positing := coalesce(NEW."ST_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."ST_NAM_Reliability", 1);
    _changing := coalesce(NEW."ST_NAM_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_NAM_ID"
    INTO
        _posit
    FROM
        attributes."ST_NAM_Scen_Namn_Posit" p
    WHERE
        p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
    AND
        p."ST_NAM_ChangedAt" = _changing
    AND
        attributes."eq_ST_NAM_Scen_Namn"(p."ST_NAM_Scen_Namn", NEW."ST_NAM_Scen_Namn")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn_Annex" a
        WHERE
            a."ST_NAM_ID" = _posit
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Scen_Namn for: %', concat_ws(', ', NEW."ST_NAM_ST_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn_Posit" p
        JOIN
            attributes."ST_NAM_Scen_Namn_Annex" a
        ON
            a."ST_NAM_ID" = p."ST_NAM_ID"
        WHERE
            p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_NAM_Scen_Namn"(p."ST_NAM_Scen_Namn", NEW."ST_NAM_Scen_Namn")
        AND
            a."ST_NAM_PositedAt" = _positing
        AND
            a."ST_NAM_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_NAM_Scen_Namn for: %', concat_ws(', ', NEW."ST_NAM_ST_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_NAM_Scen_Namn_Annex" a
        WHERE
            a."ST_NAM_ID" = _posit
        AND
            a."ST_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."ST_NAM_Reliability" = 1
            FROM
                attributes."ST_NAM_Scen_Namn_Annex" a
            WHERE
                a."ST_NAM_ID" = _posit
            AND
                a."ST_NAM_PositedAt" <= _positing
            ORDER BY
                a."ST_NAM_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_NAM_Scen_Namn_Annex" (
            "Metadata_ST_NAM",
            "ST_NAM_ID",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", 0),
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
            p."ST_NAM_ID"
        FROM
            attributes."ST_NAM_Scen_Namn_Posit" p
        WHERE
            p."ST_NAM_ST_ID" = NEW."ST_NAM_ST_ID"
        AND
            p."ST_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_NAM_Scen_Namn"(p."ST_NAM_Scen_Namn", NEW."ST_NAM_Scen_Namn")
        AND
            coalesce((
                SELECT
                    a."ST_NAM_Reliability" = 1
                FROM
                    attributes."ST_NAM_Scen_Namn_Annex" a
                WHERE
                    a."ST_NAM_ID" = p."ST_NAM_ID"
                AND
                    a."ST_NAM_PositedAt" <= _positing
                ORDER BY
                    a."ST_NAM_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."ST_NAM_Scen_Namn_Annex" (
            "Metadata_ST_NAM",
            "ST_NAM_ID",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_NAM_Scen_Namn_Posit" (
            "ST_NAM_ST_ID",
            "ST_NAM_ChangedAt",
            "ST_NAM_Scen_Namn"
        )
        VALUES (
            NEW."ST_NAM_ST_ID",
            _changing,
            NEW."ST_NAM_Scen_Namn"
        )
        RETURNING "ST_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_NAM_Scen_Namn_Annex" (
        "Metadata_ST_NAM",
        "ST_NAM_ID",
        "ST_NAM_PositedAt",
        "ST_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_NAM", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_NAM_Scen_Namn" ON attributes."ST_NAM_Scen_Namn";
CREATE TRIGGER "it_ST_NAM_Scen_Namn"
INSTEAD OF INSERT ON attributes."ST_NAM_Scen_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_NAM_Scen_Namn"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_LOC_Scen_Plats tells whether two values of ST_LOC_Scen_Plats are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_LOC_Scen_Plats"(
    l text,
    r text
)
RETURNS boolean
AS
$$
    SELECT md5(l::text) = md5(r::text)
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_LOC_Scen_Plats instead of INSERT trigger on ST_LOC_Scen_Plats
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_LOC_Scen_Plats"()
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
    _positing := coalesce(NEW."ST_LOC_PositedAt", _now);
    _reliability := coalesce(NEW."ST_LOC_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."ST_LOC_ID"
    INTO
        _posit
    FROM
        attributes."ST_LOC_Scen_Plats_Posit" p
    WHERE
        p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
    AND
        attributes."eq_ST_LOC_Scen_Plats"(p."ST_LOC_Scen_Plats", NEW."ST_LOC_Scen_Plats")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats_Annex" a
        WHERE
            a."ST_LOC_ID" = _posit
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Scen_Plats for: %', concat_ws(', ', NEW."ST_LOC_ST_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats_Posit" p
        JOIN
            attributes."ST_LOC_Scen_Plats_Annex" a
        ON
            a."ST_LOC_ID" = p."ST_LOC_ID"
        WHERE
            p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            NOT attributes."eq_ST_LOC_Scen_Plats"(p."ST_LOC_Scen_Plats", NEW."ST_LOC_Scen_Plats")
        AND
            a."ST_LOC_PositedAt" = _positing
        AND
            a."ST_LOC_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_LOC_Scen_Plats for: %', concat_ws(', ', NEW."ST_LOC_ST_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_LOC_Scen_Plats_Annex" a
        WHERE
            a."ST_LOC_ID" = _posit
        AND
            a."ST_LOC_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."ST_LOC_Reliability" = 1
            FROM
                attributes."ST_LOC_Scen_Plats_Annex" a
            WHERE
                a."ST_LOC_ID" = _posit
            AND
                a."ST_LOC_PositedAt" <= _positing
            ORDER BY
                a."ST_LOC_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_LOC_Scen_Plats_Annex" (
            "Metadata_ST_LOC",
            "ST_LOC_ID",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", 0),
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
            p."ST_LOC_ID"
        FROM
            attributes."ST_LOC_Scen_Plats_Posit" p
        WHERE
            p."ST_LOC_ST_ID" = NEW."ST_LOC_ST_ID"
        AND
            NOT attributes."eq_ST_LOC_Scen_Plats"(p."ST_LOC_Scen_Plats", NEW."ST_LOC_Scen_Plats")
        AND
            coalesce((
                SELECT
                    a."ST_LOC_Reliability" = 1
                FROM
                    attributes."ST_LOC_Scen_Plats_Annex" a
                WHERE
                    a."ST_LOC_ID" = p."ST_LOC_ID"
                AND
                    a."ST_LOC_PositedAt" <= _positing
                ORDER BY
                    a."ST_LOC_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."ST_LOC_Scen_Plats_Annex" (
            "Metadata_ST_LOC",
            "ST_LOC_ID",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_LOC_Scen_Plats_Posit" (
            "ST_LOC_ST_ID",
            "ST_LOC_Scen_Plats"
        )
        VALUES (
            NEW."ST_LOC_ST_ID",
            NEW."ST_LOC_Scen_Plats"
        )
        RETURNING "ST_LOC_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_LOC_Scen_Plats_Annex" (
        "Metadata_ST_LOC",
        "ST_LOC_ID",
        "ST_LOC_PositedAt",
        "ST_LOC_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_LOC", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_LOC_Scen_Plats" ON attributes."ST_LOC_Scen_Plats";
CREATE TRIGGER "it_ST_LOC_Scen_Plats"
INSTEAD OF INSERT ON attributes."ST_LOC_Scen_Plats"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_LOC_Scen_Plats"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_AVG_Scen_Medel tells whether two values of ST_AVG_Scen_Medel are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_AVG_Scen_Medel"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_AVG_Scen_Medel instead of INSERT trigger on ST_AVG_Scen_Medel
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_AVG_Scen_Medel"()
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
    _positing := coalesce(NEW."ST_AVG_PositedAt", _now);
    _reliability := coalesce(NEW."ST_AVG_Reliability", 1);
    _changing := coalesce(NEW."ST_AVG_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_AVG_ID"
    INTO
        _posit
    FROM
        attributes."ST_AVG_Scen_Medel_Posit" p
    WHERE
        p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        p."ST_AVG_ChangedAt" = _changing
    AND
        attributes."eq_ST_AVG_Scen_Medel"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel_Annex" a
        WHERE
            a."ST_AVG_ID" = _posit
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Scen_Medel for: %', concat_ws(', ', NEW."ST_AVG_ST_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel_Posit" p
        JOIN
            attributes."ST_AVG_Scen_Medel_Annex" a
        ON
            a."ST_AVG_ID" = p."ST_AVG_ID"
        WHERE
            p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_AVG_Scen_Medel"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
        AND
            a."ST_AVG_PositedAt" = _positing
        AND
            a."ST_AVG_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_AVG_Scen_Medel for: %', concat_ws(', ', NEW."ST_AVG_ST_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_AVG_Scen_Medel_Annex" a
        WHERE
            a."ST_AVG_ID" = _posit
        AND
            a."ST_AVG_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."ST_AVG_Reliability" = 1
            FROM
                attributes."ST_AVG_Scen_Medel_Annex" a
            WHERE
                a."ST_AVG_ID" = _posit
            AND
                a."ST_AVG_PositedAt" <= _positing
            ORDER BY
                a."ST_AVG_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
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
            p."ST_AVG_ID"
        FROM
            attributes."ST_AVG_Scen_Medel_Posit" p
        WHERE
            p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
        AND
            p."ST_AVG_ChangedAt" = _changing
        AND
            NOT attributes."eq_ST_AVG_Scen_Medel"(p."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
        AND
            coalesce((
                SELECT
                    a."ST_AVG_Reliability" = 1
                FROM
                    attributes."ST_AVG_Scen_Medel_Annex" a
                WHERE
                    a."ST_AVG_ID" = p."ST_AVG_ID"
                AND
                    a."ST_AVG_PositedAt" <= _positing
                ORDER BY
                    a."ST_AVG_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
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
                p."ST_AVG_UTL_ID"
            FROM
                attributes."ST_AVG_Scen_Medel_Posit" p
            WHERE
                p."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
            AND
                p."ST_AVG_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."ST_AVG_Reliability" = 1
                    FROM
                        attributes."ST_AVG_Scen_Medel_Annex" a
                    WHERE
                        a."ST_AVG_ID" = p."ST_AVG_ID"
                    AND
                        a."ST_AVG_PositedAt" <= _positing
                    ORDER BY
                        a."ST_AVG_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."ST_AVG_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_ST_AVG_Scen_Medel"(pre."ST_AVG_UTL_ID", NEW."ST_AVG_UTL_ID")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."ST_AVG_ID"
    INTO
        _following
    FROM
        attributes."ST_AVG_Scen_Medel_Posit" f
    WHERE
        f."ST_AVG_ST_ID" = NEW."ST_AVG_ST_ID"
    AND
        f."ST_AVG_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."ST_AVG_Reliability" = 1
            FROM
                attributes."ST_AVG_Scen_Medel_Annex" a
            WHERE
                a."ST_AVG_ID" = f."ST_AVG_ID"
            AND
                a."ST_AVG_PositedAt" <= _positing
            ORDER BY
                a."ST_AVG_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."ST_AVG_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_ST_AVG_Scen_Medel"((
        SELECT x."ST_AVG_UTL_ID" FROM attributes."ST_AVG_Scen_Medel_Posit" x WHERE x."ST_AVG_ID" = _following
    ), NEW."ST_AVG_UTL_ID") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
            "Metadata_ST_AVG",
            "ST_AVG_ID",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", 0),
            _following,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_AVG_Scen_Medel_Posit" (
            "ST_AVG_ST_ID",
            "ST_AVG_ChangedAt",
            "ST_AVG_UTL_ID"
        )
        VALUES (
            NEW."ST_AVG_ST_ID",
            _changing,
            NEW."ST_AVG_UTL_ID"
        )
        RETURNING "ST_AVG_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
        "Metadata_ST_AVG",
        "ST_AVG_ID",
        "ST_AVG_PositedAt",
        "ST_AVG_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_AVG", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_AVG_Scen_Medel" ON attributes."ST_AVG_Scen_Medel";
CREATE TRIGGER "it_ST_AVG_Scen_Medel"
INSTEAD OF INSERT ON attributes."ST_AVG_Scen_Medel"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_AVG_Scen_Medel"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_ST_MIN_Scen_Minimum tells whether two values of ST_MIN_Scen_Minimum are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_ST_MIN_Scen_Minimum"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_MIN_Scen_Minimum instead of INSERT trigger on ST_MIN_Scen_Minimum
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_ST_MIN_Scen_Minimum"()
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
    _positing := coalesce(NEW."ST_MIN_PositedAt", _now);
    _reliability := coalesce(NEW."ST_MIN_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."ST_MIN_ID"
    INTO
        _posit
    FROM
        attributes."ST_MIN_Scen_Minimum_Posit" p
    WHERE
        p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
    AND
        attributes."eq_ST_MIN_Scen_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum_Annex" a
        WHERE
            a."ST_MIN_ID" = _posit
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Scen_Minimum for: %', concat_ws(', ', NEW."ST_MIN_ST_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum_Posit" p
        JOIN
            attributes."ST_MIN_Scen_Minimum_Annex" a
        ON
            a."ST_MIN_ID" = p."ST_MIN_ID"
        WHERE
            p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
        AND
            NOT attributes."eq_ST_MIN_Scen_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
        AND
            a."ST_MIN_PositedAt" = _positing
        AND
            a."ST_MIN_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_MIN_Scen_Minimum for: %', concat_ws(', ', NEW."ST_MIN_ST_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."ST_MIN_Scen_Minimum_Annex" a
        WHERE
            a."ST_MIN_ID" = _posit
        AND
            a."ST_MIN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."ST_MIN_Reliability" = 1
            FROM
                attributes."ST_MIN_Scen_Minimum_Annex" a
            WHERE
                a."ST_MIN_ID" = _posit
            AND
                a."ST_MIN_PositedAt" <= _positing
            ORDER BY
                a."ST_MIN_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."ST_MIN_Scen_Minimum_Annex" (
            "Metadata_ST_MIN",
            "ST_MIN_ID",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_MIN", 0),
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
            p."ST_MIN_ID"
        FROM
            attributes."ST_MIN_Scen_Minimum_Posit" p
        WHERE
            p."ST_MIN_ST_ID" = NEW."ST_MIN_ST_ID"
        AND
            NOT attributes."eq_ST_MIN_Scen_Minimum"(p."ST_MIN_UTL_ID", NEW."ST_MIN_UTL_ID")
        AND
            coalesce((
                SELECT
                    a."ST_MIN_Reliability" = 1
                FROM
                    attributes."ST_MIN_Scen_Minimum_Annex" a
                WHERE
                    a."ST_MIN_ID" = p."ST_MIN_ID"
                AND
                    a."ST_MIN_PositedAt" <= _positing
                ORDER BY
                    a."ST_MIN_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."ST_MIN_Scen_Minimum_Annex" (
            "Metadata_ST_MIN",
            "ST_MIN_ID",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_MIN", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."ST_MIN_Scen_Minimum_Posit" (
            "ST_MIN_ST_ID",
            "ST_MIN_UTL_ID"
        )
        VALUES (
            NEW."ST_MIN_ST_ID",
            NEW."ST_MIN_UTL_ID"
        )
        RETURNING "ST_MIN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."ST_MIN_Scen_Minimum_Annex" (
        "Metadata_ST_MIN",
        "ST_MIN_ID",
        "ST_MIN_PositedAt",
        "ST_MIN_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_MIN", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_MIN_Scen_Minimum" ON attributes."ST_MIN_Scen_Minimum";
CREATE TRIGGER "it_ST_MIN_Scen_Minimum"
INSTEAD OF INSERT ON attributes."ST_MIN_Scen_Minimum"
FOR EACH ROW EXECUTE FUNCTION attributes."it_ST_MIN_Scen_Minimum"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_NAM_Skådespelare_Namn tells whether two values of AC_NAM_Skådespelare_Namn are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_NAM_Skådespelare_Namn"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_NAM_Skådespelare_Namn instead of INSERT trigger on AC_NAM_Skådespelare_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_NAM_Skådespelare_Namn"()
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
    _positing := coalesce(NEW."AC_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."AC_NAM_Reliability", 1);
    _changing := coalesce(NEW."AC_NAM_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_NAM_ID"
    INTO
        _posit
    FROM
        attributes."AC_NAM_Skådespelare_Namn_Posit" p
    WHERE
        p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
    AND
        p."AC_NAM_ChangedAt" = _changing
    AND
        attributes."eq_AC_NAM_Skådespelare_Namn"(p."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn_Annex" a
        WHERE
            a."AC_NAM_ID" = _posit
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn_Posit" p
        JOIN
            attributes."AC_NAM_Skådespelare_Namn_Annex" a
        ON
            a."AC_NAM_ID" = p."AC_NAM_ID"
        WHERE
            p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_NAM_Skådespelare_Namn"(p."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
        AND
            a."AC_NAM_PositedAt" = _positing
        AND
            a."AC_NAM_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_NAM_Skådespelare_Namn_Annex" a
        WHERE
            a."AC_NAM_ID" = _posit
        AND
            a."AC_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."AC_NAM_Reliability" = 1
            FROM
                attributes."AC_NAM_Skådespelare_Namn_Annex" a
            WHERE
                a."AC_NAM_ID" = _posit
            AND
                a."AC_NAM_PositedAt" <= _positing
            ORDER BY
                a."AC_NAM_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Annex" (
            "Metadata_AC_NAM",
            "AC_NAM_ID",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", 0),
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
            p."AC_NAM_ID"
        FROM
            attributes."AC_NAM_Skådespelare_Namn_Posit" p
        WHERE
            p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
        AND
            p."AC_NAM_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_NAM_Skådespelare_Namn"(p."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
        AND
            coalesce((
                SELECT
                    a."AC_NAM_Reliability" = 1
                FROM
                    attributes."AC_NAM_Skådespelare_Namn_Annex" a
                WHERE
                    a."AC_NAM_ID" = p."AC_NAM_ID"
                AND
                    a."AC_NAM_PositedAt" <= _positing
                ORDER BY
                    a."AC_NAM_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Annex" (
            "Metadata_AC_NAM",
            "AC_NAM_ID",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", 0),
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
                p."AC_NAM_Skådespelare_Namn"
            FROM
                attributes."AC_NAM_Skådespelare_Namn_Posit" p
            WHERE
                p."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
            AND
                p."AC_NAM_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."AC_NAM_Reliability" = 1
                    FROM
                        attributes."AC_NAM_Skådespelare_Namn_Annex" a
                    WHERE
                        a."AC_NAM_ID" = p."AC_NAM_ID"
                    AND
                        a."AC_NAM_PositedAt" <= _positing
                    ORDER BY
                        a."AC_NAM_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."AC_NAM_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_AC_NAM_Skådespelare_Namn"(pre."AC_NAM_Skådespelare_Namn", NEW."AC_NAM_Skådespelare_Namn")
    ) THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", _changing, _positing);
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."AC_NAM_ID"
    INTO
        _following
    FROM
        attributes."AC_NAM_Skådespelare_Namn_Posit" f
    WHERE
        f."AC_NAM_AC_ID" = NEW."AC_NAM_AC_ID"
    AND
        f."AC_NAM_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."AC_NAM_Reliability" = 1
            FROM
                attributes."AC_NAM_Skådespelare_Namn_Annex" a
            WHERE
                a."AC_NAM_ID" = f."AC_NAM_ID"
            AND
                a."AC_NAM_PositedAt" <= _positing
            ORDER BY
                a."AC_NAM_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."AC_NAM_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_AC_NAM_Skådespelare_Namn"((
        SELECT x."AC_NAM_Skådespelare_Namn" FROM attributes."AC_NAM_Skådespelare_Namn_Posit" x WHERE x."AC_NAM_ID" = _following
    ), NEW."AC_NAM_Skådespelare_Namn") THEN
        RAISE EXCEPTION 'Restatement in AC_NAM_Skådespelare_Namn for: %', concat_ws(', ', NEW."AC_NAM_AC_ID", _changing, _positing);
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Posit" (
            "AC_NAM_AC_ID",
            "AC_NAM_ChangedAt",
            "AC_NAM_Skådespelare_Namn"
        )
        VALUES (
            NEW."AC_NAM_AC_ID",
            _changing,
            NEW."AC_NAM_Skådespelare_Namn"
        )
        RETURNING "AC_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Annex" (
        "Metadata_AC_NAM",
        "AC_NAM_ID",
        "AC_NAM_PositedAt",
        "AC_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_NAM", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_NAM_Skådespelare_Namn" ON attributes."AC_NAM_Skådespelare_Namn";
CREATE TRIGGER "it_AC_NAM_Skådespelare_Namn"
INSTEAD OF INSERT ON attributes."AC_NAM_Skådespelare_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_NAM_Skådespelare_Namn"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_GEN_Skådespelare_Kön tells whether two values of AC_GEN_Skådespelare_Kön are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_GEN_Skådespelare_Kön"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_GEN_Skådespelare_Kön instead of INSERT trigger on AC_GEN_Skådespelare_Kön
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_GEN_Skådespelare_Kön"()
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
    _positing := coalesce(NEW."AC_GEN_PositedAt", _now);
    _reliability := coalesce(NEW."AC_GEN_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."AC_GEN_ID"
    INTO
        _posit
    FROM
        attributes."AC_GEN_Skådespelare_Kön_Posit" p
    WHERE
        p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
    AND
        attributes."eq_AC_GEN_Skådespelare_Kön"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön_Annex" a
        WHERE
            a."AC_GEN_ID" = _posit
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Skådespelare_Kön for: %', concat_ws(', ', NEW."AC_GEN_AC_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön_Posit" p
        JOIN
            attributes."AC_GEN_Skådespelare_Kön_Annex" a
        ON
            a."AC_GEN_ID" = p."AC_GEN_ID"
        WHERE
            p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
        AND
            NOT attributes."eq_AC_GEN_Skådespelare_Kön"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
        AND
            a."AC_GEN_PositedAt" = _positing
        AND
            a."AC_GEN_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_GEN_Skådespelare_Kön for: %', concat_ws(', ', NEW."AC_GEN_AC_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_GEN_Skådespelare_Kön_Annex" a
        WHERE
            a."AC_GEN_ID" = _posit
        AND
            a."AC_GEN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."AC_GEN_Reliability" = 1
            FROM
                attributes."AC_GEN_Skådespelare_Kön_Annex" a
            WHERE
                a."AC_GEN_ID" = _posit
            AND
                a."AC_GEN_PositedAt" <= _positing
            ORDER BY
                a."AC_GEN_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Annex" (
            "Metadata_AC_GEN",
            "AC_GEN_ID",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_GEN", 0),
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
            p."AC_GEN_ID"
        FROM
            attributes."AC_GEN_Skådespelare_Kön_Posit" p
        WHERE
            p."AC_GEN_AC_ID" = NEW."AC_GEN_AC_ID"
        AND
            NOT attributes."eq_AC_GEN_Skådespelare_Kön"(p."AC_GEN_GEN_ID", NEW."AC_GEN_GEN_ID")
        AND
            coalesce((
                SELECT
                    a."AC_GEN_Reliability" = 1
                FROM
                    attributes."AC_GEN_Skådespelare_Kön_Annex" a
                WHERE
                    a."AC_GEN_ID" = p."AC_GEN_ID"
                AND
                    a."AC_GEN_PositedAt" <= _positing
                ORDER BY
                    a."AC_GEN_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Annex" (
            "Metadata_AC_GEN",
            "AC_GEN_ID",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_GEN", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Posit" (
            "AC_GEN_AC_ID",
            "AC_GEN_GEN_ID"
        )
        VALUES (
            NEW."AC_GEN_AC_ID",
            NEW."AC_GEN_GEN_ID"
        )
        RETURNING "AC_GEN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Annex" (
        "Metadata_AC_GEN",
        "AC_GEN_ID",
        "AC_GEN_PositedAt",
        "AC_GEN_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_GEN", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_GEN_Skådespelare_Kön" ON attributes."AC_GEN_Skådespelare_Kön";
CREATE TRIGGER "it_AC_GEN_Skådespelare_Kön"
INSTEAD OF INSERT ON attributes."AC_GEN_Skådespelare_Kön"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_GEN_Skådespelare_Kön"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_AC_PLV_Skådespelare_Yrkesnivå tells whether two values of AC_PLV_Skådespelare_Yrkesnivå are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(
    l smallint,
    r smallint
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_PLV_Skådespelare_Yrkesnivå instead of INSERT trigger on AC_PLV_Skådespelare_Yrkesnivå
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_AC_PLV_Skådespelare_Yrkesnivå"()
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
    _positing := coalesce(NEW."AC_PLV_PositedAt", _now);
    _reliability := coalesce(NEW."AC_PLV_Reliability", 1);
    _changing := coalesce(NEW."AC_PLV_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_PLV_ID"
    INTO
        _posit
    FROM
        attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
    WHERE
        p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
    AND
        p."AC_PLV_ChangedAt" = _changing
    AND
        attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
        WHERE
            a."AC_PLV_ID" = _posit
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: %', concat_ws(', ', NEW."AC_PLV_AC_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
        JOIN
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
        ON
            a."AC_PLV_ID" = p."AC_PLV_ID"
        WHERE
            p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
        AND
            a."AC_PLV_PositedAt" = _positing
        AND
            a."AC_PLV_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_PLV_Skådespelare_Yrkesnivå for: %', concat_ws(', ', NEW."AC_PLV_AC_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
        WHERE
            a."AC_PLV_ID" = _posit
        AND
            a."AC_PLV_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."AC_PLV_Reliability" = 1
            FROM
                attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
            WHERE
                a."AC_PLV_ID" = _posit
            AND
                a."AC_PLV_PositedAt" <= _positing
            ORDER BY
                a."AC_PLV_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
            "Metadata_AC_PLV",
            "AC_PLV_ID",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_PLV", 0),
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
            p."AC_PLV_ID"
        FROM
            attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
        WHERE
            p."AC_PLV_AC_ID" = NEW."AC_PLV_AC_ID"
        AND
            p."AC_PLV_ChangedAt" = _changing
        AND
            NOT attributes."eq_AC_PLV_Skådespelare_Yrkesnivå"(p."AC_PLV_PLV_ID", NEW."AC_PLV_PLV_ID")
        AND
            coalesce((
                SELECT
                    a."AC_PLV_Reliability" = 1
                FROM
                    attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" a
                WHERE
                    a."AC_PLV_ID" = p."AC_PLV_ID"
                AND
                    a."AC_PLV_PositedAt" <= _positing
                ORDER BY
                    a."AC_PLV_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
            "Metadata_AC_PLV",
            "AC_PLV_ID",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_PLV", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" (
            "AC_PLV_AC_ID",
            "AC_PLV_ChangedAt",
            "AC_PLV_PLV_ID"
        )
        VALUES (
            NEW."AC_PLV_AC_ID",
            _changing,
            NEW."AC_PLV_PLV_ID"
        )
        RETURNING "AC_PLV_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
        "Metadata_AC_PLV",
        "AC_PLV_ID",
        "AC_PLV_PositedAt",
        "AC_PLV_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_PLV", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_PLV_Skådespelare_Yrkesnivå" ON attributes."AC_PLV_Skådespelare_Yrkesnivå";
CREATE TRIGGER "it_AC_PLV_Skådespelare_Yrkesnivå"
INSTEAD OF INSERT ON attributes."AC_PLV_Skådespelare_Yrkesnivå"
FOR EACH ROW EXECUTE FUNCTION attributes."it_AC_PLV_Skådespelare_Yrkesnivå"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_NAM_Föreställning_Namn tells whether two values of PR_NAM_Föreställning_Namn are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_PR_NAM_Föreställning_Namn"(
    l varchar(42),
    r varchar(42)
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_NAM_Föreställning_Namn instead of INSERT trigger on PR_NAM_Föreställning_Namn
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_NAM_Föreställning_Namn"()
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
    _positing := coalesce(NEW."PR_NAM_PositedAt", _now);
    _reliability := coalesce(NEW."PR_NAM_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."PR_NAM_ID"
    INTO
        _posit
    FROM
        attributes."PR_NAM_Föreställning_Namn_Posit" p
    WHERE
        p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
    AND
        attributes."eq_PR_NAM_Föreställning_Namn"(p."PR_NAM_Föreställning_Namn", NEW."PR_NAM_Föreställning_Namn")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn_Annex" a
        WHERE
            a."PR_NAM_ID" = _posit
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Föreställning_Namn for: %', concat_ws(', ', NEW."PR_NAM_PR_ID",
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn_Posit" p
        JOIN
            attributes."PR_NAM_Föreställning_Namn_Annex" a
        ON
            a."PR_NAM_ID" = p."PR_NAM_ID"
        WHERE
            p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            NOT attributes."eq_PR_NAM_Föreställning_Namn"(p."PR_NAM_Föreställning_Namn", NEW."PR_NAM_Föreställning_Namn")
        AND
            a."PR_NAM_PositedAt" = _positing
        AND
            a."PR_NAM_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_NAM_Föreställning_Namn for: %', concat_ws(', ', NEW."PR_NAM_PR_ID",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_NAM_Föreställning_Namn_Annex" a
        WHERE
            a."PR_NAM_ID" = _posit
        AND
            a."PR_NAM_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."PR_NAM_Reliability" = 1
            FROM
                attributes."PR_NAM_Föreställning_Namn_Annex" a
            WHERE
                a."PR_NAM_ID" = _posit
            AND
                a."PR_NAM_PositedAt" <= _positing
            ORDER BY
                a."PR_NAM_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."PR_NAM_Föreställning_Namn_Annex" (
            "Metadata_PR_NAM",
            "PR_NAM_ID",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", 0),
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
            p."PR_NAM_ID"
        FROM
            attributes."PR_NAM_Föreställning_Namn_Posit" p
        WHERE
            p."PR_NAM_PR_ID" = NEW."PR_NAM_PR_ID"
        AND
            NOT attributes."eq_PR_NAM_Föreställning_Namn"(p."PR_NAM_Föreställning_Namn", NEW."PR_NAM_Föreställning_Namn")
        AND
            coalesce((
                SELECT
                    a."PR_NAM_Reliability" = 1
                FROM
                    attributes."PR_NAM_Föreställning_Namn_Annex" a
                WHERE
                    a."PR_NAM_ID" = p."PR_NAM_ID"
                AND
                    a."PR_NAM_PositedAt" <= _positing
                ORDER BY
                    a."PR_NAM_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."PR_NAM_Föreställning_Namn_Annex" (
            "Metadata_PR_NAM",
            "PR_NAM_ID",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."PR_NAM_Föreställning_Namn_Posit" (
            "PR_NAM_PR_ID",
            "PR_NAM_Föreställning_Namn"
        )
        VALUES (
            NEW."PR_NAM_PR_ID",
            NEW."PR_NAM_Föreställning_Namn"
        )
        RETURNING "PR_NAM_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."PR_NAM_Föreställning_Namn_Annex" (
        "Metadata_PR_NAM",
        "PR_NAM_ID",
        "PR_NAM_PositedAt",
        "PR_NAM_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_PR_NAM", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_NAM_Föreställning_Namn" ON attributes."PR_NAM_Föreställning_Namn";
CREATE TRIGGER "it_PR_NAM_Föreställning_Namn"
INSTEAD OF INSERT ON attributes."PR_NAM_Föreställning_Namn"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_NAM_Föreställning_Namn"();
-- Equality of two values -----------------------------------------------------------------------------------------------
-- eq_PR_LEN_Föreställning_Längd tells whether two values of PR_LEN_Föreställning_Längd are the same (by checksum, if it has one)
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."eq_PR_LEN_Föreställning_Längd"(
    l time,
    r time
)
RETURNS boolean
AS
$$
    SELECT l = r
$$ LANGUAGE sql IMMUTABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_LEN_Föreställning_Längd instead of INSERT trigger on PR_LEN_Föreställning_Längd
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION attributes."it_PR_LEN_Föreställning_Längd"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _reliability decimal(5,2);
    _changing date;
    _posit integer;
    _other integer;
    _following integer;
BEGIN
    _positing := coalesce(NEW."PR_LEN_PositedAt", _now);
    _reliability := coalesce(NEW."PR_LEN_Reliability", 1);
    _changing := coalesce(NEW."PR_LEN_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."PR_LEN_ID"
    INTO
        _posit
    FROM
        attributes."PR_LEN_Föreställning_Längd_Posit" p
    WHERE
        p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        p."PR_LEN_ChangedAt" = _changing
    AND
        attributes."eq_PR_LEN_Föreställning_Längd"(p."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction, and so, since
    -- one posit at a time is asserted, is an assertion of another value at that time
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd_Annex" a
        WHERE
            a."PR_LEN_ID" = _posit
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Föreställning_Längd for: %', concat_ws(', ', NEW."PR_LEN_PR_ID",
            _changing,
            _positing);
    END IF;
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd_Posit" p
        JOIN
            attributes."PR_LEN_Föreställning_Längd_Annex" a
        ON
            a."PR_LEN_ID" = p."PR_LEN_ID"
        WHERE
            p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT attributes."eq_PR_LEN_Föreställning_Längd"(p."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
        AND
            a."PR_LEN_PositedAt" = _positing
        AND
            a."PR_LEN_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_LEN_Föreställning_Längd for: %', concat_ws(', ', NEW."PR_LEN_PR_ID",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            attributes."PR_LEN_Föreställning_Längd_Annex" a
        WHERE
            a."PR_LEN_ID" = _posit
        AND
            a."PR_LEN_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    -- whether the posit is asserted at the positing time
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT coalesce((
            SELECT
                a."PR_LEN_Reliability" = 1
            FROM
                attributes."PR_LEN_Föreställning_Längd_Annex" a
            WHERE
                a."PR_LEN_ID" = _posit
            AND
                a."PR_LEN_PositedAt" <= _positing
            ORDER BY
                a."PR_LEN_PositedAt" DESC
            LIMIT 1
        ), false) THEN
            RETURN NULL;
        END IF;
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
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
            p."PR_LEN_ID"
        FROM
            attributes."PR_LEN_Föreställning_Längd_Posit" p
        WHERE
            p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
        AND
            p."PR_LEN_ChangedAt" = _changing
        AND
            NOT attributes."eq_PR_LEN_Föreställning_Längd"(p."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
        AND
            coalesce((
                SELECT
                    a."PR_LEN_Reliability" = 1
                FROM
                    attributes."PR_LEN_Föreställning_Längd_Annex" a
                WHERE
                    a."PR_LEN_ID" = p."PR_LEN_ID"
                AND
                    a."PR_LEN_PositedAt" <= _positing
                ORDER BY
                    a."PR_LEN_PositedAt" DESC
                LIMIT 1
            ), false)
    LOOP
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
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
                p."PR_LEN_Föreställning_Längd"
            FROM
                attributes."PR_LEN_Föreställning_Längd_Posit" p
            WHERE
                p."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
            AND
                p."PR_LEN_ChangedAt" < _changing
            AND
                coalesce((
                    SELECT
                        a."PR_LEN_Reliability" = 1
                    FROM
                        attributes."PR_LEN_Föreställning_Längd_Annex" a
                    WHERE
                        a."PR_LEN_ID" = p."PR_LEN_ID"
                    AND
                        a."PR_LEN_PositedAt" <= _positing
                    ORDER BY
                        a."PR_LEN_PositedAt" DESC
                    LIMIT 1
                ), false)
            ORDER BY
                p."PR_LEN_ChangedAt" DESC
            LIMIT 1
        ) pre
        WHERE
            attributes."eq_PR_LEN_Föreställning_Längd"(pre."PR_LEN_Föreställning_Längd", NEW."PR_LEN_Föreställning_Längd")
    ) THEN
        -- (an idempotent attribute does not store it)
        RETURN NULL;
    END IF;
    -- the same value as the version after it makes that version a restatement
    SELECT
        f."PR_LEN_ID"
    INTO
        _following
    FROM
        attributes."PR_LEN_Föreställning_Längd_Posit" f
    WHERE
        f."PR_LEN_PR_ID" = NEW."PR_LEN_PR_ID"
    AND
        f."PR_LEN_ChangedAt" > _changing
    AND
        coalesce((
            SELECT
                a."PR_LEN_Reliability" = 1
            FROM
                attributes."PR_LEN_Föreställning_Längd_Annex" a
            WHERE
                a."PR_LEN_ID" = f."PR_LEN_ID"
            AND
                a."PR_LEN_PositedAt" <= _positing
            ORDER BY
                a."PR_LEN_PositedAt" DESC
            LIMIT 1
        ), false)
    ORDER BY
        f."PR_LEN_ChangedAt" ASC
    LIMIT 1;
    IF _following IS NOT NULL AND attributes."eq_PR_LEN_Föreställning_Längd"((
        SELECT x."PR_LEN_Föreställning_Längd" FROM attributes."PR_LEN_Föreställning_Längd_Posit" x WHERE x."PR_LEN_ID" = _following
    ), NEW."PR_LEN_Föreställning_Längd") THEN
        -- (an idempotent attribute retracts it)
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
            "Metadata_PR_LEN",
            "PR_LEN_ID",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", 0),
            _following,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO attributes."PR_LEN_Föreställning_Längd_Posit" (
            "PR_LEN_PR_ID",
            "PR_LEN_ChangedAt",
            "PR_LEN_Föreställning_Längd"
        )
        VALUES (
            NEW."PR_LEN_PR_ID",
            _changing,
            NEW."PR_LEN_Föreställning_Längd"
        )
        RETURNING "PR_LEN_ID" INTO _posit;
    END IF;
    INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
        "Metadata_PR_LEN",
        "PR_LEN_ID",
        "PR_LEN_PositedAt",
        "PR_LEN_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_PR_LEN", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_LEN_Föreställning_Längd" ON attributes."PR_LEN_Föreställning_Längd";
CREATE TRIGGER "it_PR_LEN_Föreställning_Längd"
INSTEAD OF INSERT ON attributes."PR_LEN_Föreställning_Längd"
FOR EACH ROW EXECUTE FUNCTION attributes."it_PR_LEN_Föreställning_Längd"();
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
-- it_lST_Scen instead of INSERT trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lST_Scen"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id integer;
    _AVG smallint;
    _MIN smallint;
BEGIN
    _id := NEW."ST_ID";
    IF _id IS NULL THEN
        INSERT INTO anchors."ST_Scen" (
            "Metadata_ST"
        )
        VALUES (
            NEW."Metadata_ST"
        )
        RETURNING "ST_ID" INTO _id;
    END IF;
    IF NEW."ST_NAM_Scen_Namn" IS NOT NULL THEN
        INSERT INTO attributes."ST_NAM_Scen_Namn" (
            "Metadata_ST_NAM",
            "ST_NAM_ST_ID",
            "ST_NAM_Scen_Namn",
            "ST_NAM_ChangedAt",
            "ST_NAM_PositedAt",
            "ST_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_NAM", NEW."Metadata_ST"),
            coalesce(NEW."ST_NAM_ST_ID", _id),
            NEW."ST_NAM_Scen_Namn",
            coalesce(NEW."ST_NAM_ChangedAt", _now),
            coalesce(NEW."ST_NAM_PositedAt", _now),
            coalesce(NEW."ST_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."ST_LOC_Scen_Plats" IS NOT NULL THEN
        INSERT INTO attributes."ST_LOC_Scen_Plats" (
            "Metadata_ST_LOC",
            "ST_LOC_ST_ID",
            "ST_LOC_Scen_Plats",
            "ST_LOC_PositedAt",
            "ST_LOC_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_LOC", NEW."Metadata_ST"),
            coalesce(NEW."ST_LOC_ST_ID", _id),
            NEW."ST_LOC_Scen_Plats",
            coalesce(NEW."ST_LOC_PositedAt", _now),
            coalesce(NEW."ST_LOC_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _AVG := NEW."ST_AVG_UTL_ID";
    IF _AVG IS NULL AND NEW."ST_AVG_UTL_Utnyttjande" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _AVG
        FROM
            knots."UTL_Utnyttjande" k
        WHERE
            k."UTL_Utnyttjande" = NEW."ST_AVG_UTL_Utnyttjande"
        LIMIT 1;
    END IF;
    IF _AVG IS NOT NULL THEN
        INSERT INTO attributes."ST_AVG_Scen_Medel" (
            "Metadata_ST_AVG",
            "ST_AVG_ST_ID",
            "ST_AVG_UTL_ID",
            "ST_AVG_ChangedAt",
            "ST_AVG_PositedAt",
            "ST_AVG_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_AVG", NEW."Metadata_ST"),
            coalesce(NEW."ST_AVG_ST_ID", _id),
            _AVG,
            coalesce(NEW."ST_AVG_ChangedAt", _now),
            coalesce(NEW."ST_AVG_PositedAt", _now),
            coalesce(NEW."ST_AVG_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _MIN := NEW."ST_MIN_UTL_ID";
    IF _MIN IS NULL AND NEW."ST_MIN_UTL_Utnyttjande" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _MIN
        FROM
            knots."UTL_Utnyttjande" k
        WHERE
            k."UTL_Utnyttjande" = NEW."ST_MIN_UTL_Utnyttjande"
        LIMIT 1;
    END IF;
    IF _MIN IS NOT NULL THEN
        INSERT INTO attributes."ST_MIN_Scen_Minimum" (
            "Metadata_ST_MIN",
            "ST_MIN_ST_ID",
            "ST_MIN_UTL_ID",
            "ST_MIN_PositedAt",
            "ST_MIN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_MIN", NEW."Metadata_ST"),
            coalesce(NEW."ST_MIN_ST_ID", _id),
            _MIN,
            coalesce(NEW."ST_MIN_PositedAt", _now),
            coalesce(NEW."ST_MIN_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lST_Scen" ON anchors."lST_Scen";
CREATE TRIGGER "it_lST_Scen"
INSTEAD OF INSERT ON anchors."lST_Scen"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lST_Scen"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lST_Scen instead of UPDATE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lST_Scen"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _AVG smallint;
    _MIN smallint;
BEGIN
    IF NEW."ST_ID" IS DISTINCT FROM OLD."ST_ID" THEN
        RAISE EXCEPTION 'The identity column ST_ID is not updatable.';
    END IF;
    IF NEW."ST_NAM_ID" IS DISTINCT FROM OLD."ST_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column ST_NAM_ID is not updatable.';
    END IF;
    IF NEW."ST_NAM_ST_ID" IS DISTINCT FROM OLD."ST_NAM_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_NAM_ST_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_NAM_Scen_Namn, and when it posits
    _reliability := CASE
        WHEN NEW."ST_NAM_Reliability" IS DISTINCT FROM OLD."ST_NAM_Reliability" THEN NEW."ST_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_NAM_Reliability"
    END;
    _positing := CASE
        WHEN NEW."ST_NAM_PositedAt" IS DISTINCT FROM OLD."ST_NAM_PositedAt" THEN NEW."ST_NAM_PositedAt"
        WHEN NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" AND NEW."ST_NAM_Scen_Namn" IS NULL THEN NEW."ST_NAM_ChangedAt"
        ELSE _now
    END;
    IF NEW."ST_NAM_Scen_Namn" IS DISTINCT FROM OLD."ST_NAM_Scen_Namn"
    OR NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt"
    OR NEW."ST_NAM_PositedAt" IS DISTINCT FROM OLD."ST_NAM_PositedAt"
    OR NEW."ST_NAM_Reliability" IS DISTINCT FROM OLD."ST_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."ST_NAM_Scen_Namn" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."ST_NAM_Scen_Namn" IS NULL
            OR NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt"
            OR NEW."ST_NAM_PositedAt" IS DISTINCT FROM OLD."ST_NAM_PositedAt"
            OR OLD."ST_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."ST_NAM_Scen_Namn" <> NEW."ST_NAM_Scen_Namn"
            THEN
                INSERT INTO attributes."ST_NAM_Scen_Namn" (
                    "Metadata_ST_NAM",
                    "ST_NAM_ST_ID",
                    "ST_NAM_Scen_Namn",
                    "ST_NAM_ChangedAt",
                    "ST_NAM_PositedAt",
                    "ST_NAM_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                             AND NEW."Metadata_ST_NAM" IS NOT DISTINCT FROM OLD."Metadata_ST_NAM"
                            THEN NEW."Metadata_ST"
                            ELSE NEW."Metadata_ST_NAM"
                        END, NEW."Metadata_ST"),
                    coalesce(NEW."ST_NAM_ST_ID", NEW."ST_ID"),
                    NEW."ST_NAM_Scen_Namn",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."ST_NAM_ChangedAt" IS DISTINCT FROM OLD."ST_NAM_ChangedAt" THEN NEW."ST_NAM_ChangedAt"
                        WHEN OLD."ST_NAM_Scen_Namn" = NEW."ST_NAM_Scen_Namn" THEN NEW."ST_NAM_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."ST_NAM_Scen_Namn" IS NULL AND OLD."ST_NAM_Scen_Namn" IS NOT NULL THEN
            INSERT INTO attributes."ST_NAM_Scen_Namn" (
                "Metadata_ST_NAM",
                "ST_NAM_ST_ID",
                "ST_NAM_Scen_Namn",
                "ST_NAM_ChangedAt",
                "ST_NAM_PositedAt",
                "ST_NAM_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_NAM" IS NOT DISTINCT FROM OLD."Metadata_ST_NAM"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_NAM"
                    END, NEW."Metadata_ST"),
                p."ST_NAM_ST_ID",
                p."ST_NAM_Scen_Namn",
                p."ST_NAM_ChangedAt",
                _positing,
                0
            FROM
                attributes."ST_NAM_Scen_Namn_Posit" p
            WHERE
                p."ST_NAM_ID" = OLD."ST_NAM_ID";
        END IF;
    END IF;
    IF NEW."ST_LOC_ID" IS DISTINCT FROM OLD."ST_LOC_ID" THEN
        RAISE EXCEPTION 'The identity column ST_LOC_ID is not updatable.';
    END IF;
    IF NEW."ST_LOC_ST_ID" IS DISTINCT FROM OLD."ST_LOC_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_LOC_ST_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_LOC_Scen_Plats, and when it posits
    _reliability := CASE
        WHEN NEW."ST_LOC_Reliability" IS DISTINCT FROM OLD."ST_LOC_Reliability" THEN NEW."ST_LOC_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_LOC_Reliability"
    END;
    _positing := CASE
        WHEN NEW."ST_LOC_PositedAt" IS DISTINCT FROM OLD."ST_LOC_PositedAt" THEN NEW."ST_LOC_PositedAt"
        ELSE _now
    END;
    IF NEW."ST_LOC_Scen_Plats" IS DISTINCT FROM OLD."ST_LOC_Scen_Plats"
    OR NEW."ST_LOC_PositedAt" IS DISTINCT FROM OLD."ST_LOC_PositedAt"
    OR NEW."ST_LOC_Reliability" IS DISTINCT FROM OLD."ST_LOC_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."ST_LOC_Scen_Plats" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."ST_LOC_Scen_Plats" IS NULL
            OR NEW."ST_LOC_PositedAt" IS DISTINCT FROM OLD."ST_LOC_PositedAt"
            OR OLD."ST_LOC_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR md5(OLD."ST_LOC_Scen_Plats"::text) <> md5(NEW."ST_LOC_Scen_Plats"::text)
            THEN
                INSERT INTO attributes."ST_LOC_Scen_Plats" (
                    "Metadata_ST_LOC",
                    "ST_LOC_ST_ID",
                    "ST_LOC_Scen_Plats",
                    "ST_LOC_PositedAt",
                    "ST_LOC_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                             AND NEW."Metadata_ST_LOC" IS NOT DISTINCT FROM OLD."Metadata_ST_LOC"
                            THEN NEW."Metadata_ST"
                            ELSE NEW."Metadata_ST_LOC"
                        END, NEW."Metadata_ST"),
                    coalesce(NEW."ST_LOC_ST_ID", NEW."ST_ID"),
                    NEW."ST_LOC_Scen_Plats",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."ST_LOC_Scen_Plats" IS NULL AND OLD."ST_LOC_Scen_Plats" IS NOT NULL THEN
            INSERT INTO attributes."ST_LOC_Scen_Plats" (
                "Metadata_ST_LOC",
                "ST_LOC_ST_ID",
                "ST_LOC_Scen_Plats",
                "ST_LOC_PositedAt",
                "ST_LOC_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_LOC" IS NOT DISTINCT FROM OLD."Metadata_ST_LOC"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_LOC"
                    END, NEW."Metadata_ST"),
                p."ST_LOC_ST_ID",
                p."ST_LOC_Scen_Plats",
                _positing,
                0
            FROM
                attributes."ST_LOC_Scen_Plats_Posit" p
            WHERE
                p."ST_LOC_ID" = OLD."ST_LOC_ID";
        END IF;
    END IF;
    IF NEW."ST_AVG_ID" IS DISTINCT FROM OLD."ST_AVG_ID" THEN
        RAISE EXCEPTION 'The identity column ST_AVG_ID is not updatable.';
    END IF;
    IF NEW."ST_AVG_ST_ID" IS DISTINCT FROM OLD."ST_AVG_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_AVG_ST_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_AVG_Scen_Medel, and when it posits
    _reliability := CASE
        WHEN NEW."ST_AVG_Reliability" IS DISTINCT FROM OLD."ST_AVG_Reliability" THEN NEW."ST_AVG_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_AVG_Reliability"
    END;
    _positing := CASE
        WHEN NEW."ST_AVG_PositedAt" IS DISTINCT FROM OLD."ST_AVG_PositedAt" THEN NEW."ST_AVG_PositedAt"
        WHEN NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" AND NEW."ST_AVG_UTL_ID" IS NULL THEN NEW."ST_AVG_ChangedAt"
        ELSE _now
    END;
    _AVG := NEW."ST_AVG_UTL_ID";
    IF _AVG IS NOT DISTINCT FROM OLD."ST_AVG_UTL_ID" AND NEW."ST_AVG_UTL_Utnyttjande" IS DISTINCT FROM OLD."ST_AVG_UTL_Utnyttjande" THEN
        _AVG := NULL;
        IF NEW."ST_AVG_UTL_Utnyttjande" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _AVG
            FROM
                knots."UTL_Utnyttjande" k
            WHERE
                k."UTL_Utnyttjande" = NEW."ST_AVG_UTL_Utnyttjande"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."ST_AVG_UTL_ID" IS DISTINCT FROM OLD."ST_AVG_UTL_ID"
    OR NEW."ST_AVG_UTL_Utnyttjande" IS DISTINCT FROM OLD."ST_AVG_UTL_Utnyttjande"
    OR NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt"
    OR NEW."ST_AVG_PositedAt" IS DISTINCT FROM OLD."ST_AVG_PositedAt"
    OR NEW."ST_AVG_Reliability" IS DISTINCT FROM OLD."ST_AVG_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _AVG IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."ST_AVG_UTL_ID" IS NULL
            OR NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt"
            OR NEW."ST_AVG_PositedAt" IS DISTINCT FROM OLD."ST_AVG_PositedAt"
            OR OLD."ST_AVG_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."ST_AVG_UTL_ID" <> _AVG
            THEN
                INSERT INTO attributes."ST_AVG_Scen_Medel" (
                    "Metadata_ST_AVG",
                    "ST_AVG_ST_ID",
                    "ST_AVG_UTL_ID",
                    "ST_AVG_ChangedAt",
                    "ST_AVG_PositedAt",
                    "ST_AVG_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                             AND NEW."Metadata_ST_AVG" IS NOT DISTINCT FROM OLD."Metadata_ST_AVG"
                            THEN NEW."Metadata_ST"
                            ELSE NEW."Metadata_ST_AVG"
                        END, NEW."Metadata_ST"),
                    coalesce(NEW."ST_AVG_ST_ID", NEW."ST_ID"),
                    _AVG,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."ST_AVG_ChangedAt" IS DISTINCT FROM OLD."ST_AVG_ChangedAt" THEN NEW."ST_AVG_ChangedAt"
                        WHEN OLD."ST_AVG_UTL_ID" = _AVG THEN NEW."ST_AVG_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."ST_AVG_UTL_ID" IS NOT NULL AND (
            NEW."ST_AVG_UTL_ID" IS NULL OR (
                NEW."ST_AVG_UTL_ID" = OLD."ST_AVG_UTL_ID"
                AND NEW."ST_AVG_UTL_Utnyttjande" IS NULL AND OLD."ST_AVG_UTL_Utnyttjande" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."ST_AVG_Scen_Medel" (
                "Metadata_ST_AVG",
                "ST_AVG_ST_ID",
                "ST_AVG_UTL_ID",
                "ST_AVG_ChangedAt",
                "ST_AVG_PositedAt",
                "ST_AVG_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_AVG" IS NOT DISTINCT FROM OLD."Metadata_ST_AVG"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_AVG"
                    END, NEW."Metadata_ST"),
                p."ST_AVG_ST_ID",
                p."ST_AVG_UTL_ID",
                p."ST_AVG_ChangedAt",
                _positing,
                0
            FROM
                attributes."ST_AVG_Scen_Medel_Posit" p
            WHERE
                p."ST_AVG_ID" = OLD."ST_AVG_ID";
        END IF;
    END IF;
    IF NEW."ST_MIN_ID" IS DISTINCT FROM OLD."ST_MIN_ID" THEN
        RAISE EXCEPTION 'The identity column ST_MIN_ID is not updatable.';
    END IF;
    IF NEW."ST_MIN_ST_ID" IS DISTINCT FROM OLD."ST_MIN_ST_ID" THEN
        RAISE EXCEPTION 'The foreign key column ST_MIN_ST_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of ST_MIN_Scen_Minimum, and when it posits
    _reliability := CASE
        WHEN NEW."ST_MIN_Reliability" IS DISTINCT FROM OLD."ST_MIN_Reliability" THEN NEW."ST_MIN_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."ST_MIN_Reliability"
    END;
    _positing := CASE
        WHEN NEW."ST_MIN_PositedAt" IS DISTINCT FROM OLD."ST_MIN_PositedAt" THEN NEW."ST_MIN_PositedAt"
        ELSE _now
    END;
    _MIN := NEW."ST_MIN_UTL_ID";
    IF _MIN IS NOT DISTINCT FROM OLD."ST_MIN_UTL_ID" AND NEW."ST_MIN_UTL_Utnyttjande" IS DISTINCT FROM OLD."ST_MIN_UTL_Utnyttjande" THEN
        _MIN := NULL;
        IF NEW."ST_MIN_UTL_Utnyttjande" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _MIN
            FROM
                knots."UTL_Utnyttjande" k
            WHERE
                k."UTL_Utnyttjande" = NEW."ST_MIN_UTL_Utnyttjande"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."ST_MIN_UTL_ID" IS DISTINCT FROM OLD."ST_MIN_UTL_ID"
    OR NEW."ST_MIN_UTL_Utnyttjande" IS DISTINCT FROM OLD."ST_MIN_UTL_Utnyttjande"
    OR NEW."ST_MIN_PositedAt" IS DISTINCT FROM OLD."ST_MIN_PositedAt"
    OR NEW."ST_MIN_Reliability" IS DISTINCT FROM OLD."ST_MIN_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _MIN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."ST_MIN_UTL_ID" IS NULL
            OR NEW."ST_MIN_PositedAt" IS DISTINCT FROM OLD."ST_MIN_PositedAt"
            OR OLD."ST_MIN_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."ST_MIN_UTL_ID" <> _MIN
            THEN
                INSERT INTO attributes."ST_MIN_Scen_Minimum" (
                    "Metadata_ST_MIN",
                    "ST_MIN_ST_ID",
                    "ST_MIN_UTL_ID",
                    "ST_MIN_PositedAt",
                    "ST_MIN_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                             AND NEW."Metadata_ST_MIN" IS NOT DISTINCT FROM OLD."Metadata_ST_MIN"
                            THEN NEW."Metadata_ST"
                            ELSE NEW."Metadata_ST_MIN"
                        END, NEW."Metadata_ST"),
                    coalesce(NEW."ST_MIN_ST_ID", NEW."ST_ID"),
                    _MIN,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."ST_MIN_UTL_ID" IS NOT NULL AND (
            NEW."ST_MIN_UTL_ID" IS NULL OR (
                NEW."ST_MIN_UTL_ID" = OLD."ST_MIN_UTL_ID"
                AND NEW."ST_MIN_UTL_Utnyttjande" IS NULL AND OLD."ST_MIN_UTL_Utnyttjande" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."ST_MIN_Scen_Minimum" (
                "Metadata_ST_MIN",
                "ST_MIN_ST_ID",
                "ST_MIN_UTL_ID",
                "ST_MIN_PositedAt",
                "ST_MIN_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_ST" IS DISTINCT FROM OLD."Metadata_ST"
                         AND NEW."Metadata_ST_MIN" IS NOT DISTINCT FROM OLD."Metadata_ST_MIN"
                        THEN NEW."Metadata_ST"
                        ELSE NEW."Metadata_ST_MIN"
                    END, NEW."Metadata_ST"),
                p."ST_MIN_ST_ID",
                p."ST_MIN_UTL_ID",
                _positing,
                0
            FROM
                attributes."ST_MIN_Scen_Minimum_Posit" p
            WHERE
                p."ST_MIN_ID" = OLD."ST_MIN_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lST_Scen" ON anchors."lST_Scen";
CREATE TRIGGER "ut_lST_Scen"
INSTEAD OF UPDATE ON anchors."lST_Scen"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lST_Scen"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_Scen instead of DELETE trigger on lST_Scen
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lST_Scen"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of ST_NAM_Scen_Namn is retracted
    INSERT INTO attributes."ST_NAM_Scen_Namn_Annex" (
        "Metadata_ST_NAM",
        "ST_NAM_ID",
        "ST_NAM_PositedAt",
        "ST_NAM_Reliability"
    )
    SELECT
        OLD."Metadata_ST_NAM",
        OLD."ST_NAM_ID",
        _now,
        0
    WHERE
        OLD."ST_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of ST_LOC_Scen_Plats is retracted
    INSERT INTO attributes."ST_LOC_Scen_Plats_Annex" (
        "Metadata_ST_LOC",
        "ST_LOC_ID",
        "ST_LOC_PositedAt",
        "ST_LOC_Reliability"
    )
    SELECT
        OLD."Metadata_ST_LOC",
        OLD."ST_LOC_ID",
        _now,
        0
    WHERE
        OLD."ST_LOC_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of ST_AVG_Scen_Medel is retracted
    INSERT INTO attributes."ST_AVG_Scen_Medel_Annex" (
        "Metadata_ST_AVG",
        "ST_AVG_ID",
        "ST_AVG_PositedAt",
        "ST_AVG_Reliability"
    )
    SELECT
        OLD."Metadata_ST_AVG",
        OLD."ST_AVG_ID",
        _now,
        0
    WHERE
        OLD."ST_AVG_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of ST_MIN_Scen_Minimum is retracted
    INSERT INTO attributes."ST_MIN_Scen_Minimum_Annex" (
        "Metadata_ST_MIN",
        "ST_MIN_ID",
        "ST_MIN_PositedAt",
        "ST_MIN_Reliability"
    )
    SELECT
        OLD."Metadata_ST_MIN",
        OLD."ST_MIN_ID",
        _now,
        0
    WHERE
        OLD."ST_MIN_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_Scen" ON anchors."lST_Scen";
CREATE TRIGGER "dt_lST_Scen"
INSTEAD OF DELETE ON anchors."lST_Scen"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lST_Scen"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_Skådespelare instead of INSERT trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lAC_Skådespelare"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id smallint;
    _GEN smallint;
    _PLV smallint;
BEGIN
    _id := NEW."AC_ID";
    IF _id IS NULL THEN
        INSERT INTO anchors."AC_Skådespelare" (
            "Metadata_AC"
        )
        VALUES (
            NEW."Metadata_AC"
        )
        RETURNING "AC_ID" INTO _id;
    END IF;
    IF NEW."AC_NAM_Skådespelare_Namn" IS NOT NULL THEN
        INSERT INTO attributes."AC_NAM_Skådespelare_Namn" (
            "Metadata_AC_NAM",
            "AC_NAM_AC_ID",
            "AC_NAM_Skådespelare_Namn",
            "AC_NAM_ChangedAt",
            "AC_NAM_PositedAt",
            "AC_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_NAM", NEW."Metadata_AC"),
            coalesce(NEW."AC_NAM_AC_ID", _id),
            NEW."AC_NAM_Skådespelare_Namn",
            coalesce(NEW."AC_NAM_ChangedAt", _now),
            coalesce(NEW."AC_NAM_PositedAt", _now),
            coalesce(NEW."AC_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _GEN := NEW."AC_GEN_GEN_ID";
    IF _GEN IS NULL AND NEW."AC_GEN_GEN_Kön" IS NOT NULL THEN
        SELECT
            k."GEN_ID"
        INTO
            _GEN
        FROM
            knots."GEN_Kön" k
        WHERE
            k."GEN_Checksum" = decode(md5(NEW."AC_GEN_GEN_Kön"::text), 'hex')
        LIMIT 1;
    END IF;
    IF _GEN IS NOT NULL THEN
        INSERT INTO attributes."AC_GEN_Skådespelare_Kön" (
            "Metadata_AC_GEN",
            "AC_GEN_AC_ID",
            "AC_GEN_GEN_ID",
            "AC_GEN_PositedAt",
            "AC_GEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_GEN", NEW."Metadata_AC"),
            coalesce(NEW."AC_GEN_AC_ID", _id),
            _GEN,
            coalesce(NEW."AC_GEN_PositedAt", _now),
            coalesce(NEW."AC_GEN_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _PLV := NEW."AC_PLV_PLV_ID";
    IF _PLV IS NULL AND NEW."AC_PLV_PLV_Yrkesnivå" IS NOT NULL THEN
        SELECT
            k."PLV_ID"
        INTO
            _PLV
        FROM
            knots."PLV_Yrkesnivå" k
        WHERE
            k."PLV_Checksum" = decode(md5(NEW."AC_PLV_PLV_Yrkesnivå"::text), 'hex')
        LIMIT 1;
    END IF;
    IF _PLV IS NOT NULL THEN
        INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå" (
            "Metadata_AC_PLV",
            "AC_PLV_AC_ID",
            "AC_PLV_PLV_ID",
            "AC_PLV_ChangedAt",
            "AC_PLV_PositedAt",
            "AC_PLV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_PLV", NEW."Metadata_AC"),
            coalesce(NEW."AC_PLV_AC_ID", _id),
            _PLV,
            coalesce(NEW."AC_PLV_ChangedAt", _now),
            coalesce(NEW."AC_PLV_PositedAt", _now),
            coalesce(NEW."AC_PLV_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_Skådespelare" ON anchors."lAC_Skådespelare";
CREATE TRIGGER "it_lAC_Skådespelare"
INSTEAD OF INSERT ON anchors."lAC_Skådespelare"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lAC_Skådespelare"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_Skådespelare instead of UPDATE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lAC_Skådespelare"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _GEN smallint;
    _PLV smallint;
BEGIN
    IF NEW."AC_ID" IS DISTINCT FROM OLD."AC_ID" THEN
        RAISE EXCEPTION 'The identity column AC_ID is not updatable.';
    END IF;
    IF NEW."AC_NAM_ID" IS DISTINCT FROM OLD."AC_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column AC_NAM_ID is not updatable.';
    END IF;
    IF NEW."AC_NAM_AC_ID" IS DISTINCT FROM OLD."AC_NAM_AC_ID" THEN
        RAISE EXCEPTION 'The foreign key column AC_NAM_AC_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of AC_NAM_Skådespelare_Namn, and when it posits
    _reliability := CASE
        WHEN NEW."AC_NAM_Reliability" IS DISTINCT FROM OLD."AC_NAM_Reliability" THEN NEW."AC_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."AC_NAM_Reliability"
    END;
    _positing := CASE
        WHEN NEW."AC_NAM_PositedAt" IS DISTINCT FROM OLD."AC_NAM_PositedAt" THEN NEW."AC_NAM_PositedAt"
        WHEN NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" AND NEW."AC_NAM_Skådespelare_Namn" IS NULL THEN NEW."AC_NAM_ChangedAt"
        ELSE _now
    END;
    IF NEW."AC_NAM_Skådespelare_Namn" IS DISTINCT FROM OLD."AC_NAM_Skådespelare_Namn"
    OR NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt"
    OR NEW."AC_NAM_PositedAt" IS DISTINCT FROM OLD."AC_NAM_PositedAt"
    OR NEW."AC_NAM_Reliability" IS DISTINCT FROM OLD."AC_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."AC_NAM_Skådespelare_Namn" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."AC_NAM_Skådespelare_Namn" IS NULL
            OR NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt"
            OR NEW."AC_NAM_PositedAt" IS DISTINCT FROM OLD."AC_NAM_PositedAt"
            OR OLD."AC_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."AC_NAM_Skådespelare_Namn" <> NEW."AC_NAM_Skådespelare_Namn"
            THEN
                INSERT INTO attributes."AC_NAM_Skådespelare_Namn" (
                    "Metadata_AC_NAM",
                    "AC_NAM_AC_ID",
                    "AC_NAM_Skådespelare_Namn",
                    "AC_NAM_ChangedAt",
                    "AC_NAM_PositedAt",
                    "AC_NAM_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                             AND NEW."Metadata_AC_NAM" IS NOT DISTINCT FROM OLD."Metadata_AC_NAM"
                            THEN NEW."Metadata_AC"
                            ELSE NEW."Metadata_AC_NAM"
                        END, NEW."Metadata_AC"),
                    coalesce(NEW."AC_NAM_AC_ID", NEW."AC_ID"),
                    NEW."AC_NAM_Skådespelare_Namn",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."AC_NAM_ChangedAt" IS DISTINCT FROM OLD."AC_NAM_ChangedAt" THEN NEW."AC_NAM_ChangedAt"
                        WHEN OLD."AC_NAM_Skådespelare_Namn" = NEW."AC_NAM_Skådespelare_Namn" THEN NEW."AC_NAM_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."AC_NAM_Skådespelare_Namn" IS NULL AND OLD."AC_NAM_Skådespelare_Namn" IS NOT NULL THEN
            INSERT INTO attributes."AC_NAM_Skådespelare_Namn" (
                "Metadata_AC_NAM",
                "AC_NAM_AC_ID",
                "AC_NAM_Skådespelare_Namn",
                "AC_NAM_ChangedAt",
                "AC_NAM_PositedAt",
                "AC_NAM_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                         AND NEW."Metadata_AC_NAM" IS NOT DISTINCT FROM OLD."Metadata_AC_NAM"
                        THEN NEW."Metadata_AC"
                        ELSE NEW."Metadata_AC_NAM"
                    END, NEW."Metadata_AC"),
                p."AC_NAM_AC_ID",
                p."AC_NAM_Skådespelare_Namn",
                p."AC_NAM_ChangedAt",
                _positing,
                0
            FROM
                attributes."AC_NAM_Skådespelare_Namn_Posit" p
            WHERE
                p."AC_NAM_ID" = OLD."AC_NAM_ID";
        END IF;
    END IF;
    IF NEW."AC_GEN_ID" IS DISTINCT FROM OLD."AC_GEN_ID" THEN
        RAISE EXCEPTION 'The identity column AC_GEN_ID is not updatable.';
    END IF;
    IF NEW."AC_GEN_AC_ID" IS DISTINCT FROM OLD."AC_GEN_AC_ID" THEN
        RAISE EXCEPTION 'The foreign key column AC_GEN_AC_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of AC_GEN_Skådespelare_Kön, and when it posits
    _reliability := CASE
        WHEN NEW."AC_GEN_Reliability" IS DISTINCT FROM OLD."AC_GEN_Reliability" THEN NEW."AC_GEN_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."AC_GEN_Reliability"
    END;
    _positing := CASE
        WHEN NEW."AC_GEN_PositedAt" IS DISTINCT FROM OLD."AC_GEN_PositedAt" THEN NEW."AC_GEN_PositedAt"
        ELSE _now
    END;
    _GEN := NEW."AC_GEN_GEN_ID";
    IF _GEN IS NOT DISTINCT FROM OLD."AC_GEN_GEN_ID" AND NEW."AC_GEN_GEN_Kön" IS DISTINCT FROM OLD."AC_GEN_GEN_Kön" THEN
        _GEN := NULL;
        IF NEW."AC_GEN_GEN_Kön" IS NOT NULL THEN
            SELECT
                k."GEN_ID"
            INTO
                _GEN
            FROM
                knots."GEN_Kön" k
            WHERE
                k."GEN_Checksum" = decode(md5(NEW."AC_GEN_GEN_Kön"::text), 'hex')
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."AC_GEN_GEN_ID" IS DISTINCT FROM OLD."AC_GEN_GEN_ID"
    OR NEW."AC_GEN_GEN_Kön" IS DISTINCT FROM OLD."AC_GEN_GEN_Kön"
    OR NEW."AC_GEN_PositedAt" IS DISTINCT FROM OLD."AC_GEN_PositedAt"
    OR NEW."AC_GEN_Reliability" IS DISTINCT FROM OLD."AC_GEN_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _GEN IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."AC_GEN_GEN_ID" IS NULL
            OR NEW."AC_GEN_PositedAt" IS DISTINCT FROM OLD."AC_GEN_PositedAt"
            OR OLD."AC_GEN_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."AC_GEN_GEN_ID" <> _GEN
            THEN
                INSERT INTO attributes."AC_GEN_Skådespelare_Kön" (
                    "Metadata_AC_GEN",
                    "AC_GEN_AC_ID",
                    "AC_GEN_GEN_ID",
                    "AC_GEN_PositedAt",
                    "AC_GEN_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                             AND NEW."Metadata_AC_GEN" IS NOT DISTINCT FROM OLD."Metadata_AC_GEN"
                            THEN NEW."Metadata_AC"
                            ELSE NEW."Metadata_AC_GEN"
                        END, NEW."Metadata_AC"),
                    coalesce(NEW."AC_GEN_AC_ID", NEW."AC_ID"),
                    _GEN,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."AC_GEN_GEN_ID" IS NOT NULL AND (
            NEW."AC_GEN_GEN_ID" IS NULL OR (
                NEW."AC_GEN_GEN_ID" = OLD."AC_GEN_GEN_ID"
                AND NEW."AC_GEN_GEN_Kön" IS NULL AND OLD."AC_GEN_GEN_Kön" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."AC_GEN_Skådespelare_Kön" (
                "Metadata_AC_GEN",
                "AC_GEN_AC_ID",
                "AC_GEN_GEN_ID",
                "AC_GEN_PositedAt",
                "AC_GEN_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                         AND NEW."Metadata_AC_GEN" IS NOT DISTINCT FROM OLD."Metadata_AC_GEN"
                        THEN NEW."Metadata_AC"
                        ELSE NEW."Metadata_AC_GEN"
                    END, NEW."Metadata_AC"),
                p."AC_GEN_AC_ID",
                p."AC_GEN_GEN_ID",
                _positing,
                0
            FROM
                attributes."AC_GEN_Skådespelare_Kön_Posit" p
            WHERE
                p."AC_GEN_ID" = OLD."AC_GEN_ID";
        END IF;
    END IF;
    IF NEW."AC_PLV_ID" IS DISTINCT FROM OLD."AC_PLV_ID" THEN
        RAISE EXCEPTION 'The identity column AC_PLV_ID is not updatable.';
    END IF;
    IF NEW."AC_PLV_AC_ID" IS DISTINCT FROM OLD."AC_PLV_AC_ID" THEN
        RAISE EXCEPTION 'The foreign key column AC_PLV_AC_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of AC_PLV_Skådespelare_Yrkesnivå, and when it posits
    _reliability := CASE
        WHEN NEW."AC_PLV_Reliability" IS DISTINCT FROM OLD."AC_PLV_Reliability" THEN NEW."AC_PLV_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."AC_PLV_Reliability"
    END;
    _positing := CASE
        WHEN NEW."AC_PLV_PositedAt" IS DISTINCT FROM OLD."AC_PLV_PositedAt" THEN NEW."AC_PLV_PositedAt"
        WHEN NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt" AND NEW."AC_PLV_PLV_ID" IS NULL THEN NEW."AC_PLV_ChangedAt"
        ELSE _now
    END;
    _PLV := NEW."AC_PLV_PLV_ID";
    IF _PLV IS NOT DISTINCT FROM OLD."AC_PLV_PLV_ID" AND NEW."AC_PLV_PLV_Yrkesnivå" IS DISTINCT FROM OLD."AC_PLV_PLV_Yrkesnivå" THEN
        _PLV := NULL;
        IF NEW."AC_PLV_PLV_Yrkesnivå" IS NOT NULL THEN
            SELECT
                k."PLV_ID"
            INTO
                _PLV
            FROM
                knots."PLV_Yrkesnivå" k
            WHERE
                k."PLV_Checksum" = decode(md5(NEW."AC_PLV_PLV_Yrkesnivå"::text), 'hex')
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."AC_PLV_PLV_ID" IS DISTINCT FROM OLD."AC_PLV_PLV_ID"
    OR NEW."AC_PLV_PLV_Yrkesnivå" IS DISTINCT FROM OLD."AC_PLV_PLV_Yrkesnivå"
    OR NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt"
    OR NEW."AC_PLV_PositedAt" IS DISTINCT FROM OLD."AC_PLV_PositedAt"
    OR NEW."AC_PLV_Reliability" IS DISTINCT FROM OLD."AC_PLV_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _PLV IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."AC_PLV_PLV_ID" IS NULL
            OR NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt"
            OR NEW."AC_PLV_PositedAt" IS DISTINCT FROM OLD."AC_PLV_PositedAt"
            OR OLD."AC_PLV_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."AC_PLV_PLV_ID" <> _PLV
            THEN
                INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå" (
                    "Metadata_AC_PLV",
                    "AC_PLV_AC_ID",
                    "AC_PLV_PLV_ID",
                    "AC_PLV_ChangedAt",
                    "AC_PLV_PositedAt",
                    "AC_PLV_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                             AND NEW."Metadata_AC_PLV" IS NOT DISTINCT FROM OLD."Metadata_AC_PLV"
                            THEN NEW."Metadata_AC"
                            ELSE NEW."Metadata_AC_PLV"
                        END, NEW."Metadata_AC"),
                    coalesce(NEW."AC_PLV_AC_ID", NEW."AC_ID"),
                    _PLV,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."AC_PLV_ChangedAt" IS DISTINCT FROM OLD."AC_PLV_ChangedAt" THEN NEW."AC_PLV_ChangedAt"
                        WHEN OLD."AC_PLV_PLV_ID" = _PLV THEN NEW."AC_PLV_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."AC_PLV_PLV_ID" IS NOT NULL AND (
            NEW."AC_PLV_PLV_ID" IS NULL OR (
                NEW."AC_PLV_PLV_ID" = OLD."AC_PLV_PLV_ID"
                AND NEW."AC_PLV_PLV_Yrkesnivå" IS NULL AND OLD."AC_PLV_PLV_Yrkesnivå" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå" (
                "Metadata_AC_PLV",
                "AC_PLV_AC_ID",
                "AC_PLV_PLV_ID",
                "AC_PLV_ChangedAt",
                "AC_PLV_PositedAt",
                "AC_PLV_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_AC" IS DISTINCT FROM OLD."Metadata_AC"
                         AND NEW."Metadata_AC_PLV" IS NOT DISTINCT FROM OLD."Metadata_AC_PLV"
                        THEN NEW."Metadata_AC"
                        ELSE NEW."Metadata_AC_PLV"
                    END, NEW."Metadata_AC"),
                p."AC_PLV_AC_ID",
                p."AC_PLV_PLV_ID",
                p."AC_PLV_ChangedAt",
                _positing,
                0
            FROM
                attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit" p
            WHERE
                p."AC_PLV_ID" = OLD."AC_PLV_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_Skådespelare" ON anchors."lAC_Skådespelare";
CREATE TRIGGER "ut_lAC_Skådespelare"
INSTEAD OF UPDATE ON anchors."lAC_Skådespelare"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lAC_Skådespelare"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_Skådespelare instead of DELETE trigger on lAC_Skådespelare
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lAC_Skådespelare"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of AC_NAM_Skådespelare_Namn is retracted
    INSERT INTO attributes."AC_NAM_Skådespelare_Namn_Annex" (
        "Metadata_AC_NAM",
        "AC_NAM_ID",
        "AC_NAM_PositedAt",
        "AC_NAM_Reliability"
    )
    SELECT
        OLD."Metadata_AC_NAM",
        OLD."AC_NAM_ID",
        _now,
        0
    WHERE
        OLD."AC_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of AC_GEN_Skådespelare_Kön is retracted
    INSERT INTO attributes."AC_GEN_Skådespelare_Kön_Annex" (
        "Metadata_AC_GEN",
        "AC_GEN_ID",
        "AC_GEN_PositedAt",
        "AC_GEN_Reliability"
    )
    SELECT
        OLD."Metadata_AC_GEN",
        OLD."AC_GEN_ID",
        _now,
        0
    WHERE
        OLD."AC_GEN_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of AC_PLV_Skådespelare_Yrkesnivå is retracted
    INSERT INTO attributes."AC_PLV_Skådespelare_Yrkesnivå_Annex" (
        "Metadata_AC_PLV",
        "AC_PLV_ID",
        "AC_PLV_PositedAt",
        "AC_PLV_Reliability"
    )
    SELECT
        OLD."Metadata_AC_PLV",
        OLD."AC_PLV_ID",
        _now,
        0
    WHERE
        OLD."AC_PLV_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_Skådespelare" ON anchors."lAC_Skådespelare";
CREATE TRIGGER "dt_lAC_Skådespelare"
INSTEAD OF DELETE ON anchors."lAC_Skådespelare"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lAC_Skådespelare"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_Föreställning instead of INSERT trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."it_lPR_Föreställning"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id bigint;
BEGIN
    _id := NEW."PR_ID";
    IF _id IS NULL THEN
        INSERT INTO anchors."PR_Föreställning" (
            "Metadata_PR"
        )
        VALUES (
            NEW."Metadata_PR"
        )
        RETURNING "PR_ID" INTO _id;
    END IF;
    IF NEW."PR_NAM_Föreställning_Namn" IS NOT NULL THEN
        INSERT INTO attributes."PR_NAM_Föreställning_Namn" (
            "Metadata_PR_NAM",
            "PR_NAM_PR_ID",
            "PR_NAM_Föreställning_Namn",
            "PR_NAM_PositedAt",
            "PR_NAM_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_NAM", NEW."Metadata_PR"),
            coalesce(NEW."PR_NAM_PR_ID", _id),
            NEW."PR_NAM_Föreställning_Namn",
            coalesce(NEW."PR_NAM_PositedAt", _now),
            coalesce(NEW."PR_NAM_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."PR_LEN_Föreställning_Längd" IS NOT NULL THEN
        INSERT INTO attributes."PR_LEN_Föreställning_Längd" (
            "Metadata_PR_LEN",
            "PR_LEN_PR_ID",
            "PR_LEN_Föreställning_Längd",
            "PR_LEN_ChangedAt",
            "PR_LEN_PositedAt",
            "PR_LEN_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_LEN", NEW."Metadata_PR"),
            coalesce(NEW."PR_LEN_PR_ID", _id),
            NEW."PR_LEN_Föreställning_Längd",
            coalesce(NEW."PR_LEN_ChangedAt", _now),
            coalesce(NEW."PR_LEN_PositedAt", _now),
            coalesce(NEW."PR_LEN_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_Föreställning" ON anchors."lPR_Föreställning";
CREATE TRIGGER "it_lPR_Föreställning"
INSTEAD OF INSERT ON anchors."lPR_Föreställning"
FOR EACH ROW EXECUTE FUNCTION anchors."it_lPR_Föreställning"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_Föreställning instead of UPDATE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."ut_lPR_Föreställning"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
BEGIN
    IF NEW."PR_ID" IS DISTINCT FROM OLD."PR_ID" THEN
        RAISE EXCEPTION 'The identity column PR_ID is not updatable.';
    END IF;
    IF NEW."PR_NAM_ID" IS DISTINCT FROM OLD."PR_NAM_ID" THEN
        RAISE EXCEPTION 'The identity column PR_NAM_ID is not updatable.';
    END IF;
    IF NEW."PR_NAM_PR_ID" IS DISTINCT FROM OLD."PR_NAM_PR_ID" THEN
        RAISE EXCEPTION 'The foreign key column PR_NAM_PR_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of PR_NAM_Föreställning_Namn, and when it posits
    _reliability := CASE
        WHEN NEW."PR_NAM_Reliability" IS DISTINCT FROM OLD."PR_NAM_Reliability" THEN NEW."PR_NAM_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."PR_NAM_Reliability"
    END;
    _positing := CASE
        WHEN NEW."PR_NAM_PositedAt" IS DISTINCT FROM OLD."PR_NAM_PositedAt" THEN NEW."PR_NAM_PositedAt"
        ELSE _now
    END;
    IF NEW."PR_NAM_Föreställning_Namn" IS DISTINCT FROM OLD."PR_NAM_Föreställning_Namn"
    OR NEW."PR_NAM_PositedAt" IS DISTINCT FROM OLD."PR_NAM_PositedAt"
    OR NEW."PR_NAM_Reliability" IS DISTINCT FROM OLD."PR_NAM_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."PR_NAM_Föreställning_Namn" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."PR_NAM_Föreställning_Namn" IS NULL
            OR NEW."PR_NAM_PositedAt" IS DISTINCT FROM OLD."PR_NAM_PositedAt"
            OR OLD."PR_NAM_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."PR_NAM_Föreställning_Namn" <> NEW."PR_NAM_Föreställning_Namn"
            THEN
                INSERT INTO attributes."PR_NAM_Föreställning_Namn" (
                    "Metadata_PR_NAM",
                    "PR_NAM_PR_ID",
                    "PR_NAM_Föreställning_Namn",
                    "PR_NAM_PositedAt",
                    "PR_NAM_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_PR" IS DISTINCT FROM OLD."Metadata_PR"
                             AND NEW."Metadata_PR_NAM" IS NOT DISTINCT FROM OLD."Metadata_PR_NAM"
                            THEN NEW."Metadata_PR"
                            ELSE NEW."Metadata_PR_NAM"
                        END, NEW."Metadata_PR"),
                    coalesce(NEW."PR_NAM_PR_ID", NEW."PR_ID"),
                    NEW."PR_NAM_Föreställning_Namn",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."PR_NAM_Föreställning_Namn" IS NULL AND OLD."PR_NAM_Föreställning_Namn" IS NOT NULL THEN
            INSERT INTO attributes."PR_NAM_Föreställning_Namn" (
                "Metadata_PR_NAM",
                "PR_NAM_PR_ID",
                "PR_NAM_Föreställning_Namn",
                "PR_NAM_PositedAt",
                "PR_NAM_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_PR" IS DISTINCT FROM OLD."Metadata_PR"
                         AND NEW."Metadata_PR_NAM" IS NOT DISTINCT FROM OLD."Metadata_PR_NAM"
                        THEN NEW."Metadata_PR"
                        ELSE NEW."Metadata_PR_NAM"
                    END, NEW."Metadata_PR"),
                p."PR_NAM_PR_ID",
                p."PR_NAM_Föreställning_Namn",
                _positing,
                0
            FROM
                attributes."PR_NAM_Föreställning_Namn_Posit" p
            WHERE
                p."PR_NAM_ID" = OLD."PR_NAM_ID";
        END IF;
    END IF;
    IF NEW."PR_LEN_ID" IS DISTINCT FROM OLD."PR_LEN_ID" THEN
        RAISE EXCEPTION 'The identity column PR_LEN_ID is not updatable.';
    END IF;
    IF NEW."PR_LEN_PR_ID" IS DISTINCT FROM OLD."PR_LEN_PR_ID" THEN
        RAISE EXCEPTION 'The foreign key column PR_LEN_PR_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of PR_LEN_Föreställning_Längd, and when it posits
    _reliability := CASE
        WHEN NEW."PR_LEN_Reliability" IS DISTINCT FROM OLD."PR_LEN_Reliability" THEN NEW."PR_LEN_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."PR_LEN_Reliability"
    END;
    _positing := CASE
        WHEN NEW."PR_LEN_PositedAt" IS DISTINCT FROM OLD."PR_LEN_PositedAt" THEN NEW."PR_LEN_PositedAt"
        WHEN NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" AND NEW."PR_LEN_Föreställning_Längd" IS NULL THEN NEW."PR_LEN_ChangedAt"
        ELSE _now
    END;
    IF NEW."PR_LEN_Föreställning_Längd" IS DISTINCT FROM OLD."PR_LEN_Föreställning_Längd"
    OR NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt"
    OR NEW."PR_LEN_PositedAt" IS DISTINCT FROM OLD."PR_LEN_PositedAt"
    OR NEW."PR_LEN_Reliability" IS DISTINCT FROM OLD."PR_LEN_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."PR_LEN_Föreställning_Längd" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."PR_LEN_Föreställning_Längd" IS NULL
            OR NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt"
            OR NEW."PR_LEN_PositedAt" IS DISTINCT FROM OLD."PR_LEN_PositedAt"
            OR OLD."PR_LEN_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."PR_LEN_Föreställning_Längd" <> NEW."PR_LEN_Föreställning_Längd"
            THEN
                INSERT INTO attributes."PR_LEN_Föreställning_Längd" (
                    "Metadata_PR_LEN",
                    "PR_LEN_PR_ID",
                    "PR_LEN_Föreställning_Längd",
                    "PR_LEN_ChangedAt",
                    "PR_LEN_PositedAt",
                    "PR_LEN_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_PR" IS DISTINCT FROM OLD."Metadata_PR"
                             AND NEW."Metadata_PR_LEN" IS NOT DISTINCT FROM OLD."Metadata_PR_LEN"
                            THEN NEW."Metadata_PR"
                            ELSE NEW."Metadata_PR_LEN"
                        END, NEW."Metadata_PR"),
                    coalesce(NEW."PR_LEN_PR_ID", NEW."PR_ID"),
                    NEW."PR_LEN_Föreställning_Längd",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."PR_LEN_ChangedAt" IS DISTINCT FROM OLD."PR_LEN_ChangedAt" THEN NEW."PR_LEN_ChangedAt"
                        WHEN OLD."PR_LEN_Föreställning_Längd" = NEW."PR_LEN_Föreställning_Längd" THEN NEW."PR_LEN_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."PR_LEN_Föreställning_Längd" IS NULL AND OLD."PR_LEN_Föreställning_Längd" IS NOT NULL THEN
            INSERT INTO attributes."PR_LEN_Föreställning_Längd" (
                "Metadata_PR_LEN",
                "PR_LEN_PR_ID",
                "PR_LEN_Föreställning_Längd",
                "PR_LEN_ChangedAt",
                "PR_LEN_PositedAt",
                "PR_LEN_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_PR" IS DISTINCT FROM OLD."Metadata_PR"
                         AND NEW."Metadata_PR_LEN" IS NOT DISTINCT FROM OLD."Metadata_PR_LEN"
                        THEN NEW."Metadata_PR"
                        ELSE NEW."Metadata_PR_LEN"
                    END, NEW."Metadata_PR"),
                p."PR_LEN_PR_ID",
                p."PR_LEN_Föreställning_Längd",
                p."PR_LEN_ChangedAt",
                _positing,
                0
            FROM
                attributes."PR_LEN_Föreställning_Längd_Posit" p
            WHERE
                p."PR_LEN_ID" = OLD."PR_LEN_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_Föreställning" ON anchors."lPR_Föreställning";
CREATE TRIGGER "ut_lPR_Föreställning"
INSTEAD OF UPDATE ON anchors."lPR_Föreställning"
FOR EACH ROW EXECUTE FUNCTION anchors."ut_lPR_Föreställning"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_Föreställning instead of DELETE trigger on lPR_Föreställning
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION anchors."dt_lPR_Föreställning"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of PR_NAM_Föreställning_Namn is retracted
    INSERT INTO attributes."PR_NAM_Föreställning_Namn_Annex" (
        "Metadata_PR_NAM",
        "PR_NAM_ID",
        "PR_NAM_PositedAt",
        "PR_NAM_Reliability"
    )
    SELECT
        OLD."Metadata_PR_NAM",
        OLD."PR_NAM_ID",
        _now,
        0
    WHERE
        OLD."PR_NAM_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of PR_LEN_Föreställning_Längd is retracted
    INSERT INTO attributes."PR_LEN_Föreställning_Längd_Annex" (
        "Metadata_PR_LEN",
        "PR_LEN_ID",
        "PR_LEN_PositedAt",
        "PR_LEN_Reliability"
    )
    SELECT
        OLD."Metadata_PR_LEN",
        OLD."PR_LEN_ID",
        _now,
        0
    WHERE
        OLD."PR_LEN_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_Föreställning" ON anchors."lPR_Föreställning";
CREATE TRIGGER "dt_lPR_Föreställning"
INSTEAD OF DELETE ON anchors."lPR_Föreställning"
FOR EACH ROW EXECUTE FUNCTION anchors."dt_lPR_Föreställning"();
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
-- it_lEV_Händelse instead of INSERT trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."it_lEV_Händelse"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _id numeric(12,0);
    _UTL smallint;
    _LVL smallint;
BEGIN
    _id := NEW."EV_ID";
    IF _id IS NULL THEN
        INSERT INTO nexuses."EV_Händelse" (
            "ST_ID_hölls",
            "PR_ID_spelades",
            "ETY_ID_of",
            "Metadata_EV"
        )
        VALUES (
            NEW."ST_ID_hölls",
            NEW."PR_ID_spelades",
            NEW."ETY_ID_of",
            NEW."Metadata_EV"
        )
        RETURNING "EV_ID" INTO _id;
    END IF;
    IF NEW."EV_DAT_Händelse_Datum" IS NOT NULL THEN
        INSERT INTO attributes."EV_DAT_Händelse_Datum" (
            "Metadata_EV_DAT",
            "EV_DAT_EV_ID",
            "EV_DAT_Händelse_Datum",
            "EV_DAT_PositedAt",
            "EV_DAT_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_DAT", NEW."Metadata_EV"),
            coalesce(NEW."EV_DAT_EV_ID", _id),
            NEW."EV_DAT_Händelse_Datum",
            coalesce(NEW."EV_DAT_PositedAt", _now),
            coalesce(NEW."EV_DAT_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."EV_AUD_Händelse_Publik" IS NOT NULL THEN
        INSERT INTO attributes."EV_AUD_Händelse_Publik" (
            "Metadata_EV_AUD",
            "EV_AUD_EV_ID",
            "EV_AUD_Händelse_Publik",
            "EV_AUD_PositedAt",
            "EV_AUD_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_AUD", NEW."Metadata_EV"),
            coalesce(NEW."EV_AUD_EV_ID", _id),
            NEW."EV_AUD_Händelse_Publik",
            coalesce(NEW."EV_AUD_PositedAt", _now),
            coalesce(NEW."EV_AUD_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."EV_REV_Händelse_Intäkt" IS NOT NULL THEN
        INSERT INTO attributes."EV_REV_Händelse_Intäkt" (
            "Metadata_EV_REV",
            "EV_REV_EV_ID",
            "EV_REV_Händelse_Intäkt",
            "EV_REV_PositedAt",
            "EV_REV_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_REV", NEW."Metadata_EV"),
            coalesce(NEW."EV_REV_EV_ID", _id),
            NEW."EV_REV_Händelse_Intäkt",
            coalesce(NEW."EV_REV_PositedAt", _now),
            coalesce(NEW."EV_REV_Reliability", NEW."Reliability", 1)
        );
    END IF;
    IF NEW."EV_STA_Händelse_Status" IS NOT NULL THEN
        INSERT INTO attributes."EV_STA_Händelse_Status" (
            "Metadata_EV_STA",
            "EV_STA_EV_ID",
            "EV_STA_Händelse_Status",
            "EV_STA_ChangedAt",
            "EV_STA_PositedAt",
            "EV_STA_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_STA", NEW."Metadata_EV"),
            coalesce(NEW."EV_STA_EV_ID", _id),
            NEW."EV_STA_Händelse_Status",
            coalesce(NEW."EV_STA_ChangedAt", _now),
            coalesce(NEW."EV_STA_PositedAt", _now),
            coalesce(NEW."EV_STA_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _UTL := NEW."EV_UTL_UTL_ID";
    IF _UTL IS NULL AND NEW."EV_UTL_UTL_Utnyttjande" IS NOT NULL THEN
        SELECT
            k."UTL_ID"
        INTO
            _UTL
        FROM
            knots."UTL_Utnyttjande" k
        WHERE
            k."UTL_Utnyttjande" = NEW."EV_UTL_UTL_Utnyttjande"
        LIMIT 1;
    END IF;
    IF _UTL IS NOT NULL THEN
        INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande" (
            "Metadata_EV_UTL",
            "EV_UTL_EV_ID",
            "EV_UTL_UTL_ID",
            "EV_UTL_PositedAt",
            "EV_UTL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_UTL", NEW."Metadata_EV"),
            coalesce(NEW."EV_UTL_EV_ID", _id),
            _UTL,
            coalesce(NEW."EV_UTL_PositedAt", _now),
            coalesce(NEW."EV_UTL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    _LVL := NEW."EV_LVL_PLV_ID";
    IF _LVL IS NULL AND NEW."EV_LVL_PLV_Yrkesnivå" IS NOT NULL THEN
        SELECT
            k."PLV_ID"
        INTO
            _LVL
        FROM
            knots."PLV_Yrkesnivå" k
        WHERE
            k."PLV_Checksum" = decode(md5(NEW."EV_LVL_PLV_Yrkesnivå"::text), 'hex')
        LIMIT 1;
    END IF;
    IF _LVL IS NOT NULL THEN
        INSERT INTO attributes."EV_LVL_Händelse_Level" (
            "Metadata_EV_LVL",
            "EV_LVL_EV_ID",
            "EV_LVL_PLV_ID",
            "EV_LVL_ChangedAt",
            "EV_LVL_PositedAt",
            "EV_LVL_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_LVL", NEW."Metadata_EV"),
            coalesce(NEW."EV_LVL_EV_ID", _id),
            _LVL,
            coalesce(NEW."EV_LVL_ChangedAt", _now),
            coalesce(NEW."EV_LVL_PositedAt", _now),
            coalesce(NEW."EV_LVL_Reliability", NEW."Reliability", 1)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_Händelse" ON nexuses."lEV_Händelse";
CREATE TRIGGER "it_lEV_Händelse"
INSTEAD OF INSERT ON nexuses."lEV_Händelse"
FOR EACH ROW EXECUTE FUNCTION nexuses."it_lEV_Händelse"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lEV_Händelse instead of UPDATE trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."ut_lEV_Händelse"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _reliability decimal(5,2);
    _positing timestamp;
    _UTL smallint;
    _LVL smallint;
BEGIN
    IF NEW."EV_ID" IS DISTINCT FROM OLD."EV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_ID is not updatable.';
    END IF;
    IF NEW."ST_ID_hölls" IS DISTINCT FROM OLD."ST_ID_hölls" THEN
        RAISE EXCEPTION 'The role column ST_ID_hölls is not updatable.';
    END IF;
    IF NEW."PR_ID_spelades" IS DISTINCT FROM OLD."PR_ID_spelades" THEN
        RAISE EXCEPTION 'The role column PR_ID_spelades is not updatable.';
    END IF;
    IF NEW."ETY_ID_of" IS DISTINCT FROM OLD."ETY_ID_of" THEN
        RAISE EXCEPTION 'The role column ETY_ID_of is not updatable.';
    END IF;
    IF NEW."of_ETY_Händelsetyp" IS DISTINCT FROM OLD."of_ETY_Händelsetyp" THEN
        RAISE EXCEPTION 'The role column of_ETY_Händelsetyp is not updatable.';
    END IF;
    IF NEW."EV_DAT_ID" IS DISTINCT FROM OLD."EV_DAT_ID" THEN
        RAISE EXCEPTION 'The identity column EV_DAT_ID is not updatable.';
    END IF;
    IF NEW."EV_DAT_EV_ID" IS DISTINCT FROM OLD."EV_DAT_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_DAT_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_DAT_Händelse_Datum, and when it posits
    _reliability := CASE
        WHEN NEW."EV_DAT_Reliability" IS DISTINCT FROM OLD."EV_DAT_Reliability" THEN NEW."EV_DAT_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_DAT_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt" THEN NEW."EV_DAT_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_DAT_Händelse_Datum" IS DISTINCT FROM OLD."EV_DAT_Händelse_Datum"
    OR NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt"
    OR NEW."EV_DAT_Reliability" IS DISTINCT FROM OLD."EV_DAT_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_DAT_Händelse_Datum" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_DAT_Händelse_Datum" IS NULL
            OR NEW."EV_DAT_PositedAt" IS DISTINCT FROM OLD."EV_DAT_PositedAt"
            OR OLD."EV_DAT_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_DAT_Händelse_Datum" <> NEW."EV_DAT_Händelse_Datum"
            THEN
                INSERT INTO attributes."EV_DAT_Händelse_Datum" (
                    "Metadata_EV_DAT",
                    "EV_DAT_EV_ID",
                    "EV_DAT_Händelse_Datum",
                    "EV_DAT_PositedAt",
                    "EV_DAT_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_DAT" IS NOT DISTINCT FROM OLD."Metadata_EV_DAT"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_DAT"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_DAT_EV_ID", NEW."EV_ID"),
                    NEW."EV_DAT_Händelse_Datum",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_DAT_Händelse_Datum" IS NULL AND OLD."EV_DAT_Händelse_Datum" IS NOT NULL THEN
            INSERT INTO attributes."EV_DAT_Händelse_Datum" (
                "Metadata_EV_DAT",
                "EV_DAT_EV_ID",
                "EV_DAT_Händelse_Datum",
                "EV_DAT_PositedAt",
                "EV_DAT_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_DAT" IS NOT DISTINCT FROM OLD."Metadata_EV_DAT"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_DAT"
                    END, NEW."Metadata_EV"),
                p."EV_DAT_EV_ID",
                p."EV_DAT_Händelse_Datum",
                _positing,
                0
            FROM
                attributes."EV_DAT_Händelse_Datum_Posit" p
            WHERE
                p."EV_DAT_ID" = OLD."EV_DAT_ID";
        END IF;
    END IF;
    IF NEW."EV_AUD_ID" IS DISTINCT FROM OLD."EV_AUD_ID" THEN
        RAISE EXCEPTION 'The identity column EV_AUD_ID is not updatable.';
    END IF;
    IF NEW."EV_AUD_EV_ID" IS DISTINCT FROM OLD."EV_AUD_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_AUD_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_AUD_Händelse_Publik, and when it posits
    _reliability := CASE
        WHEN NEW."EV_AUD_Reliability" IS DISTINCT FROM OLD."EV_AUD_Reliability" THEN NEW."EV_AUD_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_AUD_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt" THEN NEW."EV_AUD_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_AUD_Händelse_Publik" IS DISTINCT FROM OLD."EV_AUD_Händelse_Publik"
    OR NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt"
    OR NEW."EV_AUD_Reliability" IS DISTINCT FROM OLD."EV_AUD_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_AUD_Händelse_Publik" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_AUD_Händelse_Publik" IS NULL
            OR NEW."EV_AUD_PositedAt" IS DISTINCT FROM OLD."EV_AUD_PositedAt"
            OR OLD."EV_AUD_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_AUD_Händelse_Publik" <> NEW."EV_AUD_Händelse_Publik"
            THEN
                INSERT INTO attributes."EV_AUD_Händelse_Publik" (
                    "Metadata_EV_AUD",
                    "EV_AUD_EV_ID",
                    "EV_AUD_Händelse_Publik",
                    "EV_AUD_PositedAt",
                    "EV_AUD_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_AUD" IS NOT DISTINCT FROM OLD."Metadata_EV_AUD"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_AUD"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_AUD_EV_ID", NEW."EV_ID"),
                    NEW."EV_AUD_Händelse_Publik",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_AUD_Händelse_Publik" IS NULL AND OLD."EV_AUD_Händelse_Publik" IS NOT NULL THEN
            INSERT INTO attributes."EV_AUD_Händelse_Publik" (
                "Metadata_EV_AUD",
                "EV_AUD_EV_ID",
                "EV_AUD_Händelse_Publik",
                "EV_AUD_PositedAt",
                "EV_AUD_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_AUD" IS NOT DISTINCT FROM OLD."Metadata_EV_AUD"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_AUD"
                    END, NEW."Metadata_EV"),
                p."EV_AUD_EV_ID",
                p."EV_AUD_Händelse_Publik",
                _positing,
                0
            FROM
                attributes."EV_AUD_Händelse_Publik_Posit" p
            WHERE
                p."EV_AUD_ID" = OLD."EV_AUD_ID";
        END IF;
    END IF;
    IF NEW."EV_REV_ID" IS DISTINCT FROM OLD."EV_REV_ID" THEN
        RAISE EXCEPTION 'The identity column EV_REV_ID is not updatable.';
    END IF;
    IF NEW."EV_REV_EV_ID" IS DISTINCT FROM OLD."EV_REV_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_REV_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_REV_Händelse_Intäkt, and when it posits
    _reliability := CASE
        WHEN NEW."EV_REV_Reliability" IS DISTINCT FROM OLD."EV_REV_Reliability" THEN NEW."EV_REV_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_REV_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt" THEN NEW."EV_REV_PositedAt"
        ELSE _now
    END;
    IF NEW."EV_REV_Händelse_Intäkt" IS DISTINCT FROM OLD."EV_REV_Händelse_Intäkt"
    OR NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt"
    OR NEW."EV_REV_Reliability" IS DISTINCT FROM OLD."EV_REV_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_REV_Händelse_Intäkt" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_REV_Händelse_Intäkt" IS NULL
            OR NEW."EV_REV_PositedAt" IS DISTINCT FROM OLD."EV_REV_PositedAt"
            OR OLD."EV_REV_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_REV_Händelse_Intäkt" <> NEW."EV_REV_Händelse_Intäkt"
            THEN
                INSERT INTO attributes."EV_REV_Händelse_Intäkt" (
                    "Metadata_EV_REV",
                    "EV_REV_EV_ID",
                    "EV_REV_Händelse_Intäkt",
                    "EV_REV_PositedAt",
                    "EV_REV_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_REV" IS NOT DISTINCT FROM OLD."Metadata_EV_REV"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_REV"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_REV_EV_ID", NEW."EV_ID"),
                    NEW."EV_REV_Händelse_Intäkt",
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_REV_Händelse_Intäkt" IS NULL AND OLD."EV_REV_Händelse_Intäkt" IS NOT NULL THEN
            INSERT INTO attributes."EV_REV_Händelse_Intäkt" (
                "Metadata_EV_REV",
                "EV_REV_EV_ID",
                "EV_REV_Händelse_Intäkt",
                "EV_REV_PositedAt",
                "EV_REV_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_REV" IS NOT DISTINCT FROM OLD."Metadata_EV_REV"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_REV"
                    END, NEW."Metadata_EV"),
                p."EV_REV_EV_ID",
                p."EV_REV_Händelse_Intäkt",
                _positing,
                0
            FROM
                attributes."EV_REV_Händelse_Intäkt_Posit" p
            WHERE
                p."EV_REV_ID" = OLD."EV_REV_ID";
        END IF;
    END IF;
    IF NEW."EV_STA_ID" IS DISTINCT FROM OLD."EV_STA_ID" THEN
        RAISE EXCEPTION 'The identity column EV_STA_ID is not updatable.';
    END IF;
    IF NEW."EV_STA_EV_ID" IS DISTINCT FROM OLD."EV_STA_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_STA_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_STA_Händelse_Status, and when it posits
    _reliability := CASE
        WHEN NEW."EV_STA_Reliability" IS DISTINCT FROM OLD."EV_STA_Reliability" THEN NEW."EV_STA_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_STA_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_STA_PositedAt" IS DISTINCT FROM OLD."EV_STA_PositedAt" THEN NEW."EV_STA_PositedAt"
        WHEN NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt" AND NEW."EV_STA_Händelse_Status" IS NULL THEN NEW."EV_STA_ChangedAt"
        ELSE _now
    END;
    IF NEW."EV_STA_Händelse_Status" IS DISTINCT FROM OLD."EV_STA_Händelse_Status"
    OR NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt"
    OR NEW."EV_STA_PositedAt" IS DISTINCT FROM OLD."EV_STA_PositedAt"
    OR NEW."EV_STA_Reliability" IS DISTINCT FROM OLD."EV_STA_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF NEW."EV_STA_Händelse_Status" IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_STA_Händelse_Status" IS NULL
            OR NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt"
            OR NEW."EV_STA_PositedAt" IS DISTINCT FROM OLD."EV_STA_PositedAt"
            OR OLD."EV_STA_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_STA_Händelse_Status" <> NEW."EV_STA_Händelse_Status"
            THEN
                INSERT INTO attributes."EV_STA_Händelse_Status" (
                    "Metadata_EV_STA",
                    "EV_STA_EV_ID",
                    "EV_STA_Händelse_Status",
                    "EV_STA_ChangedAt",
                    "EV_STA_PositedAt",
                    "EV_STA_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_STA" IS NOT DISTINCT FROM OLD."Metadata_EV_STA"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_STA"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_STA_EV_ID", NEW."EV_ID"),
                    NEW."EV_STA_Händelse_Status",
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."EV_STA_ChangedAt" IS DISTINCT FROM OLD."EV_STA_ChangedAt" THEN NEW."EV_STA_ChangedAt"
                        WHEN OLD."EV_STA_Händelse_Status" = NEW."EV_STA_Händelse_Status" THEN NEW."EV_STA_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF NEW."EV_STA_Händelse_Status" IS NULL AND OLD."EV_STA_Händelse_Status" IS NOT NULL THEN
            INSERT INTO attributes."EV_STA_Händelse_Status" (
                "Metadata_EV_STA",
                "EV_STA_EV_ID",
                "EV_STA_Händelse_Status",
                "EV_STA_ChangedAt",
                "EV_STA_PositedAt",
                "EV_STA_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_STA" IS NOT DISTINCT FROM OLD."Metadata_EV_STA"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_STA"
                    END, NEW."Metadata_EV"),
                p."EV_STA_EV_ID",
                p."EV_STA_Händelse_Status",
                p."EV_STA_ChangedAt",
                _positing,
                0
            FROM
                attributes."EV_STA_Händelse_Status_Posit" p
            WHERE
                p."EV_STA_ID" = OLD."EV_STA_ID";
        END IF;
    END IF;
    IF NEW."EV_UTL_ID" IS DISTINCT FROM OLD."EV_UTL_ID" THEN
        RAISE EXCEPTION 'The identity column EV_UTL_ID is not updatable.';
    END IF;
    IF NEW."EV_UTL_EV_ID" IS DISTINCT FROM OLD."EV_UTL_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_UTL_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_UTL_Händelse_Utnyttjande, and when it posits
    _reliability := CASE
        WHEN NEW."EV_UTL_Reliability" IS DISTINCT FROM OLD."EV_UTL_Reliability" THEN NEW."EV_UTL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_UTL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_UTL_PositedAt" IS DISTINCT FROM OLD."EV_UTL_PositedAt" THEN NEW."EV_UTL_PositedAt"
        ELSE _now
    END;
    _UTL := NEW."EV_UTL_UTL_ID";
    IF _UTL IS NOT DISTINCT FROM OLD."EV_UTL_UTL_ID" AND NEW."EV_UTL_UTL_Utnyttjande" IS DISTINCT FROM OLD."EV_UTL_UTL_Utnyttjande" THEN
        _UTL := NULL;
        IF NEW."EV_UTL_UTL_Utnyttjande" IS NOT NULL THEN
            SELECT
                k."UTL_ID"
            INTO
                _UTL
            FROM
                knots."UTL_Utnyttjande" k
            WHERE
                k."UTL_Utnyttjande" = NEW."EV_UTL_UTL_Utnyttjande"
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."EV_UTL_UTL_ID" IS DISTINCT FROM OLD."EV_UTL_UTL_ID"
    OR NEW."EV_UTL_UTL_Utnyttjande" IS DISTINCT FROM OLD."EV_UTL_UTL_Utnyttjande"
    OR NEW."EV_UTL_PositedAt" IS DISTINCT FROM OLD."EV_UTL_PositedAt"
    OR NEW."EV_UTL_Reliability" IS DISTINCT FROM OLD."EV_UTL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _UTL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_UTL_UTL_ID" IS NULL
            OR NEW."EV_UTL_PositedAt" IS DISTINCT FROM OLD."EV_UTL_PositedAt"
            OR OLD."EV_UTL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_UTL_UTL_ID" <> _UTL
            THEN
                INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande" (
                    "Metadata_EV_UTL",
                    "EV_UTL_EV_ID",
                    "EV_UTL_UTL_ID",
                    "EV_UTL_PositedAt",
                    "EV_UTL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_UTL" IS NOT DISTINCT FROM OLD."Metadata_EV_UTL"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_UTL"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_UTL_EV_ID", NEW."EV_ID"),
                    _UTL,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."EV_UTL_UTL_ID" IS NOT NULL AND (
            NEW."EV_UTL_UTL_ID" IS NULL OR (
                NEW."EV_UTL_UTL_ID" = OLD."EV_UTL_UTL_ID"
                AND NEW."EV_UTL_UTL_Utnyttjande" IS NULL AND OLD."EV_UTL_UTL_Utnyttjande" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande" (
                "Metadata_EV_UTL",
                "EV_UTL_EV_ID",
                "EV_UTL_UTL_ID",
                "EV_UTL_PositedAt",
                "EV_UTL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_UTL" IS NOT DISTINCT FROM OLD."Metadata_EV_UTL"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_UTL"
                    END, NEW."Metadata_EV"),
                p."EV_UTL_EV_ID",
                p."EV_UTL_UTL_ID",
                _positing,
                0
            FROM
                attributes."EV_UTL_Händelse_Utnyttjande_Posit" p
            WHERE
                p."EV_UTL_ID" = OLD."EV_UTL_ID";
        END IF;
    END IF;
    IF NEW."EV_LVL_ID" IS DISTINCT FROM OLD."EV_LVL_ID" THEN
        RAISE EXCEPTION 'The identity column EV_LVL_ID is not updatable.';
    END IF;
    IF NEW."EV_LVL_EV_ID" IS DISTINCT FROM OLD."EV_LVL_EV_ID" THEN
        RAISE EXCEPTION 'The foreign key column EV_LVL_EV_ID is not updatable.';
    END IF;
    -- what the update says about the reliability of EV_LVL_Händelse_Level, and when it posits
    _reliability := CASE
        WHEN NEW."EV_LVL_Reliability" IS DISTINCT FROM OLD."EV_LVL_Reliability" THEN NEW."EV_LVL_Reliability"
        WHEN NEW."Reliability" IS DISTINCT FROM OLD."Reliability" THEN NEW."Reliability"
        ELSE NEW."EV_LVL_Reliability"
    END;
    _positing := CASE
        WHEN NEW."EV_LVL_PositedAt" IS DISTINCT FROM OLD."EV_LVL_PositedAt" THEN NEW."EV_LVL_PositedAt"
        WHEN NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt" AND NEW."EV_LVL_PLV_ID" IS NULL THEN NEW."EV_LVL_ChangedAt"
        ELSE _now
    END;
    _LVL := NEW."EV_LVL_PLV_ID";
    IF _LVL IS NOT DISTINCT FROM OLD."EV_LVL_PLV_ID" AND NEW."EV_LVL_PLV_Yrkesnivå" IS DISTINCT FROM OLD."EV_LVL_PLV_Yrkesnivå" THEN
        _LVL := NULL;
        IF NEW."EV_LVL_PLV_Yrkesnivå" IS NOT NULL THEN
            SELECT
                k."PLV_ID"
            INTO
                _LVL
            FROM
                knots."PLV_Yrkesnivå" k
            WHERE
                k."PLV_Checksum" = decode(md5(NEW."EV_LVL_PLV_Yrkesnivå"::text), 'hex')
            LIMIT 1;
        END IF;
    END IF;
    IF NEW."EV_LVL_PLV_ID" IS DISTINCT FROM OLD."EV_LVL_PLV_ID"
    OR NEW."EV_LVL_PLV_Yrkesnivå" IS DISTINCT FROM OLD."EV_LVL_PLV_Yrkesnivå"
    OR NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt"
    OR NEW."EV_LVL_PositedAt" IS DISTINCT FROM OLD."EV_LVL_PositedAt"
    OR NEW."EV_LVL_Reliability" IS DISTINCT FROM OLD."EV_LVL_Reliability"
    OR NEW."Reliability" IS DISTINCT FROM OLD."Reliability"
    THEN
        IF _LVL IS NOT NULL THEN
            -- a statement that leaves everything as it is states nothing
            IF OLD."EV_LVL_PLV_ID" IS NULL
            OR NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt"
            OR NEW."EV_LVL_PositedAt" IS DISTINCT FROM OLD."EV_LVL_PositedAt"
            OR OLD."EV_LVL_Reliability" IS DISTINCT FROM coalesce(_reliability, 1)
            OR OLD."EV_LVL_PLV_ID" <> _LVL
            THEN
                INSERT INTO attributes."EV_LVL_Händelse_Level" (
                    "Metadata_EV_LVL",
                    "EV_LVL_EV_ID",
                    "EV_LVL_PLV_ID",
                    "EV_LVL_ChangedAt",
                    "EV_LVL_PositedAt",
                    "EV_LVL_Reliability"
                )
                VALUES (
                    coalesce(
                        CASE
                            WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                             AND NEW."Metadata_EV_LVL" IS NOT DISTINCT FROM OLD."Metadata_EV_LVL"
                            THEN NEW."Metadata_EV"
                            ELSE NEW."Metadata_EV_LVL"
                        END, NEW."Metadata_EV"),
                    coalesce(NEW."EV_LVL_EV_ID", NEW."EV_ID"),
                    _LVL,
                    -- the shown version asserted again keeps its changing time, as does one that is given
                    CASE
                        WHEN NEW."EV_LVL_ChangedAt" IS DISTINCT FROM OLD."EV_LVL_ChangedAt" THEN NEW."EV_LVL_ChangedAt"
                        WHEN OLD."EV_LVL_PLV_ID" = _LVL THEN NEW."EV_LVL_ChangedAt"
                        ELSE _now
                    END,
                    _positing,
                    coalesce(_reliability, 1)
                );
            END IF;
        END IF;
        -- logical delete by setting the value to null
        IF OLD."EV_LVL_PLV_ID" IS NOT NULL AND (
            NEW."EV_LVL_PLV_ID" IS NULL OR (
                NEW."EV_LVL_PLV_ID" = OLD."EV_LVL_PLV_ID"
                AND NEW."EV_LVL_PLV_Yrkesnivå" IS NULL AND OLD."EV_LVL_PLV_Yrkesnivå" IS NOT NULL
            )
        ) THEN
            INSERT INTO attributes."EV_LVL_Händelse_Level" (
                "Metadata_EV_LVL",
                "EV_LVL_EV_ID",
                "EV_LVL_PLV_ID",
                "EV_LVL_ChangedAt",
                "EV_LVL_PositedAt",
                "EV_LVL_Reliability"
            )
            SELECT
                coalesce(
                    CASE
                        WHEN NEW."Metadata_EV" IS DISTINCT FROM OLD."Metadata_EV"
                         AND NEW."Metadata_EV_LVL" IS NOT DISTINCT FROM OLD."Metadata_EV_LVL"
                        THEN NEW."Metadata_EV"
                        ELSE NEW."Metadata_EV_LVL"
                    END, NEW."Metadata_EV"),
                p."EV_LVL_EV_ID",
                p."EV_LVL_PLV_ID",
                p."EV_LVL_ChangedAt",
                _positing,
                0
            FROM
                attributes."EV_LVL_Händelse_Level_Posit" p
            WHERE
                p."EV_LVL_ID" = OLD."EV_LVL_ID";
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lEV_Händelse" ON nexuses."lEV_Händelse";
CREATE TRIGGER "ut_lEV_Händelse"
INSTEAD OF UPDATE ON nexuses."lEV_Händelse"
FOR EACH ROW EXECUTE FUNCTION nexuses."ut_lEV_Händelse"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_Händelse instead of DELETE trigger on lEV_Händelse
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION nexuses."dt_lEV_Händelse"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown of EV_DAT_Händelse_Datum is retracted
    INSERT INTO attributes."EV_DAT_Händelse_Datum_Annex" (
        "Metadata_EV_DAT",
        "EV_DAT_ID",
        "EV_DAT_PositedAt",
        "EV_DAT_Reliability"
    )
    SELECT
        OLD."Metadata_EV_DAT",
        OLD."EV_DAT_ID",
        _now,
        0
    WHERE
        OLD."EV_DAT_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_AUD_Händelse_Publik is retracted
    INSERT INTO attributes."EV_AUD_Händelse_Publik_Annex" (
        "Metadata_EV_AUD",
        "EV_AUD_ID",
        "EV_AUD_PositedAt",
        "EV_AUD_Reliability"
    )
    SELECT
        OLD."Metadata_EV_AUD",
        OLD."EV_AUD_ID",
        _now,
        0
    WHERE
        OLD."EV_AUD_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_REV_Händelse_Intäkt is retracted
    INSERT INTO attributes."EV_REV_Händelse_Intäkt_Annex" (
        "Metadata_EV_REV",
        "EV_REV_ID",
        "EV_REV_PositedAt",
        "EV_REV_Reliability"
    )
    SELECT
        OLD."Metadata_EV_REV",
        OLD."EV_REV_ID",
        _now,
        0
    WHERE
        OLD."EV_REV_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_STA_Händelse_Status is retracted
    INSERT INTO attributes."EV_STA_Händelse_Status_Annex" (
        "Metadata_EV_STA",
        "EV_STA_ID",
        "EV_STA_PositedAt",
        "EV_STA_Reliability"
    )
    SELECT
        OLD."Metadata_EV_STA",
        OLD."EV_STA_ID",
        _now,
        0
    WHERE
        OLD."EV_STA_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_UTL_Händelse_Utnyttjande is retracted
    INSERT INTO attributes."EV_UTL_Händelse_Utnyttjande_Annex" (
        "Metadata_EV_UTL",
        "EV_UTL_ID",
        "EV_UTL_PositedAt",
        "EV_UTL_Reliability"
    )
    SELECT
        OLD."Metadata_EV_UTL",
        OLD."EV_UTL_ID",
        _now,
        0
    WHERE
        OLD."EV_UTL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- what is shown of EV_LVL_Händelse_Level is retracted
    INSERT INTO attributes."EV_LVL_Händelse_Level_Annex" (
        "Metadata_EV_LVL",
        "EV_LVL_ID",
        "EV_LVL_PositedAt",
        "EV_LVL_Reliability"
    )
    SELECT
        OLD."Metadata_EV_LVL",
        OLD."EV_LVL_ID",
        _now,
        0
    WHERE
        OLD."EV_LVL_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_Händelse" ON nexuses."lEV_Händelse";
CREATE TRIGGER "dt_lEV_Händelse"
INSTEAD OF DELETE ON nexuses."lEV_Händelse"
FOR EACH ROW EXECUTE FUNCTION nexuses."dt_lEV_Händelse"();
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
-- ie_AC_partner_AC_with_ONG_currently tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_partner_AC_with_ONG_currently"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_partner_AC_with_ONG_currently_Reliability" = 1
            FROM
                ties."AC_partner_AC_with_ONG_currently_Annex" a
            WHERE
                a."AC_partner_AC_with_ONG_currently_ID" = _id
            AND
                a."AC_partner_AC_with_ONG_currently_PositedAt" <= _positing
            ORDER BY
                a."AC_partner_AC_with_ONG_currently_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_partner_AC_with_ONG_currently instead of INSERT trigger on AC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_partner_AC_with_ONG_currently"()
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
    _positing := coalesce(NEW."AC_partner_AC_with_ONG_currently_PositedAt", _now);
    _reliability := coalesce(NEW."AC_partner_AC_with_ONG_currently_Reliability", 1);
    _changing := coalesce(NEW."AC_partner_AC_with_ONG_currently_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_partner_AC_with_ONG_currently_ID"
    INTO
        _posit
    FROM
        ties."AC_partner_AC_with_ONG_currently_Posit" p
    WHERE
        p."AC_ID_partner" = NEW."AC_ID_partner"
    AND
        p."AC_ID_with" = NEW."AC_ID_with"
    AND
        p."ONG_ID_currently" = NEW."ONG_ID_currently"
    AND
        p."AC_partner_AC_with_ONG_currently_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_partner_AC_with_ONG_currently_Annex" a
        WHERE
            a."AC_partner_AC_with_ONG_currently_ID" = _posit
        AND
            a."AC_partner_AC_with_ONG_currently_PositedAt" = _positing
        AND
            a."AC_partner_AC_with_ONG_currently_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_partner_AC_with_ONG_currently for: %', concat_ws(', ',
            NEW."AC_ID_partner",
            NEW."AC_ID_with",
            NEW."ONG_ID_currently",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_partner_AC_with_ONG_currently_Annex" a
        WHERE
            a."AC_partner_AC_with_ONG_currently_ID" = _posit
        AND
            a."AC_partner_AC_with_ONG_currently_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_partner_AC_with_ONG_currently"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" (
            "Metadata_AC_partner_AC_with_ONG_currently",
            "AC_partner_AC_with_ONG_currently_ID",
            "AC_partner_AC_with_ONG_currently_PositedAt",
            "AC_partner_AC_with_ONG_currently_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_partner_AC_with_ONG_currently", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_partner_AC_with_ONG_currently_Posit" (
            "AC_ID_partner",
            "AC_ID_with",
            "ONG_ID_currently",
            "AC_partner_AC_with_ONG_currently_ChangedAt"
        )
        VALUES (
            NEW."AC_ID_partner",
            NEW."AC_ID_with",
            NEW."ONG_ID_currently",
            _changing
        )
        RETURNING "AC_partner_AC_with_ONG_currently_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_partner_AC_with_ONG_currently", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_partner_AC_with_ONG_currently" ON ties."AC_partner_AC_with_ONG_currently";
CREATE TRIGGER "it_AC_partner_AC_with_ONG_currently"
INSTEAD OF INSERT ON ties."AC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_partner_AC_with_ONG_currently"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_partner_AC_with_ONG_currently instead of INSERT trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_ID_partner",
        "AC_ID_with",
        "ONG_ID_currently",
        "AC_partner_AC_with_ONG_currently_ChangedAt",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_partner_AC_with_ONG_currently",
        NEW."AC_ID_partner",
        NEW."AC_ID_with",
        coalesce(NEW."ONG_ID_currently", (
            SELECT
                k."ONG_ID"
            FROM
                knots."ONG_Pågående" k
            WHERE
                k."ONG_Pågående" = NEW."currently_ONG_Pågående"
            LIMIT 1
        )),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_ChangedAt", _now),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_PositedAt", _now),
        coalesce(NEW."AC_partner_AC_with_ONG_currently_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "it_lAC_partner_AC_with_ONG_currently"
INSTEAD OF INSERT ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_partner_AC_with_ONG_currently"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_partner_AC_with_ONG_currently instead of UPDATE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _ONG_currently smallint;
BEGIN
    _ONG_currently := NEW."ONG_ID_currently";
    IF NEW."currently_ONG_Pågående" IS DISTINCT FROM OLD."currently_ONG_Pågående" AND NEW."ONG_ID_currently" IS NOT DISTINCT FROM OLD."ONG_ID_currently" THEN
        _ONG_currently := NULL;
        IF NEW."currently_ONG_Pågående" IS NOT NULL THEN
            SELECT
                k."ONG_ID"
            INTO
                _ONG_currently
            FROM
                knots."ONG_Pågående" k
            WHERE
                k."ONG_Pågående" = NEW."currently_ONG_Pågående"
            LIMIT 1;
        END IF;
    END IF;
    _positing := CASE
        WHEN NEW."AC_partner_AC_with_ONG_currently_PositedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_PositedAt" THEN NEW."AC_partner_AC_with_ONG_currently_PositedAt"
        ELSE _now
    END;
    IF
        NEW."AC_ID_partner" IS DISTINCT FROM OLD."AC_ID_partner" OR
        NEW."AC_ID_with" IS DISTINCT FROM OLD."AC_ID_with" OR
        _ONG_currently IS DISTINCT FROM OLD."ONG_ID_currently" OR
        NEW."AC_partner_AC_with_ONG_currently_ChangedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_ChangedAt" OR
        NEW."AC_partner_AC_with_ONG_currently_PositedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_PositedAt" OR
        NEW."AC_partner_AC_with_ONG_currently_Reliability" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_Reliability"
    THEN
        IF
            NEW."AC_ID_partner" IS NOT NULL
        AND
            NEW."AC_ID_with" IS NOT NULL
        AND
            _ONG_currently IS NOT NULL
        THEN
            INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
                "Metadata_AC_partner_AC_with_ONG_currently",
                "AC_ID_partner",
                "AC_ID_with",
                "ONG_ID_currently",
                "AC_partner_AC_with_ONG_currently_ChangedAt",
                "AC_partner_AC_with_ONG_currently_PositedAt",
                "AC_partner_AC_with_ONG_currently_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_partner_AC_with_ONG_currently",
                NEW."AC_ID_partner",
                NEW."AC_ID_with",
                _ONG_currently,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt" IS DISTINCT FROM OLD."AC_partner_AC_with_ONG_currently_ChangedAt" THEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt"
                    WHEN
                        NEW."AC_ID_partner" = OLD."AC_ID_partner"
                    AND
                        NEW."AC_ID_with" = OLD."AC_ID_with"
                    AND
                        _ONG_currently = OLD."ONG_ID_currently"
                    THEN NEW."AC_partner_AC_with_ONG_currently_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."AC_partner_AC_with_ONG_currently_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_partner_AC_with_ONG_currently" (
                "Metadata_AC_partner_AC_with_ONG_currently",
                "AC_ID_partner",
                "AC_ID_with",
                "ONG_ID_currently",
                "AC_partner_AC_with_ONG_currently_ChangedAt",
                "AC_partner_AC_with_ONG_currently_PositedAt",
                "AC_partner_AC_with_ONG_currently_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_partner_AC_with_ONG_currently",
                OLD."AC_ID_partner",
                OLD."AC_ID_with",
                OLD."ONG_ID_currently",
                OLD."AC_partner_AC_with_ONG_currently_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "ut_lAC_partner_AC_with_ONG_currently"
INSTEAD OF UPDATE ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_partner_AC_with_ONG_currently"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_partner_AC_with_ONG_currently instead of DELETE trigger on lAC_partner_AC_with_ONG_currently
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_partner_AC_with_ONG_currently"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_partner_AC_with_ONG_currently_Annex" (
        "Metadata_AC_partner_AC_with_ONG_currently",
        "AC_partner_AC_with_ONG_currently_ID",
        "AC_partner_AC_with_ONG_currently_PositedAt",
        "AC_partner_AC_with_ONG_currently_Reliability"
    )
    SELECT
        OLD."Metadata_AC_partner_AC_with_ONG_currently",
        OLD."AC_partner_AC_with_ONG_currently_ID",
        _now,
        0
    WHERE
        OLD."AC_partner_AC_with_ONG_currently_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_partner_AC_with_ONG_currently" ON ties."lAC_partner_AC_with_ONG_currently";
CREATE TRIGGER "dt_lAC_partner_AC_with_ONG_currently"
INSTEAD OF DELETE ON ties."lAC_partner_AC_with_ONG_currently"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_partner_AC_with_ONG_currently"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_subset_PN_of tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_subset_PN_of"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_subset_PN_of_Reliability" = 1
            FROM
                ties."AC_subset_PN_of_Annex" a
            WHERE
                a."AC_subset_PN_of_ID" = _id
            AND
                a."AC_subset_PN_of_PositedAt" <= _positing
            ORDER BY
                a."AC_subset_PN_of_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_subset_PN_of instead of INSERT trigger on AC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_subset_PN_of"()
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
    _positing := coalesce(NEW."AC_subset_PN_of_PositedAt", _now);
    _reliability := coalesce(NEW."AC_subset_PN_of_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."AC_subset_PN_of_ID"
    INTO
        _posit
    FROM
        ties."AC_subset_PN_of_Posit" p
    WHERE
        p."AC_ID_subset" = NEW."AC_ID_subset"
    AND
        p."PN_ID_of" = NEW."PN_ID_of"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_subset_PN_of_Annex" a
        WHERE
            a."AC_subset_PN_of_ID" = _posit
        AND
            a."AC_subset_PN_of_PositedAt" = _positing
        AND
            a."AC_subset_PN_of_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_subset_PN_of for: %', concat_ws(', ',
            NEW."AC_ID_subset",
            NEW."PN_ID_of",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_subset_PN_of_Annex" a
        WHERE
            a."AC_subset_PN_of_ID" = _posit
        AND
            a."AC_subset_PN_of_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_subset_PN_of"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_subset_PN_of_Annex" (
            "Metadata_AC_subset_PN_of",
            "AC_subset_PN_of_ID",
            "AC_subset_PN_of_PositedAt",
            "AC_subset_PN_of_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_subset_PN_of", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_subset_PN_of_Posit" (
            "AC_ID_subset",
            "PN_ID_of",
            "AC_subset_PN_of_ID"
        )
        VALUES (
            NEW."AC_ID_subset",
            NEW."PN_ID_of",
            DEFAULT
        )
        RETURNING "AC_subset_PN_of_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_subset_PN_of_Annex" (
        "Metadata_AC_subset_PN_of",
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_subset_PN_of", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_subset_PN_of" ON ties."AC_subset_PN_of";
CREATE TRIGGER "it_AC_subset_PN_of"
INSTEAD OF INSERT ON ties."AC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_subset_PN_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_subset_PN_of instead of INSERT trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_subset_PN_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_subset_PN_of" (
        "Metadata_AC_subset_PN_of",
        "AC_ID_subset",
        "PN_ID_of",
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_subset_PN_of",
        NEW."AC_ID_subset",
        NEW."PN_ID_of",
        coalesce(NEW."AC_subset_PN_of_PositedAt", _now),
        coalesce(NEW."AC_subset_PN_of_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "it_lAC_subset_PN_of"
INSTEAD OF INSERT ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_subset_PN_of"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_subset_PN_of instead of UPDATE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_subset_PN_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
BEGIN
    _positing := CASE
        WHEN NEW."AC_subset_PN_of_PositedAt" IS DISTINCT FROM OLD."AC_subset_PN_of_PositedAt" THEN NEW."AC_subset_PN_of_PositedAt"
        ELSE _now
    END;
    IF
        NEW."AC_ID_subset" IS DISTINCT FROM OLD."AC_ID_subset" OR
        NEW."PN_ID_of" IS DISTINCT FROM OLD."PN_ID_of" OR
        NEW."AC_subset_PN_of_PositedAt" IS DISTINCT FROM OLD."AC_subset_PN_of_PositedAt" OR
        NEW."AC_subset_PN_of_Reliability" IS DISTINCT FROM OLD."AC_subset_PN_of_Reliability"
    THEN
        IF
            NEW."AC_ID_subset" IS NOT NULL
        AND
            NEW."PN_ID_of" IS NOT NULL
        THEN
            INSERT INTO ties."AC_subset_PN_of" (
                "Metadata_AC_subset_PN_of",
                "AC_ID_subset",
                "PN_ID_of",
                "AC_subset_PN_of_PositedAt",
                "AC_subset_PN_of_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_subset_PN_of",
                NEW."AC_ID_subset",
                NEW."PN_ID_of",
                _positing,
                coalesce(NEW."AC_subset_PN_of_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_subset_PN_of" (
                "Metadata_AC_subset_PN_of",
                "AC_ID_subset",
                "PN_ID_of",
                "AC_subset_PN_of_PositedAt",
                "AC_subset_PN_of_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_subset_PN_of",
                OLD."AC_ID_subset",
                OLD."PN_ID_of",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "ut_lAC_subset_PN_of"
INSTEAD OF UPDATE ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_subset_PN_of"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_subset_PN_of instead of DELETE trigger on lAC_subset_PN_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_subset_PN_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_subset_PN_of_Annex" (
        "Metadata_AC_subset_PN_of",
        "AC_subset_PN_of_ID",
        "AC_subset_PN_of_PositedAt",
        "AC_subset_PN_of_Reliability"
    )
    SELECT
        OLD."Metadata_AC_subset_PN_of",
        OLD."AC_subset_PN_of_ID",
        _now,
        0
    WHERE
        OLD."AC_subset_PN_of_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_subset_PN_of" ON ties."lAC_subset_PN_of";
CREATE TRIGGER "dt_lAC_subset_PN_of"
INSTEAD OF DELETE ON ties."lAC_subset_PN_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_subset_PN_of"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_EV_in_AC_rollsattes tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_EV_in_AC_rollsattes"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."EV_in_AC_rollsattes_Reliability" = 1
            FROM
                ties."EV_in_AC_rollsattes_Annex" a
            WHERE
                a."EV_in_AC_rollsattes_ID" = _id
            AND
                a."EV_in_AC_rollsattes_PositedAt" <= _positing
            ORDER BY
                a."EV_in_AC_rollsattes_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_EV_in_AC_rollsattes instead of INSERT trigger on EV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_EV_in_AC_rollsattes"()
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
    _positing := coalesce(NEW."EV_in_AC_rollsattes_PositedAt", _now);
    _reliability := coalesce(NEW."EV_in_AC_rollsattes_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."EV_in_AC_rollsattes_ID"
    INTO
        _posit
    FROM
        ties."EV_in_AC_rollsattes_Posit" p
    WHERE
        p."EV_ID_in" = NEW."EV_ID_in"
    AND
        p."AC_ID_rollsattes" = NEW."AC_ID_rollsattes"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_rollsattes_Annex" a
        WHERE
            a."EV_in_AC_rollsattes_ID" = _posit
        AND
            a."EV_in_AC_rollsattes_PositedAt" = _positing
        AND
            a."EV_in_AC_rollsattes_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in EV_in_AC_rollsattes for: %', concat_ws(', ',
            NEW."EV_ID_in",
            NEW."AC_ID_rollsattes",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."EV_in_AC_rollsattes_Annex" a
        WHERE
            a."EV_in_AC_rollsattes_ID" = _posit
        AND
            a."EV_in_AC_rollsattes_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_EV_in_AC_rollsattes"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."EV_in_AC_rollsattes_Annex" (
            "Metadata_EV_in_AC_rollsattes",
            "EV_in_AC_rollsattes_ID",
            "EV_in_AC_rollsattes_PositedAt",
            "EV_in_AC_rollsattes_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_EV_in_AC_rollsattes", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."EV_in_AC_rollsattes_Posit" (
            "EV_ID_in",
            "AC_ID_rollsattes",
            "EV_in_AC_rollsattes_ID"
        )
        VALUES (
            NEW."EV_ID_in",
            NEW."AC_ID_rollsattes",
            DEFAULT
        )
        RETURNING "EV_in_AC_rollsattes_ID" INTO _posit;
    END IF;
    INSERT INTO ties."EV_in_AC_rollsattes_Annex" (
        "Metadata_EV_in_AC_rollsattes",
        "EV_in_AC_rollsattes_ID",
        "EV_in_AC_rollsattes_PositedAt",
        "EV_in_AC_rollsattes_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_EV_in_AC_rollsattes", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_EV_in_AC_rollsattes" ON ties."EV_in_AC_rollsattes";
CREATE TRIGGER "it_EV_in_AC_rollsattes"
INSTEAD OF INSERT ON ties."EV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."it_EV_in_AC_rollsattes"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lEV_in_AC_rollsattes instead of INSERT trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lEV_in_AC_rollsattes"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."EV_in_AC_rollsattes" (
        "Metadata_EV_in_AC_rollsattes",
        "EV_ID_in",
        "AC_ID_rollsattes",
        "EV_in_AC_rollsattes_PositedAt",
        "EV_in_AC_rollsattes_Reliability"
    )
    VALUES (
        NEW."Metadata_EV_in_AC_rollsattes",
        NEW."EV_ID_in",
        NEW."AC_ID_rollsattes",
        coalesce(NEW."EV_in_AC_rollsattes_PositedAt", _now),
        coalesce(NEW."EV_in_AC_rollsattes_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lEV_in_AC_rollsattes" ON ties."lEV_in_AC_rollsattes";
CREATE TRIGGER "it_lEV_in_AC_rollsattes"
INSTEAD OF INSERT ON ties."lEV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."it_lEV_in_AC_rollsattes"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lEV_in_AC_rollsattes instead of DELETE trigger on lEV_in_AC_rollsattes
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lEV_in_AC_rollsattes"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."EV_in_AC_rollsattes_Annex" (
        "Metadata_EV_in_AC_rollsattes",
        "EV_in_AC_rollsattes_ID",
        "EV_in_AC_rollsattes_PositedAt",
        "EV_in_AC_rollsattes_Reliability"
    )
    SELECT
        OLD."Metadata_EV_in_AC_rollsattes",
        OLD."EV_in_AC_rollsattes_ID",
        _now,
        0
    WHERE
        OLD."EV_in_AC_rollsattes_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lEV_in_AC_rollsattes" ON ties."lEV_in_AC_rollsattes";
CREATE TRIGGER "dt_lEV_in_AC_rollsattes"
INSTEAD OF DELETE ON ties."lEV_in_AC_rollsattes"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lEV_in_AC_rollsattes"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_deltar_PR_in_RAT_fick tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_deltar_PR_in_RAT_fick"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_deltar_PR_in_RAT_fick_Reliability" = 1
            FROM
                ties."AC_deltar_PR_in_RAT_fick_Annex" a
            WHERE
                a."AC_deltar_PR_in_RAT_fick_ID" = _id
            AND
                a."AC_deltar_PR_in_RAT_fick_PositedAt" <= _positing
            ORDER BY
                a."AC_deltar_PR_in_RAT_fick_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_deltar_PR_in_RAT_fick instead of INSERT trigger on AC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_deltar_PR_in_RAT_fick"()
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
    _positing := coalesce(NEW."AC_deltar_PR_in_RAT_fick_PositedAt", _now);
    _reliability := coalesce(NEW."AC_deltar_PR_in_RAT_fick_Reliability", 1);
    _changing := coalesce(NEW."AC_deltar_PR_in_RAT_fick_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."AC_deltar_PR_in_RAT_fick_ID"
    INTO
        _posit
    FROM
        ties."AC_deltar_PR_in_RAT_fick_Posit" p
    WHERE
        p."AC_ID_deltar" = NEW."AC_ID_deltar"
    AND
        p."PR_ID_in" = NEW."PR_ID_in"
    AND
        p."RAT_ID_fick" = NEW."RAT_ID_fick"
    AND
        p."AC_deltar_PR_in_RAT_fick_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Annex" a
        WHERE
            a."AC_deltar_PR_in_RAT_fick_ID" = _posit
        AND
            a."AC_deltar_PR_in_RAT_fick_PositedAt" = _positing
        AND
            a."AC_deltar_PR_in_RAT_fick_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_deltar_PR_in_RAT_fick for: %', concat_ws(', ',
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            NEW."RAT_ID_fick",
            _changing,
            _positing);
    END IF;
    -- other values for identifiers that already have values at that time, asserted at the positing time, are a contradiction
    IF _reliability = 1 AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Posit" p
        JOIN
            ties."AC_deltar_PR_in_RAT_fick_Annex" a
        ON
            a."AC_deltar_PR_in_RAT_fick_ID" = p."AC_deltar_PR_in_RAT_fick_ID"
        WHERE
            p."AC_ID_deltar" = NEW."AC_ID_deltar"
        AND
            p."PR_ID_in" = NEW."PR_ID_in"
        AND
            p."AC_deltar_PR_in_RAT_fick_ChangedAt" = _changing
        AND
            NOT (
                p."RAT_ID_fick" = NEW."RAT_ID_fick"
            )
        AND
            a."AC_deltar_PR_in_RAT_fick_PositedAt" = _positing
        AND
            a."AC_deltar_PR_in_RAT_fick_Reliability" = 1
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_deltar_PR_in_RAT_fick for: %', concat_ws(', ',
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            NEW."RAT_ID_fick",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Annex" a
        WHERE
            a."AC_deltar_PR_in_RAT_fick_ID" = _posit
        AND
            a."AC_deltar_PR_in_RAT_fick_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_deltar_PR_in_RAT_fick"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Annex" (
            "Metadata_AC_deltar_PR_in_RAT_fick",
            "AC_deltar_PR_in_RAT_fick_ID",
            "AC_deltar_PR_in_RAT_fick_PositedAt",
            "AC_deltar_PR_in_RAT_fick_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_deltar_PR_in_RAT_fick", 0),
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
            p."AC_deltar_PR_in_RAT_fick_ID"
        FROM
            ties."AC_deltar_PR_in_RAT_fick_Posit" p
        WHERE
            p."AC_ID_deltar" = NEW."AC_ID_deltar"
        AND
            p."PR_ID_in" = NEW."PR_ID_in"
        AND
            p."AC_deltar_PR_in_RAT_fick_ChangedAt" = _changing
        AND
            NOT (
                p."RAT_ID_fick" = NEW."RAT_ID_fick"
            )
        AND
            ties."ie_AC_deltar_PR_in_RAT_fick"(p."AC_deltar_PR_in_RAT_fick_ID", _positing)
    LOOP
        INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Annex" (
            "Metadata_AC_deltar_PR_in_RAT_fick",
            "AC_deltar_PR_in_RAT_fick_ID",
            "AC_deltar_PR_in_RAT_fick_PositedAt",
            "AC_deltar_PR_in_RAT_fick_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_deltar_PR_in_RAT_fick", 0),
            _other,
            _positing,
            0
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Posit" (
            "AC_ID_deltar",
            "PR_ID_in",
            "RAT_ID_fick",
            "AC_deltar_PR_in_RAT_fick_ChangedAt"
        )
        VALUES (
            NEW."AC_ID_deltar",
            NEW."PR_ID_in",
            NEW."RAT_ID_fick",
            _changing
        )
        RETURNING "AC_deltar_PR_in_RAT_fick_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Annex" (
        "Metadata_AC_deltar_PR_in_RAT_fick",
        "AC_deltar_PR_in_RAT_fick_ID",
        "AC_deltar_PR_in_RAT_fick_PositedAt",
        "AC_deltar_PR_in_RAT_fick_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_deltar_PR_in_RAT_fick", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_deltar_PR_in_RAT_fick" ON ties."AC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "it_AC_deltar_PR_in_RAT_fick"
INSTEAD OF INSERT ON ties."AC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_deltar_PR_in_RAT_fick"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_deltar_PR_in_RAT_fick instead of INSERT trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
        "Metadata_AC_deltar_PR_in_RAT_fick",
        "AC_ID_deltar",
        "PR_ID_in",
        "RAT_ID_fick",
        "AC_deltar_PR_in_RAT_fick_ChangedAt",
        "AC_deltar_PR_in_RAT_fick_PositedAt",
        "AC_deltar_PR_in_RAT_fick_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_deltar_PR_in_RAT_fick",
        NEW."AC_ID_deltar",
        NEW."PR_ID_in",
        coalesce(NEW."RAT_ID_fick", (
            SELECT
                k."RAT_ID"
            FROM
                knots."RAT_Betyg" k
            WHERE
                k."RAT_Betyg" = NEW."fick_RAT_Betyg"
            LIMIT 1
        )),
        coalesce(NEW."AC_deltar_PR_in_RAT_fick_ChangedAt", _now),
        coalesce(NEW."AC_deltar_PR_in_RAT_fick_PositedAt", _now),
        coalesce(NEW."AC_deltar_PR_in_RAT_fick_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_deltar_PR_in_RAT_fick" ON ties."lAC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "it_lAC_deltar_PR_in_RAT_fick"
INSTEAD OF INSERT ON ties."lAC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_deltar_PR_in_RAT_fick"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lAC_deltar_PR_in_RAT_fick instead of UPDATE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lAC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
    _RAT_fick smallint;
BEGIN
    IF NEW."AC_ID_deltar" IS DISTINCT FROM OLD."AC_ID_deltar" THEN
        RAISE EXCEPTION 'The identity column AC_ID_deltar is not updatable.';
    END IF;
    IF NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" THEN
        RAISE EXCEPTION 'The identity column PR_ID_in is not updatable.';
    END IF;
    _RAT_fick := NEW."RAT_ID_fick";
    IF NEW."fick_RAT_Betyg" IS DISTINCT FROM OLD."fick_RAT_Betyg" AND NEW."RAT_ID_fick" IS NOT DISTINCT FROM OLD."RAT_ID_fick" THEN
        _RAT_fick := NULL;
        IF NEW."fick_RAT_Betyg" IS NOT NULL THEN
            SELECT
                k."RAT_ID"
            INTO
                _RAT_fick
            FROM
                knots."RAT_Betyg" k
            WHERE
                k."RAT_Betyg" = NEW."fick_RAT_Betyg"
            LIMIT 1;
        END IF;
    END IF;
    _positing := CASE
        WHEN NEW."AC_deltar_PR_in_RAT_fick_PositedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_PositedAt" THEN NEW."AC_deltar_PR_in_RAT_fick_PositedAt"
        ELSE _now
    END;
    IF
        NEW."AC_ID_deltar" IS DISTINCT FROM OLD."AC_ID_deltar" OR
        NEW."PR_ID_in" IS DISTINCT FROM OLD."PR_ID_in" OR
        _RAT_fick IS DISTINCT FROM OLD."RAT_ID_fick" OR
        NEW."AC_deltar_PR_in_RAT_fick_ChangedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_ChangedAt" OR
        NEW."AC_deltar_PR_in_RAT_fick_PositedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_PositedAt" OR
        NEW."AC_deltar_PR_in_RAT_fick_Reliability" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_Reliability"
    THEN
        IF
            NEW."AC_ID_deltar" IS NOT NULL
        AND
            NEW."PR_ID_in" IS NOT NULL
        AND
            _RAT_fick IS NOT NULL
        THEN
            INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
                "Metadata_AC_deltar_PR_in_RAT_fick",
                "AC_ID_deltar",
                "PR_ID_in",
                "RAT_ID_fick",
                "AC_deltar_PR_in_RAT_fick_ChangedAt",
                "AC_deltar_PR_in_RAT_fick_PositedAt",
                "AC_deltar_PR_in_RAT_fick_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_deltar_PR_in_RAT_fick",
                NEW."AC_ID_deltar",
                NEW."PR_ID_in",
                _RAT_fick,
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt" IS DISTINCT FROM OLD."AC_deltar_PR_in_RAT_fick_ChangedAt" THEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
                    WHEN
                        NEW."AC_ID_deltar" = OLD."AC_ID_deltar"
                    AND
                        NEW."PR_ID_in" = OLD."PR_ID_in"
                    AND
                        _RAT_fick = OLD."RAT_ID_fick"
                    THEN NEW."AC_deltar_PR_in_RAT_fick_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."AC_deltar_PR_in_RAT_fick_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."AC_deltar_PR_in_RAT_fick" (
                "Metadata_AC_deltar_PR_in_RAT_fick",
                "AC_ID_deltar",
                "PR_ID_in",
                "RAT_ID_fick",
                "AC_deltar_PR_in_RAT_fick_ChangedAt",
                "AC_deltar_PR_in_RAT_fick_PositedAt",
                "AC_deltar_PR_in_RAT_fick_Reliability"
            )
            VALUES (
                NEW."Metadata_AC_deltar_PR_in_RAT_fick",
                OLD."AC_ID_deltar",
                OLD."PR_ID_in",
                OLD."RAT_ID_fick",
                OLD."AC_deltar_PR_in_RAT_fick_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lAC_deltar_PR_in_RAT_fick" ON ties."lAC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "ut_lAC_deltar_PR_in_RAT_fick"
INSTEAD OF UPDATE ON ties."lAC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lAC_deltar_PR_in_RAT_fick"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_deltar_PR_in_RAT_fick instead of DELETE trigger on lAC_deltar_PR_in_RAT_fick
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_deltar_PR_in_RAT_fick"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_deltar_PR_in_RAT_fick_Annex" (
        "Metadata_AC_deltar_PR_in_RAT_fick",
        "AC_deltar_PR_in_RAT_fick_ID",
        "AC_deltar_PR_in_RAT_fick_PositedAt",
        "AC_deltar_PR_in_RAT_fick_Reliability"
    )
    SELECT
        OLD."Metadata_AC_deltar_PR_in_RAT_fick",
        OLD."AC_deltar_PR_in_RAT_fick_ID",
        _now,
        0
    WHERE
        OLD."AC_deltar_PR_in_RAT_fick_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_deltar_PR_in_RAT_fick" ON ties."lAC_deltar_PR_in_RAT_fick";
CREATE TRIGGER "dt_lAC_deltar_PR_in_RAT_fick"
INSTEAD OF DELETE ON ties."lAC_deltar_PR_in_RAT_fick"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_deltar_PR_in_RAT_fick"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_ST_at_PR_spelas tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_ST_at_PR_spelas"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."ST_at_PR_spelas_Reliability" = 1
            FROM
                ties."ST_at_PR_spelas_Annex" a
            WHERE
                a."ST_at_PR_spelas_ID" = _id
            AND
                a."ST_at_PR_spelas_PositedAt" <= _positing
            ORDER BY
                a."ST_at_PR_spelas_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_ST_at_PR_spelas instead of INSERT trigger on ST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_ST_at_PR_spelas"()
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
    _positing := coalesce(NEW."ST_at_PR_spelas_PositedAt", _now);
    _reliability := coalesce(NEW."ST_at_PR_spelas_Reliability", 1);
    _changing := coalesce(NEW."ST_at_PR_spelas_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."ST_at_PR_spelas_ID"
    INTO
        _posit
    FROM
        ties."ST_at_PR_spelas_Posit" p
    WHERE
        p."ST_ID_at" = NEW."ST_ID_at"
    AND
        p."PR_ID_spelas" = NEW."PR_ID_spelas"
    AND
        p."ST_at_PR_spelas_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_spelas_Annex" a
        WHERE
            a."ST_at_PR_spelas_ID" = _posit
        AND
            a."ST_at_PR_spelas_PositedAt" = _positing
        AND
            a."ST_at_PR_spelas_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in ST_at_PR_spelas for: %', concat_ws(', ',
            NEW."ST_ID_at",
            NEW."PR_ID_spelas",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."ST_at_PR_spelas_Annex" a
        WHERE
            a."ST_at_PR_spelas_ID" = _posit
        AND
            a."ST_at_PR_spelas_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_ST_at_PR_spelas"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."ST_at_PR_spelas_Annex" (
            "Metadata_ST_at_PR_spelas",
            "ST_at_PR_spelas_ID",
            "ST_at_PR_spelas_PositedAt",
            "ST_at_PR_spelas_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_ST_at_PR_spelas", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."ST_at_PR_spelas_Posit" (
            "ST_ID_at",
            "PR_ID_spelas",
            "ST_at_PR_spelas_ChangedAt"
        )
        VALUES (
            NEW."ST_ID_at",
            NEW."PR_ID_spelas",
            _changing
        )
        RETURNING "ST_at_PR_spelas_ID" INTO _posit;
    END IF;
    INSERT INTO ties."ST_at_PR_spelas_Annex" (
        "Metadata_ST_at_PR_spelas",
        "ST_at_PR_spelas_ID",
        "ST_at_PR_spelas_PositedAt",
        "ST_at_PR_spelas_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_ST_at_PR_spelas", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_ST_at_PR_spelas" ON ties."ST_at_PR_spelas";
CREATE TRIGGER "it_ST_at_PR_spelas"
INSTEAD OF INSERT ON ties."ST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."it_ST_at_PR_spelas"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lST_at_PR_spelas instead of INSERT trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lST_at_PR_spelas"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."ST_at_PR_spelas" (
        "Metadata_ST_at_PR_spelas",
        "ST_ID_at",
        "PR_ID_spelas",
        "ST_at_PR_spelas_ChangedAt",
        "ST_at_PR_spelas_PositedAt",
        "ST_at_PR_spelas_Reliability"
    )
    VALUES (
        NEW."Metadata_ST_at_PR_spelas",
        NEW."ST_ID_at",
        NEW."PR_ID_spelas",
        coalesce(NEW."ST_at_PR_spelas_ChangedAt", _now),
        coalesce(NEW."ST_at_PR_spelas_PositedAt", _now),
        coalesce(NEW."ST_at_PR_spelas_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lST_at_PR_spelas" ON ties."lST_at_PR_spelas";
CREATE TRIGGER "it_lST_at_PR_spelas"
INSTEAD OF INSERT ON ties."lST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."it_lST_at_PR_spelas"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lST_at_PR_spelas instead of DELETE trigger on lST_at_PR_spelas
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lST_at_PR_spelas"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."ST_at_PR_spelas_Annex" (
        "Metadata_ST_at_PR_spelas",
        "ST_at_PR_spelas_ID",
        "ST_at_PR_spelas_PositedAt",
        "ST_at_PR_spelas_Reliability"
    )
    SELECT
        OLD."Metadata_ST_at_PR_spelas",
        OLD."ST_at_PR_spelas_ID",
        _now,
        0
    WHERE
        OLD."ST_at_PR_spelas_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lST_at_PR_spelas" ON ties."lST_at_PR_spelas";
CREATE TRIGGER "dt_lST_at_PR_spelas"
INSTEAD OF DELETE ON ties."lST_at_PR_spelas"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lST_at_PR_spelas"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_AC_förälder_AC_barn_PAT_har tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_AC_förälder_AC_barn_PAT_har"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."AC_förälder_AC_barn_PAT_har_Reliability" = 1
            FROM
                ties."AC_förälder_AC_barn_PAT_har_Annex" a
            WHERE
                a."AC_förälder_AC_barn_PAT_har_ID" = _id
            AND
                a."AC_förälder_AC_barn_PAT_har_PositedAt" <= _positing
            ORDER BY
                a."AC_förälder_AC_barn_PAT_har_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_AC_förälder_AC_barn_PAT_har instead of INSERT trigger on AC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_AC_förälder_AC_barn_PAT_har"()
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
    _positing := coalesce(NEW."AC_förälder_AC_barn_PAT_har_PositedAt", _now);
    _reliability := coalesce(NEW."AC_förälder_AC_barn_PAT_har_Reliability", 1);
    -- the posit, if there is one
    SELECT
        p."AC_förälder_AC_barn_PAT_har_ID"
    INTO
        _posit
    FROM
        ties."AC_förälder_AC_barn_PAT_har_Posit" p
    WHERE
        p."AC_ID_förälder" = NEW."AC_ID_förälder"
    AND
        p."AC_ID_barn" = NEW."AC_ID_barn"
    AND
        p."PAT_ID_har" = NEW."PAT_ID_har"
    AND
        true
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_förälder_AC_barn_PAT_har_Annex" a
        WHERE
            a."AC_förälder_AC_barn_PAT_har_ID" = _posit
        AND
            a."AC_förälder_AC_barn_PAT_har_PositedAt" = _positing
        AND
            a."AC_förälder_AC_barn_PAT_har_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in AC_förälder_AC_barn_PAT_har for: %', concat_ws(', ',
            NEW."AC_ID_förälder",
            NEW."AC_ID_barn",
            NEW."PAT_ID_har",
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."AC_förälder_AC_barn_PAT_har_Annex" a
        WHERE
            a."AC_förälder_AC_barn_PAT_har_ID" = _posit
        AND
            a."AC_förälder_AC_barn_PAT_har_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_AC_förälder_AC_barn_PAT_har"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."AC_förälder_AC_barn_PAT_har_Annex" (
            "Metadata_AC_förälder_AC_barn_PAT_har",
            "AC_förälder_AC_barn_PAT_har_ID",
            "AC_förälder_AC_barn_PAT_har_PositedAt",
            "AC_förälder_AC_barn_PAT_har_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_AC_förälder_AC_barn_PAT_har", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."AC_förälder_AC_barn_PAT_har_Posit" (
            "AC_ID_förälder",
            "AC_ID_barn",
            "PAT_ID_har",
            "AC_förälder_AC_barn_PAT_har_ID"
        )
        VALUES (
            NEW."AC_ID_förälder",
            NEW."AC_ID_barn",
            NEW."PAT_ID_har",
            DEFAULT
        )
        RETURNING "AC_förälder_AC_barn_PAT_har_ID" INTO _posit;
    END IF;
    INSERT INTO ties."AC_förälder_AC_barn_PAT_har_Annex" (
        "Metadata_AC_förälder_AC_barn_PAT_har",
        "AC_förälder_AC_barn_PAT_har_ID",
        "AC_förälder_AC_barn_PAT_har_PositedAt",
        "AC_förälder_AC_barn_PAT_har_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_AC_förälder_AC_barn_PAT_har", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_AC_förälder_AC_barn_PAT_har" ON ties."AC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "it_AC_förälder_AC_barn_PAT_har"
INSTEAD OF INSERT ON ties."AC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."it_AC_förälder_AC_barn_PAT_har"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lAC_förälder_AC_barn_PAT_har instead of INSERT trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lAC_förälder_AC_barn_PAT_har"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."AC_förälder_AC_barn_PAT_har" (
        "Metadata_AC_förälder_AC_barn_PAT_har",
        "AC_ID_förälder",
        "AC_ID_barn",
        "PAT_ID_har",
        "AC_förälder_AC_barn_PAT_har_PositedAt",
        "AC_förälder_AC_barn_PAT_har_Reliability"
    )
    VALUES (
        NEW."Metadata_AC_förälder_AC_barn_PAT_har",
        NEW."AC_ID_förälder",
        NEW."AC_ID_barn",
        coalesce(NEW."PAT_ID_har", (
            SELECT
                k."PAT_ID"
            FROM
                knots."PAT_Föräldratyp" k
            WHERE
                k."PAT_Föräldratyp" = NEW."har_PAT_Föräldratyp"
            LIMIT 1
        )),
        coalesce(NEW."AC_förälder_AC_barn_PAT_har_PositedAt", _now),
        coalesce(NEW."AC_förälder_AC_barn_PAT_har_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lAC_förälder_AC_barn_PAT_har" ON ties."lAC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "it_lAC_förälder_AC_barn_PAT_har"
INSTEAD OF INSERT ON ties."lAC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."it_lAC_förälder_AC_barn_PAT_har"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lAC_förälder_AC_barn_PAT_har instead of DELETE trigger on lAC_förälder_AC_barn_PAT_har
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lAC_förälder_AC_barn_PAT_har"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."AC_förälder_AC_barn_PAT_har_Annex" (
        "Metadata_AC_förälder_AC_barn_PAT_har",
        "AC_förälder_AC_barn_PAT_har_ID",
        "AC_förälder_AC_barn_PAT_har_PositedAt",
        "AC_förälder_AC_barn_PAT_har_Reliability"
    )
    SELECT
        OLD."Metadata_AC_förälder_AC_barn_PAT_har",
        OLD."AC_förälder_AC_barn_PAT_har_ID",
        _now,
        0
    WHERE
        OLD."AC_förälder_AC_barn_PAT_har_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lAC_förälder_AC_barn_PAT_har" ON ties."lAC_förälder_AC_barn_PAT_har";
CREATE TRIGGER "dt_lAC_förälder_AC_barn_PAT_har"
INSTEAD OF DELETE ON ties."lAC_förälder_AC_barn_PAT_har"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lAC_förälder_AC_barn_PAT_har"();
-- In effect ------------------------------------------------------------------------------------------------------------
-- ie_PR_innehåll_ST_plats_EV_of tells whether a posit is asserted at a positing time: its latest annex row up to then asserts it
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ie_PR_innehåll_ST_plats_EV_of"(
    _id integer,
    _positing timestamp
)
RETURNS boolean
AS
$$
    SELECT
        coalesce((
            SELECT
                a."PR_innehåll_ST_plats_EV_of_Reliability" = 1
            FROM
                ties."PR_innehåll_ST_plats_EV_of_Annex" a
            WHERE
                a."PR_innehåll_ST_plats_EV_of_ID" = _id
            AND
                a."PR_innehåll_ST_plats_EV_of_PositedAt" <= _positing
            ORDER BY
                a."PR_innehåll_ST_plats_EV_of_PositedAt" DESC
            LIMIT 1
        ), false)
$$ LANGUAGE sql STABLE;
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_PR_innehåll_ST_plats_EV_of instead of INSERT trigger on PR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_PR_innehåll_ST_plats_EV_of"()
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
    _positing := coalesce(NEW."PR_innehåll_ST_plats_EV_of_PositedAt", _now);
    _reliability := coalesce(NEW."PR_innehåll_ST_plats_EV_of_Reliability", 1);
    _changing := coalesce(NEW."PR_innehåll_ST_plats_EV_of_ChangedAt", _now);
    -- the posit, if there is one
    SELECT
        p."PR_innehåll_ST_plats_EV_of_ID"
    INTO
        _posit
    FROM
        ties."PR_innehåll_ST_plats_EV_of_Posit" p
    WHERE
        p."PR_ID_innehåll" = NEW."PR_ID_innehåll"
    AND
        p."ST_ID_plats" = NEW."ST_ID_plats"
    AND
        p."EV_ID_of" = NEW."EV_ID_of"
    AND
        p."PR_innehåll_ST_plats_EV_of_ChangedAt" = _changing
    LIMIT 1;
    -- another reliability at a positing time that already has an assertion of the posit is a contradiction
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."PR_innehåll_ST_plats_EV_of_Annex" a
        WHERE
            a."PR_innehåll_ST_plats_EV_of_ID" = _posit
        AND
            a."PR_innehåll_ST_plats_EV_of_PositedAt" = _positing
        AND
            a."PR_innehåll_ST_plats_EV_of_Reliability" <> _reliability
    ) THEN
        RAISE EXCEPTION 'Contradiction in PR_innehåll_ST_plats_EV_of for: %', concat_ws(', ',
            NEW."PR_ID_innehåll",
            NEW."ST_ID_plats",
            NEW."EV_ID_of",
            _changing,
            _positing);
    END IF;
    -- the identical (the posit and the assertion are there already) states nothing
    IF _posit IS NOT NULL AND EXISTS (
        SELECT
            1
        FROM
            ties."PR_innehåll_ST_plats_EV_of_Annex" a
        WHERE
            a."PR_innehåll_ST_plats_EV_of_ID" = _posit
        AND
            a."PR_innehåll_ST_plats_EV_of_PositedAt" = _positing
    ) THEN
        RETURN NULL;
    END IF;
    IF _reliability = 0 THEN
        -- a retraction of what is not asserted states nothing
        IF _posit IS NULL OR NOT ties."ie_PR_innehåll_ST_plats_EV_of"(_posit, _positing) THEN
            RETURN NULL;
        END IF;
        INSERT INTO ties."PR_innehåll_ST_plats_EV_of_Annex" (
            "Metadata_PR_innehåll_ST_plats_EV_of",
            "PR_innehåll_ST_plats_EV_of_ID",
            "PR_innehåll_ST_plats_EV_of_PositedAt",
            "PR_innehåll_ST_plats_EV_of_Reliability"
        )
        VALUES (
            coalesce(NEW."Metadata_PR_innehåll_ST_plats_EV_of", 0),
            _posit,
            _positing,
            _reliability
        );
        RETURN NEW;
    END IF;
    -- the posit, which is new when it was not found
    IF _posit IS NULL THEN
        INSERT INTO ties."PR_innehåll_ST_plats_EV_of_Posit" (
            "PR_ID_innehåll",
            "ST_ID_plats",
            "EV_ID_of",
            "PR_innehåll_ST_plats_EV_of_ChangedAt"
        )
        VALUES (
            NEW."PR_ID_innehåll",
            NEW."ST_ID_plats",
            NEW."EV_ID_of",
            _changing
        )
        RETURNING "PR_innehåll_ST_plats_EV_of_ID" INTO _posit;
    END IF;
    INSERT INTO ties."PR_innehåll_ST_plats_EV_of_Annex" (
        "Metadata_PR_innehåll_ST_plats_EV_of",
        "PR_innehåll_ST_plats_EV_of_ID",
        "PR_innehåll_ST_plats_EV_of_PositedAt",
        "PR_innehåll_ST_plats_EV_of_Reliability"
    )
    VALUES (
        coalesce(NEW."Metadata_PR_innehåll_ST_plats_EV_of", 0),
        _posit,
        _positing,
        _reliability
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_PR_innehåll_ST_plats_EV_of" ON ties."PR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "it_PR_innehåll_ST_plats_EV_of"
INSTEAD OF INSERT ON ties."PR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_PR_innehåll_ST_plats_EV_of"();
-- Insert trigger -----------------------------------------------------------------------------------------------------
-- it_lPR_innehåll_ST_plats_EV_of instead of INSERT trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."it_lPR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
        "Metadata_PR_innehåll_ST_plats_EV_of",
        "PR_ID_innehåll",
        "ST_ID_plats",
        "EV_ID_of",
        "PR_innehåll_ST_plats_EV_of_ChangedAt",
        "PR_innehåll_ST_plats_EV_of_PositedAt",
        "PR_innehåll_ST_plats_EV_of_Reliability"
    )
    VALUES (
        NEW."Metadata_PR_innehåll_ST_plats_EV_of",
        NEW."PR_ID_innehåll",
        NEW."ST_ID_plats",
        NEW."EV_ID_of",
        coalesce(NEW."PR_innehåll_ST_plats_EV_of_ChangedAt", _now),
        coalesce(NEW."PR_innehåll_ST_plats_EV_of_PositedAt", _now),
        coalesce(NEW."PR_innehåll_ST_plats_EV_of_Reliability", 1)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "it_lPR_innehåll_ST_plats_EV_of" ON ties."lPR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "it_lPR_innehåll_ST_plats_EV_of"
INSTEAD OF INSERT ON ties."lPR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."it_lPR_innehåll_ST_plats_EV_of"();
-- UPDATE trigger -----------------------------------------------------------------------------------------------------
-- ut_lPR_innehåll_ST_plats_EV_of instead of UPDATE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."ut_lPR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
    _positing timestamp;
BEGIN
    _positing := CASE
        WHEN NEW."PR_innehåll_ST_plats_EV_of_PositedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_PositedAt" THEN NEW."PR_innehåll_ST_plats_EV_of_PositedAt"
        ELSE _now
    END;
    IF
        NEW."PR_ID_innehåll" IS DISTINCT FROM OLD."PR_ID_innehåll" OR
        NEW."ST_ID_plats" IS DISTINCT FROM OLD."ST_ID_plats" OR
        NEW."EV_ID_of" IS DISTINCT FROM OLD."EV_ID_of" OR
        NEW."PR_innehåll_ST_plats_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_ChangedAt" OR
        NEW."PR_innehåll_ST_plats_EV_of_PositedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_PositedAt" OR
        NEW."PR_innehåll_ST_plats_EV_of_Reliability" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_Reliability"
    THEN
        IF
            NEW."PR_ID_innehåll" IS NOT NULL
        AND
            NEW."ST_ID_plats" IS NOT NULL
        AND
            NEW."EV_ID_of" IS NOT NULL
        THEN
            INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
                "Metadata_PR_innehåll_ST_plats_EV_of",
                "PR_ID_innehåll",
                "ST_ID_plats",
                "EV_ID_of",
                "PR_innehåll_ST_plats_EV_of_ChangedAt",
                "PR_innehåll_ST_plats_EV_of_PositedAt",
                "PR_innehåll_ST_plats_EV_of_Reliability"
            )
            VALUES (
                NEW."Metadata_PR_innehåll_ST_plats_EV_of",
                NEW."PR_ID_innehåll",
                NEW."ST_ID_plats",
                NEW."EV_ID_of",
                -- the shown version asserted again keeps its changing time, as does one that is given
                CASE
                    WHEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt" IS DISTINCT FROM OLD."PR_innehåll_ST_plats_EV_of_ChangedAt" THEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt"
                    WHEN
                        NEW."PR_ID_innehåll" = OLD."PR_ID_innehåll"
                    AND
                        NEW."ST_ID_plats" = OLD."ST_ID_plats"
                    AND
                        NEW."EV_ID_of" = OLD."EV_ID_of"
                    THEN NEW."PR_innehåll_ST_plats_EV_of_ChangedAt"
                    ELSE _now
                END,
                _positing,
                coalesce(NEW."PR_innehåll_ST_plats_EV_of_Reliability", 1)
            );
        ELSE
            -- logical delete by setting a value to null: the shown version is retracted
            INSERT INTO ties."PR_innehåll_ST_plats_EV_of" (
                "Metadata_PR_innehåll_ST_plats_EV_of",
                "PR_ID_innehåll",
                "ST_ID_plats",
                "EV_ID_of",
                "PR_innehåll_ST_plats_EV_of_ChangedAt",
                "PR_innehåll_ST_plats_EV_of_PositedAt",
                "PR_innehåll_ST_plats_EV_of_Reliability"
            )
            VALUES (
                NEW."Metadata_PR_innehåll_ST_plats_EV_of",
                OLD."PR_ID_innehåll",
                OLD."ST_ID_plats",
                OLD."EV_ID_of",
                OLD."PR_innehåll_ST_plats_EV_of_ChangedAt",
                _positing,
                0
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "ut_lPR_innehåll_ST_plats_EV_of" ON ties."lPR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "ut_lPR_innehåll_ST_plats_EV_of"
INSTEAD OF UPDATE ON ties."lPR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."ut_lPR_innehåll_ST_plats_EV_of"();
-- DELETE trigger -----------------------------------------------------------------------------------------------------
-- dt_lPR_innehåll_ST_plats_EV_of instead of DELETE trigger on lPR_innehåll_ST_plats_EV_of
-----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ties."dt_lPR_innehåll_ST_plats_EV_of"()
RETURNS trigger
AS
$$
DECLARE
    _now timestamp := current_timestamp::timestamp;
BEGIN
    -- what is shown is retracted
    INSERT INTO ties."PR_innehåll_ST_plats_EV_of_Annex" (
        "Metadata_PR_innehåll_ST_plats_EV_of",
        "PR_innehåll_ST_plats_EV_of_ID",
        "PR_innehåll_ST_plats_EV_of_PositedAt",
        "PR_innehåll_ST_plats_EV_of_Reliability"
    )
    SELECT
        OLD."Metadata_PR_innehåll_ST_plats_EV_of",
        OLD."PR_innehåll_ST_plats_EV_of_ID",
        _now,
        0
    WHERE
        OLD."PR_innehåll_ST_plats_EV_of_ID" IS NOT NULL
    ON CONFLICT DO NOTHING;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS "dt_lPR_innehåll_ST_plats_EV_of" ON ties."lPR_innehåll_ST_plats_EV_of";
CREATE TRIGGER "dt_lPR_innehåll_ST_plats_EV_of"
INSTEAD OF DELETE ON ties."lPR_innehåll_ST_plats_EV_of"
FOR EACH ROW EXECUTE FUNCTION ties."dt_lPR_innehåll_ST_plats_EV_of"();
-- DESCRIPTIONS -------------------------------------------------------------------------------------------------------
--
-- Descriptions in the model are added as comments on the schema, tables, and the columns holding values and
-- references, making them available to catalogs and semantic layers.
--
COMMENT ON SCHEMA dw IS 'Example model of a theatre business: stages (venues) where programs (shows) are played by actors, and the individual events (performances) at which a program is played on a stage.';
COMMENT ON TABLE knots."PAT_Föräldratyp" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON COLUMN knots."PAT_Föräldratyp"."PAT_Föräldratyp" IS 'Kind of parent-child relationship between two actors, such as biological or adoptive parent.';
COMMENT ON TABLE knots."GEN_Kön" IS 'Gender of an actor.';
COMMENT ON COLUMN knots."GEN_Kön"."GEN_Kön" IS 'Gender of an actor.';
COMMENT ON TABLE knots."PLV_Yrkesnivå" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON COLUMN knots."PLV_Yrkesnivå"."PLV_Yrkesnivå" IS 'Professional level of an actor, describing experience and seniority, such as amateur, trained or professional.';
COMMENT ON TABLE knots."UTL_Utnyttjande" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON COLUMN knots."UTL_Utnyttjande"."UTL_Utnyttjande" IS 'Utilization expressed as a percentage (0-100) of the capacity of a stage that is in use.';
COMMENT ON TABLE knots."ONG_Pågående" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON COLUMN knots."ONG_Pågående"."ONG_Pågående" IS 'Yes or No flag indicating whether a relationship is still ongoing or has ended.';
COMMENT ON TABLE knots."RAT_Betyg" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN knots."RAT_Betyg"."RAT_Betyg" IS 'Rating of how well an actor performs a part in a program, such as good, mediocre or bad.';
COMMENT ON COLUMN attributes."EV_DAT_Händelse_Datum_Posit"."EV_DAT_Händelse_Datum" IS 'Date and time when the event took place.';
COMMENT ON COLUMN attributes."EV_AUD_Händelse_Publik_Posit"."EV_AUD_Händelse_Publik" IS 'Number of people in the audience at the event.';
COMMENT ON COLUMN attributes."EV_REV_Händelse_Intäkt_Posit"."EV_REV_Händelse_Intäkt" IS 'Revenue from ticket sales for the event.';
COMMENT ON COLUMN attributes."EV_STA_Händelse_Status_Posit"."EV_STA_Händelse_Status" IS 'Status of the event, which may change until it has taken place.';
COMMENT ON COLUMN attributes."EV_LVL_Händelse_Level_Posit"."EV_LVL_PLV_ID" IS 'Professional level required for the event, over time.';
COMMENT ON COLUMN attributes."ST_NAM_Scen_Namn_Posit"."ST_NAM_Scen_Namn" IS 'Name of the stage. Historized, since a stage may be renamed over time.';
COMMENT ON COLUMN attributes."ST_LOC_Scen_Plats_Posit"."ST_LOC_Scen_Plats" IS 'Geographic location of the stage as a geography point.';
COMMENT ON COLUMN attributes."ST_AVG_Scen_Medel_Posit"."ST_AVG_UTL_ID" IS 'Average utilization of the stage capacity, recalculated over time.';
COMMENT ON COLUMN attributes."ST_MIN_Scen_Minimum_Posit"."ST_MIN_UTL_ID" IS 'Minimum utilization of the stage capacity required for a performance to take place.';
COMMENT ON COLUMN attributes."AC_NAM_Skådespelare_Namn_Posit"."AC_NAM_Skådespelare_Namn" IS 'Name of the actor, such as a stage name. Historized, since it may change over time.';
COMMENT ON COLUMN attributes."AC_GEN_Skådespelare_Kön_Posit"."AC_GEN_GEN_ID" IS 'Gender of the actor.';
COMMENT ON COLUMN attributes."AC_PLV_Skådespelare_Yrkesnivå_Posit"."AC_PLV_PLV_ID" IS 'Professional level of the actor, which may change as the actor gains experience.';
COMMENT ON COLUMN attributes."PR_NAM_Föreställning_Namn_Posit"."PR_NAM_Föreställning_Namn" IS 'Name or title of the program.';
COMMENT ON COLUMN attributes."PR_LEN_Föreställning_Längd_Posit"."PR_LEN_Föreställning_Längd" IS 'Running time of the program. Historized, since the program may be shortened or extended over time.';
COMMENT ON TABLE anchors."PN_Person" IS 'A person. Persons who perform are also registered as actors.';
COMMENT ON TABLE anchors."ST_Scen" IS 'A stage or venue where programs are played and events are held.';
COMMENT ON TABLE anchors."AC_Skådespelare" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON TABLE nexuses."EV_Händelse" IS 'An event, a single performance of a program held at a stage at a specific date and time.';
COMMENT ON COLUMN nexuses."EV_Händelse"."ST_ID_hölls" IS 'The stage at which the event was held.';
COMMENT ON COLUMN nexuses."EV_Händelse"."PR_ID_spelades" IS 'The program that was played at the event.';
COMMENT ON TABLE ties."AC_partner_AC_with_ONG_currently_Posit" IS 'Marriage or domestic partnership between two actors. This is a one-to-one relationship, since an actor can have at most one partner at any point in time. History is never deleted, so the end of a partnership is recorded by changing its ongoing status to No.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_partner" IS 'One of the actors in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Posit"."AC_ID_with" IS 'The other actor in the partnership.';
COMMENT ON COLUMN ties."AC_partner_AC_with_ONG_currently_Posit"."ONG_ID_currently" IS 'Whether the partnership is still ongoing (Yes) or has ended (No).';
COMMENT ON COLUMN ties."AC_subset_PN_of_Posit"."AC_ID_subset" IS 'An actor, a person who performs parts in programs and is cast in events.';
COMMENT ON COLUMN ties."AC_subset_PN_of_Posit"."PN_ID_of" IS 'The person who is the actor.';
COMMENT ON TABLE ties."EV_in_AC_rollsattes_Posit" IS 'The actors that were cast in an event, meaning those who performed at that performance.';
COMMENT ON COLUMN ties."EV_in_AC_rollsattes_Posit"."EV_ID_in" IS 'The event the actor was cast in.';
COMMENT ON COLUMN ties."EV_in_AC_rollsattes_Posit"."AC_ID_rollsattes" IS 'An actor cast in the event.';
COMMENT ON TABLE ties."AC_deltar_PR_in_RAT_fick_Posit" IS 'Actors having a part in a program, along with a rating of how well they perform the part. Historized, since the rating may change over time.';
COMMENT ON COLUMN ties."AC_deltar_PR_in_RAT_fick_Posit"."AC_ID_deltar" IS 'The actor having a part in the program.';
COMMENT ON COLUMN ties."AC_deltar_PR_in_RAT_fick_Posit"."PR_ID_in" IS 'The program the actor has a part in.';
COMMENT ON COLUMN ties."AC_deltar_PR_in_RAT_fick_Posit"."RAT_ID_fick" IS 'The rating the actor got for the part.';
COMMENT ON TABLE ties."ST_at_PR_spelas_Posit" IS 'Programs that are currently playing at stages, meaning which stage is running which program. Historized over time.';
COMMENT ON COLUMN ties."ST_at_PR_spelas_Posit"."ST_ID_at" IS 'The stage where the program is playing.';
COMMENT ON COLUMN ties."ST_at_PR_spelas_Posit"."PR_ID_spelas" IS 'The program playing at the stage.';
COMMENT ON TABLE ties."AC_förälder_AC_barn_PAT_har_Posit" IS 'Parent-child relationships between actors, along with the type of parental relationship.';
COMMENT ON COLUMN ties."AC_förälder_AC_barn_PAT_har_Posit"."AC_ID_förälder" IS 'The actor who is the parent.';
COMMENT ON COLUMN ties."AC_förälder_AC_barn_PAT_har_Posit"."AC_ID_barn" IS 'The actor who is the child.';
COMMENT ON COLUMN ties."AC_förälder_AC_barn_PAT_har_Posit"."PAT_ID_har" IS 'The type of parental relationship.';
COMMENT ON TABLE ties."PR_innehåll_ST_plats_EV_of_Posit" IS 'The program content and stage location of an event, connecting each event to what was played and where. This deliberately repeats the wasHeldAt and wasPlayed roles of the Event nexus, to show that the same fact can be modeled either as nexus roles or as a tie.';
COMMENT ON COLUMN ties."PR_innehåll_ST_plats_EV_of_Posit"."PR_ID_innehåll" IS 'The program that made up the content of the event.';
COMMENT ON COLUMN ties."PR_innehåll_ST_plats_EV_of_Posit"."ST_ID_plats" IS 'The stage where the event was located.';
COMMENT ON COLUMN ties."PR_innehåll_ST_plats_EV_of_Posit"."EV_ID_of" IS 'The event.';
